//
//  SNRollingNewsDataSource.m
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//


#import "SNRollingNewsDataSource.h"
#import "SNRollingNews.h"
#import "SNRollingNewsTableItem.h"
#import "SNPromotionTableItem.h"
#import "SNTableMoreButton.h"
#import "SNTableAutoLoadMoreCell.h"
#import "SNCommonNewsDatasource.h"
#import "UITableViewCell+ConfigureCell.h"
#import "SNUserLocationManager.h"
#import "SNRollingCellHelp.h"
#import "SNRollingLoadMoreItem.h"
#import "SNRollingAddStockCell.h"
#import "SNRollingNewsRefreshCell.h"
#import "SNRollingPageViewCell.h"
#import "SNRollingAdIndividuationCell.h"
#import "SNRollingRedPacketCell.h"
#import "SNRollingNewsFunnyTextCell.h"
#import "SNRollingNewsVideoCell.h"
#import "SNRollingNewsSohuLiveCell.h"
#import "SNAutoPlayVideoStyleTwoCell.h"
#import "SNRollingNewsHotWrodsCell.h"
#import "SNRollingSohuFeedPhotoCell.h"
#import "SNRollingSohuFeedBigPicCell.h"
//书籍相关
#import "SNRollingNewsBookCell.h"
#import "SNBookShelfRecommendClassificationLabelCell.h"
#import "SNBookShelfRecommendBannerCell.h"
#import "SNNovelUtilities.h"
#import "NSAttributedString+Attributes.h"
#import "SNSubRollingNewsModel.h"
#import "SNRollingTrainFocusCell.h"
#import "SNRollingTrainCardsCell.h"
#import "SNRollingNewsTitleTopCell.h"
#import "SNRollingNewsTableTopCell.h"
#import "SNRollingNewsHistoryLineCell.h"

@implementation SNRollingNewsDataSource

- (id)initWithChannelId:(NSString *)channelId {
	if (self = [super init]) {
		_newsModel = [[SNRollingNewsModel alloc] initWithChannelId:channelId];
	}
	return self;
}

- (id)initWithChannelId:(NSString *)channelId channelName:(NSString *)channelName {
    if (self = [super init]) {
        _newsModel = [[SNRollingNewsModel alloc] initWithChannelId:channelId];
        _newsModel.channelName = channelName;
        _exposureDictiongary = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}

- (id)initWithChannelId:(NSString *)channelId channelName:(NSString *)channelName isMixStream:(int)isMixStream{
    if (self = [super init]) {
        if (isMixStream == NewsChannelEditAndRecom) {
            _newsModel = [[SNSubRollingNewsModel alloc] initWithChannelId:channelId];
        }
        else{
            _newsModel = [[SNRollingNewsModel alloc] initWithChannelId:channelId];
        }
        
        _newsModel.channelName = channelName;
        _exposureDictiongary = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}

- (id)initWithChannelId:(NSString *)channelId lastMinTimeline:(NSString *)lastMinTimeline {
	if (self = [super init]) {
		_newsModel = [[SNRollingNewsModel alloc] initWithChannelId:channelId];
        _newsModel.timelineWhenViewReleased=lastMinTimeline;
	}
	return self;
}

- (id<TTModel>)model {
	return _newsModel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[TTTableViewCell class]]) {
        id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
        [cell setObject:object];
    }
    
    id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    if ([object isKindOfClass:[SNRollingNewsTableItem class]]) {
        SNRollingNewsTableItem *item = (SNRollingNewsTableItem *)object;
        if (item.news.newsId && item.news.link) {
            @autoreleasepool {
                NSString *exposurLink = [item.news.link stringByAppendingString:@"&exposureFrom=1"];
                if (_newsModel.isLoadRecommend) {
                    exposurLink = [item.news.link stringByAppendingString:@"&exposureFrom=3"];
                }
                if (item.news.templateType.length > 0) {
                    exposurLink = [exposurLink stringByAppendingFormat:@"&templateType=%@",item.news.templateType];
                }
                NSMutableDictionary *newsInfo = [NSMutableDictionary dictionary];
                [newsInfo setValue:exposurLink forKey:item.news.newsId];
                [_exposureDictiongary addEntriesFromDictionary:newsInfo];
            }
        }
    }
    
    return cell;
}

