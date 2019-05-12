//
//  SNMySDK.m
//  sohunews
//
//  Created by Cae on 14-12-14.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNMySDK.h"
#import "SNNewAlertView.h"
#import "SNTwinsMoreView.h"
#import "SNTwinsLoadingView.h"
#import "SNTripletsLoadingView.h"
#import "SNUserinfoMediaObject.h"
#import "SNUserManager.h"
#import "SNToast.h"
#import "SNLocalChannelListViewController.h"
#import "SNUserLocationManager.h"
#import "SNClientRegister.h"
#import "SNUserUtility.h"
#import "WebViewJavascriptBridge.h"
#import "SNDownloadScheduler.h"
#import "SNDBManager.h"
#import "UIDevice-Hardware.h"
#import "SNUserLocationManager.h"
#import "SNLogManager.h"
#import "SNArticle.h"
#import "NSJSONSerialization+String.h"
#import "SNNewsLogin.h"
#import "SNNewsLoginManager.h"
#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginEnvironment.h"
#import "SNNewsLogout.h"
 
@interface SNMySDK()
@property (nonatomic, strong) UIViewController *snsController;
@property (nonatomic, strong) SNUserAccountService *userAccountService;
@property (nonatomic, strong) SNWebViewJavascriptBridge *jsBridge;
@end

@implementation SNMySDK

- (UIViewController *)snsController {
#pragma mark - huangjing -添加了些参数
    if (nil == _snsController) {
        [SNSLib sharedInstance].isNight = [[SNThemeManager sharedThemeManager] isNightTheme];
        
        sohunewsAppDelegate *app = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray* array = [[SNUserinfoEx userinfoEx] getPersonMediaObjects];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [array enumerateObjectsUsingBlock:^(SNUserinfoMediaObject *obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:obj.iconUrl forKey:@"iconUrl"];
            [dic setValue:obj.name forKey:@"name"];
            [dic setValue:obj.count forKey:@"count"];
            [dic setValue:obj.link forKey:@"link"];
            [dic setValue:obj.mediaLink forKey:@"mediaLink"];
            [dic setValue:obj.subId forKey:@"subId"];
            [dic setValue:obj.subTypeIcon forKey:@"subTypeIcon"];
            [tempArray addObject:dic];
        }];
        NSDictionary *loginPara = @{@"userId" : [SNUserManager getUserId],
                                    @"token" : [SNUserManager getToken],
                                    @"cid" : [SNUserManager getP1],
                                    @"tabHeight" : @([app appTabbarController].tabbarView.frame.size.height),
                                    @"pid" : [SNUserManager getPid],
                                    @"mediaLinkArray" : tempArray,
                                    @"pushToken" : [SNClientRegister sharedInstance].deviceToken ? [SNClientRegister sharedInstance].deviceToken : @"",
                                    @"gid" : ([SNUserManager getGid] ? [SNUserManager getGid] : @"")
                                    };
        self.snsController = [SNSLib getTimeLineViewControlWithDictionary:loginPara];
    }
    
    return _snsController;
}

+ (SNMySDK *)sharedInstance {
    static SNMySDK *mySDKInstance;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^(){
        mySDKInstance = [[SNMySDK alloc] init];
    });
    
    return mySDKInstance;
}

