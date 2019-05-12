//
//  SNWeiboLogin.m
//  sohunews
//
//  Created by wang shun on 2017/4/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNWeiboLogin.h"
#import "SNNewsSSOOpenUrl.h"
#import "SNThirdBindPhone.h"
#import "SNMySDK.h"

#import "SNNewsLoginManager.h"
#import "SNThirdLoginViewModel.h"
#import "SNNewsRecordLastLogin.h"
#import "SNUserManager.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginThirdAnalyse.h"
#import "SNNewsPPLoginEnvironment.h"


@interface SNWeiboLogin ()<SNThirdBindPhoneDelegate>

@property (nonatomic,strong) SNThirdBindPhone* bingPhone;
@property (nonatomic,strong) WBBaseResponse* resp_weibo;

@property (nonatomic,strong) NSDictionary* open_params;

@property (nonatomic,copy) void (^successed_Method)(NSDictionary*resultDic);

@property (nonatomic,weak) SNThirdLoginViewModel* vModel;

//埋点
@property (nonatomic,strong) NSString* loginFrom;
@property (nonatomic,strong) NSString* local_plat;
@property (nonatomic,strong) NSString* screen;

@property (nonatomic,strong) NSString* entrance;//埋点

@end

@implementation SNWeiboLogin

-(instancetype)initWithParams:(NSDictionary*)params WithSuccess:(void (^)(NSDictionary*))method{
    if (self = [super init]) {
        self.open_params = params;
        
        self.loginFrom = [self.open_params objectForKey:@"loginFrom"];
        self.entrance = [self.open_params objectForKey:@"entrance"];
        self.local_plat = @"weibo";
        self.screen = [self.open_params objectForKey:@"screen"];
        
        if (method) {
            self.successed_Method = method;
        }
    }
    return self;
}

#pragma mark -  登录

+ (void)weiboLogin:(NSDictionary*)params thridModel:(SNThirdLoginViewModel*)vModel WithSuccess:(void (^)(NSDictionary*))method{
    
    [SNNewsSSOOpenUrl sharedInstance].isLogin = YES;
    SNWeiboLogin* weiboLogin = [[SNWeiboLogin alloc] initWithParams:params WithSuccess:method];
    weiboLogin.vModel = vModel;
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
        if (response.statusCode != WeiboSDKResponseStatusCodeSuccess) {
            return;
        }

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
        
        self.vModel.isOpeningThrid = YES;
        
        if (self.successed_Method) {
            self.successed_Method(@{@"success":@"-1"});
        }
        
        NSString* plat = @"weibo";
        NSString* sourceID = [self.open_params objectForKey:@"loginFrom"]?:@"";
        
        NSDictionary* params = @{@"openId":userID,@"token":accessToken,@"expire":expire,@"appId":@"sina",@"from":@"login",@"loginFrom":sourceID,@"local_plat":plat,@"screen":self.screen?:@"0"};
        
        if ([SNNewsPPLoginEnvironment isPPLogin]) {
            NSMutableDictionary* pp_mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            [pp_mDic setObject:SNNews_Weibo_APPKEY forKey:@"openkey"];
            [pp_mDic setObject:userID forKey:@"openid"];
            [pp_mDic setObject:userID forKey:@"userid"];
            [pp_mDic setObject:@"sina" forKey:@"platform"];
            
            [pp_mDic setObject:accessToken forKey:@"accesstoken"];
            [pp_mDic setObject:refreshToken forKey:@"refreshtoken"];
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"正在登录..." toUrl:nil mode:SNCenterToastModeOnlyText];
            [SNNewsPPLogin thirdLogin:pp_mDic WithResult:^(NSDictionary *info) {
                [self analysePPLoginParams:pp_mDic Response:info];
            }];
            
            return;
        }

        
        self.bingPhone = [[SNThirdBindPhone alloc] initWithDelegate:self];
        [self.bingPhone bindThirdPartyLogin:params];
    }
    
}

