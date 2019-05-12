//
//  SNDatabase_NewsImage.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase_NewsImage.h"
#import "SNDatabase_Private.h"


@implementation SNDatabase(NewsImage)

-(NSArray*)getNewsImageListInDatabase:(FMDatabase *)db
{
	return [self getNewsImageListWithTimeOrderOption:ORDER_OPT_DEFAULT inDatabase:db];
}
-(NSArray*)getNewsImageList
{
	return [self getNewsImageListWithTimeOrderOption:ORDER_OPT_DEFAULT];
}

-(NSArray*)getNewsImageListWithTimeOrderOption:(ORDER_OPTION)orderOpt inDatabase:(FMDatabase *)db
{
    FMResultSet *rs	= nil;
    switch (orderOpt) {
        case ORDER_OPT_ASC:
            rs = [db executeQuery:@"SELECT * FROM tbNewsImage ORDER BY time ASC"];
            break;
        case ORDER_OPT_DESC:
            rs = [db executeQuery:@"SELECT * FROM tbNewsImage ORDER BY time ASC"];
            break;
        case ORDER_OPT_DEFAULT:
        default:
            rs = [db executeQuery:@"SELECT * FROM tbNewsImage"];
            break;
    }
    
    if ([db hadError]) {
        SNDebugLog(@"getNewsImageListWithTimeOrderOption : executeQuery error :%d,%@"
                   ,[db lastErrorCode],[db lastErrorMessage]);
        return nil;
    }
    
    NSArray *newsImageList	= [self getObjects:[NewsImageItem class] fromResultSet:rs];
    [rs close];
    
	return newsImageList;
}


-(NSArray*)getNewsImageListWithTimeOrderOption:(ORDER_OPTION)orderOpt
{
    __block NSArray *newsImageList = nil;
	
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        newsImageList	= [self getNewsImageListWithTimeOrderOption:orderOpt inDatabase:db];
    }];
    
	return newsImageList;
}

-(NSArray*)getNewsImageByNewsId:(NSString*)newsId inDatabase:(FMDatabase *)db
{
    if ([newsId length] == 0) {
        SNDebugLog(@"getNewsImageByNewsId : Invalid newsId");
        return nil;
    }
    
    FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsImage WHERE newsId=?",newsId];
    if ([db hadError]) {
        SNDebugLog(@"getNewsImageByNewsId : executeQuery error :%d,%@,newsId=%@"
                   ,[db lastErrorCode],[db lastErrorMessage],newsId);
        return nil;
    }
    
    NSArray *newsImageList	= [self getObjects:[NewsImageItem class] fromResultSet:rs];
    [rs close];
    return newsImageList;
}

//-(NSArray*)getNewsImageByNewsId:(NSString*)newsId
//{
//    __block NSArray *newsImageList = nil;
//    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
//        newsImageList = [self getNewsImageByNewsId:newsId inDatabase:db];
//    }];
//    return newsImageList;
//}

-(NSArray*)getNewsImageByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db
{
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"getNewsImageByTermId : Invalid termId=%@ or newsId=%@",termId,newsId);
		return nil;
	}
    FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsImage WHERE termId=? AND newsId=?",termId,newsId];
    if ([db hadError]) {
        SNDebugLog(@"getNewsImageByTermId : executeQuery error :%d,%@,termId=%@,newsId=%@"
                   ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
        return nil;
    }
    
    NSArray *newsImageList	= [self getObjects:[NewsImageItem class] fromResultSet:rs];
    [rs close];
	return newsImageList;
}

-(NSArray*)getNewsImageByTermId:(NSString*)termId newsId:(NSString*)newsId;
{
	__block NSArray *newsImageList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        newsImageList	= [self getNewsImageByTermId:termId newsId:newsId inDatabase:db];
    }];
	return newsImageList;
}

-(NSArray*)getNewsShareImageListByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db
{
    if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"getNewsShareImageListByTermId : Invalid termId=%@ or newsId=%@",termId,newsId);
		return nil;
	}
    FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsImage WHERE termId=? AND newsId=? AND type=?"
                       ,termId,newsId,NEWSSHAREIMAGE_TYPE];
    if ([db hadError]) {
        SNDebugLog(@"getNewsShareImageListByTermId : executeQuery error :%d,%@,termId=%@,newsId=%@"
                   ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
        return nil;
    }
    
    NSArray *newsImageList	= [self getObjects:[NewsImageItem class] fromResultSet:rs];
    [rs close];

	return newsImageList;
}

