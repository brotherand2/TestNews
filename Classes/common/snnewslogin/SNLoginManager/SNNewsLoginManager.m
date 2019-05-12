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

@implementation SNNewsLoginManager

+ (void)loginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success{
    //tt://login
    NSString* link = @"tt://login";
    
    SNNewsLoginSuccess* loginSuccess = [[SNNewsLoginSuccess alloc] initWithParams:nil];
    loginSuccess.loginSuccess = success;
    NSMutableDictionary* queryDic = [NSMutableDictionary dictionaryWithDictionary:params];
    [queryDic setObject:loginSuccess forKey:@"loginSuccess"];
    
    [SNNewsLoginManager pushWithLink:link Data:queryDic];
}

+ (void)bindData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success{
    //tt://bind
    NSString* link = @"tt://bind";
    
    NSMutableDictionary* queryDic = [NSMutableDictionary dictionaryWithDictionary:params];
    
    id third = [params objectForKey:@"third"];
    if (third) {//如果是 第三方/搜狐passport登录 成功事件由登录处理
        
    }
    else{//如果是 直接绑定
        SNNewsBindSuccess* bindSuccess = [[SNNewsBindSuccess alloc] initWithParams:nil];
        bindSuccess.bindSuccess = success;
        [queryDic setObject:bindSuccess forKey:@"bindSuccess"];
    }
    
    [SNNewsLoginManager pushWithLink:link Data:queryDic];
}

//仅手机号登录 红包 (调绑定页面 走登录逻辑)
+ (void)phoneLoginData:(NSDictionary*)params Successed:(void(^)(NSDictionary* info))success{
    //tt://bind
    NSString* link = @"tt://bind";
    
    SNNewsLoginSuccess* loginSuccess = [[SNNewsLoginSuccess alloc] initWithParams:nil];
    loginSuccess.loginSuccess = success;
    NSMutableDictionary* queryDic = [NSMutableDictionary dictionaryWithDictionary:params];
    [queryDic setObject:loginSuccess forKey:@"loginSuccess"];
    
    [SNNewsLoginManager pushWithLink:link Data:queryDic];
}


+ (void)pushWithLink:(NSString*)link Data:(NSDictionary*)query{
    if (link && link.length>0) {
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:link] applyAnimated:YES] applyQuery:query];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
}

@end
