//
//  SNNewsLogin.m
//  sohunews
//
//  Created by wang shun on 2017/5/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLogin.h"
//#import "SNNewsLoginSuccess.h"

#import "SNUserManager.h"
#import "SNNewsLoginManager.h"

@implementation SNNewsLogin

+ (void)loginWithParams:(NSDictionary*)params Success:(void (^)(NSDictionary* info))method{
    
//    if ([SNUserManager isLogin] && [SNUserManager getIsRealName] == NO) {//绑定
//        [SNNewsLogin bindSuccess:method];
//    } else {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//        NSValue* loginMethod = [NSValue valueWithPointer:@selector(loginSuccess)];
//#pragma clang diagnostic pop
//        NSMutableDictionary* query = [[NSMutableDictionary alloc] initWithCapacity:0];
//        [query setObject:loginMethod forKey:@"method"];
//        
//        SNNewsLoginSuccess* loginSuccess = [[SNNewsLoginSuccess alloc] initWithParams:params WithLoginSuccess:method];
//        [query setObject:loginSuccess forKey:@"loginSuccess"];
//        
//        [SNUtility openLoginViewWithDict:query];
//    }
    
    
    [SNNewsLoginManager loginData:params Successed:method Failed:nil];//111收藏页／我的页用户评论
}

+ (void)loginSuccess:(void (^)(NSDictionary* info))method{
    [SNNewsLogin loginWithParams:nil Success:method];
}


+ (void)bindSuccess:(void (^)(NSDictionary* info))method{
    
//    id sender = [TTNavigator navigator].topViewController;
//    NSMutableDictionary* query = [[NSMutableDictionary alloc] initWithCapacity:0];
//    [query setObject:@"手机绑定" forKey:@"headTitle"];
//    [query setObject:@"立即绑定" forKey:@"buttonTitle"];
//    [query setObject:@"1" forKey:@"commentBindOpen"];
//    if (sender && [sender isKindOfClass:[UIViewController class]]) {
//        [query setObject:sender forKey:@"popvc"];
//    }
//    
//    SNNewsLoginSuccess* loginSuccess = [[SNNewsLoginSuccess alloc] initWithParams:nil WithLoginSuccess:method];
//    [query setObject:loginSuccess forKey:@"bindSuccess"];
//    
//    [SNNewsLogin pushLogin:query WithLink:@"tt://mobileNumBindLogin"];
}

+ (void)pushLogin:(NSDictionary*)params WithLink:(NSString* )link{
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:link] applyAnimated:YES] applyQuery:params];
    [[TTNavigator navigator] openURLAction:_urlAction];
}


@end
