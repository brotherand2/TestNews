//
//  SNCheckManager.m
//  sohunews
//
//  Created by qi pei on 7/3/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
// WIKI: http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=2163166

#import "SNCheckManager.h"
//#import "SNURLDataResponse.h"
#import "SNDBManager.h"
#import "SNUpgrade.h"
#import "SNCheckRequest.h"
#import "SNNotifyService.h"
#import "SNDataBase_Notification.h"
#import "SNBubbleBadgeObject.h"
#import "SNAdvertiseManager.h"
#import "SNUserLocationManager.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "SNSubscribeCenterDefines.h"
#import "SNDynamicPreferences.h"
#import "SNRollingNewsPublicManager.h"
#import "SNUpgradeInfo.h"

#define kSNSupportVideoDownload                 (@"kSNSupportVideoDownload")

static SNCheckManager *_sharedInstance = nil;
static NSArray *checkDoResults = nil;

@implementation SNCheckManager

@synthesize allAds;
@synthesize isAccurateAd;
@synthesize contentRefreshInterval = _contentRefreshInterval;

- (id)init {
    if (_sharedInstance != nil) {
        [NSException raise:@"singletonClassError" format:@"不要直接初始化单例类 SNCheckManager."];
    } else if (self = [super init]) {
        _sharedInstance = self;
        _contentRefreshInterval = 60 * 60;
    }
    return _sharedInstance;
}

#pragma mark -
#pragma mark static methods
+ (SNCheckManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNCheckManager alloc] init];
    });
    
    return _sharedInstance;
}


+ (void)startCheckService:(RefreshInterval)interval {
    [[SNCheckManager sharedInstance] startCheckTimer:interval];
}

+ (void)stopCheckService {
    [[SNCheckManager sharedInstance] stopCheckTimer];
}

- (void)downloadAllImages {
}

#pragma mark -
- (void)startCheckTimer:(RefreshInterval)interval {
    _interval = interval;
    
    [self stopCheckTimer];
    [self startCheckServiceTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _adTimer = [NSTimer scheduledTimerWithTimeInterval:_interval
                                                    target:self
                                                  selector:@selector(startCheckServiceTimer)
                                                  userInfo:nil
                                                   repeats:YES];
    });
}

- (void)startTimer {
    [self stopCheckTimer];
    _adTimer = [NSTimer scheduledTimerWithTimeInterval:_interval
                                                target:self
                                              selector:@selector(startCheckServiceTimer)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)stopCheckTimer {
    if (_adTimer) {
        if ([_adTimer isValid]) {
            [_adTimer invalidate];
            _adTimer = nil;
        }
    }
}

- (void)startCheckServiceTimer {
//    [self performSelectorInBackground:@selector(startCheckServiceTimerInThread) withObject:nil];
    //放主线程执行，避免很长时间未执行到
    [self startCheckServiceTimerInThread];
}

- (void)startCheckServiceTimerInThread {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kClientInfoSynchronized]) {
        [self checkAdDataFromServer];
    } else {
        SNUpgrade *_upgrade = [[SNUpgrade alloc] init];
        [_upgrade getUpgradeInfoWithCompletionHandle:^(SNUpgradeInfo *upgradeInfo) {
            if (upgradeInfo && ![upgradeInfo hadError]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kClientInfoSynchronized];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self checkAdDataFromServer];
            }
        }];
    }
}

