//
//  SNShakingManager.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNShakingManager.h"
#import <AudioToolbox/AudioToolbox.h>

static SNShakingManager* g_ShakingManager;


@implementation SNShakingManager
@synthesize _listeners;
@synthesize _player;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

+(SNShakingManager*)GetInstance
{
	if(g_ShakingManager==nil)
	{
		g_ShakingManager = [[SNShakingManager alloc]init];
	}
	return g_ShakingManager;
}

-(void)dealloc
{
    if(self._listeners!=nil)
    {
        [self._listeners removeAllObjects];
    }
    [self._player stop];
    
    [_manager stopAccelerometerUpdates];
    
}

-(id)init
{
    if(self=[super init])
    {
        _shaingNow = NO;
        _minShakingTime = 2.0f;
        _audioIsAlreadyPlaying = NO;
        self._listeners = [NSMutableArray arrayWithCapacity:0];
        
        _manager = [[CMMotionManager alloc]init];
        _manager.accelerometerUpdateInterval=1.0/60.0;
        [_manager startAccelerometerUpdates];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(shackAction) userInfo:nil repeats:YES];

        
        NSString* path = [[NSBundle mainBundle] pathForResource:@"shakebook" ofType:@"mp3"];
        if(path!=nil)
        {
            self._player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
            self._player.delegate = self;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        }
    }
    return self;
}

-(void)shackAction
{
    if(_shaingNow)
        return;
    
	if(fabs(_manager.accelerometerData.acceleration.x)>1.8||fabs(_manager.accelerometerData.acceleration.y)>1.8||fabs(_manager.accelerometerData.acceleration.z)>1.8)
	{
        _shaingNow = YES;
        //[self playMp3];
        //[self playShaking];
        [self performSelector:@selector(endShakingFlag) withObject:nil afterDelay:_minShakingTime];
        
        if(self._listeners!=nil && [self._listeners count]>0)
        {
            for(NSInteger i=0; i<[self._listeners count]; i++)
            {                id<SNShakingManagerDelegate> listener = (id<SNShakingManagerDelegate>)[self._listeners objectAtIndex:i];
                if([listener respondsToSelector:@selector(notifyShaking:)])
                    [listener notifyShaking:YES];
            }
        }
	}
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 用户接口 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)addListener:(id<SNShakingManagerDelegate>)aListener
{
    if(aListener!=nil)
    {
        [self._listeners removeObject:aListener];
        [self._listeners addObject:aListener];
    }
}

-(void)removeListener:(id<SNShakingManagerDelegate>)aListener
{
    if(aListener!=nil)
        [self._listeners removeObject:aListener];
}

-(void)endShakingFlag
{
    _shaingNow = NO;
}

-(void)playMp3
{
    self._player.numberOfLoops = 1;
    self._player.volume = 0.5f;
    [self._player play];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(_audioIsAlreadyPlaying)
        [[AVAudioSession sharedInstance] setActive:NO withFlags:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    else
        [[AVAudioSession sharedInstance] setActive:YES withFlags:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

-(void)playShaking
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)audioSetActiveIfNeeded
{
    UInt32 propertySize;
    UInt32 audioIsAlreadyPlaying = 0;
    propertySize = sizeof(UInt32);
    AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &audioIsAlreadyPlaying);
    _audioIsAlreadyPlaying = (audioIsAlreadyPlaying==1);
    
    if(!_audioIsAlreadyPlaying)
        AudioSessionSetActive(YES);
}

-(void)audioSetDeActive
{
    AudioSessionSetActive(NO);
}

-(BOOL)audioIsRunningInbackgroud
{
    return _audioIsAlreadyPlaying;
}
@end
