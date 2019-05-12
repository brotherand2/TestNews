//
//  SNAutoPlayVideoContentView.m
//  sohunews
//
//  Created by cuiliangliang on 16/6/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAutoPlayVideoContentView.h"
#import "SNPickStatisticRequest.h"
#import "SNVideoBreakpointManager.h"
#import "WSMVVideoStatisticManager.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "UIFont+Theme.h"
#import "SNCellImageView.h"

@implementation SNAutoPlaySharedVideoPlayer

#pragma mark - SharedInstance
+ (SNAutoPlaySharedVideoPlayer *)sharedInstance {
    static SNAutoPlaySharedVideoPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect playerFrame = CGRectMake(kTimelineVideoCellSubContentViewsSideMargin,
                                        kTimelineVideoCellSubContentViewsTopMargin,
                                        kTimelineContentViewWidth,
                                        kPlayerViewHeight);
        sharedInstance = [[SNAutoPlaySharedVideoPlayer alloc] initWithFrame:playerFrame andDelegate:nil];
        sharedInstance.isPlayingRecommendList = NO;
        sharedInstance.currentIndex = 0;
    });
    return sharedInstance;
}

+ (void)forceStopVideo {
    //播放器锁屏逻辑交给视频负责处理
    //[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    SNAutoPlaySharedVideoPlayer *autoPlayerView = [SNAutoPlaySharedVideoPlayer sharedInstance];
    NSString *breakPointKey = autoPlayerView.playingVideoModel.vid ? : autoPlayerView.playingVideoModel.siteInfo.siteId;
    [[SNVideoBreakpointManager sharedInstance] addBreakpointByVid:breakPointKey breakpoint:[autoPlayerView getMoviePlayer].currentPlaybackTime];
    [self reportPlayTime:[autoPlayerView getMoviePlayer].currentPlaybackTime playerData:autoPlayerView.playingVideoModel];
    [autoPlayerView forceStop];
    [autoPlayerView clearMoviePlayerController];
    if (autoPlayerView.delegate && [autoPlayerView.delegate respondsToSelector:@selector(stopToUpdateProgress)]) {
        [autoPlayerView.delegate performSelector:@selector(stopToUpdateProgress)];
    }
    [autoPlayerView getMoviePlayer].currentPlayMedia.vid = nil;
    autoPlayerView.delegate = nil;
    [autoPlayerView resetModel];
    [[[SNAutoPlaySharedVideoPlayer sharedInstance] getMoviePlayer] setMuted:NO];
    [autoPlayerView removeFromSuperview];
    [SNNotificationManager postNotificationName:kUpdatePlayVideoImageNotification object:nil];
}

- (void)playbackTimeDidChanged {
    if ([self.delegate respondsToSelector:@selector(updateProgress)]) {
        [self.delegate performSelector:@selector(updateProgress)];
    }
}

- (void)didTapOnPlayerView:(UITapGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(clickVideoPlay)]) {
        [self.delegate performSelector:@selector(clickVideoPlay)];
    }
}

- (void)noNextVideoToPlay {
    [super noNextVideoToPlay];
    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    [player playCurrentVideo];
}

- (void)autoVideoDidFinishByPlaybackError {
    if ([self.delegate respondsToSelector:@selector(videoDidFinishByPlaybackError)]) {
        [self.delegate performSelector:@selector(videoDidFinishByPlaybackError)];
    }
}

- (void)autoVideoDidPlay {
    if ([self.delegate respondsToSelector:@selector(videoToPlay)]) {
        [self.delegate performSelector:@selector(videoToPlay)];
    }
}

