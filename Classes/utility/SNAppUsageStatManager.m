//
//  SNAppUsageStatManager.m
//  sohunews
//
//  Created by you guess on 14-8-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNAppUsageStatManager.h"
#import "SNPickStatisticRequest.h"

@interface SNAppUsageStatManager() {
    NSMutableDictionary *_enteringPagesDateDic;
}
@end

@implementation SNAppUsageStatManager

+ (SNAppUsageStatManager *)sharedInstance {
    static SNAppUsageStatManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNAppUsageStatManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enteringPagesDateDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)statAppLaunching {
    [self cacheEnteringPageDateWhileAppLaunching];
    NSDate *startVisitTime = [NSDate date];
    if (!!startVisitTime) {
        NSTimeInterval t = startVisitTime.timeIntervalSince1970;
        [SNUserDefaults setDouble:t forKey:kAPPCurrentStartVisitTime];
    }
}

- (void)statAppResigning {
    [self calculateDurationWhileAppResigning];
    
    NSDate *currentEndVisitTime = [NSDate date];
    
    SNAppUsageStatData *statData = [[SNAppUsageStatData alloc] init];
    statData.launchingTimeInSec = [SNUserDefaults doubleForKey:kAPPCurrentStartVisitTime];
    if (self.isFromLaunch) {
        statData.currentTimeResigningTimeInSec = -0.001;
        self.isFromLaunch = NO;
    }
    else {
        statData.currentTimeResigningTimeInSec = currentEndVisitTime.timeIntervalSince1970;
    }
    
    statData.lastTimeResigningTimeInSec = [SNUserDefaults doubleForKey:kAppLastEndVisitTime];
    CGFloat s1 = [SNUserDefaults doubleForKey:[self pageStayDurationKey:SNAppUsageStatPage_RollingNewsTimeline]];
    CGFloat s2 = [SNUserDefaults doubleForKey:[self pageStayDurationKey:SNAppUsageStatPage_VideoTimeline]];
    CGFloat s3 = [SNUserDefaults doubleForKey:[self pageStayDurationKey:SNAppUsageStatPage_MyCenter]];
    CGFloat s4 = [SNUserDefaults doubleForKey:[self pageStayDurationKey:SNAppUsageStatPage_NewsContent]];
    statData.rollingNewsStayDurInSec =s1;
    statData.videosStayDurInSec =s2;
    statData.myCenterStayDurInSec = s3;
    statData.newsContentStayDurInSec = s4;
    statData.appLaunchingRefer = [SNUserDefaults integerForKey:kAppLaunchingRefer];
    
    [[[SNPickStatisticRequest alloc] initWithDictionary:[SNAppUsageStatManager addParamsWithStatData:statData]
                                       andStatisticType:PickLinkDotGifTypeUsr] send:nil failure:nil];
    
    //清扫数据
    [SNUserDefaults removeObjectForKey:[self pageStayDurationKey:SNAppUsageStatPage_RollingNewsTimeline]];
    [SNUserDefaults removeObjectForKey:[self pageStayDurationKey:SNAppUsageStatPage_VideoTimeline]];
    [SNUserDefaults removeObjectForKey:[self pageStayDurationKey:SNAppUsageStatPage_MyCenter]];
    [SNUserDefaults removeObjectForKey:[self pageStayDurationKey:SNAppUsageStatPage_NewsContent]];
    [SNUserDefaults removeObjectForKey:kAppLaunchingRefer];
    [SNUserDefaults removeObjectForKey:kClickIntelligentOfferKey];
    [SNUserDefaults removeObjectForKey:kSpreadAnimationStartKey];
    
    if (!!currentEndVisitTime) {
        NSTimeInterval t = currentEndVisitTime.timeIntervalSince1970;
        [SNUserDefaults setDouble:t forKey:kAppLastEndVisitTime];
    }
    
    [SNUserDefaults setBool:YES forKey:kLaunchAppKey];
}

- (void)statAppLaunchingRefer:(SNAppLaunchingRefer)refer {
    [SNUserDefaults setInteger:refer forKey:kAppLaunchingRefer];
}

- (void)statEnteringPage:(id)page withPageType:(SNAppUsageStatPage)pageType {
    if (!!page) {
        NSString *enterKey = [self enteringPageDateKey:page withPageType:pageType];
        _enteringPagesDateDic[enterKey] = [NSDate date];
    }
}

