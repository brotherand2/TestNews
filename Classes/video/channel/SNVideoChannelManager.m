//
//  SNVideoChannelManager.m
//  sohunews
//
//  Created by jojo on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelManager.h"
#import "SNURLJSONResponse.h"
#import "SNDBManager.h"
#import "ASIFormDataRequest.h"
#import "NSObject+YAJL.h"
//#import "SNChannelListRequest.h"

// url topics
#define kVideoUrlTopicsCategorySubscribe            (@"kVideoUrlTopicsCategorySubscribe")
#define kVideoUrlTopicsCategoryUnsubscribe          (@"kVideoUrlTopicsCategoryUnsubscribe")

NSString * const kVideoChannelHotCategoryIdKey = @"kVideoChannelHotCategoryIdKey"; // value -- category id
NSString * const kVideoChannelHotCategorySubResultKey = @"kVideoChannelHotCategorySubResultKey"; //

SNURLRequest * configuredVideoRequest(NSString *url, id delegate, id userInfo);

static SNVideoChannelManager *__gInstance;

@interface SNVideoChannelManager ()

@property (nonatomic, strong) SNURLRequest *requestChannels;
@property (nonatomic, strong) SNURLRequest *requestHotChannelCategories;
@property (nonatomic, strong) ASIFormDataRequest *requestUploadChannels;
//@property (nonatomic, strong) SNChannelListRequest *channelListRequest;

// 某个热门分类 订阅与取消的操作串行，不能并发；
@property (nonatomic, strong) NSMutableDictionary *categorySubscribeRequests;

// for cache
@property (nonatomic, strong) NSMutableArray *allVideoColumns;

@end

@implementation SNVideoChannelManager
@synthesize hasMoreHotChannelCategories;
@synthesize requestChannels = _requestChannels;
@synthesize requestHotChannelCategories = _requestHotChannelCategories;
@synthesize requestUploadChannels = _requestUploadChannels;
@synthesize channels = _channels;
@synthesize hotChannelCategories = _hotChannelCategories;
@synthesize categorySubscribeRequests = _categorySubscribeRequests;
@synthesize allVideoColumns = _allVideoColumns;

+ (SNVideoChannelManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __gInstance = [[self alloc] init];
    });
    return __gInstance;
}

- (void)dealloc {
     //(_requestChannels);
     //(_requestHotChannelCategories);
     //(_requestUploadChannels);
     //(_channels);
     //(_hotChannelCategories);
     //(_categorySubscribeRequests);
     //(_allVideoColumns);
    
}

- (NSMutableArray *)channels {
    if (!_channels) {
        _channels = [[NSMutableArray alloc] init];
    }
    return  _channels;
}

- (NSMutableArray *)hotChannelCategories {
    if (!_hotChannelCategories) {
        _hotChannelCategories = [[NSMutableArray alloc] init];
    }
    return _hotChannelCategories;
}

- (NSMutableDictionary *)categorySubscribeRequests {
    if (!_categorySubscribeRequests) {
        _categorySubscribeRequests = [[NSMutableDictionary alloc] init];
    }
    return _categorySubscribeRequests;
}

- (NSMutableArray *)allVideoColumns {
    if (!_allVideoColumns) {
        _allVideoColumns = [[NSMutableArray alloc] init];
    }
    return _allVideoColumns;
}

#pragma mark - public methods
- (NSArray *)loadVideoChannelsFromLocal {
    return [[SNDBManager currentDataBase] getVideoChannelList];
}

- (void)loadVideoChannelsFromServer {
    // 只保证一个请求在跑；
//    if (!self.requestChannels || !self.requestChannels.isLoading) {
//        self.requestChannels = configuredVideoRequest(kVideoUrlChannel, self, nil);
//        [self.requestChannels send];
//    }
    
//    if (self.channelListRequest) {
//        return;
//    } else {
//        self.channelListRequest = [[SNChannelListRequest alloc] init];
//        __weak typeof(self)weakself = self;
//        [self.channelListRequest send:^(SNBaseRequest *request, id responseObject) {
//            weakself.channelListRequest = nil;
//            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
//                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [weakself parseAndCacheChannels:responseObject];
//                });
//            }
//        } failure:^(SNBaseRequest *request, NSError *error) {
//            weakself.channelListRequest = nil;
//            SNDebugLog(@"%@",error.localizedDescription);
//        }];
//    }
}

- (void)syncAllVideosAndCache:(NSArray *)channels {
    if (channels.count == 0) {
        return;
    }
    
    @synchronized(self.channels) {
        [self.channels removeAllObjects];
        [self.channels addObjectsFromArray:channels];
        // upload
        [self uploadVideoChannelsToServer];
        // cache
        [[SNDBManager currentDataBase] clearVideoChannelList];
        [[SNDBManager currentDataBase] addVideoChannelList:self.channels];
    }
}

