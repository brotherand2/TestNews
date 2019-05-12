//
//  UIWaitingActivityView.m
//  RedAnim
//
//  Created by Xiang WeiJia on 12/18/14.
//  Copyright (c) 2014 Xiang WeiJia. All rights reserved.
//

#import "SNWaitingActivityView.h"
#import <QuartzCore/CAAnimation.h>

#define kActivityFrameWidth  12
#define kActivityFrameHeight 12

#define kBallLeftRightMargin 1.0f

#define kActivityCircleRadius 2.5
#define kActivityCircleDiameter (kActivityCircleRadius * 2)

#define kActivityCircle1RepeatedScaleAnimationKey  @"activity_circle1_repeated_scale_animation_key"
#define kActivityCircle2RepeatedScaleAnimationKey  @"activity_circle2_repeated_scale_animation_key"

#define kActivityWaitDuration 0.4

@interface SNWaitingActivityView()

@property (nonatomic, strong) CALayer *ball1;
@property (nonatomic, strong) CALayer *ball2;

@property BOOL animating;

@end

@implementation SNWaitingActivityView

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {

    _hidesWhenStopped = hidesWhenStopped;
    
    if (![self isAnimating]) {
        [self.ball1 removeFromSuperlayer];
        [self.ball2 removeFromSuperlayer];

        if (!self.hidesWhenStopped) {
            [self.layer addSublayer:self.ball1];
            [self.layer addSublayer:self.ball2];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {

    self = [self init];
    
    if (self) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, kActivityFrameWidth, kActivityFrameHeight);
    }
    
    return self;
}

- (instancetype)init {

    self = [super initWithFrame:CGRectMake(0, 0, kActivityFrameWidth, kActivityFrameWidth)];
    
    if (self) {
        self.ball1 = [self createBallWithPosition:kBallLeftRightMargin];
        self.ball2 = [self createBallWithPosition:(kActivityFrameWidth - kBallLeftRightMargin - kActivityCircleDiameter)];
        
        self.hidesWhenStopped = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, kActivityFrameWidth, kActivityFrameHeight);
    }
    
    return self;
}


- (CALayer *)createBallWithPosition:(float)x{
    
    CALayer *ball = [CALayer layer];

    //设置layer的属性
    ball.bounds = CGRectMake(x, (kActivityFrameHeight - kActivityCircleDiameter) / 2, kActivityCircleDiameter, kActivityCircleDiameter);
    ball.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color]].CGColor;
    ball.position = ball.bounds.origin;
    ball.anchorPoint = CGPointMake(0, 0);
    ball.cornerRadius = kActivityCircleRadius;
    
    return ball;
}

- (CABasicAnimation *)createAnimatingWithToPosition:(float)x {
    
    CABasicAnimation *anima = [CABasicAnimation animation];
    
    anima.keyPath = @"transform";
    anima.duration = kActivityWaitDuration;
    anima.repeatCount = 1000000;  // 基本上不会播放完吧，除非纯心找茬
    anima.autoreverses = YES;
    anima.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(x, 0, 0)];
    anima.removedOnCompletion = NO;
    anima.fillMode = kCAFillModeForwards;
    anima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return anima;
}

- (void)stopAnimating {

    if (self.isAnimating) {
        _animating = NO;
        [_ball1 removeAnimationForKey:kActivityCircle1RepeatedScaleAnimationKey];
        [_ball2 removeAnimationForKey:kActivityCircle2RepeatedScaleAnimationKey];
        
        if (self.hidesWhenStopped) {
            [self.ball1 removeFromSuperlayer];
            [self.ball2 removeFromSuperlayer];
        }
    }
}

- (BOOL)isAnimating {
    
    return _animating;
}

- (void)startAnimating {
    
    if (!self.isAnimating) {
        _animating = YES;
        
        [self.ball1 removeFromSuperlayer];
        [self.ball2 removeFromSuperlayer];
        
        [self.layer addSublayer:self.ball1];
        [self.layer addSublayer:self.ball2];
        
        float toValue = kBallLeftRightMargin + (kActivityFrameWidth / 2 - kBallLeftRightMargin - kActivityCircleRadius);
        
        [self.ball1 addAnimation:[self createAnimatingWithToPosition:toValue]
                          forKey:kActivityCircle1RepeatedScaleAnimationKey];
        
        [self.ball2 addAnimation:[self createAnimatingWithToPosition:-toValue]
                          forKey:kActivityCircle2RepeatedScaleAnimationKey];
    }
}

- (void)updateTheme {
    
    self.ball1.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color]].CGColor;
    self.ball2.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color]].CGColor;
}

@end