+ (void)reportPlayTime:(CGFloat)playTime playerData:(SNVideoData *)playerData {
    if (playerData.vid.length == 0) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"pgc_play" forKey:@"_act"];
    [params setValue:@"tm" forKey:@"_tp"];
    [params setValue:[NSNumber numberWithFloat:playTime] forKey:@"ttime"];
    [params setValue:playerData.vid forKey:@"vid"];
    [params setValue:[NSNumber numberWithInteger:[SNUtility AbTestAppStyle]] forKey:@"abmode"];
    [params setValue:playerData.recomInfo ? : @"" forKey:@"recomInfo"];
    [params setValue:[SNUtility sharedUtility].currentChannelId forKey:@"channelid"];
    [params setValue:playerData.newsId forKey:@"newsId"];
    [[[SNPickStatisticRequest alloc] initWithDictionary:params
                                       andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
}

@end


@interface SNAutoPlayVideoContentView ()<WSMVVideoPlayerViewDelegate, SNAutoPlaySharedVideoPlayerDelegate>
@property (nonatomic, strong) UIButton *posterPlayBtn;
@property (nonatomic, strong) SNWebImageView *poster;
@property (nonatomic, strong) UILabel *countDown;
@property (nonatomic, assign) AutoPlayStyle playStyle;
@property (nonatomic, strong) UIImageView *flameAnimation;
@property (nonatomic, strong) UIImageView *playNightMode;
@property (nonatomic, strong) UIImageView *logoImgView;
@property (nonatomic, weak) UIView *maskView;
@end

@implementation SNAutoPlayVideoContentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.poster = [[SNWebImageView alloc] initWithFrame:self.bounds];
        self.poster.contentMode = UIViewContentModeScaleAspectFill;
        self.poster.clipsToBounds = YES;
        self.poster.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.poster.backgroundColor = kVideoPlayerPosterBgColor();
        self.poster.userInteractionEnabled = NO;
        [self addSubview:self.poster];
        
        //Logo image view
        _logoImgView = [[UIImageView alloc] initWithFrame:self.poster.bounds];
        _logoImgView.contentMode = UIViewContentModeScaleAspectFill;
        _logoImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _logoImgView.backgroundColor = [UIColor clearColor];
        [self.poster insertSubview:_logoImgView atIndex:0];
        
        //Poster button
        self.posterPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.posterPlayBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.posterPlayBtn.backgroundColor = [UIColor clearColor];
        self.posterPlayBtn.top += 3.f;
        self.posterPlayBtn.left += 10.f;
        [self.posterPlayBtn setImage:[UIImage imageNamed:@"timeline_videoplay_poster_play_btn.png"] forState:UIControlStateNormal];
        [self.posterPlayBtn addTarget:self action:@selector(toplayVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.posterPlayBtn];
        
        self.countDown = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 52, frame.size.height - 26, 50, 20)];
        self.countDown.backgroundColor = [UIColor clearColor];
        self.countDown.textAlignment = NSTextAlignmentCenter;
        self.countDown.textColor = [UIColor whiteColor];
        self.countDown.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
        [self addSubview:self.countDown];
        
        [self initflameAnimation];
        
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
        
        _isClickPlay = NO;
        _isToPlay = NO;
        _isMinToPlay = NO;
        [SNNotificationManager addObserver:self selector:@selector(setPosterImage) name:kUpdatePlayVideoImageNotification object:nil];
    }
    return self;
}

- (void)addMaskView:(UIView *)maskView {
    [self.poster addSubview:maskView];
    self.maskView = maskView;
}
- (void)layoutCountDownCenterY:(CGFloat)centerY {
    self.countDown.centerY = centerY;
    self.flameAnimation.centerY = centerY;
}

- (void)updateTheme {
    [self setPosterImage];
    self.countDown.alpha = themeImageAlphaValue();
    self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    [self setPlayStyle:_playStyle];
    [self updatePlayNightMode];
    [self addFlameAnimationImage];
}

