//
//  SNEmbededActivityIndicator.m
//  sohunewsipad
//
//  Created by handy wang on 12/4/12.
//  Copyright (c) 2012 sohu. All rights reserved.
//

#import "SNEmbededActivityIndicator.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"

#define kOffsetRate                                 (0.85)

#define kQuarterCircleViewWidth                     (170/2.0f)
#define kQuarterCircleViewHeight                    (170/2.0f)
#define kCircleBgViewWidth                          (170/2.0f)
#define kCircleBgViewHeight                         (170/2.0f)
#define kCircleBgShadowViewWidth                    (200/2.0f)
#define kCircleBgShadowViewHeigt                    (50/2.0f)

#define kTapActionBtnWidth                          (170/2.0f)
#define kTapActionBtnHeight                         (170/2.0f)

#define kNetworkErrorBtnWidth                       (170/2.0f)
#define kNetworkErrorBtnHeight                      (170/2.0f)

#define kLogoImageViewWidth                         (170/2.0f)
#define kLogoImageViewHeight                        (170/2.0f)

#define kZhMsgLabelFonSize                          (32/2.0f)
#define kZhMsgLabelHeight                           (kZhMsgLabelFonSize+1)
#define kZhMsgLabelVPaddingToCircleShadow           (20/2.0f)

#define kEnMsgLabelFonSize                          (24/2.0f)
#define kEnMsgLabelHeight                           (kEnMsgLabelFonSize+1)
#define kEnMsgLabelVPaddingToZhMsgLabel             (16/2.0f)

#define kEAIRotatingAnimation                       (@"transform.rotation.z")




@interface SNEmbededActivityIndicator()
@property(nonatomic, strong, readwrite)UIImageView *quarterCircleView;
@property(nonatomic, strong, readwrite)UIImageView *circleBgView;
@property(nonatomic, strong, readwrite)UIImageView *circleBgShadowView;
@property(nonatomic, strong, readwrite)UIButton *tapActionBtn;
@property(nonatomic, strong, readwrite)UIButton *networkErrorBtn;
@property(nonatomic, strong, readwrite)UILabel *zhMsgLabel;
@property(nonatomic, strong, readwrite)UILabel *enMsgLabel;
@property(nonatomic, readwrite)BOOL animating;
@end


@implementation SNEmbededActivityIndicator

@synthesize delegate = _delegate;
@synthesize quarterCircleView = _quarterCircleView;
@synthesize circleBgView = _circleBgView;
@synthesize circleBgShadowView = _circleBgShadowView;
@synthesize tapActionBtn = _tapActionBtn;
@synthesize networkErrorBtn = _networkErrorBtn;
@synthesize logoImageView = _logoImageView;

@synthesize zhMsgLabel = _zhMsgLabel;
@synthesize enMsgLabel = _enMsgLabel;

@synthesize zhReadyToRefreshMsg = _zhReadyToRefreshMsg;
@synthesize enReadyToRefreshMsg = _enReadyToRefreshMsg;

@synthesize zhLoadingMsg = _zhLoadingMsg;
@synthesize enLoadingMsg = _enLoadingMsg;

@synthesize zhNetworkErrorMsg = _zhNetworkErrorMsg;
@synthesize enNetworkErrorMsg = _enNetworkErrorMsg;

@synthesize status = _status;
@synthesize animating = _animating;
@synthesize hidesWhenStopped = _hidesWhenStopped;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initWorkWithDelegate:nil];
    }
    
    return self;
}

- (id)initWithDelegate:(id)delegateParam {
    if (self = [super init]) {
        [self initWorkWithDelegate:delegateParam];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegateParam {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWorkWithDelegate:delegateParam];
    }
    return self;
}

