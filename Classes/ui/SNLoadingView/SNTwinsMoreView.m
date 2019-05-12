//
//  SNTwinsMoreView.m
//  SNLoading
//
//  Created by WongHandy on 10/21/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import "SNTwinsMoreView.h"

static NSString *kTopCircleRepeatedScaleAnimationKey = @"top_circle_repeated_scale_animation_key";
static NSString *kBottomCircleRepeatedScaleAnimationKey = @"bottom_circle_repeated_scale_animation_key";

static NSString *kTopCircleEndingScaleAnimationKey = @"top_circle_ending_scale_animation_key";
static NSString *kBottomCircleEndingScaleAnimationKey = @"bottom_circle_ending_scale_animation_key";

static NSString *kSelfRotationAnimationKey = @"self_rotation_animation_key";

@interface SNTwinsMoreView() <CAAnimationDelegate> {
    NSLock *_statusLock;
    UIView *_topCircle;
    UIView *_bottomCircle;
}
@end

@implementation SNTwinsMoreView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //初始化状态的同步锁
        _statusLock = [[NSLock alloc] init];
        
        //Status label
        NSString *statusLabelGrayColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
        UIColor *statusLabelGrayColor = [UIColor colorFromString:statusLabelGrayColorString];
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, self.width, kStatusLabelHeight)];
        _statusLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.text = @"";
        _statusLabel.height = [_statusLabel.text sizeWithFont:_statusLabel.font].height;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textColor = statusLabelGrayColor;
        [self addSubview:_statusLabel];
        
        //初始化动画容器
        _animationView = [[UIView alloc] initWithFrame:CGRectMake(0, _statusLabel.bottom + 3, self.frame.size.width, kAnimationViewHeight)];
        [self addSubview:_animationView];
        
        //初始化两小圆圈
        NSString *circleRedColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color];
        UIColor *circleRedColor = [UIColor colorFromString:circleRedColorString];
        _topCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCircleDiameter, kCircleDiameter)];
        _topCircle.backgroundColor = circleRedColor;
        _topCircle.layer.cornerRadius = kCircleRadius;
        _topCircle.center = CGPointMake(_animationView.frame.size.width / 2.0f, kTopCircleMarginTopToAnimationView+kCircleRadius);
        _topCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);
        [_animationView addSubview:_topCircle];
        
        _bottomCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCircleDiameter, kCircleDiameter)];
        _bottomCircle.backgroundColor = circleRedColor;
        _bottomCircle.layer.cornerRadius = kCircleRadius;
        _bottomCircle.center = CGPointMake(_animationView.frame.size.width / 2.0f, _topCircle.center.y + kCircleDiameter+kCircleVPadding);
        _bottomCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);
        [_animationView addSubview:_bottomCircle];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:)
                                                     name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - Public
- (void)setStatus:(SNTwinsMoreStatus)status {
    [_statusLock lock];
    _status = status;
    switch (_status) {
        case SNTwinsMoreStatusLoading://0
            [self startAnimations];
            break;
        case SNTwinsMoreStatusStop://1
            [self stopAnimations];
            _statusLabel.text = @"";
            break;
    }
    [_statusLock unlock];
}

- (void)updateTheme:(NSNotification *)notification {
    NSString *circleRedColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color];
    UIColor *circleRedColor = [UIColor colorFromString:circleRedColorString];
    NSString *statusLabelGrayColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
    UIColor *statusLabelGrayColor = [UIColor colorFromString:statusLabelGrayColorString];
    _topCircle.backgroundColor = circleRedColor;
    _bottomCircle.backgroundColor = circleRedColor;
    _statusLabel.textColor = statusLabelGrayColor;
}

- (void)dealloc {
    if (self.status != SNTwinsMoreStatusStop) {
        self.status = SNTwinsMoreStatusStop;
    }
    [SNNotificationManager removeObserver:self];
}

#pragma mark - Private - 一系列动画处理
- (void)startAnimations {
    _statusLabel.text = @"正在加载";
    _topCircle.layer.transform = CATransform3DIdentity;
    _bottomCircle.layer.transform = CATransform3DIdentity;
    [self beginRepeatedScaleAnimation];
}

