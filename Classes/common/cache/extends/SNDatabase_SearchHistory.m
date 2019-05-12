//
//  SNDatabase_SearchHistory.m
//  sohunews
//
//  Created by chenhong on 13-4-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase_SearchHistory.h"
#import "CacheObjects.h"
#import "CacheDefines.h"

#define MAX_COUNT 10

@implementation SNDatabase (SearchHistory)

// add
- (BOOL)addSearchHistoryItem:(SearchHistoryItem *)item {
    if (!item) {
        return NO;
    }
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@, %@) VALUES (?,?)", TB_SEARCH_HISTORY, TB_SEARCH_HISTORY_CONTENT, TB_SEARCH_HISTORY_TIME];
        result = [db executeUpdate:sql, item.content, item.time];
        
        if ([db hadError]) {
            SNDebugLog(@"%@-- add search history item failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];

    return result;
}

// delete
- (BOOL)clearAllSearchHistoryItems {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_SEARCH_HISTORY]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    return result;
}

- (BOOL)deleteSearchHistoryItem:(NSString *)word {
	if ([word length] == 0) {
		return NO;
	}
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result =[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=?", TB_SEARCH_HISTORY, TB_SEARCH_HISTORY_CONTENT], word];
        if ([db hadError]) {
            SNDebugLog(@"%@ : executeUpdate error :%d,%@,word=%@", NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage],word);
            *rollback = YES;
            return;
        }
    }];
    return result;
}

- (BOOL)deleteSearchHistoryItemsBefore:(SearchHistoryItem *)item {
    if (!item.time) {
        return NO;
    }
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ <= %g", TB_SEARCH_HISTORY, TB_SEARCH_HISTORY_TIME, [item.time doubleValue]]];
        if ([db hadError]) {
            SNDebugLog(@"%@ : executeUpdate error :%d,%@,item=%@", NSStringFromSelector(_cmd), [db lastErrorCode],[db lastErrorMessage],item);
            *rollback = YES;
            return;
        }
    }];
    return result;
}

// get
- (NSArray *)getSearchHistoryItems:(int)count {
    __block  NSArray *items = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC limit %d", TB_SEARCH_HISTORY, TB_SEARCH_HISTORY_TIME, MAX_COUNT]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        items = [self getObjects:[SearchHistoryItem class] fromResultSet:rs];
        [rs close];
        
    }];
    return items;
}

@end
