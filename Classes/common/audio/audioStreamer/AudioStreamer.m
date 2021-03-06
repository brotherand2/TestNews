
#import "AudioStreamer.h"
#if TARGET_OS_IPHONE			
#import <CFNetwork/CFNetwork.h>
#endif
#include "interf_dec.h"
#include "dec_if.h"

#import "SNSoundManager.h"

#define BitRateEstimationMaxPackets 5000
#define BitRateEstimationMinPackets 50

NSString * const ASStatusChangedNotification = @"ASStatusChangedNotification";
NSString * const ASAudioSessionInterruptionOccuredNotification = @"ASAudioSessionInterruptionOccuredNotification";

NSString * const AS_NO_ERROR_STRING = @"No error.";
NSString * const AS_FILE_STREAM_GET_PROPERTY_FAILED_STRING = @"File stream get property failed.";
NSString * const AS_FILE_STREAM_SEEK_FAILED_STRING = @"File stream seek failed.";
NSString * const AS_FILE_STREAM_PARSE_BYTES_FAILED_STRING = @"Parse bytes failed.";
NSString * const AS_FILE_STREAM_OPEN_FAILED_STRING = @"Open audio file stream failed.";
NSString * const AS_FILE_STREAM_CLOSE_FAILED_STRING = @"Close audio file stream failed.";
NSString * const AS_AUDIO_QUEUE_CREATION_FAILED_STRING = @"Audio queue creation failed.";
NSString * const AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED_STRING = @"Audio buffer allocation failed.";
NSString * const AS_AUDIO_QUEUE_ENQUEUE_FAILED_STRING = @"Queueing of audio buffer failed.";
NSString * const AS_AUDIO_QUEUE_ADD_LISTENER_FAILED_STRING = @"Audio queue add listener failed.";
NSString * const AS_AUDIO_QUEUE_REMOVE_LISTENER_FAILED_STRING = @"Audio queue remove listener failed.";
NSString * const AS_AUDIO_QUEUE_START_FAILED_STRING = @"Audio queue start failed.";
NSString * const AS_AUDIO_QUEUE_BUFFER_MISMATCH_STRING = @"Audio queue buffers don't match.";
NSString * const AS_AUDIO_QUEUE_DISPOSE_FAILED_STRING = @"Audio queue dispose failed.";
NSString * const AS_AUDIO_QUEUE_PAUSE_FAILED_STRING = @"Audio queue pause failed.";
NSString * const AS_AUDIO_QUEUE_STOP_FAILED_STRING = @"Audio queue stop failed.";
NSString * const AS_AUDIO_DATA_NOT_FOUND_STRING = @"No audio data found.";
NSString * const AS_AUDIO_QUEUE_FLUSH_FAILED_STRING = @"Audio queue flush failed.";
NSString * const AS_GET_AUDIO_TIME_FAILED_STRING = @"Audio queue get current time failed.";
NSString * const AS_AUDIO_STREAMER_FAILED_STRING = @"Audio playback failed";
NSString * const AS_NETWORK_CONNECTION_FAILED_STRING = @"Network connection failed";
NSString * const AS_AUDIO_BUFFER_TOO_SMALL_STRING = @"Audio packets are larger than kAQDefaultBufSize.";

//static const unsigned int PACKETNUM =  25;//20ms * 25 = 0.5s ,每个包25帧,可以播放0.5秒
static const float KSECONDSPERBUFFER = 0.2; //每秒播放0.2个缓冲
//static const unsigned int AMRFRAMELEN = 32; //帧长
static const unsigned int PERREADFRAME =  10;//每次读取帧数
static unsigned int gBufferSizeBytes = 0x10000;

#define AMRWB_MAGIC ("#!AMR-WB\n")
#define AMRNB_MAGIC ("#!AMR\n")
#define AMRWB_TYPE 1
#define AMRNB_TYPE 2
#define NUM_BUFFERS 3

@interface AudioStreamer () {
    AudioStreamerState _laststate;
    BOOL _isAMR;
    BOOL _isDone;
    int _amrType; //0 - amrnb 1 - amrwb
    int * _destate;
    int _hasReadSize;
    NSMutableData *_dataBuffer;
    int _bufferReadIndex;
}

@property (readwrite) AudioStreamerState state;

- (void)handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream
                     fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID
                                  ioFlags:(UInt32 *)ioFlags;

- (void)handleAudioPackets:(const void *)inInputData
               numberBytes:(UInt32)inNumberBytes
             numberPackets:(UInt32)inNumberPackets
        packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;

- (void)handleBufferCompleteForQueue:(AudioQueueRef)inAQ 
                              buffer:(AudioQueueBufferRef)inBuffer;

- (void)handlePropertyChangeForQueue:(AudioQueueRef)inAQ 
                          propertyID:(AudioQueuePropertyID)inID;

#if TARGET_OS_IPHONE
- (void)handleInterruptionChangeToState:(NSNotification *)notification;
#endif

- (void)internalSeekToTime:(double)newSeekTime;
- (void)enqueueBuffer;
- (void)handleReadFromStream:(CFReadStreamRef)aStream eventType:(CFStreamEventType)eventType;
- (void)audioQueueOutputWithQueue:(AudioQueueRef)aaudioQueue
                      queueBuffer:(AudioQueueBufferRef)aaudioQueueBuffer;
@end

#pragma mark - 
static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer) {
    AudioStreamer* player = (AudioStreamer*)inUserData;
    [player audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}

static void isRunningProc(void * inUserData, AudioQueueRef queue, AudioQueuePropertyID inID) {
    AudioStreamer* player = (AudioStreamer*)inUserData;
    
	[player handlePropertyChangeForQueue:queue propertyID:inID];
    
    [player performSelectorOnMainThread:@selector(notifyDelegatePlaybackStateChanged:) withObject:nil waitUntilDone:NO];
}


#pragma mark Audio Callback Function Prototypes

void MyAudioQueueOutputCallback(void* inClientData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);
void MyAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID);
void MyPropertyListenerProc(	void *							inClientData,
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags);
void MyPacketsProc(				void *							inClientData,
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions);
OSStatus MyEnqueueBuffer(AudioStreamer* myData);

#if TARGET_OS_IPHONE			
void MyAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState);
#endif

#pragma mark Audio Callback Function Implementations

//
// MyPropertyListenerProc
//
// Receives notification when the AudioFileStream has audio packets to be
// played. In response, this function creates the AudioQueue, getting it
// ready to begin playback (playback won't begin until audio packets are
// sent to the queue in MyEnqueueBuffer).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// kAudioQueueProperty_IsRunning listening added.
//
void MyPropertyListenerProc(	void *							inClientData,
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags)
{	
	// this is called by audio file stream when it finds property values
	AudioStreamer* streamer = (AudioStreamer *)inClientData;
	[streamer
		handlePropertyChangeForFileStream:inAudioFileStream
		fileStreamPropertyID:inPropertyID
		ioFlags:ioFlags];
}

//
// MyPacketsProc
//
// When the AudioStream has packets to be played, this function gets an
// idle audio buffer and copies the audio packets into it. The calls to
// MyEnqueueBuffer won't return until there are buffers available (or the
// playback has been stopped).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
void MyPacketsProc(				void *							inClientData,
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions)
{
	// this is called by audio file stream when it finds packets of audio
	AudioStreamer* streamer = (AudioStreamer *)inClientData;
	[streamer
		handleAudioPackets:inInputData
		numberBytes:inNumberBytes
		numberPackets:inNumberPackets
		packetDescriptions:inPacketDescriptions];
}

