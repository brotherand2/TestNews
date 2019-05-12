//
//  SNVideoDownloadManager.m
//  sohunews
//
//  Created by handy wang on 8/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "SNVideoDownloadRequest.h"
#import "SNM3U8VideoDownloadRequest.h"
#import "SNDBManager.h"
#import "SNMP4SegmentInfo.h"
#import "SNStatusBarMessageCenter.h"
#import "WSMVVideoHelper.h"

#import "SNVideoDownloadViewController.h"
#import "NSJSONSerialization+String.h"

#define kMaxConcurrentVideoDownloadCount                            (1)

#define kRootDirOfDownloadedVideos                                  (@"downloaded_videos")
#define kDownloadedDirOfNormalVideos                                (@"normal")
#define kTmpDirOfNormalVideos                                       (@"tmp")
#define kDownloadedDirOfM3U8Videos                                  (@"m3u8")
#define kTmpDirOfM3U8Videos                                         (@"tmp")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SNVideoDownloadConfig
+ (NSString *)rootDir {
    return [self cachePathWithName:@"downloaded_videos"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)normalVideoDir {
    NSString *_normalVideoDir = [[self rootDir] stringByAppendingPathComponent:kDownloadedDirOfNormalVideos];
    [self createPathIfNecessary:_normalVideoDir];
    return _normalVideoDir;
}

+ (NSString *)normalVideoTmpDir {
    NSString *_tmpPath = [[self normalVideoDir] stringByAppendingPathComponent:kTmpDirOfNormalVideos];
    [self createPathIfNecessary:_tmpPath];
    return _tmpPath;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)m3u8VideoDir:(NSString *)vid {
    if (vid.length <= 0) {
        return nil;
    }
    
    NSString *_m3u8VideoDir = [[[self rootDir] stringByAppendingPathComponent:kDownloadedDirOfM3U8Videos] stringByAppendingPathComponent:vid];
    [self createPathIfNecessary:_m3u8VideoDir];
    return _m3u8VideoDir;
}

+ (NSString *)m3u8VideoTmpDir {
    NSString *_tmpPath = [self m3u8VideoDir:kTmpDirOfM3U8Videos];
    [self createPathIfNecessary:_tmpPath];
    return _tmpPath;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private
+ (NSString*)cachePathWithName:(NSString*)name {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [paths objectAtIndex:0];
    NSString* cachePath = [cachesPath stringByAppendingPathComponent:name];
    
    [self createPathIfNecessary:cachesPath];
    [self createPathIfNecessary:cachePath];
    return cachePath;
}

+ (BOOL)createPathIfNecessary:(NSString*)path {
    BOOL succeeded = YES;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        succeeded = [fm createDirectoryAtPath: path
                  withIntermediateDirectories: YES
                                   attributes: nil
                                        error: nil];
    }
    
    return succeeded;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SNVideoDownloadManager()
@property (nonatomic, assign)BOOL                       finished;
@property (nonatomic, strong)NSMutableArray             *videoModelArray;
@property (nonatomic, strong)NSLock                     *videoQueueLock;

@property (nonatomic, strong)NSMutableArray             *downloadingRequests;
@property (nonatomic, strong)NSLock                     *downloadQueueLock;
@end

@implementation SNVideoDownloadManager

#pragma mark - Get instance
+ (SNVideoDownloadManager *)sharedInstance {
    static SNVideoDownloadManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SNDebugLog(@"######## Will initialize SNVideoDownloadManager...");
        _sharedInstance = [[SNVideoDownloadManager alloc] init];
        SNDebugLog(@"######## Had initialized SNVideoDownloadManager...");
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.videoModelArray        = [NSMutableArray array];
        self.videoQueueLock         = [[NSLock alloc] init];
        
        self.downloadingRequests    = [NSMutableArray array];
        self.downloadQueueLock      = [[NSLock alloc] init];
        
        self.finished = YES;
        
        //从数据库中初始化videoModelArray以及各自最后的下载进度情况
        NSArray *_localNotFinishedDownloadVideos = [[SNDBManager currentDataBase] queryAllDownloadVideosExcludingSuccessfulAndCanceled];
        
        if (_localNotFinishedDownloadVideos.count > 0) {
            for (SNVideoDataDownload *videoModel in _localNotFinishedDownloadVideos) {
                if (videoModel.state == SNVideoDownloadState_Downloading || videoModel.state == SNVideoDownloadState_Waiting) {
                    videoModel.state = SNVideoDownloadState_Pause;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSDictionary *__data = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:videoModel.state] forKey:@"state"];
                        [[SNDBManager currentDataBase] updateADownloadedVideo:__data byVid:videoModel.vid];
                    });
                }
                
                //从数据库读取进度(如果有的话)
                NSArray *_segments = [[SNDBManager currentDataBase] queryVideoSegmentsByVID:videoModel.vid];
                if ([videoModel.videoType isEqualToString:kDownloadVideoType_M3U8]) {
                    NSMutableDictionary *_eachSegmentDownloadBytes = [NSMutableDictionary dictionary];
                    NSMutableDictionary *_eachSegmentTotalBytes     = [NSMutableDictionary dictionary];
                    CGFloat _progress = 0;
                    for (SNSegmentInfo *_segment in _segments) {
                        NSString *_key = [NSString stringWithFormat:@"%@_%ld", _segment.vid, (long)_segment.segmentOrder];
                        if (_segment.downloadBytes > 0 && _segment.totalBytes > 0) {
                            //每个片断已下载量
                            [_eachSegmentTotalBytes setObject:[NSNumber numberWithFloat:_segment.downloadBytes] forKey:_key];
                            //每个片断的总量
                            [_eachSegmentDownloadBytes setObject:[NSNumber numberWithFloat:_segment.totalBytes] forKey:_key];
                            
                            _progress = _progress+_segment.downloadBytes/_segment.totalBytes/_segments.count;
                        }
                    }
                    videoModel.eachSegmentDownloadBytes = _eachSegmentDownloadBytes;
                    videoModel.eachSegmentTotalBytes = _eachSegmentTotalBytes;
                    //每个片断总量求和
                    __block CGFloat _total = 0;
                    NSArray *_eachSegmentTotalBytesValues = [videoModel.eachSegmentTotalBytes allValues];
                    [_eachSegmentTotalBytesValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSObject *_value = [_eachSegmentTotalBytesValues objectAtIndex:idx];
                        if ([_value isKindOfClass:[NSNumber class]]) {
                            _total += [(NSNumber *)_value floatValue];
                        }
                    }];
                    
                    //每个片断已下载量求和
                    __block CGFloat _downloaded = 0;
                    NSArray *_eachSegmentDownloadBytesValues = [videoModel.eachSegmentDownloadBytes allValues];
                    [_eachSegmentDownloadBytesValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSObject *_value = [_eachSegmentDownloadBytesValues objectAtIndex:idx];
                        if ([_value isKindOfClass:[NSNumber class]]) {
                            _downloaded += [(NSNumber *)_value floatValue];
                        }
                    }];
                    
                    //计算进度
                    videoModel.downloadProgress = _progress;
                    videoModel.downloadBytes = _downloaded;
                    videoModel.totalBytes    = _total;
                }
                //MP4
                else {
                    if (_segments.count > 0) {
                        SNSegmentInfo *_segmentInfo = [_segments objectAtIndex:0];
                        videoModel.downloadBytes = _segmentInfo.downloadBytes;
                        videoModel.totalBytes    = _segmentInfo.totalBytes;
                        if (videoModel.totalBytes != 0) {
                            videoModel.downloadProgress = videoModel.downloadBytes/videoModel.totalBytes;
                        }
                    }
                }
            }
            [self.videoModelArray addObjectsFromArray:_localNotFinishedDownloadVideos];
        }
        
        [SNNotificationManager addObserver:self selector:@selector(handleReachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleApplicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleApplicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    [self.videoModelArray removeAllObjects];
    
    [self.downloadingRequests removeAllObjects];
    
}

#pragma mark - Public
- (void)downloadVideoInThread:(SNVideoDataDownload *)videoModel {
    videoModel.state = SNVideoDownloadState_Waiting;
    
    NSDictionary *videoSourcesDic = [NSJSONSerialization JSONObjectWithString:videoModel.videoSources
                                                                      options:NSJSONReadingMutableLeaves
                                                                        error:NULL];
    NSString *mp4DownloadURL = [videoSourcesDic stringValueForKey:@"mp4" defaultValue:@""];
    NSString *m3u8DownloadURL = [videoSourcesDic stringValueForKey:@"m3u8" defaultValue:@""];
    
    NSString *downloadURL = nil;
    if (mp4DownloadURL.length > 0) {
        downloadURL = mp4DownloadURL;
    }
    else {
        downloadURL = m3u8DownloadURL;
    }
    
    videoModel.downloadURL = downloadURL;
    
    //----------------------------------------------------
    //model数组中没有此将要下载的对象时才加入到videoModelArray中
    BOOL _addedNewsItem = NO;
    [self.videoQueueLock lock];
    BOOL inVideoModelArray = NO;
    for (SNVideoDataDownload *tempVideo in self.videoModelArray) {
        if ([videoModel.vid isEqualToString:tempVideo.vid]) {
            tempVideo.state = SNVideoDownloadState_Waiting;
            inVideoModelArray = YES;
            break;
        }
    }
    if (!!videoModel && !inVideoModelArray) {
        [self.videoModelArray addObject:videoModel];
        
        //---设置开始下载时间、本地存储目录、VideoType
        videoModel.beginDownloadTimeInterval = [(NSDate *)([NSDate date]) timeIntervalSince1970];
        if ([[videoModel.downloadURL lowercaseString] containsString:@".m3u8"]) {
            videoModel.videoType         = kDownloadVideoType_M3U8;
            videoModel.localRelativePath = [[kDownloadedDirOfM3U8Videos stringByAppendingPathComponent:videoModel.vid] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m3u8", videoModel.vid]];
        }
        else if ([[videoModel.downloadURL lowercaseString] containsString:@".mp4"]) {
            videoModel.videoType         = kDownloadVideoType_MP4;
            videoModel.localRelativePath = [kDownloadedDirOfNormalVideos stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", videoModel.vid]];
        }
        else {
            videoModel.videoType         = kDownloadVideoType_Other;
            videoModel.localRelativePath = [kDownloadedDirOfNormalVideos stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", videoModel.vid]];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SNVideoDataDownload *_videoModelInDB = [[SNDBManager currentDataBase] queryDownloadVideoByVID:videoModel.vid];
            if (!_videoModelInDB) {
                [[SNDBManager currentDataBase] saveADownloadVideo:videoModel];
            }
            else {
                NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
                [_valuePair setObject:[NSNumber numberWithDouble:videoModel.beginDownloadTimeInterval] forKey:@"beginDownloadTimeInterval"];
                [_valuePair setObject:[NSNumber numberWithInt:videoModel.state] forKey:@"state"];
                [[SNDBManager currentDataBase] updateADownloadedVideo:_valuePair byVid:videoModel.vid];
            }
        });
        
        _addedNewsItem = YES;
    }
    [self.videoQueueLock unlock];
    
    if (_addedNewsItem) {
        [SNNotificationManager postNotificationName:kDidAddANewsDownloadItemNotification object:videoModel];
    }
    //----------------------------------------------------
    
    /////////////////////////////////////////////////
    BOOL _append = NO;
    while (self.downloadingRequests.count < kMaxConcurrentVideoDownloadCount && [self waitingItems].count > 0) {
        videoModel = [[self waitingItems] objectAtIndex:0];
        
        //M3U8
        if ([videoModel.videoType isEqualToString:kDownloadVideoType_M3U8]) {
            SNM3U8VideoDownloadRequest *_m3u8Request    = [[SNM3U8VideoDownloadRequest alloc] initWithURL:[NSURL URLWithString:videoModel.downloadURL]];
            _m3u8Request.callback                       = self;
            if (!!_m3u8Request) {
                _m3u8Request.userInfo = [NSMutableDictionary dictionaryWithObject:videoModel forKey:kDownloadingVideoItem];
                [self.downloadingRequests addObject:_m3u8Request];
                
                _append = YES;
                videoModel.state = SNVideoDownloadState_Downloading;
                NSDictionary *__data = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:videoModel.state] forKey:@"state"];
                [[SNDBManager currentDataBase] updateADownloadedVideo:__data byVid:videoModel.vid];
                
                [_m3u8Request startAsynchronous];
                  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                 //(_m3u8Request);
            }
        }
        //MP4
        else {
            SNVideoDownloadRequest *_request    = [[SNVideoDownloadRequest alloc] initWithURL:[NSURL URLWithString:videoModel.downloadURL]];
            _request.delegate                   = self;
            _request.downloadProgressDelegate   = self;
            _request.temporaryFileDownloadPath  = [[SNVideoDownloadConfig normalVideoTmpDir] stringByAppendingPathComponent:videoModel.vid];
            _request.downloadDestinationPath    = [[SNVideoDownloadConfig normalVideoDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", videoModel.vid]];
            if (!!_request) {
                NSMutableDictionary *_userInfo = [NSMutableDictionary dictionary];
                SNMP4SegmentInfo *_segment = nil;
                //---
                //下载MP4时，把MP4的片断信息在这里存进数据库；M3U8的片断信息存储是在SNM3U8VideoDownloadRequest里的解析完m3u8文件之后
                NSArray *_segments = [[SNDBManager currentDataBase] queryVideoSegmentsByVID:videoModel.vid];
                if (_segments.count > 0) {
                    _segment = [_segments objectAtIndex:0];
                    _segment.state = SNVideoDownloadState_Waiting;
                    NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
                    [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
                    [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_segment.vid andSegmentOrder:_segment.segmentOrder];
                    if (!!_segment) {
                        [_userInfo setObject:_segment forKey:kSegmentInfo];
                    }
                    videoModel.downloadBytes = _segment.downloadBytes;
                    videoModel.totalBytes    = _segment.totalBytes;
                    if (videoModel.totalBytes != 0) {
                        videoModel.downloadProgress = videoModel.downloadBytes/videoModel.totalBytes;
                    }
                }
                else {
                    _segment  = [[SNMP4SegmentInfo alloc] init];
                    _segment.vid                = videoModel.vid;
                    _segment.segmentOrder       = 0;
                    _segment.urlString          = videoModel.downloadURL;
                    _segment.duration           = 0;//对于MP4这个不是必要的
                    _segment.downloadBytes      = 0;
                    _segment.totalBytes         = 0;
                    _segment.videoType          = videoModel.videoType;
                    _segment.state              = SNVideoDownloadState_Waiting;
                    [[SNDBManager currentDataBase] saveAVideoSegment:_segment];
                    if (!!_segment) {
                        [_userInfo setObject:_segment forKey:kSegmentInfo];
                    }
                     //(_segment);
                }
                //---
                [_userInfo setObject:videoModel forKey:kDownloadingVideoItem];
                _request.userInfo = _userInfo;
                [self.downloadingRequests addObject:_request];
                
                _append = YES;
                videoModel.state = SNVideoDownloadState_Downloading;
                NSDictionary *__data = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:videoModel.state] forKey:@"state"];
                [[SNDBManager currentDataBase] updateADownloadedVideo:__data byVid:videoModel.vid];
                
                [_request startAsynchronous];
                  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                 //(_request);
            }
        }
    }
    if (!_append && !!videoModel) {
        SNDebugLog(@"===INFO: %@ is waiting to download for only support %d items concurrent download.", videoModel.title, kMaxConcurrentVideoDownloadCount);
    }

    if ([self waitingItems].count <= 0) {
        if (self.downloadingRequests.count > 0) {
            SNDebugLog(@"===INFO: No waiting items, however, there is %d downloading items.", self.downloadingRequests.count);
        }
        else {
            [self finishedToDownloadAllVideosInMainThread];
        }
    }
}

- (void)pauseAllVideo {
    for (SNVideoDataDownload *video in self.videoModelArray) {
        if (video.state == SNVideoDownloadState_Downloading || video.state == SNVideoDownloadState_Waiting) {
            if (video.state == SNVideoDownloadState_Downloading) {
                //5.0屏蔽视频离线提示
//                NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"paused_to_download_a_video", nil), video.title];
//                [[SNStatusBarMessageCenter sharedInstance] postImmediateMessage:msg];
//                [[SNToast shareInstance] showToastWithTitle:msg
//                                                      toUrl:nil
//                                                       mode:SNToastUIModeFeedBackCommon];
            }
            [self doPauseADownloadingVideo:video];
        }
    }
    [self downloadNextItem];
}

- (void)resumeAllVideo {
    Reachability *currentReach = [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability];
    NetworkStatus currentNetStatus = [currentReach currentReachabilityStatus];
    SNDebugLog(@"SNVideoDownloadManager, current netStatus is %d", currentNetStatus);
    if (currentNetStatus != ReachableViaWiFi) {
        return;
    }
    
    for (SNVideoDataDownload *video in self.videoModelArray) {
        if (video.state == SNVideoDownloadState_Pause ||
            video.state == SNVideoDownloadState_Failed) {
            video.state = SNVideoDownloadState_Waiting;
        }
    }
    [self downloadNextItem];
}

- (void)pauseDownloadingVideo:(SNVideoDataDownload *)videoModel {
    [self doPauseADownloadingVideo:videoModel];
    [self downloadNextItem];
}

- (void)doPauseADownloadingVideo:(SNVideoDataDownload *)videoModel {
    __block SNVideoDownloadRequest *_downloadingRequest = nil;
    [self.downloadingRequests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNVideoDownloadRequest *_request = [self.downloadingRequests objectAtIndex:idx];
        SNVideoDataDownload *_downloadingModel = [_request.userInfo objectForKey:kDownloadingVideoItem];
        if ([_downloadingModel.vid isEqualToString:videoModel.vid]) {
            if ([_downloadingModel.videoType isEqualToString:kDownloadVideoType_MP4]) {
                [_request clearDelegatesAndCancel];
                _downloadingRequest = _request;
                *stop = YES;
            }
            else if ([_downloadingModel.videoType isEqualToString:kDownloadVideoType_M3U8]) {
                if ([_request isKindOfClass:[SNM3U8VideoDownloadRequest class]]) {
                    SNM3U8VideoDownloadRequest *_m3u8Request = (SNM3U8VideoDownloadRequest *)_request;
                    [_m3u8Request clearAllSegmentRequests];
                    _m3u8Request.callback = nil;
                }
                _downloadingRequest = _request;
                *stop = YES;
            }
        }
    }];
    if (!!_downloadingRequest) {
        [self.downloadingRequests removeObject:_downloadingRequest];
    }
    videoModel.state = SNVideoDownloadState_Pause;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *__data = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:videoModel.state] forKey:@"state"];
        [[SNDBManager currentDataBase] updateADownloadedVideo:__data byVid:videoModel.vid];
        
        NSArray *_excludingStates = [NSArray arrayWithObject:[NSNumber numberWithInt:SNVideoDownloadState_Successful]];
        [[SNDBManager currentDataBase] updateAllSegmentsState:SNVideoDownloadState_Pause byVid:videoModel.vid excludingStates:_excludingStates];
    });
}