- (NSString *)jsonFromVideoChannels {
    NSArray *channels = [self.channels copy];
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    NSMutableArray *upChannels = [NSMutableArray array];
    NSMutableArray *downChannels = [NSMutableArray array];
    
    for (SNVideoChannelObject *channelObj in channels) {
        if ([channelObj.up isEqualToString:@"1"]) {
            [upChannels addObject:channelObj.channelId];
        }
        else {
            [downChannels addObject:channelObj.channelId];
        }
    }
    
    [jsonDic setObject:upChannels forKey:@"up"];
    [jsonDic setObject:downChannels forKey:@"down"];
    
    return [jsonDic yajl_JSONString];
}

- (void)uploadVideoChannelsToServer {
    [_requestUploadChannels setDelegate:nil];
     //(_requestUploadChannels);
    
    NSString *urlString = [SNUtility addParamP1ToURL:kVideoUrlUploadChannelList];
    
    _requestUploadChannels = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    _requestUploadChannels.timeOutSeconds = 30;
    _requestUploadChannels.delegate = self;
    
    NSString *channelListInJson = [self jsonFromVideoChannels];
    if (channelListInJson) {
        [_requestUploadChannels addPostValue:channelListInJson forKey:@"channelList"];
    }
    
    [_requestUploadChannels startAsynchronous];
}

- (void)refreshHotCategories {
    // 只保证一个请求在跑；
    if (!self.requestHotChannelCategories || !self.requestHotChannelCategories.isLoading) {
        self.requestHotChannelCategories = configuredVideoRequest(kVideoUrlHotChannelCategory, self, nil);
        [self.requestHotChannelCategories send];
    }
}

- (void)loadMoreHotCategories {
}

- (BOOL)subscribeACategoryWithColumnId:(NSString *)columnId {
    if (!columnId || ![columnId isKindOfClass:[NSString class]] || columnId.length == 0) {
        SNDebugLog(@"%@ - %@ : invalidate column id %@",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd),
                   columnId);
        return NO;
    }
    
    SNURLRequest *existRequest = [self.categorySubscribeRequests objectForKey:columnId ofClass:[SNURLRequest class] defaultObj:nil];
    if (existRequest) {
        SNDebugLog(@"%@ - %@ : a request`s with column id %@ already running .",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd),
                   columnId);
        [existRequest.delegates removeObject:self];
        [existRequest cancel];
    }
    
    NSString *requestUrl = [NSString stringWithFormat:kVideoUrlCategorySubscribe, columnId, @"0"];
    TTUserInfo *userInfo = [TTUserInfo topic:kVideoUrlTopicsCategorySubscribe strongRef:columnId weakRef:nil];
    
    SNURLRequest *request = configuredVideoRequest(requestUrl, self, userInfo);
    
    if (request) {
        [self.categorySubscribeRequests setObject:request forKey:columnId];
    }
    
    [request send];
    
    return YES;
}

- (BOOL)unsubscribeACategoryWithColumnId:(NSString *)columnId {
    if (!columnId || ![columnId isKindOfClass:[NSString class]] || columnId.length == 0) {
        SNDebugLog(@"%@ - %@ : invalidate column id %@",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd),
                   columnId);
        return NO;
    }
    
    SNURLRequest *existRequest = [self.categorySubscribeRequests objectForKey:columnId ofClass:[SNURLRequest class] defaultObj:nil];
    if (existRequest) {
        SNDebugLog(@"%@ - %@ : a request`s with column id %@ already running .",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd),
                   columnId);
        [existRequest.delegates removeObject:self];
        [existRequest cancel];
    }
    
    NSString *requestUrl = [NSString stringWithFormat:kVideoUrlCategorySubscribe, columnId, @"1"];
    TTUserInfo *userInfo = [TTUserInfo topic:kVideoUrlTopicsCategoryUnsubscribe strongRef:columnId weakRef:nil];
    
    SNURLRequest *request = configuredVideoRequest(requestUrl, self, userInfo);
    
    if (request) {
        [self.categorySubscribeRequests setObject:request forKey:columnId];
    }
    
    [request send];
    
    return YES;
}

#pragma mark - TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
    if (request == self.requestHotChannelCategories) {
        // notify
        //dispatch_async(dispatch_get_main_queue(), ^{
            [SNNotificationManager postNotificationName:kVideoChannelDidStartLoadCategoriesNotification
                                                                object:nil
                                                              userInfo:nil];
        //});
    }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    SNURLJSONResponse *jsonRes = request.response;
    TTUserInfo *userInfo = request.userInfo;
