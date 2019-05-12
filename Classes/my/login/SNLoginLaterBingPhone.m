//
//  SNLoginLaterBingPhone.m
//  sohunews
//
//  Created by wang shun on 2017/3/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLoginLaterBingPhone.h"
#import "SNThirdPartyLoginRequest.h"

#import "SNNewsThirdLoginEnable.h"
#import "SNShareManager.h"

#import "SNSLib.h"
#import "SNUserManager.h"

@interface SNLoginLaterBingPhone ()

@property (nonatomic,strong) SNThirdPartyLoginRequest* thirdPartyLoginReq;

@property (nonatomic,strong) NSDictionary* thirdParams;

@end

@implementation SNLoginLaterBingPhone


- (instancetype)initWithDelegate:(id <SNLoginLaterBingPhoneDelegate>)del{
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
    
    [[[SNThirdPartyLoginRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"bindThirdPartyLogin:%@",responseObject);
        
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        [self analyseStatusCode:statusCode response:responseObject];
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"bindThirdPartyLogin error:%@",error);
        [[SNCenterToast shareInstance] hideToast];
        [SNNewsThirdLoginEnable sharedInstance].isLanding = NO;//放开第三方登录点击限制
    }];
}

- (void)analyseStatusCode:(NSNumber*)statusCode response:(NSDictionary*)respDic{
    NSInteger i = statusCode.integerValue;
    
    [SNNewsThirdLoginEnable sharedInstance].isLanding = NO;//放开第三方登录点击限制
    
    if (i == 10000000) {//成功        
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
                
                [self.delegate openBindPhoneViewControllerData:param WithUserInfo:respDic];
                return;
            }
        }
        else{
            //10000000 中有两种情况 一种直接成功 ，一种判断 bindMobileStatus
            if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccessed:)]) {
                [self.delegate loginSuccessed:respDic];
                return;
            }
        }
        
    }
    else if (i == 10000004) {//登录失败
        
    }
    else if (i == 10000006) {//新用户，需要注册
//        if (self.delegate && [self.delegate respondsToSelector:@selector(openBingPhoneViewControllerData:)]) {
//            NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:self.thirdParams];
//            [param setObject:@"signup" forKey:@"type"];
//            [self.delegate openBingPhoneViewControllerData:param];
//            return;
//        }
    }
    else if (i == 10000008) {//绑定列表为空  iOS 不用做 因share中微博登录已经迁移至sso
        
    }
    
    [[SNCenterToast shareInstance] hideToast];
    [self burySuccess:@"-1"];
}

- (void)burySuccess:(NSString*)sender{
    NSString* classname = NSStringFromClass([self.delegate class]);
    NSString* loginType = @"";
    if ([classname isEqualToString:@"SNSSOQQWrapper"]) {
        loginType = @"qq";
    }
    else if ([classname isEqualToString:@"SNSSOSinaWrapper"]){
        loginType = @"weibo";
    }
    else if ([classname isEqualToString:@"SNWXHelper"]){
        loginType = @"weixin";
    }
    
    NSString* sourceChannelID = [SNShareManager defaultManager].loginFrom;
    NSDictionary* dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"cid":[SNUserManager getP1]};
    if ([sender isEqualToString:@"-1"]) {
        dic = @{@"loginSuccess":sender?:@"",@"loginType":loginType,@"errType":@"0",@"cid":[SNUserManager getP1]};
    }
    
    SNDebugLog(@"第三方 sourceChannelID ::::%@ dic:%@",sourceChannelID,dic);
    
    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
}

//
//appId  sina:1  qq:6  wechat:8
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

//
/* sina
 NSDictionary* params = @{@"accessToken":accessToken,@"refreshToken":refreshToken,@"expirationDate":userID,@"expire":expire,@"appId":@"sina"};
 */
//


@end
