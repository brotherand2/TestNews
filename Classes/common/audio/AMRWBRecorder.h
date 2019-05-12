//
//  AMRRecorder.h
//  sohunews
//
//  Created by chenhong on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//
#ifndef AMRWBRECORDER_H_
#define AMRWBRECORDER_H_

#include <AudioToolbox/AudioToolbox.h>
#include <Foundation/Foundation.h>
#include <libkern/OSAtomic.h>

#include "CAStreamBasicDescription.h"
#include "CAXException.h"
#include "MeterTable.h"

#define kNumberRecordBuffers	3

@protocol AMRWBRecorderDelegate <NSObject>
@optional
    
@end

class AMRWBRecorder
{
public:
    AMRWBRecorder();
    ~AMRWBRecorder();
    
    UInt32						GetNumberChannels() const	{ return mRecordFormat.NumberChannels(); }
    CFStringRef					GetFileName() const			{ return mFileName; }
    AudioQueueRef				Queue() const				{ return mQueue; }
    CAStreamBasicDescription	DataFormat() const			{ return mRecordFormat; }
    CGFloat                     GetFileDuration() const     { return mFileDuration; }
    
    void                        StartRecord(CFStringRef inRecordFile);
    void                        StopRecord();
    Boolean                     IsRunning() const			{ return mIsRunning; }
    
    void                        EncodeBuffer(short* buf,int len);
    
    void                        EnableLevelMeter();
    void                        DisableLevelMeter();
    void                        UpdateLevelMeter(float *avgPower, float *peakPower);
    void                        SetDelegate(id delegate);
    
private:
    CFStringRef					mFileName;
    AudioQueueRef				mQueue;
    AudioQueueBufferRef			mBuffers[kNumberRecordBuffers];
    SInt64						mRecordPacket; // current packet number in record file
    CAStreamBasicDescription	mRecordFormat;
    Boolean						mIsRunning;
    CGFloat                     mFileDuration;
    FILE                        *_amrFile;
    int                         *_destate;
    AudioQueueLevelMeterState	*_chan_lvls;
    MeterTable					*_meterTable;
    id<AMRWBRecorderDelegate>   _delegate;
    
    void			SetupAudioFormat(UInt32 inFormatID);
    int				ComputeRecordBufferSize(const AudioStreamBasicDescription *format, float seconds);
    
    static void MyInputBufferHandler(	void *								inUserData,
                                     AudioQueueRef						inAQ,
                                     AudioQueueBufferRef					inBuffer,
                                     const AudioTimeStamp *				inStartTime,
                                     UInt32								inNumPackets,
                                     const AudioStreamPacketDescription*	inPacketDesc);
};

#endif //AMRWBRECORDER_H_