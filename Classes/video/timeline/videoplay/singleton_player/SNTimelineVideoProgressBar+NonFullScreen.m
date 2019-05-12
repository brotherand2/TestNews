//
//  SNTimelineVideoProgressBar+NonFullScreen.m
//  sohunews
//
//  Created by handy wang on 11/18/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTimelineVideoProgressBar+NonFullScreen.h"
#import "SNTimelineVideoSlider+NonFullScreen.h"

@implementation SNTimelineVideoProgressBar_NonFullScreen

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.passedTimeLabel removeFromSuperview];
        self.passedTimeLabel = nil;
        
        [self.totalTimeLabel removeFromSuperview];
        self.totalTimeLabel = nil;
        
        NSInteger sliderIndex = [self.subviews indexOfObject:self.slider];
        self.delegate = nil;
        [self.slider removeFromSuperview];
        self.slider = nil;
        
        CGRect sliderFrame = CGRectMake(0, 0, self.width, self.height);
        self.slider = [[SNTimelineVideoSlider_NonFullScreen alloc] initWithFrame:sliderFrame];
        [self insertSubview:self.slider atIndex:sliderIndex];
    }
    return self;
}

- (void)updateSubviewsFrame {
    [super updateSubviewsFrame];
    
    self.slider.left = 0;    
    self.slider.width = self.width;
    [self.slider updateSubviewsFrame];
}

- (void)disBackgroundView1 {
    [self.slider.backgroundView removeFromSuperview];
    self.slider.backgroundView = nil;
    
    [self.slider.bufferView removeFromSuperview];
    self.slider.bufferView = nil;
}

@end
