//
//  SNNewsContentWorker.h
//  sohunews
//
//  Created by handy wang on 1/9/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsChannelModule.h"
#import "CacheObjects.h"
#import "SNDBManager.h"
#import "SNNewsImageFetcher.h"
#import "SNConsts.h"

@protocol SNNewsContentWorkerDelegate;

@interface SNNewsContentWorkerNews : NSObject {
    NSString *_newsID;
    NSString *_termID;
    NSString *_newsTitle;
    NSString *_newsType;
}
@property(nonatomic, copy)NSString *newsID;
@property(nonatomic, copy)NSString *termID;
@property(nonatomic, copy)NSString *newsTitle;
@property(nonatomic, copy)NSString *newsType;

- (id)initWithNewsID:(NSString *)newsID newsTitle:(NSString *)newsTitle newsType:(NSString *)newsType;
//For 专题列表里的新闻
- (id)initWithNewsID:(NSString *)newsID termID:(NSString *)termID newsTitle:(NSString *)newsTitle newsType:(NSString *)newsType;

@end


@interface SNNewsContentWorker : NSObject {
    id __weak _myDelegate;
    NSMutableArray *_newsArray;
    BOOL _isCanceled;
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)BOOL isCanceled;

- (id)initWithDelegate:(id)delegateParam;

- (void)cancel;

- (void)appenNewsID:(NSString *)newsID newsTitle:(NSString *)newsTitle newsType:(NSString *)newsType;

- (void)appenNewsID:(NSString *)newsID termID:(NSString *)termID newsTitle:(NSString *)newsTitle newsType:(NSString *)newsType;

- (void)startInThread;

- (void)endInMainThread;

- (void)notifyStartingWorking;

- (NSString *)channelID;

@end

@protocol SNNewsContentWorkerDelegate
@optional
- (void)didStartWorking:(SNNewsContentWorker *)worker;
- (void)didFailedToWork:(SNNewsContentWorker *)worker;
- (void)didCancelWorking:(SNNewsContentWorker *)worker;
@required
- (void)didFinishWorking:(SNNewsContentWorker *)worker;
@end
