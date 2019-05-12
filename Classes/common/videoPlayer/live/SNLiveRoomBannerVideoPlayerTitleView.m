//
//  SNLiveRoomBannerVideoPlayerTitleView.m
//  sohunews
//
//  Created by handy wang on 3/24/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNLiveRoomBannerVideoPlayerTitleView.h"

static const CGFloat kHeadlineMarginLeftAndRight = 20.0f/2.0f;
#define kHeadlineTitleWidth_NonFullScreen                   (self.width-2*kHeadlineMarginLeftAndRight)
#define kHeadlineTitleWidth_FullScreen                      (self.width-2*kHeadlineMarginLeftAndRight)

@implementation SNLiveRoomBannerVideoPlayerTitleView

- (id)initWithFrame:(CGRect)frame delegate:(id)delegateParam {
    if (self = [super initWithFrame:frame delegate:delegateParam]) {
        self.headlineLabel.hidden = YES;
        self.headlineLabel.textAlignment = NSTextAlignmentCenter;
        self.headlineLabel.width = kHeadlineTitleWidth_FullScreen;
        
        [self.subtitleLabel removeFromSuperview];
        self.subtitleLabel = nil;
    }
    return self;
}

- (void)updateViewsInFullScreenMode {
    [super updateViewsInFullScreenMode];
    self.headlineLabel.hidden = NO;
    self.headlineLabel.width = kHeadlineTitleWidth_FullScreen;
}

- (void)updateViewsInNonScreenMode {
    [super updateViewsInNonScreenMode];
    self.headlineLabel.hidden = YES;
    self.headlineLabel.width = kHeadlineTitleWidth_NonFullScreen;
}

@end