- (void)resumeDownloadingVideo:(SNVideoDataDownload *)videoModel {
    SNVideoData *timelineVideo = [[SNDBManager currentDataBase] getVideoTimeLineByVid:videoModel.vid];
    if (![[WSMVVideoHelper sharedInstance] canDownload:timelineVideo userInfo:@{kToBeDownloadedVideoModel:videoModel}]) {
        return;
    }
    
    [self downloadVideoInThread:videoModel];
}

- (void)retryDownloadingVideo:(SNVideoDataDownload *)videoModel {
    SNVideoData *timelineVideo = [[SNDBManager currentDataBase] getVideoTimeLineByVid:videoModel.vid];
    if (![[WSMVVideoHelper sharedInstance] canDownload:timelineVideo userInfo:@{kToBeDownloadedVideoModel:videoModel}]) {
        return;
    }
    
    [self downloadVideoInThread:videoModel];
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Private
- (void)downloadNextItem {
    NSArray *_waitingItems = [self waitingItems];
    SNVideoDataDownload *_videoDownloadModel = nil;
    if (_waitingItems.count > 0) {
        _videoDownloadModel = [_waitingItems objectAtIndex:0];
    }
    [self downloadVideoInThread:_videoDownloadModel];
}

#pragma mark -
- (BOOL)hasWaitingItems {
    return [self waitingItems].count > 0;
}

- (BOOL)hasDownloadingItems {
    return [self downloadingItems].count > 0;
}

- (BOOL)hasPausedItems {
    return [self pausedItems].count > 0;
}

- (BOOL)hasFailedItems {
    return [self failedItems].count > 0;
}

- (BOOL)hasSuccessfulItems {
    return [self successfulItems].count > 0;
}

#pragma mark -
- (NSArray *)itemsForDownloadingView {
    NSMutableArray *_items = [NSMutableArray array];
    [self.videoQueueLock lock];
    for (SNVideoDataDownload *_item in self.videoModelArray) {
        if (_item.state == SNVideoDownloadState_Waiting ||
            _item.state == SNVideoDownloadState_Downloading ||
            _item.state == SNVideoDownloadState_Pause ||
            _item.state == SNVideoDownloadState_Failed) {
            [_items addObject:_item];
        }
    }
    [self.videoQueueLock unlock];
    return _items;
}

- (void)removeSelectedItem:(SNVideoDataDownload *)selectedItem {
    [self.videoQueueLock lock];
    
    NSInteger _index = NSNotFound;
    for (SNVideoDataDownload *_modelInManager in self.videoModelArray) {
        if ([selectedItem.vid isEqualToString:_modelInManager.vid]) {
            _index = [self.videoModelArray indexOfObject:_modelInManager];
        }
    }
    
    if (_index != NSNotFound) {
        [self.videoModelArray removeObjectAtIndex:_index];
    }
    [self.videoQueueLock unlock];
}

- (NSArray *)waitingItems {
    NSMutableArray *_items = [NSMutableArray array];
    [self.videoQueueLock lock];
    for (SNVideoDataDownload *_item in self.videoModelArray) {
        if ([_item state] == SNVideoDownloadState_Waiting) {
            [_items addObject:_item];
        }
    }
    [self.videoQueueLock unlock];
    return _items;
}

- (NSMutableArray *)downloadingItems {
    NSMutableArray *_items = [NSMutableArray array];
    [self.videoQueueLock lock];
    for (SNVideoDataDownload *_item in self.videoModelArray) {
        if ([_item state] == SNVideoDownloadState_Downloading) {
            [_items addObject:_item];
        }
    }
    [self.videoQueueLock unlock];
    return _items;
}

- (NSMutableArray *)pausedItems {
    NSMutableArray *_items = [NSMutableArray array];
    [self.videoQueueLock lock];
    for (SNVideoDataDownload *_item in self.videoModelArray) {
        if ([_item state] == SNVideoDownloadState_Pause) {
            [_items addObject:_item];
        }
    }
    [self.videoQueueLock unlock];
    return _items;
}

- (NSMutableArray *)failedItems {
    NSMutableArray *_items = [NSMutableArray array];
    [self.videoQueueLock lock];
    for (SNVideoDataDownload *_item in self.videoModelArray) {
        if ([_item state] == SNVideoDownloadState_Failed) {
            [_items addObject:_item];
        }
    }
    [self.videoQueueLock unlock];
    return _items;
}

- (NSMutableArray *)successfulItems {
    NSMutableArray *_items = [NSMutableArray array];
    [self.videoQueueLock lock];
    for (SNVideoDataDownload *_item in self.videoModelArray) {
        if ([_item state] == SNVideoDownloadState_Successful) {
            [_items addObject:_item];
        }
    }
    [self.videoQueueLock unlock];
    return _items;
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestStarted:(ASIHTTPRequest *)request {
    SNVideoDataDownload *_videoModel = [[request userInfo] objectForKey:kDownloadingVideoItem];
    _videoModel.state = SNVideoDownloadState_Downloading;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SNMP4SegmentInfo *_segment = [request.userInfo objectForKey:kSegmentInfo];
        _segment.state = SNVideoDownloadState_Downloading;
        NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
        [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
        [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_segment.vid andSegmentOrder:_segment.segmentOrder];
    });
    
    [SNNotificationManager postNotificationName:kDidStartDownloadingVideoNotification object:_videoModel];
    SNDebugLog(@"===INFO: Start downloading %@ vid %@ from %@, isMainThead:%d",
               _videoModel.title, _videoModel.vid, _videoModel.downloadURL, [NSThread isMainThread]);
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    SNVideoDataDownload *_videoModel = [[request userInfo] objectForKey:kDownloadingVideoItem];
    
    int __responseStatusCode = [request responseStatusCode];
    SNDebugLog(@"===INFO:Receive responseHeaders of %@ \n, %@, status code: %d, isMainThread:%d",
               _videoModel.title, responseHeaders, __responseStatusCode, [NSThread isMainThread]);
    
    /**
     * 判断是否200、301、302、303
     * 因为：
     * ASIHTTPRequest will automatically redirect to a new URL when it encounters one of the following HTTP status codes, assuming a Location header was sent:
     * 301 Moved Permanently
     * 302 Found
     * 303 See Other
     */
    
    if(!(__responseStatusCode >= HttpSucceededResponseStatusCode && __responseStatusCode <= 299) &&
       __responseStatusCode != 301 &&
       __responseStatusCode != 302 &&
       __responseStatusCode != 303){
        SNDebugLog(@"===ERROR: Failed to download video %@ vid %@ from %@, status code is %d",
                   _videoModel.title, _videoModel.vid, _videoModel.downloadURL, __responseStatusCode);
        
        [self failedToDownloadAVideo:_videoModel request:(SNVideoDownloadRequest *)request];
        [self downloadNextItem];
    }
    else {
        [self diskSpaceNotEnoughAndPauseAllIfNeededWithResponseHeaders:responseHeaders];
    }
}

- (void)diskSpaceNotEnoughAndPauseAllIfNeededWithResponseHeaders:(NSDictionary *)responseHeaders {
    SNFileSystemSize *fileSystemSize = [SNUtility getCachedFileSystemSize];
    unsigned long long contentLength = [responseHeaders longlongValueForKey:@"Content-Length" defaultValue:0];
    
    if (contentLength > fileSystemSize.freeFileSystemSizeInBytes) {
        [self pauseAllVideo];
        
        UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
        UIWindow *appWindow = [(sohunewsAppDelegate *)[UIApplication sharedApplication].delegate window];
        //视频处于非全屏模式
        if (appWindow == currentKeyWindow) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"diskspace_not_enough_for_video_download_and_pause_all", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
        //视频处于全屏模式
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"diskspace_not_enough_for_video_download_and_pause_all", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    SNVideoDataDownload *_videoModel = [[request userInfo] objectForKey:kDownloadingVideoItem];
    SNDebugLog(@"===INFO:Finished to download video %@ vid %@ from %@, Main thread:%d",
               _videoModel.title, _videoModel.vid, _videoModel.downloadURL, [NSThread isMainThread]);
    
    //M3U8
    if ([[request.userInfo valueForKey:kM3U8_Download_Result] isEqualToString:kM3U8_Download_Result_Success]) {
        [self succeedToDownloadAVideo:_videoModel request:(SNVideoDownloadRequest *)request];
    }
    //非M3U8
    else {
        // 因为这里已经到完成方法里，所以只判断是否200
        //下载失败
        if(!([request responseStatusCode] >= HttpSucceededResponseStatusCode && [request responseStatusCode] <= 299)){
            SNDebugLog(@"===INFO:[requestFinished]:Failed to download with httpStatusCode %d, Main thread:%d",
                       [request responseStatusCode], [NSThread isMainThread]);
            
            SNMP4SegmentInfo *_segment = [request.userInfo objectForKey:kSegmentInfo];
            _segment.state = SNVideoDownloadState_Failed;
            NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
            [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
            [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_segment.vid andSegmentOrder:_segment.segmentOrder];
            
            [self failedToDownloadAVideo:_videoModel request:(SNVideoDownloadRequest *)request];
        }
        //下载成功
        else {
            SNMP4SegmentInfo *_segment = [request.userInfo objectForKey:kSegmentInfo];
            _segment.state = SNVideoDownloadState_Successful;
            NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
            [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
            [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_segment.vid andSegmentOrder:_segment.segmentOrder];
            
            [self succeedToDownloadAVideo:_videoModel request:(SNVideoDownloadRequest *)request];
        }
    }
    
    //下载下一个视频
    [self downloadNextItem];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    SNVideoDataDownload *_videoModel = [[request userInfo] objectForKey:kDownloadingVideoItem];
    SNDebugLog(@"requestFailed: videoModel:\n %@", _videoModel);
    SNDebugLog(@"===INFO:Failed to download %@ vid %@ from %@ with comming message: %@",
               _videoModel.title, _videoModel.vid, _videoModel.downloadURL, [[request error] localizedDescription]);
    
    //m3u8
    if ([[request.userInfo valueForKey:kM3U8_Download_Result] isEqualToString:kM3U8_Download_Result_Fail]) {
        SNM3U8SegmentInfo *_segment = [request.userInfo objectForKey:kSegmentInfo];
        _segment.state = SNVideoDownloadState_Failed;
        NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
        [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
        [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_segment.vid andSegmentOrder:_segment.segmentOrder];
    }
    [self failedToDownloadAVideo:_videoModel request:(SNVideoDownloadRequest *)request];
    [self downloadNextItem];
}

#pragma mark -
- (void)failedToDownloadAVideo:(SNVideoDataDownload *)videoModel request:(SNVideoDownloadRequest *)request {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self failedToDownloadAVideo:videoModel request:request];
        });
        return;
    }
    SNDebugLog(@"failedToDownloadAVideo: videoModel:\n %@", videoModel);
    SNDebugLog(@"===INFO: Failed to download video %@ vid %@ from %@",
               videoModel.title, videoModel.vid, videoModel.downloadURL);
    
    videoModel.state = SNVideoDownloadState_Failed;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *__data = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:videoModel.state] forKey:@"state"];
        [[SNDBManager currentDataBase] updateADownloadedVideo:__data byVid:videoModel.vid];
    });
    
    [self resetRequest:request];
    [self.downloadingRequests removeObject:request];
    [SNNotificationManager postNotificationName:kDidFailedToDownloadAVideoNotification object:videoModel];
    [SNNotificationManager postNotificationName:kRefreshFileSystemSizeBarNotification object:nil];
    
