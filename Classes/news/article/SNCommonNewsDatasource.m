//
//  SNCommonNewsDatasource.m
//  sohunews
//
//  Created by Diaochunmeng on 13-3-26.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//


#import "SNCommonNewsDatasource.h"
#import "SNRollingNewsTableItem.h"
#import "SNRollingNewsPublicManager.h"

@implementation SNCommonNewsDatasource
@synthesize newsList,photoList,specailList,weiboList,allList, newsModel;
@synthesize excludePhotoNewsIds,photoNewsIds,allNewsIds,snModel;
@synthesize allWeiwen;
@synthesize isFromSub;

-(void)dealloc
{
    self.newsModel = nil;
    
    self.snModel = nil;
    
}

-(NSMutableDictionary*)getContentDictionary:(SNRollingNews*)aNews
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:NEWS_ITEM_TYPE_NORMAL] forKey:kType]; //新加字段，标示本条新闻类型（连续阅读)
    [userInfo setObject:aNews.channelId forKey:kChannelId];
    [userInfo setObject:aNews.newsId forKey:kNewsId];
    [userInfo setObject:kNewsOnline forKey:kNewsMode];
    [userInfo setObject:self.newsList forKey:kNewsList];
    [userInfo setObject:self.newsModel forKey:kNewsModel];
    [userInfo setObject:kDftChannelGalleryTermId forKey:kTermId];
    [userInfo setObject:aNews.link forKey:kLink];
    [userInfo setObject:aNews.updateTime forKey:kUpdateTime];
    [userInfo setObject:aNews.recomInfo forKey:kRecomInfo];
    if (isFromSub) {
        [userInfo setObject:kReferFromPublication forKey:kReferFrom];
    }else {
        [userInfo setObject:kReferFromRollingNews forKey:kReferFrom];
    }
    [userInfo setObject:aNews.newsType forKey:kNewsType];//lijian 2015.03.31 添加newsType
//    NSDictionary* linkParam = [SNUtility parseURLParam:aNews.link schema:kProtocolNews];
//    NSString* openType = [linkParam objectForKey:kOpenType];
//    if(openType) {
//        [userInfo setObject:openType forKey:kOpenType];
//    }
    
    NSMutableDictionary *photoInfo = [NSMutableDictionary dictionary];
    [photoInfo setObject:[NSNumber numberWithInt:NEWS_ITEM_TYPE_GROUP_PHOTOS] forKey:kType]; //新加字段，标示本条新闻类型（连续阅读)
    [photoInfo setObject:aNews.channelId forKey:kChannelId];
    [photoInfo setObject:aNews.newsId forKey:kNewsId];
    [photoInfo setObject:kDftChannelGalleryTermId forKey:kTermId];
    [photoInfo setObject:kNewsOnline forKey:kNewsMode];
    [photoInfo setObject:self.photoList forKey:kNewsList];
    [photoInfo setObject:self.newsModel forKey:kNewsModel];
    [photoInfo setObject:[NSNumber numberWithInt:GallerySourceTypeGroupPhoto] forKey:kGallerySourceType];
    [photoInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS] forKey:kMyFavouriteRefer];
    [photoInfo setObject:kReferFromRollingNews forKey:kReferFrom];
    [photoInfo setObject:aNews.link forKey:kLink];
    [photoInfo setObject:aNews.newsType forKey:kNewsType];//lijian 2015.03.31 添加newsType
    [photoInfo setObject:aNews.updateTime forKey:kUpdateTime];
    [photoInfo setObject:aNews.recomInfo forKey:kRecomInfo];
    
    NSMutableDictionary* specail = [NSMutableDictionary dictionary];
    [specail setObject:[NSNumber numberWithInt:NEWS_ITEM_TYPE_SPECIAL_NEWS] forKey:kType]; //新加字段，标示本条新闻类型（连续阅读)
    [specail setObject:aNews.newsId forKey:kSpecialNewsTermId]; //对于滚动的专题新闻来说，从JSON数据中得到的newsId就是termId;
    [specail setObject:aNews.title forKey:kSpecialNewsTitle];
    [specail setObject:self.specailList forKey:kNewsList];
    [specail setObject:aNews.channelId forKey:kChannelId];
    [specail setObject:self.newsModel forKey:kNewsModel];
    [specail setObject:aNews.link forKey:kLink];
    [specail setObject:aNews.recomInfo forKey:kRecomInfo];

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(aNews.link!=nil && [aNews.link hasPrefix:kProtocolWeibo])
    {
        NSMutableDictionary* weibo = [SNUtility parseProtocolUrl:aNews.link schema:kProtocolWeibo];
        if (weibo && [weibo objectForKey:@"rootId"])
        {
            [weibo setObject:[weibo objectForKey:@"rootId"] forKey:kWeiboId];
            [dic setObject:weibo forKey:kContinuityWeibo];
        }
        else
            [dic setObject:[NSMutableDictionary dictionary] forKey:kContinuityWeibo];
    }
    else
        [dic setObject:[NSMutableDictionary dictionary] forKey:kContinuityWeibo];

    [dic setObject:userInfo forKey:kContinuityNews];
    [dic setObject:photoInfo forKey:kContinuityPhoto];
    [dic setObject:specail forKey:kContinuitySpecial];
    [dic setObject:aNews.recomInfo forKey:kRecomInfo];
    
    if([aNews.newsType isEqualToString:kNewsTypeGroupPhoto])
        [dic setObject:kContinuityPhoto forKey:kContinuityType];
    else if([aNews.newsType isEqualToString:kNewsTypeWeibo])
        [dic setObject:kContinuityWeibo forKey:kContinuityType];
    else if([aNews.newsType isEqualToString:kNewsTypeSpecialNews])
    {
//        [[SNDBManager currentDataBase] markRollingNewsListItemAsReadByChannelId:aNews.channelId newsId:aNews.newsId];
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:aNews.newsId ChannelId:aNews.channelId];
        [dic setObject:kContinuitySpecial forKey:kContinuityType];
    }
    else
        [dic setObject:kContinuityNews forKey:kContinuityType];

    [dic setObject:self.allList forKey:kNewsListAll]; //新加字段，标示全部新闻
    return dic;
}


