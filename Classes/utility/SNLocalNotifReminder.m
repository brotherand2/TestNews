//
//  SNLocalNotifReminder.m
//  sohunews
//
//  Created by chenhong on 14-4-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNLocalNotifReminder.h"
#import "SNDBManager.h"

/// 本地通知提醒长时间未开启app的用户
@implementation SNLocalNotifReminder

+ (void)printAllPendingLocalNotifications {
}

+ (void)cancelLocalNotifications {
#if TARGET_IPHONE_SIMULATOR
#else
    dispatch_async(dispatch_get_main_queue(), ^{
        // 应用长时间未启动过（2周）
        for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            if ([aNotif.userInfo objectForKey:kAppNotLaunchedForSomeTime]) {
                [[UIApplication sharedApplication] cancelLocalNotification:aNotif];
            }
        }
    });
#endif
}

+ (void)setupLocalNotifications {
    //判断功能是否启用
    NSString *localNotifForAppNotLaunchedForLong = [[NSUserDefaults standardUserDefaults] objectForKey:kAppNotLaunchedForSomeTimeNotifyEnabled];
    if ([localNotifForAppNotLaunchedForLong isEqualToString:@"0"]) {
        return;
    }
    
    //判断快讯是不是都关闭了
    NSString *newsPushSet = [[NSUserDefaults standardUserDefaults] stringForKey:kNewsPushSet];
    if ([newsPushSet intValue] != 0) {
        return;
    }
    
    // 判断订阅刊物的推送是不是都关闭了
    NSArray *mysubArray = [[SNDBManager currentDataBase] getSubArrayWithoutExpressOrYouMayLike];
    for (SCSubscribeObject *subObj in mysubArray) {
        if ([subObj.isPush isEqualToString:@"1"]) {
            return;
        }
    }
    
    // 应用长时间未启动过（如2周）
    BOOL bAlreadyScheduled = NO;
    for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([aNotif.userInfo objectForKey:kAppNotLaunchedForSomeTime]) {
            bAlreadyScheduled = YES;
            break;
        }
    }
    
    // n个提示语随机每隔d天弹出一次
    if (!bAlreadyScheduled) {
        // 得到提示语随机索引数组
        static const int TOTAL = 6;
        int indexArray[TOTAL];
        for (int i = 0; i < TOTAL; ++i) {
            indexArray[i] = i+1;
        }
        
        for (int i = TOTAL; i > 0; --i) {
            int m = arc4random() % i;
            int t = indexArray[i-1];
            indexArray[i-1] = indexArray[m];
            indexArray[m] = t;
        }
        
        if ([SNPreference sharedInstance].debugModeEnabled) {
            printf("random index array: ");
            for (int i = 0; i < TOTAL; ++i) {
                printf("%d ", indexArray[i]);
            }
            printf("\n");
        }
        
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:currentDate];
        NSTimeInterval timeinterval;
        NSInteger _hour = [comps hour];
        
        if (_hour < kAppNotLaunchedFireTime) {
            comps.hour = kAppNotLaunchedFireTime;
            comps.minute = 0;
            comps.second = 0;
            
            NSDate *date1 = [calendar dateFromComponents:comps];
            timeinterval = [date1 timeIntervalSinceDate:currentDate];
            timeinterval += kAppNotLaunchedPeriod;
        } else {
            comps.hour = 23;
            comps.minute = 59;
            comps.second = 59;
            
            NSDate *date1 = [calendar dateFromComponents:comps];
            timeinterval = [date1 timeIntervalSinceDate:currentDate];
            timeinterval += kAppNotLaunchedFireTime * 60 * 60 + 1 + kAppNotLaunchedPeriod;
        }
        
        calendar = nil;
        
        for (int i = 0; i < 3; ++i) {
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif == nil)
                break;
            
            localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeinterval];
            timeinterval += kAppNotLaunchedPeriod;
            
            //int index = arc4random()%3 + 1;
            int index = indexArray[i];
            NSString *temp = [NSString stringWithFormat:@"appNotUsedForSomeTime%d", index];
            localNotif.alertBody = NSLocalizedString(temp, nil);
            
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            localNotif.repeatCalendar = [NSCalendar currentCalendar];
            localNotif.repeatInterval = kCFCalendarUnitMonth;
            localNotif.alertAction = @"去看看";
            
            localNotif.soundName = UILocalNotificationDefaultSoundName; //=nil; //避免夜间声音打扰
            localNotif.applicationIconBadgeNumber = 1;
            
            NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", kAppNotLaunchedForSomeTime, nil];
            localNotif.userInfo = infoDict;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        }
    }
}

@end