//    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"failed_to_download_a_video", nil), videoModel.title];
    NSString *msg = NSLocalizedString(@"failed_to_download_a_video", nil);
    //    [[SNStatusBarMessageCenter sharedInstance] postImmediateMessage:msg];
    
    //只在离线列表页弹出离线失败提示
    UIViewController *topSubVC = [[TTNavigator navigator].topViewController.flipboardNavigationController topSubcontroller];
    if ([topSubVC isKindOfClass:[SNVideoDownloadViewController class]]) {
        UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
        UIWindow *appWindow = [(sohunewsAppDelegate *)[UIApplication sharedApplication].delegate window];
        if (appWindow == currentKeyWindow) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
}

- (void)succeedToDownloadAVideo:(SNVideoDataDownload *)videoModel request:(SNVideoDownloadRequest *)request {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self succeedToDownloadAVideo:videoModel request:request];
        });
        return;
    }
    SNDebugLog(@"===INFO: Succeed to download video %@ vid %@ from %@", videoModel.title, videoModel.vid, videoModel.downloadURL);
    
    videoModel.state = SNVideoDownloadState_Successful;
    //---离线时处于编辑状态，下载完的model的isEditing状态还是YES，所以这里要重置一下，防止在已离线列表中显示为编辑状态样式;
    videoModel.isEditing = NO;
    //---
    
    //把segments的总大小更新到videoDownload表中
    NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
    
    CGFloat _videoTotalBytes = [[SNDBManager currentDataBase] queryVideoSegmentsTotalBytes:videoModel.vid];
    videoModel.totalBytes = _videoTotalBytes;
    
    NSNumber *videoTotalBytesNumber = [NSNumber numberWithFloat:_videoTotalBytes];
    if (!!videoTotalBytesNumber) {
        [_valuePair setObject:videoTotalBytesNumber forKey:TB_VIDEOS_DOWNLOAD_TOTALBYTES];
    }
    
    NSNumber *finishDownloadTimeIntervalNumber = [NSNumber numberWithDouble:[(NSDate *)([NSDate date]) timeIntervalSince1970]];
    if (!!finishDownloadTimeIntervalNumber) {
        [_valuePair setObject:finishDownloadTimeIntervalNumber
                  forKey:TB_VIDEOS_DOWNLOAD_FINISH_DOWNLOAD_TIMEINTERVAL];
    }
    
    NSNumber *stateNumber = [NSNumber numberWithInt:videoModel.state];
    if (!!stateNumber) {
        [_valuePair setObject:stateNumber forKey:TB_VIDEOS_DOWNLOAD_STATE];
    }
    
    [[SNDBManager currentDataBase] updateADownloadedVideo:_valuePair byVid:videoModel.vid];
    //---
    
    //把下载完成时间同步到timeline表中，以用于已离线列表的显示排序
    NSMutableDictionary *tempValuePair = [NSMutableDictionary dictionary];
    if (!!finishDownloadTimeIntervalNumber) {
        [tempValuePair setObject:finishDownloadTimeIntervalNumber
                       forKey:TB_VIDEO_TIMELINE_FINISH_DOWNLOAD_TIMEINTERVAL];
    }
    
    NSNumber *offlinePlay = @(YES);
    if (!!offlinePlay) {
        [tempValuePair setObject:offlinePlay
                          forKey:TB_VIDEO_TIMELINE_OFFLINE_PLAY];
    }
    
    [[SNDBManager currentDataBase] updateATimelineVideo:tempValuePair byVid:videoModel.vid];
    //---
    
    [self resetRequest:request];
    [self.downloadingRequests removeObject:request];
    [self.videoModelArray removeObject:videoModel];
    
    [SNNotificationManager postNotificationName:kDidSucceedToDownloadAVideoNotification object:videoModel];
    [SNNotificationManager postNotificationName:kRefreshFileSystemSizeBarNotification object:nil];
    
    NSString *msg = NSLocalizedString(@"succeed_to_download_a_video", nil);
    UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIWindow *appWindow = [(sohunewsAppDelegate *)[UIApplication sharedApplication].delegate window];