-(NSMutableDictionary*)getSpecialContentDictionary:(SNSpecialNews*)aSpecailNews
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:aSpecailNews.termId forKey:kTermId];
    [userInfo setObject:aSpecailNews.newsId forKey:kNewsId];
    [userInfo setObject:kNewsOnline forKey:kNewsMode];
    [userInfo setObject:self.snModel forKey:kNewsModel];
    [userInfo setObject:kReferFromSpecialNews forKey:kReferFrom];
    [userInfo setObject:aSpecailNews.link forKey:kLink];
    
    NSMutableDictionary* photoInfo = [userInfo mutableCopy];
    [photoInfo setObject:[NSNumber numberWithInt:GallerySourceTypeGroupPhoto] forKey:kGallerySourceType];
    [photoInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS] forKey:kMyFavouriteRefer];
    [photoInfo setValue:[NSString stringWithFormat:@"%d",NEWS_ITEM_TYPE_GROUP_PHOTOS] forKey:kType];
    [photoInfo setObject:aSpecailNews.link forKey:kLink];
    if (self.photoNewsIds != nil && [self.photoNewsIds count]>0)
        [photoInfo setObject:self.photoNewsIds forKey:kNewsList];
    
    NSMutableDictionary* newsInfo = [userInfo mutableCopy];
    [newsInfo setValue:[NSString stringWithFormat:@"%d",NEWS_ITEM_TYPE_NORMAL] forKey:kType];
    if (self.excludePhotoNewsIds != nil && [self.excludePhotoNewsIds count]>0)
        [newsInfo setObject:self.excludePhotoNewsIds forKey:kNewsList];
    
    /*
    NSMutableDictionary* weibo = [SNUtility parseProtocolUrl:aSpecailNews.link schema:kProtocolWeibo];
    if (weibo && [weibo objectForKey:@"rootId"]) {
        [weibo setObject:[weibo objectForKey:@"rootId"] forKey:kWeiboId];
    }*/
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:newsInfo forKey:kContinuityNews];
    [dic setObject:photoInfo forKey:kContinuityPhoto];
    //[dic setObject:weibo forKey:kContinuityWeibo];
    
    if(self.allNewsIds != nil) {
        [dic setObject:self.allNewsIds forKey:kSpecailNewsListAll];
    }
    
    if([kSNGroupPhotoNewsType isEqualToString:aSpecailNews.newsType])
        [dic setObject:kContinuityPhoto forKey:kContinuityType];
    //else if ([kSNVoteWeiwenType isEqualToString:aSpecailNews.newsType])
    //    [dic setObject:kContinuityWeibo forKey:kContinuityType];
    else
        [dic setObject:kContinuityNews forKey:kContinuityType];
    
    return dic;
}

+(NSMutableDictionary*)getContentRecommandDictionary:(NSDictionary*)aDic
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:aDic forKey:kContinuityNews];
    [dic setObject:kContinuityNews forKey:kContinuityType];
    return dic;
}

+(NSMutableDictionary*)getPhotoListRecommandDictionary:(NSDictionary*)aDic
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:aDic forKey:kContinuityPhoto];
    [dic setObject:kContinuityPhoto forKey:kContinuityType];
    return dic;
}
@end
