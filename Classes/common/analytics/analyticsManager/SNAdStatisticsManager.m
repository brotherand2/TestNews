//
//  SNAdStatisticsManager.m
//  sohunews
//
//  Created by jialei on 14-8-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//  向广告SDK上报统计参数

#import "SNAdStatisticsManager.h"
#import "SNStatTypeObject.h"

@implementation SNAdStatisticsManager

static SNAdStatisticsManager *__instance = nil;

+ (SNAdStatisticsManager *)shareInstance
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        __instance = [[SNAdStatisticsManager alloc] init];
    });
    return __instance;
}
#pragma mark - Singleton
- (id)init {
    if (__instance) {
        return __instance;
    }
    if(self = [super init]) {
    }
    
    return self;
}

- (void)uploadAdSDKParamEventSync:(SNStatInfo *)statInfo
{
    if (!statInfo) {
        return;
    }
    //调试用：
//    SNDebugLog(@"apid = %@",statInfo.itemspaceid);

    // 和于和琪BOSS商定，以后缓存的不再报了  by Cae.
    if (statInfo.isReported && STADDisplayTrackTypeClick != statInfo.adTrackType && STADDisplayTrackTypePlaying != statInfo.adTrackType)
    {
        return ;
    }
    
    Class statTypeObjClass = [SNStatTypeObject classForStatisticsType:statInfo.objLabel];
    SNStatTypeObject *statTypeObj = [[statTypeObjClass alloc] initWithStateInfo:statInfo];
    if (statTypeObj) {
        [statTypeObj uploadAdServerEvent];
    }
}

- (void)uploadAdSDKParamEvent:(SNStatInfo *)statInfo
{
    if (!statInfo) {
        return;
    }
    //调试用：
//    SNDebugLog(@"apid = %@ *** %ld",statInfo.itemspaceid,(long)statInfo.adTrackType);
    
    /**
     * #bug 第一次启动会多报一个流内4位置的av，原因是tableView的代理方法多调用了一次导致。
     */
    if (statInfo.adTrackType == STADDisplayTrackTypeImp && [statInfo.position isEqualToString:@"4"] && [statInfo.newsChannelId isEqualToString:@"0"]) {
        return;
    }
    // 和于和琪BOSS商定，以后缓存的不再报了  by Cae.
    if (statInfo.isReported && STADDisplayTrackTypeClick != statInfo.adTrackType && STADDisplayTrackTypePlaying != statInfo.adTrackType && STADDisplayTrackTypeTelImp != statInfo.adTrackType)
    {
        return ;
    }
    
    Class statTypeObjClass = [SNStatTypeObject classForStatisticsType:statInfo.objLabel];
    SNStatTypeObject *statTypeObj = [[statTypeObjClass alloc] initWithStateInfo:statInfo];
    if (statTypeObj) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [statTypeObj uploadAdServerEvent];
        });
    }
}

@end
