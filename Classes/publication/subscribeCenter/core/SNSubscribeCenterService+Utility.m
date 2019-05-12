//
//  SNSubscribeCenterService+Utility.m
//  sohunews
//
//  Created by jojo on 14-2-18.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSubscribeCenterService+Utility.h"
#import "SNDBManager.h"
#import "SNUserManager.h"

@implementation SNSubscribeCenterService (Utility)


+ (BOOL)handleAdOpenRequest:(SCSubscribeAdObject *)adObj {
    if (adObj == nil) {
        return NO;
    }
    //首先通过服务器返回的二代协议跳转
    if ([adObj.refLink length] > 0) {
        [SNUtility openProtocolUrl:adObj.refLink];
        return YES;
    }
    
    // adType：  0：订阅，1：广告 2：直播
    if ([adObj.adType isEqualToString:@"0"]) {
        if ([adObj.refId length] > 0) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:adObj.refId, @"subId", [NSNumber numberWithInt:REFER_SUBCENTER_PROMOTION], @"refer", nil];
            TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyQuery:dic] applyAnimated:YES];
            [[TTNavigator navigator] openURLAction:action];
            return YES;
        }
    }
    //    else if ([adObj.adType isEqualToString:@"1"]) {
    //        if ([adObj.refLink length] > 0) {
    //            [SNUtility openProtocolUrl:adObj.refLink];
    //            return YES;
    //        }
    //    }
    else if ([adObj.adType isEqualToString:@"2"]) {
        if ([adObj.refId length] > 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:adObj.refId forKey:kLiveIdKey];
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://live"] applyQuery:dic] applyAnimated:YES];
            [[TTNavigator navigator] openURLAction:urlAction];
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)shouldReloadMySub {
    NSNumber *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:kSubMySubLastRefreshKey];
    if (lastTime) {
        NSDate *now = [NSDate date];
        NSTimeInterval timeNow = [now timeIntervalSince1970];
        return (timeNow - [lastTime doubleValue] > kSubMySubRefreshTimeDiff);
    }
    
    return YES;
}

+ (void)saveMySubRefreshDate {
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    NSNumber *lastTime = [NSNumber numberWithDouble:timeNow];
    
    [[NSUserDefaults standardUserDefaults] setObject:lastTime forKey:kSubMySubLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *)getMySubLastRefreshDate {
    NSNumber *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:kSubMySubLastRefreshKey];
    if (lastTime) {
        return [NSDate dateWithTimeIntervalSince1970:[lastTime doubleValue]];
    }
    return nil;
}

+ (void)clearMySubRefreshDate {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubMySubLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldReloadTypeList {
    return YES;
}

+ (void)clearAllSubRefreshCachedData {
    // 清理 广场 广告数据刷新时间
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubHomeDataLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 清理 广场每个分类下的刷新时间
    NSDictionary *infoDic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (id key in infoDic.allKeys) {
        if ([key isKindOfClass:[NSString class]] &&
            [key rangeOfString:kSubTypeSubsLastRefreshKey options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldReloadHomeData {
    NSNumber *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:kSubHomeDataLastRefreshKey];
    if (lastTime) {
        NSDate *now = [NSDate date];
        NSTimeInterval timeNow = [now timeIntervalSince1970];
        return (timeNow - [lastTime doubleValue] > kSubHomeDataRefreshTimeDiff);
    }
    
    return YES;
}

+ (void)saveHomeDataRefreshDate {
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    NSNumber *lastTime = [NSNumber numberWithDouble:timeNow];
    
    [[NSUserDefaults standardUserDefaults] setObject:lastTime forKey:kSubHomeDataLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldReloadSubItemsForType:(NSString *)typeId {
    NSString *key = [NSString stringWithFormat:@"%@-%@", kSubTypeSubsLastRefreshKey, typeId];
    NSNumber *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (lastTime) {
        NSDate *now = [NSDate date];
        NSTimeInterval timeNow = [now timeIntervalSince1970];
        return (timeNow - [lastTime doubleValue] > kSubTypeSubsRefreshTimeDiff);
    }
    return YES;
}

+ (void)saveSubItemsDateForType:(NSString *)typeId {
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    NSNumber *lastTime = [NSNumber numberWithDouble:timeNow];
    NSString *key = [NSString stringWithFormat:@"%@-%@", kSubTypeSubsLastRefreshKey, typeId];
    
    [[NSUserDefaults standardUserDefaults] setObject:lastTime forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 新刊物提醒
+ (BOOL)shouldDisplayFloatingCell {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    NSString *checkKey = [NSString stringWithFormat:@"check_floating_in_my_sub_%@", version];
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:checkKey];
    if (!value)
        return YES;
    else if (![value boolValue])
        return YES;
    else
        return NO;
}

+ (void)setDisplayedFloatingCell:(BOOL)bShowed {
    if (bShowed) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
        NSString *checkKey = [NSString stringWithFormat:@"check_floating_in_my_sub_%@", version];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:checkKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        // 趁此好机会把之前不用的标志都清掉
        NSDictionary *infoDic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        for (id key in infoDic.allKeys) {
            if ([key isKindOfClass:[NSString class]] &&
                [key rangeOfString:@"check_floating_in_my_sub_" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)hasNewSubscribe {
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"has_new_subscribe"];
    if (value && [value boolValue])
        return YES;
    else
        return NO;
}

+ (void)setHasNewSubscrbe:(BOOL)bHasNew {
    [[NSUserDefaults standardUserDefaults] setObject:bHasNew ? @"1" : @"0" forKey:@"has_new_subscribe"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSubscribeOrPluginEnable:(NSString *)subId {
    return [[[[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId] isSubscribed] isEqualToString:@"1"];
}

+ (BOOL)shouldLoginForSubscribeWithSubId:(NSString *)subId {
    BOOL rt = NO;
    
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
    
    if (subObj && ![SNUserManager isLogin])
        rt = [subObj.needLogin isEqualToString:@"1"];
    
    return rt;
}

+ (BOOL)shouldLoginForSubscribeWithObj:(SCSubscribeObject *)subObj {
    BOOL rt = NO;
    
    if (subObj && [subObj isKindOfClass:[SCSubscribeObject class]] && ![SNUserManager isLogin])
        rt = [subObj.needLogin isEqualToString:@"1"];
    
    return rt;
}

+ (NSArray *)subAuthorInfoListBySubId:(NSString *)subId {
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
    if (subObj)
        return subObj.userInfoListArray;
    else
        return nil;
}

@end
