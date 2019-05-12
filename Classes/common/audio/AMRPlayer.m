//
//  AMRPlayer.m
//  sohunews
//
//  Created by chenhong on 13-4-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//


#import "AMRPlayer.h"
#include "interf_dec.h"
#include "dec_if.h"
#import <AVFoundation/AVFoundation.h>

const unsigned int PACKETNUM =  25;//20ms * 25 = 0.5s ,每个包25帧,可以播放0.5秒
const float KSECONDSPERBUFFER = 0.2; //每秒播放0.2个缓冲
const unsigned int AMRFRAMELEN = 32; //帧长
const unsigned int PERREADFRAME =  10;//每次读取帧数
static unsigned int gBufferSizeBytes = 0x10000;


#define AMRWB_MAGIC ("#!AMR-WB\n")
#define AMRNB_MAGIC ("#!AMR\n")
#define AMRWB_TYPE 1
#define AMRNB_TYPE 2

@implementation AMRPlayer 

@synthesize queue;
@synthesize delegate;
@synthesize url=_url;

// 回调（Callback）函数的实现

static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer) {
    AMRPlayer* player = (AMRPlayer*)inUserData;
    [player  audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}

static void isRunningProc(void * inUserData, AudioQueueRef queue, AudioQueuePropertyID inID) {
    AMRPlayer* player = (AMRPlayer*)inUserData;
    [player performSelectorOnMainThread:@selector(notifyDelegatePlaybackStateChanged:) withObject:nil waitUntilDone:NO];
}

- (BOOL)initFile:(const char*) amrFileName
{
    char magic[10] = {0};
    _hasReadSize = 0;
    int rCount = 0;

    if ((_amrFile = fopen(amrFileName, "rb")))
    {
        self.url = [NSString stringWithUTF8String:amrFileName];
        
        //AMR-WB
        rCount = fread(magic, sizeof(char), strlen(AMRWB_MAGIC), _amrFile);
        if (!strncmp(magic, AMRWB_MAGIC, strlen(AMRWB_MAGIC))) {
            _destate = D_IF_init();
            _hasReadSize = rCount;
            _amrType = AMRWB_TYPE;
            return YES;
        }

        fseek(_amrFile, 0, SEEK_SET);

        //AMR-NB
        rCount = fread(magic, sizeof(char), strlen(AMRNB_MAGIC), _amrFile);
        if (!strncmp(magic, AMRNB_MAGIC, strlen(AMRNB_MAGIC))) {
            _destate = Decoder_Interface_init();
            _hasReadSize = rCount;
            _amrType = AMRNB_TYPE;
            return YES;
        }

        fclose( _amrFile );
        _amrFile = NULL;
    }
    return NO;
}

//缓存数据读取方法的实现

- (void) audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                       queueBuffer:(AudioQueueBufferRef)audioQueueBuffer {
    if (_amrFile) {
        int readAMRFrame = [self readPacketsIntoBuffer:audioQueueBuffer];
        if (readAMRFrame <= 0) {
            _isDone = YES;
            AudioQueueStop(queue, false);
        }
    }
}

//音频播放方法的实现

- (BOOL)startPlay:(const char*)path
{//CFURLRef
    
    if (![self initFile:path]) return NO;
    
    //--设置音频数据格式
    memset(&dataFormat, 0, sizeof(dataFormat));
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mSampleRate = (_amrType == AMRWB_TYPE ? 16000.0 : 8000.0);
    dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mChannelsPerFrame = 1;
    dataFormat.mFramesPerPacket = 1;
    dataFormat.mBytesPerFrame = (dataFormat.mBitsPerChannel/8) * dataFormat.mChannelsPerFrame;
    dataFormat.mBytesPerPacket = dataFormat.mBytesPerFrame;
    
    //---
    
    // 创建播放用的音频队列(nil:audio队列的间隙线程)
    AudioQueueNewOutput(&dataFormat, BufferCallback,self, nil, nil, 0, &queue);
    
    // 创建并分配缓存空间
    //packetIndex = 0;
    gBufferSizeBytes = KSECONDSPERBUFFER *  2 * 160 * 50 *2; //MR122 size * 2

    if (_amrType == AMRWB_TYPE) {
        gBufferSizeBytes *= 2;
    }
    
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueAllocateBuffer(queue, gBufferSizeBytes, &buffers[i]);//&mBuffers[i]
        
        //读取包数据
        //        if ([self readPacketsIntoBuffer:buffers[i]] == 0) {
        //            break;
        //        }
    }
    
    //设置监听
    AudioQueueAddPropertyListener(queue, kAudioQueueProperty_IsRunning, isRunningProc, self);
    
    //忽略静音开关
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //设置音量
    AudioQueueSetParameter (queue,kAudioQueueParam_Volume,1.0);
    
    //队列处理开始，此后系统会自动调用回调（Callback）函数
    //AudioQueueStart(queue, nil);
    
    return [self StartQueue] == noErr;
}

