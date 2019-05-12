//
//  SNNewsChannelModule.m
//  sohunews
//
//  Created by handy wang on 1/8/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNNewsChannelModule.h"
#import "SNRollingNewsDownloadManagerFinishType.h"
#import "SNNewsContentWorker.h"

@implementation SNNewsChannelModule
@synthesize channelID = _channelID;
@synthesize channelName = _channelName;
@synthesize channelType = _channelType;
@synthesize newsChannelItem = _newsChannelItem;
@synthesize runningNewsContentWorker = _runningNewsContentWorker;

#pragma mark - Lifecycle

- (id)initWithDelegate:(id)delegateParam {
    if (self = [super init]) {
        _delegate = delegateParam;
        _newsItemArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self resetAll];
    
}

#pragma mark - Public methods

//This methods must be override in subclass
- (void)startInThread {
    [self notifyStartingDownloading];
    
    //--------------------
    /**
     * This is implementation by default for SNNewsDownloadmanager running well.
     * Actually, you should callback SNNewsDownloadManager by one of SNNewsChannelModuleDelegate methods(didFinishDownloadingModule, didFailedToDownloadModule, didCancelDownloadingModule) depending on your actual job's result.
     */
    [self end];
    //--------------------
}

- (void)end {
    //下载下一个频道
    if ([_delegate respondsToSelector:@selector(didFinishDownloadingModule:)]) {
        [_delegate didFinishDownloadingModule:self];
    }
    _delegate = nil;
}

//This methods can be override in subclass
- (void)cancel {
    _isCanceled = YES;
    [self cancelRunningContentWorker];
}

- (void)cancelRunningContentWorker {
    if (!!_runningNewsContentWorker) {
        [_runningNewsContentWorker cancel];
    }
}

//This methods can be override in subclass
- (void)resetAll {
     //(_channelID);
     //(_channelName);
    _channelType = NewsChannelTypeNewsUnknown;
     //(_runningNewsContentWorker);
     //(_newsChannelItem);
     //(_newsItemArray);
    _delegate = nil;
}

//This method neednt override in sub class. Otherwise, override this method at your own risk.
- (void)notifyStartingDownloading {
    SNDebugLog(@"===INFO: Main thread: %d, begin downloading %@ channel......", [NSThread isMainThread], _channelName);
    if ([_delegate respondsToSelector:@selector(didStartDownloadingModule:)]) {
        [_delegate didStartDownloadingModule:self];
    }
}

//This methods must be override in subclass
- (void)scheduleANewsContentWorkerToWorkInThread {
    if (_isCanceled) {
        _isCanceled = NO;
        return;
    }
}

#pragma mark - SNNewsContentWorkerDelegate

- (void)didFinishWorking:(SNNewsContentWorker *)worker {
    [self scheduleANewsContentWorkerToWorkInThread];
}

- (void)didFinishDownloadingCount:(NSInteger)aFininsh total:(NSInteger)aTotal{
    
}

//暂停所有下载
-(BOOL)doSuspendIfNeeded
{
    return NO;
}

//恢复所有下载
-(BOOL)doResumeIfNeeded
{
    return NO;
}

-(NSNumber*)isCancel
{
    return [NSNumber numberWithBool:_isCanceled];
}
@end
