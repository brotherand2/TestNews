//
//  SNPhotoGallerySlideshowController.h
//  sohunews
//
//  Created by Dan on 12/16/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPhotoSlideshow.h"
#import "SNRollingNewsModel.h"
#import "SNViewController.h"
#import "SNGroupPicturesSlideshowContainerViewController.h"

@protocol SNPhotoGallerySlideshowControllerDelegate;

//带动画的幻灯片模式
@interface SNPhotoGallerySlideshowController : SNViewController <SNGroupPicturesSlideshowContainerViewControllerDelegate>
{
    SNPhotoSlideshow *_gallery;
    SNGroupPicturesSlideshowContainerViewController *_groupPicturesSlideshowContainerViewController;
    
    id<SNPhotoGallerySlideshowControllerDelegate> __weak _delegate;
    
    UIView *_containerView;//用来遮挡裁剪后溢出的部分的容器
    UIView *_stageView;//动画的舞台
    
    NSInteger _index;
    
    CGRect _initImgRect;
    BOOL _loadFromRecommend;
    BOOL _loadFromAdjacentNews;
    
    NSString *currentNewsId;
    
    NSMutableArray *allItems;
    SNRollingNewsModel *_newsModel;
    
    MYFAVOURITE_REFER _myFavouriteReferInSlideShow;
    
    NSString *_pubDate;
    
    GallerySourceType _gallerySourceType;
    GalleryTargetType _galleryTargetType;

    BOOL firstTime;
    NSString *termId;
    
    NSMutableArray *recommendIds;
    BOOL _recommendsPhotos;
}

@property (nonatomic, strong) SNRollingNewsModel *newsModel;

@property(nonatomic, strong)SNPhotoSlideshow *gallery;
@property(nonatomic, weak)id<SNPhotoGallerySlideshowControllerDelegate> delegate;
@property(nonatomic, copy)NSString *currentNewsId;
@property(nonatomic,strong)NSMutableArray *allItems;

@property(nonatomic,readwrite)GallerySourceType gallerySourceType;

@property(nonatomic, assign)MYFAVOURITE_REFER myFavouriteReferInSlideShow;

@property(nonatomic, copy)NSString *pubDate;
@property(nonatomic, copy)NSString *termId;
@property(nonatomic, assign) BOOL supportContinuousReadingNext;

- (id)initWithGallery:(SNPhotoSlideshow *)gallery;
- (BOOL)showPhotoByIndex:(int)index fromRect:(CGRect)initRect inView:(UIView *)aView animated:(BOOL)animated;
- (void)refreshStatusbar;

- (void)refreshAd:(SNAdDataCarrier *)ad12238 ad13371:(SNAdDataCarrier *)ad13371 ad12233:(SNAdDataCarrier *)ad12233;

@end


@protocol SNPhotoGallerySlideshowControllerDelegate<NSObject>

@optional
- (void)slideshowWillShow:(SNPhotoGallerySlideshowController *)slideshowController;
- (void)slideshowDidShow:(SNPhotoGallerySlideshowController *)slideshowController;
- (void)slideshowDidChange:(SNPhotoGallerySlideshowController *)slideshowController termId:(NSString *)termId newsId:(NSString *)newsId slideToNextGroup:(BOOL)isNextGroup;
- (void)slideshowDidChange:(SNPhotoGallerySlideshowController *)slideshowController galleryId:(NSString *)gid;
- (void)slideshowDidChange:(SNPhotoGallerySlideshowController *)slideshowController photoIndex:(int)index;

- (CGRect)slideshowPhotoFrameShouldReturn:(SNPhotoGallerySlideshowController *)slideshowController photoIndex:(NSInteger)index;
- (void)slideshowWillDismiss:(SNPhotoGallerySlideshowController *)slideshowController;
- (void)slideshowDidDismiss:(SNPhotoGallerySlideshowController *)slideshowController;
- (void)slideshowDidTapRetry;
@end