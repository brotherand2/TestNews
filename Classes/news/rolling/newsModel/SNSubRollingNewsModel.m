//
//  SNSubRollingNewsModel.m
//  sohunews
//
//  Created by wangyy on 2017/10/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSubRollingNewsModel.h"
#import "SNRollingNewsTableItem.h"
#import "SNStatisticsInfoAdaptor.h"

@implementation SNSubRollingNewsModel

@synthesize contentToken = _contentToken;
@synthesize showHistoryLine = _showHistoryLine;
@synthesize curTrainCardId = _curTrainCardId;
@synthesize todayHistoryFinish = _todayHistoryFinish;
@synthesize hasHistoryData = _hasHistoryData;

- (void)load:(TTURLRequestCachePolicy)cachePolicy
        more:(BOOL)more {
    //下拉到指定页码后，从数据库读取历史数据
//    _page = [SNRollingNewsPublicManager sharedInstance].pageNum;
    _page = [SNRollingNewsPublicManager readRollingPageWithChannelId:self.channelId];

    if ((cachePolicy == TTURLRequestCachePolicyLocal) || (more == YES && _page >= [SNNewsFullscreenManager manager].newsPullTimes)) {
        _more = more;
        [self readCacheFromDatabase];
        return;
    }
    
    if (cachePolicy == TTURLRequestCachePolicyNetwork && more == YES) {
        if (self.hasHistoryData) {
            _more = more;
            [self readCacheFromDatabase];
            
            return;
        }
        [SNNewsFullscreenManager userNewsPullTimes:[SNNewsFullscreenManager manager].newsPullTimes - _page - 1];
    }
    
    //火车卡片加载中，加载频道流，火车请求cancel
    if (isLoadingNews && action == 3) {
        [self requestDidCancelLoad:nil];
    }
    [super load:cachePolicy more:more];
}