- (void)setupSNS {
    SNSLib *lib = [SNSLib sharedInstance];
#pragma mark - huangjing  //获取登录信息
    NSDictionary *dic = @{@"sid" : [SNClientRegister sharedInstance].sid ?
                          [SNClientRegister sharedInstance].sid : @"",
                          @"columnId" : @"0",
                          @"cid" : [SNUserManager getP1] ? [SNUserManager getP1] : @"",
                          @"apiversion" : @"29",
                          @"pid" : [SNUserManager getPid] ? [SNUserManager getPid] : @"",
                          @"u" : @"1",
                          @"userId" : [SNUserManager getUserId] ? [SNUserManager getUserId] : @"",
                          @"token" : [SNUserManager getToken] ? [SNUserManager getToken] : @"",
                          @"gid": ([SNUserManager getGid] ? [SNUserManager getGid] : @""),
                          @"userName" : ([SNUserManager getNickName] ? [SNUserManager getNickName] : @""),
                          @"mobile" : ([SNUserManager getMobil] ? [SNUserManager getMobil] : @"")
                          };
    
#pragma mark - end
    //狐友 刘通 请求换一下调用顺序 wangshun
    if (nil == lib.delegate) {
        lib.delegate = [SNMySDK sharedInstance];
    }
    
    [SNSLib setupWithInfo:dic];
}

- (void)showMySDK:(UIViewController *)parentController {
    UIViewController *controller = self.snsController;
    
    [controller removeFromSupercontroller];
    [controller.view removeFromSuperview];
    [parentController addChildViewController:controller];
    [parentController.view addSubview:controller.view];
    [controller didMoveToParentViewController:parentController];
}

- (UIView *)getMoreAnimationViewWithFrame:(CGRect)frame {
    return [[SNTwinsMoreView alloc] initWithFrame:frame];
}

// 获取新闻客户端下拉视图
- (UIView *)getLoadingViewWithFrame:(CGRect)frame
                 ObservedScrollView:(UIScrollView *)scrollView {
    return [[SNTwinsLoadingView alloc] initWithFrame:frame
                               andObservedScrollView:scrollView];
}

- (UIView *)getTripletsLoadViewWithFrame:(CGRect)frame {
    SNTripletsLoadingView *view = [[SNTripletsLoadingView alloc] initWithFrame:frame];
    [view setColorBackgroundClear];
    return view;
}

- (UIView *)getTripletsLoadViewForVideoWithFrame:(CGRect)frame {
    SNTripletsLoadingView *view = [[SNTripletsLoadingView alloc] initWithFrame:frame];
    [view setColorBackgroundClear];
    [view setColorVideoMode:YES];
    return view;
}

- (void)getPassPortByPid:(NSString *)pid
                callback:(void (^)(NSString *passport))result {
    @try {
        NSString *url = [NSString stringWithFormat:kSNSUserCenterURL, pid];
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                            timeoutInterval:10];
        
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableContainers error:nil];
        
        NSString *passport = [AesEncryptDecrypt decrypt:dic[@"passport"]];
        result(passport);
    }
    @catch (NSException *exception) {
        result(@"");
    }
}

- (NSString *)getPassPortByPid:(NSString *)pid {
    @try {
        NSString *url = [NSString stringWithFormat:kSNSUserCenterURL, pid];
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                            timeoutInterval:10];
        
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableContainers error:nil];
        
        NSString *passport = [AesEncryptDecrypt decrypt:dic[@"passport"]];
        return passport;
    }
    @catch (NSException *exception) {
        return @"";
    }
}
#pragma mark - huangjing  //获取登录状态
- (NSDictionary *)getLoginStatusInfo {
    if ([SNUserManager isLogin]) {
        [SNSLib sharedInstance].isNight = [[SNThemeManager sharedThemeManager] isNightTheme];
        NSArray *array = [[SNUserinfoEx userinfoEx] getPersonMediaObjects];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [array enumerateObjectsUsingBlock:^(SNUserinfoMediaObject *obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:obj.iconUrl forKey:@"iconUrl"];
            [dic setValue:obj.name forKey:@"name"];
            [dic setValue:obj.count forKey:@"count"];
            [dic setValue:obj.link forKey:@"link"];
            [dic setValue:obj.mediaLink forKey:@"mediaLink"];
            [dic setValue:obj.subId forKey:@"subId"];
            [dic setValue:obj.subTypeIcon forKey:@"subTypeIcon"];
            [tempArray addObject:dic];
        }];
        NSDictionary *loginPara = @{@"userId" : [SNUserManager getUserId] ? [SNUserManager getUserId] : @"",
                                    @"userName" : [SNUserManager getNickName] ? [SNUserManager getNickName] : @"",
                                    @"token" : [SNUserManager getToken],
                                    @"cid" : [SNUserManager getP1],
                                    @"pid" : [SNUserManager getPid],
                                    @"avatar" : [SNUserManager getHeadImageUrl] ? [SNUserManager getHeadImageUrl] : @"",
                                    @"isRealName" : [SNUserManager getIsRealName] ? @"1" : @"0",
                                    @"mobil" : [SNUserManager getMobil] ? [SNUserManager getMobil] : @"",
                                    @"mediaLinkArray" : tempArray,
                                    @"loginStatus" : @YES,
                                    @"gid" : ([SNUserManager getGid] ? [SNUserManager getGid] : @""),
                                    @"mobile" : ([SNUserManager getMobil] ? [SNUserManager getMobil] : @"")
                                    };
        return loginPara;
    } else {
        [SNSLib sharedInstance].isNight = [[SNThemeManager sharedThemeManager] isNightTheme];
        return @{@"loginStatus" : @NO};
    }
}

