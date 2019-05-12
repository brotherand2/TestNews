//
//  SNNewsFullscreenManager.m
//  sohunews
//
//  Created by HuangZhen on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsFullscreenManager.h"
#import "SNRollingNewsPublicManager.h"
#import "SNDBManager.h"
#import "SNDynamicPreferences.h"
#import "SNRollingNewsViewController.h"

#define kIsFullScreanSwitch             @"IsFullScreanSwitch"
#define kIsFirstOpenAPPToday            @"kIsFirstOpenAPPToday"
#define kRollingNewsPullTimes           @"kRollingNewsPullTimes"
#define kNeedTrainAnimation             @"needTrainAnimation"

@implementation SNNewsFullscreenManager

+ (SNNewsFullscreenManager *)manager {
    static SNNewsFullscreenManager *__manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[SNNewsFullscreenManager alloc] init];
    });
    return __manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _openAppFlag = YES;
        _rollingFocusAnchor = 0.f;
        _homeTableViewOffsetY = 0.f;
        _focusToTrain = NO;
        _trainAnimationDistance = 1;
        _newsPullTimes = [[self class] getUserNewsPullTimes];
    }
    
    return self;
}

+ (BOOL)isFullScreanSwitch {
    //第二天6点后显示全屏幕焦点图
    return [SNUserDefaults boolForKey:kIsFullScreanSwitch] && [SNUtility isTimeToResetChannel];
}

+ (BOOL)newsChannelChanged {
    return [SNUserDefaults boolForKey:kIsFullScreanSwitch];
}

//此方法目前只针对要闻频道
+ (void)setFullScreanSwitch:(BOOL)value {
    BOOL currentStatus = [self newsChannelChanged];
    if (currentStatus != value) {
        [SNUtility resetHomeChannelTime];
        
        //判断当前要闻状态是否变化, 如果变化需要清空缓存
        //如果以后所有频道都变化, 需要针对不同频道做处理
        [[SNAppStateManager sharedInstance] removeAllChannelRefreshList];
        [[SNRollingNewsPublicManager sharedInstance] deleteRequestParamsWithChannelId:@"1"];
        [[SNDBManager currentDataBase] clearHomeChannelRollingNewsList];
        [SNUserDefaults setBool:value forKey:kIsFullScreanSwitch];
    }
}

+ (void)setOpenAppToday:(BOOL)isFirst{
    [SNUserDefaults setBool:isFirst forKey:kIsFirstOpenAPPToday];
}

+ (BOOL)isFirstOpenAppToday {
    //新版全屏幕要闻频道每天6点重置，其他刷新
    if ([SNUtility isTimeToResetChannel]) {
        [SNUtility deleteChannelParamsWithChannelId:[SNUtility sharedUtility].currentChannelId];
        [SNNewsFullscreenManager setOpenAppToday:YES];
        [[SNDBManager currentDataBase] clearRollingNewsHistoryByChannelID:@"1" days:[[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsSaveDays]];
        return YES;
    }
    //return YES;
    return [SNUserDefaults boolForKey:kIsFirstOpenAPPToday];
}

+ (void)userNewsPullTimes:(int)pullTime{
    [SNUserDefaults setInteger:pullTime forKey:kRollingNewsPullTimes];
}

+ (int)getUserNewsPullTimes{
    if ([SNNewsFullscreenManager isFirstOpenAppToday] == YES) {
        SNAppConfig *config = [[SNAppConfigManager sharedInstance] config];
        [SNNewsFullscreenManager userNewsPullTimes:[config.appNewsSettingConfig getNewsPullTimes]];
        NSInteger configPullTimes = [config.appNewsSettingConfig getNewsPullTimes];
        [self userNewsPullTimes:configPullTimes];
        return configPullTimes;
    }
    
    return [SNUserDefaults integerForKey:kRollingNewsPullTimes];
}

+ (void)setNeedTrainAnimation:(BOOL)need{
    [SNUserDefaults setBool:need forKey:kNeedTrainAnimation];
}

+ (BOOL)needTrainAnimation{
    return [SNUserDefaults boolForKey:kNeedTrainAnimation];
}

+ (void)resetStatusBarStyleIfFullscreenMode:(BOOL)fullscreenMode {
    if (![[TTNavigator navigator].topViewController isKindOfClass:[SNRollingNewsViewController class]]) {
        return;
    }
    if (fullscreenMode && ![SNUtility isFromChannelManagerViewOpened] && [[SNUtility getCurrentChannelId] isEqualToString:@"1"]) {
        CGFloat offsetY = [SNNewsFullscreenManager manager].homeTableViewOffsetY;
        if (offsetY < 0 || offsetY > [SNNewsFullscreenManager manager].trainAnimationDistance) {
            [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"default"}];
        }else{
            [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
        }
    }else{
        if ([[SNDynamicPreferences sharedInstance] statusTextColorShouldChange] && ![[SNThemeManager sharedThemeManager] isNightTheme] && ![SNUtility isFromChannelManagerViewOpened]) {
            [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
        }
        else {
            if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
                [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
            }else{
                [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"default"}];
            }
        }
    }
}

@end
