//
//  SNSoundManager.m
//  sohunews
//
//  Created by chenhong on 13-4-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSoundManager.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "SNDownloaderRequest.h"

@interface SNSoundManager () {
    ASINetworkQueue *_downloadingQueue;
    NSMutableArray *_downloadingRequests;    
    ASIHTTPRequest *_currentRequest;
    
    AVAudioSession *_audioSession;		// Reference to an audio session
	NSError *_audioSessionError;			// Audiosession errors are placed in this ivar
    
    NSString *_soundCategory;
    
    AVAudioPlayer *_player;
    
    SNAudioStreamPlayer *_streamPlayer;
    
    AMRPlayer *_amrPlayer;
    
    NSMutableDictionary *_statusDictForAllSounds;
    
//    NSTimer *_updateTimer;

    BOOL _isAMR;
    
    BOOL _isSoundPlayingWhenResignActive;
}

@property(nonatomic, strong) ASIHTTPRequest *currentRequest;
@property(nonatomic, strong) AVAudioPlayer *player;

- (BOOL)isAudioPlaying;

@end

@implementation SNSoundManager

@synthesize currentRequest=_currentRequest;
@synthesize player=_player;
@synthesize sndItemPlaying=_sndItemPlaying;
@synthesize sndItemNextToPlay=_sndItemNextToPlay;
@synthesize playCommentId = _playCommentId;
//@synthesize delegate;

+ (SNSoundManager *)sharedInstance {
    static SNSoundManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SNSoundManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initDownloadQueue];
        _statusDictForAllSounds = [[NSMutableDictionary alloc] initWithCapacity:5];
        
//        [SNNotificationManager addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
//        [SNNotificationManager addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    //[SNNotificationManager removeObserver:self];
    [self cancelAllDownloads];
    [_downloadingQueue reset];
     //(_downloadingQueue);
     //(_downloadingRequests);
     //(_currentRequest);
    
    _player.delegate = nil;
     //(_player);
    _amrPlayer.delegate = nil;
     //(_amrPlayer);
    _streamPlayer.delegate = nil;
     //(_streamPlayer);
    
     //(_sndItemPlaying);
     //(_sndItemNextToPlay);
     //(_statusDictForAllSounds);
    
//    TT_INVALIDATE_TIMER(_updateTimer);
     //(_playCommentId);
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (_isSoundPlayingWhenResignActive) {
        [self setSessionActive:YES];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    _isSoundPlayingWhenResignActive = (self.sndItemPlaying != nil);
    [self setSessionActive:NO];
}

- (void)setupCategoryForPlay {
    // Grab a reference to the AVAudioSession singleton
    _audioSession = [AVAudioSession sharedInstance];

    // Reset the error ivar
    NSError * audioSessionError = nil;

    // Check to see if music is already playing. If that is the case then you can leave the sound category as AmbientSound.
    // If music is not playing we can set the sound category to SoloAmbientSound so that decoding is done using the hardware.
    //		BOOL isExternalAudioPlaying = [self isAudioPlaying];

    _soundCategory = AVAudioSessionCategorySoloAmbient;

    // Having decided on the category we then set it
    [_audioSession setCategory:_soundCategory error:&audioSessionError];

    if (audioSessionError) {
        SNDebugLog(@"WARNING - SoundManager: Unable to set the sound category to %@", _soundCategory);
    }
}


