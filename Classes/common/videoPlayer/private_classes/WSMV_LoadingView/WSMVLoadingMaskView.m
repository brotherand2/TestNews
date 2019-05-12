//
//  WSMVLoadingMaskView.m
//  sohunews
//
//  Created by Gao Yongyue on 13-10-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "WSMVLoadingMaskView.h"
#import "WSMVLoadingView.h"
#import "SNTripletsLoadingView.h"

#define kUserGuideImageViewWidth   70.f
#define kUserGuideImageViewHeight  56.f

#define kLoadingViewWidth    59.f
#define kLoadingViewHeight   57.f

#define kUserGuideImageViewLeftAndRightMargin  5.f

@interface WSMVLoadingMaskView ()
{
    UIImageView *_userGuideVolumnImageView;
    UIImageView *_userGuideSwitchImageView;
}
@end

@implementation WSMVLoadingMaskView

- (id)initWithFrame:(CGRect)frame showUserGuide:(BOOL)showUserGuide
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        _loadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0.f, 0.f, kLoadingViewWidth, kLoadingViewHeight)];
        //_loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _loadingView.backgroundColor = [UIColor clearColor];
        
        [_loadingView setColorVideoMode:YES];
        
        [self addSubview:_loadingView];
        _loadingView.center = self.center;//CGPointMake(self.centerX, self.centerY);
        //_loadingView.top -= 5.f;
        
        _userGuideVolumnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kUserGuideImageViewLeftAndRightMargin, (frame.size.height - kUserGuideImageViewHeight)/2 - 5.f, kUserGuideImageViewWidth, kUserGuideImageViewHeight)];
        _userGuideVolumnImageView.image = [UIImage imageNamed:@"wsmv_userguide_volumn.png"];
        _userGuideVolumnImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_userGuideVolumnImageView];
        
        _userGuideSwitchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - kUserGuideImageViewLeftAndRightMargin - kUserGuideImageViewWidth, _userGuideVolumnImageView.top, kUserGuideImageViewWidth, kUserGuideImageViewHeight)];
        _userGuideSwitchImageView.image = [UIImage imageNamed:@"wsmv_userguide_switch.png"];
        _userGuideSwitchImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_userGuideSwitchImageView];
        
        [self setShowUserGuide:showUserGuide];
        
        self.hidden = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _loadingView.center = self.center;
}

- (void)setShowUserGuide:(BOOL)showUserGuide
{
    _showUserGuide = showUserGuide;
    if (showUserGuide)
    {
        _userGuideVolumnImageView.hidden = NO;
        _userGuideSwitchImageView.hidden = NO;
    }
    else
    {
        _userGuideSwitchImageView.hidden = YES;
        _userGuideVolumnImageView.hidden = YES;
    }
}

- (void)reset
{
    _loadingView.center = CGPointMake(self.centerX, self.centerY);
    //_loadingView.top -= 5.f;
    _userGuideVolumnImageView.frame = CGRectMake(kUserGuideImageViewLeftAndRightMargin, (self.frame.size.height - kUserGuideImageViewHeight)/2 - 5.f, kUserGuideImageViewWidth, kUserGuideImageViewHeight);
    _userGuideSwitchImageView.frame = CGRectMake(self.frame.size.width - kUserGuideImageViewLeftAndRightMargin - kUserGuideImageViewWidth, _userGuideVolumnImageView.top, kUserGuideImageViewWidth, kUserGuideImageViewHeight);
}

- (void)startLoadingViewAnimation
{
    if (!(self.hidden)) {
        return;
    }
    
    self.hidden = NO;
    [_loadingView setStatus:SNTripletsLoadingStatusLoading];
}
- (void)stopLoadingViewAnimation
{
    self.hidden = YES;
    [_loadingView setStatus:SNTripletsLoadingStatusStopped];
}
- (void)dealloc
{
    _loadingView = nil;
    _userGuideVolumnImageView = nil;
    _userGuideSwitchImageView = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
