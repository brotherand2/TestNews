//
//  SNDatabase_GroupPhoto.m
//  sohunews
//
//  Created by ivan on 3/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_GroupPhoto.h"

@implementation SNDatabase(GroupPhoto)


-(NSMutableArray*)getGroupPhotoImageUrls:(FMResultSet*)rs
{
	if (rs == nil) {
		SNDebugLog(@"getGroupPhotoImageUrls : Invalid rs");
		return nil;
	}
	NSMutableArray *urls	= [[NSMutableArray alloc] init];
	while ([rs next]) {
        @autoreleasepool {
            [urls addObject:[rs stringForColumn:TB_GROUPPHOTOURL_URL]];
        }
	}
	return urls;
}
-(BOOL)addSingleGroupPhoto:(GroupPhotoItem *)aPhoto updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleGroupPhoto:aPhoto updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)addSingleGroupPhoto:(GroupPhotoItem *)aPhoto updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db
{
	if (aPhoto == nil) {
		SNDebugLog(@"addSingleGroupPhoto : Invalid GroupPhotoItem");
		return YES;
	}
	if (bUpdateIfExist) {

        [db executeUpdate:@"REPLACE into tbGroupPhoto(title, time, commentNum, favoriteNum, imageNum, newsId,type,typeId,sublink,timelineIndex,readFlag,createAt) values(?,?,?,?,?,?,?,?,?,?,?,?)"
         ,aPhoto.title,aPhoto.time,aPhoto.commentNum,aPhoto.favoriteNum,aPhoto.imageNum,aPhoto.newsId,aPhoto.type,aPhoto.typeId,aPhoto.sublink,aPhoto.timelineIndex,[NSNumber numberWithInt:aPhoto.readFlag], [NSDate nowTimeIntervalNumber]];
        if ([db hadError]) {
            return NO;
        }
        [db executeUpdate:@"delete from tbGroupPhotoUrl where newsId = ? and typeId = ? and type=?", aPhoto.newsId, aPhoto.typeId,aPhoto.type];
        if ([db hadError]) {
            return NO;
        }
        for (NSString *url in aPhoto.images) {
            [db executeUpdate:@"insert into tbGroupPhotoUrl(url, newsId, typeId, type, createAt) values(?,?,?,?,?)",url,aPhoto.newsId,aPhoto.typeId,aPhoto.type,[NSDate nowTimeIntervalNumber]];
            if ([db hadError]) {
                break;
            }
        }
    } else {
        NSInteger count	= [db intForQuery:@"SELECT COUNT(*) FROM tbGroupPhoto WHERE newsId=? and typeId=? and type=?",aPhoto.newsId,aPhoto.typeId, aPhoto.type];
        if ([db hadError]) {
            SNDebugLog(@"addSingleGroupPhoto : executeQuery for exist one error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return NO;
        }
        if (count==0) {
            [db executeUpdate:@"insert into tbGroupPhoto(title, time, commentNum, favoriteNum, imageNum, newsId,type,typeId,sublink,timelineIndex,readFlag,createAt) values(?,?,?,?,?,?,?,?,?,?,?,?)"
             ,aPhoto.title,aPhoto.time,aPhoto.commentNum,aPhoto.favoriteNum,aPhoto.imageNum,aPhoto.newsId,aPhoto.type,aPhoto.typeId,aPhoto.sublink,aPhoto.timelineIndex,[NSNumber numberWithInt:aPhoto.readFlag], [NSDate nowTimeIntervalNumber]];
            
            if ([db hadError]) {
                return NO;
            }
            [db executeUpdate:@"delete from tbGroupPhotoUrl where newsId = ? and typeId = ? and type=?", aPhoto.newsId, aPhoto.typeId,aPhoto.type];
            if ([db hadError]) {
                return NO;
            }
            for (NSString *url in aPhoto.images) {
                [db executeUpdate:@"insert into tbGroupPhotoUrl(url, newsId, typeId, type, createAt) values(?,?,?,?,?)",url,aPhoto.newsId,aPhoto.typeId,aPhoto.type,[NSDate nowTimeIntervalNumber]];
                if ([db hadError]) {
                    return NO;
                }
            }

        }
    }
    return YES;
}

-(BOOL)addMultiGroupPhoto:(NSArray*)aPhotoArray updateIfExist:(BOOL)bUpdateIfExist
{
	if ([aPhotoArray count] == 0) {
		SNDebugLog(@"addMultiGroupPhoto : Invalid aPhotoArray");
	}
	
	__block BOOL bSucceed	= YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (GroupPhotoItem *photo in aPhotoArray) {
            bSucceed = [self addSingleGroupPhoto:photo updateIfExist:bUpdateIfExist inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                return ;
            }
        }
        
    }];
	
	return bSucceed;
}

