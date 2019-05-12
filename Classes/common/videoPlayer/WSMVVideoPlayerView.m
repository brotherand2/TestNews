//
//  WSMVVideoPlayerView.m
//  WeSee
//
//  Created by handy wang on 8/14/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoPlayerView.h"
#import "UIViewAdditions+WSMV.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WSMVVideoPlayerViewObserver.h"
#import "WSMVSlider.h"
#import "WSMVRecommendVideosView.h"
#import "WSMVStopWatch.h"
#import "WSMVRelativeVideosView.h"
#import "WSMVVideoStatisticManager.h"
#import "SNVideoBreakpointManager.h"
#import "SNMyFavouriteManager.h"
#import "SNVideoDownloadManager.h"
#import "SNDBManager.h"
#import "SNCheckManager.h"
#import "WSMVVideoPlayerConst.h"
#import "SNVideoAdContext.h"
#import "SNVideoAdMaskHelper.h"
#import "SNVideoAdMaskConst.h"
#import "SNStatisticsManager.h"
#import "SNTimelineVideoCellContentView.h"
#import "SNRollingNewsViewController.h"
#import "SNVideosViewController.h"
#import "SNTripletsLoadingView.h"
#import "SNSoundManager.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNTimelineVideoControlBar+FullScreen.h"
#import "SNADVideoCellAudioSession.h" //wangshun 广告视频 声音静音 打断问题 2017.6.21
#import "SNVideoRetryRequest.h" //@qz 播放有问题，发送重试请求看是否有必要切换siteId重新播放
#import "SNVideoReportRequest.h"
#define kControlBarHeight_nonfullscreen             (78.0f/2.0f)
#define kControlBarHeight_fullscreen                (94.0f/2.0f)
#define kControlBarHeight_smallscreen               (4.0f/2.0f)

#define kThumbnailBtnWidth                          (64.0f)
#define kThumbnailBtnHeight                         (64.0f)

#define kTitleViewHeight_NonFullScreen              (100.0f/2.0f)
#define kTitleViewHeight_FullScreen                 (100.0f/2.0f)

#define kVolumnBarPaddingBottomToVolumnBtnBottom    (60/2.0f)

static NSString *kVideoIDOfLastPlayingFail = @"kVideoIDOfLastPlayingFail";

void WSMVVideoPlayerViewAudioVolumeChangeListenerCallback
(void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue) {
    if (inPropertyID != kAudioSessionProperty_CurrentHardwareOutputVolume) {
        return;
    }
    Float32 value = *(Float32 *)inPropertyValue;
    WSMVVideoPlayerView *_playerView = (__bridge WSMVVideoPlayerView *)inUserData;
    WSMVVideoVolumnBar *_volumnBar = _playerView.volumnBarMask.volumnBar;
    [_volumnBar.slider assignProgressValue:value];
    
    if (value <= 0) {
        [_playerView.controlBarFullScreen.volumeBtn setBackgroundImage:[UIImage imageNamed:@"wsmv_volumn_mute.png"] forState:UIControlStateNormal];
    } else {
        [_playerView.controlBarFullScreen.volumeBtn setBackgroundImage:[UIImage imageNamed:@"wsmv_volumn.png"] forState:UIControlStateNormal];
    }
}

@interface WSMVVideoPlayerView()
@property (nonatomic, strong) WSMVVideoPlayerViewObserver *observer;
@property (nonatomic, assign) NSInteger                   currentVideoSegmentIndex;
@property (nonatomic, strong) NSTimer                     *playbackTimeTimer;
@property (nonatomic, strong) UIView                      *parentView;
@property (nonatomic, assign) CGRect                      nonFullScreenFrame;
@property (nonatomic, strong) NSMutableDictionary         *thumbnailsOfSegments;
@property (nonatomic, strong) WSMVRecommendVideosView     *recommendVideosView;
@property (nonatomic, assign) BOOL                        isAllVideoSegmentsFinished;
@property (nonatomic, strong) UITapGestureRecognizer      *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer      *panGestureRecognizer;
@property (nonatomic, weak) UIWindow                    *tmpKeyWindow;
@property (nonatomic, assign) NSInteger selfIndexInSuperViewOfNonFullScreen;
@property (nonatomic, assign) BOOL                        isFullscreenAnimating;
@property (nonatomic, assign) BOOL                        isFullScreenModel;
@property (nonatomic, strong) NSMutableArray*   retryedVidArray;//@qz 如果当前类能播放多个视频，用这个来判断某个vid是不是已经发送过retry接口
@property (nonatomic, strong) NSMutableArray*   reportedVidArray;//@qz 如果当前类能播放多个视频，用这个来判断某个vid是不是已经发送过report接口
@property (nonatomic, assign) BOOL    isRetryLoading;
@end

@implementation WSMVVideoPlayerView
@synthesize moviePlayer = _moviePlayer;

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.thumbnailsOfSegments = [NSMutableDictionary dictionary];
        self.playerActionsStatData = [NSMutableDictionary dictionary];
        
        [SNNotificationManager addObserver:self selector:@selector(handleExitFullScreenNofiticaion:) name:kNotifyDidHandled object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handlePauseVideoNofiticaion:) name:kSNPlayerViewPauseVideoNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleStopVideoNofiticaion:) name:kSNPlayerViewStopVideoNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleReachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleSupportVideoDownloadValueChangedNotification:) name:kSupportVideoDownloadValueChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleSNVideoAdMaskShowVideoAdDetailNotification:) name:kSNVideoAdMaskShowVideoAdDetailNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleSNVideoAdMaskEnterOrExitFullscreenNotification:) name:kSNVideoAdMaskEnterOrExitFullscreenNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleThemeDidChangeNotification:) name:kThemeDidChangeNotification object:nil];

        [SNNotificationManager addObserver:self selector:@selector(onReceiveNotifyToBack) name:kNotifyExpressShow object:nil];

        self.isPlayingRecommendList = NO;
        self.isFromAutoPlayVideo = NO;
        self.isFullScreenModel = NO;
        self.supportSwitchVideoByLRGestureInNonFullscreenMode = YES;
        self.supportRelativeVideosViewInNonFullscreenMode = NO;
        self.playlist = [NSMutableArray array];
        self.retryedVidArray = [NSMutableArray array];
        self.reportedVidArray = [NSMutableArray array];
        //Poster
        self.poster = [[SNWebImageView alloc] initWithFrame:self.bounds];
        self.poster.contentMode = UIViewContentModeScaleAspectFill;
        self.poster.clipsToBounds = YES;
        self.poster.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.poster.backgroundColor = [self isFullScreen] ? [UIColor blackColor] : kVideoPlayerPosterBgColor();
        self.poster.userInteractionEnabled = NO;
        [self addSubview:self.poster];
        

        //default logo
        self.defaultLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 140.f, 38.f)];

        self.defaultLogo.image = [self isFullScreen] ? [UIImage imageNamed:@"videoplayer_fullscreen_posterlogo.png"] : [UIImage imageNamed:@"videoplayer_nonfullscreen_posterlogo.png"];
        self.defaultLogo.size = [self isFullScreen] ? CGSizeMake(164.f, 80.f) : CGSizeMake(140.f, 38.f);
        self.defaultLogo.backgroundColor = [UIColor clearColor];
        self.defaultLogo.center = self.poster.center;
        [self.poster addSubview:self.defaultLogo];
        
        //Poster button
        self.posterPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.posterPlayBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.posterPlayBtn.backgroundColor = [UIColor clearColor];
        self.posterPlayBtn.frame = self.poster.bounds;
        [self.posterPlayBtn setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"] forState:UIControlStateNormal];
        [self.posterPlayBtn addTarget:self action:@selector(didTapPlayBtnInPosterToPlay) forControlEvents:UIControlEventTouchUpInside];
        self.posterPlayBtn.accessibilityLabel = @"播放视频";
        [self addSubview:self.posterPlayBtn];
        
        //Title view
        self.titleView  = [[WSMVVideoTitleView alloc] initWithFrame:CGRectMake(0, 0, self.width, kTitleViewHeight_NonFullScreen) delegate:self];
        self.titleView.delegate = self;
        [self addSubview:self.titleView];
        
        //Copyright msg view
        self.copyrightMsgView = [[WSMVPlayerCopyrightMsgView alloc] initWithFrame:self.bounds];
        self.copyrightMsgView.delegate = self;
        self.copyrightMsgView.alpha = 0;
       [self addSubview:self.copyrightMsgView];
        self.copyrightMsgView.frame = self.bounds;
        
        //Control bar(non fullscreen & fullscreen)
        CGRect _controlBarFrameNonFullScreen = CGRectMake(0, CGRectGetHeight(self.bounds) - kControlBarHeight_nonfullscreen, self.bounds.size.width, kControlBarHeight_nonfullscreen);
        _controlBarNonFullScreen = [[WSMVVideoControlBar_NonFullScreen alloc] initWithFrame:_controlBarFrameNonFullScreen];
        _controlBarNonFullScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _controlBarNonFullScreen.delegate = self;
        [self addSubview:_controlBarNonFullScreen];
        [self showCorrectControlBar:NO];
        
        //Recommend video view
        if (!(self.recommendVideosView)) {
            self.recommendVideosView = [[WSMVRecommendVideosView alloc] initWithDelegate:self];
            [self addSubview:self.recommendVideosView];
            self.recommendVideosView.alpha = 0;
        }
        
        //Loading view

        self.loadingMaskView = [[WSMVLoadingMaskView alloc] initWithFrame:self.bounds showUserGuide:YES];
        self.loadingMaskView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        [self addSubview:self.loadingMaskView];
        
        //Pan GestureRecognizer(用于上下实时滑动调整音量)
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(adjustVolumeOrSwitchVideo:)];
        self.panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.panGestureRecognizer];
        
        //Tap GestureRecognizer(用于单点播放区域时显示或隐藏上下条)
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnPlayerView:)];
        self.tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        [self bringSubviewToFront:self.copyrightMsgView];
    }
    return self;
}

- (SHMoviePlayerController *)moviePlayer {
    if (_moviePlayer == nil) {
        //SHMoviePlayerController
        _moviePlayer = [[SHMoviePlayerController alloc] init];
        _moviePlayer.view.userInteractionEnabled = NO;
        _moviePlayer.movieScaleMode = SHMovieScaleModeAspectFit;
        _moviePlayer.shouldAutoplay = YES;
        _moviePlayer.view.frame = self.bounds;
        _moviePlayer.view.clipsToBounds = YES;
        [self addSubview:_moviePlayer.view];
        [self sendSubviewToBack:_moviePlayer.view];
    }
    return _moviePlayer;
}

- (SHMoviePlayerController *)getMoviePlayer {
    return _moviePlayer;
}

- (void)clearMoviePlayerController {
    if (_moviePlayer) {
        self.observer.delegate = nil;
        self.observer = nil;
        _moviePlayer.delegate = nil;
        [_moviePlayer playerExit];
        [_moviePlayer.view removeFromSuperview];
        _moviePlayer = nil;
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];

    [self removePureModeTimer];
    
    self.playingVideoModel = nil;
    
    [self removeNotificationObservers];
    [self clearMoviePlayerController];
    
    self.controlBarNonFullScreen.delegate = nil;

    self.controlBarFullScreen.delegate = nil;
    
    self.controlBarSmallScreen.delegate = nil;
    
    self.titleView.delegate = nil;
    
    self.copyrightMsgView.delegate = nil;
    
    self.volumnBarMask.delegate = nil;
    
    self.recommendVideosView.delegate = nil;
    
    self.tapGestureRecognizer.delegate = nil;
    self.panGestureRecognizer.delegate = nil;
    
    self.relativeVideosView.delegate = nil;
}

- (void)setSupportSwitchVideoByLRGestureInNonFullscreenMode:(BOOL)supportSwitchVideoByLRGestureInNonFullscreenMode {
    _supportSwitchVideoByLRGestureInNonFullscreenMode = supportSwitchVideoByLRGestureInNonFullscreenMode;
    self.loadingMaskView.showUserGuide = supportSwitchVideoByLRGestureInNonFullscreenMode;
}

#pragma mark - Public
- (BOOL)isRelativeVideosViewInFirstPage {
    if (!(self.relativeVideosView)) {
        return YES;
    }
    return [self.relativeVideosView isInFirstPage];
}

- (void)setSupportRelativeVideosViewInNonFullscreenMode:(BOOL)support {
    _supportRelativeVideosViewInNonFullscreenMode = support;
    if (_supportRelativeVideosViewInNonFullscreenMode) {
        if (!(self.relativeVideosView)) {
            self.relativeVideosView = [[WSMVRelativeVideosView alloc] initWithFrame:self.bounds];
            self.relativeVideosView.alpha = 0;
            self.relativeVideosView.delegate = self;
            [self addSubview:self.relativeVideosView];
        }
    } else {
        [self.relativeVideosView removeFromSuperview];
        self.relativeVideosView = nil;
    }
}

- (void)initPlaylist:(NSArray *)playlist initPlayingIndex:(NSInteger)playingIndex {
    if (playlist.count <= 0 || playingIndex < 0 || playingIndex >= playlist.count) {
        NSLogError(@"Invalid intial playlist or invalid initial playing index.");
        return;
    }

    [self stop];
    [self.playlist removeAllObjects];
    [self.playlist addObjectsFromArray:playlist];
    
    self.playingVideoModel = [self.playlist objectAtIndex:playingIndex];
}

- (void)appendPlaylist:(NSArray *)videos {
    if (videos.count > 0) {
        [self.playlist addObjectsFromArray:videos];
    }
}

- (void)appendRecommendVideos:(NSArray *)videos {
    [self.recommendVideosView appendRecommendVideos:videos];
    [self.relativeVideosView appendRelativeVideos:videos];
}

- (void)replaceAllRecommendVieos:(NSArray *)videos {
    [self.recommendVideosView replaceAllRecommendVieos:videos];
    [self.relativeVideosView replaceAllRelativeVieos:videos];
}

- (NSArray *)recommendVideos {
    return self.recommendVideosView.recommendVideos;
}

- (void)resetModel {
    _playingVideoModel = nil;
    [self.playlist removeAllObjects];
    [self.recommendVideosView replaceAllRecommendVieos:nil];
}

- (void)setPlayingVideoModel:(SNVideoData *)playingVideoModel {
    if (_playingVideoModel != playingVideoModel) {
        [self resetLastPlayingFailState];
        
        NSUInteger _tmpIndex = [self.playlist indexOfObject:playingVideoModel];
        if (_tmpIndex != NSNotFound) {
            _playingVideoModel.hadEverAlert2G3G = NO;
            _playingVideoModel = nil;

            self.playingIndex = _tmpIndex;
            _playingVideoModel = playingVideoModel;
            _playingVideoModel.callbackWillPlayNextIn5Seconds = NO;

            [self statPV];
            
            [self setPosterImage];
            
            self.controlBarNonFullScreen.siteNameLabel.text = [self getSiteName];
            self.controlBarFullScreen.siteNameLabel.text = [self getSiteName];
            
            [self updateTextAfterModelChanged];
        }
    }
    
    if (self.playingVideoModel.playType == WSMVVideoPlayType_HTML5) {
        self.copyrightMsgView.alpha = 1;
    } else {
        self.copyrightMsgView.alpha = 0;
    }
    
    [self enableActionsOrNot];
}

