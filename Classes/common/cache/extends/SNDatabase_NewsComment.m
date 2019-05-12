//
//  SNDatabase_NewsComment.m
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase_NewsComment.h"


@implementation SNDatabase(NewsComment)

-(NSArray*)getNewsCommentByNewsId:(NSString*)newsId
{
	if ([newsId length] == 0) {
		SNDebugLog(@"getNewsCommentByNewsId : Invalid newsId");
		return nil;
	}
	__block NSArray *newsCommentList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsComment WHERE newsId=? order by ID desc, ctime desc",newsId];
        if ([db hadError]) {
            SNDebugLog(@"getNewsCommentByNewsId : db executeQuery error:%d,%@,newsId=%@"
                       ,[db lastErrorCode],[db lastErrorMessage],newsId);
            return ;
        }
        newsCommentList	= [self getObjects:[NewsCommentItem class] fromResultSet:rs];
        [rs close];
    }];
	
	return newsCommentList;
}
-(BOOL)addSingleNewsComment:(NewsCommentItem*)newsComment
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleNewsComment:newsComment inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return  result;
}


-(BOOL)addSingleNewsComment:(NewsCommentItem*)newsComment inDatabase:(FMDatabase *)db
{
	if (newsComment == nil) {
		return NO;
	}

	[db executeUpdate:@"INSERT INTO tbNewsComment (newsId,commentId,type,ctime,author,content,hadDing,digNum,imagePath,authorImage,audioPath,audioDuration,userComtId) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"
	 ,newsComment.newsId,newsComment.commentId,newsComment.type,newsComment.ctime,newsComment.author,
     newsComment.content,[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], newsComment.imagePath,
     newsComment.authorImage, newsComment.audioPath, newsComment.audioDuration, newsComment.userComtId];
    
	if ([db hadError]) {
		SNDebugLog(@"getNewsCommentByNewsId : db executeUpdate error:%d,%@"
				   ,[db lastErrorCode],[db lastErrorMessage]);
		return NO;
	}
	return YES;
}
-(BOOL)updateMyCommentDigNumById:(NSInteger)cid
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self updateMyCommentDigNumById:cid inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}
-(BOOL)updateMyCommentDigNumById:(NSInteger)cid inDatabase:(FMDatabase *)db {
    [db executeUpdate:@"update tbNewsComment set digNum = digNum + 1, hadDing = 1 where ID = ?", [NSNumber numberWithInteger:cid]];
	if ([db hadError]) {
		SNDebugLog(@"updateDigNumById : db executeUpdate error:%d,%@"
				   ,[db lastErrorCode],[db lastErrorMessage]);
		return NO;
	}
	return YES;
}
-(BOOL)updateMyCommentUserComtId:(NSString *)userComtId By:(NSString *)ctime
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"update tbNewsComment set userComtId = ? where ctime = ?", userComtId, ctime];
        if ([db hadError]) {
            SNDebugLog(@"updateMyCommentUserComtId : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
        }
    }];
    return result;
}
-(BOOL)clearNewsComment
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbNewsComment"];
        if ([db hadError]) {
            SNDebugLog(@"clearNewsComment : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

-(BOOL)deleteNewsCommentByctime:(NSString*)ctime
{
	if ([ctime length] == 0) {
		SNDebugLog(@"deleteNewsCommentByctime : Invalid ctime");
		return NO;
	}
	
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbNewsComment WHERE ctime=?", ctime];
        if ([db hadError]) {
            SNDebugLog(@"deleteNewsCommentByUserCmtId : db executeUpdate error:%d,%@,ctime=%@"
                       ,[db lastErrorCode],[db lastErrorMessage], ctime);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

/*

-(BOOL)addOrUpdateSingleNewsComment:(NewsCommentItem*)newsComment {
    if (newsComment == nil) {
		return NO;
	}

    NSArray *newsCommentList = nil;
    
    // 查询是否已存在
    if ([newsComment.commentId length] > 0) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbNewsComment WHERE newsId=? and commentId=? order by ID desc", newsComment.newsId, newsComment.commentId];
        if (![db hadError]) {
            newsCommentList	= [self getNewsCommentFromResultSet:rs];
            [rs close];
        }
    }
    
    // 添加
    if ([newsCommentList count] == 0) {
        [db executeUpdate:@"INSERT INTO tbNewsComment (newsId,commentId,type,ctime,author,content) VALUES (?,?,?,?,?,?)"
         ,newsComment.newsId,newsComment.commentId,newsComment.type,newsComment.ctime,newsComment.author,newsComment.content];
        if ([db hadError]) {
            SNDebugLog(@"getNewsCommentByNewsId : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return NO;
        }
        return YES;
    }
    
    // 更新
    NSDictionary *valuePairs	= [NSDictionary dictionaryWithObjectsAndKeys:
                                   newsComment.type,@"type"
                                   ,newsComment.ctime,@"ctime"
                                   ,newsComment.author,@"author"
                                   ,newsComment.content,@"content"
                                   ,nil];
    
    [self updateNewsCommentByNewsId:newsComment.newsId commentId:newsComment.commentId withValuePairs:valuePairs];
    
    return YES;
}

-(BOOL)addMultiNewsComment:(NSArray*)newsCommentList
{
	if (newsCommentList == nil) {
		SNDebugLog(@"addMultiNewsComment : Invalid newsCommentList");
		return NO;
	}
	
	if ([newsCommentList count] == 0) {
		SNDebugLog(@"addMultiNewsComment : Empty newsCommentList");
		return NO;
	}
	
	BOOL bSucceed	= YES;
	[db beginTransaction];
	for (NewsCommentItem *item in newsCommentList) {
		if (![self addSingleNewsComment:item]) {
			bSucceed = NO;
			SNDebugLog(@"addMultiNewsComment : Failed");
			break;
		}
	}
	
	if (bSucceed) {
		[db commit];
	}
	else {
		[db rollback];
	}
	
	return bSucceed;
}

-(BOOL)deleteNewsCommentByNewsId:(NSString*)newsId
{
	if ([newsId length] == 0) {
		SNDebugLog(@"deleteNewsCommentByNewsId : Invalid newsId");
		return NO;
	}
	
	[db executeUpdate:@"DELETE FROM tbNewsComment WHERE newsId=?",newsId];
	if ([db hadError]) {
		SNDebugLog(@"deleteNewsCommentByNewsId : db executeUpdate error:%d,%@,newsId=%@"
				   ,[db lastErrorCode],[db lastErrorMessage],newsId);
		return NO;
	}
	
	return YES;
}

-(BOOL)updateNewsCommentByNewsId:(NSString*)newsId commentId:(NSString *)commentId withValuePairs:(NSDictionary*)valuePairs
{
	if ([newsId length] == 0 || [commentId length] == 0) {
		SNDebugLog(@"updateNewsCommentByNewsId : Invalid newsId=%@ or commentId=%@",newsId, commentId);
		return NO;
	}
	
	if ([valuePairs count] == 0) {
		SNDebugLog(@"updateNewsCommentByNewsId : Invalid valuePairs");
		return NO;
	}
	
	//执行更新
	NSDictionary *updateStatementsInfo	= [self formatUpdateSetStatementsInfoFromValuePairs:valuePairs ignoreNilValue:NO];
	if ([updateStatementsInfo count] == 0) {
		SNDebugLog(@"updateRollingNewsListItemByChannelId : formatUpdateSetStatementsInfoFromValuePairs failed");
		return NO;
	}
	
	NSString *statement				= [updateStatementsInfo objectForKey:UPDATE_SETSTATEMNT];
	NSMutableArray *updateArguments	= [updateStatementsInfo objectForKey:UPDATE_SETARGUMENTS];
	
	NSString *updateStatement		= [NSString stringWithFormat:@"UPDATE %@ %@ WHERE %@=? AND %@=?"
									   ,@"tbNewsComment",statement,@"newsId",@"commentId"];
	
	[updateArguments addObject:newsId];
	[updateArguments addObject:commentId];
	
	[db executeUpdate:updateStatement withArgumentsInArray:updateArguments];
	if ([db hadError]) {
		SNDebugLog(@"updateNewsCommentByNewsId : executeUpdate error:%d,%@,newsId=%@,commentId=%@"
				   ,[db lastErrorCode], [db lastErrorMessage],newsId,commentId);
		return NO;
	}
	
	return YES;
}
*/

@end
