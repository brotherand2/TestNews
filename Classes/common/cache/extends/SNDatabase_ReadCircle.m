//
//  SNDatabase_ReadCircle.m
//  sohunews
//
//  Created by jojo on 13-7-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase_ReadCircle.h"
#import "NSObject+YAJL.h"

#pragma mark - TimelineOriginContentObj
@interface TimelineOriginContentObj : NSObject

@property(nonatomic, copy) NSString *ID;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *contentId;
@property(nonatomic, copy) NSString *json;

@end

@implementation TimelineOriginContentObj
@synthesize ID = _ID;
@synthesize type = _type;
@synthesize contentId = _contentId;
@synthesize json = _json;

- (void)dealloc {

}

@end

#pragma mark - TimelineContentObj

@interface TimelineContentObj : NSObject

@property(nonatomic, copy) NSString *ID;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *shareId;
@property(nonatomic, copy) NSString *pid;
@property(nonatomic, copy) NSString *json;

- (SNTimelineTrendItem *)toTimelineObj;

@end

@implementation TimelineContentObj
@synthesize ID, type, shareId, pid, json;

- (void)dealloc {
     //(ID);
     //(type);
     //(shareId);
     //(pid);
     //(json);
}

- (SNTimelineTrendItem *)toTimelineObj {
    SNTimelineTrendItem *obj = nil;
    
    if (self.json.length > 0) {
        NSError *error = nil;
        NSDictionary *dicInfo = [self.json yajl_JSON:&error];
        if (error) {
            SNDebugLog(@"%@-%@:json  to timeline obj error %@",
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd),
                       [error localizedDescription]);
        }
        else if (dicInfo) {
            obj = [SNTimelineTrendItem timelineTrendFromDic:dicInfo];
        }
    }
    
    return obj;
}

@end


@implementation SNDatabase(ReadCircle)

#pragma mark - share original content

- (BOOL)addOrReplaceOneTimelineOriginObj:(SNTimelineOriginContentObject *)originObj withContentType:(SNTimelineContentType)type contentId:(NSString *)contentId {
    if (!originObj || contentId.length == 0) {
        SNDebugLog(@"%@:invalide arguments", NSStringFromSelector(_cmd));
        return NO;
    }
    
    NSString *json = [[originObj toDictionary] yajl_JSONString];
    if (json.length == 0) {
        SNDebugLog(@"%@:deserialization failed", NSStringFromSelector(_cmd));
        return NO;
    }
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        
        NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@, %@, %@) VALUES (?,?,?)",
                         TB_SHARE_READ_CIRCLE,
                         TB_SHARE_READ_CIRCLE_TYPE,
                         TB_SHARE_READ_CIRCLE_CONTENT_ID,
                         TB_SHARE_READ_CIRCLE_JSON];
        result = [db executeUpdate:sql, [NSString stringWithFormat:@"%d", type], contentId, json];
        
        if ([db hadError]) {
            SNDebugLog(@"%@-- add Or Replace One TimelineOriginObj failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    
    return result;
}

- (SNTimelineOriginContentObject *)getTimelineOriginObjByType:(SNTimelineContentType)type contentId:(NSString *)contentId {
    if (contentId.length == 0) {
        return nil;
    }
    
    __block  NSArray *items = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@",
                         TB_SHARE_READ_CIRCLE,
                         TB_SHARE_READ_CIRCLE_TYPE,
                         [NSString stringWithFormat:@"%d", type],
                         TB_SHARE_READ_CIRCLE_CONTENT_ID,
                         contentId];
        
        FMResultSet *rs = [db executeQuery:sql];
        if ([db hadError]) {
            SNDebugLog(@"%@-- failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        items = [self getObjects:[TimelineOriginContentObj class] fromResultSet:rs];
        [rs close];
        
    }];
    
    if (items.count > 0) {
        TimelineOriginContentObj *obj = [items objectAtIndex:0];
        NSError *error = nil;
        NSDictionary *jsonObj = [obj.json yajl_JSON:&error];
        
        if (error) {
            SNDebugLog(@"%@: serialization failed with error %@",
                       NSStringFromSelector(_cmd),
                       [error localizedDescription]);
            return nil;
        }
        
        return [SNTimelineOriginContentObject timelineOriginContentObjFromDic:jsonObj];
    }
    return nil;
}