-(NSArray*)getNewsShareImageListByTermId:(NSString*)termId newsId:(NSString*)newsId
{
   __block NSArray *newsImageList = nil;
   [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        newsImageList	= [self getNewsShareImageListByTermId:termId newsId:newsId inDatabase:db];
    }];
	return newsImageList;
}

-(NewsImageItem*)getNewsImageByUrl:(NSString*)url inDatabase:(FMDatabase *)db
{
	if ([url length] == 0) {
		SNDebugLog(@"getNewsImageByUrl : Invalid url");
		return nil;
	}
    FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsImage WHERE url=?",url];
    if ([db hadError]) {
        SNDebugLog(@"getNewsImageByUrl : executeQuery error :%d,%@,url=%@"
                   ,[db lastErrorCode],[db lastErrorMessage],url);
        return nil;
    }
    
    NewsImageItem *newsImage	= [self getFirstObject:[NewsImageItem class] fromResultSet:rs];
    [rs close];
    return newsImage;
}

-(NewsImageItem*)getNewsImageByUrl:(NSString*)url
{
    __block NewsImageItem *newsImageItem = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        newsImageItem = [self getNewsImageByUrl:url inDatabase:db];
    }];
    return newsImageItem;
}

-(BOOL)addSingleNewsImage:(NewsImageItem*)newsImage inDatabase:(FMDatabase *)db
{
    return [self addSingleNewsImage:newsImage updateIfExist:YES inDatabase:db];
}

-(BOOL)addSingleNewsImage:(NewsImageItem*)newsImage
{
	return [self addSingleNewsImage:newsImage updateIfExist:YES];
}

-(BOOL)addMultiNewsImage:(NSArray*)newsImageList inDatabase:(FMDatabase *)db;
{
    return [self addMultiNewsImage:newsImageList updateIfExist:YES inDatabase:db];
}
-(BOOL)addMultiNewsImage:(NSArray*)newsImageList
{
	return [self addMultiNewsImage:newsImageList updateIfExist:YES];
}
-(BOOL)addSingleNewsImage:(NewsImageItem*)newsImage updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleNewsImage:newsImage updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
-(BOOL)addSingleNewsImage:(NewsImageItem*)newsImage updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db
{
	if (newsImage == nil) {
		SNDebugLog(@"addSingleNewsImage : Invalid newsImage");
		return NO;
	}

    if (bUpdateIfExist) {
        [db executeUpdate:@"REPLACE INTO tbNewsImage (ID,termId,newsId,imageId,type,time,link,url,path,title,createAt,width,height) \
         VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?)",newsImage.termId,newsImage.newsId,newsImage.imageId,newsImage.type
         ,newsImage.time,newsImage.link,newsImage.url,newsImage.path,newsImage.title,[NSDate nowTimeIntervalNumber],[NSNumber numberWithInteger:newsImage.width],[NSNumber numberWithInteger:newsImage.height]];
        if ([db hadError]) {
            SNDebugLog(@"addSingleNewsImage : executeUpdate error :%d,%@,newsImage:%@"
                       ,[db lastErrorCode],[db lastErrorMessage],newsImage);
            return NO;
        }
    } else {
        NSInteger count	= [db intForQuery:@"SELECT COUNT(*) FROM tbNewsImage WHERE url=?",newsImage.url];
        if ([db hadError]) {
            SNDebugLog(@"addSingleNewsImage : executeQuery for exist newsImage error :%d,%@,url=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],newsImage.url);
            return NO;
        }
        if (count == 0) {
            [db executeUpdate:@"INSERT INTO tbNewsImage (ID,termId,newsId,imageId,type,time,link,url,path,title,createAt,width,height) \
             VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?)",newsImage.termId,newsImage.newsId,newsImage.imageId,newsImage.type
             ,newsImage.time,newsImage.link,newsImage.url,newsImage.path,newsImage.title,[NSDate nowTimeIntervalNumber],[NSNumber numberWithInteger:newsImage.width],[NSNumber numberWithInteger:newsImage.height]];
            if ([db hadError]) {
                SNDebugLog(@"addSingleNewsImage : executeUpdate error :%d,%@,newsImage:%@"
                           ,[db lastErrorCode],[db lastErrorMessage],newsImage);
                return NO;
            }
        }
    }
    return YES;
}

-(BOOL)addMultiNewsImage:(NSArray*)newsImageList updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db
{
	if ([newsImageList count] == 0) {
		SNDebugLog(@"addMultiNewsImage : Invalid newsImageList");
		return NO;
	}
	
    BOOL result = YES;
    for (NewsImageItem *newsImage in newsImageList) {
        result = [self addSingleNewsImage:newsImage inDatabase:db];
        if (!result) {
            break;
        }
    }
    return result;
}

-(BOOL)addMultiNewsImage:(NSArray*)newsImageList updateIfExist:(BOOL)bUpdateIfExist
{
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addMultiNewsImage:newsImageList updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
	return result;
}

-(BOOL)deleteNewsImageByUrl:(NSString*)url
{
	if ([url length] == 0) {
		SNDebugLog(@"deleteNewsImageByUrl : Invalid Url");
		return NO;
	}
	__block BOOL result = YES;
    __block NewsImageItem *newsImage = nil;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        newsImage	= [self getNewsImageByUrl:url inDatabase:db];
        if (newsImage == nil) {
            result = NO;
            return ;
        }
        
        result =[db executeUpdate:@"DELETE FROM tbNewsImage WHERE url=?",url];
        if ([db hadError]) {
            SNDebugLog(@"deleteNewsImageByUrl : executeUpdate error :%d,%@,url=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],url);
            *rollback = YES;
            return;
        }
        
    }];
    
	if (result) {
        //删除图片文件
        NSError *error		= nil;
        NSFileManager *fm	= [NSFileManager defaultManager];
        BOOL bSucceed	= [fm removeItemAtPath:newsImage.path error:&error];
        if (!bSucceed) {
            SNDebugLog(@"deleteNewsImageByUrl: remove newsImage failed:%d,%@,path=%@"
                       ,[error code],[error localizedDescription],newsImage.path);
        }
    }
	
	return result;
}

