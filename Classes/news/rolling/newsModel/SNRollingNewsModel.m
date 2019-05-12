
//  SNRollingNewsModel.m
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsModel.h"
#import "SNURLJSONResponse.h"
#import "SNRollingNews.h"
#import "SNDBManager.h"
#import "NSDictionaryExtend.h"
#import "SNRefreshMessageView.h"
#import "SNBubbleBadgeService.h"
#import "SNUserLocationManager.h"
#import "SNNewsNotificationManager.h"
#import "SNThirdPartRequestManager.h"
#import "SNStatisticsManager.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNAppConfigManager.h"
#import "TMCache.h"
#import "SNUserManager.h"
#import "SNLocalChannelService.h"
#import "SNNewsAd+analytics.h"
#import "SNUserLocationManager.h"
#import "SNAdvertiseManager.h"
#import "SNRedPacketManager.h"
#import "SNAdManager.h"
#import "SNNovelUtilities.h"
#import "NSObject+YAJL.h"
#import "SNClientRegister.h"
#import "SNSearchHotV6Request.h"
#import "SNNewsChannelType.h"

//线程函数中需要用到self.channelId, 这个值可能随时在外部修改，
//所以传入前copy到线程函数参数中，避免线程函数内部使用已被释放的channelId
#define kChannelIdCopy              @"channelIdCopy"

#define kTopicDefaultNews           @"defaultNews"
#define kTopicEditNewsLoadMore      @"editLoadMore"
#define kExposureRequestInterval    20 * 60
#define kCacheNewsNumber            20         //缓存新闻条数

@implementation SNRollingNewsModel
@synthesize channelId = _channelId, isLoadingNewChannel;
@synthesize channelIdForPromotion;
@synthesize more = _more;
@synthesize timelineWhenViewReleased;
@synthesize page=_page;
@synthesize shareContent = _shareContent;
@synthesize recommendNews = _recommendNews;
@synthesize isLoadRecommend = _isLoadRecommend;
@synthesize ctx;
@synthesize tracker;
@synthesize isSection;
@synthesize sectionsArray;
@synthesize cursor;
@synthesize topNewsList = _topNewsList;
@synthesize topNewsIndex = _topNewsIndex;
@synthesize subId = _subId;
@synthesize messageDic = _messageDic;
@synthesize topNewsCnt,curTopNewsCnt;

- (id)initWithChannelId:(NSString *)channelId {
	if (self = [super init]) {
        isPreload = YES;
        isLoadingNews = NO;
		self.channelId = channelId;
        self.rollingNews = [NSMutableArray array];
        self.recommendNews = [NSMutableArray array];
        self.topNewsList = [NSMutableArray array];
        self.topNewsIndex = 0;
	}
	return self;
}

- (BOOL)isHomePage {
    BOOL isHome = NO;
    if (self.channelId &&
        [self.channelId isEqualToString:@"1"]) {
        isHome = YES;
    }
    return isHome;
}

- (BOOL)isNewHomePage {
    return [self isHomePage] && self.isMixStream == NewsChannelEditAndRecom;
}

- (BOOL)isLoadingTrainList {
    return [self isNewHomePage] && ([self getAction] == 3);
}

- (BOOL)isHomeEidtPage {
    return [self isHomePage];
}

- (BOOL)isRecommendPage {
    BOOL isRecommend = NO;
    if (self.channelId &&
        [self.channelId isEqualToString:@"13557"]) {
        isRecommend = YES;
    }
    
    return isRecommend;
}

- (BOOL)isRecomendNewChannel {
    if (self.isHomePage) {
        return NO;
    }
    
    return self.isNewChannel;
}

- (BOOL)shouldResetNewChannel {
    return [self isRecomendNewChannel] && times == 0;
}

/**
 判断是否为推荐流

 @return BOOL
 */
- (BOOL)isHomeRecommendPage {
    BOOL isRecommendChannel = NO;
    if (self.channelId &&
        [self.channelId isEqualToString:@"13557"]) {
        isRecommendChannel = YES;
    }
    return isRecommendChannel;
}

- (BOOL)showHomeRecommendPage {
    return [self isHomeRecommendPage];
}

- (BOOL)isChannelAction {
    //频道跳转
    if (self.link != nil && [self.link length] > 0) {
        if ([self.link hasPrefix:@"channel://"]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)cancel {
	isCancelLoading = YES;
	if (_request) {
		[_request cancel];
        [_request.delegates removeObject:self];
	}
}

+ (void)updateNewsWithNews:(SNRollingNews *)news {
    @synchronized (self) {
        if (news) {
            dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                NSArray *newsArray = [NSArray arrayWithObject:news];
                [[SNDBManager currentDataBase] addMultiRollingNewsListItem:[self createRollingNewsListItems:newsArray] updateIfExist:YES];
            });
        }
    }
}

- (void)deleteNewsWithNews:(SNRollingNews *)news {
    if (news) {
        if ([self.recommendNews containsObject:news]) {
            [self.recommendNews removeObject:news];
        }
        if ([self.rollingNews containsObject:news]) {
            [self.rollingNews removeObject:news];
        }
        if (news.isTopNews == YES && [self.topNewsList containsObject:news]) {
            [self.topNewsList removeObject:news];
        }
    }
}

- (BOOL)isLoadingMore {
    return _more;
}

- (BOOL)isEditLoadingMore {
    return isEditLoadMore;
}

- (NSString *)getCursorFromRollingNews {
    NSString *cursorString = @"";
    for (NSUInteger i = [_rollingNews count] - 1; i < [_rollingNews count]; i--) {
        SNRollingNews *news = [_rollingNews objectAtIndex:i];
        if (news.cursor.length > 0) {
            cursorString = news.cursor;
            break;
        }
    }
    return cursorString;
}

- (BOOL)loadMoreEditNewsWithPage:(int)pageNum {
    if (isLoadingNews) {
        return NO;
    }
    
    _more = YES;
    _page = pageNum;
    isEditLoadMore = YES;
    self.isLoadRecommend = NO;
    self.cursor = nil;
    
    NSString *prefixURL = self.isNewChannel ? kUrlRollingNewsListJsonV6 : kUrlRollingNewsListJsonPrefix;
    NSString *url = [NSString stringWithFormat:prefixURL];
    url = [url stringByAppendingFormat:@"channelId=%@&", _channelId];
    if (self.isNewChannel) {
        NSString *urlParams = kUrlRollingNewsParamsV6;
        url = [url stringByAppendingFormat:urlParams, KPaginationNum, _page];
    } else {
        url = [url stringByAppendingFormat:kUrlRollingNewsParams, KPaginationNum, _page];
        if ([_channelId isEqualToString:@"351"] ||
            [_channelId isEqualToString:@"4"]) {
            //股票、财经频道
            NSString *lastCurStr = [[NSUserDefaults standardUserDefaults]
                                    objectForKey:kFinanceLastCursorKey];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kClickIntelligentOfferKey]) {
                NSString *curStr = [[NSUserDefaults standardUserDefaults]
                                    objectForKey:kFinanceCursorKey];
                lastCurStr = curStr;
                if (curStr.length > 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:curStr forKey:kFinanceLastCursorKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            url = [url stringByAppendingFormat:@"&curCursor=%@", lastCurStr];
        }
    }
    
    url = [url stringByAppendingFormat:@"&morePage=%d", pageNum];
    [self loadNewsRequestWithUrl:url isSynch:YES topic:kTopicEditNewsLoadMore];
    return YES;
}

- (BOOL)homeRefreshHandle {
    BOOL isContinue = YES;
    //强制刷新时不走时间逻辑
    if ([SNRollingNewsPublicManager sharedInstance].resetOpen) {
        if ([self isHomeEidtPage]) {
            action = 0;
        }
        self.isLoadRecommend = NO;
        [[SNRollingNewsPublicManager sharedInstance] recordLeaveHomeTime];
    } else {
        //频道左划时，首页不提前请求数据
        if ([SNRollingNewsPublicManager sharedInstance].refreshClose) {
            [SNRollingNewsPublicManager sharedInstance].refreshClose = NO;
            self.isRefreshFromDrag = YES;
            isContinue = NO;
        }
    }
    
    return isContinue;
}

- (void)request:(BOOL)bASyn {
    if (![SNUtility isRightP1]) {
        [[SNClientRegister sharedInstance] registerClientAnyway];
    }
    
    if (isLoadingNews) {
        if ([self isHomePage] &&
            [SNRollingNewsPublicManager sharedInstance].resetOpen) {
            [self cancel];
        } else {
            if ([self isHomePage]) {
                if ([SNRollingNewsPublicManager sharedInstance].newsTableClick) {
                    [SNRollingNewsPublicManager sharedInstance].newsTableClick = NO;
                }
            }
            return;
        }
    }
    
    //网络请求成功后，缓存请求参数 wyy 这块代码Page不能赋值
//    _page = [SNRollingNewsPublicManager sharedInstance].pageNum;
//    times = [SNRollingNewsPublicManager sharedInstance].times;
    _page = [SNRollingNewsPublicManager readRollingPageWithChannelId:self.channelId];
    times = [SNRollingNewsPublicManager readRollingTimesWithChannelId:self.channelId];
    isEditLoadMore = NO;
    
    if (times == 0 && ([self isHomePage] || [self isRecommendPage])) {
        [self loadHotSearchWords];
    }
    
    if (!_more) {
        if (!self.isRefreshFromDrag && ![self isRecomendNewChannel]) {
            if (([self isHomePage] && self.showRecommend == NO) ||
                [self isChannelAction] || [self isLocalChannel]) {
                _page = 0;
            }
            action = 0;
            self.isLoadRecommend = NO;
        } else {
            _page = 0;
            action = 1;
            self.isLoadRecommend = YES;
            if ([self showHomeRecommendPage]) {
                [SNRollingNewsPublicManager sharedInstance].newsMode = SNRollingNewsModeV6;
            }
        }
    } else {
        action = 2;
        self.isLoadRecommend = NO;
    }
    
    self.cursor = _more ? [self getCursorFromRollingNews] : @"0";
    if ([self isHomePage]) {
        if (!_more) {
            BOOL isContinue = [self homeRefreshHandle];
            if (!isContinue) {
                return;
            }
        }
    }
    
    //娱乐频道重置获取焦点图
    if ([self shouldResetNewChannel]) {
        _page = 0;//后边会page+1
        [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:0 channelId:self.channelId];
    }
    
    if ([self isRecomendNewChannel] && times != 0 ) {
        if (self.rollingNews.count > 0) {
            SNRollingNews *news = [self.rollingNews objectAtIndex:0];
            if ([news isMoreFocusNews]) {
                [SNNotificationManager postNotificationName:kShowFirstPageNotification object:nil];
            }
        }
    }

    NSString *prefixURL = self.isNewChannel ? kUrlRollingNewsListJsonV6 : kUrlRollingNewsListJsonPrefix;
    if (!self.isNewChannel &&
        ([_channelId isEqualToString:@"351"] ||
         [_channelId isEqualToString:@"4"])) {
        //股票、财经频道
        NSString *lastCurStr = [[NSUserDefaults standardUserDefaults] objectForKey:kFinanceLastCursorKey];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kClickIntelligentOfferKey]) {
            NSString *curStr = [[NSUserDefaults standardUserDefaults] objectForKey:kFinanceCursorKey];
            lastCurStr = curStr;
            if (curStr.length > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:curStr forKey:kFinanceLastCursorKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        prefixURL = [prefixURL stringByAppendingFormat:@"&curCursor=%@&", lastCurStr];
    }
    NSString *url = @"";
    url = [NSString stringWithFormat:prefixURL];
    url = [self addPrefixParametersWithUrl:url];
    [self loadNewsRequestWithUrl:url isSynch:bASyn topic:kTopicDefaultNews];
    
    //5.3 股票频道刷新标志
    [SNRollingNewsPublicManager sharedInstance].refreshStock = NO;
}

- (NSString *)addHomeParameterWithUrl:(NSString *)url {
    if ([self isHomePage]) {
        url = [[SNRollingNewsPublicManager sharedInstance] addParameterWithUrl:url];
    }
    return url;
}

