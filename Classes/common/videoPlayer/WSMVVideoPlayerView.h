//
//  WSMVVideoPlayerView.h
//  WeSee
//
//  Created by handy wang on 8/14/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVVideoForNews/SVVideoForNews.h>
#import <AVFoundation/AVFoundation.h>

#import "WSMVConst.h"
#import "WSMVVideoVolumnBar.h"
#import "WSMVVideoVolumnBarMask.h"
#import "WSMVVideoControlBar+NonFullScreen.h"
#import "WSMVVideoControlBar_FullScreen.h"
#import "WSMVLoadingMaskView.h"
#import "WSMVVideoHelper.h"
#import "WSMVVideoTitleView.h"
#import "WSMVPlayerCopyrightMsgView.h"
#import "SNVideoObjects.h"
#import "WSMVRelativeVideosView.h"
#import "SNTimelineVideoControlBar+NonFullScreen.h"

#define kVolumnBarWidth   (30.0f)
#define kVolumnBarHeight  (192 / 2.0f)

typedef enum {
    SNVideoWindowType_normal    = 0,
    SNVideoWindowType_small     = 1,
    SNVideoWindowType_full      = 2,
} SNVideoWindowType;

@interface WSMVVideoPlayerView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, weak)id delegate;

@property (nonatomic, assign) WSMVVideoPlayerRefer videoPlayerRefer;

//以下三个public属性是为了在.m文件里的WSMVVideoPlayerViewAudioVolumeChangeListenerCallback方法调用，不是用于外部调用
@property (nonatomic, strong) WSMVVideoVolumnBarMask *volumnBarMask;
@property (nonatomic, strong) WSMVVideoControlBar_NonFullScreen *controlBarNonFullScreen;
@property (nonatomic, strong) WSMVVideoControlBar_FullScreen *controlBarFullScreen;
@property (nonatomic, strong) SNTimelineVideoControlBar_NonFullScreen *controlBarSmallScreen;

//注意:以下属性为子类需要用到，而非方便外部调而申明为public的
@property (nonatomic, strong) WSMVVideoTitleView          *titleView;
@property (nonatomic, strong) WSMVPlayerCopyrightMsgView  *copyrightMsgView;
@property (nonatomic, assign) NSInteger                   playingIndex;
@property (nonatomic, strong) SNVideoData                 *playingVideoModel;
@property (nonatomic, strong) NSMutableArray              *playlist;
@property (nonatomic, strong) SHMoviePlayerController     *moviePlayer;
@property (nonatomic, strong) WSMVRelativeVideosView      *relativeVideosView;
@property (nonatomic, strong) WSMVLoadingMaskView         *loadingMaskView;
@property (nonatomic, strong) UIImageView                 *defaultLogo;
@property (nonatomic, strong) SNWebImageView              *poster;
@property (nonatomic, strong) UIButton                    *posterPlayBtn;
@property (nonatomic, assign) BOOL                        isPlayingRecommendList;
@property (nonatomic, assign) BOOL supportSwitchVideoByLRGestureInNonFullscreenMode;
@property (nonatomic, assign) BOOL supportRelativeVideosViewInNonFullscreenMode;
@property (nonatomic, strong) NSMutableDictionary         *playerActionsStatData;
@property (nonatomic, assign) BOOL                        isPureMode;
@property (nonatomic, assign) BOOL                        enterPureModeFinished;
@property (nonatomic, strong) NSTimer                     *pureModeTimer;
@property (nonatomic, assign) SNVideoWindowType           videoWindowType;
@property (nonatomic, assign) BOOL                        isFromNewsContent;
@property (nonatomic, assign) BOOL                        isFromAutoPlayVideo;
@property (nonatomic, assign) CGRect                      normalFrame;
@property (nonatomic, assign) CGFloat                     originalWidth;
@property (nonatomic, assign) CGFloat                     originalHeight;
@property (nonatomic, assign) BOOL                        isExitFullFinish;
@property (nonatomic, assign) BOOL                        isVideoFinsh;

@property (nonatomic, strong) UIWindow                    *fullscreenWindow;
@property (nonatomic, strong) UIWindow                    *bottomWindow;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate;

- (void)initPlaylist:(NSArray *)playlist
    initPlayingIndex:(NSInteger)playingIndex;
- (void)appendPlaylist:(NSArray *)videos;

- (void)appendRecommendVideos:(NSArray *)videos;
- (void)replaceAllRecommendVieos:(NSArray *)videos;

- (void)playCurrentVideo;
- (void)pause;
- (void)stop;
- (void)forceStop;
- (void)updatePlaybackProgress;

- (void)statVV;

- (BOOL)isFullScreen;
- (void)toFullScreen;
- (void)exitFullScreen;
- (void)exitFullScreenWithAnimation:(BOOL)animated;

