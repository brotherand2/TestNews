//
//  SNRollingNewsModel.h
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNURLRequest.h"
#import "SNNewsModel.h"
#import "SNRollingNews.h"
#import "SNRollingNewsPublicManager.h"

#define kLastTopNewsCnt             @"kLastTopNewsCnt"//置顶区显示N条置顶新闻

@interface SNRollingNewsModel : SNNewsModel {
    NSString *_channelId;                       //频道ID
    NSString *timelineWhenViewReleased;
    NSString *ctx;
    NSString *tracker;
    NSString *cursor;

    NSMutableArray *_rollingNews;               //存储频道新闻数据
    NSMutableArray *_recommendNews;             //存储推荐新闻数据
    NSMutableArray *sectionsArray;              //section标题数据
    
	NSInteger _page;                            //加载页数
    int _minTimelineIndex;                      //数据库排序编号
    int action;                                 //用户行为 0 无动作，1 下拉，2 上拉
    long long rtime;                            //推荐新闻缓存时间
    NSInteger times;                            //用户的主动下拉次数
    BOOL _more;                                 //是否加载更多
    BOOL isLoadingNewChannel;                   //这个是为了防止上一个频道刚刷完的瞬间，仍然是isLoading=YES，导致无法刷新下一个频道
    BOOL isCancelLoading;                       //防止数据load成功之后回调crash
    BOOL isRecreate;
    BOOL isLoadRecommend;                       //是否为刷新推荐
    BOOL isLoadingNews;                         //是否正在加载
    BOOL isSection;
    BOOL isPreload;                             //是否允许预加载
    BOOL isEditLoadMore;                        //是否加载编辑频道更多
    BOOL showUpdateTips;                        //是否显示频道更新红点
    BOOL isLoadFirstPage;                       //是否加载首页频道第一页
    
    SNRollingNews *loadMoreNews;
    
    BOOL _clickTodayImportNews;
    int  topNewsCnt;                            //显示的置顶新闻条数
    int  curTopNewsCnt;                         //当前展示的置顶数
}

@property (nonatomic, strong) SNURLRequest *request;
@property (nonatomic, strong) NSString *loadMoreTopicString;

@property (nonatomic, assign) BOOL isLoadRecommend;
@property (nonatomic, assign) BOOL isSection;
@property (nonatomic, readonly) BOOL more;

//这个是为了防止上一个频道刚刷完的瞬间，仍然是isLoading=YES，导致无法刷新下一个频道
@property (nonatomic, assign) BOOL isLoadingNewChannel;

@property (nonatomic, strong) NSMutableArray *rollingNews;
@property (nonatomic, strong) NSMutableArray *recommendNews;
@property (nonatomic, strong) NSMutableArray *adItem;
@property (nonatomic, strong) NSMutableArray *popularizeItem;
@property (nonatomic, strong) NSMutableArray *sectionsArray;

//切换其他Tab时暂时缓存Promotion
@property (nonatomic, strong) NSArray *cachePromotions;
//预加载的空广告
@property (nonatomic, strong) NSMutableArray *preloadEmptyADs;
//预加载的新闻 只是个容器，用完了就清空，内容与rollingNews是一样的
@property (nonatomic, strong) NSMutableArray *preloadNews;

@property (nonatomic, copy) NSString *channelIdForPromotion;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *timelineWhenViewReleased;
@property (nonatomic, copy) NSString *ctx;
@property (nonatomic, copy) NSString *tracker;
@property (nonatomic, copy) NSString *shareContent;
@property (nonatomic, copy) NSString *cursor;
@property (nonatomic, copy) NSString *subId;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, readonly) BOOL isLocalChannel;
@property (nonatomic, copy) NSString *channelName;

@property (nonatomic, assign) BOOL isCacheModel;//此model是缓存数据

//本次刷新是否由下拉刷新发起。 如果是下拉刷新，
//不重置Focusposition，否则重置。此逻辑有任何bug，找书魁摆平。
@property (nonatomic) BOOL isPullRefresh;


@property (nonatomic, strong) NSMutableArray *topNewsList;
@property (nonatomic, assign) int topNewsIndex;//当前显示置顶新闻Index
@property (nonatomic, strong) NSString *notificationURL;
@property (nonatomic, assign) BOOL shouldDeleteTopNews;
@property (nonatomic, strong) NSMutableDictionary *messageDic;//toast提示相关子弹

@property (nonatomic, assign) int  topNewsCnt;
@property (nonatomic, assign) int  curTopNewsCnt;


- (BOOL)isEditLoadingMore;
- (BOOL)isHomePage;
- (BOOL)isHomeEidtPage;
- (BOOL)loadMoreEditNewsWithPage:(int) pageNum;
- (BOOL)isRecommendPage;
- (BOOL)isRecomendNewChannel;

- (int)getAction;

- (id)initWithChannelId:(NSString *)channelId;
- (void)setNewsAsRead:(NSString *)newsId;
- (void)deleteNewsWithNews:(SNRollingNews *)news;
+ (void)updateNewsWithNews:(SNRollingNews *)news;

+ (BOOL)isLocalChannel:(NSString *)channelId;
+ (void)saveLocalChannelId:(NSString *)channelIdString;

+ (BOOL)isReadNewsWithNewsId:(NSString *)newsId
                   ChannelId:(NSString *)channelId;

+ (void)saveReadNewsWithNewsId:(NSString *)newsId
                     ChannelId:(NSString *)channelId;

- (void)updateRollingNewsToDB:(id)rootData;

- (BOOL)hasTopNews;
- (BOOL)shouldInsertNews;

- (void)requestDidFinishLoad;
- (BOOL)addExclusiveRollingNews:(SNRollingNews *)news;
- (SNRollingNews *)createNews:(NSDictionary *)data
                         from:(NSString *)from ;
- (NSArray *)createRollingNewsListItems:(NSArray *)newsList;
- (SNRollingNews *)createNewsByItem:(RollingNewsListItem *)item;
- (void)setRollingNewsTimelineIndex:(NSMutableArray *)rollingNews;
- (NSArray *)getNeedShowTopNewsList;
- (void)loadNewsRequestWithUrl:(NSString *)url
                       isSynch:(BOOL)isSyn
                         topic:(NSString *)topicString;
- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error;
- (void)requestDidCancelLoad:(TTURLRequest *)request;
- (BOOL)isNewHomePage;
- (BOOL)isLoadingTrainList;

- (void)setRequestFinishedLoad;

@end
