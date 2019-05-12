//
//  SNH5NewsVideoPlayer.m
//  sohunews
//
//  Created by 赵青 on 2016/10/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNH5NewsVideoPlayer.h"
#import "SNNewsReport.h"
#import "SNUserManager.h"
#import "SNVideoAdContext.h"

#define kOfficialAccountViewHeight  (30)
#define kSmallVideoWidth           ((kAppScreenWidth > 375.0) ? 270.0 : 270.0)
#define kCloseWidth                ((kAppScreenWidth > 375.0) ? 54.0/3 : 36.0/2)
#define kActionBtnWidth            ((kAppScreenWidth > 375.0) ? 57.0/3 : 40.0/2)
#define kSmallVideoTop              (self.isShowNavView ? 64 : kOfficialAccountViewHeight + kSystemBarHeight)

@implementation SNH5NewsVideoPlayer

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate {
    if ((self = [super initWithFrame:frame andDelegate:delegate])) {
        self.videoWindowType = SNVideoWindowType_normal;
        self.normalFrame = frame;
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.frame = CGRectMake(7, 7, kCloseWidth, kCloseWidth);
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"icovideo_close_v5.png"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeSmallVideoButton) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.hidden = YES;
        [self addSubview:_closeButton];
        
        _fullscreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullscreenBtn.frame = CGRectMake(kAppScreenWidth*2/3 - kActionBtnWidth-7, 7, kActionBtnWidth, kActionBtnWidth);
        _fullscreenBtn.showsTouchWhenHighlighted = NO;
        [_fullscreenBtn setImage:[UIImage themeImageNamed:@"icovideo_unfold_v5.png"] forState:UIControlStateNormal];
        [_fullscreenBtn setImageEdgeInsets:UIEdgeInsetsZero];
        [_fullscreenBtn addTarget:self action:@selector(fullscreenAction) forControlEvents:UIControlEventTouchUpInside];
        _fullscreenBtn.hidden = YES;
        [self addSubview:_fullscreenBtn];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(0, 0, 43, 43);
        [_playButton setImage:[UIImage imageNamed:@"icovideo_play_v5.png"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playSmallVideo) forControlEvents:UIControlEventTouchUpInside];
        _playButton.hidden = YES;
        [self addSubview:_playButton];
    }
    return self;
}

-(void)videoDidPlay
{
    [super videoDidPlay];
}

- (void)setSmallVideoAnimation
{
    if(nil != self.delegate && [self.delegate respondsToSelector:@selector(videoNomalForToSmallPlayerView:)]){
        [self.delegate videoNomalForToSmallPlayerView:self];
    }
    if (self.originalHeight/self.originalWidth < 1) {
        self.frame =  CGRectMake(kAppScreenWidth/3, kSmallVideoTop-(kAppScreenWidth*2/3-3)*(self.originalHeight/self.originalWidth), kAppScreenWidth*2/3-3, (kAppScreenWidth*2/3-3)*self.originalHeight/self.originalWidth);
    } else {
        self.frame =  CGRectMake(kAppScreenWidth-((kAppScreenWidth*2/3)*self.originalWidth/self.originalHeight)-3, kSmallVideoTop, (kAppScreenWidth*2/3)*self.originalWidth/self.originalHeight, kAppScreenWidth*2/3);
    }
    [self getMoviePlayer].view.frame = self.bounds;
    _isBeingChange = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _isBeingChange = YES;
        self.controlBarNonFullScreen.alpha = 0;
        self.titleView.alpha = 0;
        
        if (self.originalHeight/self.originalWidth < 1) {
            self.frame =  CGRectMake(kAppScreenWidth/3, kSmallVideoTop, kAppScreenWidth*2/3-3, (kAppScreenWidth*2/3-3)*self.originalHeight/self.originalWidth);
        } else {
            self.frame =  CGRectMake(kAppScreenWidth-((kAppScreenWidth*2/3)*self.originalWidth/self.originalHeight)-3, kSmallVideoTop, (kAppScreenWidth*2/3)*self.originalWidth/self.originalHeight, kAppScreenWidth*2/3);
        }
        [self getMoviePlayer].view.frame = self.bounds;
        
    } completion:^(BOOL finished) {
        _isBeingChange = NO;
        self.videoWindowType = SNVideoWindowType_small;
        [self updateViewsInSmallScreenMode];
        _isSmallVideo = YES;
        [self setLongPressDrag];
        
        self.controlBarNonFullScreen.alpha = 0;
        self.titleView.alpha = 0;
        if ([self getMoviePlayer].isLoadAdvert && [self getMoviePlayer].advertCurrentPlayState == SHAdvertPlayStatePlaying) {
            return;
        }
        
        self.controlBarSmallScreen.alpha = 1;
        _closeButton.hidden = NO;
        _fullscreenBtn.hidden = NO;
        _fullscreenBtn.frame = CGRectMake(self.frame.size.width - kActionBtnWidth-7, 7, kActionBtnWidth, kActionBtnWidth);
    }];
}

