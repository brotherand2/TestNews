//
//  SNTimelineVideoSlider+NonFullScreen.m
//  sohunews
//
//  Created by handy wang on 11/18/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTimelineVideoSlider+NonFullScreen.h"
#define kWSSliderInnerBarHeight                                 (4.0f/2.0f)

@implementation SNTimelineVideoSlider_NonFullScreen

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        
        [self removeAllSubviews];
        self.backgroundView = nil;
        self.bufferView = nil;
        self.progressView = nil;
        self.thumbButton = nil;
        
        //Background view
        self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                             self.height-kWSSliderInnerBarHeight,
                                                                             self.width,
                                                                             kWSSliderInnerBarHeight)];
        UIImage *_bgImage = [UIImage imageNamed:@"timeline_videoplay_totalprogress_bg.png"];
        self.backgroundView.image = [_bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 1)];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView.userInteractionEnabled = NO;
        [self addSubview:self.backgroundView];
        
        //Buffer view
        self.bufferView = [[UIImageView alloc] initWithFrame:self.backgroundView.frame];
        UIImage *_bufferBgImage = [UIImage imageNamed:@"timeline_videoplay_playableprogress_bg.png"];
        self.bufferView.image = [_bufferBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 1)];
        self.bufferView.backgroundColor = [UIColor clearColor];
        self.bufferView.userInteractionEnabled = NO;
        [self addSubview:self.bufferView];
        
        //Progress view
        self.progressView = [[UIImageView alloc] initWithFrame:self.backgroundView.frame];
        UIImage *_progressImage = [UIImage imageNamed:@"timeline_videoplay_progress_bg.png"];
        self.progressView.image = [_progressImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 1)];
        self.progressView.backgroundColor = [UIColor clearColor];
        self.progressView.userInteractionEnabled = NO;
        [self addSubview:self.progressView];
        
        self.minimumValue = 0.0f;
        self.maximumValue = 1.0f;
        [self assignProgressValue:0];
        self.bufferValue = 0;
    }
    return self;
}

- (void)assignProgressValue:(CGFloat)progressValue {
    [super assignProgressValue:progressValue];

    CGFloat _rate = (progressValue-self.minimumValue)/(self.maximumValue-self.minimumValue);
    self.progressView.width = self.width*_rate;
}

- (void)setBufferValue:(CGFloat)bufferValue {
    [super setBufferValue:bufferValue];
    
    CGFloat _rate = (bufferValue-self.minimumValue)/(self.maximumValue-self.minimumValue);
    self.bufferView.width = self.width*_rate;
}

- (void)updateSubviewsFrame {
    self.backgroundView.frame = CGRectMake(0,
                                           self.height-kWSSliderInnerBarHeight,
                                           self.width,
                                           kWSSliderInnerBarHeight);
}

@end
