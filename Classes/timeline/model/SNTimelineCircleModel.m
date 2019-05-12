//
//  SNTimelineModel.m
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineCircleModel.h"
#import "SNTLComViewBuilder.h"
#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNDBManager.h"
#import "SNUserManager.h"

@interface SNTimelineCircleModel () {
    SNURLRequest *_request;
}

- (void)_cancelAndCleanRequest;

// 查看自己或者某个人的 动态 （用户中心动态）
//- (void)timelineRefreshForOneUser;
//- (void)timelineGetMoreForOneUser;

// 数据解析
- (void)parseResult:(NSDictionary *)resultDic;
- (void)parseActsInfo:(NSArray *)actsInfoArray;

@end

@implementation SNTimelineCircleModel
@synthesize timelineObjects = _timelineObjects;
@synthesize hasMore = _hasMore;
@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize pid = _pid;
@synthesize isLogged = _isLogged;
@synthesize isForOneUser = _isForOneUser;
@synthesize nextCursor, preCursor;
@synthesize lastErrorMsg = _lastErrorMsg;
@synthesize lastErrorCode = _lastErrorCode;
@synthesize isLoadingMore = _isLoadingMore;
@synthesize lastRefreshDate = _lastRefreshDate;
@synthesize allNum = _allNum;

+ (SNTimelineCircleModel *)modelForCurrentUser {
    SNTimelineCircleModel *aModel = [SNTimelineCircleModel new];
    aModel.pid = [SNUserManager getPid];
    aModel.isLogged = aModel.pid.length > 0;
    aModel.isForOneUser = NO;
    [aModel loadCache];
    return [aModel autorelease];
}

//+ (SNTimelineCircleModel *)modelForUserWithPid:(NSString *)pid {
//    SNTimelineCircleModel *aModel = [SNTimelineCircleModel new];
//    aModel.pid = pid;
//    aModel.isForOneUser = YES;
//    [aModel loadCache];
//    return [aModel autorelease];
//}

- (id)init {
    self = [super init];
    if (self) {
        self.timelineObjects = [NSMutableArray array];
    }
    return self;
}

- (void)loadCache {
    [self.timelineObjects removeAllObjects];
    
    SNTimelineGetDataType type = 0;
    
    if (self.isForOneUser) {
        type = SNTimelineGetDataTypeUserActs;
    }
    else if (self.isLogged) {
        type = SNTimelineGetDataTypeTimeline;
    }
    else {
        type = SNTimelineGetDataTypeTimeline;
    }
    
    if (type != SNTimelineGetDataTypeUserActs) {
        NSArray *array = [[SNDBManager currentDataBase] getTimelineObjsByGetType:type pid:self.pid];
        if (array) {
            [self.timelineObjects addObjectsFromArray:array];
            self.hasMore = array.count > 0; // 本地缓存有 认为可以加载更多
        }
    }
}

- (void)timelineRefresh {
    _requestUrl = [NSString stringWithFormat:@"%@followingActV2/1?", kCircleTimelineServer];
    //sns.k.sohu.com/share/followingActV2/1?token=8888&version=1.0&p1=awoeiru4351&gid=123412&pid=5702676713062797336/
    _requestUrl = [SNUtility addParamsToURLForReadingCircle:_requestUrl];

    [self timelineSendRefresh];
}

- (void)timelineSendRefresh {
    if (self.loading) {
        return;
    }
    self.isLoadingMore = NO;
    [self _cancelAndCleanRequest];
    
    self.request = [SNURLRequest requestWithURL:_requestUrl delegate:self];
    self.request.timeOut = 30;
    self.request.cachePolicy = TTURLRequestCachePolicyNoCache;
    self.request.response = [[[SNURLJSONResponse alloc] init] autorelease];
    
    [self.request send];
}

- (void)timelineGetMore {
    // 只加载某人自己的动态
    _requestUrl = [NSString stringWithFormat:@"%@followingActV2/1?nextCursor=%d&fpid=%@", kTimelineServer, self.nextCursor, self.pid];
    _requestUrl = [SNUtility addParamsToURLForReadingCircle:_requestUrl];
    
    [self timelineSendGetMore];
}

- (void)timelineSendGetMore {
    if (self.loading) {
        return;
    }
    
    self.isLoadingMore = YES;
    [self _cancelAndCleanRequest];
    
    self.request = [SNURLRequest requestWithURL:_requestUrl delegate:self];
    self.request.timeOut = 30;
    self.request.cachePolicy = TTURLRequestCachePolicyNoCache;
    self.request.response = [[[SNURLJSONResponse alloc] init] autorelease];
    
    [self.request send];
}

- (void)cancelAndClean {
    self.delegate = nil;
    [self _cancelAndCleanRequest];
}

- (void)dealloc {
    
    [self cancelAndClean];
    
    TT_RELEASE_SAFELY(_allNum);
    TT_RELEASE_SAFELY(_timelineObjects);
    TT_RELEASE_SAFELY(_request);
    TT_RELEASE_SAFELY(_pid);
    TT_RELEASE_SAFELY(_lastErrorMsg);
    TT_RELEASE_SAFELY(_lastRefreshDate);
    
    [super dealloc];
}