- (NSString *)getMarketId {
    return [NSString stringWithFormat:@"%d", [SNUtility marketID]];
}

//提示框
- (void)showToastWithTitle:(NSString *)title toUrl:(NSString *)url mode:(int)toastMode onView:(UIView *)view {
    [[SNToast shareInstance] showToastToTargetView:view title:title toUrl:url userInfo:nil mode:toastMode];
}

//中心提示框
- (void)showCenterToastWithTitle:(NSString *)title mode:(int)mode {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:title
                                                      toUrl:nil mode:mode];
}

//底部导航显示YES为隐藏已经没有用了
- (void)hidenTabBar:(BOOL)hiden {
    sohunewsAppDelegate *app = (sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app appTabbarController].tabbarView.hidden = hiden;
}

- (UIImage *)imageNamed:(NSString *)name {
    if ([name hasSuffix:@"png"]) {
        return [UIImage imageNamed:name];
    } else {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
    }
}

// 获取跳转的新闻页(返回为导航跳转)
- (void)pushToNewsViewControllerWith:(NSDictionary *)info {
    /*
     linkId的值可能是以下的内容
     news://newsId=28552717
     photo://newsId=28586844
     photo://gid=97557
     live://???=XXXX
     */
    NSString *protocal = info[@"linkId"];
    if (nil != protocal) {
        NSDictionary *dic = nil;
        if ([protocal containsString:@"novelfree/modules/novelfree/novelfree.html"]) {
            dic = @{kUniversalWebViewType:[NSNumber numberWithInt:TimeFreeWebViewType]};
        }
        [SNUtility openProtocolUrl:protocal context:dic];
    }
}

//跳转到媒体账号
- (void)jumpToMediaCenter:(NSString *)link hideShare:(BOOL)hideShare {
    if (hideShare) {
        [SNUtility openProtocolUrl:link context:@{kNormalWebviewHideShareButton:[NSNumber numberWithBool:YES]}];
    }
    else {
        [SNUtility openProtocolUrl:link];
    }
}


//跳转到分享
- (void)jumpToShareCenter:(NSString *)link {
    [SNUtility openProtocolUrl:link];
}

//跳转到管理自媒体
- (void)pushToManageMediaViewControllerWith:(NSDictionary *)info {
    NSString *url = info[@"mediaLink"];
    if (url) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:url, kLink, [NSNumber numberWithInteger:ApplicationSohuWebViewType], kUniversalWebViewType, nil];
        [SNUtility openUniversalWebView:dic];
    }
}

#pragma mark - huangjing 跳转到登录界面
- (void)pushToLoginViewController:(NSString *)loginfrom {

//    [SNNewsLogin loginSuccess:^(NSDictionary *info) {
//        NSLog(@"wangshun loginSuccess block");
//    }];
    
    [SNGuideRegisterManager login:loginfrom];
}

