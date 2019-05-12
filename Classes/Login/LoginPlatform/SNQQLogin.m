//
//  SNQQLogin.m
//  sohunews
//
//  Created by wang shun on 2017/4/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNQQLogin.h"
#import "SNQQHelper.h"
#import "SNNewsSSOOpenUrl.h"
#import "SNNewsLoginManager.h"
#import "SNThirdBindPhone.h"
#import "SNThirdLoginViewModel.h"
#import "SNNewsRecordLastLogin.h"
#import "SNUserManager.h"
#import "SNSLib.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginThirdAnalyse.h"
#import "SNNewsPPLoginEnvironment.h"

@interface SNQQLogin ()<SNQQHelperLoginDelegate,SNThirdBindPhoneDelegate>

@property (nonatomic,strong) SNThirdBindPhone* bingPhone;
@property (nonatomic,strong) NSDictionary* resp_qq;

@property (nonatomic,strong) NSDictionary* open_params;
@property (nonatomic,copy) void (^successed_Method)(NSDictionary*resultDic);

@property (nonatomic,weak) SNThirdLoginViewModel* vModel;

//埋点
@property (nonatomic,strong) NSString* loginFrom;
@property (nonatomic,strong) NSString* local_plat;
@property (nonatomic,strong) NSString* screen;

@property (nonatomic,strong) NSString* entrance;//埋点

@end

@implementation SNQQLogin

- (instancetype)initWithParams:(NSDictionary*)params WithSuccess:(void (^)(NSDictionary*))method{
    if (self = [super init]) {
        self.open_params = params;
        
        self.loginFrom = [self.open_params objectForKey:@"loginFrom"];
        self.entrance = [self.open_params objectForKey:@"entrance"];
        self.local_plat = @"qq";
        self.screen = [self.open_params objectForKey:@"screen"];
        
        if (method) {
            self.successed_Method = method;
        }
    }
    return self;
}

+ (void)qqlogin:(NSDictionary*)params thridModel:(SNThirdLoginViewModel*)vModel WithSuccessed:(void(^)(NSDictionary*resultDic))method{
    SNQQLogin* qqlogin = [[SNQQLogin alloc] initWithParams:params WithSuccess:method];
    qqlogin.vModel = vModel;
    [[SNNewsSSOOpenUrl sharedInstance] setQQLogin:qqlogin];
    
    if ([SNQQHelper isSupportQQSSO]) {//sso
        [[SNQQHelper sharedInstance] loginForQQWithDelegate:qqlogin];
    }
    else{
        [[SNQQHelper sharedInstance] loginForQQWebWithDelegate:qqlogin];
    }
}

//qq 回调
- (void)qqDidLogin{
    NSString* userName = [[SNQQHelper sharedInstance].loginUserInfoDic stringValueForKey:@"nickname" defaultValue:nil];
    NSString* userId = [SNQQHelper sharedInstance].tencentAuth.openId;
    NSString* accessToken = [SNQQHelper sharedInstance].tencentAuth.accessToken;
    NSDate*   expirationDate = [SNQQHelper sharedInstance].tencentAuth.expirationDate;
    NSString* expire =[NSString stringWithFormat:@"%zd",(long long)[expirationDate timeIntervalSince1970]];
    
    //[self syncTokenLoginInfo:response];
    //wangshun
    //原来直接同步信息
    //现在加入绑定流程 wangshun 2017.3.6
    
    if (self.bingPhone != nil) {
        self.bingPhone = nil;
    }
    
    self.vModel.isOpeningThrid = YES;
    
    
    if (self.successed_Method) {
        self.successed_Method(@{@"success":@"-1"});
    }
    
    NSDictionary* params = @{@"openId":userId,@"token":accessToken,@"expire":expire,@"appId":@"qq",@"from":@"login",@"screen":self.screen?:@"0"};
    
    if ([SNNewsPPLoginEnvironment isPPLogin]) {
        NSMutableDictionary* pp_mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        [pp_mDic setObject:SNNews_QQ_APPKEY forKey:@"openkey"];
        [pp_mDic setObject:userId forKey:@"openid"];
        [pp_mDic setObject:userId forKey:@"userid"];
        [pp_mDic setObject:@"qq" forKey:@"platform"];
        
        [pp_mDic setObject:accessToken forKey:@"accesstoken"];
        
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"正在登录..." toUrl:nil mode:SNCenterToastModeOnlyText];
        [SNNewsPPLogin thirdLogin:pp_mDic WithResult:^(NSDictionary *info) {
            [self analysePPLoginParams:pp_mDic Response:info];
        }];
        
        return;
    }

    
    self.bingPhone = [[SNThirdBindPhone alloc] initWithDelegate:self];
    [self.bingPhone bindThirdPartyLogin:params];
}

- (void)analysePPLoginParams:(NSDictionary *)params Response:(NSDictionary *)info{
    
    [SNNewsPPLoginThirdAnalyse analysePPLoginParams:params Response:info Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {
                
                [self ppLoginSuccessed:nil];
                return;
            }
            else if ([success isEqualToString:@"40323"]) {
                self.vModel.isOpeningThrid = NO;
                NSMutableDictionary* mDic = [NSMutableDictionary dictionaryWithDictionary:params];
                [self openBindPhoneViewControllerData:mDic WithUserInfo:nil];
                return ;
            }
            else{//埋点
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
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"qq",@"value":@"1"}];
    
    if (self.successed_Method) {
        self.successed_Method(@{@"success":@"1"});
    }
}



////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SNThirdBindPhoneDelegate

- (void)loginSuccessed:(NSDictionary*)data WithUserInfo:(NSDictionary *)userInfo{
    //    [self syncTokenLoginInfo:self.resp_qq];
    
    if (self.thirdLoginSuccess) {
        self.thirdLoginSuccess = nil;
    }
    
    if (userInfo == nil) {
        userInfo = self.userInfoDic;
    }
    
    [self burySuccess:@"1"];
    
    self.thirdLoginSuccess = [[SNThirdLoginSuccess alloc] init];
    self.thirdLoginSuccess.appId = @"6";//QQ
    [self.thirdLoginSuccess loginSuccessed:userInfo WithThirdData:self.resp_qq WithSuccessed:self.successed_Method];
    self.vModel.isOpeningThrid = NO;
    
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"qq",@"value":@"1"}];
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


////////////////////////////////////////////////////////////////////////////////////


-(void)qqDidFailLoginWithError:(NSError *)error{
    
}

#pragma mark -  sns 埋点

- (void)burySuccess:(NSString*)str{
    //    NSDictionary* dic = @{@"loginSuccess":str,@"loginType":loginType,@"cid":[SNUserManager getP1],@"errType":errType?:@""};
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:str?:@"" forKey:@"loginSuccess"];
    [dic setObject:@"qq" forKey:@"loginType"];
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
        NSString* agif = @"_act=login&s=qq";
        if(self.entrance){
            agif = [agif stringByAppendingFormat:@"&entrance=%@",self.entrance];
        }
        [SNNewsReport reportADotGif:agif];
    }
}


@end
