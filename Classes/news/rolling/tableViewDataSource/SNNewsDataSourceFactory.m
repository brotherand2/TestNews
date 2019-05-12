//
//  SNNewsDataSourceFactory.m
//  sohunews
//
//  Created by chenhong on 14-3-6.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsDataSourceFactory.h"
#import "SNLiveDataSource.h"
#import "SNRollingNewsDataSource.h"
#import "SNRollingGroupPhotoDataSource.h"
#import "SNRollingNewsSubscribeDataSource.h"

/// 创建新闻tab中各频道dataSource
@implementation SNNewsDataSourceFactory

+ (SNNewsDataSource *)dataSourceWithNewsChannelType:(SNNewsChannelType)channelType
                                          channelId:(NSString *)channelId
                                        channelName:(NSString *)channelName
                                        isMixStream:(int)isMixStream
{
    @autoreleasepool {
        SNNewsDataSource *dataSource = nil;
        
        if (channelType == NewsChannelTypeLive) {
            dataSource = [[SNLiveDataSource alloc] initWithChannelID:channelId];
        } else if (channelType == NewsChannelTypePhotos) {
            dataSource = [[SNRollingGroupPhotoDataSource alloc] initWithChannelId:channelId];
        } else if (channelType == NewsChannelTypeSubscribe) {
            dataSource = [[SNRollingNewsSubscribeDataSource alloc] initWithChannelId:channelId];
        }else {
            dataSource = [[SNRollingNewsDataSource alloc] initWithChannelId:channelId
                                                                channelName:channelName
                                                                isMixStream:isMixStream];
        }
        
        return dataSource;
    }
}

@end
