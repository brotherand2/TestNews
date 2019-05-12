//
//  SNNavigationView.m
//  sohunews
//
//  Created by wang yanchen on 12-9-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNNavigationView.h"

#define kSideMargin         (7.0)
#define kNavigationHeight   (44)

@implementation SNNavigationView
@synthesize leftBtn = _leftBtn;
@synthesize rightBtn = _rightBtn;
@synthesize backgroundView = _backgroundView;
@synthesize titleView = _titleView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = kNavigationBarShadowOffset;
        self.layer.shadowOpacity = kNavigationBarShadowOpacity;
        self.layer.shadowRadius = kNavigationBarShadowRadius;
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:_backgroundView];
    }
    return self;
}

+ (SNNavigationView *)defautlNavigationView {
    SNNavigationView *aNavi = [[SNNavigationView alloc] initWithFrame:CGRectMake(0, 0, TTScreenBounds().size.width, kNavigationHeight)];
    return aNavi;
}

- (void)dealloc {
     //(_leftBtn);
     //(_rightBtn);
     //(_titleView);
     //(_backgroundView);
}

- (void)setLeftBtn:(UIButton *)leftBtn {
    if (_leftBtn != leftBtn) {
        [_leftBtn removeFromSuperview];
         //(_leftBtn);
        _leftBtn = leftBtn;
        [self addSubview:_leftBtn];
        [self setNeedsLayout];
    }
}

- (void)setRightBtn:(UIButton *)rightBtn {
    if (_rightBtn != rightBtn) {
        [_rightBtn removeFromSuperview];
         //(_rightBtn);
        _rightBtn = rightBtn;
        [self addSubview:_rightBtn];
        [self setNeedsLayout];
    }
}

- (void)setTitleView:(UIView *)titleView {
    if (_titleView != titleView) {
        [_titleView removeFromSuperview];
         //(_titleView);
        _titleView = titleView;
        [self addSubview:_titleView];
        [self setNeedsLayout];
    }
}

- (void)setBackgroundView:(UIImageView *)backgroundView {
    if (_backgroundView != backgroundView) {
        [_backgroundView removeFromSuperview];
         //(_backgroundView);
        _backgroundView = backgroundView;
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundView];
        [self sendSubviewToBack:_backgroundView];
        [self setNeedsLayout];
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (!_backgroundView) {
        self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    }
    _backgroundView.image = backgroundImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_leftBtn) {
        _leftBtn.frame = CGRectMake(kSideMargin, (self.height - _leftBtn.height) / 2,
                                    _leftBtn.width, _leftBtn.height);
    }
    if (_rightBtn) {
        _rightBtn.frame = CGRectMake(self.width - kSideMargin - _rightBtn.width, (self.height - _rightBtn.height) / 2,
                                     _rightBtn.width, _rightBtn.height);
    }
    if (_titleView) {
        _titleView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    if (_backgroundView) {
        _backgroundView.frame = self.bounds;
    }
}

@end
