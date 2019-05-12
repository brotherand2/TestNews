//
//  SNBaseWebViewController.m
//  sohunews
//
//  Created by yangln on 2016/12/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.


#import "SNBaseWebViewController.h"
#import "SNWKWebView.h"
#import "SNNewsLoginManager.h"

#import "SNNewsPPLoginCookie.h"

@implementation SNBaseWebViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.isShowReport = YES;
        self.isShowMask = YES;
        self.newsTitle = [query stringValueForKey:kTitle defaultValue:@""];
        if (self.newsTitle.length == 0) {
            self.newsTitle = kUniversalTitle;
        }
        self.webViewType = [[query stringValueForKey:kUniversalWebViewType defaultValue:@""] integerValue];
        
        if ([[query objectForKey:kFrom] isEqualToString:@"todaywidget"]) {
            self.newsLink = [query stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:@""];
        }
        else {
            self.newsLink = [query stringValueForKey:kLink defaultValue:@""];
        }
        
        if (_webViewType == FullScreenADWebViewType) {
            self.statusHidden = YES;//子类的 - (BOOL)prefersStatusBarHidden 中设置statusbar是否隐藏
            if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
                self.statusHidden = NO;
            }
            if (self.newsLink && self.newsLink.length) {
                NSArray *tmpArray = [self.newsLink componentsSeparatedByString:[SNUtility fullScreenADServerFlagString]];
                if ([tmpArray count] > 1) {
                    self.newsLink = tmpArray[0];
                    self.predownloadKey = tmpArray[1];
                    //@qz 2017.8.11 杨立说必须先去预缓存接口里拿物料 才能得到服务器下发的要predownload的广告的本地地址 预缓存接口就是指snadStartPerdonwloadWithParam 参数dic里面的itemspaceid=12224、itemspaceid=12355开机时候都要请求一遍
                    self.predownloadLocalUrl = [[SNADManager sharedSTADManager] localFileExitsForRemote:_predownloadKey];
                    if (_predownloadLocalUrl && [[_predownloadLocalUrl absoluteString] length]){
                        NSString *realString = [_predownloadLocalUrl absoluteString];
                        _predownloadLocalUrl = [NSURL fileURLWithPath:realString];
                    }
                }
            }
        }
        
        if (!self.newsLink || self.newsLink.length==0) {
            self.termID = [query stringValueForKey:kTermId defaultValue:@""];
        }
        
        self.packId = [query stringValueForKey:kPackId defaultValue:@""];
        self.newsOriginLink = self.newsLink;
        self.stockCode = [query stringValueForKey:kStockCodeKey defaultValue:@""];
        self.stockFrom = [query stringValueForKey:kStockFromKey defaultValue:@""];
        self.channelId = [query stringValueForKey:kChannelId defaultValue:@""];
        self.channelCategoryId = [query stringValueForKey:kCategoryId defaultValue:@""];
        self.delegate = [query objectForKey:@"delegate"];
        self.photoLink = [query stringValueForKey:kPhoto defaultValue:@""];//分享搜狐我的
        self.landscape = [[query stringValueForKey:kLandscape defaultValue:@""] boolValue];
        self.forceBack = [[query stringValueForKey:kWebViewForceBackKey defaultValue:@""] boolValue];
        self.refer = [query stringValueForKey:kRefer defaultValue:@""];
        self.shouldHideShareButton = [[query stringValueForKey:kNormalWebviewHideShareButton defaultValue:@"0"] boolValue];
        
        NSString* fromreadZone = [query stringValueForKey:@"fromreadZone" defaultValue:@""];
        if (fromreadZone && [fromreadZone isEqualToString:@"1"]) {
            _isSohunewsclient_h5_title = YES;
            _isUse_h5_title = YES;
        }
        else{
            _isUse_h5_title = NO;
        }
        
        if ([self.newsLink containsString:@"sohunewsclient_h5_title=hide"]){
            _isSohunewsclient_h5_title = NO;
            _isUse_h5_title = YES;
        }
        
        self.showTitleBar = YES;
        
        [self variableReassigned:query];
        [self processTitleBar];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.backgroundView];
    
    if ([self useWKWebView]) {
        [self initUniversalWKWebView];
    }else{
        [self initUniversalWebView];
    }
    NSString * urlstr = [self getUrlString];
    //去除掉url首尾的空白字符和换行字符
    urlstr = [urlstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self openWebView:[NSURL URLWithString:urlstr]];
    
    self.loadingView.status = SNTripletsLoadingStatusStopped;
    
    [self initNavigationBarAndToolbar];
    
    if (_webViewType != FullScreenADWebViewType) {
        [self.backgroundView addSubview:self.progressBar];
    }

    if ([self.newsLink containsString:kUrlReadHistory] || [self.newsLink containsString:kUrlPushHistory]) {
        [self banLongPressGesture];
    }
    
    [SNNotificationManager addObserver:self selector:@selector(handleWebViewProgressDidChange:) name:kSNWebViewProgressDidChangedNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(updateFontTheme) name:kFontModeChangeNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleWebPage) name:kUserDidCancelLoginNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(updateRedPacketPage) name:kReceiveRedPacketSucceedNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(updateBaseWebControllerTheme:) name:kThemeDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backgroundView.backgroundColor = SNUICOLOR(kThemeBg5Color);
    
    self.swipeGestureUp = [self getGesture:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:self.swipeGestureUp];
    
    self.swipeGestureDown = [self getGesture:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:self.swipeGestureDown];
    
    self.scrollViewOffsetY = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_universalWebView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.universalWebView.scrollView.scrollsToTop = YES;
            [self.universalWebView callJavaScript:[NSString stringWithFormat:@"window.changeFontSize(%@)",[NSNumber numberWithInteger:[SNUtility getNewsFontSizeIndex] - 2]] forKey:nil callBack:nil];
        });
    }
    self.isClickHistoryNews = NO;
    
    BOOL nightMode = NO;
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        nightMode = YES;
    }
    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.nightModeChanged" withObject:[NSNumber numberWithBool:nightMode]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [self prefersStatusBarHidden];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.popoverView) {
        [self.popoverView dismiss];
    }
    
    //奥运红包
    if ([self.newsOriginLink containsString:@"olympicredpacket"]) {
        [SNNewsReport reportADotGif:@"_act=ayhongbao&_tp=bak"];
    }
}

#pragma mark variable
- (void)processTitleBar {
    if (self.newsLink.length > 0) {
        if ([[SNUtility getApplicationDelegate] isNetworkReachable]) {//避免无网络标题栏空白
            [self checkNativeURL:[NSURL URLWithString:self.newsLink]];
        }else {
            if ([self.newsLink containsString:kUrlReadHistory] || [self.newsLink containsString:kUrlPushHistory]) {
                self.isNativeH5 = YES;
            }
        }
    }
}

- (void)variableReassigned:(NSDictionary *)dict {
    switch (self.webViewType) {
        case SpecialWebViewType:
            self.newsTitle = kUniversalTitle;
            self.isShowReport = NO;
            self.refer = kTermId;
            self.referId = [dict stringValueForKey:kTermId defaultValue:@""];
            break;
        case FeedBackWebViewType:
            if ([[dict objectForKey:@"allQuestionUrl"] length] > 0) {
                self.newsOriginLink = [dict stringValueForKey:@"allQuestionUrl" defaultValue:@""];
            }
            break;
        default:
            break;
    }
}

- (UISwipeGestureRecognizer *)getGesture:(UISwipeGestureRecognizerDirection)direction {
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
    gesture.direction = direction;
    gesture.delegate = self;
    return gesture;
}

