//
//  SNTimelineSharedVideoPlayerView.m
//  sohunews
//
//  Created by handy wang on 11/23/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTimelineSharedVideoPlayerView.h"
#import "SNTimelineVideoTitleView.h"
#import "SNTimelineVideoControlBar+NonFullScreen.h"
#import "SNTimelineVideoControlBar+FullScreen.h"
#import "WSMVVideoStatisticManager.h"
#import "SNVideoBreakpointManager.h"
#import "SNVideoAdMaskHelper.h"

@interface SNTimelineBottomView_NonFullScreen : UIView

@property (nonatomic, strong)UILabel *siteNameLabel;
@property (nonatomic, strong)UILabel *durationLabel;
@end

@implementation SNTimelineBottomView_NonFullScreen

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //Site name label
        CGRect siteNameLabelFrame = CGRectMake(0, 0, self.width-kTimelineSiteNameAndDurationLRMarginToPosterLRSide, kTimelineSiteNameAndDurationHeight);
        _siteNameLabel = [[UILabel alloc] initWithFrame:siteNameLabelFrame];
        _siteNameLabel.left = kTimelineSiteNameAndDurationLRMarginToPosterLRSide;
        _siteNameLabel.bottom = self.height-kTimelineSiteNameAndDurationHeight;
        _siteNameLabel.backgroundColor = [UIColor clearColor];
        _siteNameLabel.textColor = [UIColor whiteColor];
        _siteNameLabel.textAlignment = NSTextAlignmentLeft;
        _siteNameLabel.font = [UIFont systemFontOfSize:kTimelineSiteNameAndDurationFontSize];
        [self addSubview:_siteNameLabel];
        
        //Duration label
        CGRect durationLabelFrame = CGRectMake(0, 0, self.width-kTimelineSiteNameAndDurationLRMarginToPosterLRSide, kTimelineSiteNameAndDurationHeight);
        _durationLabel = [[UILabel alloc] initWithFrame:durationLabelFrame];
        _durationLabel.right = self.width-kTimelineSiteNameAndDurationLRMarginToPosterLRSide;
        _durationLabel.bottom = self.height-kTimelineSiteNameAndDurationHeight;
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.font = [UIFont systemFontOfSize:kTimelineSiteNameAndDurationFontSize];
        [self addSubview:_durationLabel];
    }
    return self;
}


#pragma mark - Public
- (void)setSiteName:(NSString *)siteName duration:(NSString *)duration {
    self.siteNameLabel.text = siteName;
    self.durationLabel.text = duration;
}

@end

#define kControlBarHeight_fullscreen (94.0f/2.0f)

@interface SNTimelineSharedVideoPlayerView()

@property (nonatomic, strong)SNTimelineBottomView_NonFullScreen *bottomViewNonFullScreen;
@property (nonatomic, strong) NSTimer *hiddenTimer;

@end

@implementation SNTimelineSharedVideoPlayerView

#pragma mark - SharedInstance
+ (SNTimelineSharedVideoPlayerView *)sharedInstance {
    static SNTimelineSharedVideoPlayerView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect playerFrame =
        CGRectMake(kTimelineVideoCellSubContentViewsSideMargin,
                   kTimelineVideoCellSubContentViewsTopMargin,
                   kTimelineContentViewWidth,
                   kPlayerViewHeight);
        sharedInstance = [[SNTimelineSharedVideoPlayerView alloc] initWithFrame:playerFrame andDelegate:nil];
        sharedInstance.isPlayingRecommendList = YES;
        sharedInstance.isNewsVideo = NO;
        sharedInstance.isShowBarInNoFullScreen = NO;
    });
    return sharedInstance;
}