-(BOOL)deleteNewsImageByNewsId:(NSString*)newsId
{
	if ([newsId length] == 0) {
		SNDebugLog(@"deleteNewsImageByNewsId : Invalid newsId");
		return NO;
	}
	__block BOOL result = YES;
    __block NSArray *newsImageList = nil;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        newsImageList	= [self getNewsImageByNewsId:newsId inDatabase:db];
        if ([newsImageList count] == 0) {
            result = NO;
            return;
        }
        
        result = [db executeUpdate:@"DELETE FROM tbNewsImage WHERE newsId=?",newsId];
        if ([db hadError]) {
            SNDebugLog(@"deleteNewsImageByNewsId : executeUpdate error :%d,%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],newsId);
            *rollback = YES;
            return;
        }
    }];
	
	if (result) {
        //删除图片文件
        NSError *error		= nil;
        NSFileManager *fm	= [NSFileManager defaultManager];
        for (NewsImageItem *newsImage in newsImageList){
            if ([newsImage.path length] == 0) {
                continue;
            }
            
            BOOL bSucceed	= [fm removeItemAtPath:newsImage.path error:&error];
            if (!bSucceed) {
                SNDebugLog(@"deleteNewsImageByNewsId: remove newsImage failed:%d,%@,path=%@"
                           ,[error code],[error localizedDescription],newsImage.path);
            }
        }
    }

	return result;
}

-(BOOL)deleteNewsImageByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db
{
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"deleteNewsImageByTermId : Invalid termId=%@ or newsId=%@",termId,newsId);
		return NO;
	}
    
    BOOL result = [db executeUpdate:@"DELETE FROM tbNewsImage WHERE termId=? AND newsId=?",termId,newsId];
    if ([db hadError]) {
        SNDebugLog(@"deleteNewsImageByNewId : executeUpdate error :%d,%@,termId=%@,newsId=%@"
                   ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
    }
    	
	return result;
}

-(BOOL)clearNewsImageList
{
    __block BOOL result = YES;
    __block NSArray *newsImageList	 = nil;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        newsImageList	= [self getNewsImageListInDatabase:db];
        if ([newsImageList count] == 0) {
            return;
        }
        
        result = [db executeUpdate:@"DELETE FROM tbNewsImage"];
        if ([db hadError]) {
            SNDebugLog(@"clearNewsImageList : executeUpdate error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
    }];
	
	if (result) {
        //删除图片文件
        NSError *error		= nil;
        NSFileManager *fm	= [NSFileManager defaultManager];
        for (NewsImageItem *newsImage in newsImageList){
            if ([newsImage.path length] == 0) {
                continue;
            }
            
            BOOL bSucceed	= [fm removeItemAtPath:newsImage.path error:&error];
            if (!bSucceed) {
                SNDebugLog(@"clearNewsImageList: remove newsImage failed:%d,%@,path=%@"
                           ,[error code],[error localizedDescription],newsImage.path);
            }
        }
    }
	
	
	return result;
}


@end
