//
//  SNStatisticsDataAdpator.h
//  sohunews
//
//  Created by jialei on 14-8-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//  对统计的中间数据进行处理

#import <Foundation/Foundation.h>
#import "SNStatisticsManager.h"
#import "SNRollingSubscribeRecomItem.h"

@class SNRollingNews;


@interface SNStatisticsInfoAdaptor : NSObject

/*流内广告加载数据上传
 *@param  rollingNewsItems  一次加载的所有新闻数据，如果是预加载的数据，preload=YES
 */
+ (void)uploadTimelineloadInfo:(NSArray *)rollingNewsItems isPreload:(BOOL)preload;

/*订阅tab加载推广位数据上传
 *@param ((SCSubscribeAdObject *)aNewAdObj *)aNewAdObj  推广位数据结构
 */
+ (void)uploadSubPopularizeLoadInfo:(NSArray *)aNewAdObj;

/*订阅tab展示推广位数据上传
 *@param ((SCSubscribeAdObject *)aNewAdObj *)aNewAdObj  推广位数据结构
 */
+ (void)uploadSubPopularizeDisplayInfo:(SCSubscribeAdObject *)aNewAdObj;

/*流内业务类型展示曝光数据统计
 *@param (SNRollingNews *)newsItem  一次展示新闻数据结构
 */
+ (void)cacheTimelineNewsShowBusinessStatisticsInfo:(SNRollingNews *)newsItem;

//订阅频道推荐订阅数据上传
+ (void)cacheRecomSubscribeShowBusinessStatisticsInfo:(SCSubscribeObject *)recomSubItem;

/*流内业务类型加载曝光数据统计
 * @param  (NSArray *)newsItems  一次加载的所有新闻数据
 */
+ (void)cacheTimelineNewsLoadBusinessStatisticsInfo:(NSArray *)newsItems dragDown:(BOOL)isDragDown;

+ (void)cacheNewsRecommendBusinessStatisticsInfo:(NSArray *)rollingNewsTableItems statType:(SNStatisticsEventType)statType;

+ (void)cacheLoadGalleryRecommendBusinessStatisticsInfo:(NSArray *)galleryRecommends;

@end

