//
//  WSMVVideoPlayerViewObserver.m
//  WeSee
//
//  Created by handy wang on 8/14/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoPlayerViewObserver.h"
#import "WSMVVideoPlayerView.h"

/*NSString *NSStringFromMovieLoadState(SHMovieLoadState loadState) {
    switch (loadState) {
        case SHMovieLoadStateUnknown: {//0
            return @"SHMovieLoadStateUnknown";
        }
        case SHMovieLoadStatePlayable: {//1
            return @"SHMovieLoadStatePlayable";
        }
        case SHMovieLoadStatePlaythroughOK: {//2
            return @"SHMovieLoadStatePlaythroughOK";
        }
        case (SHMovieLoadStatePlayable|SHMovieLoadStatePlaythroughOK): {//3
            return @"SHMovieLoadStatePlayable|SHMovieLoadStatePlaythroughOK";
        }
        case SHMovieLoadStateStalled: {//4
            return @"SHMovieLoadStateStalled";
        }
        case (SHMovieLoadStatePlayable|SHMovieLoadStateStalled): {//5
            return @"SHMovieLoadStatePlayable|SHMovieLoadStateStalled";
        }
        default: {
            return nil;
        }
    }
}*/

NSString *NSStringFromMoviePlaybackState(SHMoviePlayState playbackState) {
    switch (playbackState) {
        case SHMoviePlayStateStopped: {
            return @"SHMoviePlayStateStopped";
            break;
        }
        case SHMoviePlayStatePlaying: {
            return @"SHMoviePlayStatePlaying";
            break;
        }
        case SHMoviePlayStatePaused: {
            return @"SHMoviePlayStatePaused";
            break;
        }
        case SHMoviePlayStateInterrupted: {
            return @"SHMoviePlayStateInterrupted";
            break;
        }
        case SHMoviePlayStateSeekingForward: {
            return @"SHMoviePlayStateSeekingForward";
            break;
        }
        case SHMoviePlayStateSeekingBackward: {
            return @"SHMoviePlayStateSeekingBackward";
            break;
        }
        default: {
            return nil;
            break;
        }
    }
}
//====================================================================
//====================================================================
//====================================================================

@implementation WSMVVideoPlayerViewObserver

#pragma mark - SHMoviePlayerControllerDelegate - 广告相关
/**
 *  将要进入广告播放器，开始请求广告地址
 */
- (void)playerEnterAdvertMode {
    NSLogWarning(@"===Requesting ad url ...");
    if ([_delegate respondsToSelector:@selector(adDidLoading)]) {
        [_delegate adDidLoading];
    }
}

/**
 *  当前播放广告详细信息回调
 */
- (void)playerPlayAdvertWithInfo:(id)advertInfo {
    if ([_delegate respondsToSelector:@selector(didGetAdInfo:)]) {
        [_delegate didGetAdInfo:advertInfo];
    }
}
    
/**
 *  广告地址请求完成，开始加载广告
 */
- (void)advertPlayerPreparing {
    NSLogWarning(@"===Loading ad with ad url ...");
}

/**
 *  广告加载完成，开始播放
 */
- (void)advertPlayerPrepared { 
    NSLogWarning(@"===Playing ad ...");
    if ([_delegate respondsToSelector:@selector(adDidPlay)]) {
        [_delegate adDidPlay];
    }
}

/**
 *  广告播放完成，退出广告播放器
 */
- (void)playerExitAdvertMode {
    NSLogWarning(@"===Finish playing ad ...");
    if ([_delegate respondsToSelector:@selector(adDidFinishPlaying)]) {
        [_delegate adDidFinishPlaying];
    }
}

/**
 *  广告播放发生错误。此方法被调到时，playerExitAdvertMode方法不会被回调
 */
- (void)playerPlayAdvertError {
    NSLogWarning(@"===Failed to play ad ...");
    if ([_delegate respondsToSelector:@selector(adDidPlayWithError)]) {
        [_delegate adDidPlayWithError];
    }
}

#pragma mark - SHMoviePlayerControllerDelegate - 播放相关
/**
 *  正常缓存，该函数对应的缓冲包括：首次加载缓冲、前后拖动进度引起的缓存
 *
 */
- (void)playbackPreparing {
    NSLogWarning(@"===Preparing video......");
    if ([_delegate respondsToSelector:@selector(videoIsLoading)]) {
        [_delegate videoIsLoading];
    }
}

/**
 *  视频加载第一针请求时长
 */
- (void)playerLoadDuration:(NSTimeInterval)loadDuration success:(BOOL)success {
    NSLogWarning(@"===playerLoadDuration:success...");
    if ([_delegate respondsToSelector:@selector(didFinishFirstFrameLoadOnMilliseconds:success:)]) {
        [_delegate didFinishFirstFrameLoadOnMilliseconds:loadDuration success:success];
    }
}

/**
 *  等同系统播放器MPMovieDurationAvailableNotification通知，
 *  获取视频时长
 */
