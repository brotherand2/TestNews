//
//  SNDatabase_WeiboHotDetail.m
//  sohunews
//
//  Created by guo yalun on 12-12-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_WeiboHotDetail.h"


@implementation SNDatabase(WeiboHotDetail)


- (BOOL)saveOrUpdateWeiboHotComment:(WeiboHotCommentItem *)commentItem inDatabase:(FMDatabase *)db
{
    
    [db executeUpdate:@"REPLACE INTO tbWeiboHotComment (commentId,nick,isVip,head,type,homeUrl,time,content,cellHeight,weiboId,createAt,gender) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
     commentItem.commentId,commentItem.nick,commentItem.isVip,commentItem.head,commentItem.type,commentItem.homeUrl,commentItem.time,commentItem.content,
     [NSNumber numberWithFloat:commentItem.cellHeight],commentItem.weiboId, [NSDate nowTimeIntervalNumber], [NSNumber numberWithInt:commentItem.gender]];
    if ([db hadError]) {
        return NO;
    }
    return YES;
}

- (BOOL)saveOrUpdateWeiboHotComments:(NSArray *)commentItems
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [commentItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WeiboHotCommentItem *item = (WeiboHotCommentItem *)obj;
            result = [self saveOrUpdateWeiboHotComment:item inDatabase:db];
            if (!result) {
                *rollback = YES;
            }
        }];
    }];
    return result;
}

- (BOOL)saveOrUpdateWeiboHotDetail:(WeiboHotItemDetail *)weiboDetail
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {

        result = [db executeUpdate:@"REPLACE INTO tbWeiboHotDetail(weiboId,nick,isVip,head,homeUrl,title,time,weiboType,commentCount,content,newsId,wapUrl,resourceJSON,shareContent,cellHeight,createAt,source,cmtHint,cmtStatus)VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",weiboDetail.weiboId,weiboDetail.nick,weiboDetail.isVip,weiboDetail.head,weiboDetail.homeUrl,weiboDetail.title,weiboDetail.time,weiboDetail.weiboType,weiboDetail.commentCount,weiboDetail.content,weiboDetail.newsId,weiboDetail.wapUrl,weiboDetail.resourceJSON,weiboDetail.shareContent,[NSNumber numberWithFloat:weiboDetail.cellHeight], [NSDate nowTimeIntervalNumber],weiboDetail.source,weiboDetail.cmtHint,weiboDetail.cmtStatus];
        if ([db hadError]) {
            SNDebugLog(@"saveOrUpdateWeiboHotDetail  error : %@",[db lastError]);
            *rollback = YES;
            return ;
        }
    }];
    
    return result;
}


- (WeiboHotItemDetail *)getWeiboItemDetailById:(NSString *)weiboId
{
    __block WeiboHotItemDetail *itemDetail = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbWeiboHotDetail WHERE weiboId = ?",weiboId];
        if ([db hadError]) {
            SNDebugLog(@"getWeiboItemDetailById  error : %@",[db lastError]);
            return ;
        }
        itemDetail = [self getFirstObject:[WeiboHotItemDetail class] fromResultSet:rs];
        [rs close];
    }];
    return itemDetail;
}


- (NSArray *)getWeiboCommentList:(NSString *)weiboId pageNo:(NSInteger)pageIndex
{
    __block NSArray *commentList = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        commentList = [self getWeiboCommentList:weiboId pageNo:pageIndex inDatabase:db];
    }];
    return commentList;
}

- (NSArray *)getWeiboCommentList:(NSString *)weiboId pageNo:(NSInteger)pageIndex inDatabase:(FMDatabase *)db
{
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbWeiboHotComment WHERE weiboId = ? ORDER BY ID  LIMIT ?,?",weiboId,      [NSNumber numberWithInteger:(pageIndex-1)*kWeiboDetailModelPageSize],[NSNumber numberWithInteger:kWeiboDetailModelPageSize]];
    if ([db hadError]) {
        SNDebugLog(@"getWeiboCommentList  error : %@",[db lastError]);
        return nil;
    }
    NSArray *comments = [self getObjects:[WeiboHotCommentItem class] fromResultSet:rs];
    [rs close];
    return comments;
}

- (BOOL)deleteWeiboCommentByWeiboId:(NSString *)weiboId inDatabase:(FMDatabase *)db
{
    [db executeUpdate:@"DELETE FROM tbWeiboHotComment WHERE weiboId = ?",weiboId];
    if ([db hadError]) {
        SNDebugLog(@"deleteWeiboCommentByWeiboId  error : %@",[db lastError]);
        return NO;
    }
    return YES;
}

- (BOOL)deleteWeiboCommentByWeiboId:(NSString *)weiboId
{
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [self deleteWeiboCommentByWeiboId:weiboId inDatabase:db];
        if (!result) {
            *rollback = YES;
        }
    }];
    return result;
}

- (BOOL)clearWeiboHotDetail {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbWeiboHotDetail"];
        if ([db hadError]) {
            SNDebugLog(@"clearWeiboHotDetail : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

- (BOOL)clearWeiboComment {
    __block BOOL result = YES;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbWeiboHotComment"];
        if ([db hadError]) {
            SNDebugLog(@"clearWeiboComment : db executeUpdate error:%d,%@"
                       ,[db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
    }];
	
	return result;
}

@end