#pragma mark - 播放
- (BOOL)playSound:(SNSoundItem *)sndItem {
    if (sndItem.localPath.length == 0) {
        return NO;
    }
    SNDebugLog(@"playSound: localPath: %@\n url: %@", sndItem.localPath, sndItem.url);
    
    if (_player) {
        if (_player.isPlaying) {
            [_player stop];
        }
        _player = nil;
    }
    
    if (_amrPlayer && _amrPlayer.isPlaying) {
        [_amrPlayer stop];
    }
    
    if (_streamPlayer && (_streamPlayer.isPlaying || _streamPlayer.isWaiting)) {
        [_streamPlayer stop];
    }
    
    if (_streamPlayer && _streamPlayer.isPaused && ![_streamPlayer.url isEqualToString:sndItem.url]) {
        [_streamPlayer stop];
    }

    [self notifySoundPlayFinished];

    // 停止所有视频
    [SNNotificationManager postNotificationName:kSNPlayerViewPauseVideoNotification object:nil];
    
//    if (_updateTimer) {
//		TT_INVALIDATE_TIMER(_updateTimer);
//    }

    [self setupCategoryForPlay];

    BOOL bOK = NO;
    
    if ([[sndItem.url lowercaseString] hasSuffix:@".amr"] /*&&
        [[NSFileManager defaultManager] fileExistsAtPath:sndItem.localPath]*/) {
        if (_amrPlayer == nil) {
            _amrPlayer = [[AMRPlayer alloc] init];
            _amrPlayer.delegate = self;
        }

        bOK = [_amrPlayer startPlay:[sndItem.localPath UTF8String]];
        if (bOK) {
            self.sndItemPlaying = sndItem;
            
            [self setStatus:SNSoundStatusPlaying soundItem:sndItem];
            
            _isAMR = YES;
            
            // 通知
            [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
        }
    }
    else if (/*[[sndItem.url lowercaseString] hasSuffix:@".amr"] ||*/
               [[sndItem.url lowercaseString] hasSuffix:@".mp3"]) {
        if (_streamPlayer == nil) {
            _streamPlayer = [[SNAudioStreamPlayer alloc] init];
            _streamPlayer.delegate = self;
        }
        [_streamPlayer play:sndItem.url];
        
        bOK = YES;
        
        self.sndItemPlaying = sndItem;
        
        [self setStatus:SNSoundStatusDownloading soundItem:sndItem];
        
        _isAMR = NO;
        
        // 通知
        [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
    }
    else {
        NSError *err = nil;
                
        NSURL *fileURL = [NSURL fileURLWithPath:sndItem.localPath];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err];
//        NSData *data = [NSData dataWithContentsOfFile:sndItem.localPath];
//        _player = [[AVAudioPlayer alloc] initWithData:data error:&err];

        if (err || !_player) {
            SNDebugLog(@"err playSound: %@", err);
            return bOK;
        }

        _player.delegate = self;
        
        bOK = [_player play];
        if (bOK) {
            self.sndItemPlaying = sndItem;
            
            [self setStatus:SNSoundStatusPlaying soundItem:sndItem];
            
            _isAMR = NO;
            
            // 通知
            [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
        }
    }
    
//    if (bOK) {
//        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
//    }
    return bOK;
}

- (void)setSessionActive:(BOOL)bActive {
    NSError * audioSessionError = nil;
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(setActive:withOptions:error:)]) {
        [[AVAudioSession sharedInstance] setActive:bActive withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&audioSessionError];
    } else {
        [[AVAudioSession sharedInstance] setActive:bActive withFlags:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&audioSessionError];
    }
}

- (void)pause {
    if (_isAMR) {
        [_amrPlayer pause];
    } else {
        [_player pause];
        [_streamPlayer pause];
    }

//    TT_INVALIDATE_TIMER(_updateTimer);
    
    [self setSessionActive:NO];
}

- (BOOL)resume {
    [self setSessionActive:YES];
    
    BOOL bOK = NO;
    if (_isAMR) {
        bOK = [_amrPlayer resume];
    } else {
        bOK = [_player play];
        [_streamPlayer play:self.sndItemPlaying.url];
    }
    
//    if (bOK) {
//        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
//    }
    return bOK;
}

- (void)stopByUrl:(NSString *)url {
    if ([_sndItemPlaying.url isEqualToString:url]) {
        if (_streamPlayer && [_streamPlayer.url isEqualToString:url]) {
            [_streamPlayer stop];
             //(_streamPlayer);
            
            [self notifySoundPlayFinished];
        } else if (_amrPlayer && _amrPlayer.isPlaying) {
            if ([_amrPlayer.url isEqualToString:/*_sndItemPlaying.localPath*/url]) {
                [_amrPlayer stop];
                [self notifySoundPlayFinished];
            }
        }
    }
}

- (BOOL)pauseByUrl:(NSString *)url {
    BOOL ret = YES;
    if ([_sndItemPlaying.url isEqualToString:url]) {
        if (_streamPlayer && [_streamPlayer.url isEqualToString:url]) {
            ret = [_streamPlayer pause];
        } else if (_amrPlayer && _amrPlayer.isPlaying) {
            if ([_amrPlayer.url isEqualToString:/*_sndItemPlaying.localPath*/url]) {
                [_amrPlayer stop];
                [self notifySoundPlayFinished];
            }
        }
    }
    return ret;
}

- (void)stopAmr {
    if (_amrPlayer && _amrPlayer.isPlaying) {
        [_amrPlayer stop];
        [self notifySoundPlayFinished];
    }
}

- (void)stopAll {
    if (_isAMR) {
        if (_amrPlayer && _amrPlayer.isPlaying) {
            [_amrPlayer stop];
        }
    } else {
        if (_player.isPlaying) {
            [_player stop];
        }
        if (_streamPlayer) {
            [_streamPlayer stop];
             //(_streamPlayer);
        }
    }
    
    [self notifySoundPlayFinished];
}

