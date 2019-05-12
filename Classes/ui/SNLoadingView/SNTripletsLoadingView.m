//
//  SNTripletsLoadingView.m
//  SNLoading
//
//  Created by WongHandy on 10/11/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import "SNTripletsLoadingView.h"
#import "CAKeyframeAnimation+AHEasing.h"

static NSString *kCircle1RepeatedScaleAnimationKey = @"circle1_repeated_scale_animation_key";
static NSString *kCircle2RepeatedScaleAnimationKey = @"circle2_repeated_scale_animation_key";
static NSString *kCircle3RepeatedScaleAnimationKey = @"circle3_repeated_scale_animation_key";

static NSString *kCircle1ShrinkMoveAnimationKey = @"circle1_shrink_move_animation_key";
static NSString *kCircle3ShrinkMoveAnimationKey = @"circle3_shrink_move_animation_key";

static NSString *kCircle1ShrinkScaleAnimationKey = @"circle1_shrink_scale_animation_key";
static NSString *kCircle2ShrinkScaleAnimationKey = @"circle2_shrink_scale_animation_key";
static NSString *kCircle3ShrinkScaleAnimationKey = @"circle3_shrink_scale_animation_key";

static NSString *kCircle2BounceAnimationKey = @"circle2_bounce_animation_key";


#define kGoldenSectionRatio         (0.4)//(0.5)//0.618
#define kCircleRadius               (3.0f)
#define kCircleDiameter             (2*kCircleRadius)
#define kCirclesHPadding            (4.0f)

@interface SNTripletsLoadingView() <CAAnimationDelegate> {
    UIView *_circle1;
    UIView *_circle2;
    UIView *_circle3;
    
    UIButton *_notReachableIndicator;
    UIButton *_emptyButton;
    
    UIColor *circleRedColor;
    UIColor *backColor;
    
    BOOL isVideoMode;
}
@end

@implementation SNTripletsLoadingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSString *bgColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg3Color];
        backColor = [UIColor colorFromString:bgColorString];
        self.backgroundColor = backColor;
        self.hidden = YES;
        
        //---初始化三个小圆
        CGFloat left = (self.frame.size.width-3*kCircleDiameter-2*kCirclesHPadding)/2.0f;
        CGFloat centerTop = (self.frame.size.height - kCircleDiameter) / 2;
        NSString *circleRedColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color];
        circleRedColor = [UIColor colorFromString:circleRedColorString];
        
        //Circle1
        CGRect _circle1Frame = CGRectMake(left, 0, kCircleDiameter, kCircleDiameter);
        _circle1 = [[UIView alloc] initWithFrame:_circle1Frame];
        _circle1.backgroundColor = circleRedColor;
        _circle1.layer.cornerRadius = kCircleRadius;
        _circle1.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        _circle1.center = CGPointMake(_circle1.center.x, centerTop);
        [self addSubview:_circle1];
        
        //Circle2
        left += (kCircleDiameter+kCirclesHPadding);
        CGRect _circle2Frame = CGRectMake(left, 0, kCircleDiameter, kCircleDiameter);
        _circle2 = [[UIView alloc] initWithFrame:_circle2Frame];
        _circle2.backgroundColor = circleRedColor;
        _circle2.layer.cornerRadius = kCircleRadius;
        _circle2.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        _circle2.center = CGPointMake(_circle2.center.x, centerTop);
        [self addSubview:_circle2];
        
        //Circle3
        left += (kCircleDiameter+kCirclesHPadding);
        CGRect _circle3Frame = CGRectMake(left, 0, kCircleDiameter, kCircleDiameter);
        _circle3 = [[UIView alloc] initWithFrame:_circle3Frame];
        _circle3.backgroundColor = circleRedColor;
        _circle3.layer.cornerRadius = kCircleRadius;
        _circle3.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        _circle3.center = CGPointMake(_circle3.center.x, centerTop);
        [self addSubview:_circle3];
        //---
        
        //---无网UI
        UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeC];
        NSString *labelColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
        UIColor *fontColor = [UIColor colorFromString:labelColorString];
        CGFloat indicatorWidth = floorf(415/2.0f);
        CGFloat indicatorHeight = floorf(150/2.0f);
        CGFloat indicatorLeft = (self.frame.size.width-indicatorWidth)/2.0f;
        CGFloat indicatorTop = (self.frame.size.height-indicatorHeight)/2.0f;
        UIImage *image = [UIImage imageNamed:@"sohu_loading_1.png"];
        _notReachableIndicator = [UIButton buttonWithType:UIButtonTypeCustom];
        _notReachableIndicator.userInteractionEnabled = NO;
        _notReachableIndicator.frame = CGRectMake(indicatorLeft, indicatorTop, indicatorWidth, indicatorHeight);
        [_notReachableIndicator setImage:image forState:UIControlStateNormal];
        [_notReachableIndicator setTitle:@"点击屏幕 重新加载" forState:UIControlStateNormal];
        [_notReachableIndicator.titleLabel setFont:font];
        [_notReachableIndicator setTitleColor:fontColor forState:UIControlStateNormal];
        [_notReachableIndicator addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
        _notReachableIndicator.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _notReachableIndicator.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        CGSize size = _notReachableIndicator.frame.size;
        CGFloat imgViewEdgeInsetLeft = (size.width - image.size.width)/2;
        CGFloat imgViewEdgeInsetTop = _notReachableIndicator.imageView.top;
        CGFloat titleLabelEdgeInsetLeft = (size.width - _notReachableIndicator.titleLabel.size.width)/2 - image.size.width - 50;
        CGFloat titleLabelEdgeInsetTop  = imgViewEdgeInsetTop + image.size.height + 12;
        UIEdgeInsets imgViewEdgeInsets = UIEdgeInsetsMake(0, imgViewEdgeInsetLeft, 0, 0);
        UIEdgeInsets titleLabelEdgeInsets = UIEdgeInsetsMake(titleLabelEdgeInsetTop, titleLabelEdgeInsetLeft, 0, 0);
        [_notReachableIndicator setImageEdgeInsets:imgViewEdgeInsets];
        [_notReachableIndicator setTitleEdgeInsets:titleLabelEdgeInsets];
        
        _notReachableIndicator.hidden = YES;
        [self addSubview:_notReachableIndicator];
        //---
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retry)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        self.status = SNTripletsLoadingStatusStopped;
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:)
                                                     name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - Public
