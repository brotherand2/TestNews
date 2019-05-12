//
//  SNLiveSubscribeService.m
//  sohunews
//
//  Created by Chen Hong on 12-7-9.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveSubscribeService.h"
#import "CacheObjects.h"


#define kSystemVersionIsLow             (@"您的系统版本太低，订阅功能在iOS 4.0以上版本可用")

@implementation SNLiveSubscribeService

- (id)init {
	if (self = [super init]) {
        _subscribedLiveIdInfo = [[NSMutableDictionary alloc] init];
        
#if TARGET_IPHONE_SIMULATOR
        
#else
    for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([aNotif.userInfo objectForKey:kLiveIdKey]) {
            [_subscribedLiveIdInfo setObject:@"1" forKey:[aNotif.userInfo objectForKey:kLiveIdKey]];
        }
    }
#endif
    }
    return self;
}

- (void)dealloc {
}

- (void)refreshSubscribeInfo {
    if (!_subscribedLiveIdInfo) {
        _subscribedLiveIdInfo = [[NSMutableDictionary alloc] init];
    } else {
        [_subscribedLiveIdInfo removeAllObjects];
    }
    
    for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([aNotif.userInfo objectForKey:kLiveIdKey]) {
            [_subscribedLiveIdInfo setObject:@"1" forKey:[aNotif.userInfo objectForKey:kLiveIdKey]];
        }
    }
}

#pragma mark static methods
+ (SNLiveSubscribeService *)sharedInstance {
    static SNLiveSubscribeService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNLiveSubscribeService alloc] init];
    });
    return _sharedInstance;
}

- (BOOL)subscribeWithLiveGame:(LivingGameItem *)liveItem {
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"4.0")) {
        [SNNotificationCenter showMessage:kSystemVersionIsLow];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kSystemVersionIsLow toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }

    if (!liveItem || !liveItem.liveId) {
        return NO;
    }
    
    NSMutableArray *duplicatedNotif = [NSMutableArray arrayWithCapacity:1];
    for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[NSString stringWithFormat:@"%@", [aNotif.userInfo objectForKey:kLiveIdKey]] isEqualToString:liveItem.liveId]) {
            SNDebugLog(@"duplicated Notif");
            [duplicatedNotif addObject:aNotif];
        }
        SNDebugLog(@"notification: %@", [aNotif.userInfo objectForKey:kLiveIdKey]);
    }
    
    for (UILocalNotification *aNotif in duplicatedNotif) {
        aNotif.applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication] cancelLocalNotification:aNotif];
    }
    
    // 如果指定时间小于当前时间则忽略
    if ([[NSDate date] timeIntervalSince1970] > [liveItem.liveTime longLongValue]/1000) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"直播已经开始" toUrl:nil mode:SNCenterToastModeOnlyText];
        return NO;
    }
    
    // local notification
    UILocalNotification *localNotif = [[UILocalNotification alloc] init]; 
    
    if (localNotif == nil)  
        return NO;
    
    localNotif.fireDate = [NSDate dateWithTimeIntervalSince1970:[liveItem.liveTime longLongValue]/1000];//[NSDate dateWithTimeIntervalSinceNow:15];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertAction = NSLocalizedString(@"显示", nil); 
    localNotif.alertBody = [NSString stringWithFormat:@"%@ 正在直播", liveItem.title];
    localNotif.soundName = UILocalNotificationDefaultSoundName; 
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:liveItem.liveId, kLiveIdKey, liveItem.liveType, kLiveTypeKey, nil];
    localNotif.userInfo = infoDict;
    SNDebugLog(@"added localNoti: %@", infoDict);
    
    [[SNUtility getApplicationDelegate].localNotifInfo setObject:@"0" forKey:liveItem.liveId];
    
    [_subscribedLiveIdInfo setObject:@"1" forKey:liveItem.liveId];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif]; 
    return YES;
}

- (BOOL)unsubscribeLiveGame:(NSString *)liveId {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"4.0")) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kSystemVersionIsLow toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }

    if (!liveId.length) {
        return NO;
    }
    
    UILocalNotification *notificationToCancel=nil;
    for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if([[NSString stringWithFormat:@"%@", [aNotif.userInfo objectForKey:kLiveIdKey]] isEqualToString:liveId]) {
            notificationToCancel=aNotif;
            SNDebugLog(@"canceled localNoti: %@", aNotif.userInfo);
            break;
        }
    }
    
    if (notificationToCancel) {
        [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
    }
    
    [_subscribedLiveIdInfo removeObjectForKey:liveId];
    return YES;
}

- (BOOL)hasLiveGameSubscribed:(NSString *)liveId {
    BOOL ret = [[_subscribedLiveIdInfo objectForKey:liveId] boolValue];
    return ret;
}

- (NSArray *)subscribedList {
    return _subscribedLiveIdInfo.allKeys;
}


@end
