//
//  SNJSKitWebViewController.m
//  sohunews
//
//  Created by yangln on 2017/2/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNJSKitWebViewController.h"
#import "SNConsts.h"

#import "SNUserPortraitPlayer.h"

@interface SNJSKitWebViewController ()

@property (nonatomic,strong) SNUserPortraitPlayer* player;

@end

@implementation SNJSKitWebViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.webViewType == FictionWebViewType){
        //@qz 只有小说页面需要改 不判断会影响到abtest
        self.toolBar.bottom = self.view.height;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.isNativeH5) {
        [self showTitleBar:NO animated:NO];
    }
    
    if ([self.newsLink containsString:@"h5apps/newssdk.sohu.com/modules/readZone/readZone.html"]) {
        [self showTitleBar:NO animated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (statusBarFrameDidChange:) name : UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)statusBarFrameDidChange:(NSNotification *)notification {
    if(self.webViewType == FictionWebViewType){
        //@qz 只有小说页面需要改 不判断会影响到abtest
        self.toolBar.bottom = self.view.height;
    }
}

#pragma mark webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.isClickBack) {
        return NO;
    }
    NSString *urlString = request.URL.absoluteString;
    SNDebugLog(@"load jskit webView URL:%@", urlString);
    
    if ([urlString containsString:@"openinwebview_finance=false"]) {
        return YES;
    }
    
    if ([urlString isEqualToString:@"about:blank"]) {
        self.isWebviewLoad = NO;
        return YES;
    }
    
    if ([urlString containsString:@".pdf"]) {
        self.forceBack = YES;
    }
    
    if (self.isRedirect && ![SNUtility isProtocolV2:urlString]) {
        self.isWebviewLoad = YES;
        return YES;
    }
    
    //处理正文页、搜索页iOS8点击问题
    if ([urlString hasPrefix:@"js:"] && urlString.length > 3) {
        urlString = [urlString substringFromIndex:3];
    }
    
    [self checkNativeURL:request.URL];
    
    ///读书币充值记录
    if ([urlString containsString:kProtocolStoryRechargeHistory]) {
        [SNUtility openProtocolUrl:urlString];
        return NO;
    }
    ///读书币充值
    if ([urlString containsString:kProtocolStoryRechargeCenter]) {
        [SNUtility openProtocolUrl:urlString];
        return NO;
    }
    //打开用户画像子页面
    if ([self openUserTraitPage:urlString]) {
        self.isWebviewLoad = YES;
        return NO;
    }
    
    //端内打开第三方APP
    if ([self canOpenThirdPartyApp:urlString]) {
        self.isWebviewLoad = NO;
        return NO;
    }
    
    //处理二代协议
    if ([SNUtility isProtocolV2:urlString]) {
        self.isWebviewLoad = [self processProtocolV2:urlString navigationType:navigationType];
        return self.isWebviewLoad;
    }
    
    //处理特殊域名，转化为二代协议
    if ([SNUtility changeSohuLinkToProtocol:urlString]) {
        self.isWebviewLoad = [self processSpecialDomain:urlString navigationType:navigationType];
        return self.isWebviewLoad;
    }
    
    //搜狐域内种cookie
    if ([self needAddCookieForUrlString:urlString request:request]) {
        self.isWebviewLoad = NO;
        return NO;
    }
    
    if (self.webViewType == ReadHistoryWebViewType && [SNUtility isProtocolV2:urlString]) {
        self.isClickHistoryNews = YES;
    }
    self.isWebviewLoad = YES;
    
    return YES;
}

