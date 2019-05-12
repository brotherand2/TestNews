//
//  SNDatabase_Votes.m
//  sohunews
//
//  Created by wang yanchen on 12-10-31.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase_Votes.h"
#import "SNDatabase.h"

@implementation SNDatabase(Votes)

- (void)addOrUpdateOneVoteInfo:(VotesInfo *)voteInfo {
    if (voteInfo &&
        [voteInfo.newsID length] > 0 &&
        voteInfo.topicID &&
        voteInfo.isVoted &&
        voteInfo.voteXML &&
        voteInfo.isOver) {
        
        SNDebugLog(@"addOrUpdateOneVoteInfo voteInfo=%@", voteInfo);
        [[SNDatabase writeQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString *replaceSQL = [NSString stringWithFormat:@"REPLACE INTO %@ (%@,%@,%@,%@,%@,%@) VALUES (?,?,?,?,?,?)",
                                    TB_VOTES_INFO,
                                    TB_VOTES_NEWS_ID,
                                    TB_VOTES_TOPIC_ID,
                                    TB_VOTES_IS_VOTED,
                                    TB_VOTES_XML_STR,
                                    TB_VOTES_IS_OVER,
                                    TB_CREATEAT_COLUMN];
            [db executeUpdate:replaceSQL, voteInfo.newsID, voteInfo.topicID, voteInfo.isVoted, voteInfo.voteXML, voteInfo.isOver, [NSDate nowTimeIntervalNumber]];
            if ([db hadError]) {
                *rollback = YES;
                return;
                SNDebugLog(@"insert new voteinfo item error : %@", [db lastErrorMessage]);
            }
        }];
    }
}

- (VotesInfo *)getVotesInfoByNewsID:(NSString *)newsID inDatabase:(FMDatabase *)db {
    VotesInfo *votesInfo = nil;
    //SNDebugLog(@"getVotesInfoByNewsID : newsID = %@", newsID);
    if ([newsID length] > 0) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM tbVotesInfo WHERE newsID=?", newsID];
        if ([db hadError]) {
            SNDebugLog(@"addOrUpdateOneVoteInfo query exist item error with %@", [db lastErrorMessage]);
            return nil;
        }
        votesInfo = [self getFirstObject:[VotesInfo class] fromResultSet:rs];
        [rs close];
    }
    
    return votesInfo;
}

- (VotesInfo *)getVotesInfoByNewsID:(NSString *)newsID
{
    __block VotesInfo *votesInfo = nil;
    [[SNDatabase readQueue] inDatabase:^(FMDatabase *db) {
        votesInfo  = [self getVotesInfoByNewsID:newsID inDatabase:db];
    }];
    return votesInfo;
}

@end
