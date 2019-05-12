//
//  SNRollingNewsChannelModule.m
//  sohunews
//
//  Created by handy wang on 1/8/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsChannelModule.h"
#import "SNRollingNews.h"
#import "SNNewsType.h"
#import "SNRollingArticleNewsContentWorker.h"
#import "SNChannelGroupPhotoNewsContentWorker.h"
#import "SNSpecialNewsListContentWorker.h"
#import "NSJSONSerialization+String.h"

@implementation SNRollingNewsChannelModule

#pragma mark - Lifecycle

- (void)dealloc {
    _delegate = nil;
    _rollingNewsRequest.delegate = nil;
     //(_rollingNewsRequest);
     //(_newsItemArray);
    
}

#pragma mark - Public methods implementation

//Override
- (void)startInThread {
    SNDebugLog(@"===INFO: %@,%@, Main thread:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread isMainThread]);
    
	NSString *urlString = [NSString stringWithFormat:kUrlRollingNewsListJson, _channelID, kRNLPageSize,
                           kRNLStartPageNumber];
    // 目前只有频道订阅中可以出发频道新闻下载  为了区分频道新闻请求的来源 需要加一个from参数 未来如果增加了频道直接下载功能 这里需要根据具体情况来修改参数
    // by jojo on 2013-12-26
    urlString = [urlString stringByAppendingString:@"&from=sub"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    _rollingNewsRequest = [SNASIRequest requestWithURL:url];
    SNDebugLog(@"===INFO: Module start in thread, Fetching Rolling news from %@", [_rollingNewsRequest.url absoluteString]);
    [SNASIRequest setShouldUpdateNetworkActivityIndicator:NO];
    [_rollingNewsRequest setValidatesSecureCertificate:NO];
    [_rollingNewsRequest setTimeOutSeconds:20];
    [_rollingNewsRequest setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
    _rollingNewsRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    _rollingNewsRequest.delegate = self;
    [_rollingNewsRequest setValidatesSecureCertificate:NO];
    [_rollingNewsRequest startAsynchronous];
    
    [self notifyStartingDownloading];
}

//Override
- (void)cancel {
    [super cancel];
    
    if (!!(_channelName) && ![@"" isEqualToString:_channelName]) {
        SNDebugLog(@"===INFO: Main thread:%d, Canceling fetching %@ channel rolling news......", [NSThread isMainThread], _channelName);
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Canceling fetching channel rolling news......", [NSThread isMainThread]);
    }
    
    [_rollingNewsRequest cancel];
    _rollingNewsRequest.delegate = nil;
     //(_rollingNewsRequest);
     //(_newsItemArray);
}


#pragma mark - 下载某频道RollingNews成功
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSString *jsonString = [[request responseString] copy];
    _rollingNewsRequest.delegate = nil;
     //(_rollingNewsRequest);
    
    id rootData = [NSJSONSerialization JSONObjectWithString:jsonString
                                                    options:NSJSONReadingMutableLeaves
                                                      error:NULL];
     //(jsonString);
    SNDebugLog(@"===INFO: Fetched %@ channel rolling news list jsondata : %@, Main thread:%d", _channelName, rootData, [NSThread isMainThread]);
    
    if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SNDebugLog(@"===INFO: Ready to save data and fetch news content for channel %@, Main thread:%d", _channelName, [NSThread isMainThread]);
            [self saveRollingNewsToDB:rootData];//保存rollingnews以及下载rollingsnews图片
            [self scheduleANewsContentWorkerToWorkInThread];
            
            //下载下一个频道
            if ([_delegate respondsToSelector:@selector(didFinishDownloadingModule:)]) {
                [_delegate didFinishDownloadingModule:self];
            }
            _delegate = nil;
        });
    } else {
        SNDebugLog(@"===ERROR: Main thread:%d, fetched %@ channel rolling news list jsondata is invalid, and continue fetching next channel.",
                   [NSThread isMainThread], _channelName);
        //下载下一个频道
        if ([_delegate respondsToSelector:@selector(didFinishDownloadingModule:)]) {
            [_delegate didFinishDownloadingModule:self];
        }
        _delegate = nil;
    }
}