+ (void)fakeStop {
    [[WSMVVideoStatisticManager sharedIntance] statVideoSV];

    SNTimelineSharedVideoPlayerView *timelineVideoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
    NSString *breakPointKey = timelineVideoPlayer.playingVideoModel.vid ?: timelineVideoPlayer.playingVideoModel.siteInfo.siteId;
    [[SNVideoBreakpointManager sharedInstance] addBreakpointByVid:breakPointKey breakpoint:[timelineVideoPlayer getMoviePlayer].currentPlaybackTime];
    [timelineVideoPlayer pause];//用stop方法卡顿，用pause好一些
    if (nil != timelineVideoPlayer.playingVideoModel) {
        [timelineVideoPlayer statVV];
    }
    [timelineVideoPlayer resetModel];
    [timelineVideoPlayer removeFromSuperview];
    
    if ([[self sharedInstance].delegate respondsToSelector:@selector(didStopVideo:)]) {
        [[self sharedInstance].delegate didStopVideo:[self sharedInstance].playingVideoModel];
    }
    
    [timelineVideoPlayer performSelector:@selector(exitFullScreen)
                              withObject:nil afterDelay:0];
}

+ (void)forceStop {
    SNTimelineSharedVideoPlayerView *timelineVideoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
    NSString *breakPointKey = timelineVideoPlayer.playingVideoModel.vid ?: timelineVideoPlayer.playingVideoModel.siteInfo.siteId;
    [[SNVideoBreakpointManager sharedInstance] addBreakpointByVid:breakPointKey breakpoint:[timelineVideoPlayer getMoviePlayer].currentPlaybackTime];
    [timelineVideoPlayer forceStop];
    timelineVideoPlayer.pauseButton.hidden = YES;
    timelineVideoPlayer.voiceButton.hidden = YES;
    [timelineVideoPlayer clearMoviePlayerController];
    [timelineVideoPlayer resetModel];
    [timelineVideoPlayer removeFromSuperview];

    [timelineVideoPlayer performSelector:@selector(exitFullScreen)
                              withObject:nil afterDelay:0];
}

#pragma mark - Override
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate {
    if (self = [super initWithFrame:frame andDelegate:delegate]) {
        self.isEnableFullScreen = YES;
        self.supportSwitchVideoByLRGestureInNonFullscreenMode = NO;
        self.isFromNewsContent = NO;
        self.isFromAutoPlayVideo = NO;
        self.defaultLogo.left += 10;
        self.defaultLogo.top += 3;
        
        self.copyrightMsgView.delegate = nil;
        [self.copyrightMsgView removeFromSuperview];
        self.copyrightMsgView = nil;
        
        //Title view
        self.titleView.delegate = nil;
        [self.titleView removeFromSuperview];
        
        //Nonfullscreen controlBar
        NSInteger controlBarNonFullScreenIndex = [self.subviews indexOfObject:self.controlBarNonFullScreen];
        CGRect controlBarNonFullScreenFrame = self.controlBarNonFullScreen.frame;
        [self.controlBarNonFullScreen removeFromSuperview];
        self.controlBarNonFullScreen.delegate = nil;
        self.controlBarNonFullScreen = nil;
        
        self.controlBarNonFullScreen = [[SNTimelineVideoControlBar_NonFullScreen alloc] initWithFrame:controlBarNonFullScreenFrame];
        self.controlBarNonFullScreen.width = self.width;
        self.controlBarNonFullScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        self.controlBarNonFullScreen.delegate = nil;
        [self insertSubview:self.controlBarNonFullScreen atIndex:controlBarNonFullScreenIndex];
        
        //Bottom view(siteName & duration)
        CGRect bottomViewNonFullScreenFrame = self.controlBarNonFullScreen.frame;
        _bottomViewNonFullScreen = [[SNTimelineBottomView_NonFullScreen alloc] initWithFrame:bottomViewNonFullScreenFrame];
        [self addSubview:_bottomViewNonFullScreen];
    }
    return self;
}


#pragma mark -
- (void)createFullScreenControllBar {
    if (!(self.controlBarFullScreen)) {
        CGRect _controlBarFrameFullScreen =
        CGRectMake(0, CGRectGetHeight(self.bounds) - kControlBarHeight_fullscreen,
                   self.bounds.size.width, kControlBarHeight_fullscreen);
        self.controlBarFullScreen = [[SNTimelineVideoControlBar_FullScreen alloc] initWithFrame:_controlBarFrameFullScreen];

        self.controlBarFullScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        self.controlBarFullScreen.delegate = self;
        self.controlBarFullScreen.alpha = 0;
        [self addSubview:self.controlBarFullScreen];
    }
}

