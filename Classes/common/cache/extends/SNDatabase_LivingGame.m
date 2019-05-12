//
//  SNDatabase_LivingGame.m
//  sohunews
//
//  Created by yanchen wang on 12-6-15.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_LivingGame.h"

@implementation SNDatabase(LivingGame)

#pragma mark - live category

- (BOOL)updateLiveCategoryItem:(LiveCategoryItem *)categoryItem inDatabase:(FMDatabase *)db {
    if (!categoryItem) {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@) VALUES (?, ?, ?)", TB_LIVE_CATEGORY, TB_LIVE_CATEGORY_SUBID, TB_LIVE_CATEGORY_NAME, TB_LIVE_CATEGORY_LINK];
    
    [db executeUpdate:sql, categoryItem.subId, categoryItem.name, categoryItem.link];
    
    if ([db hadError]) {
        SNDebugLog(@"updateLiveCategoryItem : executeUpdate error:%d,%@",
                   [db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

- (NSArray *)livingCategoryItemsInDatabase:(FMDatabase *)db
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", TB_LIVE_CATEGORY];
    FMResultSet *rs = [db executeQuery:sql];
    if ([db hadError]) {
        SNDebugLog(@"livingCategoryItemsInDatabase error");
        return nil;
    }
    NSArray *categoryItems = [self getObjects:[LiveCategoryItem class] fromResultSet:rs];
    [rs close];
    
    return categoryItems;
}

#pragma mark -

- (BOOL)saveOneGame:(LivingGameItem *)aGame inDatabase:(FMDatabase *)db {
    if (!aGame) {
        return NO;
    }
    
    [db executeUpdate:@"INSERT INTO tbLivingGame (flag, isToday, isFocus, liveId, livePic, isHot, liveCat, liveSubCat, liveType, title, status, liveTime, liveDay, liveDate, visitorId, visitorName, visitorPic, visitorInfo, visitorTotal, hostId, hostName, hostPic, hostInfo, hostTotal, createAt, mediaType, pubType) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
     aGame.reserveFlag,
     aGame.isToday,
     aGame.isFocus,
     aGame.liveId,
     aGame.livePic,
     aGame.isHot,
     aGame.liveCat,
     aGame.liveSubCat,
     aGame.liveType,
     aGame.title,
     aGame.status,
     aGame.liveTime,
     aGame.liveDay,
     aGame.liveDate,
     aGame.visitorId,
     aGame.visitorName,
     aGame.visitorPic,
     aGame.visitorInfo,
     aGame.visitorTotal,
     aGame.hostId,
     aGame.hostName,
     aGame.hostPic,
     aGame.hostInfo,
     aGame.hostTotal,
     [NSDate nowTimeIntervalNumber],
     [NSNumber numberWithInt:aGame.mediaType],
     aGame.pubType];
    if ([db hadError]) {
        SNDebugLog(@"save one game error: %@", [db lastErrorMessage]);
        return NO;
    }
    
    return YES;
}

- (BOOL)updateTodayLivingGames:(NSArray *)gamesArray {
    __block BOOL bRet = NO;
    
    @autoreleasepool {
        NSMutableArray *oldGames = [NSMutableArray array];
        [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
            [oldGames addObjectsFromArray:[self livingGamesTodayInDatabase:db]];
        }];
        for (LivingGameItem *aGame in gamesArray) {
            for (LivingGameItem *oldGame in oldGames) {
                if ([oldGame.liveId isEqualToString:aGame.liveId]) {
                    aGame.reserveFlag = oldGame.reserveFlag;
                    break;
                }
            }
        }
                
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            bRet = [db executeUpdate:@"DELETE FROM tbLivingGame WHERE isToday = 1"];
            if ([db hadError]) {
                SNDebugLog(@"delete tbLivingGame error");
                *rollback = YES;
                return ;
            }
            for (LivingGameItem *aGame in gamesArray) {
                bRet = [self saveOneGame:aGame inDatabase:db];
                if (!bRet) {
                    *rollback = YES;
                }
            }
        }];
    }
    return bRet;
}

- (BOOL)updateLivingCategoryItems:(NSArray *)livingCategoryArr {
    __block BOOL bRet = NO;
    
    @autoreleasepool {
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", TB_LIVE_CATEGORY];
            bRet = [db executeUpdate:sql];
            if ([db hadError]) {
                SNDebugLog(@"delete TB_LIVE_CATEGORY error");
                *rollback = YES;
                return ;
            }
            for (LiveCategoryItem *aItem in livingCategoryArr) {
                bRet = [self updateLiveCategoryItem:aItem inDatabase:db];
                if (!bRet) {
                    *rollback = YES;
                }
            }
        }];
    }
    return bRet;
}

