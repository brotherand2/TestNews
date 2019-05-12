//
//  SNTableHeaderDragRefreshView.m
//  sohunews
//
//  Created by Dan on 7/20/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNTableHeaderDragRefreshView.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "DACircularProgressView.h"
#import "CAKeyframeAnimation+AHEasing.h"

// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
const CGFloat kRefreshDeltaY = -64.0f;

// The height of the refresh header when it is in its "loading" state.
const CGFloat kHeaderVisibleHeight = 60.0f;


#define kDefaultCircleViewDiameter  (56 / 2)
#define kStatusLabelFont            (26 / 2)
#define kLastUpdateLabelFont        (18 / 2)
#define kLabelSpace                 (12 / 2)
#define kLabelLeftMargin            (16 / 2)
#define kLabelStartY                (88 / 2)
#define kLabelStartX                (90 / 2)
#define kCircleWidth                (3)

@implementation SNDragRefreshView

- (CGFloat)refreshStartPosY {
    return 65.0f;
}

- (void)setCurrentDate {
}

- (void)setUpdateDate:(NSDate *)date {
}

- (void)refreshUpdateDate {
}

- (void)setStatus:(TTTableHeaderDragRefreshStatus)status {
    self.state = status;
}

- (void)setStatusText:(NSString *)text {
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIImage *bgImage = [UIImage imageNamed:@"drag_refresh_bg.png"];
    [bgImage drawInRect:CGRectMake(0, self.height - bgImage.size.height, kAppScreenWidth, bgImage.size.height)];
}


- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    NSString *superViewClassStr = NSStringFromClass([self.superview class]);
    if (self.superview && ([self.superview isKindOfClass:[UIScrollView class]] || [superViewClassStr rangeOfString:@"ScrollView" options:NSCaseInsensitiveSearch].location != NSNotFound)) {
        self.scrollView = (UIScrollView *)self.superview;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    if (!self.superview && self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.scrollView = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.scrollView &&
        [keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:self.scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)removeObserver {
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.scrollView = nil;
    }
}

@end


#pragma mark -
@interface SNTableHeaderDragRefreshView () {
    DACircularProgressView *_circleView;
    DACircularProgressView *_rotateView;
    
    NSDate *_lastUpdatedDate;
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
    UIImageView *_logoImageView;
}

@property (nonatomic, assign) float currentScalePercent;

@end

@implementation SNTableHeaderDragRefreshView

- (id)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame needTipsView:NO];
}

- (id)initWithFrame:(CGRect)frame
       needTipsView:(BOOL)needTipsView {
    self = [super initWithFrame:frame];
    if (self) {
		[self initSubViewsWithFrame:frame needTipsView:needTipsView];
    }
    return self;
}

- (void)initSubViewsWithFrame:(CGRect)frame
                 needTipsView:(BOOL)needTipsView {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat labelStartX = kLabelStartX;
    CGFloat labelStartY = frame.size.height - kLabelStartY;
    
    _statusLabel = [[UILabel alloc]
                    initWithFrame:CGRectMake(labelStartX, labelStartY, frame.size.width, kStatusLabelFont + 1 )];
    _statusLabel.font = [UIFont systemFontOfSize:kStatusLabelFont];
    _statusLabel.backgroundColor  = [UIColor clearColor];
    
    //@Dan: 没必要被读屏
    _statusLabel.isAccessibilityElement = NO;
    
    [self setStatus:TTTableHeaderDragRefreshPullToReload];
    [self addSubview:_statusLabel];
    
    _lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelStartX, _statusLabel.bottom + kLabelSpace, frame.size.width, kLastUpdateLabelFont + 1)];
    _lastUpdatedLabel.font = [UIFont systemFontOfSize:kLastUpdateLabelFont];
    _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
    
    //@Dan: 没必要被读屏
    _lastUpdatedLabel.isAccessibilityElement = NO;
    
    [self addSubview:_lastUpdatedLabel];
    
    _circleView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, kDefaultCircleViewDiameter, kDefaultCircleViewDiameter)];
    _circleView.center = CGPointMake(25, frame.size.height - 28.0f);

    _circleView.innerRadius = _circleView.width / 2 - kCircleWidth;
    [self addSubview:_circleView];
    
    _rotateView = [[DACircularProgressView alloc] initWithFrame:_circleView.frame];
    _rotateView.innerRadius = _circleView.innerRadius;
    _rotateView.hidden = YES;
    [self addSubview:_rotateView];
    
    if (needTipsView) {
        _tipsView = [[SNTipsView alloc] initWithFrame:CGRectMake(10, frame.size.height - 48 - 30 - 20, frame.size.width - 2 * 10, 40)];
        _tipsView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipsView];
    } else {
        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_logo_dark.png"]];
        [_logoImageView setFrame:CGRectMake((frame.size.width - kAppLogoWidth / 2) / 2, frame.size.height - 48.0f - 60, kAppLogoWidth / 2, kAppLogoHeight / 2)];
        [self addSubview:_logoImageView];
    }
    
    [SNNotificationManager addObserver:self selector:@selector(updateTheme)
                                                 name:kThemeDidChangeNotification object:nil];
    [self setUIElements];
}

