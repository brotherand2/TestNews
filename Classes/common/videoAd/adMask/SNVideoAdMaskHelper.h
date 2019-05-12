//
//  SNVideoAdMaskHelper.h
//  sohunews
//
//  Created by handy wang on 5/9/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoAdMask.h"

@class WSMVVideoPlayerView;
@class SNLiveRoomBannerVideoPlayerView;

@interface SNVideoAdMaskHelper : NSObject

/**
 *  在指定视频播放器里显示广告UE Mask
 *
 *  @param player 被指定的需要显示广告UE Mask的播放器
 *  @param adInfo 广告信息(URL形式的字符串)
 */
+ (void)showAdMaskInPlayer:(WSMVVideoPlayerView *)player withAdInfo:(id)adInfo;

/**
 *  从指定视频播放器里移除广告UE Mask
 *
 *  @param player 被指定的需要移除广告UE Mask的播放器
 */
+ (void)dismissMaskForPlayer:(WSMVVideoPlayerView *)player;

/**
 *  判断被Touch的UIView是不是SNVideoAdMask
 *
 *  @param touchedView 被touch的UIView
 *
 *  @return YES：表示被Touch的UIView是SNVideoAdMask，否则不是SNVideoAdMask
 */
+ (BOOL)doesTouchOnVideoAdMask:(UIView *)touchedView;

/**
 *  是否在指定的视频播放器显示全屏按钮
 *
 *  @param show YES:表示显示；NO:表示不显示
 *  @param player 指定的视频播放器
 */
+ (void)setShowFullscreenButton:(BOOL)show inVideoPlayer:(WSMVVideoPlayerView *)player;

/**
 *  根据播放器是否全屏的状态和更新全屏按钮显示的样式
 *
 *  @param player 播放器
 */
+ (void)updateFullscreenButtonStateInVideoPlayer:(WSMVVideoPlayerView *)player;

/**
 *  展开Live Banner视频播放器上的广告Mask
 *
 *  @param player Live Banner视频播放器
 */
+ (void)expandLiveBannerPlayerMask:(SNLiveRoomBannerVideoPlayerView *)player;

/**
 *  收起Live Banner视频播放器上的广告Mask
 *
 *  @param player Live Banner视频播放器
 */
+ (void)shrinkLiveBannerPlayerMask:(SNLiveRoomBannerVideoPlayerView *)player;

/**
 *  广告是否正在播放
 *
 *  @param player 视频播放器
 *
 *  @return YES:广告正在播放; NO:广告没有正在播放
 */
+ (BOOL)isAdPlayingInVideoPlayer:(WSMVVideoPlayerView *)player;

@end