- (NSString *)posterURL {
    return self.playingVideoModel.poster_4_3;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIWindow *_currentWindow = [UIApplication sharedApplication].keyWindow;
    UIView *_touchedView = [_currentWindow hitTest:[touch locationInView:_currentWindow] withEvent:nil];
    SNDebugLog(@"_touchedView is %@", NSStringFromClass(_touchedView.class));
    
    //点击事件：只感知视频图像区域的TapGesture, 以显示或隐藏上下条；
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return (_touchedView == self);
    }
    //滑动事件：只感知视频图像区域的PanGesture，以切换上一个或下一个视频；
    else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        //不在视频图像区域：如果检测是在WSMVSlider上的PanGesture则忽略，因为WSMVSlider自己有拖动行为
        if ([_touchedView isKindOfClass:[WSMVSlider class]]) {
            return NO;
        } else {
            //全屏时可切换上一个或下一个视频；
            if ([self isFullScreen]) {
                return YES;
            }
            //非全屏时没有切换上一个或下一个视频的能力；
            else {
                return NO;
            }
        }
    } else {
        return YES;
    }
}

- (UIInterfaceOrientation)fullScreenOrientation {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        return UIInterfaceOrientationLandscapeRight;
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        return UIInterfaceOrientationLandscapeLeft;
    } else {
        return [super fullScreenOrientation];
    }
}

- (void)toFullScreen {
    if (self.isEnableFullScreen) {
        self.bottomViewNonFullScreen.alpha = 0;
        
        [super toFullScreen];
        
        if ([self getMoviePlayer].isLoadAdvert) {
            [SNVideoAdMaskHelper setShowFullscreenButton:YES
                                           inVideoPlayer:self];
        }
    }
}

- (void)exitFullScreen {
    BOOL wasFullscreen = [self isFullScreen];
    
    [super exitFullScreen];
    
    if ([self getMoviePlayer].volume == 1) {
        self.voiceButton.selected = YES;
    } else {
        self.voiceButton.selected = NO;
    }

    if ([self getMoviePlayer].playbackState == SHMoviePlayStateStopped) {
        self.posterPlayBtn.hidden = NO;
    }
    
    if (wasFullscreen && [self getMoviePlayer].isLoadAdvert) {
        [SNVideoAdMaskHelper setShowFullscreenButton:NO inVideoPlayer:self];
    }
}

- (void)stop {
    [super stop];
    [self showTitleAndControlBarWithAnimation:NO];
    [self hideNonFullScreenControlBar];
}

- (void)playCurrentVideo {
    //初始化视频Player, 修改尺寸
    self.moviePlayer.view.frame = self.bounds;
    
    [super playCurrentVideo];

    self.isPausedManually = NO;
    [self showTitleAndControlBarWithAnimation:YES];
}

