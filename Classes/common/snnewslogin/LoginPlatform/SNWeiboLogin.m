//
//  SNWeiboLogin.m
//  sohunews
//
//  Created by wang shun on 2017/4/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNWeiboLogin.h"
#import "SNNewsSSOOpenUrl.h"
#import "SNLoginLaterBingPhone.h"
#import "SNMySDK.h"

#import "SNNewsLoginManager.h"

@interface SNWeiboLogin ()<SNLoginLaterBingPhoneDelegate>

@property (nonatomic,strong) SNLoginLaterBingPhone* bingPhone;
@property (nonatomic,strong) WBBaseResponse* resp_weibo;

@property (nonatomic,strong) NSDictionary* open_params;

@property (nonatomic,copy) void (^successed_Method)(NSDictionary*resultDic);

@end

@implementation SNWeiboLogin

-(instancetype)initWithParams:(NSDictionary*)params WithSuccess:(void (^)(NSDictionary*))method{
    if (self = [super init]) {
        self.open_params = params;
        if (method) {
            self.successed_Method = method;
        }
    }
    return self;
}

#pragma mark -  登录

+ (void)weiboLogin:(NSDictionary*)params WithSuccess:(void (^)(NSDictionary*))method{
    
    [SNNewsSSOOpenUrl sharedInstance].isLogin = YES;
    SNWeiboLogin* weiboLogin = [[SNWeiboLogin alloc] initWithParams:params WithSuccess:method];
    [[SNNewsSSOOpenUrl sharedInstance] setWeiboLogin:weiboLogin];
    
    WBAuthorizeRequest *wbRequest = [WBAuthorizeRequest request];
    wbRequest.redirectURI = SNLinks_Domain_ApiK;
    wbRequest.scope = @"all";
    wbRequest.userInfo = nil;
    [WeiboSDK sendRequest:wbRequest];
}

////////////////////////////////////////////////////////////


#pragma mark -
//weibo 回调
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if (self.resp_weibo != nil) {
        self.resp_weibo = nil;
    }
    self.resp_weibo = response;
    
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        
        SNDebugLog(@"statusCode:%d",response.statusCode);

        //wangshun login
        //sina网页登录，SSO登录成功回调
        NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
        NSString *refreshToken = [(WBAuthorizeResponse *)response refreshToken];
        NSString *userID = [(WBAuthorizeResponse *)response userID];
        NSDate *expirationDate = [(WBAuthorizeResponse *)response expirationDate];
        NSString* expire =[NSString stringWithFormat:@"%zd",(long long)[expirationDate timeIntervalSince1970]];

        //现在加入绑定流程 wangshun 2017.3.6
     
        if (self.bingPhone != nil) {
            self.bingPhone = nil;
        }
        
        NSDictionary* params = @{@"openId":userID,@"token":accessToken,@"expire":expire,@"appId":@"sina",@"from":@"login"};
        self.bingPhone = [[SNLoginLaterBingPhone alloc] initWithDelegate:self];
        [self.bingPhone bindThirdPartyLogin:params];
    }
    
}

////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SNLoginLaterBingPhoneDelegate

-(void)loginSuccessed:(NSDictionary*)data{
    //[self syncTokenLoginInfo:self.resp_weibo];
    
    //sina网页登录，SSO登录成功回调
    WBBaseResponse* response = self.resp_weibo;
    NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
    NSString *userID = [(WBAuthorizeResponse *)response userID];
    NSDate *expirationDate = [(WBAuthorizeResponse *)response expirationDate];
    NSString *refreshToken = [(WBAuthorizeResponse *)response refreshToken];
    
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
    [self.thirdLoginSuccess loginSuccessed:data WithThirdData:nil WithSuccessed:self.successed_Method];
}

-(void)openBindPhoneViewControllerData:(NSDictionary *)dic WithUserInfo:(NSDictionary *)userinfo{
    if (userinfo) {
        self.userInfoDic = userinfo;
    }
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"data",self,@"third",nil];
    [SNNewsLoginManager bindData:query Successed:self.successed_Method];
}

////////////////////////////////////////////////////////////////////////////////////

@end
