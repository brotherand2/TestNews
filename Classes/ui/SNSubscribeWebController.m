//
//  SNSubscribeWebController.m
//  sohunews
//
//  Created by ZhaoQing on 15/7/10.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNSubscribeWebController.h"
#import "SNToolbar.h"
#import "SNNotificationCenter.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "SNNewsPaperWebController.h"
#import "SNUserManager.h"
#import "NSString+Utilities.h"
#import "SNSkinManager.h"
#import "SNSubscribeCenterService.h"


#define kIndicatorSize 20
#define kHTMLBodyDetectInterval 0.1
#define kMPMarking @"iosHack=1"

@interface SNSubscribeWebController ()
@property (nonatomic, copy) NSString *rootPageHtmlString;
@property (nonatomic, assign) BOOL isRedirect;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) UIView *nightModeView;
@end

@implementation SNSubscribeWebController

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.query = query;
        NSString *address = [query objectForKey:kLink];
        NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
        if (NSNotFound == [address rangeOfString:@"cid=" options:NSCaseInsensitiveSearch].location) {
            if (address.length) {
                if (NSNotFound == [address rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                    address = [address stringByAppendingFormat:@"?cid=%@", cid];
                } else {
                    address = [address stringByAppendingFormat:@"&cid=%@", cid];
                }
            }
        }
        
        SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
        BOOL isNightMode = [themeManager.currentTheme isEqualToString:@"night"];
        if (isNightMode) {
            if (NSNotFound == [address rangeOfString:@"mode=" options:NSCaseInsensitiveSearch].location) {
                if (address.length) {
                    if (NSNotFound == [address rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                        address = [address stringByAppendingFormat:@"?mode=2"];
                    } else {
                        address = [address stringByAppendingFormat:@"&mode=2"];
                    }
                }
            }
        } else {
            if (NSNotFound == [address rangeOfString:@"mode=" options:NSCaseInsensitiveSearch].location) {
                if (address.length) {
                    if (NSNotFound == [address rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                        address = [address stringByAppendingFormat:@"?mode=1"];
                    } else {
                        address = [address stringByAppendingFormat:@"&mode=1"];
                    }
                }
            }

        }
        
        if (address.length > 0) {
            NSURL *url = [NSURL URLWithString:address];
            self.webUrl = address;
            //如果创建不成功，需要转义下。
            if (!url) {
                address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                url = [NSURL URLWithString:address];
            }
            
            [self openURL:url];
            [self performSelectorInBackground:@selector(loadRootPageHtmlString:) withObject:url];
        }
        
        if ([[query objectForKey:kNewsExpressType] intValue] == 1){
            _isPushed = YES;
        }
        self.hidesBottomBarWhenPushed = YES;
        
        [SNNotificationManager addObserver:self selector:@selector(handleWebViewProgressDidChange:) name:kSNWebViewProgressDidChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)loadRootPageHtmlString:(NSURL *)url {
    self.rootPageHtmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:Nil];
}

- (void)updateWebView {
    [self setWebNightMode];
}

- (SNToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[SNToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - kToolbarHeight, self.view.width, kToolbarHeight)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:_toolbar];
    }
    return _toolbar;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    if (_webView) {
        _webView.delegate = nil;
        [_webView stopObserveProgress];
    }
}

