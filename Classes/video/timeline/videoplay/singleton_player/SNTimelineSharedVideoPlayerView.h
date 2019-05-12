//
//  SNTimelineSharedVideoPlayerView.h
//  sohunews
//
//  Created by handy wang on 11/23/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "WSMVVideoPlayerView.h"

@interface SNTimelineSharedVideoPlayerView : WSMVVideoPlayerView
@property(nonatomic, assign) BOOL isEnableFullScreen;
//李健 2015.01.25 替代kTimelineVideoPausedManually的设定，
//不应该写文件，因为该设置只针对于
@property(nonatomic, assign) BOOL isPausedManually;
@property(nonatomic, assign) BOOL isNewsVideo;
//崔亮亮 用于非全屏时 显示状态栏
@property(nonatomic, assign) BOOL isShowBarInNoFullScreen;

@property (nonatomic, strong)UIButton *pauseButton;
@property (nonatomic, strong)UIButton *voiceButton;

#pragma mark - SharedInstance
+ (SNTimelineSharedVideoPlayerView *)sharedInstance;
+ (void)fakeStop;
+ (void)forceStop;

#pragma mark - Public methods
- (void)hideNonFullScreenControlBar;
- (void)replaceAllPlaylist:(NSArray *)videos;
@end

@protocol SNTimelineSharedVideoPlayerViewDelegate
- (void)didStopVideo:(SNVideoData *)video;
@end

