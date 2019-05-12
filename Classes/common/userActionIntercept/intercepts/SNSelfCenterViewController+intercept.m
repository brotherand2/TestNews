//
//  SNSelfCenterViewController+intercept.m
//  sohunews
//
//  Created by yangln on 14-10-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSelfCenterViewController+intercept.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"

@implementation SNSelfCenterViewController (intercept)

+ (void)load {
    executeInsteadSelector(self, @selector(onClickHead), ^(NSInvocation *invocation) {
        
        // 点击“用户头像”触发的CC统计
        SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_me link2:nil];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:more_user link2:nil];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
        [SNNewsReport reportADotGifWithTrack:paramString];
        [invocation invoke];
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    executeInsteadSelector(self, @selector(onclickLogin), ^(NSInvocation *invocation) {
        // 点击“立即使用qq登录”触发的CC统计
        SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_me link2:[SNAnalytics loginLinkStringForLocationId:kUserActionIdForUserCenterLogin]];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:login_sohu link2:nil];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
        [SNNewsReport reportADotGifWithTrack:paramString];
        
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForUserCenterLogin] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
    
    executeInsteadSelector(self, @selector(onClickMessage), ^(NSInvocation *invocation) {
        
        // 点击“消息”触发的CC统计
        SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_me link2:nil];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:more_message link2:nil];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
        [SNNewsReport reportADotGifWithTrack:paramString];
        
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForUserCenterMessage] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
    
    executeInsteadSelector(self, @selector(onClickCollection), ^(NSInvocation *invocation) {
        
        // 点击“收藏”触发的CC统计
        SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_me link2:nil];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:more_favorite link2:nil];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
        [SNNewsReport reportADotGifWithTrack:paramString];
        
        // 判断是否需要拦截登陆
        if ([[SNInterceptConfigManager sharedManager] handleActionInterceptActionId:kUserActionIdForUserCenterFaverite] == SNUserActionInterceptTypeDontIntercept) {
            [invocation invoke];
        }
    });
#pragma clang diagnostic pop

}


@end
