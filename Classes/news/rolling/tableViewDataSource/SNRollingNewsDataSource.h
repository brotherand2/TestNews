//
//  SNRollingNewsDataSource.h
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRollingNewsModel.h"
#import "SNNewsDataSource.h"

@class SNCommonNewsDatasource;

@interface SNRollingNewsDataSource : SNNewsDataSource

@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) SNRollingNewsModel *newsModel;
@property (nonatomic, strong) SNCommonNewsDatasource* data;
@property (nonatomic, strong) NSMutableDictionary *exposureDictiongary;

- (id)initWithChannelId:(NSString *)channelId;
- (id)initWithChannelId:(NSString *)channelId channelName:(NSString *)channelName;
- (id)initWithChannelId:(NSString *)channelId lastMinTimeline:(NSString *)lastMinTimeline;
- (id)initWithChannelId:(NSString *)channelId channelName:(NSString *)channelName isMixStream:(int)isMixStream;

@end
