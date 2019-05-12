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
        self.isOpeningThrid = NO;//第三方正在打开时不能点击
    }
    return self;
}

- (void)thirdLoginWithName:(NSString*)name WithParams:(NSDictionary *)params Success:(void (^)(NSDictionary *))method {
    
    if ([name isEqualToString:@"sohu"]) {
        [self openSohuLogin:params];
        if (method) {
            method(@{@"success":@"0"});
        }
    }
    else{
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {//如果有网络才能登陆
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            if (method) {
                method(@{@"success":@"0"});
            }
            return;
        }
        
        if ([name isEqualToString:@"weibo"]){
            [SNWeiboLogin weiboLogin:params thridModel:self WithSuccess:method];
        }
        else if ([name isEqualToString:@"qq"]){
            [SNQQLogin qqlogin:params thridModel:self WithSuccessed:method];
        }
        else if ([name isEqualToString:@"weixin"]){
            [SNWeiXinLogin weixinLogin:params thridModel:self WithSuccess:method];
        }
    }
}

- (void)openSohuLogin:(NSDictionary*)params{
    [SNUtility shouldUseSpreadAnimation:NO];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://sohulogin"] applyAnimated:YES] applyQuery:params];
    [[TTNavigator navigator] openURLAction:urlAction];
}


@end