-(BOOL)addMultiGroupPhoto:(NSArray*)aPhotoArray {
    return [self addMultiGroupPhoto:aPhotoArray updateIfExist:YES];
}
-(NSMutableArray *)queryGroupPhotoUrlsByNewsId:(NSString *)aNewsId
                                       andType:(NSString *)aType
                                     andTypeId:(NSString *)aTypeId
{
    __block NSMutableArray *urls = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        urls = [self queryGroupPhotoUrlsByNewsId:aNewsId andType:aType andTypeId:aTypeId inDatabase:db];
    }];
    return urls;
}
-(NSMutableArray *)queryGroupPhotoUrlsByNewsId:(NSString *)aNewsId
                                       andType:(NSString *)aType
                                     andTypeId:(NSString *)aTypeId
                                    inDatabase:(FMDatabase *)db
{
    FMResultSet *rs	= [db executeQuery:@"select url from tbGroupPhotoUrl where newsId = ? and typeId=? and type=?", aNewsId, aTypeId, aType];
    if ([db hadError]) {
		SNDebugLog(@"queryGroupPhotoUrlsByNewsId : error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
		return nil;
	}
	NSMutableArray *urls = [self getGroupPhotoImageUrls:rs];
	[rs close];

    return urls;
}

-(NSMutableArray*)getCachedGroupPhotoByPage:(int)pageNum 
                                    andType:(NSString *)aType
                                  andTypeId:(NSString *)aTypeId {
    //SELECT * FROM tbGroupPhoto ORDER BY date(time) desc limit %d offset %d
    __block NSMutableArray *cacheList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbGroupPhoto where typeId='%@' and type='%@' ORDER BY timelineIndex DESC limit %d offset %d", aTypeId, aType, KPhotoPaginationNum, pageNum*KPhotoPaginationNum];
        FMResultSet *rs	= [db executeQuery:sql];
        if ([db hadError]) {
            SNDebugLog(@"getCachedGroupPhotoByPage : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        cacheList = (NSMutableArray *)[self getObjects:[GroupPhotoItem class] fromResultSet:rs];
        [rs close];
        for (GroupPhotoItem *photo in cacheList) {
            NSMutableArray *urls = [self queryGroupPhotoUrlsByNewsId:photo.newsId andType:aType andTypeId:aTypeId inDatabase:db];
            if (urls) {
                photo.images = urls;
            }
        }
    }];
    
   
    
    return cacheList;
}

-(NSMutableArray *)getCachedGroupPhotoByTimelineIndex:(NSString *)timelineIndex 
                                              andType:(NSString *)aType
                                            andTypeId:(NSString *)aTypeId {
    __block NSMutableArray *cacheList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = nil;
        if (timelineIndex) {
            sql = [NSString stringWithFormat:@"SELECT * FROM tbGroupPhoto where typeId='%@' and type='%@' and timelineIndex < %d ORDER BY timelineIndex DESC limit %d", aTypeId, aType, [timelineIndex intValue], KPhotoPaginationNum];
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM tbGroupPhoto where typeId='%@' and type='%@' ORDER BY timelineIndex DESC limit %d", aTypeId, aType, KPhotoPaginationNum];
        }
        FMResultSet *rs	= [db executeQuery:sql];
        if ([db hadError]) {
            SNDebugLog(@"getCachedGroupPhotoByPage : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        cacheList = (NSMutableArray *)[self getObjects:[GroupPhotoItem class] fromResultSet:rs];
        [rs close];
        for (GroupPhotoItem *photo in cacheList) {
            NSMutableArray *urls = [self queryGroupPhotoUrlsByNewsId:photo.newsId andType:aType andTypeId:aTypeId inDatabase:db];
            if (urls) {
                photo.images = urls;
            }
        }
    }];



    return cacheList;
}

-(NSMutableArray *)getFirstCachedPhoto:(NSString *)timelineIndex 
                                              andType:(NSString *)aType
                                            andTypeId:(NSString *)aTypeId {
    __block NSMutableArray *cacheList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = nil;
        if (timelineIndex) {
            sql = [NSString stringWithFormat:@"SELECT * FROM tbGroupPhoto where typeId='%@' and type='%@' and timelineIndex >= %d ORDER BY timelineIndex DESC limit %d", aTypeId, aType, [timelineIndex intValue], KPhotoPaginationNum];
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM tbGroupPhoto where typeId='%@' and type='%@' ORDER BY timelineIndex DESC limit %d", aTypeId, aType, KPhotoPaginationNum];
        }
        FMResultSet *rs	= [db executeQuery:sql];
        if ([db hadError]) {
            SNDebugLog(@"getCachedGroupPhotoByPage : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        cacheList = (NSMutableArray *)[self getObjects:[GroupPhotoItem class] fromResultSet:rs];
        [rs close];
        for (GroupPhotoItem *photo in cacheList) {
            NSMutableArray *urls = [self queryGroupPhotoUrlsByNewsId:photo.newsId andType:aType andTypeId:aTypeId inDatabase:db];
            if (urls) {
                photo.images = urls;
            }
        }
    }];

    return cacheList;
}

-(NSMutableArray *)getAllCachedPhotoByTimeline:(NSString *)timelineIndex
                               andType:(NSString *)aType
                             andTypeId:(NSString *)aTypeId
{
    __block NSMutableArray *cacheList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbGroupPhoto where typeId='%@' and type='%@' and timelineIndex >= %d ORDER BY timelineIndex DESC", aTypeId, aType, [timelineIndex intValue]];
        
        FMResultSet *rs	= [db executeQuery:sql];
        if ([db hadError]) {
            SNDebugLog(@"getCachedGroupPhotoByPage : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        cacheList = (NSMutableArray *)[self getObjects:[GroupPhotoItem class] fromResultSet:rs];
        [rs close];
 
        for (GroupPhotoItem *photo in cacheList) {
            NSMutableArray *urls = [self queryGroupPhotoUrlsByNewsId:photo.newsId andType:aType andTypeId:aTypeId inDatabase:db];
            if (urls) {
                photo.images = urls;
            }
        }
    }];
    
    return cacheList;
}

-(BOOL)updateFavoriteNum:(NSString *)favNum
                byNewsId:(NSString *)newsId 
                 andType:(NSString *)aType
               andTypeId:(NSString *)aTypeId 
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"update tbGroupPhoto set favoriteNum = ?, createAt=? where newsId = ? and typeId = ? and type=?", favNum, [NSDate nowTimeIntervalNumber], newsId, aTypeId, aType];
        
        if ([db hadError]) {
            SNDebugLog(@"addSingleGroupPhoto : update tbGroupPhoto set...");
            *rollback = YES;
            return;
        }
    }];
    
    return result;
}

