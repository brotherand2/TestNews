//
//  SNLiveModel.m
//  sohunews
//
//  Created by yanchen wang on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveModel.h"
#import "SNLiveListRequest.h"
//#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "CacheObjects.h"
#import "SNDBManager.h"
#import "SNLiveSubscribeService.h"
#import "SNHisLivesRequest.h"

#define kRequestTodayTag                (1)
#define kRequestForecastTag             (2)
#define kRequestSubscribeTopic          (@"subscribe")
#define kRequestListTag                 (3)
#define kRequestHistoryTag              (4)

static NSString * const kLiveModelSectionTitles = @"kLiveModelSectionTitles";
static NSString * const kLiveModelSectionCounts = @"kLiveModelSectionCounts";

@interface SNLiveModel ()

@property (nonatomic, strong) SNHisLivesRequest *hisLivesRequest;
@property (nonatomic, assign) BOOL requestLoaing;
@end

@implementation SNLiveModel
@synthesize channelID = _channelID;
@synthesize livingGamesToday = _livingGamesToday;
@synthesize livingCategoryArr = _livingCategoryArr;
@synthesize livingGamesForecast = _livingGamesForecast;
@synthesize livingGamesHistory = _livingGamesHistory;
@synthesize sectionsArray = _sectionsArray;
@synthesize needRefreshOnStart;

- (id)initWithChannelID:(NSString *)channelID {
    self = [super init];
    if (self) {
        if ([channelID length] > 0) {
            self.channelID = [NSString stringWithFormat:@"%@", channelID];
        }
        else {
            self.channelID = @"-1";
        }
        
        self.livingGamesToday = [NSMutableArray array];
        self.livingCategoryArr = [NSMutableArray array];
        self.livingGamesForecast = [NSMutableArray array];
        self.livingGamesHistory = [NSMutableArray array];
        
        _livingGameSectionTitles = [[NSMutableArray alloc] init];
        _livingGameSectionCounts = [[NSMutableArray alloc] init];
        
        self.needRefreshOnStart = YES;
    }
    return self;
}

- (void)dealloc {
//    if (_requestToday) {
//        [_requestToday.delegates removeObject:self];
//        [_requestToday cancel];
//         //(_requestToday);
//    }
//
//    if (_requestForecast) {
//        [_requestForecast.delegates removeObject:self];
//        [_requestForecast cancel];
//         //(_requestForecast);
//    }
//    
//    if (_requestList) {
//        [_requestList.delegates removeObject:self];
//        [_requestList cancel];
//         //(_requestList);
//    }
//    
//    if (_requestHistory) {
//        [_requestHistory.delegates removeObject:self];
//        [_requestHistory cancel];
//         //(_requestHistory);
//    }

     //(_channelID);
     //(_livingGamesToday);
     //(_livingCategoryArr);
     //(_livingGamesForecast);
     //(_livingGamesHistory);
     //(_livingGameSectionTitles);
     //(_livingGameSectionCounts);
    
     //(_sectionsArray);
     //(_todayLiveDate);
     //(_items);
}

- (void)cancel {
    isCancelLoading = YES;
//    if (_requestToday) {
//        [_requestToday cancel];
//    }
//    if (_requestForecast) {
//        [_requestForecast cancel];
//    }
//    if (_requestList) {
//        [_requestList cancel];
//    }
//    if (_requestHistory) {
//        [_requestHistory cancel];
//    }
//    if (_requestList.isLoading) {
//        [super requestDidCancelLoad:nil];
//    }
}

#pragma mark - private Methods
- (void)requestDidFinishLoad {
    if (!isCancelLoading) {
        [super requestDidFinishLoad:nil];
    }
    else {
        [super requestDidCancelLoad:nil];
    }
}

- (void)updateLiveGame:(LivingGameItem *)game {
    @autoreleasepool {
        [[SNDBManager currentDataBase] updateLivingGame:game];
    }
}

+ (LivingGameItem *)createTodayLivingGameItemByDicInfo:(NSDictionary *)dicInfo
                                               isFocus:(BOOL)isFocus
                                               isToday:(BOOL)isToday {
    if (!dicInfo) {
        return nil;
    }
    LivingGameItem *aGame = [[LivingGameItem alloc] initWithDictionary:dicInfo];
    aGame.reserveFlag = @"";
    aGame.isToday = isToday ? @"1" : @"0";
    aGame.isFocus = isFocus ? @"1" : @"0";
    
    return aGame;
}