- (BOOL)loadMoreTrainNews:(NSString *)trainId
                 trainPos:(NSString *)trainPos
                  success:(SNTrainNetworkSuccessBlock)success
                  failure:(SNTrainNetworkFailureBlock)failure {
    if (![[SNUtility getApplicationDelegate] isCurrentNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        if (failure) {
            failure(nil);
        }
        return NO;
    }
    //不同火车卡片同时请求时
    if (isLoadingNews) {
        if (self.curTrainCardId != trainId) {
            [self cancel];
        }else{
            //避免同一火车多次重复请求
            return NO;
        }
    }
    self.curTrainCardId = trainId;
    action = 3;//火车横拉加载
    _more = YES;//递减timeline
    
    NSString *url = [NSString stringWithFormat:kUrlRollingNewsListJsonV6];
    url = [url stringByAppendingFormat:@"channelId=%@&", _channelId];
    NSString *urlParams = kUrlRollingNewsParamsV6;
    url = [url stringByAppendingFormat:urlParams, KPaginationNum, _page];
    url = [url stringByAppendingFormat:@"&trainId=%@", trainId];
    url = [url stringByAppendingFormat:@"&trainPos=%@", trainPos];
    
    [self loadNewsRequestWithUrl:url isSynch:YES topic:nil];
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    return YES;
}

- (void)requestDidFinishLoad{
    [super requestDidFinishLoad];
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
    if (action == 3) {
        if (self.failureBlock) {
            self.failureBlock(nil);
        }
        [super setRequestFinishedLoad];
    }
    else{
        [super request:request didFailLoadWithError:error];
    }
}

- (void)requestDidCancelLoad:(TTURLRequest *)request {
    if (action == 3) {
        if (self.failureBlock) {
            self.failureBlock(nil);
        }
        [super setRequestFinishedLoad];
    }
    else{
        [super requestDidCancelLoad:request];
    }
}

#pragma mark 新数据解析 原始数据 - 有效数据（写入数据库） - 展示数据

- (void)readCacheFromDatabase {
    NSString *timelineIndex = nil;
    int pageSize = KPaginationNum;
    
    NSNumber *timePoint = [NSNumber numberWithInt:[[SNUtility getTodayValidTime:6] timeIntervalSince1970]];
    BOOL later = YES;//当天6点以后的
    if (!_more) {
        [self.rollingNews removeAllObjects];
        
        NSArray *topNewsList = [[SNDBManager currentDataBase] getRollingNewsListNextPageByChannelId:self.channelId timelineIndex:nil form:kRollingNewsFormTop pageSize:pageSize dateTime:[NSDate nowDateToSysytemIntervalNumber] later:NO];
        
        for (RollingNewsListItem *item in topNewsList) {
            @autoreleasepool {
                SNRollingNews *news = [self createNewsByItem:item];
                [self.topNewsList addObject:news];
            }
        }
    } else {
        SNRollingNews *last = [self.rollingNews lastObject];
        timelineIndex = last ? last.timelineIndex : nil;
        
        NSInteger createDate = last.createAt;
        later = (createDate >= timePoint.integerValue || createDate == 0)? YES : NO;
        if (_page >= [SNNewsFullscreenManager manager].newsPullTimes && [SNNewsFullscreenManager getUserNewsPullTimes] != 0){
            later = NO;
        }
    }

    NSMutableArray *curRollingNewsLits = [NSMutableArray array];

    if (!self.showHistoryLine && !later) timelineIndex = nil; // 如果还没开始展示历史,取历史时只需createat一个字段限制
    //获取数据库推荐数据
    NSArray *newsList = [[SNDBManager currentDataBase] getRollingNewsListNextPageByChannelId:self.channelId timelineIndex:timelineIndex form:kRollingNewsFormRecommend pageSize:pageSize dateTime:timePoint later:later];
    
    if (newsList.count == 0 && later == YES) {
        self.todayHistoryFinish = YES;
        if (_page < [SNNewsFullscreenManager manager].newsPullTimes) {
            SNAppConfig *config = [[SNAppConfigManager sharedInstance] config];
            NSInteger configPullTimes = [config.appNewsSettingConfig getNewsPullTimes];
            
            if ([SNNewsFullscreenManager getUserNewsPullTimes] <= configPullTimes &&
                ([SNNewsFullscreenManager getUserNewsPullTimes] != 0 ||
                 ([SNNewsFullscreenManager getUserNewsPullTimes] == 0 && _page == 0)) && _more) {
                    self.hasHistoryData = NO;
                    [self load:TTURLRequestCachePolicyNetwork more:_more];
                    return;
            }
//            if ((!self.hasHistoryData || requestNet) && self.rollingNews.count > 0) {
//                //获取7次为了请求完的数据
//                BOOL more = (self.rollingNews.count > 0) ? YES : NO;
//                if (_more) {
//                    [SNNewsFullscreenManager userNewsPullTimes:[SNNewsFullscreenManager manager].newsPullTimes - _page -1];
//                }
//                [super load:TTURLRequestCachePolicyNetwork more:more];
//                return;
//            }
        }
        
        //获取当天6点以前的
        later = NO;
        if (!self.showHistoryLine) timelineIndex = nil; // 如果还没开始展示历史,取历史时只需createat一个字段限制
        newsList = [[SNDBManager currentDataBase] getRollingNewsListNextPageByChannelId:self.channelId timelineIndex:timelineIndex form:kRollingNewsFormRecommend pageSize:pageSize dateTime:timePoint later:later];
        if (newsList.count == 0) self.hasHistoryData = NO; // 历史看完,置为NO.
    }
    
    if (_more == YES &&
        newsList.count != 0 &&
        !later &&
        !self.showHistoryLine) {
        //计算加载的时间点
        SNRollingNews *last = [self.rollingNews lastObject];
        if (last.timelineIndex.length > 0) { // 加载历史前,记录下当天新闻的最小索引
//            [SNRollingNewsPublicManager sharedInstance].minTimelineIndex = [last.timelineIndex integerValue];
            [SNRollingNewsPublicManager saveRollingMinTimelineIndex:[last.timelineIndex integerValue] channelId:self.channelId];
        }
        SNRollingNews *first = [newsList firstObject];
        NSNumber *timeNumber = [NSDate nowDateToSysytemIntervalNumber];
        NSString *timeStr = [self getHistoryTimeStye:[timeNumber integerValue] time2:first.createAt];
        [curRollingNewsLits addObject:[self createHistoryLineItem:timeStr]];
        self.showHistoryLine = YES;
    }
   
    for (RollingNewsListItem *item in newsList) {
        @autoreleasepool {
            self.hasHistoryData = YES;
            
            SNRollingNews *news = [self createNewsByItem:item];
            if ([news isFullScreenFocusNewsItem]) {
                //获取焦点图数据
                NSArray *focusList = [[SNDBManager currentDataBase] getRollingFocusNewsListByChannelId:self.channelId trainCardId:news.trainCardId];
                for (RollingNewsListItem *subItem in focusList) {
                    @autoreleasepool {
                        SNRollingNews *subNews = [self createNewsByItem:subItem];
                        if (later == NO && [SNNewsFullscreenManager needTrainAnimation] && self.rollingNews.count > 0) {
                            //焦点图如果是今天前的历史，并且需要变火车
                            if ([subNews isFullScreenFocusNews] || [subNews isTowTopNews]) {
                                news.templateType = kTemplateTypeTrainCard;
                                if (news.newsItemArray == nil) {
                                    news.newsItemArray = [NSMutableArray array];
                                }
                                [news.newsItemArray addObject:subNews];
                            }
                        } else {
                            if ([subNews isFullScreenFocusNews]) {
                                if (news.newsFocusArray == nil) {
                                    news.newsFocusArray = [NSMutableArray array];
                                }
                                [news.newsFocusArray addObject:subNews];
                            } else if ([subNews isTowTopNews]) {
                                if (news.newsItemArray == nil) {
                                    news.newsItemArray = [NSMutableArray array];
                                }
                                [news.newsItemArray addObject:subNews];
                            }
                        }
                    }
                }
            }
            
            if ([news isTrainCardNewsItem] ||
                [news isFullScreenFocusNewsItem]) {
                //获取此火车的火车数据
                NSMutableArray *trainNewsList = [NSMutableArray arrayWithArray:[[SNDBManager currentDataBase] getRollingNewsListNextPageByChannelId:self.channelId timelineIndex:timelineIndex form:kRollingNewsFormTrainCard trainCardId:news.trainCardId]];
                for (RollingNewsListItem *subItem in trainNewsList) {
                    SNRollingNews *subNews = [self createNewsByItem:subItem];
                    if (news.newsItemArray == nil) {
                        news.newsItemArray = [NSMutableArray array];
                    }
                    [news.newsItemArray addObject:subNews];
                }
            }
            
            [curRollingNewsLits addObject:news];
        }
    }
    
    if (_more == YES) {
        if (curRollingNewsLits.count == 0) {
            if (self.hasHistoryData == YES && self.showHistoryLine) {
                [self.rollingNews addObject:[self createHistoryLineItem:@"历史记录已看完，以下为新内容"]];
                self.hasHistoryData = NO;
            }
            [SNNewsFullscreenManager userNewsPullTimes:INT_MAX];
            [SNNewsFullscreenManager manager].newsPullTimes = INT_MAX;
            [super load:TTURLRequestCachePolicyNetwork more:YES];
            return;
        }
    } else {
        if (self.topNewsList.count > self.topNewsIndex) {
            if (curRollingNewsLits.count > 0 ) {
                SNRollingNews *news = [curRollingNewsLits objectAtIndex:0];
                if (!news.isMoreFocusNews) {
                    NSString *key = [NSString stringWithFormat:@"%@_%@", kTopCount, self.channelId];
                    self.topNewsCnt = [SNUserDefaults integerForKey:key];
                    //容错机制
                    if (self.topNewsList.count != 0 &&
                        self.topNewsCnt == 0) {
                        self.topNewsCnt = 1;
                    }
                    
                    NSArray *showTopNewList = [self getNeedShowTopNewsList];
                    self.curTopNewsCnt = showTopNewList.count;
                    [self.rollingNews addObjectsFromArray:showTopNewList];
                }
            }
        }
    }
    [self updateRollingNews:curRollingNewsLits];
}

- (void)updateRollingNewsToDB:(id)rootData {
    NSArray *recommendRollingNews = [rootData objectForKey:kRecommendArticles];
    id articleRollingNews = [rootData objectForKey:kArticles];
    if (!recommendRollingNews && articleRollingNews) { // 容错处理：isMixStream =2 时下发的是Articles字段，避免白屏，调取旧版逻辑
        [super updateRollingNewsToDB:rootData];
        return;
    }
    
    NSMutableArray *currentPageRollingNews = [NSMutableArray array];
    
    if ([SNNewsFullscreenManager isFirstOpenAppToday] == YES) {
        //保护：重置时服务端下发数据空，避免白屏
        if ([recommendRollingNews isKindOfClass:[NSArray class]] && recommendRollingNews.count > 0) {
            [self.rollingNews removeAllObjects];
            self.showHistoryLine = NO; // 切时间到第二天后,showHistoryLine已设为yes;而后每天首次启动(程序未杀死)都无法再显示历史提示了,showHistoryLine没有置NO的地方.
            self.hasHistoryData = NO;
            //设置下次显示全屏幕焦点图时间
            [SNUtility setTimeToResetChannel];
            //设置可上拉的最大次数
            SNAppConfig *config = [[SNAppConfigManager sharedInstance] config];
            [SNNewsFullscreenManager manager].newsPullTimes = [config.appNewsSettingConfig getNewsPullTimes];
        } else {
            [self requestDidFinishLoad];
            return;
        }
        
    }
    
    if ([SNNewsFullscreenManager needTrainAnimation] &&!_more && self.rollingNews.count > 0) {
        SNRollingNews *news = [self.rollingNews objectAtIndex:0];
        if ([news isFullScreenFocusNewsItem]) {
            [self updateFocusToTrainNews];
        }
    }
    [SNUtility recordRefreshTime:self.channelId];
    
    //获取各个数据块的有效数据
    if (rootData &&
        [rootData isKindOfClass:[NSDictionary class]]) {
        if (action == 3) {
            //刷新火车卡片数据
            [self updateTrainCardList:rootData];
            return;
        }
        
        NSArray *focusArray = [self updateFocusArticles:rootData];
        if (focusArray.count > 0) {
            [SNNewsFullscreenManager manager].fullscreenMode = YES;
        } else {
            if ([SNNewsFullscreenManager manager].isFullscreenMode &&
                !_more) {
                [SNNotificationManager postNotificationName:kSNFullscreenModeFinishedNotification object:nil];
            }
        }
        NSArray *focusTowTopArray = [self updateFocusTowTopArticles:rootData];
        NSMutableArray *recommendArray = [NSMutableArray arrayWithArray:[self updateRecommendArticles:rootData]];
        if (focusArray.count > 0 && recommendArray.count > 0) {
            SNRollingNews *news = [recommendArray objectAtIndex:0];
            if ([news isTrainCardNewsItem]) {
                //焦点图需要变火车，记录火车ID
                for (SNRollingNews *subNews in focusArray) {
                    //焦点图Item不是火车news。转变后是火车ITEM
                    if ([subNews isFullScreenFocusNewsItem]) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObject:news.trainPos forKey:kTrainPos];
                        [subNews setTrainInfoDataDic:dic];
                        subNews.trainCardId = news.trainCardId;
                        
                        if (subNews.newsItemArray == nil) {
                            subNews.newsItemArray = [NSMutableArray array];
                        }
                        [subNews.newsItemArray addObjectsFromArray:news.newsItemArray];
                    } else {
                        subNews.trainCardId = news.trainCardId;
                    }
                }
                for (SNRollingNews *subNews in focusTowTopArray) {
                    subNews.trainCardId = news.trainCardId;
                }
                
                [SNNewsFullscreenManager setNeedTrainAnimation:YES];
                [recommendArray removeObjectAtIndex:0];
            }
            else{
                NSNumber *tempId = [NSDate nowDateToSysytemIntervalNumber];
                for (SNRollingNews *subNews in focusArray) {
                    subNews.trainCardId = [NSString stringWithFormat:@"%@", tempId];
                }
                for (SNRollingNews *subNews in focusTowTopArray) {
                    subNews.trainCardId = [NSString stringWithFormat:@"%@", tempId];
                }
            }
        }
        
        [currentPageRollingNews addObjectsFromArray:focusArray];
        [currentPageRollingNews addObjectsFromArray:focusTowTopArray];
        [currentPageRollingNews addObjectsFromArray:recommendArray];
        if (self.isPreloadChannel) {
            [self.preloadNews addObjectsFromArray:currentPageRollingNews];
        } else {
            [SNStatisticsInfoAdaptor uploadTimelineloadInfo:currentPageRollingNews isPreload:self.isPreloadChannel];
        }

        if (self.rollingNews.count != 0 && !_more && currentPageRollingNews.count != 0) {
            [currentPageRollingNews addObject:[self addRefreshItemToRollingNews]];
        }
        
        if (action == 1 || action == 0) {
            //特殊处理置顶新闻
            [self updateTopArticles:rootData];
        }
    }
   
    if (currentPageRollingNews.count > 0) {
        //写数据库
        [self setRollingNewsTimelineIndex:currentPageRollingNews];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [[SNDBManager currentDataBase] clearRefreshRollingNewsItem:self.channelId];
            [[SNDBManager currentDataBase] addMultiRollingNewsListItem:[self createRollingNewsListItems:currentPageRollingNews] updateIfExist:YES];
        });
        
        if (_more) {
            _page++;
        } else {
            times++;
        }
        [SNRollingNewsPublicManager sharedInstance].homeADCount += 1;
        //按业务处理数据，得到展示数据
        [self updateRollingNews:currentPageRollingNews];
        
        [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellLoadMore;
    } else {
        [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellAllLoad;
        if (_more) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"内容看完了，看看其他频道" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        
        //本身就是在主线程调用, perform会造成执行延时, UI显示错误
        [self requestDidFinishLoad];
    }
    
    [SNNewsFullscreenManager setOpenAppToday:NO];
}