//    UIViewController *topSubVC = [[TTNavigator navigator].topViewController.flipboardNavigationController topSubcontroller];
    
//    if ([topSubVC isKindOfClass:[SNVideoDownloadViewController class]]) {
        if (appWindow == currentKeyWindow) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
            
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:msg toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
        }
//    }
}

- (void)resetRequest:(SNVideoDownloadRequest *)request {
    if ([request isKindOfClass:[SNM3U8VideoDownloadRequest class]]) {
        SNM3U8VideoDownloadRequest *_m3u8Request = (SNM3U8VideoDownloadRequest *)request;
        _m3u8Request.callback = nil;
    }
    
    request.downloadProgressDelegate    = nil;
    request.delegate                    = nil;
    request.userInfo                    = nil;
}

#pragma mark -
- (void)finishedToDownloadAllVideosInMainThread {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishedToDownloadAllVideosInMainThread];
        });
        return;
    }
    
    self.finished = YES;
    [SNNotificationManager postNotificationName:kDidFinishedToDownloadAllVideosNotification object:nil];
    SNDebugLog(@"===INFO: Finished to download all videos.");
}

#pragma mark - ASIProgressDelegate
//有多大的数据需要下载
- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength {
	[self request:request didReceiveBytes:0];
}

//下载中每次接收到数据长度
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)newLength {
    SNVideoDataDownload *_videoModel = [[request userInfo] objectForKey:kDownloadingVideoItem];
    SNDebugLog(@"didReceiveBytes: videoModel:\n %@", _videoModel);
    
    if ([request totalBytesRead] == 0) {
    }
    else if ([request contentLength]+[request partialDownloadSize] > 0) {
        CGFloat _totalBytes         = ([request contentLength]+[request partialDownloadSize])*1.0;
        CGFloat _downloadedBytes    = ([request totalBytesRead]+[request partialDownloadSize])*1.0;

        SNMP4SegmentInfo *_segment = [request.userInfo objectForKey:kSegmentInfo];
        _segment.state = SNVideoDownloadState_Downloading;
        _segment.totalBytes = _totalBytes;
        _segment.downloadBytes = _downloadedBytes;
        
        NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
        [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
        [_valuePair setObject:[NSNumber numberWithInt:_segment.downloadBytes] forKey:@"downloadBytes"];
        [_valuePair setObject:[NSNumber numberWithInt:_segment.totalBytes] forKey:@"totalBytes"];
        [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_segment.vid andSegmentOrder:_segment.segmentOrder];
        
        
        SNDebugLog(@"===INFO: Downloading video %@ vid %@, progress [%f]", _videoModel.title, _videoModel.vid, _downloadedBytes/_totalBytes);

        NSDictionary *_progressData = [NSDictionary dictionaryWithObjects:@[kDownloadVideoType_MP4, [NSNumber numberWithFloat:_downloadedBytes], [NSNumber numberWithFloat:_totalBytes], _videoModel]
                                                                  forKeys:@[kDownloadingVideoType, kVideoDownloadedBytes, kVideoTatalBytes, kDownloadingVideoModel]];
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SNNotificationManager postNotificationName:kVideoDownloadingProgressNotification object:_progressData];
            });
        } else {
            [SNNotificationManager postNotificationName:kVideoDownloadingProgressNotification object:_progressData];
        }
    }
}

