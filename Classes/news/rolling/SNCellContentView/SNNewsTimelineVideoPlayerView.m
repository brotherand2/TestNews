//
//  SNNewsTimelineVideoPlayerView.m
//  sohunews
//
//  Created by lhp on 5/21/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNNewsTimelineVideoPlayerView.h"
#import "WSMVVideoStatisticManager.h"
#import "SNVideoBreakpointManager.h"

@interface SNNewsTimelineVideoPlayerView ()

@end

#define kNewsTimelinePlayerWidth        300
#define kNewsTimelinePlayerHeight       185

@implementation SNNewsTimelineVideoPlayerView

+ (SNNewsTimelineVideoPlayerView *)sharedInstance {
    static SNNewsTimelineVideoPlayerView *_sharedInstance = nil;
    @synchronized(self) {
        if (!_sharedInstance) {
            CGRect playerFrame = CGRectMake(0,
                                            0,
                                            kNewsTimelinePlayerWidth,
                                            kNewsTimelinePlayerHeight);
            _sharedInstance = [[SNNewsTimelineVideoPlayerView alloc] initWithFrame:playerFrame andDelegate:nil];
            _sharedInstance.isPlayingRecommendList = YES;
        }
    }
    return _sharedInstance;
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate
{
    self = [super initWithFrame:frame andDelegate:delegate];
    if (self) {
        self.titleView.hidden = YES;
    }
    return self;
}


+ (void)fakeStop
{
    [[WSMVVideoStatisticManager sharedIntance] statVideoSV];
    
    SNNewsTimelineVideoPlayerView *timelineVideoPlayer = [SNNewsTimelineVideoPlayerView sharedInstance];
    NSString *breakPointKey = timelineVideoPlayer.playingVideoModel.vid ?: timelineVideoPlayer.playingVideoModel.siteInfo.siteId;
    [[SNVideoBreakpointManager sharedInstance] addBreakpointByVid:breakPointKey breakpoint:[timelineVideoPlayer getMoviePlayer].currentPlaybackTime];
    [timelineVideoPlayer pause];//用stop方法卡顿，用pause好一些
    [timelineVideoPlayer statVV];
    timelineVideoPlayer.delegate = nil;
    [timelineVideoPlayer resetModel];
    [timelineVideoPlayer clearMoviePlayerController];
    [timelineVideoPlayer removeFromSuperview];
    
    if ([[self sharedInstance].delegate respondsToSelector:@selector(didStopVideo:)]) {
        [[self sharedInstance].delegate didStopVideo:[self sharedInstance].playingVideoModel];
    }
}

+ (void)forceStop
{
    SNNewsTimelineVideoPlayerView *timelineVideoPlayer = [SNNewsTimelineVideoPlayerView sharedInstance];
    NSString *breakPointKey = timelineVideoPlayer.playingVideoModel.vid ?: timelineVideoPlayer.playingVideoModel.siteInfo.siteId;
    [[SNVideoBreakpointManager sharedInstance] addBreakpointByVid:breakPointKey breakpoint:[timelineVideoPlayer getMoviePlayer].currentPlaybackTime];
    [timelineVideoPlayer forceStop];
    timelineVideoPlayer.delegate = nil;
    [timelineVideoPlayer resetModel];
    [timelineVideoPlayer removeFromSuperview];
    [timelineVideoPlayer clearMoviePlayerController];
}

@end