- (void)setUIElements {
    _lastUpdatedLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDragRefreshUpdateTimeColor]];
    _statusLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDragRefreshTextColor]];
    
    // 这里需要按日夜间的配置给色值
    self.circleViewBgColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDragCircleBgColor]];
    self.circleViewMaskColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDragCircleMaskColor]];
    
    _circleView.backgroundColor = [UIColor clearColor];
    _circleView.progressTintColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDragCircleMaskColor]];
    _circleView.trackTintColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDragCircleBgColor]];
    [_circleView setNeedsDisplay];
    
    _rotateView.backgroundColor = [UIColor clearColor];
    _rotateView.progressTintColor = _circleView.progressTintColor;
    _rotateView.trackTintColor = _circleView.trackTintColor;
    
    _tipsView.textColor = _lastUpdatedLabel.textColor;
    _logoImageView.alpha = themeImageAlphaValue();
}

- (void)updateTheme {
    [self setUIElements];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
    [_circleView invalidateTimer];
    [_rotateView invalidateTimer];
}

#pragma mark -
#pragma mark Public
- (CGFloat)circleViewDiameter {
    if (_circleViewDiameter == 0)
        self.circleViewDiameter = kDefaultCircleViewDiameter;
    return _circleViewDiameter;
}

- (void)setUpdateDate:(NSDate *)newDate {
	if (newDate) {
		if (_lastUpdatedDate != newDate) {
            _lastUpdatedDate = newDate;
		}
        
        NSTimeInterval elapsed = [_lastUpdatedDate timeIntervalSinceNow];
        if (elapsed > 0) {
            _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LastRefreshTime", @""), [_lastUpdatedDate formatTimeString]];
        } else {
            _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LastRefreshTime", @""), [_lastUpdatedDate formatRelativeTime]];
        }
	} else {
		_lastUpdatedDate = nil;
		_lastUpdatedLabel.text = NSLocalizedString(@"LastRefreshTimeNo", @"");
	}
}

- (void)refreshUpdateDate {
    [self setUpdateDate:_lastUpdatedDate];
}

- (void)setCurrentDate {
	[self setUpdateDate:[NSDate date]];
}

- (void)setStatusText:(NSString *)text {
    _statusLabel.text = text;
}

- (void)setStatus:(TTTableHeaderDragRefreshStatus)status {
    self.state = status;
    
	switch (status) {
		case TTTableHeaderDragRefreshReleaseToReload: {
			[self showActivity:NO animated:NO];
			_statusLabel.text = NSLocalizedString(@"ReleaseToRefresh", @"");
			break;
		}
		case TTTableHeaderDragRefreshPullToReload: {
			[self showActivity:NO animated:NO];
			_statusLabel.text = NSLocalizedString(@"DragToRefresh", @"");
			break;
		}
		case TTTableHeaderDragRefreshLoading: {
			[self showActivity:YES animated:YES];
			_statusLabel.text = NSLocalizedString(@"Refresh...", @"");
			break;
		}
		default: {
			break;
		}
	}
}

- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
	if (shouldShow) {
        _circleView.hidden = YES;
        _rotateView.hidden = NO;
        [_rotateView resetNow];
        [_rotateView updateProgress:0.25 anmiated:NO];
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:3] forKey:kCATransactionAnimationDuration];
        CALayer *theLayer = _rotateView.layer;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z" function:LinearInterpolation fromAngle:0 toAngle:(4 * M_PI)];
        animation.repeatCount = 100000000000;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.duration = 2;
        [theLayer addAnimation:animation forKey:@"transform.rotation.z"];
        [CATransaction commit];
	} else {
        _circleView.hidden = NO;
        _rotateView.hidden = YES;
        [_rotateView.layer removeAnimationForKey:@"transform.rotation.z"];
        [_rotateView resetNow];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y + scrollView.contentInset.top;
    self.currentScalePercent = 0;
    [_circleView updateProgress:self.currentScalePercent anmiated:NO];
    if (offsetY < 0) {
        if (offsetY > -self.refreshStartPosY) {
            // 这里有问题 算的不对
            CGFloat percent = (0 - offsetY) / self.refreshStartPosY;
            self.currentScalePercent = percent;
            [_circleView updateProgress:self.currentScalePercent anmiated:NO];
        }
        // 保持待刷新状态
        else {
            self.currentScalePercent = 1;
            [_circleView updateProgress:self.currentScalePercent anmiated:NO];
        }
    }
}

@end