//
// MyAudioQueueOutputCallback
//
// Called from the AudioQueue when playback of specific buffers completes. This
// function signals from the AudioQueue thread to the AudioStream thread that
// the buffer is idle and available for copying data.
//
// This function is unchanged from Apple's example in AudioFileStreamExample.
//
void MyAudioQueueOutputCallback(	void*					inClientData, 
									AudioQueueRef			inAQ, 
									AudioQueueBufferRef		inBuffer)
{
	// this is called by the audio queue when it has finished decoding our data. 
	// The buffer is now free to be reused.
	AudioStreamer* streamer = (AudioStreamer*)inClientData;
	[streamer handleBufferCompleteForQueue:inAQ buffer:inBuffer];
}

//
// MyAudioQueueIsRunningCallback
//
// Called from the AudioQueue when playback is started or stopped. This
// information is used to toggle the observable "isPlaying" property and
// set the "finished" flag.
//
void MyAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
	AudioStreamer* streamer = (AudioStreamer *)inUserData;
	[streamer handlePropertyChangeForQueue:inAQ propertyID:inID];
}

#if TARGET_OS_IPHONE			
//
// MyAudioSessionInterruptionListener
//
// Invoked if the audio session is interrupted (like when the phone rings)
//
void MyAudioSessionInterruptionListener(__unused void *inClientData, UInt32 inInterruptionState)
{
    [SNNotificationManager postNotificationName:ASAudioSessionInterruptionOccuredNotification object:@(inInterruptionState)];}
#endif

#pragma mark CFReadStream Callback Function Implementations

//
// ReadStreamCallBack
//
// This is the callback for the CFReadStream from the network connection. This
// is where all network data is passed to the AudioFileStream.
//
// Invoked when an error occurs, the stream ends or we have data to read.
//
void ASReadStreamCallBack
(
   CFReadStreamRef aStream,
   CFStreamEventType eventType,
   void* inClientInfo
)
{
	AudioStreamer* streamer = (AudioStreamer *)inClientInfo;
	[streamer handleReadFromStream:aStream eventType:eventType];
}




@implementation AudioStreamer

@synthesize errorCode;
@synthesize state;
@synthesize bitRate;
@synthesize httpHeaders;


- (id)initWithURL:(NSURL *)aURL
{
	self = [super init];
	if (self != nil)
	{
        url = [aURL retain];
        _isAMR = [[[url path] pathExtension] isEqualToString:@"amr"];
		[SNNotificationManager addObserver:self selector:@selector(handleInterruptionChangeToState:) name:ASAudioSessionInterruptionOccuredNotification object:nil];        
	}
    
	return self;
}

- (void)dealloc
{
	[SNNotificationManager removeObserver:self name:ASAudioSessionInterruptionOccuredNotification object:nil];
	[self stop];
	[url release];
	[super dealloc];
}

- (BOOL)isFinishing
{
    @synchronized (self)
	{
		if ((errorCode != AS_NO_ERROR && state != AS_INITIALIZED) ||
			((state == AS_STOPPING || state == AS_STOPPED) &&
             stopReason != AS_STOPPING_TEMPORARILY))
		{
			return YES;
		}
	}
    
	return NO;
}

- (BOOL)isPlaying
{
	if (state == AS_PLAYING)
	{
		return YES;
	}
	
	return NO;
}

- (BOOL)isPaused
{
	if (state == AS_PAUSED)
	{
		return YES;
	}
	
	return NO;
}

