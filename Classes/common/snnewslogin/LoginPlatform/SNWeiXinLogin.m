//
//  SNWeiXinLogin.m
//  sohunews
//
//  Created by wang shun on 2017/4/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNWeiXinLogin.h"
#import "SNNewsSSOOpenUrl.h"
#import "SNNewsLoginManager.h"
#import "SNWeixinOauthRequest.h"

@interface SNWeiXinLogin () <SNLoginLaterBingPhoneDelegate>

@property (nonatomic,strong) SNLoginLaterBingPhone* bingPhone;
@property (nonatomic,strong) NSDictionary* resp_weixin;

@property (nonatomic,strong) NSDictionary* open_params;
@property (nonatomic,copy) void (^successed_Method)(NSDictionary*resultDic);

@end

@implementation SNWeiXinLogin

- (instancetype)initWithParams:(NSDictionary*)params WithSuccess:(void (^)(NSDictionary *))method{
    if (self = [super init]) {
        self.open_params = params;
        if (method) {
            self.successed_Method = method;
        }
    }
    return self;
}

+ (void)weixinLogin:(NSDictionary *)params WithSuccess:(void (^)(NSDictionary *))method{
    [SNNewsSSOOpenUrl sharedInstance].isLogin = YES;
    
    SNWeiXinLogin* weixinlogin = [[SNWeiXinLogin alloc] initWithParams:params WithSuccess:method];
    [[SNNewsSSOOpenUrl sharedInstance] setWeiXinLogin:weixinlogin];
    
    if (isINHOUSE) {
        [WXApi registerApp:@"wx5f5316beab0e372a"];
    }
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";//必须
    req.state = @"111111";//不必须
    [WXApi sendReq:req];
}

////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SNLoginLaterBingPhoneDelegate

-(void)loginSuccessed:(NSDictionary*)data{
    //[self syncTokenLoginInfo:self.resp_weixin];
    
    if (self.thirdLoginSuccess) {
        self.thirdLoginSuccess = nil;
    }
    if (data == nil) {
        data = self.userInfoDic;
    }
    self.thirdLoginSuccess = [[SNThirdLoginSuccess alloc] init];
    self.thirdLoginSuccess.appId = @"8";//微信
    [self.thirdLoginSuccess loginSuccessed:data WithThirdData:self.resp_weixin WithSuccessed:self.successed_Method];
}

-(void)openBindPhoneViewControllerData:(NSDictionary *)dic WithUserInfo:(NSDictionary *)userinfo{
    if (userinfo) {
        self.userInfoDic = userinfo;
    }
    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"data",self,@"third",nil];
    [SNNewsLoginManager bindData:query Successed:self.successed_Method];
}

////////////////////////////////////////////////////////////////////////////////////

//weixin 回调
#pragma mark get weixin token
- (void)setURLWithCode:(NSString *)code {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setValue:code forKey:@"code"];
    
    if (isINHOUSE) {//等重构吧 inhouse 和 appstore 不是一个bundleid passport不想兼容俩
        [WXApi registerApp:kWX_APP_ID_Inhouse];
    }
    
    [[[SNWeixinOauthRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id requestDict) {
        NSString *access_token = [requestDict objectForKey:@"access_token"];
        NSString *expires_in = [requestDict objectForKey:@"expires_in"];//获取的是秒，需要转为NSDate类型
        NSDate *expireDate = [NSString getDateFromSecond:expires_in];
        NSString *refresh_token = [requestDict objectForKey:@"refresh_token"];
        NSString *openid = [requestDict objectForKey:@"openid"];
        NSString* expire =[NSString stringWithFormat:@"%zd",(long long)[expireDate timeIntervalSince1970]];
        
        if (self.resp_weixin != nil) {
            self.resp_weixin = nil;
        }
        self.resp_weixin = requestDict;
        
        //wangshun
        //原来直接同步信息
        //现在加入绑定流程 wangshun 2017.3.6
        
        if (self.bingPhone != nil) {
            self.bingPhone = nil;
        }
        
        NSDictionary* params = @{@"openId":openid,@"refresh_token":refresh_token,@"token":access_token,@"expire":expire,@"appId":@"wechat",@"from":@"login"};
        self.bingPhone = [[SNLoginLaterBingPhone alloc] initWithDelegate:self];
        [self.bingPhone bindThirdPartyLogin:params];
        
        //      [[SNShareManager defaultManager] syncToken:access_token refreshToken:refresh_token expire:expireDate userName:nil userId:openid appId:@"8"];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }];
}



@end
