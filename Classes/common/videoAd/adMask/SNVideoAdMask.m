//
//  SNVideoAdMask.m
//  sohunews
//
//  Created by handy wang on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNVideoAdMask.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

#import "SNHighlightedTextButton.h"
#import "SNVideoAdMaskConst.h"
#import "SNVideoAdMaskHelper.h"
#import "SNVideoAdMaskLiveBanner.h"

static const CGFloat kMaskHeaderHeight = (286.0f/2.0f);

static const CGFloat kCountdownBtnWidth = (182.0f/2.0f);
static const CGFloat kCountdownBtnHeight = (50.0f/2.0f);
static const CGFloat kCountdownBtnMarginTop = (16.0f/2.0f);
static const CGFloat kCountdownBtnAndMuteBtnHPadding = (12.0f/2.0f);
static const CGFloat kCountdownBtnFontsize = (22.0f/2.0f);

static const CGFloat kMuteBtnWidth = (60.0f/2.0f);
static const CGFloat kMuteBtnHeight = kCountdownBtnHeight;
static const CGFloat kMuteBtnMarginTop = kCountdownBtnMarginTop;
static const CGFloat kMuteBtnMarginRight = 16.0f/2.0f;

static const CGFloat kMaskFooterBgHeight = (88.0f/2.0f);
static const CGFloat kAdDetailBtnWidth = (146.0f/2.0f);
static const CGFloat kAdDetailBtnHeight = kCountdownBtnHeight;
static const CGFloat kAdDetailBtnMarginRight = (16.0f/2.0f);
static const CGFloat kAdDetailBtnMarginBottom = (16.0f/2.0f);
static const CGFloat kAdDetailBtnFontsize = (24.0f/2.0f);

static const CGFloat kAdMaskFullscreenBtnWidth = (50.0f/2.0f);
static const CGFloat kAdMaskFullscreenBtnHeight = kCountdownBtnHeight;
static const CGFloat kAdMaskFullscreenBtnMarginRight = kAdDetailBtnMarginRight;
static const CGFloat kAdMaskFullscreenBtnAndAdDetailBtnHPadding = (12.0f/2.0f);
static const CGFloat kAdMaskFullscreenBtnMarginBottom = kAdDetailBtnMarginBottom;




void SNVideoAdMaskAudioVolumeChangeListenerCallback (void *inUserData,
                                                           AudioSessionPropertyID inPropertyID,
                                                           UInt32 inPropertyValueSize,
                                                           const void *inPropertyValue) {
    if (inPropertyID != kAudioSessionProperty_CurrentHardwareOutputVolume) {
        return;
    }
    Float32 value = *(Float32 *)inPropertyValue;
    UIButton *muteBtn = (__bridge UIButton *)inUserData;
    if (value > 0) {
        [muteBtn setImage:[UIImage imageNamed:@"videoAdMask_muteBtnSound.png"] forState:UIControlStateNormal];
    }
    else {
        [muteBtn setImage:[UIImage imageNamed:@"videoAdMask_muteBtnSilence.png"] forState:UIControlStateNormal];
    }
}


@interface SNVideoAdMask() {
    __strong UIImageView *_header;
    __strong SNHighlightedTextButton *_countdownBoard;
    __strong UIButton *_muteBtn;
    
    __strong UIImageView *_footer;
    __strong UIButton *_videoAdDetailBtn;
    __strong SNVideoAdDetailInfo *_videoAdDetailInfo;
    __strong UIButton *_fullscreenBtn;
    
    __strong NSTimer *_countdownTimer;
    
    Float32 _lastSystemVolume;
}
@end

@implementation SNVideoAdMask

#pragma mark - Lifecycle
+ (SNVideoAdMask *)maskWithType:(SNVideoAdMaskType)type {
    SNVideoAdMask *mask = nil;
    switch (type) {
        case SNVideoAdMaskType_Normal: {
            mask = [[SNVideoAdMask alloc] initWithType:type];
            break;
        }
        case SNVideoAdMaskType_LiveBanner: {
            mask = [[SNVideoAdMaskLiveBanner alloc] initWithType:type];
            break;
        }
    }
    return mask;
}