- (void)initWorkWithDelegate:(id)delegateParam {
    
    _zhReadyToRefreshMsg = nil;
    _enReadyToRefreshMsg = nil;
    
    _zhLoadingMsg = nil;
    _enLoadingMsg = nil;
    
    _zhNetworkErrorMsg = nil;
    _enNetworkErrorMsg = nil;
    
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
    [self addTarget:self action:@selector(tapRetry) forControlEvents:UIControlEventTouchUpInside];
    
    //---About network reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
    
    _status = SNEmbededActivityIndicatorStatusInit;
    _animating = NO;
    _hidesWhenStopped = NO;

    _delegate = delegateParam;
    
    [self circleBgView];
    [self circleBgShadowView];
    [self tapActionBtn];
    [self networkErrorBtn];
    [self logoImageView];
    [self quarterCircleView];
    [self localChannelBtn];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetToInitStatus) object:nil];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


#pragma mark - Public methods

- (void)startAnimating {
    [self setStatus:SNEmbededActivityIndicatorStatusStartLoading];
}

- (void)stopAnimating {
    [self setStatus:SNEmbededActivityIndicatorStatusStopLoading];
}

- (void)setStatus:(SNEmbededActivityIndicatorStatus)status {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetToInitStatus) object:nil];
    
    _status = status;
    
    switch (_status) {
        case SNEmbededActivityIndicatorStatusInit: {
            if (_animating) {
                [self stopRotating];
            }
            [self updateRenderByCurrentStatus];
            break;
        }
            
        case SNEmbededActivityIndicatorStatusStartLoading: {
            if (!([SNUtility getApplicationDelegate].isNetworkReachable)) {
                [self setStatus:SNEmbededActivityIndicatorStatusUnstableNetwork];
                return;
            }
            
            if (_animating) {
                return;
            }
            [self updateRenderByCurrentStatus];
            [self startRotating];
            break;
        }
            
        case SNEmbededActivityIndicatorStatusStopLoading: {
            if (_animating) {
                [self stopRotating];
            }
            [self updateRenderByCurrentStatus];
            break;
        }
            
        case SNEmbededActivityIndicatorStatusUnstableNetwork: {
            if (_animating) {
                [self stopRotating];
            }
            [self updateRenderByCurrentStatus];
            break;
        }
        case SNEmbededActivityIndicatorStatusLocalChannelError: {
            [self updateRenderByCurrentStatus];
            break;
        }
    }
}

- (BOOL)isAnimating {
    return _animating;
}

- (void)updateTheme {
    [self updateRenderByCurrentStatus];
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
}

- (void)updateTheme:(NSNotification *)notifiction {
    if (!self.hidden) {
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
        self.circleBgView.image = [UIImage imageNamed:@"eai_circle_bg.png"];
        self.circleBgShadowView.image = [UIImage imageNamed:@"eai_circle_bgshadow.png"];
        
        [self.networkErrorBtn setBackgroundImage:[UIImage imageNamed:@"eai_unstablenetwork.png"] forState:UIControlStateNormal];
        self.quarterCircleView.image = [UIImage imageNamed:@"eai_quartercircle.png"];
        [self.tapActionBtn setBackgroundImage:[UIImage imageNamed:@"eai_retryaction.png"] forState:UIControlStateNormal];
        self.logoImageView.image = [UIImage imageNamed:@"eai_sohu.png"];
        
        self.zhMsgLabel.textColor = SNUICOLOR(kLoadTextColor);
        self.enMsgLabel.textColor = SNUICOLOR(kLoadTextColor);
    }
}

#pragma mark - Ovrride

- (UIImageView *)quarterCircleView {
    if (!_quarterCircleView) {
        _quarterCircleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eai_quartercircle.png"]];
        _quarterCircleView.backgroundColor = [UIColor clearColor];
        _quarterCircleView.hidden = YES;
        [self addSubview:_quarterCircleView];
    }
    
    return _quarterCircleView;
}

- (UIImageView *)circleBgView {
    if (!_circleBgView) {
        _circleBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eai_circle_bg.png"]];
        _circleBgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_circleBgView];
    }
    
    return _circleBgView;
}

- (UIImageView *)circleBgShadowView {
    if (!_circleBgShadowView) {
        _circleBgShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eai_circle_bgshadow.png"]];
        _circleBgShadowView.backgroundColor = [UIColor clearColor];
        [self addSubview:_circleBgShadowView];
    }
    
    return _circleBgShadowView;
}