- (NSString *)addPrefixParametersWithUrl:(NSString *)url {
    //频道跳转URL处理
    if (self.link != nil && [self.link length] > 0) {
        if ([self.link hasPrefix:@"channel://"]) {
            NSString *linkStr = [self.link  stringByReplacingOccurrencesOfString:@"channel://" withString:@""];
            if (linkStr.length > 0) {
                url = [url stringByAppendingFormat:@"%@&", linkStr];
            } else {
                url = [url stringByAppendingFormat:@"channelId=%@&", _channelId];
            }
        }
        self.link = nil;
    } else {
        url = [url stringByAppendingFormat:@"channelId=%@&", _channelId];
    }
    
    if (self.isNewChannel) {
        NSString *urlParams = kUrlRollingNewsParamsV6;
        url = [url stringByAppendingFormat:urlParams, KPaginationNum, _page + 1];
    } else {
        if (action == 0) {
            _page = 0;
        }
        //股票频道重置
        int pageNum = [SNRollingNewsPublicManager sharedInstance].refreshStock ? 1 :(_page + 1);
        url = [url stringByAppendingFormat:kUrlRollingNewsParams, KPaginationNum, pageNum];
    }
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)addAllParametersWithUrl:(NSString *)url {
    SNRollingNewsPublicManager *newsPublicManager = [SNRollingNewsPublicManager sharedInstance];
    //为了区分频道新闻请求的来源 需要加一个from参数
    //by jojo on 2013-12-26
    NSString *fromString = self.isFromSub ? @"sub" : @"channel";
    url = [url stringByAppendingFormat:@"&from=%@", fromString];
    
    if (!self.isNewChannel) {
        if (self.isLoadRecommend) {
            url = [url stringByAppendingFormat:@"&pull=1"];
        } else {
            url = [url stringByAppendingFormat:@"&pull=0"];
        }
    }
    
    NSString *focusPosition;
    if (_isPullRefresh) {
        focusPosition = [newsPublicManager getFocusPositionWithChannelId:self.channelId];
    } else {
        focusPosition = @"1";
        [newsPublicManager saveFocusPosition:focusPosition
                               withChannelId:self.channelId];
    }

    if (newsPublicManager.resetOpen) {
        focusPosition = @"1";
    }
    if (focusPosition.length > 0) {
        url = [url stringByAppendingFormat:@"&focusPosition=%@", focusPosition];
    }
    
    //添加首页特有参数
    url = [self addHomeParameterWithUrl:url];
        
    if (self.tracker.length) {
        url = [url stringByAppendingFormat:@"&tracker=%@", [self.tracker URLEncodedString]];
    }
    if (self.ctx.length) {
        url = [url stringByAppendingFormat:@"&ctx=%@", [self.ctx URLEncodedString]];
    }
    if (self.cursor && self.cursor.length > 0) {
        url = [url stringByAppendingFormat:@"&cursor=%@", self.cursor];
    }
    
    //==========v6接口参数 Begin===============//
    url = [url stringByAppendingFormat:@"&times=%d", times];
    
    //广告上滑、下滑参数
    if ([self isHomePage] || [self isLocalChannel]) {
        if ([self isLocalChannel]) {
            if (newsPublicManager.localADCount == 0) {
                newsPublicManager.localADCount += 1;
            }
            url = [url stringByAppendingFormat:@"&rr=%d", newsPublicManager.localADCount];
        } else {
            if ([self isNewHomePage]) {
                if (newsPublicManager.homeADCount == 0) {
                    newsPublicManager.homeADCount += 1;
                }
                url = [url stringByAppendingFormat:@"&rr=%d", newsPublicManager.homeADCount];
            } else {
                if (newsPublicManager.homeADCount == 0) {
                    if (newsPublicManager.isRecommendAfterEditNews ||
                        !newsPublicManager.isRollingEditNewsShow) {
                        newsPublicManager.homeADCount += 1;
                    }
                }
                
                if (newsPublicManager.homeADCount > 0) {
                    if (newsPublicManager.isRecommendAfterEditNews &&
                        !newsPublicManager.isRollingEditNewsShow) {
                        url = [url stringByAppendingFormat:@"&rr=%d", newsPublicManager.homeADCount];
                        newsPublicManager.homeADCount += 1;
                    }
                }
            }
        }
    }
    
    if ([self.channelId isEqualToString:@"13557"]) {
        if (newsPublicManager.recomADCount == 0) {
            newsPublicManager.recomADCount += 1;
        }
        url = [url stringByAppendingFormat:@"&rr=%d", newsPublicManager.recomADCount];
    }
    
    if ([self.channelId isEqualToString:@"3"] || [self.channelId isEqualToString:@"960513"]) {
        url = [url stringByAppendingFormat:@"&rr=%d", newsPublicManager.entertainmentADCount];
    }
    
    if (self.isNewChannel) {
        url = [url stringByAppendingFormat:@"&action=%d", action];
        url = [url stringByAppendingFormat:@"&subId=%d", self.subId];
        if ([self isLocalChannel] && self.rollingNews.count == 0) {
            url = [url stringByAppendingFormat:@"&contentToken=%@", kDefaultContentToken];
            [newsPublicManager saveContentToken:kDefaultContentToken withChannelId:self.channelId];
        } else {
              url = [url stringByAppendingFormat:@"&contentToken=%@", [newsPublicManager getContentTokenWithChannelId:self.channelId]];
        }
        
//        int forceRefresh = 0;
//        if ([self shouldResetNewChannel] || self.rollingNews.count == 0) {
//            forceRefresh = 1;
//        } else {
//            BOOL toRefresh = ![SNUserDefaults boolForKey:kChannelforceRefreshKey];
//            if ([self showHomeRecommendPage] && toRefresh) {
//                forceRefresh = 1;
//                [SNUserDefaults setBool:YES forKey:kChannelforceRefreshKey];
//            }
//        }
        
        int forceRefresh = [self getParamForceRefresh];
        if ([self showHomeRecommendPage]) {
            [SNRollingNewsPublicManager sharedInstance].isRecomForceRefresh = forceRefresh;
        }
        url = [url stringByAppendingFormat:@"&forceRefresh=%d", forceRefresh];
    }
    url = [url stringByAppendingFormat:@"&isMixStream=%d", self.isMixStream];
    if ([self isNewHomePage]) {
        url = [url stringByAppendingFormat:@"&isFirst=%d",  [SNNewsFullscreenManager isFirstOpenAppToday]];
        //测试 
        //url = [url stringByAppendingFormat:@"&isFirst=1"];
    }
    if (self.isMixStream == 2 && [SNNewsFullscreenManager isFirstOpenAppToday]) {
        url = [url stringByAppendingFormat:@"&picScale=%d", 18]; //全屏焦点图传18  2017.11.27
    } else {
        url = [url stringByAppendingFormat:@"&picScale=%d", 11];
    }
    if (self.isNewChannel || [self isHomePage]) {
        url = [url stringByAppendingFormat:@"&mode=%d", [newsPublicManager getNewsModeNum]];
    }
    
    url = [url stringByAppendingFormat:@"&source=%d&categoryId=%@", newsPublicManager.newsSource, [SNUtility sharedUtility].currentChannelCategoryID];
    newsPublicManager.newsSource = SNRollingNewsSourceDefault;
    [SNUtility sharedUtility].currentChannelCategoryID = nil;
    url = [url stringByAppendingFormat:@"&apiVersion=%d&u=1", APIVersion];
    if (!self.isNewChannel && ![url containsString:@"action="]) {
        url = [url stringByAppendingFormat:@"&action=%d", action];
    }
    
    NSString *newsId = [SNRollingNewsPublicManager sharedInstance].channelProtocolNewsID;
    if (newsId.length > 0) {
        url = [url stringByAppendingFormat:@"&newsId=%@", newsId];
    }
    
    //==========v6接口参数 End===============//
    //红包参数
    if (![[SNRedPacketManager sharedInstance] showRedPacketActivityTheme]) {
        url = [url stringByAppendingFormat:@"&isSupportRedPacket=%d", 0];
    } else {
        url = [url stringByAppendingFormat:@"&isSupportRedPacket=%d", 1];
    }
    
    //密钥
    url = [url stringByAppendingFormat:@"&skd=%@&v=%@&t=%@", [[SNRedPacketManager sharedInstance] getEncryptData], [[SNRedPacketManager sharedInstance] getKeyVersion], [[SNRedPacketManager sharedInstance] getKeyTime]];
    
    SNUserLocationManager *locationManager = [SNUserLocationManager sharedInstance];
    NSString *locationString = [locationManager getNewsLocationString];
    if (locationString) {
        url = [url stringByAppendingFormat:@"&%@", locationString];
    }
    
    NSString *reachStatus = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
    if (reachStatus && ![reachStatus isEqualToString:@""]) {
        url = [url stringByAppendingFormat:@"&net=%@", reachStatus];
    }
    
    //按需求，添加abtest参数
    url = [url stringByAppendingFormat:@"&abt=%d", [SNUtility AbTestAppStyle]];
    if (self.isMixStream != NewsChannelEdit) {
        url = [url stringByAppendingFormat:@"&actiontype=%d", [SNRollingNewsPublicManager sharedInstance].userAction];
    }
    
    return url;
}

- (int)getParamForceRefresh{
    //强制刷新逻辑： 流式频道，如果当前缓存为0， 需要重置；如第一次启动。或服务端不再返回数据；娱乐频道1小时后，或第二天6点需要重置
    if ([self shouldResetNewChannel] || self.rollingNews.count == 0) {
        return 1;
    }
    
    BOOL toRefresh = ![SNUserDefaults boolForKey:kChannelforceRefreshKey];
    if ([self showHomeRecommendPage] && toRefresh) {
        [SNUserDefaults setBool:YES forKey:kChannelforceRefreshKey];
        return 1;
    }

    
    return 0;
}

- (void)loadNewsRequestWithUrl:(NSString *)url
                       isSynch:(BOOL)isSyn
                         topic:(NSString *)topicString {
    self.loadMoreTopicString = topicString;
    url = [self addAllParametersWithUrl:url];
    url = [SNAdManager urlByAppendingAdParameter:url];//拼接一些设备id的参数广告需要
    [self.request cancel];
    self.request = [SNURLRequest requestWithURL:url delegate:self isParamP:YES scookie:YES isV6:self.isNewChannel];
    
    if (isRefreshManually || _more) {
        _request.isShowNoNetWorkMessage = YES;
    } else {
        _request.isShowNoNetWorkMessage = NO;
    }
    
    if ([SNUtility isRightP1]) {
        [SNUtility sharedUtility].isWrongP1RequestNewsList = NO;
    }
    else {
        [SNUtility sharedUtility].isWrongP1RequestNewsList = YES;
    }
    
	_request.response = [[TTURLDataResponse alloc] init];
    _request.userInfo = [TTUserInfo topic:topicString strongRef:nil weakRef:nil];
    _request.timeOut = 20;

	if (isSyn) {
		[_request send];
	} else {
		[_request sendSynchronously];
	}
    
    self.isRefreshFromDrag = YES;
    isLoadingNews = YES;
}

- (SNRollingNews *)createNewsByItem:(RollingNewsListItem *)item {
    SNRollingNews *news = [[SNRollingNews alloc] init];
    news.channelId = item.channelId;
    news.newsId = item.newsId;
    news.newsType = item.type;
    news.from = item.form;
    news.time = item.time;
    news.title = item.title;
    news.digNum = item.digNum;
    news.commentNum = item.commentNum;
    news.abstract = item.description;
    news.link = item.link;
    news.picUrl = item.listPic;
    news.isRead = [@"1" isEqualToString:item.readFlag];
    news.listPicsNumber = item.listPicsNumber;
    news.timelineIndex = item.timelineIndex;
    news.hasVideo = item.hasVideo;
    news.hasAudio = item.hasAudio;
    news.hasVote = item.hasVote;
    news.updateTime = item.updateTime;
    news.from = item.form;
    news.recomDay = item.recomIconDay;
    news.recomNight = item.recomIconNight;
    news.media = item.media;
    news.isWeather = item.isWeather;
    news.city = item.city;
    news.tempLow = item.tempLow;
    news.tempHigh = item.tempHigh;
    news.weather = item.weather;
    news.pm25 = item.pm25;
    news.quality = item.quality;
    news.weatherIoc = item.weatherIoc;
    news.wind = item.wind;
    news.gbcode = item.gbcode;
    news.date = item.date;
    news.localIoc = item.localIoc;
    news.isRecom = item.isRecom;
    news.recomType = item.recomType;
    news.liveStatus = item.liveStatus;
    news.local = item.local;
    news.thirdPartUrl = item.thirdPartUrl;
    news.templateId = item.templateId;
    news.templateType = item.templateType;
    news.playTime = item.playTime;
    news.liveType = item.liveType;
    news.isFlash = item.isFlash;
    news.token = item.token;
    news.position = item.position;
    news.fromSub = self.isFromSub;
    news.statsType = item.newsStatsType;
    news.adType = item.adType;
    news.adAbPosition = item.adAbPosition;
    news.adPosition = item.adPosition;
    news.refreshCount = item.refreshCount;
    news.loadMoreCount = item.loadMoreCount;
    news.scope = item.scope;
    news.appChannel = [NSString stringWithFormat:@"%d", item.appChannel];
    news.newsChannel = [NSString stringWithFormat:@"%d", item.newsChannel];
    news.morePageNum = item.morePageNum;
    news.iconText = item.iconText;
    news.newsTypeText = item.newsTypeText;
    news.cursor = item.cursor;
    news.isHasSponsorships = item.isHasSponsorships;
    news.adReportState = item.adReportState;
    news.isTopNews = item.isTopNews;
    news.weak = item.weak;
    news.liveTemperature = item.liveTemperature;

    //组图频道有可能是外链，templateType＝2肯定为组图
    if ([kNewsTypeGroupPhoto isEqualToString:item.type] ||
        [news isGroupPhotoNews]) {
        @autoreleasepool {
            news.picUrls = [item.listPic componentsSeparatedByString:kParameterSeparator];
            if ([news.picUrls count]) {
                news.picUrl = [news.picUrls objectAtIndex:0];
            }
        }
    } else {
        news.picUrl = item.listPic;
    }
    
    if (item.dataString.length >0) {
        [news setDateStringWithJson:item.dataString];
    }
    
    //冠名
    [news setSponsorshipsWithJson:item.sponsorships];
    news.subId = item.subId;
    
    //红包
    news.bgPic = item.bgPic;
    news.sponsoredIcon = item.sponsoredIcon;
    news.redPacketTitle = item.redPacketTitle;
    news.redPacketId = item.redPacketID;
    
    news.tvPlayTime = item.tvPlayTime;
    news.tvPlayNum = item.tvPlayNum;
    news.playVid = item.playVid;
    news.tvUrl = item.tvUrl;
    news.sourceName = item.sourceName;
    news.siteValue = item.siteValue;
    news.recomReasons = item.recomReasons;
    news.recomTime = item.recomTime;
    news.blueTitle = item.blueTitle;
    news.recomInfo = item.recomInfo;
    news.createAt = item.createAt;

    return news;

}

