//
//  WSMVVideoControlBar.m
//  WeSee
//
//  Created by handy on 8/15/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoControlBar.h"
#import "WSMVSlider.h"
#import "WSMVVideoPlayerView.h"

@interface WSMVVideoControlBar()
@end

@implementation WSMVVideoControlBar

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.image = [[UIImage imageNamed:@"wsmv_controlbar_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        
        //Site name label
        CGRect siteNameLabelFrame = CGRectMake(kTimelineSiteNameAndDurationLRMarginToPosterLRSide, -2 * kTimelineSiteNameAndDurationHeight, self.width - kTimelineSiteNameAndDurationLRMarginToPosterLRSide, kTimelineSiteNameAndDurationHeight);
        _siteNameLabel = [[UILabel alloc] initWithFrame:siteNameLabelFrame];
        _siteNameLabel.backgroundColor = [UIColor clearColor];
        _siteNameLabel.textColor = [UIColor whiteColor];
        _siteNameLabel.textAlignment = NSTextAlignmentLeft;
        _siteNameLabel.font = [UIFont systemFontOfSize:kTimelineSiteNameAndDurationFontSize];
        [self addSubview:_siteNameLabel];
        
        //Play btn
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect _playBtnFrame = CGRectMake(0, 0, kActionBtnWidth_NonFullScrenn, self.height);
        self.playBtn.frame = _playBtnFrame;
        [self.playBtn setShowsTouchWhenHighlighted:NO];
        [self.playBtn setImage:[UIImage themeImageNamed:@"wsmv_play_btn_hl.png"] forState:UIControlStateHighlighted];
        [self.playBtn setImage:[UIImage themeImageNamed:@"wsmv_play_btn.png"] forState:UIControlStateNormal];
        [self.playBtn addTarget:self action:@selector(tapPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.playBtnStatus = WSMVVideoPlayerPlayBtnStatus_Stop;
        self.playBtn.exclusiveTouch = YES;
        [self addSubview:self.playBtn];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        //Fullscreen btn
        self.fullscreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fullscreenBtn addTarget:self action:@selector(fullscreenAction) forControlEvents:UIControlEventTouchUpInside];

        CGRect _fullscreenBtnFrame = CGRectMake(self.width - kActionBtnWidth_NonFullScrenn, 0, kActionBtnWidth_NonFullScrenn, self.height);
        self.fullscreenBtn.frame = _fullscreenBtnFrame;
        [self.fullscreenBtn setShowsTouchWhenHighlighted:NO];
        [self.fullscreenBtn setImage:[UIImage themeImageNamed:@"wsmv_fullscreen_hl.png"] forState:UIControlStateHighlighted];
        [self.fullscreenBtn setImage:[UIImage themeImageNamed:@"wsmv_fullscreen.png"] forState:UIControlStateNormal];
        [self addSubview:self.fullscreenBtn];
#pragma clang diagnostic pop
        
        //Download btn
        self.downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.downloadBtn addTarget:self action:@selector(downloadVideoAction) forControlEvents:UIControlEventTouchUpInside];

        CGRect _downloadBtnFrame = CGRectMake(CGRectGetMinX(self.fullscreenBtn.frame) - kDownloadBtnPaddingRightToFullScreenBtn_NonFullScreen - kActionBtnWidth_NonFullScrenn, 0, kActionBtnWidth_NonFullScrenn, self.height);
        self.downloadBtn.frame = _downloadBtnFrame;
        [self.downloadBtn setShowsTouchWhenHighlighted:NO];
        [self.downloadBtn setImage:[UIImage themeImageNamed:@"wsmv_download.png"] forState:UIControlStateNormal];
        [self.downloadBtn setImage:[UIImage themeImageNamed:@"wsmv_download_hl.png"] forState:UIControlStateHighlighted];
        [self addSubview:self.downloadBtn];
    }
    return self;
}