- (NSString *)getUrlString {
    NSString *string = self.newsOriginLink;
    if (self.webViewType == SpecialWebViewType) {
        NSString *termIdString = @"";
        if (self.newsLink.length > 0) {
            NSArray *array = [self.newsLink componentsSeparatedByString:@"//"];
            if ([array count] > 0) {
                termIdString = [array lastObject];
            }
            if (![termIdString containsString:@"termId"]) {
                termIdString = [NSString stringWithFormat:@"termId=%@", self.termID];
            }
        }
        if (termIdString.length == 0) {
            termIdString = [NSString stringWithFormat:@"termId=%@", self.termID];
        }
        
        NSDictionary *dict = [SNUtility parseURLParam:self.newsLink schema:kProtocolSpecial];
        if ([self.newsLink containsString:SNLinks_Domain_3gK]) {
            NSString *specialLink = [SNUtility changeSohuLinkToProtocol:self.newsLink];
            NSDictionary *dictParse = [SNUtility parseProtocolUrl:specialLink schema:kProtocolSpecial];
            termIdString = [NSString stringWithFormat:@"termId=%@", [dictParse stringValueForKey:@"termId" defaultValue:@""]];
        }
        string = [NSString stringWithFormat:@"%@?%@&fontSize=%d", [SHUrlMaping getLocalPathWithKey:SH_JSURL_SPECIAL], termIdString, [SNUtility getNewsFontSizeIndex]];
        self.channelId = [dict objectForKey:@"channelId"];
    }
    else if (self.webViewType == ChannelPreviewWebViewType) {
        NSString *channelHtml = nil;
        if ([self.channelId isEqualToString:@"47"] || [self.channelId isEqualToString:@"54"]) {//47美图频道，54奇趣频道
            channelHtml = [SHUrlMaping getLocalPathWithKey:SH_JSURL_PICS];
        }
        else if ([self.channelId isEqualToString:@"25"]) {//互动直播
            channelHtml = [SHUrlMaping getLocalPathWithKey:SH_JSURL_LIVE];
        }
        else {
            channelHtml = [SHUrlMaping getLocalPathWithKey:SH_JSURL_CHANNEL];
        }
        string = [NSString stringWithFormat:@"%@?channelId=%@&categoryId=%@", channelHtml, self.channelId, self.channelCategoryId];
    }
    else if (self.webViewType == RedPacketTaskWebViewType) {
        SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
        if (![string containsString:@"packId="]) {
            if (![string containsString:@"?"]) {
                string = [string stringByAppendingFormat:@"?packId=%@", item.redPacketId];
            }
            else {
                string = [string stringByAppendingFormat:@"&packId=%@", item.redPacketId];
            }
        }
    }
    else if (self.webViewType == RedPacketWebViewType){
        NSString *parameter = nil;
        if ([string containsString:@"?"]) {
            parameter = @"%@&isSupportRedPacket=%d&packId=%@";
        }
        else {
            parameter = @"%@?isSupportRedPacket=%d&packId=%@";
        }
        string = [NSString stringWithFormat:parameter, string, [SNRedPacketManager sharedInstance].joinActivity, self.packId];
    }
    else if (self.webViewType == FeedBackWebViewType) { // 反馈问题页面
        string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        string = [SNUtility addParamModeToURL:string];
    }
    
    int nonePictureMode = [SNPreference sharedInstance].pictureMode;
    if (nonePictureMode > 0) {
        nonePictureMode = 1;
    }
    if ([SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        if (NSNotFound == [string rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
            string = [NSString stringWithFormat:@"%@?picMode=%d", string, nonePictureMode];
        }
        else {
            string = [NSString stringWithFormat:@"%@&picMode=%d", string, nonePictureMode];
        }
    }
    //避免类似https://po.baidu.com/feed/share?isBdboxShare=1&context={%22nid%22:%22news_3438436642049943023%22,%22sourceFrom%22:%22bjh%22}，[NSURL URLWithString:urlstr]为nil(含有大括号引起)---------强制UTF8处理
    if ([string isContainChineseCharacter] || [string containsString:@"{"] || [string containsString:@"}"]) {
        return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    return string;
}

- (NSURL *)urlAppendingTimeStamps:(NSURL *)URL {
    NSString * urlString = [URL absoluteString];
    if (urlString.length > 0 && ![urlString containsString:@"timestamp="]) {
        if ([URL.absoluteString containsString:@"?"]) {
            NSString *timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
            URL = [NSURL URLWithString:[URL.absoluteString stringByAppendingFormat:@"&timestamp=%@",timestamp]];
        }else {
            NSString *timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
            URL = [NSURL URLWithString:[URL.absoluteString stringByAppendingFormat:@"?timestamp=%@",timestamp]];
        }
    }
    return URL;
}

- (NSURL *)urlChenkingNightTheme:(NSURL *)URL {
    NSString *urlString = [URL absoluteString];
    if (![urlString containsString:SNLinks_Domain_3gK]) {
        return URL;
    }
    
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        urlString = [SNUtility addParamModeToURL:urlString];
    }

    return [NSURL URLWithString:urlString];
}

#pragma mark init function
- (void)initUniversalWebView {
    SHH5CommonApi *commonApi = [SHH5CommonApi shareInstance];
    commonApi.delegate = self;
    if ([self.newsLink containsString:@"h5apps/newssdk.sohu.com/modules/readZone/readZone.html"]) {
        self.universalWebView.scrollView.alwaysBounceVertical = NO;
    }
    
    if (self.webViewType == ReadHistoryWebViewType) {
        self.universalWebView.scrollView.bounces = NO;
        self.universalWebView.scrollView.contentSize = CGSizeMake(self.universalWebView.frame.size.width, 0);
    }
    
    [self registJavaScriptInterFace];
    if (self.webViewType == FeedBackWebViewType) {
        self.universalWebView.backgroundColor = SNUICOLOR(kThemeBg3Color);
    }
    [self.backgroundView addSubview:self.universalWebView];
    [self setWebNightMode];
    
    if(_webViewType == NormalWebViewType && [[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        _universalWebView.frame = CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - 64);
    }
    if (self.webViewType == FullScreenADWebViewType) {
        _universalWebView.frame = CGRectMake(0, kSystemBarHeight ,CGRectGetWidth(self.universalWebView.frame), kAppScreenHeight-kSystemBarHeight);
        if (self.statusHidden) {
            _universalWebView.frame = CGRectMake(0, 0 ,CGRectGetWidth(self.universalWebView.frame), kAppScreenHeight);
        }
        if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
            _universalWebView.frame = CGRectMake(0, 0 ,CGRectGetWidth(self.universalWebView.frame), 812-44);
        }
    }
}

//@qz WKWebview 初始化
- (void)initUniversalWKWebView {
    if (!_universalWKWebView) {
        WKWebViewConfiguration *wkDefaultConfiguration = [[WKWebViewConfiguration alloc] init];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
            wkDefaultConfiguration.dataDetectorTypes = WKDataDetectorTypeNone;//iOS9 暂时就不管这个参数了 反正默认也是禁止检测
            wkDefaultConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;//iOS 10以上的写法
        }else{
            wkDefaultConfiguration.requiresUserActionForMediaPlayback = NO;
        }
        //陈秋(职位部门不明..)微信说
        //我先说明一下：页面的视频功能是在页面里直接播放的，没有做弹出播放的功能。是只有在客户端ios下才弹出播放，你可以再试一下端外的页面效果，所有的h5里的视频都是在本页面里播放的
        wkDefaultConfiguration.allowsInlineMediaPlayback = YES;//@qz 广告中的视频改为默认不全屏 2017.11.16
    
        //替代 UIWebview中的scalesPageToFit = YES; 如果需要的话
//        NSString *jScript = @"var meta = document.createElement('meta'); \
//        meta.name = 'viewport'; \
//        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
//        var head = document.getElementsByTagName('head')[0];\
//        head.appendChild(meta);";
//
//        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//        [wkDefaultConfiguration.userContentController addUserScript:wkUScript];
        
        //_universalWKWebView = [[SNWKWebView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - kWebUrlViewHeight + 2) configuration:wkDefaultConfiguration];
        
        CGFloat originY = kSystemBarHeight + kWebUrlViewHeight;
        CGFloat originHeight = kAppScreenHeight - originY - 44;
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            originHeight = kAppScreenHeight - originY - 64;
        }
        _universalWKWebView = [[SNWKWebView alloc] initWithFrame:CGRectMake(0, originY, kAppScreenWidth, originHeight) configuration:wkDefaultConfiguration];

        _universalWKWebView.navigationDelegate = self;
        _universalWKWebView.UIDelegate = self;
        _universalWKWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        _universalWKWebView.opaque = NO;
//        if (_webViewType == AdvertisementWebViewType) {
//            //_universalWKWebView.scrollView.contentInset = UIEdgeInsetsMake(kWebUrlViewHeight + 3.0, 0, 100, 0);
//        }
    }
    
    if (self.statusHidden) {
        self.universalWKWebView.frame = CGRectMake(0, 0, CGRectGetWidth(self.universalWKWebView.frame), kAppScreenHeight);
    }
    SHH5CommonApi *commonApi = [SHH5CommonApi shareInstance];
    commonApi.delegate = self;
    //[self registJavaScriptInterFace];
    [self.backgroundView addSubview:_universalWKWebView];
    [self setWebNightMode];
}

-(BOOL)jskitEnable{
    if (_webViewType == FullScreenADWebViewType || _webViewType == AdvertisementWebViewType) {
        return NO;
    }
    return YES;
}

-(BOOL)useWKWebView{
    //return NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        if (_webViewType == FullScreenADWebViewType || _webViewType == AdvertisementWebViewType) {
            return YES;
        }
    }
    return NO;
}

- (void)initNavigationBarAndToolbar {
    [self normalNavigationBarWithType:self.webViewType];
    if (self.webViewType == ReportWebViewType || self.webViewType == ReadHistoryWebViewType) {
        [self addToolbar];
        [self addMoreButton];
    }else if(_webViewType == FullScreenADWebViewType){
        [self.toolBar hideShadowLine];
        _toolBar.frame = CGRectMake(_toolBar.frame.origin.x, kAppScreenHeight-49, _toolBar.frame.size.width, 49);
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            _toolBar.frame = CGRectMake(_toolBar.frame.origin.x, kAppScreenHeight-64, _toolBar.frame.size.width, 64);
        }
        [_toolBar setBackgroundImage:[UIImage imageNamed:@"ico_bg.png"]];
        [_toolBar updateFullADStyle];
        [self normalToolBarWithType:self.webViewType];
    }else{
        [self normalToolBarWithType:self.webViewType];
    }
}