- (BOOL)isWaiting
{
	@synchronized(self)
	{
		if (state == AS_STARTING_FILE_THREAD ||
			state == AS_WAITING_FOR_DATA ||
			state == AS_WAITING_FOR_QUEUE_TO_START ||
			state == AS_BUFFERING)
		{
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)isIdle
{
    // 播放完毕, 空闲状态
	if (state == AS_INITIALIZED)
	{
		return YES;
	}
	
	return NO;
}


//
// runLoopShouldExit
//
// returns YES if the run loop should exit.
//
- (BOOL)runLoopShouldExit
{
	@synchronized(self)
	{
        // 存在错误码,或非临时性的播放停止时, 需要终止streamer
		if ( errorCode != AS_NO_ERROR ||
			 (state == AS_STOPPED && stopReason != AS_STOPPING_TEMPORARILY)
            )
		{
			return YES;
		}
	}
	
	return NO;
}


+ (NSString *)stringForErrorCode:(AudioStreamerErrorCode)anErrorCode
{
	switch (anErrorCode)
	{
		case AS_NO_ERROR:
			return AS_NO_ERROR_STRING;
		case AS_FILE_STREAM_GET_PROPERTY_FAILED:
			return AS_FILE_STREAM_GET_PROPERTY_FAILED_STRING;
		case AS_FILE_STREAM_SEEK_FAILED:
			return AS_FILE_STREAM_SEEK_FAILED_STRING;
		case AS_FILE_STREAM_PARSE_BYTES_FAILED:
			return AS_FILE_STREAM_PARSE_BYTES_FAILED_STRING;
		case AS_AUDIO_QUEUE_CREATION_FAILED:
			return AS_AUDIO_QUEUE_CREATION_FAILED_STRING;
		case AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED:
			return AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED_STRING;
		case AS_AUDIO_QUEUE_ENQUEUE_FAILED:
			return AS_AUDIO_QUEUE_ENQUEUE_FAILED_STRING;
		case AS_AUDIO_QUEUE_ADD_LISTENER_FAILED:
			return AS_AUDIO_QUEUE_ADD_LISTENER_FAILED_STRING;
		case AS_AUDIO_QUEUE_REMOVE_LISTENER_FAILED:
			return AS_AUDIO_QUEUE_REMOVE_LISTENER_FAILED_STRING;
		case AS_AUDIO_QUEUE_START_FAILED:
			return AS_AUDIO_QUEUE_START_FAILED_STRING;
		case AS_AUDIO_QUEUE_BUFFER_MISMATCH:
			return AS_AUDIO_QUEUE_BUFFER_MISMATCH_STRING;
		case AS_FILE_STREAM_OPEN_FAILED:
			return AS_FILE_STREAM_OPEN_FAILED_STRING;
		case AS_FILE_STREAM_CLOSE_FAILED:
			return AS_FILE_STREAM_CLOSE_FAILED_STRING;
		case AS_AUDIO_QUEUE_DISPOSE_FAILED:
			return AS_AUDIO_QUEUE_DISPOSE_FAILED_STRING;
		case AS_AUDIO_QUEUE_PAUSE_FAILED:
			return AS_AUDIO_QUEUE_DISPOSE_FAILED_STRING;
		case AS_AUDIO_QUEUE_FLUSH_FAILED:
			return AS_AUDIO_QUEUE_FLUSH_FAILED_STRING;
		case AS_AUDIO_DATA_NOT_FOUND:
			return AS_AUDIO_DATA_NOT_FOUND_STRING;
		case AS_GET_AUDIO_TIME_FAILED:
			return AS_GET_AUDIO_TIME_FAILED_STRING;
		case AS_NETWORK_CONNECTION_FAILED:
			return AS_NETWORK_CONNECTION_FAILED_STRING;
		case AS_AUDIO_QUEUE_STOP_FAILED:
			return AS_AUDIO_QUEUE_STOP_FAILED_STRING;
		case AS_AUDIO_STREAMER_FAILED:
			return AS_AUDIO_STREAMER_FAILED_STRING;
		case AS_AUDIO_BUFFER_TOO_SMALL:
			return AS_AUDIO_BUFFER_TOO_SMALL_STRING;
		default:
			return AS_AUDIO_STREAMER_FAILED_STRING;
	}
	
	return AS_AUDIO_STREAMER_FAILED_STRING;
}

//
// presentAlertWithTitle:message:
//
// Common code for presenting error dialogs
//
// Parameters:
//    title - title for the dialog
//    message - main test for the dialog
//
- (void)presentAlertWithTitle:(NSString*)title message:(NSString*)message
{
    SNDebugLog(@"%@: %@", title, message);
    return;
}

//
// failWithErrorCode:
//
// Sets the playback state to failed and logs the error.
//
// Parameters:
//    anErrorCode - the error condition
//
- (void)failWithErrorCode:(AudioStreamerErrorCode)anErrorCode
{
	@synchronized(self)
	{
		if (errorCode != AS_NO_ERROR)
		{
			// Only set the error once.
			return;
		}
		
		errorCode = anErrorCode;

		if (state == AS_PLAYING ||
			state == AS_PAUSED ||
			state == AS_BUFFERING)
		{
			self.state = AS_STOPPING;
			stopReason = AS_STOPPING_ERROR;
			AudioQueueStop(audioQueue, true);
		}

        if (![self isFinishing]) {
            [self presentAlertWithTitle:@"播放停止"
                                message:@"网络出现故障,请重试一次."];
        }		
	}
}

//
// mainThreadStateNotification
//
// Method invoked on main thread to send notifications to the main thread's
// notification center.
//
- (void)mainThreadStateNotification
{
	NSNotification *notification = [NSNotification notificationWithName:ASStatusChangedNotification object:self];
	[SNNotificationManager postNotification:notification];
}

//
// setState:
//
// Sets the state and sends a notification that the state has changed.
//
// This method
//
// Parameters:
//    anErrorCode - the error condition
//
- (void)setState:(AudioStreamerState)aStatus
{
	@synchronized(self)
	{
		if (state != aStatus)
		{
			state = aStatus;
			
			if ([[NSThread currentThread] isEqual:[NSThread mainThread]])
			{
				[self mainThreadStateNotification];
			}
			else
			{
				[self
					performSelectorOnMainThread:@selector(mainThreadStateNotification)
					withObject:nil
					waitUntilDone:NO];
			}
		}
	}
}

- (AudioStreamerState)state {
    return state;
}
//
// hintForFileExtension:
//
// Generates a first guess for the file type based on the file's extension
//
// Parameters:
//    fileExtension - the file extension
//
// returns a file type hint that can be passed to the AudioFileStream
//
+ (AudioFileTypeID)hintForFileExtension:(NSString *)fileExtension
{
	AudioFileTypeID fileTypeHint = kAudioFileAAC_ADTSType;
	if ([fileExtension isEqual:@"mp3"])
	{
		fileTypeHint = kAudioFileMP3Type;
	}
	else if ([fileExtension isEqual:@"wav"])
	{
		fileTypeHint = kAudioFileWAVEType;
	}
	else if ([fileExtension isEqual:@"aifc"])
	{
		fileTypeHint = kAudioFileAIFCType;
	}
	else if ([fileExtension isEqual:@"aiff"])
	{
		fileTypeHint = kAudioFileAIFFType;
	}
	else if ([fileExtension isEqual:@"m4a"])
	{
		fileTypeHint = kAudioFileM4AType;
	}
	else if ([fileExtension isEqual:@"mp4"])
	{
		fileTypeHint = kAudioFileMPEG4Type;
	}
	else if ([fileExtension isEqual:@"caf"])
	{
		fileTypeHint = kAudioFileCAFType;
	}
	else if ([fileExtension isEqual:@"aac"])
	{
		fileTypeHint = kAudioFileAAC_ADTSType;
	}
	return fileTypeHint;
}

//
// openReadStream
//
// Open the audioFileStream to parse data and the fileHandle as the data
// source.
//
- (BOOL)openReadStream
{
	@synchronized(self)
	{
		NSAssert([[NSThread currentThread] isEqual:internalThread],
			@"File stream download must be started on the internalThread");
		NSAssert(stream == nil, @"Download stream already initialized");
		
		//
		// Create the HTTP GET request
		//
		CFHTTPMessageRef message= CFHTTPMessageCreateRequest(NULL, (CFStringRef)@"GET", (CFURLRef)url, kCFHTTPVersion1_1);
		
		//
		// If we are creating this request to seek to a location, set the
		// requested byte range in the headers.
		//
		if (fileLength > 0 && seekByteOffset > 0)
		{
			CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Range"),
				(CFStringRef)[NSString stringWithFormat:@"bytes=%ld-%ld", (long)seekByteOffset, (long)fileLength]);
			discontinuous = YES;
		}
		
		//
		// Create the read stream that will receive data from the HTTP request
		//
		stream = CFReadStreamCreateForHTTPRequest(NULL, message);
		CFRelease(message);
		
		//
		// Enable stream redirection
		//
		if (CFReadStreamSetProperty(
			stream,
			kCFStreamPropertyHTTPShouldAutoredirect,
			kCFBooleanTrue) == false)
		{
			[self presentAlertWithTitle:NSLocalizedStringFromTable(@"File Error", @"Errors", nil)
								message:NSLocalizedStringFromTable(@"Unable to configure network read stream.", @"Errors", nil)];
			return NO;
		}
		
		//
		// Handle proxies
		//
		CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
		CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPProxy, proxySettings);
		CFRelease(proxySettings);
		
		//
		// Handle SSL connections
		//
        //if( [[url absoluteString] rangeOfString:@"https"].location != NSNotFound )
		if([SNAPI isHttpsUrl:[url absoluteString]])
		{
			NSDictionary *sslSettings =
				[NSDictionary dictionaryWithObjectsAndKeys:
					(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL, kCFStreamSSLLevel,
					[NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
					[NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredRoots,
					[NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
					[NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
					[NSNull null], kCFStreamSSLPeerName,
				nil];

			CFReadStreamSetProperty(stream, kCFStreamPropertySSLSettings, sslSettings);
		}
		
		//
		// We're now ready to receive data
		//
		self.state = AS_WAITING_FOR_DATA;

		//
		// Open the stream
		//
		if (!CFReadStreamOpen(stream))
		{
			CFRelease(stream);
			[self presentAlertWithTitle:NSLocalizedStringFromTable(@"File Error", @"Errors", nil)
								message:NSLocalizedStringFromTable(@"Unable to configure network read stream.", @"Errors", nil)];
			return NO;
		}
		
		//
		// Set our callback function to receive the data
		//
		CFStreamClientContext context = {0, self, NULL, NULL, NULL};
		CFReadStreamSetClient(
			stream,
			kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered,
			ASReadStreamCallBack,
			&context);
		CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	}
	
	return YES;
}

//
// startInternal
//
// This is the start method for the AudioStream thread. This thread is created
// because it will be blocked when there are no audio buffers idle (and ready
// to receive audio data).
//
// Activity in this thread:
//	- Creation and cleanup of all AudioFileStream and AudioQueue objects
//	- Receives data from the CFReadStream
//	- AudioFileStream processing
//	- Copying of data from AudioFileStream into audio buffers
//  - Stopping of the thread because of end-of-file
//	- Stopping due to error or failure
//
// Activity *not* in this thread:
//	- AudioQueue playback and notifications (happens in AudioQueue thread)
//  - Actual download of NSURLConnection data (NSURLConnection's thread)
//	- Creation of the AudioStreamer (other, likely "main" thread)
//	- Invocation of -start method (other, likely "main" thread)
//	- User/manual invocation of -stop (other, likely "main" thread)
//
// This method contains bits of the "main" function from Apple's example in
// AudioFileStreamExample.
//
- (void)startInternal
{
    @autoreleasepool {
        @synchronized(self)
        {
            if (state != AS_STARTING_FILE_THREAD)
            {
                if (state != AS_STOPPING &&
                    state != AS_STOPPED)
                {
                    SNDebugLog(@"### Not starting audio thread. State code is: %d", state);
                }
                self.state = AS_INITIALIZED;
                return;
            }
            
#if TARGET_OS_IPHONE
            //
            // Set the audio session category so that we continue to play if the
            // iPhone/iPod auto-locks.
            //
            AudioSessionInitialize (
                                    NULL,                          // 'NULL' to use the default (main) run loop
                                    NULL,                          // 'NULL' to use the default run loop mode
                                    MyAudioSessionInterruptionListener,  // a reference to your interruption callback
                                    self                       // data to pass to your interruption listener callback
                                    );
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty (
                                     kAudioSessionProperty_AudioCategory,
                                     sizeof (sessionCategory),
                                     &sessionCategory
                                     );
            AudioSessionSetActive(true);
#endif
            
            // initialize a mutex and condition so that we can block on buffers in use.
            pthread_mutex_init(&queueBuffersMutex, NULL);
            pthread_cond_init(&queueBufferReadyCondition, NULL);
            
            if (![self openReadStream])
            {
                goto cleanup;
            }
        }
        
        //
        // Process the run loop until playback is finished or failed.
        //
        BOOL isRunning = YES;
        do
        {
            isRunning = [[NSRunLoop currentRunLoop]
                         runMode:NSDefaultRunLoopMode
                         beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
            
            @synchronized(self) {
                if (seekWasRequested) {
                    [self internalSeekToTime:requestedSeekTime];
                    seekWasRequested = NO;
                }
            }
            
            //
            // If there are no queued buffers, we need to check here since the
            // handleBufferCompleteForQueue:buffer: should not change the state
            // (may not enter the synchronized section).
            //
            if (buffersUsed == 0 && self.state == AS_PLAYING)
            {
                err = AudioQueuePause(audioQueue);
                if (err)
                {
                    [self failWithErrorCode:AS_AUDIO_QUEUE_PAUSE_FAILED];
                    return;
                }
                self.state = AS_BUFFERING;
            }
        } while (isRunning && ![self runLoopShouldExit]);
        
    cleanup:
        
        @synchronized(self)
        {
            //
            // Cleanup the read stream if it is still open
            //
            if (stream)
            {
                CFReadStreamClose(stream);
                CFRelease(stream);
                stream = nil;
            }
            
            //
            // Close the audio file strea,
            //
            if (audioFileStream)
            {
                err = AudioFileStreamClose(audioFileStream);
                audioFileStream = nil;
                if (err)
                {
                    [self failWithErrorCode:AS_FILE_STREAM_CLOSE_FAILED];
                }
            }
            
            //
            // Dispose of the Audio Queue
            //
            if (audioQueue)
            {
                err = AudioQueueDispose(audioQueue, true);
                audioQueue = nil;
                if (err)
                {
                    [self failWithErrorCode:AS_AUDIO_QUEUE_DISPOSE_FAILED];
                }
            }
            
            pthread_mutex_destroy(&queueBuffersMutex);
            pthread_cond_destroy(&queueBufferReadyCondition);
            
#if TARGET_OS_IPHONE			
            AudioSessionSetActive(false);
#endif
            
            [httpHeaders release];
            httpHeaders = nil;
            
            bytesFilled = 0;
            packetsFilled = 0;
            seekByteOffset = 0;
            packetBufferSize = 0;
            self.state = AS_INITIALIZED;
            
            [internalThread release];
            internalThread = nil;
        }
    }
}


// internalSeekToTime:
//
// Called from our internal runloop to reopen the stream at a seeked location
//
- (void)internalSeekToTime:(double)newSeekTime
{
	if ([self calculatedBitRate] == 0.0 || fileLength <= 0)
	{
		return;
	}
	
	//
	// Calculate the byte offset for seeking
	//
	seekByteOffset = dataOffset +
		(newSeekTime / self.duration) * (fileLength - dataOffset);
		
	//
	// Attempt to leave 1 useful packet at the end of the file (although in
	// reality, this may still seek too far if the file has a long trailer).
	//
	if (seekByteOffset > fileLength - 2 * packetBufferSize)
	{
		seekByteOffset = fileLength - 2 * packetBufferSize;
	}
	
	//
	// Store the old time from the audio queue and the time that we're seeking
	// to so that we'll know the correct time progress after seeking.
	//
	seekTime = newSeekTime;
	
	//
	// Attempt to align the seek with a packet boundary
	//
	double calculatedBitRate = [self calculatedBitRate];
	if (packetDuration > 0 &&
		calculatedBitRate > 0)
	{
		UInt32 ioFlags = 0;
		SInt64 packetAlignedByteOffset;
		SInt64 seekPacket = floor(newSeekTime / packetDuration);
		err = AudioFileStreamSeek(audioFileStream, seekPacket, &packetAlignedByteOffset, &ioFlags);
		if (!err && !(ioFlags & kAudioFileStreamSeekFlag_OffsetIsEstimated))
		{
			seekTime -= ((seekByteOffset - dataOffset) - packetAlignedByteOffset) * 8.0 / calculatedBitRate;
			seekByteOffset = packetAlignedByteOffset + dataOffset;
		}
	}

	//
	// Close the current read straem
	//
	if (stream)
	{
		CFReadStreamClose(stream);
		CFRelease(stream);
		stream = nil;
	}

	//
	// Stop the audio queue
	//
	self.state = AS_STOPPING;
	stopReason = AS_STOPPING_TEMPORARILY;
	err = AudioQueueStop(audioQueue, true);
	if (err)
	{
		[self failWithErrorCode:AS_AUDIO_QUEUE_STOP_FAILED];
		return;
	}

	//
	// Re-open the file stream. It will request a byte-range starting at
	// seekByteOffset.
	//
	[self openReadStream];
}

//
// seekToTime:
//
// Attempts to seek to the new time. Will be ignored if the bitrate or fileLength
// are unknown.
//
// Parameters:
//    newTime - the time to seek to
//
- (void)seekToTime:(double)newSeekTime
{
	@synchronized(self)
	{
		seekWasRequested = YES;
		requestedSeekTime = newSeekTime;
	}
}

//
// progress
//
// returns the current playback progress. Will return zero if sampleRate has
// not yet been detected.
//
- (double)progress
{
	@synchronized(self)
	{
		if (sampleRate > 0/* && ![self isFinishing]*/)
		{
			if (state != AS_PLAYING && state != AS_PAUSED && state != AS_BUFFERING && state != AS_STOPPING)
			{
				return lastProgress;
			}

			AudioTimeStamp queueTime;
			Boolean discontinuity;
			err = AudioQueueGetCurrentTime(audioQueue, NULL, &queueTime, &discontinuity);

			const OSStatus AudioQueueStopped = 0x73746F70; // 0x73746F70 is 'stop'
			if (err == AudioQueueStopped)
			{
				return lastProgress;
			}
			else if (err)
			{
				//[self failWithErrorCode:AS_GET_AUDIO_TIME_FAILED];
			}

			double progress = seekTime + queueTime.mSampleTime / sampleRate;
			if (progress < 0.0)
			{
				progress = 0.0;
			}
			
			lastProgress = progress;
			return progress;
		}
	}
	
	return lastProgress;
}

//
// calculatedBitRate
//
// returns the bit rate, if known. Uses packet duration times running bits per
//   packet if available, otherwise it returns the nominal bitrate. Will return
//   zero if no useful option available.
//
- (double)calculatedBitRate
{
	if (packetDuration && processedPacketsCount > BitRateEstimationMinPackets)
	{
		double averagePacketByteSize = processedPacketsSizeTotal / processedPacketsCount;
		return 8.0 * averagePacketByteSize / packetDuration;
	}
	
	if (bitRate)
	{
		return (double)bitRate;
	}
	
	return 0;
}

//
// duration
//
// Calculates the duration of available audio from the bitRate and fileLength.
//
// returns the calculated duration in seconds.
//
- (double)duration
{
	double calculatedBitRate = [self calculatedBitRate];
	
	if (calculatedBitRate == 0 || fileLength == 0)
	{
		return 0.0;
	}
	
	return (fileLength - dataOffset) / (calculatedBitRate * 0.125);
}

- (NSString *)currentTime
{
    NSString *current = [NSString stringWithFormat:@"%d:%02d", 
                         (int)[self progress] / 60, 
                         (int)[self progress] % 60, nil];
    return  current;
}

- (NSString *)totalTime
{
    NSString *total = [NSString stringWithFormat:@"-%d:%02d",
                       (int)((int)([self duration] - [self progress])) / 60, 
                       (int)((int)([self duration] - [self progress])) % 60, nil];
    return total;
}


//
// start
//
// Calls startInternal in a new thread.
//
- (void)start
{
	@synchronized (self)
	{
		if (state == AS_PAUSED)
		{
			[self pause]; // will resume the player
		}
		else if (state == AS_INITIALIZED)
		{
			NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"Playback can only be started from the main thread.");
            
			self.state = AS_STARTING_FILE_THREAD;
            
			internalThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(startInternal)
                                                       object:nil];                              
            
			[internalThread start];
		}
        else if (state == AS_PLAYING)
        {
            // do nothing
        }
	}
}


//
// pause
//
// A togglable pause function between pause and play
//
- (BOOL)pause
{
	@synchronized(self)
	{
		if (state == AS_PLAYING || state == AS_STOPPING || state == AS_BUFFERING)
		{
			err = AudioQueuePause(audioQueue);
			if (err)
			{
				[self failWithErrorCode:AS_AUDIO_QUEUE_PAUSE_FAILED];
				return NO;
			}
            _laststate = state;
			self.state = AS_PAUSED;
		}
		else if (state == AS_PAUSED)
		{
			err = AudioQueueStart(audioQueue, NULL);
			if (err)
			{
				[self failWithErrorCode:AS_AUDIO_QUEUE_START_FAILED];
				return NO;
			}
			self.state = _laststate;
		}
        else {
            return NO;
        }
	}
    
    return YES;
}

//
// stop
//
// This method can be called to stop downloading/playback before it completes.
// It is automatically called when an error occurs.
//
// If playback has not started before this method is called, it will toggle the
// "isPlaying" property so that it is guaranteed to transition to true and
// back to false 
//
- (void)stop
{
	@synchronized(self)
	{
		if (audioQueue &&
			(state == AS_PLAYING || state == AS_PAUSED || state == AS_STOPPING ||
				state == AS_BUFFERING || state == AS_WAITING_FOR_QUEUE_TO_START))
		{
			self.state = AS_STOPPING;
			stopReason = AS_STOPPING_USER_ACTION;
			err = AudioQueueStop(audioQueue, true);
			if (err)
			{
				[self failWithErrorCode:AS_AUDIO_QUEUE_STOP_FAILED];
				return;
			}
		}
		else if (state != AS_INITIALIZED)
		{
			self.state = AS_STOPPED;
			stopReason = AS_STOPPING_USER_ACTION;
		}
		seekWasRequested = NO;
	}
	
	while (state != AS_INITIALIZED)
	{
		[NSThread sleepForTimeInterval:0.1];
	}
    AudioSessionSetActive(false);
}

//
// handleReadFromStream:eventType:
//
// Reads data from the network file stream into the AudioFileStream
//
// Parameters:
//    aStream - the network file stream
//    eventType - the event which triggered this method
//
- (void)handleReadFromStream:(CFReadStreamRef)aStream eventType:(CFStreamEventType)eventType
{
	if (aStream != stream)
	{
		//
		// Ignore messages from old streams
		//
		return;
	}
	
	if (eventType == kCFStreamEventErrorOccurred)
	{
		[self failWithErrorCode:AS_AUDIO_DATA_NOT_FOUND];
	}
	else if (eventType == kCFStreamEventEndEncountered)
	{
        if (_isAMR && _amrType > 0) {
            NSString *localPath = [SNSoundManager soundFileDownloadPathWithURL:[url absoluteString]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [_dataBuffer writeToFile:localPath atomically:NO];
            });
            return;
        }
        
		@synchronized(self)
		{
			if ([self isFinishing])
			{
				return;
			}
		}
		
		//
		// If there is a partially filled buffer, pass it to the AudioQueue for
		// processing
		//
		if (bytesFilled)
		{
			if (self.state == AS_WAITING_FOR_DATA)
			{
				//
				// Force audio data smaller than one whole buffer to play.
				//
				self.state = AS_FLUSHING_EOF;
			}
			[self enqueueBuffer];
		}

		@synchronized(self)
		{
			if (state == AS_WAITING_FOR_DATA)
			{
				[self failWithErrorCode:AS_AUDIO_DATA_NOT_FOUND];
			}
			
			//
			// We left the synchronized section to enqueue the buffer so we
			// must check that we are !finished again before touching the
			// audioQueue
			//
			else if (![self isFinishing])
			{
				if (audioQueue)
				{
					//
					// Set the progress at the end of the stream
					//
					err = AudioQueueFlush(audioQueue);
					if (err)
					{
						[self failWithErrorCode:AS_AUDIO_QUEUE_FLUSH_FAILED];
						return;
					}

					self.state = AS_STOPPING;
					stopReason = AS_STOPPING_EOF;
					err = AudioQueueStop(audioQueue, false);
					if (err)
					{
						[self failWithErrorCode:AS_AUDIO_QUEUE_FLUSH_FAILED];
						return;
					}
				}
				else
				{
					self.state = AS_STOPPED;
					stopReason = AS_STOPPING_EOF;
				}
			}
		}
	}
	else if (eventType == kCFStreamEventHasBytesAvailable)
	{
		if (!httpHeaders)
		{
			CFTypeRef message =
				CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
			httpHeaders =
				(NSDictionary *)CFHTTPMessageCopyAllHeaderFields((CFHTTPMessageRef)message);
			CFRelease(message);
			
			//
			// Only read the content length if we seeked to time zero, otherwise
			// we only have a subset of the total bytes.
			//
			if (seekByteOffset == 0)
			{
				fileLength = [[httpHeaders objectForKey:@"Content-Length"] integerValue];
			}
            if (_isAMR && !_dataBuffer) {
                NSInteger capacity = fileLength > 200*1024 ? 200*1024 : (fileLength > 0 ? fileLength : 0);
                _dataBuffer = [[NSMutableData alloc] initWithCapacity:capacity];
            } else {
                [_dataBuffer setLength:0];
            }
            _bufferReadIndex = 0;
		}

		if (!_isAMR && !audioFileStream)
		{
			//
			// Attempt to guess the file type from the URL. Reading the MIME type
			// from the httpHeaders might be a better approach since lots of
			// URL's don't have the right extension.
			//
			// If you have a fixed file-type, you may want to hardcode this.
			//
			AudioFileTypeID fileTypeHint =
				[AudioStreamer hintForFileExtension:[[url path] pathExtension]];

			// create an audio file stream parser
			err = AudioFileStreamOpen(self, MyPropertyListenerProc, MyPacketsProc, 
									fileTypeHint, &audioFileStream);
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_OPEN_FAILED];
				return;
			}
		}
		
		UInt8 bytes[kAQDefaultBufSize];
		CFIndex length;
		@synchronized(self)
		{
			if ([self isFinishing] || !CFReadStreamHasBytesAvailable(stream))
			{
				return;
			}
			
			//
			// Read the bytes from the stream
			//
			length = CFReadStreamRead(stream, bytes, kAQDefaultBufSize);
            
			if (length == -1)
			{
				[self failWithErrorCode:AS_AUDIO_DATA_NOT_FOUND];
				return;
			}
			
			if (length == 0)
			{
				return;
			}
            if (_isAMR) {
                SNDebugLog(@"download: %ld/%d", length, fileLength);
                [_dataBuffer appendBytes:bytes length:length];
            }
		}

        if (_isAMR) {
            //AMR-WB
            if (_amrType == 0) {
                if (!strncmp((char *)_dataBuffer.bytes, AMRWB_MAGIC, strlen(AMRWB_MAGIC))) {
                    _destate = D_IF_init();
                    _amrType = AMRWB_TYPE;
                    _bufferReadIndex = strlen(AMRWB_MAGIC);
                }
                
                //AMR-NB
                if (!strncmp((char *)_dataBuffer.bytes, AMRNB_MAGIC, strlen(AMRNB_MAGIC))) {
                    _destate = Decoder_Interface_init();
                    _amrType = AMRNB_TYPE;
                    _bufferReadIndex = strlen(AMRNB_MAGIC);
                }
                
                if (_amrType != 0) {
                    [self createQueueForPCM];
                }
                
                for (int i = 0; i < NUM_BUFFERS; ++i) {
                    //读取包数据
                    if ([self readPacketsIntoBuffer:audioQueueBuffer[i]] == 0) {
                        break;
                    }
                }
                err = AudioQueueStart(audioQueue, NULL);
                if (err)
                {
                    [self failWithErrorCode:AS_AUDIO_QUEUE_START_FAILED];
                    return;
                }
                self.state = AS_WAITING_FOR_QUEUE_TO_START;
                //self.state = AS_PLAYING;
            }
            
            //
        }
        else {
            if (discontinuous)
            {
                err = AudioFileStreamParseBytes(audioFileStream, length, bytes, kAudioFileStreamParseFlag_Discontinuity);
                if (err)
                {
                    [self failWithErrorCode:AS_FILE_STREAM_PARSE_BYTES_FAILED];
                    return;
                }
            }
            else
            {
                err = AudioFileStreamParseBytes(audioFileStream, length, bytes, 0);
                if (err)
                {
                    [self failWithErrorCode:AS_FILE_STREAM_PARSE_BYTES_FAILED];
                    return;
                }
            }
        }
        
	}
}

//
// enqueueBuffer
//
// Called from MyPacketsProc and connectionDidFinishLoading to pass filled audio
// bufffers (filled by MyPacketsProc) to the AudioQueue for playback. This
// function does not return until a buffer is idle for further filling or
// the AudioQueue is stopped.
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
- (void)enqueueBuffer
{
	@synchronized(self)
	{
		if ([self isFinishing] || stream == 0)
		{
			return;
		}
		
		inuse[fillBufferIndex] = true;		// set in use flag
		buffersUsed++;

		// enqueue buffer
		AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
		fillBuf->mAudioDataByteSize = bytesFilled;
		
		if (packetsFilled)
		{
			err = AudioQueueEnqueueBuffer(audioQueue, fillBuf, packetsFilled, packetDescs);
		}
		else
		{
			err = AudioQueueEnqueueBuffer(audioQueue, fillBuf, 0, NULL);
		}
		
		if (err)
		{
			[self failWithErrorCode:AS_AUDIO_QUEUE_ENQUEUE_FAILED];
			return;
		}

		
		if (state == AS_BUFFERING ||
			state == AS_WAITING_FOR_DATA ||
			state == AS_FLUSHING_EOF ||
			(state == AS_STOPPED && stopReason == AS_STOPPING_TEMPORARILY))
		{
			//
			// Fill all the buffers before starting. This ensures that the
			// AudioFileStream stays a small amount ahead of the AudioQueue to
			// avoid an audio glitch playing streaming files on iPhone SDKs < 3.0
			//
			if (state == AS_FLUSHING_EOF || buffersUsed == kNumAQBufs - 1)
			{
				if (self.state == AS_BUFFERING)
				{
					err = AudioQueueStart(audioQueue, NULL);
					if (err)
					{
						[self failWithErrorCode:AS_AUDIO_QUEUE_START_FAILED];
						return;
					}
					self.state = AS_PLAYING;
				}
				else
				{
					self.state = AS_WAITING_FOR_QUEUE_TO_START;

					err = AudioQueueStart(audioQueue, NULL);
					if (err)
					{
						[self failWithErrorCode:AS_AUDIO_QUEUE_START_FAILED];
						return;
					}
				}
			}
		}

		// go to next buffer
		if (++fillBufferIndex >= kNumAQBufs) fillBufferIndex = 0;
		bytesFilled = 0;		// reset bytes filled
		packetsFilled = 0;		// reset packets filled
	}

	// wait until next buffer is not in use
	pthread_mutex_lock(&queueBuffersMutex); 
	while (inuse[fillBufferIndex])
	{
		pthread_cond_wait(&queueBufferReadyCondition, &queueBuffersMutex);
	}
	pthread_mutex_unlock(&queueBuffersMutex);
}

//
// createQueue
//
// Method to create the AudioQueue from the parameters gathered by the
// AudioFileStream.
//
// Creation is deferred to the handling of the first audio packet (although
// it could be handled any time after kAudioFileStreamProperty_ReadyToProducePackets
// is true).
//
- (void)createQueue
{
	sampleRate = asbd.mSampleRate;
	packetDuration = asbd.mFramesPerPacket / sampleRate;
	
	// create the audio queue
	err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, self, NULL, NULL, 0, &audioQueue);
	if (err)
	{
		[self failWithErrorCode:AS_AUDIO_QUEUE_CREATION_FAILED];
		return;
	}
	
	// start the queue if it has not been started already
	// listen to the "isRunning" property
	err = AudioQueueAddPropertyListener(audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, self);
	if (err)
	{
		[self failWithErrorCode:AS_AUDIO_QUEUE_ADD_LISTENER_FAILED];
		return;
	}
	
	// get the packet size if it is available
	UInt32 sizeOfUInt32 = sizeof(UInt32);
	err = AudioFileStreamGetProperty(audioFileStream, kAudioFileStreamProperty_PacketSizeUpperBound, &sizeOfUInt32, &packetBufferSize);
	if (err || packetBufferSize == 0)
	{
		err = AudioFileStreamGetProperty(audioFileStream, kAudioFileStreamProperty_MaximumPacketSize, &sizeOfUInt32, &packetBufferSize);
		if (err || packetBufferSize == 0)
		{
			// No packet size available, just use the default
			packetBufferSize = kAQDefaultBufSize;
		}
	}

	// allocate audio queue buffers
	for (unsigned int i = 0; i < kNumAQBufs; ++i)
	{
		err = AudioQueueAllocateBuffer(audioQueue, packetBufferSize, &audioQueueBuffer[i]);
		if (err)
		{
			[self failWithErrorCode:AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED];
			return;
		}
	}

	// get the cookie size
	UInt32 cookieSize;
	Boolean writable;
	OSStatus ignorableError;
	ignorableError = AudioFileStreamGetPropertyInfo(audioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
	if (ignorableError)
	{
        // set the software codec too on the queue.
        UInt32 val = kAudioQueueHardwareCodecPolicy_PreferSoftware;
        ignorableError = AudioQueueSetProperty(audioQueue, kAudioQueueProperty_HardwareCodecPolicy, &val, sizeOfUInt32);
        return;
	}

	// get the cookie data
	void* cookieData = calloc(1, cookieSize);
	ignorableError = AudioFileStreamGetProperty(audioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
	if (ignorableError)
	{
		return;
	}

	// set the cookie on the queue.
	ignorableError = AudioQueueSetProperty(audioQueue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
	free(cookieData);
	if (ignorableError)
	{
		return;
	}
}

//
// handlePropertyChangeForFileStream:fileStreamPropertyID:ioFlags:
//
// Object method which handles implementation of MyPropertyListenerProc
//
// Parameters:
//    inAudioFileStream - should be the same as self->audioFileStream
//    inPropertyID - the property that changed
//    ioFlags - the ioFlags passed in
//
- (void)handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream
	fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID
	ioFlags:(UInt32 *)ioFlags
{
	@synchronized(self)
	{
		if ([self isFinishing])
		{
			return;
		}
		
		if (inPropertyID == kAudioFileStreamProperty_ReadyToProducePackets)
		{
			discontinuous = true;
		}
		else if (inPropertyID == kAudioFileStreamProperty_DataOffset) // get property: dataOffset
		{
			SInt64 offset;
			UInt32 offsetSize = sizeof(offset);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataOffset, &offsetSize, &offset);
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_GET_PROPERTY_FAILED];
				return;
			}
			dataOffset = offset;
			
			if (audioDataByteCount)
			{
				fileLength = dataOffset + audioDataByteCount;
			}
		}
		else if (inPropertyID == kAudioFileStreamProperty_AudioDataByteCount) // get property: audioDataByteCount
		{
			UInt32 byteCountSize = sizeof(UInt64);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_AudioDataByteCount, &byteCountSize, &audioDataByteCount);
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_GET_PROPERTY_FAILED];
				return;
			}
			fileLength = dataOffset + audioDataByteCount;
		}
		else if (inPropertyID == kAudioFileStreamProperty_DataFormat) // get property: absd
		{
			if (asbd.mSampleRate == 0)
			{
				UInt32 asbdSize = sizeof(asbd);
				
				// get the stream format.
				err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
				if (err)
				{
					[self failWithErrorCode:AS_FILE_STREAM_GET_PROPERTY_FAILED];
					return;
				}
			}
		}
		else if (inPropertyID == kAudioFileStreamProperty_FormatList)
		{
			Boolean outWriteable;
			UInt32 formatListSize;
			err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_FormatList, &formatListSize, &outWriteable);
			if (err)
			{
				[self failWithErrorCode:AS_FILE_STREAM_GET_PROPERTY_FAILED];
				return;
			}
			
			AudioFormatListItem *formatList = malloc(formatListSize);
	        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_FormatList, &formatListSize, formatList);
			if (err)
			{
                free(formatList);
				[self failWithErrorCode:AS_FILE_STREAM_GET_PROPERTY_FAILED];
				return;
			}

			for (int i = 0; i * sizeof(AudioFormatListItem) < formatListSize; i += sizeof(AudioFormatListItem))
			{
				AudioStreamBasicDescription pasbd = formatList[i].mASBD;
		
				if (pasbd.mFormatID == kAudioFormatMPEG4AAC_HE)
				{
					//
					// We've found HE-AAC, remember this to tell the audio queue
					// when we construct it.
					//
#if !TARGET_IPHONE_SIMULATOR
					asbd = pasbd;
#endif
					break;
				}                                
			}
			free(formatList);
		}
	}
}

