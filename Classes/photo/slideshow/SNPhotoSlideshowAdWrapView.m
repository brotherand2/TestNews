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

- (id)initWithAdView:(UIView *)adView {
    self = [self initWithFrame:adView.frame];
    if (self) {
        self.adView = adView;
    }
    return self;
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
        TT_RELEASE_SAFELY(_adView);
        _adView = [adView retain];
        
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
    TT_RELEASE_SAFELY(_adView);
    [super dealloc];
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
