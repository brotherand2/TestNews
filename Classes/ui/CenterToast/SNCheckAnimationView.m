//
//  SNCheckAnimationView.m
//  WebViewZoomDemo
//
//  Created by Scarlett on 16/8/23.
//  Copyright © 2016年 Scalett. All rights reserved.
//

#import "SNCheckAnimationView.h"
#import "SNCheckAnimationMoveLayer.h"

static NSString *kNameString = @"name";

static CGFloat const kRadius = 12;
static CGFloat const kStep1Duration = 0.5;
static CGFloat const kStep2Duration = 0.2;
static CGFloat const kCircleRadius = 25.0;

@interface SNCheckAnimationView () <CAAnimationDelegate>

@property (strong, nonatomic) SNCheckAnimationMoveLayer *arcMoveLayer;
@property (strong, nonatomic) CAShapeLayer *checkLine;

@end
@implementation SNCheckAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - public
- (void)startSuccessAnimation {
    [self reset];
    [self doSuccessStep1];
}

- (void)startErrorAnimation {
    [self reset];
}

#pragma mark - animation
- (void)reset {
    [self.arcMoveLayer removeFromSuperlayer];
    [self.checkLine removeFromSuperlayer];
}

#pragma mark - animation step stop
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:kNameString] isEqualToString:@"successStep1"]) {
        [self doSuccessStep2];
    }
}
// 成功 第1阶段
- (void)doSuccessStep1 {
    self.arcMoveLayer = [SNCheckAnimationMoveLayer layer];
    self.arcMoveLayer.contentsScale = [UIScreen mainScreen].scale;
    self.arcMoveLayer.bounds = CGRectMake(0, 0, kCircleRadius, kCircleRadius);
    self.arcMoveLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // animation
    self.arcMoveLayer.progress = 1; // end status
    [self.layer addSublayer:self.arcMoveLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
    animation.duration = kStep1Duration;
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.delegate = self;
    [animation setValue:@"successStep1" forKey:kNameString];
    [self.arcMoveLayer addAnimation:animation forKey:nil];
}

#pragma mark - success
//成功 第2阶段
- (void)doSuccessStep2 {
    self.checkLine = [CAShapeLayer layer];
    [self.layer addSublayer:self.checkLine];
    self.checkLine.frame = self.layer.bounds;
    // path
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    path.lineCapStyle = kCGLineCapSquare; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    
    [path moveToPoint:CGPointMake(CGRectGetMidX(self.bounds) - kRadius + 5, CGRectGetMidY(self.bounds))];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.bounds) - kRadius / 5, CGRectGetMidY(self.bounds) + kRadius / 5 * 2)];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.bounds) + kRadius - kRadius / 8 * 3, CGRectGetMidY(self.bounds) - kRadius / 2)];
    
    self.checkLine.path = path.CGPath;
    self.checkLine.lineWidth = kLineWidth;
    UIColor *color = SNUICOLOR(kThemeCheckLineColor);
    self.checkLine.strokeColor = color.CGColor;
    self.checkLine.fillColor = nil;
    
    //SS(strokeStart)
    CGFloat SSFrom = 0;
    CGFloat SSTo = 1.0;
    // animation
    CABasicAnimation *startAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    startAnimation.fromValue = @(SSFrom);
    startAnimation.toValue = @(SSTo);
    
    CABasicAnimation *endAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    endAnimation.fromValue = @(SSFrom);
    endAnimation.toValue = @(SSTo);
    
    
    CAAnimationGroup *step2 = [CAAnimationGroup animation];
    step2.animations = @[endAnimation];
    step2.duration = kStep2Duration;
    step2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.checkLine addAnimation:step2 forKey:nil];
}


@end
