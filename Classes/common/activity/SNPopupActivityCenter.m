//
//  SNPopupActivityCenter.m
//  sohunews
//
//  Created by handy wang on 6/24/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNPopupActivityCenter.h"
#import "SNPopupActivity.h"
#import "SNAppConfigManager.h"
#import "SNPopupActivityConst.h"
#import "SNRedPacketManager.h"
#import "SNNormalActivityAlert.h"
#import "SNAlertStackManager.h"
static NSString *kLasttimePopupedActivityID = @"kLasttimePopupedActivityID";

@interface SNPopupActivityCenter ()

@end

@implementation SNPopupActivityCenter

+ (SNPopupActivityCenter *)defaultCenter {
    static SNPopupActivityCenter *activityCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        activityCenter = [[SNPopupActivityCenter alloc] init];
    });
    return activityCenter;
}

- (void)popupActivityIfNeeded {
    //activity id为空视为没有弹窗活动
    SNPopupActivity *activity = [SNAppConfigManager sharedInstance].popupActivity;
    if (activity.identifier.length <= 0 || [activity.identifier isEqualToString:@"0"]) {
        SNDebugLog(@"Cant popup activity for empty activity id");
        return;
    }

    //最新activity id与上次弹窗activity id相同则视为此活动已弹窗过
    NSString *cachedLasttimePopupedActivityID = [[NSUserDefaults standardUserDefaults] stringForKey:kLasttimePopupedActivityID];
    if ([cachedLasttimePopupedActivityID isEqualToString:activity.identifier]) {
        return;
    }

    //红包活动不显示
    if (activity.activityType == 2) {
        return;
    }

    [self showNormalActivityAlert:activity];

    [SNNormalActivityAlert cacheLasttimePopupedActivityID:activity.identifier];
}


- (void)popupRedPacketActivityIfNeeded{
    //当前有红包口令或着优惠卷口令，不显示红包活动页
    if ([SNRedPacketManager sharedInstance].isValidRedPacket) {
        return;
    }
    
    SNPopupActivity *activity = [SNAppConfigManager sharedInstance].popupActivity;
    
    //activity id为空视为没有弹窗活动
    if (activity.identifier.length <= 0 || [activity.identifier isEqualToString:@"0"]) {
        SNDebugLog(@"Cant popup activity for empty activity id");
        return;
    }
    
    //最新activity id与上次弹窗activity id相同则视为此活动已弹窗过
    NSString *cachedLasttimePopupedActivityID = [[NSUserDefaults standardUserDefaults] stringForKey:kLasttimePopupedActivityID];
    if ([cachedLasttimePopupedActivityID isEqualToString:activity.identifier]) {
        return;
    }
    
    if (activity.activityType == 2) {
        //显示红包引导活动页面
        [self showNormalActivityAlert:activity];
        [SNNormalActivityAlert cacheLasttimePopupedActivityID:activity.identifier];
    }
}

- (void)showNormalActivityAlert:(SNPopupActivity *)activity {
    SNNormalActivityAlert *activityAlert = [[SNNormalActivityAlert alloc] initWithAlertViewData:activity];
    [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:activityAlert];
}

@end