- (NSArray *)updateRecommendArticles:(NSDictionary *)rootDic {
    id recommendRollingNews = [rootDic objectForKey:kRecommendArticles];
    if ([recommendRollingNews isKindOfClass:[NSArray class]]) {
        return [self createRollingNewsListItems:recommendRollingNews from:kRollingNewsFormRecommend];
    }
    
    return nil;
}

- (NSArray *)updateFocusArticles:(NSDictionary *)rootDic {
    NSMutableArray *list = [NSMutableArray array];

    id articleDic = [rootDic objectForKey:kFocusAreaItem];
    if ([articleDic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)articleDic;
        if (dic.count <= 0) {
            return nil;
        }
        SNRollingNews *news = [self createNews:articleDic from:kRollingNewsFormRecommend];
        news.newsId = [NSString stringWithFormat:@"%@_focus",news.newsId]; // 原因,服务端下发的数组外层的newsID和内部元素第一个的NewsID相同
        news.templateType = kTemplateTypeFullScreenFocus;
        
        //容错：焦点图内容为空，不返回
        if (news.newsFocusArray.count == 0) {
            return nil;
        }
        
        for (SNRollingNews *subNews in news.newsFocusArray) {
            [list addObject:subNews];
        }
        [news.newsFocusArray removeAllObjects];
        [news.newsFocusArray addObjectsFromArray:list];
        [list insertObject:news atIndex:0];
        
        return list;
    }
    
    return nil;
}

