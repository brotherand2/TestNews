//
//  SNDatabase_Gallery.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_Gallery.h"
#import "SNDatabase_RecommendGallery.h"
#import "SNDatabase_Photo.h"


@implementation SNDatabase(Gallery)

-(NSArray*)getGalleryFromResultSet:(FMResultSet*)rs inDatabase:(FMDatabase *)db
{
	if (rs == nil) {
		SNDebugLog(@"getGalleryFromResultSet : Invalid rs");
		return nil;
	}
	
	NSMutableArray *galleryList	= [[NSMutableArray alloc] init];
	while ([rs next]) {
		GalleryItem *gallery	= [[GalleryItem alloc] init];
        for (int i = 0 ; i< [rs columnCount]; i ++) {
            NSString *columnName =  [rs columnNameForIndex:i];
            id value = [rs objectForColumnIndex:i];
            if (value != (id)[NSNull null]) {
                [gallery setValue:value forKey:columnName];
            }
        }
		gallery.gallerySubItems	= [self getPhotoListByTermId:gallery.termId newsId:gallery.newsId inDatabase:db];
        //
        gallery.moreRecommends  = [self getRecommendGalleryByrTermId:gallery.termId rNewsId:gallery.newsId inDatabase:db];
		
		[galleryList addObject:gallery];
	}
	
	return galleryList;
}

-(NSDictionary*)getGalleryUpdateValuePairs:(GalleryItem*)gallery
{
	if (gallery == nil) {
		SNDebugLog(@"getGalleryUpdateValuePairs : Invalid gallery");
		return nil;
	}
	
	NSMutableDictionary *valuePairs	= [[NSMutableDictionary alloc] init];
	
	if(gallery.title != nil){
		[valuePairs setObject:gallery.title forKey:TB_GALLERY_TITLE];
	}
    if (gallery.newsMark != nil) {
        [valuePairs setObject:gallery.newsMark forKey:TB_GALLERY_NEWSMARK];
    }
    if (gallery.originFrom != nil) {
        [valuePairs setObject:gallery.originFrom forKey:TB_GALLERY_ORIGINFROM];
    }
	if(gallery.time != nil){
		[valuePairs setObject:gallery.time forKey:TB_GALLERY_TIME];
	}
    if(gallery.updateTime != nil){
		[valuePairs setObject:gallery.updateTime forKey:TB_GALLERY_UPDATETIME];
	}
	if(gallery.type != nil){
		[valuePairs setObject:gallery.type forKey:TB_GALLERY_TYPE];
	}
	if(gallery.commentNum != nil){
		[valuePairs setObject:gallery.commentNum forKey:TB_GALLERY_COMMENTNUM];
	}
	if(gallery.digNum != nil){
		[valuePairs setObject:gallery.digNum forKey:TB_GALLERY_DIGNUM];
	}
	if(gallery.shareContent != nil){
		[valuePairs setObject:gallery.digNum forKey:TB_GALLERY_SHARECONTENT];
	}
    
    if(gallery.nextId != nil){
		[valuePairs setObject:gallery.nextId forKey:TB_GALLERY_NEXTID];
	}
	if(gallery.nextName != nil){
		[valuePairs setObject:gallery.nextName forKey:TB_GALLERY_NEXTNAME];
	}
	if(gallery.preId != nil){
		[valuePairs setObject:gallery.preId forKey:TB_GALLERY_PREID];
	}
	if(gallery.preName != nil){
		[valuePairs setObject:gallery.preName forKey:TB_GALLERY_PRENAME];
	}
    if(gallery.from != nil){
		[valuePairs setObject:gallery.from forKey:TB_GALLERY_FROM];
	}
    if(gallery.isLike != nil){
		[valuePairs setObject:gallery.isLike forKey:TB_GALLERY_ISLIKE];
	}
    if(gallery.likeCount != nil){
		[valuePairs setObject:gallery.likeCount forKey:TB_GALLERY_LIKECOUNT];
	}
    if (gallery.subId != nil) {
        [valuePairs setObject:gallery.subId forKey:TB_GALLERY_SUBID];
    }
	
	return  valuePairs;
}