- (void)readCacheFromDatabase {
    if (!_more) {
        [self.rollingNews removeAllObjects];
        self.rollingNews = [NSMutableArray array];
        
        [self.recommendNews removeAllObjects];
        self.recommendNews = [NSMutableArray array];
        
        [self.topNewsList removeAllObjects];
        self.topNewsList = [NSMutableArray array];
    }
    
    SNRollingNews *last = [self.rollingNews lastObject];
    NSString *timelineIndex = last ? last.timelineIndex : nil;
    
    //rolling news
    NSString *lChannelId = self.channelId;
    NSMutableArray *newsList = [NSMutableArray arrayWithArray:[[SNDBManager currentDataBase] getRollingNewsListNextPageByChannelId:lChannelId timelineIndex:timelineIndex]];

    if ([newsList count] == 1) {
        [[SNDBManager currentDataBase] clearRollingEditNewsListByChannelId:lChannelId];
        [newsList removeAllObjects];
    }
    
    [SNRollingNewsPublicManager sharedInstance].isClickBackToHomePage = NO;
    
    //判断是否第一次进入频道流
    BOOL isFisrtEnterChannel = [[SNAppStateManager sharedInstance] appFinishLaunchLoadNewsWithChannelId:lChannelId];
    
    SNRollingNews *funcNews = nil;
    SNRollingNews *focusNews = nil;
    BOOL addFocus = NO;
    SNRollingNews *topAdNews = nil;
    for (RollingNewsListItem *item in newsList) {
        SNRollingNews *news = [self createNewsByItem:item];
    
        if (isFisrtEnterChannel) {
            if ([news.templateType isEqualToString:@"76"]) {
                continue;
            }
        } else {
            //置顶广告
            if ([news.templateType isEqualToString:@"76"]) {
                if (!topAdNews) {
                    topAdNews = [self creatTopAdNews:[NSMutableArray array]];
                }
                [topAdNews.topAdNews addObject:news];
                continue;
            }
            
            if (topAdNews) {
                [self.rollingNews addObject:topAdNews];
                topAdNews = nil;
            }
        }
        
        //处理焦点图轮播新闻
        if ([item.form isEqualToString:kRollingNewsFormFocus]) {
            if (focusNews == nil) {
                focusNews = news;
                focusNews.templateType = @"28";
                focusNews.newsFocusArray = [NSMutableArray array];
            }
            [focusNews.newsFocusArray addObject:news];
        }
        else {
            @autoreleasepool {
                //娱乐频道焦点图如果出现在第一位或中间位置的时候
                if ([self isRecomendNewChannel] && addFocus == NO && focusNews != nil) {
                    [self.rollingNews addObject:focusNews];
                    addFocus = YES;
                }
                
                if (news.isTopNews == 1) {
                    [self.topNewsList addObject:news];
                } else {
                    if ([news.templateType isEqualToString:@"27"] ||
                        [news.templateType isEqualToString:@"30"]) {
                        funcNews = news;
                    } else {
                        [self.rollingNews addObject:news];
                    }
                }
            }
        }
    }
    
    if ([self hasTopNews] && self.topNewsList.count > self.topNewsIndex) {
        if (self.rollingNews.count > 0) {
            SNRollingNews *news = [self.rollingNews objectAtIndex:0];
            if (!news.isMoreFocusNews) {
                NSString *key = [NSString stringWithFormat:@"%@_%@", kTopCount, self.channelId];
                self.topNewsCnt = [SNUserDefaults integerForKey:key];
                //容错机制
                if (self.topNewsList.count != 0 && self.topNewsCnt == 0) {
                    self.topNewsCnt = 1;
                }
                self.curTopNewsCnt = self.topNewsCnt;
                
                NSArray *showTopNewList = [self getNeedShowTopNewsList];
                NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, showTopNewList.count)];
                [self.rollingNews insertObjects:showTopNewList atIndexes:indexes];
                
            }
        }
    }
    
    if (topAdNews) {
        if (times == 0 && _page == 0 &&
            [self.channelId isEqualToString:kLocalChannelUnifyID]) {
            if ([self.rollingNews containsObject:topAdNews]) {
            }
        }
    }
    
    if (funcNews != nil) {
        [self.rollingNews insertObject:funcNews atIndex:0];
    }
    
    if (focusNews != nil) {
        if ([self isRecomendNewChannel]) {
            //频道焦点图如果出现在最后一位的时候
            if (addFocus == NO) {
                [self.rollingNews addObject:focusNews];
            }
        } else {
            [self.rollingNews insertObject:focusNews atIndex:0];
        }
    }
   
    if (newsList.count > 0) {
        self.hasNoMore = NO;
        [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellLoadMore;
    }
}

- (void)setNewsAsRead:(NSString *)newsId {
    for (SNRollingNews *news in self.rollingNews) {
        if ([newsId isEqualToString:news.newsId]) {
            news.isRead = YES;
            return;
        }
    }
}

- (void)requestDidFinishLoad {
    if (self.isNewChannel) {
        if (self.rollingNews.count == 1) {
            SNRollingNews *news = [self.rollingNews objectAtIndex:0];
            if ([news.templateType isEqualToString:@"27"] ||
                [news.templateType isEqualToString:@"30"]) {
                [self.rollingNews removeAllObjects];
            }
        }
    }
    if ([self.rollingNews count] == 0) {
        self.rollingNews = [NSMutableArray arrayWithArray:self.recommendNews];
    }
    [self processTopNews];
    
    //2017-12-14 wangchuanwen add
    //小说书架入口数据不是来自news.go，是仿照news.go数据，在首位强行插入一条
    if (([self.channelId isEqualToString:@"13555"] || [self.channelId isEqualToString:@"960415"])) {
        
        //确保书架入口在第一行
        if (self.rollingNews && self.rollingNews.count > 0) {
            SNRollingNews *firstNews = self.rollingNews[0];
            if (![firstNews.title isEqualToString:[SNNovelUtilities shelfDataTitle]]) {
                
                [self.rollingNews insertObject:[self shelf] atIndex:0];
            }
        }else{
            [self.rollingNews addObject:[self shelf]];
        }
    }
    //2017-12-14 wangchuanwen add end
    
    [super requestDidFinishLoad:nil];
    self.isRecreate = NO;
}

//2017-12-14 wangchuanwen add
#pragma mark - 小说的书架入口
-(SNRollingNews *)shelf
{
    //小说的书架入口
    SNRollingNews *news = [[SNRollingNews alloc]init];
    news.from = kRollingNewsFormCommon;
    news.channelId = self.channelId;
    news.title = [SNNovelUtilities shelfDataTitle];
    news.newsId = @"";
    news.channelId = @"";
    news.templateType = @"19";
    return news;
}
//2017-12-14 wangchuanwen add end

- (void)processTopNews {
    //处理置顶新闻
    if (self.shouldDeleteTopNews) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.rollingNews];
        NSInteger index = 0;
        for (SNRollingNews *rollingNews in self.rollingNews) {
            if (rollingNews.isTopNews) {
                SNRollingNews *tempRollingNews = [tempArray objectAtIndex:index];
                [tempArray removeObject:tempRollingNews];
            }
            index++;
        }
        
        self.rollingNews = [NSMutableArray arrayWithArray:tempArray];
        
        NSString *lChannelId = self.channelId;
        [[SNDBManager currentDataBase] clearAllTopRollingNewsList:lChannelId];
    }
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    if ([SNUtility isFirstInstallOrUpdateApp]) {
        //首次安装启动App同步List.go
        return;
    }
    //火车卡片加载中，加载频道流，火车请求cancel
    if ([self isLoadingTrainList] && isLoadingNews) {
        isLoadingNews = NO;
        [self cancel];
    }

    if (!isLoadingNewChannel &&
        self.isLoading &&
        ![self isLoadingTrainList]) {
        if ([SNRollingNewsPublicManager sharedInstance].resetOpen) {
            [SNRollingNewsPublicManager sharedInstance].resetOpen = NO;
        }
        return;
    }
    
    isCancelLoading = NO;
    _more = more;
    self.hasNoMore = NO;
    self.isPreloadChannel = _more ? NO : self.isPreloadChannel;
    self.isPreloadChannel = _isPullRefresh ? NO : self.isPreloadChannel;
    //刷新要闻频道的时候刷新一下气泡
    if ([_channelId intValue] == 1 && more == NO && cachePolicy != TTURLRequestCachePolicyLocal) {
        self.isSection = YES;
    }
    
    if (TTURLRequestCachePolicyLocal == cachePolicy) {
        [self readCacheFromDatabase];
        _page = 0;
        _isCacheModel = YES;
        if (self.rollingNews.count > 0) {
            //因为这个方法，每次启动进入推荐流都会强制刷新，现有逻辑这个代码应该没啥用了，先注释调
            /*if ((![SNRollingNewsPublicManager sharedInstance].appLaunch && ![SNUtility shouldShowEditMode]) || [self.rollingNews count] == 1) {
                if ([SNUtility getApplicationDelegate].isNetworkReachable) {
                    [self.rollingNews removeAllObjects];
                }
            }*/
            
            self.hasNoMore = NO;
            [self requestDidFinishLoad];
        } else {
            //列表为空
            [self requestDidFinishLoad];
        }
        
        //应用启动首页必须刷新
        if (![SNRollingNewsPublicManager sharedInstance].appLaunch && ![SNNewsFullscreenManager newsChannelChanged]) {
            [SNRollingNewsPublicManager sharedInstance].appLaunch = YES;
            [self request:YES];
            [SNRollingNewsPublicManager deleteReadTimeOutNews];
        }
    } else {
        //无网络不发送请求
        if (![[SNUtility getApplicationDelegate]
              isCurrentNetworkReachable]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            if ([self isHomePage] &&
                [SNRollingNewsPublicManager sharedInstance].resetOpen) {
                [SNRollingNewsPublicManager sharedInstance].resetOpen = NO;
            }
            if (!_more) {
                [[SNAppStateManager sharedInstance] loadedChannelNewsWith:self.channelId];
            }
            [self requestDidFinishLoad];
            return;
        }
        if (self.rollingNews.count > 0) {
            self.hasNoMore = NO;
        } else {
            //做处理
        }
        
        NSString *key = self.channelId;
        [[SNRollingNewsPublicManager sharedInstance] readRequestParamsWithChannelId:key];
        [self request:YES];
    }
}

//本地频道置顶广告数据重新组装
- (SNRollingNews *)creatTopAdNews:(NSMutableArray *)topAdNews {
    SNRollingNews *news = [[SNRollingNews alloc] init];
    news.topAdNews = topAdNews;
    news.newsId = @"0";
    news.templateType = @"76";
    return news;
}