//wangshun 2017.5.17 login callback
- (void)callSohuNewsLogin:(NSString*)loginFrom WithCallBack:(void (^)(NSDictionary*info))method{
    
    NSDictionary* dic = @{@"loginFrom":loginFrom};
    if ([loginFrom isEqualToString:@"100004"] || [loginFrom isEqualToString:@"100024"]) {
        dic = @{@"loginFrom":loginFrom,@"entrance":@"3"};
    }  else if ([loginFrom isEqualToString:@"100040"]){
        dic = @{@"loginFrom":loginFrom,@"entrance":@"4"};
    }
    
    [SNNewsLoginManager loginData:dic Successed:^(NSDictionary *info) {//111狐友／申请搜狐号／评论狐友
        if (method) {
            method(info);
        }
    } Failed:nil];
    
}

//wangshun  登录半屏浮层 2017.10.9
/** params : {@"loginFrom":xxxx,@"halfScreenTitle":xxxx}
 */
- (void)callHalfSohuNewsLogin:(NSDictionary *)params WithCallBack:(void (^)(NSDictionary *))method{
	//loginFrom
    //halfScreenTitle
    NSString* loginFrom = [params objectForKey:@"loginFrom"]?:@"";
    NSDictionary* dic = @{@"loginFrom":loginFrom};
    if ([loginFrom isEqualToString:@"100004"] || [loginFrom isEqualToString:@"100024"]) {
        dic = @{@"loginFrom":loginFrom,@"entrance":@"3"};
    }
    else if ([loginFrom isEqualToString:@"100040"]){
        dic = @{@"loginFrom":loginFrom,@"entrance":@"4"};
    }
    
    [SNNewsLoginManager halfLoginData:params Successed:^(NSDictionary *info) {
        if (method) {
            method(info);
        }
    } Failed:nil];
}

- (NSDictionary *)getPassportParams:(id)sender{
    NSString* appID  = SNNewsPPLogin_APPID;
    NSString* appKey = [SNNewsPPLoginEnvironment getAPPKey];
    NSString* ua     = [SNNewsPPLogin getUA]?:@"";
    return @{@"appid":appID,@"appkey":appKey,@"ua":ua};
}



// 新浪微博绑定跳转
- (void)pushToBindSinaAccountViewController {
    [[SNShareManager defaultManager] authrizeByAppId:@"1" loginType:SNShareManagerAuthLoginTypeBind delegate:self];
}