- (BOOL)updateForecastLivingGames:(NSArray *)gamesArray {
    __block BOOL bRet = YES;
    @autoreleasepool {
        NSMutableArray *oldGames = [NSMutableArray array];
        [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
            [oldGames addObjectsFromArray:[self livingGamesForecastInDatabase:db]];
        }];
        for (LivingGameItem *aGame in gamesArray) {
            for (LivingGameItem *oldGame in oldGames) {
                if ([oldGame.liveId isEqualToString:aGame.liveId]) {
                    aGame.reserveFlag = oldGame.reserveFlag;
                    break;
                }
            }
        }
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            bRet =  [db executeUpdate:@"DELETE FROM tbLivingGame WHERE isToday = 0"];
            if ([db hadError]) {
                SNDebugLog(@"delete tbLivingGame error");
                *rollback = YES;
                return ;
            }
            for (LivingGameItem *aGame in gamesArray) {
                bRet = [self saveOneGame:aGame inDatabase:db];
                if (!bRet) {
                    *rollback = YES;
                    break;
                }
            }
        }];
    }
    return bRet;
}

- (BOOL)updateLivingGame:(LivingGameItem *)game {
    __block BOOL bRet = YES;
    if (game) {
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString *replaceStr = @"REPLACE INTO tbLivingGame (liveId,flag,isToday,isFocus,livePic,isHot, liveCat,liveSubCat,liveType,title,status,liveTime,liveDay,liveDate,visitorId, visitorName,visitorPic,visitorInfo,visitorTotal,hostId,hostName,hostPic,hostInfo, hostTotal, createAt, mediaType, pubType) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            bRet = [db executeUpdate:replaceStr, game.liveId,
             game.reserveFlag, game.isToday, game.isFocus, game.livePic, game.isHot, game.liveCat, game.liveSubCat,
             game.liveType, game.title, game.status, game.liveTime, game.liveDay, game.liveDate,
             game.visitorId, game.visitorName, game.visitorPic, game.visitorInfo, game.visitorTotal,
             game.hostId, game.hostName, game.hostPic, game.hostInfo, game.hostTotal, [NSDate nowTimeIntervalNumber], [NSNumber numberWithInt:game.mediaType], game.pubType];

            if ([db hadError]) {
                SNDebugLog(@"update a game error");
                *rollback = YES;
                return;
            }
        }];
    } else {
        bRet = NO;
    }
    return bRet;
}

- (LivingGameItem *)getLiveItemByLiveId:(NSString *)liveId {
    __block LivingGameItem *item = nil;

    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbLivingGame WHERE liveId = ?",liveId];
        if ([db hadError]) {
            SNDebugLog(@"query a game error");
            return;
        }
        item = [self getFirstObject:[LivingGameItem class] fromResultSet:rs];
        [rs close];

    }];
        
    return item;
}

- (NSArray *)livingGamesTodayInDatabase:(FMDatabase *)db
{
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbLivingGame WHERE isToday = 1"];
    if ([db hadError]) {
        SNDebugLog(@"get today games error");
        return nil;
    }
    NSArray *games = [self getObjects:[LivingGameItem class] fromResultSet:rs];
    [rs close];
    
    return games;

}

- (NSArray *)livingGamesToday {
    NSMutableArray *games = [[NSMutableArray alloc] init];

    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        [games addObjectsFromArray:[self livingGamesTodayInDatabase:db]];
    }];
    return games;
}

- (NSArray *)livingCategoryItems {
    NSMutableArray *games = [[NSMutableArray alloc] init];
    
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        [games addObjectsFromArray:[self livingCategoryItemsInDatabase:db]];
    }];
    return games;
}

- (NSArray *)livingGamesForecastInDatabase:(FMDatabase *)db
{
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbLivingGame WHERE isToday = 0"];
    if ([db hadError]) {
        SNDebugLog(@"get forecast games error");
        return nil;
    }
    NSArray *games = [self getObjects:[LivingGameItem class] fromResultSet:rs];
    [rs close];
    
    return games;

}

- (NSArray *)livingGamesForecast {
    NSMutableArray *games = [[NSMutableArray alloc] init];

    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        [games addObjectsFromArray:[self livingGamesForecastInDatabase:db]];
    }];
        
    return games;
}

- (BOOL)clearLivingGames {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbLivingGame"];
        if ([db hadError]) {
            SNDebugLog(@"clearLivingGames : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    
    return result;
}

@end