-(void)updateBaseWebControllerTheme:(NSNotification *)notifiction{
    self.backgroundView.backgroundColor = SNUICOLOR(kThemeBg5Color);
}

- (void)registJavaScriptInterFace {
    if (self.webViewType == ChannelPreviewWebViewType) {
        SHH5ChannelApi *jsChannelModel = [[SHH5ChannelApi alloc] init];
        jsChannelModel.delegate = self;
        [self.universalWebView registerJavascriptInterface:jsChannelModel forName:@"channelApi"];
    }
    else if (self.webViewType == FeedBackWebViewType) {
        SNFeedBackApi *feedBackApiModel = [[SNFeedBackApi alloc] init];
        [self.universalWebView registerJavascriptInterface:feedBackApiModel forName:@"FeedBackApi"];
        [self registerJavaScriptNewsAPI];
    }
    else {
        if ([self jskitEnable]) { //广告不开启jskit
            [self registerJavaScriptNewsAPI];
        }
    }
}

- (void)registerJavaScriptNewsAPI {
    //用于优惠券和红包，接收JS事件
    SHHomePageArticleViewJSModel *jsModel = [[SHHomePageArticleViewJSModel alloc] init];
    jsModel.delegate = self;
    self.universalWebView.jsDelegate = self;
    [self.universalWebView registerJavascriptInterface:jsModel forName:@"newsApi"];
}

- (void)normalNavigationBarWithType:(UniversalWebViewType)webViewType {
    if (webViewType == FullScreenADWebViewType) {
        return;
    }
    [self.backgroundView addSubview:self.naviBarImageView];
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2.0, 1.0, 2.0, 1.0);
    UIImage *image = [[UIImage imageNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, image.size.height/2)];
    shadowImageView.top = self.naviBarImageView.height;
    shadowImageView.image = image;
    [self.naviBarImageView addSubview:shadowImageView];
    
    image = [UIImage imageNamed:@"icotitlebar_sohu_v5.png"];
    UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    iconButton.backgroundColor = [UIColor clearColor];
    iconButton.frame = CGRectMake(14.0, kSystemBarHeight + (kHeaderHeight - image.size.width)/2, image.size.width, image.size.height);
    [iconButton setImage:image forState:UIControlStateNormal];
    iconButton.tag = 2;
    [iconButton addTarget:self action:@selector(iconSohuAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.naviBarImageView addSubview:iconButton];
    
    self.titleLabel.frame = CGRectMake(iconButton.right + 14.0, kSystemBarHeight, kAppScreenWidth - iconButton.right - 28.0, self.naviBarImageView.height - kSystemBarHeight);

    if (webViewType == StockMarketWebViewType || webViewType == ChannelPreviewWebViewType) {
        CGFloat moveX = 0;
        if (kAppScreenWidth == 375.0) {
            moveX = 120.0;
        }
        else {
            moveX = 138.0;
        }
        self.titleLabel.size = CGSizeMake(kAppScreenWidth - iconButton.right - moveX, self.naviBarImageView.height - kSystemBarHeight);
        
        self.addedButton.center = self.titleLabel.center;
        self.addedButton.right = kAppScreenWidth - kAddedButtonRightDistance;
        [self.naviBarImageView addSubview:self.addedButton];
    }
}

- (void)normalToolBarWithType:(UniversalWebViewType)webViewType {
    //设置toolbar的图片
    NSString *imageName = nil;
    NSString *pressImageName = nil;
    NSMutableArray *muArray = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < kToolBarButtonCount; i++) {
        if (i == 0) {
            imageName = @"icotext_back_v5.png";
            pressImageName = @"icotext_backpress_v5.png";
            
            if (_webViewType == FullScreenADWebViewType) {
                imageName = @"ico_full_close_v5.png";
                pressImageName = @"ico_full_close_v5.png";
            }
        }
        else if (i == 1) {
            imageName = @"icotab_close_v5.png";
            pressImageName = @"icotab_closepress_v5.png";
        }
        else if (i == 2) {
            imageName = @"icotext_share_v5.png";
            pressImageName = @"icotext_sharepress_v5.png";
            if (_webViewType == FullScreenADWebViewType) {
                imageName = @"ico_full_share_v5.png";
                pressImageName = imageName;
            }
        }
        else {
            imageName = @"icotext_more_v5.png";
            pressImageName = @"icotext_morepress_v5.png";
            if (_webViewType == FullScreenADWebViewType) {
                imageName = @"ico_full_more_v5.png";
                pressImageName = imageName;
            }
        }
        
        UIButton *button = [self setTooBarButton:imageName pressImageName:pressImageName index:kToolBarButtonTag + i];
        [muArray addObject:button];
    }
    
    [self.toolBar setButtons:[NSArray arrayWithArray:muArray] withType:SNToolbarAlignCenter];
    if ([[SNThemeManager sharedThemeManager] isNightTheme] && self.webViewType != SpecialWebViewType && self.webViewType != ChannelPreviewWebViewType && self.webViewType != ActivityWebViewType) {//修改夜间出现白线问题
        CGPoint point = self.toolBar.origin;
        CGSize size = self.toolBar.size;
        self.toolBar.frame = CGRectMake(point.x, point.y - 2, size.width, size.height + 2);
    }
}

- (void)addMoreButton {
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(kAppScreenWidth - kToolbarButtonSize - 10, (self.toolbarView.height - kToolbarButtonSize)/2.0, kToolbarButtonSize, kToolbarButtonSize);
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        //@qz 适配iPhone X 2017.10.9
        moreButton.frame = CGRectMake(kAppScreenWidth - kToolbarButtonSize - 10, (self.toolbarView.height - 19 - kToolbarButtonSize)/2.0, kToolbarButtonSize, kToolbarButtonSize);
    }
    moreButton.backgroundColor = [UIColor clearColor];
    [moreButton setImage:[UIImage imageNamed:@"icotext_more_v5.png"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"icotext_morepress_v5.png"] forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(webViewMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:moreButton];
}

- (UIButton *)setTooBarButton:(NSString *)imageName pressImageName:(NSString *)pressImageName index:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:pressImageName] forState:UIControlStateHighlighted];
    button.tag = index;
    if (index == kToolBarButtonTag + 1) {
        button.hidden = YES;
    }
    else if (index == kToolBarButtonTag + 2) {
        //分享按钮
        if (self.webViewType == FeedBackWebViewType || self.shouldHideShareButton || [self.newsLink containsString:@"h5apps/newssdk.sohu.com/modules/readZone/readZone.html"]) {
            button.hidden = YES;
        }
        self.shareButton = button;
    }
    
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(toolBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    }
    return _backgroundView;
}

- (SHWebView *)universalWebView {
    if (!_universalWebView) {

        _universalWebView = [[SHWebView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - kWebUrlViewHeight + 2)];
        
        if(_webViewType == SpecialWebViewType  && [[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            _universalWebView.frame = CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - 20 - kSystemBarHeight - kWebUrlViewHeight + 2);
        }
        if (_webViewType != FullScreenADWebViewType) {
            _universalWebView.scrollView.contentInset = UIEdgeInsetsMake(kWebUrlViewHeight, 0, 0, 0);
        }
        if ([self jskitEnable]) {
            [_universalWebView setJsDelegate:self];
        }else{
            _universalWebView.delegate = self;
        }
        _universalWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        _universalWebView.scrollView.delegate =self;
        _universalWebView.opaque = NO;
        _universalWebView.allowsInlineMediaPlayback = YES; //@qz 广告中的视频改为默认不全屏 2017.11.16
        _universalWebView.dataDetectorTypes = UIDataDetectorTypeNone;
        _universalWebView.scalesPageToFit = YES;
        _universalWebView.backgroundColor = [UIColor clearColor];
        if (_webViewType != FullScreenADWebViewType) {
            [_universalWebView startObserveProgress];
        }
    }
    return _universalWebView;
}

- (SNToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight],kAppScreenWidth, [SNToolbar toolbarHeight])];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.backgroundView addSubview:_toolBar];
    }
    return _toolBar;
}

- (SNTripletsLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight - kSystemBarHeight)];
        _loadingView.delegate = self;
        [self.backgroundView addSubview:_loadingView];
    }
    return _loadingView;
}

- (SNProgressBar *)progressBar {
    if (!_progressBar) {
        _progressBar = [[SNProgressBar alloc] initWithFrame:CGRectMake(0, kSystemBarHeight + 44.0, kAppScreenWidth, 2.0)];
        _progressBar.layer.cornerRadius = 1.0;
        _progressBar.backgroundColor = [UIColor clearColor];
    }
    return _progressBar;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = self.newsTitle;
        _titleLabel.textColor = SNUICOLOR(kThemeText1Color);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        [self.naviBarImageView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIView *)nightModeView {
    if (!_nightModeView) {
        _nightModeView = [[UIView alloc] initWithFrame:self.view.frame];
        UIColor *color = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
        _nightModeView.backgroundColor = color;
        _nightModeView.alpha = 0.6;
    }
    
    if (_universalWebView) {
        _nightModeView.frame = CGRectMake(0, 0, _universalWebView.scrollView.contentSize.width, _universalWebView.scrollView.contentSize.height);
    }

    return _nightModeView;
}

- (UIImageView *)naviBarImageView {
    if (!_naviBarImageView) {
        _naviBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderHeight + kSystemBarHeight)];
        UIImage *image = [UIImage imageNamed:@"channel_middle_bg.png"];
        _naviBarImageView.image = image;
        _naviBarImageView.userInteractionEnabled = YES;
    }
    return _naviBarImageView;
}