-(GalleryItem*)getGalleryByTermId:(NSString*)termId newsId:(NSString*)newsId
{
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"getGalleryByTermId : Invalid termId or newsId");
		return nil;
	}
	__block NSArray *galleryList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbGallery WHERE termId=? AND newsId=?",termId,newsId];
        if ([db hadError]) {
            SNDebugLog(@"getGalleryByTermId : executeQuery error :%d,%@,termId=%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
            return;
        }
        
        galleryList	= [self getGalleryFromResultSet:rs inDatabase:db];
        [rs close];
	    
    }];
	
	switch ([galleryList count]) {
		case 0:
			return nil;
		case 1:
			return [galleryList objectAtIndex:0];
		default:
			SNDebugLog(@"getGalleryByTermId : Find more than one gallerys(%d) with termId=%@ and newsId=%@"
					   ,[galleryList count],termId,newsId);
			return [galleryList objectAtIndex:0];
	}
}

-(BOOL)addSingleGalleryOrUpdate:(GalleryItem*)gallery
{
	return [self addSingleGallery:gallery updateIfExist:YES];
}

-(BOOL)addSingleGalleryIfNotExist:(GalleryItem*)gallery
{
	return [self addSingleGallery:gallery updateIfExist:NO];
}

-(BOOL)addSingleGallery:(GalleryItem*)gallery updateIfExist:(BOOL)bUpdateIfExist inDatabase:(FMDatabase *)db
{
	if (gallery == nil) {
		SNDebugLog(@"addSingleGallery : Invalid gallery");
		return NO;
	}

    if (bUpdateIfExist) {
        [db executeUpdate:@"REPLACE INTO tbGallery (ID,termId,newsId,title,newsMark,originFrom,time,updateTime,type,commentNum,digNum,shareContent,nextId,nextNewsLink,nextNewsLink2,nextName,preId,preName,source,isLike,likeCount,createAt,subId,cmtStatus,cmtHint,cmtRead,mediaName,mediaLink) \
         VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
         ,gallery.termId,gallery.newsId,gallery.title,gallery.newsMark,gallery.originFrom,gallery.time,gallery.updateTime,gallery.type,gallery.commentNum,gallery.digNum,gallery.shareContent
         ,gallery.nextId,gallery.nextNewsLink,gallery.nextNewsLink2,gallery.nextName,gallery.preId,gallery.preName,gallery.from,gallery.isLike,gallery.likeCount, [NSDate nowTimeIntervalNumber],gallery.subId,gallery.cmtStatus,gallery.cmtHint,[NSNumber numberWithBool:gallery.cmtRead],gallery.mediaName, gallery.mediaLink];
        
        if ([db hadError]) {
            SNDebugLog(@"addSingleGallery : executeUpdate error :%d,%@,gallery:%@"
                       ,[db lastErrorCode],[db lastErrorMessage],gallery);
            return NO;
        }
    } else {
        NSInteger count	= [db intForQuery:@"SELECT COUNT(*) FROM tbGallery WHERE termId=? AND newsId=?",gallery.termId,gallery.newsId];
        if ([db hadError]) {
            SNDebugLog(@"addSingleGallery : executeQuery for exist one error :%d,%@,termId=%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],gallery.termId,gallery.newsId);
            return NO;
        }
        if (count==0) {
            [db executeUpdate:@"INSERT INTO tbGallery (ID,termId,newsId,title,newsMark,originFrom,time,updateTime,type,commentNum,digNum,shareContent,nextId,nextNewsLink,nextNewsLink2,nextName,preId,preName,source,isLike,likeCount,createAt,subId,cmtStatus,cmtHint,cmtRead,mediaName,mediaLink) \
             VALUES (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
             ,gallery.termId,gallery.newsId,gallery.title,gallery.newsMark,gallery.originFrom,gallery.time,gallery.updateTime,gallery.type,gallery.commentNum,gallery.digNum,gallery.shareContent
             ,gallery.nextId,gallery.nextNewsLink,gallery.nextNewsLink2,gallery.nextName,gallery.preId,gallery.preName,gallery.from,gallery.isLike,gallery.likeCount, [NSDate nowTimeIntervalNumber],gallery.subId, gallery.cmtStatus, gallery.cmtHint,
             [NSNumber numberWithBool:gallery.cmtRead],gallery.mediaName, gallery.mediaLink];
            
            if ([db hadError]) {
                SNDebugLog(@"addSingleGallery : executeUpdate error :%d,%@,gallery:%@"
                           ,[db lastErrorCode],[db lastErrorMessage],gallery);
                return NO;
            }
        }
    }
    
    // 先清空tbPhoto中的相应图片

    //delete by liangliangcui 2015-10-16
    //[self deletePhotoByTermId:gallery.termId newsId:gallery.newsId inDatabase:db];
    
	//插入组图
	if ([gallery.gallerySubItems count] != 0) {
		BOOL bSucceed	 = YES;
		for (PhotoItem *photoItem in gallery.gallerySubItems ) {
			if (![self addSinglePhoto:photoItem inDatabase:db]) {
				bSucceed = NO;
				break;
			}
		}
		if (!bSucceed) {
			return NO;
		}
	}
    
    // 先清空更多推荐
    [self deleteRecommendGalleryByrTermId:gallery.termId rNewsId:gallery.newsId inDatabase:db];
    
    //插入更多推荐
    if ([gallery.moreRecommends count] != 0) {
        BOOL bSucceed	 = YES;
        for (RecommendGallery *item in gallery.moreRecommends) {
            if (![self addSingleRecommendGallery:item inDatabase:db]) {
                bSucceed = NO;
                SNDebugLog(@"addSingleGallery : addSingleRecommendGallery failed");
                break;
            }
        }
        if (!bSucceed) {
			return NO;
		}
    }
    
	return YES;
}

-(BOOL)addSingleGallery:(GalleryItem*)gallery updateIfExist:(BOOL)bUpdateIfExist
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleGallery:gallery updateIfExist:bUpdateIfExist inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}


