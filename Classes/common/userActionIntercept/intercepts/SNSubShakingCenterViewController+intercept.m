//
//  SNSubShakingCenterViewController+intercept.m
//  sohunews
//
//  Created by jojo on 13-12-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSubShakingCenterViewController+intercept.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"

@implementation SNSubShakingCenterViewController (intercept)

+ (void)load {
    executeInsteadSelector(self, @selector(submitSubnow:), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForSubShakeSubButton] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    executeInsteadSelector(self, @selector(onViewDidAppear), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForSubShake] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
#pragma clang diagnostic pop
}

@end
