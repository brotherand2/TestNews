//
//  SNDatabase+VideoColumn.m
//  sohunews
//
//  Created by jojo on 13-10-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase+VideoColumn.h"
#import "SNVideoChannelObjects.h"

@implementation SNDatabase (VideoColumn)

- (BOOL)addAVideoClumnObj:(SNVideoColumnCacheObj *)colObj inDatabase:(FMDatabase *)db {
    if (!colObj || ![colObj isKindOfClass:[SNVideoColumnCacheObj class]]) {
        SNDebugLog(@"%@: invalidate column obj %@", NSStringFromSelector(_cmd), colObj);
        return NO;
    }
    
    if (colObj.readCount) {
        NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@, %@, %@, %@) VALUES (?,?,?,?)",
                         TB_VIDEO_COLUMN,
                         TB_VIDEO_COLUMN_ID,
                         TB_VIDEO_COLUMN_TITLE,
                         TB_VIDEO_COLUMN_IS_SUB,
                         TB_VIDEO_COLUMN_READ_COUNT];
        
        [db executeUpdate:sql, colObj.columnId, colObj.columnTitle, colObj.isSubed, colObj.readCount];
    }
    else {
        NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@, %@, %@) VALUES (?,?,?)",
                         TB_VIDEO_COLUMN,
                         TB_VIDEO_COLUMN_ID,
                         TB_VIDEO_COLUMN_TITLE,
                         TB_VIDEO_COLUMN_IS_SUB];
        
        [db executeUpdate:sql, colObj.columnId, colObj.columnTitle, colObj.isSubed];
    }
    
    if ([db hadError]) {
        SNDebugLog(@"%@: executeUpdate error:%d,%@", NSStringFromSelector(_cmd),[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

- (BOOL)clearAllVideoColumnsInDatabase:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", TB_VIDEO_COLUMN];
    return [db executeUpdate:sql];
}

- (NSArray *)getVideoColumnsFromResultSet:(FMResultSet *)rs {
    if (!rs) {
        SNDebugLog(@"%@: invalidate rs", NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    while ([rs next]) {
        @autoreleasepool {
            SNVideoColumnCacheObj *obj = [[SNVideoColumnCacheObj alloc] init];
            
            obj.columnId = [rs stringForColumn:TB_VIDEO_COLUMN_ID];
            obj.columnTitle = [rs stringForColumn:TB_VIDEO_COLUMN_TITLE];
            obj.isSubed = [rs stringForColumn:TB_VIDEO_COLUMN_IS_SUB];
            obj.readCount = [rs stringForColumn:TB_VIDEO_COLUMN_READ_COUNT];
            
            [arr addObject:obj];
            //obj);
        }
        
    }
    return arr;
}

- (BOOL)setVideoColumns:(NSArray *)columns {
    if (!columns) {
        SNDebugLog(@"%@: nil columns argument", NSStringFromSelector(_cmd));
        return NO;
    }
    
    __block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (SNVideoColumnCacheObj *obj in columns) {
            bSucceed = [self addAVideoClumnObj:obj inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                SNDebugLog(@"%@: add a column obj error %@", NSStringFromSelector(_cmd), [db lastErrorMessage]);
                break;
            }
        }
    }];
    
    return bSucceed;
}

- (BOOL)setVideoColumnSubed:(BOOL)subed byColumnId:(NSString *)columnId {
    if (!columnId || ![columnId isKindOfClass:[NSString class]]) {
        SNDebugLog(@"%@: invalidate columnid %@", NSStringFromSelector(_cmd), columnId);
        return NO;
    }
    __block BOOL bSucceed = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@",
                         TB_VIDEO_COLUMN,
                         TB_VIDEO_COLUMN_ID,
                         columnId];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if ([db hadError]) {
            bSucceed = NO;
            SNDebugLog(@"%@: executeQuery error :%d,%@", NSStringFromSelector(_cmd),[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        NSArray *arr = [self getVideoColumnsFromResultSet:rs];
        if (arr.count > 0) {
            SNVideoColumnCacheObj *obj = arr[0];
            obj.isSubed = subed ? @"1" : @"0";
            bSucceed = [self addAVideoClumnObj:obj inDatabase:db];
        }
        else {
            SNDebugLog(@"%@: no item found that fit columnId %@", NSStringFromSelector(_cmd), columnId);
            bSucceed = NO;
        }
        
    }];
    
    return bSucceed;
}

- (BOOL)setVideoColumnReadCount:(NSString *)count byColumnId:(NSString *)columnId {
    if (!columnId || ![columnId isKindOfClass:[NSString class]]) {
        SNDebugLog(@"%@: invalidate columnid %@", NSStringFromSelector(_cmd), columnId);
        return NO;
    }
    if (!count || ![count isKindOfClass:[NSString class]]) {
        SNDebugLog(@"%@: invalidate count %@", NSStringFromSelector(_cmd), count);
        return NO;
    }
    
    __block BOOL bSucceed = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@",
                         TB_VIDEO_COLUMN,
                         TB_VIDEO_COLUMN_ID,
                         columnId];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if ([db hadError]) {
            bSucceed = NO;
            SNDebugLog(@"%@: executeQuery error :%d,%@", NSStringFromSelector(_cmd),[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        NSArray *arr = [self getVideoColumnsFromResultSet:rs];
        if (arr.count > 0) {
            SNVideoColumnCacheObj *obj = arr[0];
            obj.readCount = count;
            bSucceed = [self addAVideoClumnObj:obj inDatabase:db];
        }
        else {
            SNDebugLog(@"%@: no item found that fit columnId %@", NSStringFromSelector(_cmd), columnId);
            bSucceed = NO;
        }
    }];
    
    return bSucceed;
}

- (NSArray *)getVideoColumnsByColumnId:(NSString *)columnId {
    if (!columnId || ![columnId isKindOfClass:[NSString class]]) {
        SNDebugLog(@"%@: invalidate columnid %@", NSStringFromSelector(_cmd), columnId);
        return nil;
    }
    
    __block NSArray *array = nil;
    
    [[SNDatabase readQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@",
                         TB_VIDEO_COLUMN,
                         TB_VIDEO_COLUMN_ID,
                         columnId];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if ([db hadError]) {
            SNDebugLog(@"%@: executeQuery error :%d,%@", NSStringFromSelector(_cmd),[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        array = [self getVideoColumnsFromResultSet:rs];
        
    }];
    
    return array;
}

- (BOOL)clearAllVideoColumns {
    __block BOOL bSucceed = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        bSucceed = [self clearAllVideoColumnsInDatabase:db];
        if (!bSucceed) {
            *rollback = YES;
            SNDebugLog(@"%@: failed with error %@", NSStringFromSelector(_cmd), [db lastErrorMessage]);
        }
    }];
    return bSucceed;
}

@end
