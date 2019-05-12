//
//  sohunewsAppDelegate+intercept.m
//  sohunews
//
//  Created by jojo on 14-1-2.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "sohunewsAppDelegate+intercept.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"

@implementation sohunewsAppDelegate (intercept)

+ (void)load {
    executeInsteadSelector(self, @selector(newUserGuideViewDidCloseNotification:), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForUserGuide] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
}

@end
