//
//  SNNewsPreloader.h
//  sohunews
//
//  Created by jojo on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kWifiLoaderMaxConcurrentCount               (1)
#define kImmediatelyLoaderMaxConcurrentCount        (1)

@interface SNNewsPreloader : NSObject

+ (SNNewsPreloader *)sharedLoader;

- (void)appendAWifiDownloader:(NSOperation *)downloader;
- (void)appendAImmediatelyDownloader:(NSOperation *)downloader;

// 取消所有wifi离线内容
- (void)cancelAllWifiDownloadOperations;

// 让队列根据网络状况 自行决定要不要暂停 非wifi情况下 需要暂停
- (void)pauseAllWifiDownloadOperationsIfNeeded;

// 暂停wifi离线下载
- (void)pauseAllWifiDownloadOperations;

// 让队列自己决定要不要恢复 wifi情况下才可以继续
- (void)resumeAllWifiDownloadOperationIfNeeded;

// 恢复所有wifi离线下载
- (void)resumeAllWifiDownloadOperation;

@end
