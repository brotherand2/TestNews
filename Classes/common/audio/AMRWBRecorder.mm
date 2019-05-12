//
//  AMRWBRecorder.m
//  sohunews
//
//  Created by chenhong on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "AMRWBRecorder.h"
#import <AVFoundation/AVFoundation.h>

extern "C" {
    #include "enc_if.h"
}

#define SAMPLES_PER_SECOND 16000.0f
#define kBufferDurationSeconds .5
#define AWRWB_MAGIC ("#!AMR-WB\n")
#define kMinDBvalue -80.0

void AMRWBRecorder::SetDelegate(id delegate) {
    _delegate = delegate;
}

// ____________________________________________________________________________________
// Determine the size, in bytes, of a buffer necessary to represent the supplied number
// of seconds of audio data.
int AMRWBRecorder::ComputeRecordBufferSize(const AudioStreamBasicDescription *format, float seconds)
{
	int packets, frames, bytes = 0;
	try {
		frames = (int)ceil(seconds * format->mSampleRate);
		
		if (format->mBytesPerFrame > 0)
			bytes = frames * format->mBytesPerFrame;
		else {
			UInt32 maxPacketSize;
			if (format->mBytesPerPacket > 0)
				maxPacketSize = format->mBytesPerPacket;	// constant packet size
			else {
				UInt32 propertySize = sizeof(maxPacketSize);
				XThrowIfError(AudioQueueGetProperty(mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,
                                                    &propertySize), "couldn't get queue's maximum output packet size");
			}
			if (format->mFramesPerPacket > 0)
				packets = frames / format->mFramesPerPacket;
			else
				packets = frames;	// worst-case scenario: 1 frame in a packet
			if (packets == 0)		// sanity check
				packets = 1;
			bytes = packets * maxPacketSize;
		}
	} catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		return 0;
	}
	return bytes;
}

// ____________________________________________________________________________________
// AudioQueue callback function, called when an input buffers has been filled.
void AMRWBRecorder::MyInputBufferHandler(	void *								inUserData,
                                      AudioQueueRef						inAQ,
                                      AudioQueueBufferRef					inBuffer,
                                      const AudioTimeStamp *				inStartTime,
                                      UInt32								inNumPackets,
                                      const AudioStreamPacketDescription*	inPacketDesc)
{    
    AMRWBRecorder *aqr = (AMRWBRecorder *)inUserData;
    try {
        if (inNumPackets > 0) {
            fprintf(stdout, "inBuffer->mAudioDataByteSize: %d inNumPackets: %d", (unsigned int)inBuffer->mAudioDataByteSize, (unsigned int)inNumPackets);
            for (int i =0; i < inBuffer->mAudioDataByteSize ;i+=320*2) {
                short * pPacket = (short *)(((unsigned char*)(inBuffer->mAudioData))+i);
                
                //                const short par = 2;
                //                for (int j=0; j<160; j++) {
                //                    if (pPacket[j]<(0x7FFF/par)&&pPacket[j]>(-0x7FFF/par)) {
                //                        if (pPacket[j] > 0x7FFF/2) {
                //                            pPacket[j] = 0x7FFF-1;
                //                        }else if (pPacket[j] < -0x7FFF/2) {
                //                            pPacket[j] = -0x7FFF+1;
                //                        }else{
                //                            pPacket[j] = pPacket[j]*par;
                //                        }
                //                    }
                //                }
                
                aqr->EncodeBuffer(pPacket,640);
            }
            
            aqr->mRecordPacket += inNumPackets;
            //int duration   = (int)(aqr->mRecordPacket * (aqr->mRecordFormat).mFramesPerPacket) %  (int)((aqr->mRecordFormat).mSampleRate) >= 0.5 ? 1 : 0;
            aqr->mFileDuration = (aqr->mRecordPacket * (aqr->mRecordFormat).mFramesPerPacket) / (aqr->mRecordFormat).mSampleRate;// + duration;
            fprintf(stdout, "duration = %f\n", aqr->mFileDuration);
        }
        
        // if we're not stopping, re-enqueue the buffer so that it gets filled again
        if (aqr->IsRunning())
            XThrowIfError(AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL), "AudioQueueEnqueueBuffer failed");
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
}

AMRWBRecorder::AMRWBRecorder()
{
	mIsRunning      = false;
	mRecordPacket   = 0;
    mFileDuration   = 0;
    mQueue          = nil;
    mFileName       = NULL;
    _amrFile        = 0;
    _chan_lvls      = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState));
    _meterTable     = new MeterTable(kMinDBvalue);
    _destate        = (int*) E_IF_init();
}

AMRWBRecorder::~AMRWBRecorder()
{
    delete _meterTable;
    
    if (_chan_lvls) {
        free(_chan_lvls);
        _chan_lvls = NULL;
    }

    if (mQueue) {
        AudioQueueDispose(mQueue, TRUE);
        mQueue = NULL;
    }
    
	if (mFileName){
        CFRelease(mFileName);
        mFileName = nil;
    }
    
    if (_destate) {
        E_IF_exit((void*)_destate);
        _destate = 0;
    }
    
    if (_amrFile)
    {
        fclose(_amrFile);
        _amrFile = 0;
    }
}

void AMRWBRecorder::SetupAudioFormat(UInt32 inFormatID)
{
	memset(&mRecordFormat, 0, sizeof(mRecordFormat));
    
	mRecordFormat.mFormatID = inFormatID;
	if (inFormatID == kAudioFormatLinearPCM)
	{
		// if we want pcm, default to signed 16-bit little-endian
		mRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        mRecordFormat.mSampleRate = SAMPLES_PER_SECOND;
		mRecordFormat.mBitsPerChannel = 16;
        mRecordFormat.mChannelsPerFrame = 1;
		mRecordFormat.mBytesPerPacket = mRecordFormat.mBytesPerFrame = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
		mRecordFormat.mFramesPerPacket = 1;
	}
}

