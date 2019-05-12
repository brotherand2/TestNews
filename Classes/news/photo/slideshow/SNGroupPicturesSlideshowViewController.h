//
//  SNGroupPicturesSlideshowViewController.h
//  sohunews
//
//  Created by Gao Yongyue on 14-2-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNMyFavourite.h"
#import "SNPhotoSlideshowAdWrapView.h"
#import "SNCommentEditorViewController.h"

@class SNPhotoSlideshow;
@class SNSlideshowView;

@protocol SNGroupPicturesSlideshowViewControllerDelegate <NSObject>
- (void)photoDidMoveToIndex:(NSInteger)index slideshow:(SNPhotoSlideshow *)slideshow;
- (BOOL)hasNextGroupWithCurrentSlideshow:(SNPhotoSlideshow *)slideshow;
- (void)reloadSlideshowInfo:(SNPhotoSlideshow *)slideshowData;

@optional
- (void)updateCommentCount:(NSString *)commentCount slideshow:(SNPhotoSlideshow *)slideshow;

@end

/*
 SNGroupPicturesSlideshowViewController:一组组图的大图（slideshow幻灯片）
 */
@interface SNGroupPicturesSlideshowViewController : UIViewController<PhotoSlideShowAdWrapViewDelegate>

@property (nonatomic, assign)NSInteger slideshowIndex;                                     //当前的index
@property (nonatomic, weak)id<SNGroupPicturesSlideshowViewControllerDelegate> delegate;
@property (nonatomic, strong)SNPhotoSlideshow *slideshows;                           //新闻信息（图片信息，newsid等）
@property (nonatomic, assign)BOOL isHideHeaderAndFooter;                           //是否显示header和footer，连续阅读图片的时候会用到
@property (nonatomic, assign)MYFAVOURITE_REFER myFavouriteRefer;
@property (nonatomic, strong) SNCommentEditorViewController *commentEditorViewController;

- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow;
- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow index:(int)index;
- (BOOL)isRecommendView;  //是否是推荐页
- (BOOL)isAdView;
- (void)loadPlaceholderView:(SNPhotoSlideshow *)slideshow;
- (void)reloadViewsWithPictures:(SNPhotoSlideshow *)slideshow index:(NSInteger)index isRecommendView:(BOOL)isRecommendView;
- (UIImage *)currentImage; //除了广告和推荐
- (NSString *)commentNumber;
- (void)prepareForReuse;
- (void)setSlideshowViewZoom;
- (void)displayCurrentSlideshowView;
- (void)showEmbededActivityIndicator;
- (void)hideEmbededActivityIndicator;

//- (void)showCommentListAction;
- (void)commentAction;
- (void)shareAction;
- (void)downloadAction;
@end