- (NSArray *)updateFocusTowTopArticles:(NSDictionary *)rootDic {
    id rollingNewsList = [rootDic objectForKey:kFocusUnderAreaItems];
    if ([rollingNewsList isKindOfClass:[NSArray class]]) {
        return [self createRollingNewsListItems:rollingNewsList from:kRollingNewsFormTowTop];
    }
    
    return nil;
}

- (SNRollingNews *)createNewsByItem:(RollingNewsListItem *)item{
    SNRollingNews *news = [super createNewsByItem:item];
    news.trainCardId = item.trainCardId;
    
    return news;
}

- (SNRollingNews *)createNews:(NSDictionary *)data
                         from:(NSString *)from {
    SNRollingNews *news = [super createNews:data from:from];
    news.trainCardId = [data stringValueForKey:kTrainCardId defaultValue:@""];
    
    return news;
}

- (NSArray *)createRollingNewsListItems:(NSArray *)newsList
                                   from:(NSString *)from
                              trainNews:(SNRollingNews *)trainNews
                            trainCardId:(NSString *)trainCardId
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:newsList.count];
    for (NSDictionary *articleDic in newsList) {
        @autoreleasepool {
            SNRollingNews *news = [self createNews:articleDic from:from];
            news.trainCardId = trainCardId;
            BOOL isExists = [self addExclusiveTrainRollingNews:news trainNews:trainNews];//剔重
            if (isExists) {
                continue;
            }
            [list addObject:news];
        }
    }
    return [NSArray arrayWithArray:list];
}

