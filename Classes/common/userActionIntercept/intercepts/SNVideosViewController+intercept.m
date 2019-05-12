//
//  SNVideosViewController+intercept.m
//  sohunews
//
//  Created by jojo on 13-12-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosViewController+intercept.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"
#import "SNAppUsageStatManager.h"

@implementation SNVideosViewController (intercept)

+ (void)load {
    executeInsteadSelector(self, @selector(tabBarBeginEdit:), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForVideoChannelEdit] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
    
    executeBeforeSelector(self, @selector(viewDidAppear:), ^(NSInvocation *invocation) {
        SNDebugLog(@"AOP: SNVideosViewController viewDidAppear");
        [[SNAppUsageStatManager sharedInstance] statEnteringPage:invocation.target withPageType:SNAppUsageStatPage_VideoTimeline];
    });
    executeBeforeSelector(self, @selector(viewDidDisappear:), ^(NSInvocation *invocation) {
        SNDebugLog(@"AOP: SNVideosViewController viewDidDisappear");
        [[SNAppUsageStatManager sharedInstance] statExitingPage:invocation.target withPageType:SNAppUsageStatPage_VideoTimeline];
    });
}

@end
