//
//  SNPhotoSlideshowAdWrapView.h
//  sohunews
//
//  Created by jojo on 13-12-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotoSlideshowView.h"

@interface SNPhotoSlideshowAdWrapView : SNPhotoSlideshowView
@property (nonatomic, retain) UIView *adView;

- (id)initWithAdView:(UIView *)adView;

@end
