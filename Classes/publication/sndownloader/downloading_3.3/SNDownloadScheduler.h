//
//  SNDownloadScheduler.h
//  sohunews
//
//  Created by handy wang on 1/24/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNActionSheet.h"

@protocol SNDownloadSchedulerDelegate;

#define DOWNLOAD_FAILTIME_MAX 2

@interface SNDownloadScheduler : NSObject <SNActionSheetDelegate>{
    CGFloat _percent;
    BOOL _isDownloading;
    NSInteger _failTime;
    NSString* _currentDownloading;
    BOOL _didUserCancelAllDownloads;
    NSMutableArray *_multicastDelegates;
    BOOL _alreadyPopAlert;
}

+ (SNDownloadScheduler *)sharedInstance;

//批量下载设置的刊物和频道新闻
- (void)start;

//暂停所有下载
- (void)doSuspendIfNeeded;

//恢复所有下载
- (void)resume;
- (void)doResumeIfNeeded;
- (BOOL)isSuspending;

//下载某个刊物的最新一期
- (void)downloadSub:(SCSubscribeObject *)sub;

//加载设置的将要被下载的刊物和频道新闻
- (void)loadToBeDownloadedPubsAndNewsFromMemInThread;

//设置multicast delegate
- (void)setDelegate:(id)delegate;

//移出某个delegate
- (void)removeDelegate:(id)delegate;

//取消全部刊物和频道下载
- (void)cancelAll;

//强制所有正在下载和等待下载的项失败
- (void)forceAllDownloadToFailWhenEndBgTask;

//取消指定的下载项
- (void)cancelDownload:(id)downloadItem;

//重试某失败项
- (void)retryDownload:(id)downloadItem;

#pragma mark -
//已全部下载完成（无论其中是否有下载失败的）－没有下载等待的项就说明所有待下载项都已尝试下载过，可能其中有下载失败的。
- (BOOL)isAllDownloadFinished;

//已全部下载完成但其中有失败的
- (BOOL)isAllDownloadFinishedButAndSomeFail;

//已全部下载完成但其中有取消的
- (BOOL)isAllDownloadFinishedButAndSomeCancel;

//已全部下载完成且其中没有有失败的
- (BOOL)isAllDownloadFinishedAndNoFail;

//当前是否处于离线管理界面
- (BOOL)isDownloaderVisible;

//刊物或频道新闻是否正在下载
- (BOOL)isDownloadingItem:(id)item;

//刊物或频道新闻是否为失败项
- (BOOL)isFailedItem:(id)item;

//刊物或频道新闻是否不在下载队列中
- (BOOL)isDetachedItem:(id)item;

//重置本地下载状态
- (void)resetCurrentToDownloadingStart;
- (void)resetCurrentToDownloadingend;

@property(nonatomic,assign)CGFloat percent;
@property(nonatomic,assign)BOOL isDownloading;
@property(nonatomic,assign)NSInteger failTime;
@property(nonatomic,strong)NSString* currentDownloading;
@property(nonatomic,assign)BOOL didUserCancelAllDownloads;
@end

@protocol SNDownloadSchedulerDelegate <NSObject>
@optional
- (void)plsSetDownloadItems;
- (void)thereIsNoTasksToDownloadInMainThread;
- (void)thereAreTasksToDownloadInMainThread;
- (void)refreshDownloadingListInMainThread:(NSMutableArray *)toBeDownloadedItems;
- (void)updateSubDownloadProgressNumber:(NSNumber *)progress;
- (void)updateNewsDownloadProgressNumber:(NSNumber *)progress;
- (void)refreshDownloadedListInMainThread;
- (void)didFinishedDownloadAllInMainThread;

- (void)didFailedDownloadSub:(SCSubscribeObject *)sub;
- (void)didFinishedDownloadSub:(SCSubscribeObject *)sub;
@end