- (void)checkAdDataFromServer {
    self.isAccurateAd = NO;
    
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        NSString *uid = [SNClientRegister sharedInstance].uid;
        if ([uid isEqualToString:kDefaultProfileClientID]) {
            return;
        }
        [[[SNCheckRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
            NSString *stringcheckDoResult = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (stringcheckDoResult.length > 0) {
                NSArray *checkDoResults = [stringcheckDoResult componentsSeparatedByString:@","];
                [self handleCheckResultWithCheckDoResults:checkDoResults];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        } failure:nil];
    }
}

- (void)handleCheckResultWithCheckDoResults:(NSArray *)checkDoResults {
    if (checkDoResults.count > 1) {
        NSString *minute = [checkDoResults objectAtIndex:1];
        int second = [minute intValue] * 60;
        if (second > 0 && second != _interval) {
            _interval = second;
            [self startTimer];
        }
    }
    
    // App长期未使用本地通知提醒是否开启，1开启，0关闭。默认开启
    if (checkDoResults.count > 10) {
        NSString *v = [checkDoResults objectAtIndex:10];
        BOOL bEnable = ![v isEqualToString:@"0"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[NSUserDefaults standardUserDefaults] setObject:(bEnable ? @"1" : @"0") forKey:kAppNotLaunchedForSomeTimeNotifyEnabled];
        });
    }
    
    [SNBubbleNumberManager shareInstance].feedback = [SNCheckManager hasNewfeedbackWithCheckDoResults:checkDoResults];
    
    // 新通知个数 by chengweibin
    if (checkDoResults.count > 15) {
        NSString *msgNum = [checkDoResults objectAtIndex:15];
        if ([msgNum intValue] > 0) {
            [[SNNotifyService shareInstance] startRequestNotify];
        }
    }
    
    // 第十八个返回值，视频tab中新视频的个数n，通过参数maxVid来控制（n 为该用户的timeline中 大于 maxVid的视频个数）
    if (checkDoResults.count > 17) {
        NSString *num = [checkDoResults objectAtIndex:17];
        if ([num intValue] >= 0) {
            [SNNotificationManager postNotificationName:kVideoTimelineCheckNewNotification object:nil userInfo:@{kVideoTimelineCntForNew:num}];
        }
    }
    
    // 第十九个返回值，静默下载是否有更新 0没有 时间戳代表有
    // 第二十个返回值，订阅tab中我的订阅是否有更新（用于显示红点 0-否 1-是）
    if (checkDoResults.count > 19) {
        NSString *num = [checkDoResults objectAtIndex:19];
        
        [SNNotificationManager postNotificationName:kUnReadCountIsShowNotification object:num.integerValue > 0? @"1":@"0"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[NSUserDefaults standardUserDefaults] setBool:num.integerValue forKey:kIsRedDot];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
    
    // 第二十一个返回值，广告sdk投放开关 0关闭 1开启
    if (checkDoResults.count > 20) {
        NSString *rs = [checkDoResults objectAtIndex:20];
        if (rs) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[NSUserDefaults standardUserDefaults] setObject:rs forKey:kSNAdvertiseEnableKey];
            });
        }
    }
    
    // 第二十二个返回值，视频离线功能是否开启（控制 离线按钮入口和离线列表入口 是否显示给用户）
    if (checkDoResults.count > 21) {
        NSString *rs = [checkDoResults objectAtIndex:21];
        if (rs) {
            NSString *oldValueOfSupportVideoDownload = [[NSUserDefaults standardUserDefaults] stringForKey:kSNSupportVideoDownload];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[NSUserDefaults standardUserDefaults] setObject:rs forKey:kSNSupportVideoDownload];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
            
            if (![oldValueOfSupportVideoDownload isEqualToString:rs]) {
                [SNNotificationManager postNotificationName:kSupportVideoDownloadValueChangedNotification object:rs];
            }
        }
    }
    // 客户端强制请求location.go时间间隔,单位分钟. 在此时间间隔以上的未请求location.go的情况下,必须强制请求一次location.go
    if (checkDoResults.count > 22) {
        NSString *rs = [checkDoResults objectAtIndex:22];
        if (rs) {
            int requestTime = [rs intValue];
            if (requestTime * 60 > 0) {
                [SNUserLocationManager sharedInstance].loactionRequestTime = requestTime * 60;
            }
        }
    }
    
    // 客户端请求location.go的距离阈值,单位公里,当本次定位和上次定位的距离大于此值,就需要将最新的经纬度传给location.go
    if (checkDoResults.count > 23) {
        NSString *rs = [checkDoResults objectAtIndex:23];
        if (rs) {
            int distanceValue = [rs intValue];
            if (distanceValue >0) {
                [SNUserLocationManager sharedInstance].distanceValue = distanceValue;
            }
        }
    }
    
    // 客户端定位的时间间隔, 单位分钟
    if (checkDoResults.count > 24) {
        NSString *rs = [checkDoResults objectAtIndex:24];
        if (rs) {
            int updateTime = [rs intValue];
            [[SNUserLocationManager sharedInstance] updateLocationTime:updateTime];
        }
    }
    
    // 要闻列表失效时间间隔, 单位分钟
    if (checkDoResults.count > 25) {
        NSString *rs = [checkDoResults objectAtIndex:25];
        if (rs) {
            int updateTime = [rs intValue];
            _contentRefreshInterval = updateTime*60;
        }
    }
    
    // 是否请求特殊皮肤接口
    if (checkDoResults.count > 26) {
        NSString *num = [checkDoResults objectAtIndex:26];
        if (num) {
            [SNUserDefaults setBool:[num boolValue] forKey:@"DynamicPreferences"];
            //添加了条件判断，防止为空时在主线程中刷新视图 bug #41967 crash
            if ([num intValue] > 0) {
                [[SNDynamicPreferences sharedInstance] requestDynamicPreferences];
            }
            else {
                [[SNDynamicPreferences sharedInstance] clearData];
                if ([[SNDynamicPreferences sharedInstance] needRefresh]) {
                    [SNDynamicPreferences refreshView];
                }
            }
        }
    }
    
    if (checkDoResults.count > 27) {
        // 判断是否有回复
        NSString *num = [checkDoResults objectAtIndex:27];
        [SNNotificationManager postNotificationName:kUnReadFbReplyNotification object:num.integerValue > 0 ? @"1":@"0"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [SNUserDefaults setBool:num.integerValue forKey:kFbHaveReply];
        });
    } else {
        [SNUserDefaults setBool:NO forKey:@"DynamicPreferences"];
        [SNDynamicPreferences refreshView];
    }
}