- (SNRollingNewsTableItem *)createNewsItemWithNews:(SNRollingNews *)news {
    @autoreleasepool {
        SNRollingNewsTableItem *tItem = [[SNRollingNewsTableItem alloc] init];
        tItem.news = news;
        tItem.newsModel = _newsModel;
        tItem.controller = self.controller;
        tItem.dataSource = _data;
        tItem.isRecommend = [news isRecomNews];
        tItem.expressFrom = [news isRecomNews] ? NewsFromRecommend : NewsFromChannel;
        tItem.expressFrom = _newsModel.isFromSub ? NewsFromChannelSubscribe : tItem.expressFrom;
        [tItem setItemNewsType];
        [tItem setItemCellTypeWithTemplate];
        
        Class cellClass = [self tableView:nil cellClassForObject:tItem];
        if ([cellClass
             respondsToSelector:@selector(calculateCellHeight:)]) {
            [cellClass calculateCellHeight:tItem];
        }
        return tItem;
    }
}

- (void)tableViewDidLoadModel:(UITableView *)tableView {
    //关闭之前弹出的更多View
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:YES];
    
    _isEdit = YES;
    NSInteger count = _newsModel.rollingNews.count;

    self.data = nil;
    self.data = [[SNCommonNewsDatasource alloc] init];
    self.data.newsModel = _newsModel;
    self.data.isFromSub = _newsModel.isFromSub;

    NSMutableArray *newsIds = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *gIds = [NSMutableArray array];
    NSMutableArray *liveIds = [NSMutableArray array];
    NSMutableArray *specialIds = [NSMutableArray array];
    NSMutableArray *weiboIds = [NSMutableArray array];
    NSMutableArray *tableItems = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *focusIds = [NSMutableArray arrayWithCapacity:5];//焦点图最多5个
    
    for (int i = 0; i < count; i++) {
        @autoreleasepool {
            SNRollingNews *news = [_newsModel.rollingNews objectAtIndex:i];
            
            //by 5.9.4 wangchuanwen modify
            //cell分割线是否显示处理
            [self dealHiddenLineWithNews:news];
            //modify end
           
            if ([news isLoadMore]) {
                SNRollingLoadMoreItem *loadMoreItem = [[SNRollingLoadMoreItem alloc] init];
                loadMoreItem.news = news;
                loadMoreItem.dataSource = self;
                [tableItems addObject:loadMoreItem];
                
                //by 5.9.4 wangchuanwen modify
                if (i > 0) {//如果是@"展开，继续看今日要闻"，其上一个cell不显示分割线
                    SNRollingNews *news = [_newsModel.rollingNews objectAtIndex:i-1];
                    news.hiddenLine = YES;
                }
                //modify end
            } else {
                //@qz 小说适配新的小说页面 2017.4
                if (news.templateType.integerValue == 139) {
                    continue;
                }
                
                //by 5.9.4 wangchuanwen modify
                if ([news.templateType isEqualToString:@"201"] || [news.templateType isEqualToString:kTemplateTypeRollingNewsHistoryLine]) {
                    //如果是@"上次看到这里，点击刷新"，其上一个cell不显示分割线
                    if (i > 0) {
                        SNRollingNews *news = [_newsModel.rollingNews objectAtIndex:i-1];
                        news.hiddenLine = YES;
                    }
                }
                //modify end
                
                SNRollingNewsTableItem *tItem = [self createNewsItemWithNews:news];
                tItem.photoList = gIds;
                tItem.newsList = newsIds;
                tItem.specailList = specialIds;
                tItem.liveList = liveIds;
                tItem.focusList = focusIds;
                self.data.photoList = gIds;
                self.data.newsList = newsIds;
                self.data.specailList = specialIds;
                self.data.weiboList = weiboIds;
                
                if (!news.newsId) {
                    continue;
                }
                
                if ([news.newsType isEqualToString:kNewsTypePhotoAndText]
                    || [news.newsType isEqualToString:kNewsTypeVoteNews]) {
                    [newsIds addObject:news.newsId];
                } else if([news.newsType isEqualToString:kNewsTypeGroupPhoto])
                {
                    [gIds addObject:news.newsId];
                } else if ([news.newsType isEqualToString:kNewsTypeSpecialNews])
                {
                    [specialIds addObject:news.newsId];
                } else if ([news.newsType isEqualToString:kNewsTypeLive])
                {
                    [liveIds addObject:news.newsId];
                }
                if ([news isMoreFocusNews] && news.newsFocusArray.count != 0) {
                    for (SNRollingNews *focusItem in news.newsFocusArray) {
                        if (!focusItem.newsId) {
                            continue;
                        }
                        [focusIds addObject:focusItem.newsId];
                        if ([focusItem.newsType isEqualToString:kNewsTypeGroupPhoto]) {
                            if (![gIds containsObject:focusItem.newsId]) {
                                [gIds addObject:focusItem.newsId];
                            }
                        }
                    }
                }
                
                self.data.allList = tableItems;
                [tableItems addObject:tItem];
            }
        }
    }
	
    if ([_newsModel.rollingNews count] > 0) {
        SNRollingNews *lastItem = (SNRollingNews *)[_newsModel.rollingNews lastObject];
        self.controller.currentMinTimeline = [lastItem timelineIndex];
    }
    
    self.items = [NSMutableArray array];
    [self.items addObjectsFromArray:tableItems];

    if (!_newsModel.hasNoMore && self.items.count > 0) {
        SNTableMoreButton *moreBtn = [SNTableMoreButton itemWithText:NSLocalizedString(@"Loading...", @"Loading...")];
        moreBtn.model = self.model;
        [self.items addObject:moreBtn];
    }
    
    self.isEdit = NO;
}