#pragma mark subscrib channel and stock
- (void)addedButtonAction:(id)sender {
    if ([[SNUtility getApplicationDelegate] currentNetworkStatus] == NotReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    UIButton *button = (UIButton *)sender;
    SNASIRequest *request = nil;
    if (self.webViewType == StockMarketWebViewType) {
        [self processStockAddButton:button];
    }
    else if (self.webViewType == ChannelPreviewWebViewType) {
        [self processAddChannelButton:button];
    }
}

//股票频道添加、删除
- (void)processStockAddButton:(UIButton *)button {
    BOOL subStatus = NO;
    NSString *title = nil;
    NSInteger tag = 0;
    UIColor *color = nil;
    if (button.tag == kAddedTag) {
        //退订
        tag = kUnAddedTag;
        title = kAddToOptionalStock;
        color = SNUICOLOR(kThemeBlue1Color);
        subStatus = NO;
        
        [[[SNDelMyStockRequest alloc] initWithDictionary:@{@"stockCode":self.stockCode}] send:^(SNBaseRequest *request, id responseObject) {
            if (self.webViewType == StockMarketWebViewType) {
                self.addedButton.tag = tag;
                [self.addedButton setTitle:title forState:UIControlStateNormal];
                [self.addedButton setTitleColor:color forState:UIControlStateNormal];
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.stockCode,@"stockCode", [NSNumber numberWithBool:subStatus], @"status", nil];
                [SNNotificationManager postNotificationName:kRefreshStockDetailButtonNotification object:nil userInfo:userDic];
                [SNRollingNewsPublicManager sharedInstance].refreshStock = YES;
            }
        } failure:nil];
    }
    else {
        //添加
        tag = kAddedTag;
        title = kAddedToText;
        color = SNUICOLOR(kThemeText4Color);
        subStatus = YES;
        
        [[[SNAddMyStockRequest alloc] initWithDictionary:@{@"stockCode":self.stockCode,@"from":self.stockFrom}] send:^(SNBaseRequest *request, id responseObject) {
            if (self.webViewType == StockMarketWebViewType) {
                self.addedButton.tag = tag;
                [self.addedButton setTitle:title forState:UIControlStateNormal];
                [self.addedButton setTitleColor:color forState:UIControlStateNormal];
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.stockCode,@"stockCode", [NSNumber numberWithBool:subStatus], @"status", nil];
                [SNNotificationManager postNotificationName:kRefreshStockDetailButtonNotification object:nil userInfo:userDic];
                [SNRollingNewsPublicManager sharedInstance].refreshStock = YES;
            }
        } failure:nil];
    }
}

//普通频道添加、删除
- (void)processAddChannelButton:(UIButton *)button {
    NSString *title = nil;
    NSInteger tag = 0;
    UIColor *color = nil;
    
    NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
    NewsChannelItem *channelItem = nil;
    for (NewsChannelItem *item in channelList) {
        if ([item.channelId isEqualToString:self.channelId]) {
            channelItem = item;
            break;
        }
    }
    if (button.tag == kAddedTag) {
        //退订
        tag = kUnAddedTag;
        title = kAddToChannel;
        color = SNUICOLOR(kThemeGreen1Color);
        [self cancelSubscribeChannel];
        [[SNDBManager currentDataBase] addOrDeleteNewsChannnelToDataBase:channelItem editMode:NO];
    }
    else {
        //添加
        tag = kAddedTag;
        title = kAddedToText;
        color = SNUICOLOR(kThemeText4Color);
        channelItem.isChannelSubed = @"1";
        [self subscribeChannel];
        [[SNDBManager currentDataBase] addOrDeleteNewsChannnelToDataBase:channelItem editMode:YES];
    }
    self.addedButton.tag = tag;
    [self.addedButton setTitle:title forState:UIControlStateNormal];
    [self.addedButton setTitleColor:color forState:UIControlStateNormal];
}

- (void)cancelSubscribeChannel {
    if (self.delegate) {
        [self.delegate deleteSubscribeChannelViewWithID:self.channelId];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:@"%@channelId=%@&channelName=%@&channelSource=%@&channelStatusDelete=%@", kProtocolChannel, self.channelId, [self.newsTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [NSNumber numberWithBool:YES], kChannelDeleteFromChannelPreview];
        [SNUtility openProtocolUrl:urlString];
        //只在搜索的标签中，添加频道时更新频道管理界面；不影响正文页标签频道的添加(任务单 #41047 (new bug) [搜狐新闻_iOS]_5.2_频道管理：从搜索结果中添加频道，无法添加到频道栏)
        [SNNotificationManager postNotificationName:kProcessChannelFromSearchNotification object:nil];
    }
}

