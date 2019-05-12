//
//  SNThirdBindPhone.m
//  sohunews
//
//  Created by wang shun on 2017/4/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNThirdBindPhone.h"
#import "SNThirdPartyLoginRequest.h"
#import "SNUserManager.h"
#import "SNSLib.h"
#import "SNBindPhoneViewModel.h"

@interface SNThirdBindPhone ()

@property (nonatomic,strong) SNThirdPartyLoginRequest* thirdPartyLoginReq;

@property (nonatomic,strong) NSDictionary* thirdParams;

@property (nonatomic,strong) NSString* pprefer;
@property (nonatomic,strong) SNBindPhoneViewModel* registModel;//如果微信 评论自动注册

//埋点
@property (nonatomic,strong) NSString* sourceID;
@property (nonatomic,strong) NSString* local_plat;
@property (nonatomic,strong) NSString* screen;

@end

@implementation SNThirdBindPhone

- (instancetype)initWithDelegate:(id <SNThirdBindPhoneDelegate>)del{
    if (self = [super init]) {
        self.delegate = del;
    }
    return self;
}

- (void)bindThirdPartyLogin:(NSDictionary*)params{
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:params];
    
    NSString* appId = [params objectForKey:@"appId"];
    NSString* app = [self getAppId:appId WithDic:dic];
    if (dic) {
        [dic setObject:app forKey:@"appId"];
    }
    
    self.thirdParams = dic;
    
    self.sourceID = [params objectForKey:@"loginFrom"];
    self.local_plat = [params objectForKey:@"local_plat"];
    
    if ([params objectForKey:@"pprefer"]) {
        self.pprefer = [params objectForKey:@"pprefer"];
    }
    
    
    //    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"正在登录.." toUrl:nil mode:SNCenterToastModeOnlyText];
    [[SNCenterToast shareInstance] showWithTitle:@"正在登录.."];
    
    [[[SNThirdPartyLoginRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"bindThirdPartyLogin:%@",responseObject);
        
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg  = [responseObject objectForKey:@"statusMsg"];
        
        [self analyseStatusCode:statusCode response:responseObject];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"bindThirdPartyLogin error:%@",error);
        [[SNCenterToast shareInstance] hideToast];
        [self thirdPartyLoginFailed:nil];
    }];
}

- (void)analyseStatusCode:(NSNumber*)statusCode response:(NSDictionary*)respDic{
    NSInteger i = statusCode.integerValue;
    [[SNCenterToast shareInstance] hideToast];
    if (i == 10000000) {//成功
        
        SNDebugLog(@"ThirdPartyLogin:%@",respDic);
        
        NSNumber* bindMobileStatus = [respDic objectForKey:@"bindMobileStatus"];
        NSDictionary* userInfo = [respDic objectForKey:@"userInfo"];
        if (userInfo && bindMobileStatus == nil) {
            bindMobileStatus = [userInfo objectForKey:@"bindMobileStatus"];
        }
        
        if (bindMobileStatus.integerValue == 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(openBindPhoneViewControllerData:WithUserInfo:)]) {
                
                NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:self.thirdParams];
                [param setObject:@"bind" forKey:@"type"];
                
                NSString* passport = [userInfo objectForKey:@"passport"];
                if (passport) {
                    [param setObject:passport?:@"" forKey:@"passport"];
                }
                
                if([self.pprefer isEqualToString:@"comment"]){
                    //10000000 中有两种情况 一种直接成功 ，一种判断 bindMobileStatus
                    if([NSStringFromClass([self.delegate class]) isEqualToString:@"SNWeiXinLogin"]){//如果微信 评论
                    if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccessed:WithUserInfo:)]) {
                        //埋点
                        [self.delegate loginSuccessed:nil WithUserInfo:respDic];
                        return;
                    }
                }
                }
                
                [self.delegate openBindPhoneViewControllerData:param WithUserInfo:respDic];
                return;
            }
        }
        else{
            //10000000 中有两种情况 一种直接成功 ，一种判断 bindMobileStatus
            if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccessed:WithUserInfo:)]) {
                //埋点
                [self.delegate loginSuccessed:nil WithUserInfo:respDic];
                return;
            }
        }
        
    }
    else if (i == 10000004) {//登录失败
        [self thirdPartyLoginFailed:nil];
    }
    else if (i == 10000006) {//新用户，需要注册
        if (self.delegate && [self.delegate respondsToSelector:@selector(openBindPhoneViewControllerData:WithUserInfo:)]) {
            NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:self.thirdParams];
            [param setObject:@"signup" forKey:@"type"];
            if ([self.pprefer isEqualToString:@"comment"]) {
                if([NSStringFromClass([self.delegate class]) isEqualToString:@"SNWeiXinLogin"]){//如果微信 评论 自动注册
                    if (!self.registModel) {
                        self.registModel = [[SNBindPhoneViewModel alloc] init];
                    }
                    [self.registModel autoThirdSignup:param Successed:^(NSDictionary *resultDic) {
                       
                        if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccessed:WithUserInfo:)]) {
                            //埋点
                            NSDictionary* userInfo = [resultDic objectForKey:@"resp"];
                            [self.delegate loginSuccessed:nil WithUserInfo:userInfo];
                            return;
                        }
                    }];
                    
                    return;
                }
            }
            
            [self.delegate openBindPhoneViewControllerData:param WithUserInfo:nil];
            return;
        }
    }
    else if (i == 10000008) {//绑定列表为空  iOS 不用做 因share中微博登录已经迁移至sso
        [self thirdPartyLoginFailed:nil];
    }
    else{
        [self thirdPartyLoginFailed:nil];
    }
   
    [self burySuccess:@"-1"];
}


- (void)burySuccess:(NSString*)sender{
    NSString* loginType = self.local_plat;
    NSString* sourceChannelID = self.sourceID;
    
    NSDictionary* dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"cid":[SNUserManager getP1],@"screen":self.screen?:@"0"};
    if ([sender isEqualToString:@"-1"]) {
        dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"errType":@"0",@"cid":[SNUserManager getP1],@"screen":self.screen?:@"0"};
    }
    
    SNDebugLog(@"第三方 sourceChannelID ::::%@ dic:%@",sourceChannelID,dic);
    
    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
}

- (void)thirdPartyLoginFailed:(NSDictionary*)dic{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ThirdBindApiFailed:)]) {
        [self.delegate ThirdBindApiFailed:nil];
    }
}

//
//appId     sina:1  qq:6  wechat:8
- (NSString*)getAppId:(NSString*)appId WithDic:(NSMutableDictionary*)mdic{
    NSString* app = @"";
    NSString* loginType = @"";
    if ([appId isEqualToString:@"sina"]) {
        app = @"1";
        loginType = SNLogin_ThirdLogin_LoginType_Sina;
    }
    else if ([appId isEqualToString:@"qq"]){
        app = @"6";
        loginType = SNLogin_ThirdLogin_LoginType_QQ;
    }
    else if ([appId isEqualToString:@"wechat"]){
        app = @"8";
        loginType = SNLogin_ThirdLogin_LoginType_WeChat;
    }
    
    [mdic setObject:loginType forKey:@"logintype"];
    [mdic setObject:@"0" forKey:@"loginfrom"];
    
    return app;
}


@end