- (void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController {
    [SNSLib sinaBindBackWithDictionary:@{}];
}

//申请开通媒体账号
- (void)pushToApplyForMediAccountViewController {
    SNUserinfoEx *userinfoEx = [SNUserinfoEx userinfoEx];
    NSArray *mediaArray = [userinfoEx getPersonMediaObjects];
    if (!userinfoEx.isShowManage) {
        if (mediaArray.count == 0) {
            if (userinfoEx.cmsRegUrl.length > 0) {
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:userinfoEx.cmsRegUrl, @"address", nil];
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5WebBrowser"] applyAnimated:YES] applyQuery:dic];
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        } else {
            SNUserinfoMediaObject *object = [mediaArray objectAtIndex:0];
            if (object && object.mediaLink) {
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:object.mediaLink, @"address", nil];
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5WebBrowser"] applyAnimated:YES] applyQuery:dic];
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        }
    }
}

- (void)updateAppTheme {
    [SNSLib sharedInstance].isNight = [[SNThemeManager sharedThemeManager] isNightTheme];
}

- (void)pushToCityViewController {
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://localChannelList"] applyAnimated:NO] applyQuery:@{@"notifySDK" : @(YES)}];
    [[TTNavigator navigator] openURLAction:urlAction];
}

#define SAFE_PTR(ptr) ((nil == (ptr)) ? [NSNull null] : (ptr))
- (void)updateLocation:(SNChannel *)channel {
    NSDictionary *locationInfo = @{
                                   @"channelName" : SAFE_PTR(channel.channelName),
                                   @"channelId" : SAFE_PTR(channel.channelId),
                                   @"channelIcon" : SAFE_PTR(channel.channelIcon),
                                   @"channelPosition" : SAFE_PTR(channel.channelPosition),
                                   @"channelTop" : SAFE_PTR(channel.channelTop),
                                   @"channelTopTime" : SAFE_PTR(channel.channelTopTime),
                                   @"isChannelSubed" : SAFE_PTR(channel.isChannelSubed),
                                   @"isChannelSubed" : SAFE_PTR(channel.isChannelSubed),
                                   @"lastModify" : SAFE_PTR(channel.lastModify),
                                   @"currPosition" : SAFE_PTR(channel.currPosition),
                                   @"localType" : SAFE_PTR(channel.localType),
                                   @"isRecom" : SAFE_PTR(channel.isRecom),
                                   @"tips" : SAFE_PTR(channel.tips),
                                   @"link" : SAFE_PTR(channel.link),
                                   @"add" : @(channel.add),
                                   @"tipsInterval" : @(channel.tipsInterval),
                                   };
    [SNSLib chooseCity:locationInfo];
}

- (void)logout {
    if (nil != _snsController) {
        [_snsController removeFromSupercontroller];
        [_snsController.view removeFromSuperview];
        _snsController = nil;
    }
}

- (void)loginOutWithInfo:(NSDictionary *)info {
//    if (!_userAccountService) {
//        _userAccountService = [[SNUserAccountService alloc] init];
//    }
//    [_userAccountService requestLogout];
    
    [SNNewsLogout requestLogout:nil];
}

#pragma mark - mysdk
- (SNNavigationController *)getNav {
    SNTabBarController *vc = (SNTabBarController *)[TTNavigator navigator].rootViewController;
    return [vc.viewControllers objectAtIndex:vc.selectedIndex];
}

#pragma mark - 自媒体页点击协议
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType offLine:(BOOL)offLine {
    NSString *reqUrlStr = [request.URL absoluteString];
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [SNUtility shouldUseSpreadAnimation:NO];
        
        //打开二代协议（新闻、组图、H5调Native分享、普通H5外链[http/https]）
        NSString *protocol = [NSString stringWithFormat:@"%@://", request.URL.scheme];
        NSDictionary *context = [self produceProtocolContextByProtocolLink2:reqUrlStr offLine:offLine];
        if ([SNUtility isSohuNewsProtocol:protocol]) {
            //不区分openType,直接native打开
            [SNUtility openProtocolUrl:reqUrlStr context:context];
            return NO;
        } else {
            [SNUtility openProtocolUrl:reqUrlStr];
            return NO;
        }
    }
    return YES;
}