+ (LiveCategoryItem *)createLivingCategoryItemByDicInfo:(NSDictionary *)dicInfo {
    if (!dicInfo) {
        return nil;
    }
    LiveCategoryItem *item = [[LiveCategoryItem alloc] initWithDictionary:dicInfo];
    return item;
}

+ (NSArray *)createForeLivingGameItemArrayByDicInfo:(NSDictionary *)dicInfo {
    if (!dicInfo) {
        return nil;
    }
    
    NSString *liveDay = [dicInfo objectForKey:@"liveDay" defalutObj:@""];
    NSString *liveDate = [dicInfo objectForKey:@"liveDate" defalutObj:@""];
    NSMutableArray *gamesArray = [[NSMutableArray alloc] init];
    id lives = [dicInfo objectForKey:@"lives" defalutObj:nil];
    
    if (lives && [lives isKindOfClass:[NSArray class]]) {
        for (NSDictionary *aGameDic in lives) {
            @autoreleasepool {
                LivingGameItem *aGame = [self createTodayLivingGameItemByDicInfo:aGameDic isFocus:NO isToday:NO];
                if (aGame) {
                    aGame.liveDay = liveDay;
                    aGame.liveDate = liveDate;
                    [gamesArray addObject:aGame];
                }
            }
        }
    }
    else if (lives && [lives isKindOfClass:[NSDictionary class]]) {
        @autoreleasepool {
            LivingGameItem *aGame = [self createTodayLivingGameItemByDicInfo:lives isFocus:NO isToday:NO];
            if (aGame) {
                aGame.liveDay = liveDay;
                aGame.liveDate = liveDate;
                [gamesArray addObject:aGame];
            }
        }
    }
    
    return gamesArray;
}

+ (NSArray *)createHistoryLivingGameItemArrayByDicInfo:(NSDictionary *)dicInfo {
    if (!dicInfo) {
        return nil;
    }

    NSArray *gamesArray = [self createForeLivingGameItemArrayByDicInfo:dicInfo];
    return gamesArray;
}


// 刷新直播列表
//- (void)refreshLivingGames {
//    NSString *url = SNLinks_Path_Live_LiveList;
//    
//    if (!_requestList) {
//        _requestList = [SNURLRequest requestWithURL:url delegate:self];
//        _requestList.cachePolicy = TTURLRequestCachePolicyNoCache;
//        _requestList.userInfo = [NSNumber numberWithInt:kRequestListTag];
//    }
//    else {
//        _requestList.urlPath = url;
//    }
//    
//    if (isRefreshManually) {
//        _requestList.isShowNoNetWorkMessage = YES;
//    }
//    else {
//        _requestList.isShowNoNetWorkMessage = NO;
//    }
//    if (!_requestList.isLoading) {
//        _bHistoryLoadMore = NO;
//        
//        _requestList.response = [[SNURLJSONResponse alloc] init];
//        [_requestList send];
//    }
//}

- (void)refreshLivingGames {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        if (isRefreshManually) {
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        }
        return;
    }

    if (self.requestLoaing) {
        return;
    }
    
    self.requestLoaing = YES;
    [[[SNLiveListRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        self.requestLoaing = NO;
        if (responseObject) {
            self.hasNoMore = NO;
            [self saveCacheLivingTodayGames:responseObject];
            /*
             [self saveCacheLivingCategoryItems:json.rootObject]; // what ?
             [self saveCacheLivingForecastGames:json.rootObject];
             */
        } else {
            [_livingGamesToday removeAllObjects];
            
            /*
             [_livingCategoryArr removeAllObjects];
             [_livingGamesForecast removeAllObjects];
             */
            
            [[SNDBManager currentDataBase] updateTodayLivingGames:_livingGamesToday];
            
            /*
             [[SNDBManager currentDataBase] updateForecastLivingGames:_livingGamesForecast];
             */
        }
        [self.livingGamesHistory removeAllObjects];
        
        [self requestDidFinishLoad];
        
        [self refreshHistoryGamesFromDate:self.todayLiveDate more:NO];
        
        [self setRefreshedTime];
        [self setRefreshStatusOfUpgrade];
        [[SNAppStateManager sharedInstance] loadedChannelNewsWith:self.channelId];

    } failure:^(SNBaseRequest *request, NSError *error) {
        self.requestLoaing = NO;
        [self didFailLoadWithError:error];
        SNDebugLog(@"%@",error.userInfo);
    }];
    [self didStartLoad];
}

