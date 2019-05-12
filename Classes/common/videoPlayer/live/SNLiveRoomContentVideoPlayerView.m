//
//  SNLiveRoomContentVideoPlayerView.m
//  sohunews
//
//  Created by handy wang on 3/20/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNLiveRoomContentVideoPlayerView.h"

static const CGFloat kDownloadBtnMarginLeft_FullScreen = 20/2.0f;

@implementation SNLiveRoomContentVideoPlayerView

/**
 * 扩展：
 * 1）禁用推荐视频、相关视频、非全屏的手势切换视频功能
 * 2）全屏下不显示推荐按钮
 */
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate {
    if (self = [super initWithFrame:frame andDelegate:delegate]) {
        self.posterPlayBtn.top += 5.0f;
        
        self.isPlayingRecommendList = NO;
        self.supportRelativeVideosViewInNonFullscreenMode = NO;
        self.supportSwitchVideoByLRGestureInNonFullscreenMode = NO;
        self.isFromNewsContent = NO;
        
        [self.titleView.recommendBtn removeFromSuperview];
        self.titleView.recommendBtn = nil;
        
        [self hideTitleAndControlBarWithAnimation:NO];
    }
    return self;
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
}

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

@end
