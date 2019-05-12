//
//  SNDataBase_Notification.m
//  sohunews
//
//  Created by weibin cheng on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDataBase_Notification.h"

@implementation SNDatabase (Notification)

-(NSArray*)getAllNotification
{
    __block NSArray* itemList = nil;
    [[SNDatabase writeQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:@"SELECT *  FROM tbNotification ORDER BY time DESC"];
        if([db hadError])
        {
            SNDebugLog(@"db errcode:%d errMsg:%@", [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        itemList = [self getObjects:[SNNotificationItem class] fromResultSet:set];
        [set close];
    }];
    return itemList;
}

-(BOOL)addSingleNotification:(SNNotificationItem *)notification
{
    __block BOOL result = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleNotification:notification inDatabase:db];
        if(!result)
        {
            *rollback = YES;
        }
    }];
    return  result;
}
-(BOOL)addSingleNotification:(SNNotificationItem *)notification inDatabase:(FMDatabase *)db
{
    if(notification == nil)
        return NO;
    NSString* sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",TB_NOTIFICATION, TB_NOTIFICATION_PID, TB_NOTIFICATION_MSGID, TB_NOTIFICATION_TYPE, TB_NOTIFICATION_ALERT, TB_NOTIFICATION_DATA_PID, TB_NOTIFICATION_NICK_NAME, TB_NOTIFICATION_HEAD_URL, TB_NOTIFICATION_TIME];
    BOOL result = [db executeUpdate:sql, notification.pid, notification.msgid, notification.type, notification.alert, notification.dataPid, notification.nickName, notification.headUrl, notification.time];
    if([db hadError])
    {
        SNDebugLog(@"db errcode:%d errMsg:%@", [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    return  result;
}
-(BOOL)addMutipleNotification:(NSArray *)itemArray
{
    for(SNNotificationItem* model in itemArray)
    {
        BOOL result = [self addSingleNotification:model];
        if(!result)
         return NO;
    }
    return YES;
}

-(int)selectMaxNotificationId
{
    NSMutableArray *ids = [NSMutableArray array];
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT MAX(msgid) AS msgid FROM tbNotification"];
        if ([db hadError]) {
            SNDebugLog(@"selectMaxRid : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        while ([rs next]) {
            [ids addObject:[NSNumber numberWithInteger:[rs intForColumn:TB_NOTIFICATION_MSGID]]];
        }
    }];
	if (ids.count > 0) {
        return [[ids objectAtIndex:0] intValue];
    }
	return -1;
}

-(BOOL)deleteAllNotification
{
    __block BOOL result = NO;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM tbNotification"];
    }];
    return result;
}
@end