-(BOOL)deleteCachedPhotosByType:(NSString *)aType
                      andTypeId:(NSString *)aTypeId {
    __block BOOL bSucceed	= TRUE;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        bSucceed = [db executeUpdate:@"delete from tbGroupPhoto where typeId = ? and type=?",aTypeId, aType];
        if ([db hadError]) {
            *rollback =  YES;
            return ;
        }
        
        bSucceed = [db executeUpdate:@"delete from tbGroupPhotoUrl where typeId = ? and type=?",aTypeId, aType];
        if ([db hadError]) {
            *rollback =  YES;
            return;
        }
    }];
    
	return bSucceed;
}

-(NSString*)getMaxPhotoTimelineIndexByType:(NSString *)aType
                                 andTypeId:(NSString *)aTypeId
{
	if ([aType length] == 0 || [aTypeId length] == 0) {
		SNDebugLog(@"getMaxPhotoTimelineIndexByType : Invalid aType=%@,aTypeId=%@",aType,aTypeId);
        return nil;
	}
    __block NSString *ids = @"0";
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT MAX(timelineIndex) AS maxTimelineIndex FROM tbGroupPhoto where typeId = ? and type=?", aTypeId, aType];
        if ([db hadError]) {
            SNDebugLog(@"getMaxPhotoTimelineIndexByType : executeQuery error :%d,%@,aType=%@,aTypeId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],aType,aTypeId);
            return;
        }
        if ([rs next]) {
            ids = [NSString stringWithFormat:@"%d", [rs intForColumn:@"maxTimelineIndex"]];
        }
        [rs close];
    }];
	
	return ids;
}

