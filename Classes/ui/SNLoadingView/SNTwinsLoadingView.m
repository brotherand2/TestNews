//
//  SNTwinsLoadingView.m
//  SNLoading
//
//  Created by WongHandy on 9/30/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import "SNTwinsLoadingView.h"
#import "SNRollingNewsPublicManager.h"
#import "SNRedPacketManager.h"

#define kCircleRadius                               (3.0f)
#define kCircleDiameter                             (2 * kCircleRadius)
#define kCircleVPadding                             (2.0f)
#define kTopCircleMarginTopToAnimationView          (5.0f)
#define kBottomCircleMarginBottomToAnimationView  kTopCircleMarginTopToAnimationView
#define kAnimationViewHeight  (kTopCircleMarginTopToAnimationView + kBottomCircleMarginBottomToAnimationView + 2 * kCircleDiameter+kCircleVPadding)
#define kBottomCircleBottomMarginToSelf (self.frame.size.height - kAnimationViewHeight)

#define kStatusLabelFonSize                         (12.0f)
#define kStatusLabelHeight                          (14.0f)

static NSString *kTopCircleRepeatedScaleAnimationKey = @"top_circle_repeated_scale_animation_key";
static NSString *kBottomCircleRepeatedScaleAnimationKey = @"bottom_circle_repeated_scale_animation_key";

static NSString *kTopCircleEndingScaleAnimationKey = @"top_circle_ending_scale_animation_key";
static NSString *kBottomCircleEndingScaleAnimationKey = @"bottom_circle_ending_scale_animation_key";

static NSString *kSelfRotationAnimationKey = @"self_rotation_animation_key";

@interface SNTwinsLoadingView() <CAAnimationDelegate> {
    NSLock *_statusLock;
    UIView *_animationView;
    UIView *_topCircle;
    UIView *_bottomCircle;
    __weak UIScrollView *_observedScrollView;
    CGFloat _observedScrollViewOriginalContentInsetTop;
    UILabel *_statusLabel;
    NSDate *_lasteLoadDate;
    BOOL _finishedToLoad;
}
@end

@implementation SNTwinsLoadingView

//此loading的最低高度为kAnimationViewHeight+kStatusLabelHeight = 38
- (id)initWithFrame:(CGRect)frame andObservedScrollView:(UIScrollView *)scrollView {
    self = [super initWithFrame:frame];
    if (self) {
        //初始化状态的同步锁
        _statusLock = [[NSLock alloc] init];
        
        //初始化动画容器
        _animationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kAnimationViewHeight)];
        [self addSubview:_animationView];
        
        //初始化两小圆圈
        NSString *circleRedColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color];
        UIColor *circleRedColor = [UIColor colorFromString:circleRedColorString];
        _topCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCircleDiameter, kCircleDiameter)];
        _topCircle.backgroundColor = circleRedColor;
        _topCircle.layer.cornerRadius = kCircleRadius;
        _topCircle.center = CGPointMake(_animationView.frame.size.width / 2.0f, kTopCircleMarginTopToAnimationView + kCircleRadius);
        _topCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        [_animationView addSubview:_topCircle];
        
        _bottomCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCircleDiameter, kCircleDiameter)];
        _bottomCircle.backgroundColor = circleRedColor;
        _bottomCircle.layer.cornerRadius = kCircleRadius;
        _bottomCircle.center = CGPointMake(_animationView.frame.size.width / 2.0f, _topCircle.center.y + kCircleDiameter + kCircleVPadding);
        _bottomCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);//缩放为不可见
        [_animationView addSubview:_bottomCircle];
        
        //初始化文案Label
        NSString *statusLabelGrayColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
        UIColor *statusLabelGrayColor = [UIColor colorFromString:statusLabelGrayColorString];
        
        //为了躲开订阅页的添加订阅，下移5
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _animationView.frame.origin.y + _animationView.frame.size.height + 5, self.frame.size.width, kStatusLabelHeight)];
        _statusLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.text = [SNTwinsLoadingView dragRefreshRelativelyDate:_lasteLoadDate];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textColor = statusLabelGrayColor;
        [self addSubview:_statusLabel];
        
        //监听scrollView的滚动
        _observedScrollViewOriginalContentInsetTop = scrollView.contentInset.top;
        _observedScrollView = scrollView;
        [_observedScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)removeObserver {
    [_observedScrollView removeObserver:self forKeyPath:@"contentOffset"];
    _observedScrollView = nil;
}