#pragma mark - Handle notifications
- (void)handleReachabilityChangedNotification:(NSNotification *)notification {
    Reachability *currentReach = [notification object];
    NSParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    if (currentReach == [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability]) {
        NetworkStatus currentNetStatus = [currentReach currentReachabilityStatus];
        SNDebugLog(@"SNVideoDownloadManager, netStatus changed to %d", currentNetStatus);
        
        SNTabBarController* tabBarController = [[SNUtility getApplicationDelegate] appTabbarController];
        BOOL isCurrentVideoTab = [tabBarController isTabIndexSelected:TABBAR_INDEX_VIDEO];
        BOOL isCurrentMyCenterTab = [tabBarController isTabIndexSelected:TABBAR_INDEX_MORE];
        
        NSArray *downloadingVideos = [self downloadingItems];
        NSArray *waitingVideos = [self waitingItems];
        if ((currentNetStatus == ReachableViaWWAN ||
             currentNetStatus == ReachableVia2G   ||
             currentNetStatus == ReachableVia3G   ||
             currentNetStatus == ReachableVia4G)
            && (isCurrentVideoTab || isCurrentMyCenterTab)
            && (downloadingVideos.count > 0 || waitingVideos.count > 0)) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"current_network_is_2g3g", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
        
        if (currentNetStatus != ReachableViaWiFi) {
            [self pauseAllVideo];
        }
	}
}

- (void)handleApplicationWillResignActive:(NSNotification *)notification {
    [self pauseAllVideo];
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    //5.0版本后台进入不继续下载
    [self resumeAllVideo];
}

@end