- (id)init {
    if (self = [super init]) {
        _videoAdMaskType = SNVideoAdMaskType_Normal;
        [self p_init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _videoAdMaskType = SNVideoAdMaskType_Normal;
        [self p_init];
        [self p_layout];
    }
    return self;
}

- (id)initWithType:(SNVideoAdMaskType)type {
    if (self = [super init]) {
        _videoAdMaskType = type;
        [self p_init];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self p_layout];
}

- (void)dealloc {
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                   SNVideoAdMaskAudioVolumeChangeListenerCallback,
                                                   (__bridge void *)(_muteBtn));
}

#pragma mark - Public
- (void)maskWillAppearInVideoPlayer:(WSMVVideoPlayerView *)videoPlayer {
}

- (void)startCountdownInVideoPlayer:(WSMVVideoPlayerView *)videoPlayer {
    if (!_countdownTimer) {
        [self updateCountdownSecondsValue:(int)([videoPlayer getMoviePlayer].advertCurrentPlaybackTime)];
        
        _countdownTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(doCountdown:) userInfo:@{kVideoAdMaskVideoPlayer:videoPlayer} repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_countdownTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopCountdown {
    if ([_countdownTimer isValid]) {
        [_countdownTimer invalidate];
    }
}

#pragma mark -
- (void)updateLastSystemVolume:(Float32)systemVolume {
    _lastSystemVolume = systemVolume;
}

- (void)resumeAppVolumeIfNeeded {
    Float32 systemVolume;
    UInt32 dataSize = sizeof(Float32);
    AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareOutputVolume,
                             &dataSize,&systemVolume);
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    
    if (systemVolume <= 0) {
        Float32 newValue = 0;
        if (_lastSystemVolume >= 0) {
            newValue = _lastSystemVolume;
            mpc.volume = newValue;
        }else {
            mpc.volume = newValue;
        }
        [self updateLastSystemVolume:newValue];
    }
}

#pragma mark -
- (void)setVideoAdDetailInfo:(SNVideoAdDetailInfo *)videoAdDetailInfo {
    _videoAdDetailInfo = videoAdDetailInfo;
    if (_videoAdDetailInfo) {
        _videoAdDetailBtn.hidden = !videoAdDetailInfo.isOpenInApp;
    }else{
        _videoAdDetailBtn.hidden = !_videoAdDetailInfo;
    }
}

- (SNVideoAdDetailInfo *)getVideoAdDetailInfo {
    return _videoAdDetailInfo;
}

#pragma mark -
- (void)setShowFullscreenButton:(BOOL)show {
    SNDebugLog(@"========================ad detail info: %@",[self getVideoAdDetailInfo]);
    
    if (show) {
        _videoAdDetailBtn.left = _footer.width-(kAdDetailBtnWidth+kAdMaskFullscreenBtnWidth+kAdMaskFullscreenBtnAndAdDetailBtnHPadding+kAdMaskFullscreenBtnMarginRight);
        _fullscreenBtn.hidden = NO;
    }
    else {
        _videoAdDetailBtn.left = _footer.width-(kAdDetailBtnWidth+kAdDetailBtnMarginRight);
        _fullscreenBtn.hidden = YES;
    }
}

- (void)updateFullscreenButtonState:(BOOL)isFullscreen {
    if (isFullscreen) {
        [_fullscreenBtn setImage:[UIImage imageNamed:@"videoAdMask_exitFullscreenBtn.png"] forState:UIControlStateNormal];
    }
    else {
        [_fullscreenBtn setImage:[UIImage imageNamed:@"videoAdMask_toFullscreenBtn.png"] forState:UIControlStateNormal];
    }
}

#pragma mark -
- (void)hideHeaderAndFooter {
    _header.hidden = YES;
    _footer.hidden = YES;
}

- (void)showHeaderAndFooter {
    _header.hidden = NO;
    _footer.hidden = NO;
}

#pragma mark -
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *muteBtnSuperView = _muteBtn.superview;
    CGRect muteBtnFrame = [self convertRect:_muteBtn.frame fromView:muteBtnSuperView];
    
    UIView *videoAdDetailBtnSuperView = _videoAdDetailBtn.superview;
    CGRect videoAdDetailBtnFrarme = [self convertRect:_videoAdDetailBtn.frame fromView:videoAdDetailBtnSuperView];
    
    UIView *fullscreenBtnSuperView = _fullscreenBtn.superview;
    CGRect fullscreenBtnFrame = [self convertRect:_fullscreenBtn.frame fromView:fullscreenBtnSuperView];
    
    if (CGRectContainsPoint(muteBtnFrame, point)) {
        return _muteBtn;
    }
    else if (CGRectContainsPoint(videoAdDetailBtnFrarme, point) && !(_videoAdDetailBtn.hidden) && !(_footer.hidden)) {
        return _videoAdDetailBtn;
    }
    else if (CGRectContainsPoint(fullscreenBtnFrame, point) && !(_fullscreenBtn.hidden) && !(_footer.hidden)) {
        return _fullscreenBtn;
    }
    else {
        return [super hitTest:point withEvent:event];
    }
}

