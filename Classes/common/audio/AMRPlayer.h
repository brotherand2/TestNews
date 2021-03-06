//
//  AMRPlayer.h
//  sohunews
//
//  Created by chenhong on 13-4-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//



//使用AudioQueue来实现音频播放功能时最主要的步骤:
//
//1. 打开播放音频文件
//2. 取得或设置播放音频文件的数据格式
//3. 建立播放用的队列
//4. 将缓冲中的数据填充到队列中
//5. 开始播放
//6. 在回调函数中进行队列处理
//
//
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_BUFFERS 3

@class AMRPlayer;

@protocol AMRPlayerDelegate

- (void)sound:(AMRPlayer*)sender didFinishPlaying:(BOOL)state;

@end


@interface AMRPlayer : NSObject { 
    
    //播放音频文件ID
    //AudioFileID audioFile;
    
    //音频流描述对象
    AudioStreamBasicDescription dataFormat;
    
    //音频队列
    AudioQueueRef queue;
    
    //SInt64 packetIndex;
    
    //UInt32 numPacketsToRead;
    
    //UInt32 bufferByteSize;
    
    AudioStreamPacketDescription *packetDescs;
    
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    int * _destate;
    int _hasReadSize;
    FILE* _amrFile;
    
    NSString *_url;
    
    id<AMRPlayerDelegate> delegate;
    BOOL _isDone;
    int _amrType; // 区分WB/NB
    
}

//定义队列为实例属性

@property AudioQueueRef queue;
@property (nonatomic, weak) id<AMRPlayerDelegate> delegate;
@property (nonatomic, retain) NSString *url;

//播放方法定义

- (BOOL)startPlay:(const char*) path;//CFURLRef
- (void)pause;
- (BOOL)resume;
- (void)stop;
- (BOOL)isPlaying;
- (float)currentTime;

//定义缓存数据读取方法

- (void) audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                       queueBuffer:(AudioQueueBufferRef)audioQueueBuffer;

//定义回调（Callback）函数

static void BufferCallback(void *inUserData, AudioQueueRef inAQ,
                           AudioQueueBufferRef buffer);

//定义包数据的读取方法

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;

- (void)notifyDelegatePlaybackStateChanged:(id)sender;

@end