- (UIButton *)addedButton {
    if (!_addedButton) {
        _addedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addedButton.backgroundColor = [UIColor clearColor];
        _addedButton.frame = CGRectMake(0, 0, kAddedButtonWidth, kThemeFontSizeC + 2);
        _addedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _addedButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [_addedButton addTarget:self action:@selector(addedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addedButton;
}

#pragma mark webView process
- (void)openWebView:(NSURL *)URL {
//    URL = [self urlAppendingTimeStamps:URL];
    URL = [self urlChenkingNightTheme:URL];
    
    if (_predownloadLocalUrl && [[_predownloadLocalUrl absoluteString] length]) {
        URL = _predownloadLocalUrl;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [self openRequest:request];
    
    if (self.webViewType == StockMarketWebViewType || self.webViewType == ChannelPreviewWebViewType) {
        [self requestSubscribeStatus];
    }
}

- (void)openRequest:(NSMutableURLRequest *)request {
    if ([self useWKWebView]) {
        if (_predownloadLocalUrl && [[_predownloadLocalUrl absoluteString] length]) {
            NSURL *parentPath = [NSURL URLWithString:[[_predownloadLocalUrl absoluteString] stringByDeletingLastPathComponent]] ;
            [_universalWKWebView loadFileURL:_predownloadLocalUrl allowingReadAccessToURL:parentPath];
        }else{
            [_universalWKWebView loadRequest:request];
        }
    }else{
        [self.universalWebView loadRequest:request];
    }
}

- (void)onBack:(id)sender {
    if (self.isClickHistoryNews) {
        return;
    }
    self.isClickBack = YES;
    
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewController];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)refreshWebView {//wangshun
    self.isWebviewRefresh = YES;
    if (self.isNativeH5) {
        [self.universalWebView reload];
        return;
    }
    if([self useWKWebView]){
        [_universalWKWebView reload];
    }else{
        [_universalWebView reload];
    }
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=wvrefresh&_tp=pv&channelid=%@", self.channelId]];
}

- (void)webViewGoBack {
    if (self.webViewType == ApplicationSohuWebViewType && self.isMPHomeLink) {
        [self webViewClose];
        return;
    }
    
    if ([self.newsLink containsString:@"h5apps/activity/h5_user_activity/index.html"]) {//用户画像立即捐书 容错
        [self webViewClose];
        return;
    }
    
    if ([self.universalWebView canGoBack] && !_forceBack) {
        [self.universalWebView goBack];
        for (UIView *view in self.toolBar.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag == kToolBarButtonTag + 1) {
                    button.hidden = NO;
                    break;
                }
            }
        }
    }
    else {
        if ([self.newsOriginLink containsString:@"://mp.sohu.com/m/main/home/index.action"]) {
            [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
        } else {
            [self webViewClose];
        }
    }
}

- (void)webViewClose {
    NSArray *array = self.flipboardNavigationController.viewControllers;
    if ([array count] > 0 && [[array lastObject] isKindOfClass:NSClassFromString(@"SHH5NewsWebViewController")]) {
        return;
    }
    if (_universalWebView && self.universalWebView.isLoading) {
        [self.universalWebView stopLoading];
    }
    if (_universalWKWebView && [_universalWKWebView isLoading]) {
        [_universalWKWebView stopLoading];
    }
    
    if (self.flipboardNavigationController) {
        if ([self.newsOriginLink containsString:@"://mp.sohu.com/m/main"]) {
            [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
        }
        else if ([self.newsOriginLink containsString:@"readZone/readZone.html"]){//用户画像wangshun
            [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
        }
        else {
            [self.flipboardNavigationController popViewController];
        }
    }
    else {
        SNNavigationController *topNavigation = [TTNavigator navigator].topViewController.flipboardNavigationController;
        if (topNavigation) {
            [topNavigation popViewControllerAnimated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    [self.popoverView dismiss];
    
    if (_universalWebView) {
        if ([_universalWebView jsDelegate]) {
            _universalWebView.jsDelegate = nil;
        }
        [_universalWebView loadHTMLString:@"" baseURL:nil];
        [_universalWebView stopLoading];
        [_universalWebView removeFromSuperview];
        _universalWebView = nil;
    }else if (_universalWKWebView){
        if ([_universalWKWebView jsDelegate]) {
            _universalWKWebView.jsDelegate = nil;
        }
        _universalWKWebView.scrollView.delegate = nil;
        [_universalWKWebView loadHTMLString:@"" baseURL:nil];
        [_universalWKWebView stopLoading];
        [_universalWKWebView removeFromSuperview];
        _universalWKWebView = nil;
    }
}

- (void)webViewGoBackInToolBar {
    BOOL _shouldClose = NO;
    if (self.webViewType == ApplicationSohuWebViewType && self.isMPHomeLink) {
        _shouldClose = YES;
    }
    if (_webViewType == FullScreenADWebViewType){
        _shouldClose = YES;
    }
    if (_shouldClose) {
        [self webViewClose];
        return;
    }
    
    BOOL _shouldGoBack = NO;
    
    if (_universalWebView && [_universalWebView canGoBack] && !_forceBack) {
        _shouldGoBack = YES;
    }
    if (_universalWKWebView && [_universalWKWebView canGoBack] && !_forceBack) {
        _shouldGoBack = YES;
    }
    if (_shouldGoBack) {
        if (_universalWebView) {
            [_universalWebView goBack];
        }else if (_universalWKWebView) {
            [_universalWKWebView goBack];
        }
        for (UIView *view in self.toolBar.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag == kToolBarButtonTag + 1) {
                    button.hidden = NO;
                    break;
                }
            }
        }
    }else {
        if ([self.newsOriginLink containsString:@"://mp.sohu.com/m/main/home/index.action"]) {
            [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
        } else {
            [self webViewClose];
        }
    }
}

- (NSString *)contentTypeStringWithWebviewType:(NSInteger)webViewType {
    switch (self.webViewType) {
        case SpecialWebViewType:
            return @"special";
        case ChannelPreviewWebViewType:
            return @"channel";
        case ActivityWebViewType:
            return @"activityPage";
        case RedPacketWebViewType:
            return @"pack";
        case RedPacketTaskWebViewType:
            return @"pack";
        default:
            return @"web";
    }
}

- (void)reportWebView {
    [SNUtility shouldUseSpreadAnimation:NO];
    
    if(![SNUserManager isLogin]) {//未登录 先登录
//        [SNUtility openLoginViewWithDict:dic];
        
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {
            
            [self reportWebView];
        } Failed:nil];
        
        return;
    }
    
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=wvreport&_tp=pv&channelid=%@", self.channelId]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"100000",@"newsId", nil];
    NSString *type = @"3";
    NSString *urlString = [NSString stringWithFormat:kUrlReport,type];
    urlString = [SNUtility addParamP1ToURL:urlString];
    urlString = [NSString stringWithFormat:@"%@&newsId=%@", urlString, @"100000"];
    urlString = [NSString stringWithFormat:@"%@&url=%@", urlString, self.newsLink];
    urlString = [NSString stringWithFormat:@"%@&channelId=%@", urlString, self.channelId];
    [dic setObject:urlString forKey:kLink];
    [dic setObject:[NSNumber numberWithInt:ReportWebViewType] forKey:kUniversalWebViewType];
    [SNUtility openUniversalWebView:dic];
}

#pragma mark webview share
- (void)webViewShare {
    if (self.newsTitle.length == 0) {
        self.newsTitle = @"";
    }
    
    NSString *content = [self.universalWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('sharecontent')[0].content"];
    if (content.length == 0) {
        content = kFromSohuNewsClient;
    }
    
    NSString *title = [self.universalWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('sharetitle')[0].content"];
    if (title.length == 0) {
        title = self.newsTitle;
    }
    if (self.channelId.length == 0) {
        self.channelId = @"";
    }
    if (self.refer.length == 0) {
        self.refer = @"";
    }
    if (self.referId.length == 0) {
        self.referId = @"";
    }
    //取红包标记
    NSString *shareOn = [self.universalWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('shareon')[0].content"];
    if (shareOn.length == 0) {
        shareOn = @"";
    }
    
    NSString *shareUrl = [self getUrlString];
    if (self.webViewType == ActivityWebViewType || self.webViewType == InterlligentOfferWebViewType) {
        shareUrl = self.newsLink;
    }
    
    NSString *shareLink = nil;
    NSString *encodeShareon = nil;
    if ([shareOn hasPrefix:@"shareon="]) {
        shareLink = @"%@link=%@&title=%@&content=%@&shareOrigin=universalWebView&contentType=%@&channelId=%@&refer=%@&referId=%@&%@&shareType=%@";
        encodeShareon = shareOn;
    }
    else {
        shareLink = @"%@link=%@&title=%@&content=%@&shareOrigin=universalWebView&contentType=%@&channelId=%@&refer=%@&referId=%@&shareOn=%@&shareType=%@";
        encodeShareon = [shareOn URLEncodedString];
    }
    
    if (self.clickActivityPage && [self.universalWebView canGoBack]) {//区分活动子页面
        shareLink = [shareLink stringByAppendingString:@"&origin=activity"];
    }
    
    if ([shareUrl isEqualToString:@"http://mp.sohu.com/m/main/client/index.action"]) {//自媒体分享狐友正文
        NSString* webUrl = self.universalWebView.request.URL.absoluteString;
        if (webUrl && [webUrl hasPrefix:@"https://m.sohu.com/n"]) {
            shareUrl = webUrl;
        }
    }
    
    //
    if ([shareUrl rangeOfString:@"jlp/tg-index.html"].location != NSNotFound) {//判断是金罗盘
        //wangshun 分享bug
        NSString* jlp_share_url = [self.universalWebView.request.URL absoluteString];
        if ([jlp_share_url rangeOfString:@"jlp/tg-index.html"].location == NSNotFound) {
            if (![jlp_share_url isEqualToString:shareUrl]) {
                shareUrl = jlp_share_url;
            }
        }
    }
    
    SNRedPacketItem *redItem = [SNRedPacketManager sharedInstance].redPacketItem;
    NSString *string = [NSString stringWithFormat: shareLink, kProtocolShare, [shareUrl URLEncodedString], [title URLEncodedString], [content URLEncodedString], [self contentTypeStringWithWebviewType:self.webViewType], self.channelId, self.refer, self.referId, encodeShareon, [NSString stringWithFormat:@"%d", redItem.redPacketType]];
    
    [SNUtility openProtocolUrl:string context:nil];
    
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=wvshare&_tp=pv&channelid=%@", self.channelId]];
}

- (NSDictionary*)getShareData{
    if (self.newsTitle.length == 0) {
        self.newsTitle = @"";
    }
    
    NSString *content = [self.universalWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('sharecontent')[0].content"];
    if (content.length == 0) {
        content = kFromSohuNewsClient;
    }
    
    NSString *title = [self.universalWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('sharetitle')[0].content"];
    if (title.length == 0) {
        title = self.newsTitle;
    }
    if (self.channelId.length == 0) {
        self.channelId = @"";
    }
    if (self.refer.length == 0) {
        self.refer = @"";
    }
    if (self.referId.length == 0) {
        self.referId = @"";
    }
    //取红包标记
    NSString *shareOn = [self.universalWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('shareon')[0].content"];
    if (shareOn.length == 0) {
        shareOn = @"";
    }
    
    NSString *shareUrl = [self getUrlString];
    if (self.webViewType == ActivityWebViewType || self.webViewType == InterlligentOfferWebViewType) {
        shareUrl = self.newsLink;
    }
    
    NSString *shareLink = nil;
    NSString *encodeShareon = nil;
    if ([shareOn hasPrefix:@"shareon="]) {
        shareLink = @"%@link=%@&title=%@&content=%@&shareOrigin=universalWebView&contentType=%@&channelId=%@&refer=%@&referId=%@&%@&shareType=%@";
        encodeShareon = shareOn;
    }
    else {
        shareLink = @"%@link=%@&title=%@&content=%@&shareOrigin=universalWebView&contentType=%@&channelId=%@&refer=%@&referId=%@&shareOn=%@&shareType=%@";
        encodeShareon = [shareOn URLEncodedString];
    }
    
    if (self.clickActivityPage && [self.universalWebView canGoBack]) {//区分活动子页面
        shareLink = [shareLink stringByAppendingString:@"&origin=activity"];
    }
    
    if ([shareUrl isEqualToString:@"http://mp.sohu.com/m/main/client/index.action"]) {//自媒体分享狐友正文
        NSString* webUrl = self.universalWebView.request.URL.absoluteString;
        if (webUrl && [webUrl hasPrefix:@"https://m.sohu.com/n"]) {
            shareUrl = webUrl;
        }
    }
    
    //
    if ([shareUrl rangeOfString:@"jlp/tg-index.html"].location != NSNotFound) {//判断是金罗盘
        //wangshun 分享bug
        NSString* jlp_share_url = [self.universalWebView.request.URL absoluteString];
        if ([jlp_share_url rangeOfString:@"jlp/tg-index.html"].location == NSNotFound) {
            if (![jlp_share_url isEqualToString:shareUrl]) {
                shareUrl = jlp_share_url;
            }
        }
    }
    
    SNRedPacketItem *redItem = [SNRedPacketManager sharedInstance].redPacketItem;
    NSString *string = [NSString stringWithFormat: shareLink, kProtocolShare, [shareUrl URLEncodedString], [title URLEncodedString], [content URLEncodedString], [self contentTypeStringWithWebviewType:self.webViewType], self.channelId, self.refer, self.referId, encodeShareon, [NSString stringWithFormat:@"%d", redItem.redPacketType]];
    
    NSDictionary* dic = [SNUtility createShareData:string Context:nil];
    return dic;
}

- (void)shareToAlipay:(SNActionMenuOption)actionMenuOption shareUrl:(NSString *)shareUrl {
    SNAPOpenApiHelper *openApiHelper =  [SNAPOpenApiHelper sharedInstance];
    if (openApiHelper.isAPAppInstalled == NO) {
        
        SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:@"未安装支付宝客户端" cancelButtonTitle:@"我知道了" otherButtonTitle:nil];
        [alert show];
        return;
    }
    
    NSDictionary *dic = [SNUtility parseURLParam:shareUrl schema:kProtocolSharethirdpart];
    NSString *link = [dic stringValueForKey:kLink defaultValue:@""];
    NSString *pics = [dic stringValueForKey:kIcon defaultValue:@""];
    NSString *title = [dic stringValueForKey:kTitle defaultValue:@""];
    NSString *content = [dic stringValueForKey:kContent defaultValue:@""];
    
    openApiHelper.text = [content URLDecodedString];
    openApiHelper.title = [title URLDecodedString];
    openApiHelper.desc = [content URLDecodedString];
    openApiHelper.wepageUrl = [link URLDecodedString];
    openApiHelper.thumbUrl = [pics URLDecodedString];
    openApiHelper.shareType =  ShareTypeWebByUrl;
    
    NSString *targetName = nil;
    if (actionMenuOption == SNActionMenuOptionAliPaySession)
    {
        openApiHelper.scene = APSceneSession;
        targetName = @"alipayFriend";
    }
    if (actionMenuOption == SNActionMenuOptionAliPayLifeCircle)
    {
        openApiHelper.scene = APSceneTimeLine;
        targetName = @"alipayCircle";
    }
    [openApiHelper shareToAPScene];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithInteger:ShareTargetSNS] forKey:kShareTargetKey];
    [dict setValue:[dic stringValueForKey:@"logstaisType" defaultValue:@""] forKey:kShareInfoKeyShareType];
    [dict setValue:targetName forKey:kShareTargetNameKey];
    [dict setValue:[dic stringValueForKey:@"sourceId" defaultValue:@""] forKey:kShareInfoKeyNewsId];
    [SNNewsReport reportShareWithInfo:dict];
}

#pragma mark open new page
#pragma mark 处理二代协议
- (BOOL)processProtocolV2:(NSString *)urlString navigationType:(UIWebViewNavigationType)navigationType {
    BOOL isFromH5 = [urlString containsString:kH5NoTriggerIOSClick] && [SNUtility isProtocolV2:urlString];//h5拦截了navigationType事件，使用kH5NoTriggerIOSClick标记点击事件
    
    if ([urlString hasPrefix:kSchemeUrlSNS]) {
        if (navigationType != UIWebViewNavigationTypeLinkClicked && !isFromH5) {
            [self popToPreController];
        }
        return YES;
    }
    else if ([urlString hasPrefix:kProtocolSubscirbe]) {
        NSString *prefixStr = [NSString stringWithFormat:@"%@subId=",kProtocolSubscirbe];
        NSString *subId = [urlString substringFromIndex:[prefixStr length]];
        [[SNSubscribeCenterService defaultService] dealSubInfoFromServerBySubId:subId operationTopic:kTopicAddSubInfo];
        return YES;
    }
    else if ([urlString hasPrefix:kProtocolSharethirdpart] || [urlString hasPrefix:kBrowserShareContent] || [urlString hasPrefix:kProtocolShare]) {
        [self openShareFloat:urlString];
        return NO;
    }
    else if([urlString hasPrefix:@"videofullscreen://"]){
        [SNUtility openProtocolUrl:urlString];
        return NO;
    }
    else {
        return [self openNormalProtocol:urlString  navigationType:navigationType isFromH5:isFromH5];
    }
    
    return YES;
}

- (void)openShareFloat:(NSString *)urlString {
    NSString *scheme = kProtocolShare;
    if ([urlString hasPrefix:kProtocolSharethirdpart]) {
        scheme = kProtocolSharethirdpart;
    }
    else if ([urlString hasPrefix:kBrowserShareContent]) {
        scheme = kBrowserShareContent;
    }
    
    NSDictionary *dictInfo = [SNUtility parseURLParam:urlString schema:scheme];
    NSString *toThrdPart = [dictInfo stringValueForKey:@"to" defaultValue:@""];
    if ([toThrdPart isEqualToString:@"alipaylife"]) {
        //生活圈
        [self shareToAlipay:SNActionMenuOptionAliPayLifeCircle shareUrl:urlString];
    }
    else if ([toThrdPart isEqualToString:@"alipayfriends"]){
        //支付宝好友
        [self shareToAlipay:SNActionMenuOptionAliPaySession shareUrl:urlString];
    }
    else {
        NSString *link = [dictInfo stringValueForKey:kLink defaultValue:@""];
        NSString *pics = [dictInfo stringValueForKey:kListPics defaultValue:@""];
        NSString *title = [dictInfo stringValueForKey:kTitle defaultValue:@""];
        NSString *content = [dictInfo stringValueForKey:kContent defaultValue:@""];
        
        NSString *shareString = [NSString stringWithFormat:@"%@link=%@&title=%@&content=%@&pics=%@&shareOrigin=universalWebView", kProtocolShare, link, [title URLDecodedString], [content URLDecodedString], [pics URLDecodedString]];
        
        if ([scheme isEqualToString:kProtocolShare]) {
            NSString *shareOn = [dictInfo stringValueForKey:kShareOnKey defaultValue:@""];
            shareString = [shareString stringByAppendingFormat:@"&shareon=%@", shareOn];
        }
        
        [SNUtility openProtocolUrl:shareString context:nil];
    }
}

- (BOOL)openNormalProtocol:(NSString *)urlString navigationType:(UIWebViewNavigationType)navigationType isFromH5:(BOOL)isFromH5 {
    if ([urlString hasPrefix:kProtocolNews]) {
        if (self.webViewType != ReadHistoryWebViewType) {
            //展开动画中使用当前点击纵坐标
            NSDictionary *dict = [SNUtility parseURLParam:urlString schema:kProtocolNews];
            CGFloat linkTop = [[dict stringValueForKey:kH5LinkTop defaultValue:@""] floatValue];
            [SNUserDefaults setDouble:linkTop forKey:kRememberCellOriginYInScreen];
            [SNUtility shouldUseSpreadAnimation:YES];
        }
        [SNUtility openProtocolUrl:urlString];
        return NO;
    }
    else if ([urlString containsString:kLoginBackUrl]) {
        [SNUtility shouldUseSpreadAnimation:NO];
        NSDictionary *dict = @{@"newslink":self.newsLink, kWebViewForceBackKey:[NSNumber numberWithBool:self.forceBack]};
        if ([[urlString URLDecodedString] containsString:@"coupon.sohu.com"]) {
            dict = @{@"newslink":self.newsLink, kUniversalWebViewType:[NSNumber numberWithInteger:MyTicketsListWebViewType], kWebViewForceBackKey:[NSNumber numberWithBool:self.forceBack]};
        }
        //======暂时这样处理(延迟执行，避免push动画未执行完成)=======//
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SNUtility openProtocolUrl:urlString context:dict];
        });
        //======暂时这样处理(延迟执行，避免push动画未执行完成)=======//
        return NO;
    }
    else if ([urlString hasPrefix:kProtocolStoryNovelDetail]) {
        //展开动画中使用当前点击纵坐标
        NSDictionary *dict = [SNUtility parseURLParam:urlString schema:kProtocolNews];
        CGFloat linkTop = [[dict stringValueForKey:kH5LinkTop defaultValue:@""] floatValue];
        [SNUserDefaults setDouble:linkTop forKey:kRememberCellOriginYInScreen];
        [SNUtility shouldUseSpreadAnimation:YES];
        [SNUtility openProtocolUrl:urlString];
        return NO;
    }

    else {
        if (navigationType != UIWebViewNavigationTypeLinkClicked && !isFromH5 && self.webViewType != ReadHistoryWebViewType && ![urlString containsString:kProtocolThirdParty]) {
            [self popToPreController];
        }
        
        if (self.webViewType == RedPacketTaskWebViewType || self.webViewType == RedPacketWebViewType || self.webViewType == ActivityWebViewType || self.webViewType == MyTicketsListWebViewType || self.webViewType == NormalWebViewType) {
            urlString = [NSString stringWithFormat:@"%@&contentType=%@", urlString, [self contentTypeStringWithWebviewType:RedPacketTaskWebViewType]];
        }
        
        if (self.webViewType == ChannelPreviewWebViewType) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:kTagChannalNews forKey:kNewsFrom];
            [SNUtility openProtocolUrl:urlString context:dic];
            return NO;
        } else if (_webViewType == SpecialWebViewType) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:kTopicNews forKey:kNewsFrom];
            [SNUtility openProtocolUrl:urlString context:dic];
            return NO;
        }
        if (self.webViewType != SpecialWebViewType) {
            [SNUtility shouldUseSpreadAnimation:NO];
        }
        if ([urlString hasPrefix:kProtocolPaper]) {
            urlString = [urlString stringByReplacingOccurrencesOfString:kProtocolPaper withString:kProtocolSubHome];
        }
        else if ([urlString hasPrefix:kProtocolDataFlow]) {
            urlString = [urlString stringByReplacingOccurrencesOfString:kProtocolDataFlow withString:kProtocolSubHome];
        }
        if ([urlString hasPrefix:kProtocolChannel]) {
            [self popToTabShowViewController];
        }
        
        if (self.webViewType == StockChannelLoginWebViewType) {
            self.forceBack = YES;
        }
        
        [SNUtility openProtocolUrl:urlString context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.webViewType], kUniversalWebViewType, [NSNumber numberWithBool:self.forceBack], kWebViewForceBackKey, nil]];
        return NO;
    }
    return NO;
}