- (void)setPosterImage {
    self.defaultLogo.hidden = NO;

    __weak __typeof(&*self)weakSelf = self;
    [self.poster setUrlPath:[self posterURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if(nil != image){
            weakSelf.defaultLogo.hidden = YES;
        }else{
            weakSelf.defaultLogo.hidden = NO;
            weakSelf.defaultLogo.center = weakSelf.poster.center;

        }
    }];
    if (!self.isFromAutoPlayVideo) {
    } else {
        self.poster.backgroundColor = [UIColor clearColor];
    }
}

- (void)updateTextAfterModelChanged {
    [self.titleView updateHeadline:_playingVideoModel.title
                          subtitle:_playingVideoModel.subtitle];
}

- (NSString *)posterURL {
    return _playingVideoModel.poster;
}

#pragma mark - Play next video
- (void)playNextVideo {
    NSInteger _nextIndex = self.playingIndex + 1;
    if (_nextIndex > self.playingIndex && _nextIndex < self.playlist.count) {
        self.copyrightMsgView.alpha = 0;
    
        NSInteger _nextIndex = self.playingIndex + 1;
        SNVideoData *_nextVideoModel = [self.playlist objectAtIndex:_nextIndex];
        [self setPlayingVideoModel:_nextVideoModel];
        
        //---加载相关推荐
        if (!(self.isPlayingRecommendList)) {
            [self.recommendVideosView clearRecommendVideos];
        } else {
            [self.recommendVideosView reloadData];
        }
        if ([self.delegate respondsToSelector:@selector(willPlayNextVideo:)]) {
            [self.delegate willPlayNextVideo:_nextVideoModel];
        }
        //---
        
        //---如果连续播放列表中剩余的视频个数不足三个时，则发起追加播放列表的请求
        [self appendPlaylistIfNeeded];
        
        [self playCurrentVideo];
    } else if ([self recommendVideos].count > 0 && !(self.isPlayingRecommendList)) {
        [self switchToPlayRecommendVideo:[[self recommendVideos] objectAtIndex:0] inRecommendVideos:[self recommendVideos]];
    } else {
        [self noNextVideoToPlay];
    }
}

- (void)playNextVideoWithDelay {
    self.relativeVideosView.alpha = 1;
    [self.relativeVideosView willPlayVideoAfter:self.playingVideoModel];
    [self performSelector:@selector(playNextVideo) withObject:nil afterDelay:5];
}

- (void)noNextVideoToPlay {
    //lijian 2015.01.08 如果已经是不可用的旧不提示了，
    if (self.controlBarFullScreen.nextVideoBtn.enabled == NO) {
        return;
    }
    //V3.8版本：因为推荐打开播放页时，播放列表本来就只有一个视频，所以播放这一个视频就不用提示“已是最后一个视频了“。
    //V4.0版本：如果播放页能在播放列表中只有一个视频的情况下，自动连播相关视频(相关视频个数大于0)则还是要在播放完最后一个相关视频时提示“已是最后一个视频了，
    if (self.videoPlayerRefer == WSMVVideoPlayerRefer_PushNotification) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(thereisNoNextVideo:)]) {
        [self.delegate thereisNoNextVideo:self];
    }
}

- (void)autoVideoDidFinishByPlaybackError {
}

- (void)autoVideoDidPlay {
}

#pragma mark - Play previous video
- (void)playPreVideo {
    NSInteger _preIndex = self.playingIndex - 1;
    if (_preIndex < self.playingIndex && _preIndex >= 0) {
        self.copyrightMsgView.alpha = 0;
        
        NSInteger _preIndex = self.playingIndex - 1;
        SNVideoData *_preVideoModel = [self.playlist objectAtIndex:_preIndex];
        [self setPlayingVideoModel:_preVideoModel];
        
        //---加载相关推荐
        if (!(self.isPlayingRecommendList)) {
            [self.recommendVideosView clearRecommendVideos];
        } else {
            [self.recommendVideosView reloadData];
        }
        if ([self.delegate respondsToSelector:@selector(willPlayPreVideo:)]) {
            [self.delegate willPlayPreVideo:_preVideoModel];
        }
        //---
        
        [self playCurrentVideo];
    } else {
        [self noPreVideoToPlay];
    }
}

- (void)noPreVideoToPlay {
    if ([self.delegate respondsToSelector:@selector(thereIsNoPreVideo:)]) {
        [self.delegate thereIsNoPreVideo:self];
    }
}

- (void)pause {
    //by cuiliangliang 2015-12-16
    if (!_moviePlayer.isInAdvertMode) {
        [self showTitleAndControlBarWithAnimation:YES];
    }
    [self.loadingMaskView stopLoadingViewAnimation];
    [_moviePlayer pause];
}

- (void)stop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(playNextVideo)
                                               object:nil];
    
    if ([self canStop]) {
        //视频前贴面广告的VV统计
        if ([self canStatVideoAdVVWhenStop]) {
            [self statVideoAdVV];
        }
        if ([self canStatVVWhenStopVideo]) {
            [self statVV];
        }
        [self removeNotificationObservers];
        [self saveVideoBreakpoint];
        [self reset];
        [_moviePlayer stop];
        [_moviePlayer playerExit];
        //lijian 2015.09.25 操！原来是这个原因，如果不调用该接口，光stop没用，从后台切到前台一样会恢复播放，这尼玛sdk
    } else {
        [_moviePlayer stop];
        [_moviePlayer playerExit];
    }
}

- (BOOL)canStop {
    BOOL _canStop = NO;
    SHMoviePlayState moviePlayState = _moviePlayer.playbackState;
    BOOL isLoadAdvert = _moviePlayer.isLoadAdvert;//是否启用广告播放
    if (isLoadAdvert) {
        //启用广告播放能力的前提下
        SHAdvertPlayState adPlayState = _moviePlayer.advertCurrentPlayState;
        _canStop = !!(self.playingVideoModel) && (adPlayState != SHAdvertPlayStateStoped || (moviePlayState != SHMoviePlayStateStopped && moviePlayState != SHMoviePlayStateInterrupted));
    } else {
        //没有启用广告播放能力的前提下
        _canStop = !!(self.playingVideoModel) && moviePlayState != SHMoviePlayStateStopped && moviePlayState != SHMoviePlayStateInterrupted;
    }
    return _canStop;
}

- (BOOL)canStatVVWhenStopVideo {
    //有广告的情况：广告必须是已播完且正片处于暂停或正在播放状态才能统计VV
    if (_moviePlayer.isLoadAdvert) {
        SHAdvertPlayState adPlayState = _moviePlayer.advertCurrentPlayState;
        BOOL isVideoPlaying = [self isPlaying];
        BOOL isVideoPaused = [self isPaused];
        if ((adPlayState == SHAdvertPlayStateUnknown || adPlayState == SHAdvertPlayStateStoped) && (isVideoPlaying || isVideoPaused)) {
            return YES;
        } else {
            return NO;
        }
    }
    //无广告的情况：只有正片暂停或正在播放时才能统计VV
    else {
        return [self isPlaying] || [self isPaused];
    }
}

- (BOOL)canStatVideoAdVVWhenStop {
    SHAdvertPlayState adPlayState = _moviePlayer.advertCurrentPlayState;
    if (_moviePlayer.isLoadAdvert && (adPlayState == SHAdvertPlayStatePlaying || adPlayState == SHAdvertPlayStatePause)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)forceStop {
//    if (self.isFromAutoPlayVideo && self.playingVideoModel.vid) {
//        //@qz说明来自频道流的自动播放cell滑出屏幕外面了，暂时这么判断
//        if ([_retryedVidArray count]) {
//            [_retryedVidArray removeAllObjects];
//            if ([_reportedVidArray count])
//                [_reportedVidArray removeAllObjects];//其实应该顶多就一个值
//        }
//    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playNextVideo) object:nil];
    [self removeNotificationObservers];
    [self saveVideoBreakpoint];
    [_moviePlayer stop];
    [self reset];
}

- (void)playVideo {
    //当视频播放器不可见时则不能播放视频；若delegate没有实现isVideoPlayerVisible方法则默认是无论如何都可以播放的
    if ([self.delegate respondsToSelector:@selector(isVideoPlayerVisible)]) {
        BOOL isVideoPlayerVisible = [self.delegate isVideoPlayerVisible];
        if (!isVideoPlayerVisible) {
            return;
        }
    }
    
    //---网络提示
    if (![self canContinueBeforePlayCurrentVideo]) {
        return;
    }
    //---
    
    //保证静音按钮开启时视频播放仍有声音
    if ([SNADVideoCellAudioSession sharedInstance].isADVideo ==YES) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    //停止语言播放
    [[SNSoundManager sharedInstance] stopAll];

    [self statPlayAction];
    
    self.relativeVideosView.alpha = 0;
    [self.relativeVideosView resetWillPlayThumbnailUI];

    if ([self.delegate respondsToSelector:@selector(willPlayVideo:)]) {
        [self.delegate willPlayVideo:self.playingVideoModel];
    }
    
    if (self.playingVideoModel.playType == WSMVVideoPlayType_HTML5) {
        return;
    }
    if (self.isFromAutoPlayVideo) {
        if (!(self.observer)) {
            self.observer = [[WSMVVideoPlayerViewObserver alloc] init];
            self.observer.delegate = self;
            _moviePlayer.delegate = self.observer;
            AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, WSMVVideoPlayerViewAudioVolumeChangeListenerCallback,
                                            (__bridge void *)(self));
        }
    } else {
         [self addNotificationObserversIfNeeded];
    }

    self.posterPlayBtn.hidden = YES;
    SHMoviePlayState _playbackState = _moviePlayer.playbackState;
    SHAdvertPlayState adPlayState = _moviePlayer.advertCurrentPlayState;
    
    if (adPlayState == SHAdvertPlayStateUnknown &&
        (_playbackState == SHMoviePlayStateStopped ||
         _playbackState == SHMoviePlayStateInterrupted)) {
        if (self.playingVideoModel) {
            //@qz test
//            BOOL isChange = YES;
//            for(NSString *value in _retryedVidArray){
//                if (value.integerValue == _playingVideoModel.vid.integerValue) {
//                    isChange = NO;
//                }
//            }
//            if (isChange) {
//                if (self.isFromAutoPlayVideo) {
//                    self.playingVideoModel.siteInfo.siteId = @"1111111";
//                }else if(self.isFromNewsContent){
//                    self.playingVideoModel.vid = @"1111111";
//                }
//            }
            [self loadVideoSourceAndReadyToPlay:self.playingVideoModel];
            
            if ([self.delegate respondsToSelector:@selector(didPlayVideo:)]) {
                [self.delegate didPlayVideo:self.playingVideoModel];
            }
        } else {
            //重置状态
            [self removeNotificationObservers];
            [self reset];
            [self showTitleAndControlBarWithAnimation:YES];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didPlayVideo:)]) {
            [self.delegate didPlayVideo:self.playingVideoModel];
        }
        //lijian 2015.05.09 这个方法不能放在上面用，否则会再下面的代理里面调用停止播放。导致视频失效
        [_moviePlayer play];
    }
}

- (void)playActiveVideo {
    [self playVideo];
}

- (void)playCurrentVideo {
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    if (appState != UIApplicationStateActive) {
        return;
    }
    [self playVideo];
}

- (BOOL)isLoading {
    BOOL _isLoading = !(self.loadingMaskView.hidden);
    return _isLoading;
}

- (BOOL)isPlaying {
    float currentPlaybackRate = _moviePlayer.currentPlaybackRate;
    SHMoviePlayState playbackState = _moviePlayer.playbackState;
    SHAdvertPlayState adPlayState = _moviePlayer.advertCurrentPlayState;
    
    BOOL _isPlaying = adPlayState == SHAdvertPlayStatePlaying || (currentPlaybackRate > 0 && playbackState ==  SHMoviePlayStatePlaying);
    return _isPlaying;
}

- (BOOL)isVideoPlayingExcludingAdPlaying {
    float currentPlaybackRate = _moviePlayer.currentPlaybackRate;
    SHMoviePlayState playbackState = _moviePlayer.playbackState;
    
    BOOL _isPlaying = currentPlaybackRate > 0 && playbackState ==  SHMoviePlayStatePlaying;
    return _isPlaying;
}

- (BOOL)isPaused {
    SHAdvertPlayState adPlayState = _moviePlayer.advertCurrentPlayState;
    SHMoviePlayState playbackState = _moviePlayer.playbackState;
    
    BOOL _isPaused = (adPlayState == SHAdvertPlayStatePause) || (adPlayState != SHAdvertPlayStatePlaying && playbackState ==  SHMoviePlayStatePaused);
    return _isPaused;
}

- (BOOL)isStopped {
    float currentPlaybackRate = _moviePlayer.currentPlaybackRate;
    SHAdvertPlayState adPlayState = _moviePlayer.advertCurrentPlayState;
    SHMoviePlayState playbackState = _moviePlayer.playbackState;
    
    BOOL _isStopped = NO;
    BOOL isLoadAdvert = _moviePlayer.isLoadAdvert;
    if (isLoadAdvert) {
        _isStopped = (adPlayState == SHAdvertPlayStateUnknown || adPlayState == SHAdvertPlayStateStoped) && currentPlaybackRate <= 0 && playbackState ==  SHMoviePlayStateStopped;
    } else {
        _isStopped = currentPlaybackRate <= 0 && playbackState ==  SHMoviePlayStateStopped;
    }
    return _isStopped;
}

- (NSTimeInterval)curretnPlayTime {
    NSTimeInterval _currentPTime = _moviePlayer.currentPlaybackTime;
    if (isnan(_currentPTime)) {
        _currentPTime = 0;
    }
    return _currentPTime;
}

#pragma mark - Private
- (void)didTapPlayBtnInPosterToPlay {
    if (_moviePlayer == nil) {
        self.moviePlayer.view.frame = self.bounds;
        [self getMoviePlayer].movieScaleMode = SHMovieScaleModeAspectFit;
    }
    
    [self playCurrentVideo];
}

- (void)enterPureModeIfNeeded {
    if (!self.enterPureModeFinished || self.isPureMode) {
        return;
    }
    
    //正在播放时才会有自动隐藏的功能
    if ([self isPlaying]) {
        SNDebugLog(@"Will enter pure mode after 4 seconds...");
        self.enterPureModeFinished = NO;
        [self performSelector:@selector(doEnterPureMode) withObject:nil afterDelay:4];
    }
}

