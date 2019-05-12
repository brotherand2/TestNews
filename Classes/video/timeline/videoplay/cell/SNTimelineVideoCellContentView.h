//
//  SNTimelineVideoCellContentView.h
//  sohunews
//
//  Created by handy wang on 11/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideoObjects.h"

@interface SNTimelineVideoCellContentView : UIView
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) SNVideoData *object;
@property (nonatomic, assign) BOOL isAdVideo;
@property (nonatomic, assign) BOOL isToFullScreen;

- (void)setObject:(SNVideoData *)item;
- (void)updateFullscreenBtn;
- (void)updateDownloadBtn;

- (void)playVideoIfNeeded;
- (void)playVideoIfNeededIn2G3G;
- (void)stopVideoPlayIfPlaying;
- (BOOL)isFullScreen;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isLoading;
- (void)videoToFullScreen;
- (void)videoExitFullScreen;
- (void)didPlayToEnd;

//李健 2014.12.30 增加新闻流模板视频广告
- (void)resetPlayerViewFrame:(CGRect)frame hiddenBottom:(BOOL)hidden;
- (void)fullscreenAction:(UIButton *)fullscreenBtn;
- (void)pause;
- (void)playVideoManually;
- (void)autoPlayVideo;
@end

@protocol SNTimelineVideoCellContentViewDelegate
@optional
- (void)toVideoDetailPage:(SNVideoData *)videoItem;
- (BOOL)isTableViewControllerLoading;
- (BOOL)isVideoTimelineVisiable;

- (void)clickPlayButton:(SNVideoData *)data;

- (void)enterToFullScreen;
- (void)exitFullScreen;
@end