- (SNRollingNews *)createNews:(NSDictionary *)data
                         from:(NSString *)from {
    SNRollingNews *news = [[SNRollingNews alloc] init];
    news.channelId = self.channelId;    
    news.newsId = [data stringValueForKey:kNewsId defaultValue:@""];
    news.newsType = [data stringValueForKey:kNewsType defaultValue:@""];
    news.time = [data stringValueForKey:kTime defaultValue:@""];
    news.title = [data stringValueForKey:kTitle defaultValue:@""];
    news.digNum = [data stringValueForKey:kDigNum defaultValue:@""];
    news.commentNum = [data stringValueForKey:kCommentNum defaultValue:@""];
    news.abstract = [data stringValueForKey:kDesc defaultValue:@""];
    news.link = [data stringValueForKey:kNewsLink2 defaultValue:@""];
    news.picUrl = [data objectForKey:kListPic];
    news.listPicsNumber = [data stringValueForKey:kListPicsNumber defaultValue:@""];
    news.hasVideo = [data stringValueForKey:kIsHasTV defaultValue:@""];
    news.hasAudio = [data stringValueForKey:kIsHasAudio defaultValue:@""];
    news.hasVote = [data stringValueForKey:kIsHasVote defaultValue:@""];
    news.updateTime = [data stringValueForKey:kUpdateTime defaultValue:@""];
    news.recomDay = [data stringValueForKey:kRecomDay defaultValue:@""];
    news.recomNight = [data stringValueForKey:kRecomNight defaultValue:@""];
    news.media = [data stringValueForKey:kNewsMedia defaultValue:@""];
    news.isWeather = [data stringValueForKey:kIsWeather defaultValue:@""];
    news.isRecom = [data stringValueForKey:kIsRecom defaultValue:@""];
    news.recomType = [data stringValueForKey:kRecomType defaultValue:@""];
    news.liveStatus = [data stringValueForKey:kLiveStatus defaultValue:@""];
    news.local = [data stringValueForKey:kLocal defaultValue:@""];
    news.thirdPartUrl = [data stringValueForKey:kThirdPartUrl defaultValue:@""];
    news.templateId = [data stringValueForKey:kTemplateId defaultValue:@""];
    news.templateType = [data stringValueForKey:kTemplateType defaultValue:@"1"];
    news.playTime = [data stringValueForKey:kPlayTime defaultValue:@""];
    news.liveType = [data stringValueForKey:kLiveType defaultValue:@""];
    news.isFlash = [data stringValueForKey:kIsFlash defaultValue:@"0"];
    news.position = [data stringValueForKey:kPos defaultValue:@""];
    news.from = from;
    news.fromSub = self.isFromSub;
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
    news.isPush = NO;
    news.tvPlayNum = [data stringValueForKey:@"tvPlayNum" defaultValue:@""];
    news.tvPlayTime = [data stringValueForKey:@"tvPlayTime" defaultValue:@""];
    news.playVid = [data stringValueForKey:@"vid" defaultValue:@""];
    news.tvUrl = [data stringValueForKey:@"tvUrl" defaultValue:@""];
    news.sourceName = [data stringValueForKey:@"sourceName" defaultValue:@""];
    news.siteValue = [data intValueForKey:@"site" defaultValue:0];
    
    news.novelAuthor = [data stringValueForKey:@"author" defaultValue:@""];
    news.novelBookId = [data stringValueForKey:@"bookId" defaultValue:@""];
    news.novelCategory = [data stringValueForKey:@"category" defaultValue:@""];
    
    news.recomReasons = [data stringValueForKey:kRecomReasons defaultValue:@""];
    news.recomTime = [data stringValueForKey:kRecomTime defaultValue:@""];
    news.blueTitle = [data stringValueForKey:kBlueTitle defaultValue:@""];
    news.recomInfo = [data stringValueForKey:kRecomInfo defaultValue:@""];
    NSString *subId = [data stringValueForKey:kSubId defaultValue:@""];
    if ([subId length] > 0) {
        news.subId = subId;
    } else {
        news.subId = [[news.link componentsSeparatedByString:@"subId="] lastObject];
        news.subId = [[news.link componentsSeparatedByString:@"&"] firstObject];
    }
    
    if ([[data objectForKey:kListPics] isKindOfClass:[NSArray class]]) {
        news.picUrls = [data objectForKey:kListPics];
        if ([news.picUrls count]) {
            news.picUrl = [news.picUrls objectAtIndex:0];
        }
    }
    
    //设置特殊模信息
    [news setDataStringWithDic:data];
    if ([from isEqualToString:kRollingNewsFormTrainCard] && [news.adType isEqualToString:@"2"] && ![news.templateType isEqualToString:@"3"] && ![news.templateType isEqualToString:@"25"]) {
        [news setAdDataWithDic:data];//火车卡片空广告数据处理
    }
    
    //设置冠名信息
    [news setSponsorshipsWithDic:[data objectForKey:kSponsorships]];
    
    //设置天气信息
    [news setWeatherInfoWithDic:data];
    
    news.isRead = [SNRollingNewsPublicManager isReadNewsWithNewsId:news.newsId ChannelId:news.channelId];

    //房产焦点图，获取城市信息
    NSDictionary *cityVO = [data objectForKey:kCityVO];
    if (cityVO != nil) {
        news.city = [cityVO stringValueForKey:@"city" defaultValue:@""];
    }
    
    //获取轮播焦点图信息
    if ([news isMoreFocusNews]) {
        [news setNewsFocusItems:[data objectForKey:kNewsItems]];
    }
    
    //获取红包模版信息
    if ([news isRedPacketNews]) {
        [news setRedPacketNewsItem:data];
        [SNRedPacketManager sharedInstance].pullRedPacket = YES;
    }
    
    //优惠券模板Cell信息
    if ([news isCouponsNews]) {
        [news setCouponsNesItem:data];
    }
    
    return news;
}

+ (RollingNewsListItem *)createRollingNewsListItem:(SNRollingNews *)news {
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
    item.hasAudio = news.hasAudio;
    item.hasVote = news.hasVote;
    item.updateTime = news.updateTime;
    item.recomIconDay = news.recomDay;
    item.recomIconNight = news.recomNight;
    item.media = news.media;
    item.isWeather = news.isWeather;
    item.tempLow = news.tempLow;
    item.tempHigh = news.tempHigh;
    item.city = news.city;
    item.weather = news.weather;
    item.weak = news.weak;
    item.liveTemperature = news.liveTemperature;
    item.pm25 = news.pm25;
    item.quality = news.quality;
    item.weatherIoc = news.weatherIoc;
    item.wind = news.wind;
    item.gbcode = news.gbcode;
    item.date = news.date;
    item.localIoc = news.localIoc;
    item.isRecom = news.isRecom;
    item.recomType = news.recomType;
    item.local = news.local;
    item.thirdPartUrl = news.thirdPartUrl;
    item.liveStatus = news.liveStatus;
    item.templateId = news.templateId;
    item.templateType = news.templateType;
    item.playTime = news.playTime;
    item.liveType = news.liveType;
    item.isFlash = news.isFlash;
    item.position = news.position;
    item.dataString = news.dataString;
    item.token = news.token;
    item.newsStatsType = news.statsType;
    item.morePageNum = news.morePageNum;
    item.isHasSponsorships = news.isHasSponsorships;
    item.iconText = news.iconText;
    item.newsTypeText = news.newsTypeText;
    item.cursor = news.cursor;
    item.sponsorships = news.sponsorships;
    item.adReportState = news.adReportState;
    item.subId = news.subId;
    item.isTopNews = news.isTopNews;
    item.isLatest = news.isLatestNews;
    
    item.novelAuthor = news.novelAuthor;
    item.novelCategory = news.novelCategory;
    item.novelBookId = news.novelBookId;
    
    item.recomReasons = news.recomReasons;
    item.recomTime = news.recomTime;
    item.blueTitle = news.blueTitle;
    item.recomInfo = news.recomInfo;
    
    if ([item.form isEqualToString:kRollingNewsFormHeadline]) {
        item.listPic = news.picUrl;
    } else if ([kNewsTypeGroupPhoto isEqualToString:news.newsType] ||
               [news isGroupPhotoNews]) {
        item.listPic = [news.picUrls componentsJoinedByString:kParameterSeparator];
    } else {
        item.listPic = news.picUrl;
    }
    
    return item;
}

+ (NSArray *)createRollingNewsListItems:(NSArray *)newsList {
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:newsList.count];
    for (SNRollingNews *news in newsList) {
        @autoreleasepool {
            RollingNewsListItem *item = [[RollingNewsListItem alloc] init];
            item.channelId = news.channelId;
            item.newsId = news.newsId;
            item.type = news.newsType;
            item.title = news.title;
            if ([item.title isEqualToString:@"展开，继续看今日要闻"]) {
                [SNRollingNewsPublicManager sharedInstance].isRecommendAfterEditNews = YES;
                [SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow = NO;
            }
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
            item.hasAudio = news.hasAudio;
            item.hasVote = news.hasVote;
            item.updateTime = news.updateTime;
            item.recomIconDay = news.recomDay;
            item.recomIconNight = news.recomNight;
            item.media = news.media;
            item.isWeather = news.isWeather;
            item.tempLow = news.tempLow;
            item.tempHigh = news.tempHigh;
            item.city = news.city;
            item.weather = news.weather;
            item.weak = news.weak;
            item.liveTemperature = news.liveTemperature;
            item.pm25 = news.pm25;
            item.quality = news.quality;
            item.weatherIoc = news.weatherIoc;
            item.wind = news.wind;
            item.gbcode = news.gbcode;
            item.date = news.date;
            item.localIoc = news.localIoc;
            item.isRecom = news.isRecom;
            item.recomType = news.recomType;
            item.local = news.local;
            item.thirdPartUrl = news.thirdPartUrl;
            item.liveStatus = news.liveStatus;
            item.templateId = news.templateId;
            item.templateType = news.templateType;
            item.playTime = news.playTime;
            item.liveType = news.liveType;
            item.isFlash = news.isFlash;
            item.position = news.position;
            item.dataString = news.dataString;
            item.token = news.token;
            item.newsStatsType = news.statsType;
            item.morePageNum = news.morePageNum;
            item.isHasSponsorships = news.isHasSponsorships;
            item.iconText = news.iconText;
            item.newsTypeText = news.newsTypeText;
            item.cursor = news.cursor;
            item.sponsorships = news.sponsorships;
            item.adReportState = news.adReportState;
            item.subId = news.subId;
            item.isTopNews = news.isTopNews;
            item.isLatest = news.isLatestNews;
            item.redPacketTitle = news.redPacketTitle;
            item.bgPic = news.bgPic;
            item.sponsoredIcon = news.sponsoredIcon;
            item.redPacketID = news.redPacketId;
            item.tvPlayNum = news.tvPlayNum;
            item.tvPlayTime = news.tvPlayTime;
            item.playVid = news.playVid;
            item.tvUrl = news.tvUrl;
            item.sourceName = news.sourceName;
            item.novelAuthor = news.novelAuthor;
            item.novelCategory = news.novelCategory;
            item.novelBookId = news.novelBookId;
            
            if ([item.form isEqualToString:kRollingNewsFormHeadline]) {
                item.listPic = news.picUrl;
            } else if ([kNewsTypeGroupPhoto isEqualToString:news.newsType] || [news isGroupPhotoNews]) {
                item.listPic = [news.picUrls componentsJoinedByString:kParameterSeparator];
            } else {
                item.listPic = news.picUrl;
            }
            item.siteValue = news.siteValue;
            item.recomReasons = news.recomReasons;
            item.recomTime = news.recomTime;
            item.blueTitle = news.blueTitle;
            item.recomInfo = news.recomInfo;
            item.trainCardId = news.trainCardId;
            
            [list addObject:item];
        }
    }
    
    return [NSArray arrayWithArray:list];
}

- (NSArray *)createRollingNewsListItems:(NSArray *)newsList {
    return [SNRollingNewsModel createRollingNewsListItems:newsList];
}

- (BOOL)addExclusiveRollingNews:(SNRollingNews *)news {
    BOOL exists = NO;
    for (SNRollingNews *n in self.rollingNews) {
        
        if ([n isRollingTopNews]) {//置顶新闻不参与火车虑重wyy
            continue;
        }
        
        //增加newsType判断
        if ([n.newsId isEqualToString:news.newsId] &&
            [n.channelId isEqualToString:news.channelId]
            && [n.newsType isEqualToString:news.newsType]) {
            ///// 增加火车ID的判断,不然历史火车展示不出来 //////
            if (news.trainCardId && news.trainCardId.length > 0) {
                if ([n.trainCardId isEqualToString:news.trainCardId]) {
                    exists = YES;
                } else {
                    exists = NO;
                }
                break;
            }
            //////////////////////////////////////////////
            exists = YES;
            break;
        }
    }
    return exists;
}

- (NSInteger)getEditLoadMoreIndex {
    NSInteger loadMoreIndex = -1;
    for (SNRollingNews *news in self.rollingNews) {
        if ([news isLoadMore]) {
            loadMoreIndex = [self.rollingNews indexOfObject:news];
            break;
        }
    }
    return loadMoreIndex;
}

- (BOOL)hasLoadMoreNews {
    BOOL hasLoadMoreNews = NO;
    if ([self isHomePage]) {
        if ([self.rollingNews count] >= 2) {
            SNRollingNews *news = [self.rollingNews objectAtIndex:1];
            if (news.templateType.length > 0 &&
                [news.templateType isEqualToString:@"20"]) {
                hasLoadMoreNews = YES;
            }
        }
    }
    return hasLoadMoreNews;
}

//计算出滚动新闻所在的时间线上的序号
//翻页的新闻是旧新闻，在上一页的序号基础上递减
//刷新的新闻是新新闻，在最大序号的基础上递增
- (void)setRollingNewsTimelineIndex:(NSMutableArray *)rollingNews {
    if (_more) {
        int minTimelineIndex = _minTimelineIndex;

        for (SNRollingNews *news in rollingNews) {
            news.timelineIndex = [NSString stringWithFormat:@"%d", --minTimelineIndex];
        }
        _minTimelineIndex = minTimelineIndex;
    } else {
        NSString *maxIndex = [[SNDBManager currentDataBase] getMaxRollingTimelineIndexByChannelId:_channelId];
        
        int maxTimelineIndex = [maxIndex intValue];
        
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
        SNDebugLog(@"maxTimelineIndex = %d", maxTimelineIndex);
        
        _minTimelineIndex = maxTimelineIndex;
        
        for (SNRollingNews *news in [[rollingNews reverseObjectEnumerator] allObjects]) {
            news.timelineIndex = [NSString stringWithFormat:@"%d", ++maxTimelineIndex];
        }
    }
}

