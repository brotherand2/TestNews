//
//  SNShakingManager.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@protocol SNShakingManagerDelegate <NSObject>
@optional
-(void)notifyShaking:(BOOL)aSoundAndShaking;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface SNShakingManager : NSObject<UIAccelerometerDelegate,AVAudioPlayerDelegate>
{
    CMMotionManager *_manager;
    
    AVAudioPlayer* _player;
    NSMutableArray* _listeners;
    
    BOOL _shaingNow;             //是否处于摇一摇间隙
    CGFloat _minShakingTime;     //最小间隔
    BOOL _audioIsAlreadyPlaying; //之前是否已经有音乐在播放
}

@property(nonatomic,strong) AVAudioPlayer* _player;
@property(nonatomic,strong) NSMutableArray* _listeners;

+(SNShakingManager*)GetInstance;
-(void)addListener:(id<SNShakingManagerDelegate>)aListener;
-(void)removeListener:(id<SNShakingManagerDelegate>)aListener;
-(void)endShakingFlag;

-(void)playMp3;
-(void)playShaking;

-(void)audioSetActiveIfNeeded;
-(void)audioSetDeActive;
-(BOOL)audioIsRunningInbackgroud;
@end