- (void)notifySoundPlayFinished {
    if (self.sndItemPlaying.url) {
        NSString *tag = [[TTURLCache sharedCache] keyForURL:self.sndItemPlaying.url];
        NSString *sndId = [NSString stringWithFormat:@"snd%@", tag];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:sndId, @"id", self.sndItemPlaying.localPath, @"url", nil];
        
        [self setStatus:SNSoundStatusDefault soundItem:self.sndItemPlaying];
        
        self.sndItemPlaying = nil;
        
        [SNNotificationManager postNotificationName:kSoundPlayFinished object:userInfo];
    }
    
//    TT_INVALIDATE_TIMER(_updateTimer);
    [self setSessionActive:NO];
}

- (void)notifySoundPlayStatusChanged {
    [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    SNDebugLog(@"%@ %d", NSStringFromSelector(_cmd), flag);

    [self notifySoundPlayFinished];

     //(_player);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    SNDebugLog(@"audioPlayerDecodeErrorDidOccur: %@", error);
    
    [self notifySoundPlayFinished];
    
     //(_player);
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));

    [self notifySoundPlayFinished];
    
     //(_player);
}

#pragma mark -
#pragma mark AVAudioSessionDelegate

- (void)beginInterruption {
	SNDebugLog(@"%@", @"beginInterruption");
	[self setActivated:NO];
}

- (void)endInterruption {
    SNDebugLog(@"%@", @"endInterruption");
	[self setActivated:YES];
}

#pragma mark -
#pragma mark Interruption handling

- (void)setActivated:(BOOL)aState {
    
    if(aState) {
        SNDebugLog(@"%@", @"INFO - SoundManager: active");
        NSError * audioSessionError = nil;
        // Set the AudioSession AudioCategory to what has been defined in soundCategory
		[_audioSession setCategory:_soundCategory error:&audioSessionError];
        if(_audioSessionError) {
            SNDebugLog(@"%@", @"ERROR - SoundManager: Unable to set the audio session category");
            return;
        }
        
        // Set the audio session state to true and report any errors
        _audioSessionError = nil;
		[_audioSession setActive:YES error:&audioSessionError];
		if (_audioSessionError) {
            SNDebugLog(@"ERROR - SoundManager: Unable to set the audio session state to YES with error.");
            return;
        }
        
        if (_isAMR) {
            if ([_amrPlayer resume]) {
                [self setStatus:SNSoundStatusPlaying soundItem:self.sndItemPlaying];
            }
        }
		if (_player) {
			if ([_player play] ) {
                [self setStatus:SNSoundStatusPlaying soundItem:self.sndItemPlaying];
            }
		}
        if (_streamPlayer) {
            
        }
    } else {
        SNDebugLog(@"%@", @"INFO - SoundManager: inactive");
    }
}


- (BOOL)isAudioPlaying {
    
	UInt32 audioPlaying = 0;
	UInt32 audioPlayingSize = sizeof(audioPlaying);
    
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &audioPlayingSize, &audioPlaying);
    
	return (BOOL)audioPlaying;
}

//- (void)updateCurrentTime {
//    if (delegate) {
//        [delegate sndItemPlaying:self.sndItemPlaying progressChanged:self.player.currentTime];
//    }
//    SNDebugLog(@"playTime: %f", self.player.currentTime);
//}

//- (void)updateCurrentTimeAMR {
//    if (delegate) {
//        [delegate sndItemPlaying:self.sndItemPlaying progressChanged:[_amrPlayer currentTime]];
//    }
//    SNDebugLog(@"playTime: %f", [_amrPlayer currentTime]);
//}

- (void)getCurrentTime:(CGFloat *)currTime duration:(CGFloat *)dur {
    if (currTime) {
        *currTime = _streamPlayer.progress;
    }
    if (dur) {
        *dur = _streamPlayer.duration;
    }
}

#pragma mark - AMRPlayerDelegate
- (void)sound:(AMRPlayer*)sender didFinishPlaying:(BOOL)state {
    [self notifySoundPlayFinished];
}