- (UIButton *)tapActionBtn {
    if (!_tapActionBtn) {
        _tapActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapActionBtn addTarget:self action:@selector(tapRetry) forControlEvents:UIControlEventTouchUpInside];
        [_tapActionBtn setBackgroundImage:[UIImage imageNamed:@"eai_retryaction.png"] forState:UIControlStateNormal];
        [self addSubview:_tapActionBtn];
    }

    return _tapActionBtn;
}

- (UIButton *)networkErrorBtn {
    if (!_networkErrorBtn) {
        _networkErrorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_networkErrorBtn setBackgroundImage:[UIImage imageNamed:@"eai_unstablenetwork.png"] forState:UIControlStateNormal];
        _networkErrorBtn.hidden = YES;
        [self addSubview:_networkErrorBtn];
    }
    
    return _networkErrorBtn;
}

- (UIImageView *)logoImageView
{
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eai_sohu.png"]];
        _logoImageView.hidden = YES;
        [self addSubview:_logoImageView];
    }
    
    return _logoImageView;
}

- (UIButton *)localChannelBtn
{
    if (!_localChannelBtn) {
        _localChannelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _localChannelBtn.frame = CGRectMake(0, 0, 155, 155);
        [_localChannelBtn setBackgroundImage:[UIImage imageNamed:@"eai_localchannel_failure.png"] forState:UIControlStateNormal];
        _localChannelBtn.hidden = YES;
        [_localChannelBtn addTarget:self action:@selector(tapRetry) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_localChannelBtn];
    }
    
    return _localChannelBtn;
}

- (UILabel *)zhMsgLabel {
    if (!_zhMsgLabel) {
        _zhMsgLabel = [[UILabel alloc] init];
        _zhMsgLabel.backgroundColor = [UIColor clearColor];
        _zhMsgLabel.textAlignment = NSTextAlignmentCenter;
        _zhMsgLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLoadTextColor]];
        _zhMsgLabel.font = [UIFont systemFontOfSize:kZhMsgLabelFonSize];
        [self addSubview:_zhMsgLabel];
    }
    
    return _zhMsgLabel;
}

- (UILabel *)enMsgLabel {
    if (!_enMsgLabel) {
        _enMsgLabel = [[UILabel alloc] init];
        _enMsgLabel.backgroundColor = [UIColor clearColor];
        _enMsgLabel.textAlignment = NSTextAlignmentCenter;
        _enMsgLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLoadTextColor]];
        _enMsgLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kEnMsgLabelFonSize];
        [self addSubview:_enMsgLabel];
    }
    
    return _enMsgLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.quarterCircleView.frame = CGRectMake((CGRectGetWidth(self.frame)-kQuarterCircleViewWidth)/2.0f,
                                              (CGRectGetHeight(self.frame)*kOffsetRate-kQuarterCircleViewHeight)/2.0f,
                                              kQuarterCircleViewWidth,
                                              kQuarterCircleViewHeight);
    
    self.circleBgView.frame = CGRectMake((CGRectGetWidth(self.frame)-kCircleBgViewWidth)/2.0f,
                                         (CGRectGetHeight(self.frame)*kOffsetRate-kCircleBgViewHeight)/2.0f,
                                         kCircleBgViewWidth,
                                         kCircleBgViewHeight);
    
    self.circleBgShadowView.frame = CGRectMake((CGRectGetWidth(self.frame)-kCircleBgShadowViewWidth)/2.0f,
                                               CGRectGetMaxY(self.circleBgView.frame),
                                               kCircleBgShadowViewWidth,
                                               kCircleBgShadowViewHeigt);
    
    self.tapActionBtn.frame = CGRectMake(0, 0, kTapActionBtnWidth, kTapActionBtnHeight);
    self.tapActionBtn.center = self.circleBgView.center;
    
    self.networkErrorBtn.frame = CGRectMake(0, 0, kNetworkErrorBtnWidth, kNetworkErrorBtnHeight);
    self.networkErrorBtn.center = self.circleBgView.center;
    
    self.logoImageView.frame = CGRectMake(0, 0, kLogoImageViewWidth, kLogoImageViewWidth);
    self.logoImageView.center = self.circleBgView.center;
    
    _localChannelBtn.center = self.circleBgView.center;
    
    self.zhMsgLabel.frame = CGRectMake(0,
                                       CGRectGetMaxY(self.circleBgShadowView.frame)+kZhMsgLabelVPaddingToCircleShadow,
                                       CGRectGetWidth(self.frame),
                                       kZhMsgLabelHeight);
    
    self.enMsgLabel.frame = CGRectMake(0,
                                       CGRectGetMaxY(self.zhMsgLabel.frame)+kEnMsgLabelVPaddingToZhMsgLabel,
                                       CGRectGetWidth(self.frame),
                                       kEnMsgLabelHeight);
    

    [self setStatus:_status];
}