- (NSArray *)createRollingNewsListItems:(NSArray *)newsList
                                   from:(NSString *)from{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:newsList.count];
    for (NSDictionary *articleDic in newsList) {
        @autoreleasepool {
            SNRollingNews *news = [self createNews:articleDic from:from];
            BOOL isExists = [self addExclusiveRollingNews:news];//剔重
            if (isExists) {
                continue;
            }
      
            if (news &&
                ![news shouldBeHiddenWith:self.isPreloadChannel])
            {
                 [list addObject:news];
//                [self reportTrainCardNewsLoad:news];
            } else if (news && self.isPreloadChannel) {
                [self.preloadEmptyADs addObject:news];
            }
        
            if ([news isTrainCardNewsItem]) {
                SNRollingNews *trainItem = news;
                if (action == 3) {
                    for (SNRollingNews *n in self.rollingNews) {
                        if ([n isTrainCardNewsItem] && [n.trainCardId isEqualToString:self.curTrainCardId]) {
                            trainItem = n;
                            break;
                        }
                    }
                }
              
                //获取火车卡片内的数据
                NSArray *trainNewsList = [self createRollingNewsListItems:[articleDic objectForKey:@"data"]
                                                                     from:kRollingNewsFormTrainCard
                                                                trainNews:trainItem
                                                              trainCardId:news.trainCardId];
                
                //容错：服务端返回的火车数据小于两条，当空火车
                if (trainNewsList.count > 2) {
                    news.newsItemArray = [NSMutableArray arrayWithCapacity:trainNewsList.count];
                    [news.newsItemArray addObjectsFromArray:trainNewsList];
                    [list addObjectsFromArray:trainNewsList];
                }
                else{
                    [list removeObject:news];
                }
            }
        }
    }
    return [NSArray arrayWithArray:list];
}

- (void)reportTrainCardNewsLoad:(SNRollingNews *)news {
    NSString *paramStr = [NSString stringWithFormat:@"_act=card_news&_tp=load&channelid=%@&newsid=%@",news.channelId, news.newsId];
    [SNNewsReport reportADotGif:paramStr];
}

- (void)updateRollingNews:(NSArray *)newsList {
    if (newsList.count != 0) {
        NSMutableArray *currentPageRollingNews = [NSMutableArray array];
        
        SNRollingNews *focusNews = nil;
        NSMutableArray *towTopNews = [NSMutableArray array];
        int focusIndex = -1;//记录第一位是不是焦点图
        for (int i = 0; i < newsList.count; i++) {
            SNRollingNews *news = [newsList objectAtIndex:i];
            BOOL isExists = [self addExclusiveRollingNews:news];//剔重
            if (isExists) {
                continue;
            }
            
            if ([news isFullScreenFocusNewsItem]) {
                if (focusNews == nil) {
                    focusNews = news;
                    [currentPageRollingNews addObject:focusNews];
                }
                focusIndex = i;
                continue;
            }
            
            if ([news isMoreFocusNews]) {
                focusIndex = i;
            }
            
            if ([news isTowTopNews] && focusNews != nil) {
                [towTopNews addObject:news];
        
                continue;
            }
            
            if ([news isTrainCardNews] || [news isFullScreenFocusNews]) {
                continue;
            }
            
            //如果火车里面的数据小于2条，不显示；避免空火车
            if ([news isTrainCardNewsItem] && news.newsItemArray.count <= 2) {
                continue;
            }
            
            [currentPageRollingNews addObject:news];
        }
 
        if (focusNews != nil) {
            if (focusNews.newsItemArray == nil) {
                focusNews.newsItemArray = [NSMutableArray arrayWithCapacity:towTopNews.count];
            }
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [towTopNews count])];
            [focusNews.newsItemArray insertObjects:towTopNews atIndexes:indexes];
        }
        
        if (!_more && focusIndex == 0){
            [SNNewsFullscreenManager manager].fullscreenMode = YES;
            
           //焦点显示第一位图时候，不显示置顶新闻
            if (self.topNewsList.count !=0) {
                self.topNewsIndex = 0;
                if (self.curTopNewsCnt <= [self.rollingNews count]) {
                    [self.rollingNews removeObjectsInRange:NSMakeRange(0, self.curTopNewsCnt)];
                }
                self.curTopNewsCnt = 0;
            }
        }
        
        if (_more) {
            [self.rollingNews addObjectsFromArray:currentPageRollingNews];
        } else {
            NSInteger index = self.topNewsList.count == 0 ? 0 : self.curTopNewsCnt;
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [currentPageRollingNews count])];
            [self.rollingNews insertObjects:currentPageRollingNews atIndexes:indexes];
        }
    }
    
    //本身就是在主线程调用, perform会造成执行延时, UI显示错误
    [self requestDidFinishLoad];
}

- (NSString *)getHistoryTimeStye:(NSInteger)time1 time2:(NSInteger)time2 {
    NSString *timeStyle = nil;
    int interval = (time1 - time2) / (60 * 60);
    interval = (interval > 24) ? 24 : interval;
    if (interval == 0) interval = 1;
    return [NSString stringWithFormat:@"以下为%d小时前看过的新闻",interval];
}


