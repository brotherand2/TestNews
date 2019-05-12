//
//  SNNewsPaperWebController+intercept.m
//  sohunews
//
//  Created by jojo on 13-12-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNewsPaperWebController+intercept.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"

@implementation SNNewsPaperWebController (intercept)

+ (void)load {
    [self addIntercepts];
}

+ (void)addIntercepts {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    executeInsteadSelector(self, @selector(addASubscribe), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForPaperSubAction] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
    
    executeInsteadSelector(self, @selector(downloadClicked:), ^(NSInvocation *invocation) {
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForPaperDownload] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
#pragma clang diagnostic pop

}

@end
