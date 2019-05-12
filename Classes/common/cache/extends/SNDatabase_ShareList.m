//
//  SNDatabase_ShareList.m
//  sohunews
//
//  Created by yanchen wang on 12-5-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_ShareList.h"
@implementation SNDatabase(ShareList)

- (BOOL)saveOneShareItem:(ShareListItem *)item InDatabase:(FMDatabase *)db {
    if (!item) {
        SNDebugLog(@"shareList item null!");
        return NO;
    }
    NSString *sql = @"INSERT INTO tbShareList (appLevel, appName, appID, status, appIconUrl, appGrayIconUrl, userName, requestUrl, openId) VALUES (?,?,?,?,?,?,?,?,?)";
    [db executeUpdate:sql,[NSNumber numberWithInt:item.appLevel],
     item.appName, item.appID, item.status, item.appIconUrl, item.appGrayIconUrl, item.userName, item.requestUrl, item.openId];
    if ([db hadError]) {
        SNDebugLog(@"shareList insert item error!");
        return NO;
    }
    return YES;
}

- (NSArray *)shareList {
    __block NSArray *array = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbShareList ORDER BY appLevel ASC"];
        if ([db hadError]) {
            SNDebugLog(@"query tbShareList error!");
            return;
        }
        array = [self getObjects:[ShareListItem class] fromResultSet:rs];
        [rs close];
    }];
    
    return array;
}

- (BOOL)setShareList:(NSArray *)items {
    __block BOOL bRet = YES;
    if ([items count] > 0) {
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            bRet = [db executeUpdate:@"DELETE FROM tbShareList"];
            if ([db hadError]) {
                SNDebugLog(@"delete tbShareList error");
                *rollback = YES;
                return ;
            }
            for (ShareListItem *item in items) {
                bRet = [self saveOneShareItem:item InDatabase:db];
                if (!bRet) {
                    *rollback = YES;
                    return ;
                }
            }
        }];
    } else {
        bRet = NO;
    }
    return bRet;
}

@end
