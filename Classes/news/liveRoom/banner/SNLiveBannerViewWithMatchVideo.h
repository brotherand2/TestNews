//
//  SNLiveBannerViewWithMatchVideo.h
//  sohunews
//
//  Created by wang yanchen on 13-5-3.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SNLiveBannerView.h"
#import "SNLiveRoomBannerVideoPlayerView.h"

@interface SNLiveBannerViewWithMatchVideo : SNLiveBannerView<UIGestureRecognizerDelegate, SNActionSheetDelegate> {
    SNLiveRoomBannerVideoPlayerView *_bannerVideoPlayer;
    
    UIImageView *_bottomShadowView;
    UILabel *_scoreDotsLabel;
    
    UILabel *_vsLabel;
    UILabel *_liveStatusLabel;
    UILabel *_pubTypeLabel;
    
    UILabel *_hostTeamName;
    UILabel *_hostScore;
    UIView *_hostUpView;
    UILabel *_hostUpLabel;
    
    UILabel *_visitTeamName;
    UILabel *_visitScore;
    UIView *_visitUpView;
    UILabel *_visitUpLabel;
}

- (id)initWithMode:(BOOL)bShrinkMode;

- (SNLiveRoomBannerVideoPlayerView *)getBannerVideoPlayer;

@end
