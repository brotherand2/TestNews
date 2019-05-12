//
//  SNLiveBannerViewWithTitleVideo.m
//  sohunews
//
//  Created by wang yanchen on 13-5-3.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveBannerViewWithTitleVideo.h"
#import "UIColor+ColorUtils.h"
#import "SNVideoAdMaskHelper.h"
#import "SNSkinManager.h"

#define kTitleViewHeight            ((512 + 20) / 2 + kSystemBarHeight)
#define kTitleViewHeight_S          ((220 + 10) / 2 + kSystemBarHeight)

#define kTitleTopMarginS            (28 / 2 + kSystemBarHeight)
#define kTitleTopMargin             (28 / 2 + kSystemBarHeight)
#define kTitleSideMargin            (20 / 2)
#define kTitleFont                  (40 / 2)
#define kTitleFontS                 (36 / 2)

#define kTitleVideoPlayerTopMargin       ((88 + 24)/ 2 + kSystemBarHeight)
#define kTitleVideoPlayerTopMargin_S     (18 / 2 + kSystemBarHeight)
#define kTitleVideoPlayerSideMargin      (20 / 2)
#define kTitleVideoPlayerSideMargin_S    (22 / 2)
#define kTitleVideoPlayerHeight          (360 / 2)
#define kTitleVideoPlayerWidth_S         (260 / 2)
#define kTitleVideoPlayerHeight_S        (146 / 2)

// live status
#define kLiveStatusFont             (18 / 2)
#define kLiveStatusBottomMargin     (14 / 2)
#define kLiveStatusLeftMargin       (338 / 2)
#define kLiveStatusLeftMargin_S     (338 / 2)

@implementation SNLiveBannerViewWithTitleVideo

- (CGRect)viewFrame:(BOOL)bShrinkMode {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect frame = CGRectMake(0, 0, appFrame.size.width, bShrinkMode?kTitleViewHeight_S:kTitleViewHeight);
    return frame;
}

- (id)initWithMode:(BOOL)bShrinkMode {
    self = [super initWithMode:bShrinkMode];
    if (self) {
        [_scoreDotsLabel removeFromSuperview];
         //(_scoreDotsLabel);
        
        [_vsLabel removeFromSuperview];
         //(_vsLabel);
        
        [_hostTeamName removeFromSuperview];
         //(_hostTeamName);
        [_hostScore removeFromSuperview];
         //(_hostScore);
        [_hostUpView removeFromSuperview];
         //(_hostUpView);
        [_hostUpLabel removeFromSuperview];
         //(_hostUpLabel);
        
        [_visitTeamName removeFromSuperview];
         //(_visitTeamName);
        [_visitScore removeFromSuperview];
         //(_visitScore);
        [_visitUpView removeFromSuperview];
         //(_visitUpView);
        [_visitUpLabel removeFromSuperview];
         //(_visitUpLabel);
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTitleSideMargin,
                                                                kTitleTopMargin,
                                                                self.width -  2 * kTitleSideMargin,
                                                                kTitleFont + 1)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:kTitleFont];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 1;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.clipsToBounds = NO;
        [self addSubview:_titleLabel];
        
        [self setHasLeftVerticleLine:NO];
        
        _leftVerticleLine.top = _titleLabel.top-1;
        _leftVerticleLine.height = _titleLabel.height + 17;
        
        
        _liveStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLiveStatusLeftMargin,
                                                                     self.height - kLiveStatusBottomMargin - kLiveStatusFont - 1,
                                                                     125,
                                                                     kLiveStatusFont + 1)];
        _liveStatusLabel.backgroundColor = [UIColor clearColor];
        _liveStatusLabel.font = [UIFont systemFontOfSize:kLiveStatusFont];
        _liveStatusLabel.textAlignment = NSTextAlignmentLeft;
        _liveStatusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_liveStatusLabel];
        //_liveStatusLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];

        
        [self updateTheme];
    }
    return self;
}

- (void)layoutStatusLabel {
    _liveStatusLabel.frame = CGRectMake(_titleLabel.left,
                                        _titleLabel.bottom + 5,
                                        _liveStatusLabel.width,
                                        _liveStatusLabel.height);
    
    // 判断是否显示 独家
    if (self.infoObj.pubType.integerValue == 1) {
        if (!_pubTypeLabel) {
            _pubTypeLabel = [[UILabel alloc] initWithFrame:_liveStatusLabel.frame];
            _pubTypeLabel.backgroundColor = [UIColor clearColor];
            _pubTypeLabel.font = _liveStatusLabel.font;
            _pubTypeLabel.textColor = [SNSkinManager color:SkinRed];
            _pubTypeLabel.text = kPubTypeName;
            _pubTypeLabel.width = 25.0;
            [self addSubview:_pubTypeLabel];
        }
        
        _pubTypeLabel.top = _liveStatusLabel.top;
        _liveStatusLabel.left = _pubTypeLabel.right;
        _pubTypeLabel.hidden = NO;
    } else {
        
        _pubTypeLabel.hidden = YES;
    }
}

