//
//  SNDatabase_Photo.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase_Photo.h"
#import "SNURLDataResponse.h"
#import <sqlite3.h>

@implementation SNDatabase(Photo)

-(NSArray*)getPhotoList
{
	return [self getPhotoListWithTimeOrderOption:ORDER_OPT_DEFAULT];
}

-(NSArray*)getPhotoListWithTimeOrderOption:(ORDER_OPTION)orderOpt
{
    __block NSArray *photoList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= nil;
        switch (orderOpt) {
            case ORDER_OPT_ASC:
                rs = [db executeQuery:@"SELECT * FROM tbPhoto ORDER BY time ASC"];
                break;
            case ORDER_OPT_DESC:
                rs = [db executeQuery:@"SELECT * FROM tbPhoto ORDER BY time DESC"];
                break;
            case ORDER_OPT_DEFAULT:
            default:
                rs = [db executeQuery:@"SELECT * FROM tbPhoto"];
                break;
        }
        
        if ([db hadError]) {
            SNDebugLog(@"getPhotoListWithTimeOrderOption : executeQuery error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        photoList = [self getObjects:[PhotoItem class] fromResultSet:rs];
        [rs close];
	    
    }];
	return photoList;
}

-(NSArray*)getPhotoListByTermId:(NSString*)termId newsId:(NSString*)newsId
{
	
	__block NSArray *photoList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        photoList	= [self getPhotoListByTermId:termId newsId:newsId inDatabase:db];
    }];
	return photoList;
}

-(NSArray*)getPhotoListByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db
{
	if ([termId length] == 0) {
		SNDebugLog(@"getPhotoListByTermId : Invalid termId");
		return nil;
	}
	if ([newsId length] == 0) {
		SNDebugLog(@"getPhotoListByTermId : Invalid newsId");
		return nil;
	}
    FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbPhoto WHERE termId=? AND newsId=? ORDER BY ID",termId,newsId];
    if ([db hadError]) {
        SNDebugLog(@"getPhotoListByTermId : executeQuery error :%d,%@,termId=%@,newsId=%@"
                   ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
        return nil;
    }
    
    NSArray *photoList	= [self getObjects:[PhotoItem class] fromResultSet:rs];
    [rs close];
	return photoList;
}

-(PhotoItem*)getPhotoByUrl:(NSString*)url
{
    if ([url length] == 0) {
        return nil;
    }
    __block PhotoItem *photoItem = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbPhoto WHERE url=?",url];
        if ([db hadError]) {
            SNDebugLog(@"getPhotoByUrl : executeQuery error :%d,%@,url=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],url);
            return;
        }
        
        photoItem	= [self getFirstObject:[PhotoItem class] fromResultSet:rs];
        [rs close];
        
    }];
    return photoItem;
}

-(BOOL)addSinglePhoto:(PhotoItem*)photo inDatabase:(FMDatabase *)db
{
	return [self addSinglePhoto:photo updateIfExist:YES inDatabase:db];
}
-(BOOL)addSinglePhoto:(PhotoItem*)photo
{
	return [self addSinglePhoto:photo updateIfExist:YES];
}
-(BOOL)addSinglePhoto:(PhotoItem*)photo updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSinglePhoto:photo updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)addSinglePhoto:(PhotoItem*)photo updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db
{
	if (photo == nil) {
		SNDebugLog(@"addSinglePhoto : Invalid photo");
		return NO;
	}

    BOOL result = [db executeUpdate:@"INSERT OR IGNORE INTO tbPhoto (termId,newsId,abstract,ptitle,shareLink,url,path,time,createAt,width,height) VALUES (?,?,?,?,?,?,?,?,?,?,?)",photo.termId,photo.newsId,photo.abstract,photo.ptitle,photo.shareLink,photo.url,photo.path,photo.time,[NSDate nowTimeIntervalNumber],@(photo.width),@(photo.height)];
    if (!result) {
        if ([db hadError]) {
            SNDebugLog(@"addSinglePhoto : executeUpdate error :%d,%@,photo:%@"
                       ,[db lastErrorCode],[db lastErrorMessage],photo);
            if ([db lastErrorCode]!=SQLITE_CONSTRAINT) {
                return NO;
            }
        }
        if(bUpdateIfExist){
            [db executeUpdate:@"UPDATE tbPhoto SET abstract=?,ptitle=?,shareLink=?,path=?,time=?,createAt=? WHERE termId=? AND newsId=? AND url=? AND width=? AND height=?"
             ,photo.abstract,photo.ptitle,photo.shareLink,photo.path,photo.time,[NSDate nowTimeIntervalNumber],photo.termId,photo.newsId,photo.url,@(photo.width),@(photo.height)];
            if ([db hadError]) {
                SNDebugLog(@"addSinglePhoto : executeUpdate error :%d,%@,photo:%@"
                           ,[db lastErrorCode],[db lastErrorMessage],photo);
                return NO;
            }
        }
    }

    return YES;
}