- (void)saveRollingNewsToDB:(id)rootData {
    SNDebugLog(@"===INFO: Main thread:%d, saving %@ channel rolling news list to db.", [NSThread isMainThread], _channelName);
    
     //(_newsItemArray);
    _newsItemArray = [NSMutableArray array];
    
    NSMutableArray *_rollingNewsImgURLArray = [NSMutableArray array];
    
    NSMutableArray *_headlineNewsArray = [NSMutableArray array];
    NSMutableArray *_normalRollingNewsArray = [NSMutableArray array];
    NSMutableArray *_expressNewsArray = [NSMutableArray array];
    
    id headlineData = [rootData objectForKey:kFocals];
    id rollingNewsData = [rootData objectForKey:kArticles];
    id expressNewsData = [rootData objectForKey:kFlashes];
    
    //---Headline(焦点新闻)
    if ([headlineData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *_headlineDic in headlineData) {
            SNRollingNews *_headlineNews = [self createNews:_headlineDic form:kRollingNewsFormHeadline channelID:_channelID];
            if (_headlineNews) {
                [_headlineNewsArray addObject:_headlineNews];
                [self collectRollingNewsImgURL:_headlineNews into:_rollingNewsImgURLArray];
            }
        }
    } else if ([headlineData isKindOfClass:[NSDictionary class]]) {
        SNRollingNews *_headlineNews = [self createNews:headlineData form:kRollingNewsFormHeadline channelID:_channelID];
        if (_headlineNews) {
            [_headlineNewsArray addObject:_headlineNews];
            [self collectRollingNewsImgURL:_headlineNews into:_rollingNewsImgURLArray];
        }
    }
    NSArray *_rollingNewsItemArray = [self createRollingNewsListItems:_headlineNewsArray];
    if (!!_rollingNewsItemArray) {
        [_newsItemArray addObjectsFromArray:_rollingNewsItemArray];
    }
    
    //---Express news(快讯)
    if ([expressNewsData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *_expressNewsDic in expressNewsData) {
            SNRollingNews *_expressNews = [self createNews:_expressNewsDic form:kRollingNewsFormExpress channelID:_channelID];
            if (_expressNews && ![_expressNews shouldBeHiddenWith:NO]) {
                [_expressNewsArray addObject:_expressNews];
                [self collectRollingNewsImgURL:_expressNews into:_rollingNewsImgURLArray];
            }
        }
    } else if ([expressNewsData isKindOfClass:[NSDictionary class]]) {
        SNRollingNews *_expressNews = [self createNews:expressNewsData form:kRollingNewsFormExpress channelID:_channelID];
        if (_expressNews && ![_expressNews shouldBeHiddenWith:NO]) {
            [_expressNewsArray addObject:_expressNews];
            [self collectRollingNewsImgURL:_expressNews into:_rollingNewsImgURLArray];
        }
    }
    NSArray *_expressNewsItemArray = [self createRollingNewsListItems:_expressNewsArray];
    if (!!_expressNewsItemArray) {
        [_newsItemArray addObjectsFromArray:_expressNewsItemArray];
    }
    
    //---Rolling news(普通滚动新闻)
    if ([rollingNewsData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *_rollingNewsDic in rollingNewsData) {
            SNRollingNews *news = [self createNews:_rollingNewsDic form:kRollingNewsFormCommon channelID:_channelID];
            if (news && ![news shouldBeHiddenWith:NO]) {
                [self addRollingNews:news ifNotExistIn:_normalRollingNewsArray];
                [self collectRollingNewsImgURL:news into:_rollingNewsImgURLArray];
            }
        }
    } else if ([rollingNewsData isKindOfClass:[NSDictionary class]]) {
        SNRollingNews *news = [self createNews:rollingNewsData form:kRollingNewsFormCommon channelID:_channelID];
        if (news && ![news shouldBeHiddenWith:NO]) {
            [self addRollingNews:news ifNotExistIn:_normalRollingNewsArray];
            [self collectRollingNewsImgURL:news into:_rollingNewsImgURLArray];
        }
    }
    NSArray *_normalNewsItemArray = [self createRollingNewsListItems:_normalRollingNewsArray];
    if (!!_normalNewsItemArray) {
        [_newsItemArray addObjectsFromArray:_normalNewsItemArray];
    }
    
    // 4.0广告 解析广告定向数据 并缓存 by jojo
    // 先清除之前的缓存
    [[SNDBManager currentDataBase] adInfoClearAdInfosByType:SNAdInfoTypeChannelBanner
                                                     dataId:_channelID
                                                 categoryId:kAdInfoDefaultCategoryId];
    
    NSArray *adInfoControls = [(NSDictionary *)rootData arrayValueForKey:@"adControlInfos" defaultValue:nil];
    if (adInfoControls) {
        NSMutableArray *parsedAdInfos = [NSMutableArray array];
        for (NSDictionary *adInfoDic in adInfoControls) {
            if ([adInfoDic isKindOfClass:[NSDictionary class]]) {
                SNAdControllInfo *adControlInfo = [[SNAdControllInfo alloc] initWithJsonDic:adInfoDic];
                [parsedAdInfos addObject:adControlInfo];
                 //(adControlInfo);
            }
        }
        // 添加到缓存
        [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:parsedAdInfos
                                                       withType:SNAdInfoTypeChannelBanner
                                                         dataId:_channelID
                                                     categoryId:kAdInfoDefaultCategoryId];
    }
    
    _totalDownloadCount = [_newsItemArray count];
    [self setRollingNewsTimelineIndex:_newsItemArray];
    [[SNDBManager currentDataBase] saveDownloadedRollingNewsItemArrayToDB:_newsItemArray forChannelID:_channelID];
    
    SNDebugLog(@"===INFO: Main thread:%d, saved %@ channel rolling news list to db.", [NSThread isMainThread], _channelName);
    
    //下载即时新闻的图片
    if (!!_rollingNewsImgURLArray && (_rollingNewsImgURLArray.count > 0)) {
        SNDebugLog(@"===INFO: Main thread:%d, downloading channel %@ rollingnews images %@ ...", [NSThread isMainThread], _channelID, _rollingNewsImgURLArray);
        [[SNNewsImageFetcher sharedInstance] setDelegate:self];
        [[SNNewsImageFetcher sharedInstance] fetchRollingNewsImagesInThread:_rollingNewsImgURLArray];
        //下载完图片的回调开始下载article内容;
    }
    //无图可下载
    else {
        SNDebugLog(@"===INFO: Main thread:%d, there is no images to download for channel %@ rolling news.", [NSThread isMainThread], _channelName);
    }
}

