//
//  SNDrawOvalAnimation.m
//  drawCircle
//
//  Created by HuangZhen on 2017/8/14.
//  Copyright © 2017年 HuangZhen. All rights reserved.
//

#import "SNDrawOvalAnimation.h"

typedef void(^SNDrawOvalAnimationCompletedBlock)(void);

@interface SNDrawOvalAnimation () <CAAnimationDelegate>

@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, strong) UIView * finger;
@property (nonatomic, copy) SNDrawOvalAnimationCompletedBlock completeBlock;

@end

@implementation SNDrawOvalAnimation

+ (void)start {
    
    UIScreen * mainScreen = [UIScreen mainScreen];
    UIView * base = [[UIView alloc] initWithFrame:mainScreen.bounds];
    SNDrawOvalAnimation * animation = [[SNDrawOvalAnimation alloc] initWithFrame:CGRectMake(0, 0, 240, 120)];
    animation.center = CGPointMake(base.width/2.f, base.height/2.f);
    [base addSubview:animation];
    [[UIApplication sharedApplication].keyWindow addSubview:base];
    __weak __typeof(base)weakBase = base;
    [animation startWithComplete:^{
        [weakBase removeFromSuperview];
    }];
}

- (void)startWithComplete:(SNDrawOvalAnimationCompletedBlock)completed {
    self.completeBlock = completed;
    [self.layer addSublayer:self.finger.layer];
    self.finger.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
        self.finger.alpha = 1;
        self.finger.frame = CGRectMake(self.frame.size.width/2.f, 15, 30, 30);
    } completion:^(BOOL finished) {
        [self.layer addSublayer:self.finger.layer];
        [self.layer addSublayer:self.trackLayer];
        [self addFingerAnimation];
        [self startAnimationDuration:2];
    }];
}

- (UIBezierPath *)bezierPath
{
    if (!_bezierPath) {
//        _bezierPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
        _bezierPath = [UIBezierPath bezierPath];
        [_bezierPath moveToPoint: CGPointMake(120, 25.5)];
        [_bezierPath addCurveToPoint: CGPointMake(120, 94.5) controlPoint1: CGPointMake(-19.33, 25.5) controlPoint2: CGPointMake(-19.33, 94.5)];
        [_bezierPath addCurveToPoint: CGPointMake(120, 25.5) controlPoint1: CGPointMake(259.33, 94.5) controlPoint2: CGPointMake(259.33, 25.5)];
        [_bezierPath closePath];
    }
    return _bezierPath;
}

- (CAShapeLayer *)trackLayer
{
    if (!_trackLayer) {
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.frame = self.bounds;
        _trackLayer.fillColor = [UIColor clearColor].CGColor;
        _trackLayer.lineWidth = 2.f;
        _trackLayer.strokeColor = SNUICOLOR(kThemeRed1Color).CGColor;
        _trackLayer.strokeStart = 0;
        _trackLayer.strokeEnd =1;
        _trackLayer.path = self.bezierPath.CGPath;
    }
    return _trackLayer;
}

- (UIView *)finger {
    if (!_finger) {
        _finger = [[UIView alloc] initWithFrame:CGRectMake(700, 0, 30, 30)];
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 30, 30)];
        img.contentMode = UIViewContentModeScaleAspectFit;
        img.image = [UIImage imageNamed:@"ico_hand.png"];
        [_finger addSubview:img];
        _finger.backgroundColor = [UIColor clearColor];
    }
    return _finger;
}

- (void)addFingerAnimation {
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;// 是否在动画完成后从 Layer 层上移除  回到最开始状态
    pathAnimation.duration = 3;// 动画时间
    pathAnimation.repeatCount = 1;// 动画重复次数
    pathAnimation.path = self.bezierPath.CGPath;
    pathAnimation.delegate = self;
    [self.finger.layer addAnimation:pathAnimation forKey:@"pathAnimation"];
}

#pragma mark ---
- (void)startAnimationDuration:(CGFloat)duration
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];  //
    anim.fromValue = @0;
    anim.toValue = @1;
    anim.duration = duration;
    anim.delegate = self;
    [self.trackLayer addAnimation:anim forKey:@"strokeAnimation"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim == [self.finger.layer animationForKey:@"pathAnimation"]) {
        [UIView animateWithDuration:0.5 animations:^{
            self.finger.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self.finger.layer removeAllAnimations];
                [self.trackLayer removeAllAnimations];
                [self removeFromSuperview];
                self.completeBlock();
            }];
        }];
    }
}

@end