#pragma mark 处理3g.k.sohu.com
- (BOOL)processSpecialDomain:(NSString *)urlString navigationType:(UIWebViewNavigationType)navigationType {
    
    BOOL b = NO;
    if (navigationType != UIWebViewNavigationTypeLinkClicked) {
        [self popToPreController];
        b = YES; //广告需要上报 得让它继续刷 wangshun
    }
    //延迟执行，避免push动画未执行完成
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^() {
        [SNUtility openProtocolUrl:[SNUtility changeSohuLinkToProtocol:urlString]];
    });
    
    //是pop的 return YES wangshun
    return b;
}

- (BOOL)processSpecialDomain:(NSString *)urlString WKNavigationType:(WKNavigationType)navigationType {
    BOOL b = NO;
    if (navigationType != WKNavigationTypeLinkActivated) {
        [self popToPreController];
        b = YES;//广告需要上报 得让它继续刷 wangshun
    }
    //延迟执行，避免push动画未执行完成
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^() {
        [SNUtility openProtocolUrl:[SNUtility changeSohuLinkToProtocol:urlString]];
    });
    
    //是pop的 return YES wangshun
    return b;
}

#pragma mark 打开第三方APP
- (BOOL)canOpenThirdPartyApp:(NSString *)urlString {
    if ([SNUtility isContainSchemeWithType:self.refer urlString:urlString]) {
        //根据服务端下发白名单打开
        [self showOpenThirdAppAlert:urlString];
        return YES;
    }
    else if ([SNUtility isWhiteListURL:[NSURL URLWithString:urlString]] && ![SNAPI isWebURL:urlString]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        return YES;
    }
    else if ([SNAPI isItunes:urlString]) {
        //打开APP Store
        [self.progressBar resetProgress];
        [self showAppStoreInApp:[NSURL URLWithString:urlString]];
        return YES;
    }
    else if ([urlString containsString:@"sohuExternalLink=1"]) {
        //延迟执行，避免push动画未执行完成，[self webViewClose]不起作用
        urlString = [[urlString componentsSeparatedByString:@"sohuExternalLink=1"] componentsJoinedByString:@""];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^() {
            //广告添加参数，safari打开
            [self.progressBar resetProgress];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            [self webViewClose];
        });
        return YES;
    }
    
    return NO;
}