-(BOOL)deletePhotoByTermId:(NSString*)termId newsId:(NSString*)newsId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self deletePhotoByTermId:termId newsId:newsId inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
-(BOOL)deletePhotoByTermId:(NSString*)termId newsId:(NSString*)newsId inDatabase:(FMDatabase *)db
{
	if ([termId length] == 0) {
		SNDebugLog(@"deletePhotoByTermId : Invalid termId");
		return NO;
	}
	if ([newsId length] == 0) {
		SNDebugLog(@"deletePhotoByTermId : Invalid newsId");
		return NO;
	}
	
	NSArray *photoList	= [self getPhotoListByTermId:termId newsId:newsId];
	if ([photoList count] == 0) {
		return NO;
	}
	
	[db executeUpdate:@"DELETE FROM tbPhoto WHERE termId=? AND newsId=?",termId,newsId];
	if ([db hadError]) {
		SNDebugLog(@"deletePhotoByTermId : executeUpdate error :%d,%@,termId=%@,newsId=%@"
				   ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
		return NO;
	}
	
	//删除图片文件
//	NSError *error		= nil;
//	NSFileManager *fm	= [NSFileManager defaultManager];
//	for (PhotoItem *photo in photoList){
//		if ([photo.path length] == 0) {
//			continue;
//		}
//		
//		BOOL bSucceed	= [fm removeItemAtPath:photo.path error:&error];
//		if (!bSucceed) {
//			SNDebugLog(@"deletePhotoByTermId: remove newsImage failed:%d,%@,path=%@"
//					   ,[error code],[error localizedDescription],photo.path);
//		}
//	}
	
	return YES;
}

-(BOOL)clearPhotoListInDatabase:(FMDatabase *)db
{
    NSArray *photoList	= [self getPhotoList];
	if ([photoList count] == 0) {
		return YES;
	}
	
	[db executeUpdate:@"DELETE FROM tbPhoto"];
	if ([db hadError]) {
		SNDebugLog(@"clearPhotoList : executeUpdate error :%d,%@"
				   ,[db lastErrorCode],[db lastErrorMessage]);
		return NO;
	}
	
	return YES;
}


-(BOOL)clearPhotoList
{
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self clearPhotoListInDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

- (void)addDelegate:(id)deleg forURL:(NSString *)url
{
    if (!url || !deleg) {
        return;
    }
    
    NSMutableArray *delegates = [_imgDownloadDelegates objectForKey:url];
    if (delegates) {
        [delegates addObject:deleg];
    } else {
        delegates = [[NSMutableArray alloc] init];
        [delegates addObject:deleg];
        [_imgDownloadDelegates setObject:delegates forKey:url];
        //delegates);
    }
}

-(BOOL)downloadPhoto:(PhotoItem*)photo delegate:(id)delegate
{
    SNDebugLog(@"downloadPhoto :%@", photo.url);
    
    if (photo == nil || [photo.url length] == 0) {
        return NO;
    }
    
    [self addDelegate:delegate forURL:photo.url];
    
    if ([self isUrlBeingRequested:photo.url]) {
        SNDebugLog(@"downloadPhoto isUrlBeingRequested, cancel :%@", photo.url);
        
        SEL selector = @selector(requestDidStartLoad:);
    
        if ([delegate respondsToSelector:selector]) 
        {
            [delegate requestDidStartLoad:nil];
        }
        
        return YES;
    }
    
    PhotoRequestItem *requestItem	= (PhotoRequestItem *)([PhotoRequestItem requestWithURL:photo.url delegate:self isParamP:NO]);
    requestItem.isFastScroll        = YES;
    requestItem.url                 = photo.url;
    requestItem.photoInfo           = photo;
    requestItem.cacheExpirationAge	= TT_DEFAULT_CACHE_EXPIRATION_AGE;
    requestItem.cachePolicy			= TTURLRequestCachePolicyDefault;
    requestItem.response            = [[SNURLDataResponse alloc] init];
    
    requestItem.urlRequestDelegate	= delegate;
    
    [_UrlRequestAry addObject:requestItem];
    BOOL bSend  = [requestItem send];
    
    return bSend;
}

- (void)cleanupAllPhotoDownload {
    NSArray *arr = [NSArray arrayWithArray:_UrlRequestAry];
    for (PhotoRequestItem *requestItem in arr) {
        if ([requestItem isKindOfClass:[PhotoRequestItem class]]) {
            requestItem.urlRequestDelegate = nil;
            [requestItem cancel];
        }
    }
    SNDebugLog(@"%@", @"cleanupAllPhotoDownload");
}

- (void)cancelPhotoDownloadByUrl:(NSString *)url {
    [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
    
    NSArray *arr = [NSArray arrayWithArray:_UrlRequestAry];
    for (PhotoRequestItem *requestItem in arr) {
        if ([requestItem.urlPath isEqualToString:url]) {
            requestItem.urlRequestDelegate = nil;
            [requestItem cancel];
            SNDebugLog(@"cancel photo url: %@", url);
        }
    }
}

@end
