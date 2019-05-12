//
//  WSMVVideoStatisticManager.h
//  sohunews
//
//  Created by handy wang on 10/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSMVVideoStatisticModel.h"
@class WSMVVideoPlayerView;

#define kWSMVVideoPlayerActionStat_Pause                            (@"ps")//暂停
#define kWSMVVideoPlayerActionStat_Play                             (@"py")//播放
#define kWSMVVideoPlayerActionStat_Forward                          (@"fd")//快进(拖动进度条)
#define kWSMVVideoPlayerActionStat_Backward                         (@"bd")//快退(拖动进度条)
#define kWSMVVideoPlayerActionStat_Fullscreen                       (@"fs")//全屏
#define kWSMVVideoPlayerActionStat_Recommend                        (@"rcm")//全屏时点右上角的栏目按钮
#define kWSMVVideoPlayerActionStat_Download                         (@"dwn")//下载按钮

@interface WSMVVideoStatisticManager : NSObject

#pragma mark - Instance method
+ (WSMVVideoStatisticManager *)sharedIntance;

#pragma mark - Public
//PV统计
- (void)statVideoPV:(WSMVVideoStatisticModel *)statisticModel;
//
- (void)statNewVideoPV:(WSMVVideoStatisticModel *)statisticModel;
//VV统计
- (void)statVideoVV:(WSMVVideoStatisticModel *)statisticModel inVideoPlayer:(WSMVVideoPlayerView *)videoPlayer;
//
- (void)statNewVideoVV:(WSMVVideoStatisticModel *)statisticModel;

- (void)statNewVideoLoad:(WSMVVideoStatisticModel *)statisticModel;

//SV统计
- (void)cacheVideoSV:(WSMVVideoStatisticModel *)statisticModel;
- (void)statVideoSV;

//播放器行为统计
- (void)statVideoPlayerActions:(WSMVVideoStatisticModel *)statisticModel actionsData:(NSMutableDictionary *)actionData;

#pragma mark - FFL统计
//FFL stands for FIRST FRAME LOAING。

/**
 *  缓存加载视频第一帧的时间(毫秒)到Manager里
 *
 *  @param fflTimeCostInMilliseconds 加载视频第一帧的时间(毫秒)
 */
- (void)cacheFFLTimeCost:(NSTimeInterval)fflTimeCostInMilliseconds;

//视频第一帧缓冲统计, FFL stands for FIRST FRAME LOAING。缓冲成功或失败都要统计
- (void)statFFL:(WSMVVideoStatisticModel *)statisticModel;

#pragma mark - 视频广告统计
//广告加载上报
- (void)statVideoAdLoad:(id)statData;

//广告VV上报
- (void)statVideoAdVV:(id)statData;

//广告点击上报
- (void)statVideoAdClick:(id)statData;

#pragma mark - 视频Tab中行为统计
// 点击视频tab右上角 频道按钮
- (void)videoFireChannelsActionStatistic;

// 点击进入热播管理
- (void)videoFireHotColumnsActionStatistic;

// 点击添加或者取消某个热播栏目
- (void)videoFireHotColumnsSubActionStatisticWithActionData:(NSDictionary *)actionData;

//第一个pgc视频暂停，退出视频正文上报
- (void)pgcVideoStaticWithType:(NSString *)type model:(WSMVVideoStatisticModel *)model;

@end
