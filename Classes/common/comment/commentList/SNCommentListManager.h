//
//  SNCommentListManager.h
//  sohunews
//
//  Created by jialei on 13-8-20.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCommentConfigs.h"
#import "SNHotCommentListModel.h"
#import "SNNewCommentListModel.h"
#import "SNCommentListModel.h"

#define kCommentListKeyNewsId           (@"kCommentListKeyNewsId")
#define kCommentListKeyGid              (@"kCommentListKeyGid")
#define kCommentListKeyNewsSource       (@"kCommentListKeyNewsSource")
#define kCommentListKeyNewsTime         (@"kCommentListKeyNewsTime")
#define kCommentListKeyNewsTitle        (@"kCommentListKeyNewsTitle")
#define kCommentListKeyNewsReadCount    (@"kCommentListKeyNewsReadCoundt")
#define kCommentListKeyNewsStopAudio    (@"kCommentListKeyNewsStopAudio")
#define kCommentListkeyRequestType      (@"kCommentListkeyRequestType")
#define kCommentListKeyNewsQuery        (@"kCommentListKeyNewsQuery")
#define kCommentListKeyIsAuthor         (@"kCommentListKeyIsAuthor")
#define kCommentListKeySubId            (@"kCommentListKeySubId")
#define kCommentListKeyShareContent     (@"kCommentListKeyShareContent")
#define kCommentListKeyCmtStatus        (@"kCommentListKeyCmtStatus")   
#define kCommentListKeyCmtHint          (@"kCommentListKeyCmtHint")
#define kCommentListKeyShareCmtObj      (@"kCommentListKeyShareCmtObj")
#define kCommentListKeyBusiCode         (@"kCommentListKeyBusiCode")
#define kNotificationSetCommentDelegate     @"setCommentDelegate"

typedef void (^SNCLRequestFinishedBlock)();
typedef void (^SNCLRequestFailedBlock)();


@interface SNCommentListManager : NSObject<SNCommentListModelDelegate>

@property (nonatomic, strong)SNHotCommentListModel *theHotCommentListModel;
@property (nonatomic, strong)SNNewCommentListModel *theNewCommentListModel;
@property (nonatomic, strong)NSString *readCount;
@property (nonatomic, strong)NSString *commentNum;
@property (nonatomic, strong)NSArray *commentItems;
@property (nonatomic, assign)int comtItemsCount;
@property (nonatomic, assign)int hotComtItemsCount;
@property (nonatomic, assign)int newComtItemsCount;
@property (nonatomic, assign)BOOL isAuthor;
@property (nonatomic, weak)NSMutableDictionary *userInfo;

@property (nonatomic, weak)NSString *comtStatus;
@property (nonatomic, strong)NSString *comtHint;
@property (nonatomic, strong)NSString *stpAudCmtRsn;

@property (nonatomic, copy)SNCLRequestFinishedBlock requestFinishedBlock;
@property (nonatomic, copy)SNCLRequestFailedBlock requestFailedBlock;

//+ (void)pushAllCommentListWithQuery:(NSDictionary *)query;
+ (void)expandCommentById:(NSArray *)comments cid:(NSString *)commentId;
+ (void)deleteCommentFromComments:(NSMutableArray *)comments commentId:(NSString *)commentId theId:(NSString *)theId subId:(NSString *)subId;
+ (void)deleteFloorCommentFromComments:(NSArray *)comments row:(int)row floorIndex:(int)floorIndex theId:(NSString *)theId subId:(NSString *)subId;
+ (void)openFloorById:(NSArray *)comments id:(NSString *)commentId;
+ (void)expandSubComment:(NSArray*)comments subFloorIndex:(int)floorIndex indexPathRow:(NSInteger)rowIndex;
+ (void)expandSocialByMsgId:(NSArray *)comments messageId:(NSString *)messageId;
+ (void)expandSocialFloorByMsgId:(NSArray *)comments messageId:(NSString *)messageId;
+ (void)changeAllSameCommentDingNum:(NSArray *)comments dingNumber:(NSString *)dingNum commentId:(NSString *)commentId;

- (id)initWithId:(NSString *)cmtReqId requestType:(SNCommentRequestType)type;
- (void)loadHotData:(BOOL)moreData;
- (void)loadNewData:(BOOL)moreData;
- (void)resetData;
- (BOOL)loadMoreHotComment;
- (BOOL)loadMoreNewComment:(UIScrollView *)scrollView;
//插入缓存评论
- (void)insertCacheComment:(NewsCommentItem *)cacheComment;

- (void)resetAllCommentCellHeight;
- (void)showImageWithUrl:(NSString *)urlPath;

@end