- (void)playbackDurationAvailable {
    NSLogWarning(@"===Duration had been available...");
    if ([_delegate respondsToSelector:@selector(videoPlaybackDurationAvailable)]) {
        [_delegate videoPlaybackDurationAvailable];
    }
}
    
/**
 *  缓冲结束（正常缓冲和卡顿缓冲），准备开始播放
 */
- (void)playbackPrepared {
//    NSLogWarning(@"===Had prepared to play and will begin playing...");
//    if ([_delegate respondsToSelector:@selector(videoDidPlay)]) {
//        [_delegate videoDidPlay];
//    }
}

/**
 *  播放开始
 */
- (void)playbackStart {
    NSLogWarning(@"===Had start playing...");
    if ([_delegate respondsToSelector:@selector(videoDidPlay)]) {
        [_delegate videoDidPlay];
    }
}

/**
 *  卡顿，播放过程中因网络或播放源引起的卡顿，不包括首次加载缓冲、前后拖动进度引起的缓冲
 */
- (void)playbackStalling {
    NSLogWarning(@"===Had stalled...");
    if ([_delegate respondsToSelector:@selector(videoDidStall)]) {
        [_delegate videoDidStall];
    }
}

/**
 *  播放暂停
 */
- (void)playbackPause {
    NSLogWarning(@"===Had paused playing...");
        if ([_delegate respondsToSelector:@selector(videoDidPause)]) {
            [_delegate videoDidPause];
        }
}

/**
 *  播放停止
 */
- (void)playbackStop {
    NSLogWarning(@"===Had stop playing...");
    if ([_delegate respondsToSelector:@selector(videoDidStop)]) {
        [_delegate videoDidStop];
    }
}

/**
 *  播放中断
 */
- (void)playbackInterrupted {
        //TODO:这个状态什么意思？
//        if ([_delegate respondsToSelector:@selector(videDidInterrupted)]) {
//            [_delegate videDidInterrupted];
//        }
        }

/**
 *  前/后拖动进度条
 */
- (void)playbackSeekingForward {
    NSLogWarning(@"===Had forward playing...");
        if ([_delegate respondsToSelector:@selector(videoDidSeekForward)]) {
            [_delegate videoDidSeekForward];
        }
}

- (void)playbackSeekingBackward {
    NSLogWarning(@"===Had backward playing...");
        if ([_delegate respondsToSelector:@selector(videoDidSeekBackward)]) {
            [_delegate videoDidSeekBackward];
        }
    }

/**
 *  播放失败
 *
 *  @param error 错误信息
 */
- (void)playerPlayError:(SHMoviePlayErrorType)errorType {
    NSLogWarning(@"===Had occured error while playing: %d", errorType);
    if ([_delegate respondsToSelector:@selector(videoDidFinishByPlaybackError)]) {
        [_delegate videoDidFinishByPlaybackError];
    }
}

- (BOOL)playerbackRequestError:(NSDictionary *)errorInfo {
    //_delegate 是 SNH5NewsVideoPlayer   WSMVVideoPlayerView的子类
    return YES;//@qz 下期再上
    if (!errorInfo) {
        return YES;
    }
    
    if ([_delegate isKindOfClass:[WSMVVideoPlayerView class]]) {
        if ([(WSMVVideoPlayerView*)_delegate checkIfNeccessaryToRetry]) {
            if ([_delegate respondsToSelector:@selector(playbackRequestErrorCallBack:)]) {
                [_delegate playbackRequestErrorCallBack:errorInfo];
                return NO;
            }
        }
    }
    return YES;
}

/**
 *  播放器对播放用户定制的视频相关回调函数
 *  若果只有一个定制播放视频将不会调用这个函数，直接回调playerPlaybackComplete函数
 */
- (void)playerPlaybackFinish:(NSInteger)playIndex {
    //因为搜狐新闻用SDK播视频时是一个一个的给SDK播放的，所以这个回调方法用不到。
}
    
/**
 *  所有定制视频播放完成回调函数
 */
- (void)playerPlaybackComplete {
    NSLogWarning(@"===Had complete playing...");
                        if ([_delegate respondsToSelector:@selector(videoDidFinishByPlaybackEnd)]) {
                            [_delegate videoDidFinishByPlaybackEnd];
                        }
                    }

/**
 *  点击系统播放器完成按钮触发
 */
- (void)playerPlaybackFinishByUserExited {
    NSLogWarning(@"===Had finish playing by user exited...");
                        if ([_delegate respondsToSelector:@selector(videoDidFinishByUserExited)]) {
                            [_delegate videoDidFinishByUserExited];
                        }
}

#pragma mark - Observe current playbacktime
- (void)playbackTimeDidChanged {
    if ([_delegate respondsToSelector:@selector(playbackTimeDidChanged)]) {
        [_delegate playbackTimeDidChanged];
    }
}

@end