-(BOOL)updateGalleryAsLikeByTermId:(NSString*)termId newsId:(NSString*)newsId likeCount:(NSString *)count {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result =  [db executeUpdate:@"update tbGallery set isLike='1', likeCount= ?, createAt=? where termId=? and newsId = ?", [NSDate nowTimeIntervalNumber], count,termId, newsId];
        if ([db hadError]) {
            *rollback = YES;
            return;
        }
    }];
    return result;
}

- (BOOL)updateGalleryCmtReadByTermId:(NSString*)termId newsId:(NSString*)newsId hasRead:(BOOL)hasRead {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result =  [db executeUpdate:@"update tbGallery set cmtRead=? where termId=? and newsId = ?", [NSNumber numberWithBool:hasRead], termId, newsId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"updateGalleryCmtReadByTermId : executeUpdate error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
    }];
    return result;
}

-(BOOL)deleteGalleryByTermId:(NSString*)termId newsId:(NSString*)newsId
{
	if ([termId length] == 0 || [newsId length] == 0) {
		SNDebugLog(@"deleteGalleryByTermId : Invalid termId or newsId");
		return NO;
	}
	
	__block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbGallery WHERE termId=? AND newsId=?",termId,newsId];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"deleteGalleryByTermId : executeUpdate error :%d,%@,termId=%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],termId,newsId);
            return;
        }
        result=[self deletePhotoByTermId:termId newsId:newsId inDatabase:db];
        if (!result) {
            *rollback = YES;
            return;
        }
        
        //删除相关推荐组图
        result=[self deleteRecommendGalleryByrTermId:termId rNewsId:newsId inDatabase:db];
        if (!result) {
            *rollback = YES;
            return;
        }
        

    }];
	return result;
}

-(BOOL)clearGalleryList
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbGallery"];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"clearGalleryList : executeUpdate error :%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        result=[self clearPhotoListInDatabase:db];
        if (!result) {
            *rollback = YES;
            return;
        }
        
        //删除相关推荐组图
        result=[self clearRecommendGalleryInDatabase:db];
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
	return result;
}


@end