//
// handleAudioPackets:numberBytes:numberPackets:packetDescriptions:
//
// Object method which handles the implementation of MyPacketsProc
//
// Parameters:
//    inInputData - the packet data
//    inNumberBytes - byte size of the data
//    inNumberPackets - number of packets in the data
//    inPacketDescriptions - packet descriptions
//
- (void)handleAudioPackets:(const void *)inInputData
	numberBytes:(UInt32)inNumberBytes
	numberPackets:(UInt32)inNumberPackets
	packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;
{
	@synchronized(self)
	{
		if ([self isFinishing])
		{
			return;
		}
		
		if (bitRate == 0)
		{
			//
			// m4a and a few other formats refuse to parse the bitrate so
			// we need to set an "unparseable" condition here. If you know
			// the bitrate (parsed it another way) you can set it on the
			// class if needed.
			//
			bitRate = ~0;
		}
		
		// we have successfully read the first packests from the audio stream, so
		// clear the "discontinuous" flag
		if (discontinuous)
		{
			discontinuous = false;
		}
		
		if (!audioQueue)
		{
			[self createQueue];
		}
	}

	// the following code assumes we're streaming VBR data. for CBR data, the second branch is used.
	if (inPacketDescriptions)
	{
		for (int i = 0; i < inNumberPackets; ++i)
		{
			SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
			SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
			size_t bufSpaceRemaining;
			
			if (processedPacketsCount < BitRateEstimationMaxPackets)
			{
				processedPacketsSizeTotal += packetSize;
				processedPacketsCount += 1;
			}
			
			@synchronized(self)
			{
				// If the audio was terminated before this point, then
				// exit.
				if ([self isFinishing])
				{
					return;
				}
				
				if (packetSize > packetBufferSize)
				{
					[self failWithErrorCode:AS_AUDIO_BUFFER_TOO_SMALL];
				}

				bufSpaceRemaining = packetBufferSize - bytesFilled;
			}

			// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
			if (bufSpaceRemaining < packetSize)
			{
				[self enqueueBuffer];
			}
			
			@synchronized(self)
			{
				// If the audio was terminated while waiting for a buffer, then
				// exit.
				if ([self isFinishing])
				{
					return;
				}
				
				//
				// If there was some kind of issue with enqueueBuffer and we didn't
				// make space for the new audio data then back out
				//
				if (bytesFilled + packetSize > packetBufferSize)
				{
					return;
				}
				
				// copy data to the audio queue buffer
				AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
				memcpy((char*)fillBuf->mAudioData + bytesFilled, (const char*)inInputData + packetOffset, packetSize);

				// fill out packet description
				packetDescs[packetsFilled] = inPacketDescriptions[i];
				packetDescs[packetsFilled].mStartOffset = bytesFilled;
				// keep track of bytes filled and packets filled
				bytesFilled += packetSize;
				packetsFilled += 1;
			}
			
			// if that was the last free packet description, then enqueue the buffer.
			size_t packetsDescsRemaining = kAQMaxPacketDescs - packetsFilled;
			if (packetsDescsRemaining == 0) {
				[self enqueueBuffer];
			}
		}	
	}
	else
	{
		size_t offset = 0;
		while (inNumberBytes)
		{
			// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
			size_t bufSpaceRemaining = kAQDefaultBufSize - bytesFilled;
			if (bufSpaceRemaining < inNumberBytes)
			{
				[self enqueueBuffer];
			}
			
			@synchronized(self)
			{
				// If the audio was terminated while waiting for a buffer, then
				// exit.
				if ([self isFinishing])
				{
					return;
				}
				
				bufSpaceRemaining = kAQDefaultBufSize - bytesFilled;
				size_t copySize;
				if (bufSpaceRemaining < inNumberBytes)
				{
					copySize = bufSpaceRemaining;
				}
				else
				{
					copySize = inNumberBytes;
				}

				//
				// If there was some kind of issue with enqueueBuffer and we didn't
				// make space for the new audio data then back out
				//
				if (bytesFilled > packetBufferSize)
				{
					return;
				}
				
				// copy data to the audio queue buffer
				AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
				memcpy((char*)fillBuf->mAudioData + bytesFilled, (const char*)(inInputData + offset), copySize);


				// keep track of bytes filled and packets filled
				bytesFilled += copySize;
				packetsFilled = 0;
				inNumberBytes -= copySize;
				offset += copySize;
			}
		}
	}
}