- (void)stopAnimations {
    _statusLabel.text = @"";
    CFTimeInterval currentMediaTime = CACurrentMediaTime();
    CFTimeInterval duration = 0.2f;
    [_bottomCircle.layer addAnimation:[self createEndingScaleAnimation:currentMediaTime duration:duration] forKey:kBottomCircleEndingScaleAnimationKey];
    [_topCircle.layer addAnimation:[self createEndingScaleAnimation:(currentMediaTime + duration) duration:duration] forKey:kTopCircleEndingScaleAnimationKey];
}

- (void)beginRepeatedScaleAnimation {
    CFTimeInterval currentMediaTime = CACurrentMediaTime();
    CFTimeInterval duration = 0.2f;
    [_topCircle.layer addAnimation:[self createRepeatedScaleAnimation:(currentMediaTime + duration) duration:duration] forKey:kTopCircleRepeatedScaleAnimationKey];
    [_bottomCircle.layer addAnimation:[self createRepeatedScaleAnimation:currentMediaTime duration:duration] forKey:kBottomCircleRepeatedScaleAnimationKey];
}

- (CAAnimation *)createRepeatedScaleAnimation:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.delegate = self;
    animation.duration = duration;
    animation.repeatCount = 1;
    animation.autoreverses = YES;
    animation.beginTime = beginTime;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (CAAnimation *)createRotationAnimation:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.delegate = self;
    animation.beginTime = beginTime;
    animation.additive = YES; // Make the values relative to the current value
    animation.values = @[@(0), @(M_PI/2.0f), @(M_PI)];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (CAAnimation *)createEndingScaleAnimation:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.delegate = self;
    animation.duration = duration;
    animation.repeatCount = 1;
    animation.beginTime = beginTime;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    SNDebugLog(@"上拉加载更多");
    //两个小圆圈缩放动画都结束，开始旋转动画
    CAAnimation *topCircleScaleAnimation = [_topCircle.layer animationForKey:kTopCircleRepeatedScaleAnimationKey];
    if (topCircleScaleAnimation == animation) {//至此，两个小圆的缩放动画已结束
        [_topCircle.layer removeAnimationForKey:kTopCircleRepeatedScaleAnimationKey];
        [_bottomCircle.layer removeAnimationForKey:kBottomCircleRepeatedScaleAnimationKey];
        
        //就地开始一次把两个小圆上下颠倒的旋转动画
        CFTimeInterval currentMediaTime = CACurrentMediaTime()+0.1;//缩放完成后延迟0.2秒再进行旋转动画以让缩放完后的画面停留0.2秒
        CFTimeInterval duration = 0.3f;
        [_animationView.layer addAnimation:[self createRotationAnimation:currentMediaTime duration:duration] forKey:kSelfRotationAnimationKey];
    }
    
    //旋转动画结束
    CAAnimation *selfRotationAnimation = [_animationView.layer animationForKey:kSelfRotationAnimationKey];
    if (selfRotationAnimation == animation) {//至此，两个小圆上下颠倒的旋转动画已结束
        [_animationView.layer removeAnimationForKey:kSelfRotationAnimationKey];
        if (CATransform3DEqualToTransform(_animationView.layer.transform, CATransform3DIdentity)) {
            _animationView.layer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI, 0, 0, 1);
        } else {
            _animationView.layer.transform = CATransform3DIdentity;
        }
        
        if (_status == SNTwinsMoreStatusStop && CATransform3DEqualToTransform(_animationView.layer.transform, CATransform3DIdentity)) {
            [self stopAnimations];
        } else {
            [self beginRepeatedScaleAnimation];
        }
    }
    
    //收尾缩放动画结束
    CAAnimation *endingScaleAnimation = [_topCircle.layer animationForKey:kTopCircleEndingScaleAnimationKey];
    if (endingScaleAnimation == animation) {
        _bottomCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);
        _topCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);
        _animationView.layer.transform = CATransform3DIdentity;
        [_topCircle.layer removeAllAnimations];
        [_bottomCircle.layer removeAllAnimations];
        [_animationView.layer removeAllAnimations];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        [UIView commitAnimations];
    }
}

@end