- (void)didTapOnPlayerView:(UITapGestureRecognizer *)gestureRecognizer {
    if (![self isFullScreen]) {
        if ([self isLoading]) {
            [[self class] forceStop];
            self.isPausedManually = YES;
        } else if ([self isVideoPlayingExcludingAdPlaying]) {
            self.isPausedManually = YES;

            if (!_isNewsVideo) {
                [self createPauseAndVoiceView];
            } else {
                if (!self.isShowBarInNoFullScreen) {
                    NSInteger controlBarNonFullScreenIndex = [self.subviews indexOfObject:self.controlBarNonFullScreen];
                    CGRect controlBarNonFullScreenFrame = self.controlBarNonFullScreen.frame;
                    [self.controlBarNonFullScreen removeFromSuperview];
                    self.controlBarNonFullScreen.delegate = nil;
                    self.controlBarNonFullScreen = nil;
                    
                    self.controlBarNonFullScreen = [[WSMVVideoControlBar_NonFullScreen alloc] initWithFrame:controlBarNonFullScreenFrame];
                    self.controlBarNonFullScreen.width = self.width;
                    self.controlBarNonFullScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
                    self.controlBarNonFullScreen.delegate = self;
                    self.controlBarNonFullScreen.downloadBtn.hidden = YES;
                    self.controlBarNonFullScreen.downloadBtn.alpha = 0;
                    [self.controlBarNonFullScreen setPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Playing];
                    [self insertSubview:self.controlBarNonFullScreen atIndex:controlBarNonFullScreenIndex];
                    [self showTitleAndControlBarWithAnimation:YES];
                    self.isShowBarInNoFullScreen = YES;
                     [self.controlBarNonFullScreen disableDownload];
                } else {
                    NSInteger controlBarNonFullScreenIndex = [self.subviews indexOfObject:self.controlBarNonFullScreen];
                    CGRect controlBarNonFullScreenFrame = self.controlBarNonFullScreen.frame;
                    [self.controlBarNonFullScreen removeFromSuperview];
                    self.controlBarNonFullScreen.delegate = nil;
                    self.controlBarNonFullScreen = nil;
                    
                    self.controlBarNonFullScreen = [[SNTimelineVideoControlBar_NonFullScreen alloc] initWithFrame:controlBarNonFullScreenFrame];
                    self.controlBarNonFullScreen.width = self.width;
                    self.controlBarNonFullScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
                    self.controlBarNonFullScreen.delegate = nil;
                    self.controlBarNonFullScreen.downloadBtn.hidden = YES;
                    [self.controlBarNonFullScreen setPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Playing];
                    [self insertSubview:self.controlBarNonFullScreen atIndex:controlBarNonFullScreenIndex];
                    self.isShowBarInNoFullScreen = NO;
                    [self.controlBarNonFullScreen disableDownload];
                }
            }
        } else if (![self isPlaying]) {
//            self.isPausedManually = NO;
//            [self playCurrentVideo];
        }
    } else {
        if (self.isPureMode) {
            [self showTitleAndControlBarWithAnimation:YES];
        }
        else {
            [self hideTitleAndControlBarWithAnimation:YES];
        }
    }
}

- (void)createPauseAndVoiceView {
    if (!_pauseButton) {
        self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.pauseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.pauseButton.backgroundColor = [UIColor clearColor];
        self.pauseButton.frame = CGRectMake(0, 0, 46, 46);
        self.pauseButton.center = self.poster.center;
        [self.pauseButton setImage:[UIImage imageNamed:@"iconome_suspend_v5.png"] forState:UIControlStateNormal];
        [self.pauseButton addTarget:self action:@selector(clickPauseButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.pauseButton];
        
        self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.voiceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.voiceButton.backgroundColor = [UIColor clearColor];
        self.voiceButton.frame = CGRectMake(0, 0, 33, 33);//13*13
        self.voiceButton.bottom = self.bounds.size.height;
        self.voiceButton.right = self.bounds.size.width - 4/2;
        [self.voiceButton setImage:[UIImage imageNamed:@"iconome_mute_v5.png"] forState:UIControlStateNormal];
        [self.voiceButton setImage:[UIImage imageNamed:@"iconome_volume_v5.png"] forState:UIControlStateSelected];
        [self.voiceButton addTarget:self action:@selector(clickVoiceButton) forControlEvents:UIControlEventTouchUpInside];
        if ([self getMoviePlayer].volume == 1) {
            self.voiceButton.selected = YES;
        } else {
            self.voiceButton.selected = NO;
        }
        [self addSubview:self.voiceButton];
        self.hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(buttonHidden) userInfo:nil repeats:NO];
        
    } else {
        [self.pauseButton setImage:[UIImage imageNamed:@"iconome_suspend_v5.png"] forState:UIControlStateNormal];
        [self.voiceButton setImage:[UIImage imageNamed:@"iconome_mute_v5.png"] forState:UIControlStateNormal];
        [self.voiceButton setImage:[UIImage imageNamed:@"iconome_volume_v5.png"] forState:UIControlStateSelected];
        if (self.pauseButton.hidden == NO) {
            self.pauseButton.hidden = YES;
            self.voiceButton.hidden = YES;
            [self timefire];
            
        } else {
            self.pauseButton.hidden = NO;
            self.voiceButton.hidden = NO;
            if ([self getMoviePlayer].volume == 1) {
                self.voiceButton.selected = YES;
            } else {
                self.voiceButton.selected = NO;
            }
            self.hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(buttonHidden) userInfo:nil repeats:NO];
        }
    }
}