- (void)doEnterPureMode {
    [UIView animateWithDuration:0.2 animations:^{
        if (!(self.pureModeTimer) || ![self.pureModeTimer isValid]) {
            return;
        }
        
        self.titleView.alpha = 0;
        [self hideVolumnBarMask];
        _controlBarNonFullScreen.alpha = 0;
        _controlBarFullScreen.alpha = 0;
    } completion:^(BOOL finished) {
        if (!(self.pureModeTimer) || ![self.pureModeTimer isValid]) {
            return;
        }
        
        self.enterPureModeFinished = YES;
        self.isPureMode = (self.titleView.alpha == 0);
    }];
}

- (void)addNotificationObserversIfNeeded {
    if (!_observer) {
        self.observer = [[WSMVVideoPlayerViewObserver alloc] init];
        self.observer.delegate = self;
        _moviePlayer.delegate = self.observer;
        
        [SNNotificationManager addObserver:self selector:@selector(handleApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(saveVideoBreakpoint) name:UIApplicationWillTerminateNotification object:nil];
        
        //ApplicationDidBecomeActive
        [SNNotificationManager addObserver:self selector:@selector(handleApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                        WSMVVideoPlayerViewAudioVolumeChangeListenerCallback,
                                        (__bridge void *)(self));
    }
}

- (void)removeNotificationObservers {
    [self removePlaybackTimeObserver];
    
    _moviePlayer.delegate = nil;
    self.observer.delegate = nil;
    self.observer = nil;
    
    [SNNotificationManager removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, WSMVVideoPlayerViewAudioVolumeChangeListenerCallback,
                                                   (__bridge void *)(self));
}

#pragma mark - Private - Control bar
- (void)showCorrectControlBar:(BOOL)animation {
    if (animation) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
    }
    
    if (self.videoWindowType == SNVideoWindowType_small) {
        _controlBarSmallScreen.alpha = 1;
    } else {
        if ([self isFullScreen]) {
            _controlBarNonFullScreen.alpha = 0;
            _controlBarFullScreen.alpha = 1;
        } else {
            _controlBarNonFullScreen.alpha = 1;
            _controlBarFullScreen.alpha = 0;
        }
    }
    
    if (animation) {
        [UIView commitAnimations];
    }
}

- (void)setControlBarPlayBtnStatus:(WSMVVideoPlayerPlayBtnStatus)playBtnStatus {
    [_controlBarNonFullScreen setPlayBtnStatus:playBtnStatus];
    [_controlBarFullScreen setPlayBtnStatus:playBtnStatus];
}

- (void)updateToCurrentTime:(double)seconds duration:(double)duration {
    [_controlBarNonFullScreen.progressBar updateToCurrentTime:seconds
                                                     duration:duration];
    [_controlBarFullScreen.progressBar updateToCurrentTime:seconds
                                                  duration:duration];
    [_controlBarSmallScreen.progressBar updateToCurrentTime:seconds
                                                   duration:duration];
}

- (void)updateBuffer:(double)seconds duration:(double)duration {
    [_controlBarNonFullScreen.progressBar updateBuffer:seconds duration:duration];
    [_controlBarFullScreen.progressBar updateBuffer:seconds duration:duration];
    [_controlBarSmallScreen.progressBar updateBuffer:seconds duration:duration];
}

- (void)resetControlBarTimeLabel {
    [_controlBarNonFullScreen.progressBar resetTimeLabel];
    [_controlBarFullScreen.progressBar resetTimeLabel];
}

- (BOOL)isControlBarSliderHighlighted {
    return _controlBarNonFullScreen.progressBar.slider.isHighlighted || _controlBarFullScreen.progressBar.slider.isHighlighted || _controlBarSmallScreen.progressBar.slider.isHighlighted;
}

- (void)setControlBarTimeLabelTextToNonLive {
    [_controlBarNonFullScreen.progressBar setTimeLabelTextToNonLive];
    [_controlBarFullScreen.progressBar setTimeLabelTextToNonLive];
}

- (void)setControlBarTimeLabelTextToLive {
    [_controlBarNonFullScreen.progressBar setTimeLabelTextToLive];
    [_controlBarFullScreen.progressBar setTimeLabelTextToLive];
}

/**
 * 启用或禁用某些功能按钮（App视频离线功能是否开启、视频是否能下载、分享按钮是否显示）
 * App视频离线功能是否开启：开启则显示，否则隐藏；通过check.do接口进行check获取此参数
 * 视频是否能下载：显示下载图标或禁止下载图标，由video数据中的downloadType决定
 * 分享按钮是否显示：视频控件在非全屏状态下本身就不显示分享按钮，
 *                所以只有全屏下需要控制分享按钮显示与否。又由于全屏时分享按钮在离线按钮在的右边，所以直接控制全屏的分享按钮是否显示即可。
 */
- (void)enableActionsOrNot {
    //App开启视频下载功能
    if ([[SNCheckManager sharedInstance] supportVideoDownload]
        && (self.videoPlayerRefer != WSMVVideoPlayerRefer_OfflinePlay &&
            self.videoPlayerRefer != WSMVVideoPlayerRefer_NewsArticle &&
            self.videoPlayerRefer != WSMVVideoPlayerRefer_LiveRoomList &&
            self.videoPlayerRefer != WSMVVideoPlayerRefer_LiveRoomBanner)) {
        [_controlBarNonFullScreen enableDownload];
        [_controlBarFullScreen enableDownload];
    }
    //App禁用视频下载功能
    else {
        [_controlBarNonFullScreen disableDownload];
        [_controlBarFullScreen disableDownload];
    }
    
    //当前视频不让下载
    if (self.playingVideoModel.downloadType != WSMVVideoDownloadType_CanDownload ||
        self.playingVideoModel.playType != WSMVVideoPlayType_Native ||
        self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
        [_controlBarNonFullScreen forbidDownload];
        [_controlBarFullScreen forbidDownload];
    }
    //当前视频可以下载
    else {
        [_controlBarNonFullScreen notForbidDownload];
        [_controlBarFullScreen notForbidDownload];
    }
    
    //隐藏新闻正文页全屏时底部功能条的分享按钮
    if (self.videoPlayerRefer == WSMVVideoPlayerRefer_NewsArticle) {
        [_controlBarFullScreen disableShare];
    }
    //其它情况显示分享按钮
    else {
        [_controlBarFullScreen enableShare];
    }
}

- (void)showTitleAndControlBarWithAnimation:(BOOL)animation {
    //--- 如果广告正在播放中，则不显响应显示上下条的操作
    SHAdvertPlayState adPlayState = _moviePlayer.advertCurrentPlayState;
    if (_moviePlayer.isLoadAdvert && adPlayState == SHAdvertPlayStatePlaying) {
        return;
    }
    //---
    
    [self removeTitleAndControlBarAnimations];
    //By cuiliangliang
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.videoWindowType == SNVideoWindowType_small) {
        return;
    }
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.titleView.alpha = 1;
            if ([self isFullScreen]) {
                _controlBarFullScreen.alpha = 1;
            } else {
                _controlBarNonFullScreen.alpha = 1;
            }
        } completion:^(BOOL finished) {
            self.isPureMode = (self.titleView.alpha == 0);
        }];
    } else {
        self.titleView.alpha = 1;
        if ([self isFullScreen]) {
            _controlBarFullScreen.alpha = 1;
        } else {
            _controlBarNonFullScreen.alpha = 1;
        }
        self.isPureMode = (self.titleView.alpha == 0);
    }
}

- (void)hideTitleAndControlBarWithAnimation:(BOOL)animation {
    [self removeTitleAndControlBarAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doEnterPureMode) object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.titleView.alpha = 0;
            _controlBarNonFullScreen.alpha = 0;
            _controlBarFullScreen.alpha = 0;
           [self hideVolumnBarMask];
        } completion:^(BOOL finished) {
            self.enterPureModeFinished = YES;
            self.isPureMode = (self.titleView.alpha == 0);
        }];
    } else {
        self.titleView.alpha = 0;
        _controlBarNonFullScreen.alpha = 0;
        _controlBarFullScreen.alpha = 0;
        [self hideVolumnBarMask];
        self.enterPureModeFinished = YES;
        self.isPureMode = (self.titleView.alpha == 0);
    }
}

- (void)removeTitleAndControlBarAnimations {
    [self.titleView.layer removeAllAnimations];
    [self.volumnBarMask.layer removeAllAnimations];
    [_controlBarNonFullScreen.layer removeAllAnimations];
    [_controlBarFullScreen.layer removeAllAnimations];
}

#pragma mark - Private - About WSRecommendVideosView
- (void)showRecommendVideosView {
    [self bringSubviewToFront:self.recommendVideosView];
    
    if (self.recommendVideosView.alpha == 0) {
        [self.recommendVideosView refreshEmptyNoticeIfNeed];
        [UIView animateWithDuration:0.2 animations:^{
            self.recommendVideosView.alpha = 1;
        }];
    }
}

- (void)hideRecommendVideosView {
    if (self.recommendVideosView.alpha == 1) {
        [self.recommendVideosView refreshEmptyNoticeIfNeed];
        [UIView animateWithDuration:0.2 animations:^{
            self.recommendVideosView.alpha = 0;
        }];
    }
}

#pragma mark - Private - About play
- (void)addPlaybackTimeObserverIfNeeded {
    if (self.playbackTimeTimer) {
        return;
    }
    
    CGFloat _duration = _moviePlayer.duration;
    if (isnan(_duration)) {
        return;
    }
    
    if (_duration >= 0 && _duration != CGFLOAT_MAX) {
        [self setControlBarTimeLabelTextToNonLive];
        self.playbackTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self.observer selector:@selector(playbackTimeDidChanged) userInfo:nil repeats:YES];
    } else {
        [self setControlBarTimeLabelTextToLive];
    }
}

- (void)removePlaybackTimeObserver {
    if (self.playbackTimeTimer) {
        [self.playbackTimeTimer invalidate];
        self.playbackTimeTimer = nil;
    }
}

- (void)loadVideoSourceAndReadyToPlay:(SNVideoData *)videoModel {
    self.copyrightMsgView.alpha = 0;
    [self.loadingMaskView stopLoadingViewAnimation];
    [self.loadingMaskView startLoadingViewAnimation];
    
    NSString *classname = NSStringFromClass([self class]);
    if ([classname isEqualToString:@"SNUserPortraitPlayer"]) {
        SHMedia *media = [self getSHMedia];
        [_moviePlayer playWithMedia:media];
        return;
    }
    
    if (self.isFromAutoPlayVideo) {
        [self.defaultLogo removeFromSuperview];
        self.poster.backgroundColor = [UIColor clearColor];
        SHMedia *shMedia = [[SHMedia alloc] init];
        shMedia.url = nil;
        shMedia.site = [videoModel.siteInfo.site2 intValue];
        shMedia.poid = @"16";
        
        if ([videoModel.templateType isEqualToString:kNewsTypeRollingBigVideo] ||
            [videoModel.templateType isEqualToString:kNewsTypeRollingMiddleVideo]) {
            shMedia.decoderType = SHMediaDecoder_System;
        } else {
            shMedia.decoderType = SHMediaDecoder_Default;
        }
        if (videoModel.isRecommend) {
            shMedia.expandMemo = @{@"channeled":@"1300030002", @"type":@"1"};
        } else {
            shMedia.expandMemo = @{@"channeled":@"1300030001", @"type":@"1"};
        }
        if ([videoModel.siteInfo.site2 intValue] == kSohuLiveVideo) {
            shMedia.sourceType = SHLiveMedia;
            shMedia.lid = videoModel.siteInfo.siteId;//电台直播id
        } else {
            shMedia.sourceType = SHSohuMedia;
            shMedia.vid = videoModel.siteInfo.siteId;//siteId表示在搜狐视频或搜狐博客源ID
            //shMedia.vid = videoModel.vid;//写成这个也能播放成功
        }
        _moviePlayer.isLoadAdvert = NO;
        _moviePlayer.isPreloadMovieWhenPlayAdvert = YES;
        
        // Cae add. 增加视频播放透传的参数
        sohunewsAppDelegate *app = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
        NSNumber *tabId = [SNTabBarController tabIndexToStatistics:app.appTabbarController.selectedIndex];
        NSMutableDictionary *extendsParams = [[NSMutableDictionary alloc] init];
        
        [extendsParams setObject:tabId.stringValue forKey:@"sourcetab"];
        [extendsParams setObject:[self getControllerFromTabId:tabId] forKey:@"newschn"];
        if (nil != [[SNVideoAdContext sharedInstance] getAdTrace]) {
            [extendsParams setObject:[[SNVideoAdContext sharedInstance] getAdTrace] forKey:@"cid"];
        }
        
        shMedia.extendParams = extendsParams;
        
        [_moviePlayer playWithMedia:shMedia];
        
        shMedia = nil;
        return;
    }
    
    if (!(videoModel) || videoModel.sources.count <= 0) {
        [self videoDidFinishByPlaybackError];
    } else {
        if (_currentVideoSegmentIndex < videoModel.sources.count) {
            //腾讯OpenAPI framework有Bug，会导致在模拟器iOS7版本上播视频时Crash.
            if ([SNPreference sharedInstance].debugModeEnabled) {
                [NSURLCache setSharedURLCache:nil];
            }
            
            SHMedia *shMedia = [[SHMedia alloc] init];
            BOOL isLoadAdvert = NO;
            SNVideoDataDownload *downloadVideo = [[SNDBManager currentDataBase] queryDownloadVideoByVID:videoModel.vid];
            //播本地视频
            if (!!downloadVideo && downloadVideo.state == SNVideoDownloadState_Successful &&
                downloadVideo.localRelativePath.length > 0) {
                NSString *videoURLString = nil;
                if ([downloadVideo.videoType isEqualToString:kDownloadVideoType_M3U8]) {
                    shMedia.sourceType = SHLocalDownload;
                    videoURLString = downloadVideo.localM3U8URL;
                    shMedia.url = videoURLString;
                } else {
                    shMedia.sourceType = SHLocalDownload;
                    videoURLString = [[SNVideoDownloadConfig rootDir] stringByAppendingPathComponent:downloadVideo.localRelativePath];
                    shMedia.url = videoURLString;
                }
                isLoadAdvert = NO;
            }
            //播在线视频
            else {
                //搜狐视频、搜狐博客、搜狐直播
                if ([videoModel.siteInfo.playById isEqualToString:kWSMVVideoPlayByVIDEnabled]
                    && ([videoModel.siteInfo.site2 intValue] == kSohuVRSVideo
                        || [videoModel.siteInfo.site2 intValue] == kSohuUGCVideo
                        || [videoModel.siteInfo.site2 intValue] == kSohuLiveVideo)) {
                        
                        shMedia.url = nil;
                        shMedia.site = [videoModel.siteInfo.site2 intValue];
                        if ([videoModel.siteInfo.site2 intValue] == kSohuLiveVideo) {
                            shMedia.sourceType = SHLiveMedia;
                            shMedia.lid = videoModel.siteInfo.siteId;//电台直播id
                            shMedia.expandMemo = @{@"channeled" : @"1300030004",
                                                   @"type" : @"1"};
                        } else {
                            shMedia.sourceType = SHSohuMedia;
                            shMedia.vid = videoModel.vid;//siteId表示在搜狐视频或搜狐博客源ID
                            if (shMedia.vid.length == 0) {
                                shMedia.vid = videoModel.siteInfo.siteId;
                            }
                            shMedia.expandMemo = @{@"channeled" : @"1300030003",
                                                   @"type" : @"1"};
                        }
                }
                //当直播视频不通过id方式方式播放时，采用lid+url方式播放
                else if ([videoModel.siteInfo.playById isEqualToString:kWSMVVideoPlayByVIDDisabled]
                         && [videoModel.siteInfo.site2 intValue] == kSohuLiveVideo) {
                    NSString *videoURLString = [[videoModel.sources objectAtIndex:_currentVideoSegmentIndex] trim];
                    videoURLString = [SNUtility addVideoCipherToURL:videoURLString];
                    videoURLString = [SNUtility addVideoP1ToURL:videoURLString];
                    
                    shMedia.url = videoURLString;
                    shMedia.lid = videoModel.siteInfo.siteId;
                    
                    shMedia.site = [videoModel.siteInfo.site2 intValue];
                    shMedia.sourceType = SHLiveMedia;
                    shMedia.expandMemo = @{@"channeled" : @"1300030004",
                                           @"type" : @"1"};
                }
                //其它第三方视频或不需要通过vid播放的搜狐视频 视频广告
                else {
                    shMedia.sourceType = SHCommonMedia;
                
                    NSString *videoURLString = [[videoModel.sources objectAtIndex:_currentVideoSegmentIndex] trim];
                    videoURLString = [SNUtility addVideoCipherToURL:videoURLString];
                    videoURLString = [SNUtility addVideoP1ToURL:videoURLString];
                   
                    shMedia.url = videoURLString;
                    shMedia.advUrl = videoModel.siteInfo.adServer;
                    shMedia.expandMemo = @{@"channeled" : @"1300030005",
                                           @"type" : @"1"};
                    
                    //lijian 2016.04.05 加入vid字段
                    if (nil != videoModel.vid &&
                        [videoModel.vid length] > 0) {
                        shMedia.vid = videoModel.vid;
                    }
                }
                
                isLoadAdvert = [[SNVideoAdContext sharedInstance] doesVideoPlayerNeedLoadAd];
                
                //---断点续播的视频不加载广告
                if (isLoadAdvert) {
                    NSString *breakPointKey = self.playingVideoModel.vid ?: self.playingVideoModel.siteInfo.siteId;
                    isLoadAdvert = ![[SNVideoBreakpointManager sharedInstance] breakpointExistsByVid:breakPointKey];
                }
            }

            //如果视频播放失败且在没有更换model的情况下，再次播放时不加载广告
            if ([self didPlayFailAtLastTime]) {
                isLoadAdvert = NO;
            }
            
            //只有在Wifi网络环境下才播放广告
            Reachability *reachability = [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability];
            if ([reachability currentReachabilityStatus] != ReachableViaWiFi) {
                isLoadAdvert = NO;
            }
            
            BOOL videoAdTestServerEnabled = [[SNPreference sharedInstance] videoAdTestServerEnabled];
            
            _moviePlayer.advertHostTestSwitch = videoAdTestServerEnabled;
            _moviePlayer.isLoadAdvert = isLoadAdvert;
            _moviePlayer.isPreloadMovieWhenPlayAdvert = YES;
            
            // Cae add. 增加视频播放透传的参数
            sohunewsAppDelegate *app = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
            NSNumber *tabId = [SNTabBarController tabIndexToStatistics:app.appTabbarController.selectedIndex];
            NSMutableDictionary *extendsParams = [[NSMutableDictionary alloc] init];
            [extendsParams setObject:tabId.stringValue forKey:@"sourcetab"];
            [extendsParams setObject:[self getControllerFromTabId:tabId] forKey:@"newschn"];
            //lijian 2015.01.24 这里加了保护，如果不加保护，在我的阅读圈的视频会有crash的问题
            if (nil != [[SNVideoAdContext sharedInstance] getAdTrace]) {
                [extendsParams setObject:[[SNVideoAdContext sharedInstance] getAdTrace] forKey:@"cid"];
            }

            shMedia.extendParams = extendsParams;
            //正文页连续播放问题，跟广告自动播放有冲突，下期修改
            /*NSString *url = shMedia.url;
            if (shMedia.sourceType == SHCommonMedia &&
                [url rangeOfString:@"prod=news"].length == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                // 避免参数不全导致播放不了
                if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendorString)]) {
                    NSString *uid = [[UIDevice currentDevice] performSelector:@selector(identifierForVendorString)];
                    if ([url containsString:@"?"]) {
                        url = [NSString stringWithFormat:@"%@&uid=%@&pt=3&prod=news&pg=1", url,  uid];
                    } else {
                        url = [NSString stringWithFormat:@"%@?uid=%@&pt=3&prod=news&pg=1", url, uid];
                    }
                } else {
                    if ([url containsString:@"?"]) {
                        url = [NSString stringWithFormat:@"%@&pt=3&prod=news&pg=1", url];
                    } else {
                        url = [NSString stringWithFormat:@"%@?pt=3&prod=news&pg=1", url];
                    }
                }
#pragma clang diagnostic pop
            }
            shMedia.url = url;*/
            [_moviePlayer playWithMedia:shMedia];
            
            shMedia = nil;
       }
    }
}

