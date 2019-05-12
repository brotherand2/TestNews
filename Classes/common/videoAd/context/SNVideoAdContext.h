//
//  SNVideoAdContext.h
//  sohunews
//
//  Created by handy wang on 5/6/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoAdContextConst.h"
#import "SNStatisticsConst.h"

@interface SNVideoAdContext : NSObject

#pragma mark - Public
/**
*  获取SNVideoAdContext类的单实例
*
*  @return SNVideoAdContext类的单实例
*/
+ (instancetype)sharedInstance;

/**
 *  记录App当前处于哪个tab item
 *
 *  @param selectedTabIndex 当前选中的tab item index
 */
- (void)setCurrentTabIndex:(NSInteger)selectedTabIndex;

/**
 *  获取当前tab枚举值
 *
 *  @return SNBusinessStatisticsObjFrom  当前tab对应的枚举值
 */
- (SNBusinessStatisticsObjFrom)getObjFromForExpsGif;

/**
 *  获取App当前处于哪个tab item
 *
 *  @return App当前所在tab item
 */
- (NSString *)getObjFromForCDotGif;

/**
 *  当前是"新闻"Tab，则返回所在频道channelId
 *  当前是"视频"Tab，则返回所在频道channelId
 *  当前是"订阅"Tab，则返回所在刊物的subId
 *
 *  @return 相应的id
 */
- (NSString *)getObjFromIdForCDotGif;

/**
 *  根据当前所在的tab来对应设置当前tab所打开的频道
 *
 *  @param channelID 频道ID
 */
- (void)setCurrentChannelID:(NSString *)channelID;

/**
 *  获取新闻Tab或视频Tab里的当前channelID
 *
 *  @return 新闻Tab或视频Tab里的当前channelID
 */
- (NSString *)getCurrentChannelID;

/**
 *  计算视频播放器是否需要加载广告
 *
 *  @return YES:视频播放器需要加载广告， NO:视频播放器不需要加载广告
 */
- (BOOL)doesVideoPlayerNeedLoadAd;

#pragma mark -
/**
 *  记录视频播放器里的视频广告播放的广告位(即在哪个业务场景页面播放)，这决定了视频广告UE Mask的样式
 *
 *  @param currentVideoAdPosition 广告位(即在哪个业务场景页面播放)
 */
- (void)setCurrentVideoAdPosition:(SNVideoAdContextCurrentVideoAdPosition)currentVideoAdPosition;

/**
 *  获取视频播放器里的视频广告播放的广告位(即在哪个业务场景页面播放)
 *
 *  @return 广告位位置
 */
- (SNVideoAdContextCurrentVideoAdPosition)getCurrerntVideoAdPosition;

/**
 *  获取当前TabID和ChannelID的路径
 *
 *  @return 当前TabID和ChannelID的路径
 */
- (NSString *)getAdTrace;

- (SNVideoAdContextCurrentTabValue)getCurrentTab;

@end