//计算出滚动新闻所在的时间线上的序号
//翻页的新闻是旧新闻，在上一页的序号基础上递减
//刷新的新闻是新新闻，在最大序号的基础上递增
- (void)setRollingNewsTimelineIndex:(NSMutableArray *)rollingNews {
    NSString *maxIndex = [[SNDBManager currentDataBase] getMaxRollingTimelineIndexByChannelId:_channelID];
    int maxTimelineIndex = [maxIndex intValue];
    
    //和当前最大值拉开1000条(50页)的距离，确保这个最大值不会导致翻页后覆盖现有缓存的timelineIndex,
    //否则会导致很久不看新闻时翻页后和以前的新闻timelineIndex值重复。除非用户翻50页，还会重复，不过不太可能，50页呢。
    //就算每秒刷一次，每秒加1000，也需要3亿年(9223372036854775807/1000/60/60/24/30/12=296533309)才达到sqlite表里timelineIndex上限。
    maxTimelineIndex += KPaginationNum * 50;
    SNDebugLog(@"===INFO: Main thread:%d, maxTimelineIndex = %d", [NSThread isMainThread], maxTimelineIndex);
    
    for (SNRollingNews *news in [[rollingNews reverseObjectEnumerator] allObjects]) {
        news.timelineIndex = [NSString stringWithFormat:@"%d", ++maxTimelineIndex];
        SNDebugLog(@"===INFO: Main thread:%d, set %@  maxTimelineIndex = %@", [NSThread isMainThread], news.title, news.timelineIndex);
    }
}