- (BOOL)isPlaying;
- (BOOL)canContinueBeforePlayCurrentVideo;
/**
 *  正片是否正处于播放中
 *
 *  @return YES:正片处于播放中；NO:正片没有处于播放中
 */
- (BOOL)isVideoPlayingExcludingAdPlaying;
- (BOOL)isPaused;
- (BOOL)isStopped;
- (BOOL)isLoading;
- (NSTimeInterval)curretnPlayTime;

- (BOOL)isRelativeVideosViewInFirstPage;

- (void)showTitleAndControlBarWithAnimation:(BOOL)animation;
- (void)hideTitleAndControlBarWithAnimation:(BOOL)animation;
- (void)adjustVolumeOrSwitchVideo:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)closeMiniVideo;

//注意:以下方法为子类需要用到，而非方便外部调而申明为public的
- (void)resetModel;
- (void)setPlayingVideoModel:(SNVideoData *)playingVideoModel;
- (void)videoDidPlay;
- (void)playVideo;
- (UIInterfaceOrientation)fullScreenOrientation;
- (void)didTapOnPlayerView:(UITapGestureRecognizer *)gestureRecognizer;
- (void)hideVolumnBarMask;
- (NSString *)getSiteName;
- (void)updateViewsInFullScreenMode;
- (void)updateViewsInSmallScreenMode;
- (void)updateViewsInNonScreenMode;
- (void)noNextVideoToPlay;
- (BOOL)isControlBarSliderHighlighted;
- (void)videoDidPause;
- (void)createFullScreenControllBar;
- (NSString *)posterURL;
- (void)updateTextAfterModelChanged;
- (BOOL)shouldShowTitleAndControlBarBeforePlayNextVideo;

- (void)didTapPlayBtnInPosterToPlay;
- (void)didTapPlayBtnInControlBarToPlay;
- (void)didTapPlayBtnInControlBarToPause;

- (void)didGetAdInfo:(id)adInfo;
- (void)adDidPlay;
- (void)adDidFinishPlaying;
- (void)adDidPlayWithError;

- (void)videoDidFinishByPlaybackEnd;
- (void)autoVideoDidFinishByPlaybackError;
- (void)autoVideoDidPlay;

- (void)playActiveVideo;
- (void)clearMoviePlayerController;
- (SHMoviePlayerController *)getMoviePlayer;

- (void)addPureModeTimerIfNeeded;
- (void)removePureModeTimer;

- (SHMedia*)getSHMedia;
- (BOOL)checkIfNeccessaryToRetry;
@end

@protocol WSMVVideoPlayerViewDelegate
@required
- (void)thereIsNoPreVideo:(WSMVVideoPlayerView *)playerView;
- (void)willPlayPreVideo:(SNVideoData *)video;
- (void)thereisNoNextVideo:(WSMVVideoPlayerView *)playerView;
- (void)willPlayNextVideo:(SNVideoData *)video;
- (void)willPlayNextVideoIn5Seconds:(SNVideoData *)video;

- (void)willPlayVideo:(SNVideoData *)video;
- (void)didPlayVideo:(SNVideoData *)video;
- (void)handleAppDidBecomeActive;

- (NSArray *)recommendVideosOfVideoModel:(SNVideoData *)playingVideoModel
                                    more:(BOOL)more;
- (void)needMoreRecommendIntoPlaylist;
- (void)needMoreTimelineIntoPlaylist;
- (void)willShareVideo:(SNVideoData *)video fromPlayer:(WSMVVideoPlayerView *)player;
- (void)toWapPageOf:(SNVideoData *)video;

- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style
                   forPlayerView:(WSMVVideoPlayerView *)playerView;
- (void)didEnterFullScreen:(WSMVVideoPlayerView *)videoPlayerView;
- (void)didExitFullScreen:(WSMVVideoPlayerView *)videoPlayerView;

- (void)statVideoPV:(SNVideoData *)willPlayModel
         playerView:(WSMVVideoPlayerView *)videoPlayerView;

- (void)statVideoVV:(SNVideoData *)finishedPlayModel
         playerView:(WSMVVideoPlayerView *)videoPlayerView;

- (void)cacheVideoSV:(SNVideoData *)videoModel
          playerView:(WSMVVideoPlayerView *)videoPlayerView;

- (void)statVideoAV:(SNVideoData *)videoModel
         playerView:(WSMVVideoPlayerView *)videoPlayerView;

- (void)statFFL:(SNVideoData *)videoModel
     playerView:(WSMVVideoPlayerView *)videoPlayerView
succeededToLoad:(BOOL)succeededToLoad;

- (BOOL)isVideoPlayerVisible;
- (void)videoNomalForToSmallPlayerView:(WSMVVideoPlayerView *)playerView;
- (void)videoSmallToNomalForPlayerView:(WSMVVideoPlayerView *)playerView;
- (void)setIsSmallVideo:(BOOL)isSmall;

@optional
- (void)clearOtherPlayer;
@end
