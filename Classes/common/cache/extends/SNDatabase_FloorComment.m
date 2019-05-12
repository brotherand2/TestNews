//
//  SNDatabase_FloorComment.m
//  sohunews
//
//  Created by qi pei on 7/1/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"
#import "SNDatabase_Private.h"

@implementation SNDatabase(FloorComment)

-(BOOL)addMultiFloorComment:(NSArray*)commentList {
    if (commentList == nil) {
		return NO;
	}
	if ([commentList count] == 0) {
		return NO;
	}
	__block BOOL bSucceed	= YES;
	[[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (CommentFloor *comment in commentList) {
            bSucceed = [self addSingleComment:comment inDatabase:db];
            if (!bSucceed) {
                *rollback = YES;
                return ;
            }
        }
    }];
	return bSucceed;
}

-(BOOL)addSingleComment:(CommentFloor *)comment
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self addSingleComment:comment inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

-(BOOL)addSingleComment:(CommentFloor *)comment inDatabase:(FMDatabase *)db{
    if (comment == nil) {
		return NO;
	}

    [db executeUpdate:@"REPLACE INTO tbCommentJson (newsId,commentId,commentJson,ctime, type, topicId, newsType, digNum, hadDing, createAt) VALUES (?,?,?,?,?,?,?,?,?,?)"
     ,comment.newsId,comment.commentId,comment.commentJson,[NSNumber numberWithDouble:comment.ctime],comment.type, comment.topicId, comment.newsType,[NSNumber numberWithInteger:comment.digNum],[NSNumber numberWithDouble:0], [NSDate nowTimeIntervalNumber]];
    if ([db hadError]) {
        SNDebugLog(@"getNewsCommentByNewsId : db executeUpdate error:%d,%@"
                   ,[db lastErrorCode],[db lastErrorMessage]);
        return NO;
    }
    return YES;
}

-(BOOL)updateCommentDigNumByNewsId:(NSString *)newsId andCommentId:(NSString *)commId andNewsType:(NSString *)newsType {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"update tbCommentJson set digNum = digNum + 1, hadDing = 1, createAt=? where newsId = ? and commentId = ? and newsType = ? and hadDing = 0", [NSDate nowTimeIntervalNumber], newsId, commId, newsType];
        if ([db hadError]) {
            SNDebugLog(@"updateDigNumById : db executeUpdate error:%d,%@", [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
    
	return result;
}

-(NSMutableArray *)getHadDingFloorComment:(NSString *)type
                                    andNewsId:(NSString *)newsId
                                  andNewsType:(NSString *)newsType {
    __block NSMutableArray *commentList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs	= [db executeQuery:@"SELECT * FROM tbCommentJson WHERE newsId=? and type=? and newsType = ? and hadDing = 1", newsId, type, newsType];
        if ([db hadError]) {
            SNDebugLog(@"getFirstCachedFloorComment : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        commentList	= (NSMutableArray *)[self getObjects:[CommentFloor class] fromResultSet:rs];
        [rs close];
    }];
	
	return commentList;
}

-(NSMutableArray *)getFirstCachedFloorComment:(NSString *)type
                               andNewsId:(NSString *)newsId     
                             andNewsType:(NSString *)newsType {
    __block NSMutableArray *commentList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = nil;
        if ([type isEqualToString:KCommentTypeLatest]) {
            rs	= [db executeQuery:@"SELECT * FROM tbCommentJson WHERE newsId=? and type=? and newsType = ? ORDER BY ctime DESC limit ?", newsId, type, newsType, [NSNumber numberWithInt:KPaginationNum]];
        } else {
            rs	= [db executeQuery:@"SELECT * FROM tbCommentJson WHERE newsId=? and type=? and newsType = ? ORDER BY digNum DESC, ctime DESC limit ?", newsId, type, newsType, [NSNumber numberWithInt:KPaginationNum]];
        }
        if ([db hadError]) {
            SNDebugLog(@"getFirstCachedFloorComment : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        
        commentList	= (NSMutableArray *)[self getObjects:[CommentFloor class] fromResultSet:rs];
        [rs close];
    }];
	
	return commentList;
}

-(NSMutableArray *)loadNextPageCommentBy:(NSString *)type 
                               andNewsId:(NSString *)newsId
                             andNewsType:(NSString *)newsType
                                andCtime:(double)ctime {
    __block NSMutableArray *commentList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = nil;
        if ([type isEqualToString:KCommentTypeLatest]) {
            rs	= [db executeQuery:@"SELECT * FROM tbCommentJson WHERE newsId=? and type=? and newsType = ? and ctime < ? ORDER BY ctime DESC limit ?", newsId, type, newsType, [NSNumber numberWithDouble:ctime],[NSNumber numberWithInt:KPaginationNum]];
        } else {
            rs	= [db executeQuery:@"SELECT * FROM tbCommentJson WHERE newsId=? and type=? and newsType = ? and ctime < ? ORDER BY digNum DESC, ctime DESC limit ?", newsId, type, newsType, [NSNumber numberWithDouble:ctime],[NSNumber numberWithInt:KPaginationNum]];
        }
        if ([db hadError]) {
            return ;
        }
        
        commentList	= (NSMutableArray *)[self getObjects:[CommentFloor class] fromResultSet:rs];
        [rs close];
    
    }];
    
	return commentList;
}

-(BOOL)clearCommentJson
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbCommentJson"];
        if ([db hadError]) {
            SNDebugLog(@"clearCommentJson : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

@end
