//
//  SNGalleryConst.h
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#ifndef SNGalleryConst_h
#define SNGalleryConst_h

static NSString * const SNGalleryPhotoCellReuseIdentifier = @"SNGalleryPhotoCell";
static NSString * const SNGalleryAdCellReuseIdentifier = @"SNGalleryAdCell";
static NSString * const SNGalleryRecommendCellReuseIdentifier = @"SNGalleryRecommendCell";

#import "SNGalleryPhotoCell.h"
#import "SNGalleryAdCell.h"
#import "SNGalleryRecommendCell.h"
#import "SNArticle.h"

typedef void(^GalleryDismissBlock)(UIImage*image, NSInteger index);


#define kPhotoCellDidZommingNotification            @"kPhotoCellDidZommingNotification"

#define kScreenRect                 [UIScreen mainScreen].bounds
#define kScreenWidth                [UIScreen mainScreen].bounds.size.width
#define kScreenHeight               [UIScreen mainScreen].bounds.size.height
#define kScreenRatio                kScreenWidth / kScreenHeight
#define kScreenMidX                 CGRectGetMaxX(kScreenRect)
#define kScreenMidY                 CGRectGetMaxY(kScreenRect)
#define kLeftOffset                (0)

#endif /* SNGalleryConst_h */
