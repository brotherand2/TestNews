//
//  SNActionUserLoginManager.m
//  sohunews
//
//  Created by lhp on 9/30/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNActionSheetLoginManager.h"
#import "SNLoginRegisterViewController.h"
#import "SNOauthWebViewController.h"
#import "SNMyFavouriteManager.h"
#import "SNH5WebController.h"
#import "SNTimelinePostService.h"
#import "SNTimelineObjects.h"
#import "SNBindMobileNumViewController.h"
#import "SNUserManager.h"
#import "SNAdvertiseManager.h"
#import "SNSLib.h"
#import "SNCloudSynRequest.h"
#import "SNBaseWebViewController.h"

@interface SNActionSheetLoginManager (){
    BOOL _loginMsgFromShareSns;
}

@property(nonatomic,strong) NSString *subId;
@property(nonatomic,strong) NSString *pid;
@property(nonatomic,strong) NSString *link;
@property (nonatomic, strong)NSString *actId;
@property (nonatomic, assign)int hasApproval;

@end

@implementation SNActionSheetLoginManager
@synthesize guideDic;
@synthesize favouriteObject;
@synthesize logining;

+ (SNActionSheetLoginManager *)sharedInstance {
    static SNActionSheetLoginManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNActionSheetLoginManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userinfoModel = [[SNUserAccountService alloc] init];
        [SNNotificationManager addObserver:self selector:@selector(notifyLoginSuccess) name:kNewsCollectReportNotification object:nil];
//        [SNNotificationManager addObserver:self selector:@selector(notifyLoginSuccess) name:kMobileNumLoginSucceedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(loginMsgFromShareSNS) name:kLoginMsgFromShareToSNSNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(loginSuccess) name:kBackFromBindViewControllerNotification object:nil];
        _loginMsgFromShareSns = NO;
    }
    return self;
}

- (void)setNewGuideDic:(NSDictionary *) dictionary {
    
    NSNumber *type = [dictionary objectForKey:kRegisterInfoKeyGuideType];
    _guideType = [type intValue];
    self.subId = [dictionary stringValueForKey:kRegisterInfoKeySubId defaultValue:nil];
    self.pid = [dictionary objectForKey:kRegisterInfoKeyUserPid];
    self.link = [dictionary objectForKey:kRegisterInfoKeyUserLink];
    self.backUrl = [dictionary objectForKey:kRegisterInfoKeyBackUrl];
    self.actId = [dictionary objectForKey:kRegisterInfoKeyActId];
    self.hasApproval = [dictionary intValueForKey:kRegisterInfoKeyApprovalType defaultValue:0];
    //v5.1 add
    self.favouriteObject = [dictionary objectForKey:kRegisterInfoKeyFavObject];
    self.newsId = [dictionary objectForKey:kRegisterInfoKeyNewsId];
    self.forceBackWebView = [[dictionary objectForKey:kWebViewForceBackKey] boolValue];
}

- (void)resetNewGuideDic {
    _guideType = 0;
    self.subId = nil;
    self.pid = nil;
    self.link = nil;
    self.backUrl = nil;
    self.actId = nil;
    self.hasApproval = 0;
    self.favouriteObject = nil;
    self.newsId = nil;
    self.forceBackWebView = NO;
}

