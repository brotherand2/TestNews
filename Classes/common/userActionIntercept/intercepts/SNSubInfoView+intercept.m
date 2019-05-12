//
//  SNSubInfoView+intercept.m
//  sohunews
//
//  Created by jojo on 13-12-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSubInfoView+intercept.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"

@implementation SNSubInfoView (intercept)

+ (void)load {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    executeInsteadSelector(self, @selector(addFollowAction:), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        //5.2.3订阅自媒体刊物不弹登录浮层
        [invocation invoke];
    });
#pragma clang diagnostic pop

}

@end
