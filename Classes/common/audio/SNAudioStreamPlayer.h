//
//  SNAudioStreamPlayer.h
//  sohunews
//
//  Created by chenhong on 13-7-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNAudioStreamPlayer;

@protocol SNAudioStreamPlayerDelegate
- (void)audioStreamPlayerDoLoading:(SNAudioStreamPlayer *)sender;
- (void)audioStreamPlayerDidStop:(SNAudioStreamPlayer *)sender;
- (void)audioStreamPlayerDidPause:(SNAudioStreamPlayer *)sender;
- (void)audioStreamPlayerDoPlay:(SNAudioStreamPlayer *)sender;
- (void)audioStreamPlayerDidFailedToPlay:(SNAudioStreamPlayer *)sender;
@end

@class AudioStreamer;

@interface SNAudioStreamPlayer : NSObject {
    AudioStreamer *_streamer;
    NSString *_url;
    NSTimer *_timer;
    CGFloat _lastProgress;
    id<SNAudioStreamPlayerDelegate> __weak delegate;
}

@property (nonatomic, strong) AudioStreamer *streamer;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, weak) id<SNAudioStreamPlayerDelegate> delegate;

- (void)play:(NSString *)url;
- (BOOL)pause;
- (void)stop;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isWaiting;
- (CGFloat)progress;
- (CGFloat)duration;

@end
