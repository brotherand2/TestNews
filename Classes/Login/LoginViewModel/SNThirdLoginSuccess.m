//
//  SNThirdLoginSuccess.m
//  sohunews
//
//  Created by wang shun on 2017/3/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNThirdLoginSuccess.h"
#import "SNUserUtility.h"
#import <JsKitFramework/JKNotificationCenter.h>

@interface SNThirdLoginSuccess ()

@property (nonatomic,copy) void (^successed_Method)(NSDictionary*resultDic);

@end

@implementation SNThirdLoginSuccess

- (void)loginSuccessed:(NSDictionary *)respDic WithThirdData:(NSDictionary *)thirdDic{
    
    [self loginSuccessed:respDic WithThirdData:thirdDic WithSuccessed:nil];
}

-(void)loginSuccessed:(NSDictionary *)respDic WithThirdData:(NSDictionary *)thirdDic WithSuccessed:(void (^)(NSDictionary *))method{
    
    [SNNotificationCenter hideLoadingAndBlock];
    
    SNUserinfoEx *aUserInfo = [SNUserinfoEx userinfoEx];
    [aUserInfo parseUserinfoFromDictionary:respDic];
    NSDictionary* userInfo = [respDic objectForKey:@"userInfo"];
    if (userInfo != nil && [userInfo isKindOfClass:[NSDictionary class]])
    {
        [aUserInfo parseUserinfoFromDictionary:userInfo];
    }
    
    [aUserInfo saveUserinfoToUserDefault];
    
    [SNNotificationCenter hideLoadingAndBlock];
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录成功" toUrl:nil mode:SNCenterToastModeOnlyText];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.appId forKey:kUserCenterLoginAppId];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (method) {
        self.successed_Method = method;
    }
    
    [self performSelector:@selector(closeToast) withObject:nil afterDelay:1.0];
}

- (void)closeToast{
    [[SNCenterToast shareInstance] hideToast];
    [self performSelector:@selector(thirdloginNotification) withObject:nil afterDelay:0.5];
}

- (void)thirdloginNotification{
    
    if (self.successed_Method) {
        self.successed_Method(@{@"success":@"1"});
    }
}

@end
