//
//  SNRingSpinnerView.m
//  SNNewGallery
//
//  Created by H.Ekko on 03/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import "SNRingSpinnerView.h"

static NSString *SNRingSpinnerAnimationKey = @"snringspinnerview.rotation";

@interface SNRingSpinnerView ()

@property (nonatomic, readonly) CAShapeLayer *progressLayer;

@property (nonatomic, readonly) CAShapeLayer *bgProgressLayer;

@property (nonatomic, readwrite) BOOL isAnimating;

@end

@implementation SNRingSpinnerView
@synthesize progressLayer = _progressLayer;
@synthesize bgProgressLayer = _bgProgressLayer;
@synthesize isAnimating = _isAnimating;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self.layer addSublayer:self.bgProgressLayer];
    [self.layer addSublayer:self.progressLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.bgProgressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self updatePath];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
}

- (void)startAnimating {
    if (self.isAnimating)
        return;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = .8f;
    animation.fromValue = @(0.0f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animation forKey:SNRingSpinnerAnimationKey];
    self.isAnimating = true;
}

- (void)stopAnimating {
    if (!self.isAnimating)
        return;
    
    [self.progressLayer removeAnimationForKey:SNRingSpinnerAnimationKey];
    self.isAnimating = false;
}

#pragma mark - Private

- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
    CGFloat startAngle = (CGFloat)(-M_PI_4);
    CGFloat endAngle = (CGFloat)(1 * M_PI_2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    path.lineCapStyle = kCGLineCapRound;
    self.progressLayer.path = path.CGPath;
    
    CGFloat bgStartAngle = (CGFloat)(-M_PI_4);
    CGFloat bgEndAngle = (CGFloat)(4 * M_PI_2);
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:bgStartAngle endAngle:bgEndAngle clockwise:YES];
    path.lineCapStyle = kCGLineCapRound;
    self.bgProgressLayer.path = bgPath.CGPath;
}

#pragma mark - Properties

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 4.f;
        _progressLayer.lineCap = @"round";
        
    }
    return _progressLayer;
}

- (CAShapeLayer *)bgProgressLayer {
    if (!_bgProgressLayer) {
        _bgProgressLayer = [CAShapeLayer layer];
        _bgProgressLayer.strokeColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        _bgProgressLayer.fillColor = nil;
        _bgProgressLayer.lineWidth = 4.f;
        _bgProgressLayer.lineCap = @"round";
        
    }
    return _bgProgressLayer;

}

- (BOOL)isAnimating {
    return _isAnimating;
}

- (CGFloat)lineWidth {
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.progressLayer.lineWidth = lineWidth;
    self.bgProgressLayer.lineWidth = lineWidth;
    [self updatePath];
}
@end
