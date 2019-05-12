//
//  SNDatabase_WeiboHotChannel.m
//  sohunews
//
//  Created by wang yanchen on 12-12-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_WeiboHotChannel.h"
#import "SNChannelManageContants.h"

@implementation SNDatabase(WeiboHotChannel)

-(NSArray*)getWeiboHotChannelList
{
    __block NSArray *newsChannel = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbWeiboHotChannel"];
        if ([db hadError]) {
            SNDebugLog(@"getWeiboHotChannelList : executeQuery error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        newsChannel = [self getObjects:[WeiboHotChannelItem class] fromResultSet:rs limitCount:kChannelMaxVolum];
        [rs close];
    
    }];
    return newsChannel;
}

-(BOOL)setWeiboHotChannelList:(NSArray*)channelList updateTopTime:(BOOL)update
{
	if ([channelList count] == 0) {
		SNDebugLog(@"setNewsChannelList : Invalid newsChannelList");
		return NO;
	}
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbWeiboHotChannel"];
        if ([db hadError])
        {
            SNDebugLog(@"setWeiboHotChannelList: executeUpdate clear current weibo channel list error %d : %@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
        NSInteger index = 0;
        for (WeiboHotChannelItem *item in  channelList) {
            if (update) {
                NSString *currentDateString = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                result = [db executeUpdate:@"INSERT INTO tbWeiboHotChannel (ID,name,channelID,channelIcon,channelType,isChannelSubed,channelPosition,channelTop,channelTopTime) VALUES (NULL,?,?,?,?,?,?,?,?)",item.channelName,item.channelId,item.channelIcon,item.channelType,item.isChannelSubed == nil?@"0":item.isChannelSubed,item.channelPosition,item.channelTop,currentDateString];
            } else {
                result = [db executeUpdate:@"INSERT INTO tbWeiboHotChannel (ID,name,channelID,channelIcon,channelType,isChannelSubed,channelPosition,channelTop,channelTopTime) VALUES (NULL,?,?,?,?,?,?,?,?)",item.channelName,item.channelId,item.channelIcon,item.channelType,item.isChannelSubed == nil?@"0":item.isChannelSubed,item.channelPosition,item.channelTop,item.channelTopTime];
            }
            
            if ([db hadError]) {
                SNDebugLog(@"setWeiboHotChannelList: executeUpdate error %d , %@,item:%@",[db lastErrorCode],[db lastErrorMessage],item);
                *rollback = YES;
                return;
            }
            if (++index >= kChannelMaxVolum) {
                break ;
            }
        }
        if (update) {
            [SNUserDefaults setBool:YES forKey:kWeiboHotEdit];
        }
    }];
	
	return result;
}

-(BOOL)clearWeiboHotChannelList
{
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbWeiboHotChannel"];
        if ([db hadError])
        {
            SNDebugLog(@"clearWeiboHotChannelList: executeUpdate error %d : %@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

@end