- (BOOL)clearAllTimelineOriginObjs {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_SHARE_READ_CIRCLE]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    return result;
}

#pragma mark - timeline object
- (BOOL)setTimelineObjs:(NSArray *)timelineJsonObjs withGetType:(SNTimelineGetDataType)type pid:(NSString *)pid {
    if (pid.length == 0) {
        SNDebugLog(@"%@  error with  pid is empty", NSStringFromSelector(_cmd));
        return NO;
    }
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=%@ AND %@=%@",
                            TB_READCIRCLE_TIMELINE,
                            TB_READCIRCLE_TIMELINE_TYPE,
                            [NSString stringWithFormat:@"%d", type],
                            TB_READCIRCLE_TIMELINE_PID,
                            pid];
        result = [db executeUpdate:sqlStr];
        if ([db hadError]) {
            SNDebugLog(@"%@-- failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    
    if (result) {
        for (NSDictionary *timelineObjDic in timelineJsonObjs) {
            if ([timelineObjDic isKindOfClass:[NSDictionary class]]) {
                NSString *timelineJsonObj = [timelineObjDic yajl_JSONString];
                NSDictionary *shareInfoDic = [timelineObjDic dictionaryValueForKey:@"shareInfo" defalutValue:nil];
                NSString *shareId = [shareInfoDic stringValueForKey:@"id" defaultValue:nil];
                if (shareId && timelineJsonObj) {
                    result = [self addOrReplaceOneTimelineObj:timelineJsonObj withShareId:shareId getType:type pid:pid];
                    if (!result) break;
                }
            }
        }
    }    
    
    return result;
}

- (BOOL)addOrReplaceOneTimelineObj:(NSString *)timelineJsonObj withShareId:(NSString *)shareId getType:(SNTimelineGetDataType)type pid:(NSString *)pid {
    if (timelineJsonObj.length == 0 || pid.length == 0) {
        SNDebugLog(@"%@ : invalidate arguments", NSStringFromSelector(_cmd));
        return NO;
    }
    
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        
        NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@, %@, %@, %@) VALUES (?,?,?,?)",
                         TB_READCIRCLE_TIMELINE,
                         TB_READCIRCLE_TIMELINE_SHARE_ID,
                         TB_READCIRCLE_TIMELINE_PID,
                         TB_READCIRCLE_TIMELINE_TYPE,
                         TB_READCIRCLE_TIMELINE_JSON];
        result = [db executeUpdate:sql, shareId, pid, [NSString stringWithFormat:@"%d", type], timelineJsonObj];
        
        if ([db hadError]) {
            SNDebugLog(@"%@-- add Or Replace One TimelineOriginObj failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    
    return result;
}

- (NSArray *)getTimelineObjsByGetType:(SNTimelineGetDataType)type pid:(NSString *)pid {
    if (pid.length == 0) {
        SNDebugLog(@"%@  error with  pid is empty", NSStringFromSelector(_cmd));
        return nil;
    }
    
    __block  NSArray *items = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@",
                         TB_READCIRCLE_TIMELINE,
                         TB_READCIRCLE_TIMELINE_TYPE,
                         [NSString stringWithFormat:@"%d", type],
                         TB_READCIRCLE_TIMELINE_PID,
                         pid];
        
        FMResultSet *rs = [db executeQuery:sql];
        if ([db hadError]) {
            SNDebugLog(@"%@-- failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        
        items = [self getObjects:[TimelineContentObj class] fromResultSet:rs];
        [rs close];
        
    }];
    
    NSMutableArray *objsArray = [NSMutableArray array];
    for (TimelineContentObj *obj in items) {
        SNTimelineTrendItem *timelineObj = [obj toTimelineObj];
        if (timelineObj) [objsArray addObject:timelineObj];
    }
    
    return objsArray;
}

- (BOOL)clearAllTimelineObjs {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", TB_READCIRCLE_TIMELINE]];
        if ([db hadError]) {
            SNDebugLog(@"%@-- failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    return result;
}

@end