- (void)setColorBackgroundClear
{
    backColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
}
- (void)setColorVideoMode:(BOOL)isVideo
{
    if(NO == isVideo)
        return;
    
    NSString *circleWhiteColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg4Color];
    UIColor *circleWhiteColor = [UIColor colorFromString:circleWhiteColorString];
    
    circleRedColor = circleWhiteColor;
    backColor = [UIColor clearColor];
    
    _circle1.backgroundColor = circleRedColor;
    _circle2.backgroundColor = circleRedColor;
    _circle3.backgroundColor = circleRedColor;
    
    self.backgroundColor = backColor;
    
    isVideoMode = YES;
}
- (void)setStatus:(SNTripletsLoadingStatus)status {
    _status = status;
    switch (_status) {
        case SNTripletsLoadingStatusStopped:
            _notReachableIndicator.hidden = YES;
            _emptyButton.hidden = YES;
            [self stopAnimations];
            break;
        case SNTripletsLoadingStatusLoading:
            self.hidden = NO;
            _notReachableIndicator.hidden = YES;
            _emptyButton.hidden = YES;
            [self startAnimations];
            break;
        case SNTripletsLoadingStatusNetworkNotReachable:
            _emptyButton.hidden = YES;
            [self stopAnimations];
            break;
        case SNTripletsLoadingStatusEmpty:{
            _notReachableIndicator.hidden = YES;
            [self stopAnimations];
        }
            break;
    }
    
    if(self.backgroundColor != [UIColor clearColor]){
        NSString *bgColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg3Color];
        self.backgroundColor = [UIColor colorFromString:bgColorString];
    }
    
}

