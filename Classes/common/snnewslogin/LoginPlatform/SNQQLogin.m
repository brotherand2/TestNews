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

@interface SNQQLogin ()<SNQQHelperLoginDelegate,SNLoginLaterBingPhoneDelegate>

@property (nonatomic,strong) SNLoginLaterBingPhone* bingPhone;
@property (nonatomic,strong) NSDictionary* resp_qq;

@property (nonatomic,strong) NSDictionary* open_params;
@property (nonatomic,copy) void (^successed_Method)(NSDictionary*resultDic);


@end

@implementation SNQQLogin

- (instancetype)initWithParams:(NSDictionary*)params WithSuccess:(void (^)(NSDictionary*))method{
    if (self = [super init]) {
        self.open_params = params;
        if (method) {
            self.successed_Method = method;
        }
    }
    return self;
}

+ (void)qqlogin:(NSDictionary*)params WithSuccessed:(void(^)(NSDictionary*resultDic))method{
    SNQQLogin* qqlogin = [[SNQQLogin alloc] initWithParams:params WithSuccess:method];
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
    
    NSDictionary* params = @{@"openId":userId,@"token":accessToken,@"expire":expire,@"appId":@"qq",@"from":@"login"};
    
    self.bingPhone = [[SNLoginLaterBingPhone alloc] initWithDelegate:self];
    [self.bingPhone bindThirdPartyLogin:params];
}

////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SNLoginLaterBingPhoneDelegate

- (void)loginSuccessed:(NSDictionary*)data{
    //    [self syncTokenLoginInfo:self.resp_qq];
    
    if (self.thirdLoginSuccess) {
        self.thirdLoginSuccess = nil;
    }
    
    if (data == nil) {
        data = self.userInfoDic;
    }
    
    self.thirdLoginSuccess = [[SNThirdLoginSuccess alloc] init];
    self.thirdLoginSuccess.appId = @"6";//QQ
    [self.thirdLoginSuccess loginSuccessed:data WithThirdData:self.resp_qq WithSuccessed:self.successed_Method];
}

-(void)openBindPhoneViewControllerData:(NSDictionary *)dic WithUserInfo:(NSDictionary *)userinfo{
    if (userinfo) {
        self.userInfoDic = userinfo;
    }
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"data",self,@"third",nil];
    [SNNewsLoginManager bindData:query Successed:self.successed_Method];
}

////////////////////////////////////////////////////////////////////////////////////


-(void)qqDidFailLoginWithError:(NSError *)error{
    
}


@end