#pragma mark - SNAudioStreamPlayerDelegate
- (void)audioStreamPlayerDoLoading:(SNAudioStreamPlayer *)sender {
    if ([self statusForSoundItem:self.sndItemPlaying] != SNSoundStatusDownloading) {
        [self setStatus:SNSoundStatusDownloading soundItem:self.sndItemPlaying];
        [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
    }
}

- (void)audioStreamPlayerDidStop:(SNAudioStreamPlayer *)sender {
    if ([self statusForSoundItem:self.sndItemPlaying] != SNSoundStatusDefault) {
        [self notifySoundPlayFinished];
    }
}

- (void)audioStreamPlayerDidPause:(SNAudioStreamPlayer *)sender {
    if ([self statusForSoundItem:self.sndItemPlaying] != SNSoundStatusDefault) {
        [self setStatus:SNSoundStatusDefault soundItem:self.sndItemPlaying];
        [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
    }
}

- (void)audioStreamPlayerDoPlay:(SNAudioStreamPlayer *)sender {
    if ([self statusForSoundItem:self.sndItemPlaying] != SNSoundStatusPlaying) {
        [self setStatus:SNSoundStatusPlaying soundItem:self.sndItemPlaying];
        [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
    }
}

- (void)audioStreamPlayerDidFailedToPlay:(SNAudioStreamPlayer *)sender {
    if ([self statusForSoundItem:self.sndItemPlaying] != SNSoundStatusDownloadFailed) {    
        [self setStatus:SNSoundStatusDownloadFailed soundItem:self.sndItemPlaying];
        [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
    }
}

#pragma mark - 下载
- (void)initDownloadQueue {
    _downloadingQueue = [[ASINetworkQueue alloc] init];
    [_downloadingQueue setShouldCancelAllRequestsOnFailure:NO];
    [_downloadingQueue setDelegate:self];
    [_downloadingQueue setShowAccurateProgress:YES];
    [_downloadingQueue setMaxConcurrentOperationCount:1];
    [_downloadingQueue go];
}

- (void)downloadSoundItem:(SNSoundItem *)sndItem {
    if (sndItem.url.length > 0) {
        if (!_downloadingRequests) {
            _downloadingRequests = [[NSMutableArray alloc] init];
        }
        
        if ([self isSoundItemDownloading:sndItem]) {
            return;
        }
        
        NSURL *_tmpDownloadingURL = [NSURL URLWithString:sndItem.url];
        SNDownloaderSndRequest *downloadingRequest = [SNDownloaderSndRequest requestWithURL:_tmpDownloadingURL];
        downloadingRequest.delegate = self;
        downloadingRequest.downloadProgressDelegate = self;
        downloadingRequest.allowResumeForFileDownloads = YES;
        downloadingRequest.showAccurateProgress = YES;
        downloadingRequest.validatesSecureCertificate = NO;
        downloadingRequest.downloadDestinationPath = [[self class] soundFileDownloadPathWithURL:sndItem.url];
        downloadingRequest.timeOutSeconds = 20;
        downloadingRequest.numberOfTimesToRetryOnTimeout = 0;
        [downloadingRequest setUserInfo:[NSDictionary dictionaryWithObject:sndItem forKey:kSndDownloadUserInfoKey]];
        [_downloadingQueue addOperation:downloadingRequest];
        [_downloadingRequests addObject:downloadingRequest];
        
        sndItem.localPath = downloadingRequest.downloadDestinationPath;
        [self setStatus:SNSoundStatusDownloading soundItem:sndItem];

        SNDebugLog(@"==downloading sound: %@\n localPath %@", sndItem.url, sndItem.localPath);
    }
}

- (BOOL)isSoundItemDownloading:(SNSoundItem *)sndItem {
    if (sndItem.url.length > 0) {
        SNDownloaderSndRequest *reqToFind = nil;
        for (SNDownloaderSndRequest *req in _downloadingRequests) {
            SNSoundItem *item = [req.userInfo objectForKey:kSndDownloadUserInfoKey];
            if ([item.url isEqualToString:sndItem.url]) {
                reqToFind = req;
                break;
            }
        }
        
        if (reqToFind) {
            return YES;
        }
    }
    return NO;
}

- (void)cancelAllDownloads {
    if (_downloadingQueue) {
        [_downloadingQueue cancelAllOperations];
    }
    
    for (SNDownloaderSndRequest *req in _downloadingRequests) {
        [req setDelegate:nil];
        [req setDownloadProgressDelegate:nil];
        [req setUploadProgressDelegate:nil];
        [req cancel];
    }
    
    [_downloadingRequests removeAllObjects];
    self.currentRequest = nil;
    
    [self clearAllDownloadingStatus];
}

- (SNSoundStatusType)statusForSoundItem:(SNSoundItem *)sndItem {
    if (sndItem.url.length > 0) {
        NSNumber *status = [_statusDictForAllSounds objectForKey:sndItem.url];
        return [status intValue];
    }
    return SNSoundStatusDefault;
}

- (void)setStatus:(SNSoundStatusType)status soundItem:(SNSoundItem *)sndItem {
    if (sndItem.url.length > 0) {
        [_statusDictForAllSounds setObject:[NSNumber numberWithInt:status] forKey:sndItem.url];
    }
}

- (SNSoundStatusType)statusForSoundUrl:(NSString *)sndUrl {
    if (sndUrl && [sndUrl isKindOfClass:[NSString class]]) {
        if (sndUrl.length > 0) {
            NSNumber *status = [_statusDictForAllSounds objectForKey:sndUrl];
            if ([status isKindOfClass:[NSNumber class]]) {
                return [status intValue];
            }
        }
    }
    return SNSoundStatusDefault;
}

- (void)clearAllStatus {
    [_statusDictForAllSounds removeAllObjects];
    _statusDictForAllSounds = [[NSMutableDictionary alloc] init];
}

- (void)clearAllDownloadingStatus {
    BOOL hasDownloadingStatus = NO;
    for (id key in [_statusDictForAllSounds allKeys]) {
        NSNumber *status = [_statusDictForAllSounds objectForKey:key];
        if ([status intValue] == SNSoundStatusDownloading) {
            [_statusDictForAllSounds setObject:[NSNumber numberWithInt:SNSoundStatusDefault] forKey:key];
            hasDownloadingStatus = YES;
        }
    }
    
    if (hasDownloadingStatus) {
        [SNNotificationManager postNotificationName:kSoundPlayStatusChanged object:nil];
    }
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestStarted:(ASIHTTPRequest *)request {
    SNDebugLog(@"%@--", NSStringFromSelector(_cmd));
    self.currentRequest = request;
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    SNDebugLog(@"%@--response=%@", NSStringFromSelector(_cmd), responseHeaders);
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    SNSoundItem *item = [[request userInfo] objectForKey:kSndDownloadUserInfoKey];
    [_downloadingRequests removeObject:request];
    self.currentRequest = nil;
    
    [self setStatus:SNSoundStatusDefault soundItem:item];
    
    NSString *tag = [[TTURLCache sharedCache] keyForURL:item.url];
    NSString *sndId = [NSString stringWithFormat:@"snd%@", tag];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:sndId, @"id", item.localPath, @"url", nil];
    [SNNotificationManager postNotificationName:kSoundDownloaded object:userInfo];
    
    SNDebugLog(@"snd download succees: %@", item.url);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    SNSoundItem *item = [[request userInfo] objectForKey:kSndDownloadUserInfoKey];
    [_downloadingRequests removeObject:request];
    self.currentRequest = nil;
    
    [self setStatus:SNSoundStatusDownloadFailed soundItem:item];
    
    NSString *tag = [[TTURLCache sharedCache] keyForURL:item.url];
    NSString *sndId = [NSString stringWithFormat:@"snd%@", tag];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:sndId, @"id", @"", @"url", nil];
    [SNNotificationManager postNotificationName:kSoundDownloaded object:userInfo];
    
    SNDebugLog(@"snd download failed: %@", item.url);
}

// 下面的回调，暂时还用不上
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    SNDebugLog(@"%@--", NSStringFromSelector(_cmd));
}

- (void)requestRedirected:(ASIHTTPRequest *)request {
    SNDebugLog(@"%@--", NSStringFromSelector(_cmd));
}

#pragma mark -

+ (NSString *)soundFileDownloadPathWithURL:(NSString *)urlParam {
    if (urlParam.length == 0) {
        return @"";
    }
    
    if (![urlParam hasPrefix:kProtocolHTTP]) {
        return urlParam;
    }
    
    NSString *_fileName = [[TTURLCache sharedCache] keyForURL:urlParam];
    
    // 根据url添加音频文件扩展名
    NSString *ext = @"";
    NSRange range = [urlParam rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSString *lastComponent = [urlParam substringFromIndex:range.location];
        ext = [lastComponent pathExtension];
        if (ext.length > 0) {
            _fileName = [_fileName stringByAppendingFormat:@".%@", ext];
        } else {
            _fileName = [_fileName stringByAppendingString:@".amr"];
        }
    }
    
    NSString *_absolutePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:_fileName];
    return _absolutePath;
}

#pragma mark - utility functions

+ (BOOL)isMicrophoneEnabled {
    __block BOOL bEnabled = NO;
    
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL response) { //SNDebugLog(@"Allow microphone use response: %d", response);
            if (response) {
                bEnabled = YES;
            }
        }];
    } else {
        bEnabled = YES;
    }
    
    return bEnabled;
}

@end