- (void)setPlayStyle:(AutoPlayStyle)style {
    _playStyle = style;
    switch (style) {
        case AutoPlayStyleBigImage:
        {
            [self.posterPlayBtn setImage:[UIImage themeImageNamed:@"icohome_ad_play_v5.png"] forState:UIControlStateNormal];
        }
            break;
        case AutoPlayStyleMinImage:
        {
            [self.posterPlayBtn setImage:[UIImage themeImageNamed:@"icohome_play_v5_mid.png"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)updatePlayNightMode {
    if (nil == self.playNightMode) {
        self.playNightMode = [[UIImageView alloc] initWithFrame:self.bounds];
        self.playNightMode.backgroundColor = [UIColor blackColor];
        self.playNightMode.alpha = 0.5;
    }
    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if ([[SNThemeManager sharedThemeManager] isNightTheme] && [player getMoviePlayer].currentPlayMedia && [[player getMoviePlayer].currentPlayMedia.vid isEqualToString:self.object.vid] ) {
        if (![self.playNightMode superview]) {
            [self addSubview:self.playNightMode];
            [self bringSubviewToFront:self.playNightMode];
            [self bringSubviewToFront:self.countDown];
            [self bringSubviewToFront:self.flameAnimation];
        }
    } else {
        if ([self.playNightMode superview]) {
             [self.playNightMode removeFromSuperview];
        }
    }
}

- (void)removePlayNightMode {
    [self.playNightMode removeFromSuperview];
}

- (NSString *)stringToTime:(NSInteger)time {
    if (time > 0) {
        NSInteger _time = time;
        NSInteger s = 0, m = 0, h = 0;
        s = _time % 60;
        
        if (_time >= 60) {
            m = (_time / 60) % 60;
            if (_time / 60 >= 60) {
                h = (_time / 60) / 60;
            }
        }
        
        if (h > 0) {
            return [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
        }
        
        return [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
    return @" ";
}

- (void)setPosterImage {
    UIImage *defaultImage = [UIImage themeImageNamed:@"zhan4_bg_pgchalf.png"];
    if (_playStyle == AutoPlayStyleBigImage) {
        //PGC视频默认改为大视频
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            defaultImage = [UIImage themeImageNamed:@"night_defaultImageBg.png"];
        } else {
            defaultImage = [UIImage themeImageNamed:@"defaultImageBg.png"];
        }
        /*if ([SNUtility rollingNewsShowVideoChange]) {
            
        } else {
            if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
                 defaultImage = [UIImage themeImageNamed:@"night_zhan4_bg_pgchalf.png"];
            } else {
                 defaultImage = [UIImage themeImageNamed:@"zhan4_bg_pgchalf.png"];
            }
        }*/
    }
    _logoImgView.image = defaultImage;
    __weak __typeof(self) weakSelf = self;
    [self.poster setUrlPath:self.object.poster_4_3
                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (nil != image) {
            strongSelf.logoImgView.hidden = YES;
        } else {
            strongSelf.logoImgView.hidden = NO;
        }
    }];
    
    self.poster.alpha = themeImageAlphaValue();
}

- (void)resetPlayerViewFrame:(CGRect)frame {
    self.frame = frame;
    _posterPlayBtn.frame = self.bounds;
    self.poster.frame = self.bounds;
    _logoImgView.frame = self.poster.bounds;
    self.countDown.frame = CGRectMake(self.frame.size.width - 47,
                                      self.frame.size.height - 21, 50, 20);
    self.flameAnimation.frame = CGRectMake(self.frame.size.width - 55,
                                           self.frame.size.height - 15.5, 11, 8);
    [self showPlayTime];
    [self.posterPlayBtn setImage:[UIImage imageNamed:@"icohome_play_v5_mid.png"] forState:UIControlStateNormal];
    
    if (_playStyle == AutoPlayStyleBigImage) {
        [self.posterPlayBtn setImage:[UIImage imageNamed:@"icohome_ad_play_v5.png"] forState:UIControlStateNormal];
    }
    
    [self setPosterImage];
    self.countDown.alpha = themeImageAlphaValue();
}

- (void)stopToUpdateProgress {
    [self.flameAnimation stopAnimating];
    [self showPlayTime];
    if ([self.playNightMode superview]) {
        [self.playNightMode removeFromSuperview];
    }
}

- (void)updateProgress {
    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    NSTimeInterval _duration = [player getMoviePlayer].duration;
    NSTimeInterval _currentPlaybackTime = [player getMoviePlayer].currentPlaybackTime;
    if (isnan(_duration) || isnan(_currentPlaybackTime)) {
        return;
    }
    
    NSTimeInterval _playableDuration = [player getMoviePlayer].playableDuration;
    if (_playableDuration > _duration) {
        //这里为了容错：有些视频的playableDuration比duration大
        _duration = _playableDuration;
    }
    if (isnan(_duration)) {
        return;
    }
    int currentTime = (int)_currentPlaybackTime + 1;
    //为了容错，某些视频的currentTime永远小于totalTime，提前一秒上报视频结束播放
    int totalTime = (int)_duration;
    NSInteger countDownTime = totalTime - currentTime;
    self.countDown.text = [self stringToTime:countDownTime];
    if (![self.flameAnimation isAnimating]) {
        [self.flameAnimation startAnimating];
    }
}

- (void)showPlayTime {
    self.countDown.text = [self stringToTime:self.object.duration];
}

- (void)initflameAnimation {
    self.flameAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 78, self.frame.size.height - 18, 11, 8)];
    [self addFlameAnimationImage];
    self.flameAnimation.animationDuration = 1.0;
    self.flameAnimation.animationRepeatCount = 0;
    [self addSubview:self.flameAnimation];
}

- (void)addFlameAnimationImage {
    if (self.flameAnimation) {
        if (nil == self.flameAnimation.animationImages ||
            self.flameAnimation.animationImages.count == 0) {
            self.flameAnimation.animationImages =
            [NSArray arrayWithObjects:
             [UIImage themeImageNamed:@"auto_1.png"],
             [UIImage themeImageNamed:@"auto_2.png"],
             [UIImage themeImageNamed:@"auto_3.png"],
             [UIImage themeImageNamed:@"auto_4.png"],
             [UIImage themeImageNamed:@"auto_5.png"],
             [UIImage themeImageNamed:@"auto_6.png"],
             [UIImage themeImageNamed:@"auto_7.png"],
             [UIImage themeImageNamed:@"auto_8.png"],
             [UIImage themeImageNamed:@"auto_9.png"],
             [UIImage themeImageNamed:@"auto_10.png"],
             [UIImage themeImageNamed:@"auto_11.png"],
             [UIImage themeImageNamed:@"auto_12.png"],
             [UIImage themeImageNamed:@"auto_13.png"],
             [UIImage themeImageNamed:@"auto_14.png"],
             [UIImage themeImageNamed:@"auto_15.png"],
             [UIImage themeImageNamed:@"auto_16.png"],
             [UIImage themeImageNamed:@"auto_17.png"],
             [UIImage themeImageNamed:@"auto_18.png"],
             [UIImage themeImageNamed:@"auto_19.png"],
             [UIImage themeImageNamed:@"auto_20.png"],
             [UIImage themeImageNamed:@"auto_21.png"],
             [UIImage themeImageNamed:@"auto_22.png"],
             [UIImage themeImageNamed:@"auto_23.png"],
             [UIImage themeImageNamed:@"auto_24.png"],
             [UIImage themeImageNamed:@"auto_25.png"],
             [UIImage themeImageNamed:@"auto_26.png"],
             [UIImage themeImageNamed:@"auto_27.png"],
             [UIImage themeImageNamed:@"auto_28.png"],
             [UIImage themeImageNamed:@"auto_29.png"],
             [UIImage themeImageNamed:@"auto_30.png"],
             [UIImage themeImageNamed:@"auto_31.png"],
             [UIImage themeImageNamed:@"auto_32.png"],
             [UIImage themeImageNamed:@"auto_33.png"],
             [UIImage themeImageNamed:@"auto_34.png"],
             [UIImage themeImageNamed:@"auto_35.png"],
             [UIImage themeImageNamed:@"auto_36.png"],
             [UIImage themeImageNamed:@"auto_37.png"],
             [UIImage themeImageNamed:@"auto_38.png"],
             [UIImage themeImageNamed:@"auto_39.png"],
             [UIImage themeImageNamed:@"auto_40.png"],
             [UIImage themeImageNamed:@"auto_41.png"],
             [UIImage themeImageNamed:@"auto_42.png"],
             [UIImage themeImageNamed:@"auto_43.png"],
             [UIImage themeImageNamed:@"auto_44.png"],
             [UIImage themeImageNamed:@"auto_45.png"],
             [UIImage themeImageNamed:@"auto_46.png"], nil];
        }
        self.flameAnimation.alpha = themeImageAlphaValue();
    }
}

- (void)clickVideoPlay {
    _isClickPlay = YES;
    [self toplayVideo:nil];
    [self stopVideo];
}

- (void)toplayVideo:(UIButton *)sender {
    //通知需要的Cell设置已读状态
    [SNNotificationManager postNotificationName:kSNRollingNewViewCellReadNotification object:self];
    
    if (_isEditMode) {
        return;
    }
    if (sender && _isClickPlay) {
        _isClickPlay = NO;
        return;
        
    }
    if (_playStyle == AutoPlayStyleMinImage && _isMinToPlay) {
        _isToPlay = NO;
        _isMinToPlay = NO;
        return;
    }
    _isToPlay = YES;
    
    NSTimeInterval currentPlaybackTime = 0;
    SNAutoPlaySharedVideoPlayer *play = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (play.moviePlayer) {
        if ([play getMoviePlayer].currentPlayMedia &&
            [[play getMoviePlayer].currentPlayMedia.vid isEqualToString:self.object.vid] ) {
            currentPlaybackTime = [play getMoviePlayer].currentPlaybackTime * 1000;
        }
    }
    NSString *channeled = self.object.isRecommend ? @"1300030009" : @"1300030008";
    
    [SNUtility shouldAddAnimationOnSpread:NO];
    
    //lijian 20171021 去掉了sourcedata 里的 \"getad\":0 解决了pgc视频不能受配置有没有广告。
    NSString *url = nil;
    if (self.object.recomInfo != nil && [self.object.recomInfo length] > 0) {
       url = [NSString stringWithFormat:@"sohunewsvideosdk://sva://action.cmd?action=1.1&vid=%@&site=%@&position=%f&more={\"sourcedata\":{\"channeled\":\"%@\",\"type\":2,\"newsId\":\"%@\",\"recomInfo\":\"%@\"}}", self.object.vid, self.object.siteInfo.site2, currentPlaybackTime, channeled, self.object.newsId, self.object.recomInfo];
    }
    else {
        url = [NSString stringWithFormat:@"sohunewsvideosdk://sva://action.cmd?action=1.1&vid=%@&site=%@&position=%f&more={\"sourcedata\":{\"channeled\":\"%@\",\"type\":2,\"newsId\":\"%@\"}}", self.object.vid, self.object.siteInfo.site2, currentPlaybackTime, channeled, self.object.newsId];
    }
    
    [[ActionManager defaultManager] handleUrl:url];
    
    [SNUtility banUniversalLinkOpenInSafari];
    
    [self report:url];
}

- (void)report:(NSString *)url {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"pgc_vv" forKey:@"_tp"];
    [params setValue:self.object.vid forKey:@"vid"];
    [params setValue:self.object.channelId forKey:@"channelId"];
    [params setValue:[NSNumber numberWithInteger:[SNUtility AbTestAppStyle]] forKey:@"abmode"];
    [params setValue:self.object.recomInfo ? : @"" forKey:@"recomInfo"];
    [params setValue:self.object.newsId forKey:@"newsId"];
    [params setValue:[SNUtility sharedUtility].currentChannelId forKey:@"channelid"];
    [[[SNPickStatisticRequest alloc] initWithDictionary:params
                                       andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
    
    
    [params setValue:@"pgc_video" forKey:@"_act"];
    [params setValue:@"clk" forKey:@"_tp"];
    [[[SNPickStatisticRequest alloc] initWithDictionary:params andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
    
    SNUserTrack *curPage = [SNUserTrack trackWithPage:video_sohuPGC link2:url];
    NSInteger fromPage = 5;
    if (self.object.isRecommend) {
        fromPage = 6;
    }
    SNUserTrack *fromPageTrack = [SNUserTrack trackWithPage:fromPage link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [fromPageTrack toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
    
    [self pvReport:url];
}

- (void)pvReport:(NSString *)url {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"pv" forKey:@"_act"];
    NSString *string = [NSString stringWithFormat:@"66_%@", self.object.voidLink];
    [params setValue:string forKey:@"page"];
    [params setValue:self.object.recomInfo ? : @"" forKey:@"recomInfo"];
    NSString *newsfrom = self.object.isRecommend ? @"6" : @"5";
    [params setValue:newsfrom forKey:@"newsfrom"];
    [[[SNPickStatisticRequest alloc] initWithDictionary:params
                                       andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
}

- (void)initVideoPlayView {
    SNAutoPlaySharedVideoPlayer *videoPlayView = [SNAutoPlaySharedVideoPlayer sharedInstance];
    videoPlayView.frame = self.bounds;
    videoPlayView.poster.backgroundColor = [UIColor clearColor];
    videoPlayView.poster.alpha = themeImageAlphaValue();
    videoPlayView.videoPlayerRefer = WSMVVideoPlayerRefer_NewsArticle;
    [videoPlayView hideTitleAndControlBarWithAnimation:NO];
    videoPlayView.isPlayingRecommendList = NO;
    videoPlayView.supportSwitchVideoByLRGestureInNonFullscreenMode = NO;
    videoPlayView.isFromNewsContent = NO;
    videoPlayView.supportRelativeVideosViewInNonFullscreenMode = NO;
    videoPlayView.controlBarNonFullScreen = nil;
    videoPlayView.titleView = nil;
    videoPlayView.isFromAutoPlayVideo = YES;
    videoPlayView.delegate = self;
    videoPlayView.moviePlayer.muted = YES;
    [videoPlayView getMoviePlayer].view.frame = videoPlayView.frame;
    videoPlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [videoPlayView initPlaylist:[NSArray arrayWithObject:self.object] initPlayingIndex:0];
    [self addSubview:videoPlayView];
    [self bringSubviewToFront:videoPlayView];
    [self bringSubviewToFront:self.maskView];
    [self bringSubviewToFront:self.countDown];
    [self bringSubviewToFront:self.flameAnimation];
}

- (void)toStopVideo {
    SNAutoPlaySharedVideoPlayer *autoPlayerView = [SNAutoPlaySharedVideoPlayer sharedInstance];
    NSString *breakPointKey = autoPlayerView.playingVideoModel.vid ?: autoPlayerView.playingVideoModel.siteInfo.siteId;
    [[SNVideoBreakpointManager sharedInstance] addBreakpointByVid:breakPointKey breakpoint:[autoPlayerView getMoviePlayer].currentPlaybackTime];
    [autoPlayerView forceStop];
    [SNAutoPlaySharedVideoPlayer reportPlayTime:[autoPlayerView getMoviePlayer].currentPlaybackTime playerData:autoPlayerView.playingVideoModel];
    if (autoPlayerView.delegate && [autoPlayerView.delegate respondsToSelector:@selector(stopToUpdateProgress)]) {
        [autoPlayerView.delegate performSelector:@selector(stopToUpdateProgress)];
    }
    [autoPlayerView getMoviePlayer].currentPlayMedia.vid = nil;
    autoPlayerView.delegate = nil;
    [autoPlayerView resetModel];
    [[[SNAutoPlaySharedVideoPlayer sharedInstance] getMoviePlayer] setMuted:NO];
    [autoPlayerView removeFromSuperview];
}
//频道流播放视频的地方
- (void)autoPlayVideo {
    BOOL isWifi = ((![SNUtility isNetworkWWANReachable]) &&
                   [SNUtility isNetworkReachable]);
    if (isWifi && [SNUtility channelVideoSwitchStatus]) {
        self.countDown.text = [self stringToTime:self.object.duration];
        [self showPlayTime];
        [self toStopVideo]; 
        [self resetPlayerViewFrame:self.frame];
        [self initVideoPlayView];//初始化播放数据 数据来源是self.object
        [[[SNAutoPlaySharedVideoPlayer sharedInstance] moviePlayer] setMuted:YES];
        [[SNAutoPlaySharedVideoPlayer sharedInstance] playCurrentVideo];
        [self updatePlayNightMode];
        if (![SNUserDefaults boolForKey:kVideoFirstPlayToast]) {
            [SNUserDefaults setBool:YES forKey:kVideoFirstPlayToast];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"WiFi下自动播放视频" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
}

- (void)stopVideo {
    [self showPlayTime];
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
}

- (void)videoToPlay {
    [self.flameAnimation startAnimating];
}

- (void)videoDidFinishByPlaybackError {
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
    [self stopToUpdateProgress];
}

#pragma mark - Statistic
- (void)statVideoPV:(SNVideoData *)willPlayModel
         playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = willPlayModel.vid.length > 0 ? willPlayModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = willPlayModel.channelId;
    _vStatModel.messageId = willPlayModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    _vStatModel.recomInfo = willPlayModel.recomInfo;
    [[WSMVVideoStatisticManager sharedIntance] statVideoPV:_vStatModel];
}

- (void)statVideoVV:(SNVideoData *)finishedPlayModel
         playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = finishedPlayModel.vid.length > 0 ? finishedPlayModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = finishedPlayModel.channelId;
    _vStatModel.messageId = finishedPlayModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    _vStatModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + finishedPlayModel.playedTime;
    _vStatModel.totalTimeInSeconds = finishedPlayModel.totalTime;
    _vStatModel.siteId = finishedPlayModel.siteInfo.siteId;
    _vStatModel.columnId = [NSString stringWithFormat:@"%d", finishedPlayModel.columnId];
    _vStatModel.recomInfo = finishedPlayModel.recomInfo;
    
    SHMedia *shMedia = [[SNAutoPlaySharedVideoPlayer sharedInstance] getMoviePlayer].currentPlayMedia;
    SHMediaSourceType mediaSourceType = shMedia.sourceType;
    if (mediaSourceType == SHLocalDownload) {
        _vStatModel.offline = kWSMVStatVV_Offline_YES;
    } else {
        _vStatModel.offline = kWSMVStatVV_Offline_NO;
    }
    
    [[WSMVVideoStatisticManager sharedIntance] statVideoVV:_vStatModel
                                             inVideoPlayer:videoPlayerView];
}

//累计连播数据以便在调起播放器页不再使用播放器时统计连播
- (void)cacheVideoSV:(SNVideoData *)videoModel
          playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_statModel = [[WSMVVideoStatisticModel alloc] init];
    _statModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _statModel.newsId = @"";
    _statModel.messageId = videoModel.messageId;
    _statModel.refer = VideoStatRefer_VideoTabTimeline;
    _statModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + videoModel.playedTime;
    [[WSMVVideoStatisticManager sharedIntance] cacheVideoSV:_statModel];
}

- (void)statVideoAV:(SNVideoData *)videoModel
         playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = videoModel.channelId;
    _vStatModel.messageId = videoModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    _vStatModel.recomInfo = videoModel.recomInfo;
    [[WSMVVideoStatisticManager sharedIntance] statVideoPlayerActions:_vStatModel actionsData:videoPlayerView.playerActionsStatData];
}

- (void)statFFL:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView succeededToLoad:(BOOL)succeededToLoad {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = videoModel.channelId;
    _vStatModel.messageId = videoModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    _vStatModel.succeededToFFL = succeededToLoad;
    _vStatModel.siteId = videoModel.siteInfo.siteId;
    _vStatModel.recomInfo = videoModel.recomInfo;
    [[WSMVVideoStatisticManager sharedIntance] statFFL:_vStatModel];
}

- (void)settingPlayButton {
    if (_isEditMode) {
        [self.posterPlayBtn removeFromSuperview];
    } else {
        if (![self.subviews containsObject:self.posterPlayBtn]) {
            [self addSubview:self.posterPlayBtn];
        }
    }
}

- (void)handleAppDidBecomeActive {
    BOOL isWifi = ((![SNUtility isNetworkWWANReachable]) &&
                   [SNUtility isNetworkReachable]);
    if (isWifi && [SNUtility channelVideoSwitchStatus]) {
        SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
        if ([player getMoviePlayer].playbackState == MPMoviePlaybackStatePaused) {
            [[player getMoviePlayer] play];
        }
    } else {
        [self stopVideo];
    }
}

#pragma mark - 2G3G提示
- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style
                   forPlayerView:(WSMVVideoPlayerView *)playerView {
    [self stopVideo];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
