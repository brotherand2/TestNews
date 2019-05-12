//
//  SNDatabase+VideoChannel.m
//  sohunews
//
//  Created by chenhong on 13-10-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase+VideoChannel.h"
#import "SNVideoChannelObjects.h"

@implementation SNDatabase (VideoChannel)

- (NSArray*)getVideoChannelList {
    __block NSArray *array = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC",
                         TB_VIDEO_CHANNEL, TB_VIDEO_CHANNEL_INDEX];
        
        FMResultSet *rs	= [db executeQuery:sql];
        if ([db hadError]) {
            SNDebugLog(@"getVideoChannelList : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        array = [self getVideoChannelListFromResultSet:rs];
        [rs close];
    }];
	
	return array;
}

- (NSArray*)getVideoChannelListFromResultSet:(FMResultSet*)rs
{
	if (rs == nil) {
		SNDebugLog(@"getVideoChannelListFromResultSet: invalid rs");
		return nil;
	}
    
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while ([rs next])
	{
        @autoreleasepool {
            SNVideoChannelObject *item	= [[SNVideoChannelObject alloc] init];
            item.channelId              = [rs stringForColumn:TB_VIDEO_CHANNEL_ID];
            item.title                  = [rs stringForColumn:TB_VIDEO_CHANNEL_TITLE];
            item.sort                   = [rs stringForColumn:TB_VIDEO_CHANNEL_SORT];
            item.status                 = [rs stringForColumn:TB_VIDEO_CHANNEL_STATUS];
            item.descn                  = [rs stringForColumn:TB_VIDEO_CHANNEL_DESCN];
            item.ctime                  = [rs stringForColumn:TB_VIDEO_CHANNEL_CTIME];
            item.utime                  = [rs stringForColumn:TB_VIDEO_CHANNEL_UTIME];
            item.sortable               = [rs stringForColumn:TB_VIDEO_CHANNEL_SORTABLE];
            item.up                     = [rs stringForColumn:TB_VIDEO_CHANNEL_UP];
            
            [array addObject:item];
            //item);
        }
	}
	
	return array;
}

- (BOOL)addVideoChannelList:(NSArray*)channelList {
    if ([channelList count] == 0) {
		SNDebugLog(@"addVideoChannelList : empty list");
		return NO;
	}
	
	__block BOOL bSucceed	= YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for(int nIndex = 0; nIndex < [channelList count]; ++nIndex)
        {
            SNVideoChannelObject *item	= [channelList objectAtIndex:nIndex];
            bSucceed = [self addVideoChannelListItem:item inDatabase:db];
            if (!bSucceed) {
                SNDebugLog(@"addVideoTimeLineList : Failed");
                *rollback = YES;
                return ;
            }
        }
    }];
	return bSucceed;
}

- (BOOL)addVideoChannelListItem:(SNVideoChannelObject*)item inDatabase:(FMDatabase *)db
{
	if (item == nil) {
		SNDebugLog(@"addVideoChannelListItem : Invalid item");
		return NO;
	}
	
    //执行插入操作
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (\
                     %@,%@,%@,%@,%@,%@,%@,%@,%@,%@ \
                     ) VALUES (NULL,?,?,?,?,?,?,?,?,?)",
                     TB_VIDEO_CHANNEL,
                     TB_VIDEO_CHANNEL_INDEX,
                     TB_VIDEO_CHANNEL_ID,
                     TB_VIDEO_CHANNEL_STATUS,
                     TB_VIDEO_CHANNEL_SORT,
                     TB_VIDEO_CHANNEL_TITLE,
                     TB_VIDEO_CHANNEL_CTIME,
                     TB_VIDEO_CHANNEL_UTIME,
                     TB_VIDEO_CHANNEL_DESCN,
                     TB_VIDEO_CHANNEL_SORTABLE,
                     TB_VIDEO_CHANNEL_UP
                     ];
    
    [db executeUpdate:sql, item.channelId, item.status, item.sort,
     item.title, item.ctime, item.utime, item.descn, item.sortable, item.up];
    
    if ([db hadError]) {
        SNDebugLog(@"addVideoChannelListItem : executeUpdate error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

- (BOOL)clearVideoChannelList {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", TB_VIDEO_CHANNEL];
        result =  [db executeUpdate:sql];
        if (!result) {
            *rollback = YES;
            return ;
        }
    }];
	return result;
}

@end