- (NSDictionary *)produceProtocolContextByProtocolLink2:(NSString *)protocolLink2
                                                offLine:(BOOL)offLine {
    if (protocolLink2.length <= 0) {
        return nil;
    }
    NSMutableDictionary *protocolContext = [NSMutableDictionary dictionary];
    //解析二代协议中所有参数并加入到context中
    NSMutableDictionary *protocolLink2Params = [[SNUtility getParemsInfoWithLink:protocolLink2] mutableCopy];
    if (![protocolLink2Params objectForKey:kTermId] && [protocolLink2Params objectForKey:kChannelId]) {
        [protocolLink2Params setObject:[protocolLink2Params objectForKey:kChannelId] forKey:kTermId];
    }
    [protocolLink2Params removeObjectForKey:kChannelId];
    
    if (protocolLink2Params.allKeys.count > 0) {
        [protocolContext setValuesForKeysWithDictionary:protocolLink2Params];
        if (offLine) {
            [protocolContext setObject:kNewsOffline forKey:kNewsMode];
        } else {
            [protocolContext setObject:kNewsOnline forKey:kNewsMode];
        }
        [protocolContext setObject:@(GallerySourceTypeNewsPaper) forKey:kGallerySourceType];
        [protocolContext setObject:kReferFromPublication forKey:kReferFrom];
        [protocolContext setObject:protocolLink2 forKey:kLink];
        [protocolContext setObject:protocolLink2 forKey:kOpenProtocolOriginalLink2];
    }
    [protocolContext setObject:@(NO)
                        forKey:kNewsSupportNext];//不支持连续阅读“后面没有新闻了”提示
    return protocolContext;
}
#pragma mark - ***********离线下载
- (void)connectWebviewWithBridge:(UIWebView *)webView withSubId:(NSString *)subID callback:(void (^)(NSString *subId))down {
    _jsBridge = [SNWebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:webView.delegate handler:^(id data, WVJBResponseCallback responseCallback) {
    }];
    
    [_jsBridge registerHandler:@"sohunewsGetTermZip" handler:^(id pubdownloadParameters, WVJBResponseCallback responseCallback) {
        if (!pubdownloadParameters) {
            [SNNotificationCenter showExclamation:NSLocalizedString(@"publication_home_cant_download_for_nil_link", @"")];
            down(nil);
            return;
        }
        
        if ([pubdownloadParameters isKindOfClass:[NSDictionary class]]) {
            down(pubdownloadParameters[@"subId"]);
        } else {
            down(nil);
        }
        
        //如果网络不可用提示网络不可用；
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            return;
        }
        
        //2G、3G网络下进行流量警告
        if ([SNUtility getApplicationDelegate].isWWANNetworkReachable) {
            SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"download_video_pub_bandwidth_alert", @"") cancelButtonTitle:@"取消" otherButtonTitle:NSLocalizedString(@"download anyway", @"")];
            [alertView show];
            [alertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
                [self downloadPublicationWithInfo:pubdownloadParameters];
            }];
            
        } else {
            //Wifi网络环境下就直接下载
            [self downloadPublicationWithInfo:pubdownloadParameters];
        }
    }];
    [_jsBridge registerHandler:@"sohunewsSubComment" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (subID.length > 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:subID forKey:@"subId"];
            TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://subCommentPost"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:action];
        }
    }];
}

- (void)downloadPublicationWithInfo:(NSDictionary *)pubdownloadParameters {
    if ([pubdownloadParameters isKindOfClass:[NSDictionary class]]) {
        SCSubscribeObject *subscribe = [[SCSubscribeObject alloc] init];
        subscribe.subId = pubdownloadParameters[@"subId"];
        subscribe.termId = pubdownloadParameters[@"termId"];
        subscribe.subName = pubdownloadParameters[@"subName"];
        subscribe.termName = pubdownloadParameters[@"termName"];
        [[SNDownloadScheduler sharedInstance] setDelegate:self];
        [[SNDownloadScheduler sharedInstance] downloadSub:subscribe];
    } else {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"publication_home_cant_download_for_invalid_link", @"")];
    }
}

- (void)loadOffLineWebView:(UIWebView *)webView other:(void (^)(NSDictionary *dictionary))other withInfo:(NSDictionary *)info {
    NewspaperItem *localNewspaper = [[SNDBManager currentDataBase] getNewspaperByTermId:info[@"termId"]];
    if (!!localNewspaper && [localNewspaper.downloadFlag isEqualToString:@"1"]
        && [localNewspaper newspaperPath].length > 0 && [localNewspaper realNewspaperPath].length > 0) {
        NSString *subhomeHTMLFilePath = [localNewspaper realNewspaperPath];
        [self requestSubInfoWithLocalSubHomePath:subhomeHTMLFilePath withSubID:info[@"subId"] withBlock:other];
        [self requestSubHomeWithLocalSubHomePath:subhomeHTMLFilePath withWebView:webView];
    }
}