- (void)updateTheme:(NSNotification *)notification {
    NSString *bgColorString = nil;
    
    //lijian 2015.01.13 如果是设置了空背景则不改背景颜色了
    if(self.backgroundColor != [UIColor clearColor]){
        bgColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg3Color];
        self.backgroundColor = [UIColor colorFromString:bgColorString];
    }
    
    if(NO == isVideoMode){
        NSString *circleRedColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color];
        circleRedColor = [UIColor colorFromString:circleRedColorString];
        _circle1.backgroundColor = circleRedColor;
        _circle2.backgroundColor = circleRedColor;
        _circle3.backgroundColor = circleRedColor;
    }else{
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
             circleRedColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
        }else{
             circleRedColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        }
        _circle1.backgroundColor = circleRedColor;
        _circle2.backgroundColor = circleRedColor;
        _circle3.backgroundColor = circleRedColor;
    }
    
    NSString *labelColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
    UIColor *fontColor = [UIColor colorFromString:labelColorString];
    [_notReachableIndicator setTitleColor:fontColor forState:UIControlStateNormal];
    [_notReachableIndicator setImage:[UIImage imageNamed:@"sohu_loading_1.png"] forState:UIControlStateNormal];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

#pragma mark - Private
- (void)startAnimations {
    self.backgroundColor = backColor;
    if(YES == isVideoMode){
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            circleRedColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
        }else{
            circleRedColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        }
    }
    _circle1.backgroundColor = circleRedColor;
    _circle2.backgroundColor = circleRedColor;
    _circle3.backgroundColor = circleRedColor;
    _circle1.backgroundColor = circleRedColor;
    _circle2.backgroundColor = circleRedColor;
    _circle3.backgroundColor = circleRedColor;
    if (![_circle1.layer animationForKey:kCircle1RepeatedScaleAnimationKey] &&
        ![_circle2.layer animationForKey:kCircle2RepeatedScaleAnimationKey] &&
        ![_circle3.layer animationForKey:kCircle3RepeatedScaleAnimationKey]) {
        //---开始三个小圆重复的大小变化动画
        CFTimeInterval beginTime = CACurrentMediaTime();
        CFTimeInterval duration = 0.4f;
        [_circle1.layer addAnimation:[self createRepeatedScaleAnimation:beginTime duration:duration] forKey:kCircle1RepeatedScaleAnimationKey];
        
        beginTime += (duration/3);
        [_circle2.layer addAnimation:[self createRepeatedScaleAnimation:beginTime duration:duration] forKey:kCircle2RepeatedScaleAnimationKey];
        
        beginTime += (duration/3);
        [_circle3.layer addAnimation:[self createRepeatedScaleAnimation:beginTime duration:duration] forKey:kCircle3RepeatedScaleAnimationKey];
    }
}

- (void)stopAnimations {
    if ([_circle1.layer animationForKey:kCircle1RepeatedScaleAnimationKey] &&
        [_circle2.layer animationForKey:kCircle2RepeatedScaleAnimationKey] &&
        [_circle3.layer animationForKey:kCircle3RepeatedScaleAnimationKey]) {
        //---终止三个小圆重复的大小变化动画
        [_circle1.layer removeAnimationForKey:kCircle1RepeatedScaleAnimationKey];
        [_circle2.layer removeAnimationForKey:kCircle2RepeatedScaleAnimationKey];
        [_circle3.layer removeAnimationForKey:kCircle3RepeatedScaleAnimationKey];
        _circle1.layer.transform = CATransform3DIdentity;
        _circle2.layer.transform = CATransform3DIdentity;
        _circle3.layer.transform = CATransform3DIdentity;
        //---
        
        //---三个小圆合成一个并bounce一下
        CFTimeInterval beginTime = CACurrentMediaTime()+0.05;
        CFTimeInterval duration = 0.4f;
        
        NSValue *circle1FromPosition = [NSValue valueWithCGPoint:_circle1.layer.position];
        NSValue *circle1ToPosition = [NSValue valueWithCGPoint:_circle2.layer.position];
        CAAnimation *circle1ShrinkMoveAnimation = [self createShrinkMoveAnimation:beginTime duration:duration
                                                                     fromPosition:circle1FromPosition toPosition:circle1ToPosition];
        [_circle1.layer addAnimation:circle1ShrinkMoveAnimation forKey:kCircle1ShrinkMoveAnimationKey];
        [_circle1.layer addAnimation:[self createShrinkScaleAnimation:beginTime duration:duration] forKey:kCircle1ShrinkScaleAnimationKey];
        
        [_circle2.layer addAnimation:[self createShrinkScaleAnimation:beginTime duration:duration] forKey:kCircle2ShrinkScaleAnimationKey];
        
        NSValue *circle3FromPosition = [NSValue valueWithCGPoint:_circle3.layer.position];
        NSValue *circle3ToPosition = [NSValue valueWithCGPoint:_circle2.layer.position];
        CAAnimation *circle3ShrinkMoveAnimation = [self createShrinkMoveAnimation:beginTime duration:duration
                                                                     fromPosition:circle3FromPosition toPosition:circle3ToPosition];
        [_circle3.layer addAnimation:circle3ShrinkMoveAnimation forKey:kCircle3ShrinkMoveAnimationKey];
        [_circle3.layer addAnimation:[self createShrinkScaleAnimation:beginTime duration:duration] forKey:kCircle3ShrinkScaleAnimationKey];
        
        duration = 0.15;
        CAAnimation *circle3BounceAnimation = [self createBounceAnimation:(beginTime+duration) duration:duration];
        [_circle2.layer addAnimation:circle3BounceAnimation forKey:kCircle2BounceAnimationKey];
        //---
    } else {
        _circle1.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        _circle2.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        _circle3.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        
        //兼容：没有经过loading状态而直接设置notreachable状态，如：在init中初骀化时就设置为notreachable状态
        if (_status == SNTripletsLoadingStatusNetworkNotReachable) {
            [self renderNotReachableUI];
        }
        else if (_status == SNTripletsLoadingStatusEmpty){
        }
        //兼容：没有经过loading状态而直接设置stop状态，如：在init中初骀化时就设置为notreachable状态
        if (_status == SNTripletsLoadingStatusStopped) {
            self.hidden = YES;
        }
    }
}

