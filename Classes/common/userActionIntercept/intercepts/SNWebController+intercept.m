//
//  SNWebController+intercept.m
//  sohunews
//
//  Created by XiaoShan on 11/6/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNWebController+intercept.h"
#import "SNAppUsageStatManager.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"

@implementation SNWebController (intercept)

+ (void)load {
    executeBeforeSelector(self, @selector(viewDidAppear:), ^(NSInvocation *invocation) {
        SNDebugLog(@"AOP: SNWebController viewDidAppear");
        [[SNAppUsageStatManager sharedInstance] statEnteringPage:invocation.target withPageType:SNAppUsageStatPage_NewsContent];
    });
    
    executeBeforeSelector(self, @selector(viewDidDisappear:), ^(NSInvocation *invocation) {
        SNDebugLog(@"AOP: SNWebController viewDidDisappear");
        [[SNAppUsageStatManager sharedInstance] statExitingPage:invocation.target withPageType:SNAppUsageStatPage_NewsContent];
    });
}

@end
