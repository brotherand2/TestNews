//
//  SNDatabase_WeiboHotItem.m
//  sohunews
//
//  Created by wang yanchen on 12-12-24.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_WeiboHotItem.h"
#import "SNDatabase_Private.h"


@implementation SNDatabase(WeiboHotItem)
// add
- (BOOL)addAWeiboHotItem:(WeiboHotItem *)weiboItem updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addAWeiboHotItem:weiboItem updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)addAWeiboHotItem:(WeiboHotItem *)weiboItem updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db {
    if (!weiboItem || ![weiboItem isKindOfClass:[WeiboHotItem class]]) {
        SNDebugLog(@"%@-- invalidate weiboItem", NSStringFromSelector(_cmd));
        return NO;
    }
    
    if (bUpdateIfExist) {
        NSString *sqlStr = [NSString stringWithFormat:@"REPLACE INTO %@ (weiboId,nick,head,isVip,time,title,type,commentCount,content,abstract,focusPic,weight,userJson,pageNo,readMark,createAt,icon) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", TB_WEIBOHOT_ITEM];
        [db executeUpdate:sqlStr, weiboItem.weiboId, weiboItem.nick, weiboItem.head, weiboItem.isVip, weiboItem.time, weiboItem.title, weiboItem.type, weiboItem.commentCount, weiboItem.content, weiboItem.abstract, weiboItem.focusPic, weiboItem.weight, weiboItem.userJson, weiboItem.pageNo, weiboItem.readMark, [NSDate nowTimeIntervalNumber], weiboItem.icon];
        if ([db hadError]) {
            SNDebugLog(@"%@-- insert a new itemId [%@] failed with error : %d - %@", NSStringFromSelector(_cmd), weiboItem.weiboId, [db lastErrorCode], [db lastErrorMessage]);
            return NO;
        }
    } else {
        NSInteger count = [db intForQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@=?", TB_WEIBOHOT_ITEM, TB_WEIBOHOT_ITEM_ID], weiboItem.weiboId];
        if (count==0) {
            NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (weiboId,nick,head,isVip,time,title,type,commentCount,content,abstract,focusPic,weight,userJson,pageNo,readMark,createAt,icon) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", TB_WEIBOHOT_ITEM];
            [db executeUpdate:sqlStr, weiboItem.weiboId, weiboItem.nick, weiboItem.head, weiboItem.isVip, weiboItem.time, weiboItem.title, weiboItem.type, weiboItem.commentCount, weiboItem.content, weiboItem.abstract, weiboItem.focusPic, weiboItem.weight, weiboItem.userJson, weiboItem.pageNo, weiboItem.readMark, [NSDate nowTimeIntervalNumber], weiboItem.icon];
            if ([db hadError]) {
                SNDebugLog(@"%@-- insert a new itemId [%@] failed with error : %d - %@", NSStringFromSelector(_cmd), weiboItem.weiboId, [db lastErrorCode], [db lastErrorMessage]);
                return NO;
            }
        }
    }
    return YES;
    
}

- (BOOL)setWeiboHotItems:(NSArray *)weiboItems {
    
    // 先删除老数据
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_WEIBOHOT_ITEM]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- delete old items failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (WeiboHotItem *weiboItem in weiboItems) {
            result = [self addAWeiboHotItem:weiboItem updateIfExist:YES inDatabase:db];
            if (!result) {
                SNDebugLog(@"%@ -- add a item [%@ -- %@] failed ", NSStringFromSelector(_cmd), weiboItem.weiboId, weiboItem.title);
                *rollback = YES;
                break;
            }
        }
    }];
    return result;
}

- (BOOL)setWeiboHotItems:(NSArray *)weiboItems withPageNo:(int)pageNo {
    // 清空并且从第一页重新填充数据
    __block BOOL result = YES;
    if (pageNo <= 1) {
        return [self setWeiboHotItems:weiboItems];
    }
    else {
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ >= %d", TB_WEIBOHOT_ITEM, TB_WEIBOHOT_ITEM_PAGENO, pageNo]];
            if ([db hadError]) {
                SNDebugLog(@"%@ -- delete items with pageNo >= %d error : %d- %@", NSStringFromSelector(_cmd), pageNo, [db lastErrorCode], [db lastErrorMessage]);
                *rollback = YES;
                return;
            }
        }];
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (WeiboHotItem *item in weiboItems) {
                result = [self addAWeiboHotItem:item updateIfExist:YES inDatabase:db];
                if (!result) {
                    *rollback = YES;
                    break;
                }
            }
        }];
        
        return result;
    }
}

// delete
- (BOOL)clearAllWeiboHotItems {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_WEIBOHOT_ITEM]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- delete all weibo items failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    return result;
}

// update
- (BOOL)updateAWeiboHotItem:(WeiboHotItem *)weiboItem addIfNotExist:(BOOL)bAddIfNotExist;
{
    return [self addAWeiboHotItem:weiboItem updateIfExist:bAddIfNotExist];
}

// query
- (WeiboHotItem *)getAWeiboHotItemByWeiboId:(NSString *)weiboId {
    if ([weiboId length] == 0) {
        SNDebugLog(@"%@-- invalidate weiboId", NSStringFromSelector(_cmd));
        return nil;
    }
    __block WeiboHotItem *weiboItem = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=?", TB_WEIBOHOT_ITEM, TB_WEIBOHOT_ITEM_ID], weiboId];
        if ([db hadError]) {
            SNDebugLog(@"%@-- query weibo item id[%@] failed with error :%d - %@", NSStringFromSelector(_cmd), weiboId, [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        weiboItem = [self getFirstObject:[WeiboHotItem class] fromResultSet:rs];
        [rs close];
    }];
    
    return weiboItem;
}

- (NSArray *)getAllWeiboHotItem {
    __block  NSArray *items = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TB_WEIBOHOT_ITEM]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- query weibo items failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        items = [self getObjects:[WeiboHotItem class] fromResultSet:rs];
        [rs close];
    
    }];
    return items;
}

- (NSArray *)getWeiboHotItemsByPageNo:(int)pageNo {
    __block NSArray *items = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d ", TB_WEIBOHOT_ITEM, TB_WEIBOHOT_ITEM_PAGENO, pageNo]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- query weibo items failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        items = [self getObjects:[WeiboHotItem class] fromResultSet:rs];
        [rs close];
    }];
    
    return items;
}


@end