//    SNDebugLog(@"%@ \n url %@\n jsonObj %@", NSStringFromSelector(_cmd), request.urlPath, jsonRes.rootObject);
    if (request == self.requestChannels) {
        if (jsonRes && [jsonRes isKindOfClass:[SNURLJSONResponse class]]) {
            NSDictionary *jsonDic = jsonRes.rootObject;
            if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self parseAndCacheChannels:jsonDic];
                });
            }
        }
    }
    else if (request == self.requestHotChannelCategories) {
        if (jsonRes && [jsonRes isKindOfClass:[SNURLJSONResponse class]]) {
            NSDictionary *json = jsonRes.rootObject;
            if (json && [json isKindOfClass:[NSDictionary class]]) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self parseAndCacheHotChannelCategories:json];
                });
            }
            else {
                [SNNotificationManager postNotificationName:kVideoChannelDidFinishLoadCategoriesNotification
                                                                    object:nil
                                                                  userInfo:nil];
            }
        }
    }
    // 热播栏目添加成功
    else if ([userInfo.topic isEqualToString:kVideoUrlTopicsCategorySubscribe]) {
        BOOL bRet = NO;
        if (jsonRes && [jsonRes isKindOfClass:[SNURLJSONResponse class]]) {
            NSDictionary *json = jsonRes.rootObject;
            if (json && [json isKindOfClass:[NSDictionary class]]) {
                NSString *retKey = [json stringValueForKey:@"isSuccess" defaultValue:nil];
                bRet = [retKey rangeOfString:@"s" options:NSCaseInsensitiveSearch].location != NSNotFound;
            }
        }
        
        if (bRet) {
            [[SNDBManager currentDataBase] setVideoColumnSubed:YES byColumnId:userInfo.strongRef];
        }
        
        NSDictionary *retDic = @{kVideoChannelHotCategoryIdKey: userInfo.strongRef,
                                 kVideoChannelHotCategorySubResultKey : bRet ? @"0" : @"-1"};
        [SNNotificationManager postNotificationName:kVideoChannelHotCategorySubDidChangeNotification
                                                            object:nil
                                                          userInfo:retDic];
    }
    // 热播栏目退订成功
    else if ([userInfo.topic isEqualToString:kVideoUrlTopicsCategoryUnsubscribe]) {
        BOOL bRet = NO;
        if (jsonRes && [jsonRes isKindOfClass:[SNURLJSONResponse class]]) {
            NSDictionary *json = jsonRes.rootObject;
            if (json && [json isKindOfClass:[NSDictionary class]]) {
                NSString *retKey = [json stringValueForKey:@"isSuccess" defaultValue:nil];
                bRet = [retKey rangeOfString:@"s" options:NSCaseInsensitiveSearch].location != NSNotFound;
            }
        }
        
        if (bRet) {
            [[SNDBManager currentDataBase] setVideoColumnSubed:NO byColumnId:userInfo.strongRef];
            [[SNDBManager currentDataBase] setVideoColumnReadCount:@"0" byColumnId:userInfo.strongRef];
        }
        
        NSDictionary *retDic = @{kVideoChannelHotCategoryIdKey: userInfo.strongRef,
                                 kVideoChannelHotCategorySubResultKey : bRet ? @"0" : @"-1"};
        [SNNotificationManager postNotificationName:kVideoChannelHotCategorySubDidChangeNotification
                                                            object:nil
                                                          userInfo:retDic];
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    TTUserInfo *userInfo = request.userInfo;
    
    if (request == self.requestChannels) {
        
    }
    else if (request == self.requestHotChannelCategories) {
        
        @synchronized(_hotChannelCategories) {
            [self.hotChannelCategories removeAllObjects];
        }
        
        // notify
        //dispatch_async(dispatch_get_main_queue(), ^{
            [SNNotificationManager postNotificationName:kVideoChannelDidFinishLoadCategoriesNotification
                                                                object:nil
                                                              userInfo:nil];
        //});
    }
    else if ([userInfo.topic isEqualToString:kVideoUrlTopicsCategorySubscribe] ||
             [userInfo.topic isEqualToString:kVideoUrlTopicsCategoryUnsubscribe]) {
        //dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *retDic = @{kVideoChannelHotCategoryIdKey: userInfo.strongRef,
                                     kVideoChannelHotCategorySubResultKey : @"-1"};
            [SNNotificationManager postNotificationName:kVideoChannelHotCategorySubDidChangeNotification
                                                                object:nil
                                                              userInfo:retDic];
        //});
    }
}

#pragma mark - asi http delegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    SNDebugLog(@"%d, %@", request.responseStatusCode, request.responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    SNDebugLog(@"%d, %@", request.responseStatusCode, request);
}

#pragma mark - data parse