- (NSString *)getControllerFromTabId:(NSNumber *)tabId {
    NSArray *_viewControllers = [TTNavigator navigator].topViewController.flipboardNavigationController.viewControllers;
    Class cls;
    if (tabId.intValue == 1) {
        cls = [SNRollingNewsViewController class];
    } else if (tabId.intValue == 2) {
        cls = [SNVideosViewController class];
    } else {
        return @"0";
    }
    
    UIViewController *ctrl = nil;
    
    for (NSInteger i = (_viewControllers.count - 1); i >= 0; i--) {
        UIViewController *_vc = [_viewControllers objectAtIndex:i];
        if ([_vc isKindOfClass:cls]) {
            ctrl = _vc;
            break;
        }
    }
    
    if (nil == ctrl) {
        return  @"0";
    }
    
    if (tabId.intValue == 1) {
        SNRollingNewsViewController *rolling = (SNRollingNewsViewController *)ctrl;
        return rolling.selectedChannelId;
    } else {
        SNVideosViewController *video = (SNVideosViewController *)ctrl;
        return video.selectedChannelId;
    }
}

#pragma mark - Private - About gesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    UIWindow *_currentWindow = [UIApplication sharedApplication].keyWindow;
    UIView *_touchedView = [_currentWindow hitTest:[touch locationInView:_currentWindow] withEvent:nil];

    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return (_touchedView == self);
    } else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([_touchedView isKindOfClass:[WSMVSlider class]]) {
            return NO;
        } else {
            if ([self isFullScreen] ||
                self.videoWindowType == SNVideoWindowType_small) {
                return YES;
            } else {
                return self.supportSwitchVideoByLRGestureInNonFullscreenMode;
            }
        }
    } else {
        return YES;
    }
}

#pragma mark -
- (void)didTapOnPlayerView:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.isPureMode) {
        [self showTitleAndControlBarWithAnimation:YES];
    } else {
        [self hideTitleAndControlBarWithAnimation:YES];
    }
}

- (void)adjustVolumeOrSwitchVideo:(UIPanGestureRecognizer *)gestureRecognizer {
    [self hideRecommendVideosView];
    
    CGPoint _translation = [gestureRecognizer translationInView:self];
    CGPoint _velocity = [gestureRecognizer velocityInView:self];

    //斜率
    CGFloat _k = _translation.y / _translation.x;
  
    //Adjust volume
    if (_k > tanf(60 * M_PI / 180) ||
        _k < tanf(120 * M_PI / 180)) {
        //第一象限大于60度或第二象限小于120度时
        //广告播放时不让上下滑动调节音量
        if ([SNVideoAdMaskHelper isAdPlayingInVideoPlayer:self]) {
            return;
        }
        
        Float32 systemVolume;
        UInt32 dataSize = sizeof(Float32);
        AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareOutputVolume,
                                  &dataSize, &systemVolume);
        
        CGFloat _maxOffset = 2000.0f;
        CGFloat _currentOffset = fabsf(_translation.y);
        CGFloat _deltaVolume = fabsf(_currentOffset / _maxOffset);
        
        //Down-调小音量
        CGFloat _newVolume = 0;
        if (_velocity.y > 0) {
            _newVolume = systemVolume - _deltaVolume;
            if (_newVolume <= 0) {
                _newVolume = 0;
            }
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            mpc.volume = _newVolume;
        }
        //Up-调大音量
        else {
            _newVolume = systemVolume + _deltaVolume;
            if (_newVolume > 1) {
                _newVolume = 1;
            }
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            mpc.volume = _newVolume;
        }
    }
    //Swipe
    else if (_k <= tanf(30 * M_PI / 180) &&
             _k >= tanf(-30 * M_PI / 180)) {
        //第一象限小于等30度且第四象限大于等-30度时
        if (fabsf(_velocity.x) > 50 && fabsf(_translation.x) > 50) {
            if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                //广告播放时不让左右滑动切换视频
                if ([SNVideoAdMaskHelper isAdPlayingInVideoPlayer:self]) {
                    return;
                }
                
                [SNNotificationManager postNotificationName:kHideActionMenuViewNotification object:nil];
                if (_velocity.x > 0) {//向右
                    NSInteger _preIndex = self.playingIndex-1;
                    if (_preIndex < self.playingIndex && _preIndex >= 0) {
                        //如果没有前一个视频了，不要停播当前视频
                        [self stop];
                    }
                    [self playPreVideo];
                } else {//向左
                    NSInteger _nextIndex = self.playingIndex+1;
                    if (_nextIndex > self.playingIndex &&
                        _nextIndex < self.playlist.count) {
                        //如果没有后一个视频了，不要停播当前视频
                        [self stop];
                    }
                    [self playNextVideo];
                }
            }
        }
    }
}

#pragma mark - Private - About Pure mode
- (void)addPureModeTimerIfNeeded {
    if (!(self.pureModeTimer)) {
        //自动隐藏TitleView、ControlBar等
        self.enterPureModeFinished = YES;
        self.isPureMode = (self.titleView.alpha == 0);
        self.pureModeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(enterPureModeIfNeeded) userInfo:nil repeats:YES];
    }
}

- (void)removePureModeTimer {
    if (self.pureModeTimer && [self.pureModeTimer isValid]) {
        [self.pureModeTimer invalidate];
        self.pureModeTimer = nil;
        self.enterPureModeFinished = YES;
        self.isPureMode = (self.titleView.alpha == 0);
    }
}

#pragma mark - Private - About Playlist
- (void)appendPlaylistIfNeeded {
    NSInteger _leftCount = self.playlist.count - (self.playingIndex + 1);
    if (_leftCount <= 3) {
        //需要更多的推荐数据
        if ([self isPlayingRecommendList]) {
            if ([self.delegate respondsToSelector:@selector(needMoreRecommendIntoPlaylist)]) {
                [self.delegate needMoreRecommendIntoPlaylist];
            }
        }
        //需要更多的timeline数据
        else {
            if ([self.delegate respondsToSelector:@selector(needMoreTimelineIntoPlaylist)]) {
                [self.delegate needMoreTimelineIntoPlaylist];
            }
        }
    }
}

#pragma mark - Private - 行为统计相关
- (void)statPlayAction {
    NSString *key = @"py";
    int _count = [self.playerActionsStatData intValueForKey:key defaultValue:0];
    _count++;
    [self.playerActionsStatData setValue:@(_count) forKey:key];
}

- (void)statPauseAction {
    NSString *key = @"ps";
    int _count = [self.playerActionsStatData intValueForKey:key defaultValue:0];
    _count++;
    [self.playerActionsStatData setValue:@(_count) forKey:key];
}

- (void)statSeekingForwardAction {
    NSString *key = @"fd";
    int _count = [self.playerActionsStatData intValueForKey:key defaultValue:0];
    _count++;
    [self.playerActionsStatData setValue:@(_count) forKey:key];
}

- (void)statSeekingBackwardAction {
    NSString *key = @"bd";
    int _count = [self.playerActionsStatData intValueForKey:key defaultValue:0];
    _count++;
    [self.playerActionsStatData setValue:@(_count) forKey:key];
}

- (void)statFullscreenAction {
    NSString *key = @"fs";
    int _count = [self.playerActionsStatData intValueForKey:key defaultValue:0];
    _count++;
    [self.playerActionsStatData setValue:@(_count) forKey:key];
}

- (void)statRecommendAction {
    NSString *key = @"rcm";
    int _count = [self.playerActionsStatData intValueForKey:key defaultValue:0];
    _count++;
    [self.playerActionsStatData setValue:@(_count) forKey:key];
}

- (void)statDownloadAction {
    NSString *key = @"dwn";
    int _count = [self.playerActionsStatData intValueForKey:key defaultValue:0];
    _count++;
    [self.playerActionsStatData setValue:@(_count) forKey:key];
}

#pragma mark - Application - ResignActive & BecomeActive
- (void)handleApplicationWillResignActive:(NSNotification *)notification {
    [self.recommendVideosView dismissIfNeeded];
    [self saveVideoBreakpoint];
    if ([self isFullScreen]) {
        //进入后台时退出全屏，不然再启动App时会有很多相关的Bug
        [self exitFullScreen];
    }
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    //---Fixed bug:全屏播放时返回主屏，重新启动后音量提示显示为竖
    if ([self isFullScreen]) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    }
    //---
    
    /**
     * 播放器回到前台时，如果当前网络是非Wifi，那么重置当前数据对象的hadEverAlert2G3G。
     * 以便playCurrentVideo里可以Toast一下“流量提醒:正在非Wifi网络下播放视频“
     */
    NetworkStatus currentNetworkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (currentNetworkStatus == ReachableViaWWAN ||
        currentNetworkStatus == ReachableVia2G ||
        currentNetworkStatus == ReachableVia3G ||
        currentNetworkStatus == ReachableVia4G ) {
        if (self.playingVideoModel.channelId.length > 0) {
            [[WSMVVideoHelper sharedInstance].hadEverAlert2G3GOfChannels setObject:@(NO) forKey:self.playingVideoModel.channelId];
        }
        self.playingVideoModel.hadEverAlert2G3G = NO;
    }
    
    //前后台逻辑由视频SKD处理
    /*if ([[SNVideoAdContext sharedInstance] getCurrentTab] == SNVideoAdContextCurrentTabValue_Video) {
        [self playCurrentVideo];
    } else {
        if (!_moviePlayer.isInAdvertMode) {
            [self pause];
        } else {
            [self playActiveVideo];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(handleAppDidBecomeActive)]) {
        [self.delegate performSelector:@selector(handleAppDidBecomeActive)];
    }*/
}

