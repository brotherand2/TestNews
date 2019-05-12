//
//  WSMVVideoProgressBar.h
//  WeSee
//
//  Created by handy on 8/15/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMVSlider.h"

@interface WSMVVideoProgressBar : UIView
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) WSMVSlider *slider;
@property (nonatomic, strong) UILabel *passedTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;

- (void)updateSubviewsFrame;
- (void)resetTimeLabel;
- (void)setTimeLabelTextToNonLive;
- (void)setTimeLabelTextToLive;
- (void)updateToCurrentTime:(double)seconds duration:(double)duration;
- (void)updateBuffer:(double)seconds duration:(double)duration;

@end