- (BOOL)isLoading {
    return self.requestLoaing;
}
//- (void)refreshHistoryGamesFromDate:(NSString *)liveDate more:(BOOL)bMore {
//    NSString *url = [NSString stringWithFormat:SNLinks_Path_Live_LiveHistory, liveDate];
//
//    if (!_requestHistory) {
//        _requestHistory = [SNURLRequest requestWithURL:url delegate:self];
//        _requestHistory.cachePolicy = TTURLRequestCachePolicyNoCache;
//        _requestHistory.userInfo = [NSNumber numberWithInt:kRequestHistoryTag];
//    }
//    else {
//        _requestHistory.urlPath = url;
//    }
//    
////    if (isRefreshManually) {
//        _requestHistory.isShowNoNetWorkMessage = YES;
////    }
////    else {
////        _requestHistory.isShowNoNetWorkMessage = NO;
////    }
//    if (!_requestHistory.isLoading) {
//        _bHistoryLoadMore = bMore;
//        _requestHistory.response = [[SNURLJSONResponse alloc] init];
//        [_requestHistory send];
//    }
//}


- (void)refreshHistoryGamesFromDate:(NSString *)liveDate more:(BOOL)bMore {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    if (self.hisLivesRequest) {
        return;
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
        if (liveDate != nil) {
            [params setValue:liveDate forKey:@"hisDate"];
        }
        self.hisLivesRequest = [[SNHisLivesRequest alloc] initWithDictionary:params];
        _bHistoryLoadMore = bMore;
    }
    __weak typeof(self)weakself = self;
    [self.hisLivesRequest send:^(SNBaseRequest *request, id responseObject) {
        weakself.hisLivesRequest = nil;
        if (responseObject) {
            [weakself saveCacheLivingHistoryGames:responseObject];
        }
        [weakself requestDidFinishLoad];
        
        [weakself setRefreshedTime];
        [weakself setRefreshStatusOfUpgrade];
        [[SNAppStateManager sharedInstance] loadedChannelNewsWith:weakself.channelId];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        weakself.hisLivesRequest = nil;
    }];
}