#pragma mark - Private - Init&Layout
/**
 * 只是创建各个子视图对象，不包括设置各子视图的位置和大小
 */
- (void)p_init {
    self.backgroundColor = [UIColor clearColor];
    AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                    SNVideoAdMaskAudioVolumeChangeListenerCallback,
                                    (__bridge void *)(_muteBtn));
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    _lastSystemVolume = -1;
    
    [self p_initHeader];
    [self p_initCountdownBoard];
    [self p_initMuteBtn];

    [self p_initFooter];
    [self p_initAdDetailBtn];
    [self p_initFullscreenBtn];
    [self o_willFinishInitSubviews];
}

- (void)p_initHeader {
    if (!_header) {
        UIImage *tmpImg = [UIImage imageNamed:@"timeline_videoplay_titleviewbg_nonfullscreen.png"];
        tmpImg = [tmpImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        _header = [[UIImageView alloc] initWithImage:tmpImg];
        [self addSubview:_header];
    }
}

- (void)p_initCountdownBoard {
    if (!_countdownBoard) {
        _countdownBoard = [[SNHighlightedTextButton alloc] init];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
        UIImage *btnBgImg = [[UIImage imageNamed:@"videoAdMask_actionBtnBgImg.png"] resizableImageWithCapInsets:insets];
        [_countdownBoard setBackgroundImage:btnBgImg forState:UIControlStateNormal];

        [_countdownBoard setTextAlignment:NSTextAlignmentCenter];
        [_countdownBoard setTextFont:[UIFont systemFontOfSize:kCountdownBtnFontsize]];
        [_countdownBoard setTextColor:[UIColor whiteColor]];
        [_header addSubview:_countdownBoard];
    }
}

- (void)p_initMuteBtn {
    if (!_muteBtn) {
        Float32 systemVolume;
        UInt32 dataSize = sizeof(Float32);
        AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareOutputVolume,
                                 &dataSize,&systemVolume);
        
        _muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteBtn addTarget:self action:@selector(muteOrNot:) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateLastSystemVolume:systemVolume];
        if (systemVolume > 0) {
            [_muteBtn setImage:[UIImage imageNamed:@"videoAdMask_muteBtnSound.png"] forState:UIControlStateNormal];
        }
        else {
            [_muteBtn setImage:[UIImage imageNamed:@"videoAdMask_muteBtnSilence.png"] forState:UIControlStateNormal];
        }
        
        UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
        UIImage *btnBgImg = [[UIImage imageNamed:@"videoAdMask_actionBtnBgImg.png"] resizableImageWithCapInsets:insets];
        [_muteBtn setBackgroundImage:btnBgImg forState:UIControlStateNormal];
        
        [_header addSubview:_muteBtn];
    }
}

