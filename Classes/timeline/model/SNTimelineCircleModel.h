//
//  SNTimelineModel.h
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTimelineTrendObjects.h"
#import "SNConsts.h"


#define kTimelineDidPostCommentNotification     (@"kTimelineDidPostCommentNotification")

typedef NS_ENUM(NSInteger, SNCircleErrorCode)
{
    kSNCircleErrorCodeNoError =  0,
    kSNCircleErrorCodeNoData  =  1000,
    kSNCircleErrorCodeDisconnect = -1009,
    kSNCircleErrorCodeTimeOut = -1001,
//    kSNCircleErrorCodeEmpty = 200
};

// 多实例 model
// 独立请求 不做多请求处理

@interface SNTimelineCircleModel : NSObject<TTURLRequestDelegate> {
    id _delegate;
    
    NSString *_requestUrl;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) BOOL hasMore; // default value is NO
@property(nonatomic, assign) BOOL hasMoreComment;
@property(nonatomic, assign) BOOL isLoadingMore;
@property(nonatomic, assign) BOOL loading;
@property(nonatomic, retain) NSMutableArray *timelineObjects; // array of SNTimelineObject 默认model 实例化之后  会首先加载db数据
@property(nonatomic, copy) NSString *allNum; // 所有动态的数量 （不是所有的请求都能返回 ）

@property(nonatomic, retain) SNURLRequest *request;
@property(nonatomic, copy) NSString *pid; // 用户的passport id // 如果未登陆 则为nil
@property(nonatomic, assign) BOOL isLogged; // 是否已经登陆
@property(nonatomic, assign) BOOL isForOneUser; // 是否只看某个人自己的动态

// timeline cursor
@property(nonatomic, assign) int nextCursor;
@property(nonatomic, assign) int preCursor;

// response result
@property(nonatomic, copy) NSString *lastErrorMsg;
@property(nonatomic, assign) int lastErrorCode;
@property(nonatomic, retain) NSDate *lastRefreshDate;

+ (SNTimelineCircleModel *)modelForCurrentUser; // 当前用户

// 加载本地数据 有多少加载多少
- (void)loadCache;

// 登陆情况下 查看阅读圈 动态
- (void)timelineRefresh;
- (void)timelineSendRefresh;
- (void)timelineGetMore;
- (void)timelineSendGetMore;
- (void)parseResult:(NSDictionary *)resultDic;
- (void)cancelAndClean; // delegate will be cleaned 

@end

@protocol SNTimelineModelDelegate <NSObject>

@optional
- (void)timelineModelDidStartLoad;
- (void)timelineModelDidFinishLoad;
- (void)timelineModelDidFailToLoadWithError:(NSError *)error;

@end
