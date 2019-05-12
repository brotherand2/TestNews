//
//  SNDatabase+LiveInvite.m
//  sohunews
//
//  Created by chenhong on 13-12-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase+LiveInvite.h"
#import "SNLiveInviteModel.h"

@implementation SNDatabase (LiveInvite)

// add
- (BOOL)addOrUpdateLiveInviteItem:(SNLiveInviteStatusObj *)item {
    if (item.liveId.length == 0 || item.passport.length == 0) {
        return NO;
    }
    
    __block BOOL bRet = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (!(bRet = [self addOrUpdateLiveInviteItem:item inDatabase:db])) {
            *rollback = YES;
        }
    }];
    
    return bRet;
}

// delete
- (BOOL)clearLiveInviteItems:(NSNumber *)expiredPoint {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ < ?",
                         TB_LIVE_INVITE,
                         TB_LIVE_INVITE_CREATE];
        result =  [db executeUpdate:sql, expiredPoint];
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
	return result;
}

- (BOOL)clearAllLiveInviteItems {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", TB_LIVE_INVITE];
        result =  [db executeUpdate:sql];
        if (!result)
        {
            *rollback = YES;
            return ;
        }
    }];
	return result;
}

- (BOOL)deleteLiveInviteItemByLiveId:(NSString *)liveId
                            passport:(NSString *)passport {
    if (liveId.length == 0 || passport.length == 0) {
        return NO;
    }

    __block BOOL bRet = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ? AND %@ = ?",
                         TB_LIVE_INVITE,
                         TB_LIVE_INVITE_LIVEID,
                         TB_LIVE_INVITE_PASSPORT];
        
        bRet = [db executeUpdate:sql, liveId, passport];
        
        if ([db hadError] || !bRet) {
            bRet = NO;
            *rollback = YES;
        }
    }];
    
    return bRet;
}

// get
- (SNLiveInviteStatusObj *)getLiveInviteItemByLiveId:(NSString *)liveId
                                            passport:(NSString *)passport {
    
    __block SNLiveInviteStatusObj *obj = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? AND %@ = ?",
                         TB_LIVE_INVITE,
                         TB_LIVE_INVITE_LIVEID,
                         TB_LIVE_INVITE_PASSPORT];
        FMResultSet *rs	= [db executeQuery:sql, liveId, passport];
        if ([db hadError]) {
            SNDebugLog(@"%@: executeUpdate error:%d,%@",
                       NSStringFromSelector(_cmd),
                       [db lastErrorCode],
                       [db lastErrorMessage]);
            return;
        }
        
        NSArray *arr = [self getLiveInviteItemsFromResultSet:rs];
        if (arr.count > 0) {
            obj = arr[0];
        }
        else {
            SNDebugLog(@"%@: no invite item found for liveId:%@ passport:%@", NSStringFromSelector(_cmd), liveId, passport);
        }
        
        [rs close];
    }];
    return obj;
}

#pragma private
- (BOOL)addOrUpdateLiveInviteItem:(SNLiveInviteStatusObj *)item
                       inDatabase:(FMDatabase *)db {
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@, %@, %@, %@, %@) VALUES (?,?,?,?,?)",
                     TB_LIVE_INVITE,
                     TB_LIVE_INVITE_LIVEID,
                     TB_LIVE_INVITE_PASSPORT,
                     TB_LIVE_INVITE_STATUS,
                     TB_LIVE_INVITE_SHOWMSG,
                     TB_LIVE_INVITE_CREATE];
    
    [db executeUpdate:sql, item.liveId, item.passport, item.inviteStatus,
     item.showmsg, [NSNumber numberWithInt:(int)[[NSDate date] timeIntervalSince1970]]];
    
    if ([db hadError]) {
        SNDebugLog(@"%@: executeUpdate error:%d,%@",
                   NSStringFromSelector(_cmd),
                   [db lastErrorCode],
                   [db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

- (NSArray *)getLiveInviteItemsFromResultSet:(FMResultSet *)rs {
    if (!rs) {
        SNDebugLog(@"%@: invalidate rs", NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    while ([rs next]) {
        @autoreleasepool {
            SNLiveInviteStatusObj *obj = [[SNLiveInviteStatusObj alloc] init];
            
            obj.liveId = [rs stringForColumn:TB_LIVE_INVITE_LIVEID];
            obj.passport = [rs stringForColumn:TB_LIVE_INVITE_PASSPORT];
            obj.showmsg = [rs stringForColumn:TB_LIVE_INVITE_SHOWMSG];
            obj.inviteStatus = [rs objectForColumnName:TB_LIVE_INVITE_STATUS];
            
            [arr addObject:obj];
            //obj);
        }
    }
    return arr;
}

@end