- (void)pause {
    [self PauseQueue];
}

- (BOOL)resume {
    return (AudioQueueStart(queue, NULL) == noErr);
}

- (void)stop {
    [self StopQueue];
    self.url = nil;
}

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer {
    short pcmBuf[1600*2] = {0}; //KSECONDSPERBUFFER * 160 * 50
    
    int readAMRFrame = 0;
    const short block_size[16] = {12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0};
    const int wb_block_size[] = {17, 23, 32, 36, 40, 46, 50, 58, 60, 5, -1, -1, -1, -1, -1, 0};
    char analysis[64]={0};
    
    int rCout=0;
    while (readAMRFrame < PERREADFRAME && (rCout=fread(analysis, sizeof (unsigned char), 1, _amrFile)))
    {
        _hasReadSize += rCout;
        
        int dec_mode = (analysis[0] >> 3) & 0x000F;
        
        int read_size = (_amrType == AMRWB_TYPE ? wb_block_size[dec_mode] : block_size[dec_mode]);
        rCout=fread(&analysis[1], sizeof (char), read_size, _amrFile);
        
        _hasReadSize += rCout;

        if (_amrType == AMRWB_TYPE) {
            D_IF_decode(_destate, (unsigned char *)analysis, &pcmBuf[readAMRFrame*160*2], 0);
        } else {
            Decoder_Interface_Decode(_destate,(unsigned char *)analysis,&pcmBuf[readAMRFrame*160],0);
        }
        readAMRFrame ++;
    }
    //SNDebugLog(@"readCount:%d",_hasReadSize);
        
    if (readAMRFrame > 0) {
        int coef = (_amrType == AMRWB_TYPE ? 2 : 1);
        buffer ->mAudioDataByteSize = readAMRFrame * 2 * 160 * coef;
        buffer ->mPacketDescriptionCount = readAMRFrame * 160 * coef;
        memcpy(buffer ->mAudioData, pcmBuf, readAMRFrame * 160 *2 * coef);
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    }
    return readAMRFrame;
}

- (void)dealloc {
    [self stop];
    [super dealloc];
}

- (OSStatus)StartQueue
{
    _isDone = NO;

    // prime the queue with some data before starting
    for (int i = 0; i < NUM_BUFFERS; ++i) {
        //读取包数据
        if ([self readPacketsIntoBuffer:buffers[i]] == 0) {
            break;
        }
    }
    return AudioQueueStart(queue, NULL);
}

- (OSStatus)StopQueue
{
    OSStatus result = noErr;
    if (queue) {
        result = AudioQueueStop(queue, TRUE);
        if (result)
            printf("ERROR STOPPING QUEUE!\n");
        
        result = AudioQueueDispose(queue, TRUE);
        if (result)
            printf("ERROR DISPOSE QUEUE!\n");
        
        queue = NULL;
    }
    if (_destate) {
        if (_amrType == AMRNB_TYPE) {
            Decoder_Interface_exit(_destate);
        } else if (_amrType == AMRWB_TYPE) {
            D_IF_exit(_destate);
        }
        _destate = NULL;
    }

    if (_amrFile) {
        fclose( _amrFile );
        _amrFile = NULL;
    }

    return result;
}

- (OSStatus)PauseQueue
{
    OSStatus result = AudioQueuePause(queue);
    
    return result;
}

- (BOOL)isPlaying
{
    UInt32 state = NO, size = sizeof(UInt32);
    if (queue) {
        OSStatus err = AudioQueueGetProperty(queue, kAudioQueueProperty_IsRunning, &state, &size);
        if( err != noErr )
            printf("Couldn't get play state of queue.\n");
    }
    
    return state;
}

- (float)currentTime {
    float timeInterval = 0;
    if (queue) {
        AudioQueueTimelineRef timeLine;
        OSStatus status = AudioQueueCreateTimeline(queue, &timeLine);
        if (status == noErr) {
            AudioTimeStamp timeStamp;
            AudioQueueGetCurrentTime(queue, timeLine, &timeStamp, NULL);
            timeInterval = timeStamp.mSampleTime / dataFormat.mSampleRate; // modified
        }
        AudioQueueDisposeTimeline(queue, timeLine);
    }

    return timeInterval;
}

- (void)notifyDelegatePlaybackStateChanged:(id)sender
{
    if (![self isPlaying] && _isDone)
    {
        [self StopQueue];
        [delegate sound:self didFinishPlaying:YES];
    }
}

@end
