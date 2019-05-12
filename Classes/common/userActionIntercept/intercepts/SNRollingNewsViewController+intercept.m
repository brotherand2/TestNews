//
//  SNRollingNewsViewController+intercept.m
//  sohunews
//
//  Created by jojo on 13-12-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsViewController+intercept.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"
#import "SNAppUsageStatManager.h"

@implementation SNRollingNewsViewController (intercept)

+ (void)load {
    executeInsteadSelector(self, @selector(tabBarBeginEdit:), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForNewsChannelEdit] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
    
    //SNDebugLog(@"AOP class: %@", NSStringFromClass(self));
    executeBeforeSelector(self, @selector(viewDidAppear:), ^(NSInvocation *invocation) {
        //SNDebugLog(@"AOP: SNRollingNewsViewController viewDidAppear");
        [[SNAppUsageStatManager sharedInstance] statEnteringPage:invocation.target withPageType:SNAppUsageStatPage_RollingNewsTimeline];
    });
    executeBeforeSelector(self, @selector(viewDidDisappear:), ^(NSInvocation *invocation) {
        //SNDebugLog(@"AOP: SNRollingNewsViewController viewDidDisappear");
        [[SNAppUsageStatManager sharedInstance] statExitingPage:invocation.target withPageType:SNAppUsageStatPage_RollingNewsTimeline];
    });
}

@end