- (void)loginWithIndex:(NSInteger) index {
    
    NSString *loginType = nil;
    
    if ([WXApi isWXAppInstalled]) {
        switch (index) {
            case 0:
                loginType = @"mobile";
                break;
            case 1:
                loginType = @"wechat";
                break;
            case 2:
                loginType = @"sina";
                break;
//            case 2:
//                loginType = @"t.qq";
//                break;
            case 3:
                loginType = @"qq";
                break;
            
            case 4: {
                NSValue *method = [NSValue valueWithPointer:@selector(loginSuccess)];
                NSDictionary *dic= [NSDictionary dictionaryWithObjectsAndKeys:method, @"method", [NSNumber numberWithInteger:_guideType], kRegisterInfoKeyGuideType, self.backUrl, kRegisterInfoKeyBackUrl, nil];
                //[SNUtility openLoginViewWithDict:dic];
                return;
            }
            default:
                loginType = nil;
                break;
        }
    }
    else {
        switch (index) {
            case 0:
                loginType = @"mobile";
                break;
            case 1:
                loginType = @"sina";
                break;
//            case 2:
//                loginType = @"t.qq";
//                break;
            case 2:
                loginType = @"qq";
                break;
            case 3: {
                NSValue *method = [NSValue valueWithPointer:@selector(loginSuccess)];
                NSDictionary *dic= [NSDictionary dictionaryWithObjectsAndKeys:method, @"method", [NSNumber numberWithInteger:_guideType], kRegisterInfoKeyGuideType, self.backUrl, kRegisterInfoKeyBackUrl, nil];
                //[SNUtility openLoginViewWithDict:dic];
                return;
            }
            default:
                loginType = nil;
                break;
        }
    }
    
    if (loginType && ![loginType isEqualToString:@"mobile"]) {
        self.logining = YES;
        _userinfoModel.openLoginUrlDelegate = self;
        _userinfoModel.loginDelegate = self;
        isSSO = ![_userinfoModel openLoginLinkRequest:loginType loginFrom:nil];
    }
    else if ([loginType isEqualToString:@"mobile"]) {
        //open mobile login page
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机登录", @"headTitle", @"立即登录", @"buttonTitle", self.backUrl, kRegisterInfoKeyBackUrl, nil];
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
    else {
        isSSO = NO;
    }
}

- (void)cleanGuideType {
    _guideType = SNGuideRegisterTypeUnknow;
}

- (SNGuideRegisterType)getGuideRegisterType {
    return _guideType;
}

- (BOOL)guideLoginSuccessFunction
{
    
    switch (_guideType) {
        case SNGuideRegisterTypeSubscribe:
        {
            [SNGuideRegisterManager guideForSubscribe:self.subId];
            return isSSO ? NO:YES;
        }
        case SNGuideRegisterTypeContentComment:
        {
            [SNGuideRegisterManager guideForContentComment];
            return isSSO ? NO:YES;
        }
        case SNGuideRegisterTypeMediaComment:
        {
            [SNGuideRegisterManager guideForMediaComment];
            return isSSO ? NO:YES;
        }
        case SNGuideRegisterTypeShake:
        {
            if (self.subId.length > 0)
                [SNGuideRegisterManager guideForShake:self.subId];
            return isSSO ? NO:YES;
        }
        case SNGuideRegisterTypeUsercenter:
        {
            [SNGuideRegisterManager guideForUserCenter:self.pid userSpace:self.link];
            return NO;
        }
        case SNGuideRegisterTypeUserAttention:
        {
            [SNGuideRegisterManager guideForAttention];
            return isSSO ? NO:YES;
        }
        case SNGuideRegisterTypeLogin:
        {
            //[SNGuideRegisterManager showUserCenter];
            return NO;
        }
        case SNGuideRegisterTypeFav:
        {
            [SNGuideRegisterManager showMyFavByFloat];
            return NO;
        }
        case SNGuideRegisterTypeMessage:
        {
            [SNGuideRegisterManager showMyMessageByFloat];
            return NO;
        }
        case SNGuideRegisterTypeFavNews:
        {
            if (self.favouriteObject && self.favouriteObject.title.length!=0) {
                [[SNMyFavouriteManager shareInstance] addToMyFavouriteList:self.favouriteObject];
            }
            return NO;
        }
        case SNGuideRegisterTypeProtocolLogin:
        {
            if (self.backUrl.length > 0) {
                NSString *urlString = nil;
                if ([SNAPI isWebURL:self.backUrl]) {
                    urlString = [SNUtility addParamSuccessToURL:self.backUrl];
                }
                else {
                    urlString = self.backUrl;
                }
                [SNUtility openProtocolUrl:urlString];
            }
            else {
                [self refreshBackUrl];
            }
            return isSSO ? NO:YES;
        }
        case SNGuideRegisterTypeTrendApproval:
        {
            [[SNTimelinePostService sharedService] timelineTrendApproval:self.actId
                                                                    spid:self.pid
                                                            approvalType:self.hasApproval];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (self.actId.length) {
                [dic setObject:self.actId forKey:kSNTLTrendKeyActId];
            }
            [SNNotificationManager postNotificationName:kTLTrendSendApprovalSucNotification object:dic];
            return YES;
        }
        case SNGuideRegisterTypeReport:
        {
            if (self.newsId) {
                NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.newsId,@"newsId", nil];
                NSString *urlString = [NSString stringWithFormat:kUrlReport,@"1"];
                urlString = [SNUtility addParamP1ToURL:urlString];
                urlString = [NSString stringWithFormat:@"%@&newsId=%@", urlString, self.newsId];
                [dic setObject:urlString forKey:kLink];
                [dic setObject:[NSNumber numberWithInt:ReportWebViewType] forKey:kUniversalWebViewType];
                [SNUtility openUniversalWebView:dic];
            }
            return NO;
        }
        case SNGuideRegisterTypeBackToUrl: {
            NSString *backUrl = [[SNActionSheetLoginManager sharedInstance] backUrl];
            if (backUrl.length > 0) {
                NSArray *viewsArray = [TTNavigator navigator].topViewController.flipboardNavigationController.viewControllers;
                NSInteger index = [viewsArray count] - 1;
                if ([[viewsArray objectAtIndex:index] isKindOfClass:[SNBaseWebViewController class]] && index > 1) {
                    if ([[viewsArray objectAtIndex:index - 1] isKindOfClass:[SNBaseWebViewController class]]) {
                        [[TTNavigator navigator].topViewController.flipboardNavigationController popToViewController:[viewsArray objectAtIndex:index - 1] animated:YES];
                    }
                }
                if ([SNUtility isProtocolV2:backUrl] || [backUrl hasPrefix:@"http"]) {
                    NSString *urlString = nil;
                    if ([SNAPI isWebURL:backUrl]) {
                        urlString = [SNUtility addParamSuccessToURL:backUrl];
                    }
                    else {
                        urlString = backUrl;
                    }
                    [SNUtility openProtocolUrl:urlString];
                }
            }
            return NO;
        }
        default:
            return NO;
    }
}

