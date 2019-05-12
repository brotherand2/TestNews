//
//  WSMVLoadingView.m
//  sohunewsipad
//
//  Created by guoyalun on 12/11/12.
//  Copyright (c) 2012 sohu. All rights reserved.
//

#import "WSMVLoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "WSMVConst.h"

#define kLoadingViewWidth                       (59.0f)
#define kLoadingViewHeight                      (59.0f)

@interface WSMVLoadingView() <CAAnimationDelegate> {
    UIImageView *_bgView;
}
@end

@implementation WSMVLoadingView
- (id)initWithSuperView:(UIView *)superView {
        CGRect _superViewFrame = superView.frame;
        CGRect _frame = CGRectMake((CGRectGetWidth(_superViewFrame)-kLoadingViewWidth)/2.0f, (CGRectGetHeight(_superViewFrame)-kLoadingViewHeight)/2.0f, kLoadingViewWidth, kLoadingViewHeight);
    
    self = [super initWithFrame:_frame];
    if (self) {
        self.backgroundColor    = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.hidden = YES;
        
        UIImage *_videoLoadingBg    = [UIImage imageNamed:@"wsmv_videoloading_bg.png"];
        _bgView                     = [[UIImageView alloc] initWithImage:_videoLoadingBg];
        _bgView.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        CGSize _loadingBgSize       = _videoLoadingBg.size;
        _bgView.frame               = CGRectMake((CGRectGetWidth(self.bounds)-_loadingBgSize.width)/2,
                                                 (CGRectGetHeight(self.bounds)-_loadingBgSize.height)/2,
                                                 _loadingBgSize.width,
                                                 _loadingBgSize.height);
        [self addSubview:_bgView];
        
        
        UIImage *_videoLoadingIndicator = [UIImage imageNamed:@"wsmv_videoloading_indicator.png"];
        indicatorView                   = [[UIImageView alloc] initWithImage:_videoLoadingIndicator];
        indicatorView.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        CGSize _contentSize             = _videoLoadingIndicator.size;
        indicatorView.frame             = CGRectMake((CGRectGetWidth(self.bounds)-_contentSize.width)/2,
                                                     (CGRectGetHeight(self.bounds)-_contentSize.height)/2,
                                                     _contentSize.width,
                                                     _contentSize.height);
        [self addSubview:indicatorView];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor    = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.hidden = YES;
        
        UIImage *_videoLoadingBg    = [UIImage imageNamed:@"wsmv_videoloading_bg.png"];
        _bgView                     = [[UIImageView alloc] initWithImage:_videoLoadingBg];
        _bgView.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        CGSize _loadingBgSize       = self.size;
        _bgView.frame               = CGRectMake((CGRectGetWidth(self.bounds)-_loadingBgSize.width)/2,
                                                 (CGRectGetHeight(self.bounds)-_loadingBgSize.height)/2,
                                                 _loadingBgSize.width,
                                                 _loadingBgSize.height);
        [self addSubview:_bgView];
        
        
        UIImage *_videoLoadingIndicator = [UIImage imageNamed:@"wsmv_videoloading_indicator.png"];
        indicatorView                   = [[UIImageView alloc] initWithImage:_videoLoadingIndicator];
        indicatorView.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        CGSize _contentSize             = self.size;
        indicatorView.frame             = CGRectMake((CGRectGetWidth(self.bounds)-_contentSize.width)/2,
                                                     (CGRectGetHeight(self.bounds)-_contentSize.height)/2,
                                                     _contentSize.width,
                                                     _contentSize.height);
        [self addSubview:indicatorView];
    }
    return self;
}

- (void)dealloc {
     _bgView = nil;
     indicatorView = nil;
}


- (void)startAnimation {
    if (!(self.hidden)) {
        return;
    }
    
    self.hidden = NO;

    CABasicAnimation *expandbBundsAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [expandbBundsAnimation setDelegate:self];
    [expandbBundsAnimation setRemovedOnCompletion:YES];
    [expandbBundsAnimation setFromValue:[NSValue valueWithCATransform3D: CATransform3DMakeRotation(0, 0, 0, 1.0)]];
    [expandbBundsAnimation setToValue:[NSValue valueWithCATransform3D: CATransform3DMakeRotation(0.9999* M_PI, 0, 0, 1.0)]];
    [expandbBundsAnimation setDuration:0.8f];
    [expandbBundsAnimation setRepeatCount:HUGE_VALF];
    [expandbBundsAnimation setCumulative:YES];
    [indicatorView.layer addAnimation:expandbBundsAnimation forKey:@"transform"];
}

- (void)stopAnimation
{
    [indicatorView.layer removeAllAnimations];
    self.hidden = YES;
}

#pragma mark - CAAnimationDelegate
/* Called when the animation begins its active duration. */
- (void)animationDidStart:(CAAnimation *)anim {
    NSLogInfo(@"Loading animation did start...");
}

/* Called when the animation either completes its active duration or
 * is removed from the object it is attached to (i.e. the layer). 'flag'
 * is true if the animation reached the end of its active duration
 * without being removed. */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLogInfo(@"Loading animation did stop, and finished flag is %d", flag);
}

@end
