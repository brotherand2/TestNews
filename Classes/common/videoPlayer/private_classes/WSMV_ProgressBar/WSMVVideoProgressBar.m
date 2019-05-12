//
//  WSMVVideoProgressBar.m
//  WeSee
//
//  Created by handy on 8/15/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoProgressBar.h"

#define kTimeLabelTextFontSize                  (7.0f)
#define kProgressTimeLabelWidth                 (35.0f)
#define kSliderPaddingLeftToPassedTimeLabel     (5.0f)

static NSString * const kDefaultHumanReadableTime = @"00:00:00";
static NSString * const kLiveTimeText = @"Live";

@implementation WSMVVideoProgressBar

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.passedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kProgressTimeLabelWidth, self.height)];
        self.passedTimeLabel.backgroundColor = [UIColor clearColor];
        self.passedTimeLabel.textAlignment = NSTextAlignmentLeft;
        self.passedTimeLabel.textColor = [UIColor whiteColor];
        self.passedTimeLabel.font = [UIFont systemFontOfSize:kTimeLabelTextFontSize];
        [self addSubview:self.passedTimeLabel];
        
        self.totalTimeLabel = [[UILabel alloc] initWithFrame:
                               CGRectMake(self.width - kProgressTimeLabelWidth,
                                          0,
                                          kProgressTimeLabelWidth,
                                          self.height)];
        self.totalTimeLabel.backgroundColor = [UIColor clearColor];
        self.totalTimeLabel.textAlignment = NSTextAlignmentRight;
        self.totalTimeLabel.font = [UIFont systemFontOfSize:kTimeLabelTextFontSize];
        self.totalTimeLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.totalTimeLabel];
        
        [self resetTimeLabel];
        
        CGFloat leftOfSlider = self.passedTimeLabel.right + kSliderPaddingLeftToPassedTimeLabel - kWSSliserInnerBarMarginLeftAndRight;
        CGFloat widthOfSlider = self.width - 2 * kProgressTimeLabelWidth - 2 * kSliderPaddingLeftToPassedTimeLabel + 2 * kWSSliserInnerBarMarginLeftAndRight;
        self.slider = [[WSMVSlider alloc] initWithFrame:
                       CGRectMake(leftOfSlider, 0,
                                  widthOfSlider, self.height)];
        self.slider.delegate = self;
        self.slider.minimumValue = 0;
        self.slider.maximumValue = 1;
        self.slider.progressValue = 0.0;
        self.slider.bufferValue = 0.0;
        [self addSubview:self.slider];
    }
    return self;
}

- (void)dealloc {
    self.slider.delegate = nil;
    [self.slider removeFromSuperview];
}

#pragma mark - Public
- (void)updateSubviewsFrame {
    self.passedTimeLabel.frame = CGRectMake(0, 0, kProgressTimeLabelWidth, CGRectGetHeight(self.frame));
    self.totalTimeLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - kProgressTimeLabelWidth, 0, kProgressTimeLabelWidth, CGRectGetHeight(self.frame));
    
    self.slider.frame =
    CGRectMake(CGRectGetMaxX(self.passedTimeLabel.frame) + kSliderPaddingLeftToPassedTimeLabel - kWSSliserInnerBarMarginLeftAndRight,
               0,
               CGRectGetWidth(self.frame) - 2 * kProgressTimeLabelWidth - 2 * kSliderPaddingLeftToPassedTimeLabel + 2 * kWSSliserInnerBarMarginLeftAndRight,
               CGRectGetHeight(self.frame));
    
    self.slider.bounds = CGRectMake(0, 0, self.slider.width, self.slider.height);
    [self.slider updateSubviewsFrame];
}

- (void)resetTimeLabel {
    self.userInteractionEnabled = NO;
    self.slider.enabled = NO;
    self.passedTimeLabel.text = kDefaultHumanReadableTime;
    self.totalTimeLabel.text = kDefaultHumanReadableTime;
    self.slider.progressValue = 0.0f;
    self.slider.bufferValue = 0.0f;
}

- (void)setTimeLabelTextToNonLive {
    self.userInteractionEnabled = YES;
    self.slider.enabled = YES;
}

- (void)setTimeLabelTextToLive {
    self.userInteractionEnabled = NO;
    self.slider.enabled = NO;
    self.slider.progressValue = 0.0f;
    self.slider.bufferValue = 0.0f;
    self.passedTimeLabel.text = kLiveTimeText;
    self.totalTimeLabel.text = kLiveTimeText;
}

- (void)updateToCurrentTime:(double)seconds duration:(double)duration {
    float minValue = [self.slider minimumValue];
    float maxValue = [self.slider maximumValue];
    if (duration != 0) {
        [self.slider setProgressValue:(maxValue - minValue) * seconds / duration + minValue];
    } else {
        [self.slider setProgressValue:0];
    }
    
    NSString *_passedTime = [self getHumanReadableTime:seconds];
    self.passedTimeLabel.text = _passedTime;
    
    NSString *_totalTime = [self getHumanReadableTime:(duration)];
    self.totalTimeLabel.text = _totalTime;
}

- (void)updateBuffer:(double)seconds duration:(double)duration {
    float minValue = [self.slider minimumValue];
    float maxValue = [self.slider maximumValue];
    if (duration != 0) {
        [self.slider setBufferValue:(maxValue - minValue) * seconds / duration + minValue];
    } else {
        [self.slider setBufferValue:0];
    }
}

- (NSString *)getHumanReadableTime:(double)secondsOfHumanUnreadable {
    NSUInteger dHours = floor(secondsOfHumanUnreadable / 3600);
    NSUInteger dMinutes = floor((NSUInteger)secondsOfHumanUnreadable % 3600 / 60);
    NSUInteger dSeconds = floor((NSUInteger)secondsOfHumanUnreadable % 3600 % 60);
    
    NSString *_humanReadableTime = nil;
    if (dHours>0) {
        _humanReadableTime = [NSString stringWithFormat:@"%02lu:%02lu:%02lu",(unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
    } else {
        _humanReadableTime = [NSString stringWithFormat:@"00:%02lu:%02lu",(unsigned long)dMinutes, (unsigned long)dSeconds];
    }
    return _humanReadableTime;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)events{
    if (self.alpha == 1 && CGRectContainsPoint(self.slider.frame, point)) {
        self.userInteractionEnabled = YES;
        self.slider.userInteractionEnabled = YES;
        return [super hitTest:point withEvent:events];
    }
    return [super hitTest:point withEvent:events];
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
