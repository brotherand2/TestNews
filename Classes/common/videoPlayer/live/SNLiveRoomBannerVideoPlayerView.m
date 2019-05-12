//
//  SNLiveRoomBannerVideoPlayerView.m
//  sohunews
//
//  Created by handy wang on 3/19/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNLiveRoomBannerVideoPlayerView.h"
#import "SNLiveRoomBannerVideoPlayerTitleView.h"


static const CGFloat kDownloadBtnMarginLeft_FullScreen = 20/2.0f;

@implementation SNLiveRoomBannerVideoPlayerView

/**
 * 扩展：
 * 1）禁用推荐视频、相关视频、非全屏的手势切换视频功能
 * 2）全屏下不显示推荐按钮
 */
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate {
    if (self = [super initWithFrame:frame andDelegate:delegate]) {
        _canPlayByNotification = NO;
        
        //self.posterPlayBtn.top += 5.0f;
        
        self.isPlayingRecommendList = NO;
        self.supportRelativeVideosViewInNonFullscreenMode = NO;
        self.supportSwitchVideoByLRGestureInNonFullscreenMode = NO;
        self.isFromNewsContent = NO;
        
        self.poster.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.posterPlayBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self getMoviePlayer].view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.controlBarNonFullScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        self.controlBarNonFullScreen.fullscreenBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.controlBarNonFullScreen.progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        //Title view
        NSInteger titleViewIndex = [self.subviews indexOfObject:self.titleView];
        CGRect titleViewFrame = self.titleView.frame;
        self.titleView.delegate = nil;
        [self.titleView removeFromSuperview];
        
        self.titleView  = [[SNLiveRoomBannerVideoPlayerTitleView alloc] initWithFrame:titleViewFrame delegate:self];
        self.titleView.delegate = self;
        [self.titleView.recommendBtn removeFromSuperview];
        self.titleView.recommendBtn = nil;
        [self insertSubview:self.titleView atIndex:titleViewIndex];
        [self hideTitleAndControlBarWithAnimation:NO];
    }
    return self;
}

/**
 * 扩展：收起和展开非全屏视频控件时都会调.frame =，所以这时需要更新一下非全屏下progressBar内部的尺寸和坐标
 */
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self getMoviePlayer].view.frame = self.bounds;
    
    [self.titleView updateViewsInNonScreenMode];
    [self.controlBarNonFullScreen.progressBar updateSubviewsFrame];
}

/**
 * 扩展：不显示分享按钮、下一视频、上一视频按钮
 */
- (void)createFullScreenControllBar {
    [super createFullScreenControllBar];
    
    [self.controlBarFullScreen.shareBtn removeFromSuperview];
    self.controlBarFullScreen.shareBtn = nil;
    
    [self.controlBarFullScreen.previousVideoBtn removeFromSuperview];
    self.controlBarFullScreen.previousVideoBtn = nil;
    
    [self.controlBarFullScreen.nextVideoBtn removeFromSuperview];
    self.controlBarFullScreen.nextVideoBtn = nil;
    
    self.controlBarFullScreen.playBtn.left = kDownloadBtnMarginLeft_FullScreen;
//    self.controlBarFullScreen.playBtn.top =  (self.controlBarFullScreen.height - self.controlBarFullScreen.playBtn.height)/2.0f;
//    self.controlBarFullScreen.fullscreenBtn.top = (self.controlBarFullScreen.height - self.controlBarFullScreen.fullscreenBtn.height)/2.0f;
//    self.controlBarFullScreen.volumeBtn.top = (self.controlBarFullScreen.height - self.controlBarFullScreen.volumeBtn.height)/2.0f;
}

/**
 * 扩展：
 * 视频播放器收起进不显示非全屏的控制条、展开时再显示控制条
 */
- (void)removeControlBarTemporarily {
    self.controlBarNonFullScreen.hidden = YES;
}

- (void)addControlBarTemporarily {
    self.controlBarNonFullScreen.hidden = NO;
}

/**
 * 扩展：
 * 播放过程中或非播放过程中更新数据
 */
- (void)updateVideoModelIfChanged:(SNVideoData *)videoData {
    if (!videoData) {
        return;
    }
    
    SNVideoData *playingVideo = self.playingVideoModel;
    
    BOOL changed = NO;
    for (NSString *playingSource in playingVideo.sources) {
        for (NSString *newSource in videoData.sources) {
            if (![playingSource isEqual:newSource]) {
                changed = YES;
            }
        }
    }
    //lijian 2016.04.05 把vid赋值，如果有vid就用vid
    playingVideo.vid = videoData.vid;
    
    if (changed) {
        SNDebugLog(@"===Video model changed, updating video model...");
        BOOL _isPlaying = [self isPlaying];
        if (_isPlaying) {
            [self pause];
        }
        
        [self initPlaylist:[NSArray arrayWithObject:videoData] initPlayingIndex:0];

        if (_isPlaying) {
            [self playCurrentVideo];
        }
    }
    else {
        SNDebugLog(@"===Video model not changed, Dont update video model.");
    }
}

//---扩展功能：Banner播放器在手动暂停的情况下，不允许被其它非手动行为触发播放。
- (void)tapBannerViewToPlay {
    _canPlayByNotification = YES;
    [self playCurrentVideo];
}

- (void)tapBannerViewToPause {
    if ([self getMoviePlayer].advertCurrentPlayState == SHAdvertPlayStatePlaying) {
        return;
    }
    _canPlayByNotification = NO;
    [self pause];
}

- (void)didTapPlayBtnInPosterToPlay {
    //清除无效的Player
    if ([self.delegate respondsToSelector:@selector(clearOtherPlayer)]) {
        [self.delegate clearOtherPlayer];
    }
    
    self.moviePlayer.view.frame = self.bounds;
    _canPlayByNotification = YES;
    [self playCurrentVideo];
}

- (void)didTapPlayBtnInControlBarToPause {
    _canPlayByNotification = NO;
    [super didTapPlayBtnInControlBarToPause];
}

- (void)didTapPlayBtnInControlBarToPlay {
    _canPlayByNotification = YES;
    [super didTapPlayBtnInControlBarToPlay];
}

- (void)playCurrentVideo {
    if (!_canPlayByNotification) {
        return;
    }
    [super playCurrentVideo];
}
//---

/**
 * 扩展：如果没有处于播放状态就不用暂停
 */
- (void)pause {
    SNDebugLog(@"Trigger pause action...");
    
    if ([self isPlaying]) {
        [self showTitleAndControlBarWithAnimation:YES];
        [self.loadingMaskView stopLoadingViewAnimation];
        [[self getMoviePlayer] pause];
    }
}

/**
 * 扩展：暂停时显示播放器view中心的播放按钮
 */
- (void)videoDidPause {
    [super videoDidPause];
    
    //暂停时显示posterPlayBtn;
    if (![self isControlBarSliderHighlighted]) {
        self.posterPlayBtn.hidden = NO;
    }
}

@end
