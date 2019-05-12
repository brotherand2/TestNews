//
//  SNLiveBannerView.h
//  sohunews
//
//  Created by wang yanchen on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLiveBannerSegmentView.h"
#import "SNLiveContentObjects.h"
#import "SNAdvertiseManager.h"

static NSString * const kPubTypeName = @"独家";

@interface SNLiveBannerView : UIView {
    id __weak _delegate;
    BOOL _isAnimating;
    
    SNLiveBannerSegmentView *_segmentView;
    UIView *_leftVerticleLine;
}

@property(nonatomic, weak) id delegate;

/* data source */
@property(nonatomic, assign) BOOL hasExpandButton;
@property(nonatomic, strong) NSArray *sectionTitleArray;
@property(nonatomic, strong) SNLiveContentMatchInfoObject *infoObj;

// Unified
@property(nonatomic, assign) BOOL hasLeftVerticleLine;
@property(nonatomic, copy) NSString *onlineCount; // "10000人参与"
@property(nonatomic, copy) NSString *liveStatus; // 直播中 已结束 未开始等

// segment
@property(nonatomic, assign) int currentIndex;

@property(nonatomic, assign) BOOL isVisible;

@property(nonatomic, assign) BOOL hasExpanded;

// 4.3
@property(nonatomic, assign) BOOL isWorldCup;
@property(nonatomic, strong) UIImageView *backgroundImageView;

//5.0
@property(nonatomic, weak) SNAdDataCarrier *adDataSponsorShip;
@property (nonatomic, strong)SNWebImageView *adSponsorShipView;

- (void)segmentViewWillExpand;
- (void)segmentViewWillShrink;

- (void)showPopNewMark:(BOOL) show atIndex:(int)index;
- (BOOL)hasNewMarkAtIndex:(int)index;
- (BOOL)hasVideo;

// for animation
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

// for override
- (void)initOnlineCountLabel;
- (void)initLiveStatusLabel;

- (CGFloat)viewExpandHeight;
- (CGFloat)viewShrinkHeight;

- (void)doExpandAnimation;
- (void)doShrinkAnimation;

- (void)updateTheme;
- (void)createSubviews;

// for video
@property(nonatomic, assign) BOOL isStoppedByForce;
- (void)playVideo;
- (void)stopVideo;
- (void)pauseVideo;
- (void)resumeVideo;

@end


@protocol SNLiveBannerViewDelegate <NSObject>

@optional
- (void)bannerIndexDidChanged:(int)newIndex;
- (void)bannerIndexDidSelected:(int)selectIndex;

- (void)bannerWillExpand;
- (void)bannerWillShrink;

- (void)bannerTappedHostIcon;
- (void)bannerTappedVisitIcon;
- (void)bannerTappedHostUp;
- (void)bannerTappedVisitUp;

// for video
- (BOOL)shouldStartVideo;
- (void)bannerVideoDidStart;
- (void)bannerVideoDidStop;

@end