- (void)updateRollingNewsToDB:(id)rootData {
    @autoreleasepool {
        id rollingNewsData = nil;
        NSString *channelId = nil;
        NSString *oldChannelId = nil;
        NSString *token = nil;
        self.shareContent = nil;
        isLoadFirstPage = NO;
        if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
            rollingNewsData = [rootData arrayValueForKey:kArticles defaultValue:nil];
            channelId = [rootData stringValueForKey:kChannelId defaultValue:nil];
            oldChannelId = [rootData stringValueForKey:kChannelIdCopy defaultValue:nil];
            token = [rootData objectForKey:kToken];
            NSString *loadMoreTips = [rootData objectForKey:kExpandTips];
            self.shareContent = [rootData objectForKey:@"shareContent"];
            if (channelId && oldChannelId) {
                isLoadingNewChannel = ![channelId isEqualToString:oldChannelId];
            }
            if (loadMoreTips.length > 0) {
                [SNRollingNewsPublicManager sharedInstance].loadMoreTips = loadMoreTips;
            }
            
            if ([(NSArray *)rollingNewsData count] == 0) {
                [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellAllLoad;
                [self performSelectorOnMainThread:@selector(requestDidFinishLoad) withObject:nil waitUntilDone:NO];
                return;
            }
        }
        
        if (self.isLoadRecommend && _more) {
            if ([rollingNewsData isKindOfClass:[NSArray class]]) {
                if ([(NSArray *)rollingNewsData count] == 0) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无新内容，请稍后再试" toUrl:nil mode:SNCenterToastModeWarning];
                }
            }
        }
        
        //4.0广告 解析广告定向数据 并缓存 by jojo
        //先清除之前的缓存
        [[SNDBManager currentDataBase] adInfoClearAdInfosByType:SNAdInfoTypeChannelBanner dataId:channelId categoryId:kAdInfoDefaultCategoryId];
        
        NSArray *adInfoControls = [(NSDictionary *)rootData arrayValueForKey:@"adControlInfos" defaultValue:nil];
        if (adInfoControls) {
            NSMutableArray *parsedAdInfos = [NSMutableArray array];
            for (NSDictionary *adInfoDic in adInfoControls) {
                if ([adInfoDic isKindOfClass:[NSDictionary class]]) {
                    SNAdControllInfo *adControlInfo = [[SNAdControllInfo alloc] initWithJsonDic:adInfoDic];
                    [parsedAdInfos addObject:adControlInfo];
                }
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 添加到缓存
                [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:parsedAdInfos
                                                               withType:SNAdInfoTypeChannelBanner
                                                                 dataId:channelId
                                                             categoryId:kAdInfoDefaultCategoryId];
            });
        }
        
        //Rolling news
        NSMutableArray *currentPageRollingNews = [NSMutableArray array];
        NSMutableArray *loadMoreRollingNews = [NSMutableArray array];
        
        //清空预加载空广告的容器
        [self.preloadEmptyADs removeAllObjects];
        [self.preloadNews removeAllObjects];
        
        BOOL clearRecommendNews = NO;
        //如果是推荐刷新kArticles节点的数据为推荐新闻
        if (self.isLoadRecommend && !_more) {
            if ([rollingNewsData isKindOfClass:[NSArray class]]) {
                NSMutableArray *currentNewsArray = [NSMutableArray array];
                NSMutableArray *allNewsArray = [NSMutableArray array];
                [allNewsArray addObjectsFromArray:self.rollingNews];
                
                for (NSDictionary *articleDic in rollingNewsData) {
                    @autoreleasepool {
                        SNRollingNews *news = [self createNews:articleDic from:kRollingNewsFormCommon];
                        if (news.isRecom.length == 0) {
                            news.isRecom = @"1";
                        }
                        if (news &&
                            ![news shouldBeHiddenWith:self.isPreloadChannel]) {
                            [currentNewsArray addObject:news];
                        } else if (news && self.isPreloadChannel) {
                            [self.preloadEmptyADs addObject:news];
                        }
                    }
                }
                
                //删除编辑新闻
                if ([currentNewsArray count] > 0 && [self isHomePage]) {
                    [SNRollingNewsPublicManager sharedInstance].newsMode = SNRollingNewsModeRecommend;
                    SNRollingNews *loadEditNews = [[SNRollingNews alloc] init];
                    loadEditNews.templateType = @"20";
                    loadEditNews.from = kRollingNewsFormCommon;
                    
                    NSString *moreTip = [SNRollingNewsPublicManager sharedInstance].loadMoreTips;
                    
                    loadEditNews.title = (nil != moreTip && moreTip.length > 0) ? moreTip : @"展开，看搜狐编辑部内容";
                    loadEditNews.morePageNum = 1;
                    loadEditNews.channelId = channelId;
                    loadEditNews.showUpdateTips = showUpdateTips;
                    loadEditNews.newsId = [SNUtility CreateUUID];
                    [currentNewsArray insertObject:loadEditNews atIndex:1];
                    
                    for (SNRollingNews *news in allNewsArray) {
                        if (![news isRecomNews]) {
                            [self.rollingNews removeObject:news];
                        }
                    }
                    
                    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [currentNewsArray count])];
                    [self.rollingNews insertObjects:currentNewsArray
                                          atIndexes:indexes];
                    
                    [currentPageRollingNews addObjectsFromArray:self.rollingNews];
                    [self setRollingNewsTimelineIndex:currentPageRollingNews];
                }
                
                //推荐流缓存中上传加载数据统计
                [SNStatisticsInfoAdaptor uploadTimelineloadInfo:currentNewsArray isPreload:self.isPreloadChannel];
                [SNStatisticsInfoAdaptor cacheTimelineNewsLoadBusinessStatisticsInfo:currentNewsArray dragDown:self.isLoadRecommend];
            }
        } else {
            //刷新为新闻模式时清空推荐数据
            if (!_more) {
                self.recommendNews = [NSMutableArray array];
                clearRecommendNews = YES;
                _page = 0;
            }
            
            NSMutableArray *tempNewsList = [NSMutableArray array];
            if ([rollingNewsData isKindOfClass:[NSArray class]]) {
                for (int i = 0; i < ((NSArray *)rollingNewsData).count; i++) {
                    @autoreleasepool {
                        NSDictionary *dict = rollingNewsData[i];
                        if (![dict isKindOfClass:[NSDictionary class]]) {
                            continue;
                        }
                        
                        if ([[dict stringValueForKey:kTemplateType defaultValue:@"1"] integerValue] == 139) {
                            //5.9.0之前，书架在小说频道展示，5.9.0之后，就只有一个入口了，所以书架数据不用了 by wangchuanwen update
                            continue;
                        }
                        
                        NSMutableDictionary *articleDic = [NSMutableDictionary dictionaryWithDictionary:dict];
                        if (articleDic.count == 0) {
                            continue;
                        }
                        
                        id orgDic = articleDic[@"data"];

                        if (nil != orgDic &&
                            [orgDic isKindOfClass:[NSDictionary class]]) {
                            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:orgDic];
                            
                            //解决一个bug, 11号位的广告如果是视频的时候会重复上报, 增加一个透传的参数
                            [data setObject:@(1) forKey:@"ignoreUploadVideoAd"];
                            articleDic[@"data"] = data;
                        }
                        //********视频加SubId**********//
                        NSDictionary *subInfoDic = [rootData dictionaryValueForKey:@"subInfo" defalutValue:nil];
                        NSString *subId = [NSString stringWithFormat:@"%d", [subInfoDic intValueForKey:@"subId" defaultValue:0]];
                        if (![subId intValue]) subId = self.channelId;
                        [articleDic setObject:subId forKey:@"subId"];
                        //****************************//
                        
                        SNRollingNews *news = [self createNews:articleDic from:kRollingNewsFormCommon];
                        if (news &&
                            ![news shouldBeHiddenWith:self.isPreloadChannel]) {
                            news.token = token;
                            if ([news isMoreFocusNews]) {
                                for (SNRollingNews *newsItem in news.newsFocusArray) {
                                    newsItem.token = token;
                                }
                            }
                            BOOL isExists = [self addExclusiveRollingNews:news];
                            if (!isExists && !isEditLoadMore) {
                                [currentPageRollingNews addObject:news];
                                [self.rollingNews addObject:news];
                            }
                            
                            if (isEditLoadMore && !isExists) {
                                [loadMoreRollingNews addObject:news];
                            }
                            
                            [tempNewsList addObject:news];
                        }
                        
                        //预加载流内空广告延迟上报，先存起来 SNRollingNewsTableController.m line 1128
                        if (news &&
                            [news.newsType isEqualToString:@"21"] &&
                            [news.adType isEqualToString:@"2"] &&
                            self.isPreloadChannel) {
                            [self.preloadEmptyADs addObject:news];
                        }
                    }
                }
                
                //删除本地频道天气模版历史数据
                if ([SNUserLocationManager sharedInstance].localChannelId.length > 0) {
                    NSString *localChannelId = [SNUserLocationManager sharedInstance].localChannelId;
                    
                    if (localChannelId && [self.channelId isEqualToString:localChannelId] && !_more) {
                        [[SNDBManager currentDataBase] clearRollingLocalWeatherNewsByChannelId:channelId];
                    }
                }
                
                // 编辑流缓存中上传加载数据统计
                if (isEditLoadMore) {
                    [SNStatisticsInfoAdaptor uploadTimelineloadInfo:loadMoreRollingNews isPreload:self.isPreloadChannel];
                    [SNStatisticsInfoAdaptor cacheTimelineNewsLoadBusinessStatisticsInfo:loadMoreRollingNews dragDown:!_more];
                } else {
                    [SNStatisticsInfoAdaptor uploadTimelineloadInfo:currentPageRollingNews isPreload:self.isPreloadChannel];
                    [SNStatisticsInfoAdaptor cacheTimelineNewsLoadBusinessStatisticsInfo:currentPageRollingNews dragDown:!_more];
                }
                
                if (isEditLoadMore) {
                    NSInteger loadMoreIndex = [self getEditLoadMoreIndex];
                    if (loadMoreIndex > 0 && [loadMoreRollingNews count] > 0) {
                        //删除数据库中新闻
                        [[SNDBManager currentDataBase] clearRollingLoadMoreNewsListByChannelId:channelId];
                        
                        [self.rollingNews replaceObjectsInRange:NSMakeRange(loadMoreIndex, 1) withObjectsFromArray:loadMoreRollingNews];
                        [currentPageRollingNews addObjectsFromArray:self.rollingNews];
                    }
                }
                
                if ([self isHomePage]) {
                    if (isEditLoadMore && _page == 1) {
                        isLoadFirstPage = YES;
                    }
                    if (_page == 0 && !_more) {
                        isLoadFirstPage = YES;
                    }
                    
                    NSString *tips = [[SNAppConfigManager sharedInstance] showPullNewsTips];
                    if (tips == nil || tips.length == 0) {
                        //王洋洋
                        tips = kPullMyConcernContent;
                    }
                    //第一次启动app，不显示下拉提示 王洋洋
                    BOOL firstlaunchApp = ![[NSUserDefaults standardUserDefaults] boolForKey:@"firstlaunchApp"];
                    if (firstlaunchApp) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstlaunchApp"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    if (isLoadFirstPage && tips.length >0 && !firstlaunchApp) {
                        SNRollingNews *topicNews = [[SNRollingNews alloc] init];
                        topicNews.templateType = @"200";
                        topicNews.channelId = @"1";
                        topicNews.newsId = [SNUtility CreateUUID];
                        topicNews.title = tips;
                        topicNews.from = @"1";
                        
                        if (currentPageRollingNews.count > 2) {
                            SNRollingNews *news = [currentPageRollingNews objectAtIndex:1];
                            if (![news isRedPacketTips]) {
                                //此处发生过数组越界crash 黄震
                                if ([self.rollingNews count] > 0) {
                                    [self.rollingNews insertObject:topicNews
                                                           atIndex:1];
                                }
                                if (currentPageRollingNews.count > 0) {
                                    [currentPageRollingNews insertObject:topicNews atIndex:1];
                                }
                            }
                        }
                    }
                }
                
                if ([(NSArray *)rollingNewsData count] > 0) {
                    _page++;
                    
                    if (!_more) {
                        times++;
                    }
                    self.hasNoMore = NO;
                    [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellLoadMore;
                } else {
                    //5.2.2 已全部加载完成
                    [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellAllLoad;
                }
            }
            
            //剔重后，如果只有广告，则删除 王洋洋
            if ([self isAllAdNews:currentPageRollingNews]) {
                [self.rollingNews removeObjectsInArray:currentPageRollingNews];
            }
        }
        
        [self.preloadNews addObjectsFromArray:self.rollingNews];
        
        [self performSelectorOnMainThread:@selector(requestDidFinishLoad) withObject:nil waitUntilDone:NO];
        
        if ([SNRollingNewsPublicManager sharedInstance].clearAllCache) {
            [currentPageRollingNews removeAllObjects];
            [currentPageRollingNews addObjectsFromArray:self.rollingNews];
            [SNRollingNewsPublicManager sharedInstance].clearAllCache = NO;
        }
        
        //轮播焦点图数据处理，写入数据库
        if (currentPageRollingNews.count > 0) {
            SNRollingNews *news = [currentPageRollingNews objectAtIndex:0];
            if ([news isMoreFocusNews] && news.newsFocusArray.count != 0 ) {
                NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [news.newsFocusArray count])];
                [currentPageRollingNews removeObjectAtIndex:0];
                [currentPageRollingNews insertObjects:news.newsFocusArray atIndexes:indexes];
            }
        }
        
        [self setRollingNewsTimelineIndex:currentPageRollingNews];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // 解析shareRead by jojo
            NSDictionary *shareReadDic = [rootData dictionaryValueForKey:@"shareRead" defalutValue:nil];
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareReadDic];
            if (obj) {
                NSDictionary *subInfoDic = [rootData dictionaryValueForKey:@"subInfo" defalutValue:nil];
                NSString *subId = [NSString stringWithFormat:@"%d", [subInfoDic intValueForKey:@"subId" defaultValue:0]];
                if (![subId intValue]) subId = self.channelId;
                [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypeNewsChannel contentId:subId];
            }
            [[SNDBManager currentDataBase] addMultiRollingNewsListItem:[self createRollingNewsListItems:currentPageRollingNews] updateIfExist:YES];
            if (clearRecommendNews) {
                //TODO:
                [[SNDBManager currentDataBase] clearRollingRecommendNewsListByChannelId:oldChannelId];
            }
        });
    }
}

