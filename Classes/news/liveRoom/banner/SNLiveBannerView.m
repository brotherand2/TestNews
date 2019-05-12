//
//  SNLiveBannerView.m
//  sohunews
//
//  Created by wang yanchen on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveBannerView.h"
#import "UIColor+ColorUtils.h"
#import "NSDate-Utilities.h"
#import "SNLiveRoomConsts.h"

#define kLiveBannerViewLeftVerticleLineWidth                (4)
#define kLiveBannerViewLeftVerticleLineHeight               (42)

@implementation SNLiveBannerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.onlineCount = @"0";
        self.liveStatus = @"";
        self.hasExpanded = YES;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        [SNNotificationManager addObserver:self selector:@selector(stopVideo) name:kSNLiveBannerViewStopVideoNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(pauseVideo) name:kSNLiveBannerViewPauseVideoNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(resumeVideo) name:kSNLiveBannerViewResumeVideoNotification object:nil];
        
        _isVisible = YES;
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    if (_segmentView) {
        if (_hasExpandButton) {
            [_segmentView removeObserver:self forKeyPath:@"hasExpanded"];
        }
    }
    self.adDataSponsorShip.delegate = nil;
}

// override in subclasses
- (void)createSubviews {
}

- (void)setHasLeftVerticleLine:(BOOL)hasLeftVerticleLine {
    _hasLeftVerticleLine = hasLeftVerticleLine;
    if (_hasLeftVerticleLine) {
        if (!_leftVerticleLine) {
            _leftVerticleLine = [[UIView alloc] initWithFrame:CGRectZero];
            _leftVerticleLine.width = kLiveBannerViewLeftVerticleLineWidth;
            _leftVerticleLine.height = kLiveBannerViewLeftVerticleLineHeight;
            _leftVerticleLine.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kContentSolidColor]];
            _leftVerticleLine.centerY = CGRectGetMidY(self.bounds);
            [self addSubview:_leftVerticleLine];
        }
        _leftVerticleLine.hidden = NO;
    }
    else {
        _leftVerticleLine.hidden = YES;
    }
}

- (void)setOnlineCount:(NSString *)onlineCount {
    if (_onlineCount != onlineCount) {
        _onlineCount = [onlineCount copy];
    }
    
    [self initOnlineCountLabel];
}

- (void)setLiveStatus:(NSString *)liveStatus {
    if (_liveStatus != liveStatus) {
        _liveStatus = [liveStatus copy];
    }
    
    [self initLiveStatusLabel];
}

- (void)setCurrentIndex:(int)currentIndex{
    _currentIndex = currentIndex;
    if (_segmentView) {
        _segmentView.currentIndex = _currentIndex;
        [_segmentView resetBtnsState];
    }
}

- (void)setSectionTitleArray:(NSArray *)sectionTitleArray {
    if (_sectionTitleArray != sectionTitleArray) {
        _sectionTitleArray = sectionTitleArray;
    }
    if (!_segmentView) {
        _segmentView = [[SNLiveBannerSegmentView alloc] initWithFrame:CGRectZero];
        _segmentView.isWorldCup = self.isWorldCup;
        [_segmentView createWithSectionsArray:_sectionTitleArray hasExpandButton:_hasExpandButton isExpand:self.hasExpanded];
        _segmentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _segmentView.bottom = self.height;
        [_segmentView addTarget:self action:@selector(currentIndexChanged:) forControlEvents:UIControlEventValueChanged];
        [_segmentView addTarget:self action:@selector(currentIndexTouched:) forControlEvents:UIControlEventTouchUpInside];
        if (_hasExpandButton) {
            [_segmentView addObserver:self forKeyPath:@"hasExpanded" options:NSKeyValueObservingOptionNew context:NULL];
        }
        [self addSubview:_segmentView];
        [self bringSubviewToFront:_segmentView];
    }
}

- (void)currentIndexChanged:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerIndexDidChanged:)]) {
        [_delegate bannerIndexDidChanged:(int)_segmentView.currentIndex];
    }
}

- (void)currentIndexTouched:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerIndexDidSelected:)]) {
        [_delegate bannerIndexDidSelected:(int)_segmentView.currentIndex];
    }
}

- (void)showPopNewMark:(BOOL)show atIndex:(int)index {
    if (_segmentView)
        [_segmentView showPopNewMark:show atIndex:index];
}

- (BOOL)hasNewMarkAtIndex:(int)index {
    if (_segmentView)
        return [_segmentView hasNewMarkAtIndex:index];
    else
        return NO;
}

- (BOOL)hasVideo {
    return NO;
}

