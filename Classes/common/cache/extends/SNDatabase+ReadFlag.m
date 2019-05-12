//
//  SNDatabase+ReadFlag.m
//  sohunews
//
//  Created by guoyalun on 7/5/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDatabase+ReadFlag.h"

@implementation SNDatabase (ReadFlag)

- (void)saveLink2:(NSString *)link2 read:(BOOL)flag
{
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT INTO tbNewspaperReadFlag (link2,readFlag,createAt) VALUES (?,?,?)",link2,[NSNumber numberWithBool:flag],[NSNumber numberWithInt:(int)[[NSDate date] timeIntervalSince1970]]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- add Or Replace One link2 read flag failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
    }];
}
- (BOOL)readFlagForLink2:(NSString *)link2
{
    __block BOOL flag = NO;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT readFlag FROM tbNewspaperReadFlag WHERE link2=?",link2];
        if ([rs next]) {
            flag = [rs boolForColumn:@"readFlag"];
        }
        [rs close];
    }];
    return flag;
}

- (BOOL)removeAllLink2
{
    __block BOOL result = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbNewspaperReadFlag"];
        if ([db hadError]) {
            SNDebugLog(@"%@--removeTimeOutLink2 failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
    }];
    return result;

}




@end
