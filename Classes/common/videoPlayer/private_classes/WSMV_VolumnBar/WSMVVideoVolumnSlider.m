//
//  WSVideoVolumnSlider.m
//  WeSee
//
//  Created by handy wang on 9/11/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoVolumnSlider.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation WSMVVideoVolumnSlider

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView.height = 4;
        self.backgroundView.backgroundColor = [UIColor clearColor];
        UIImage *_bgImage = [UIImage themeImageNamed:@"wsmv_slider_bg.png"];
        self.backgroundView.image = [_bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        
        self.progressView.height = 4;
        self.progressView.backgroundColor = [UIColor clearColor];
        UIImage *_progressImage = [UIImage themeImageNamed:@"wsmv_slider_progress.png"];
        self.progressView.image = [_progressImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        
        Float32 systemVolume;
        UInt32 dataSize = sizeof(Float32);
        AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareOutputVolume,
                                 &dataSize,&systemVolume);
        [self assignProgressValue:systemVolume];
    }
    return self;
}


#pragma mark - Private
- (void)setVolumnSliderProgressValue:(CGFloat)progressValue {
    [self assignProgressValue:progressValue];
    [self setVolume:progressValue];
}

- (void)setVolume:(CGFloat)volume {
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = volume;
}

@end