- (void)_cancelAndCleanRequest {
    if (self.request) {
        [_request.delegates removeObject:self];
        [_request cancel];
        self.request = nil;
    }
    self.lastErrorMsg = @"";
    self.lastErrorCode = 0;
}

#pragma mark - parse result
- (void)parseResult:(NSDictionary *)resultDic {
    if (resultDic && [resultDic isKindOfClass:[NSDictionary class]]) {
        self.lastErrorCode = [resultDic intValueForKey:@"code" defaultValue:0];
        self.lastErrorMsg = [resultDic stringValueForKey:@"msg" defaultValue:@""];
    }
}

- (void)parseActsInfo:(NSArray *)actsInfoArray {
    if (actsInfoArray && [actsInfoArray isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *actsArray = [NSMutableArray array];
        
        for (NSDictionary *actInfo in actsInfoArray) {
            if ([actInfo isKindOfClass:[NSDictionary class]]) {
                SNTimelineTrendItem *timelineTrendObj = [SNTimelineTrendItem timelineTrendFromDic:actInfo];
                if (timelineTrendObj) {
                    [actsArray addObject:timelineTrendObj];
                }
            }
        }
        
        if (self.isLoadingMore) {
            [self.timelineObjects addObjectsFromArray:actsArray];
        }
        else {
            [self.timelineObjects removeAllObjects];
            [self.timelineObjects addObjectsFromArray:actsArray];
        }
    }
}

#pragma mark - TTURLRequestDelegate
- (void)requestDidStartLoad:(TTURLRequest*)request {
    if (_delegate && [_delegate respondsToSelector:@selector(timelineModelDidStartLoad)]) {
        [_delegate performSelectorOnMainThread:@selector(timelineModelDidStartLoad)
                                    withObject:nil
                                 waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    if (request == self.request) {
        SNURLJSONResponse *rtJson = self.request.response;
        NSDictionary *jsonDic = rtJson.rootObject;
        
//        //阅读圈详情页会多封装一层value，这是个why
//        if ([jsonDic dictionaryValueForKey:@"value" defalutValue:nil]) {
//            jsonDic = [jsonDic dictionaryValueForKey:@"value" defalutValue:nil];
//        }
        
        SNDebugLog(@"%@--%@:time line json obj %@",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd),
                   jsonDic);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL bResultSuccess = NO;
            if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultObj = [jsonDic dictionaryValueForKey:@"result" defalutValue:nil];
                [self parseResult:resultObj];
                
                if (self.lastErrorCode == 200) {
                    self.nextCursor = [jsonDic intValueForKey:@"nextCursor" defaultValue:0];
                    self.preCursor = [jsonDic intValueForKey:@"preCursor" defaultValue:0];
                    
                    self.allNum = [jsonDic stringValueForKey:@"allNum" defaultValue:nil];
                    
                    NSString *arrayKey = nil;
                    NSArray *actsInfoArray = nil;
                    SNTimelineGetDataType type = 0;

                    arrayKey = @"acts";
                    type = SNTimelineGetDataTypeUserActs;
                    actsInfoArray = [jsonDic arrayValueForKey:arrayKey defaultValue:nil];
                    self.lastRefreshDate = [NSDate date];
                    
                    if (actsInfoArray) {
                        [self parseActsInfo:actsInfoArray];
                    }
                    
                    // 服务器返回数据数量小于三 或者两个游标 相等  认为没有更多
                    self.hasMore = ((self.nextCursor != self.preCursor) && (actsInfoArray.count > 3));
                    
                    if(self.timelineObjects.count > 0) {
                        bResultSuccess = YES;
                    }
                }
            }
            
            if (bResultSuccess) {
                if (_delegate && [_delegate respondsToSelector:@selector(timelineModelDidFinishLoad)]) {
                    [_delegate performSelectorOnMainThread:@selector(timelineModelDidFinishLoad)
                                                withObject:nil
                                             waitUntilDone:[NSThread isMainThread]];
                }
            }
            else {
                if (_delegate && [_delegate respondsToSelector:@selector(timelineModelDidFailToLoadWithError:)]) {
                    if (self.timelineObjects.count == 0) {
                        self.lastErrorCode = kSNCircleErrorCodeNoData;
                    }
                    NSError *error = [NSError errorWithDomain:self.lastErrorMsg code:self.lastErrorCode userInfo:nil];
                    [_delegate performSelectorOnMainThread:@selector(timelineModelDidFailToLoadWithError:)
                                                withObject:error
                                             waitUntilDone:[NSThread isMainThread]];
                }
            }
        });
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    self.lastErrorCode = error.code;
    self.lastErrorMsg = error.domain;
    if (_delegate && [_delegate respondsToSelector:@selector(timelineModelDidFailToLoadWithError:)]) {
        [_delegate performSelectorOnMainThread:@selector(timelineModelDidFailToLoadWithError:)
                                    withObject:error
                                 waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    NSError *error = [NSError errorWithDomain:@"user canceled" code:250 userInfo:nil];
    self.lastErrorCode = error.code;
    self.lastErrorMsg = error.domain;
    if (_delegate && [_delegate respondsToSelector:@selector(timelineModelDidFailToLoadWithError:)]) {
        [_delegate performSelectorOnMainThread:@selector(timelineModelDidFailToLoadWithError:)
                                    withObject:error
                                 waitUntilDone:[NSThread isMainThread]];
    }
}

@end
