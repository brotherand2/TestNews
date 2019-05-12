//
//  SNDatabase+NickNameObj.m
//  sohunews
//
//  Created by guoyalun on 8/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_NickNameObj.h"

@implementation SNDatabase (NickNameObj)
-(NSArray *)getAllNickNames;
{
    __block NSArray *cacheList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNickName ORDER BY ID DESC"];
        
        if ([db hadError]) {
            SNDebugLog(@"getAllNickNames : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        cacheList = [self getObjects:[NickNameObj class] fromResultSet:rs];
        [rs close];
  	}];
    return cacheList;
}
-(BOOL)saveOrUpdateNickName:(NickNameObj *)nick;
{
    if (nick == nil) {
		return NO;
	}
    
    //查询是否已经存在相同项
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"REPLACE into tbNickName(nickName) values(?)", nick.nickName];
        if ([db hadError]) {
            SNDebugLog(@"saveOrUpdateNickName : executeQuery for exist one error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    return result;
}
-(BOOL)clearAllNickNames;
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"delete from tbNickName"];
        if ([db hadError]) {
            SNDebugLog(@"clearAllNickNames : executeUpdate one error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    
    return result;
}

@end