//
// handleBufferCompleteForQueue:buffer:
//
// Handles the buffer completetion notification from the audio queue
//
// Parameters:
//    inAQ - the queue
//    inBuffer - the buffer
//
- (void)handleBufferCompleteForQueue:(AudioQueueRef)inAQ
	buffer:(AudioQueueBufferRef)inBuffer
{
	unsigned int bufIndex = -1;
	for (unsigned int i = 0; i < kNumAQBufs; ++i)
	{
		if (inBuffer == audioQueueBuffer[i])
		{
			bufIndex = i;
			break;
		}
	}
	
	if (bufIndex == -1)
	{
		[self failWithErrorCode:AS_AUDIO_QUEUE_BUFFER_MISMATCH];
		pthread_mutex_lock(&queueBuffersMutex);
		pthread_cond_signal(&queueBufferReadyCondition);
		pthread_mutex_unlock(&queueBuffersMutex);
		return;
	}
	
	// signal waiting thread that the buffer is free.
	pthread_mutex_lock(&queueBuffersMutex);
	inuse[bufIndex] = false;
	buffersUsed--;

//
//  Enable this logging to measure how many buffers are queued at any time.
//
#if LOG_QUEUED_BUFFERS
	SNDebugLog(@"Queued buffers: %d", buffersUsed);
#endif
	
	pthread_cond_signal(&queueBufferReadyCondition);
	pthread_mutex_unlock(&queueBuffersMutex);
}

