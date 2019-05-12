//
//  SNPhotoSlideshowAdWrapView.m
//  sohunews
//
//  Created by jojo on 13-12-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotoSlideshowAdWrapView.h"

@implementation SNPhotoSlideshowAdWrapView

@synthesize adView = _adView;
@synthesize viewDelegate;

- (id)initWithAdView:(UIView *)adView {
    self = [self initWithFrame:adView.frame];
    if (self) {
        self.adView = adView;
        [self.adView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClicked)]];
    }
    return self;
}

- (void)onClicked
{    
    [self.viewDelegate adDidClicked:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAdView:(UIView *)adView {
    if (_adView != adView) {
        [_adView removeFromSuperview];
         //(_adView);
        _adView = adView;
        
        if (_adView) {
            [self addSubview:_adView];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.adView.frame = self.bounds;
}

- (void)dealloc {
     //(_adView);
}

- (void)loadImage {
    // render ad image
    // do nothing
}

- (void)showStatus:(NSString*)text {
    //do nothing, don't show
}

- (void)showProgress:(CGFloat)progress {
    //do nothing, don't show
}

@end