- (SNRollingNews *)createNews:(NSDictionary *)data form:(NSString *)from channelID:(NSString *)channelID {
    SNRollingNews *news = [[SNRollingNews alloc] init];
    news.channelId = channelID;
    news.newsId = [data stringValueForKey:kNewsId defaultValue:@""];
    news.newsType = [data stringValueForKey:kNewsType defaultValue:@""];
    news.time = [data stringValueForKey:kTime defaultValue:@""];
    news.title = [data stringValueForKey:kTitle defaultValue:@""];
    news.digNum = [data stringValueForKey:kDigNum defaultValue:@""];
    news.commentNum = [data stringValueForKey:kCommentNum defaultValue:@""];
    news.abstract = [data stringValueForKey:kDesc defaultValue:@""];
    news.link = [data stringValueForKey:kNewsLink2 defaultValue:@""];
    news.picUrl = [data stringValueForKey:kListPic defaultValue:@""];
    news.listPicsNumber = [data stringValueForKey:kListPicsNumber defaultValue:@""];
    news.hasVideo = [data stringValueForKey:kIsHasTV defaultValue:@""];
    news.hasVote = [data stringValueForKey:kIsHasVote defaultValue:@""];
    news.updateTime = [data stringValueForKey:kUpdateTime defaultValue:@""];
    news.templateType = [data stringValueForKey:kTemplateType defaultValue:@"1"];
    news.templateId = [data stringValueForKey:kTemplateId defaultValue:@""];
    news.playTime = [data stringValueForKey:kPlayTime defaultValue:@""];
    news.liveType = [data stringValueForKey:kLiveType defaultValue:@""];
    news.isFlash = [data stringValueForKey:kIsFlash defaultValue:@"0"];
    news.position = [data stringValueForKey:kPos defaultValue:@""];
    news.from = from;
    news.statsType = [data intValueForKey:kRollingNewsStatsType defaultValue:0];
    news.adType = [data stringValueForKey:kAdType defaultValue:@""];
    news.adAbPosition = [data intValueForKey:kAdAbPosition defaultValue:0];
    news.adPosition = [data intValueForKey:kAdPosition defaultValue:0];
    news.refreshCount = [data intValueForKey:kAdRefreshCount defaultValue:0];
    news.loadMoreCount = [data intValueForKey:kAdLoadMoreCount defaultValue:0];
    news.scope = [data stringValueForKey:kAdScope defaultValue:nil];
    news.appChannel = [data stringValueForKey:kAdAppChannel defaultValue:0];
    news.newsChannel = [data stringValueForKey:kAdNewsChannel defaultValue:0];
    news.isHasSponsorships = [data stringValueForKey:kIsHasSponsorships defaultValue:@""];
    news.iconText = [data objectForKey:kIconText];
    news.newsTypeText = [data objectForKey:kNewsTypeText];
    news.cursor = [data stringValueForKey:kCursor defaultValue:@""];
    
    if ([[data objectForKey:kListPics] isKindOfClass:[NSArray class]]) {
        news.picUrls = [data objectForKey:kListPics];
        if ([news.picUrls count]) {
            news.picUrl = [news.picUrls objectAtIndex:0];
        }
    }
    news.isRead = NO;
    
    //设置特殊模信息
    [news setDataStringWithDic:data];
    
    //设置冠名信息
    [news setSponsorshipsWithDic:[data objectForKey:kSponsorships]];
    
    return news;
}

- (NSArray *)createRollingNewsListItems:(NSArray *)newsList {
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:newsList.count];
    for (SNRollingNews *news in newsList) {
        RollingNewsListItem *item = [[RollingNewsListItem alloc] init];
        
        item.channelId = news.channelId;
        item.newsId = news.newsId;
        item.type = news.newsType;
        item.title = news.title;
        item.description = news.abstract;
        item.time = news.time;
        item.commentNum = news.commentNum;
        item.digNum = news.digNum;
        item.link = news.link;
        item.form = news.from;
        item.readFlag = news.isRead ? @"1" : @"0";
        item.listPicsNumber = news.listPicsNumber;
        item.timelineIndex = news.timelineIndex;
        item.hasVideo = news.hasVideo;
        item.hasVote = news.hasVote;
        item.updateTime = news.updateTime;
        item.newsStatsType = news.statsType;
        item.iconText = news.iconText;
        item.newsTypeText = news.newsTypeText;
        item.cursor = news.cursor;
        
        if ([item.form isEqualToString:kRollingNewsFormHeadline]) {
            item.listPic = news.picUrl;
        } else if ([kNewsTypeGroupPhoto isEqualToString:news.newsType]) {
            item.listPic = [news.picUrls componentsJoinedByString:kParameterSeparator];
        } else {
            item.listPic = news.picUrl;
        }
        
        [list addObject:item];
    }
    return [NSArray arrayWithArray:list];
}