- (void)statExitingPage:(id)page withPageType:(SNAppUsageStatPage)pageType {
    if (page) {
        //单次停留时长
        NSString *enteringPageKey = [self enteringPageDateKey:page withPageType:pageType];
        NSDate *enteringPageDate = _enteringPagesDateDic[enteringPageKey];
        NSTimeInterval pageStayDuration = fabs([enteringPageDate timeIntervalSinceNow]);
        [_enteringPagesDateDic removeObjectForKey:enteringPageKey];
        
        //多次停留时长总和
        double cachePageStayDuration = [SNUserDefaults doubleForKey:[self pageStayDurationKey:pageType]];
        NSTimeInterval totalDurationOfAPage = cachePageStayDuration+pageStayDuration;
        [SNUserDefaults setDouble:totalDurationOfAPage forKey:[self pageStayDurationKey:pageType]];
    }
}

#pragma mark - Private
- (void)calculateDurationWhileAppResigning {
    for (int i=SNAppUsageStatPage_RollingNewsTimeline; i<SNAppUsageStatPageTypeCount; i++) {
        for (NSString *key in _enteringPagesDateDic.allKeys) {
            if ([key endWith:[NSString stringWithFormat:@"enter_page_%d", i]]) {
                //单次停留时长
                NSDate *enteringPageDate = _enteringPagesDateDic[key];
                NSTimeInterval pageStayDuration = fabs([enteringPageDate timeIntervalSinceNow]);
                //多次停留时长总和
                double cachePageStayDuration = [SNUserDefaults doubleForKey:[self pageStayDurationKey:i]];
                NSTimeInterval totalDurationOfAPage = cachePageStayDuration+pageStayDuration;
                [SNUserDefaults setDouble:totalDurationOfAPage forKey:[self pageStayDurationKey:i]];
            }
        }
    }
}

- (void)cacheEnteringPageDateWhileAppLaunching {
    for (int i=SNAppUsageStatPage_RollingNewsTimeline; i<SNAppUsageStatPageTypeCount; i++) {
        for (NSString *key in _enteringPagesDateDic.allKeys) {
            if ([key endWith:[NSString stringWithFormat:@"enter_page_%d", i]]) {
                _enteringPagesDateDic[key] = [NSDate date];
            }
        }
    }
}

- (NSString *)enteringPageDateKey:(id)page withPageType:(SNAppUsageStatPage)pageType {
    return [NSString stringWithFormat:@"%p_enter_page_%ld", page, (long)pageType];
}

- (NSString *)pageStayDurationKey:(SNAppUsageStatPage)pageType {
    return [NSString stringWithFormat:@"page_stay_duration_%ld", (long)pageType];
}

+ (NSDictionary *)addParamsWithStatData:(SNAppUsageStatData *)statData {
    NSString *startfrom = @"icon";
    if (statData.appLaunchingRefer == SNAppLaunchingRefer_iCon) {
        startfrom = @"icon";
    } else if (statData.appLaunchingRefer == SNAppLaunchingRefer_Push) {
        startfrom = @"push";
    } else {
        startfrom = @"other";
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:kUserStartAPPType forKey:@"objType"];
    [params setValue:[NSString stringWithFormat:@"%f",statData.lastTimeResigningTimeInSec*1000] forKey:@"lastetime"];
    [params setValue:[NSString stringWithFormat:@"%f",statData.launchingTimeInSec*1000] forKey:@"stime"];
    [params setValue:[NSString stringWithFormat:@"%f",statData.currentTimeResigningTimeInSec*1000] forKey:@"etime"];
    [params setValue:[NSString stringWithFormat:@"%f",statData.rollingNewsStayDurInSec*1000] forKey:@"inchannel"];
    [params setValue:[NSString stringWithFormat:@"%f",statData.videosStayDurInSec*1000] forKey:@"invedio"];
    [params setValue:[NSString stringWithFormat:@"%f",statData.myCenterStayDurInSec*1000] forKey:@"infriend"];
    [params setValue:[NSString stringWithFormat:@"%f",statData.newsContentStayDurInSec*1000] forKey:@"incontent"];
    [params setValue:startfrom forKey:@"startfrom"];

    return params.copy;
}


@end