void AMRWBRecorder::StartRecord(CFStringRef inRecordFile)
{
	int i, bufferByteSize;
    
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	try {
		// specify the recording format
		SetupAudioFormat(kAudioFormatLinearPCM);
		
		// create the queue
		XThrowIfError(AudioQueueNewInput(
                                         &mRecordFormat,
                                         MyInputBufferHandler,
                                         this /* userData */,
                                         NULL /* run loop */, NULL /* run loop mode */,
                                         0 /* flags */, &mQueue), "AudioQueueNewInput failed");
		
		// get the record format back from the queue's audio converter --
		// the file may require a more specific stream description than was necessary to create the encoder.
		mRecordPacket = 0;
		
		// allocate and enqueue buffers
		bufferByteSize = ComputeRecordBufferSize(&mRecordFormat, kBufferDurationSeconds);	// enough bytes for half a second
		for (i = 0; i < kNumberRecordBuffers; ++i) {
			XThrowIfError(AudioQueueAllocateBuffer(mQueue, bufferByteSize, &mBuffers[i]),
                          "AudioQueueAllocateBuffer failed");
			XThrowIfError(AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL),
                          "AudioQueueEnqueueBuffer failed");
		}
		// start the queue
		mIsRunning = true;
        //AudioQueueFlush(mQueue);
        
        Float32 gain=1.0;
        
        //设置音量
        AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, gain);
        
        OSStatus st = AudioQueueStart(mQueue, NULL);
		XThrowIfError(st, "AudioQueueStart failed");
        
        if (mFileName) {
            CFRelease(mFileName);
            mFileName = nil;
        }
        
        mFileName = CFStringCreateCopy(kCFAllocatorDefault, inRecordFile);
        mRecordPacket = 0;
        mFileDuration = 0;
        if (0 != mFileName) {
            _amrFile = fopen((const char *)[(NSString *)mFileName UTF8String], "wb+");
            XThrowIfError(0 == _amrFile, "Amr file create failed");
            fwrite(AWRWB_MAGIC, 1, strlen(AWRWB_MAGIC), _amrFile);
        }
        EnableLevelMeter();
	}
	catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");;
	}
    
}

void AMRWBRecorder::StopRecord()
{
    try {
        // end recording
        mIsRunning = false;
        XThrowIfError(AudioQueueStop(mQueue, true), "AudioQueueStop failed");
        // a codec may update its cookie at the end of an encoding session, so reapply it to the file now
        //CopyEncoderCookieToFile();
        if (mFileName)
        {
            CFRelease(mFileName);
            mFileName = NULL;
        }
        if (mQueue) {
            DisableLevelMeter();
            XThrowIfError(AudioQueueDispose(mQueue, true), "AudioQueueDispose failed");
            mQueue = NULL;
        }
        //    if (mRecordFile) {
        //        AudioFileClose(mRecordFile);
        //    }
        if (_amrFile) {
            fflush(_amrFile);
            fclose(_amrFile);
            _amrFile=NULL;
        }
        
    }
    catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");;
	}
    
//    if (_destate) {
//        E_IF_exit((void*)_destate);
//        _destate = 0;
//    }
    
    // 恢复播放模式并结束
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

void AMRWBRecorder::EncodeBuffer(short *buf,int len)
{
    if (!_destate) {
        return;
    }
    
    int mode = 8; //23850bps
    int dtx = 0;
    unsigned char serialbuf[320*2]= {0};
    memset(serialbuf, 0, sizeof(serialbuf));
    int frameLen = E_IF_encode(_destate, mode, buf, serialbuf, dtx);
    // printf("amr Frame len = %d\n",frameLen);
    
    /*int ilen = 0;*/
    if (0 != _amrFile) {
        //fprintf(stderr, "%d bytes wrote", frameLen);
        /*ilen = */fwrite((unsigned char *)serialbuf,1,frameLen,_amrFile);
    }
}

void AMRWBRecorder::EnableLevelMeter()
{
    if (!_chan_lvls) {
        _chan_lvls = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState));
    }
        
    try {
        UInt32 val = 1;
        XThrowIfError(AudioQueueSetProperty(mQueue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32)), "couldn't enable metering");
    }
    catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }

}
void AMRWBRecorder::DisableLevelMeter() {
    if (_chan_lvls) {
        free(_chan_lvls);
        _chan_lvls = NULL;
    }
    
    try {
        UInt32 val = 0;
        XThrowIfError(AudioQueueSetProperty(mQueue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32)), "couldn't disable metering");
    }
    catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }

}

void AMRWBRecorder::UpdateLevelMeter(float *avgPower, float *peakPower)
{
    UInt32 data_sz = sizeof(AudioQueueLevelMeterState);
    OSErr status = AudioQueueGetProperty(mQueue, kAudioQueueProperty_CurrentLevelMeterDB, _chan_lvls, &data_sz);
    if (status != noErr)
    {
        printf("ERROR: metering failed\n");
        return;
    }
    
    if (_chan_lvls)
    {
        if (avgPower) {
            *avgPower = _meterTable->ValueAt(_chan_lvls->mAveragePower);
        }
        if (peakPower) {
            *peakPower = _meterTable->ValueAt(_chan_lvls->mPeakPower);
        }
    }
    
    return;
}

