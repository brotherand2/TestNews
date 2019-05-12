//
//  SNDingImageView.m
//  sohunews
//
//  Created by lhp on 6/28/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDingView.h"

@interface SNDingView () <CAAnimationDelegate>

@end

@implementation SNDingView

@synthesize dingImageView = _dingImageView;

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _dingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width -35,(frame.size.height-25)/2-1,
                                                                       kApprovalViewWidth, kApprovalViewHeight)];
//        NSString *normalString = [[SNThemeManager sharedThemeManager] themeImageNamed:@"ding_normal.png"];
//        NSString *highlightString = [[SNThemeManager sharedThemeManager] themeFileName:@"ding_highlight.png"];
        UIImage *normalImage = [UIImage themeImageNamed:@"icotext_like_v5.png"];
        UIImage *highlightImage = [UIImage themeImageNamed:@"icotext_like_press_v5.png"];
        _dingImageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2+3);
        _dingImageView.size = normalImage.size;
        _dingImageView.image = normalImage;
        _dingImageView.highlightedImage = highlightImage;
        [self addSubview:_dingImageView];
        
        [self sizeToFit];
    }
    return self;
}

- (void)beginAnimation {
    if (_animating || self.dingImageView.highlighted) {
        return;
    }
    [self doAnimation:YES];
}

- (void)doAnimation:(BOOL)isHighLight {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _dingImageView.layer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0);
        
    } completion:^(BOOL finished) {
        
        if (!finished) {
            return ;
        }
        
        self.dingImageView.highlighted = isHighLight;
        
        _dingImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
        CAKeyframeAnimation * animation;
        animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.duration = 0.40;
        animation.removedOnCompletion = YES;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 0.9)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        animation.values = values;
        
        _animating = YES;
        [_dingImageView.layer addAnimation:animation forKey:nil];
    }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        _animating = NO;
    }
}

- (void)dealloc{
    
     //(_dingImageView);
}

- (void)updateTheme
{
//    NSString *normalString = [[SNThemeManager sharedThemeManager] themeFileName:@"ding_normal.png"];
//    NSString *highlightString = [[SNThemeManager sharedThemeManager] themeFileName:@"ding_highlight.png"];
//    UIImage *normalImage = [UIImage themeImageNamed:@"icotext_like_v5.png"];
//    UIImage *highlightImage = [UIImage themeImageNamed:@"icotext_like_press_v5.png"];
//    _dingImageView.image = normalImage;
//    _dingImageView.highlightedImage = highlightImage;
}

@end