- (void)dealloc {
     //(_titleLabel);
    
}

#pragma mark - override 

- (void)setInfoObj:(SNLiveContentMatchInfoObject *)infoObj {
    //BOOL bInit = (_bannerVideoPlayer == nil);
    [super setInfoObj:infoObj];
    _titleLabel.text = self.infoObj.matchTitle;
//    if (bInit) {
//        CGRect _videoPlayerFrame    = CGRectMake(0,
//                                                 kTitleVideoPlayerTopMargin,
//                                                 self.width,
//                                                 kTitleVideoPlayerHeight);
//        _bannerVideoPlayer.frame = _videoPlayerFrame;
//    }
    
    [_liveStatusLabel sizeToFit];
    [self layoutStatusLabel];
}

- (CGFloat)viewExpandHeight {
    return kTitleViewHeight;
}

- (CGFloat)viewShrinkHeight {
    return kTitleViewHeight_S;
}

- (void)doExpandAnimation {
    [super doExpandAnimation];
    
    _titleLabel.frame = CGRectMake(kTitleSideMargin,
                                   kTitleTopMargin,
                                   self.width -  2 * kTitleSideMargin,
                                   kTitleFont + 1);
    
    _titleLabel.font = [UIFont boldSystemFontOfSize:kTitleFont];
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.numberOfLines = 1;
    
    _leftVerticleLine.frame = CGRectMake(0,
                                         _titleLabel.top - 2,
                                         _leftVerticleLine.width,
                                         _titleLabel.height + 4 + 17);
    
    [self layoutStatusLabel];
}

- (void)doShrinkAnimation {
    [super doShrinkAnimation];
    
    CGFloat titleWidth = self.width - kTitleSideMargin * 2 - _bannerVideoPlayer.width - 15;
    CGFloat titleHeight = [_titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:kTitleFontS]
                                       constrainedToSize:CGSizeMake(titleWidth, 10000)
                                           lineBreakMode:_titleLabel.lineBreakMode].height;
    CGRect titleRect = CGRectMake(0, 0, 100, _segmentView.top);
    CGFloat titleCenterY = CGRectGetMidY(titleRect);
    
    // title超过两行
    if (titleHeight > kTitleFont + 4)
        titleHeight = 50;

    _titleLabel.frame = CGRectMake(kTitleSideMargin,
                                   titleCenterY - titleHeight / 2,
                                   titleWidth,
                                   titleHeight);

    _titleLabel.font = [UIFont boldSystemFontOfSize:kTitleFontS];
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.numberOfLines = 2;
    
    _leftVerticleLine.frame = CGRectMake(0,
                                         titleCenterY - titleHeight / 2,
                                         _leftVerticleLine.width,
                                         titleHeight + 17);
    
    [self layoutStatusLabel];
}

- (CGRect)videoFrameForExpandMode {
    return CGRectMake(0,
                      kTitleVideoPlayerTopMargin,
                      self.width,
                      kTitleVideoPlayerHeight);
}

- (CGRect)videoFrameForShrinkMode {
    return CGRectMake(self.width - kTitleVideoPlayerSideMargin_S - kTitleVideoPlayerWidth_S,
                      kTitleVideoPlayerTopMargin_S,
                      kTitleVideoPlayerWidth_S,
                      kTitleVideoPlayerHeight_S);
}

- (void)expandBannerVideoPlayer {
    _bannerVideoPlayer.frame = [self videoFrameForExpandMode];
    _bannerVideoPlayer.defaultLogo.bounds = CGRectMake(0, 0, 140.0, 38.0);
    _bannerVideoPlayer.defaultLogo.center = CGPointMake(_bannerVideoPlayer.frame.size.width/2, _bannerVideoPlayer.frame.size.height/2);
    [SNVideoAdMaskHelper expandLiveBannerPlayerMask:_bannerVideoPlayer];
}

- (void)shrinkBannerVideoPlayer {
    _bannerVideoPlayer.frame = [self videoFrameForShrinkMode];
    _bannerVideoPlayer.defaultLogo.bounds = CGRectMake(0, 0, 111, 30);
    _bannerVideoPlayer.defaultLogo.center = CGPointMake(_bannerVideoPlayer.frame.size.width/2, _bannerVideoPlayer.frame.size.height/2);
    [SNVideoAdMaskHelper shrinkLiveBannerPlayerMask:_bannerVideoPlayer];
}

- (void)updateTheme {
    [super updateTheme];

    UIColor *titleColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameInfoTextColor]];
    
    _titleLabel.textColor = titleColor;
}

@end
