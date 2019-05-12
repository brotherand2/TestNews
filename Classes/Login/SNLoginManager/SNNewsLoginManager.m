//
//  SNNewsLoginManager.m
//  sohunews
//
//  Created by wang shun on 2017/4/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginManager.h"

#import "SNNewsLoginSuccess.h"
#import "SNNewsBindSuccess.h"

#import "SNClientRegister.h"
#import "SNNewsLoginHalfViewController.h"

#import "SNUserManager.h"
#import "SNWeiboLogin.h"
#import "SNWeiXinLogin.h"
#import "SNQQLogin.h"

@implementation SNNewsLoginManager
    
    
+ (void)registerClient:(void (^)(void))method{
    
    if (![SNUtility isRightP1]) {
        //强制注册p1
        [[SNClientRegister sharedInstance] registerClientAnywaySuccess:^(SNBaseRequest *request) {
            if (method) {
                method();
            }
        } fail:^(SNBaseRequest *request, NSError *error) {
            if (method) {
                method();
            }
        }];
    }
    
    if (method) {
        method();
    }
}

+ (void)loginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success Failed:(void(^)(NSDictionary* errorDic))failed{
    
    [SNNewsLoginManager registerClient:^{
        if ([SNUserManager isLogin]) {
            [SNNewsLoginManager bindData:nil Successed:success Failed:failed];
        }
        else{
            
            NSString* link = @"tt://login";
            SNNewsLoginSuccess* loginSuccess = [SNNewsLoginSuccess sharedInstanceParams:params];
            loginSuccess.loginSuccess = success;
            loginSuccess.loginCancel = failed;
            
            NSString* sourceID = [params objectForKey:@"loginFrom"];
            loginSuccess.sourceChannelID = sourceID?:@"";
            NSString* entrance = [params objectForKey:@"entrance"]?:@"0";
            loginSuccess.entrance = entrance;
            
            
            NSMutableDictionary* queryDic = [NSMutableDictionary dictionaryWithDictionary:params];
            [queryDic setObject:loginSuccess forKey:@"loginSuccess"];
            
            [SNNewsLoginManager pushWithLink:link Data:queryDic];
        }
    }];
}


+ (void)bindData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success Failed:(void(^)(NSDictionary* errorDic))failed{
    //tt://bind
    NSString* link = @"tt://bind";
    
    NSMutableDictionary* queryDic = [NSMutableDictionary dictionaryWithDictionary:params];
    
    id third = [params objectForKey:@"third"];
    if (third) {//如果是 第三方/搜狐passport登录 成功事件由登录处理
        
    }
    else{//如果是 直接绑定
        SNNewsBindSuccess* bindSuccess = [[SNNewsBindSuccess alloc] initWithParams:params];
        bindSuccess.bindSuccess = success;
        bindSuccess.bindCancel = failed;
        [queryDic setObject:bindSuccess forKey:@"bindSuccess"];
    }
    
    [SNNewsLoginManager pushWithLink:link Data:queryDic];
}

//仅手机号登录 红包 (调绑定页面 走登录逻辑)
+ (void)phoneLoginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success{
    //tt://bind
    NSString* link = @"tt://bind";
    
    SNNewsLoginSuccess* loginSuccess = [[SNNewsLoginSuccess alloc] initWithParams:params];
    loginSuccess.loginSuccess = success;
    NSMutableDictionary* queryDic = [NSMutableDictionary dictionaryWithDictionary:params];
    [queryDic setObject:loginSuccess forKey:@"loginSuccess"];
    
    [SNNewsLoginManager pushWithLink:link Data:queryDic];
}


+ (void)pushWithLink:(NSString*)link Data:(NSDictionary*)query{
    if (link && link.length>0) {
        [SNUtility shouldUseSpreadAnimation:NO];
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:link] applyAnimated:YES] applyQuery:query];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
}

+ (void)halfLoginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success Failed:(void(^)(NSDictionary* errorDic))failed{
    [SNNewsLoginManager registerClient:^{
        
        if ([SNUserManager isLogin]) {
            [SNNewsLoginManager bindData:nil Successed:success Failed:failed];
        }
        else{
            
            NSString* link = @"tt://halflogin";
            SNNewsLoginSuccess* loginSuccess = [SNNewsLoginSuccess sharedInstanceParams:params];
            loginSuccess.loginSuccess = success;
            loginSuccess.loginCancel = failed;
            
            NSString* sourceID = [params objectForKey:@"loginFrom"];
            loginSuccess.sourceChannelID = sourceID?:@"";
            loginSuccess.screen = @"1";
            NSString* entrance = [params objectForKey:@"entrance"]?:@"0";
            loginSuccess.entrance = entrance;
            
            NSString* halfScreenTitle = [params objectForKey:@"halfScreenTitle"];
            
            NSMutableDictionary* queryDic = [NSMutableDictionary dictionaryWithDictionary:params];
            [queryDic setObject:loginSuccess forKey:@"loginSuccess"];
            [queryDic setObject:halfScreenTitle?:@"" forKey:@"halfScreenTitle"];
            
//            [SNNewsLoginManager pushWithLink:link Data:queryDic];
            
            SNNewsLoginHalfViewController* vc = [[SNNewsLoginHalfViewController alloc] initWithNavigatorURL:nil query:queryDic];
            [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:vc animated:NO];
        }
    }];
}

@end
