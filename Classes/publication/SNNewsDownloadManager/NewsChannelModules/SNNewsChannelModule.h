//
//  SNNewsChannelModule.h
//  sohunews
//
//  Created by handy wang on 1/8/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsChannelType.h"
#import "SNASIRequest.h"
#import "SNDBManager.h"
#import "NSDictionaryExtend.h"
#import "SNNewsImageFetcher.h"
@class SNNewsContentWorker;

#define kRNLStartPageNumber                         (1)//第一页page number为1
#define kRNLPageSize                                (20)

@protocol SNNewsChannelModuleDelegate;

@interface SNNewsChannelModule : NSObject {
    id _delegate;
    
    NSString *_channelID;
    NSString *_channelName;
    SNNewsChannelType _channelType;
    SNNewsContentWorker *_runningNewsContentWorker;
    NewsChannelItem *_newsChannelItem;
    NSMutableArray *_newsItemArray;
    BOOL _isCanceled;
    BOOL _isSuspending;
}

@property(nonatomic, copy)NSString *channelID;
@property(nonatomic, copy)NSString *channelName;
@property(nonatomic, assign)SNNewsChannelType channelType;
@property(nonatomic, strong)NewsChannelItem *newsChannelItem;
@property(nonatomic, strong)SNNewsContentWorker *runningNewsContentWorker;

//This methods must be override in subclass
- (id)initWithDelegate:(id)delegateParam;

- (void)startInThread;

- (void)end;

//This methods can be override in subclass depending on you.
- (void)cancel;

- (void)cancelRunningContentWorker;

//This methods can be override in subclass depending on you.
- (void)resetAll;

//This method neednt override in sub class. Otherwise, override this method at your own risk.
- (void)notifyStartingDownloading;

//This methods must be override in subclass
- (void)scheduleANewsContentWorkerToWorkInThread;

//暂停所有下载
-(BOOL)doSuspendIfNeeded;

//恢复所有下载
-(BOOL)doResumeIfNeeded;

-(NSNumber*)isCancel;
@end

@protocol SNNewsChannelModuleDelegate
- (void)didStartDownloadingModule:(SNNewsChannelModule *)module;
- (void)didFinishDownloadingModule:(SNNewsChannelModule *)module;
- (void)didFailedToDownloadModule:(SNNewsChannelModule *)module;
- (void)didCancelDownloadingModule:(SNNewsChannelModule *)module;
@optional
- (void)didFinishDownloadingCount:(NSInteger)aFininsh total:(NSInteger)aTotal;
@end
