//
//  SNSubCenterAllSubsCell+intercept.m
//  sohunews
//
//  Created by jojo on 13-12-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSubCenterAllSubsCell+intercept.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"

@implementation SNSubCenterAllSubsCell (intercept)

+ (void)load {
    executeInsteadSelector(self, NSSelectorFromString(@"subBtnClick"), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForSubCenterSubAction] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
}

@end
