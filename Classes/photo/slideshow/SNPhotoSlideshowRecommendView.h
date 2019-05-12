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
    id<SNPhotoSlideshowRecommendViewDelegate> _recommendDelegate;
    NSMutableArray *_imageViews;
    UIImageView *_arrow;
    
    BOOL  hasNextGroup;
}

@property(nonatomic, retain)NSArray *moreRecommends;
@property(nonatomic, assign)id<SNPhotoSlideshowRecommendViewDelegate> recommendDelegate;
@property(nonatomic, readwrite)BOOL  hasNextGroup;
@property(nonatomic, retain) SNAdDataCarrier *sdkAdRecommend;

- (id)initWithRecommends:(NSArray *)recommends 
                delegate:(id<SNPhotoSlideshowRecommendViewDelegate>)delegate
            hasNextGroup:(BOOL)ishasNextGroup
           adDataCarrier:(SNAdDataCarrier *)adDataCarrier; // 最后一格的广告位

- (void)loadImageWithAdDataCarrier:(SNAdDataCarrier *)adDataCarrier;

@end


@protocol SNPhotoSlideshowRecommendViewDelegate <NSObject>

- (void)photoDidRecommendAtNewsId:(NSString *)newsId;

@end