- (void)addRollingNews:(SNRollingNews *)news ifNotExistIn:(NSMutableArray *)rollingNewsArray {
    BOOL exists = NO;
    for (SNRollingNews *n in rollingNewsArray) {
        if ([n.newsId isEqualToString:news.newsId] && [n.channelId isEqualToString:news.channelId]) {
            exists = YES;
            break;
        }
    }
    if (!exists) {
        [rollingNewsArray addObject:news];
    }
    
}

- (void)collectRollingNewsImgURL:(SNRollingNews *)rollingNews into:(NSMutableArray *)rollingNewsImgURLArray {
    if ([rollingNews.from isEqualToString:kRollingNewsFormHeadline]) {
        if (!!(rollingNews.picUrl) && ![@"" isEqualToString:rollingNews.picUrl]) {
            [rollingNewsImgURLArray addObject:rollingNews.picUrl];
        }
    } else if ([kNewsTypeGroupPhoto isEqualToString:rollingNews.newsType]) {
        for (NSString *_imgURL in rollingNews.picUrls) {
            if (!!_imgURL && ![@"" isEqualToString:_imgURL]) {
                [rollingNewsImgURLArray addObject:_imgURL];
            }
        }
    } else {
        if (!!(rollingNews.picUrl) && ![@"" isEqualToString:rollingNews.picUrl]) {
            [rollingNewsImgURLArray addObject:rollingNews.picUrl];
        }
    }
}

#pragma mark - 下载某频道RollingNews失败;

- (void)requestFailed:(ASIHTTPRequest *)request {
    _rollingNewsRequest.delegate = nil;
     //(_rollingNewsRequest);
    
    SNDebugLog(@"===ERROR: Main thread:%d, failed to fetched %@ channel rolling news list, and continue fetching next channel.", [NSThread isMainThread], _channelName);

    if ([_delegate respondsToSelector:@selector(didFailedToDownloadModule:)]) {
        [_delegate didFailedToDownloadModule:self];
    }
    _delegate = nil;
}

#pragma mark - 下载某频道RollingNews图片完成
- (void)finishedToFetchRollingNewsImagesInThread {
    SNDebugLog(@"===INFO: Main thread:%d, finish downloading images for channel %@ rolling news.", [NSThread isMainThread], _channelName);
}

#pragma mark - 下载某频道正文内容（图片、文字等）

- (NSInteger)downloadedItemCount {
    if (!_newsItemArray || (_newsItemArray.count <= 0)) {
        return kRNLPageSize;
    }
    else
        return kRNLPageSize - [_newsItemArray count];
}

- (NSArray *)waitingItems {
    if (!_newsItemArray || (_newsItemArray.count <= 0)) {
        SNDebugLog(@"===INFO: There is no undownloaded rolling news items.");
        return nil;
    }
    
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"isDownloadFinished==0"];//未下载的新闻
    return [_newsItemArray filteredArrayUsingPredicate:_predicate];
}