- (void)showOpenThirdAppAlert:(NSString *)urlString {
    //一个scheme，alert只显示一次
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *scheme = [url scheme];
    if (scheme && scheme.length > 0 && [SNUserDefaults boolForKey:scheme]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        return;
    }
    
    SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@%@", kJudgeOpenThirdApp, [SNUtility sharedUtility].thirdPartName] cancelButtonTitle:kOpenThirdAppCancel otherButtonTitle:kOpenThirdAppConfirm];
    [alertView show];
    [alertView actionWithBlocksCancelButtonHandler:^{
    } otherButtonHandler:^{
        [SNUserDefaults setBool:YES forKey:scheme];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }];
    [SNUtility sharedUtility].thirdPartName = nil;
}

- (void)showAppStoreInApp:(NSURL *)appStoreURL {
    Class isAllow = NSClassFromString(@"SKStoreProductViewController");
    if (isAllow != nil && ![[UIDevice currentDevice].model isEqualToString:@"iPhone Simulator"]) {
        if (!self.sKStoreProductViewController) {
            self.sKStoreProductViewController = [[SKStoreProductViewController alloc] init];
            self.sKStoreProductViewController.delegate = self;
        }
        NSDictionary *productParams = @{ SKStoreProductParameterITunesItemIdentifier : [self appIdInURL:appStoreURL] };
        
        [self.sKStoreProductViewController loadProductWithParameters:productParams                                                 completionBlock:^(BOOL result, NSError *error) {
            if (!result) {
                SNDebugLog(@"Load product view error:%@",error);
            }
        }];
        if (self.presentedViewController == nil) {
            [self presentViewController:self.sKStoreProductViewController
                               animated:YES
                             completion:nil];
        }
        
    }
    else{
        //低于iOS6没有这个类
        [[UIApplication sharedApplication] openURL:appStoreURL];
    }
}