- (void)dealloc {
    self.progressBar.delegate = nil;
}

#pragma mark - Public
- (void)setPlayBtnStatus:(WSMVVideoPlayerPlayBtnStatus)playBtnStatus {
    if (_playBtnStatus != playBtnStatus) {
        _playBtnStatus = playBtnStatus;
        
        if (playBtnStatus == WSMVVideoPlayerPlayBtnStatus_Stop || playBtnStatus == WSMVVideoPlayerPlayBtnStatus_Pause) {
            [self.playBtn setImage:[UIImage themeImageNamed:@"wsmv_play_btn.png"] forState:UIControlStateNormal];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                [self.playBtn setImage:[UIImage themeImageNamed:@"wsmv_play_btn_hl.png"] forState:UIControlStateHighlighted];
            }
        } else if (playBtnStatus == WSMVVideoPlayerPlayBtnStatus_Playing) {
            [self.playBtn setImage:[UIImage themeImageNamed:@"wsmv_pause_btn.png"] forState:UIControlStateNormal];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                [self.playBtn setImage:[UIImage themeImageNamed:@"wsmv_pause_btn_hl.png"] forState:UIControlStateHighlighted];
            }
        }
    }
}

- (void)enableDownload {
    self.downloadBtn.hidden = NO;
}

- (void)disableDownload {
    self.downloadBtn.hidden = YES;
}

- (void)forbidDownload {
    self.downloadBtn.alpha = 0.3;
    [self.downloadBtn setImage:[UIImage themeImageNamed:@"wsmv_cant_download.png"] forState:UIControlStateNormal];
    [self.downloadBtn setImage:[UIImage themeImageNamed:@"wsmv_cant_download.png"] forState:UIControlStateHighlighted];
}

- (void)notForbidDownload {
    self.downloadBtn.alpha = 1;
    [self.downloadBtn setImage:[UIImage themeImageNamed:@"wsmv_download.png"] forState:UIControlStateNormal];
    [self.downloadBtn setImage:[UIImage themeImageNamed:@"wsmv_download_hl.png"] forState:UIControlStateHighlighted];
}

#pragma mark - Private
- (void)tapPlayBtn:(id)sender {
    if (self.playBtnStatus == WSMVVideoPlayerPlayBtnStatus_Stop || self.playBtnStatus == WSMVVideoPlayerPlayBtnStatus_Pause) {
        if ([self.delegate respondsToSelector:@selector(didTapPlayBtnInControlBarToPlay)]) {
            [self.delegate didTapPlayBtnInControlBarToPlay];
        }
    } else if (self.playBtnStatus == WSMVVideoPlayerPlayBtnStatus_Playing) {
        if ([self.delegate respondsToSelector:@selector(didTapPlayBtnInControlBarToPause)]) {
            [self.delegate didTapPlayBtnInControlBarToPause];
        }
    }
}

- (void)downloadVideoAction {
    if ([self.delegate respondsToSelector:@selector(didTapDownloadBtn)]) {
        [self.delegate didTapDownloadBtn];
    }
}

#pragma mark - WSSliderDelegate
- (void)didTouchDown:(WSMVSlider *)slider {
    if ([_delegate respondsToSelector:@selector(didTouchDown:)]) {
        [_delegate didTouchDown:slider];
    }
}

- (void)didTouchMove:(WSMVSlider *)slider {
    if ([_delegate respondsToSelector:@selector(didTouchMove:)]) {
        [_delegate didTouchMove:slider];
    }
}

- (void)didTouchUp:(WSMVSlider *)slider {
    if ([_delegate respondsToSelector:@selector(didTouchUp:)]) {
        [_delegate didTouchUp:slider];
    }
}

- (void)didTouchCancel:(WSMVSlider *)slider {
    if ([_delegate respondsToSelector:@selector(didTouchCancel:)]) {
        [_delegate didTouchCancel:slider];
    }
}

@end