- (void)requestDidFinishLoad:(TTURLRequest *)request {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHaveLoadRollingNewsFinished];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SNRollingNewsPublicManager sharedInstance].isClickTodayImportNews = NO;
    [SNRollingNewsPublicManager sharedInstance].isClickBackToHomePage = NO;
    [SNRollingNewsPublicManager sharedInstance].channelProtocolNewsID = nil;
    _isCacheModel = NO;
    isLoadingNews = NO;
    TTURLDataResponse *resp = request.response;
    
    if (self.preloadNews == nil) {
        self.preloadNews = [NSMutableArray array];
    } else {
        [self.preloadNews removeAllObjects];
    }
    
    if (self.preloadEmptyADs == nil) {
        self.preloadEmptyADs = [NSMutableArray array];
    } else {
        [self.preloadEmptyADs removeAllObjects];
    }
    
    id rootData = nil;
    NSError *error = nil;
    BOOL isSpace = [resp.data isEqualToData:[NSData dataWithBytes:" " length:1]];
    if (resp.data.length > 0 && !isSpace) {
        rootData = [NSJSONSerialization JSONObjectWithData:resp.data options:NSJSONReadingAllowFragments error:&error];
    }
    
    if (error || nil == rootData) {
        [self request:request didFailLoadWithError:error];
        return;
    }
    
    TTUserInfo *userInfo = request.userInfo;
    if ([userInfo.topic isEqualToString:kTopicEditNewsLoadMore]) {
        isEditLoadMore = YES;
    } else {
        isEditLoadMore = NO;
    }
    
    if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
        @autoreleasepool {
            NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithDictionary:rootData];
            [dictData setObject:self.channelId forKey:kChannelIdCopy];
            
            //处理频道数据
            [self dealNewChannelPage:rootData];
            
            //判断是推荐还是频道新闻
            NSString *newsType = [dictData stringValueForKey:@"type" defaultValue:@""];
            NSString *ctxString = [rootData objectForKey:@"ctx"];
            if (ctxString) {
                self.ctx = ctxString;
            }
            NSString *trackerString = [rootData objectForKey:@"tracker"];
            if (trackerString) {
                self.tracker = trackerString;
            }
            isPreload = YES;
            NSString *preload = [rootData stringValueForKey:@"preload" defaultValue:@""];
            if (preload && [preload isEqualToString:@"0"]) {
                isPreload = NO;
            }
            
            //焦点图跟广告轮换位置信息
            NSString *focusPosition = [rootData stringValueForKey:@"focusPosition" defaultValue:@""];
            if (focusPosition.length > 0) {
                [SNRollingNewsPublicManager sharedInstance].focusPosition = focusPosition;
            }
            
            //买房频道本地化 add by Cae
            NSInteger isDefault = [rootData integerForKey:@"isDefault"];
            if (isDefault != 1) {
                //启动客户端时，如果本地频道有信息，则_isLocalChannelChange＝NO，不需要推送 wyy
                [[SNUserLocationManager sharedInstance] canNotifyDefault];
            }
            
            //发现是保底数据
            if (1 == isDefault
                && [[[SNVideoAdContext sharedInstance] getCurrentChannelID] isEqualToString:self.channelId]) {
                if ([[SNUserLocationManager sharedInstance] canNotifyDefault]) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无该地信息,将推荐其他优质内容。" toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
            
            NSInteger localType = [rootData integerForKey:@"localType"];
            if (localType > 0) {
                [SNRollingNewsModel saveLocalChannelId:self.channelId];
                
                //只保存房产，作为后边和本地区分  wangyy
                [SNUserLocationManager saveHouseProLocalType:localType
                                               withChannelId:self.channelId];
            }
            
            self.channelName = [rootData stringForKey:@"channelName"];
            
            [SNRollingNewsPublicManager sharedInstance].noticeDict = [[rootData stringForKey:kRollingNoticeText] yajl_JSON];
            
            if ([self isHomePage]) {
                NSString *lastUpdateTime = [rootData stringValueForKey:@"lastUpdateTime" defaultValue:@""];
                NSString *mainFocalId = [rootData stringValueForKey:@"mainFocalId" defaultValue:@""];
                NSString *viceFocalId = [rootData stringValueForKey:@"viceFocalId" defaultValue:@""];
                int showUpdateTipsValue = [rootData intValueForKey:@"showUpdateTips" defaultValue:0];
                
                if (lastUpdateTime.length > 0) {
                    [SNRollingNewsPublicManager sharedInstance].lastUpdateTime = lastUpdateTime;
                }
                if (mainFocalId.length > 0) {
                    [SNRollingNewsPublicManager sharedInstance].mainFocalId = mainFocalId;
                }
                if (viceFocalId.length > 0) {
                    [SNRollingNewsPublicManager sharedInstance].viceFocalId = viceFocalId;
                }
                showUpdateTips = showUpdateTipsValue == 0 ? NO : YES;
            } else {
                showUpdateTips = NO;
            }
            
            //外网带量URL请求
            NSArray *thirdPartUrlsArray = [rootData objectForKey:@"thirdPartUrls"];
            if (thirdPartUrlsArray && [thirdPartUrlsArray isKindOfClass:[NSArray class]]) {
                SNThirdPartRequestManager *thirdPartManager = [SNThirdPartRequestManager sharedInstance];
                thirdPartManager.urlArray = thirdPartUrlsArray;
                [thirdPartManager sendAllRequest];
            }
            
            if (!_more) {
                if ([newsType isEqualToString:@"recom"] ||
                    [newsType isEqualToString:@"stream"]) {
                    if ([SNUtility shouldShowEditMode]) {
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldShowEditModeNewsKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    self.isLoadRecommend = YES;

                    BOOL isRecom = [newsType isEqualToString:@"recom"];
                    [SNRollingNewsPublicManager sharedInstance].newsMode = isRecom ? SNRollingNewsModeRecommend : SNRollingNewsModeNone;
                } else {
                    self.isLoadRecommend = NO;
                    if (self.isMixStream != 2) {
                        
                        if (![self hasTopNews]) {
                            if (dictData && [dictData isKindOfClass:[NSDictionary class]]) {
                                NSArray *array = [dictData objectForKey:kArticles];
                                if ([array isKindOfClass:[NSArray class]] && array.count != 0) {
                                    self.rollingNews = [NSMutableArray array];
                                }
                            }
                            self.recommendNews = [NSMutableArray array];
                            [[SNDBManager currentDataBase] clearRollingNewsListByChannelId:self.channelId];
                        }
                        
                        if ([self isHomeEidtPage]) {
                            [SNRollingNewsPublicManager sharedInstance].newsMode = SNRollingNewsModeEdit;
                        }
                    }
                }
                //推荐实时提醒功能暂时无效
                //[SNNewsNotificationManager sharedInstance].channelId = self.channelId;
                //[[SNNewsNotificationManager sharedInstance] start];
            }
            
            if (!_more) {
                //Tips
                NSDictionary *tipsDic = nil;
                if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
                    tipsDic = [rootData objectForKey:kTips];
                    if (tipsDic && [tipsDic isKindOfClass:[NSDictionary class]]) {
                        NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:tipsDic];
                        if (action == 0) {//编辑流
                            [messageDic setObject:[NSNumber numberWithBool:YES] forKey:kRollingNewsPullStatus];
                        } else if (action == 1) {//推荐流
                            [messageDic setObject:[NSNumber numberWithBool:NO] forKey:kRollingNewsPullStatus];
                        }
                        
                        //Toast提示相关字段
                        self.messageDic = messageDic;
                    }
                }
            }
            //(self.isMixStream == NewsChannelEditAndRecom && [self isKindOfClass:NSClassFromString(@"SNSubRollingNewsModel")])
            //出现过推荐isMixStream=2，但model是SNRollingNewsModel，数据不更新,没有发现问题根源，在这里做层保护
            if ((![self hasTopNews] && ![self showHomeRecommendPage]) || (self.isMixStream == NewsChannelEditAndRecom && [self isKindOfClass:NSClassFromString(@"SNSubRollingNewsModel")])) {
                [self updateRollingNewsToDB:dictData];
            } else {
                NSString *contentToken = [rootData stringValueForKey:@"contentToken" defaultValue:nil];
                if ([contentToken isEqualToString:kDefaultContentToken]) {
                    self.shouldDeleteTopNews = YES;
                } else if (contentToken) {
                    NSString *lastContentToken = [[SNRollingNewsPublicManager sharedInstance] getContentTokenWithChannelId:self.channelId];
                    id topRollingNews = [rootData objectForKey:kTopArticles];
                    if ([topRollingNews isKindOfClass:[NSArray class]]) {
                        NSArray *array = (NSArray *)topRollingNews;
                        if ([array count] == 0 && ![lastContentToken isEqualToString:contentToken]) {
                            self.shouldDeleteTopNews = YES;
                        } else {
                            self.shouldDeleteTopNews = NO;
                        }
                    } else {
                        self.shouldDeleteTopNews = NO;
                    }
                } else {
                    self.shouldDeleteTopNews = NO;
                }
                [self updateNewChannelRollingNewsToDB:dictData
                                         contentToken:contentToken];
            }
            
            [SNRollingNewsPublicManager sharedInstance].isRecomForceRefresh = NO;
            
            //网络请求成功后，缓存请求参数 wyy
            if (!isEditLoadMore) {
                if ([self isNewHomePage] || [self isRecomendNewChannel]) {
                    //1）流式频道 + 新要闻下拉刷新时候page不修改
                    if (_more || times == 1) {
//                        [SNRollingNewsPublicManager sharedInstance].pageNum = _page;
                        [SNRollingNewsPublicManager saveRollingPage:_page channelId:self.channelId];
                    }
                }
                else if (self.isHomePage && self.isMixStream != NewsChannelEditAndRecom) {
                    //2）旧要闻频道
//                    [SNRollingNewsPublicManager sharedInstance].pageNum = _page;
                    [SNRollingNewsPublicManager saveRollingPage:_page channelId:self.channelId];
                }
                else if(!self.isNewChannel){
                    //3）其他编辑频道
//                    [SNRollingNewsPublicManager sharedInstance].pageNum = _page;
                    [SNRollingNewsPublicManager saveRollingPage:_page channelId:self.channelId];
                }
            }
          
            [SNRollingNewsPublicManager saveRollingTimes:times channelId:self.channelId];
//            [SNRollingNewsPublicManager sharedInstance].times = times;
            [SNRollingNewsPublicManager sharedInstance].showUpdateTips = showUpdateTips;
            
            NSString *key = self.channelId;
            [[SNRollingNewsPublicManager sharedInstance] saveRequestParamsWithChannelId:key];
            
            if (!_more) {
                [self setRefreshedTime];
                [self setRefreshStatusOfUpgrade];
                [[SNAppStateManager sharedInstance] loadedChannelNewsWith:self.channelId];
            }
        }
    } else {
        isLoadingNewChannel = NO;
		[self performSelectorOnMainThread:@selector(requestDidFinishLoad) withObject:nil waitUntilDone:NO modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }

    //请求结束后隐藏红点
    if (!_more) {
        //隐藏快讯提示
        if ([self isHomePage]) {
            SNTabBarController *tabBarController = (SNTabBarController *)[SNUtility getApplicationDelegate].appTabbarController;
            //隐藏红点
            [tabBarController flashTabBarItem:NO atIndex:TABBAR_INDEX_NEWS];
        }
    }
    [[SNRollingNewsPublicManager sharedInstance] resetLeaveHomeTime];
}