- (void)renderNotReachableUI {
    self.hidden = NO;
    _notReachableIndicator.hidden = NO;
}

- (void)retry {
    if (_status == SNTripletsLoadingStatusNetworkNotReachable || _status == SNTripletsLoadingStatusEmpty) {
        if ([_delegate respondsToSelector:@selector(didRetry:)]) {
            [_delegate didRetry:self];
        }
    }
}

#pragma mark -
- (CAAnimation *)createRepeatedScaleAnimation:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration {
    return [self createScaleAnimation:beginTime duration:duration repeatCount:HUGE_VALL autoreverses:YES fromScale:0.0 toScale:1.0];
}

- (CAAnimation *)createShrinkScaleAnimation:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration {
    return [self createScaleAnimation:beginTime duration:duration repeatCount:0 autoreverses:NO fromScale:1.0 toScale:0.0];
}

- (CAAnimation *)createBounceAnimation:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration {
    return [self createScaleAnimation:beginTime duration:duration repeatCount:0 autoreverses:YES fromScale:0.0f toScale:1.0f];
}

- (CAAnimation *)createShrinkMoveAnimation:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
                              fromPosition:(NSValue *)fromValue toPosition:(NSValue *)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.delegate = self;
    animation.duration = duration;
    animation.beginTime = beginTime;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (CAAnimation *)createScaleAnimation:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
                          repeatCount:(CGFloat)repeatCount autoreverses:(BOOL)autoreverses
                            fromScale:(CGFloat)fromValue toScale:(CGFloat)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.delegate = self;
    animation.duration = duration;
    animation.repeatCount = repeatCount;
    animation.autoreverses = autoreverses;
    animation.beginTime = beginTime;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    CAAnimation *circle2BounceAnimation = [_circle2.layer animationForKey:kCircle2BounceAnimationKey];
    if (circle2BounceAnimation == animation) {
        [_circle1.layer removeAllAnimations];
        [_circle2.layer removeAllAnimations];
        [_circle3.layer removeAllAnimations];
        
        _circle1.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        _circle2.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        _circle3.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        
        if (_status == SNTripletsLoadingStatusNetworkNotReachable) {
            [self renderNotReachableUI];
        }
        else if (_status == SNTripletsLoadingStatusEmpty){
            self.hidden = NO;
            _emptyButton.hidden = NO;
        }
        
        if (_status == SNTripletsLoadingStatusStopped) {
            self.hidden = YES;
        }
    }
}

