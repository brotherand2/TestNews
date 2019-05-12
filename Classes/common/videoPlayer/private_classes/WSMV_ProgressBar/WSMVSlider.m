//
//  WSSlider.m
//  WeSee
//
//  Created by handy wang on 8/23/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVSlider.h"
#import <QuartzCore/QuartzCore.h>
#import "WSMVVideoControlBar_FullScreen.h"
#import "WSMVVideoVolumnSlider.h"

#define kWSSliderInnerBarHeight (8.0f / 2.0f)
#define kWSSliderThumbWidth     (50 / 2.0f)
#define kWSSliderThumbHeight    (50 / 2.0f)

@interface WSMVSlider() <UIGestureRecognizerDelegate>
@property (nonatomic, assign, readwrite) BOOL isHighlighted;
@end

@implementation WSMVSlider

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.enabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.backgroundView = [[UIImageView alloc] initWithFrame:
                               CGRectMake(kWSSliserInnerBarMarginLeftAndRight,
                                          (self.height - kWSSliderInnerBarHeight) / 2.0f,
                                          self.width - 2 * kWSSliserInnerBarMarginLeftAndRight,
                                          kWSSliderInnerBarHeight)];
        UIImage *_bgImage = [UIImage imageNamed:@"wsmv_slider_bg.png"];
        self.backgroundView.image = [_bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView.userInteractionEnabled = NO;
        [self addSubview:self.backgroundView];
        
        self.bufferView = [[UIImageView alloc] initWithFrame:self.backgroundView.frame];
        UIImage *_bufferBgImage = [UIImage imageNamed:@"wsmv_slider_preload_bg.png"];
        self.bufferView.image = [_bufferBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        self.bufferView.backgroundColor = [UIColor clearColor];
        self.bufferView.userInteractionEnabled = NO;
        [self addSubview:self.bufferView];
        
        self.progressView = [[UIImageView alloc] initWithFrame:self.backgroundView.frame];
        self.progressView.backgroundColor = [UIColor clearColor];
        UIImage *_progressImage = [UIImage imageNamed:@"wsmv_slider_progress.png"];
        self.progressView.image = [_progressImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        self.progressView.userInteractionEnabled = NO;
        [self addSubview:self.progressView];
        
        self.thumbButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.thumbButton.showsTouchWhenHighlighted = YES;
        CGFloat thumBtnHeight = self.height;
        if (thumBtnHeight < 20) {  //全屏视频滑块点击区域太小，特殊处理一下
            thumBtnHeight = 30.f;
        }
        self.thumbButton.frame = CGRectMake(kWSSliserInnerBarMarginLeftAndRight, -1.f, thumBtnHeight, thumBtnHeight);
        if (thumBtnHeight == 30.f) {
            self.thumbButton.centerY = self.centerY - 1.f;
        }
        
        [self.thumbButton setImage:[UIImage themeImageNamed:@"wsmv_slider_thumb.png"] forState:UIControlStateNormal];
        [self.thumbButton setImageEdgeInsets:
         UIEdgeInsetsMake((self.thumbButton.height - kWSSliderThumbHeight) / 2.0f,
                          (self.thumbButton.width - kWSSliderThumbWidth) / 2.0f,
                          (self.thumbButton.height - kWSSliderThumbHeight) / 2.0f,
                          (self.thumbButton.width - kWSSliderThumbWidth) / 2.0f)];
        self.thumbButton.userInteractionEnabled = NO;
        [self addSubview:self.thumbButton];
        
        self.minimumValue = 0.0f;
        self.maximumValue = 1.0f;
        [self assignProgressValue:0];
        self.bufferValue = 0;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //手势与UINavigationController向右滑动返回冲突
    BOOL isCurentViewGesture = NO;
    for (UIGestureRecognizer *cur in self.gestureRecognizers) {
        if (cur == gestureRecognizer) {
            isCurentViewGesture = YES;
            break;
        }
    }
    
    if (!isCurentViewGesture) {
        return NO;
    }
    
    if ([self.superview.superview isKindOfClass:[WSMVVideoControlBar_FullScreen class]]) {
        return NO;
    }
    return YES;
}

- (void)dealloc {
    [self.backgroundView removeFromSuperview];
    [self.progressView removeFromSuperview];
    [self.bufferView removeFromSuperview];
    [self.thumbButton removeFromSuperview];
}

#pragma mark - Public
- (void)updateSubviewsFrame {
    self.backgroundView.frame =
    CGRectMake(kWSSliserInnerBarMarginLeftAndRight,
               (self.height - kWSSliderInnerBarHeight) / 2.0f,
               self.width - 2 * kWSSliserInnerBarMarginLeftAndRight,
               kWSSliderInnerBarHeight);
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    if (!self.enabled) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint _translation = [gesture locationInView:self];
        BOOL _tempIsHignlighted = self.isHighlighted;
        _isHighlighted = YES;
        if (!_tempIsHignlighted) {
            [self updateProgress:&_translation];
        }
        
        if ([_delegate respondsToSelector:@selector(didTouchDown:)]) {
            [_delegate didTouchDown:self];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint _translation = [gesture locationInView:self];
        if ([self isHighlighted]) {
            [self updateProgress:&_translation];
        }
        if ([_delegate respondsToSelector:@selector(didTouchMove:)]) {
            [_delegate didTouchMove:self];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled) {
        if ([_delegate respondsToSelector:@selector(didTouchCancel:)]) {
            [_delegate didTouchCancel:self];
        }
        _isHighlighted = NO;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint _translation = [gesture locationInView:self];
        [self updateProgress:&_translation];
        if ([_delegate respondsToSelector:@selector(didTouchUp:)]) {
            [_delegate didTouchUp:self];
        }
        _isHighlighted = NO;
    }
}

#pragma mark - Override UIResponder methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    BOOL _tempIsHignlighted = self.isHighlighted;
    _isHighlighted = YES;
    if (!_tempIsHignlighted) {
        CGPoint _location = [[touches anyObject] locationInView:self];
        [self updateProgress:&_location];
    }
    
    [super touchesBegan:touches withEvent:event];
    if ([_delegate respondsToSelector:@selector(didTouchDown:)]) {
        [_delegate didTouchDown:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    
    if ([self isHighlighted]) {
        CGPoint _location = [[touches anyObject] locationInView:self];
        [self updateProgress:&_location];
    }
    if ([_delegate respondsToSelector:@selector(didTouchMove:)]) {
        [_delegate didTouchMove:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    [super touchesEnded:touches withEvent:event];
    
    CGPoint _location = [[touches anyObject] locationInView:self];
    [self updateProgress:&_location];
    if ([_delegate respondsToSelector:@selector(didTouchUp:)]) {
        [_delegate didTouchUp:self];
    }
    
    _isHighlighted = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(didTouchCancel:)]) {
        [_delegate didTouchCancel:self];
    }
}

- (void)updateProgress:(CGPoint *)location {
    CGFloat _newValue = (location->x - kWSSliserInnerBarMarginLeftAndRight) / (self.frame.size.width - 2 * kWSSliserInnerBarMarginLeftAndRight);
    if (_newValue < self.minimumValue) {
        _progressValue = self.minimumValue;
    } else if (_newValue > self.maximumValue) {
        _progressValue = self.maximumValue;
    } else {
        _progressValue = _newValue;
    }
    
    if ([self isKindOfClass:[WSMVVideoVolumnSlider class]]) {
        [(WSMVVideoVolumnSlider *)self setVolumnSliderProgressValue:_progressValue];
    } else {
        [self assignProgressValue:_progressValue];
    }
}

#pragma mark - Public
- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.userInteractionEnabled = enabled;
}

- (BOOL)isHighlighted {
    return _isHighlighted || self.thumbButton.isHighlighted;
}

- (void)setProgressValue:(CGFloat)progressValue {
    if (self.isHighlighted && progressValue != self.maximumValue && progressValue != self.minimumValue) {
        return;
    }
    [self assignProgressValue:progressValue];
}

- (void)assignProgressValue:(CGFloat)progressValue {
    if (self.minimumValue == self.maximumValue) {
        return;
    }
    
    _progressValue = progressValue;
    CGFloat _rate = (_progressValue - self.minimumValue) / (self.maximumValue - self.minimumValue);
    self.progressView.width = (self.width - 2 * kWSSliserInnerBarMarginLeftAndRight) * _rate;
    self.thumbButton.center = CGPointMake(CGRectGetMaxX(self.progressView.frame),
                                          self.thumbButton.center.y);
}

- (void)setBufferValue:(CGFloat)bufferValue {
    if (self.minimumValue == self.maximumValue) {
        return;
    }
    
    _bufferValue = bufferValue;
    CGFloat _rate = (_bufferValue - self.minimumValue) / (self.maximumValue - self.minimumValue);
    self.bufferView.width = (self.width - 2 * kWSSliserInnerBarMarginLeftAndRight) * _rate;
}

@end