- (NSString *)appIdInURL:(NSURL *)appStoreURL {
    NSString * appId = nil;
    if ([appStoreURL.absoluteString containsString:@"/id"]) {
        appId = [[appStoreURL.absoluteString componentsSeparatedByString:@"/id"] lastObject];
        if ([appId containsString:@"?"]) appId = [[appId componentsSeparatedByString:@"?"] firstObject];
    }
    
    return appId;
}

//对视图消失的处理
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        if (self.sKStoreProductViewController) {
            self.sKStoreProductViewController.delegate = nil;
            self.sKStoreProductViewController = nil;
        }
        
        [[SNUtility sharedUtility] setLastOpenUrl:nil];
        [self webViewClose];
    }];
}

#pragma mark 种cookie
- (BOOL)needAddCookieForUrlString:(NSString *)urlString request:(NSURLRequest *)request {
    if (![SNUserManager isLogin]) {
        return NO;
    }
    
    BOOL isSoHuNewsDomain = NO;
    NSArray *urlArray = [urlString componentsSeparatedByString:@"?"];
    if ([urlArray count] > 0) {
        isSoHuNewsDomain = [SNUtility isSohuDomain:[urlArray objectAtIndex:0]];
    }
    else {
        isSoHuNewsDomain = [SNUtility isSohuDomain:urlString];
    }
    
    if (isSoHuNewsDomain) {
        NSString *cookieHeader = [SNUtility extractionCookie:urlString key:nil];
        //判断域名下是否种过cookie，没种过则调用redirect.go种cookie
        if ([cookieHeader containsString:@"ppinf"] && [cookieHeader containsString:@"pprdig"]) {
            return NO;
        }
        else{
            [SNNewsPPLoginCookie readArchive];
        }
    }
    else {
        return NO;
    }
    
    BOOL isHttp = [urlString hasPrefix:kProtocolHTTP] || [urlString hasPrefix:kProtocolHTTPS];
    if (isSoHuNewsDomain && isHttp && ![urlString containsString:@"qr_message.html?"] && ![urlString containsString:@"my.k.sohu.com"] && self.webViewType != ChannelPreviewWebViewType && !self.isWebviewRefresh && self.webViewType != ActivityWebViewType) { //做个@"qr_message.html?"的排除法判断吧，暂时先这么改吧
        //Google AD filter
        if ([urlString containsString:@"googleads"] ||
            [urlString containsString:@"doubleclick"]) {
            return YES;
        }
        
        NSString *pid = [SNUserManager getPid] ? : @"-1";
        NSString *token = [SNUserManager getToken] ? : @"";
        NSString *passport = [SNUserManager getUserId] ? : @"";
        if (![urlString containsString:kH5LoginUrlString]) {
            NSString *format = nil;
            if ([urlString containsString:@"?"]) {
                format = @"&u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@";
            }
            else {
                format = @"?u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@";
            }
            
            urlString = [urlString stringByAppendingFormat:format, [SNAPI productId], [SNUserManager getP1], [SNUserManager getGid], pid, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], token, passport];
            urlString = [NSString stringWithFormat:kH5LoginUrl , [urlString URLEncodedString]];
        }
        urlString = [urlString stringByAppendingFormat:@"&u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@", [SNAPI productId], [SNUserManager getP1], [SNUserManager getGid], pid, [[UIDevice currentDevice] uniqueDeviceIdentifier], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], token, passport];
        
        NSMutableURLRequest *newRequest = [request mutableCopy];
        newRequest.timeoutInterval = WEBVIEW_REQUEST_TIMEOUT;
        [newRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];//减少内存占用
        newRequest.URL = [NSURL URLWithString:urlString];
        [self.universalWebView loadRequest:newRequest];
        self.isRedirect = YES;
        return YES;
    }
    return NO;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (_progressBar) {
        [self.progressBar startProgress];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.webViewType == SpecialWebViewType) {
        [self performSelector:@selector(updateSpecialTitle) withObject:nil afterDelay:1.0];
    }else {
        [self updateTitle];
    }
    [self setWebNightMode];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isRedirect = NO;
    });
    if (self.webViewType == FeedBackWebViewType) {
        // 禁用长按弹出框
        [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        self.loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
    }
}

#pragma mark iOS9 WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self updateTitle];
    [self setWebNightMode];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        self.loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
    }
}

//- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
//
//}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_nightModeView) {
        _nightModeView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < self.scrollViewOffsetY || scrollView.contentOffset.y == -kWebUrlViewHeight || scrollView.contentOffset.y == 0) {
        if ([self.newsLink containsString:@"readZone/readZone.html"] || [self.newsOriginLink containsString:@"readPreference/readPreference.html"]) {//用户画像
            return;
        }
        
        [self swipeShowBar:YES];//向下滑动
    }
    
    self.scrollViewOffsetY = scrollView.contentOffset.y;
}

#pragma mark request
- (void)requestSubscribeStatus {
    //子类中使用
}

#pragma mark button action 
- (void)toolBarButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case kToolBarButtonTag: {//返回
            if (_webViewType == FullScreenADWebViewType) {
                [self webViewClose];
            }else{
                [self webViewGoBackInToolBar];
            }
        }
            break;
        case kToolBarButtonTag + 1: {//关闭
            [self webViewClose];
        }
            break;
        case kToolBarButtonTag + 2: {//分享
            [self webViewShare];
        }
            break;
        case kToolBarButtonTag + 3: {//更多
            //外链页面更多按钮点击
            //@qz 埋点
            [SNNewsReport reportADotGif:@"_act=cc&fun=114"];
            [self webViewMore:button];
        }
            break;
        default:
            break;
    }
}

- (void)iconSohuAction:(id)sender {
    //不管在那个tab，点击都回到新闻tab头条流，并刷新
    UIViewController* topController = [TTNavigator navigator].topViewController;
    [SNUtility popToTabViewController:topController];
    //tab切换到新闻
    [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
    //栏目切换到焦点
    [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];
    [SNNotificationManager postNotificationName:kSearchWebViewCancle object:nil];
    if ([SNUtility isFromChannelManagerViewOpened]) {
        [SNNotificationManager postNotificationName:kHideChannelManageViewNotification object:nil];
    }
    [self.popoverView dismiss];
}

- (void)addedButtonAction:(id)sender {
    //子类中使用
}

- (void)webViewMore:(UIButton *)button {
    NSMutableArray *titleArray = [NSMutableArray array];
    NSMutableArray *imageArray = [NSMutableArray array];
    [titleArray addObject:@"刷新"];
    [imageArray addObject:@"icowebview_refresh.png"];
    if (self.webViewType != SpecialWebViewType && self.webViewType != ActivityWebViewType && self.isShowReport == YES) {
        [titleArray addObject:@"举报"];//wangshun
        [imageArray addObject:@"icowebview_report.png"];
    }
    __weak typeof(self)weakself = self;
    [SNPopOverMenu showForSender:button senderFrame:button.frame  withMenu:titleArray imageNameArray:imageArray doneBlock:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0:
                //外链页面更多按钮刷新点击
                //@qz 埋点
                [SNNewsReport reportADotGif:@"_act=cc&fun=115"];
                [weakself refreshWebView];
                break;
            case 1:
                [weakself reportWebView];
                break;
        }
        
    } dismissBlock:^{
    }];
}

- (void)webViewMoreAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    [SNPopOverMenu showForSender:button
                     senderFrame:button.frame
                        withMenu:@[@"刷新"]
                  imageNameArray:@[@"icowebview_refresh.png"]
                       doneBlock:^(NSInteger selectedIndex) {
                           [self refreshWebView];
                       } dismissBlock:^{
                       }];
}

#pragma mark page gesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)swipeGestureAction:(UISwipeGestureRecognizer *)gesture {
    //用户画像禁止收起
    if ([self.newsLink containsString:@"readZone/readZone.html"] || [self.newsOriginLink containsString:@"readPreference/readPreference.html"]) {//用户画像
        return;
    }
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        [self swipeShowBar:NO];
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        [self swipeShowBar:YES];
    }
}

