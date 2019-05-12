//
//  WSMVVideoHelper.h
//  sohunews
//
//  Created by handy wang on 11/6/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNVideoData;
@class WSMVVideoPlayerView;

typedef enum {
    WSMV2G3GAlertStyle_None                     = -1,//不需要提示
    WSMV2G3GAlertStyle_NotReachable             = 0,//无网
    WSMV2G3GAlertStyle_Block                    = 1,//阻断式的提示
    WSMV2G3GAlertStyle_VideoPlayingToast        = 2,//正在2G/3G下播放视频的Toast提示
    WSMV2G3GAlertStyle_NetChangedTo2G3GToast    = 3,//视频播放时网络变换到2G/3G下的Toast提示
    WSMV2G3GAlertStyle_OfflinePlay              = 4//离线播放
} WSMV2G3GAlertStyle;

@interface WSMVVideoHelper : NSObject<SNActionSheetDelegate>
@property (nonatomic, assign)BOOL bContinueToPlayVideoIn2G3G;
@property (nonatomic, strong)NSMutableDictionary *hadEverAlert2G3GOfChannels;

#pragma mark - Lifecycle
+ (WSMVVideoHelper *)sharedInstance;

#pragma mark - Public
- (void)continueToPlayVideoIn2G3G;

#pragma mark - Can Download
- (BOOL)canDownload:(SNVideoData *)video userInfo:(NSDictionary *)userInfo;
- (BOOL)canDownload:(SNVideoData *)video withPlayerView:(WSMVVideoPlayerView *)playerView;
@end