- (void)p_initFooter {
    if (!_footer) {
        UIImage *tmpImage = [UIImage imageNamed:@"timeline_videoplay_bottomviewbg_nonfullscreen.png"];
        tmpImage = [tmpImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
        _footer = [[UIImageView alloc] initWithImage:tmpImage];
        [self addSubview:_footer];
    }
}

- (void)p_initAdDetailBtn {
    if (!_videoAdDetailBtn) {
        _videoAdDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoAdDetailBtn addTarget:self action:@selector(toVideoAdDetailPage:) forControlEvents:UIControlEventTouchUpInside];
        [_videoAdDetailBtn setImage:[UIImage imageNamed:@"videoAdMask_videoAdDetailBtnAccessory.png"] forState:UIControlStateNormal];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
        UIImage *btnBgImg = [[UIImage imageNamed:@"videoAdMask_actionBtnBgImg.png"] resizableImageWithCapInsets:insets];
        [_videoAdDetailBtn setBackgroundImage:btnBgImg forState:UIControlStateNormal];
        
        [_videoAdDetailBtn setTitle:@"了解详情" forState:UIControlStateNormal];
        [_videoAdDetailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_videoAdDetailBtn.titleLabel setFont:[UIFont systemFontOfSize:kAdDetailBtnFontsize]];
        [_footer addSubview:_videoAdDetailBtn];
  
    }
}

- (void)p_initFullscreenBtn {
    if (!_fullscreenBtn) {
        _fullscreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_fullscreenBtn addTarget:self action:@selector(enterOrExitFullScreen:) forControlEvents:UIControlEventTouchUpInside];
        [_fullscreenBtn setImage:[UIImage imageNamed:@"videoAdMask_toFullscreenBtn.png"] forState:UIControlStateNormal];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
        UIImage *btnBgImg = [[UIImage imageNamed:@"videoAdMask_actionBtnBgImg.png"] resizableImageWithCapInsets:insets];
        [_fullscreenBtn setBackgroundImage:btnBgImg forState:UIControlStateNormal];
        [_footer addSubview:_fullscreenBtn];
    }
}

- (void)o_willFinishInitSubviews {
}

#pragma mark -
/**
 * 设置各个子视图对象的大小和位置
 */
- (void)p_layout {
    [self p_layoutHeader];
    [self p_layoutCountdownBoard];
    [self p_layoutMuteBtn];
    
    [self p_layoutFooter];
    [self p_layoutAdDetailBtn];
    [self p_layoutFullscreenBtn];
    [self o_willFinishLayoutSubviews];
}

- (void)p_layoutHeader {
    CGRect headerFrame = CGRectMake(0,
                                      0,
                                      self.width,
                                      kMaskHeaderHeight);
    _header.frame = headerFrame;
}

- (void)p_layoutCountdownBoard {
    CGFloat left = _header.width-(kCountdownBtnWidth+kCountdownBtnAndMuteBtnHPadding+kMuteBtnWidth+kMuteBtnMarginRight);
    CGRect countdownBoardFrame = CGRectMake(left, kCountdownBtnMarginTop, kCountdownBtnWidth, kCountdownBtnHeight);
    _countdownBoard.frame = countdownBoardFrame;
}

- (void)p_layoutMuteBtn {
    CGFloat left = _header.width-(kMuteBtnMarginRight+kMuteBtnWidth);
    CGRect muteBtnFrame = CGRectMake(left, kMuteBtnMarginTop, kMuteBtnWidth, kMuteBtnHeight);
    _muteBtn.frame = muteBtnFrame;
}

- (void)p_layoutFooter {
    CGRect footerFrame = CGRectMake(0, self.height-kMaskFooterBgHeight, self.width, kMaskFooterBgHeight);
    _footer.frame = footerFrame;
}