- (void)parseAndCacheChannels:(NSDictionary *)jsonDic {
    NSArray *channels = [jsonDic arrayValueForKey:@"channels" defaultValue:nil];
    if (channels) {
        // clean cached data
        NSArray *oldChannels = [self loadVideoChannelsFromLocal];
        BOOL isInitialChannels = YES;
        
        // 这里需要检查是不是内置的频道 (内置5个频道，且utime、ctime、sort字段为0)
        if (oldChannels.count == 5) {
            for (SNVideoChannelObject *chObj in oldChannels) {
                if (chObj.utime.length > 1 ||
                    chObj.ctime.length > 1 ||
                    chObj.sort.length > 1) {
                    isInitialChannels = NO;
                    break;
                }
            }
        }
        else {
            isInitialChannels = NO;
        }
        
        [self.channels removeAllObjects];
        BOOL hasNew = NO;
        
        for (id aChannelObj in channels) {
            SNVideoChannelObject *chObj = [SNVideoChannelObject chennelObjectFromDataObj:aChannelObj];
            if (chObj) {
                if (oldChannels && ![oldChannels containsObject:chObj]) {
                    if (!isInitialChannels) {
                        chObj.isNew = YES;
                    }
                    hasNew = YES;
                }
                [self.channels addObject:chObj];
            }
        }

        // notify
        dispatch_async(dispatch_get_main_queue(), ^{
            [SNNotificationManager postNotificationName:kVideoChannelDidFinishLoadNotification
                                                                object:nil
                                                              userInfo:@{@"hasNew": hasNew ? @"1" : @"0"}];
        });
        
        [[SNDBManager currentDataBase] clearVideoChannelList];
        [[SNDBManager currentDataBase] addVideoChannelList:self.channels];
    }
}

- (void)parseAndCacheHotChannelCategories:(NSDictionary *)jsonDic {
    [self.hotChannelCategories removeAllObjects];
    [self.allVideoColumns removeAllObjects];
    
    // 数据结构改变 之前的解析方法作废
#if 0
    NSArray *weiboArray = [jsonDic arrayValueForKey:@"weiboData" defaultValue:nil];
    if (weiboArray) {
        SNVideoHotChannelCategoriSectionObj *weiboSection = [[SNVideoHotChannelCategoriSectionObj alloc] init];
        weiboSection.textAlignment = NSTextAlignmentCenter;
        weiboSection.sectionTitle = @"绑定社交账号,观看好友分享的视频";
        [weiboSection parseSectionObjs:weiboArray];
        
        [self.hotChannelCategories addObject:weiboSection];
    }
    
    NSArray *categoriesArray = [jsonDic arrayValueForKey:@"data" defaultValue:nil];
    if (categoriesArray) {
        SNVideoHotChannelCategoriSectionObj *categorySection = [[SNVideoHotChannelCategoriSectionObj alloc] init];
        categorySection.textAlignment = NSTextAlignmentLeft;
        categorySection.sectionTitle = @"栏目";
        [categorySection parseSectionObjs:categoriesArray];
        
        [self.hotChannelCategories addObject:categorySection];
    }
#endif
    
    NSArray *categoriesArr = [jsonDic arrayValueForKey:@"categoryData" defaultValue:nil];
    for (id obj in categoriesArr) {
        SNVideoHotChannelCategoriSectionObj *aSection = [SNVideoHotChannelCategoriSectionObj sectionObjWithDataObject:obj];
        if (aSection) {
            [self.hotChannelCategories addObject:aSection];
            for (SNVideoChannelCategoryObject *cgObj in aSection.categories) {
                SNVideoColumnCacheObj *colObj = [cgObj toVideoColumnObj];
                [self.allVideoColumns addObject:colObj];
            }
        }
    }
    
    [self.hotChannelCategories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[SNVideoHotChannelCategoriSectionObj class]] && [obj2 isKindOfClass:[SNVideoHotChannelCategoriSectionObj class]]) {
            SNVideoHotChannelCategoriSectionObj *s1 = obj1, *s2 = obj2;
            return -[s1.categoryType compare:s2.categoryType options:NSNumericSearch];
            
        }
        return NSOrderedSame;
    }];
    
    [[SNDBManager currentDataBase] setVideoColumns:self.allVideoColumns];
    
    // notify
    dispatch_async(dispatch_get_main_queue(), ^{
        [SNNotificationManager postNotificationName:kVideoChannelDidFinishLoadCategoriesNotification
                                                            object:nil
                                                          userInfo:nil];
    });
}

@end


SNURLRequest * configuredVideoRequest(NSString *url, id delegate, id userInfo) {
    SNURLRequest *aReq = [SNURLRequest requestWithURL:url delegate:delegate];
    aReq.timeOut = 30;
    aReq.cachePolicy = TTURLRequestCachePolicyNoCache;
    aReq.response = [[SNURLJSONResponse alloc] init];
    aReq.userInfo = userInfo;
    
    return aReq;
}
