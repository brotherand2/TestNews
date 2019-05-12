//
//  SNProgressView.m
//  sohunews
//
//  Created by handy wang on 6/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNProgressView.h"

#define SELF_HEIGHT                                                                             (10.0f/2)

@implementation SNProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, SELF_HEIGHT)];
    if (self) {
        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];

        _backgroundView.image = [[UIImage imageNamed:@"snprogressview_bg.png"]stretchableImageWithLeftCapWidth:2 topCapHeight:0];
        [self addSubview:_backgroundView];

        _trackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.5, 0.5, 0, self.frame.size.height-1)];
        _trackImageView.image = [[UIImage imageNamed:@"snprogressview_track.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:0];
        [self addSubview:_trackImageView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateProgress:(CGFloat)progressValue animated:(BOOL)animated {
    if (_trackImageView && progressValue >= 0 && progressValue <= 1) {
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        CGRect _tmpFrame = _trackImageView.frame;
        _tmpFrame.size.width = (self.frame.size.width-1.3)*progressValue;
        _trackImageView.frame = _tmpFrame;
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void)dealloc {
    _backgroundView = nil;
    
    _trackImageView = nil;
    
}

@end
