//
//  WSMVVideoPlayerViewObserver.h
//  WeSee
//
//  Created by handy wang on 8/14/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVVideoForNews/SVVideoForNews.h>
#import "WSMVConst.h"

//FOUNDATION_EXPORT NSString *NSStringFromMovieLoadState(SHMovieLoadState loadState);
FOUNDATION_EXPORT NSString *NSStringFromMoviePlaybackState(SHMoviePlayState playbackState);

@interface WSMVVideoPlayerViewObserver : NSObject<SHMoviePlayerControllerDelegate>
@property (nonatomic, weak)id delegate;

- (void)playbackTimeDidChanged;
@end

@protocol WSMVVideoPlayerViewObserverDelegate
- (void)adDidLoading;
- (void)adDidPlay;
- (void)adDidPlayWithError;
- (void)adDidFinishPlaying;
- (void)didGetAdInfo:(id)adInfo;

- (void)didFinishFirstFrameLoadOnMilliseconds:(NSTimeInterval)milliseconds success:(BOOL)success;
- (void)videoPlaybackDurationAvailable;
- (void)videoIsLoading;
- (void)videoDidPlay;
- (void)videoDidSeekForward;
- (void)videoDidSeekBackward;
- (void)videoDidStall;
- (void)videoDidPause;
- (void)videoDidStop;
- (void)videDidInterrupted;
- (void)videoDidFinishByPlaybackEnd;
- (void)videoDidFinishByPlaybackError;
- (void)videoDidFinishByUserExited;
- (void)playbackRequestErrorCallBack:(NSDictionary *)errorInfo;
- (void)playbackTimeDidChanged;
@end
