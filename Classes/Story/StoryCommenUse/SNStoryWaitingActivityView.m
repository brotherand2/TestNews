//
//  SNStoryWaitingActivityView.m
//  RedAnim
//
//  Created by Xiang WeiJia on 12/18/14.
//  Copyright (c) 2014 Xiang WeiJia. All rights reserved.
//

#import "SNStoryWaitingActivityView.h"
#import <QuartzCore/CAAnimation.h>
#import "SNStoryContanst.h"
#import "UIViewAdditions+Story.h"

#define BallLeftRightMargin 1.0f

#define BallCircleRadius 6
#define BallCircleDiameter (BallCircleRadius * 2)

#define LeftBallRepeatedScaleAnimationKey   @"LeftBallRepeatedScaleAnimationKey"
#define RightBallRepeatedScaleAnimationKey  @"RightBallRepeatedScaleAnimationKey"

#define BallActivityWaitDuration 0.4

@interface SNStoryWaitingActivityView()

@property (nonatomic, retain) CALayer *ball1;
@property (nonatomic, retain) CALayer *ball2;
@property (weak,nonatomic)UIView *superView;
@property BOOL animating;

@end

@implementation SNStoryWaitingActivityView

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

    self = [super initWithFrame:frame];
    self.tag = 1111101;
    if (self) {
        self.ball1 = [self createBallWithPosition:(self.width - BallCircleDiameter*2 - BallLeftRightMargin)/2];
        self.ball2 = [self createBallWithPosition:((self.width - BallCircleDiameter*2 - BallLeftRightMargin)/2 + BallLeftRightMargin + BallCircleDiameter)];
        self.userInteractionEnabled = NO;
        self.hidesWhenStopped = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (CALayer *)createBallWithPosition:(float)x{
    
    CALayer *ball = [CALayer layer];

    //设置layer的属性
    ball.bounds = CGRectMake(x, (self.height - BallCircleDiameter) / 2, BallCircleDiameter, BallCircleDiameter);
    ball.backgroundColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
    ball.position = ball.bounds.origin;
    ball.anchorPoint = CGPointMake(0, 0);
    ball.cornerRadius = BallCircleRadius;
    
    return ball;
}

- (CABasicAnimation *)createAnimatingWithToPosition:(float)x {
    
    CABasicAnimation *anima = [CABasicAnimation animation];
    
    anima.keyPath = @"transform";
    anima.duration = BallActivityWaitDuration;
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
        [_ball1 removeAnimationForKey:LeftBallRepeatedScaleAnimationKey];
        [_ball2 removeAnimationForKey:RightBallRepeatedScaleAnimationKey];
        
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
        
        float toValue = BallLeftRightMargin + BallCircleRadius;
        
        [self.ball1 addAnimation:[self createAnimatingWithToPosition:toValue]
                          forKey:LeftBallRepeatedScaleAnimationKey];
        
        [self.ball2 addAnimation:[self createAnimatingWithToPosition:-toValue]
                          forKey:RightBallRepeatedScaleAnimationKey];
    }
}

- (void)updateTheme {
    
    self.ball1.backgroundColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
    self.ball2.backgroundColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
}

@end
