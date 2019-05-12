//
//  SNLiveRoomViewController+intercept.m
//  sohunews
//
//  Created by jojo on 13-12-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomViewController+intercept.h"
#import "SNAppUsageStatManager.h"
#import "AOPAspect.h"
#import "SNInterceptConfigManager.h"
//#import "Aspect.h"

@implementation SNLiveRoomViewController (intercept)

+ (void)load {
    executeInsteadSelector(self, NSSelectorFromString(@"onLiveChatTabDidSelected"), ^(NSInvocation *invocation) {
        SNUserTrack *curPage = [SNUserTrack trackWithPage:live link2:[SNAnalytics loginLinkStringForLocationId:kUserActionIdForLiveChat]];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [curPage toFormatString], f_login];
        [SNNewsReport reportADotGifWithTrack:paramString];
        
        [invocation invoke];
    });
    
    executeBeforeSelector(self, @selector(viewDidAppear:), ^(NSInvocation *invocation) {
        SNDebugLog(@"AOP: SNLiveRoomViewController viewDidAppear");
        [[SNAppUsageStatManager sharedInstance] statEnteringPage:invocation.target withPageType:SNAppUsageStatPage_NewsContent];
    });
    
    executeBeforeSelector(self, @selector(viewDidDisappear:), ^(NSInvocation *invocation) {
        SNDebugLog(@"AOP: SNLiveRoomViewController viewDidDisappear");
        [[SNAppUsageStatManager sharedInstance] statExitingPage:invocation.target withPageType:SNAppUsageStatPage_NewsContent];
    });
}

@end
