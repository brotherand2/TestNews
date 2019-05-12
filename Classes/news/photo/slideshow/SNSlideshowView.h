//
//  SNSlideshowView.h
//  sohunews
//
//  Created by Gao Yongyue on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTripletsLoadingView.h"
#import "SNAdDataCarrier.h"

@class SNPhoto;

@protocol SNSlideshowViewDelegate <NSObject>
- (void)didTapRetry;
@end

/*
 SNSlideshowView是图文图片中展现的大图幻灯片单个图片的View
 */
@interface SNSlideshowView : UIView<SNTripletsLoadingViewDelegate>

@property (nonatomic, strong)SNPhoto *picture;
@property (nonatomic, strong)UIImage *adImage;
@property (nonatomic, assign)BOOL prepared;
@property (nonatomic, strong)SNAdDataCarrier *adDataCarrier;
@property (nonatomic, weak)id<SNSlideshowViewDelegate> delegate;

- (void)updateFrameWithFrame:(CGRect)frame;
- (void)loadImage;
- (void)prepareForReuse;
- (void)resetImageScale;
- (UIImage *)image;
- (void)setScrollViewZoom;
- (void)hideEmbededActivityIndicator;
- (void)showEmbededActivityIndicator;
@end