- (void)dealloc {
    if (_adTimer) {
        if ([_adTimer isValid]) {
            [_adTimer invalidate];
        }
    }
}

+ (BOOL)hasNewfeedbackWithCheckDoResults:(NSArray *)checkDoResults {
    if (checkDoResults) {
        if (checkDoResults.count > 4) {
            NSString *fbCount = [checkDoResults objectAtIndex:4];
            fbCount = fbCount ? fbCount : @"0";
            if ([@"0" isEqualToString:fbCount]) {
                return NO;
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

+ (void)changeToNoNewFB {
    if (checkDoResults.count > 4) {
        NSMutableArray *mArray = [NSMutableArray arrayWithArray:checkDoResults];
        [mArray replaceObjectAtIndex:4 withObject:@"0"];
        checkDoResults = mArray;
        
        NSMutableString *tmp = [NSMutableString stringWithString:[checkDoResults objectAtIndex:0]];
        for (int i = 1 ; i < checkDoResults.count; i++) {
            [tmp appendFormat:@",%@", [checkDoResults objectAtIndex:i]];
        }
        [[NSUserDefaults standardUserDefaults] setValue:tmp forKey:kCheckDoResponse];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)checkNewVersion {
    if (checkDoResults) {
        if (checkDoResults.count > 4) {
            NSString *value = [checkDoResults objectAtIndex:2];
            value = value ? value : @"0";
            if (value && ![value isKindOfClass:[NSString class]]) {
                value = [NSString stringWithFormat:@"%@", value];
            }
            if ([@"0" isEqualToString:value]) {
                return NO;
            } else {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:kUpgradeOffOn]) {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUpgradeOffOn];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return NO;
                }
                return YES;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

+ (BOOL)checkDynamicPreferences {
    return [SNUserDefaults boolForKey:@"DynamicPreferences"];
}

- (BOOL)supportVideoDownload {
    NSString *supportDownload = [[NSUserDefaults standardUserDefaults] stringForKey:kSNSupportVideoDownload];
    return (supportDownload.length <= 0) || ![supportDownload isEqualToString:@"0"];
}

#pragma mark - SNUpgradeDelegate
- (void)receiveUpgradeInfo:(SNUpgradeInfo *)upgradeInfo {
    if (upgradeInfo&&![upgradeInfo hadError]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kClientInfoSynchronized];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self checkAdDataFromServer];
    }
}

@end