//为了解决"home" icon仍然无法明确退出键的功能的问题，当浏览历史为空的时候【上一步】按钮等同于【退出】按钮。
- (void)backAction {
    if (_isPushed) {
        [SNUtility popViewToPreViewController];
    } else {
        if (![_webView canGoBack]) {
            [self closeBrowser];
            [[SNSubscribeCenterService defaultService] loadMySubFromServer];
        } else if ([self canLeavePage]) {
            [_webView goBack];
            _closeButton.hidden = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

//Only works for iOS7 and greater.
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

//Only works for iOS7 and greater.
- (UIStatusBarStyle)preferredStatusBarStyle {
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"]) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)hideGradientBackground:(UIView *)theView {
    for (UIView *subview in theView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}

- (void)handleWebViewProgressDidChange:(NSNotification *)notification {
    if (notification.object == _webView) {
        CGFloat progress = [[notification userInfo] floatValueForKey:kSNWebViewCurrentProgressValueKey defaultValue:0];
        [self handleProgress:progress];
    }
}

- (void)handleProgress:(CGFloat)progress
{
    _progress.curProgress = progress;
}

- (void)addWebView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight-kSystemBarHeight-kToolbarViewTop)];
    _webView.delegate = self;
    _webScrollView = _webView.scrollView;
    
    float bottomInset = kWebToolbarViewHeight;
    
    if (bottomInset > 0) {
        bottomInset -= 15;
    }
    _webScrollView.contentInset = UIEdgeInsetsMake(0, 0.f, bottomInset, 0.f);
    _webScrollView.delegate = self;
    _webScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    _webView.opaque = NO;//Make system draw the logo below transparent webview
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = [UIColor clearColor];
    
    [self hideGradientBackground:_webView];
    [_webView startObserveProgress];
    [self.view addSubview:_webView];
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    
    [self addWebView];
    
    [_webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    //add logo
     //(_loading);
    _loading = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, 0, TTScreenBounds().size.width, TTScreenBounds().size.height)];
    _loading.delegate = self;
    _loading.status = SNTripletsLoadingStatusStopped;
    [self.view addSubview:_loading];
    
    //add toolbar
    _back = [[UIButton alloc] init];
    [_back setImage:[UIImage imageNamed:@"icotext_back_v5.png"]
           forState:UIControlStateNormal];
    [_back setImage:[UIImage imageNamed:@"icotext_backpress_v5.png"]
           forState:UIControlStateHighlighted];
    [_back setBackgroundColor:[UIColor clearColor]];
    [_back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:[UIImage imageNamed:@"icotab_close_v5.png"] forState:UIControlStateNormal];
    [_closeButton setImage:[UIImage imageNamed:@"icotab_closepress_v5.png"] forState:UIControlStateHighlighted];
    [_closeButton setBackgroundColor:[UIColor clearColor]];
    _closeButton.hidden = YES;
    [_closeButton addTarget:self action:@selector(closeBrowser) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolbar setButtons:[NSArray arrayWithObjects:_back, _closeButton, nil]
                    withType:SNToolbarAlignCenter];
    
    _back.enabled = YES;
    
    //Add progress bar
    _progress = [[SNProgressBar alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, self.view.width, 2)];
    _progress.layer.cornerRadius = 1;
    _progress.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_progress];
    
    [SNNotificationManager addObserver:self selector:@selector(refreshStockDetailButton:) name:kRefreshStockDetailButtonNotification object:nil];
}

- (BOOL)canLeavePage {
    NSString *canLeavePage = [_webView stringByEvaluatingJavaScriptFromString:@"sohunews_canLeavePage();"];
    //未定义此函数返回值为空字符串，当做true处理
    return ![@"false" isEqualToString:canLeavePage];
}

- (BOOL)canCloseBrowser {
    NSString *canCloseBrowser = [_webView stringByEvaluatingJavaScriptFromString:@"sohunews_canCloseBrowser();"];
    //未定义此函数返回值为空字符串，当做true处理
    return ![@"false" isEqualToString:canCloseBrowser];
}

- (BOOL)canRefreshBrowser {
    NSString *canCloseBrowser = [_webView stringByEvaluatingJavaScriptFromString:@"sohunews_canRefreshBrowser();"];
    //未定义此函数返回值为空字符串，当做true处理
    return ![@"false" isEqualToString:canCloseBrowser];
}

- (void)closeBrowser {
    if ([self canCloseBrowser]) {
        //返回bug wangyy
        [self.flipboardNavigationController popViewControllerAnimated:YES];
    }
}