- (void)p_layoutAdDetailBtn {
    CGFloat left = _footer.width-(kAdDetailBtnWidth+kAdMaskFullscreenBtnWidth+kAdMaskFullscreenBtnAndAdDetailBtnHPadding+kAdMaskFullscreenBtnMarginRight);
    CGFloat top = _footer.height-(kAdDetailBtnMarginBottom+kAdDetailBtnHeight);
    CGRect videoAdDetailBtnFrame = CGRectMake(left, top, kAdDetailBtnWidth, kAdDetailBtnHeight);
    _videoAdDetailBtn.frame = videoAdDetailBtnFrame;
}

- (void)p_layoutFullscreenBtn {
    CGFloat left = _videoAdDetailBtn.right + kAdMaskFullscreenBtnAndAdDetailBtnHPadding;
    CGFloat top = _footer.height-(kAdMaskFullscreenBtnMarginBottom+kAdMaskFullscreenBtnHeight);
    CGRect adMaskFullscreenBtnFrame = CGRectMake(left, top, kAdMaskFullscreenBtnWidth, kAdMaskFullscreenBtnHeight);
    _fullscreenBtn.frame = adMaskFullscreenBtnFrame;
}

- (void)o_willFinishLayoutSubviews {
}

#pragma mark - Private - Actions
- (void)muteOrNot:(UIButton *)muteBtn {
    Float32 systemVolume;
    UInt32 dataSize = sizeof(Float32);
    AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareOutputVolume,
                             &dataSize,&systemVolume);
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    
    Float32 newValue = 0;
    if (systemVolume > 0) {
        newValue = systemVolume;
        mpc.volume = 0;
    }else if (_lastSystemVolume > 0) {
        newValue = _lastSystemVolume;
        mpc.volume = newValue;
    }
    else {
        newValue = 0.5;
        mpc.volume = newValue;
    }
    
    [self updateLastSystemVolume:newValue];
}

- (void)toVideoAdDetailPage:(UIButton *)videoAdDetailBtn {
    [SNNotificationManager postNotificationName:kSNVideoAdMaskShowVideoAdDetailNotification object:self];
}

- (void)enterOrExitFullScreen:(UIButton *)fullscreenBtn {
    [SNNotificationManager postNotificationName:kSNVideoAdMaskEnterOrExitFullscreenNotification object:self];
}

#pragma mark - Private Others
- (void)doCountdown:(NSTimer *)timer {
    WSMVVideoPlayerView *videoPlayer = timer.userInfo[kVideoAdMaskVideoPlayer];
    
    NSTimeInterval leftSeconds = (int)([videoPlayer getMoviePlayer].advertCurrentPlaybackTime);
    if (leftSeconds > 0) {
        [self updateCountdownSecondsValue:leftSeconds];
    }
    else if (leftSeconds == 0) {
        [self updateCountdownSecondsValue:leftSeconds];
        //延迟0.2秒的原因：让倒计时的第一个值多显示一会儿
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SNVideoAdMaskHelper dismissMaskForPlayer:videoPlayer];
            [self stopCountdown];
        });
    }
    /**
     *  为了容错，把剩余时长为负数的情况也考虑到了，但实际上剩余时长也许不会为负数。
     */
    else {
        [SNVideoAdMaskHelper dismissMaskForPlayer:videoPlayer];
        [self updateCountdownSecondsValue:0];
        [self stopCountdown];
    }
}

- (void)updateCountdownSecondsValue:(NSTimeInterval)leftSeconds {
    NSString *leftSecondsText = [NSString stringWithFormat:@"%02d", (int)leftSeconds];
    NSString *text = [NSString stringWithFormat:@"广告剩余%@秒", leftSecondsText];
    [_countdownBoard setText:text highlightedText:leftSecondsText];
    
    [self o_didUpdateCountdownSecondsValue:leftSeconds];
}

- (void)o_didUpdateCountdownSecondsValue:(NSTimeInterval)leftSeconds {
}

@end
