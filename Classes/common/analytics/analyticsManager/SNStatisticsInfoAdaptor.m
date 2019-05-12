//
//  SNStatisticsDataAdpator.m
//  sohunews
//
//  Created by jialei on 14-8-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//  

#import "SNStatisticsInfoAdaptor.h"
#import "SNRollingNews.h"
#import "SNRollingNewsTableItem.h"
#import "SNNewsAd+analytics.h"
#import "SNBusinessStatisticsManager.h"
#import "SNVideoAdContext.h"
#import "SNUtility.h"

@implementation SNStatisticsInfoAdaptor

+ (void)uploadTimelineloadInfo:(NSArray *)rollingNewsItems isPreload:(BOOL)preload
{
    if (rollingNewsItems.count <= 0) {
        return;
    }
    for (SNRollingNews *newsItem in rollingNewsItems) {
        @autoreleasepool {
            if (!preload) {//预加载延时上报 滑动到该频道时再上报 SNRollingNewsTableController.m line 1128
                //广告类型
                if ([newsItem.newsType isEqualToString:kNewsTypeAd]) {
                    [newsItem.newsAd reportAdLoad:newsItem];
                    newsItem.newsAd.isReported = YES;
                }
                if (([newsItem.templateType isEqualToString:kTemplateTypeFullScreenFocus] || [newsItem isMoreFocusNews]) && newsItem.newsFocusArray.count > 0) {
                    for (SNRollingNews *adNews in newsItem.newsFocusArray) {
                        if (adNews && [adNews.adType isEqualToString:@"2"]) {
                            [adNews.newsAd reportEmptyLoad:adNews];
                        } else if ([adNews.newsType isEqualToString:kNewsTypeAd] &&
                            !adNews.newsAd.isReported) {
                            [adNews.newsAd reportAdLoad:adNews];
                            adNews.newsAd.isReported = YES;
                        }
                    }
                }
                if ([newsItem.templateType isEqualToString:kTemplateTypeTrainCard] && newsItem.newsItemArray.count > 0) {
                    for (SNRollingNews *adNews in newsItem.newsItemArray) {
                        if (adNews && [adNews.adType isEqualToString:@"2"]) {
                            [adNews.newsAd reportEmptyLoad:adNews];
                        } else if ([adNews.newsType isEqualToString:kNewsTypeAd] &&
                                   !adNews.newsAd.isReported) {
                            [adNews.newsAd reportAdLoad:adNews];
                            adNews.newsAd.isReported = YES;
                        }
                    }
                }
                //流内冠名加载上报，如果有SNNewsSponsorships节点，表明有冠名广告
                if ([newsItem respondsToSelector:@selector(sponsorshipsObject)]) {
                    SNNewsSponsorships *sponsorshipsObject = [newsItem performSelector:@selector(sponsorshipsObject)];
                    if ([sponsorshipsObject.adType isEqualToString:@"1"]) {
                        [sponsorshipsObject reportSponsorShipLoad:newsItem];
                        sponsorshipsObject.isReported = YES;
                    }
                    else if ([sponsorshipsObject.adType isEqualToString:@"2"]) {
                        [sponsorshipsObject reportSponsorShipEmpty:newsItem];
                        sponsorshipsObject.isReported = YES;
                    }
                }
            }
            
            //参见wiki:http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=7471346
            //流内statsType为1表示推广新闻统计(目前，流内主要有newsType为18和newsType为23的两种推广)
            if (newsItem.statsType == SNRollingNewsStatsType_ShnAdStat) {
                SNStatLoadInfo *info = [[SNStatLoadInfo alloc] init];
                info.token = newsItem.token;
                info.objType = newsItem.templateType;
                info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
                info.objFromId = newsItem.channelId;
                info.itemspaceid = newsItem.newsAd.itemSpaceId;
                info.monitorkey = newsItem.newsAd.monitorkey;
                info.gbcode = newsItem.newsAd.gbcode;
                
                NSMutableArray *appAdIDArray = [NSMutableArray array];
                for (SNNewsApp *newsApp in newsItem.appArray) {
                    @autoreleasepool {
                        NSString *adID = newsApp.adID;
                        if (adID.length > 0) {
                            [appAdIDArray addObject:adID];
                        }
                    }
                }
                info.adIDArray = appAdIDArray;
                info.objLabel = SNStatInfoUseTypeTimelinePopularize;
                
                [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
            }
            
            //个性化模版
            if ([newsItem.newsType isEqualToString:kNewsTypeIndividuation]) {
                SNStatLoadInfo *info = [[SNStatLoadInfo alloc] init];
                info.token = newsItem.token;
                info.objType = newsItem.templateType;
                info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
                info.objFromId = newsItem.channelId;
                info.itemspaceid = newsItem.newsAd.itemSpaceId;
                info.monitorkey = newsItem.newsAd.monitorkey;
                info.gbcode = newsItem.newsAd.gbcode;
                
                NSMutableArray *appAdIDArray = [NSMutableArray array];
                for (SNNewsIndividuationNameInfo *indivInfo in newsItem.individuation.individuationArray) {
                    @autoreleasepool {
                        NSString *adID = indivInfo.idString;
                        if (adID.length > 0) {
                            [appAdIDArray addObject:adID];
                        }
                    }
                }
                info.adIDArray = appAdIDArray;
                info.objLabel = SNStatInfoUseTypeTimelinePopularize;
                
                [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
            }
        }
    }
}

+ (void)uploadSubPopularizeLoadInfo:(NSArray *)aSubAdObj
{
    if (!aSubAdObj || aSubAdObj.count <= 0) {
        return;
    }
    
    SNStatLoadInfo *info = [[SNStatLoadInfo alloc] init];
    NSMutableArray *appAdIDArray = [NSMutableArray array];
    for (SCSubscribeAdObject *aNewAdObj in aSubAdObj) {
        if (aNewAdObj.adId.length > 0) {
            [appAdIDArray addObject:aNewAdObj.adId];
        }
    }
    info.adIDArray = appAdIDArray;
    info.objLabel = SNStatInfoUseTypeOutTimelinePopularize;
    info.objType = kObjTypeOfRecommendPosionInMySubBanner;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
//    info.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];

    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

+ (void)uploadSubPopularizeDisplayInfo:(SCSubscribeAdObject *)aNewAdObj
{
//    if (![[[SNVideoAdContext sharedInstance] getObjFromForCDotGif] isEqualToString:@"subscribe"]) {
//        return;
//    }
    
    if (!aNewAdObj) {
        return;
    }
    
    SNStatExposureInfo *info = [[SNStatExposureInfo alloc] init];
    if (aNewAdObj.adId.length > 0) {
        info.adIDArray = @[aNewAdObj.adId];
    }
    
    info.objLabel = SNStatInfoUseTypeOutTimelinePopularize;
    info.objType = kObjTypeOfRecommendPosionInMySubBanner;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    info.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

#pragma mark- 业务类型统计
+ (void)cacheTimelineNewsShowBusinessStatisticsInfo:(SNRollingNews *)newsItem {
    if (![newsItem.channelId isEqualToString:[[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif]]) {
        return;
    }
    
    SNBusinessStatInfo *statInfo = [[SNBusinessStatInfo alloc] init];
    statInfo.statType = SNStatisticsEventTypeShow;
    statInfo.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForExpsGif];
    
    //PGC视频
    if ([newsItem.templateType isEqualToString:@"38"]) {
        statInfo.objFrom = SNBusinessStatisticsObjFromPGC;
    }
    
    statInfo.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    if (newsItem.newsId.length > 0) {
        statInfo.objIDArray = @[newsItem.newsId];
    }
    statInfo.timelineMode = newsItem.isRecom;
    if ([newsItem isFocusNews]) {
        statInfo.timelineMode = @"13";
    } else if ([newsItem isRedPacketNews]) {
        statInfo.timelineMode = @"17";
    } else if ([newsItem.newsId isEqualToString:@"20"]) {
        statInfo.timelineMode = @"19";
        
        //解析adID
        statInfo.adId = [SNUtility getNewsItemAdId:newsItem.link];
    }
    
    statInfo.token = newsItem.token;
    statInfo.isTopNews = newsItem.isTopNews == YES ? 1 : 0;
    if ([newsItem.link hasPrefix:@"channel://"]) {
        NSString *prefix = @"channel://";
        NSString *urlStr = [newsItem.link substringFromIndex:prefix.length];
        NSArray *substrings = [urlStr componentsSeparatedByString:@"&"];
        
        for (int x = 0; x < substrings.count; x++) {
            @autoreleasepool {
                NSString *strPart = [substrings objectAtIndex:x];
                NSArray *partItem = [strPart componentsSeparatedByString:@"="];
                if (partItem.count>=2) {
                    NSString *name = [partItem objectAtIndex:0];
                    NSString *value = [partItem objectAtIndex:1];
                    if (name&&value) {
                        if ([name isEqualToString:@"channelId"]) {
                            statInfo.toChannelId = value;
                        } else if ([name isEqualToString:@"position"]) {
                            statInfo.position = value;
                        }
                    }
                }
            }
        }
    } else {
        statInfo.position = nil;
        statInfo.toChannelId = nil;
    }
    
    if (!([newsItem.recomReasons isEqualToString:@"0"] ||
          newsItem.recomReasons.length == 0)) {
        statInfo.recomReasons = newsItem.recomReasons;
    }
    if (!([newsItem.recomTime isEqualToString:@"0"] ||
          newsItem.recomTime.length == 0)) {
        statInfo.recomTime = newsItem.recomTime;
    }
    
    [[SNBusinessStatisticsManager shareInstance] updateStatisticsInfo:statInfo];
}

+ (void)cacheRecomSubscribeShowBusinessStatisticsInfo:(SCSubscribeObject *)recomSubItem
{
    if (!recomSubItem) {
        return;
    }
    
    SNBusinessStatInfo *statInfo = [[SNBusinessStatInfo alloc] init];
    statInfo.statType = SNStatisticsEventTypeShow;
    statInfo.objFrom = 3;
    statInfo.objFromId = @"0";
    statInfo.objType = SNBusinessStatisticsObjTypeSubRecom;
    statInfo.objIDArray = @[recomSubItem.subId];
    
    [[SNBusinessStatisticsManager shareInstance] updateStatisticsInfo:statInfo];

}

+ (void)cacheTimelineNewsLoadBusinessStatisticsInfo:(NSArray *)newsItems dragDown:(BOOL)isDragDown
{
    if (newsItems.count <= 0) {
        return;
    }
    
    SNBusinessStatInfo *statInfo = [[SNBusinessStatInfo alloc] init];
    SNRollingNews *newsItem = [newsItems firstObject];
    
    NSMutableArray *appAdIDArray = [NSMutableArray array];
    for (SNRollingNews *item in newsItems) {
        if (item.newsId) {
            [appAdIDArray addObject:item.newsId];
        }
    }
    
    statInfo.objIDArray = appAdIDArray;
    statInfo.statType = SNStatisticsEventTypeLoad;
    statInfo.objFrom  = [[SNVideoAdContext sharedInstance] getObjFromForExpsGif];
    statInfo.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    statInfo.objType = SNBusinessStatisticsObjTypeTimeline;
    statInfo.token = newsItem.token;
    statInfo.timelineMode = newsItem.isRecom;
    statInfo.loadMode = isDragDown ? businessStatisticsLoadTypeDragDownRefresh: businessStatisticsLoadTypeDragUpLoadMore;
    
    [[SNBusinessStatisticsManager shareInstance] updateStatisticsInfo:statInfo];
}

+ (void)cacheNewsRecommendBusinessStatisticsInfo:(NSArray *)rollingNewsTableItems statType:(SNStatisticsEventType)statType
{
    if (rollingNewsTableItems.count <= 0) {
        return;
    }
    NSMutableArray *appAdIDArray = [NSMutableArray array];
    for (SNRollingNewsTableItem *newsItem in rollingNewsTableItems) {
        [appAdIDArray addObject:newsItem.news.newsId];
    }
    SNRollingNewsTableItem *newsItem = [rollingNewsTableItems firstObject];
    
    SNBusinessStatInfo *statInfo = [[SNBusinessStatInfo alloc] init];
    statInfo.statType = statType;
    statInfo.objIDArray = appAdIDArray;
    statInfo.objFrom  = [[SNVideoAdContext sharedInstance] getObjFromForExpsGif];
    statInfo.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    statInfo.objType = SNBusinessStatisticsObjTypeArticleRecommend;
    statInfo.token = newsItem.news.token;
    [[SNBusinessStatisticsManager shareInstance] updateStatisticsInfo:statInfo];
}

+ (void)cacheLoadGalleryRecommendBusinessStatisticsInfo:(NSArray *)galleryRecommends
{
    if (galleryRecommends.count <= 0) {
        return;
    }
    NSMutableArray *appAdIDArray = [NSMutableArray array];
    for (RecommendGallery *recommend in galleryRecommends) {
        [appAdIDArray addObject:recommend.newsId];
    }
    
    SNBusinessStatInfo *statInfo = [[SNBusinessStatInfo alloc] init];
    statInfo.statType = SNStatisticsEventTypeLoad;
    statInfo.objIDArray = appAdIDArray;
    statInfo.objFrom  = [[SNVideoAdContext sharedInstance] getObjFromForExpsGif];
    statInfo.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    statInfo.objType = SNBusinessStatisticsObjTypeGalleryRecommend;

    [[SNBusinessStatisticsManager shareInstance] updateStatisticsInfo:statInfo];
}
@end
