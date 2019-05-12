//
//  SNPhotoSlideshowRecommendView.h
//  sohunews
//
//  Created by Dan on 12/31/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNAdDataCarrier.h"
#import "SNPhotoSlideshow.h"
#import "SNPhotoSlideshowView.h"

@protocol SNPhotoSlideshowRecommendViewDelegate;

@interface SNPhotoSlideshowRecommendView : SNPhotoSlideshowView
{
    NSArray *moreRecommends;
    id<SNPhotoSlideshowRecommendViewDelegate> __weak _recommendDelegate;
    NSMutableArray *_imageViews;
    UIImageView *_arrow;
    
    BOOL  hasNextGroup;
}

@property(nonatomic, strong)NSArray *moreRecommends;
@property(nonatomic, weak)id<SNPhotoSlideshowRecommendViewDelegate> recommendDelegate;
@property(nonatomic, readwrite)BOOL  hasNextGroup;
@property(nonatomic, strong) SNAdDataCarrier *ad12238;  // 最后一个广告位
@property(nonatomic, strong) SNAdDataCarrier *ad13371;  // 倒数第二个广告位
@property(nonatomic, copy) NSString *newsId;

- (id)initWithRecommends:(NSArray *)recommends 
                delegate:(id<SNPhotoSlideshowRecommendViewDelegate>)delegate
            hasNextGroup:(BOOL)ishasNextGroup
           adDataCarrier:(SNAdDataCarrier *)ad12238 // 最后一格的广告位
                 ad13371:(SNAdDataCarrier *)ad13371;

- (void)loadImageWithAdDataCarrier:(SNAdDataCarrier *)adDataCarrier ad13371:(SNAdDataCarrier *)ad13371;
- (void)reportBusinessStatisticsInfo;
- (void)reportAdDisplay;
@end


@protocol SNPhotoSlideshowRecommendViewDelegate <NSObject>

- (void)photoDidRecommendAtNewsId:(NSString *)newsId;
- (void)closeGalleryBroswer;
@end
