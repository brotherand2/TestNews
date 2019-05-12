//
//  SNPhotoSlideshowAdWrapView.h
//  sohunews
//
//  Created by jojo on 13-12-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotoSlideshowView.h"
#import "SNStatClickInfo.h"

@class SNPhotoSlideshowAdWrapView;

@protocol PhotoSlideShowAdWrapViewDelegate <NSObject>

- (void)adDidClicked:(SNPhotoSlideshowAdWrapView *)adWrapView;

@end

@interface SNPhotoSlideshowAdWrapView : SNPhotoSlideshowView

@property (nonatomic, strong) UIView *adView;
@property (nonatomic, weak) id<PhotoSlideShowAdWrapViewDelegate> viewDelegate;

- (id)initWithAdView:(UIView *)adView;

@end
