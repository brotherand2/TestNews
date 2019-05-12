//
//  SNCommentListModel.h
//  sohunews
//
//  Created by jialei on 13-8-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsComment.h"
#import "SNCommentConfigs.h"

@class SNCommentListModel;

@protocol SNCommentListModelDelegate <NSObject>
@optional
- (void)commentListModelDidStartLoad:(SNCommentListModel *)commentModel;
- (void)commentListModelDidFinishLoad:(SNCommentListModel *)commentModel;
- (void)commentListModelDidFailToLoadWithError:(SNCommentListModel *)commmentModel;

@end


@interface SNCommentListModel : NSObject
{
    BOOL            _loadHistory;
    BOOL            _hasMore;
    
    NSInteger        _loadPageNum;                    //请求开始页数
    NSString         *_type;                          //请求评论类型
    NSString         *_lastCommentId;
    NSString         *_readCount;
    NSString         *_url;
    NSString         *_stpAudCmtRsn;                  //如果不为nil，表示禁止语音评论
    id<SNCommentListModelDelegate>  __weak _delegate;
    
    NSMutableArray *_comments;
    NSMutableArray *_hadDingComments;
}

@property (nonatomic,strong)NSMutableArray   *comments;
@property (nonatomic,weak)id delegate;
@property (nonatomic,assign)int tag;

@property (nonatomic, strong)NSString *lastCommentId;
@property (nonatomic, strong)NSString *firstCommentId;
@property (nonatomic, copy) NSString *lastErrorMsg;
@property (nonatomic, assign) int lastErrorCode;
@property(nonatomic, strong) NSDate *lastRefreshDate;
@property (nonatomic, weak)NSString *requestSource;

@property (nonatomic, assign) BOOL hasMore;                          // default value is NO
@property (nonatomic, assign) BOOL loadHistory;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isAuthor;
@property (nonatomic, assign) int loadPageSize;
@property (nonatomic, assign) int loadPageNum;
@property (nonatomic, assign) int commentCellHeight;
@property (nonatomic, strong) NSString *readCount;
@property (nonatomic, strong) NSString *commentCount;
@property (nonatomic, strong) NSString *stpAudCmtRsn;
@property (nonatomic, copy)   NSString *comtStatus; //文章是否评论状态
@property (nonatomic, copy)   NSString *comtHint;   //文章禁止评论提示
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) NSString *busiCode;
@property (nonatomic, assign) int rollType;
@property (nonatomic, assign) BOOL isHotTab;
@property (nonatomic, assign) BOOL hasSameData;
@property (nonatomic, assign) BOOL changeRequest;
@property (nonatomic, assign) int commentType;   //评论类型 1=最新评论，2=热门评论，3=登录评论_最新，4=未登录评论_最新 , 5=登录评论_热门
@property (nonatomic, assign) NSInteger refererType; //默认为1，1=编辑流，2=推荐流，3=搜索，4=相关推荐，5=H5页面

- (id)initWithCommentModelWithNewsId:(NSString *)newsId gid:(NSString*)gid;
- (void)requestLatestComment;
- (void)loadData:(BOOL)more;
- (void)resetData;
- (BOOL)getIsLoading;
- (BOOL)hasEqualComment:(SNNewsComment *)comment searchArray:(NSArray *)array;
- (SNNewsComment *)jsonStringToComment:(NSString *)jsonDataString topicId:(NSString *)topicId;
- (NSString *)sourceId;
- (NSString *)cursorId;



@end
