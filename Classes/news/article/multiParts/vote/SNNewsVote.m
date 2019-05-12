//
//  SNNewsVote.m
//  sohunews
//
//  Created by Chen Hong on 12-10-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNNewsVote.h"

@implementation SNNewsVoteItemOption

@synthesize optionId, name, position, picPath, smallPicPath, optionDesc, type, optVoteTotal, optPersent, isMyVote, myMsg;


- (NSString *)description {
    return [NSString stringWithFormat:@"\n optionId:%@\n name:%@\n position:%@\n picPath: %@ smallPicPath:%@ optionDesc:%@\n type:%@\n optVoteTotal:%@\n optPersent:%@\n isMyVote:%@\n myMsg:%@\n", optionId, name, position, picPath, smallPicPath, optionDesc, type, optVoteTotal, optPersent, isMyVote, myMsg];
}

@end

@implementation SNNewsVoteItem

@synthesize voteId, content, voteType, postion, minVoteNum, maxVoteNum, optionArray;


- (BOOL)hasMyVote {
    for (SNNewsVoteItemOption *op in optionArray) {
        if ([op.isMyVote boolValue]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description {
    NSString *vote = [NSString stringWithFormat:@"\n voteId:%@\n content:%@\n voteType:%@\n position:%@\n minVoteNum:%@\n maxVoteNum:%@\n", voteId, content, voteType, postion, minVoteNum, maxVoteNum];
    
    
    NSMutableString *options = [NSMutableString stringWithCapacity:256];
    for (SNNewsVoteItemOption *op in optionArray) {
        [options appendFormat:@"\n option: %@\n", [op description]];
    }
    
    return [NSString stringWithFormat:@"\n vote:%@\n options:%@\n", vote, options];
}



@end

@implementation SNNewsVotesInfo
@synthesize topicId, startTime, endTime, viewResultCond, isRandomOrdered, isOver, isVoted, isShowDetail, voteTotal, voteArray;


- (BOOL)hasMyVote {
    for (SNNewsVoteItem *item in voteArray) {
        if ([item hasMyVote]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description {
    NSString *info = [NSString stringWithFormat:@"\n topicId: %@\n startTime: %@\n endTime:%@\n viewResultCond:%@\n isRandomOrdered:%@\n isOver:%@\n isVoted:%@\n isShowDetail:%@\n voteTotal:%@", topicId, startTime, endTime, viewResultCond, isRandomOrdered, isOver, isVoted, isShowDetail, voteTotal];
    
    NSMutableString *votes = [NSMutableString stringWithCapacity:256];
    for (SNNewsVoteItem *item in voteArray) {
        [votes appendFormat:@"\n vote: %@\n", [item description]];
    }
    
    return [NSString stringWithFormat:@"\n votesInfo: %@\n votes:%@\n", info, votes];
}

@end