- (BOOL)isLocalChannel {
    return [SNRollingNewsModel isLocalChannel:self.channelId];
}

// 这个东西目前是只存不删。 要处理这个东西，得把数据库传递数据的方式删除了重构才行。这个设计太蛋疼了。我都鄙视我自己。  by Cae
+ (void)saveLocalChannelId:(NSString *)channelIdString {
    NSInteger channelId = channelIdString.integerValue;
    
    if (channelId != 0) {
        NSMutableArray *list = [[TMCache sharedCache] objectForKey:@"channelLocalType"];
        if (list == nil) {
            list = [[NSMutableArray alloc] init];
        }
        
        NSUInteger index = [list indexOfObject:@(channelId)];
        if (NSNotFound == index) {
            //如果阅读记录大于1000条，清除
            if ([list count] > 1000) {
                [list removeObjectAtIndex:0];
            }
            [list addObject:@(channelId)];
            [[TMCache sharedCache] setObject:list forKey:@"channelLocalType"];
        }
    }
}

+ (BOOL)isLocalChannel:(NSString *)channelIdString {
    if ([channelIdString isEqualToString:kLocalChannelUnifyID]) {
        return YES;
    }
    NSInteger channelId = channelIdString.integerValue;

    if (0 == channelId) {
        return NO;
    }
    
    NSMutableArray *list = [[TMCache sharedCache] objectForKey:@"channelLocalType"];
    if (list == nil || [list count] == 0) {
        return NO;
    }
    
    return [list indexOfObject:@(channelId)] != NSNotFound;
}

+ (void)saveReadNewsWithNewsId:(NSString *)newsId
                     ChannelId:(NSString *)channelId {
    if (newsId != nil && channelId != nil) {
        NSString *value = [NSString stringWithFormat:@"%@_%@", channelId, newsId];
        
        NSMutableArray *list = [[TMCache sharedCache] objectForKey:@"readNewsList"];
        if (list == nil) {
            list = [[NSMutableArray alloc] init];
        }
      
        NSUInteger index = [list indexOfObject:value];
        if (NSNotFound == index) {
            //如果阅读记录大于1000条，清除
            if ([list count] > 1000) {
                [list removeObjectAtIndex:0];
            }
            [list addObject:value];
            
            [[TMCache sharedCache] setObject:list forKey:@"readNewsList"];
        }
    }
}

+ (BOOL)isReadNewsWithNewsId:(NSString *)newsId
                   ChannelId:(NSString *)channelId {
    if (newsId != nil && channelId != nil) {
        NSString *value = [NSString stringWithFormat:@"%@_%@", channelId, newsId];
        
        NSMutableArray *list = [[TMCache sharedCache] objectForKey:@"readNewsList"];
        if (list == nil || [list count] == 0) {
            return NO;
        }
        return [list indexOfObject:value] != NSNotFound;
    } else {
        return NO;
    }
}

- (void)readNextPageCahceFromDatabase {
    NSString *timelineIndex = nil;
    
    if (_more) {
        SNRollingNews *last = [self.rollingNews lastObject];
        timelineIndex = last.timelineIndex;
    } else {
        self.hasNoMore = NO;
        return;
    }
    
    //Rolling news
    NSArray *newsList = [[SNDBManager currentDataBase] getRollingNewsListNextPageByChannelId:self.channelId timelineIndex:timelineIndex pageSize:KPaginationNum];
    
    for (RollingNewsListItem *item in newsList) {
        @autoreleasepool {
            SNRollingNews *news = [self createNewsByItem:item];
            [self.rollingNews addObject:news];
        }
    }
    
    if (newsList.count > 0) {
        self.hasNoMore = NO;
    }
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
    isLoadingNewChannel = NO;
    isLoadingNews = NO;
    if (self.rollingNews.count > 0) {
        self.hasNoMore = NO;
    }
    
    [self requestDidFinishLoad];
    
    if (!_more) {
        [[SNAppStateManager sharedInstance] loadedChannelNewsWith:self.channelId];
    }
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    if ([SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow) {
        [SNRollingNewsPublicManager sharedInstance].isClickTodayImportNews = NO;
    }
}

- (void)requestDidCancelLoad:(TTURLRequest *)request {
    isLoadingNewChannel = NO;
    isLoadingNews = NO;
    if (self.rollingNews.count > 0) {
        self.hasNoMore = NO;
    }
    _page = self.rollingNews.count / 20;
//    [SNRollingNewsPublicManager sharedInstance].pageNum = _page;
//    [SNRollingNewsPublicManager sharedInstance].times = times;
    [SNRollingNewsPublicManager saveRollingPage:_page channelId:self.channelId];
    [SNRollingNewsPublicManager saveRollingTimes:times channelId:self.channelId];
    
    NSString *key = self.channelId;
    [[SNRollingNewsPublicManager sharedInstance] saveRequestParamsWithChannelId:key];
    
    [super requestDidCancelLoad:request];
}

#pragma mark - SNNewsModel Protocol
- (NSString *)channelId {
    return _channelId;
}

- (NSTimeInterval)refreshIntervalWithDefault:(NSTimeInterval)interval {
    return interval;
}

- (BOOL)isAllAdNews:(NSArray *)newsList {
    int adCount = 0;
    for (int i = 0; i < [newsList count]; i++) {
        SNRollingNews *news = [newsList objectAtIndex:i];
        if (![news.newsType isEqualToString:kNewsTypeAd]) {
            break;
        }
        adCount++;
    }
    
    if (adCount == [newsList count]) {
        return YES;
    }
    
    return NO;
}

#pragma mark 置顶新闻
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
                                                  from:kRollingNewsFormCommon];
                news.isTopNews = YES;
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
        //获取置顶topNewsCnt展示
        [self updateTopNewsListWithStatus:SNTopNewsUpdate];
        
        [self setRollingNewsTimelineIndex:self.topNewsList];
        
        //更新置顶新闻缓存
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *lChannelId = self.channelId;
            [[SNDBManager currentDataBase] clearAllTopRollingNewsList:lChannelId];
            [[SNDBManager currentDataBase] addMultiRollingNewsListItem:[self createRollingNewsListItems:self.topNewsList] updateIfExist:YES];
        });
    }
    [[SNRollingNewsPublicManager sharedInstance] saveContentToken:contentToken withChannelId:self.channelId];
}

- (NSArray *)getNeedShowTopNewsList{
    NSMutableArray *showTopNewList = [NSMutableArray arrayWithCapacity:self.topNewsCnt];
    if (self.topNewsCnt >= self.topNewsList.count) {
        //需要显示的条数大于置顶新闻的条数，则全部显示不轮播
        [showTopNewList addObjectsFromArray:self.topNewsList];
        self.topNewsIndex = 0;
    }
    else{
        if (self.topNewsCnt <= self.topNewsList.count - self.topNewsIndex) {
            //获取能显示的置顶新闻
            NSArray *tmpArray = [self.topNewsList subarrayWithRange:NSMakeRange(self.topNewsIndex, self.topNewsCnt)];
            [showTopNewList addObjectsFromArray:tmpArray];
            self.topNewsIndex = self.topNewsIndex + self.topNewsCnt;
        }
        else{
            //获取剩余数组的置顶新闻
            int leaveCnt = self.topNewsList.count - self.topNewsIndex;
            if (leaveCnt == 0) {
                self.topNewsIndex = 0;
                leaveCnt = self.topNewsCnt;
            }
            NSArray *tmpArray = [self.topNewsList subarrayWithRange:NSMakeRange(self.topNewsIndex, leaveCnt)];
            
            [showTopNewList addObjectsFromArray:tmpArray];
            //leaveCnt为0或不为0，topNewsIndex要重置成不同值，否则，一个轮循后，刷新时，需要刷新多次
            //self.topNewsIndex = 0;
            self.topNewsIndex = (self.topNewsIndex == 0) ? self.topNewsCnt : 0;
        }
    }
    
    return showTopNewList;
}