- (void)requestSubHomeWithLocalSubHomePath:(NSString *)subhomeHTMLFilePath withWebView:(UIWebView *)webView{
    if (subhomeHTMLFilePath.length > 0) {
        NSString *subhomeHTMLFileURLString = [self decorateNightModeForLocalSubHome:subhomeHTMLFilePath];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:subhomeHTMLFileURLString]]];
    }
}

- (NSString *)decorateNightModeForLocalSubHome:(NSString *)originalURLString {
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        NSURL *subhomeHTMLFileURL = [NSURL fileURLWithPath:originalURLString];
        NSString *subhomeHTMLFileURLString = [subhomeHTMLFileURL absoluteString];
        subhomeHTMLFileURLString = [subhomeHTMLFileURLString stringByAppendingString:@"?mode=1"];
        return subhomeHTMLFileURLString;
    } else {
        return originalURLString;
    }
}

- (void)requestSubInfoWithLocalSubHomePath:(NSString *)subhomeHTMLFilePath
                                 withSubID:(NSString *)subID
                                 withBlock:(void (^)(NSDictionary *dictionary))other {
    NSString *newspaperRootDir = nil;
    NSRange tmpRange = [subhomeHTMLFilePath rangeOfString:kNewspaperHomePageFlag];
    if (tmpRange.location != NSNotFound) {
        newspaperRootDir = [subhomeHTMLFilePath substringToIndex:tmpRange.location];
    }
    NSString *jsonFilePath = nil;
    if (newspaperRootDir.length > 0) {
        NSString *jsonFileName = [NSString stringWithFormat:@"subinfo_%@.json", subID];
        jsonFilePath = [newspaperRootDir stringByAppendingPathComponent:jsonFileName];
    }
    NSString *jsonString = [NSString stringWithContentsOfFile:jsonFilePath encoding:NSUTF8StringEncoding error:nil];
    id subInfo = [NSJSONSerialization JSONObjectWithString:jsonString
                                                   options:NSJSONReadingMutableLeaves
                                                     error:NULL];
    if ([subInfo isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:subInfo];
        [dic setValue:[newspaperRootDir stringByAppendingString:subInfo[@"subIcon"]]
               forKey:@"avatar"];
        other(dic);
    } else {
        other(nil);
    }
}

#pragma mark - ***********end离线下载
- (NSString *)platformStringForSohuNews {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return [currentDevice platformStringForSohuNews];
}

- (NSString *)getLongitude {
    return [[SNUserLocationManager sharedInstance] getLongitude];
}

- (NSString *)getLatitude {
    return [[SNUserLocationManager sharedInstance] getLatitude];
}

//获取第三方登录信息
- (NSDictionary *)getThirdLoginInfo {
    SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
    if (nil != userInfo && userInfo.from.intValue >= 1) {
        return @{@"login" : @(1),
                 @"avatar" : SAFE_PTR(userInfo.headImageUrl),
                 @"userName" : SAFE_PTR(userInfo.nickName),
                 @"thirdType" : userInfo.from};
    } else {
        return @{@"login" : @(0),
                 @"avatar" : @"",
                 @"userName" : @"", @"thirdType":@""};
    }
}

- (void)updateUserWithInfo:(NSDictionary *)info {
}

// 由于外部没有保存新浪微博的登录数据，所以只能自己保存
// 我发现这个接口的作用并不大了。先留着，估计以后用得着。
- (void)updateSinaWeiBo:(NSString *)openId
                  token:(NSString *)token expireTime:(NSDate *)time {
    if (openId != nil && token != nil) {
        [SNSLib sinaBindBackWithDictionary:@{@"sinaOpenid" : SAFE_PTR(openId),
                                             @"sinaBindStatus" : @(1),
                                             @"sinaToken" : SAFE_PTR(token),
                                             }];
    } else {
        [SNSLib sinaBindBackWithDictionary:@{@"sinaBindStatus":@(0)}];
    }
}

