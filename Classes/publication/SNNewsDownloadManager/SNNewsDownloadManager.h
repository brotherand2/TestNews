//
//  SNNewsDownloadManager.h
//  sohunews
//
//  Created by handy wang on 1/8/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsChannelModule.h"
#import "CacheObjects.h"

@protocol SNNewsDownloadManagerDelegate
- (void)didStartDownloadAItemInMainThread:(id)toBeDownloadedItem;
- (void)didCancelDownloadItemInMainThread:(id)canceledDownloadItem;
- (void)didFailedToDownloadAItemInMainThread:(id)toBeDownloadedItem;
- (void)didFinishedDownloadAItemInMainThread:(id)toBeDownloadedItem;
- (void)resetNewsDownloadingProgressBarInMainThread;

- (void)didFinishedDownloadAllNewsInMainThread;

- (void)readyToRetryInMainThread:(id)retryDownloadItem;

@optional
- (void)updateNewsOrPubDownloadProgressInMainThread;
- (void)updateNewsOrPubDownloadProgressInMainThread:(NSNumber*)aCurrentPercent;
@end

@interface SNNewsDownloadManager : NSObject {
    id __weak _delegate;
    SNNewsChannelModule *_canceledChannelModule;
    NSMutableArray *_toBeDownloadedItems;
    NSMutableArray *_toBeDownloadedItemsFromDownloadClick; //临时下载对象，用户自己点的离线
    BOOL _isCanceled;
    BOOL _isForcedToFail;
}

@property(nonatomic, weak)id delegate;

//---3.3 refactored
@property(nonatomic, strong)NSArray *toBeDownloadedItems;
@property(nonatomic, strong)NSMutableArray *toBeDownloadedItemsFromDownloadClick;//toBeDownloadedItems<SCSubscribeObject>

+ (SNNewsDownloadManager *)sharedInstance;

//Load将被下载的频道数据（订阅的频道且是在离线设置里勾选的）
- (NSArray *)loadToBeDownloadedNewsInMainThread;

//下载用户设置的所有频道的最新数据
- (void)start;

//暂停所有下载
-(BOOL)doSuspendIfNeeded;

//恢复所有下载
-(BOOL)doResumeIfNeeded;
-(void)resetSuspendState;
-(BOOL)isSuspending;

//取消全部新闻频道下载
- (void)cancelAll;

//强制所有正在下载和等待下载的项失败
- (void)forceAllDownloadToFailWhenEndBgTask;

//取消某一新闻频道下载
- (void)cancelDownload:(NewsChannelItem *)downloadItem;

//重试某一新闻频道下载
- (void)retryDownload:(NewsChannelItem *)downloadItem;

//添加某一个新闻频道的下载
- (void)addDownload:(NewsChannelItem *)downloadItem;
- (void)addDownloadSub:(SCSubscribeObject *)subdownloadItem;

//已全部下载完成（无论其中是否有下载失败的）－没有正在下载和等待的项就说明所有待下载项都已尝试下载过，可能其中有下载失败的。
- (BOOL)isAllDownloadFinished;

//已全部下载完成但其中有失败的
- (BOOL)isAllDownloadFinishedButAndSomeFail;

//已全部下载完成但其中有取消的
- (BOOL)isAllDownloadFinishedButAndSomeCancel;

//已全部下载完成且其中没有有失败的
- (BOOL)isAllDownloadFinishedAndNoFail;

//判断频道是否正在下载
- (BOOL)isChannelDownloading:(NewsChannelItem *)channel;

//频道是否为失败项
- (BOOL)isChannelFailed:(NewsChannelItem *)channel;

//频道是否不在下载队列中
- (BOOL)isChannelDetached:(NewsChannelItem *)channel;

//频道是否在下载队列中
- (BOOL)isSubChannelInList:(SCSubscribeObject*)subscribe;
@end