- (void)updateTopNewsListWithStatus:(SNTopNewsStatus)status {
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

- (BOOL)firstFocusNews{
    if (self.rollingNews.count > 0) {
        SNRollingNews *news = [self.rollingNews objectAtIndex:0];
        return news.isMoreFocusNews;
    }
    return NO;
}

- (void)clearTopNews {
    if (self.topNewsList.count != 0) {
        [self.topNewsList removeAllObjects];
        [[SNDBManager currentDataBase] clearAllTopRollingNewsList:self.channelId];
    }
    
    if (self.rollingNews.count != 0) {
        SNRollingNews *news = [self.rollingNews objectAtIndex:0];
        if (news.isTopNews == YES) {
            [self.rollingNews removeObjectAtIndex:0];
        }
    }
    [[SNRollingNewsPublicManager sharedInstance] saveContentToken:kDefaultContentToken withChannelId:self.channelId];
}

- (void)dealTopArticles:(NSDictionary *)rootDic
           contentToken:(NSString *)contentToken {
    if (contentToken == nil || [contentToken length] == 0) {
        return;
    }
 
    SNTopNewsStatus status = [[SNRollingNewsPublicManager sharedInstance] getTopNewsStatus:contentToken channelId:self.channelId];
    
    switch (status) {
        case SNTopNewsUpdate: {
            //更新置顶新闻
            self.topNewsIndex = 0;
            NSString *key = [NSString stringWithFormat:@"%@_%@", kTopCount, self.channelId];
            self.topNewsCnt = [SNUserDefaults integerForKey:key];
            [self updateTopNews:rootDic contentToken:contentToken];
            [SNUserDefaults setInteger:self.topNewsCnt forKey:key];
        }
            break;
        case SNTopNewsDefault: {
            if (self.topNewsList.count == 0) {
                //更新置顶新闻
                [self updateTopNews:rootDic contentToken:contentToken];
            } else {
                [self updateTopNewsListWithStatus:SNTopNewsDefault];
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
}

- (void)dealRecommendArticles:(NSDictionary *)rootDic {
    //置顶广告新闻
    BOOL isHasAdTopNews = NO;
    id recommendRollingNews = [rootDic objectForKey:kRecommendArticles];
    if ([recommendRollingNews isKindOfClass:[NSArray class]]) {
        @autoreleasepool {
            NSMutableArray *recommendNewsArray = [NSMutableArray array];
            [self.preloadEmptyADs removeAllObjects];
            NSString *token = [rootDic objectForKey:kToken];
            
            NSMutableArray *topAdNews = nil;
            for (NSDictionary *articleDic in recommendRollingNews) {
                @autoreleasepool {
                    SNRollingNews *news = [self createNews:articleDic from:kRollingNewsFormCommon];
                    if (news &&
                        ![news shouldBeHiddenWith:self.isPreloadChannel]) {
                        //如果是置顶广告新闻处理
                        if ([news.templateType isEqualToString:@"76"]) {
                            if (!topAdNews) {
                                topAdNews = [NSMutableArray array];
                            }
                            if ([news.newsType isEqualToString:kNewsTypeAd] &&
                                !news.newsAd.isReported) {
                                if (!self.isPreloadChannel) {
                                    [news.newsAd reportAdLoad:news];
                                    news.newsAd.isReported = YES;
                                }
                            }
                            [topAdNews addObject:news];
                            continue;
                        }
                        news.token = token;
                        //流式频道不需要客户端剔重处理
                        [recommendNewsArray addObject:news];
                    } else if (news && self.isPreloadChannel) {
                        [self.preloadEmptyADs addObject:news];
                    }
                }
            }
            
            //广告置顶逻辑
            SNRollingNews *topAd = nil;
            if (times == 0 &&
                [self.channelId isEqualToString:kLocalChannelUnifyID] && !_more) {
                //判断之前的数据里面是否有这个广告
                for (SNRollingNews *tNews in self.rollingNews) {
                    if ([tNews.templateType isEqualToString:@"76"]) {
                        [self.rollingNews removeObject:tNews];
                        break;
                    }
                }
                if (topAdNews.count > 0) {
                    isHasAdTopNews = YES;
                    topAd = [self creatTopAdNews:topAdNews];
                    [self.rollingNews insertObject:topAd atIndex:0];
                }
            } 
            if (recommendNewsArray.count > 0) {
                if (!_more && times != 0) {
                    for (SNRollingNews *news in self.rollingNews) {
                        if ([news.templateType isEqualToString:@"201"]) {
                            [self.rollingNews removeObject:news];
                            break;
                        }
                    }
                    SNRollingNews *topicNews = [[SNRollingNews alloc] init];
                    topicNews.templateType = @"201";
                    topicNews.channelId = self.channelId;
                    topicNews.newsId = [SNUtility CreateUUID];
                    topicNews.title = @"上次看到这里，点击刷新";
                    topicNews.from = @"1";
                    [recommendNewsArray addObject:topicNews];
                    
                }
                _page++;
                if (!_more) {
                    times++;
                }
                if ([self.channelId isEqualToString:@"13557"]) {
                    [SNRollingNewsPublicManager sharedInstance].recomADCount += 1;
                }
                if ([self.channelId isEqualToString:@"3"] || [self.channelId isEqualToString:@"960513"]) {
                    [SNRollingNewsPublicManager sharedInstance].entertainmentADCount += 1;
                }
                if ([self isLocalChannel]) {
                    [SNRollingNewsPublicManager sharedInstance].localADCount += 1;
                }
                self.hasNoMore = NO;
                [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellLoadMore;
            } else {
                [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellAllLoad;
                if (_more) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"内容看完了，看看其他频道" toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
            
            NSInteger index = self.topNewsList.count == 0 ? 0 : self.curTopNewsCnt;
            index = isHasAdTopNews ? index + 1 : index;
            
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [recommendNewsArray count])];
            
            //删除上次的“上次看到这里，点击刷新”
            NSMutableArray *allNewsArray = [NSMutableArray array];
            [allNewsArray addObjectsFromArray:self.rollingNews];
            for (SNRollingNews *news in allNewsArray) {
                if ([self isHomeRecommendPage] && [news.templateType isEqualToString:@"20"]) {
                    [self.rollingNews removeObject:news];
                }
                
                if ([news.templateType isEqualToString:@"27"] ||
                    [news.templateType isEqualToString:@"30"]) {
                    [self.rollingNews removeObject:news];
                }
            }
            
            //添加新加载的数据
            if (_more) {
                [self.rollingNews addObjectsFromArray:recommendNewsArray];
                //缓存最下面20条
                if (self.rollingNews.count >= kCacheNewsNumber + index) {
                    recommendNewsArray = [NSMutableArray arrayWithArray:[self.rollingNews subarrayWithRange:NSMakeRange(self.rollingNews.count - kCacheNewsNumber, kCacheNewsNumber)]];
                } else {
                    if ([self.rollingNews count] > 0 && index < self.rollingNews.count) {
                        recommendNewsArray = [NSMutableArray arrayWithArray:[self.rollingNews subarrayWithRange:NSMakeRange(index, self.rollingNews.count - index)]];
                    }
                }
            } else {
                [self.rollingNews insertObjects:recommendNewsArray atIndexes:indexes];
                if (self.rollingNews.count > index) {
                    //缓存最上面20条
                    NSUInteger len = (self.rollingNews.count - index) > kCacheNewsNumber ? kCacheNewsNumber : (self.rollingNews.count - index);
                    recommendNewsArray = [NSMutableArray arrayWithArray:[self.rollingNews subarrayWithRange:NSMakeRange(index, len)]];
                }
            }
            
            //如果是置顶广告, 添加进来topAd
            if (topAd) {
                [recommendNewsArray insertObject:topAd atIndex:0];
            }
            
            if (!self.isPreloadChannel) {
                [self reportRecommendNewsLoad:[NSArray arrayWithArray:recommendNewsArray]];
            } else {
                [self.preloadNews removeAllObjects];
                [self.preloadNews addObjectsFromArray:recommendNewsArray];
            }
            
            //轮播焦点图数据处理，写入数据库
            int count = recommendNewsArray.count;
            for (int i = 0; i < count; i++) {
                SNRollingNews *news = [recommendNewsArray objectAtIndex:i];
                if ([news isMoreFocusNews] && news.newsFocusArray.count != 0 ) {
                    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(i, [news.newsFocusArray count])];
                    [recommendNewsArray removeObjectAtIndex:i];
                    [recommendNewsArray insertObjects:news.newsFocusArray
                                            atIndexes:indexes];
                    
                    //焦点图在第一位，置顶新闻不显示
                    if (i == 0 && self.topNewsList.count !=0) {
                        self.topNewsIndex = 0;
                        if (self.curTopNewsCnt <= [self.rollingNews count]) {
                            [self.rollingNews removeObjectsInRange:NSMakeRange(0, self.curTopNewsCnt)];
                        }
                        self.curTopNewsCnt = 0;
                    }
                    
                    //只会有1个焦点图集
                    break;
                }

                if ([news.templateType isEqualToString:@"76"]) {
                    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(i, [news.topAdNews count])];
                    [recommendNewsArray removeObjectAtIndex:i];
                    [recommendNewsArray insertObjects:news.topAdNews
                                            atIndexes:indexes];
                    
                    //只会有1个置顶广告图集
                    break;
                }
            }
            
            [self setRollingNewsTimelineIndex:recommendNewsArray];
            
            for (SNRollingNews *news in recommendNewsArray) {
                if (![news.templateType isEqualToString:@"201"]) {
                    news.isLatestNews = YES;
                }
            }
            
            //更新置顶新闻缓存
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *lChannelId = self.channelId;
                [[SNDBManager currentDataBase] clearRefreshRollingNewsItem:lChannelId];
                [[SNDBManager currentDataBase] updateLatestRollingNewsList:lChannelId];
                [[SNDBManager currentDataBase] addMultiRollingNewsListItem:[self createRollingNewsListItems:recommendNewsArray] updateIfExist:YES];
            });
        }
    }
}

- (void)dealFunctionArticles:(NSDictionary *)rootDic {
    id functionArticles = [rootDic objectForKey:kFunctionArticles];
    SNRollingNews *news = nil;
    if ([functionArticles isKindOfClass:[NSArray class]]) {
        for (NSObject *objc in functionArticles) {
            @autoreleasepool {
                if ([objc isKindOfClass:[NSDictionary  class]]) {
                    NSDictionary *tempValue = (NSDictionary *)objc;
                    news = [self createNews:tempValue from:kRollingNewsFormCommon];
                    if (self.rollingNews.count > 0) {
                        SNRollingNews *tempNews = [self.rollingNews objectAtIndex:0];
                        if ([tempNews.templateType isEqualToString:@"27"] || [tempNews.templateType isEqualToString:@"30"]) {
                            [self.rollingNews replaceObjectAtIndex:0 withObject:news];
                        } else {
                            [self.rollingNews insertObject:news atIndex:0];
                        }
                        
                        news.isLatestNews = YES;
                        NSString *maxIndex = [[SNDBManager currentDataBase] getMaxRollingTimelineIndexByChannelId:_channelId];
                        news.timelineIndex = maxIndex;
                        break;
                    }
                }
            }
        }
    }
    
    if (news != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 0), ^{
            @autoreleasepool {
                [[SNDBManager currentDataBase] addSingleRollingNewsListItem:[SNRollingNewsModel createRollingNewsListItem:news] updateIfExist:YES];
            }
        });
    }
}

- (void)dealNewChannelPage:(NSDictionary *)rootData {
    if ([self isRecomendNewChannel]) {
        [SNUtility recordRefreshTime:self.channelId];
        
        //重置娱乐频道数据, 删除缓存和数据库的数据，获取服务端下发的最新20条
        if (times == 0) {
            if(_more == YES){
                //重置的时候服务端下发错误空数据的时候，上拉，需要time=1，否则每次触底只替换第一屏数据
                times = 1;
            }
            else{
                id recommendRollingNews = [rootData objectForKey:kRecommendArticles];
                if ([recommendRollingNews isKindOfClass:[NSArray class]])
                {
                    NSArray *recommandArray = (NSArray *)recommendRollingNews;
                    if (recommandArray.count > 0) {
                        [self.rollingNews removeAllObjects];
                        [[SNDBManager currentDataBase] clearRollingNewsListByChannelId:self.channelId];
                    }
                }
            }
        }
    }
    
    if ([self isLocalChannel]) {
        NSDictionary *filterInfo = [NSDictionary dictionary];
        NSArray *adInfoControls = [(NSDictionary *)rootData arrayValueForKey:@"adControlInfos" defaultValue:nil];
        if (adInfoControls) {
            for (NSDictionary *adInfoDic in adInfoControls) {
                if ([adInfoDic isKindOfClass:[NSDictionary class]]) {
                    NSArray *adInfos = [adInfoDic arrayValueForKey:@"adInfos" defaultValue:nil];
                    if (adInfos) {
                        for (NSDictionary *mInfo in adInfos) {
                            if ([mInfo isKindOfClass:[NSDictionary class]]) {
                                filterInfo = [mInfo dictionaryValueForKey:@"filterInfo" defalutValue:nil];
                            }
                        }
                    }
                }
            }
        }
        
        if (filterInfo) {
            [SNAdvertiseManager sharedManager].currentLocalChannelId = [filterInfo stringValueForKey:@"newschn" defaultValue:nil];
        }
    }
}
//
////焦点图在第一位时候，不显示置顶新闻
//- (BOOL)FocusNewsAtFirstIndex:(NSDictionary *)rootDic{
//    if (self.isAmusementPage) {
//        id recommendRollingNews = [rootDic objectForKey:kRecommendArticles];
//        if ([recommendRollingNews isKindOfClass:[NSArray class]]){
//            NSArray *recommendArray = (NSArray *)recommendRollingNews;
//            if (recommendArray.count > 0) {
//                NSDictionary *articleDic = [recommendArray objectAtIndex:0];
//                NSString *templateType = [articleDic stringValueForKey:kTemplateType defaultValue:@"1"];
//                if ([templateType isEqualToString:@"28"]) {
//                    return YES;
//                }
//            }
//        }
//    }
//    return NO;
//}

- (void)updateNewChannelRollingNewsToDB:(id)rootData
                           contentToken:(NSString *)contentToken {
    id topRollingNews = nil;
//    id recommendRollingNews = nil;
    
    if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
        id recommendRollingNews = [rootData objectForKey:kRecommendArticles];
        id articleRollingNews = [rootData objectForKey:kArticles];
        if (!recommendRollingNews && articleRollingNews) { // 容错处理：下发的是Articles字段，避免白屏，调取旧版逻辑
            [self updateRollingNewsToDB:rootData];
            return;
        }
        //下拉操作时，设置置顶新闻
        if (action == 1 || action == 0) {
            [self dealTopArticles:rootData contentToken:contentToken];
        }
        [self dealRecommendArticles:rootData];
        [self dealFunctionArticles:rootData];
    }

    [self performSelectorOnMainThread:@selector(requestDidFinishLoad)
                           withObject:nil waitUntilDone:NO];
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //解析shareRead by jojo
        NSDictionary *shareReadDic = [rootData dictionaryValueForKey:@"shareRead" defalutValue:nil];
        SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareReadDic];
        if (obj) {
            NSDictionary *subInfoDic = [rootData dictionaryValueForKey:@"subInfo" defalutValue:nil];
            self.subId = [NSString stringWithFormat:@"%d", [subInfoDic intValueForKey:@"subId" defaultValue:0]];
            if (![self.subId intValue]) self.subId = self.channelId;
            [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypeNewsChannel contentId:self.subId];
        }
    });
}

- (BOOL)hasTopNews {
    //首页的编辑流模式下无置顶新闻
    if ([self isHomeEidtPage] &&
        ![self showHomeRecommendPage]) {
        return NO;
    }
    
    return self.isNewChannel;
}

- (int)getAction {
    return action;
}

#pragma mark - 上报流式新闻广告
- (void)reportRecommendNewsLoad:(NSArray *)recommendNewsArray {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (SNRollingNews * newsItem in recommendNewsArray) {
            if (![newsItem isKindOfClass:[SNRollingNews class]]) {
                break;
            }
            //广告类型
            if ([newsItem.newsType isEqualToString:kNewsTypeAd] &&
                !newsItem.newsAd.isReported) {
                [newsItem.newsAd reportAdLoad:newsItem];
                newsItem.newsAd.isReported = YES;
            }
            if (newsItem.newsFocusArray.count > 0) {
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

            //流内冠名加载上报，如果有SNNewsSponsorships节点，表明有冠名广告
            if ([newsItem respondsToSelector:@selector(sponsorshipsObject)]) {
                SNNewsSponsorships *sponsorshipsObject = [newsItem performSelector:@selector(sponsorshipsObject)];
                if ([sponsorshipsObject.adType isEqualToString:@"1"] && !sponsorshipsObject.isReported) {
                    [sponsorshipsObject reportSponsorShipLoad:newsItem];
                    sponsorshipsObject.isReported = YES;
                } else if ([sponsorshipsObject.adType isEqualToString:@"2"] && !sponsorshipsObject.isReported) {
                    [sponsorshipsObject reportSponsorShipEmpty:newsItem];
                    sponsorshipsObject.isReported = YES;
                }
            }
        }
    });
}


#pragma mark 搜索热词
- (void)loadHotSearchWords {
    [[[SNSearchHotV6Request alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger statusCode = [[responseObject objectForKey:@"statusCode"] integerValue];
        if (statusCode == 10000000) {
            NSArray *dataList = [responseObject objectForKey:@"data"];
            NSMutableArray *tmpArray = [NSMutableArray array];
    
            for (int i = 0; i < dataList.count; i++) {
                NSObject *obj = [dataList objectAtIndex:i];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = (NSDictionary *)obj;
                    NSObject *objStr = [dic objectForKey:@"keyWords"];
                    if ([objStr isKindOfClass:[NSString class]]) {
                        [tmpArray addObject:objStr];
                    }
                }
            }
            
            [SNRollingNewsPublicManager sharedInstance].searchHotWord = tmpArray;
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
    }];
}

- (void)setRequestFinishedLoad {
    isLoadingNews = NO;
    [super requestDidFinishLoad:nil];
}

@end