- (void)handlePropertyChange:(NSNumber *)num
{
	[self handlePropertyChangeForQueue:NULL propertyID:[num intValue]];
}

//
// handlePropertyChangeForQueue:propertyID:
//
// Implementation for MyAudioQueueIsRunningCallback
//
// Parameters:
//    inAQ - the audio queue
//    inID - the property ID
//
- (void)handlePropertyChangeForQueue:(AudioQueueRef)inAQ
	propertyID:(AudioQueuePropertyID)inID
{
    @autoreleasepool {
        @synchronized(self)
        {
            if (inID == kAudioQueueProperty_IsRunning)
            {
                if (state == AS_STOPPING)
                {
                    //                self.state = AS_STOPPED;
                    //                // Should check value of isRunning
                    UInt32 isRunning = 0;
                    UInt32 size = sizeof(UInt32);
                    AudioQueueGetProperty(audioQueue, inID, &isRunning, &size);
                    if (isRunning == 0) {
                        self.state = AS_STOPPED;
                    }
                }
                else if (state == AS_WAITING_FOR_QUEUE_TO_START)
                {
                    //
                    // Note about this bug avoidance quirk:
                    //
                    // On cleanup of the AudioQueue thread, on rare occasions, there would
                    // be a crash in CFSetContainsValue as a CFRunLoopObserver was getting
                    // removed from the CFRunLoop.
                    //
                    // After lots of testing, it appeared that the audio thread was
                    // attempting to remove CFRunLoop observers from the CFRunLoop after the
                    // thread had already deallocated the run loop.
                    //
                    // By creating an NSRunLoop for the AudioQueue thread, it changes the
                    // thread destruction order and seems to avoid this crash bug -- or
                    // at least I haven't had it since (nasty hard to reproduce error!)
                    //
                    [NSRunLoop currentRunLoop];
                    
                    self.state = AS_PLAYING;
                }
                else
                {
                    SNDebugLog(@"AudioQueue changed state in unexpected way.");
                }
            }
        }
    }
}