- (void)loadCacheLivingGames {
    @autoreleasepool {
        NSArray *livingGames = [[SNDBManager currentDataBase] livingGamesToday];
        if (livingGames) {
            [_livingGamesToday removeAllObjects];
            [_livingGamesToday addObjectsFromArray:livingGames];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *titles = [defaults objectForKey:kLiveModelSectionTitles];
        if (titles) {
            [_livingGameSectionTitles removeAllObjects];
            [_livingGameSectionTitles addObjectsFromArray:titles];
        }
        
        NSArray *counts = [defaults objectForKey:kLiveModelSectionCounts];
        if (counts) {
            [_livingGameSectionCounts removeAllObjects];
            [_livingGameSectionCounts addObjectsFromArray:counts];
        }
        
        if (self.todayLiveDate.length == 0) {
            LivingGameItem *aGame = _livingGamesToday.lastObject;
            self.todayLiveDate = aGame.liveTime;
        }
        
        livingGames = [[SNDBManager currentDataBase] livingGamesForecast];
        if (livingGames) {
            [_livingGamesForecast removeAllObjects];
            [_livingGamesForecast addObjectsFromArray:livingGames];
        }
        
        NSArray *livingCategoryItems = [[SNDBManager currentDataBase] livingCategoryItems];
        if (livingCategoryItems) {
            [_livingCategoryArr removeAllObjects];
            [_livingCategoryArr addObjectsFromArray:livingCategoryItems];
        }
    }
}

- (void)saveCacheLivingTodayGames:(id)rootObj {
    @autoreleasepool {
        if ([rootObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = rootObj;
            [_livingGamesToday removeAllObjects];
            [_livingGameSectionTitles removeAllObjects];
            [_livingGameSectionCounts removeAllObjects];
            
            self.todayLiveDate = [dic stringValueForKey:@"liveDate" defaultValue:nil];
            
            id obj1 = [dic objectForKey:@"focusLives" defalutObj:nil];
            if (obj1) {
                if ([obj1 isKindOfClass:[NSArray class]]) {
                    for (id aObj in obj1) {
                        if ([aObj isKindOfClass:[NSDictionary class]]) {
                            @autoreleasepool {
                                LivingGameItem *aGame = [SNLiveModel createTodayLivingGameItemByDicInfo:aObj isFocus:YES isToday:YES];
                                if(aGame) [_livingGamesToday addObject:aGame];
                            }
                        }
                    }
                    
                    [_livingGameSectionCounts addObject:@(((NSArray *)obj1).count)];
                }
                else if ([obj1 isKindOfClass:[NSDictionary class]]) {
                    @autoreleasepool {
                        LivingGameItem *aGame = [SNLiveModel createTodayLivingGameItemByDicInfo:obj1 isFocus:YES isToday:YES];
                        if(aGame) [_livingGamesToday addObject:aGame];
                    }
                    
                    [_livingGameSectionCounts addObject:@(1)];
                } else {
                    [_livingGameSectionCounts addObject:@(0)];
                }
            } else {
                [_livingGameSectionCounts addObject:@(0)];
            }
            
            id obj2 = [dic objectForKey:@"todayLives" defalutObj:nil];
            if (obj2) {
                if ([obj2 isKindOfClass:[NSArray class]]) {
                    for (id aObj in obj2) {
                        if ([aObj isKindOfClass:[NSDictionary class]]) {
                            
                            NSArray *lives = aObj[@"lives"];
                            if ([lives isKindOfClass:[NSArray class]]) {
                                [lives enumerateObjectsUsingBlock:^(NSDictionary *everyLive, NSUInteger idx, BOOL *stop) {
                                    if ([everyLive isKindOfClass:[NSDictionary class]]) {
                                        @autoreleasepool {
                                            LivingGameItem *aGame = [SNLiveModel createTodayLivingGameItemByDicInfo:everyLive isFocus:NO isToday:YES];
                                            if(aGame) {
                                                [_livingGamesToday addObject:aGame];
                                            }
                                        }
                                    }
                                }];
                                
                                [_livingGameSectionCounts addObject:@(lives.count)];
                                
                            } else {
                                [_livingGameSectionCounts addObject:@(0)];
                            }
                            
                            NSString *name = aObj[@"name"];
                            NSNumber *blockType = (aObj[@"blockType"] ? : @(-1)); // v5.2.1 新增类型字段
                            if ([name isKindOfClass:[NSString class]] && [name length] > 0) {
                                [_livingGameSectionTitles addObject:@{@"name" : name, @"blockType" : blockType}];
                            } else {
                                [_livingGameSectionTitles addObject:@{}];
                            }
                            
                        }
                    }
                }
                else if ([obj2 isKindOfClass:[NSDictionary class]]) {
                    @autoreleasepool {
                        LivingGameItem *aGame = [SNLiveModel createTodayLivingGameItemByDicInfo:obj2 isFocus:NO isToday:YES];
                        if(aGame) [_livingGamesToday addObject:aGame];
                    }
                }
            }
            
            NSMutableArray *gamesArray = [[NSMutableArray alloc] initWithArray:_livingGamesToday];
            [[SNDBManager currentDataBase] updateTodayLivingGames:gamesArray];
             //(gamesArray);
            
            [self saveSectionTitlesAndCountsToCache];
            
            // 这里不再采用从数据库读取的方式 merge新数据 在上一步存数据库的时候如果出错就有问题了
            NSArray *oldLiveItems = [[SNDBManager currentDataBase] livingGamesToday];
            for (LivingGameItem *newItem in _livingGamesToday) {
                for (LivingGameItem *oldItem in oldLiveItems) {
                    if ([newItem.liveId isEqualToString:oldItem.liveId]) {
                        newItem.reserveFlag = oldItem.reserveFlag;
                        break;
                    }
                }
            }
        }
    }
}

- (void)saveCacheLivingCategoryItems:(id)rootObj {
    @autoreleasepool {
        if ([rootObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = rootObj;
            [_livingCategoryArr removeAllObjects];
            id subInfo = [dic objectForKey:@"subInfo" defalutObj:nil];
            if (subInfo) {
                if ([subInfo isKindOfClass:[NSArray class]]) {
                    for (id liveCategory in subInfo) {
                        if ([liveCategory isKindOfClass:[NSDictionary class]]) {
                            @autoreleasepool {
                                LiveCategoryItem *categoryItem = [SNLiveModel createLivingCategoryItemByDicInfo:liveCategory];
                                if (categoryItem) {
                                    [_livingCategoryArr addObject:categoryItem];
                                }
                            }
                        }
                    }
                }
            }
            NSMutableArray *gamesArray = [[NSMutableArray alloc] initWithArray:_livingCategoryArr];
            [[SNDBManager currentDataBase] updateLivingCategoryItems:gamesArray];
             //(gamesArray);
        }
    }
}

- (void)saveCacheLivingForecastGames:(id)rootObj {
    @autoreleasepool {
        if ([rootObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = rootObj;
            [_livingGamesForecast removeAllObjects];
            id foreLives = [dic objectForKey:@"foreLives" defalutObj:nil];
            if (foreLives) {
                if ([foreLives isKindOfClass:[NSArray class]]) {
                    for (id liveGame in foreLives) {
                        if ([liveGame isKindOfClass:[NSDictionary class]]) {
                            @autoreleasepool {
                                NSArray *gamesArray = [SNLiveModel createForeLivingGameItemArrayByDicInfo:liveGame];
                                if(gamesArray) [_livingGamesForecast addObjectsFromArray:gamesArray];
                            }
                        }
                    }
                }
                else if ([foreLives isKindOfClass:[NSDictionary class]]) {
                    @autoreleasepool {
                        NSArray *gamesArray = [SNLiveModel createForeLivingGameItemArrayByDicInfo:foreLives];
                        if(gamesArray) [_livingGamesForecast addObjectsFromArray:gamesArray];
                    }
                }
            }
            
            NSMutableArray *gamesArray = [[NSMutableArray alloc] initWithArray:_livingGamesForecast];
            
            BOOL bRet = NO;
            bRet = [[SNDBManager currentDataBase] updateForecastLivingGames:gamesArray];
            
            if (bRet) {
                [_livingGamesForecast removeAllObjects];
                [_livingGamesForecast addObjectsFromArray:[[SNDBManager currentDataBase] livingGamesForecast]];
            }
        }
    }
}

- (void)saveCacheLivingHistoryGames:(id)rootObj {
    @autoreleasepool {
        if ([rootObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = rootObj;
            
            if ([[dic stringValueForKey:@"isSuccess" defaultValue:nil] isEqualToString:@"S"]) {
                if (!_bHistoryLoadMore) {
                    [_livingGamesHistory removeAllObjects];
                }
                
                id response = [dic objectForKey:@"response" defalutObj:nil];
                if (response) {
                    if ([response isKindOfClass:[NSDictionary class]]) {
                        id hisLiveList = [response objectForKey:@"hisLiveList" defalutObj:nil];
                        if ([hisLiveList isKindOfClass:[NSArray class]]) {
                            for (id liveGame in hisLiveList) {
                                if ([liveGame isKindOfClass:[NSDictionary class]]) {
                                    @autoreleasepool {
                                        NSArray *gamesArray = [SNLiveModel createHistoryLivingGameItemArrayByDicInfo:liveGame];
                                        if(gamesArray) [_livingGamesHistory addObjectsFromArray:gamesArray];
                                    }
                                }
                            }
                            
                            NSString *liveDate = [[hisLiveList lastObject] stringValueForKey:@"liveDate" defaultValue:nil];
                            self.lastHistoryLiveDate = liveDate;
                            
                            if ([(NSArray *)hisLiveList count] == 0) {
                                self.hasNoMore = YES;
                            }
                        }
                    }
                }
            } else {
                self.hasNoMore = YES;
            }
        }
    }
}

//TODO:待优化 缓存处理
- (void)saveSectionTitlesAndCountsToCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_livingGameSectionTitles forKey:kLiveModelSectionTitles];
    [defaults setObject:_livingGameSectionCounts forKey:kLiveModelSectionCounts];
    [defaults synchronize];
}

#pragma mark - TTModel
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    //self.hasNoMore = YES;
    isCancelLoading = NO;
    loadMore = more;
    
    if (more) {
        if (_livingGamesHistory.count > 0) {
            [self refreshHistoryGamesFromDate:self.lastHistoryLiveDate more:YES];
        } else {
            [self refreshHistoryGamesFromDate:self.todayLiveDate more:NO];
        }
    } else {
        /*
        if (TTURLRequestCachePolicyLocal == cachePolicy) {
            [self loadCacheLivingGames];
            
            if ([_livingGamesToday count] + [_livingGamesForecast count] > 0) {
                [self requestDidFinishLoad];
            } else {
                [self requestDidFinishLoad];
            }
        } else {
            [self refreshLivingGames];
        }
         */
        if (_livingGamesToday.count <= 0) {
            [self didCancelLoad];
        }
        [self refreshLivingGames];
    }
}

//#pragma mark - TTURLRequestDelegate
//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//    if ([request.userInfo isKindOfClass:[NSNumber class]]) {
//        int requestTag = [request.userInfo intValue];
//        if (requestTag == kRequestTodayTag) {
//            SNURLJSONResponse *json = request.response;
////            SNDebugLog(@"today live model receive json :\n%@", json.rootObject);
//            if (json.rootObject) {
//                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [self saveCacheLivingTodayGames:json.rootObject];
//                //});
//
//            } else {
//                [_livingGamesToday removeAllObjects];
//                [[SNDBManager currentDataBase] updateTodayLivingGames:_livingGamesToday];
//                [self requestDidFinishLoad];
//            }
//        }
//        else if (requestTag == kRequestForecastTag) {
//            SNURLJSONResponse *json = request.response;
////            SNDebugLog(@"forecast live model receive json :\n%@", json.rootObject);
//            if (json.rootObject) {
//                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [self saveCacheLivingForecastGames:json.rootObject];
//                //});
//            } else {
//                [_livingGamesForecast removeAllObjects];
//                [[SNDBManager currentDataBase] updateForecastLivingGames:_livingGamesForecast];
//                [self requestDidFinishLoad];
//            }
//        }
//        else if (requestTag == kRequestListTag) {
//            SNURLJSONResponse *json = request.response;
//            if (json.rootObject) {
//                self.hasNoMore = NO;
//                [self saveCacheLivingTodayGames:json.rootObject];
//                /*
//                [self saveCacheLivingCategoryItems:json.rootObject]; // what ?
//                [self saveCacheLivingForecastGames:json.rootObject];
//                 */
//            } else {
//                [_livingGamesToday removeAllObjects];
//                
//                /*
//                [_livingCategoryArr removeAllObjects];
//                [_livingGamesForecast removeAllObjects];
//                 */
//                
//                [[SNDBManager currentDataBase] updateTodayLivingGames:_livingGamesToday];
//                
//                /*
//                [[SNDBManager currentDataBase] updateForecastLivingGames:_livingGamesForecast];
//                 */
//            }
//            [self.livingGamesHistory removeAllObjects];
//
//            [self requestDidFinishLoad];
//            
//            [self refreshHistoryGamesFromDate:self.todayLiveDate more:NO];
//        }
//        else if (requestTag == kRequestHistoryTag) {
//            SNURLJSONResponse *json = request.response;
//            if (json.rootObject) {
//                [self saveCacheLivingHistoryGames:json.rootObject];
//            }
//            [self requestDidFinishLoad];
//        }
//        
//        [self setRefreshedTime];
//        [self setRefreshStatusOfUpgrade];
//        [[SNAppStateManager sharedInstance] loadedChannelNewsWith:self.channelId];
//    }
//}
//
//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
//    if ([request.userInfo isKindOfClass:[NSNumber class]]) {
//        [self requestDidFinishLoad];
//    }
//}

- (BOOL)isLoadingMore {
    return _bHistoryLoadMore || loadMore;
}

#pragma mark - SNNewsModel Protocol
- (NSString *)channelId {
    return self.channelID;
}

- (BOOL)hasRecommendNews {
    return NO;
}

- (NSTimeInterval)refreshIntervalWithDefault:(NSTimeInterval)interval {
    return kChannelWeiboRefreshInterval;
}

#pragma mark - drag refresh

- (NSDate *)refreshedTime {
    
	NSDate *time = nil;
    
    NSString *timeKey = [NSString stringWithFormat:@"channel_%@_refresh_time", _channelID];
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
	if (data && [data isKindOfClass:[NSDate class]]) {
		time = data;
	}
    
	return time;
}

- (void)setRefreshedTime {
	NSString *timeKey = [NSString stringWithFormat:@"channel_%@_refresh_time", _channelID];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:timeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