- (void)setSmallVideoAnimation:(BOOL)animation
{
    if (animation) {
        if(nil != self.delegate && [self.delegate respondsToSelector:@selector(videoNomalForToSmallPlayerView:)]){
            [self.delegate videoNomalForToSmallPlayerView:self];
        }
        _isBeingChange = NO;
        [UIView animateWithDuration:0.5 animations:^{
            _isBeingChange = YES;

            self.controlBarNonFullScreen.alpha = 0;
            self.titleView.alpha = 0;
            
            if (self.originalHeight/self.originalWidth < 1) {
                self.frame =  CGRectMake(kAppScreenWidth/3, kSmallVideoTop, kAppScreenWidth*2/3-3, (kAppScreenWidth*2/3-3)*self.originalHeight/self.originalWidth);
            } else {
                self.frame =  CGRectMake(kAppScreenWidth-((kAppScreenWidth*2/3)*self.originalWidth/self.originalHeight)-3, kSmallVideoTop, (kAppScreenWidth*2/3)*self.originalWidth/self.originalHeight, kAppScreenWidth*2/3);
            }
            [self getMoviePlayer].view.frame = self.bounds;
            
        } completion:^(BOOL finished) {
            _isBeingChange = NO;

            self.videoWindowType = SNVideoWindowType_small;
            [self updateViewsInSmallScreenMode];
            _isSmallVideo = YES;
            [self setLongPressDrag];
            
            self.controlBarNonFullScreen.alpha = 0;
            self.titleView.alpha = 0;
            if ([self getMoviePlayer].isLoadAdvert && [self getMoviePlayer].advertCurrentPlayState == SHAdvertPlayStatePlaying) {
                return;
            }
            
            self.controlBarSmallScreen.alpha = 1;
            _closeButton.hidden = NO;
            _fullscreenBtn.hidden = NO;
            _fullscreenBtn.frame = CGRectMake(self.frame.size.width - kActionBtnWidth-7, 7, kActionBtnWidth, kActionBtnWidth);
        }];
    } else {
        if(nil != self.delegate && [self.delegate respondsToSelector:@selector(videoNomalForToSmallPlayerView:)]){
            [self.delegate videoNomalForToSmallPlayerView:self];
        }
        self.controlBarNonFullScreen.alpha = 0;
        self.titleView.alpha = 0;
        if (self.originalHeight/self.originalWidth < 1) {
            self.frame =  CGRectMake(kAppScreenWidth/3, kSmallVideoTop, kAppScreenWidth*2/3-3, (kAppScreenWidth*2/3-3)*self.originalHeight/self.originalWidth);
        } else {
            self.frame =  CGRectMake(kAppScreenWidth-((kAppScreenWidth*2/3)*self.originalWidth/self.originalHeight)-3, kSmallVideoTop, (kAppScreenWidth*2/3)*self.originalWidth/self.originalHeight, kAppScreenWidth*2/3);
        }
        [self getMoviePlayer].view.frame = self.bounds;
        
        self.videoWindowType = SNVideoWindowType_small;
        [self updateViewsInSmallScreenMode];
        _isSmallVideo = YES;
        [self setLongPressDrag];
        
        self.controlBarNonFullScreen.alpha = 0;
        self.titleView.alpha = 0;
        if ([self getMoviePlayer].isLoadAdvert && [self getMoviePlayer].advertCurrentPlayState == SHAdvertPlayStatePlaying) {
            return;
        }
        
        self.controlBarSmallScreen.alpha = 1;
        _closeButton.hidden = NO;
        _fullscreenBtn.hidden = NO;
        _fullscreenBtn.frame = CGRectMake(self.frame.size.width - kActionBtnWidth-7, 7, kActionBtnWidth, kActionBtnWidth);
    }
}