- (UIImage *)image {
    NSString *name1 = @"backNomal.png";
    return [[UIImage imageNamed:name1] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
}

- (void)showInitProgress {
    [_progress startProgress];
}

- (void)hideInitProgress {
    [_progress resetProgress];
}

//由于webview在加载新内容时仍显示旧内容，这个方法用来清空旧新闻页面用的空白html，里面只有一个logo
- (void)resetEmptyHTML {
    [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';document.body.style.background='transparent'"] ;
    
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.scalesPageToFit = NO;
    _webView.backgroundColor = [UIColor clearColor];
}

- (void)stopAction:(id)sender {
    [_webView stopLoading];
    [_progress resetProgress];
}

#pragma mark -
#pragma mark webView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.isRedirect) {
        return YES;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@", request.URL];
    SNDebugLog(@"MP Web Load Url:%@", urlString);
    if (NSNotFound != [urlString rangeOfString:kProtocolSubHome options:NSCaseInsensitiveSearch].location) {
        NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
        [referInfo setObject:@"0" forKey:kReferValue];
        [referInfo setObject:@"0" forKey:kReferType];
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Subscribe_MeMedia] forKey:kRefer];
        [referInfo setObject:[NSNumber numberWithBool:YES] forKey:kFromRollingChannelWebKey];
        return [SNUtility openProtocolUrl:urlString context:referInfo];
    } else if ([urlString hasPrefix:kProtocolSubscirbe]) {
        NSString *prefixStr = [NSString stringWithFormat:@"%@subId=",kProtocolSubscirbe];
        NSString *subId = [urlString substringFromIndex:[prefixStr length]];
        [[SNSubscribeCenterService defaultService] dealSubInfoFromServerBySubId:subId operationTopic:kTopicAddSubInfo];
    } else if ([urlString hasPrefix:kProtocolUnsubscirbe]) {
        NSString *prefixStr = [NSString stringWithFormat:@"%@subId=",kProtocolUnsubscirbe];
        NSString *subId = [urlString substringFromIndex:[prefixStr length]];
        [[SNSubscribeCenterService defaultService] dealSubInfoFromServerBySubId:subId operationTopic:kTopicDelSubInfo];
    }
    else if ([urlString containsString:SNLinks_Domain_Mp]) {
        return [self seedCookieForURLString:urlString];
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([urlString containsString:kSearchSubUrl]) {
            NSDictionary *context = [NSDictionary dictionaryWithObject:@"1" forKey:@"subSearch"];
            [SNUtility openProtocolUrl:urlString context:context];
        } else {
            [SNUtility openProtocolUrl:urlString];
        }
        return NO;
    }
    else {
        if ([urlString containsString:kMPMarking]) {//MP使用a标签代价大，使用参数控制
            if ([SNUtility isProtocolV2:urlString]) {
                SNAppConfigMPLink *confifMPLink = [SNAppConfigManager sharedInstance].configMPLink;
                NSString *stat = nil;
                if (confifMPLink.mpLink.length > 0) {
                    stat = confifMPLink.mpLink;
                }
                else {
                    stat = [NSString stringWithFormat:FixedUrl_Subscribe];
                }
                if ([urlString containsString:@"login://backUrl="]) {
                    NSString *tempStr = [urlString stringByReplacingOccurrencesOfString:@"login://backUrl=" withString:@""];
                    urlString = [NSString stringWithFormat:@"login://backUrl=%@", stat];
                    if (![urlString containsString:@"?"]) {
                        urlString = [urlString stringByAppendingFormat:@"?%@", tempStr];
                    }
                    else {
                        urlString = [urlString stringByAppendingFormat:@"%@", tempStr];
                    }
                }
                NSDictionary* context = @{kUniversalWebViewType:[NSNumber numberWithInt:NormalWebViewType],kWebViewForceBackKey:@"1"};
                [SNUtility openProtocolUrl:urlString context:context];
            }
        }
        else {
            [SNUtility openProtocolUrl:urlString];
        }
        return NO;
    }

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _isLoading = NO;
    [self hideLoading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isRedirect = NO;
    });
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    _isLoading = YES;
    _firstLoaded = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.isRedirect = NO;
    if (kCFURLErrorBadURL == error.code ||
        kCFURLErrorUnsupportedURL == error.code ||
        kCFURLErrorCannotFindHost == error.code ||
        kCFURLErrorTimedOut == error.code ||
        kCFURLErrorCannotConnectToHost == error.code ||
        kCFURLErrorNotConnectedToInternet == error.code) {
        _isLoading = NO;
        [self showErrorView:NSLocalizedString(@"LoadFailRefresh", @"加载失败，点击屏幕刷新")];
        [_progress resetProgress];
    } else {
        //Once you see an "itms" scheme, stop the webView from loading and open the URL with Safari to download app.
        NSURL *url = [NSURL URLWithString:[error.userInfo objectForKey:@"NSErrorFailingURLStringKey"]];
        
        if ([error.domain isEqual:@"WebKitErrorDomain"]) {
            //support itms:// or itms-apps:// or itms-appss:// or itmss:// to open iTunes or Appstore
            if ([SNUtility isWhiteListURL: url]) {
                if ([[url scheme] hasPrefix:@"itms"]) {
                    [_progress resetProgress];
                    [[UIApplication sharedApplication] openURL:url];
                }
                return;
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_nightModeView) {
        CGFloat viewHeight = scrollView.contentSize.height;
        if (viewHeight < _webView.height) {
            viewHeight = _webView.height;
        }
        _nightModeView.frame = CGRectMake(0, 0, scrollView.width, viewHeight);
    }
}

#pragma mark -
#pragma mark Private methods
- (BOOL)isError {
    return _loading.status == SNTripletsLoadingStatusNetworkNotReachable;
}

- (void)hideError {
    _loading.status = SNTripletsLoadingStatusStopped;
}

- (void)showLoading {
    _loading.status = SNTripletsLoadingStatusLoading;
}

- (void)hideLoading {
    _loading.status = SNTripletsLoadingStatusStopped;
}

- (void)showErrorView:(NSString *)error {
    _loading.status = SNTripletsLoadingStatusNetworkNotReachable;
}

- (void)openURL:(NSURL *)URL {
    self.url = URL;
    self.request = [NSMutableURLRequest requestWithURL:self.url];
    self.request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [self openRequest:self.request];
}

- (void)openRequest:(NSMutableURLRequest *)request {
    [self view];
    [self appendCookieToRequeset:request url:_url];
    [_webView loadRequest:request];
    
    [self updateWebView];
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if (!_webView.isLoading) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
        [self appendCookieToRequeset:request url:_url];
        [_webView loadRequest:request];
        [_progress startProgress];
        _loading.status = SNEmbededActivityIndicatorStatusStartLoading;
    }
}

