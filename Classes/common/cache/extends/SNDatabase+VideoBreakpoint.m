//
//  SNDatabase_VideoBreakpoint.m
//  sohunews
//
//  Created by Gao Yongyue on 13-11-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase+VideoBreakpoint.h"

@implementation SNDatabase (VideoBreakpoint)

- (BOOL)addBreakpointByVid:(NSString *)vid breakpoint:(double)breakpoint createAt:(double)createAt context:(int)contextType
{
    if ([vid length] == 0 && createAt && breakpoint <= 10.f)
    {
		SNDebugLog(@"addBreakpointByVid: empty list");
		return NO;
	}
	
	__block BOOL bSucceed;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        bSucceed = [self addBreakpointByVid:vid breakpoint:breakpoint createAt:createAt context:contextType inDatabase:db];
    }];
	return bSucceed;
}

- (BOOL)addBreakpointByVid:(NSString *)vid breakpoint:(double)breakpoint createAt:(double)createAt context:(int)contextType inDatabase:(FMDatabase *)db
{
    //执行插入操作
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@,%@,%@,%@) VALUES (?,?,?,?)",TB_VIDEO_BREAKPOINT,TB_VIDEO_BREAKPOINT_VID, TB_VIDEO_BREAKPOINT_BREAKPOINT, TB_VIDEO_BREAKPOINT_CREATE,TB_VIDEO_BREAKPOINT_CONTEXT];
    [db executeUpdate:sql, vid, @(breakpoint), @(createAt), @(contextType)];
    
    if ([db hadError])
    {
        SNDebugLog(@"addBreakpointByVid: : executeUpdate error:%d,%@",[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

- (float)getBreakpointByVid:(NSString *)vid context:(int)contextType
{
    if ([vid length] == 0)
    {
        SNDebugLog(@"getBreakpointByVid: Invalid vid=%@",vid);
        return 0;
    }
    __block float breakpoint = 0.f;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE vid=%@",
                         TB_VIDEO_BREAKPOINT,vid];
        
        FMResultSet *rs	= [db executeQuery:sql];
        if ([db hadError])
        {
            SNDebugLog(@"getBreakpointByVid: executeQuery error :%d,%@,channelId=%@",[db lastErrorCode],[db lastErrorMessage],vid);
            return;
        }
        
        breakpoint = [self getBreakpointFromResultSet:rs];
        [rs close];
    }];
    return breakpoint;
}

- (float)getBreakpointFromResultSet:(FMResultSet*)rs
{
    float breakpoint = 0.f;
    if (rs == nil)
    {
		SNDebugLog(@"getBreakpointFromResultSet: invalid rs");
	}
    else
    {
        while ([rs next])
        {
            breakpoint = [rs doubleForColumn:TB_VIDEO_BREAKPOINT_BREAKPOINT];
        }
    }
    return breakpoint;
}

- (BOOL)deleteVideoBreakpointByVid:(NSString *)vid
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE vid=?", TB_VIDEO_BREAKPOINT];
        result = [db executeUpdate:sql, vid];
        if ([db hadError])
        {
            *rollback = YES;
        }
    }];
	return result;
}

// 清空VideoBreakpoint列表
- (BOOL)clearVideoBreakpointList
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", TB_VIDEO_BREAKPOINT];
        result =  [db executeUpdate:sql];
        if (!result)
        {
            *rollback = YES;
            return ;
        }
    }];
	return result;
}

@end
