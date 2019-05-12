//
//  SNAudioStreamPlayer.m
//  sohunews
//
//  Created by chenhong on 13-7-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNAudioStreamPlayer.h"
#import "AudioStreamer.h"

@implementation SNAudioStreamPlayer
@synthesize streamer=_streamer, url=_url, delegate;

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    [self stop];
//    [_timer invalidate];
}

- (void)play:(NSString *)aURL
{
    if (!aURL.length) {
        return;
    }
    
    if (!_streamer) {
        self.url = aURL;
        _streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:self.url]];
                
        // register the streamer on notification
        [SNNotificationManager addObserver:self
                                                 selector:@selector(playbackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:_streamer];
    }
    
    if ([_streamer isPlaying]) {
        [_streamer pause];
    } else {
        [_streamer start];
    }
}

- (BOOL)pause {
   return [_streamer pause];
}

- (void)stop
{    
    // release streamer
	if (_streamer/* && ![_streamer isFinishing]*/)
	{
		[_streamer stop];

        // remove notification observer for streamer
		[SNNotificationManager removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_streamer];
        
		_streamer = nil;

	}
}

- (BOOL)isPlaying {
    return [_streamer isPlaying];
}

- (BOOL)isPaused {
    return [_streamer isPaused];
}

- (BOOL)isWaiting {
    return [_streamer isWaiting];
}
//- (void)updateProgress
//{
//    if (![self isPlaying]) {
//        return;
//    }
//    
//    if (_streamer.progress <= _streamer.duration ) {
//        //[button setProgress:streamer.progress/streamer.duration];
//        SNDebugLog(@"current progress: %.2f", _streamer.progress);
//    } else {
//        //[button setProgress:0.0f];
//    }
//}

- (CGFloat)progress {
    //if ([self isPlaying]) {
        _lastProgress = _streamer.progress;
        return _lastProgress;
    //}
    return _lastProgress;
}

- (CGFloat)duration {
    return _streamer.duration;
}

/*
 *  observe the notification listener when loading an audio
 */
- (void)playbackStateChanged:(NSNotification *)notification
{
    SNDebugLog(@"playbackStateChanged %@", notification);
    
    if ([_streamer isWaiting]) {
        SNDebugLog(@"waiting");
        [delegate audioStreamPlayerDoLoading:self];
    }
    else if ([_streamer isIdle]) {
        SNDebugLog(@"idle");
        [self stop];
        if (_streamer.errorCode != AS_NO_ERROR) {
            [delegate audioStreamPlayerDidFailedToPlay:self];
        } else {
            [delegate audioStreamPlayerDidStop:self];
        }
	}
    else if ([_streamer isPaused]) {
                SNDebugLog(@"pause");
        [delegate audioStreamPlayerDidPause:self];
    }
    else if ([_streamer isPlaying] || [_streamer isFinishing]) {
                SNDebugLog(@"isPlaying:%d", _streamer.state);
        [delegate audioStreamPlayerDoPlay:self];
	}
}


@end