- (void)scheduleANewsContentWorkerToWorkInThread {
    [super scheduleANewsContentWorkerToWorkInThread];
    
    NSArray *_waitingItems = [self waitingItems];
    //更新下载数量
    NSInteger total = [_newsItemArray count];
    NSInteger finish = total - _waitingItems.count;
    if (total>0 && finish>=0 && total>=finish && [_delegate respondsToSelector:@selector(didFinishDownloadingCount:total:)])
        [_delegate didFinishDownloadingCount:finish total:total];
    
    if (!_waitingItems || (_waitingItems.count <= 0)) {
         //(_runningNewsContentWorker);
        
        //Exit Point
        SNDebugLog(@"===INFO: Main thread:%d, ExitPoint, finish downloading %@ channel content.", [NSThread isMainThread], _channelName);
        return;
    }

    SNDebugLog(@"===INFO: Creating a running content worker for channel %@...", _channelName);
    //注意：虽然下现把新闻分为多类，但是从实际新闻内容接口来看可以合并为：Article新闻(标题，文本，图文，投票新闻)，组图新闻，专题新闻，直播
    RollingNewsListItem *_rollingNewsItem = [_waitingItems objectAtIndex:0];

    if (!!(_rollingNewsItem.newsId) && ![@"" isEqualToString:_rollingNewsItem.newsId]
        && !!(_rollingNewsItem.type) && ![@"" isEqualToString:_rollingNewsItem.type]
        && !!(_rollingNewsItem.title) && ![@"" isEqualToString:_rollingNewsItem.title]) {
        
        int _type = [_rollingNewsItem.type intValue];
        switch (_type) {
            case SNNewsType_FocusNews: {//集点新闻，暂不支持 
                break;
            }
            case SNNewsType_PhotoAndTextNews: {//图文新闻
                [self createOrUpdateArticleNewsWorker:_rollingNewsItem];
                break;
            }
            case SNNewsType_GroupPhotoNews: {//组图新闻
                [self createOrUpdateGroupPhotoNewsWorker:_rollingNewsItem];
                break;
            }
            case SNNewsType_TextNews: {//文本新闻
                [self createOrUpdateArticleNewsWorker:_rollingNewsItem];
                break;
            }
            case SNNewsType_TitleNews: {//标题新闻
                [self createOrUpdateArticleNewsWorker:_rollingNewsItem];
                break;
            }
            case SNNewsType_OutterLinkNews: {//外链新闻，暂不支持
                break;
            }
            case SNNewsType_LiveNews: {//直播，暂不支持
                break;
            }
            case SNNewsType_SpecialNews: {//专题新闻
                [self createOrUpdateSpecialNewsWorker:_rollingNewsItem];
                break;
            }
            case SNNewsType_NewspaperNews: {//报纸，暂不支持
                break;
            }
            case SNNewsType_VoteNews: {//含有投票的新闻(实际上就是有article的新闻)
                [self createOrUpdateArticleNewsWorker:_rollingNewsItem];
                break;
            }
            default:
                break;
        }
        
        _rollingNewsItem.isDownloadFinished = YES;
    } else {
        _rollingNewsItem.isDownloadFinished = -1;//-1 indicates finished but rollingNewsItem is invalid data.
    }
    
    if (!!_runningNewsContentWorker && !_isCanceled) {
        SNDebugLog(@"===INFO: Start a running content worker for channel %@...", _channelName);
        [_runningNewsContentWorker startInThread];
    } else {
        SNDebugLog(@"===INFO: Give up start content worker for channel %@ with nil _runningNewsContentWorker.", _channelName);
    }
}

- (void)createOrUpdateArticleNewsWorker:(RollingNewsListItem *)rollingNewsListItem {
    self.runningNewsContentWorker = [[SNRollingArticleNewsContentWorker alloc] initWithDelegate:self];
    [_runningNewsContentWorker appenNewsID:rollingNewsListItem.newsId newsTitle:rollingNewsListItem.title newsType:rollingNewsListItem.type];
}

- (void)createOrUpdateGroupPhotoNewsWorker:(RollingNewsListItem *)groupPhotoNewsListItem {
    self.runningNewsContentWorker = [[SNChannelGroupPhotoNewsContentWorker alloc] initWithDelegate:self];
    [_runningNewsContentWorker appenNewsID:groupPhotoNewsListItem.newsId newsTitle:groupPhotoNewsListItem.title newsType:groupPhotoNewsListItem.type];
}

- (void)createOrUpdateSpecialNewsWorker:(RollingNewsListItem *)specialNewsListItem {
    self.runningNewsContentWorker = [[SNSpecialNewsListContentWorker alloc] initWithDelegate:self];
    [_runningNewsContentWorker appenNewsID:specialNewsListItem.newsId newsTitle:specialNewsListItem.title newsType:specialNewsListItem.type];
}

//暂停所有下载
-(BOOL)doSuspendIfNeeded
{
    if(!_isSuspending && (_rollingNewsRequest!=nil || _runningNewsContentWorker!=nil))
    {
        _isSuspending = YES;
//        [_runningNewsContentWorker cancel];
//         //(_runningNewsContentWorker);
//        [_rollingNewsRequest clearDelegatesAndCancel];
//         //(_rollingNewsRequest);
//         //(_newsItemArray);
        [self cancel];
        return YES;
    }
    
    return NO;
}

//恢复所有下载
-(BOOL)doResumeIfNeeded
{
    if(_isSuspending && _rollingNewsRequest==nil)
    {
        _isSuspending = NO;
        [self performSelectorOnMainThread:@selector(startInThread) withObject:nil waitUntilDone:NO];
        return YES;
    }
    
    return NO;
}
@end