#if TARGET_OS_IPHONE
//
// handleInterruptionChangeForQueue:propertyID:
//
// Implementation for MyAudioQueueInterruptionListener
//
// Parameters:
//    inAQ - the audio queue
//    inID - the property ID
//
- (void)handleInterruptionChangeToState:(NSNotification *)notification {
    AudioQueuePropertyID inInterruptionState = (AudioQueuePropertyID) [notification.object unsignedIntValue];
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if ([self isPlaying]) {
			[self pause];
			
			pausedByInterruption = YES;
		}
	}
	else if (inInterruptionState == kAudioSessionEndInterruption)
	{
		AudioSessionSetActive( true );
		
		if ([self isPaused] && pausedByInterruption) {
			[self pause]; // this is actually resume
			
			pausedByInterruption = NO; // this is redundant
		}
	}
}
#endif

//
#pragma mark - 
- (void)createQueueForPCM {
    //--设置音频数据格式
    AudioStreamBasicDescription dataFormat;
    memset(&dataFormat, 0, sizeof(dataFormat));
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mSampleRate = (_amrType == AMRWB_TYPE ? 16000.0 : 8000.0);
    dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mChannelsPerFrame = 1;
    dataFormat.mFramesPerPacket = 1;
    dataFormat.mBytesPerFrame = (dataFormat.mBitsPerChannel/8) * dataFormat.mChannelsPerFrame;
    dataFormat.mBytesPerPacket = dataFormat.mBytesPerFrame;
    
    sampleRate = dataFormat.mSampleRate;
    //---
    
    // 创建播放用的音频队列(nil:audio队列的间隙线程)
    AudioQueueNewOutput(&dataFormat, BufferCallback,self, nil, nil, 0, &audioQueue);
    
    // 创建并分配缓存空间
    //packetIndex = 0;
    gBufferSizeBytes = KSECONDSPERBUFFER *  2 * 160 * 50 *2; //MR122 size * 2
    
    if (_amrType == AMRWB_TYPE) {
        gBufferSizeBytes *= 2;
    }
    
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueAllocateBuffer(audioQueue, gBufferSizeBytes, &audioQueueBuffer[i]);
    }
    
    //设置监听
    AudioQueueAddPropertyListener(audioQueue, kAudioQueueProperty_IsRunning, isRunningProc, self);
    
    //设置音量
    AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
}

