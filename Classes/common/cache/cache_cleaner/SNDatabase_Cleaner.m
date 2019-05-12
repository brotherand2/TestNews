//
//  CacheMgr_Cleaner.m
//  sohunews
//
//  Created by handy on 9/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_Cleaner.h"
#import "SNCacheCleanerManager.h"
#import "SNDatabase_photo.h"
#import "SNDatabase_RecommendGallery.h"
#import "SNDatabase+LiveInvite.h"
#import "SNDatabase.h"

@implementation SNDatabase(Cleaner)

#pragma mark - Public methods implementation

- (void)cleanAllExpiredCache {
    NSDate *_expiredDatePoint = [NSDate dateWithTimeIntervalSinceNow:-__kDBDataExpiredInterval__];
    int _expiredTimeIntervalPoint = [_expiredDatePoint timeIntervalSince1970];
    NSNumber *_expiredPoint = [NSNumber numberWithInt:_expiredTimeIntervalPoint];
    
    if (![self cleanExpiredNewsArticleDataBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean expired newarticle data.");
    }
    
    if (![self cleanExpiredGalleryDataBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean expired gallery data.");
    }
    
    if (![self cleanExpiredRollingNewsDataBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean expired rollingnews data.");   
    }
    
    if (![self cleanExpredGroupPhotoDataBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean expired groupphoto data.");
    }
    
    if (![self cleanExpiredCommentJsonBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean expired CommentJson data.");
    }
    
    if (![self cleanExpiredSpecialNewsListBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean specialNewsList data.");
    }
    
    if (![self cleanExpiredLivingGamesBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean livingGames data.");
    }
    
    if (![self cleanExpiredRecommendNewsBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean recommendNews data.");
    }
    
    if (![self cleanExpiredAllWeiboHotItemsBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean allWeiboHotItems data.");
    }
    
    if (![self cleanExpiredWeiboHotDetailBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean weiboHotDetail data.");
    }
    
    if (![self cleanExpiredWeiboCommentBefore:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean weiboComment data.");
    }
    
    if(![self cleanExpiredAllLink2Before:_expiredPoint]) {
        SNDebugLog(@"===INFO: Failed to clean link2 data.");
    }
    if (![self cleanExpiredVideoBreakpointListBefore:_expiredPoint])
    {
        SNDebugLog(@"===INFO: Failed to clean link2 VideoBreakpointList.");
    }
    if (![self clearLiveInviteItems:_expiredPoint])
    {
        SNDebugLog(@"===INFO: Failed to clean link2 VideoBreakpointList.");
    }
}

#pragma mark - Private methods implementation

- (BOOL)cleanExpiredNewsArticleDataBefore:(NSNumber *)expiredPoint {
	__block BOOL result = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理新闻正文数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbNewsArticle......");
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM tbNewsArticle where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"===INFO: Failed to clean expired tbNewsArticle with error : %d, %@", [db lastErrorCode], [db lastErrorMessage]);
            return;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbNewsArticle==="];

        //清理新闻图片数据表过期数据
        //[_stopWatch begin];
        SNDebugLog(@"===INFO: Cleaning expired tbNewsImage......");
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM tbNewsImage where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"===INFO: Failed to clean expired tbNewsImage with error : %d,%@", [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        //[[_stopWatch stop] print:@"===Finish clening expired tbNewsImage==="];
        
        //清理投票信息数据表过期数据
        //[_stopWatch begin];
        SNDebugLog(@"===INFO: Cleaning expired tbVotesInfo......");
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM tbVotesInfo where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"===INFO: Failed to clean expired voteinfo with error : %d, %@",[db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        //[[_stopWatch stop] print:@"===Finish clening expired tbVotesInfo==="];
    }];
    
    return result;
}

- (BOOL)cleanExpiredGalleryDataBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理即时新闻组图列表和组图幻灯片数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbGallery......");
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM tbGallery where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"===INFO: Failed to clean expired tbGallery with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbGallery==="];
        
        //清理图片信息数据表过期数据
        //[_stopWatch begin];
        SNDebugLog(@"===INFO: Cleaning expired tbPhoto......");
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM tbPhoto where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbPhoto with error : %d, %@", [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbPhoto==="];
        

        //清理相关推荐组图数据表过期数据
        //[_stopWatch begin];
        SNDebugLog(@"===INFO: Cleaning expired tbRecommendGallery......");
        result =  [db executeUpdate:[NSString stringWithFormat: @"DELETE FROM tbRecommendGallery where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbRecommendGallery with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbRecommendGallery==="];
    }];
    
    return result;
}

- (BOOL)cleanExpiredRollingNewsDataBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;
    
    //要闻改版, 过期新闻无需清除
    /*[[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理即时新闻列表数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbRollingNewsList......");
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM tbRollingNewsList where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            *rollback = YES;
            SNDebugLog(@"===INFO: Failed to clean expired tbRollingNewsList with error :%d, %@", [db lastErrorCode],[db lastErrorMessage]);
            return;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbRollingNewsList==="];
    }];*/
    
	return result;
}

- (BOOL)cleanExpredGroupPhotoDataBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理组图列表数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbGroupPhoto......");
        result = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tbGroupPhoto where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbGroupPhoto with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbGroupPhoto==="];
        
        //清理组图列表数据关联的图片信息表过期数据
        //[_stopWatch begin];
        SNDebugLog(@"===INFO: Cleaning expired tbGroupPhotoUrl......");
        result = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM tbGroupPhotoUrl where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbGroupPhotoUrl with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbGroupPhotoUrl==="];
    }];
    
	return result;
}

- (BOOL)cleanExpiredCommentJsonBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理所有评论数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbCommentJson......");
        result = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tbCommentJson where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbCommentJson with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbCommentJson==="];
    }];
    
	return result;
}

