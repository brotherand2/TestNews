//
//  SNNewsPreloader.m
//  sohunews
//
//  Created by jojo on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNewsPreloader.h"

@interface SNNewsPreloader ()

@property (nonatomic, strong) NSOperationQueue *wifiPreloaderQueue;
@property (nonatomic, strong) NSOperationQueue *immediatelyQueue;

@end

@implementation SNNewsPreloader
@synthesize wifiPreloaderQueue = _wifiPreloaderQueue;
@synthesize immediatelyQueue = _immediatelyQueue;

+ (SNNewsPreloader *)sharedLoader {
    static SNNewsPreloader *__sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sInstance = [[[self class] alloc] init];
    });
    return __sInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleNetworkChanned:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
     //(_wifiPreloaderQueue);
     //(_immediatelyQueue);
}

#pragma mark - properties
- (NSOperationQueue *)wifiPreloaderQueue {
    if (!_wifiPreloaderQueue) {
        _wifiPreloaderQueue = [[NSOperationQueue alloc] init];
        [_wifiPreloaderQueue setMaxConcurrentOperationCount:kWifiLoaderMaxConcurrentCount];
        [_wifiPreloaderQueue setSuspended:[SNUtility getApplicationDelegate].currentNetworkStatus != ReachableViaWiFi];
    }
    return _wifiPreloaderQueue;
}

- (NSOperationQueue *)immediatelyQueue {
    if (!_immediatelyQueue) {
        _immediatelyQueue = [[NSOperationQueue alloc] init];
        [_immediatelyQueue setMaxConcurrentOperationCount:kImmediatelyLoaderMaxConcurrentCount];
    }
    return _immediatelyQueue;
}

#pragma mark - public methods

- (void)appendAWifiDownloader:(NSOperation *)downloader {
    [downloader setThreadPriority:0.1];
    [self.wifiPreloaderQueue addOperation:downloader];
}

- (void)appendAImmediatelyDownloader:(NSOperation *)downloader {
    [downloader setThreadPriority:0.1];
    [self.immediatelyQueue addOperation:downloader];
}

- (void)cancelAllWifiDownloadOperations {
    [self.wifiPreloaderQueue cancelAllOperations];
}

- (void)pauseAllWifiDownloadOperationsIfNeeded {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if (networkStatus != ReachableViaWiFi) {
            [self pauseAllWifiDownloadOperations];
        }
    });
}

- (void)pauseAllWifiDownloadOperations {
    if (!self.wifiPreloaderQueue.isSuspended) {
        [self.wifiPreloaderQueue setSuspended:YES];
    }
}

- (void)resumeAllWifiDownloadOperationIfNeeded {
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    if (networkStatus == ReachableViaWiFi) {
        [self resumeAllWifiDownloadOperation];
    }
}

- (void)resumeAllWifiDownloadOperation {
    if (self.wifiPreloaderQueue.isSuspended) {
        [self.wifiPreloaderQueue setSuspended:NO];
    }
}

#pragma mark - actions
#pragma mark - handle network changed notification

- (void)handleNetworkChanned:(NSNotification *)notification {
    
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi) {
        [self.wifiPreloaderQueue setSuspended:NO];
        [self.immediatelyQueue setSuspended:NO];
    }
    else if (networkStatus == ReachableViaWWAN ||
             networkStatus == ReachableVia2G   ||
             networkStatus == ReachableVia3G   ||
             networkStatus == ReachableVia4G) {
        [self.wifiPreloaderQueue setSuspended:YES];
        [self.immediatelyQueue setSuspended:NO];
    }
    else {
        [self.wifiPreloaderQueue setSuspended:YES];
        [self.immediatelyQueue setSuspended:YES];
    }
}

@end
