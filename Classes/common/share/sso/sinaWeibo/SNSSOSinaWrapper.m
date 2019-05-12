//
//  SNSSOSinaWrapper.m
//  sohunews
//
//  Created by wang yanchen on 13-2-20.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSSOSinaWrapper.h"
#import "SNShareManager.h"

#import "SNMySDK.h"
#import "SNLoginLaterBingPhone.h"
#import "SNUserManager.h"

#import "SNNewsThirdLoginEnable.h"
#import "SNNewsRecordLastLogin.h"

@interface SNSSOSinaWrapper ()<SNLoginLaterBingPhoneDelegate>

@property (nonatomic,strong) SNLoginLaterBingPhone* bingPhone;
@property (nonatomic,strong) WBBaseResponse* resp_weibo;

@end

@implementation SNSSOSinaWrapper

+ (BOOL)isHaveToken{
    NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSinaAccessToken"];
    if (str && str.length>0) {
        return YES;
    }
    return NO;
}

- (id)init {
    self = [super init];
    if (self) {
        [SNNotificationManager addObserver:self selector:@selector(onUserLogout:) name:kUserDidLogoutNotification object:nil];
    }
    return self;
}

+ (SNSSOSinaWrapper *)sharedInstance {
    static SNSSOSinaWrapper *_instance = nil;
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[SNSSOSinaWrapper alloc] init];
        }
    }
    return _instance;
}

+ (BOOL)sinaSDKRegister {
    return [WeiboSDK registerApp:kSinaAppKey];
}

- (void)dealloc {
     //(_sinaWeibo);
    [SNNotificationManager removeObserver:self];
}

- (void)login {
    [SNSSOSinaWrapper sharedInstance].isSinaWebOpen = YES;
    WBAuthorizeRequest *wbRequest = [WBAuthorizeRequest request];
    wbRequest.redirectURI = SNLinks_Domain_ApiK;
    wbRequest.scope = @"all";
    wbRequest.userInfo = nil;
    [WeiboSDK sendRequest:wbRequest];
}

- (BOOL)handleOpenUrl:(NSURL *)url {
//    NSString *urlString = [url absoluteString];
//    NSString *ssoCallbackScheme = [NSString stringWithFormat:@"sinaweibosso.%@://", kSinaAppKey];
//    if ([urlString hasPrefix:ssoCallbackScheme]) {
//        [_sinaWeibo handleOpenURL:url];
//        return YES;
//    }
//    return NO;
    
    //在设置URL Type时，URL Shcheme 需要固定格式wb3651065292(即wb和sina appkey)
    return [WeiboSDK handleOpenURL:url delegate:[SNSSOSinaWrapper sharedInstance]];
}

- (void)handleApplicationDidBecomeActive {
    [_sinaWeibo applicationDidBecomeActive];
}