- (BOOL)cleanExpiredSpecialNewsListBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理即时新闻列表数据表过期数据
       // SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbSpecialNewsList......");
        result = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tbSpecialNewsList where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbSpecialNewsList with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbSpecialNewsList==="];
    }];
    
	return result;
}

- (BOOL)cleanExpiredLivingGamesBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;
    
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理直播一级数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbLivingGame......");
        result = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tbLivingGame where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbLivingGame with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbLivingGame==="];
    }];
    
	return result;
}

- (BOOL)cleanExpiredRecommendNewsBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;

    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理相关新闻数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbRecommendNews......");
        result = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tbRecommendNews where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbRecommendNews with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbRecommendNews==="];
    }];
    
	return result;
}

- (BOOL)cleanExpiredAllWeiboHotItemsBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;

    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理微闻一级列表数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbWeiboHotItem......");
        result = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tbWeiboHotItem where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbWeiboHotItem with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbWeiboHotItem==="];
    }];
    
	return result;
}

- (BOOL)cleanExpiredWeiboHotDetailBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;

    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理微闻二级详情内容数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbWeiboHotDetail......");
        result = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tbWeiboHotDetail where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbWeiboHotDetail with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbWeiboHotDetail==="];
    }];
    
	return result;
}

- (BOOL)cleanExpiredWeiboCommentBefore:(NSNumber *)expiredPoint {
    __block BOOL result = YES;

    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //清理微闻二级评论列表数据表过期数据
        //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
        SNDebugLog(@"===INFO: Cleaning expired tbWeiboHotComment......");
        result = [db executeUpdate: [NSString stringWithFormat:@"DELETE FROM tbWeiboHotComment where %@ <= ?", TB_CREATEAT_COLUMN], expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"===INFO: Failed to clean expired tbWeiboHotComment with error : %d, %@", [db lastErrorCode],[db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
        //[[_stopWatch stop] print:@"===Finish cleaning expired tbWeiboHotComment==="];
    }];
    
	return result;
}

- (BOOL)cleanExpiredAllLink2Before:(NSNumber *)expiredPoint
{
    __block BOOL result = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbNewspaperReadFlag WHERE createAt<?",expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"%@--removeTimeOutLink2 failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
    }];
    return result;
}

- (BOOL)cleanExpiredVideoBreakpointListBefore:(NSNumber *)expiredPoint
{
    __block BOOL result = NO;
    [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:@"DELETE FROM tbVideoBreakpoint WHERE createAt<?",expiredPoint];
        if ([db hadError]) {
            SNDebugLog(@"%@--removeVideoBreakpointList failed with error :%d - %@", NSStringFromSelector(_cmd), [db lastErrorCode], [db lastErrorMessage]);
            *rollback = YES;
            return ;
        }
    }];
    return result;
}

@end
