//
//  SNRollingNewsSubscribeDataSource.m
//  sohunews
//
//  Created by lhp on 10/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingNewsSubscribeDataSource.h"
#import "CacheObjects.h"
#import "SNRollingNewsTableItem.h"
#import "SNRollingNewsSubscribeItem.h"
#import "SNRollingSubscribeSpaceItem.h"
#import "SNRollingAddSubscribeItem.h"
#import "SNRollingCellHelp.h"
#import "SNRollingNewsMySubscribeCell.h"
#import "SNRollingAddSubscribeCell.h"
#import "SNRollingSubscribeBottomCell.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNRollingEmptyViewItem.h"
#import "SNRollingEmptyViewCell.h"
#import "SNRollingRecommentViewItem.h"
#import "SNRollingRecommentViewCell.h"
#import "SNRollingSubscribeRecomItem.h"
#import "SNRollingSubscribeRecomCell.h"
#import "SNTableAutoLoadMoreCell.h"
#import "SNTableMoreButton.h"

@implementation SNRollingNewsSubscribeDataSource

- (id)initWithChannelId:(NSString *)channelId
{
    if (self = [super init]) {
        self.newsModel = [[SNSubscribeNewsModel alloc] initWithChannelId:channelId];
        self.items = [NSMutableArray array];
    }
    return self;
}