- (void)dealloc {
    if (_observedScrollView) {
        [_observedScrollView removeObserver:self forKeyPath:@"contentOffset"];
        _observedScrollView = nil;
    }
    [SNNotificationManager removeObserver:self];
}

#pragma mark - Public
- (void)resetObservedScrollViewOriginalContentInsetTop:(CGFloat)insetTop {
    _observedScrollViewOriginalContentInsetTop = insetTop;
}

- (void)setStatus:(SNTwinsLoadingStatus)status {
    [_statusLock lock];
    //以下这种情况表示加载完成并记下，然后在收尾动画中根据_finishedToLoad显示相应的文案
    if (!_finishedToLoad) {
        _finishedToLoad = _status == SNTwinsLoadingStatusLoading && status == SNTwinsLoadingStatusPullToReload;
    }

    _status = status;
    switch (_status) {
        case SNTwinsLoadingStatusLoading: {
            [self setStatusLabel:@"正在更新"];
            [self startAnimations];
            _lasteLoadDate = [NSDate date];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            CGFloat offsetTop = _observedScrollView.contentOffset.y;
            _observedScrollView.contentInset = UIEdgeInsetsMake(_observedScrollViewOriginalContentInsetTop + self.frame.size.height + 10, 0, _observedScrollView.contentInset.bottom, 0);
            [_observedScrollView setContentOffset:CGPointMake(0, offsetTop)
                                         animated:NO];
            [UIView commitAnimations];
        }
            break;
        case SNTwinsLoadingStatusPullToReload: {
            [self stopCurrentAnimations];
            [self updateTableViewAndStatusLabel];
        }
            break;
        case SNTwinsLoadingStatusReleaseToReload: {
        }
            break;
        case SNTwinsLoadingStatusNil: {
            [self stopCurrentAnimations];
            [self updateTableViewAndStatusLabel];
        }
            break;
        case SNTwinsLoadingStatusUpdateTableView: {
            [self updateTableViewAndStatusLabel];
        }
            break;
        case SNTwinsLoadingStatuStopAniamtion: {
            [self stopCurrentAnimations];
        }
            break;
    }
    [_statusLock unlock];
}

- (CGFloat)minDistanceCanReleaseToReload {
    return _animationView.frame.origin.y + _animationView.frame.size.height-kBottomCircleMarginBottomToAnimationView;
}

- (void)updateTheme:(NSNotification *)notification {
    NSString *circleRedColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color];
    UIColor *circleRedColor = [UIColor colorFromString:circleRedColorString];
    _topCircle.backgroundColor = circleRedColor;
    _bottomCircle.backgroundColor = circleRedColor;
    
    NSString *statusLabelGrayColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
    UIColor *statusLabelGrayColor = [UIColor colorFromString:statusLabelGrayColorString];
    _statusLabel.textColor = statusLabelGrayColor;
}

#pragma mark - Private - ScrollView的滚动处理
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == _observedScrollView &&
        [keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:_observedScrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_status != SNTwinsLoadingStatusLoading && scrollView.contentOffset.y <= 0) {
        CGFloat bottomEdgeTopMarginToSelfOfBottomCircle = [self minDistanceCanReleaseToReload];
        CGFloat overDistance = fabsf(scrollView.contentOffset.y) - _observedScrollViewOriginalContentInsetTop - bottomEdgeTopMarginToSelfOfBottomCircle;
        CGFloat rate = overDistance / kBottomCircleBottomMarginToSelf;
        CGFloat bottomCircleDistanceRate = rate > 1.0f ? 1 : rate;
        bottomCircleDistanceRate = bottomCircleDistanceRate < 0 ? 0 : bottomCircleDistanceRate;
        
        //bottomCicle跟手变大到什么程度时topCircle才开始跟手慢慢变大
        //即distance至少偏移到keyPoint这个百分比后，topCircle才开始跟手慢慢变大
        CGFloat keyPoint = 1 / 3.0f;
        overDistance = overDistance - (kBottomCircleBottomMarginToSelf) * keyPoint;
        CGFloat topCircleDistanceRate = overDistance / (kBottomCircleBottomMarginToSelf * (1 - keyPoint));
        topCircleDistanceRate = topCircleDistanceRate < 0 ? 0 : topCircleDistanceRate;
        topCircleDistanceRate = topCircleDistanceRate > 1.0f ? 1 : topCircleDistanceRate;
        
        //不加动画时长会显得下拉回弹时两个小圆圈变小动画更均匀
        [UIView beginAnimations:nil context:NULL];
        _bottomCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, bottomCircleDistanceRate, bottomCircleDistanceRate, 1);
        _topCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, topCircleDistanceRate, topCircleDistanceRate, 1);
        [UIView commitAnimations];
    }
}

