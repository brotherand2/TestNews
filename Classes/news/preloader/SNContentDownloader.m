//
//  SNContentDownloader.m
//  sohunews
//
//  Created by jojo on 13-11-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNContentDownloader.h"

@implementation SNContentDownloader

+ (id)downloader {
    return [[[self class] alloc] init];
}


#pragma mark - operation methods

- (void)main {
    // 每次进行一个任务 都先去检测一下网络状态
    [[SNNewsPreloader sharedLoader] pauseAllWifiDownloadOperationsIfNeeded];
}

#pragma mark - public methods override

- (void)startWorkInWifiPriority {
    [[SNNewsPreloader sharedLoader] appendAWifiDownloader:self];
}

- (void)startWorkInImmediatelyPriority {
    [[SNNewsPreloader sharedLoader] appendAImmediatelyDownloader:self];
}

@end
