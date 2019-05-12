//
//  SNDatabase_Votes.h
//  sohunews
//
//  Created by wang yanchen on 12-10-31.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"

@interface SNDatabase(Votes)

- (void)addOrUpdateOneVoteInfo:(VotesInfo *)voteInfo;
- (VotesInfo *)getVotesInfoByNewsID:(NSString *)newsID;

@end