- (void)clickPauseButton {
    self.playingVideoModel.isActivePause = YES;
    self.pauseButton.hidden = YES;
    self.voiceButton.hidden = YES;
    [self timefire];
    [self pause];
    self.bottomViewNonFullScreen.alpha = 1;
    
}

- (void)clickVoiceButton {
    self.voiceButton.selected = !self.voiceButton.selected;
    if (self.voiceButton.selected) {
        [self getMoviePlayer].volume = 1;
    } else {
        [self getMoviePlayer].volume = 0;
    }
}

- (void)buttonHidden {
    self.pauseButton.hidden = YES;
    self.voiceButton.hidden = YES;
}

- (void)timefire {
    if (_hiddenTimer && [_hiddenTimer isValid]) {
        TT_INVALIDATE_TIMER(self.hiddenTimer);
    }
}

- (void)didTapPlayBtnInControlBarToPlay {
    [super didTapPlayBtnInControlBarToPlay];
    self.isPausedManually = NO;
}

- (void)didTapPlayBtnInControlBarToPause {
    [super didTapPlayBtnInControlBarToPause];
    
    self.isPausedManually = YES;
}

- (BOOL)shouldShowTitleAndControlBarBeforePlayNextVideo {
    return YES;
}

- (void)videoDidPlay {
    [super videoDidPlay];
    self.posterPlayBtn.frame = CGRectMake(0, 0, 46, 46);
    self.posterPlayBtn.center = self.poster.center;
    BOOL isAutoPlay = [[NSUserDefaults standardUserDefaults] boolForKey:@"kIsAutoPlay"];
    
    if (isAutoPlay) {
        [self getMoviePlayer].volume = 0;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kIsAutoPlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (self.isFullScreen) {
        SNTimelineVideoControlBar_FullScreen *videoControlBar = (SNTimelineVideoControlBar_FullScreen *)self.controlBarFullScreen;
        if (!videoControlBar.volumeBtn1.selected) {
            [self getMoviePlayer].volume = 0;
        }
    }
    
    self.pauseButton.hidden = YES;
    self.voiceButton.hidden = YES;
    
    if (!(self.isPureMode) && ![self isFullScreen]) {
        self.controlBarNonFullScreen.alpha = 1;
    }
}

- (void)playVideo {
    [super playVideo];
    self.posterPlayBtn.frame = CGRectMake(0, 0, 46, 46);
    self.posterPlayBtn.center = self.poster.center;
}

- (void)noNextVideoToPlay {
    [super noNextVideoToPlay];
    
    [self showTitleAndControlBarWithAnimation:YES];
    [self hideNonFullScreenControlBar];
    
    if (![self isFullScreen]) {
        self.bottomViewNonFullScreen.alpha = 1;        
    }
}

- (void)videoDidPause {
    [super videoDidPause];
    
    //非全屏模式下点视频区域暂停时显示posterPlayBtn;
    if (![self isControlBarSliderHighlighted] && ![self isFullScreen]) {
        self.posterPlayBtn.hidden = NO;
    }
}

- (void)doEnterPureMode {
    [UIView animateWithDuration:0.2 animations:^{
        if (!(self.pureModeTimer) || ![self.pureModeTimer isValid]) {
            SNDebugLog(@"Give up entering pure mode, because pureModeTimer did been invalided.");
            return;
        }
        
        SNDebugLog(@"Entering pure mode...");
        self.titleView.alpha = 0;
        [self hideVolumnBarMask];
        self.controlBarFullScreen.alpha = 0;
        self.bottomViewNonFullScreen.alpha = 0;
    } completion:^(BOOL finished) {
        if (!(self.pureModeTimer) || ![self.pureModeTimer isValid]) {
            SNDebugLog(@"Didnt enter pure mode.");
            return;
        }
        
        self.enterPureModeFinished = YES;
        self.isPureMode = (self.titleView.alpha == 0);
        SNDebugLog(@"Did enter pure mode now.");
    }];
}

- (void)updateViewsInFullScreenMode {
    [super updateViewsInFullScreenMode];
    
    self.posterPlayBtn.hidden = YES;
    self.pauseButton.hidden = YES;
    self.voiceButton.hidden = YES;
}

- (void)updateViewsInNonScreenMode {
    [super updateViewsInNonScreenMode];
    
    [self updatePlaybackProgress];
    
    self.controlBarNonFullScreen.alpha = 1;
    
    if ([self isLoading]) {
        self.posterPlayBtn.hidden = YES;
    } else if ([self isPaused]) {
        self.posterPlayBtn.hidden = NO;
    } else if ([self isStopped]) {
        self.posterPlayBtn.hidden = NO;
        [self hideNonFullScreenControlBar];
    } else {
        self.posterPlayBtn.hidden = YES;
    }
    
    if (!(self.isPureMode)) {
        self.bottomViewNonFullScreen.alpha = 1;
    } else {
        self.bottomViewNonFullScreen.alpha = 0;
    }
}

- (void)updateTextAfterModelChanged {
    [super updateTextAfterModelChanged];
    
    if (![self isFullScreen]) {
        self.bottomViewNonFullScreen.alpha = 1;
    }
    
    NSString *durationText = [SNUtility getHumanReadableTime:self.playingVideoModel.duration];
    [self.bottomViewNonFullScreen setSiteName:[self getSiteName] duration:durationText];
    
    if (self.playingVideoModel.duration <= 0) {
        self.bottomViewNonFullScreen.hidden = YES;
    } else {
        self.bottomViewNonFullScreen.hidden = NO;
    }
}

#pragma mark - Override - Ad Delegate
- (void)didGetAdInfo:(id)adInfo {
    [super didGetAdInfo:adInfo];
    
    if ([self getMoviePlayer].isLoadAdvert &&
        [adInfo isKindOfClass:[NSString class]]) {
        self.bottomViewNonFullScreen.alpha = 0;
        
        if ([self isFullScreen]) {
            [SNVideoAdMaskHelper setShowFullscreenButton:YES inVideoPlayer:self];
        } else {
            [SNVideoAdMaskHelper setShowFullscreenButton:NO inVideoPlayer:self];
        }
        [SNVideoAdMaskHelper updateFullscreenButtonStateInVideoPlayer:self];
    }
}

- (void)adDidFinishPlaying {
    [super adDidFinishPlaying];
    
    if ([self getMoviePlayer].isLoadAdvert) {
        if ([self isFullScreen]) {
            self.bottomViewNonFullScreen.alpha = 0;
        } else {
            self.bottomViewNonFullScreen.alpha = 1;
        }
    }
}

- (void)adDidPlayWithError {
    [super adDidPlayWithError];
    
    if ([self getMoviePlayer].isLoadAdvert) {
        if ([self isFullScreen]) {
            self.bottomViewNonFullScreen.alpha = 0;
        } else {
            self.bottomViewNonFullScreen.alpha = 1;
        }
    }
}

#pragma mark - Public
- (void)hideNonFullScreenControlBar {
    self.controlBarNonFullScreen.alpha = 0;
}

- (void)replaceAllPlaylist:(NSArray *)videos {
    [self.playlist removeAllObjects];
    
    if (videos.count > 0) {
        [self.playlist addObjectsFromArray:videos];
    }
}

@end