- (NSInteger)readBuffer:(char *)dest count:(size_t)count {
    NSInteger dataBufLen = _dataBuffer.length;
    if (_bufferReadIndex + count <= dataBufLen) {
        memcpy(dest, _dataBuffer.bytes + _bufferReadIndex, count);
        return count;
    } else if (_bufferReadIndex < dataBufLen) {
        NSInteger remainCnt = dataBufLen - _bufferReadIndex;
        memcpy(dest, _dataBuffer.bytes + _bufferReadIndex, remainCnt);
        return remainCnt;
    }
    return 0;
}

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer {
    short pcmBuf[1600*2] = {0}; //KSECONDSPERBUFFER * 160 * 50
    
    int readAMRFrame = 0;
    static const short block_size[16] = {12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0};
    static const int wb_block_size[] = {17, 23, 32, 36, 40, 46, 50, 58, 60, 5, -1, -1, -1, -1, -1, 0};
    char analysis[64]={0};
    
    NSInteger rCout=0;
    while (readAMRFrame < PERREADFRAME && (rCout = [self readBuffer:analysis count:1]))
    {
        _hasReadSize += rCout;
        _bufferReadIndex += 1;
        
        int dec_mode = (analysis[0] >> 3) & 0x000F;
        
        int read_size = (_amrType == AMRWB_TYPE ? wb_block_size[dec_mode] : block_size[dec_mode]);
        rCout = [self readBuffer:&analysis[1] count:read_size];
        
        _hasReadSize += rCout;
        
        if (rCout == read_size) {
            _bufferReadIndex += read_size;
        } else {
            _bufferReadIndex -= 1;
            break;
        }
        
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
        AudioQueueEnqueueBuffer(audioQueue, buffer, 0, NULL);
        ++buffersUsed;
    }
    return readAMRFrame;
}

- (void)audioQueueOutputWithQueue:(AudioQueueRef)aaudioQueue
                       queueBuffer:(AudioQueueBufferRef)aaudioQueueBuffer {
    if (_dataBuffer) {
        --buffersUsed;
        int readAMRFrame = [self readPacketsIntoBuffer:aaudioQueueBuffer];
        if (readAMRFrame <= 0 && buffersUsed == 0) {
            if (_bufferReadIndex >= fileLength) {
                self.state = AS_STOPPED;
                _isDone = YES;
                AudioQueueStop(aaudioQueue, false);
            } else {
                self.state = AS_BUFFERING;
                AudioQueuePause(aaudioQueue);
            }
        }
    }
}

- (void)notifyDelegatePlaybackStateChanged:(id)sender
{
    if (![self isPlaying] && _isDone)
    {
        SNDebugLog(@"end");
        [self releaseDecoder];
//        [delegate sound:self didFinishPlaying:YES];
//        [
    }
}

- (void)releaseDecoder {
    if (_destate) {
        if (_amrType == AMRNB_TYPE) {
            Decoder_Interface_exit(_destate);
        } else if (_amrType == AMRWB_TYPE) {
            D_IF_exit(_destate);
        }
        _destate = NULL;
    }
}

@end


