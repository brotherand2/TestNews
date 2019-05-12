//
//  SNRollingNewsTableViewDelegate.m
//  sohunews
//
//  Created by chenhong on 14-3-12.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsTableViewDelegate.h"
#import "SNRollingNewsModel.h"
#import "SNRollingNewsTableController.h"
#import "SNNewsSectionTitleView.h"
#import "NSCellLayout.h"
#import "SNRollingNewsModel+preload.h"
#import "SNNewsPreloader.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNRollingNewsPublicManager.h"
#import "SNRollingNewsFunnyTextCell.h"
#import "SNNewsAd+analytics.h"

@implementation SNRollingNewsTableViewDelegate

- (BOOL)isModelEmpty {
    SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
    BOOL hasNoCache = rollingModel.rollingNews.count == 0;
    
    //首页无缓存时，重置请求打开
    if (hasNoCache && [rollingModel isHomeEidtPage]) {
        [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
    }
    
    return hasNoCache;
}

- (BOOL)isHomeChannel {
    SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
    BOOL isHome = [rollingModel isHomePage];
    return isHome;
}

- (BOOL)isNewHomeChannel{
    SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
    BOOL isHome = [rollingModel isNewHomePage];
    return isHome;
}

- (BOOL)isRecomendNewChannel{
    SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
    return rollingModel.isRecomendNewChannel;
}

- (BOOL)shouldReloadLocalWithChannelId:(NSString *)channelId {
    SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
    
    if (![rollingModel.channelId isEqualToString:channelId]) {
        return YES;
    }
    else if (rollingModel.rollingNews.count == 0) {
        return YES;
    }
    
    return NO;
}

- (void)startFetchDataInWifi {
    SNRollingNewsModel *model = (SNRollingNewsModel *)_model;
    // 取消之前频道的预加载任务
    [[SNNewsPreloader sharedLoader] cancelAllWifiDownloadOperations];

    // wifi下自动加载 不考虑频道订阅里面的新闻
    [model fetchNewsContentData];
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kNewUserGuideHadBeenShown]) {
//        [model fetchNewsContentData];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
    if (newsModel.isSection && section < [newsModel.sectionsArray count]) {
        NSString *sectionTitle = [newsModel.sectionsArray objectAtIndex:section];
        return sectionTitle ? NEWS_SECTION_HEIGHT:0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
    if (newsModel.isSection && section < [newsModel.sectionsArray count]) {
        NSString *sectionTitle = [newsModel.sectionsArray objectAtIndex:section];
        if (sectionTitle) {
            CGRect titleViewRect = CGRectMake(0,0,tableView.bounds.size.width,NEWS_SECTION_HEIGHT);
            SNNewsSectionTitleView *newsSectionTitleView = [[SNNewsSectionTitleView alloc] initWithFrame:titleViewRect
                                                                                                    title:sectionTitle];
            return newsSectionTitleView;
        }
    }
    
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(item)]) {
        id itemObj = [cell performSelector:@selector(item)];
        if ([itemObj respondsToSelector:@selector(news)]) {
            id newsItem = [itemObj performSelector:@selector(news)];
            [SNStatisticsInfoAdaptor cacheTimelineNewsShowBusinessStatisticsInfo:newsItem];

            SNRollingNewsDataSource * newsDataSource = (SNRollingNewsDataSource *)(tableView.dataSource);
            
//            if ([newsItem respondsToSelector:@selector(video)]) {
//                id adVideo = [newsItem performSelector:@selector(video)];
//                if (adVideo && [cell respondsToSelector:@selector(didDisplay)]) {
//                    [cell performSelector:@selector(didDisplay)];
//                }//didDisplay函数中什么都没做？？？所以注掉。
//            }
            if ([newsItem respondsToSelector:@selector(topAdNews)]) { //本地频道四个button置顶广告展示上报，数据结构特殊，所以单独处理
                id topAdNews = [newsItem performSelector:@selector(topAdNews)];
                if ([topAdNews isKindOfClass:[NSArray class]]) {
                    for (SNRollingNews *adNews in topAdNews) {
                        [adNews.newsAd performSelector:@selector(reportAdOneDisplay:) withObject:adNews];
                    }
                }
            }
            if ([newsItem respondsToSelector:@selector(newsAd)]) {//是信息流广告
                id newsAdObj = [newsItem performSelector:@selector(newsAd)];
                if ([newsAdObj isKindOfClass:[SNNewsAd class]]) {
                    if (!newsDataSource.newsModel.isCacheModel) {
                        [newsAdObj performSelector:@selector(reportAdOneDisplay:) withObject:newsItem];
                    }else{
                        if ([newsItem isKindOfClass:[SNRollingNews class]]) {
                            SNRollingNews * rollingNews = (SNRollingNews *)newsItem;
//                            if ([rollingNews.channelId isEqualToString:@"1_recom"] && rollingNews.isAvailableRecomForAD) {
                             if (rollingNews.isAvailableRecomForAD) {
                                rollingNews.isAvailableRecomForAD = NO;
                                [newsAdObj performSelector:@selector(reportAdOneDisplay:) withObject:newsItem];
                            }
                        }
                    }

                }
             }
            // 流内冠名展示上报
            if ([newsItem respondsToSelector:@selector(sponsorshipsObject)]) {
                id newsAdSponsorship = [newsItem performSelector:@selector(sponsorshipsObject)];
                if ([newsAdSponsorship respondsToSelector:@selector(reportSponsorShipOneDisplay:)]
//                    && !newsDataSource.newsModel.isCacheModel
                    ) {
                    if (!newsDataSource.newsModel.isCacheModel) {
                        [newsAdSponsorship performSelector:@selector(reportSponsorShipOneDisplay:) withObject:newsItem];
                    }else{
                        if ([newsItem isKindOfClass:[SNRollingNews class]]) {
                            SNRollingNews * rollingNews = (SNRollingNews *)newsItem;
//                            if ([rollingNews.channelId isEqualToString:@"1_recom"] && rollingNews.isAvailableRecomForAD) {
                             if (rollingNews.isAvailableRecomForAD) {
                                rollingNews.isAvailableRecomForAD = NO;
                                [newsAdSponsorship performSelector:@selector(reportSponsorShipOneDisplay:) withObject:newsItem];
                            }
                        }
                    }
                    
                }
            }
        }
    }
    if ([cell respondsToSelector:@selector(reportPopularizeStatExposureInfo)]) {
        [cell performSelector:@selector(reportPopularizeStatExposureInfo)];
    }
    
    if ([cell isKindOfClass:[SNRollingNewsFunnyTextCell class]]) {
        SNRollingNewsFunnyTextCell * funnyTextCell = (SNRollingNewsFunnyTextCell *)cell;
        funnyTextCell.tableView = tableView;
        funnyTextCell.indexPath = indexPath;
    }
    
//    if ([cell isKindOfClass:[SNRollingNewsBookShelfCell class]]) {
//        SNRollingNewsBookShelfCell * bookShelfCell = (SNRollingNewsBookShelfCell *)cell;
//        bookShelfCell.tableView = tableView;
//    }@qz 2017.4 书架不用了
}

@end