- (void)setLongPressDrag
{
    if (!touchPoints) {
        touchPoints = [[NSMutableArray alloc] init];
    }
}

- (void)didTapOnPlayerView:(UITapGestureRecognizer *)gestureRecognizer {
    self.moviePlayer.view.frame = self.bounds;
    
    if (self.videoWindowType == SNVideoWindowType_small) {
        self.controlBarNonFullScreen.alpha = 0;
        
        CGPoint point = [gestureRecognizer locationInView:self];
        if (point.x > 0.f && point.x < 32.0f && point.y > 0 && point.y < 32.0f) {
            [self closeSmallVideoButton];
            return;
        } else if (self.frame.size.width - point.x < 34 && point.y < 32.0f) {
            [self fullscreenAction];
            return;
        }
        if ([self isPlaying]) {
            [[self getMoviePlayer] pause];
            _playButton.hidden = NO;
            _playButton.center = [self getMoviePlayer].view.center;
        } else {
            [super didTapPlayBtnInControlBarToPlay];
            _playButton.hidden = YES;
        }
    } else {
        [super didTapOnPlayerView:gestureRecognizer];
    }
}

- (void)playSmallVideo
{
    [super didTapPlayBtnInControlBarToPlay];
    _playButton.hidden = YES;
}

- (void)closeSmallVideoButton
{
    [SNNewsReport reportADotGif:@"_act=litevideo&_tp=closeclick"];
    [self closeView:YES animation:NO];
}

- (void)closeView:(BOOL)ispause animation:(BOOL)animation
{
    if (animation) {
        if(nil != self.delegate && [self.delegate respondsToSelector:@selector(videoSmallToNomalForPlayerView:)]){
            [self.delegate videoSmallToNomalForPlayerView:self];
        }
        _isBecomingSmall = NO;
        _isBeingChange = NO;

        [UIView animateWithDuration:0.5 animations:^{
            _isBeingChange = YES;

            self.frame = self.normalFrame;
            [self getMoviePlayer].view.frame = self.bounds;
            
            _closeButton.hidden = YES;
            _fullscreenBtn.hidden = YES;
            _playButton.hidden = YES;
        } completion:^(BOOL finished) {
            _isBeingChange = NO;

            _closeButton.hidden = YES;
            _fullscreenBtn.hidden = YES;
            _playButton.hidden = YES;
            
            _isSmallVideo = NO;
            
            self.videoWindowType = SNVideoWindowType_normal;
            [self updateViewsInNonScreenMode];
            self.controlBarSmallScreen.alpha = 0;
            if (ispause) {
                [super didTapPlayBtnInControlBarToPause];
                if(nil != self.delegate && [self.delegate respondsToSelector:@selector(setIsSmallVideo:)]){
                    [self.delegate setIsSmallVideo:_isSmallVideo];
                }
            }
            if (_isBecomingSmall == YES) {
                [self setSmallVideoAnimation];
                if(nil != self.delegate && [self.delegate respondsToSelector:@selector(setIsSmallVideo:)]){
                    [self.delegate setIsSmallVideo:YES];
                }
            }

            [self showTitleAndControlBarWithAnimation:NO];
        }];
    } else {
        if(nil != self.delegate && [self.delegate respondsToSelector:@selector(videoSmallToNomalForPlayerView:)]){
            [self.delegate videoSmallToNomalForPlayerView:self];
        }
        self.frame = self.normalFrame;
        [self getMoviePlayer].view.frame = self.bounds;
        
        _closeButton.hidden = YES;
        _fullscreenBtn.hidden = YES;
        _playButton.hidden = YES;
        
        _isSmallVideo = NO;
        self.videoWindowType = SNVideoWindowType_normal;
        [self updateViewsInNonScreenMode];
        self.controlBarSmallScreen.alpha = 0;
        if (ispause) {
            [super didTapPlayBtnInControlBarToPause];
            if(nil != self.delegate && [self.delegate respondsToSelector:@selector(setIsSmallVideo:)]){
                [self.delegate setIsSmallVideo:_isSmallVideo];
            }
        }
        
        [self showTitleAndControlBarWithAnimation:NO];
    }
}

