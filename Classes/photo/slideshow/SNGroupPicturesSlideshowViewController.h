//
//  SNGroupPicturesSlideshowViewController.h
//  sohunews
//
//  Created by Gao Yongyue on 14-2-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNMyFavourite.h"
@class SNPhotoSlideshow;
@class SNSlideshowView;

@protocol SNGroupPicturesSlideshowViewControllerDelegate <NSObject>
- (void)photoDidMoveToIndex:(int)index slideshow:(SNPhotoSlideshow *)slideshow;
- (BOOL)hasNextGroupWithCurrentNewsID:(NSString *)newsID;
- (void)updateCommentCount:(NSString *)commentCount slideshow:(SNPhotoSlideshow *)slideshow;
- (void)reloadSlideshowInfo:(SNPhotoSlideshow *)slideshowData;
@end

/*
 SNGroupPicturesSlideshowViewController:一组组图的大图（slideshow幻灯片）
 */
@interface SNGroupPicturesSlideshowViewController : UIViewController

@property (nonatomic, assign)int slideshowIndex;                                     //当前的index
@property (nonatomic, assign)id<SNGroupPicturesSlideshowViewControllerDelegate> delegate;
@property (nonatomic, retain)SNPhotoSlideshow *slideshows;                           //新闻信息（图片信息，newsid等）
@property (nonatomic, assign)BOOL isHideHeaderAndFooter;                           //是否显示header和footer，连续阅读图片的时候会用到
@property (nonatomic, assign)MYFAVOURITE_REFER myFavouriteRefer;

- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow;
- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow index:(int)index;
- (BOOL)isRecommendView;  //是否是推荐页
- (BOOL)isAdView;
- (void)loadPlaceholderView:(SNPhotoSlideshow *)slideshow;
- (void)reloadViewsWithPictures:(SNPhotoSlideshow *)slideshow index:(int)index isRecommendView:(BOOL)isRecommendView;
- (UIImage *)currentImage; //除了广告和推荐
- (NSString *)commentNumber;
- (void)prepareForReuse;
- (void)setSlideshowViewZoom;
- (void)displayCurrentSlideshowView;
- (void)showEmbededActivityIndicator;
- (void)hideEmbededActivityIndicator;

- (void)showCommentListAction;
- (void)commentAction;
- (void)shareAction;
- (void)downloadAction;
@end