- (void)analysePPLoginParams:(NSDictionary *)params Response:(NSDictionary *)info{
    
    [SNNewsPPLoginThirdAnalyse analysePPLoginParams:params Response:info Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {
                
                [self ppLoginSuccessed:nil];
                return ;
            }
            else if ([success isEqualToString:@"40323"]) {
                self.vModel.isOpeningThrid = NO;
                NSMutableDictionary* mDic = [NSMutableDictionary dictionaryWithDictionary:params];
                [self openBindPhoneViewControllerData:mDic WithUserInfo:nil];
                return;
            }
            else{
                [self burySuccess:@"-1"];
            }
        }

        self.vModel.isOpeningThrid = NO;
        if (self.successed_Method) {
            self.successed_Method(@{@"success":@"0"});
        }
    }];
}

- (void)ppLoginSuccessed:(NSDictionary*)dic{
    self.vModel.isOpeningThrid = NO;
    
    [self burySuccess:@"1"];
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"weibo",@"value":@"1"}];
    if (self.successed_Method) {
        self.successed_Method(@{@"success":@"1"});
    }
}

////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SNLoginLaterBingPhoneDelegate

- (void)loginSuccessed:(NSDictionary*)data WithUserInfo:(NSDictionary *)userInfo{
    //sina网页登录，SSO登录成功回调
    WBBaseResponse* response = self.resp_weibo;
    NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
    NSString *userID = [(WBAuthorizeResponse *)response userID];
    NSDate *expirationDate = [(WBAuthorizeResponse *)response expirationDate];
    NSString *refreshToken = [(WBAuthorizeResponse *)response refreshToken];
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"kSinaAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //[[SNMySDK sharedInstance] updateSinaWeiBo:userID token:accessToken expireTime:expirationDate];
    
    if (self.thirdLoginSuccess) {
        self.thirdLoginSuccess = nil;
    }
    
    if (userInfo == nil) {
        userInfo = self.userInfoDic;
    }
    
    [self burySuccess:@"1"];
    
    self.thirdLoginSuccess = [[SNThirdLoginSuccess alloc] init];
    self.thirdLoginSuccess.appId = @"1";//微博
    [self.thirdLoginSuccess loginSuccessed:userInfo WithThirdData:nil WithSuccessed:self.successed_Method];
    self.vModel.isOpeningThrid = NO;
    
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"weibo",@"value":@"1"}];
}

-(void)openBindPhoneViewControllerData:(NSDictionary *)dic WithUserInfo:(NSDictionary *)userinfo{
    self.vModel.isOpeningThrid = NO;
    if (userinfo) {
        self.userInfoDic = userinfo;
    }
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"data",self,@"third",self.entrance?:@"",@"entrance",self.loginFrom?:@"",@"loginFrom",self.local_plat?:@"",@"local_plat",self.screen?:@"0",@"screen",nil];
    [SNNewsLoginManager bindData:query Successed:self.successed_Method Failed:nil];
    
    if (self.successed_Method) {
        self.successed_Method(@{@"success":@"0"});
    }
}

-(void)ThirdBindApiFailed:(NSDictionary *)data{
    self.vModel.isOpeningThrid = NO;
    if (self.successed_Method) {
        self.successed_Method(@{@"success":@"0"});
    }
}

#pragma mark -  sns 埋点

- (void)burySuccess:(NSString*)str{
    //    NSDictionary* dic = @{@"loginSuccess":str,@"loginType":loginType,@"cid":[SNUserManager getP1],@"errType":errType?:@""};
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:str?:@"" forKey:@"loginSuccess"];
    [dic setObject:@"weibo" forKey:@"loginType"];
    [dic setObject:[SNUserManager getP1] forKey:@"cid"];
    if (self.screen) {
        [dic setObject:self.screen?:@"0" forKey:@"screen"];
    }
    
    if ([str isEqualToString:@"-1"]) {
        [dic setObject:@"0" forKey:@"errType"];
    }
    
    SNDebugLog(@"sourceID %@ dic:%@",self.loginFrom ,dic);
    if (self.loginFrom && ![self.loginFrom isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:self.loginFrom bodyDic:dic];
    }
    
    if ([str isEqualToString:@"1"]) {
        NSString* agif = @"_act=login&s=sina_weibo";
        if(self.entrance){
            agif = [agif stringByAppendingFormat:@"&entrance=%@",self.entrance];
        }
        [SNNewsReport reportADotGif:agif];
    }
}


////////////////////////////////////////////////////////////////////////////////////

@end