- (void)fullscreenAction
{
    [SNNewsReport reportADotGif:@"_act=litevideo&_tp=fullclick"];
    [self toFullScreen];
}

- (void)toFullScreen
{
    if (self.videoWindowType == SNVideoWindowType_small) {
        [super toFullScreen];
        self.videoWindowType = SNVideoWindowType_full;
        self.controlBarSmallScreen.alpha = 0;
        _closeButton.hidden = YES;
        _fullscreenBtn.hidden = YES;
        _playButton.hidden = YES;
    } else {
        [super toFullScreen];
    }
}

- (void)exitFullScreen
{
    if (_isSmallVideo) {
        self.videoWindowType = SNVideoWindowType_small;
        [super exitFullScreen];
        
        self.controlBarNonFullScreen.alpha = 0;
        self.titleView.alpha = 0;
        
        if (self.isPaused) {
            _playButton.hidden = NO;
            _playButton.center = [self getMoviePlayer].view.center;
        }
        [self setLongPressDrag];
        if ([self getMoviePlayer].isLoadAdvert && [self getMoviePlayer].advertCurrentPlayState == SHAdvertPlayStatePlaying) {
            return;
        }
        self.controlBarSmallScreen.alpha = 1;
        _closeButton.hidden = NO;
        _fullscreenBtn.hidden = NO;
        _fullscreenBtn.frame = CGRectMake(self.frame.size.width - kActionBtnWidth-7, 7, kActionBtnWidth, kActionBtnWidth);
    } else {
        self.videoWindowType = SNVideoWindowType_normal;
        if ([self isFullScreen]) {
            [super exitFullScreen];
        }
    }
}

- (void)adDidPlay
{
    [super adDidPlay];
    if (self.videoWindowType == SNVideoWindowType_small) {
        self.controlBarSmallScreen.alpha = 0;
        _closeButton.hidden = YES;
        _fullscreenBtn.hidden = YES;
    }
}

- (void)adDidFinishPlaying
{
    [super adDidFinishPlaying];
    if (self.videoWindowType == SNVideoWindowType_small) {
        self.controlBarSmallScreen.alpha = 1;
        _closeButton.hidden = NO;
        _fullscreenBtn.hidden = NO;
        _fullscreenBtn.frame = CGRectMake(self.frame.size.width - kActionBtnWidth-7, 7, kActionBtnWidth, kActionBtnWidth);
    }
}

- (void)adDidPlayWithError
{
    [super adDidPlayWithError];
    if (self.videoWindowType == SNVideoWindowType_small) {
        self.controlBarSmallScreen.alpha = 1;
        _closeButton.hidden = NO;
        _fullscreenBtn.hidden = NO;
        _fullscreenBtn.frame = CGRectMake(self.frame.size.width - kActionBtnWidth-7, 7, kActionBtnWidth, kActionBtnWidth);
    }
}

- (void)videoDidFinishByPlaybackEnd
{
    [super videoDidFinishByPlaybackEnd];
    if (self.videoWindowType == SNVideoWindowType_small) {
        if (self.isExitFullFinish == NO) {
            [self closeView:NO animation:NO];
            if(nil != self.delegate && [self.delegate respondsToSelector:@selector(setIsSmallVideo:)]){
                [self.delegate setIsSmallVideo:NO];
            }
            self.controlBarNonFullScreen.alpha = 0;
            self.titleView.alpha = 0;
        } else {
            self.isVideoFinsh = YES;
        }
    }
}