- (void)banLongPressGesture {
    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            UILongPressGestureRecognizer *longGesture = (UILongPressGestureRecognizer *)gesture;
            [self.view removeGestureRecognizer:longGesture];
        }
    }
}

#pragma mark JSKit related
- (BOOL)checkNativeURL:(NSURL *)URL {
    if ([URL.absoluteString isEqualToString:@"about:blank"]) {
        return self.isNativeH5;
    }
    JKWebApp *webApp = [[JKWebAppManager manager] getWebAppWithUrl:URL relativePath:nil];
    if (webApp) {
        self.isNativeH5 = YES;
        return YES;
    }
    else{
        self.isNativeH5 = NO;
        return NO;
    }
}

- (void)swipeShowBar:(BOOL)show {
    if (![SNPreference sharedInstance].autoFullscreenMode || [self.newsLink containsString:kUrlReadHistory] || [self.newsLink containsString:kUrlPushHistory] || self.webViewType == ReportWebViewType) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        CGPoint origin = CGPointMake(0, kAppScreenHeight);
        if (show) {
            origin = CGPointMake(0, kAppScreenHeight - [SNToolbar toolbarHeight]);
        }
        self.toolBar.origin = origin;
        
        BOOL isShowTitle = show;
        if (!self.showTitleBar) {
            isShowTitle = NO;
        }
        [self resetWebviewWithShowTitleBar:isShowTitle isSwipe:YES];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)resetWebviewWithShowTitleBar:(BOOL)show isSwipe:(BOOL)isSwipe {
    CGPoint naviBarOrigin = CGPointZero;
    CGPoint progressBarOrigin = CGPointZero;
    UIEdgeInsets webViewInsets = UIEdgeInsetsZero;
    CGSize webViewSize = CGSizeZero;
    if (show) {
        progressBarOrigin = CGPointMake(0, kSystemBarHeight + 44.0);
        webViewInsets = UIEdgeInsetsMake(kWebUrlViewHeight, 0, 0, 0);
        webViewSize = CGSizeMake(kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - kWebUrlViewHeight);
        if(_webViewType == ActivityWebViewType  && [[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            webViewSize = CGSizeMake(kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - kWebUrlViewHeight - 20);
        }
    }
    else {
        naviBarOrigin = CGPointMake(0, -kHeaderHeight - kSystemBarHeight);
        progressBarOrigin = CGPointMake(0, kSystemBarHeight);
        webViewInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        webViewSize = CGSizeMake(kAppScreenWidth, kAppScreenHeight - kSystemBarHeight - [SNToolbar toolbarHeight]);
        
        if (isSwipe) {
            webViewSize = CGSizeMake(kAppScreenWidth, kAppScreenHeight - kSystemBarHeight);
        }
    }
    
    self.naviBarImageView.origin = naviBarOrigin;
    self.progressBar.origin = progressBarOrigin;
    self.universalWebView.scrollView.contentInset = webViewInsets;
    self.universalWebView.size = webViewSize;
}

#pragma mark update title
- (void)updateTitle {
    if (self.webViewType == ChannelPreviewWebViewType || self.webViewType == FeedBackWebViewType) {
        return;
    }
    if (_universalWebView) {
        self.newsTitle = [_universalWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (!_newsTitle || [_newsTitle length] == 0) {
            self.newsTitle = kUniversalTitle;
        }
        self.titleLabel.text = _newsTitle;
    }else if (_universalWKWebView) {
        __weak __typeof(self)weakSelf = self;
        [_universalWKWebView evaluateJavaScript:@"document.title" completionHandler:^ (id object, NSError * error){
            if ([object isKindOfClass:[NSString class]]) {
                weakSelf.newsTitle = (NSString *)object;
                if (!weakSelf.newsTitle || [weakSelf.newsTitle length] == 0) {
                    weakSelf.newsTitle = kUniversalTitle;
                }
                weakSelf.titleLabel.text = weakSelf.newsTitle;
            }
        }];
    }
}

- (void)updateSpecialTitle {
    NSString *string = [self.universalWebView stringByEvaluatingJavaScriptFromString:@"window.getSpecialData()"];
    //加入一些保护
    if(string.length == 0){
        return;
    }
    NSDictionary *dict = [string JSONDictionary];
    if(!dict || ![dict isKindOfClass:[NSDictionary class]]){
        return;
    }
    
    self.newsTitle = [dict objectForKey:kTitle];
    if (self.newsTitle.length == 0) {
        [self updateTitle];
    }
    else {
        self.titleLabel.text = self.newsTitle;
    }
}

#pragma mark notification
- (void)handleWebViewProgressDidChange:(NSNotification *)notification {
    if (_webViewType == FullScreenADWebViewType) return;
    if (!self.isWebviewLoad) {
        if (self.progressBar.curProgress < 1.0) {
            self.progressBar.curProgress = 1.0;
        }
        return;
    }
    CGFloat progress = [[notification userInfo] floatValueForKey:kSNWebViewCurrentProgressValueKey defaultValue:0];
    self.progressBar.curProgress = progress;
}

- (void)updateFontTheme {
    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.fontChanged" withObject: [NSNumber numberWithInteger:[SNUtility getNewsFontSizeIndex] - 2]];
    
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage setItem:[NSNumber numberWithInteger:[SNUtility getNewsFontSizeIndex] - 2] forKey:@"settings_fontSize"];
}

- (void)handleWebPage {
    if (![SNUserManager isLogin] && self.webViewType == ApplicationSohuWebViewType) {
        [self webViewClose];
    }
}

- (void)updateRedPacketPage {
    NSString *timeString = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
    [self cashOutCallback:YES withRedPacketId:[SNRedPacketManager sharedInstance].redPacketItem.redPacketId withDrawTime:timeString];
}

#pragma mark SNTripletsLoadingVew delegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [self.universalWebView loadHTMLString:@"" baseURL:nil];
    }
    else {
        self.loadingView.status = SNTripletsLoadingStatusStopped;
        [self openWebView:[NSURL URLWithString:[self getUrlString]]];
    }
}

#pragma mark pop controller
- (void)popToPreController {
    NSArray *array = self.flipboardNavigationController.viewControllers;
    for (int i = 0; i < array.count; i++) {
        UIViewController *controller = [array objectAtIndex:i];
        if ([controller isKindOfClass:[SNBaseWebViewController class]]) {
            int popIndex = i - 1;
            if (popIndex >= 0 && popIndex < [array count]) {
                UIViewController *popController = [array objectAtIndex:i];
                [self.flipboardNavigationController popToViewController:popController animated:NO];
                self.universalWebView.jsDelegate = nil;
                self.universalWebView = nil;
            }
        }
    }
}

- (void)popToTabShowViewController {
    NSArray *controllerArray = self.flipboardNavigationController.viewControllers;
    for (UIViewController *viewController in controllerArray) {
        if ([viewController isKindOfClass:NSClassFromString(@"SNSPlaygroundViewController")] || [viewController isKindOfClass:NSClassFromString(@"SNNewMeViewController")]) {
            [self.flipboardNavigationController popToViewController:viewController animated:NO];
            break;
        }
    }
}

#pragma mark night
- (void)setWebNightMode {
    if ([[SNThemeManager sharedThemeManager] isNightTheme] && self.webViewType != SpecialWebViewType && self.webViewType != ChannelPreviewWebViewType && self.webViewType != ActivityWebViewType && ![self.newsOriginLink containsString:@"support/declare.go"] && self.isShowMask) {
        
        if ([self useWKWebView]) {
            if (![_nightModeView superview]) {
                self.nightModeView.tag = 1111;
                _nightModeView.frame = (CGRect){CGPointZero, _universalWKWebView.frame.size};
                _nightModeView.userInteractionEnabled = NO;
                if (_nightModeView) {
                    [_universalWKWebView addSubview:_nightModeView];
                }
            }
        }else{
            if ([self.universalWebView.subviews count] > 0 && [[self.universalWebView.subviews objectAtIndex:0].subviews count] > 0) {
                UIView *view = [[self.universalWebView.subviews objectAtIndex:0].subviews objectAtIndex:0];
                [view addSubview:self.nightModeView];
            }
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        return UIStatusBarStyleLightContent;
    }
    else {
        return UIStatusBarStyleDefault;
    }
}

- (void)dealloc {
    if (self.channelDataSource) {
        [self.channelDataSource removeObservers:self];
    }
    if (_universalWebView) {
        _universalWebView.delegate = nil;
        _universalWebView.jsDelegate = nil;
        [_universalWebView loadHTMLString:@"" baseURL:nil];
        [_universalWebView stopLoading];
        [_universalWebView removeFromSuperview];
    }
    if (_universalWKWebView) {
        _universalWKWebView.scrollView.delegate = nil;
        [_universalWKWebView loadHTMLString:@"" baseURL:nil];
        [_universalWKWebView stopLoading];
        [_universalWKWebView removeFromSuperview];
        _universalWKWebView = nil;
    }
    self.universalWebView = nil;
    self.delegate = nil;
    _photoCtl.delegate = nil;
    
    [SNNotificationManager removeObserver:self];
}

@end