#pragma mark - SinaWeiboDelegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo {
    self.accessToken = sinaweibo.accessToken;
    self.refreshToken = sinaweibo.refreshToken;
    self.userId = sinaweibo.userID;
    self.expirationDate = sinaweibo.expirationDate;
    
    if ([_delegate respondsToSelector:@selector(ssoDidLogin:)]) {
        [_delegate ssoDidLogin:self];
    }
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo {
    // never mind
    
    [[SNMySDK sharedInstance] updateSinaWeiBo:nil token:nil expireTime:nil];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo {
    if ([_delegate respondsToSelector:@selector(ssoDidCancelLogin:)]) {
        [_delegate ssoDidCancelLogin:self];
    }
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error {
    self.lastError = error;
    self.lastErrorMessage = [error localizedDescription];
    
    if ([_delegate respondsToSelector:@selector(ssoDidFailLogin:)]) {
        [_delegate ssoDidFailLogin:self];
    }
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error {
    self.lastError = error;
    self.lastErrorMessage = [error localizedDescription];
    
    if ([_delegate respondsToSelector:@selector(ssoDidFailLogin:)]) {
        [_delegate ssoDidFailLogin:self];
    }
}

////////////////////////////////////////////////////////////////////////////////////
//5.2 add new sina sdk delegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    [SNSSOSinaWrapper sharedInstance].isSinaWebOpen = NO;
    if (self.resp_weibo != nil) {
        self.resp_weibo = nil;
    }
    self.resp_weibo = response;
    
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        
        SNDebugLog(@"statusCode:%d",response.statusCode);
        
        if (response.statusCode != WeiboSDKResponseStatusCodeSuccess) {
            return;
        }
        
        [SNNewsThirdLoginEnable sharedInstance].isLanding = YES;
        [[SNCenterToast shareInstance] showWithTitle:@"正在登录.."];
        
        if ([SNSSOSinaWrapper sharedInstance].isCommentBindWeibo == YES) {
            [self syncTokenLoginInfo:self.resp_weibo];
            [SNSSOSinaWrapper sharedInstance].isCommentBindWeibo = NO;
            return;
        }
        
        //wangshun login
        //sina网页登录，SSO登录成功回调
        NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
        NSString *userID = [(WBAuthorizeResponse *)response userID];
        NSDate *expirationDate = [(WBAuthorizeResponse *)response expirationDate];
        NSString* expire =[NSString stringWithFormat:@"%zd",(long long)[expirationDate timeIntervalSince1970]];

        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"kSinaAccessToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[self syncTokenLoginInfo:response];
        //wangshun
        //原来直接同步信息
        //现在加入绑定流程 wangshun 2017.3.6
        
        if (self.bingPhone != nil) {
            self.bingPhone = nil;
        }
        
        NSDictionary* params = @{@"openId":userID,@"token":accessToken,@"expire":expire,@"appId":@"sina",@"from":@"login"};
        self.bingPhone = [[SNLoginLaterBingPhone alloc] initWithDelegate:self];
        [self.bingPhone bindThirdPartyLogin:params];
    }
}

- (void)syncTokenLoginInfo:(WBBaseResponse *)response{
    
        //这个重构再说 不干扰登录逻辑
    
        //评论同时分享至weibo
    SNShareManager* manager = [SNShareManager defaultManager];
    if (manager.delegate) {
        if ([manager.delegate respondsToSelector:@selector(shareManagerDidAuthAndLoginSuccess:)]) {
            [manager.delegate shareManagerDidAuthAndLoginSuccess:manager];
        }
    }
    
    //sina网页登录，SSO登录成功回调
    NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
    NSString *refreshToken = [(WBAuthorizeResponse *)response refreshToken];
    NSString *userID = [(WBAuthorizeResponse *)response userID];
    NSDate *expirationDate = [(WBAuthorizeResponse *)response expirationDate];
    
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
    self.userId = userID;
    self.expirationDate = expirationDate;
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"kSinaAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SNMySDK sharedInstance] updateSinaWeiBo:userID token:accessToken expireTime:expirationDate];
    
    [[SNShareManager defaultManager] syncToken:accessToken
                                  refreshToken:refreshToken
                                        expire:expirationDate
                                      userName:nil
                                        userId:userID
                                         appId:@"1"];// 程序中定义的，sina为1
}


- (void)onUserLogout:(NSNotification *)notification {
    NSString *sinaAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSinaAccessToken"];
    if (sinaAccessToken) {
        [WeiboSDK logOutWithToken:sinaAccessToken delegate:self withTag:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kSinaAccessToken"];
    }
    [SNSSOSinaWrapper sharedInstance].isSinaWebOpen = NO;
}

#pragma WBHttpRequestDelegate

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result {
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark -  sns 埋点

- (void)burySuccess:(NSString*)sender{
    NSString* loginType = @"weibo";
    NSString* sourceChannelID = [SNShareManager defaultManager].loginFrom;
    NSDictionary* dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"cid":[SNUserManager getP1]};
    if ([sender isEqualToString:@"-1"]) {
        dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"errType":@"0",@"cid":[SNUserManager getP1]};
    }
        
    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
}

#pragma mark - SNLoginLaterBingPhoneDelegate

-(void)loginSuccessed:(NSDictionary*)data{
    //[self syncTokenLoginInfo:self.resp_weibo];
    [[SNCenterToast shareInstance] hideToast];
    [[SNCenterToast shareInstance] showWithTitle:@"登录成功"];
    [self burySuccess:@"1"];
    //sina网页登录，SSO登录成功回调
    WBBaseResponse* response = self.resp_weibo;
    NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
    NSString *userID = [(WBAuthorizeResponse *)response userID];
    NSDate *expirationDate = [(WBAuthorizeResponse *)response expirationDate];
    NSString *refreshToken = [(WBAuthorizeResponse *)response refreshToken];
    
    self.accessToken = accessToken;
    self.userId = userID;
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"kSinaAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SNMySDK sharedInstance] updateSinaWeiBo:userID token:accessToken expireTime:expirationDate];
    
    if (self.thirdLoginSuccess) {
        self.thirdLoginSuccess = nil;
    }
    
    if (data == nil) {
        data = self.userInfoDic;
    }
    
    self.thirdLoginSuccess = [[SNThirdLoginSuccess alloc] init];
    self.thirdLoginSuccess.appId = @"1";//微博
    [self.thirdLoginSuccess loginSuccessed:data WithThirdData:nil];
    
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"weibo",@"value":@"1"}];
    
    [[SNShareManager defaultManager] syncToken:accessToken refreshToken:refreshToken expire:expirationDate userName:nil userId:userID appId:@"1"];// 程序中定义的，sina为1
}

- (void)openBingPhoneViewControllerData:(NSDictionary*)dic{
    [[SNCenterToast shareInstance] hideToast];
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:@"绑定手机", @"headTitle", @"立即绑定", @"buttonTitle", dic,@"data",self,@"third",nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

-(void)openBindPhoneViewControllerData:(NSDictionary *)dic WithUserInfo:(NSDictionary *)userinfo{
    self.userInfoDic = userinfo;
    [[SNCenterToast shareInstance] hideToast];
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:@"绑定手机", @"headTitle", @"立即绑定", @"buttonTitle", dic,@"data",self,@"third",nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

////////////////////////////////////////////////////////////////////////////////////
@end