-(NSString*)getMinPhotoTimelineIndexByType:(NSString *)aType
                                   andTypeId:(NSString *)aTypeId
{
	if ([aType length] == 0 || [aTypeId length] == 0) {
		SNDebugLog(@"getMinPhotoTimelineIndexByType : Invalid aType=%@,aTypeId=%@",aType,aTypeId);
		return nil;
	}
    __block NSString *ids = @"-1";
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT MIN(timelineIndex) AS minTimelineIndex FROM tbGroupPhoto where typeId = ? and type=?", aTypeId, aType];
        if ([db hadError]) {
            SNDebugLog(@"getMinPhotoTimelineIndexByType : executeQuery error :%d,%@,aType=%@,aTypeId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],aType,aTypeId);
            return;
        }
        
        
        if ([rs next]) {
            ids = [NSString stringWithFormat:@"%d", [rs intForColumn:@"minTimelineIndex"]];
        }
        [rs close];
    }];
	   
	return ids;
}

//删除滚动新闻列表
-(BOOL)clearGroupPhotoList
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbGroupPhoto"];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"clearGroupPhotoList : error :%d,%@" ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        result = [db executeUpdate:@"DELETE FROM tbGroupPhotoUrl"];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"clear tbGroupPhotoUrl : error :%d,%@" ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
    }];
	return result;
}

-(BOOL)markPhotoItemAsReadByTypeId:(NSString *)typeId newsId:(NSString *)newsId type:(NSString *)type {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"update tbGroupPhoto set readFlag = 1, createAt=? where newsId = ? and typeId = ? and type=?", [NSDate nowTimeIntervalNumber], newsId, typeId, type];
        if ([db hadError]) {
            *rollback = YES;
        }
    }];
    
    return result;
}

-(int)checkPhotoNewsReadOrNot:(NSString *)newsId typeId:(NSString *)typeId type:(NSString *)type {
    __block int readFlag = 0;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT readFlag FROM tbGroupPhoto where typeId=? and type=? and newsId=?", typeId, type, newsId];
        if ([db hadError]) {
            SNDebugLog(@"checkPhotoNewsReadOrNot : executeQuery error :%d,%@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        if ([rs next]) {
            readFlag = [rs intForColumn:@"readFlag"];
        }
        [rs close];
    }];
    return readFlag;
}

//-(BOOL)updatePhotoNewsRead:(NSString *)newsId typeId:(NSString *)typeId type:(NSString *)type flag:(int)readFlag {
//    __block BOOL result = YES;
//    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        result =  [db executeUpdate:@"update tbGroupPhoto set readFlag=? typeId=? and type=? and newsId=?", readFlag, typeId, type, newsId];
//        if ([db hadError]) {
//            *rollback = YES;
//            SNDebugLog(@"updatePhotoNewsRead : executeUpdate error :%d,%@"
//                       ,[db lastErrorCode],[db lastErrorMessage]);
//            return;
//        }
//    }];
//    return result;
//}

@end
