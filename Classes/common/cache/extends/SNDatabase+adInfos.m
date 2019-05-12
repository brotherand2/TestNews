//
//  SNDatabase+adInfos.m
//  sohunews
//
//  Created by jojo on 13-12-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase+adInfos.h"
#import "NSObject+YAJL.h"

static BOOL isInvalidateAdinfoType(SNAdInfoType type) {
    return (type <= SNAdInfoTypeStart || type >= SNAdInfoTypeEnd);
}

@implementation SNDatabase (adInfos)

- (BOOL)adInfoAddOrUpdateAdInfos:(NSArray *)adInfos
                        withType:(SNAdInfoType)type
                          dataId:(NSString *)dataId
                      categoryId:(NSString *)categoryId {
    
    if (isInvalidateAdinfoType(type) ||
        [dataId length] == 0 ||
        [categoryId length] == 0) {
        
        return NO;
    }
//    if ([categoryId isEqualToString:@"1_recom"]) {
//        categoryId = @"1"; // fix 推荐流手写的channelid 不认识
//    }

    __block BOOL bRet = YES;
    
    // 个数为0  就把之前缓存的全清理掉
    if (adInfos.count == 0) {
        return [self adInfoClearAdInfosByType:type dataId:dataId categoryId:categoryId];
    }
    else {
        
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (SNAdControllInfo *adInfo in adInfos) {
                if (!(bRet = [self adInfoAddOrUpdateOneAdInfo:adInfo
                                                     withType:type
                                                       dataId:dataId
                                                   categoryId:categoryId
                                                   inDatabase:db])) {
                    *rollback = YES;
                    break;
                }
            }
        }];
    }
    
    return bRet;
}

- (BOOL)adInfoClearAdInfosByType:(SNAdInfoType)type {
    __block BOOL bRet = YES;
    
    if (isInvalidateAdinfoType(type)) {
        return NO;
    }
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %d",
                         TB_AD_INFO_TABLE,
                         TB_AD_INFO_TYPE,
                         type];
        
        bRet = [db executeUpdate:sql];
        
        if ([db hadError]) {
            bRet = NO;
            *rollback = YES;
        }
    }];
    
    return bRet;
}

- (BOOL)adInfoClearAdInfosByType:(SNAdInfoType)type
                          dataId:(NSString *)dataId
                      categoryId:(NSString *)categoryId {
    
    if (isInvalidateAdinfoType(type) ||
        [dataId length] == 0 ||
        [categoryId length] == 0) {

        return NO;
    }
//    if ([categoryId isEqualToString:@"1_recom"]) {
//        categoryId = @"1"; // fix 推荐流手写的channelid 不认识
//    }

    __block BOOL bRet = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %d AND %@ = %@ AND %@ = %@",
                         TB_AD_INFO_TABLE,
                         TB_AD_INFO_TYPE, type,
                         TB_AD_INFO_DATA_ID, dataId,
                         TB_AD_INFO_CATEGORY_ID, categoryId];
        
        bRet = [db executeUpdate:sql];
        
        if ([db hadError] || !bRet) {
            bRet = NO;
            *rollback = YES;
        }
    }];
    
    return bRet;
}

- (NSArray *)adInfoGetAdInfosByType:(SNAdInfoType)type
                             dataId:(NSString *)dataId
                         categoryId:(NSString *)categoryId {
    
    if (isInvalidateAdinfoType(type) ||
        [dataId length] == 0 ||
        [categoryId length] == 0) {
        
        return nil;
    }
//    if ([categoryId isEqualToString:@"1_recom"]) {
//        categoryId = @"1"; // fix 推荐流手写的channelid 不认识
//    }

    __block NSArray *array = nil;
    
    [[SNDatabase readQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %d AND %@ = %@ AND %@ = %@",
                         TB_AD_INFO_TABLE,
                         TB_AD_INFO_TYPE,
                         type,
                         TB_AD_INFO_DATA_ID,
                         dataId,
                         TB_AD_INFO_CATEGORY_ID,
                         categoryId];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if ([db hadError]) {
            SNDebugLog(@"%@: executeQuery error :%d,%@", NSStringFromSelector(_cmd),[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        array = [self getAdInfosFromResultSet:rs];
    }];
    
    return array;
}

#pragma mark - private

- (BOOL)adInfoAddOrUpdateOneAdInfo:(SNAdControllInfo *)adInfo
                          withType:(SNAdInfoType)type
                            dataId:(NSString *)dataId
                        categoryId:(NSString *)categoryId
                        inDatabase:(FMDatabase *)db {
    
    if (isInvalidateAdinfoType(type) ||
        [dataId length] == 0 ||
        [categoryId length] == 0 ||
        ![adInfo isKindOfClass:[SNAdControllInfo class]]) {

        return NO;
    }
//    if ([categoryId isEqualToString:@"1_recom"]) {
//        categoryId = @"1"; // fix 推荐流手写的channelid 不认识
//    }

    NSString *jsonString = [adInfo toJsonString];
    
    if ([jsonString length] == 0) {
        return NO;
    }
    
    // REPLACE INTO %@ (%@, %@, %@, %@) VALUES (?,?,?,?)
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@, %@, %@, %@) VALUES (?,?,?,?)",
                     TB_AD_INFO_TABLE,
                     TB_AD_INFO_TYPE,
                     TB_AD_INFO_DATA_ID,
                     TB_AD_INFO_CATEGORY_ID,
                     TB_AD_INFO_JSON_STRING];
    
    [db executeUpdate:sql, [NSNumber numberWithInt:type], dataId, categoryId, jsonString];
    
    if ([db hadError]) {
        SNDebugLog(@"%@: executeUpdate error:%d,%@", NSStringFromSelector(_cmd),[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

- (NSArray *)getAdInfosFromResultSet:(FMResultSet *)rs {
    if (!rs) {
        return nil;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    
    while ([rs next]) {
        @autoreleasepool {
            NSString *jsonString = [rs stringForColumn:TB_AD_INFO_JSON_STRING];
            
            SNAdControllInfo *adInfo = [[SNAdControllInfo alloc] initWithJsonDic:[jsonString yajl_JSON]];
            [arr addObject:adInfo];
            //adInfo);
        }
    }
    
    return arr;
}

@end
