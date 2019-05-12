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

@protocol SNGroupPicturesSlideshowContainerViewControllerDelegate <NSObject>
@optional
- (void)photoViewDidClose;
- (void)photoDidMoveToIndex:(int)index;
- (void)slideshowDidChangeWithGalleryId:(NSString *)gid;
- (void)slideshowDidChangeWithTermId:(NSString *)termId newsId:(NSString *)newsId;
@end
/*
 SNGroupPicturesSlideshowContainerViewController:组图连续阅读的controller
 */
@interface SNGroupPicturesSlideshowContainerViewController : UIViewController

@property (nonatomic, retain)NSString *termId;
@property (nonatomic, retain)NSMutableArray *allItems;
@property (nonatomic, retain)SNPhotoSlideshow *currentSlideshows;
@property (nonatomic, assign)int currentSlideshowIndex; //当前组的图索引
@property (nonatomic, assign)MYFAVOURITE_REFER myFavouriteRefer;
@property (nonatomic, assign)GallerySourceType gallerySourceType;
@property (nonatomic, assign)id<SNGroupPicturesSlideshowContainerViewControllerDelegate> delegate;

- (id)initWithCurrentSlideshows:(SNPhotoSlideshow *)slideshows index:(int)index delegate:(id<SNGroupPicturesSlideshowContainerViewControllerDelegate>)delegate;
- (BOOL)isRecommendViewOrAdView;  //是否是推荐页或者是广告页
- (int)currentSlideshowIndex;
- (UIImage *)currentImage;//除了广告和推荐的
@end
