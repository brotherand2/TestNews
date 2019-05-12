//
//  WSMVVideoControlBar+NonFullScreen.m
//  WeSee
//
//  Created by handy wang on 9/9/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoControlBar+NonFullScreen.h"

@implementation WSMVVideoControlBar_NonFullScreen

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {        
        //Progress bar
        CGFloat _progressBarLeft = CGRectGetMaxX(self.playBtn.frame) + kProgressBarPaddingLeftToPlayBtn_NonFullScreen;
        CGRect _progressBarFrame =
        CGRectMake(_progressBarLeft, 0, CGRectGetMinX(self.downloadBtn.frame) - kProgressBarPaddingRightToDownloadBtn_NonFullScreen - _progressBarLeft,
                                              self.height);
        self.progressBar = [[WSMVVideoProgressBar alloc] initWithFrame:_progressBarFrame];
        self.progressBar.delegate = self;
        self.progressBar.exclusiveTouch = YES;
        [self addSubview:self.progressBar];
        
        [self disableDownload];
    }
    return self;
}

#pragma mark - Override
- (void)fullscreenAction {
    if ([self.delegate respondsToSelector:@selector(toFullScreen)]) {
        [self.delegate toFullScreen];
    }
}

- (void)enableDownload {
    [super enableDownload];
    
    self.downloadBtn.left = self.fullscreenBtn.left - kDownloadBtnPaddingRightToFullScreenBtn_NonFullScreen - kActionBtnWidth_NonFullScrenn;
    
    CGFloat _progressBarLeft = self.playBtn.right + kProgressBarPaddingLeftToPlayBtn_NonFullScreen;
    CGFloat _progressBarWidth = self.downloadBtn.left - kProgressBarPaddingRightToDownloadBtn_NonFullScreen - _progressBarLeft;
    self.progressBar.width = _progressBarWidth;
    [self.progressBar updateSubviewsFrame];
}

- (void)disableDownload {
    [super disableDownload];
    
    self.downloadBtn.left = self.fullscreenBtn.left-kDownloadBtnPaddingRightToFullScreenBtn_NonFullScreen-kActionBtnWidth_NonFullScrenn;
    
    CGFloat _progressBarLeft = self.playBtn.right + kProgressBarPaddingLeftToPlayBtn_NonFullScreen;
    CGFloat _progressBarWidth = self.downloadBtn.left - kProgressBarPaddingRightToDownloadBtn_NonFullScreen - _progressBarLeft+self.downloadBtn.width;
    self.progressBar.width = _progressBarWidth;
    [self.progressBar updateSubviewsFrame];
}

@end