- (void)handleApplicationWillEnterForegroundNotification:(NSNotification *)notification {
    //---Fixed bug:全屏播放时返回主屏，重新启动后音量提示显示为竖
    if ([self isFullScreen]) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    }
    //---

    /**
     * 播放器回到前台时，如果当前网络是非Wifi，那么重置当前数据对象的hadEverAlert2G3G。
     * 以便playCurrentVideo里可以Toast一下“流量提醒:正在非Wifi网络下播放视频“
     */
    NetworkStatus currentNetworkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (currentNetworkStatus == ReachableViaWWAN ||
        currentNetworkStatus == ReachableVia2G ||
        currentNetworkStatus == ReachableVia3G ||
        currentNetworkStatus == ReachableVia4G ) {
        if (self.playingVideoModel.channelId.length > 0) {
            [[WSMVVideoHelper sharedInstance].hadEverAlert2G3GOfChannels setObject:@(NO) forKey:self.playingVideoModel.channelId];
        }
        self.playingVideoModel.hadEverAlert2G3G = NO;
    }
    
    //前后台逻辑由视频SKD处理
    /*if ([[SNVideoAdContext sharedInstance] getCurrentTab] == SNVideoAdContextCurrentTabValue_Video) {
        [self playCurrentVideo];
    } else {
        if (!_moviePlayer.isInAdvertMode) {
              [self pause];
        } else {
            [self playActiveVideo];
        }
    }*/
}

#pragma mark -
- (void)handleExitFullScreenNofiticaion:(NSNotification *)notification {
    id obj = notification.object;
    BOOL didTapLikeBtn = NO;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *userInfo = (NSDictionary *)obj;
        didTapLikeBtn = [[userInfo objectForKey:kActionMenuViewDidTapLikeBtn defalutObj:nil] boolValue];
    }
    
    if (!didTapLikeBtn) {//收藏时不退出全屏
        [self exitFullScreen];
    }
    
    if ([self isLoading] || [self isPlaying]) {
        //前后台切换，分享时视频控制播放，客户端不再负责
        //[self forceStop];
    }
}

- (void)handlePauseVideoNofiticaion:(NSNotification *)notification {
    //处理音频播放冲突的问题
    if ([self isPlaying]) {
        [self pause];
    }
}

- (void)handleStopVideoNofiticaion:(NSNotification *)notification {
    [self stop];
    [self showTitleAndControlBarWithAnimation:NO];
    
    [[WSMVVideoStatisticManager sharedIntance] statVideoSV];
}

- (void)saveVideoBreakpoint {
    NSString *breakPointKey = self.playingVideoModel.vid ? : self.playingVideoModel.siteInfo.siteId;
    [[SNVideoBreakpointManager sharedInstance] addBreakpointByVid:breakPointKey breakpoint:_moviePlayer.currentPlaybackTime];
}

- (void)handleSupportVideoDownloadValueChangedNotification:(NSNotification *)notification {
    [self enableActionsOrNot];
}

- (void)handleSNVideoAdMaskShowVideoAdDetailNotification:(NSNotification *)notification {
    if (_moviePlayer.isLoadAdvert) {
        id obj = [notification object];
        if ([obj isKindOfClass:[SNVideoAdMask class]]) {
            SNVideoAdMask *notificationSourceMask = (SNVideoAdMask *)obj;
            SNVideoAdMask *currentVideoAdMask = (SNVideoAdMask *)[self viewWithTag:kVideoAdMaskTag];
            
            if (notificationSourceMask == currentVideoAdMask) {
                [_moviePlayer getCurrentOADAdvertInfo];//曝光上报SDK
                [_moviePlayer getOadClickThroughWithPoint:CGPointZero];
                [self statVideoAdClick];//点击上报数据组
                
                //lijian 2015.01.23 这里应该用这个，在暂停时从后台切入前台后才不能被恢复播放。
                [self forceStop];

                if ([self isFullScreen]) {
                    [self exitFullScreen];
                }
                
                SNVideoAdDetailInfo *videoAdDetailInfo = [notificationSourceMask getVideoAdDetailInfo];
                if (videoAdDetailInfo.isOpenInApp) {
                    [SNUtility openProtocolUrl:videoAdDetailInfo.url];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:videoAdDetailInfo.url]];
                }
                [self hideTitleAndControlBarWithAnimation:NO];
            }
        }
    }
}

- (void)handleSNVideoAdMaskEnterOrExitFullscreenNotification:(NSNotification *)notification {
    if (_moviePlayer.isLoadAdvert) {
        id obj = [notification object];
        if ([obj isKindOfClass:[SNVideoAdMask class]]) {
            SNVideoAdMask *notificationSourceMask = (SNVideoAdMask *)obj;
            SNVideoAdMask *currentVideoAdMask = (SNVideoAdMask *)[self viewWithTag:kVideoAdMaskTag];
            
            if (notificationSourceMask == currentVideoAdMask) {
                if (![self isFullScreen]) {
                    [self toFullScreen];
                }
                else {
                    [self exitFullScreen];
                }
            }
        }
    }
}