- (void)setInfoObj:(SNLiveContentMatchInfoObject *)infoObj {
    if (_infoObj != infoObj) {
        _infoObj = infoObj;
    }
    
    if (_infoObj.onlineCount.length > 0)
        self.onlineCount = _infoObj.onlineCount;
    else
        self.onlineCount = @"0";
    
    if ([_infoObj.liveStatus isKindOfClass:[NSString class]]) {
        if (_infoObj.liveStatus.length > 0) {
            switch ([_infoObj.liveStatus intValue]) {
                case WAITING_STATUS: {
                    self.liveStatus = [self formatLiveDateString];//@"未开始";
                }
                    break;
                case LIVING_STATUS:
                    self.liveStatus = @"直播中";
                    break;
                case END_STATUS:
                    self.liveStatus = @"已结束";
                    break;
                default:
                    self.liveStatus = @"";
                    break;
            }
        }
        else {
            self.liveStatus = @"";
        }
    }
}

#pragma mark - SNLiveBannerView publick callback

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_segmentView)
        [_segmentView scrollViewDidScroll:scrollView];
}

#pragma mark - override for subclass

- (void)initOnlineCountLabel {
    
}

- (void)initLiveStatusLabel {
    
}

- (NSString *)formatLiveDateString {
    /* 若开始时间为今天, 则显示即将开始时间,如17:30开始
     若开始时间为明天和后天,则显示:明天开始、后天开始
     若开始时间为后天之后,则显示:即将开始 */
    NSString *result;
    
    NSDate *liveDate = [NSDate dateWithTimeIntervalSince1970:[_infoObj.liveTime doubleValue]/1000];

    if ([liveDate isToday]) {
        result = [NSDate stringFromDate:liveDate withFormat:@"HH:mm"];
        result = [result stringByAppendingString:@"开始"];
    } else if ([liveDate isTomorrow]) {
        result = @"明天开始";
    } else if ([liveDate isEqualToDateIgnoringTime:[NSDate dateWithDaysFromNow:2]]) {
        result = @"后天开始";
    } else {
        result = @"即将开始";
    }
    return result;
}

- (CGFloat)viewExpandHeight {
    return self.height;
}

- (CGFloat)viewShrinkHeight {
    return self.height;
}

- (void)doExpandAnimation {
    _segmentView.bottom = self.height;

    _adSponsorShipView.top = _segmentView.top + 6;
}

- (void)doShrinkAnimation {
    _segmentView.bottom = self.height;
    
    _adSponsorShipView.top = _segmentView.top + 6;
}

- (void)segmentViewWillExpand {
}

- (void)segmentViewWillShrink {
}

- (void)updateTheme {
    if (_segmentView)
        [_segmentView updateTheme];
    
    if (_leftVerticleLine) {
        NSString *colorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kContentSolidColor];
        _leftVerticleLine.backgroundColor = [UIColor colorFromString:colorStr];
    }
}

- (void)playVideo {

}

- (void)stopVideo {

}

- (void)pauseVideo {

}

- (void)resumeVideo {
    
}

#pragma mark - advertisement
- (void)setAdDataSponsorShip:(SNAdDataCarrier *)adDataSponsorShip {
    
    if (_adDataSponsorShip != adDataSponsorShip) {
        _adDataSponsorShip = adDataSponsorShip;
    }
    
    if (!_adSponsorShipView) {
        _adSponsorShipView = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              kAdvertiseSponsorShipWidth, kAdvertiseLiveSponsorShipHeight)];
        _adSponsorShipView.backgroundColor = [UIColor clearColor];
        _adSponsorShipView.alpha = themeImageAlphaValue();
        [self addSubview:_adSponsorShipView];
    }
    _adSponsorShipView.right = self.width - HEAD_W;
    _adSponsorShipView.top = _segmentView.top + 6;
    
    UIImage *image = [self.adDataSponsorShip adImage];
    if (image && [image isKindOfClass:[UIImage class]]) {
        _adSponsorShipView.image = image;
        //加载冠名图成功，展示上报
        [adDataSponsorShip reportForDisplayTrack];
    }
    else {
        [_adSponsorShipView loadUrlPath:[self.adDataSponsorShip adImageUrl]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  [adDataSponsorShip reportForDisplayTrack];
                              }];
    }
}


#pragma mark - kvo support
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _segmentView && [keyPath isEqualToString:@"hasExpanded"]) {
        if (_segmentView.hasExpanded) {
            [self segmentViewWillExpand];
            
            if (!_isAnimating) {
                _isAnimating = YES;
                if (_delegate && [_delegate respondsToSelector:@selector(bannerWillExpand)]) {
                    [_delegate bannerWillExpand];
                }
                [UIView animateWithDuration:0.3 animations:^{
                    [self doExpandAnimation];
                } completion:^(BOOL finished) {
                    _isAnimating = NO;
                    self.hasExpanded = YES;
                }];
            }
        }
        else {
            [self segmentViewWillShrink];
            
            if (!_isAnimating) {
                _isAnimating = YES;
                if (_delegate && [_delegate respondsToSelector:@selector(bannerWillShrink)]) {
                    [_delegate bannerWillShrink];
                }
                [UIView animateWithDuration:0.3 animations:^{
                    [self doShrinkAnimation];
                } completion:^(BOOL finished) {
                    _isAnimating = NO;
                    self.hasExpanded = NO;
                }];
            }
        }
    }
}

@end
