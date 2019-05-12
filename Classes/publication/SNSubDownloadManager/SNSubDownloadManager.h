//
//  SNPubDownloadManager.h
//
//  Created by handy wang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "SNDownloaderRequest.h"
#import "SNNewsChannelType.h"

@protocol SNSubDownloadManagerDelegate
@optional
- (void)didPrepareDownloadAllSubInMainThreadWithMsg:(BOOL)showMsg;
- (void)didFailedToDownloadAllSubInMainThread;
- (void)didFinishedDownloadAllSubInMainThread;
- (void)resetSubDownloadingProgressBarInMainThread;
- (void)readyToDownloadASubInMainThread:(SCSubscribeObject *)sub;

- (void)didGetNewTermOfToBeDownloadedSubsInMainThread;
- (void)didStartDownloadAItemInMainThread:(id)toBeDownloadedItem;
- (void)didCancelDownloadItemInMainThread:(id)canceledDownloadItem;
- (void)didFailedToDownloadAItemInMainThread:(id)toBeDownloadedItem;
- (void)didFinishedDownloadAItemInMainThread:(id)toBeDownloadedItem;

- (void)readyToRetryInMainThread:(id)retryDownloadItem;
- (void)updateNewsDownloadProgressInOneInMainThread:(NSNumber*)aNumber;
- (void)updateNewsOrPubDownloadProgressInMainThread:(NSNumber*)aCurrentPercent;
@end


@interface SNSubDownloadManager : NSObject {
    id __weak _delegate;
    NSMutableArray *_toBeDownloadedItems;
    NSMutableArray *_toBeDownloadedItemsFromDownloadClick; //临时下载对象，用户自己点的离线
    NSString *_downloadingZipIndexFilePath;
}

@property(nonatomic, weak, readwrite)id delegate;
@property(nonatomic, strong)NSMutableArray *toBeDownloadedItems;//toBeDownloadedItems<SCSubscribeObject>
@property(nonatomic, strong)NSMutableArray *toBeDownloadedItemsFromDownloadClick;//toBeDownloadedItems<SCSubscribeObject>

+(SNSubDownloadManager *)sharedInstance;
+(NSString*)channelFromProtocol:(NSString*)aProtocol type:(SNNewsChannelType*)aType;
+(NewsChannelItem*)newsItemFromSubItem:(SCSubscribeObject*)aSubItem;
+(NSArray*)generaNewsObjArrayFromSubObjArray:(NSArray*)aSubobjArray;

+(BOOL)validateDownloadPaper:(SCSubscribeObject*)aSubObject;
+(BOOL)validateDownloadChannel:(SCSubscribeObject*)aSubObject;

//Load将被下载的刊物数据（订阅的刊物且是在离线设置里勾选的）
- (NSArray *)loadToBeDownloadedMySubsInMainThread;

//下载用户设置的所有刊物的最新一期
- (void)start;
- (void)startWithoutPreparingMsg;

//暂停所有下载
- (BOOL)doSuspendIfNeeded;
- (void)resetSuspendState;
- (BOOL)isSuspending;

//恢复所有下载
- (BOOL)doResumeIfNeeded;

//下载某个刊物的某一期
- (void)downloadSub:(SCSubscribeObject *)sub;

//取消所有刊物的下载
- (void)cancelAll;

//强制所有正在下载和等待下载的项失败
- (void)forceAllDownloadToFailWhenEndBgTask;

//取消某一刊物的下载
- (void)cancelDownload:(SCSubscribeObject *)downloadItem;

//重试某一刊物的下载
- (void)retryDownload:(SCSubscribeObject *)downloadItem;

//已全部下载完成（无论其中是否有下载失败的）－没有正在下载和等待的项就说明所有待下载项都已尝试下载过，可能其中有下载失败的。
- (BOOL)isAllDownloadFinished;

//已全部下载完成但其中有失败的
- (BOOL)isAllDownloadFinishedButAndSomeFail;

//已全部下载完成但其中有取消的
- (BOOL)isAllDownloadFinishedButAndSomeCancel;

//已全部下载完成且其中没有有失败的
- (BOOL)isAllDownloadFinishedAndNoFail;

//等待下载的项
- (NSArray *)waitingDownloadItems;

//正在下载的项
- (NSArray *)runningDownloadItems;

//判断某刊物是否正在下载
- (BOOL)isSubDownloading:(SCSubscribeObject *)sub;

//刊物是否为失败项
- (BOOL)isSubFailed:(SCSubscribeObject *)sub;

//刊物是否不在下载队列中
- (BOOL)isSubDetached:(SCSubscribeObject *)sub;
- (BOOL)ifArrayContainItem:(NSArray*)aArray item:(SCSubscribeObject*)aItem;
@end