-(void)pause
{
    if (self.videoWindowType == SNVideoWindowType_small) {
        [self.loadingMaskView stopLoadingViewAnimation];
        [[self getMoviePlayer] pause];
        if ([self getMoviePlayer].isInAdvertMode) {
            _playButton.hidden = YES;
        } else {
            _playButton.hidden = NO;
            _playButton.center = [self getMoviePlayer].view.center;
        }
        return;
    }
    [super pause];
}

-(void)adjustVolumeOrSwitchVideo:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.videoWindowType == SNVideoWindowType_small) {
        if (gestureRecognizer.state != UIGestureRecognizerStateEnded && gestureRecognizer.state != UIGestureRecognizerStateFailed) {
            CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
            
            [touchPoints addObject:[NSValue valueWithCGPoint:location]];
            if (touchPoints.count > 2) {
                [touchPoints removeObjectAtIndex:0];
            }
            CGPoint center = self.center;
            
            CGPoint Ppoint = [[touchPoints firstObject] CGPointValue];
            CGPoint Npoint = [[touchPoints lastObject] CGPointValue];
            CGFloat moveX = Npoint.x - Ppoint.x;
            CGFloat moveY = Npoint.y - Ppoint.y;
            center.x += moveX;
            center.y += moveY;
            if (center.x < self.frame.size.width/2) {
                center.x = self.frame.size.width/2;
            }
            if (center.x > kAppScreenWidth - self.frame.size.width/2) {
                center.x = kAppScreenWidth - self.frame.size.width/2;
            }
            if (center.y < self.frame.size.height/2 + kSmallVideoTop) {
                center.y = self.frame.size.height/2 + kSmallVideoTop;
            }
            if (center.y > kAppScreenHeight - self.frame.size.height/2 - kToolbarHeight) {
                center.y = kAppScreenHeight - self.frame.size.height/2 - kToolbarHeight;
            }
            self.center = center;
            
        } else {
            [touchPoints removeAllObjects];
        }
    } else {
        [super adjustVolumeOrSwitchVideo:gestureRecognizer];
    }
}

- (void)closeMiniVideo
{
    [self closeView:YES animation:NO];
}


- (void)showWillPlayNextVideoToastWithVideo:(SNVideoData *)video {
    
    UIView *toastLabel = [self getToastLabelWithVideo:video];
    
    [UIView animateWithDuration:0.2 delay:2 options:0 animations:^{
        toastLabel.alpha = 0.8;
        toastLabel.transform = CGAffineTransformScale(toastLabel.transform,2.0, 2.0);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            toastLabel.transform = CGAffineTransformScale(toastLabel.transform,0.9, 0.9);
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                toastLabel.alpha = 0;
                [toastLabel removeFromSuperview];
            });
        }];
    }];
}

- (UIView *)getToastLabelWithVideo:(SNVideoData *)video {
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"will_play_nextvideo_in5seconds_msg", nil), video.title];
    CGSize textSize = [text getTextSizeWithFontSize:kThemeFontSizeC + 1.0];
    UILabel *toastLabel = [[UILabel alloc] init];
    toastLabel.backgroundColor = SNUICOLOR(kThemeCenterToastBgColor);
    toastLabel.alpha = 0.0;
    toastLabel.text = text;
    toastLabel.textColor = SNUICOLOR(kThemeText5Color);
    toastLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC + 1.0];
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.numberOfLines = 1;
    CGFloat width = textSize.width + 20;
    toastLabel.size = CGSizeMake(width > kAppScreenHeight * 2/3 ? (kAppScreenHeight * 2/3):width, textSize.height*2 + 5.0);
    [[UIApplication sharedApplication].keyWindow addSubview:toastLabel];
    toastLabel.transform = CGAffineTransformMakeRotation(90.0*M_PI/180.0);
    toastLabel.transform = CGAffineTransformScale(toastLabel.transform, 0.6, 0.6);
    toastLabel.center = CGPointMake(kAppScreenWidth * 0.5, kAppScreenHeight * 0.5);
    return toastLabel;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