#pragma 是否隐藏cell分割线
- (void)dealHiddenLineWithNews:(SNRollingNews *)news {
    //小说，焦点图不需要分割线
    if ([news.channelId isEqualToString:@"960415"] || [news.channelId isEqualToString:@"13555"] || [news.title isEqualToString:[SNNovelUtilities shelfDataTitle]] || [news.templateType isEqualToString:@"28"] ||[news.templateType isEqualToString:@"5"] || [news.templateType isEqualToString:@"25"] || [news.templateType isEqualToString:@"21"] || [news.templateType isEqualToString:@"202"]|| [news.templateType isEqualToString:kTemplateTypeRollingNewsHistoryLine] ) {
        news.hiddenLine = YES;
    } else {
        news.hiddenLine = NO;
    }
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
	if ([object isKindOfClass:SNRollingNewsTableItem.class]) {
        SNRollingNewsTableItem *item = (SNRollingNewsTableItem *)object;
        //新版本特殊处理要闻和推荐的置顶
        if ([SNNewsFullscreenManager newsChannelChanged] && [item.news showNewTopArea]) {
            return [item hasImage] ? [SNRollingNewsTableTopCell class] : [SNRollingNewsTitleTopCell class];
        }
        
        switch (item.cellType) {
            case SNRollingNewsCellTypeDefault:
                return [SNRollingNewsTableCell class];
            case SNRollingNewsCellTypeTitle:
                return [SNRollingNewsTitleCell class];
            case SNRollingNewsCellTypeAbstrac:
                return [SNRollingNewsAbstractCell class];
            case SNRollingNewsCellTypeWeather:
                return [SNRollingWeatherCell class];
            case SNRollingNewsCellTypePhotos:
                return [SNRollingPhotoNewsTableCell class];
            case SNRollingNewsCellTypeAppArray:
                return [SNRollingNewsAppArrayCell class];
            case SNRollingNewsCellTypeVideo:
            case SNRollingNewsCellTypeAdVideoDownload:
                return [SNRollingVideoCell class];
            case SNRollingNewsCellTypeNewsVideo:
                return [SNRollingNewsVideoCell class];
            case SNRollingNewsCellTypeMatch:
                return [SNRollingMatchCell class];
            case SNRollingNewsCellTypeFinance:
                return [SNRollingFinanceCell class];
            case SNRollingNewsCellTypeCommon:
                return [SNRollingPublicCell class];
            case SNRollingNewsCellTypeFocus:
            case SNRollingNewsCellTypeFocusAd:
                return [SNRollingNewsFocusCell class];
            case SNRollingNewsCellTypeFocusWeather:
                return [SNRollingWeatherPhotoCell class];
            case SNRollingNewsCellTypeAdDefault: {
                if ([item hasImage]) {
                    return [SNRollingNewsTableCell class];
                } else {
                    return [SNRollingNewsAbstractCell class];
                }
            }
            case SNRollingNewsCellTypeAdPicture:
                return [SNRollingNewsPictureCell class];
            case SNRollingNewsCellTypeAdBanner:
                return [SNRollingNewsAdBannerCell class];
            case SNRollingNewsCellTypeIndividuation:
                return [SNRollingIndividuationCell class];
            case SNRollingNewsCellTypeTopic:
                return [SNRollingNewsTopicCell class];
            case SNRollingNewsCellTypeAppAd:
                return [SNRollingAdAppCell class];
            case SNRollingNewsCellTypeFocusHouse:
                return [SNRollingLocalFocusCell class];
            case SNRollingNewsCellTypeFocusLocal:
                return [SNRollingHouseFocusCell class];
            case SNRollingNewsCellTypeAdStock:
                return [SNRollingAddStockCell class];
            case SNRollingNewsCellTypeChangeCity:
                return [SNRollingAddStockCell class];
            case SNRollingNewsCellTypeCityScanAndTickets:
                return [SNRollingAddStockCell class];
            case SNRollingNewsCellTypeRefresh:
                return [SNRollingNewsRefreshCell class];
            case SNRollingNewsCellTypeMoreFoucs:
                return [SNRollingPageViewCell class];
            case SNRollingNewsCellTypeFullScreenFocus:
                return [SNRollingTrainFocusCell class];
            case SNRollingNewsCellTypeTrainCard:
                return [SNRollingTrainCardsCell class];
            case SNRollingNewsCellTypeRedPacket:
                return [SNRollingRedPacketCell class];
            case SNRollingNewsCellTypeRedPacketTip:
                return [SNRollingNewsTopicCell class];
            case SNRollingNewsCellTypeCoupons:
                return [SNRollingRedPacketCell class];
            case SNRollingNewsCellTypeSohuLive:
                return [SNRollingNewsSohuLiveCell class];
            case SNRollingNewsCellTypeRecomendItemTagType:
                return [SNRollingNewsHotWrodsCell class];
            case SNRollingNewsCellTypeAutoVideoMidImageType:
                return [SNAutoPlayVideoStyleTwoCell class];
            case SNRollingNewsCellTypeAdPhotos:
                return [SNRollingPhotoNewsTableCell class];
            case SNRollingNewsCellTypeBook:
                return [SNRollingNewsBookCell class];
            case SNRollingNewsCellTypeBookLabel://书籍标签模板
                return [SNBookShelfRecommendClassificationLabelCell class];
            case SNRollingNewsCellTypeBookBanner://书籍banner模板
                return [SNBookShelfRecommendBannerCell class];
            case SNRollingNewsCellTypeAdMixpicDownload:
            case SNRollingNewsCellTypeAdMixpicPhone:
                return [SNRollingPhotoNewsTableCell class];
            case SNRollingNewsCellTypeAdBigpicDownload:
            case SNRollingNewsCellTypeAdBigpicPhone:
                return [SNRollingNewsPictureCell class];
            case SNRollingNewsCellTypeAdSmallpicDownload:
                return [SNRollingNewsTableCell class];
            case SNRollingNewsCellTypeSohuFeedPhotos:
                return [SNRollingSohuFeedPhotoCell class];
            case SNRollingNewsCellTypeSohuFeedBigPic:
                return [SNRollingSohuFeedBigPicCell class];
            case SNRollingNewsCellAdIndividuation:
                return [SNRollingAdIndividuationCell class];
            case SNRollingNewsCellTypeHistoryLine:
                return [SNRollingNewsHistoryLineCell class];
            default:
                return [SNRollingNewsAbstractCell class];
        }
	} else if ([object isKindOfClass:[TTTableMoreButton class]]) {
		return [SNTableAutoLoadMoreCell class];
    } else if ([object isKindOfClass:[SNRollingLoadMoreItem class]]) {
        return [SNRollingLoadMoreCell class];
    }
	return [super tableView:tableView cellClassForObject:object];
}

- (void)dealloc {
    self.newsModel = nil;
    self.data = nil;
    self.exposureDictiongary = nil;
	
}

- (UIImage *)imageForEmpty {
	return [UIImage imageNamed:@"tb_empty_bg.png"];
}

- (NSString *)titleForEmpty {
	return NSLocalizedString(@"NoRollingNews", @"");
}

- (NSString *)subtitleForEmpty {
	return NSLocalizedString(@"RefreshRollingNews", @"");
}

- (UIImage *)imageForError:(NSError *)error {
    return [UIImage imageNamed:@"tb_error_bg.png"];
}

- (NSString *)titleForError:(NSError *)error {
    return nil;
}

- (NSString *)subtitleForError:(NSError*)error {
    return nil;
}

@end
