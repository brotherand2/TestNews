//
//  SNDatabase_RecommendGallery.m
//  sohunews
//
//  Created by 雪 李 on 11-12-21.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_RecommendGallery.h"
#import "SNURLDataResponse.h"

@implementation SNDatabase(RecommendGallery)

-(NSArray*)getRecommendGallery
{
    __block NSArray *recommendGallery = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        recommendGallery = [self getRecommendGalleryInDatabase:db];
    }];
    return recommendGallery;
}

-(NSArray*)getRecommendGalleryInDatabase:(FMDatabase *)db
{
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbRecommendGallery"];
    if ([db hadError]) {
        SNDebugLog(@"getRecommendGalleryByrTermId : executeQuery error :%d,%@"
				   ,[db lastErrorCode],[db lastErrorMessage]);
        return nil;
    }
    
    NSArray *recommendGallery  = [self getObjects:[RecommendGallery class] fromResultSet:rs];
    [rs close];
    
    return recommendGallery;  
}

-(NSArray*)getRecommendGalleryByrTermId:(NSString *)rTermId rNewsId:(NSString *)rNewsId
{
   
    __block NSArray *recommendGallery = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        recommendGallery  = [self getRecommendGalleryByrTermId:rTermId rNewsId:rNewsId inDatabase:db];
    }];
    
    return recommendGallery;
}

-(NSArray*)getRecommendGalleryByrTermId:(NSString *)rTermId rNewsId:(NSString *)rNewsId inDatabase:(FMDatabase *)db
{
    if ([rTermId length] == 0 || [rNewsId length] == 0) {
        SNDebugLog(@"getRecommendGalleryByrTermId : Invalid params,rTermId = %@,rNewsId = %@",rTermId,rNewsId);
        return nil;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbRecommendGallery WHERE rTermId=? AND rNewsId=?",rTermId,rNewsId];
    if ([db hadError]) {
        SNDebugLog(@"getRecommendGalleryByrTermId : executeQuery error :%d,%@"
                   ,[db lastErrorCode],[db lastErrorMessage]);
        return nil;
    }
    
    NSArray *recommendGallery  = [self getObjects:[RecommendGallery class] fromResultSet:rs];
    [rs close];
    
    return recommendGallery;
}

-(NSString*)getRecommendGalleryIconPathByUrl:(NSString *)iconUrl
{
    if ([iconUrl length] == 0) {
        SNDebugLog(@"getRecommendGalleryIconPathByUrl : Invalid params");
        return nil;
    }
    
    __block NSArray *recommendGallery = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbRecommendGallery WHERE iconUrl=?",iconUrl];
        if ([db hadError]) {
            SNDebugLog(@"getRecommendGalleryIconPathByUrl : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        recommendGallery  = [self getObjects:[RecommendGallery class] fromResultSet:rs];
        [rs close];
    }];
    
    //同一个组图可能是其他多个组图的推荐组图，因此统一url的图片，可能存在多份。其中任何一个如果被下载过，重用其中的那个即可
    for (RecommendGallery *item in recommendGallery) {
        if ([item.iconPath length] != 0) {
            return item.iconPath;
        }
    }
    
    return nil;
}
-(BOOL)addSingleRecommendGallery:(RecommendGallery*)recommendGalleryItem inDatabase:(FMDatabase *)db
{
    return [self addSingleRecommendGallery:recommendGalleryItem updateIfExist:YES inDatabase:db];
}
-(BOOL)addSingleRecommendGallery:(RecommendGallery*)recommendGalleryItem
{
    return [self addSingleRecommendGallery:recommendGalleryItem updateIfExist:YES];
}
-(BOOL)addSingleRecommendGallery:(RecommendGallery*)recommendGalleryItem updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleRecommendGallery:recommendGalleryItem updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)addSingleRecommendGallery:(RecommendGallery*)recommendGalleryItem updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db
{
    if (recommendGalleryItem == nil) {
        SNDebugLog(@"addSingleRecommendGallery : Invalid params");
        return NO;
    }

    if (bUpdateIfExist) {
        [db executeUpdate:@"REPLACE INTO tbRecommendGallery (ID,rTermId,rNewsId,termId,newsId,title,time,type,iconUrl,iconPath,createAt) \
         VALUES (NULL,?,?,?,?,?,?,?,?,?,?)"
         ,recommendGalleryItem.releatedTermId,recommendGalleryItem.releatedNewsId,recommendGalleryItem.termId,recommendGalleryItem.newsId
         ,recommendGalleryItem.title,recommendGalleryItem.time,recommendGalleryItem.type,recommendGalleryItem.iconUrl
         ,recommendGalleryItem.iconPath, [NSDate nowTimeIntervalNumber]];
        
        if ([db hadError]) {
            SNDebugLog(@"addSingleRecommendGallery : executeUpdate error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return NO;
        }
    } else {
        NSInteger count = [db intForQuery:@"SELECT COUNT(*) FROM tbRecommendGallery WHERE rTermId=? AND rNewsId=? AND termId=? AND newsId=?"
                           ,recommendGalleryItem.releatedTermId,recommendGalleryItem.releatedNewsId
                           ,recommendGalleryItem.termId,recommendGalleryItem.newsId];
        if ([db hadError]) {
            SNDebugLog(@"addSingleRecommendGallery : executeQuery for exist one error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return NO;
        }
        if (count ==0) {
            [db executeUpdate:@"INSERT INTO tbRecommendGallery (ID,rTermId,rNewsId,termId,newsId,title,time,type,iconUrl,iconPath,createAt) \
             VALUES (NULL,?,?,?,?,?,?,?,?,?,?)"
             ,recommendGalleryItem.releatedTermId,recommendGalleryItem.releatedNewsId,recommendGalleryItem.termId,recommendGalleryItem.newsId
             ,recommendGalleryItem.title,recommendGalleryItem.time,recommendGalleryItem.type,recommendGalleryItem.iconUrl
             ,recommendGalleryItem.iconPath, [NSDate nowTimeIntervalNumber]];
            
            if ([db hadError]) {
                SNDebugLog(@"addSingleRecommendGallery : executeUpdate error :%d,%@"
                           ,[db lastErrorCode],[db lastErrorMessage]);
                return NO;
            }
        }
    }
    return YES;
}

-(BOOL)addMultiRecommendGallery:(NSArray*)recommendGallery
{
    if ([recommendGallery count] == 0) {
        SNDebugLog(@"addMultiRecommendGallery : Invalid param");
        return NO;
    }
    
    __block BOOL bSucceed	= YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (RecommendGallery *item in recommendGallery) {
            bSucceed =[self addSingleRecommendGallery:item updateIfExist:YES inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                SNDebugLog(@"addMultiRecommendGallery : addSingleRecommendGallery failed");
                return;
            }
        }
    }];
    
    return bSucceed;
}


