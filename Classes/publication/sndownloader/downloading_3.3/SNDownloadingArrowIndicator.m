//
//  SNDownloadingArrowIndicator.m
//  sohunews
//
//  Created by handy wang on 1/23/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingArrowIndicator.h"
#import "UIColor+ColorUtils.h"

#define SELF_WIDTH                  (34/2.0f)
#define SELF_HEIGHT                 (34/2.0f)

#define kDownloadingIndicatorAnimation  (@"kDownloadingIndicatorAnimation")

@interface SNDownloadingArrowIndicator() {
    UIImageView *_arrowMask;
    UIImageView *_animatingView;
}
@property(nonatomic, strong)UIImageView *arrowMask;
@property(nonatomic, strong)UIImageView *animatingView;
@end

@implementation SNDownloadingArrowIndicator
@synthesize arrowMask = _arrowMask;
@synthesize animatingView = _animatingView;

#pragma mark - Lifecycle

- (id)initWithPosition:(CGPoint)position {
    self = [super initWithFrame:CGRectMake(position.x, position.y, SELF_WIDTH, SELF_HEIGHT)];
    if (self) {
        self.hidden = YES;
        [self setClipsToBounds:YES];
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingArrowIndicatorBGColor]];
        
        [self animatingView];
        [self arrowMask];
    }
    return self;
}

- (void)dealloc {
     //(_arrowMask);
     //(_animatingView);
    
}

#pragma mark - Override

- (UIImageView *)animatingView {
    if (!_animatingView) {
        _animatingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -self.height, self.width, self.height)];
        _animatingView.image = [UIImage imageNamed:@"downloading_indicator_animationviewbg.png"];
        _animatingView.hidden = YES;
        [self addSubview:_animatingView];
    }
    return _animatingView;
}

- (UIImageView *)arrowMask {
    if (!_arrowMask) {
        _arrowMask = [[UIImageView alloc] initWithFrame:self.bounds];
        _arrowMask.image = [UIImage imageNamed:@"downloading_arrow_mask.png"];
        [self addSubview:_arrowMask];
    }
    return _arrowMask;
}

#pragma mark - Public methods

- (void)startAnimation {
    self.hidden = NO;
    _animatingView.hidden = NO;
    NSValue *_fromValue = [NSValue valueWithCGPoint:_animatingView.center];
    NSValue *_toValue = [NSValue valueWithCGPoint:CGPointMake(_animatingView.width/2.0f, _animatingView.height*3/2.0f)];
    CABasicAnimation *_downloadingAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [_downloadingAnimation setRemovedOnCompletion:NO];
    [_downloadingAnimation setFromValue:_fromValue];
    [_downloadingAnimation setToValue:_toValue];
    [_downloadingAnimation setDuration:1.5];
    [_downloadingAnimation setRepeatCount:FLT_MAX];
    [_animatingView.layer addAnimation:_downloadingAnimation forKey:kDownloadingIndicatorAnimation];
}

- (void)stopAnimation {
    [_animatingView.layer removeAnimationForKey:kDownloadingIndicatorAnimation];
    _animatingView.hidden = YES;
    self.hidden = YES;
}

@end
