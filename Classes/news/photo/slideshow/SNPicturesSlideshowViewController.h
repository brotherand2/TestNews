//
//  SNPicturesSlideshowViewController.h
//  sohunews
//
//  Created by Gao Yongyue on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

@class SNPhotoSlideshow;

@protocol SNPicturesSlideshowViewControllerDelegate <NSObject>
- (void)photoViewDidClose;
- (void)photoViewWillShare:(int)index;
- (void)photoViewWantShowCommentList;
- (NSString *)photoViewWantsCommentNumber;
- (void)photoViewComment;
@end

/*
 SNPicturesSlideshowViewController是显示图文新闻图片大图的ViewController
 */
@interface SNPicturesSlideshowViewController : UIViewController

@property (nonatomic, assign)int slideshowIndex;                                     //当前的index
@property (nonatomic, weak)id<SNPicturesSlideshowViewControllerDelegate> delegate;
@property (nonatomic, strong)SNPhotoSlideshow *slideshows;                           //新闻信息（图片信息，newsid等）

- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow;
- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow index:(int)index;

@end