- (void)subscribeChannel {
    if (self.delegate) {
        [self.delegate addSubscribeChannelViewWithID:self.channelId];
    }
    else {
        // 与外链频道添加类似
        NSString *urlString = [NSString stringWithFormat:@"%@channelId=%@&channelName=%@&channelSource=%@", kProtocolChannel, self.channelId, [self.newsTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [NSNumber numberWithBool:YES]];
        [SNUtility openProtocolUrl:urlString];
        //只在搜索的标签中，添加频道时更新频道管理界面；不影响正文页标签频道的添加(任务单 #41047 (new bug) [搜狐新闻_iOS]_5.2_频道管理：从搜索结果中添加频道，无法添加到频道栏)
        [SNNotificationManager postNotificationName:kProcessChannelFromSearchNotification object:nil];
    }
}

- (void)requestSubscribeStatus {
    if (self.webViewType == StockMarketWebViewType) {
        [[[SNIsMyStockRequest alloc] initWithDictionary:@{@"stockCode": self.stockCode}] send:^(SNBaseRequest *request, id responseObject) {
            int status = [responseObject intValueForKey:@"statusCode" defaultValue:0];
            BOOL added = NO;
            if (status == 20021000) {
                added = [[responseObject stringValueForKey:@"data" defaultValue:@""] boolValue];
            }
            [self resetButtonStatus:added];
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            
        }];
        
    }
    else {
        self.channelDataSource = [[SNChannelScrollTabBarDataSource alloc] initWithController:self];
        [self.channelDataSource loadFromCache];
        BOOL channelIsSubscribed = NO;
        if (self.channelDataSource.model.channels.count > 0 && !self.delegate) {//self.delegate有值，from频道标签页
            for (int index = 0; index < self.channelDataSource.model.channels.count; index++) {
                SNChannel *channel = self.channelDataSource.model.channels[index];
                if (channel != nil && [channel.channelId isEqualToString:self.channelId]) {
                    if ([channel.isChannelSubed isEqualToString:@"1"]) {
                        channelIsSubscribed = YES;
                        break;
                    }
                }
            }
        }
        [self resetButtonStatus:channelIsSubscribed];
    }
}

- (void)resetButtonStatus:(BOOL)isAdded {
    NSString *buttonTitle = nil;
    NSInteger buttonTag = 0;
    UIColor *buttonColor = nil;
    if (isAdded) {
        buttonTag = kAddedTag;
        buttonTitle = kAddedToText;
        buttonColor = SNUICOLOR(kThemeText4Color);
    }
    else {
        buttonTag = kUnAddedTag;
        if (self.webViewType == StockMarketWebViewType ){
            //股票详情页
            buttonTitle = kAddToOptionalStock;
            buttonColor = SNUICOLOR(kThemeBlue1Color);
        }
        else {
            //频道预览页
            buttonTitle = kAddToChannel;
            buttonColor = SNUICOLOR(kThemeGreen1Color);
        }
    }

    self.addedButton.tag = buttonTag;
    [self.addedButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self.addedButton setTitleColor:buttonColor forState:UIControlStateNormal];
}

#pragma mark JSKit相关回调
#pragma mark 红包相关
- (void)cashOutCallback:(BOOL)isSuccess withRedPacketId:(NSString*)redPacketId withDrawTime:(NSString*)drawTime{
    [self.universalWebView callJavaScript:[NSString stringWithFormat:@"cashOutCallback(%@, \"%@\", \"%@\")", [NSNumber numberWithBool:isSuccess], redPacketId, drawTime] forKey:nil callBack:nil];
}

- (void)checkLoginAndBindCallback:(BOOL)isSuccess url:(NSString *)url{
    [self.universalWebView callJavaScript:[NSString stringWithFormat:@"checkLoginAndBindCallback(%@, \"%@\")", [NSNumber numberWithBool:isSuccess], url] forKey:nil callBack:nil];
}

#pragma mark process page
- (void)showShareBtn:(BOOL)show {
    if (self.shareButton) {
        self.shareButton.hidden = !show;
    }
}

- (void)forceCloseBrowser:(BOOL)force{
    self.forceBack = close;
}

- (void)closeBrowserImmediately {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self webViewClose];
    });
}

