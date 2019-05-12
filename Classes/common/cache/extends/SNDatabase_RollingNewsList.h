//
//  SNDatabase_RollingNewsList.h
//  sohunews
//
//  Created by 李 雪 on 11-10-18.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"

@interface SNDatabase(RollingNewsList)
- (NewsArticleItem *)getNewsArticelByChannelId:(NSString *)channelId
                                        newsId:(NSString *)newsId;

- (BOOL)addSingleRollingArticleOrUpdate:(NewsArticleItem *)newsArtcile;
- (BOOL)addSingleRollingArticleIfNotExist:(NewsArticleItem *)newsArtcile;
- (BOOL)addSingleRollingArticle:(NewsArticleItem *)newsArtcile
                  updateIfExist:(BOOL)bUpdateIfExist;

- (NSArray *)getRollingNewsListNextPageByChannelId:(NSString *)channelId
                                     timelineIndex:(NSString *)timelineIndex;
- (NSArray *)getRollingNewsListNextPageByChannelId:(NSString *)channelId
                                     timelineIndex:(NSString *)timelineIndex
                                          pageSize:(int)pageSize;
- (NSArray *)getRollingNewsListByChannelId:(NSString *)channelId
                                      page:(int)page
                                  pageSize:(int)pageSize;
- (NSArray *)getRollingHeadlineListByChannelId:(NSString *)channelId;
- (NSArray *)getUnreadRollingExpressListByChannelId:(NSString *)channelId;
- (NSArray *)getLastRollingExpressListByChannelId:(NSString *)channelId;
- (NSArray *)getLastRollingRecomendListByChannelId:(NSString *)channelId;

- (RollingNewsListItem *)getRollingNewsListItemByChannelId:(NSString *)channelId
                                                    newsId:(NSString *)newsId;
- (RollingNewsListItem *)getRollingNewsListItemByNewsId:(NSString *)newsId;

- (BOOL)addSingleRollingNewsListItem:(RollingNewsListItem *)news;
- (BOOL)addSingleRollingNewsListItem:(RollingNewsListItem *)news
                       updateIfExist:(BOOL)bUpdateIfExist;

- (BOOL)addMultiRollingNewsListItem:(NSArray *)newsList;
- (BOOL)addMultiRollingNewsListItem:(NSArray *)newsList
                      updateIfExist:(BOOL)bUpdateIfExist;

- (BOOL)updateRollingNewsListItemByChannelId:(NSString *)channelId
                                      newsId:(NSString *)newsId
                              withValuePairs:(NSDictionary *)valuePairs;

- (BOOL)updateRollingNewsListItemByNewsId:(NSString *)newsId
                           withValuePairs:(NSDictionary *)valuePairs;

- (BOOL)deleteRollingNewsListItemByChannelId:(NSString *)channelId newsId:(NSString *)newsId;
- (BOOL)markRollingNewsListItemAsReadByChannelId:(NSString *)channelId newsId:(NSString *)newsId;
- (BOOL)checkRollingNewsListItemReadOrNotByChannelId:(NSString *)channelId newsId:(NSString *)newsId;
- (BOOL)markRollingNewsListItemAsNotExpiredByChannelId:(NSString *)channelId newsId:(NSString *)newsId;
- (BOOL)markRollingNewsListItemAsReadAndNotExpiredByChannelId:(NSString *)channelId newsId:(NSString *)newsId;

//未调用过
//- (BOOL)clearAllRecommendNewsList;
- (BOOL)clearRollingEditNewsListByChannelId:(NSString *)channelId;
//删除天气
- (BOOL)clearRollingLocalWeatherNewsByChannelId:(NSString *)channelId;
- (BOOL)clearRollingRecommendNewsListByChannelId:(NSString *)channelId;
- (BOOL)clearRollingRecommendNewsListByChannelId:(NSString *)channelId form:(NSString *)form;

//清空当前频道的置顶新闻
- (BOOL)clearAllTopRollingNewsList:(NSString *)channelId;
//清空当前频道的非置顶推荐新闻（流式频道的都是推荐新闻，针对首页流编辑和推荐混合）
- (BOOL)clearAllOtherRollingNewsList:(NSString *)channelId;
- (BOOL)updateLatestRollingNewsList:(NSString *)channelId;
- (BOOL)clearRefreshRollingNewsItem:(NSString *)channelId;

- (NSString *)getMaxRollingTimelineIndexByChannelId:(NSString *)channelId;
- (NSString *)getMinRollingTimelineIndexByChannelId:(NSString *)channelId;

- (BOOL)clearRollingNewsList;
//暂时使用, 如果以后保留所有频道历史, 可以去掉这个方法
- (BOOL)clearRollingNewsListExceptChannelID:(NSString *)channelId;

- (BOOL)clearRollingNewsListByChannelId:(NSString *)channelId;
- (BOOL)clearRollingLoadMoreNewsListByChannelId:(NSString *)channelId;
- (BOOL)clearRollingNewsHistoryByChannelID:(NSString *)channelID days:(NSInteger)days;

#pragma mark - About RollingNews list download - by Handy
- (BOOL)saveDownloadedRollingNewsItemArrayToDB:(NSArray *)downloadedRollingNews
                                  forChannelID:(NSString *)channelID;
- (NSString *)getMaxRollingTimelineIndexByChannelId:(NSString *)channelId
                                              form1:(NSString *)form1
                                              form2:(NSString *)form2;
- (NSArray *)getRollingNewsListNextPageByChannelId:(NSString *)channelId
                                     timelineIndex:(NSString *)timelineIndex
                                              form:(NSString *)form
                                          pageSize:(int)pageSize
                                          dateTime:(NSNumber *)dateTime
                                             later:(BOOL)later;
- (NSArray *)getRollingNewsListNextPageByChannelId:(NSString *)channelId
                                     timelineIndex:(NSString *)timelineIndex
                                              form:(NSString *)form
                                       trainCardId:(NSString *)trainCardId;
- (BOOL)updateFocusToTrainItemByChannelId:(NSString *)channelId;
- (BOOL)updateFocusToTrainNewsByChannelId:(NSString *)channelId;
- (NSArray *)getRollingFocusNewsListByChannelId:(NSString *)channelId trainCardId:(NSString *)trainCardId;
- (BOOL)clearHomeChannelRollingNewsList;

@end
