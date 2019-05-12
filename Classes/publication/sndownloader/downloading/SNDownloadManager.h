//
//  FKDownloadManager.h
//  FK
//
//  Created by handy wang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "CacheObjects.h"
#import "SNDownloaderRequest.h"
#import "SNDownloadConfig.h"

#define kWWANNetworkReachAlertViewTag                           (1)
#define kCancelAllDownloadAlertViewTag                          (2)
#define kNetworkStatusChangedAlertViewTag                       (3)
#define kWWANetworkResumeAlertViewTag                           (4)

@protocol SNDownloadManagerDelegate
@optional

- (void)reloadDownloadingTableView;

- (void)noTasksToDownload;

- (void)didFailedToBatchGetLatestTermId:(NSString *)message;

- (void)requestStarted:(SubscribeHomeMySubscribePO *)downloadingItem;

- (void)updateProgress:(NSNumber *)progress downloadingItemIndex:(NSNumber *)index;

- (void)requestFinished:(SubscribeHomeMySubscribePO *)downloadingItem downloadingItemIndex:(NSNumber *)index;

- (void)requestFailed:(SubscribeHomeMySubscribePO *)downloadingItem error:(NSError *)error;

- (void)changeToDownloadStatus:(NSNumber *)statusParam forItemIndex:(NSNumber *)index;

@end


@interface SNDownloadManager : NSObject <SNActionSheetDelegate>{
    id __weak _delegate;
    
    BOOL _isAllFinished;
    BOOL _isPaused;
    
    SNDownloaderRequest *_downloadingRequest;
    
    NSMutableArray *_downloadingItemsForRender;
    NSMutableArray *_downloadingItems;
    ASINetworkQueue *_downloadingQueue;
    
    NSString *_downloadingZipIndexFilePath;
}

@property(nonatomic, weak, readwrite)id delegate;
@property(nonatomic, assign, readwrite)BOOL isDownloaderVisible;
@property(nonatomic, strong, readwrite)NSMutableArray *downloadingItemsForRender;
@property(nonatomic, strong, readonly)SNDownloaderRequest *downloadingRequest;
@property(nonatomic, assign, readwrite)BOOL isAllFinished;

+ (SNDownloadManager *)sharedInstance;

- (void)addSpecifiedDownloadingItemImmediatlyWith:(SubscribeHomeMySubscribePO *)poParam;

- (void)addDownloadingItems:(NSArray *)downloadingItemsParam;

- (void)removeAllDownloadingItems;

- (void)retryDownloadWithItem:(id)itemParam;

- (void)cancelDownloadItem:(id)itemParam;

- (void)cancelAllDownloadItems;

- (void)suspend;

- (void)resume;

- (BOOL)isInDownloadingItemsForRender:(NSString *)termIdPram;

- (BOOL)isInDownloadingItems:(NSString *)termIdParam;

@end