- (void)showReportBtn:(BOOL)show{//wangshun
    self.isShowReport = show;
}

- (void)showMaskView:(BOOL)show{
    self.isShowMask = show;
    if (!show) {
        if (self.nightModeView.superview) {
            [self.nightModeView removeFromSuperview];
        }
    }
}

- (void)showTitleBar:(BOOL)show animated:(BOOL)animated {
    if (self.isUse_h5_title) {
        if (self.isSohunewsclient_h5_title) {
            show = YES;
        }
        else {
            show = NO;
        }
    }
    
    self.showTitleBar = show;
    
    if (show) {
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^(void) {
                [self resetWebviewWithShowTitleBar:YES isSwipe:NO];
            } completion:^(BOOL finished) {
            }];
        }
        else {
            [self resetWebviewWithShowTitleBar:YES isSwipe:NO];
            [self.universalWebView.scrollView setContentOffset:CGPointMake(0, -kWebUrlViewHeight) animated:NO];
        }
    }
    else {
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^(void) {
                [self resetWebviewWithShowTitleBar:NO isSwipe:NO];
            } completion:^(BOOL finished) {
            }];
        }
        else {
            [self resetWebviewWithShowTitleBar:NO isSwipe:NO];
        }
    }
}

- (void)updateTitle:(NSString *)title {
    self.newsTitle = title;
    self.titleLabel.text = title;
}


#pragma mark 用户画像
- (void)openFacePreferenceSetting:(NSString*)gender{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* url = @"tt://userPortraitSexSet";
        NSDictionary* dic = @{@"old":@"1",@"gender":gender,@"from":@"h5"};
        TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
        [action applyQuery:dic];
        [[TTNavigator navigator] openURLAction:action];
    });
}

- (BOOL)openUserTraitPage:(NSString *)urlString {
    if ([self.newsLink containsString:@"h5apps/newssdk.sohu.com/modules/readZone/readZone.html"]) {//如果是用户画像
        if (![urlString containsString:@"readZone/readZone.html"]) {//如果不是本页面刷新
            if ([urlString containsString:@"h5apps/newssdk.sohu.com/modules/"]) {//如果是h5唤起我们
                
                [SNUtility openProtocolUrl:urlString context:@{@"fromreadZone":@"1", kUniversalWebViewType:[NSNumber numberWithInteger:UserPortraitWebViewType]}];
                return YES;
            }
        }
    }
    return NO;
}

- (void)clickFaceInfoLayoutFaceType:(NSNumber *)faceType GenderStatus:(NSNumber *)genderStatus Gender:(NSString *)gender{
    
    if (faceType.integerValue !=0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* urlString = SNLinks_Path_FaceH5;
            [SNUtility openProtocolUrl:urlString context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:UserPortraitWebViewType], kUniversalWebViewType, nil]];
        });
        
        return;
    }
    
    NSString* url = @"tt://userPortraitSexSet";
    NSString* sex = @"";
    if (genderStatus && genderStatus.integerValue != 0) {
        if (gender) {
            sex = gender;
        }
    }
    NSDictionary* dic = @{@"old":[NSString stringWithFormat:@"%d",faceType.integerValue],@"gender":sex,@"from":@"h5"};
    TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
    [action applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
