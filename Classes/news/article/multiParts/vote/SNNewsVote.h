//
//  SNNewsVote.h
//  sohunews
//
//  Created by Chen Hong on 12-10-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// 投票选项
@interface SNNewsVoteItemOption : NSObject {
    NSString *optionId;
    NSString *name;
    NSString *position;
    NSString *picPath;
    NSString *smallPicPath;
    NSString *optionDesc;
    NSString *type;
    
    // 结果
    NSString *optVoteTotal; // 该选项的总投票数
    NSString *optPersent;   // 该选项占比
    NSString *isMyVote;     // 是否该用户选择的
    NSString *myMsg;        // 用户自定义输入信息
}

@property(nonatomic,copy) NSString *optionId;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *position;
@property(nonatomic,copy) NSString *picPath;
@property(nonatomic,copy) NSString *smallPicPath;
@property(nonatomic,copy) NSString *optionDesc;
@property(nonatomic,copy) NSString *type;

@property(nonatomic,copy) NSString *optVoteTotal;
@property(nonatomic,copy) NSString *optPersent;
@property(nonatomic,copy) NSString *isMyVote;
@property(nonatomic,copy) NSString *myMsg;

@end

// 一个投票
@interface SNNewsVoteItem : NSObject {
    NSString *voteId;
    NSString *content;
    NSString *voteType;
    NSString *postion;
    NSString *minVoteNum;
    NSString *maxVoteNum;
    NSArray  *optionArray;
}

@property(nonatomic,copy) NSString *voteId;
@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *voteType;
@property(nonatomic,copy) NSString *postion;
@property(nonatomic,copy) NSString *minVoteNum;
@property(nonatomic,copy) NSString *maxVoteNum;
@property(nonatomic,strong) NSArray  *optionArray;

// 是否投过票
- (BOOL)hasMyVote;

@end

// 一组投票
@interface SNNewsVotesInfo : NSObject {
    NSString *topicId;
    NSString *startTime;
    NSString *endTime;
    NSString *viewResultCond;
    NSString *isRandomOrdered;
    NSString *isOver;
    NSString *isVoted;          // 是否投过票 “1”-YES “0”-NO
    NSString *isShowDetail;
    NSString *voteTotal;
    NSArray  *voteArray;
}

@property(nonatomic,copy) NSString *topicId;
@property(nonatomic,copy) NSString *startTime;
@property(nonatomic,copy) NSString *endTime;
@property(nonatomic,copy) NSString *viewResultCond;
@property(nonatomic,copy) NSString *isRandomOrdered;
@property(nonatomic,copy) NSString *isOver;
@property(nonatomic,copy) NSString *isVoted;
@property(nonatomic,copy) NSString *isShowDetail;
@property(nonatomic,copy) NSString *voteTotal;
@property(nonatomic,strong) NSArray *voteArray;

// 是否投过票
- (BOOL)hasMyVote;

@end
