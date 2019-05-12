//
//  SNNewsGallerySlidershowController.h
//  sohunews
//
//  Created by qi pei on 5/31/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPhotoSlideshow.h"
#import "SNPicturesSlideshowViewController.h"
#import "SNViewController.h"
#import "SNWebImageView.h"
#import "SNAdvertiseManager.h"

@protocol SNNewsGallerySlidershowControllerDelegate <NSObject>

-(void)sliderShowDidClose;
-(void)sliderShowDidShow;
- (void)sliderShowWillShare:(int)index;
- (void)sliderShowWantToShowCommentList;
- (NSString *)sliderShowWantsCommentNum;
- (CGRect)rectForImageUrl:(NSString *)url;
- (void)showImageForUrl:(NSString *)url;
- (void)hiddenImageForUrl:(NSString *)url;


@end

@interface SNNewsGallerySlidershowController : SNViewController<SNPicturesSlideshowViewControllerDelegate> {
    SNPhotoSlideshow                *gallery;
    int                             beginIndex;
    SNPicturesSlideshowViewController       *sliderShowController;
    id<SNNewsGallerySlidershowControllerDelegate>  delegate;
    NSString                        *newsId;
    SNWebImageView                  *transitionView;
    BOOL                             alphaAnimate;
}
@property(nonatomic, retain)SNPhotoSlideshow *gallery;
@property(nonatomic, readwrite)int beginIndex;
@property(nonatomic, retain)SNPicturesSlideshowViewController *sliderShowController;
@property(nonatomic, assign)id<SNNewsGallerySlidershowControllerDelegate>  delegate;
@property(nonatomic, copy)NSString *newsId;
@property(nonatomic, retain) SNAdDataCarrier *sdkAdDataLastPic;

- (id)initWithGallery:(SNPhotoSlideshow *)ds;

- (BOOL)showPhotoByIndex:(int)index
                  inView:(UIView *)aView
                  newsId:(NSString *)aNewsId
                    from:(CGRect)rect;
@end
