//
//  SNLiveRoomModel.m
//  sohunews
//
//  Created by chenhong on 13-4-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomModel.h"
#import "SNURLJSONResponse.h"
#import "SNURLDataResponse.h"
#import "NSDictionaryExtend.h"
#import "GTMNSString+HTML.h"
#import "NSObject+YAJL.h"
#import "NSString+Utilities.h"
#import "SNLiveRoomConsts.h"
#import "TTErrorCodes.h"
#import "SNAdManager.h"
#import "SNLiveDataRequest.h"

#define PAGE_COUNT 10
#define LIVE_TIMEOUT 90


@interface SNLiveRoomModel () {
    BOOL _bLoadMore;
    BOOL _hasNoMore;
    
    NSMutableArray *_contentsArrayTemp;
}

@property (nonatomic, assign) BOOL requestLoading;

@end

@implementation SNLiveRoomModel

@synthesize delegate=_delegate;
@synthesize matchInfo=_matchInfo, contentsArray=_contentsArray, commentsArray=_commentsArray, mergedArray=_mergedArray;
@synthesize liveId=_liveId, rollingType=_rollingType, contentId=_contentId, commentId=_commentId, type=_type;
@synthesize subServer=_subServer;
@synthesize receivedContentItems=_receivedContentItems;
@synthesize receivedMergeItems=_receivedMergeItems;

