//
//  FGalleryPhotoView.h
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OLImageView.h"
#import "SNTripletsLoadingView.h"

@protocol FGalleryPhotoViewDelegate;

//@interface FGalleryPhotoView : UIImageView {
@interface FGalleryPhotoView : UIScrollView <UIScrollViewDelegate> {
	BOOL _isZoomed;
	NSTimer *_tapTimer;
}

- (void)killActivityIndicator;

// inits this view to have a button over the image
- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

- (void)resetZoom;

@property (nonatomic,weak) NSObject <FGalleryPhotoViewDelegate> *photoDelegate;
@property (nonatomic,readonly) OLImageView *imageView;
@property (nonatomic,readonly) UIButton *button;
@property (nonatomic,strong) UILabel *progressLabel;
@property (nonatomic,readonly) SNTripletsLoadingView *activity;

- (void)changeImageViewFrame;
- (void)resetImageScale;

@end



@protocol FGalleryPhotoViewDelegate

// indicates single touch and allows controller repsond and go toggle fullscreen
- (void)didTapPhotoView:(FGalleryPhotoView*)photoView;

@end