#pragma mark - Private methods

- (void)updateRenderByCurrentStatus {
    
    self.circleBgView.hidden = NO;
    self.circleBgShadowView.hidden = NO;
    self.quarterCircleView.hidden = NO;
    _localChannelBtn.hidden = YES;
    
    switch (_status) {
        case SNEmbededActivityIndicatorStatusInit: {
            [self showSelfIfNeed];
            
            [self updateRenderForInitLoadingExcludeHidesWhenStopped];
            break;
        }
            
        case SNEmbededActivityIndicatorStatusStartLoading: {
            [self showSelfIfNeed];
            
            self.tapActionBtn.hidden=YES;
            self.networkErrorBtn.hidden = YES;
            self.quarterCircleView.alpha = 0;
            self.quarterCircleView.hidden = NO;
            
            self.logoImageView.hidden = NO;
            [UIView animateWithDuration:0.2 animations:^{self.quarterCircleView.alpha=1;}];
            
            self.zhMsgLabel.text = (!!_zhLoadingMsg ? _zhLoadingMsg : @"搜狐新闻");
            self.enMsgLabel.text = (!!_enLoadingMsg ? _enLoadingMsg : @"SOHU NEWS");
            break;
        }
            
        case SNEmbededActivityIndicatorStatusStopLoading: {
            [self updateRenderForStopStatusIncludingHidesWhenStopped];
            break;
        }
            
        case SNEmbededActivityIndicatorStatusUnstableNetwork: {
            [self showSelfIfNeed];
            
            [self.networkErrorBtn setBackgroundImage:[UIImage imageNamed:@"eai_unstablenetwork.png"] forState:UIControlStateNormal];
            self.networkErrorBtn.hidden = NO;
            self.tapActionBtn.hidden = YES;
            self.quarterCircleView.hidden = YES;
            self.logoImageView.hidden = YES;

            self.zhMsgLabel.text = (!!_zhNetworkErrorMsg ? _zhNetworkErrorMsg : @"网络不给力，无法加载");
            self.enMsgLabel.text = (!!_enNetworkErrorMsg ? _enNetworkErrorMsg : @"Network is unstable...");
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetToInitStatus) object:nil];
            [self performSelector:@selector(resetToInitStatus) withObject:nil afterDelay:3];
            break;
        }
        case SNEmbededActivityIndicatorStatusLocalChannelError: {
            self.quarterCircleView.hidden = YES;
            self.circleBgView.hidden = YES;
            self.circleBgShadowView.hidden = YES;
            self.tapActionBtn.hidden = YES;
            self.networkErrorBtn.hidden = YES;
            self.logoImageView.hidden = YES;
            self.zhMsgLabel.text = @"";
            self.enMsgLabel.text = @"";
            _localChannelBtn.hidden = NO;
            [_localChannelBtn setBackgroundImage:[UIImage imageNamed:@"eai_localchannel_failure.png"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
    if (!self.hidden) {
        self.circleBgView.image = [UIImage imageNamed:@"eai_circle_bg.png"];
        self.circleBgShadowView.image = [UIImage imageNamed:@"eai_circle_bgshadow.png"];
        
        [self.networkErrorBtn setBackgroundImage:[UIImage imageNamed:@"eai_unstablenetwork.png"] forState:UIControlStateNormal];
        self.quarterCircleView.image = [UIImage imageNamed:@"eai_quartercircle.png"];
        [self.tapActionBtn setBackgroundImage:[UIImage imageNamed:@"eai_retryaction.png"] forState:UIControlStateNormal];
        self.logoImageView.image = [UIImage imageNamed:@"eai_sohu.png"];
        
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLoadTextColor];
        self.zhMsgLabel.textColor = [UIColor colorFromString:strColor];
        self.enMsgLabel.textColor = [UIColor colorFromString:strColor];
    }

}

- (void)updateRenderForStopStatusIncludingHidesWhenStopped {
    [self updateRenderForInitLoadingExcludeHidesWhenStopped];

    if (_hidesWhenStopped && !(self.hidden)) {
        self.hidden = YES;
    }
}

- (void)updateRenderForInitLoadingExcludeHidesWhenStopped {
    if (_animating) {
        self.quarterCircleView.hidden = NO;
    } else {
        self.quarterCircleView.hidden = YES;
    }
    
    if (self.tapActionBtn.hidden) {
        self.tapActionBtn.alpha = 0;
        self.tapActionBtn.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{self.tapActionBtn.alpha=1;}];
    }
    self.networkErrorBtn.hidden = YES;
    self.logoImageView.hidden = YES;
    self.zhMsgLabel.text = (!!_zhReadyToRefreshMsg ? _zhReadyToRefreshMsg : @"单击可以加载内容");
    self.enMsgLabel.text = (!!_enReadyToRefreshMsg ? _enReadyToRefreshMsg : @"Click to load...");
}

