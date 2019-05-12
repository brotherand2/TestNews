//
//  SNNewsDataSourceFactory.h
//  sohunews
//
//  Created by chenhong on 14-3-6.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsChannelType.h"

@class SNNewsDataSource;

@interface SNNewsDataSourceFactory : NSObject

+ (SNNewsDataSource *)dataSourceWithNewsChannelType:(SNNewsChannelType)channelType
                                          channelId:(NSString *)channelId
                                        channelName:(NSString *)channelName
                                        isMixStream:(int)isMixStream;

@end
