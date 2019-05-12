//
//  WSMVVideoControlBar_FullScreen.m
//  WeSee
//
//  Created by handy wang on 9/9/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoControlBar_FullScreen.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SNToast.h"

#define kProgressBarMarginLeft_FullScreen       (10.0f / 2.0f)
#define kProgressBarHeight_FullScreen           (34 / 2.0f)
#define kDownloadBtnMarginLeft_FullScreen       (20 / 2.0f)
#define kFullScreenBtnMarginRight_FullScreen    (20 / 2.0f)
#define kShareBtnPaddingLeftToDownloadBtn       (32 / 2.0f)
#define kPreviousVideoBtnPaddingRightToPlayBtn  (32 / 2.0f)
#define kNextVideoBtnPaddingLeftToPlayBtn       (32 / 2.0f)
#define kVolumnBtnPaddingRightToFullScreenBtn   (32 / 2.0f)

@implementation WSMVVideoControlBar_FullScreen

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //Progress bar
        
        CGFloat originX = kProgressBarMarginLeft_FullScreen;
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            originX = kProgressBarMarginLeft_FullScreen + 24;
        }
        CGRect _progressBarFrame = CGRectMake(originX, 0, self.width - 2 * originX, kProgressBarHeight_FullScreen);
        self.progressBar = [[WSMVVideoProgressBar alloc] initWithFrame:_progressBarFrame];
        self.progressBar.delegate = self;
        self.progressBar.exclusiveTouch = YES;
        [self addSubview:self.progressBar];
        
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            if(self.siteNameLabel){
                self.siteNameLabel.frame = CGRectMake(kTimelineSiteNameAndDurationLRMarginToPosterLRSide + 24, -2 * kTimelineSiteNameAndDurationHeight, self.width - kTimelineSiteNameAndDurationLRMarginToPosterLRSide - 24, kTimelineSiteNameAndDurationHeight);
            }
        }
        //Play btn
        self.playBtn.frame = CGRectMake((self.width - kActionBtnWidth_FullScreen) / 2.0f, CGRectGetMaxY(self.progressBar.frame), kActionBtnWidth_FullScreen, kActionBtnHeight_FullScreen);
        [self.playBtn setImageEdgeInsets:UIEdgeInsetsZero];
        
        //Download btn
        self.downloadBtn.frame =
        CGRectMake(kDownloadBtnMarginLeft_FullScreen,
                   CGRectGetMaxY(self.progressBar.frame),
                   kActionBtnWidth_FullScreen,
                   kActionBtnHeight_FullScreen);
        [self.downloadBtn setImageEdgeInsets:UIEdgeInsetsZero];
        
        //Fullscreen btn  wangshun
        self.fullscreenBtn.frame =
        CGRectMake(self.width - kActionBtnWidth_FullScreen - kFullScreenBtnMarginRight_FullScreen, CGRectGetMaxY(self.progressBar.frame), kActionBtnWidth_FullScreen, kActionBtnHeight_FullScreen);
        self.fullscreenBtn.showsTouchWhenHighlighted = NO;
        [self.fullscreenBtn setImage:[UIImage themeImageNamed:@"wsmv_full_exit_hl.png"] forState:UIControlStateHighlighted];
        [self.fullscreenBtn setImage:[UIImage themeImageNamed:@"wsmv_full_exit.png"] forState:UIControlStateNormal];
        [self.fullscreenBtn setImageEdgeInsets:UIEdgeInsetsZero];
        
        //Share btn
        self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareBtn.frame = CGRectMake(CGRectGetMaxX(self.downloadBtn.frame) + kShareBtnPaddingLeftToDownloadBtn, CGRectGetMaxY(self.progressBar.frame),
                                         kActionBtnWidth_FullScreen,
                                         kActionBtnHeight_FullScreen);
        self.shareBtn.showsTouchWhenHighlighted = NO;
        [self.shareBtn setImage:[UIImage themeImageNamed:@"wsmv_share_hl.png"] forState:UIControlStateHighlighted];
        [self.shareBtn setImage:[UIImage themeImageNamed:@"wsmv_share.png"] forState:UIControlStateNormal];
        [self.shareBtn addTarget:self action:@selector(shareVideoAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.shareBtn];
        
        //Previous video btn
        self.previousVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.previousVideoBtn.frame =
        CGRectMake(CGRectGetMinX(self.playBtn.frame) - kPreviousVideoBtnPaddingRightToPlayBtn - kActionBtnWidth_FullScreen,
                   CGRectGetMaxY(self.progressBar.frame),
                   kActionBtnWidth_FullScreen,
                   kActionBtnHeight_FullScreen);
        self.previousVideoBtn.showsTouchWhenHighlighted = NO;
        [self.previousVideoBtn setImage:[UIImage themeImageNamed:@"wsmv_previous_video_btn_hl.png"] forState:UIControlStateHighlighted];
        [self.previousVideoBtn setImage:[UIImage themeImageNamed:@"wsmv_previous_video_btn.png"] forState:UIControlStateNormal];
        [self.previousVideoBtn addTarget:self action:@selector(playPreviousVideoAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.previousVideoBtn];
        
        //Next video btn
        self.nextVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nextVideoBtn.frame = CGRectMake(CGRectGetMaxX(self.playBtn.frame)+kNextVideoBtnPaddingLeftToPlayBtn,
                                                 CGRectGetMaxY(self.progressBar.frame),
                                                 kActionBtnWidth_FullScreen,
                                                 kActionBtnHeight_FullScreen);
        self.nextVideoBtn.showsTouchWhenHighlighted = NO;
        [self.nextVideoBtn setImage:[UIImage themeImageNamed:@"wsmv_next_video_btn_hl.png"] forState:UIControlStateHighlighted];
        [self.nextVideoBtn setImage:[UIImage themeImageNamed:@"wsmv_next_video_btn.png"] forState:UIControlStateNormal];
        [self.nextVideoBtn addTarget:self action:@selector(playNextVideoAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.nextVideoBtn];
        
        //Volumn btn
        self.volumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.volumeBtn.frame = CGRectMake(CGRectGetMinX(self.fullscreenBtn.frame) - kActionBtnWidth_FullScreen - kVolumnBtnPaddingRightToFullScreenBtn,
                                             CGRectGetMaxY(self.progressBar.frame),
                                             kActionBtnWidth_FullScreen,
                                             kActionBtnHeight_FullScreen);
        [self.volumeBtn addTarget:self action:@selector(volumnAction) forControlEvents:UIControlEventTouchUpInside];
        
        Float32 systemVolume;
        UInt32 dataSize = sizeof(Float32);
        AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                &dataSize,
                                &systemVolume);
        
        self.volumeBtn.showsTouchWhenHighlighted = NO;
        if (systemVolume <= 0) {
            [self.volumeBtn setBackgroundImage:[UIImage themeImageNamed:@"wsmv_volumn_mute.png"]
                                      forState:UIControlStateNormal];
            [self.volumeBtn setBackgroundImage:[UIImage themeImageNamed:@"wsmv_volumn_mute_hl.png"]
                                      forState:UIControlStateHighlighted];
        } else {
            [self.volumeBtn setBackgroundImage:[UIImage themeImageNamed:@"wsmv_volumn.png"]
                                      forState:UIControlStateNormal];
            [self.volumeBtn setBackgroundImage:[UIImage themeImageNamed:@"wsmv_volumn_hl.png"]
                                      forState:UIControlStateHighlighted];
        }
        [self addSubview:self.volumeBtn];
    }
    return self;
}