- (SNRollingNews *)createRefreshItem{
    SNRollingNews *topicNews = [[SNRollingNews alloc] init];
    topicNews.templateType = @"201";
    topicNews.channelId = self.channelId;
    topicNews.newsType = @"";
    topicNews.newsId = [NSString stringWithFormat:@"%@_refresh", self.channelId];
    topicNews.title = @"上次看到这里，点击刷新";
    topicNews.from = kRollingNewsFormRecommend;

    return topicNews;
}

- (SNRollingNews *)createHistoryLineItem:(NSString *)string{
    SNRollingNews *topicNews = [[SNRollingNews alloc] init];
    topicNews.templateType = kTemplateTypeRollingNewsHistoryLine;
    topicNews.channelId = self.channelId;
    topicNews.newsId = [SNUtility CreateUUID];
    topicNews.title = string;
    topicNews.from = kRollingNewsFormRecommend;
    SNRollingNews *lastNews = [self.rollingNews lastObject];
    topicNews.timelineIndex = lastNews.timelineIndex;
    return topicNews;
}

- (SNRollingNews *)addRefreshItemToRollingNews{
    for (SNRollingNews *news in self.rollingNews) {
        if ([news.templateType isEqualToString:@"201"]) {
            [self.rollingNews removeObject:news];
            break;
        }
    }
    
    return [self createRefreshItem];
}

- (void)updateFocusToTrainNews{
    if (self.rollingNews.count > 0) {
        SNRollingNews *focusNews = [self.rollingNews objectAtIndex:0];
        if ([focusNews isFullScreenFocusNewsItem]) {
            focusNews.templateType = kTemplateTypeTrainCard;
            
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, focusNews.newsFocusArray.count)];
            [focusNews.newsItemArray insertObjects:focusNews.newsFocusArray atIndexes:indexes];
            
            [focusNews.newsFocusArray removeAllObjects];
            
//            //获取和焦点图同一个火车的数据
//            NSMutableArray *trainNewsList = [NSMutableArray arrayWithArray:[[SNDBManager currentDataBase] getRollingNewsListNextPageByChannelId:self.channelId timelineIndex:nil form:kRollingNewsFormTrainCard trainCardId:focusNews.trainCardId]];
//            for (RollingNewsListItem *subItem in trainNewsList) {
//                SNRollingNews *subNews = [self createNewsByItem:subItem];
//                [focusNews.newsItemArray addObject:subNews];
//            }
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SNDBManager currentDataBase] updateFocusToTrainItemByChannelId:self.channelId];
        [[SNDBManager currentDataBase] updateFocusToTrainNewsByChannelId:self.channelId];
    });
}

- (void)updateFocusToTrainCard{
    [self updateFocusToTrainNews];
    
    //显示置顶
    if (self.rollingNews.count > 0) {
        if (self.topNewsList.count > self.topNewsIndex) {
            NSString *key = [NSString stringWithFormat:@"%@_%@", kTopCount, self.channelId];
            self.topNewsCnt = [SNUserDefaults integerForKey:key];
            //容错机制
            if (self.topNewsList.count != 0 && self.topNewsCnt == 0) {
                self.topNewsCnt = 1;
            }
            
            NSArray *showTopNewList = [self getNeedShowTopNewsList];
            self.curTopNewsCnt = showTopNewList.count;
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, showTopNewList.count)];
            [self.rollingNews insertObjects:showTopNewList atIndexes:indexes];
        }
    }
  
    [SNNewsFullscreenManager manager].focusToTrain = YES;
    //本身就是在主线程调用, perform会造成执行延时, UI显示错误
    [self requestDidFinishLoad];
}

- (void)updateTrainCardList:(NSDictionary *)rootData{
    NSMutableArray *currentPageRollingNews = [NSMutableArray arrayWithArray:[self updateRecommendArticles:rootData]];
    
    NSString *trainPos = nil;
    if (currentPageRollingNews.count > 0 ) {
        SNRollingNews *news= [currentPageRollingNews objectAtIndex:0];
        if([news isTrainCardNewsItem]){
            trainPos = news.trainPos;
            [currentPageRollingNews removeObject:news];
        }
    }
  
    if (currentPageRollingNews.count > 0 ) {
        for (SNRollingNews *n in self.rollingNews) {
            if ([n isTrainCardNewsItem] && [n.trainCardId isEqualToString:self.curTrainCardId]) {
                n.trainPos = trainPos;
                [n.newsItemArray addObjectsFromArray:currentPageRollingNews];
                break;
            }
        }
    }
    if (self.successBlock) {
        self.successBlock(currentPageRollingNews);
    }
    [super setRequestFinishedLoad];
    //写数据库
    [self setRollingNewsTimelineIndex:currentPageRollingNews];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SNDBManager currentDataBase] addMultiRollingNewsListItem:[self createRollingNewsListItems:currentPageRollingNews] updateIfExist:YES];
    });
}

