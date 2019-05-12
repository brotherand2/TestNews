//
//  SNLiveRoomContentVideoPlayerView.h
//  sohunews
//
//  Created by handy wang on 3/20/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "WSMVVideoPlayerView.h"

@interface SNLiveRoomContentVideoPlayerView : WSMVVideoPlayerView
@end

@protocol SNLiveRoomContentVideoPlayerViewDelegate
- (void)didStopVideoAfterExitFullScreen;
@end