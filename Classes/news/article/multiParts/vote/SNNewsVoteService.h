//
//  SNNewsVoteService.h
//  sohunews
//
//  Created by wang yanchen on 12-10-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNNewsVote.h"
#import "TBXML.h"

@interface SNNewsVoteService : NSObject<TTURLRequestDelegate> {
    NSString *_newsID;
    NSString *_topicID;
    id __weak _delegate;
    
    SNNewsVotesInfo *_votesInfo;
}

@property(nonatomic, weak) id delegate;
@property(nonatomic, copy) NSString *newsID;
@property(nonatomic, copy) NSString *topicID;
@property(strong) SNNewsVotesInfo *votesInfo;

// init
- (id)initWithNewsId:(NSString *)newsId;

// vote detail
- (void)refreshVoteDetail;

// 投票接口
// topicID --> 投票主题Id
// newsID --> 新闻Id
// voteInfoStr --> 自定义格式 -->可能包含的部分：1 每个投票的voteId和optionId，格式为voteId_optionId,optionId,...; 2 自定义投票内容，格式为optionId_content
// eg. &vote=26_93,94&vote=13_51,53&msg=93_烧烤&msg=51_二锅头
- (void)submitVotesWithTopicID:(NSString *)topicID newsID:(NSString *)newsID voteInfoString:(NSString *)voteInfoStr;

// vote realtime api
- (void)refreshVotesRealTimeInfo:(NSString *)topicID newsID:(NSString *)newsID;

// cacel some running requests
- (void)cancel;

// class methods

// parse xml string from data string
+ (NSString *)getVotesXMLFromData:(NSData *)data;

// parse xml data
+ (SNNewsVotesInfo *)votesInfoFromXMLElement:(TBXMLElement *)rootElement;
+ (SNNewsVoteItem *)parseNewsVoteItemFromXMLElement:(TBXMLElement *)voteItemElem;

// parse json data
+ (SNNewsVotesInfo *)parseVoteDetailData:(id)jsonObj;
+ (SNNewsVoteItem *)parseOneVote:(id)aVote;
+ (SNNewsVoteItemOption *)parseOneOption:(id)aOption;

// load votes info from db
+ (SNNewsVotesInfo *)votesInfoFromLocalDBByNewsID:(NSString *)newsID;

@end

typedef enum {
    SNNewsVoteSubmitErrNetworkError = -1001
}SNNewsVoteSubmitErr;

@protocol SNNewsVoteServiceDelegate <NSObject>

@optional
- (void)voteRealTimeInfoDidFinishLoad:(SNNewsVotesInfo *)votesInfo;
- (void)voteRealTimeInfoDidFail;

- (void)voteSubmitDidFinishLoad:(SNNewsVotesInfo *)votesInfo;
- (void)voteSubmitDidFailWithErrorCode:(int)errCode errorMsg:(NSString *)msg;

- (void)voteDetailDidFinishLoad:(SNNewsVotesInfo *)votesInfo;

@end