#pragma mark - Private - 一系列动画处理
- (void)startAnimations {
    [SNRollingNewsPublicManager sharedInstance].isRequestChannelData = YES;
    [self beginRepeatedScaleAnimation];
}

- (void)updateTableViewAndStatusLabel {
    //非流式频道完成请求
    [SNRollingNewsPublicManager sharedInstance].isRequestChannelData = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _observedScrollView.contentInset = UIEdgeInsetsMake(_observedScrollViewOriginalContentInsetTop, 0, _observedScrollView.contentInset.bottom, 0);
    [UIView commitAnimations];
    
    if (_finishedToLoad) {
        if (_status == SNTwinsLoadingStatusNil) {
            [self setStatusLabel:@""];
        } else {
            [self setStatusLabel:[SNTwinsLoadingView dragRefreshRelativelyDate:_lasteLoadDate]];
        }
        _finishedToLoad = YES;
    } else {
        if (_status == SNTwinsLoadingStatusNil) {
            [self setStatusLabel:@""];
        } else {
            [self setStatusLabel:[SNTwinsLoadingView dragRefreshRelativelyDate:_lasteLoadDate]];
        }
    }
}

- (void)stopCurrentAnimations {
    _bottomCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);
    _topCircle.layer.transform = CATransform3DScale(CATransform3DIdentity, 0, 0, 1);
    _animationView.layer.transform = CATransform3DIdentity;
    [_topCircle.layer removeAllAnimations];
    [_bottomCircle.layer removeAllAnimations];
    [_animationView.layer removeAllAnimations];
}

- (void)stopAnimations {
    CFTimeInterval currentMediaTime = CACurrentMediaTime();
    CFTimeInterval duration = 0.0f;
    [_bottomCircle.layer addAnimation:[self createEndingScaleAnimation:currentMediaTime duration:duration] forKey:kBottomCircleEndingScaleAnimationKey];
    [_topCircle.layer addAnimation:[self createEndingScaleAnimation:(currentMediaTime + duration) duration:duration] forKey:kTopCircleEndingScaleAnimationKey];
}

- (void)beginRepeatedScaleAnimation {
    CFTimeInterval currentMediaTime = CACurrentMediaTime();
    CFTimeInterval duration = 0.2f;
    [_topCircle.layer addAnimation:[self createRepeatedScaleAnimation:(currentMediaTime + duration) duration:duration] forKey:kTopCircleRepeatedScaleAnimationKey];
    [_bottomCircle.layer addAnimation:[self createRepeatedScaleAnimation:currentMediaTime duration:duration] forKey:kBottomCircleRepeatedScaleAnimationKey];
}

