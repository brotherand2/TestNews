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
#import "SNThirdBindPhone.h"
#import "SNNewsRecordLastLogin.h"

#import "SNThirdLoginViewModel.h"
#import "SNUserManager.h"
#import "SNSLib.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginThirdAnalyse.h"
#import "SNNewsPPLoginEnvironment.h"


@interface SNWeiXinLogin () <SNThirdBindPhoneDelegate>

@property (nonatomic,strong) SNThirdBindPhone* bingPhone;
@property (nonatomic,strong) NSDictionary* resp_weixin;

@property (nonatomic,strong) NSDictionary* open_params;
@property (nonatomic,copy) void (^successed_Method)(NSDictionary*resultDic);

@property (nonatomic,weak) SNThirdLoginViewModel* vModel;

@property (nonatomic,strong) NSString* pprefer;

//埋点
@property (nonatomic,strong) NSString* loginFrom;
@property (nonatomic,strong) NSString* local_plat;
@property (nonatomic,strong) NSString* screen;

@property (nonatomic,strong) NSString* entrance;//埋点


@end

@implementation SNWeiXinLogin

- (instancetype)initWithParams:(NSDictionary*)params WithSuccess:(void (^)(NSDictionary *))method{
    if (self = [super init]) {
        self.open_params = params;
        self.loginFrom = [self.open_params objectForKey:@"loginFrom"];
        self.entrance = [self.open_params objectForKey:@"entrance"];
        self.local_plat = @"weChat";
        self.screen = [self.open_params objectForKey:@"screen"];
        if ([params objectForKey:@"pprefer"]) {
            self.pprefer = [params objectForKey:@"pprefer"];
        }
        
        if (method) {
            self.successed_Method = method;
        }
    }
    return self;
}

+ (void)weixinLogin:(NSDictionary *)params thridModel:(SNThirdLoginViewModel*)vModel WithSuccess:(void (^)(NSDictionary *))method{
    [SNNewsSSOOpenUrl sharedInstance].isLogin = YES;
    
    SNWeiXinLogin* weixinlogin = [[SNWeiXinLogin alloc] initWithParams:params WithSuccess:method];
    weixinlogin.vModel = vModel;
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

-(void)loginSuccessed:(NSDictionary*)data WithUserInfo:(NSDictionary *)userInfo{
    //[self syncTokenLoginInfo:self.resp_weixin];
    
    if (self.thirdLoginSuccess) {
        self.thirdLoginSuccess = nil;
    }
    if (userInfo == nil) {
        userInfo = self.userInfoDic;
    }

    [self burySuccess:@"1"];
    
    self.thirdLoginSuccess = [[SNThirdLoginSuccess alloc] init];
    self.thirdLoginSuccess.appId = @"8";//微信
    [self.thirdLoginSuccess loginSuccessed:userInfo WithThirdData:self.resp_weixin WithSuccessed:self.successed_Method];
    self.vModel.isOpeningThrid = NO;
    
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"weixin",@"value":@"1"}];
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

- (void)ThirdBindApiFailed:(NSDictionary *)data{
    self.vModel.isOpeningThrid = NO;
    if (self.successed_Method) {
        self.successed_Method(@{@"success":@"0"});
    }
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
        NSString *unionid = [requestDict objectForKey:@"unionid"];
        
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
        
        self.vModel.isOpeningThrid = YES;
        
        NSString* plat = @"wechat";
        NSString* sourceID = [self.open_params objectForKey:@"loginFrom"]?:@"";
        
        NSDictionary* params = @{@"openId":openid,@"refresh_token":refresh_token,@"token":access_token,@"expire":expire,@"appId":@"wechat",@"from":@"login",@"loginFrom":sourceID,@"local_plat":plat,@"screen":self.screen?:@"0"};
        
        NSMutableDictionary* paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
        if ([self.pprefer isEqualToString:@"comment"]) {
            [paramsDic setObject:self.pprefer forKey:@"pprefer"];
        }
        
        if (self.successed_Method) {
            self.successed_Method(@{@"success":@"-1"});
        }
        
        if ([SNNewsPPLoginEnvironment isPPLogin]) {
            NSMutableDictionary* pp_mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            [pp_mDic setObject:kWX_APP_ID forKey:@"openkey"];
            [pp_mDic setObject:openid forKey:@"openid"];
            [pp_mDic setObject:unionid forKey:@"userid"];//微信特殊
            [pp_mDic setObject:@"wechat" forKey:@"platform"];
            
            [pp_mDic setObject:access_token forKey:@"accesstoken"];
            [pp_mDic setObject:refresh_token forKey:@"refresh_token"];
            
            [pp_mDic setObject:expire forKey:@"expirein"];
            
            if ([self.pprefer isEqualToString:@"comment"]) {
                //评论入口登录 微信不绑定手机(老板需求) 请求发起来源，评论发起值为：comment @wangshun
                //http://wiki.sohu-inc.com/pages/viewpage.action?pageId=26055912
                [pp_mDic setObject:@"comment" forKey:@"reqrefer"];//wangshun
            }
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"正在登录..." toUrl:nil mode:SNCenterToastModeOnlyText];
            [SNNewsPPLogin thirdLogin:pp_mDic WithResult:^(NSDictionary *info) {
                [self analysePPLoginParams:pp_mDic Response:info];
            }];
            
            return ;
        }

    
        self.bingPhone = [[SNThirdBindPhone alloc] initWithDelegate:self];
        [self.bingPhone bindThirdPartyLogin:paramsDic];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        if (self.successed_Method) {
            self.successed_Method(@{@"success":@"0"});
        }
    }];
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
                return ;
            }
            else{
                [self burySuccess:@"-1"];
            }
        }
        
        if (self.successed_Method) {
            self.successed_Method(@{@"success":@"0"});
        }
        self.vModel.isOpeningThrid = NO;
    }];
}

- (void)ppLoginSuccessed:(NSDictionary*)dic{
    self.vModel.isOpeningThrid = NO;
    
    [self burySuccess:@"1"];
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"weixin",@"value":@"1"}];
    
    if (self.successed_Method) {
        self.successed_Method(@{@"success":@"1"});
    }
}

#pragma mark -  sns 埋点

- (void)burySuccess:(NSString*)str{
    //    NSDictionary* dic = @{@"loginSuccess":str,@"loginType":loginType,@"cid":[SNUserManager getP1],@"errType":errType?:@""};
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:str?:@"" forKey:@"loginSuccess"];
    [dic setObject:@"wechat" forKey:@"loginType"];
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
        NSString* agif = @"_act=login&s=weixin";
        if(self.entrance){
            agif = [agif stringByAppendingFormat:@"&entrance=%@",self.entrance];
        }
        [SNNewsReport reportADotGif:agif];
    }
}



@end