- (void)setNotReachableIndicatorOffsetY:(CGFloat)offsetY{
    CGFloat indicatorHeight = floorf(68/2.0f);
    CGFloat indicatorTop = (self.frame.size.height-indicatorHeight)/2.0f - offsetY;
    CGRect frame = _notReachableIndicator.frame;
    frame.origin.y = indicatorTop;
    _notReachableIndicator.frame = frame;
}

- (void)showEmptyViewWithImage:(UIImage *)image withTitle:(NSString *)title{
    CGFloat indicatorWidth = floorf(415/2.0f);
    CGFloat indicatorHeight = floorf(200/2.0f);
    CGFloat indicatorLeft = (self.frame.size.width-indicatorWidth)/2.0f;
    CGFloat indicatorTop = (self.frame.size.height-indicatorHeight)/2.0f;
    _emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _emptyButton.userInteractionEnabled = NO;
    _emptyButton.hidden = YES;
    _emptyButton.frame = CGRectMake(indicatorLeft, indicatorTop - 10, indicatorWidth, indicatorHeight);
    
    [_emptyButton setTitle:title forState:UIControlStateNormal];
    [_emptyButton setImage:image forState:UIControlStateNormal];
    
    [_emptyButton.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    [_emptyButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    
    _emptyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _emptyButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    CGSize size = _emptyButton.frame.size;
    CGFloat imgViewEdgeInsetLeft = (size.width - image.size.width)/2;
    CGFloat imgViewEdgeInsetTop = _emptyButton.imageView.top;
    CGFloat titleLabelEdgeInsetLeft = size.width/2.0f-_emptyButton.titleLabel.center.x - image.size.width / 2 + 16;
    CGFloat titleLabelEdgeInsetTop  = imgViewEdgeInsetTop + image.size.height + 12;
    UIEdgeInsets imgViewEdgeInsets = UIEdgeInsetsMake(0, imgViewEdgeInsetLeft, 0, 0);
    UIEdgeInsets titleLabelEdgeInsets = UIEdgeInsetsMake(titleLabelEdgeInsetTop, titleLabelEdgeInsetLeft, 0, 0);
    [_emptyButton setImageEdgeInsets:imgViewEdgeInsets];
    [_emptyButton setTitleEdgeInsets:titleLabelEdgeInsets];
    [self addSubview:_emptyButton];
}

- (void)clearSubViews{
    [_circle1 removeFromSuperview];
    [_circle2 removeFromSuperview];
    [_circle3 removeFromSuperview];
}

- (void)layoutTriplets {
    [self clearSubViews];
    
    CGFloat left = (self.frame.size.width-3*kCircleDiameter-2*kCirclesHPadding)/2.0f;
    CGFloat centerTop = (self.frame.size.height - kCircleDiameter) / 2;
    NSString *circleRedColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color];
    circleRedColor = [UIColor colorFromString:circleRedColorString];
    
    //Circle1
    CGRect _circle1Frame = CGRectMake(left, 0, kCircleDiameter, kCircleDiameter);
    _circle1 = [[UIView alloc] initWithFrame:_circle1Frame];
    _circle1.backgroundColor = circleRedColor;
    _circle1.layer.cornerRadius = kCircleRadius;
    _circle1.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
    _circle1.center = CGPointMake(_circle1.center.x, centerTop);
    [self addSubview:_circle1];
    
    //Circle2
    left += (kCircleDiameter+kCirclesHPadding);
    CGRect _circle2Frame = CGRectMake(left, 0, kCircleDiameter, kCircleDiameter);
    _circle2 = [[UIView alloc] initWithFrame:_circle2Frame];
    _circle2.backgroundColor = circleRedColor;
    _circle2.layer.cornerRadius = kCircleRadius;
    _circle2.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
    _circle2.center = CGPointMake(_circle2.center.x, centerTop);
    [self addSubview:_circle2];
    
    //Circle3
    left += (kCircleDiameter+kCirclesHPadding);
    CGRect _circle3Frame = CGRectMake(left, 0, kCircleDiameter, kCircleDiameter);
    _circle3 = [[UIView alloc] initWithFrame:_circle3Frame];
    _circle3.backgroundColor = circleRedColor;
    _circle3.layer.cornerRadius = kCircleRadius;
    _circle3.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
    _circle3.center = CGPointMake(_circle3.center.x, centerTop);
    [self addSubview:_circle3];
    //---

}

@end
