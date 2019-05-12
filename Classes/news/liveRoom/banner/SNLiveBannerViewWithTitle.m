//
//  SNLiveBannerViewWithTitle.m
//  sohunews
//
//  Created by wang yanchen on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveBannerViewWithTitle.h"
#import "UIColor+ColorUtils.h"
#import "SNSkinManager.h"

#define kLiveBannerViewTitleLeftMargin                          (22 / 2)
#define kLiveBannerViewTitleTopMargin                           (28 / 2 + kSystemBarHeight)
#define kLiveBannerViewTitleFontSize                            (40 / 2)

// live status
#define kLiveStatusFont             (18 / 2)
#define kLiveStatusBottomMargin     (14 / 2)
#define kLiveStatusLeftMargin       (338 / 2)
#define kLiveStatusTopMargin        5

#define kLiveBannerViewLeftVerticleLineWidth                (4)
#define kLiveBannerViewLeftVerticleLineHeight               (42)

@implementation SNLiveBannerViewWithTitle
@synthesize title = _title;
@synthesize liveStatusLabel = _liveStatusLabel;

- (id)initWithFrame:(CGRect)frame {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    frame = CGRectMake(0, 0, appFrame.size.width, (136 + 20)/2);
    self = [super initWithFrame:frame];
    if (self) {
        [SNNotificationManager addObserver:self selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
}

- (void)setInfoObj:(SNLiveContentMatchInfoObject *)infoObj {
    [super setInfoObj:infoObj];
    self.title = self.infoObj.matchTitle;
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title = [title copy];
    }
    
    [self initTitleLabel];
}

- (void)initTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLiveBannerViewTitleLeftMargin,
                                                                kLiveBannerViewTitleTopMargin,
                                                                self.width - kLiveBannerViewTitleLeftMargin * 2,
                                                                kLiveBannerViewTitleFontSize + 1)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:kLiveBannerViewTitleFontSize];
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
        
        UIColor *titleColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameInfoTextColor]];
        _titleLabel.textColor = titleColor;
    }
    
    if (![_titleLabel.text isEqualToString:_title]) {
        _leftVerticleLine.top = _titleLabel.top - 1;
        _titleLabel.text = _title;
        
        _titleLabel.numberOfLines = 2;
        [_titleLabel sizeToFit];
        self.height = _titleLabel.bottom + 35 + 10;
        
        _liveStatusLabel.top = _titleLabel.bottom + kLiveStatusTopMargin;
        _leftVerticleLine.height = _liveStatusLabel.bottom + 1 - _leftVerticleLine.top;
        
        _pubTypeLabel.top = _liveStatusLabel.top;
    }
}

- (void)initOnlineCountLabel {
    //[self initLiveStatusLabel];
}

- (void)initLiveStatusLabel {
    if (!_liveStatusLabel) {
        _liveStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLiveBannerViewTitleLeftMargin,
                                                                     _titleLabel.bottom + kLiveStatusTopMargin,
                                                                     self.width - kLiveBannerViewTitleLeftMargin*2,
                                                                     kLiveStatusFont + 1)];
        _liveStatusLabel.backgroundColor = [UIColor clearColor];
        _liveStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _liveStatusLabel.font = [UIFont systemFontOfSize:kLiveStatusFont];
        _liveStatusLabel.textAlignment = NSTextAlignmentLeft;
        _liveStatusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_liveStatusLabel];
        
        UIColor *onlineColor = [SNSkinManager color:SkinText4];
        _liveStatusLabel.textColor = onlineColor;
    }
    
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
        
        _liveStatusLabel.left = _pubTypeLabel.right;
        _pubTypeLabel.hidden = NO;
    } else {
        
        _liveStatusLabel.left = kLiveBannerViewTitleLeftMargin;
        _pubTypeLabel.hidden = YES;
    }
    
    _liveStatusLabel.text = [NSString stringWithFormat:@"%@人参与  %@",[SNUtility statisticsDataChangeType:self.onlineCount], self.liveStatus];
}

- (CGFloat)viewExpandHeight {
    return self.height;
}

- (CGFloat)viewShrinkHeight {
    return self.height;
}

- (void)updateTheme {
    [super updateTheme];
    //[self setNeedsDisplay];
    // todo
    NSString *titleColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameInfoTextColor];
    UIColor *titleColor = [UIColor colorFromString:titleColorStr];
    _titleLabel.textColor = titleColor;
    
    UIColor *onlineColor = [SNSkinManager color:SkinText4];
    _liveStatusLabel.textColor = onlineColor;
}

@end