- (void)showSelfIfNeed {
    if (self.hidden) {
        self.alpha = 0;
        self.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{self.alpha=1;}];
    }
}

- (void)resetToInitStatus {
    [self setStatus:SNEmbededActivityIndicatorStatusInit];
}

- (void)tapRetry {
    if (self.status == SNEmbededActivityIndicatorStatusStartLoading) {
        return;
    }
    if (self.status == SNEmbededActivityIndicatorStatusLocalChannelError) {
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://localChannelList"] applyAnimated:YES] applyQuery:nil];
        [[TTNavigator navigator] openURLAction:urlAction];
        return;
    }
    [self startAnimating];
    
    if ([_delegate respondsToSelector:@selector(didTapRetry)]) {
        [_delegate didTapRetry];
    }
}

- (void)startRotating {
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:3] forKey:kCATransactionAnimationDuration];
    CALayer* theLayer = self.quarterCircleView.layer;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:kEAIRotatingAnimation
                                                               function:LinearInterpolation
                                                              fromAngle:0
                                                                toAngle:4*M_PI];
    animation.repeatCount = 100000000000;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [theLayer addAnimation:animation forKey:kEAIRotatingAnimation];
    [CATransaction commit];
    
    _animating = YES;
}

- (void)stopRotating {
    [self.quarterCircleView.layer removeAnimationForKey:kEAIRotatingAnimation];
    _animating = NO;
}


#pragma mark - Network reachability

- (void)reachabilityChanged:(NSNotification* )note {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //网络不可用
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        }
        //网络可用
        else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetToInitStatus) object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!(self.hidden)) {
                    [self setStatus:SNEmbededActivityIndicatorStatusInit];
                }
            });
        }
    });
}

@end





@implementation SNEmbededActivityIndicatorEx

- (void)setStatus:(SNEmbededActivityIndicatorStatus)status {
    
    if(status==SNEmbededActivityIndicatorStatusStartLoading)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetToInitStatus) object:nil];
        _status = status;
        
        if (_animating)
            return;
        
        [super updateRenderByCurrentStatus];
        [super startRotating];
        return;
    }
    else
        [super setStatus:status];
}

@end
