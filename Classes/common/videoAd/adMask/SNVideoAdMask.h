//
//  SNVideoAdMask.h
//  sohunews
//
//  Created by handy wang on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideoAdDetailInfo.h"
#import "WSMVVideoPlayerView.h"

typedef NS_ENUM(NSInteger, SNVideoAdMaskType) {
    SNVideoAdMaskType_Normal,
    SNVideoAdMaskType_LiveBanner
};

@interface SNVideoAdMask : UIView
@property(nonatomic, assign) SNVideoAdMaskType videoAdMaskType;

/**
 *  Private Methods for overriding
 */
- (void)o_willFinishInitSubviews;
- (void)o_willFinishLayoutSubviews;
- (void)o_didUpdateCountdownSecondsValue:(NSTimeInterval)leftSeconds;

/**
 *  SNVideoAdMask的工厂方法
 *
 *  @param type 样式类型
 *
 *  @return SNVideoAdMask子类的实例
 */
+ (SNVideoAdMask *)maskWithType:(SNVideoAdMaskType)type;

/**
 *  Mask即将显示
 */
- (void)maskWillAppearInVideoPlayer:(WSMVVideoPlayerView *)videoPlayer;

/**
 *  开始在指定视频播放器里倒计时
 *
 *  @param videoPlayer 指定视频播放器
 */
- (void)startCountdownInVideoPlayer:(WSMVVideoPlayerView *)videoPlayer;

/**
 *  停止倒计时
 */
- (void)stopCountdown;

/**
 *  在mask内部记录一个当前的音量，以便静音后再恢复音量时可恢复到之前的音量
 *
 *  @param systemVolume 记录当前音量
 */
- (void)updateLastSystemVolume:(Float32)systemVolume;

/**
 *  因为在播放广告过程中，可能设备已被静音，所以当广告播完或播放过程中被stop时，需要提供这么一个方法给视频播放器以恢复之前的音量
 */
- (void)resumeAppVolumeIfNeeded;

/**
 *  设置视频广告详情信息
 *
 *  @param videoAdDetailInfo 视频广告详情信息
 */
- (void)setVideoAdDetailInfo:(SNVideoAdDetailInfo *)videoAdDetailInfo;

/**
 *  获取视频广告详情信息
 *
 *  @return 视频广告详情信息
 */
- (SNVideoAdDetailInfo *)getVideoAdDetailInfo;

/**
 *  是否显示全屏按钮
 *
 *  @param show YES:表示显示；NO:表示不显示
 */
- (void)setShowFullscreenButton:(BOOL)show;

/**
 *  根据是否全屏的状态和更新全屏按钮显示的样式
 *
 *  @param isFullscreen 是否全屏状态，YES:播放器当前处于全屏状态；NO:播放器当前处于非全屏状态
 */
- (void)updateFullscreenButtonState:(BOOL)isFullscreen;

/**
 *  隐藏Mask里的header和footer
 */
- (void)hideHeaderAndFooter;

/**
 *  显示Mask里的header和footer
 */
- (void)showHeaderAndFooter;

@end