- (id<TTModel>)model
{
    return _newsModel;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView
{
    [self.items removeAllObjects];
    [self addAdInfo];
    [self addMoreSubscribe];
    [self addSubscribeInfo];
//    [self addRecommentSubscribeInfo];
    [self.myConcernController showFollowingEmpty:self.newsModel.isEmpty];
}

- (SNRollingNewsTableItem *)createNewsItemWithNews:(SNRollingNews *) news
{
    SNRollingNewsTableItem *tItem = [[SNRollingNewsTableItem alloc] init];
    tItem.news = news;
    return tItem;
}

- (void)addAdInfo
{
    if ([_newsModel.adArray count] > 0) {
        SCSubscribeAdObject *adObject = [_newsModel.adArray objectAtIndex:0];
        SNRollingNews *adNews = [[SNRollingNews alloc] init];
        adNews.title = adObject.adName;
        adNews.picUrl = adObject.adImage;
        adNews.link = adObject.refLink;
        @autoreleasepool {
            SNRollingNewsTableItem *newsItem = [self createNewsItemWithNews:adNews];
            newsItem.type = NEWS_ITEM_TYPE_AD;
            newsItem.isSubscribeAd = YES;
            newsItem.cellType = SNRollingNewsCellTypeFocus;
            newsItem.subscribeAdObject = adObject;
            [self.items addObject:newsItem];
        }

        //添加订阅推广位加载统计
        [SNStatisticsInfoAdaptor uploadSubPopularizeLoadInfo:_newsModel.adArray];
    }
}

- (void)addMoreSubscribe
{
//    SNRollingAddSubscribeItem *addSubscribeItem = [[SNRollingAddSubscribeItem alloc] init];
//    [self.items addObject:addSubscribeItem];
    
}

- (void)addSubscribeInfo
{
    if (_newsModel.subscribeArray.count == 0) {
        return;
    }
    for (SCSubscribeObject *subscribeObject in _newsModel.subscribeArray) {
        SNRollingNewsSubscribeItem *subscribeItem = [[SNRollingNewsSubscribeItem alloc] init];
        subscribeItem.subscribeObject = subscribeObject;
        [self.items addObject:subscribeItem];
        
        for (NSDictionary *newsDic in subscribeObject.topNewsArray) {
            SNRollingNews *topNews = [[SNRollingNews alloc] init];
            topNews.title = [newsDic objectForKey:kTitle];
            topNews.link = [newsDic objectForKey:kLink];
            topNews.updateTime = [newsDic objectForKey:kPublishTime];
            
            if ([[newsDic objectForKey:kListPics] isKindOfClass:[NSArray class]]) {
                topNews.picUrls = [newsDic objectForKey:kListPics];
                if ([topNews.picUrls count]) {
                    topNews.picUrl = [topNews.picUrls objectAtIndex:0];
                }
            }
            @autoreleasepool {
                SNRollingNewsTableItem *newsItem = [self createNewsItemWithNews:topNews];
                newsItem.type = NEWS_ITEM_TYPE_SUBSCRIBE_NEWS;
                newsItem.cellType = topNews.picUrl.length > 0 ? SNRollingNewsCellTypeDefault : SNRollingNewsCellTypeAbstrac;
                [self.items addObject:newsItem];
            }
        }
    }
    if (!_newsModel.hasNoMore && self.items.count > 0 && [[SNUtility getApplicationDelegate] isNetworkReachable]) {
        SNTableMoreButton *moreBtn = [SNTableMoreButton itemWithText:NSLocalizedString(@"Loading...", @"Loading...")];
        moreBtn.model = self.model;
        [self.items addObject:moreBtn];
    }

//    SNRollingSubscribeSpaceItem *spaceItem = [[SNRollingSubscribeSpaceItem alloc] init];
//    [self.items addObject:spaceItem];
    
}

- (void)addRecommentSubscribeInfo
{
    if (_newsModel.recomSubscribeArray.count == 0) {
        if (_newsModel.subscribeArray.count == 0) {
            SNRollingEmptyViewItem *emptyViewItem = [[SNRollingEmptyViewItem alloc] init];
            [self.items addObject:emptyViewItem];
        }
        return;
    }
    SNRollingRecommentViewItem *recommentViewItem = [[SNRollingRecommentViewItem alloc] init];
    [self.items addObject:recommentViewItem];

    for (SCSubscribeObject *subscribeObject in _newsModel.recomSubscribeArray) {
        SNRollingSubscribeRecomItem *subscribeItem = [[SNRollingSubscribeRecomItem alloc] init];
        subscribeItem.subscribeObject = subscribeObject;
        [self.items addObject:subscribeItem];
        
        for (NSDictionary *newsDic in subscribeObject.topNewsArray) {
            SNRollingNews *topNews = [[SNRollingNews alloc] init];
            topNews.title = [newsDic objectForKey:kTitle];
            topNews.link = [newsDic objectForKey:kLink];
            topNews.updateTime = [newsDic objectForKey:kPublishTime];
            
            if ([[newsDic objectForKey:kListPics] isKindOfClass:[NSArray class]]) {
                topNews.picUrls = [newsDic objectForKey:kListPics];
                if ([topNews.picUrls count]) {
                    topNews.picUrl = [topNews.picUrls objectAtIndex:0];
                }
            }
            @autoreleasepool {
                SNRollingNewsTableItem *newsItem = [self createNewsItemWithNews:topNews];
                newsItem.cellType = topNews.picUrl.length > 0 ? SNRollingNewsCellTypeDefault : SNRollingNewsCellTypeAbstrac;
                [self.items addObject:newsItem];
            }
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[TTTableViewCell class]]) {
        id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
        [cell setObject:object];
    }
    
    id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    if ([object isKindOfClass:[SNRollingSubscribeRecomItem class]]) {
        SNRollingSubscribeRecomItem *item = (SNRollingSubscribeRecomItem *)object;
        
        if (item.subscribeObject.subId) {
            [SNStatisticsInfoAdaptor cacheRecomSubscribeShowBusinessStatisticsInfo:item.subscribeObject];
        }
    }
    return cell;
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:SNRollingNewsTableItem.class]) {
        SNRollingNewsTableItem *item = (SNRollingNewsTableItem *)object;
        if (item.cellType == SNRollingNewsCellTypeFocus) {
            return [SNRollingNewsFocusCell class];
        }
        object = nil;
//        SNRollingNewsTableItem *item = (SNRollingNewsTableItem *)object;
//        switch (item.cellType) {
//            case SNRollingNewsCellTypeDefault:
//                return [SNRollingNewsTableCell class];
//            case SNRollingNewsCellTypeTitle:
//                return [SNRollingNewsTitleCell class];
//            case SNRollingNewsCellTypeAbstrac:
//                return [SNRollingNewsAbstractCell class];
//            case SNRollingNewsCellTypeFocus:
//                return [SNRollingNewsFocusCell class];
//            default:
//                return [SNRollingNewsAbstractCell class];
//        }
    } else if ([object isKindOfClass:[SNRollingEmptyViewItem class]]) {
        return [SNRollingEmptyViewCell class];
    } else if ([object isKindOfClass:[SNRollingNewsSubscribeItem class]]) {
        return [SNRollingNewsMySubscribeCell class];
    } else if ([object isKindOfClass:[SNRollingAddSubscribeItem class]]) {
        return [SNRollingAddSubscribeCell class];
    } else if ([object isKindOfClass:[SNRollingSubscribeSpaceItem class]]) {
        return [SNRollingSubscribeBottomCell class];
    } else if ([object isKindOfClass:[SNRollingRecommentViewItem class]]) {
        return [SNRollingRecommentViewCell class];
    } else if ([object isKindOfClass:[SNRollingSubscribeRecomItem class]]) {
        return [SNRollingSubscribeRecomCell class];
    } else if ([object isKindOfClass:[SNTableMoreButton class]]) {
        return [SNTableAutoLoadMoreCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}

- (void)dealloc
{
    self.newsModel = nil;
    self.myConcernController = nil;
}

@end