- (NSDictionary *)getBindSinaStatusInfo {
    NSString *sinaOpenid = @"";
    NSNumber *sinaBindStatus = @(0);
    for (ShareListItem *item in [SNShareList shareInstance].shareList) {
        if ([item.appID isEqualToString:@"1"] && nil != item.openId && item.openId.length > 0) {
            sinaBindStatus = @(1);
            sinaOpenid = [NSString stringWithString:item.openId];
            
            break;
        }
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sinaToken = [userDefaults objectForKey:@"kSinaAccessToken"];
    
    if (!sinaToken) {
        sinaBindStatus = @(0);
    }
    
    NSDictionary *bindInfo = @{@"sinaOpenid" : SAFE_PTR(sinaOpenid),
                               @"sinaBindStatus" : SAFE_PTR(sinaBindStatus),
                               @"sinaToken" : SAFE_PTR(sinaToken)};
    
    return bindInfo;
}

- (void)bindAccount:(NSString *)appId openId:(NSString *)openId {
    if ([@"1" isEqualToString:appId]) {
        [SNSLib sinaBindBackWithDictionary:@{@"sinaOpenid" : openId,
                                             @"sinabBindStatus" : @(1)}];
    }
}

- (void)unbindAccount:(NSString *)appId {
    if ([@"1" isEqualToString:appId]) {
        [SNSLib sinaBindBackWithDictionary:@{@"sinaOpenid" : SAFE_PTR(nil),
                                             @"sinabBindStatus" : @(0)}];
    }
}

//跳转绑定手机界面
- (void)pushToBindPhoneViewController {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle",@"1",@"commentBindOpen",nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

- (void)bindPhone:(NSString *)phone {
    [SNSLib bindPhoneWith:@{@"phone" : SAFE_PTR(phone)}];
}

//获取当前小红点状态 YES为显示
- (BOOL)getRedPointShowStatus {
    sohunewsAppDelegate *app = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
    return [app.appTabbarController isBubbleAnimatingAtTabBarIndex:TABBAR_INDEX_MORE];
}

#pragma mark - huangjing  -修改小红点显示方法
//改变小红点状态 YES为显示
- (void)changeRedPointShowStatus:(BOOL)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        sohunewsAppDelegate *app = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
        [app.appTabbarController flashTabBarItem:show atIndex:TABBAR_INDEX_MORE];
    });
}

#pragma mark - end
- (void)clickTabLastSelsct:(int)lastIndex andClickSelext:(int)index {
    [SNSLib clickTabLastSelsct:lastIndex andClickSelext:index];
}

//后台统计
- (void)addLog:(NSString *)string {
    [[SNLogManager sharedInstance] addLog:string];
}

- (void)popToRoot {
    [SNUtility popViewToRootController];
}

- (void)popToPreview {
    [SNUtility popViewToPreViewController];
}

- (NSString *)getTabItemText {
    if ([SNUtility getTabBarName:2]) {
        return [SNUtility getTabBarName:2];
    }
    return NSLocalizedString(@"Me", nil);
}

- (void)reLocation {
    [[SNUserLocationManager sharedInstance] updateLocation];
}

- (void)resetOpenInSafariView {
    [SNUtility banUniversalLinkOpenInSafari];
}

/**
 更新sns的session，tabbar切换时更新（包含点击切换及二代协议切换）
 目前是切到新闻tab及狐友tab时更新
 */
- (void)updateSnsSessionWithTabbarSelectedIndex:(NSUInteger)selectedIndex{
    [SNSLib updateSnsSessionWithTabbarSelectedIndex:selectedIndex];
}

- (CTTelephonyNetworkInfo *)creatTelephonyNetworkInfo {
    return [SNUtility sharedUtility].tNetworkInfo;
}

@end
