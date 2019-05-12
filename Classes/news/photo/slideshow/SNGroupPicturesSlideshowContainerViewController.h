//
//  SNGroupPicturesSlideshowContainerViewController.h
//  sohunews
//
//  Created by Gao Yongyue on 14-2-14.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNMyFavourite.h"
@class SNPhotoSlideshow;
@class SNAdDataCarrier;

@protocol SNGroupPicturesSlideshowContainerViewControllerDelegate <NSObject>
@optional
- (void)photoViewDidClose;
- (void)photoDidMoveToIndex:(NSInteger)index;
- (void)slideshowDidChangeWithGalleryId:(NSString *)gid;
- (void)slideshowDidChangeWithTermId:(NSString *)termId newsId:(NSString *)newsId slideToNextGroup:(BOOL)isNextGroup;
- (void)slideshowDidTapRetry;
@end
/*
 SNGroupPicturesSlideshowContainerViewController:组图连续阅读的controller
 */
@interface SNGroupPicturesSlideshowContainerViewController : UIViewController

@property (nonatomic, strong)NSString *termId;
@property (nonatomic, strong)NSMutableArray *allItems;
@property (nonatomic, strong)SNPhotoSlideshow *currentSlideshows;
@property (nonatomic, assign)NSInteger currentSlideshowIndex; //当前组的图索引
@property (nonatomic, assign)MYFAVOURITE_REFER myFavouriteRefer;
@property (nonatomic, assign)GallerySourceType gallerySourceType;
@property (nonatomic, weak)id<SNGroupPicturesSlideshowContainerViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL supportContinuousReadingNext;

- (id)initWithCurrentSlideshows:(SNPhotoSlideshow *)slideshows index:(int)index delegate:(id<SNGroupPicturesSlideshowContainerViewControllerDelegate>)delegate;
- (BOOL)isRecommendViewOrAdView;  //是否是推荐页或者是广告页
- (NSInteger)currentSlideshowIndex;
- (UIImage *)currentImage;//除了广告和推荐的
- (void)refreshStatusbar;

- (void)refreshAd:(SNAdDataCarrier *)ad12238 ad13371:(SNAdDataCarrier *)ad13371 ad12233:(SNAdDataCarrier *)ad12233;


@end
