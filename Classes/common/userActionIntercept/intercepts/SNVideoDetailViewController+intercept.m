//
//  SNVideoDetailViewController+intercept.m
//  sohunews
//
//  Created by XiaoShan on 11/6/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNVideoDetailViewController+intercept.h"
#import "SNAppUsageStatManager.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"

@implementation SNVideoDetailViewController (intercept)

+ (void)load {
    executeBeforeSelector(self, @selector(viewDidAppear:), ^(NSInvocation *invocation) {
        SNDebugLog(@"AOP: SNVideoDetailViewController viewDidAppear");
        [[SNAppUsageStatManager sharedInstance] statEnteringPage:invocation.target withPageType:SNAppUsageStatPage_NewsContent];
    });
    
    executeBeforeSelector(self, @selector(viewDidDisappear:), ^(NSInvocation *invocation) {
        SNDebugLog(@"AOP: SNVideoDetailViewController viewDidDisappear");
        [[SNAppUsageStatManager sharedInstance] statExitingPage:invocation.target withPageType:SNAppUsageStatPage_NewsContent];
    });
}

@end