//
//  SNLiveRoomBannerVideoPlayerView.h
//  sohunews
//
//  Created by handy wang on 3/19/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "WSMVVideoPlayerView.h"

@interface SNLiveRoomBannerVideoPlayerView : WSMVVideoPlayerView
@property(nonatomic, assign) BOOL canPlayByNotification;

- (void)removeControlBarTemporarily;
- (void)addControlBarTemporarily;
- (void)updateVideoModelIfChanged:(SNVideoData *)videoData;

- (void)tapBannerViewToPlay;
- (void)tapBannerViewToPause;

@end