//
//  SNThirdLoginViewModel.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNThirdLoginViewModel.h"

#import "SNWeiboLogin.h"
#import "SNWeiXinLogin.h"
#import "SNQQLogin.h"

@implementation SNThirdLoginViewModel

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)thirdLoginWithName:(NSString*)name WithParams:(NSDictionary *)params Success:(void (^)(NSDictionary *))method {
    
    if ([name isEqualToString:@"sohu"]) {
        [self openSohuLogin:params];
    }
    else if ([name isEqualToString:@"weibo"]){
        [SNWeiboLogin weiboLogin:nil WithSuccess:method];
    }
    else if ([name isEqualToString:@"qq"]){
        [SNQQLogin qqlogin:nil WithSuccessed:method];
    }
    else if ([name isEqualToString:@"weixin"]){
        [SNWeiXinLogin weixinLogin:nil WithSuccess:method];
    }
}

- (void)openSohuLogin:(NSDictionary*)params{
    
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://sohulogin"] applyAnimated:YES] applyQuery:params];
    [[TTNavigator navigator] openURLAction:urlAction];
}


@end