//计算出滚动新闻所在的时间线上的序号
//翻页的新闻是旧新闻，在上一页的序号基础上递减
//刷新的新闻是新新闻，在最大序号的基础上递增
- (void)setRollingNewsTimelineIndex:(NSMutableArray *)rollingNews {
    
    if (_more) { // 上拉加载新数据,index--
//        _minTimelineIndex = [SNRollingNewsPublicManager sharedInstance].minTimelineIndex; // 不能直接取rollingNews里的最后一个索引,因为可能是昨天的历史数据,index很小,而追加的数据应该是今天的新闻索引的最小值.
        _minTimelineIndex = [SNRollingNewsPublicManager readRollingMinTimelineIndexWithChannelId:self.channelId];
        if (_minTimelineIndex == 0) {
            SNRollingNews *lastNews = [self.rollingNews lastObject];
            _minTimelineIndex = [lastNews.timelineIndex integerValue];
        }
        int minTimelineIndex = _minTimelineIndex;
      
        for (SNRollingNews *news in rollingNews) {
            news.timelineIndex = [NSString stringWithFormat:@"%d", --minTimelineIndex];
        }
        _minTimelineIndex = minTimelineIndex;
    } else { // 下拉加载新数据,index++
        NSString *maxIndex = [[SNDBManager currentDataBase] getMaxRollingTimelineIndexByChannelId:_channelId form1:kRollingNewsFormRecommend form2:kRollingNewsFormTop];
        int maxTimelineIndex = [maxIndex intValue];
        
        if ([SNNewsFullscreenManager isFirstOpenAppToday] == YES && maxTimelineIndex != 0) {
            maxTimelineIndex += ([SNNewsFullscreenManager manager].newsPullTimes + 1)*KPaginationNum;
            _minTimelineIndex = maxTimelineIndex;
        }
        else if (self.rollingNews.count <= 0 || maxTimelineIndex == 0) {
            //和当前最大值拉开1000条(50页)的距离，确保这个最大值不会导致翻页后覆盖现有缓存的timelineIndex,
            //否则会导致很久不看新闻时翻页后和以前的新闻timelineIndex值重复。除非用户翻50页，还会重复，不过不太可能，50页呢。
            //就算每秒刷一次，每秒加1000，也需要3亿年(9223372036854775807/1000/60/60/24/30/12=296533309)才达到sqlite表里timelineIndex上限。
            maxTimelineIndex += KPaginationNum * 50;
            
            int arc4randomX = 100;
            int tmparc4randomX = [[NSUserDefaults standardUserDefaults] integerForKey:@"arc4randomX"];
            if (0 == tmparc4randomX) {
                [[NSUserDefaults standardUserDefaults] setInteger:arc4randomX forKey:@"arc4randomX"];
            } else {
                arc4randomX = tmparc4randomX;
                arc4randomX += [rollingNews count];
                arc4randomX++;
                [[NSUserDefaults standardUserDefaults] setInteger:arc4randomX forKey:@"arc4randomX"];
            }
            maxTimelineIndex += arc4randomX;
            _minTimelineIndex = maxTimelineIndex;
        }else{
//            _minTimelineIndex = [SNRollingNewsPublicManager sharedInstance].minTimelineIndex;
            _minTimelineIndex = [SNRollingNewsPublicManager readRollingMinTimelineIndexWithChannelId:self.channelId];
        }
        
        SNDebugLog(@"maxTimelineIndex = %d", maxTimelineIndex);
       
        for (SNRollingNews *news in [[rollingNews reverseObjectEnumerator] allObjects]) {
            news.timelineIndex = [NSString stringWithFormat:@"%d", ++maxTimelineIndex];
        }
    }
    
//    [SNRollingNewsPublicManager sharedInstance].minTimelineIndex = _minTimelineIndex;
    [SNRollingNewsPublicManager saveRollingMinTimelineIndex:_minTimelineIndex channelId:self.channelId];
}

- (int)getParamForceRefresh{
    //满足早上6点重置，或者频道流缓存为空
    if ([SNNewsFullscreenManager isFirstOpenAppToday] || self.rollingNews.count == 0) {
        return 1;
    }
    
    return 0;
}

#pragma mark 置顶新闻

- (NSArray *)updateTopArticles:(NSDictionary *)rootData{
    self.contentToken = [rootData stringValueForKey:@"contentToken" defaultValue:kDefaultContentToken];
    if (self.contentToken == nil || [self.contentToken length] == 0) {
        return nil;
    }
    
    SNTopNewsStatus status = [[SNRollingNewsPublicManager sharedInstance] getTopNewsStatus:self.contentToken channelId:self.channelId];
    switch (status) {
        case SNTopNewsUpdate: {
            //更新置顶新闻
            self.topNewsIndex = 0;
            NSString *key = [NSString stringWithFormat:@"%@_%@", kTopCount, self.channelId];
            self.topNewsCnt = [SNUserDefaults integerForKey:key];
            [self updateTopNews:rootData contentToken:self.contentToken];
            [SNUserDefaults setInteger:self.topNewsCnt forKey:key];
        }
            break;
        case SNTopNewsDefault: {
            if (self.topNewsCnt == 0) {
                NSString *key = [NSString stringWithFormat:@"%@_%@", kTopCount, self.channelId];
                self.topNewsCnt = [SNUserDefaults integerForKey:key];
            }
            
            if (self.topNewsList.count == 0) {
                //更新置顶新闻
                [self updateTopNews:rootData contentToken:self.contentToken];
            } else {
                [self updateRollingTopNewsStatus:SNTopNewsDefault];
            }
        }
            break;
        case SNTopNewsNULL: {
            //置顶新闻置空
            [self clearTopNews];
        }
            break;
        default:
            break;
    }
    
    [[SNRollingNewsPublicManager sharedInstance] saveContentToken:self.contentToken withChannelId:self.channelId];
    
    return nil;
}

