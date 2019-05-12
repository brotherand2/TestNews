//
//  SNUserPortraitPlayer.h
//  sohunews
//
//  Created by wang shun on 2017/3/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "WSMVVideoPlayerView.h"
@interface SNUserPortraitPlayer : WSMVVideoPlayerView

@property (nonatomic,strong) NSDictionary* vplayer_info;

- initWithData:(NSDictionary*)data;

- (void)playUserPortraitVideo;

@end
