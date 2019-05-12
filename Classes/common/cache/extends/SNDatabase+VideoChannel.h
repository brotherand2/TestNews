//
//  SNDatabase+VideoChannel.h
//  sohunews
//
//  Created by chenhong on 13-10-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase (VideoChannel)

- (NSArray*)getVideoChannelList;
- (BOOL)addVideoChannelList:(NSArray*)channelList;
- (BOOL)clearVideoChannelList;

@end