- (void)updateTopNews:(NSDictionary *)rootDic
              contentToken:(NSString *)contentToken {
    //获取新的置顶新闻，展示self.topNewsCnt条
    id topRollingNews = [rootDic objectForKey:kTopArticles];
    NSString *token = [rootDic objectForKey:kToken];
    if ([topRollingNews isKindOfClass:[NSArray class]]) {
        [self.topNewsList removeAllObjects];
        for (NSDictionary *articleDic in topRollingNews) {
            @autoreleasepool {
                SNRollingNews *news = [self createNews:articleDic
                                                  from:kRollingNewsFormTop];
                news.token = token;
                if (news) {
                    [self.topNewsList addObject:news];
                }
            }
        }
        //容错机制
        if (self.topNewsList.count != 0 && self.topNewsCnt == 0) {
            self.topNewsCnt = 1;
        }
        
        [self setRollingNewsTimelineIndex:self.topNewsList];
        
        //获取置顶topNewsCnt展示
        [self updateRollingTopNewsStatus:SNTopNewsUpdate];
   
        //更新置顶新闻缓存
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSString *lChannelId = self.channelId;
            [[SNDBManager currentDataBase] clearRollingRecommendNewsListByChannelId:self.channelId form:kRollingNewsFormTop];
            [[SNDBManager currentDataBase] addMultiRollingNewsListItem:[self createRollingNewsListItems:self.topNewsList] updateIfExist:YES];
        });
    }
    
    [[SNRollingNewsPublicManager sharedInstance] saveContentToken:contentToken withChannelId:self.channelId];
}

- (void)clearTopNews {
    if (self.topNewsList.count != 0) {
        [self.topNewsList removeAllObjects];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [[SNDBManager currentDataBase] clearRollingRecommendNewsListByChannelId:self.channelId form:kRollingNewsFormTop];
        });
    }
    
    int index = 0;
    for (SNRollingNews *tmpNews in self.rollingNews) {
        //判断是不是本地频道(切换城市和扫一扫那个模板)
        if ([tmpNews.templateType isEqualToString:@"27"] ||
            [tmpNews.templateType isEqualToString:@"30"]) {
            index++;
            break;
        }
    }
    if (self.rollingNews.count > index + self.curTopNewsCnt) {
        [self.rollingNews removeObjectsInRange:NSMakeRange(index, self.curTopNewsCnt)];
    }
}

- (void)updateRollingTopNewsStatus:(SNTopNewsStatus)status {
    NSArray *showTopNewList = [self getNeedShowTopNewsList];
    if (showTopNewList == nil || showTopNewList.count == 0) {
        return;
    }
    
    if (self.rollingNews.count == 0) {
        [self.rollingNews addObjectsFromArray:showTopNewList];
    } else {
        NSInteger index = 0;
        SNRollingNews *tmpNews = [self.rollingNews objectAtIndex:index];
        //判断是不是本地频道(切换城市和扫一扫那个模板)
        if ([tmpNews.templateType isEqualToString:@"27"] ||
            [tmpNews.templateType isEqualToString:@"30"]) {
            index += 1;
            tmpNews = [self.rollingNews objectAtIndex:index];
        }
        
        //判断广告置顶的情况
        if (status == SNTopNewsDefault && tmpNews != nil && [tmpNews.templateType isEqualToString:@"76"]) {
            [self.rollingNews removeObject:tmpNews];
        }
        
        //删除置顶区新闻；写入新置顶
        int topNewsNum = self.topNewsCnt;
        NSString *key = [NSString stringWithFormat:@"%@_%@", kLastTopNewsCnt, self.channelId];
        NSInteger lastTopNewsCnt = [SNUserDefaults integerForKey:key];
        if (SNTopNewsUpdate == status && lastTopNewsCnt != 0) {
            topNewsNum = lastTopNewsCnt;
        }else{
            topNewsNum = self.curTopNewsCnt;
        }
        if (index + topNewsNum <= self.rollingNews.count) {
            [self.rollingNews removeObjectsInRange:NSMakeRange(index, topNewsNum)];
        }
        
        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(index, showTopNewList.count)];
        [self.rollingNews insertObjects:showTopNewList atIndexes:indexes];
        if (status == SNTopNewsDefault && tmpNews != nil && [tmpNews.templateType isEqualToString:@"76"]) {
            [self.rollingNews insertObject:tmpNews atIndex:index+showTopNewList.count];
        }
    }
    
    self.curTopNewsCnt = showTopNewList.count;
}

- (BOOL)addExclusiveTrainRollingNews:(SNRollingNews *)news trainNews:(SNRollingNews *)trainNews{
    BOOL exists = NO;
    for (SNRollingNews *n in trainNews.newsItemArray) {
        //增加newsType判断
        if ([n.newsId isEqualToString:news.newsId] &&
            [n.channelId isEqualToString:news.channelId]
            && [n.newsType isEqualToString:news.newsType]) {
            exists = YES;
            break;
        }
    }
    return exists;
}

@end