-(BOOL)deleteRecommendGalleryByrTermId:(NSString *)rTermId rNewsId:(NSString *)rNewsId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self deleteRecommendGalleryByrTermId:rTermId rNewsId:rNewsId inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}


-(BOOL)deleteRecommendGalleryByrTermId:(NSString *)rTermId rNewsId:(NSString *)rNewsId inDatabase:(FMDatabase *)db
{
    if ([rTermId length] == 0 || [rNewsId length] == 0) {
        SNDebugLog(@"deleteRecommendGalleryByrTermId : Invalid param,rTermId = %@,rNewsId = %@", rTermId,rNewsId);
        return NO;
    }
    
    NSArray *recommendGallery	= [self getRecommendGalleryByrTermId:rTermId rNewsId:rNewsId inDatabase:db];
	if ([recommendGallery count] == 0) {
		return NO;
	}
	
	[db executeUpdate:@"DELETE FROM tbRecommendGallery WHERE rTermId=? AND rNewsId=?",rTermId,rNewsId];
	if ([db hadError]) {
		SNDebugLog(@"deleteRecommendGalleryByrTermId : executeUpdate error :%d,%@,rTermId=%@,rNewsId=%@"
				   ,[db lastErrorCode],[db lastErrorMessage],rTermId,rNewsId);
		return NO;
	}
    
    //删除图片文件
	NSError *error		= nil;
	NSFileManager *fm	= [NSFileManager defaultManager];
	for (RecommendGallery *recommendGalleryItem in recommendGallery){
		if ([recommendGalleryItem.iconPath length] == 0) {
			continue;
		}
		
		BOOL bSucceed	= [fm removeItemAtPath:recommendGalleryItem.iconPath error:&error];
		if (!bSucceed) {
			SNDebugLog(@"deleteRecommendGalleryByrTermId: remove recommendGalleryItem iconPath failed:%d,%@,path=%@"
					   ,[error code],[error localizedDescription],recommendGalleryItem.iconPath);
		}
	}
	
	return YES;
}

-(BOOL)clearRecommendGallery
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self clearRecommendGalleryInDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
-(BOOL)clearRecommendGalleryInDatabase:(FMDatabase *)db
{
    NSArray *recommendGallery	= [self getRecommendGalleryInDatabase:db];
	if ([recommendGallery count] == 0) {
		return YES;
	}
	
	[db executeUpdate:@"DELETE FROM tbRecommendGallery"];
	if ([db hadError]) {
		SNDebugLog(@"clearRecommendGallery : executeUpdate error :%d,%@"
				   ,[db lastErrorCode],[db lastErrorMessage]);
		return NO;
	}
    
    return YES;
}

-(BOOL)downloadRecommendGallery:(RecommendGallery *)recommendGallery delegate:(id)delegate
{
    recommendGallery.iconUrl = [recommendGallery.iconUrl trim];
    
    if (recommendGallery == nil || [recommendGallery.iconUrl length] == 0) {
        return NO;
    }
    
    if ([self isUrlBeingRequested:recommendGallery.iconUrl]) {
        return YES;
    }
    
    RecommendGalleryRequestItem *requestItem = (RecommendGalleryRequestItem *)([RecommendGalleryRequestItem 
                                                                                 requestWithURL:recommendGallery.iconUrl 
                                                                                 delegate:self isParamP:NO]);
    
    requestItem.url                     = recommendGallery.iconUrl;
    requestItem.recommendGalleryInfo    = recommendGallery;
    requestItem.cacheExpirationAge	= TT_DEFAULT_CACHE_EXPIRATION_AGE;
    requestItem.cachePolicy			= TTURLRequestCachePolicyDisk;
    requestItem.response            = [[SNURLDataResponse alloc] init];
    requestItem.urlRequestDelegate	= delegate;// fix later.multi delegate??why??
    [_UrlRequestAry addObject:requestItem];
    BOOL bSend  = [requestItem send];
    
    return bSend;
}

@end