#pragma mark - Override
- (void)fullscreenAction {//wangshun
    if ([self.delegate respondsToSelector:@selector(exitFullScreen)]) {
        [self.delegate exitFullScreen];
        [[SNToast shareInstance] hideToast];
    }
}

- (void)enableDownload {
    [super enableDownload];
    
    self.shareBtn.frame =
    CGRectMake(CGRectGetMaxX(self.downloadBtn.frame) + kShareBtnPaddingLeftToDownloadBtn, CGRectGetMaxY(self.progressBar.frame),
                                     kActionBtnWidth_FullScreen,
                                     kActionBtnHeight_FullScreen);
}

- (void)disableDownload {
    [super disableDownload];
    self.shareBtn.frame = self.downloadBtn.frame;
}

- (void)enableShare {
    self.shareBtn.hidden = NO;
}

- (void)disableShare {
    self.shareBtn.hidden = YES;
}

#pragma mark - Private
- (void)shareVideoAction {
    if ([self.delegate respondsToSelector:@selector(didTapShareBtn)]) {
        [self.delegate didTapShareBtn];
    }
}

- (void)playNextVideoAction {
    if ([self.delegate respondsToSelector:@selector(didTapNextVideoBtn)]) {
        [self.delegate didTapNextVideoBtn];
    }
}

- (void)playPreviousVideoAction {
    if ([self.delegate respondsToSelector:@selector(didTapPreviousVideoBtn)]) {
        [self.delegate didTapPreviousVideoBtn];
    }
}

- (void)volumnAction {
    if (!(self.volumeBtn.selected)) {
        self.volumeBtn.selected = YES;
        if ([self.delegate respondsToSelector:@selector(showVolumnBarMask)]) {
            [self.delegate showVolumnBarMask];
        }
    } else {
        self.volumeBtn.selected = NO;
        if ([self.delegate respondsToSelector:@selector(hideVolumnBarMask)]) {
            [self.delegate hideVolumnBarMask];
        }
    }
}

@end
