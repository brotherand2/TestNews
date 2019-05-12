//
//  SNPhotoGalleryPlainSlideshowController.h
//  sohunews
//
//  Created by Cong Dan on 5/14/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNPhotoSlideshow.h"
#import "SNViewController.h"
#import "SNGroupPicturesSlideshowContainerViewController.h"

//不带动画的幻灯片模式
@interface SNPhotoGalleryPlainSlideshowController : SNViewController <SNGroupPicturesSlideshowContainerViewControllerDelegate>
{
    SNPhotoSlideshow *_gallery;
    SNGroupPicturesSlideshowContainerViewController *_groupPicturesSlideshowContainerViewController;
    NSString *currentNewsId;
    
    BOOL _loadFromRecommend;
    BOOL _firstLoadFromRecommend;
    
    int _index;
    UIImageView *_logo;
    
    NSMutableArray *allItems;
    
    MYFAVOURITE_REFER _myFavouriteRefer;
    
    NSString *_pubDate;
    
    GallerySourceType _gallerySourceType;
    
    GalleryTargetType _galleryTargetType;
    
    BOOL _isFullscreenMode;
    
    BOOL _isOnlineMode;
    
    BOOL _isViewReleased;
    
    NSMutableArray *recommendIds;
    BOOL _firstTimeFinishLoad;
}

@property(nonatomic, weak)id delegateController;
@property(nonatomic, strong)SNPhotoSlideshow *gallery;
@property(nonatomic, copy)NSString *currentNewsId;
@property(nonatomic,strong)NSMutableArray *allItems;
@property(nonatomic, copy)NSString *termId;
@property(nonatomic, strong) NSDictionary *queryDic;
@property (nonatomic, strong)SNGroupPicturesSlideshowContainerViewController *groupPicturesSlideshowContainerViewController;

@end