#pragma mark -
#pragma mark UIView
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 3.5.1
// 给所有网页访问增加用户中心cookie
- (void)appendCookieToRequeset:(NSMutableURLRequest *)request
                           url:(NSURL *)url {
    if (![SNUserManager isLogin])
        return;
    
    NSString *cookieValue = [SNUserManager getCookie];
    if (self.url != nil && cookieValue) {
        NSString *cookieHeader = nil;
        NSArray *cookiess = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        
        if ([cookiess count] > 0) {
            NSHTTPCookie *cookie;
            for (cookie in cookiess) {
                if(!cookieHeader)
                    cookieHeader = [NSString stringWithFormat: @"%@=%@", [cookie name], [cookie value]];
                else
                    cookieHeader = [NSString stringWithFormat: @"%@; %@=%@", cookieHeader, [cookie name], [cookie value]];
            }
        }
        
        //Append cookie
        if (!cookieHeader)
            cookieHeader = [NSString stringWithFormat:@"%@", cookieValue];
        else
            cookieHeader = [NSString stringWithFormat:@"%@; %@", cookieHeader,cookieValue];

        //creat a new cookie
        [request setValue:cookieHeader forHTTPHeaderField: @"Cookie" ];
    }
}

#pragma mark - SNWebUrlViewDelegate
- (void)updateTheme {
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    UIImageView *imgView = (UIImageView *)[_toolbar viewWithTag:200];
    if (imgView) {
        UIImage *img = [UIImage  themeImageNamed:@"postTab0.png"];
        imgView.image = img;
    }
    [_back setImage:[UIImage imageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [_back setImage:[UIImage imageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [_closeButton setImage:[UIImage imageNamed:@"icotab_close_v5.png"] forState:UIControlStateNormal];
    [_closeButton setImage:[UIImage imageNamed:@"icotab_closepress_v5.png"] forState:UIControlStateHighlighted];
    
    [self updateWebView];
    
    [_progress updateTheme];
}

- (void)changeWebView:(NSDictionary *)dic {
    BOOL addSub = [[dic objectForKey:@"subStatus"] boolValue];
    NSString *subId = [dic objectForKey:@"subId"];
    
    NSString *jsString = [NSString stringWithFormat:@"syncSubStatus(%@,%d);", subId, addSub];
    [_webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)refreshStockDetailButton:(NSNotification *)notification {
    NSDictionary *userDic = notification.userInfo;
    [self performSelectorOnMainThread:@selector(changeWebView:) withObject:userDic waitUntilDone:NO];
}

//种cookie
- (BOOL)seedCookieForURLString:(NSString *)urlString {
    if ([SNUserManager isLogin]) {
        NSString *cookieHeader = [SNUtility extractionCookie:urlString key:nil];
        //判断域名下是否种过cookie，没种过则调用redirect.go种cookie
        if ([cookieHeader containsString:@"ppinf"] && [cookieHeader containsString:@"pprdig"]) {
            return YES;
        }
        NSString *format = nil;
        NSString *pid = [SNUserManager getPid] ? : @"-1";
        NSString *token = [SNUserManager getToken] ? : @"";
        NSString *passport = [SNUserManager getUserId] ? : @"";
        if ([urlString containsString:@"?"]) {
            format = @"&u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@";
        }
        else {
            format = @"?u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@";
        }
        urlString = [urlString stringByAppendingFormat:format, [SNAPI productId], [SNUserManager getP1], [SNUserManager getGid], pid, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], token, passport];
        urlString = [NSString stringWithFormat:kH5LoginUrl, [urlString URLEncodedString]];
        urlString = [urlString stringByAppendingFormat:@"&u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@", [SNAPI productId], [SNUserManager getP1], [SNUserManager getGid], pid, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], token, passport];
        NSMutableURLRequest *newRequest = [_request mutableCopy];
        newRequest.timeoutInterval = WEBVIEW_REQUEST_TIMEOUT;
        [newRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];//减少内存占用
        newRequest.URL = [NSURL URLWithString:urlString];
        [self.webView loadRequest:newRequest];
        self.isRedirect = YES;
        return NO;
    }
    return YES;
}

- (void)setWebNightMode {
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        if ([_webView.subviews count] > 0 && [[_webView.subviews objectAtIndex:0].subviews count] > 0) {
            UIView *view = [[_webView.subviews objectAtIndex:0].subviews objectAtIndex:0];
            [view addSubview:self.nightModeView];
        }
    }
    else {
        if (_nightModeView) {
            [_nightModeView removeFromSuperview];
        }
    }
}

- (UIView *)nightModeView {
    if (!_nightModeView) {
        _nightModeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _webView.width, _webView.height)];
        _nightModeView.backgroundColor = SNUICOLOR(kBackgroundColor);
        _nightModeView.alpha = 0.6;
    }
    [_nightModeView setFrame:CGRectMake(0, 0, _webView.scrollView.contentSize.width, _webView.scrollView.contentSize.height)];
    return _nightModeView;
}

@end
