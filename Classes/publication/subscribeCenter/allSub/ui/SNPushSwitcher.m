//
//  SNPushSwitcher.m
//  sohunews
//
//  Created by wang yanchen on 12-12-3.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNPushSwitcher.h"

#define kHandlerInset           (2)
#define kTouchSensitiveOffset   (10)

@implementation SNPushSwitcher
@synthesize delegate = _delegate,currentIndex=_currentIndex;
@synthesize scrollViewDelegate;
@synthesize maskView = _maskView;
@synthesize bgSliderView = _bgSliderView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *maskImage = [UIImage themeImageNamed:@"subcenter_switcher_mask.png"];
        _maskView = [[UIImageView alloc] initWithImage:maskImage];
        _maskView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        [self addSubview:_maskView];
        
        UIImage *image = [UIImage themeImageNamed:@"subcenter_switcher_handler_off.png"];
        _handlerView = [[UIImageView alloc] initWithFrame:CGRectMake(-kHandlerInset, 0, image.size.width, image.size.height)];
        _handlerView.centerY = _maskView.centerY;
        _handlerView.image = image;
        [self addSubview:_handlerView];
        
        UIImage *bgSliderImage = [UIImage themeImageNamed:@"subcenter_switcher_slider.png"];
        _bgSliderView = [[UIImageView alloc] initWithImage:bgSliderImage];
        _bgSliderView.center = _handlerView.center;
        [self insertSubview:_bgSliderView belowSubview:_maskView];
        
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.isAccessibilityElement = YES;
        self.exclusiveTouch = YES;
        self.supportDrag = YES;
        _currentIndex=0;
        _lastIndex=0;
        
        [SNNotificationManager addObserver:self selector:@selector(newsFlashNotification) name:kPushOpenNewsFlashNotification object:nil];
        
    }
    return self;
}

- (void)newsFlashNotification {
    if ([self.switchName isEqualToString:kExpressName]) {
        [self tapped];
    }
}

- (void)tapped {
    if (_currentIndex == 0) {
        _currentIndex = 1;
    }
    else {
        _currentIndex = 0;
    }
    
    [self setCurrentIndex:_currentIndex animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _isTouched = YES;
    _isMoved = NO;
    _isOverFlowTapOffset = NO;
    UITouch *aTouch = [touches anyObject];
    _downPt = [aTouch locationInView:self];
    _handlerLastX = _handlerView.left;
    // lock scroll view if needed
    if (self.supportDrag) {
        if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(setScrollEnabled:)]) {
            [self.scrollViewDelegate setScrollEnabled:NO];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    CGPoint mvPt = [aTouch locationInView:self];
    _isMoved = YES;
//    if (!CGRectContainsPoint(self.bounds, mvPt)) {
//        return [self touchesCancelled:touches withEvent:event];
//    }
    if (!_isOverFlowTapOffset && (ABS(mvPt.x - _downPt.x) > kTouchSensitiveOffset || ABS(mvPt.y - _downPt.y) > kTouchSensitiveOffset)) {
        _isOverFlowTapOffset = YES;
    }
    
    if (self.supportDrag && _isTouched) {
        CGFloat dX = mvPt.x - _downPt.x;
        CGFloat cp = _handlerLastX;
        
        cp += dX;
        cp = MAX(cp, -kHandlerInset);
        cp = MIN(cp, self.width + kHandlerInset - _handlerView.width);
        
        _handlerView.left = cp;
        _bgSliderView.center = _handlerView.center;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isTouched = NO;
    _currentIndex = (_handlerView.centerX < self.width / 2) ? 0 : 1;
    [self setCurrentIndex:_currentIndex animated:YES];
    
    // unlock scroll 
    if (self.supportDrag) {
        if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(setScrollEnabled:)]) {
            [self.scrollViewDelegate setScrollEnabled:YES];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    CGPoint endPt = [aTouch locationInView:self];
    if (!self.supportDrag) {
        if (_isTouched) {
            if (CGRectContainsPoint(self.bounds, endPt) && !_isOverFlowTapOffset) {
                [self tapped];
            }
            else {
                return [self touchesCancelled:touches withEvent:event];
            }
        }
    }
    else {
        if (_isTouched) {
            if (ABS(endPt.x - _downPt.x) < kTouchSensitiveOffset && !_isOverFlowTapOffset) {
                [self tapped];
            }
            else {
                if (!_isMoved) {
                    if (endPt.x-_downPt.x>0) {
                        _currentIndex=1;
                    }
                    else{
                        _currentIndex=0;
                    }
                    [self setCurrentIndex:_currentIndex animated:YES];
                }else{
                    _currentIndex = (_handlerView.centerX < self.width / 2) ? 0 : 1;
                    [self setCurrentIndex:_currentIndex animated:YES];
                }
            }
        }
    }
    _isTouched = NO;
    // unlock scroll
    if (self.supportDrag) {
        if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(setScrollEnabled:)]) {
            [self.scrollViewDelegate setScrollEnabled:YES];
        }
    }
}

- (void)dealloc {
    _delegate = nil;
    self.scrollViewDelegate = nil;
     //(_bgSliderView);
     //(_handlerView);
     //(_maskView);
     //(_switchName);
    [SNNotificationManager removeObserver:self];
}

- (void)setCurrentIndex:(int)index animated:(BOOL)animated
{
    [self setCurrentIndex:index animated:animated inEvent:YES];
}

- (void)setCurrentIndex:(int)index animated:(BOOL)animated inEvent:(BOOL)isInEvent {
    _currentIndex = index;
    if (_currentIndex < 0) {
        _currentIndex = 0;
    }
    else if (_currentIndex > 1) {
        _currentIndex = 1;
    }
    
    [self setAccessibilityLabel:[NSString stringWithFormat:@"推送开关 当前状态：%@", _currentIndex == 0 ? @"关闭" : @"打开"]];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            if (index <= 0) {
                _handlerView.left = -kHandlerInset;
            }
            else {
                _handlerView.right = _maskView.right + kHandlerInset;
            }
            
            _bgSliderView.center = _handlerView.center;
        } completion:^(BOOL isFinished){
            [self switchAnimationDidStop:isInEvent];
        }];
    }
    else {
        if (index <= 0) {
            _handlerView.left = -kHandlerInset;
        }
        else {
            _handlerView.right = _maskView.right + kHandlerInset;
        }
        
        _bgSliderView.center = _handlerView.center;
        [self switchAnimationDidStop:isInEvent];
    }
    
    
}

- (void)switchAnimationDidStop:(BOOL)isEvent {
    if (_currentIndex == 0) {
        _handlerView.image = [UIImage themeImageNamed:@"subcenter_switcher_handler_off.png"];
    }
    else {
        _handlerView.image = [UIImage themeImageNamed:@"subcenter_switcher_handler_on.png"];
    }
    
    if (_lastIndex!=_currentIndex) {
        _lastIndex=_currentIndex;
        if (isEvent) {
            if ([_delegate respondsToSelector:@selector(swither:indexDidChanged:)]) {
                [_delegate swither:self indexDidChanged:_currentIndex];
            }
        }
    }
    
}

@end
