//
//  SNDatabase_WeiboHotChannel.h
//  sohunews
//
//  Created by wang yanchen on 12-12-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(WeiboHotChannel)

-(NSArray*)getWeiboHotChannelList;
-(BOOL)setWeiboHotChannelList:(NSArray*)channelList updateTopTime:(BOOL)update;
-(BOOL)clearWeiboHotChannelList;

@end