#pragma mark - 网络提示
- (BOOL)canContinueBeforePlayCurrentVideo {
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    //无网
    if (networkStatus == NotReachable) {
        SNVideoDataDownload *downloadVideo = [[SNDBManager currentDataBase] queryDownloadVideoByVID:self.playingVideoModel.vid];
        if (!!downloadVideo && downloadVideo.state == SNVideoDownloadState_Successful && downloadVideo.localRelativePath.length > 0) {
            return YES;//可以继续播放
        } else {
            //回调进行Toast无网提示
            if(nil != self.delegate && [self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]){
                [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_NotReachable forPlayerView:self];
            }
            SNDebugLog(@"canContinueBeforePlayCurrentVideo: NotReachable");
            return NO;//不能继续播放
        }
    }
    //有网
    else {
        //判断网络类型
        //非Wifi网络(ReachableViaWWAN)
        if (networkStatus == ReachableViaWWAN ||
            networkStatus == ReachableVia2G ||
            networkStatus == ReachableVia3G ||
            networkStatus == ReachableVia4G ) {
            //是否网络提醒过
            //网络提醒过(阻断式或Toast方式提醒过)
            if (self.playingVideoModel.hadEverAlert2G3G) {
                SNDebugLog(@"canContinueBeforePlayCurrentVideo: hadEverAlert2G3G");
                return YES;//可以继续正常播放
            }
            //没有网络提醒过(无论是阻断式还是Toast方式)
            else {
                //2G/3G下离线播放不做任何提示
                if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
                    return YES;
                }
                //没有阻断式提醒过
                else if (!([WSMVVideoHelper sharedInstance].bContinueToPlayVideoIn2G3G)) {
                    //回调进行阻断式提示
                    if (nil != self.delegate &&
                        [self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
                        [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_Block forPlayerView:self];
                    }
                    return NO;//不能继续播放
                }
                //有阻断式提醒过
                else {
                    //回调进行Toast2G/3G播放提示
                    if (nil != self.delegate &&
                        [self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
                        [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_VideoPlayingToast forPlayerView:self];
                    }
                    self.playingVideoModel.hadEverAlert2G3G = YES;
                    SNDebugLog(@"canContinueBeforePlayCurrentVideo: Toast");
                    return YES;//可以继续正常播放
                }
            }
        }
        //Wifi网络
        else {
            SNDebugLog(@"canContinueBeforePlayCurrentVideo: Continue to play");
            return YES;//可以继续正常播放
        }
    }
}
/* 视频播放断网逻辑改变为视频SDK处理,此方法不再调用 */
- (BOOL)canContinueToPlayWhenNetworkChanged:(NetworkStatus)networkStatus {
    //如果当前无网、播放器正处于开始播放前的视频加载中、将要播放的是在线视频，则强制停止加载
    if (networkStatus == NotReachable &&
        [self isLoading] &&
        self.videoPlayerRefer != WSMVVideoPlayerRefer_OfflinePlay) {
        [self forceStop];
        return NO;
    }
    
    if (![self isPlaying]) {
        if ([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
            [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_None forPlayerView:self];
        }
        SNDebugLog(@"canContinueToPlayWhenNetworkChanged: Not playing");
        return NO;//都没有正在播放肯定不能继续播放呀(@-@)
    }
    
    //无网
    if (networkStatus == NotReachable) {
        SNVideoDataDownload *downloadVideo = [[SNDBManager currentDataBase] queryDownloadVideoByVID:self.playingVideoModel.vid];
        if (!!downloadVideo && downloadVideo.state == SNVideoDownloadState_Successful && downloadVideo.localRelativePath.length > 0) {
            return YES;
        }
        
        //正在播放离线视频时，不用提示无网时不能播视频
        if (self.videoPlayerRefer != WSMVVideoPlayerRefer_OfflinePlay) {
            //回调进行Toast无网提示
            if ([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
                [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_NotReachable forPlayerView:self];
            }
            SNDebugLog(@"canContinueToPlayWhenNetworkChanged: NotReachable");
        }
        return NO;//不能继续播放
    }
    //有网
    else {
        //判断网络类型
        //非Wifi网络(ReachableViaWWAN)
        if (networkStatus == ReachableViaWWAN ||
            networkStatus == ReachableVia2G ||
            networkStatus == ReachableVia3G ||
            networkStatus == ReachableVia4G) {
            //2G/3G下离线播放不做任何提示
            if (self.videoPlayerRefer == WSMVVideoPlayerRefer_OfflinePlay) {
                return YES;
            }
            //无论以前有没有提醒过，只要网络变化为2G/3G网络后都一定要提醒(阻断式或Toast)
            //没有阻断式提醒过
            else if (!([WSMVVideoHelper sharedInstance].bContinueToPlayVideoIn2G3G)) {
                //回调进行阻断式提示
                if([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]){
                    [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_Block forPlayerView:self];
                }
                return NO;//不能继续播放
            }
            //有阻断式提醒过
            else {
                //回调进行Toast2G/3G播放提示并暂停
                if ([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
                    [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_NetChangedTo2G3GToast forPlayerView:self];
                }
                [self pause];
                self.playingVideoModel.hadEverAlert2G3G = YES;
                return NO;//不可以继续播放
            }
        }
        //Wifi网络
        else {
            SNDebugLog(@"canContinueToPlayWhenNetworkChanged: Continue to play");
            return YES;//可以继续正常播放
        }
    }
}

#pragma mark -
- (void)handleReachabilityChangedNotification:(NSNotification *)notification {
    Reachability *currentReach = [notification object];
    NSParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    if (currentReach == [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability]) {
        //视频播放的断网逻辑, 改变为视频SDK处理, 暂时不操作
        //SNDebugLog(@"WSMVVideoPlayerView, netStatus changed to %d", currentNetStatus);
//        [self canContinueToPlayWhenNetworkChanged:currentNetStatus];
        //        [self refreshPosterIfNeeded:currentNetStatus];
        
        if (![self isPlaying]) {
            if ([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
                [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_None forPlayerView:self];
            }
            SNDebugLog(@"canContinueToPlayWhenNetworkChanged: Not playing");
            return;//都没有正在播放肯定不能继续播放呀(@-@)
        }
        // MARK: - -------- 视频SDK未做wifi切换2G,3G网络提醒,暂时这样处理(弹窗提醒用户) ----------
        NetworkStatus currentNetStatus = [currentReach currentReachabilityStatus];
        if (currentNetStatus == ReachableViaWWAN ||
            currentNetStatus == ReachableVia2G ||
            currentNetStatus == ReachableVia3G ||
            currentNetStatus == ReachableVia4G) {
            //无论以前有没有提醒过，只要网络变化为2G/3G网络后都一定要提醒(阻断式或Toast)
            //没有阻断式提醒过
             if (!([WSMVVideoHelper sharedInstance].bContinueToPlayVideoIn2G3G)) {
                //回调进行阻断式提示
                if([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]){
                    [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_Block forPlayerView:self];
                }
            } else { //有阻断式提醒过
                //回调进行Toast2G/3G播放提示并暂停
                if ([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
                    [self.delegate alert2G3GIfNeededByStyle:WSMV2G3GAlertStyle_NetChangedTo2G3GToast forPlayerView:self];
                }
                [self pause];
                self.playingVideoModel.hadEverAlert2G3G = YES;
            }
        }

	}
}

- (void)onReceiveNotifyToBack {
    if ([self isFullScreen]) {
        [self exitFullScreen];
    }
}

- (void)handleThemeDidChangeNotification:(NSNotification *)notification {
    self.poster.backgroundColor = [self isFullScreen] ? [UIColor blackColor] : kVideoPlayerPosterBgColor();
    self.defaultLogo.image = [self isFullScreen] ? [UIImage imageNamed:@"videoplayer_fullscreen_posterlogo.png"] : [UIImage imageNamed:@"videoplayer_nonfullscreen_posterlogo.png"];
    [self.posterPlayBtn setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"] forState:UIControlStateNormal];
}

#pragma mark - Private - About Statisic
- (void)cachePlayedTime {
    NSTimeInterval _currentPlaybackTime = _moviePlayer.currentPlaybackTime;
    if (isnan(_currentPlaybackTime)) {
        _currentPlaybackTime = 0;
    }
    NSString *_playingURLString = _moviePlayer.contentURL.absoluteString;
    NSInteger _segmentOrder = [self.playingVideoModel.sources indexOfObject:_playingURLString];
    [self.playingVideoModel.playedTimeMap setValue:@(_currentPlaybackTime) forKey:[NSString stringWithFormat:@"%ld", _segmentOrder]];
}

- (void)cacheTotalTime:(NSTimeInterval)totalTime {
    NSString *_playingURLString = _moviePlayer.contentURL.absoluteString;
    NSInteger _segmentOrder = [self.playingVideoModel.sources indexOfObject:_playingURLString];
    NSString *_key = [NSString stringWithFormat:@"%ld", _segmentOrder];
    
    NSNumber *_cachedDurationNumber = [self.playingVideoModel.totalTimeMap objectForKey:_key];
    if (!_cachedDurationNumber || (totalTime > [_cachedDurationNumber doubleValue])) {
        [self.playingVideoModel.totalTimeMap setValue:@(totalTime) forKey:_key];
    }
}

//统计视频PV
- (void)statPV {
    if ([_delegate respondsToSelector:@selector(statVideoPV:playerView:)]) {
        [_delegate statVideoPV:self.playingVideoModel playerView:self];
    }
}

//统计视频VV
- (void)statVV {
    if ([self.delegate respondsToSelector:@selector(statVideoVV:playerView:)]) {
        [self.delegate statVideoVV:self.playingVideoModel playerView:self];
    }
    
    //---之所以在这里会cacheSV数据、以前统计AV数据，是因为它们为了依赖统计VV的这个时间点
    //累计连播数据以便在调起播放器页不再使用播放器时统计连播
    if ([self.delegate respondsToSelector:@selector(cacheVideoSV:playerView:)]) {
        [self.delegate cacheVideoSV:self.playingVideoModel playerView:self];
    }
    //统计播放器行为
    if ([self.delegate respondsToSelector:@selector(statVideoAV:playerView:)]) {
        [self.delegate statVideoAV:self.playingVideoModel playerView:self];
    }
    //---
    
    //视频前贴面广告的VV统计
    if ([self canStatVideoAdVVWhenStop]) {
        [self statVideoAdVV];
    }
}

//统计加载时长
- (void)statFFL:(BOOL)succeededToLoad {
    if ([self.delegate respondsToSelector:@selector(statFFL:playerView:succeededToLoad:)]) {
        [self.delegate statFFL:self.playingVideoModel playerView:self succeededToLoad:succeededToLoad];
    }
}

#pragma mark - 视频广告统计
//加载统计
- (void)statVideoAdLoad {
    SNStatLoadInfo *videoAdStatData = [[SNStatLoadInfo alloc] init];
    //todo: adIDArray的值需要视频SDK回传
    videoAdStatData.adIDArray = nil;
    videoAdStatData.objType = kObjTypeOfVideoAd;//视频前贴广告
    videoAdStatData.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    videoAdStatData.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    videoAdStatData.objLabel = SNStatInfoUseTypeOutTimelineAd;//商业广告非流内（视频前贴广告传此值）
    NSTimeInterval videoAdPlayedTime = _moviePlayer.advertDuration - _moviePlayer.advertCurrentPlaybackTime;
    if (videoAdPlayedTime < 0) {
        videoAdPlayedTime = 0;
    }
    videoAdStatData.videoAdPlayedTime = videoAdPlayedTime*1000;//毫秒
    videoAdStatData.videoAdTotalTime = _moviePlayer.advertDuration * 1000;//毫秒
    [[WSMVVideoStatisticManager sharedIntance] statVideoAdLoad:videoAdStatData];
}

- (void)statVideoAdVV {
    SNStatExposureInfo *videoAdStatData = [[SNStatExposureInfo alloc] init];
    //todo: adIDArray的值需要视频SDK回传
    videoAdStatData.adIDArray = nil;
    videoAdStatData.objType = kObjTypeOfVideoAd;//视频前贴广告
    videoAdStatData.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    videoAdStatData.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    videoAdStatData.objLabel = SNStatInfoUseTypeOutTimelineAd;//商业广告非流内（视频前贴广告传此值）
    NSTimeInterval videoAdPlayedTime = _moviePlayer.advertDuration - _moviePlayer.advertCurrentPlaybackTime;
    if (videoAdPlayedTime < 0) {
        videoAdPlayedTime = 0;
    }
    videoAdStatData.videoAdPlayedTime = videoAdPlayedTime * 1000;//毫秒
    videoAdStatData.videoAdTotalTime = _moviePlayer.advertDuration * 1000;//毫秒
    [[WSMVVideoStatisticManager sharedIntance] statVideoAdVV:videoAdStatData];
}

- (void)statVideoAdClick {

    SNStatClickInfo *videoAdStatData = [[SNStatClickInfo alloc] init];
    //todo: adIDArray的值需要视频SDK回传

    videoAdStatData.adIDArray = nil;
    videoAdStatData.objType = kObjTypeOfVideoAd;//视频前贴广告
    videoAdStatData.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    videoAdStatData.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    videoAdStatData.objLabel = SNStatInfoUseTypeOutTimelineAd;//商业广告非流内（视频前贴广告传此值）
    NSTimeInterval videoAdPlayedTime = _moviePlayer.advertDuration - _moviePlayer.advertCurrentPlaybackTime;
    if (videoAdPlayedTime < 0) {
        videoAdPlayedTime = 0;
    }
    videoAdStatData.videoAdPlayedTime = videoAdPlayedTime * 1000;//毫秒
    videoAdStatData.videoAdTotalTime = _moviePlayer.advertDuration * 1000;//毫秒
    [[WSMVVideoStatisticManager sharedIntance] statVideoAdClick:videoAdStatData];
}

#pragma mark - WSMVVideoPlayerViewObserverDelegate - About Ad play
- (void)adDidLoading {
    if (_moviePlayer.isLoadAdvert) {
        [self.loadingMaskView startLoadingViewAnimation];
        [self statVideoAdLoad];
    }
}

- (void)didGetAdInfo:(id)adInfo {
    _moviePlayer.isLoadAdvert = YES;
    if (_moviePlayer.isLoadAdvert && [adInfo isKindOfClass:[NSString class]]) {
        [self hideTitleAndControlBarWithAnimation:NO];
        [SNVideoAdMaskHelper showAdMaskInPlayer:self withAdInfo:adInfo];
        self.copyrightMsgView.alpha = 0;
        self.poster.hidden = YES;
        self.posterPlayBtn.hidden = YES;
        
        [SNVideoAdMaskHelper setShowFullscreenButton:YES inVideoPlayer:self];
        [SNVideoAdMaskHelper updateFullscreenButtonStateInVideoPlayer:self];
    }
}

- (void)adDidPlay {
    [self hideTitleAndControlBarWithAnimation:NO];
    if (_moviePlayer.isLoadAdvert) {
        [self.loadingMaskView stopLoadingViewAnimation];
    }
}

- (void)adDidFinishPlaying {
    if (_moviePlayer.isLoadAdvert) {
        [self showTitleAndControlBarWithAnimation:NO];
        
        [self.loadingMaskView stopLoadingViewAnimation];
        if (self.playingVideoModel.playType == WSMVVideoPlayType_HTML5) {
            self.copyrightMsgView.alpha = 1;
        } else {
            self.copyrightMsgView.alpha = 0;
        }
        
        self.poster.hidden = NO;
        self.posterPlayBtn.hidden = YES;
        
        [self statVideoAdVV];
    }
}

- (void)adDidPlayWithError {
    if (_moviePlayer.isLoadAdvert) {
        [self showTitleAndControlBarWithAnimation:NO];
        
        [self.loadingMaskView stopLoadingViewAnimation];
        if (self.playingVideoModel.playType == WSMVVideoPlayType_HTML5) {
            self.copyrightMsgView.alpha = 1;
        } else {
            self.copyrightMsgView.alpha = 0;
        }
        [self showPoster];
        
        [self statVideoAdVV];
    }
}

#pragma mark - WSMVVideoPlayerViewObserverDelegate - About Video play
- (void)videoIsLoading {
    [self.loadingMaskView startLoadingViewAnimation];
    
    [self showTitleAndControlBarWithAnimation:NO];
    self.posterPlayBtn.hidden = YES;
}

- (void)didFinishFirstFrameLoadOnMilliseconds:(NSTimeInterval)milliseconds
                                      success:(BOOL)success {
    //FFL统计
    [[WSMVVideoStatisticManager sharedIntance] cacheFFLTimeCost:milliseconds];
    [self statFFL:success];
        //@qz 发送播放成功上报的请求 2017.11.22
//        if ([self checkIfNeccessaryToReport]) {
//            [self reportSiteRequest];
//        }
}

- (void)videoPlaybackDurationAvailable {
    [self.loadingMaskView startLoadingViewAnimation];
    
    NSString *breakPointKey = self.playingVideoModel.vid ? : self.playingVideoModel.siteInfo.siteId;
    float breakpoint = [[SNVideoBreakpointManager sharedInstance] getBreakpointByVid:breakPointKey];
    if (_moviePlayer.currentPlaybackTime < breakpoint) {
        if (_moviePlayer.duration <= breakpoint || breakpoint < 0.f) {
            breakpoint = 0.f;
        }
        if (_moviePlayer.currentPlayMedia.sourceType != SHLiveMedia) {
            [_moviePlayer seekTo:breakpoint];
        }
    }
}

- (void)videoDidPlay {
    self.isAllVideoSegmentsFinished = NO;
    
    self.copyrightMsgView.alpha = 0;
    self.poster.hidden = YES;
    self.posterPlayBtn.hidden = YES;
    
    [self addPureModeTimerIfNeeded];
    [self addPlaybackTimeObserverIfNeeded];
    [self setControlBarPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Playing];
    [self.loadingMaskView stopLoadingViewAnimation];
    
    [self autoVideoDidPlay];
    
    [SNNotificationManager postNotificationName:kSNVideoPlayerDidPlayNotification object:nil userInfo:nil];
}

- (BOOL)checkIfNeccessaryToReport{
    BOOL _isSend = NO;
    if(_retryedVidArray && [_retryedVidArray count]){
        for(NSString * value in _retryedVidArray){
            if ([_playingVideoModel.vid integerValue] == [value integerValue]) {
                //必须是发送过checksite请求且重新播放过的视频，才有上报的必要。
                if ([_reportedVidArray count] == 0) {
                    return YES;
                }
                for(NSString * reportVid in _reportedVidArray){
                    //已经上报过的vid，就不用再上报了.
                    if ([_playingVideoModel.vid integerValue] == [reportVid integerValue]){
                        return NO;
                    }
                    NSInteger index = [_reportedVidArray indexOfObject:reportVid];
                    if (index == [_reportedVidArray count]-1) {
                        if ([_playingVideoModel.vid integerValue] != [reportVid integerValue]){
                            return YES;
                        }
                    }
                }
            }
        }
    }
    return _isSend;
}

- (void)reportSiteRequest {
    NSString *playFrom = @"1";//频道流
    if (self.isFromNewsContent) {
        playFrom = @"2";//正文页
    }
    NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithDictionary:
                                    @{@"playFrom": playFrom,
                                      @"newsId": [_playingVideoModel.newsId length] ? _playingVideoModel.newsId : @"",
                                      @"newsType": [_playingVideoModel.newsType length] ? _playingVideoModel.newsType : @"",
                                      @"vid": [_playingVideoModel.vid length] ? _playingVideoModel.vid : @"",
                                      @"site": [_playingVideoModel.siteInfo.site2 length] ? _playingVideoModel.siteInfo.site2 : @"",
                                      @"status": [_playingVideoModel.title length] ? _playingVideoModel.title : @"",
                                      @"tvName": [_playingVideoModel.title length] ? _playingVideoModel.title : @""}];
    if ([playFrom intValue] == 1) {
        [params setObject:(_playingVideoModel.channelId ? _playingVideoModel.channelId : @"") forKey:@"channelId"];
    }
    SNVideoReportRequest *retryReqeust = [[SNVideoReportRequest alloc] initWithDictionary:params];
    [retryReqeust send:^(SNBaseRequest *request, id responseObject) {
        [self.reportedVidArray addObject:[NSString stringWithFormat:@"%@",_playingVideoModel.vid]];
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self.reportedVidArray addObject:[NSString stringWithFormat:@"%@",_playingVideoModel.vid]];
        //@qz 元甲说不管成功还是失败，都不用再次上报了。
    }];
}

- (void)videoDidSeekForward {
    [self statSeekingForwardAction];
}

- (void)videoDidSeekBackward {
    [self statSeekingBackwardAction];
}

- (void)videoDidStall {
    [self.loadingMaskView stopLoadingViewAnimation];
    [self.loadingMaskView startLoadingViewAnimation];
}

- (void)playbackTimeDidChanged {
    [self updatePlaybackProgress];
}

- (void)updatePlaybackProgress {
    NSTimeInterval _duration = _moviePlayer.duration;
    NSTimeInterval _currentPlaybackTime = _moviePlayer.currentPlaybackTime;
    if (isnan(_duration) || isnan(_currentPlaybackTime)) {
        [self videoDidFinishByPlaybackError];
        [self autoVideoDidFinishByPlaybackError];
        return;
    }
    
    NSTimeInterval _playableDuration = _moviePlayer.playableDuration;
    if (_playableDuration > _duration) {
        //这里为了容错：有些视频的playableDuration比duration大
        _duration = _playableDuration;
    }
    
    if (isnan(_duration)) {
        return;
    }
    
    [self callbackWhenNextVideoWillPlayIn5SecondsOnDuration:_duration andCurrentPlaybackTime:_currentPlaybackTime];
    
    //存储视频总时长
    [self cacheTotalTime:_duration];
    
    [self updateToCurrentTime:_currentPlaybackTime duration:_duration];
    [self updateBuffer:_playableDuration duration:_duration];
    
    //为了容错，某些视频的currentTime永远小于totalTime，提前一秒上报视频结束播放
    int currentTime = (int)_currentPlaybackTime + 1;
    int totalTime   = (int)_duration;
    if (currentTime == totalTime) {
        if ([self.delegate respondsToSelector:@selector(didPlayToEnd)]) {
            [self.delegate didPlayToEnd];
        }
    }
}

- (void)callbackWhenNextVideoWillPlayIn5SecondsOnDuration:(NSTimeInterval)duration andCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    if (!(self.playingVideoModel.callbackWillPlayNextIn5Seconds)) {
        if (isnan(duration) || isnan(currentPlaybackTime)) {
            return;
        }
        
        BOOL willPlayIn5Seconds = (duration - currentPlaybackTime) <= 5;
        NSInteger nextVideoIndex = self.playingIndex + 1;
        willPlayIn5Seconds = willPlayIn5Seconds && (nextVideoIndex < self.playlist.count);
        if (willPlayIn5Seconds) {
            self.playingVideoModel.callbackWillPlayNextIn5Seconds = willPlayIn5Seconds;
            SNVideoData *nextVideo = [self.playlist objectAtIndex:nextVideoIndex];
            if ([self.delegate respondsToSelector:@selector(willPlayNextVideoIn5Seconds:)]) {
                [self.delegate willPlayNextVideoIn5Seconds:nextVideo];
            }
        }
    }
}

- (void)videoDidPause {
    [self removePureModeTimer];
    self.isPureMode = self.titleView.alpha == 0;
    
    [self.loadingMaskView stopLoadingViewAnimation];
    [self setControlBarPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Pause];
}

//TODO:这个状态什么意思？
- (void)videDidInterrupted {
    [self removePlaybackTimeObserver];
    
    [self.loadingMaskView stopLoadingViewAnimation];
    [self showPoster];
}

- (void)videoDidStop {
}

- (void)videoDidFinishByPlaybackEnd {
    [self removePlaybackTimeObserver];
    
    //删除数据库中这条视频的断点信息
    if (![[SNVideoBreakpointManager sharedInstance] deleteBreakpointByVid:self.playingVideoModel.vid]) {
        NSLogInfo(@"删除当前视频断点信息失败");
    }
    
    //累加已播放时间(一定是在调用[_moviePlayerlayer stop], 不然方法内取到的currentPlayTime是0)
    [self cachePlayedTime];
    
    [_moviePlayer stop];
    
    if (self.videoWindowType == SNVideoWindowType_small) {
        //小窗播放完重置到初始画面暂停
        [self removeNotificationObservers];
        [self reset];
        [self showTitleAndControlBarWithAnimation:YES];
        return;
    }
    //正常播放完片段集或单一源
    if ((self.currentVideoSegmentIndex + 1) >= self.playingVideoModel.sources.count) {
        //当前videoModel已无视频源可播
        [self statVV];
    }

    if (self.isAllVideoSegmentsFinished) {
        return;
    }
    
    //播放下一视频片断
    if (!!(self.playingVideoModel) &&
        (self.currentVideoSegmentIndex + 1) < self.playingVideoModel.sources.count) {
        //=======================
        //重置播放上一片断的一些状态和View
        [self removePlaybackTimeObserver];
        [self setControlBarPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Stop];
        [self resetControlBarTimeLabel];
        [self.loadingMaskView stopLoadingViewAnimation];
        
        //=======================
        //加载接下片断的poster并显示
        (self.currentVideoSegmentIndex)++;
        UIImage *_thumbnailImg = [self.thumbnailsOfSegments objectForKey:[NSString stringWithFormat:@"%@_%ld", self.playingVideoModel.vid, (long)self.currentVideoSegmentIndex]];
        if (!!_thumbnailImg) {
            self.poster.image = _thumbnailImg;
        } else {
            [self setPosterImage];
        }
        [self showPoster];
        self.posterPlayBtn.hidden = YES;
        
        //=======================
        //播放接下的片断
        [self loadVideoSourceAndReadyToPlay:self.playingVideoModel];
    }
    //自动连播下一视频，或播放列表中不可连播则连播相关视频
    else if (((self.playingIndex+1) < self.playlist.count) ||
             [self recommendVideos].count > 0) {
        [self removeNotificationObservers];
        [self reset];
        
        if ([self shouldShowTitleAndControlBarBeforePlayNextVideo]) {
            [self showTitleAndControlBarWithAnimation:YES];
        }
        
        //非全屏模式时，如果支持显示相关视频在播放区域则显示,如果5秒后没有人工干预则自动连播；如果不支持则直接连播
        if (![self isFullScreen]) {
            if (self.supportRelativeVideosViewInNonFullscreenMode) {
                [self playNextVideoWithDelay];
            } else {
                [self playNextVideo];
            }
        }
        //全屏模式时，直接连播
        else {
            [self playNextVideo];
        }
    }
    //没有可连播的视频了
    else {
        //重置播放器状态
        [self removeNotificationObservers];
        [self reset];
        [self showTitleAndControlBarWithAnimation:YES];
        
        [self noNextVideoToPlay];
    }
}

- (BOOL)shouldShowTitleAndControlBarBeforePlayNextVideo {
    return NO;
}

#pragma mark - WSMVVideoPlayerViewObserverDelegate - 2017.11.20新加

- (BOOL)checkIfNeccessaryToRetry{
    for(NSString *vid in _retryedVidArray){
        if ([vid integerValue] == [self.playingVideoModel.vid integerValue]) {
            return NO;
        }
    }
    return YES;
}

- (void)playbackRequestErrorCallBack:(NSDictionary *)errorInfo {
    if (![self checkIfNeccessaryToRetry]) {
        return;
    }
    
    NSString *sdkErrorCode = [NSString stringWithFormat:@"%@",errorInfo[@"errorCode"]];
    
    //if ([sdkErrorCode intValue] != 10053) return; 服务器做哪种code需要切site的逻辑
    //发送重试网络请求
    NSDictionary *params = @{@"vid": [_playingVideoModel.vid length] ? _playingVideoModel.vid : @"",
                             @"site": [_playingVideoModel.siteInfo.site2 length] ? _playingVideoModel.siteInfo.site2 : @"",
                             @"errorCode": sdkErrorCode,
                             @"newsId": [_playingVideoModel.newsId length] ? _playingVideoModel.newsId : @"",
                             @"tvName": [_playingVideoModel.title length] ? _playingVideoModel.title : @"",
                             };
    SNVideoRetryRequest *retryReqeust = [[SNVideoRetryRequest alloc] initWithDictionary:params];
    self.isRetryLoading = YES;
    [retryReqeust send:^(SNBaseRequest *request, id responseObject) {
        if (self.isRetryLoading) {
            self.isRetryLoading = NO;
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            NSDictionary *retryDic = responseObject[@"data"];
            if (retryDic && [retryDic count] && ([retryDic[@"retry"] isKindOfClass: [NSNumber class]]||[retryDic[@"retry"] isKindOfClass:[NSString class]]))
            {
                if ([retryDic[@"retry"] integerValue] == 1) {
                    if (_playingVideoModel) {
                        NSString *retrySite = [NSString stringWithFormat:@"%@",retryDic[@"site"]];
                        [_playingVideoModel.siteInfo setSite2:retrySite];
                        //[_playingVideoModel.siteInfo setSite2:@"2"];
                        if (retryDic[@"vid"]) {
                            NSString *retryVid = [NSString stringWithFormat:@"%@",retryDic[@"vid"]];
                            if ([retryVid length] && [retryVid integerValue] != _playingVideoModel.vid.integerValue) {
                                [_playingVideoModel setVid:retryVid];
                            }
                        }
//                        if (self.isFromAutoPlayVideo) {
//                            self.playingVideoModel.siteInfo.siteId = @"91113990";
//                        }
                        [_retryedVidArray addObject:[NSString stringWithFormat:@"%@",_playingVideoModel.vid]];
                        [self didTapPlayBtnInPosterToPlay];
                    }else{
                        //NSLog(@"model空了");
                    }
                }
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        
    }];
}

- (void)videoDidFinishByPlaybackError {
    //---记录此视频播放失败，以便在再次播放时对失败的视频不播放广告
    //if(self.isRetryLoading)  return;
    
    [self recordPlayingFailVideo];
    //---
    
    NetworkStatus _netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (_netStatus != NotReachable) {
        if ([self isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"video_is_unavailable_pls_try_recommend_videows", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"video_is_unavailable_pls_try_recommend_videows", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    } else {
        if ([self isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
    
    //统计VV并重置状态
    [self statVV];
    [self removeNotificationObservers];
    [_moviePlayer stop];
    [self reset];
    [self showTitleAndControlBarWithAnimation:YES];
    if (self.isFromAutoPlayVideo) {
        [SNAutoPlaySharedVideoPlayer forceStopVideo];
    }
    [self clearMoviePlayerController];
}

- (void)videoDidFinishByUserExited {
    //统计VV并重置状态
    [self statVV];
    [self removeNotificationObservers];
    [_moviePlayer stop];
    [self reset];
    [self showTitleAndControlBarWithAnimation:YES];
}

- (void)reset {
    [SNVideoAdMaskHelper dismissMaskForPlayer:self];
    
    [self.thumbnailsOfSegments removeAllObjects];
    self.currentVideoSegmentIndex = 0;
    self.isAllVideoSegmentsFinished = YES;
    
    
    [self setPosterImage];
    [self showPoster];
    
    [self removePureModeTimer];
    [self removePlaybackTimeObserver];
    
    [self setControlBarPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Stop];
    [self resetControlBarTimeLabel];
    
    [self.loadingMaskView stopLoadingViewAnimation];
}

- (void)showPoster {
    self.poster.hidden = NO;
    self.posterPlayBtn.hidden = NO;
}

- (void)refreshPosterIfNeeded:(NetworkStatus)networkStatus {
    if (!(self.defaultLogo.hidden) && networkStatus != NotReachable) {
        [self setPosterImage];
    }
}

#pragma mark - WSMVVideoControlBarDelegate
- (void)didTapPlayBtnInControlBarToPlay {
    if (self.playingVideoModel.playType == WSMVVideoPlayType_HTML5) {
        [self toWapPage];
        return;
    }
    if (_moviePlayer == nil) {
        self.moviePlayer.view.frame = self.bounds;
        [self getMoviePlayer].movieScaleMode = SHMovieScaleModeAspectFit;
    }
    [self playCurrentVideo];
}

- (void)didTapPlayBtnInControlBarToPause {
    [self statPauseAction];
    [self pause];
}

- (void)didTapDownloadBtn {
    if (![[WSMVVideoHelper sharedInstance] canDownload:self.playingVideoModel withPlayerView:self]) {
        return;
    }
    
    [self statDownloadAction];
    
    //---为离线完成后离线播放做准备
    SNVideoData *timelineVideo = [[SNDBManager currentDataBase] getVideoTimeLineByVid:self.playingVideoModel.vid];
    if (!timelineVideo) {
        if (self.playingVideoModel.channelId.length <= 0) {
            self.playingVideoModel.channelId = kDefaultChannelIdForVideoDownload;
        }
        [[SNDBManager currentDataBase] addVideoData:self.playingVideoModel channelId:self.playingVideoModel.channelId];
    }
    //---
    
    SNVideoDataDownload *downloadVideo = [[SNVideoDataDownload alloc] init];
    downloadVideo.title = self.playingVideoModel.title;
    downloadVideo.videoSources = [self.playingVideoModel.videoUrl toJsonString];
    downloadVideo.vid = self.playingVideoModel.vid;
    downloadVideo.state = SNVideoDownloadState_Waiting;
    downloadVideo.poster = self.playingVideoModel.poster_4_3;
    [[SNVideoDownloadManager sharedInstance] downloadVideoInThread:downloadVideo];
     //(downloadVideo);
    
    if ([self isFullScreen]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
    } else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
    }
}

- (void)didTapShareBtn {
    if ([self isFullScreen]) {
        if ([self.delegate respondsToSelector:@selector(willShareVideo:fromPlayer:)]) {
            [self.delegate willShareVideo:self.playingVideoModel fromPlayer:self];
        }
    }
}

- (void)didTapNextVideoBtn {
    NSInteger _nextIndex = self.playingIndex + 1;
    if (_nextIndex > self.playingIndex &&
        _nextIndex < self.playlist.count) {
        //如果没有后一个视频了，不要停播当前视频
        [self stop];
    }
    [self playNextVideo];
}

- (void)didTapPreviousVideoBtn {
    NSInteger _preIndex = self.playingIndex - 1;
    if (_preIndex < self.playingIndex &&
        _preIndex >= 0) {
        //如果没有前一个视频了，不要停播当前视频
        [self stop];
    }
    [self playPreVideo];
}

- (void)showVolumnBarMask {
    [UIView animateWithDuration:0.2 animations:^{
        _controlBarFullScreen.volumeBtn.selected = YES;
        self.volumnBarMask.alpha = 1;
    }];
}

- (void)hideVolumnBarMask {
    [UIView animateWithDuration:0.2 animations:^{
        if (![_controlBarFullScreen isKindOfClass:[SNTimelineVideoControlBar_FullScreen class]]) {
            _controlBarFullScreen.volumeBtn.selected = NO;
        }
        self.volumnBarMask.alpha = 0;
    }];
}

#pragma mark - WSSliderDelegate
- (void)didTouchDown:(WSMVSlider *)slider {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doEnterPureMode) object:nil];
    
    NSTimeInterval playerDuration = [_moviePlayer duration];
    if (playerDuration <= 0) {
        return;
    }
}

- (void)didTouchMove:(WSMVSlider *)slider {
    NSTimeInterval playerDuration = [_moviePlayer duration];
    if (playerDuration <= 0) {
        return;
    }
    
    CGFloat _progressValue = slider.progressValue;
    double _tempSeconds = (_progressValue - slider.minimumValue) / (slider.maximumValue - slider.minimumValue) * playerDuration;
    [self updateToCurrentTime:_tempSeconds duration:playerDuration];
}

- (void)didTouchUp:(WSMVSlider *)slider {
    NSTimeInterval duration = [_moviePlayer duration];
    if (duration <= 0) {
        return;
    }

    [[SNVideoBreakpointManager sharedInstance] deleteBreakpointByVid:self.playingVideoModel.vid];
    float minValue  = [slider minimumValue];
    float maxValue  = [slider maximumValue];
    float value     = [slider progressValue];
    double time = duration * (value - minValue) / (maxValue - minValue);
    [_moviePlayer seekTo:time];
    [self playCurrentVideo];
}

- (void)didTouchCancel:(WSMVSlider *)slider {
    [self didTouchUp:slider];
}

#pragma mark - WSMVVideoTitleViewDelegate
- (BOOL)isFullScreen {
    [[NSUserDefaults standardUserDefaults] setBool:self.isFullScreenModel forKey:kAticleVideoIsFullScreenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return self.isFullScreenModel;
}

- (void)didTapRecommendBtn {
    [self statRecommendAction];
    [self showRecommendVideosView];
}

#pragma mark - WSRecommendVideosViewDelegate
//只会在全屏模式下回调到此方法
- (void)didHideRecommendVideosView {
    [UIView animateWithDuration:0.2 animations:^{
        //显示titleView和全屏的controlBar，非全屏的controlBar肯定不能显示出来
        self.titleView.alpha = 1;
        _controlBarFullScreen.alpha = 1;
        _controlBarNonFullScreen.alpha = 0;
        //
        
        self.isPureMode = (self.titleView.alpha == 0);
        self.enterPureModeFinished = YES;
    }];
}

- (NSArray *)recommendVideos:(BOOL)more {
    if ([self.delegate respondsToSelector:@selector(recommendVideosOfVideoModel:more:)]) {
        return [self.delegate recommendVideosOfVideoModel:self.playingVideoModel more:more];
    } else {
        return nil;
    }
}

- (NSString *)playingVID {
    return self.playingVideoModel.vid;
}

- (void)switchToPlayRecommendVideo:(SNVideoData *)video
                 inRecommendVideos:(NSArray *)recommendVideos {
    self.isPlayingRecommendList = YES;
    [self initPlaylist:recommendVideos initPlayingIndex:[recommendVideos indexOfObject:video]];
    [self playCurrentVideo];
    [self hideTitleAndControlBarWithAnimation:NO];
}

#pragma mark - WSMVPlayerCopyrightMsgView
- (void)toWapPage {
    [self exitFullScreen];
    
    NSString *_url = self.playingVideoModel.wapUrl;
    if (_url.length <= 0) {
        if ([self isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"cant_play_in_html5_try_recommendlist", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"cant_play_in_html5_try_recommendlist", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
        }
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(toWapPageOf:)]) {
        [_delegate toWapPageOf:self.playingVideoModel];
    }
}

- (void)didTapRelativeVideo:(SNVideoData *)relativeVideo {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playNextVideo) object:nil];
    
    self.isPlayingRecommendList = YES;
    NSArray *_videos = self.relativeVideosView.relativeVideos;
    [self initPlaylist:_videos initPlayingIndex:[_videos indexOfObject:relativeVideo]];
    [self playCurrentVideo];
}

- (void)didScrollRelativeVideosView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(playNextVideo)
                                               object:nil];
}

#pragma mark -
- (BOOL)didPlayFailAtLastTime {
    BOOL didPlayFailAtLastTime = NO;
    
    if (self.playingVideoModel.vid.length <= 0) {
        return didPlayFailAtLastTime;
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *vidOfLastPlayingFail = [userDefaults stringForKey:kVideoIDOfLastPlayingFail];
        
        didPlayFailAtLastTime = [vidOfLastPlayingFail isEqualToString:self.playingVideoModel.vid];
        if (didPlayFailAtLastTime) {
            [self resetLastPlayingFailState];
        }
        
        return didPlayFailAtLastTime;
    }
}

- (void)recordPlayingFailVideo {
    NSString *vid = self.playingVideoModel.vid;
    if (vid.length > 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:vid forKey:kVideoIDOfLastPlayingFail];
        [userDefaults synchronize];
    }
}

- (void)resetLastPlayingFailState {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:kVideoIDOfLastPlayingFail];
    [userDefaults synchronize];
}

#pragma mark - FULLSCREEN MODE
- (void)toFullScreen {
    if ([self isFullScreen]) {
        return;
    }
    
    if (self.isFullscreenAnimating) {
        return;
    }

    self.isFullscreenAnimating = YES;
    self.isFullScreenModel = YES;
    
    //记录全屏前的keyWindow
    self.tmpKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    //用一个空window在后面垫一下，为了避免用户在全屏动画过程中能操作原来App界面中的任意地方而中断全屏动画导致全屏后全屏内容完全透明看不到播放器，只能看到一个横屏后的statusBar
    __block UIWindow *maskWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    maskWindow.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    maskWindow.windowLevel      = UIWindowLevelStatusBar + 1;
    maskWindow.hidden           = NO;
    [maskWindow setRootViewController:[[UIViewController alloc] init]];
    
    self.bottomWindow = maskWindow;

    //统计全屏行为
    [self statFullscreenAction];
    
    //强制横屏
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    //计算全屏将要旋转的弧度
    UIInterfaceOrientation fullScreenOrientation = [self fullScreenOrientation];
    CGFloat rotateRadian = M_PI / 2;
    if (fullScreenOrientation == UIInterfaceOrientationLandscapeLeft) {
        rotateRadian = -(M_PI / 2);
    } else if (fullScreenOrientation == UIInterfaceOrientationLandscapeRight) {
        rotateRadian = M_PI / 2;
    }
    
    //准备全屏的Window，用于承载播放器实例
    self.fullscreenWindow                   = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.fullscreenWindow.windowLevel       = UIWindowLevelStatusBar+2;

    self.fullscreenWindow.backgroundColor   = [UIColor clearColor];
    [self.fullscreenWindow makeKeyAndVisible];

    //记录播放器全屏前的一些现场数据（非全屏时的父View、非全屏时的frame、非全时在父View中的index）
    self.parentView                         = self.superview;
    self.nonFullScreenFrame                 = self.frame;
    self.selfIndexInSuperViewOfNonFullScreen = [self.superview.subviews indexOfObject:self];
    
    //把播放器放到全屏window中（相对坐标转换）
    [self removeFromSuperview];
    CGRect tempFrame = [self.fullscreenWindow convertRect:self.nonFullScreenFrame fromView:self.parentView];
    self.frame = tempFrame;
    [self.fullscreenWindow addSubview:self];
    self.poster.backgroundColor = [UIColor blackColor];
    self.defaultLogo.image = [UIImage imageNamed:@"videoplayer_fullscreen_posterlogo.png"];
    self.defaultLogo.size = CGSizeMake(164.f, 80.f);
    self.defaultLogo.center = self.poster.center;
    
    //隐藏非全屏的control bar
    _controlBarNonFullScreen.alpha = 0;

    //开始全屏动画
    [UIView animateWithDuration:0.5 animations:^{
        self.layer.transform = CATransform3DMakeRotation(rotateRadian, 0.0, 0.0, 1.0);
        self.fullscreenWindow.frame = [UIScreen mainScreen].bounds;
        self.frame = self.fullscreenWindow.bounds;
        _moviePlayer.view.frame = self.bounds;
        self.loadingMaskView.loadingView.center = _moviePlayer.view.center;
    } completion:^(BOOL finished) {
        [self updateViewsInFullScreenMode];
        
        if (self.isPureMode) {
            _controlBarFullScreen.alpha = 0;
        } else {
            _controlBarFullScreen.alpha = 1;
        }
        
        [self showCorrectControlBar:NO];
        
        if ([self isFullScreen]) {
            if (self.isPureMode) {
                _controlBarFullScreen.alpha = 0;
            } else {
                _controlBarFullScreen.alpha = 1;
            }
        }
        
        //===Fixed BUG:
        //===系统为iOS5时，当点播放并loading时进全屏，这时loading被打断，导致在全屏时loading不转了，尽管底层视频加载好后loading会消失.
        //===所以，进全屏后如果loading没有消失，那么重新开启loading动画.
        if (!(self.loadingMaskView.hidden)) {
            [self.loadingMaskView startLoadingViewAnimation];
        }
        //===
        
        maskWindow.hidden = YES;
         //(maskWindow);
        
        [[UIApplication sharedApplication] setStatusBarOrientation:fullScreenOrientation];
        
        self.isFullscreenAnimating = NO;
        
        if ([_delegate respondsToSelector:@selector(didEnterFullScreen:)]) {
            [_delegate didEnterFullScreen:self];
        }
    }];
}

- (UIInterfaceOrientation)fullScreenOrientation {
    return UIInterfaceOrientationLandscapeRight;
}

- (NSString *)getSiteName {
    NSString *siteName = @"";
    if (self.playingVideoModel.siteInfo.siteName.length > 0) {
        siteName = [NSString stringWithFormat:NSLocalizedString(@"timeline_videoplay_sitename", nil), self.playingVideoModel.siteInfo.siteName];
    }
    return siteName;
}

- (void)updateViewsInFullScreenMode {
    [SNVideoAdMaskHelper updateFullscreenButtonStateInVideoPlayer:self];
    [self createFullScreenControllBar];
    self.controlBarFullScreen.siteNameLabel.text = [self getSiteName];
    
    if (_moviePlayer.currentPlaybackRate > 0) {
        if ([self isPaused]) {
            [self setControlBarPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Pause];
        } else {
            [self setControlBarPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Playing];
        }
    } else {
        [self setControlBarPlayBtnStatus:WSMVVideoPlayerPlayBtnStatus_Stop];
    }
    
    //Volumn bar
    if (!_volumnBarMask) {
        UIView *_v = [[UIView alloc] init];
        CGRect _volumnBarFrame = CGRectMake(0, 0, kVolumnBarWidth + 40, kVolumnBarHeight);
        _v.frame = _volumnBarFrame;
        
        CGRect _volumnBtnFrame = [self convertRect:_controlBarFullScreen.volumeBtn.frame fromView:_controlBarFullScreen];
        CGPoint _volumnBtnCenter = [self convertPoint:_controlBarFullScreen.volumeBtn.center fromView:_controlBarFullScreen];
        _v.center = _volumnBtnCenter;
        _v.top = CGRectGetMaxY(_volumnBtnFrame) - kVolumnBarPaddingBottomToVolumnBtnBottom-kVolumnBarHeight;
        
        self.volumnBarMask = [[WSMVVideoVolumnBarMask alloc] initWithFrame:self.bounds
                                                            volumnBarFrame:_v.frame
                                                            volumnBtnFrame:_volumnBtnFrame];
        self.volumnBarMask.delegate = self;
        self.volumnBarMask.alpha = 0;
        [self addSubview:self.volumnBarMask];
        
        _v = nil;
    }
    [self hideVolumnBarMask];
    
    //构造时没有设置frame
    if (CGRectEqualToRect(CGRectZero, self.recommendVideosView.frame)) {
        self.recommendVideosView.frame = self.bounds;
    }
    
    CGFloat _duration = _moviePlayer.duration;
    if (isnan(_duration)) {
        return;
    }
    if (_duration >= 0 && _duration != CGFLOAT_MAX) {
        [self setControlBarTimeLabelTextToNonLive];
    } else {
        [self setControlBarTimeLabelTextToLive];
    }
    
    self.titleView.height = kTitleViewHeight_FullScreen;
    [self.titleView updateViewsInFullScreenMode];
    
    self.defaultLogo.center = self.poster.center;
    //更新copyrightMsgView的frame
    CGRect _copyRightMsgViewFrame = self.bounds;
    self.copyrightMsgView.frame = _copyRightMsgViewFrame;
    [self.copyrightMsgView updateContentToFullscreen];
    
    //Download function
    [self enableActionsOrNot];
    
    self.loadingMaskView.frame = self.bounds;
    self.loadingMaskView.showUserGuide = YES;
    [self.loadingMaskView reset];
    
    [self bringSubviewToFront:self.copyrightMsgView];
}

- (void)updateViewsInSmallScreenMode {
    [SNVideoAdMaskHelper updateFullscreenButtonStateInVideoPlayer:self];
    
    //Create controlBar for fullscreen
    [self createSmallScreenControllBar];
    
    CGFloat _duration = _moviePlayer.duration;
    if (isnan(_duration)) {
        return;
    }
    if (_duration >= 0  && _duration != CGFLOAT_MAX) {
        [self setControlBarTimeLabelTextToNonLive];
    } else {
        [self setControlBarTimeLabelTextToLive];
    }
    
    self.defaultLogo.center = self.poster.center;
    
    //更新copyrightMsgView的frame
    self.copyrightMsgView.frame = self.bounds;
    [self.copyrightMsgView updateContentToNonFullscreen];
    
    [self enableActionsOrNot];
    
    self.loadingMaskView.frame = self.bounds;
    [self.loadingMaskView reset];
    self.loadingMaskView.showUserGuide = NO;
    [self bringSubviewToFront:self.copyrightMsgView];
}

- (void)createFullScreenControllBar {
    if (!_controlBarFullScreen) {
        CGRect _controlBarFrameFullScreen = CGRectMake(0, CGRectGetHeight(self.bounds) - kControlBarHeight_fullscreen, self.bounds.size.width, kControlBarHeight_fullscreen);
        _controlBarFullScreen = [[WSMVVideoControlBar_FullScreen alloc] initWithFrame:_controlBarFrameFullScreen];
        _controlBarFullScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        _controlBarFullScreen.delegate = self;
        _controlBarFullScreen.alpha = 0;
        [self addSubview:_controlBarFullScreen];
    }
}

- (void)createSmallScreenControllBar {
    if (!_controlBarSmallScreen) {
        CGRect _controlBarFrameSmallScreen = CGRectMake(0, CGRectGetHeight(self.bounds)-kControlBarHeight_smallscreen, CGRectGetWidth(self.bounds), kControlBarHeight_smallscreen);
        _controlBarSmallScreen = [[SNTimelineVideoControlBar_NonFullScreen alloc] initWithFrame:_controlBarFrameSmallScreen];
        _controlBarSmallScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        _controlBarSmallScreen.delegate = self;
        _controlBarSmallScreen.alpha = 0;
        [_controlBarSmallScreen disBackgroundView];
        [self addSubview:_controlBarSmallScreen];
    }
}

- (void)exitFullScreen {
    [self exitFullScreenWithAnimation:YES];
    self.poster.backgroundColor = kVideoPlayerPosterBgColor();
    self.defaultLogo.image = [UIImage imageNamed:@"videoplayer_nonfullscreen_posterlogo.png"];
    self.defaultLogo.size = CGSizeMake(140.f, 38.f);
    self.defaultLogo.center = self.poster.center;
}

- (void)exitFullScreenWithAnimation:(BOOL)animated {
    if (![self isFullScreen]) {
        return;
    }
    
    if (self.isFullscreenAnimating) {
        return;
    }
    
    self.isFullscreenAnimating = YES;
    
    [SNNotificationCenter hideMessageImmediatelyForFullScreenWSVideoPlayer];
    
    [self.tmpKeyWindow makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    //隐藏全屏的control bar
    _controlBarFullScreen.alpha = 0;
    
    NSTimeInterval duration = animated ? 0.4 : 0;
    
    _isExitFullFinish = YES;
    [UIView animateWithDuration:duration animations:^{
        self.layer.transform = CATransform3DIdentity;

        UIWindow *_appWindow = (UIWindow *)([UIApplication sharedApplication].delegate.window);
        CGRect _nonFullScreenFrameInWindow = [_appWindow convertRect:self.nonFullScreenFrame fromView:self.parentView];
        self.fullscreenWindow.frame = _nonFullScreenFrameInWindow;
        self.frame = CGRectMake(0, 0, self.nonFullScreenFrame.size.width, self.nonFullScreenFrame.size.height);
        _moviePlayer.view.frame = CGRectMake(0, 0, self.nonFullScreenFrame.size.width, self.nonFullScreenFrame.size.height);
    } completion:^(BOOL finished) {
        _isExitFullFinish = NO;
        
        self.isFullScreenModel = NO;
        if (self.videoWindowType == SNVideoWindowType_small) {
            [self updateViewsInSmallScreenMode];
        } else {
            [self updateViewsInNonScreenMode];
        }
        
        self.fullscreenWindow.hidden = YES;
        [self removeFromSuperview];
        
        self.frame = self.nonFullScreenFrame;
        if (self.selfIndexInSuperViewOfNonFullScreen < self.parentView.subviews.count) {
            [self.parentView insertSubview:self atIndex:self.selfIndexInSuperViewOfNonFullScreen];
        } else {
            [self.parentView addSubview:self];
        }
        
        self.parentView         = nil;
        self.nonFullScreenFrame = CGRectZero;
        self.fullscreenWindow   = nil;
        
        //===Fixed BUG:
        //===系统为iOS5时，当点播放并loading时进全屏，这时loading被打断，导致在全屏时loading不转了，尽管底层视频加载好后loading会消失.
        //===所以，进全屏后如果loading没有消失，那么重新开启loading动画.
        if (!(self.loadingMaskView.hidden)) {
            [self.loadingMaskView startLoadingViewAnimation];
        }
        //===
        
        [self hideVolumnBarMask];
        
        self.isFullscreenAnimating = NO;
        
        if ([_delegate respondsToSelector:@selector(didExitFullScreen:)]) {
            [_delegate didExitFullScreen:self];
        }
        if (_isVideoFinsh == YES) {
            [self closeMiniVideo];
            _isVideoFinsh = NO;
        }
    }];
}

- (void)updateViewsInNonScreenMode {
    [SNVideoAdMaskHelper updateFullscreenButtonStateInVideoPlayer:self];
    
    self.controlBarNonFullScreen.siteNameLabel.text = [self getSiteName];
    
    self.recommendVideosView.alpha = 0;
    [self hideVolumnBarMask];
    
    [self showCorrectControlBar:NO];
    if (self.isPureMode) {
        _controlBarNonFullScreen.alpha = 0;
    } else {
        _controlBarNonFullScreen.alpha = 1;
    }
    
    
    self.titleView.height = kTitleViewHeight_NonFullScreen;
    [self.titleView updateViewsInNonScreenMode];
    
    self.defaultLogo.center = self.poster.center;
    
    //更新copyrightMsgView的frame
    self.copyrightMsgView.frame = self.bounds;
    [self.copyrightMsgView updateContentToNonFullscreen];
    
    [self enableActionsOrNot];
    
    self.loadingMaskView.frame = self.bounds;
    [self.loadingMaskView reset];
    if (_supportSwitchVideoByLRGestureInNonFullscreenMode) {
        self.loadingMaskView.showUserGuide = YES;
    } else {
        self.loadingMaskView.showUserGuide = NO;
    }
    [self bringSubviewToFront:self.copyrightMsgView];
}

- (void)setTab:(NSString *)sourcetab andChannel:(NSString *)newschn {
    [_moviePlayer.currentPlayMedia.extendParams setObject:(nil == sourcetab || sourcetab.length == 0 ? @"0" : sourcetab) forKey:@"currentPlayMedia"];
    [_moviePlayer.currentPlayMedia.extendParams setObject:(nil == newschn || newschn.length == 0 ? @"0" : newschn) forKey:@"newschn"];
}

@end