- (void)loginSuccessedWithBlock:(void (^)(NSDictionary* info))method{
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_login_success", @"") toUrl:nil mode:SNCenterToastModeSuccess];
    
    [[SNAdvertiseManager sharedManager] sendPassportIdForLoginSuccessed:[SNUserManager getPid]];
    
    //先处理返回，再打开新得页面
    NSArray* viewsArray = [TTNavigator navigator].topViewController.flipboardNavigationController.viewControllers;
    for(int i = 0; i < viewsArray.count; ++i)
    {
        UIViewController* controller = [viewsArray objectAtIndex:i];
        if(([controller isKindOfClass:[SNLoginRegisterViewController class]]) || ([controller isKindOfClass:[SNOauthWebViewController class]]) || ([controller isKindOfClass:[SNBindMobileNumViewController class]]) || ([controller isKindOfClass:[SNWebController class]] && self.backUrl.length > 0))
        {
            int popIndex = i - 1;
            if(popIndex >= 0 && popIndex < viewsArray.count)
            {
                UIViewController* popController = [viewsArray objectAtIndex:popIndex];
                [[TTNavigator navigator].topViewController.flipboardNavigationController popToViewController:popController animated:NO completion:^{ // pop完成之后再弹出评论
                    if (_guideType == SNGuideRegisterTypeContentComment || _guideType == SNGuideRegisterTypeReplayComment) {
                        [SNGuideRegisterManager guideForContentComment];
                    }
                    
                    if (method) {
                        method(nil);
                    }
                    
                }];
                
                UIViewController *viewController = [SNSLib forLoginSuccessToPush];
                if (nil != viewController) {
                    [[TTNavigator navigator].topViewController.flipboardNavigationController pushViewController:viewController animated:YES];
                    return;
                }
                
                
                
                break;
            }
        }
    }
}

