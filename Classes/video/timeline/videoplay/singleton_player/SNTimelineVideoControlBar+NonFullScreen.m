//
//  SNTimelineVideoControlBar_NonFullScreen.m
//  sohunews
//
//  Created by handy wang on 11/15/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTimelineVideoControlBar+NonFullScreen.h"

@implementation SNTimelineVideoControlBar_NonFullScreen

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.image = nil;
        self.userInteractionEnabled = NO;
        
        [self.siteNameLabel removeFromSuperview];
        self.siteNameLabel = nil;
        
        [self.playBtn removeFromSuperview];
        self.playBtn = nil;
        
        [self.fullscreenBtn removeFromSuperview];
        self.fullscreenBtn = nil;
        
        //Progress bar
        NSInteger progressBarIndex = [self.subviews indexOfObject:self.progressBar];
        CGRect progressBarFrame = self.progressBar.frame;
        [self.progressBar removeFromSuperview];
        self.progressBar.delegate = nil;
        self.progressBar = nil;
        
        self.progressBar = [[SNTimelineVideoProgressBar_NonFullScreen alloc] initWithFrame:progressBarFrame];
        self.progressBar.left = 0;
        self.progressBar.width = self.width;
        self.progressBar.delegate = self;
        [self insertSubview:self.progressBar atIndex:progressBarIndex];
        
        //Download btn
        [self.downloadBtn removeFromSuperview];
        self.downloadBtn = nil;
    }
    return self;
}

- (void)enableDownload {
    [super enableDownload];
    
    self.progressBar.left = 0;
    self.progressBar.width = self.width;
    [self.progressBar updateSubviewsFrame];
}

- (void)disableDownload {
    [super disableDownload];
    
    self.progressBar.left = 0;
    self.progressBar.width = self.width;
    [self.progressBar updateSubviewsFrame];
}

- (void)disBackgroundView {
//    [self.progressBar disBackgroundView1];
    [self.progressBar.slider.backgroundView removeFromSuperview];
    self.progressBar.slider.backgroundView = nil;
    
    [self.progressBar.slider.bufferView removeFromSuperview];
    self.progressBar.slider.bufferView = nil;

}

@end