- (id)initWithLiveId:(NSString *)liveId type:(NSString *)type {
    if (self = [super init]) {
        self.liveId             = liveId;//TEST_LIVEID;//
        self.rollingType        = @"0";
        self.type               = type;
        
        _receivedData           = [[NSMutableData alloc] init];
        _receivedContentItems   = [[NSMutableArray alloc] init];
        //_receivedCommentItems   = [[NSMutableArray alloc] init];
        _receivedMergeItems     = [[NSMutableArray alloc] init];
        
        self.subServer          = SNLinks_DEFALUT_SUB_SERVER;
        
        _contentsArrayTemp      = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isLoading {
    return self.requestLoading;
}

- (BOOL)hasNoMore {
    return _hasNoMore;
}

- (void)cancel {
//	if (_request) {
//		[_request cancel];
//        [_request.delegates removeObject:self];
//	}
    if (_asiRequest) {
        [_asiRequest clearDelegatesAndCancel];
    }
    if (_networkQueue) {
        [_networkQueue reset];
    }
    // 清空
    [_receivedContentItems removeAllObjects];
    //[_receivedCommentItems removeAllObjects];
    [_receivedMergeItems removeAllObjects];
    [_receivedData setLength:0];
}

- (void)dealloc {
    [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
    [_asiRequest clearDelegatesAndCancel];
    [_networkQueue reset];
}

- (void)refresh {
    if (self.requestLoading) return;
    if ([_liveId length] == 0 || [_liveId isEqualToString:@"0"]) {
        SNDebugLog(@"no liveId!");
        return;
    }
    
    _bLoadMore = NO;
    
    self.rollingType    = @"0";
    self.contentId      = @"0";
    self.commentId      = @"0";

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:_liveId forKey:@"liveId"];
    [params setValue:_rollingType forKey:@"rollingType"];
    [params setValue:_contentId forKey:@"contentId"];
    [params setValue:_commentId forKey:@"commentId"];
    [params setValue:([_type intValue] == 0 ? @"2" : _type) forKey:@"type"];
    if (_matchInfo.ts.length) {
        [params setValue:_matchInfo.ts forKey:@"ts"];
    }
    self.requestLoading = YES;
    [[[SNLiveDataRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        self.requestLoading = NO;
        if (responseObject) {
            [self handleLiveDataRequestWithResponseObject:responseObject];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        self.requestLoading = NO;
        if ([_delegate respondsToSelector:@selector(liveRoomDidFailLoadWithError:)]) {
            [_delegate liveRoomDidFailLoadWithError:error];
        }
    }];
}

// 发送长连接请求
- (void)sendPushRequest {
    NSString *url = [NSString stringWithFormat:@"%@/sub/channel_%@_v2.b5", _subServer, _liveId];
    SNDebugLog(@"%@", url);
    
    if (_networkQueue) {
        [_networkQueue cancelAllOperations];
         //(_networkQueue);
    }
    
    if (_asiRequest) {
        [_asiRequest clearDelegatesAndCancel];
         //(_asiRequest);
    }
    _networkQueue = [ASINetworkQueue queue];
    
    _asiRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    _asiRequest.timeOutSeconds = LIVE_TIMEOUT;
    _asiRequest.shouldAttemptPersistentConnection = YES;
    [_asiRequest setNumberOfTimesToRetryOnTimeout:3];
    _asiRequest.delegate = self;
    [_networkQueue addOperation:_asiRequest];
    [_networkQueue go];
}

- (void)loadMore {
    if (self.requestLoading) return;
    _bLoadMore = YES;
    
    // 下滚
    self.rollingType = @"1";
    
    if (self.contentsArray.count > 0) {
        SNLiveContentObject *last = self.contentsArray.lastObject;
        self.contentId = [NSString stringWithFormat:@"%@", last.contentId];
    } else {
        self.contentId = @"0";
    }
    
    if (self.commentsArray.count > 0) {
        SNLiveCommentObject *last = self.commentsArray.lastObject;
        self.commentId = [NSString stringWithFormat:@"%@", last.commentId];
    } else {
        self.commentId = @"0";
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:_liveId forKey:@"liveId"];
    [params setValue:_rollingType forKey:@"rollingType"];
    [params setValue:_contentId forKey:@"contentId"];
    [params setValue:_commentId forKey:@"commentId"];
    if ([_type intValue] == 0) {
        [params setValue:@"2" forKey:@"type"];
        [params setValue:[NSString stringWithFormat:@"%zd",_bottomCursor] forKey:@"cursor"];
    } else {
        [params setValue:_type forKey:@"type"];
    }
    self.requestLoading = YES;
    [[[SNLiveDataRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        self.requestLoading = NO;
        if (responseObject) {
            [self handleLiveDataRequestWithResponseObject:responseObject];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        self.requestLoading = NO;
        if ([_delegate respondsToSelector:@selector(liveRoomDidFailLoadWithError:)]) {
            [_delegate liveRoomDidFailLoadWithError:error];
        }
    }];

}

- (void)handleLiveDataRequestWithResponseObject:(id)responseObject {
    NSDictionary *rootData = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        rootData = (NSDictionary *)responseObject;
    } else {
        rootData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
    }
    [self requestDidFinishLoadWithData:rootData];
    
    if (!_bLoadMore) {
        [self setRefreshedTime];
        
        [_receivedContentItems removeAllObjects];
        [_receivedMergeItems removeAllObjects];
        
        // 有数据时才请求push
        if (([_type intValue] == 0 && self.mergedArray.count > 0) ||
            ([_type intValue] == 1 && self.contentsArray.count > 0)) {
            // 刷新data.go结束后，发送长连接请求，建立服务器push机制
            [self sendPushRequest];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(liveRoomDidFinishLoad)]) {
        [_delegate liveRoomDidFinishLoad];
    }

}

#pragma mark - TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    SNURLJSONResponse *dataRes = (SNURLJSONResponse *)request.response;
	id rootData = dataRes.rootObject;
    
    [self requestDidFinishLoadWithData:rootData];

    if (!_bLoadMore) {
        [self setRefreshedTime];
        
        [_receivedContentItems removeAllObjects];
        [_receivedMergeItems removeAllObjects];
        
        // 有数据时才请求push
        if (([_type intValue] == 0 && self.mergedArray.count > 0) ||
            ([_type intValue] == 1 && self.contentsArray.count > 0)) {
            // 刷新data.go结束后，发送长连接请求，建立服务器push机制
            [self sendPushRequest];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(liveRoomDidFinishLoad)]) {
        [_delegate liveRoomDidFinishLoad];
    }
}

- (void)requestDidFinishLoadWithData:(id)rootData {
    if (!_bLoadMore) {
        if ([_type intValue] == 0 && [_contentId intValue] == 0 && [_commentId intValue] == 0) {
            self.mergedArray = [NSMutableArray array];
        } else if ([_type intValue] == 1 && [_contentId intValue] == 0) {
            if([self.contentsArray count] <= 0){
                id liveContents = [rootData objectForKey:@"liveContents"];
                if ([liveContents isKindOfClass:[NSArray class]]) {
                    
                    NSInteger count = [liveContents count] / 10;
                    if ([_delegate respondsToSelector:@selector(liveRoomFirstToRequestAd:)]) {
                        [_delegate liveRoomFirstToRequestAd:count];
                    }
                }
            }
            _contentsArrayTemp = [NSMutableArray array];
            [_contentsArrayTemp addObjectsFromArray:self.contentsArray];
            self.contentsArray = [NSMutableArray array];
        } else if ([_type intValue] == 2 && [_commentId intValue] == 0) {
            self.commentsArray = [NSMutableArray array];
        }
    }
    
    //match info
    if ([rootData isKindOfClass:[NSDictionary class]]) {
        
        [self updateMatchInfoWithData:rootData fromPush:NO];
        
        // 分别记录加载更多时新增的直播项数和评论项数
        NSInteger numberOfContentItemsAdded = 0;
        NSInteger numberOfCommentItemsAdded = 0;
        
        long long lastContentId = 0;
        long long lastCommentId = 0;
        
        if (self.contentsArray.count > 0) {
            SNLiveContentObject *obj = [self.contentsArray objectAtIndex:0];
            lastContentId = [obj.contentId longLongValue];
        }
        if (self.commentsArray.count > 0) {
            SNLiveCommentObject *obj = [self.commentsArray objectAtIndex:0];
            lastCommentId = [obj.commentId longLongValue];
        }
        
        [self findLatestContentId:&lastContentId commentId:&lastCommentId];
        
        // liveContents字段只在type=1时有用，其他情况忽略
        if ([_type intValue] == 1) {
            id liveContents = [rootData objectForKey:@"liveContents"];
            if ([liveContents isKindOfClass:[NSArray class]]) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
                
                long long minContentId = [((SNLiveContentObject *)(self.contentsArray.lastObject)).contentId longLongValue];
                
                for (NSDictionary *dict in liveContents) {
                    if (![dict isKindOfClass:[NSDictionary class]]) {
                        continue;
                    }

                    if ([_rollingType intValue] == 1) {
                        long long contentId = [[dict objectForKey:@"contentId"] longLongValue];
                        if (contentId >= minContentId) {
                            SNDebugLog(@"duplicated contentId %lld is ignored", minContentId);
                            continue;
                        }
                    }
                    
                    SNLiveContentObject *obj = [[SNLiveContentObject alloc] init];
                    [self updateContentObj:obj withData:dict];
                    [tempArray addObject:obj];
                }
                
                if ([_contentId intValue] != 0) {
                    if ([_rollingType intValue] == 1) {
                        // 获取更多
                        if ([tempArray count] > 0) {
                            SNDebugLog(@"append %d objects at end", [tempArray count]);
                            [self.contentsArray addObjectsFromArray:tempArray];
                            _hasNoMore = NO;
                            numberOfContentItemsAdded = [tempArray count];
                            
                            //lijian 2015.04.04 加载更多
                            if(numberOfContentItemsAdded > 0){
                                long long maxContentId = [((SNLiveContentObject *)(tempArray.firstObject)).contentId longLongValue];
                                if(_delegate && [_delegate respondsToSelector:@selector(liveRoomloadMore:firstContentID:)]){
                                    [_delegate liveRoomloadMore:numberOfContentItemsAdded firstContentID:maxContentId];
                                }
                            }
                            
                        } else {
                            _hasNoMore = YES;
                            numberOfContentItemsAdded = 0;
                        }
                    } else if ([_rollingType intValue] == 0) {
                        // 增量更新
                        if ([tempArray count] > 0) {
                           SNDebugLog(@"insert %d objects at begining", [tempArray count]);
                            NSMutableArray *arr = [NSMutableArray arrayWithArray:tempArray];
                            [arr addObjectsFromArray:_contentsArray];
                            self.contentsArray = arr;
                        }
                    }
                    
                } else {
                    
                    //lijian 2015.05.09
                    NSArray *sleveArray = [self sleveContentArray:_contentsArrayTemp newArray:tempArray];
                    if([sleveArray count] > 0){
                        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sleveArray.count)];
                        [_contentsArrayTemp insertObjects:sleveArray atIndexes:set];
                        
                    }
                    self.contentsArray = _contentsArrayTemp;

                    // 重新获取
                    //self.contentsArray = tempArray;
                    numberOfContentItemsAdded = [tempArray count];
                    SNDebugLog(@"%d objects refreshed", numberOfContentItemsAdded);
                }
                
            } //liveContents
        }
        
        
        //mergers
        id liveMergers = [rootData objectForKey:@"mergers"];
        if ([liveMergers isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
            
            long long minContentId, minCommentId;
            [self findMinContentId:&minContentId commentId:&minCommentId];
            
            for (NSDictionary *dict in liveMergers) {
                if (![dict isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                NSString *mergeType = [dict stringValueForKey:@"mergeType" defaultValue:@"1"];
                
                if ([mergeType isEqualToString:@"1"]) { //直播
                    // 简单排重
                    if ([_rollingType intValue] == 0) {
                        if ([[dict objectForKey:@"contentId"] longLongValue] <= lastContentId) {
                            continue;
                        }
                    } else if ([_rollingType intValue] == 1) {
                        if ([[dict objectForKey:@"contentId"] longLongValue] >= minContentId) {
                            continue;
                        }
                    }
                    
                    SNLiveContentObject *obj = [[SNLiveContentObject alloc] init];
                    [self updateContentObj:obj withData:dict];
                    [tempArray addObject:obj];
                }
                else if ([mergeType isEqualToString:@"2"]) { //评论
                    // 简单排重
                    if ([_rollingType intValue] == 0) {
                        if ([[dict objectForKey:@"commentId"] longLongValue] <= lastCommentId) {
                            continue;
                        }
                    } else if ([_rollingType intValue] == 1) {
                        if ([[dict objectForKey:@"commentId"] longLongValue] >= minCommentId) {
                            continue;
                        }
                    }
                    
                    SNLiveCommentObject *obj = [[SNLiveCommentObject alloc] init];
                    [self updateCommentObj:obj withData:dict];
                    [tempArray addObject:obj];
                }
            }

            if ([_rollingType intValue] == 1) {
                // 获取更多
                if ([tempArray count] > 0) {
                    SNDebugLog(@"append %d comments at end", [tempArray count]);
                    [self.mergedArray addObjectsFromArray:tempArray];
                    numberOfCommentItemsAdded = tempArray.count;
                } else {
                    numberOfCommentItemsAdded = 0;
                }
            } else if ([_rollingType intValue] == 0) {
                // 重新获取
                SNDebugLog(@"%d mergers refreshed", [tempArray count]);
                self.mergedArray = tempArray;
            }
        } //mergers
        
        
        if ([_type intValue] == 0) {
            _bottomCursor = [self.matchInfo.cursor intValue];
        }

        if ([_rollingType intValue] == 1) {
            if ([_type intValue] == 0) {
                //self.hasNoMore = (numberOfContentItemsAdded + numberOfCommentItemsAdded < PAGE_COUNT);
                _hasNoMore = (_bottomCursor <= 0);
            } else if ([_type intValue] == 1) {
                _hasNoMore = (numberOfContentItemsAdded < PAGE_COUNT);
            } else if ([_type intValue] == 2) {
                _hasNoMore = (numberOfCommentItemsAdded < PAGE_COUNT);
            }
        } else {
            if ([_type intValue] == 0) {
                _hasNoMore = (self.mergedArray.count < PAGE_COUNT);
            } else if ([_type intValue] == 1) {
                _hasNoMore = (self.contentsArray.count < PAGE_COUNT);
            } else if ([_type intValue] == 2) {
                _hasNoMore = (self.commentsArray.count < PAGE_COUNT);
            }
        }
    } //root
}

- (NSArray *)sleveContentArray:(NSArray *)srcArray newArray:(NSArray *)newArray
{
    NSMutableArray *array = [NSMutableArray array];
    
    long long maxContentId = [((SNLiveContentObject *)(srcArray.firstObject)).contentId longLongValue];
    
    for (id obj in newArray) {
        if ([obj isKindOfClass:[SNLiveContentObject class]]) {
            if ([((SNLiveContentObject*)obj).contentId longLongValue] > maxContentId){
                [array addObject:obj];
            }
        }
    }
    
    return array;
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    if ([_delegate respondsToSelector:@selector(liveRoomDidFailLoadWithError:)]) {
        [_delegate liveRoomDidFailLoadWithError:error];
    }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    if ([_delegate respondsToSelector:@selector(liveRoomDidCancelLoad)]) {
        [_delegate liveRoomDidCancelLoad];
    }
}

#pragma mark - asi http
- (void)requestStarted:(ASIHTTPRequest *)request {
    SNDebugLog(@"%@ url=%@", NSStringFromSelector(_cmd), request.url);
    [_receivedData setLength:0];
    
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    SNDebugLog(@"url=%@ %@", request.url, responseHeaders);
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    SNDebugLog(@"url=%@,%@", request.url, NSStringFromSelector(_cmd));
    if ([_networkQueue requestsCount] == 1) {
         //(_networkQueue);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    SNDebugLog(@"url=%@, %@, %@", request.url, NSStringFromSelector(_cmd), request.error);
    [_receivedData setLength:0];
    if ([_networkQueue requestsCount] == 1) {
         //(_networkQueue);
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    
    id rootObject = nil;
    NSError* err = nil;
    if ([data isKindOfClass:[NSData class]]) {
        
        //static int tag = 0;
        //SNDebugLog(@"----------------------\n");
        //SNDebugLog(@"%d data: %@", tag++, [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        
        [_receivedData appendData:data];
        
        NSString *str = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
        BOOL isFullJsonData = [str hasSuffix:@"\n"];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        //SNDebugLog(@"trimed: %@", str);
        NSArray *lines = [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (lines.count > 0) {
            NSInteger nFullJsonLines = isFullJsonData ? lines.count : lines.count - 1;
            NSInteger receiveCount = 0;
            for (int i=0; i < nFullJsonLines; ++i) {
                @try {
                    NSString *jsonStr = [lines objectAtIndex:i];
                    // 收到nothing表示频道已删除，不再有新信息
                    //SNDebugLog(@"json: %@", jsonStr);
                    rootObject = [jsonStr yajl_JSON];
                    
                    if (!rootObject) {
                        continue;
                    }

                    // 第一条是最新的，只取最新的
                    if (i == 0 && [_type intValue] == 0) {
                        [self updateMatchInfoWithData:rootObject fromPush:YES];
                    }

                    // 直播内容
                    if ([_type intValue] == 1) {
                        id liveContents = [rootObject objectForKey:@"liveContents"];
                        if ([liveContents isKindOfClass:[NSArray class]]) {
                            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
                            
                            for (NSDictionary *dict in liveContents) {
                                SNLiveContentObject *obj = [[SNLiveContentObject alloc] init];
                                [self updateContentObj:obj withData:dict];
                                [tempArray addObject:obj];
                            }

                            receiveCount += [tempArray count];
                            NSEnumerator *reverseObjectEnumerator = [tempArray reverseObjectEnumerator];
                            [_receivedContentItems addObjectsFromArray:[reverseObjectEnumerator allObjects]];
                        }
                    }
                    
                    // 直播评论
                    if ([_type intValue] == 0) {
                        id liveMergers = [rootObject objectForKey:@"mergers"];
                        if ([liveMergers isKindOfClass:[NSArray class]]) {
                            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
                            
                            for (NSDictionary *dict in liveMergers) {
                                NSString *mergeType = [dict stringValueForKey:@"mergeType" defaultValue:@"1"];
                                if ([mergeType isEqualToString:@"1"]) { //直播
                                    SNLiveContentObject *obj = [[SNLiveContentObject alloc] init];
                                    [self updateContentObj:obj withData:dict];
                                    [tempArray addObject:obj];
                                }
                                else if ([mergeType isEqualToString:@"2"]) { //评论
                                    SNLiveCommentObject *obj = [[SNLiveCommentObject alloc] init];
                                    [self updateCommentObj:obj withData:dict];
                                    [tempArray addObject:obj];
                                }
                            }

                            receiveCount += [tempArray count];
                            NSEnumerator *reverseObjectEnumerator = [tempArray reverseObjectEnumerator];
                            [_receivedMergeItems addObjectsFromArray:[reverseObjectEnumerator allObjects]];
                        }
                    }
                }
                @catch (NSException* exception) {
                    err = [NSError errorWithDomain:kTTExtJSONErrorDomain
                                              code:kTTExtJSONErrorCodeInvalidJSON
                                          userInfo:[exception userInfo]];
                    SNDebugLog(@"err = %@", err);
                }
            }
            
            [_receivedData setLength:0];
            
            if (!isFullJsonData) {
                NSString *lastLine = [lines lastObject];
                NSData *d = [lastLine dataUsingEncoding:NSUTF8StringEncoding];
                [_receivedData appendData:d];
            }
        }
        
    }
}

#pragma mark -

- (NSString *)getModelNotificationNameForReceivedData {
    NSString *name = [NSString stringWithFormat:@"%@_%@_%d", kLiveContentModelReceivedData, _liveId, [_type intValue]];
    SNDebugLog(@"noti: %@", name);
    return name;
}

- (NSString *)getModelNotificationNameForModelInfoChanged {
    NSString *name = [NSString stringWithFormat:@"%@_%@", kLiveContentModelInfoChanged, _liveId];
    return name;
}

- (NSString *)getModelNotificationNameForRefreshModelInfo {
    NSString *name = [NSString stringWithFormat:@"%@_%@", kLiveRefreshModelInfo, _liveId];
    return name;
}

- (BOOL)isSubServerConnected {
    return [_asiRequest isExecuting];
}

#pragma mark - drag refresh time

- (NSDate *)refreshedTime {
    
	NSDate *time = nil;
    
    NSString *timeKey = [NSString stringWithFormat:@"%@_%d_refresh_time", _liveId, [_type intValue]];
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
	if (data && [data isKindOfClass:[NSDate class]]) {
		time = data;
	}
    
	return time;
}

- (void)setRefreshedTime {
	NSString *timeKey = [NSString stringWithFormat:@"%@_%d_refresh_time", _liveId, [_type intValue]];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:timeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - data parse
// 参数fromPush的意义是为了区别是否从push接口回来的topInfo，其与data.go返回的topInfo不一致
- (void)updateMatchInfoWithData:(NSDictionary *)rootData fromPush:(BOOL)fromPush {
    self.matchInfo.homeTeamScore = [NSString stringWithFormat:@"%d", [[rootData objectForKey:@"hostTotal"] intValue]];
    self.matchInfo.homeTeamSupportNum = [NSString stringWithFormat:@"%d", [[rootData objectForKey:@"hostSupport"] intValue]];
    self.matchInfo.visitingTeamScore = [NSString stringWithFormat:@"%d", [[rootData objectForKey:@"vistorTotal"] intValue]];
    self.matchInfo.visitingTeamSupportNum = [NSString stringWithFormat:@"%d", [[rootData objectForKey:@"vistorSupport"] intValue]];
    self.matchInfo.onlineCount = [NSString stringWithFormat:@"%d", [[rootData objectForKey:@"oneLineCount"] intValue]];
    self.matchInfo.liveStatus = [NSString stringWithFormat:@"%d", [[rootData objectForKey:@"liveStatus"] intValue]];
    self.matchInfo.liveStatistics = [rootData objectForKey:@"statistics" defalutObj:@""];
    self.matchInfo.interval = [NSString stringWithFormat:@"%d", [[rootData objectForKey:@"interval" defalutObj:@"15"] intValue]];
    self.matchInfo.subServer = [rootData objectForKey:@"subServer" defalutObj:SNLinks_DEFALUT_SUB_SERVER];
    self.subServer = self.matchInfo.subServer;
    SNDebugLog(@"data.go matchInfo onlineCount = %@ from push %d", self.matchInfo.onlineCount, fromPush);
    NSDictionary *topObj = [rootData objectForKey:@"topInfo" ofClass:[NSDictionary class] defaultObj:nil];
    //NSDictionary *topObj = @{@"top":@"测试top", @"topLink":@"live://3456"};
    if (topObj /*&& !fromPush*/) {
        self.matchInfo.top = [[SNLiveRoomTopObject alloc] init];
        self.matchInfo.top.top = [[topObj stringValueForKey:@"top" defaultValue:nil] trim];
        self.matchInfo.top.topImage = [topObj stringValueForKey:@"topImage" defaultValue:nil];
        self.matchInfo.top.topLink = [topObj stringValueForKey:@"topLink" defaultValue:nil];
    } else {
        self.matchInfo.top = nil;
    }
    self.matchInfo.cursor = [rootData stringValueForKey:@"cursor" defaultValue:@"0"];

    NSString *ts = [rootData stringValueForKey:@"ts" defaultValue:nil];

    if (ts && [ts longLongValue] > [self.matchInfo.ts longLongValue]) {
        if (self.matchInfo.ts != nil) {
            // data.go与push返回的mediaInfo等信息不可靠，发送通知，在viewController里重新请求info.go获取mediaInfo数据
            [SNNotificationManager postNotificationName:[self getModelNotificationNameForRefreshModelInfo] object:nil];
        }
        self.matchInfo.ts = ts;
        
        // 直播数据
//        NSDictionary *mediaInfo = [rootData objectForKey:@"mediaInfo" ofClass:[NSDictionary class] defaultObj:nil];
//        if (mediaInfo.count > 0) {
//            if (self.matchInfo.mediaObj == nil) {
//                self.matchInfo.mediaObj = [[[SNLiveRoomMediaObject alloc] init] autorelease];
//            }
//            [self.matchInfo.mediaObj updateWithDict:mediaInfo];
//        } else {
//            self.matchInfo.mediaObj = nil;
//            //self.matchInfo.mediaType = LiveMediaText;
//        }
//        
//        self.matchInfo.needLogin = [rootData intValueForKey:@"needLogin" defaultValue:0];
//        self.matchInfo.comtStatus = [rootData intValueForKey:@"comtStatus" defaultValue:0];
//        self.matchInfo.comtHint = [rootData stringValueForKey:@"comtHint" defaultValue:nil];
    }
    
    [SNNotificationManager postNotificationName:[self getModelNotificationNameForModelInfoChanged] object:nil];
}


- (void)updateContentObj:(SNLiveContentObject *)obj withData:(NSDictionary *)dict {
    NSString *author = [[dict stringValueForKey:@"author" defaultValue:nil] trim];
    obj.author = author.length ? author : @"直播员";
    NSString *action = [[dict stringValueForKey:@"action" defaultValue:nil] trim];
    obj.action = [action gtm_stringByUnescapingFromHTML];
    obj.action = [obj.action stringByRemovingHTMLTags];
    obj.actionTeam = [dict objectForKey:@"actionTeam"];
    obj.actionTime = [dict objectForKey:@"actionTime"];
    obj.hostScore =  [dict objectForKey:@"hostScore"];
    obj.visitorScore = [dict objectForKey:@"visitorScore"];
    obj.contentId = [dict objectForKey:@"contentId"];
    obj.contentPic = [dict objectForKey:@"contentPic"];
    //obj.contentPicSmall = [dict objectForKey:@"contentPicSmall"];

    id authorInfo   = [dict objectForKey:@"authorInfo"];
    if (authorInfo && [authorInfo isKindOfClass:[NSDictionary class]]) {
        obj.authorInfo = [[SNLiveRoomAuthorInfo alloc] initWithDict:authorInfo];
    }
    
    obj.link = [dict stringValueForKey:@"link" defaultValue:nil];
    
    id temp = [dict objectForKey:@"mediaInfo"];
    if ([temp isKindOfClass:[NSDictionary class]]) {
        SNLiveRoomMediaObject *media = [[SNLiveRoomMediaObject alloc] init];
        [media updateWithDict:temp];
        obj.mediaInfo = media;
    }
    
    temp = [dict objectForKey:@"replyComment"];
    if ([temp isKindOfClass:[NSDictionary class]]) {
        SNLiveCommentObject *reply = [[SNLiveCommentObject alloc] init];
        reply.commentId = [temp stringValueForKey:@"commentId" defaultValue:nil];
        reply.rid = [temp objectForKey:@"rid"];
        NSString *author = [[temp stringValueForKey:@"author" defaultValue:nil] trim];
        reply.author = author.length ? author : kDefaultUserName;
        reply.createTime = [temp objectForKey:@"createTime"];
        NSString *content = [[temp stringValueForKey:@"content" defaultValue:nil] trim];
        reply.content = [content gtm_stringByUnescapingFromHTML];
        reply.imageUrl = [temp stringValueForKey:@"imageBig" defaultValue:nil];
        reply.audUrl = [temp stringValueForKey:@"audUrl" defaultValue:nil];
        reply.audLen = [temp objectForKey:@"audLen"];
        obj.replyComment = reply;
        
        id authorInfo   = [temp objectForKey:@"authorInfo"];
        if (authorInfo && [authorInfo isKindOfClass:[NSDictionary class]]) {
            obj.replyComment.authorInfo = [[SNLiveRoomAuthorInfo alloc] initWithDict:authorInfo];
        }
    }
    
    id replyCont = [dict objectForKey:@"replyCont"];
    if ([replyCont isKindOfClass:[NSDictionary class]]) {
        SNLiveContentObject *replyObj = [[SNLiveContentObject alloc] init];
        [self updateContentObj:replyObj withData:replyCont];
        obj.replyContent = replyObj;
    }
}

- (void)updateCommentObj:(SNLiveCommentObject *)obj withData:(NSDictionary *)dict {
    NSString *author = [[dict stringValueForKey:@"author" defaultValue:nil] trim];
    obj.author      = author.length ? author : kDefaultUserName;
    obj.commentId   = [dict stringValueForKey:@"commentId" defaultValue:nil];
    NSString *content = [[dict stringValueForKey:@"content" defaultValue:nil] trim];
    obj.content     = [content gtm_stringByUnescapingFromHTML];
    obj.imageUrl    = [dict stringValueForKey:@"imageBig" defaultValue:nil];
    obj.rid         = [dict objectForKey:@"rid"];
    obj.createTime  = [dict objectForKey:@"createTime"];
    obj.audUrl      = [dict stringValueForKey:@"audUrl" defaultValue:nil];
    obj.audLen      = [dict objectForKey:@"audLen"];
    
    id authorInfo   = [dict objectForKey:@"authorInfo"];
    if (authorInfo && [authorInfo isKindOfClass:[NSDictionary class]]) {
        obj.authorInfo = [[SNLiveRoomAuthorInfo alloc] initWithDict:authorInfo];
    }
    
    id floors = [dict objectForKey:@"floors"];
    if ([floors isKindOfClass:[NSArray class]]) {
        //优化：只取floors里最后一条
        if ([(NSArray *)floors count] > 0) {
            SNLiveCommentObject *replyObj = [[SNLiveCommentObject alloc] init];
            NSDictionary *reply = [floors lastObject];
            NSString *author = [[reply stringValueForKey:@"author" defaultValue:nil] trim];
            replyObj.author = author.length ? author : kDefaultUserName;
            replyObj.commentId = [reply stringValueForKey:@"commentId" defaultValue:nil];
            replyObj.imageUrl = [reply stringValueForKey:@"imageBig" defaultValue:nil];
            
            NSString *content = [reply objectForKey:@"content"];
            content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            replyObj.content = [content gtm_stringByUnescapingFromHTML];
            replyObj.createTime = [reply objectForKey:@"createTime"];
            replyObj.audUrl      = [reply stringValueForKey:@"audUrl" defaultValue:nil];
            replyObj.audLen      = [reply objectForKey:@"audLen"];
            
            //obj.authorToReply = replyObj.author;
            obj.replyComment = replyObj;

            id authorInfo   = [reply objectForKey:@"authorInfo"];
            if (authorInfo && [authorInfo isKindOfClass:[NSDictionary class]]) {
                replyObj.authorInfo = [[SNLiveRoomAuthorInfo alloc] initWithDict:authorInfo];
            }
        }
    }
    
    id replyCont = [dict objectForKey:@"replyCont"];
    if ([replyCont isKindOfClass:[NSDictionary class]]) {
        SNLiveContentObject *replyObj = [[SNLiveContentObject alloc] init];
        [self updateContentObj:replyObj withData:replyCont];
        obj.replyContent = replyObj;
    }
    
}

- (void)printDataCountInfo {
    if ([_type intValue] == 0) {
        SNDebugLog(@"dataCountInfo (type: %d total:%d remain:%d)", [_type intValue], self.mergedArray.count, _receivedMergeItems.count);
    } else if ([_type intValue] == 1) {
        SNDebugLog(@"dataCountInfo (type: %d total:%d remain:%d)", [_type intValue], self.contentsArray.count, _receivedContentItems.count);
    }
}

- (SNLiveContentObject *)extractLastReceivedItem {
    long long lastContentId = 0;
    long long lastCommentId = 0;

    if ([_type intValue] == 1) {
        if (_receivedContentItems.count == 0) {
            return nil;
        }
            
        if (self.contentsArray.count > 0) {
            SNLiveContentObject *obj = [self.contentsArray objectAtIndex:0];
            lastContentId = [obj.contentId longLongValue];
        }

        // 直播内容 _receivedContentItems -> self.contentsArray

        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:_receivedContentItems.count];

        SNLiveContentObject *lastItem = nil;

        
        for (SNLiveContentObject *obj in _receivedContentItems) {

            // 简单排重
            if ([obj.contentId longLongValue] <= lastContentId) {
                [tempArray addObject:obj];
                continue;
            }

            //[tempArray addObject:obj];
            lastItem = obj;
            [tempArray addObject:obj];
            break;
        }

        [_receivedContentItems removeObjectsInArray:tempArray];

        SNDebugLog(@"extract (type: %d total:%d remain:%d)", [_type intValue], self.contentsArray.count, _receivedContentItems.count);
        
        return lastItem;

    } else if ([_type intValue] == 0) {
        if (_receivedMergeItems.count == 0) {
            return nil;
        }
        
        [self findLatestContentId:&lastContentId commentId:&lastCommentId];

        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:_receivedMergeItems.count];

        SNLiveContentObject *lastItem = nil;

        for (id obj in _receivedMergeItems) {
            if([obj isKindOfClass:[SNLiveRollAdContentObject class]]){
            
            }
            // 简单排重
            else if ([obj isKindOfClass:[SNLiveContentObject class]]) {
                if ([((SNLiveContentObject *)obj).contentId longLongValue] <= lastContentId) {
                    [tempArray addObject:obj];
                    continue;
                }

            } else if ([obj isKindOfClass:[SNLiveCommentObject class]]) {
                if ([((SNLiveCommentObject *)obj).commentId longLongValue] <= lastCommentId) {
                    [tempArray addObject:obj];
                    continue;
                }
            }

            lastItem = obj;
            [tempArray addObject:obj];
            break;
        }

        [_receivedMergeItems removeObjectsInArray:tempArray];

        SNDebugLog(@"extract (type: %d total:%d remain:%d)", [_type intValue], self.mergedArray.count, _receivedMergeItems.count);
        
        return lastItem;
    }
    return nil;
}

- (BOOL)hasReceivedNewLiveItem {
    if (_receivedContentItems.count == 0 && _receivedMergeItems.count == 0) {
        return NO;
    }
    
    long long lastContentId = 0;
    long long lastCommentId = 0;

    if ([_type intValue] == 1) {
        if (self.contentsArray.count > 0) {
            SNLiveContentObject *obj = [self.contentsArray objectAtIndex:0];
            lastContentId = [obj.contentId longLongValue];
        }
        
        for (SNLiveContentObject *obj in _receivedContentItems) {
            
            // 简单排重
            if ([obj.contentId longLongValue] <= lastContentId) {
                continue;
            }
            
            return YES;
        }
    }
    
    else if ([_type intValue] == 0) {
        [self findLatestContentId:&lastContentId commentId:&lastCommentId];
        
        for (id obj in _receivedMergeItems) {
            
            // 简单排重
            if ([obj isKindOfClass:[SNLiveContentObject class]]) {
                if ([((SNLiveContentObject *)obj).contentId longLongValue] <= lastContentId) {
                    continue;
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)mergeReceivedItemsWithModelArray {
    
    if (_receivedContentItems.count == 0 && _receivedMergeItems.count == 0) {
        return;
    }
    
    long long lastContentId = 0;
    long long lastCommentId = 0;
    
    if ([_type intValue] == 1) {
        if (self.contentsArray.count > 0) {
            SNLiveContentObject *obj = [self.contentsArray objectAtIndex:0];
            lastContentId = [obj.contentId longLongValue];
        }
        
        // 直播内容 _receivedContentItems -> self.contentsArray
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:_receivedContentItems.count];
        
        for (SNLiveContentObject *obj in _receivedContentItems) {
            
            // 简单排重
            if ([obj.contentId longLongValue] <= lastContentId) {
                continue;
            }
            
            [tempArray addObject:obj];
        }
        
        if (tempArray.count > 0) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:tempArray];
            [arr addObjectsFromArray:_contentsArray];
            if (arr.count > 50) {
                [arr removeObjectsInRange:NSMakeRange(50, arr.count-50)];
            }
            self.contentsArray = arr;
            
            [tempArray removeAllObjects];
        }
    }
    else if ([_type intValue] == 0) {
        [self findLatestContentId:&lastContentId commentId:&lastCommentId];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:_receivedMergeItems.count];
        
        for (id obj in _receivedMergeItems) {
            
            // 简单排重
            if ([obj isKindOfClass:[SNLiveContentObject class]]) {
                if ([((SNLiveContentObject *)obj).contentId longLongValue] <= lastContentId) {
                    continue;
                }
                [tempArray addObject:obj];
            } else if ([obj isKindOfClass:[SNLiveCommentObject class]]) {
                if ([((SNLiveCommentObject *)obj).commentId longLongValue] <= lastCommentId) {
                    continue;
                }
                [tempArray addObject:obj];
            }
        }
        
        if (tempArray.count > 0) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:tempArray];
            [arr addObjectsFromArray:_mergedArray];
            if (arr.count > 50) {
                [arr removeObjectsInRange:NSMakeRange(50, arr.count-50)];
            }
            self.mergedArray = arr;
            
            [tempArray removeAllObjects];
        }
    }
        
    // 清空
    [_receivedContentItems removeAllObjects];
    [_receivedMergeItems removeAllObjects];
}

- (NSMutableArray *)getObjectsArray {
    if ([_type intValue] == 1) {
        return self.contentsArray;
    } else if ([_type intValue] == 2) {
        return self.commentsArray;
    } else if ([_type intValue] == 0) {
        return self.mergedArray;
    }
    return self.contentsArray;
}

- (NSInteger)getReceivedItemsCount {
    if ([_type intValue] == 1) {
        return _receivedContentItems.count;
    } else if ([_type intValue] == 0) {
        return _receivedMergeItems.count;
    }
    return 0;
}

- (SNLiveContentMatchInfoObject *)matchInfo {
    if (!_matchInfo) {
        _matchInfo      = [[SNLiveContentMatchInfoObject alloc] init];
    }
    return _matchInfo;
}

- (void)findLatestContentId:(long long *)contentId commentId:(long long *)commentId {
    if (self.mergedArray.count > 0) {
        BOOL findContentId = FALSE, findCommentId = FALSE;
        
        for (id obj in self.mergedArray) {
            if ([obj isKindOfClass:[SNLiveContentObject class]]) {
                if (!findContentId) {
                    *contentId = [((SNLiveContentObject*)obj).contentId longLongValue];
                    findContentId = YES;
                }
            } else if ([obj isKindOfClass:[SNLiveCommentObject class]]) {
                if (!findCommentId) {
                    *commentId = [((SNLiveCommentObject *)obj).commentId longLongValue];
                    findCommentId = YES;
                }
            }
            
            if (findContentId && findCommentId) {
                break;
            }
        }
    }
}

- (void)findMinContentId:(long long *)contentId commentId:(long long *)commentId {
    if (self.mergedArray.count > 0) {
        BOOL findContentId = FALSE, findCommentId = FALSE;
        
        for (id obj in [[self.mergedArray reverseObjectEnumerator] allObjects]) {
            if ([obj isKindOfClass:[SNLiveContentObject class]]) {
                if (!findContentId) {
                    *contentId = [((SNLiveContentObject*)obj).contentId longLongValue];
                    findContentId = YES;
                }
            } else if ([obj isKindOfClass:[SNLiveCommentObject class]]) {
                if (!findCommentId) {
                    *commentId = [((SNLiveCommentObject *)obj).commentId longLongValue];
                    findCommentId = YES;
                }
            }
            
            if (findContentId && findCommentId) {
                break;
            }
        }
    }
}

@end