//人人网账号登陆成功 百度账号登陆成功 淘宝账号登陆成功 腾讯微博 搜狐账号 手机号登陆
- (void)loginSuccess
{
    SNDebugLog(@"wangshun login mobile login Success");
    [self loginSuccessedWithBlock:nil];
//    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_login_success", @"") toUrl:nil mode:SNCenterToastModeSuccess];
//    
//    [[SNAdvertiseManager sharedManager] sendPassportIdForLoginSuccessed:[SNUserManager getPid]];
//    
//    //先处理返回，再打开新得页面
//    NSArray* viewsArray = [TTNavigator navigator].topViewController.flipboardNavigationController.viewControllers;
//    for(int i = 0; i < viewsArray.count; ++i)
//    {
//        UIViewController* controller = [viewsArray objectAtIndex:i];
//        if(([controller isKindOfClass:[SNLoginRegisterViewController class]]) || ([controller isKindOfClass:[SNOauthWebViewController class]]) || ([controller isKindOfClass:[SNBindMobileNumViewController class]]) || ([controller isKindOfClass:[SNWebController class]] && self.backUrl.length > 0))
//        {
//            int popIndex = i - 1;
//            if(popIndex >= 0 && popIndex < viewsArray.count)
//            {
//                UIViewController* popController = [viewsArray objectAtIndex:popIndex];
//                [[TTNavigator navigator].topViewController.flipboardNavigationController popToViewController:popController animated:NO completion:^{ // pop完成之后再弹出评论
//                    if (_guideType == SNGuideRegisterTypeContentComment || _guideType == SNGuideRegisterTypeReplayComment) {
//                        [SNGuideRegisterManager guideForContentComment];
//                    }
//                    
//                    
//
//                }];
//                
//                UIViewController *viewController = [SNSLib forLoginSuccessToPush];
//                if (nil != viewController) {
//                    [[TTNavigator navigator].topViewController.flipboardNavigationController pushViewController:viewController animated:YES];
//                    return;
//                }
//                
//                
//                
//                break;
//            }
//        }
//    }

    return;
    
#if 0 //wangshun
    
    NSString *sourceType = [SNUserDefaults objectForKey:kLoginSourceTag];
    BOOL isOpenMobileBind = [SNUtility isOpenMobileBindSwitch:sourceType];
    SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
//    if (!userInfoEx.isRealName) {
//        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle", nil];
//        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
//        [[TTNavigator navigator] openURLAction:_urlAction];
//        return;
//    }
    
    if (_loginMsgFromShareSns) {
        _loginMsgFromShareSns = NO;
        [SNNotificationManager postNotificationName:kUserDidLoginNotification1 object:nil];
    }
    

#pragma mark - huangjing  //登录后返回我的界面需要跳新的界面   我的sdk不知道新闻端什么时候退出登录界面完毕 故在此发送通知
    [SNNotificationManager postNotificationName:kBackToMySdkNotification object:nil];
#pragma mark - end
    
      [self guideLoginSuccessFunction];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([SNPreference sharedInstance].simulateCloudSyncEnabled) {
        [params setValue:@"1" forKey:@"isDebug"];
    }
    [[[SNCloudSynRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id requestDict) {
        NSString *statusText = [requestDict objectForKey:@"statusText"];
        if ([statusText isEqualToString:@"Need sync"]) {
            NSArray *dataArray = [requestDict objectForKey:@"data"];
            if ([dataArray count] > 0) {
                NSDictionary *syncDict = (NSDictionary *)[dataArray objectAtIndex:0];
                NSString *cidString = [syncDict objectForKey:@"cid"];
                [SNUserDefaults setObject:cidString forKey:kCloudSynchronousCid];
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
    
    
#endif
}

- (void)loginMsgFromShareSNS{
    _loginMsgFromShareSns = YES;
}

- (void)refreshBackUrl
{
    UIViewController* currentController = [[TTNavigator navigator].topViewController.flipboardNavigationController currentViewController];
    if([currentController isKindOfClass:[SNH5WebController class]])
    {
        SNH5WebController* webContrller = (SNH5WebController*)currentController;
        if(self.backUrl.length > 0)
        {
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.backUrl]];
            [webContrller openRequest:request];
        }
        else
        {
            [webContrller reload];
        }
            
    }
}

#pragma mark - SNUserAccountOpenLoginUrlDelegate
//Get user info
- (void)notifyOpenLoginUrSuccess:aUrl domain:(NSString*)aDomain {
    
}

- (void)notifyOpenLoginUrFailure:(NSInteger)aStatus msg:(NSString*)aMsg {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeOnlyText];
    
}

- (void)notifyOpenLoginUrDidFailLoadWithError:(NSError*)error {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
}

//wangshun 2017.5.8
-(void)mobileLoginSuccess:(NSDictionary *)params SuccessBlock:(void (^)(NSDictionary *info))method{
    [self loginSuccessedWithBlock:method];
    self.logining = NO;
//    [self notifyLoginSuccess];
}

#pragma mark - SNUserAccountModelLoginDelegate

- (void)notifyLoginSuccess {
    [self loginSuccess];
    self.logining = NO;
}

- (void)notifyLoginFailure:(NSInteger)aStatus msg:(NSString*)aMsg {
    self.logining = NO;
    if (self.backUrl.length > 0) {
        NSString *toastUrl = [SNUtility addParamSuccessToURL:self.backUrl];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"fail_login_click_visit", nil) toUrl:toastUrl mode:SNCenterToastModeOnlyText];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeSuccess];
    }
}

- (void)notifyLoginRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    self.logining = NO;
}


- (void)dealloc
{
    [_userinfoModel clearRequestAndDelegate];
    [SNNotificationManager removeObserver:self];
}

@end
