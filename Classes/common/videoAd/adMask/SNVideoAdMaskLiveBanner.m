//
//  SNVideoAdMaskLiveBanner.m
//  sohunews
//
//  Created by handy wang on 5/15/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNVideoAdMaskLiveBanner.h"
#import "SNLiveBannerView.h"

static const CGFloat kSimpleCountdownBoardFontsize = 28/2.0f;
static const CGFloat kSimpleCountdownBoardWidth = 52/2.0f;
static const CGFloat kSimpleCountdownBoardHeight = 40/2.0f;
static const CGFloat kSimpleCountdownBoardMarginRight = 10/2.0f;
static const CGFloat kSimpleCountdownBoardMarginTop = 10/2.0f;

@interface SNVideoAdMaskLiveBanner() {
    UIButton *_simpleCountdownBoard;
    BOOL _isShrinked;
}
@end

@implementation SNVideoAdMaskLiveBanner

#pragma mark - Override
- (void)o_willFinishInitSubviews {
    [self p_initSimpleCountdownBoard];
}

- (void)p_initSimpleCountdownBoard {
    if (!_simpleCountdownBoard) {
        _simpleCountdownBoard = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
        UIImage *btnBgImg = [[UIImage imageNamed:@"videoAdMask_actionBtnBgImg.png"] resizableImageWithCapInsets:insets];
        [_simpleCountdownBoard setBackgroundImage:btnBgImg forState:UIControlStateNormal];
        
        [_simpleCountdownBoard.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_simpleCountdownBoard.titleLabel setFont:[UIFont systemFontOfSize:kSimpleCountdownBoardFontsize]];
        [_simpleCountdownBoard setTitleColor:[UIColor colorFromString:@"eb1e13"] forState:UIControlStateNormal];
        [_simpleCountdownBoard setTitleEdgeInsets:UIEdgeInsetsMake(2, 0, -2, 0)];
        _simpleCountdownBoard.hidden = YES;
        [self addSubview:_simpleCountdownBoard];
    }
}

- (void)o_willFinishLayoutSubviews {
    [self p_layoutSimpleCountdownBoard];
}

- (void)p_layoutSimpleCountdownBoard {
    CGFloat left = self.width-(kSimpleCountdownBoardWidth+kSimpleCountdownBoardMarginRight);
    CGRect simpleCountdownBoardFrame = CGRectMake(left, kSimpleCountdownBoardMarginTop, kSimpleCountdownBoardWidth, kSimpleCountdownBoardHeight);
    _simpleCountdownBoard.frame = simpleCountdownBoardFrame;
}

#pragma mark -
- (void)maskWillAppearInVideoPlayer:(WSMVVideoPlayerView *)videoPlayer {
    id delegate = videoPlayer.delegate;
    if ([delegate isKindOfClass:[SNLiveBannerView class]]) {
        SNLiveBannerView *bannerView = (SNLiveBannerView *)delegate;
        if (bannerView.hasExpanded) {
            [self setIsShrinked:NO];
        }
        else {
            [self setIsShrinked:YES];
        }
    }
}

- (void)o_didUpdateCountdownSecondsValue:(NSTimeInterval)leftSeconds {
    NSString *leftSecondsText = [NSString stringWithFormat:@"%02d", (int)leftSeconds];
    [_simpleCountdownBoard setTitle:leftSecondsText forState:UIControlStateNormal];
}

#pragma mark - Public
- (void)setIsShrinked:(BOOL)isShrinked {
    _isShrinked = isShrinked;
    if (_isShrinked) {
        [self hideHeaderAndFooter];
        _simpleCountdownBoard.hidden = NO;
    }
    else {
        [self showHeaderAndFooter];
        _simpleCountdownBoard.hidden = YES;
    }
}

@end