- (CAAnimation *)createRepeatedScaleAnimation:(CFTimeInterval)beginTime
                                     duration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.delegate = self;
    animation.duration = duration;
    animation.repeatCount = 1;
    animation.autoreverses = NO;
    animation.beginTime = beginTime;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (CAAnimation *)createRotationAnimation:(CFTimeInterval)beginTime
                                duration:(CFTimeInterval)duration {
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

- (CAAnimation *)createEndingScaleAnimation:(CFTimeInterval)beginTime
                                   duration:(CFTimeInterval)duration {
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
    SNDebugLog(@"animationDidStop: animation");
    //两个小圆圈缩放动画都结束，开始旋转动画
    CAAnimation *topCircleScaleAnimation = [_topCircle.layer animationForKey:kTopCircleRepeatedScaleAnimationKey];
    if (topCircleScaleAnimation == animation) {
        //至此，两个小圆的缩放动画已结束
        [_topCircle.layer removeAnimationForKey:kTopCircleRepeatedScaleAnimationKey];
        [_bottomCircle.layer removeAnimationForKey:kBottomCircleRepeatedScaleAnimationKey];
        
        //就地开始一次把两个小圆上下颠倒的旋转动画
        CFTimeInterval currentMediaTime = CACurrentMediaTime() + 0.1;//缩放完成后延迟0.2秒再进行旋转动画以让缩放完后的画面停留0.2秒
        CFTimeInterval duration = 0.3f;
        [_animationView.layer addAnimation:[self createRotationAnimation:currentMediaTime duration:duration] forKey:kSelfRotationAnimationKey];
    }
    
    //旋转动画结束
    CAAnimation *selfRotationAnimation = [_animationView.layer animationForKey:kSelfRotationAnimationKey];
    if (selfRotationAnimation == animation) {
        //至此，两个小圆上下颠倒的旋转动画已结束
        [_animationView.layer removeAnimationForKey:kSelfRotationAnimationKey];
        if (CATransform3DEqualToTransform(_animationView.layer.transform, CATransform3DIdentity)) {
            _animationView.layer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI, 0, 0, 1);
        } else {
            _animationView.layer.transform = CATransform3DIdentity;
        }
        
        if (_status == SNTwinsLoadingStatusPullToReload &&
            CATransform3DEqualToTransform(_animationView.layer.transform, CATransform3DIdentity)) {
            [self stopAnimations];
        } else {
            [self beginRepeatedScaleAnimation];
        }
    }
    
    //收尾缩放动画结束
    CAAnimation *endingScaleAnimation = [_topCircle.layer animationForKey:kTopCircleEndingScaleAnimationKey];
    if (endingScaleAnimation == animation) {
        [self stopCurrentAnimations];
        [self updateTableViewAndStatusLabel];
    }
}

#pragma mark - 时间格式化
+ (NSString *)dragRefreshRelativelyDate:(NSDate *)dateParam {
	if (!!dateParam) {
		double interval = [dateParam timeIntervalSinceNow] * -1;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *compsToday = [gregorian components:
                                        (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                    fromDate:[NSDate date]];
        NSDateComponents *compsDate = [gregorian components:
                                       (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                   fromDate:dateParam];
		if (interval > 0) {
            if (interval < 60) {
                return @"刚刚更新";
            } else if (interval < 3600) {
                return [NSString stringWithFormat:@"%d分钟前更新", (int)round(interval / 60)];
            } else if (interval < 24 * 3600) {
                return [NSString stringWithFormat:@"%d小时前更新",(int)round(interval / 60 / 60)];
            } else if (compsToday.year == compsDate.year) {
                return [SNTwinsLoadingView stringFromDate:dateParam
                                               withFormat:@"MM-dd更新"];
            } else {
                return [SNTwinsLoadingView stringFromDate:dateParam withFormat:@"yyyy-MM-dd更新"];
            }
		} else {
			return @"尚未更新过";
		}
	} else {
		return @"尚未更新过";
	}
}

+ (NSString *)stringFromDate:(NSDate *)date
                  withFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
	NSString *timestamp_str = [formatter stringFromDate:date];
	return timestamp_str;
}

- (void)setUpdateDate:(NSDate *)newDate {
    _lasteLoadDate = newDate;
    if ([SNRollingNewsPublicManager sharedInstance].isHomePage &&
        ![SNNewsFullscreenManager newsChannelChanged]) {
        if ([[SNRedPacketManager sharedInstance] showRedPacketActivityTheme]) {
            _statusLabel.text = [SNRedPacketManager getRedPacketTips];
        } else if (_status != SNTwinsLoadingStatusLoading) {
            _statusLabel.text = kPullMyConcernContent;
        }
    } else {
        _statusLabel.text = [SNTwinsLoadingView dragRefreshRelativelyDate:newDate];
    }
}

- (void)setStatusLabel:(NSString *)tip {
    if ([SNRollingNewsPublicManager sharedInstance].isHomePage &&
        ![SNNewsFullscreenManager newsChannelChanged]) {
        if ([[SNRedPacketManager sharedInstance] showRedPacketActivityTheme]) {
            _statusLabel.text = [SNRedPacketManager getRedPacketTips];
        } else if(_status != SNTwinsLoadingStatusLoading){
            _statusLabel.text = kPullMyConcernContent;
        }
    } else {
        _statusLabel.text = tip;
    }
}

@end
