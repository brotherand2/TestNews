//
//  SNSubscribeCenterService.m
//  sohunews
//
//  Created by wang yanchen on 12-11-20.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubscribeCenterService.h"
#import "SNURLJSONResponse.h"
#import "SNDBManager.h"
#import "SNStatusBarMessageCenter.h"
#import "NSDictionaryExtend.h"
#import "GTMNSString+HTML.h"
#import "NSObject+YAJL.h"
#import "SNUserManager.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNUnreadClearRequest.h"
#import "SNMySubscribeRequest.h"
#import "SNMoreRecomSubRequest.h"
#import "SNSubcribeChangeRequest.h"
#import "SNUserManager.h"

static NSString *getTTUserInfoWeakRefAndClean(TTUserInfo *userInfo) {
    NSString *refId = nil;
    if (userInfo.weakRef) {
        refId = userInfo.weakRef;
        userInfo.weakRef = nil;
    }
    // v5.2.0 ???
    return refId ? refId : nil;
}

static SNURLRequest *sub_center_configured_request(NSString *url, id _delegate, TTUserInfo *userInfo) {
    SNURLRequest *aRequest = [SNURLRequest requestWithURL:url delegate:_delegate];
    aRequest.timeOut = 30;
    aRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    aRequest.userInfo = userInfo;
    aRequest.response = [[SNURLJSONResponse alloc] init];
    
    return aRequest;
}

#define SUBCENTER_CONFIG_RETAINED_REQUEST(url, delegate, userInfo) (sub_center_configured_request((url), (delegate), (userInfo)))

// 全局的单实例
static SNSubscribeCenterService *__sharedInstance;

@interface SNSubscribeCenterService () {
    SNURLRequest *_refreshMySubRequest; // 刷新我的订阅的请求
    SNURLRequest *_moreRecomSubRequest; //加载更多推荐订阅
    SNURLRequest *_synchMySubOrderRequest; // 同步我的订阅顺序请求
    SNURLRequest *_refreshSubTypesRequest; // 刷新更多订阅 分类列表的请求
    SNURLRequest *_refreshSubHomeDataRequest; // 刷新更多订阅 精品排行、刊物分类、adlist的请求
    SNURLRequest *_refreshSubRankListRequest; // 刷新刊物排行的请求
    SNURLRequest *_pageRefreshHomeDataRequest; // 刷新更多订阅精品排行更多数据的请求  不带刊物分类和adlist
    SNURLRequest *_postSubCommentRequest; // 添加刊物评论的请求 可以手动cancel
    SNURLRequest *_refreshSubTypeItemsRequest; // 单个刷新某个分类下刊物的请求
    SNURLRequest *_refreshSubDetailRequest; // 单个刷新某个分类下刊物的请求
    SNURLRequest *_refreshSubDetailCommentRequest; // 单个刷新某个刊物评论请求
    SNURLRequest *_refreshSubRecommendRequest; // 刷新推荐刊物的请求 - 只保留一个
    
    NSMutableDictionary *_addMySubRequests; // 添加我的订阅的请求集合 通过subId区分
    NSMutableDictionary *_removeMySubRequests; // 删除我的订阅的请求集合 通过sudId区分
    NSMutableDictionary *_addOrRemoveMySubsRequests; // 批量删除、添加我的订阅的请求集合  通过url &yes=....&no=...区分 
    NSMutableDictionary *_syncMyPushRequests; // 同步单个订阅推送设置的请求集合  通过subId区别
    NSMutableDictionary *_syncMyPushArrayRequests; // 批量同步多个订阅推送设置的请求集合  通过url &yes=...&no=...区分
    NSMutableDictionary *_subInfoRequests; // 获取刊物info的请求合集 通过subId区别
    
    NSString *_newCount;
    
    NSMutableDictionary *_listenerArrayDic; // 分类观察者字典 根据不同的操作类型  有对应的array容器  存储对应的观察者
    NSMutableArray *_operationQueue;
    NSOperationQueue *_dataCacheMainQueue;
}

@property(nonatomic, strong) NSMutableDictionary *addMySubRequests;
@property(nonatomic, strong) NSMutableDictionary *removeMySubRequests;
@property(nonatomic, strong) NSMutableDictionary *addOrRemoveMySubsRequests;
@property(nonatomic, strong) NSMutableDictionary *syncMyPushRequests;
@property(nonatomic, strong) NSMutableDictionary *syncMyPushArrayRequests;
@property(nonatomic, strong) NSMutableDictionary *listenerArrayDic;
@property(nonatomic, strong) NSMutableDictionary *subInfoRequests;
@property(nonatomic, strong) NSMutableArray *operationQueue;
@property(nonatomic, strong) NSOperationQueue *dataCacheMainQueue;

@property (nonatomic, strong) NSMutableArray * myFollowingArray;

- (void)saveDataToDB:(TTURLRequest *)request;

// 解析单个接口返回数据
- (SCSubscribeObject *)parseOneSubObjFromJsonObj:(NSDictionary *)jsonObj;
- (SCSubscribeTypeObject *)parseOneTypeObjFromJsonObj:(NSDictionary *)jsonObj;
- (SCSubscribeAdObject *)parseOneAdObjFromJsonObj:(NSDictionary *)jsonObj;
- (SCSubscribeCommentObject *)parseOneSubCommentFromJsonObj:(NSDictionary *)jsonObj;

// 解析具体的接口数据
- (void)parseMySubRequest:(TTURLRequest *)request;
- (void)parseAddMoreRecomSubRequest:(TTURLRequest *)request;
- (void)parseSynchMySubOrderRequest:(TTURLRequest *)request;
- (void)parseSubTypesRequest:(TTURLRequest *)request;
- (void)parseSubItmesRequest:(TTURLRequest *)request;
- (void)parseSubMoreItemsRequest:(TTURLRequest *)request;
- (void)parseSubHomeDataRequest:(TTURLRequest *)request;
- (void)parseSubHomeMoreDataRequest:(TTURLRequest *)request;
- (void)parseSubRankListRequest:(TTURLRequest *)request;
- (void)parseSubMoreRankListRequest:(TTURLRequest *)request;
- (void)parseAddMySubRequest:(TTURLRequest *)request;
- (void)parseRemoveMySubRequest:(TTURLRequest *)request;
- (void)parseAddOrRemoveMySubRequest:(TTURLRequest *)request;
- (void)parseSyncMyPushRequest:(TTURLRequest *)request;
- (void)parseSyncMyPushArrayRequest:(TTURLRequest *)request;
- (void)parsePostSubCommentRequest:(TTURLRequest *)request;
- (void)parseSubDetailRequest:(TTURLRequest *)request;
- (void)parseSubInfoRequest:(TTURLRequest *)request;
- (void)parseSubCommentRequest:(TTURLRequest *)request;
- (void)parseSubRecommendRequest:(TTURLRequest *)request;
- (void)parseAddMySubsAndPushSynchRequest:(TTURLRequest *)request;
- (void)parseSubQRInfo:(TTURLRequest *)request;

// 统一的回调入口
- (void)callBackToDelegateWithCallbackDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet status:(SNSubscribeCenterServiceStatus)status;
- (void)callBackBackgroundListenerWithRefId:(NSString *)refId operationType:(SCServiceOperationType)type status:(SNSubscribeCenterServiceStatus)status;

@end

@implementation SNSubscribeCenterService
@synthesize addMySubRequests = _addMySubRequests;
@synthesize removeMySubRequests = _removeMySubRequests;
@synthesize addOrRemoveMySubsRequests = _addOrRemoveMySubsRequests;
@synthesize syncMyPushRequests = _syncMyPushRequests;
@synthesize syncMyPushArrayRequests = _syncMyPushArrayRequests;
@synthesize subInfoRequests = _subInfoRequests;
@synthesize listenerArrayDic = _listenerArrayDic;
@synthesize allSubNewCount;
@synthesize operationQueue = _operationQueue;
@synthesize dataCacheMainQueue = _dataCacheMainQueue;

- (id)init {
    self = [super init];
    if (self) {
        self.listenerArrayDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [self cancelAllRequest];
}

#pragma mark - public methods

- (NSString *)allSubNewCount {
    return [_newCount length] > 0 ? [NSString stringWithString:_newCount] : nil;
}

#pragma mark -----------------我的订阅 my subscribe---------------------------------------------------

- (NSArray *)loadMySubFromLocalDB {
    return [[SNDBManager currentDataBase] getSubscribeCenterMySubscribeArray];
}

- (NSArray *)loadSortedMySubFromLocalDB {
    return [[SNDBManager currentDataBase] getSubSortedArrayWithoutExpressOrYouMayLike];
}

- (NSArray *)loadRecomSubFromLocalDB {
    return [[SNDBManager currentDataBase] getRecomSubArray];
}

/**
 获取订阅刊物
 */
- (void)loadMySubFromServer {
    [self loadMySubFromServerWithPage:1];
}

- (void)loadMySubFromServerWithPage:(NSInteger)page {
    if (!_myFollowingArray) {
        self.myFollowingArray = [NSMutableArray array];
    }
    [[[SNMySubscribeRequest alloc] initWithDictionary:@{@"pageNo":[NSString stringWithFormat:@"%zd",page]}] send:^(SNBaseRequest *request, id responseObject) {
//        if (page == 1) {
        [_myFollowingArray removeAllObjects];
//        }
        [self parseMySubRequestWithResponseData:responseObject];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshMySub];
        if (cbDataSet) {
            cbDataSet.lastError = error;
        }
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
    }];
}
/**
 上拉加载更多刊物

 @param pageNo 页数
 */
- (void)loadMoreRecomSubFromServerWithPageNo:(NSInteger)pageNo {
    
    [[[SNMoreRecomSubRequest alloc] initWithDictionary:@{@"pageNo":[NSString stringWithFormat:@"%zd",pageNo]}] send:^(SNBaseRequest *request, id responseObject) {
        
        [self parseAddMoreRecomSubWithResponseData:responseObject];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeMoreRecomSub];
        if (cbDataSet) {
            cbDataSet.lastError = error;
        }
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];

    }];
}

- (SNSubscribeCenterOperation *)synchronizeMySubOrderToServer:(NSArray *)mySubs {
    if (_synchMySubOrderRequest) {
        [_synchMySubOrderRequest cancel];
         //(_synchMySubOrderRequest);
    }
    
    NSArray *orderSubIds = [mySubs valueForKey:@"subId"];
    if (!orderSubIds || ![orderSubIds isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSString *orderStr = [orderSubIds componentsJoinedByString:@","];
    NSString *requestUrlString = [NSString stringWithFormat:kSubCenterSynchMySubOrderUrl, orderStr];
    
    _synchMySubOrderRequest = [SNURLRequest requestWithURL:requestUrlString delegate:self isParamP:YES scookie:YES];
    _synchMySubOrderRequest.timeOut = 30;
    _synchMySubOrderRequest.httpMethod = @"POST";
    _synchMySubOrderRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    _synchMySubOrderRequest.userInfo = [TTUserInfo topic:kTopicMySubOrder strongRef:mySubs weakRef:nil];
    _synchMySubOrderRequest.response = [[SNURLJSONResponse alloc] init];
    
    [_synchMySubOrderRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeSynchronizeMySubOrder request:_synchMySubOrderRequest refId:nil];
}

#pragma mark -----------------刊物分类列表 type list---------------------------------------------------

// 从本地加载刊物分类列表
- (NSArray *)loadSubTypesFromLocalDB {
    return [[SNDBManager currentDataBase] getSubscribeCenterSubTypes];
}

// 从服务器获取最新的刊物分类列表
- (SNSubscribeCenterOperation *)loadSubTypesFromServer {
    if (_refreshSubTypesRequest) {
        [_refreshSubTypesRequest cancel];
         //(_refreshSubTypesRequest);
    }
    
    _refreshSubTypesRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(kSubCenterSubTypesRefreshUrl, self, [TTUserInfo topic:kTopicSubTypesRefresh]);
    [_refreshSubTypesRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRefreshSubTypeList request:_refreshSubTypesRequest refId:nil];
}

#pragma mark -----------------分类下的刊物数据sub list--------------------------------------------------

// 加载本地数据库刊物分类列表下的所有刊物
- (NSArray *)loadSubscribesFromLocalDBWithSubTypeId:(NSString *)typeId {
    NSArray *subItems = [[SNDBManager currentDataBase] getSubscribeCenterSubItemsBySubTypeId:typeId];
    return subItems;
}

// 从服务器获取最新的刊物分类下的所有刊物 -- 第一次获取第一页的20条
- (SNSubscribeCenterOperation *)loadSubscribesFromServerWithSubTypeId:(NSString *)typeId {
    if ([typeId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate typeId", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return nil;
    }
    
    if (_refreshSubTypeItemsRequest) {
        [_refreshSubTypeItemsRequest cancel];
         //(_refreshSubTypeItemsRequest);
    }
    
    
    
    NSString *baseUrl = [NSString stringWithFormat:kSubCenterAllSubItemsForTypeUrl, typeId];
    baseUrl = [baseUrl stringByAppendingString:@"&pageNo=1"];
    
    _refreshSubTypeItemsRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:kTopicSubItemsFortypeRefresh strongRef:typeId weakRef:typeId]);
    
    [_refreshSubTypeItemsRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRefreshSubTypeSubItems request:_refreshSubTypeItemsRequest refId:typeId];
}

// 从服务器获取更多刊物下的刊物 每次获取20条
- (SNSubscribeCenterOperation *)loadSubscribesFromServerWithSubTypeId:(NSString *)typeId pageNum:(NSInteger)pageNum {
    if (pageNum > 1 && [typeId length] > 0) {
        if (_refreshSubTypeItemsRequest) {
            [_refreshSubTypeItemsRequest cancel];
        }
        
        NSString *baseUrl = [NSString stringWithFormat:kSubCenterAllSubItemsForTypeUrl, typeId];
        NSMutableString *requestUrl = [NSMutableString stringWithString:baseUrl];
        [requestUrl appendFormat:@"&pageNo=%ld", pageNum];
        
        _refreshSubTypeItemsRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(requestUrl, self, [TTUserInfo topic:kTopicSubMoreItemsFortypeRefresh strongRef:typeId weakRef:typeId]);
        
        [_refreshSubTypeItemsRequest send];
        
        return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRefreshSubTypeMoreSubItems request:_refreshSubTypeItemsRequest refId:typeId];
    }
    
    return nil;
}

- (void)unreadClearSubId:(NSString *)subId
{
    [[[SNUnreadClearRequest alloc] initWithDictionary:@{@"subId":subId}] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger status = [(NSString *)[responseObject objectForKey:@"statusCode"] integerValue];
        if (status == 10000000) {
            [SNNotificationManager postNotificationName:kUnreadClearNotification object:self];
        }
        else {
            NSString *msg = [responseObject objectForKey:@"statusMsg"];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
}

#pragma mark ------------------订阅、退订 subscribe/change.go-------------------------------------------

/**
 订阅某个刊物

 @param subObj SCSubscribeObject
 */
- (void)addMySubToServerBySubObject:(SCSubscribeObject *)subObj {
    
    [self addMySubToServerBySubId:subObj.subId from:subObj.from];
}

- (void)addMySubToServerBySubId:(NSString *)subId from:(int)from {
    if (subId.length == 0) return;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:subId forKey:@"yes"];
    if (from > 0) {
        [params setValue:[NSString stringWithFormat:@"%zd",from] forKey:@"refer"];
    }
    
    if([SNUserManager isLogin]){
        SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
        if (userInfoEx.passport && userInfoEx.passport.length>0) {
            [params setValue:[NSString stringWithFormat:@"%@",userInfoEx.passport] forKey:@"passport"];
        }
    }
    
    [[[SNSubcribeChangeRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        
        [self parseAddMySubWithResponseObject:responseObject andSubId:subId];
        NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:subId,@"subId", [NSNumber numberWithBool:YES], @"subStatus", nil];
        [SNNotificationManager postNotificationName:kRefreshStockDetailButtonNotification object:nil userInfo:userDic];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubToServer strongDataRef:subId weakDataRef:nil];
        if (cbDataSet) {
            cbDataSet.lastError = error;
        }
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
    }];
}
/**
 退订某个刊物

 @param subObj SCSubscribeObject
 */
- (void)removeMySubToServerBySubObject:(SCSubscribeObject *)subObj {
    [self removeMySubToServerBySubId:subObj.subId from:subObj.from];
}

- (void)removeMySubToServerBySubId:(NSString *)subId from:(int)from {
    if (subId.length == 0) return;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:subId forKey:@"no"];
    if (from > 0) {
        [params setValue:[NSString stringWithFormat:@"%zd",from] forKey:@"refer"];
    }
    [[[SNSubcribeChangeRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        
        [self parseRemoveMySubWithResponseObject:responseObject andSubId:subId];
        NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:subId,@"subId", [NSNumber numberWithBool:NO], @"subStatus", nil];
        [SNNotificationManager postNotificationName:kRefreshStockDetailButtonNotification object:nil userInfo:userDic];
        
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRemoveMySubToServer strongDataRef:subId weakDataRef:nil];
        if (cbDataSet) {
            cbDataSet.lastError = error;
        }
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
    }];
}
// 批量订阅、退订某些刊物
- (SNSubscribeCenterOperation *)addAndRemoveMySubsToServerWithAddObjs:(NSArray *)addObjs removeObjs:(NSArray *)removeObjs {
    if ([addObjs count] + [removeObjs count] <= 0) {
        SNDebugLog(@"%@--%@ invalidate addObjs %@ or removeObjs %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), addObjs, removeObjs);
        return nil;
    }
    int from = 0;
    
    NSMutableDictionary *objForUserInfo = [NSMutableDictionary dictionary];
    
    NSMutableString *statementAddUrlStr = [NSMutableString stringWithString:@""];
    if ([addObjs count] > 0) {
        [statementAddUrlStr appendString:@"&yes="];
        
        for (int i = 0; i < [addObjs count]; ++i) {
            SCSubscribeObject *subObj = [addObjs objectAtIndex:i];
            if (subObj.subId.length > 0) {
                [statementAddUrlStr appendString:subObj.subId];
            }
            if (i < addObjs.count - 1) {
                [statementAddUrlStr appendString:@","];
            }

            if (from == 0 && subObj.from > 0) {
                from = subObj.from;
            }
        }
    }
    if ([statementAddUrlStr length] > 0) {
        [objForUserInfo setObject:statementAddUrlStr forKey:@"yes"];
    }
    
    NSMutableString *statementRemoveUrlStr = [NSMutableString stringWithString:@""];
    if ([removeObjs count] > 0) {
        [statementRemoveUrlStr appendString:@"&no="];
        
        for (int i = 0; i < removeObjs.count; ++i) {
            SCSubscribeObject *subObj = [removeObjs objectAtIndex:i];
            [statementRemoveUrlStr appendString:subObj.subId];
            
            if (i < removeObjs.count - 1) {
                [statementRemoveUrlStr appendString:@","];
            }
            
            if (from == 0 && subObj.from > 0) {
                from = subObj.from;
            }
        }
    }
    if ([statementRemoveUrlStr length] > 0) {
        [objForUserInfo setObject:statementRemoveUrlStr forKey:@"no"];
    }
    
    NSString *statementUrlStr = [NSString stringWithFormat:@"%@%@", statementAddUrlStr, statementRemoveUrlStr];
    
    SNDebugLog(@"%@--%@ statementUrlStr = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), statementUrlStr);
    
    [objForUserInfo setObject:statementUrlStr forKey:@"all"];
    
    if (_addOrRemoveMySubsRequests) {
        SNURLRequest *oldRequest = [_addOrRemoveMySubsRequests objectForKey:statementUrlStr];
        if (oldRequest && [oldRequest isLoading]) {
            SNDebugLog(@"%@--%@ there is already a request running for statement %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), statementUrlStr);
            return nil;
        }
        
        [_addOrRemoveMySubsRequests removeObjectForKey:statementUrlStr];
    }
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@%@", SNLinks_Path_Subcribe_Change, statementUrlStr];
    if ([addObjs count] == 1) {
        [urlStr appendString:@"&showSub=1"];
    }
    
    if (from > 0) {
        [urlStr appendFormat:@"&refer=%d", from];
    }
    
    SNURLRequest *aNewRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(urlStr, self, [TTUserInfo topic:kTopicAddOrRemoveMySubs strongRef:objForUserInfo weakRef:nil]);
    
    [aNewRequest send];
    
    if (nil == _addOrRemoveMySubsRequests) {
        self.addOrRemoveMySubsRequests = [NSMutableDictionary dictionary];
    }
    
    [_addOrRemoveMySubsRequests setObject:aNewRequest forKey:statementUrlStr];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddOrRemoveMySubsToServer request:aNewRequest refId:nil];
}

#pragma mark ------------------推送 设置 mypush/change.go-----------------------------------------------
// 批量同步多个刊物的推送设置到服务器
- (SNSubscribeCenterOperation *)synchronizeMySubsPushToServerBySubObjects:(NSArray *)subObjs {
    if ([subObjs count] <= 0) {
        SNDebugLog(@"%@--%@ invalidate subObjs %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subObjs);
        return nil;
    }
    NSMutableDictionary *objForUserInfo = [NSMutableDictionary dictionary];
    NSMutableString *addMyPushStatement = [NSMutableString string];
    NSMutableString *removeMyPushStatement = [NSMutableString string];
    
    for (SCSubscribeObject *subObj in subObjs) {
        if ([subObj.isPush isEqualToString:@"1"]) {
            [addMyPushStatement appendFormat:@"%@,", subObj.subId];
        }
        else {
            [removeMyPushStatement appendFormat:@"%@,", subObj.subId];
        }
    }
    
    NSMutableString *statementStr = [NSMutableString string];
    
    if ([addMyPushStatement length] > 0) {
        [addMyPushStatement replaceCharactersInRange:(NSRange){[addMyPushStatement length] - 1, 1} withString:@""];
        [objForUserInfo setObject:addMyPushStatement forKey:@"yes"];
        [statementStr appendFormat:@"&yes=%@", addMyPushStatement];
    }
    
    if ([removeMyPushStatement length] > 0) {
        [removeMyPushStatement replaceCharactersInRange:(NSRange){[removeMyPushStatement length] - 1, 1} withString:@""];
        [objForUserInfo setObject:removeMyPushStatement forKey:@"no"];
        [statementStr appendFormat:@"&no=%@", removeMyPushStatement];
    }
    
    if (_syncMyPushArrayRequests) {
        SNURLRequest *request = [_syncMyPushArrayRequests objectForKey:statementStr];
        if (request && [request isLoading]) {
            SNDebugLog(@"%@--%@ there is already a request running for statement %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), statementStr);
            return nil;
        }
        
        [_syncMyPushArrayRequests removeObjectForKey:statementStr];
    }
    // 摇一摇 调用了kPushChangeUrl 此接口,现在已经没有这个功能,因此先不去修改这儿的网络请求 2017.1.14 liteng
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@", SNLinks_Path_Push_Change, statementStr];
    SNURLRequest *request = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:kTopicSyncMyPushArray strongRef:objForUserInfo weakRef:nil]);
    
    [request send];
    
    if (nil == _syncMyPushArrayRequests) {
        self.syncMyPushArrayRequests = [NSMutableDictionary dictionary];
    }
    
    [_syncMyPushArrayRequests setObject:request forKey:statementStr];
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeSynchronizeMySubsPushArray request:request refId:nil];
}


#pragma mark ------------------订阅 推送 合并接口 mypush/subscribe/change.go-----------------------------

// 批量订阅刊物，并且在关注成功之后批量设置刊物推送开关 -- 分两步来做
- (SNSubscribeCenterOperation *)addMySubsToServer:(NSArray *)mySubs withPushOpen:(BOOL)bOpen {
    if ([mySubs count] == 0) {
        SNDebugLog(@"%@--%@ invalidate subObjs %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), mySubs);
        return nil;
    }
    
    NSMutableDictionary *objForUserInfo = [NSMutableDictionary dictionary];
    
    [objForUserInfo setObject:[NSNumber numberWithBool:bOpen] forKey:@"pushOpen"];
    
    NSString *lastSubId = nil;
    
    NSMutableString *statementAddUrlStr = [NSMutableString stringWithString:@""];
    if ([mySubs count] > 0) {
        [statementAddUrlStr appendString:@"&yes="];
        
        for (int i = 0; i < [mySubs count]; ++i) {
            SCSubscribeObject *subObj = [mySubs objectAtIndex:i];
            [statementAddUrlStr appendString:subObj.subId];
            
            if (i < mySubs.count - 1) {
                [statementAddUrlStr appendString:@","];
            }
            lastSubId = subObj.subId;
        }
    }
    if ([statementAddUrlStr length] > 0) {
        [objForUserInfo setObject:statementAddUrlStr forKey:@"yes"];
    }
        
    NSString *statementUrlStr = [NSString stringWithFormat:@"%@", statementAddUrlStr];
    
    SNDebugLog(@"%@--%@ statementUrlStr = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), statementUrlStr);
    
    if (_addOrRemoveMySubsRequests) {
        SNURLRequest *oldRequest = [_addOrRemoveMySubsRequests objectForKey:statementUrlStr];
        if (oldRequest && [oldRequest isLoading]) {
            SNDebugLog(@"%@--%@ there is already a request running for statement %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), statementUrlStr);
            return nil;
        }
        
        [_addOrRemoveMySubsRequests removeObjectForKey:statementUrlStr];
    }
    
    NSString *pid = @"-1";
    if ([SNUserManager getPid])
        pid = [SNUserManager getPid];
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@&pid=%@", SNLinks_Path_Subcribe_Change, statementUrlStr, pid];
    
    SNURLRequest *aNewRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:kTopicAddMySubsAndPushSynch strongRef:objForUserInfo weakRef:lastSubId]);
    
    [aNewRequest send];
    
    if (nil == _addOrRemoveMySubsRequests) {
        self.addOrRemoveMySubsRequests = [NSMutableDictionary dictionary];
    }
    
    [_addOrRemoveMySubsRequests setObject:aNewRequest forKey:statementUrlStr];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubsAndSynchPush request:nil refId:nil];
}

#pragma mark ----------------精品列表 marrow list-------------------------------------------------------

// 从服务器获取最新的精品列表，包含精品列表的刊物列表和广告推广位
- (SNSubscribeCenterOperation *)loadSubHomeDataFromServer {
    if (_refreshSubHomeDataRequest) {
        [_refreshSubHomeDataRequest cancel];
         //(_refreshSubHomeDataRequest);
    }
    
    _refreshSubHomeDataRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(kSubCenterAllSubHomeDataInitUrl, self, [TTUserInfo topic:kTopicSubHomeDataRefresh]);
    
    [_refreshSubHomeDataRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRefreshSubHomeData request:_refreshSubHomeDataRequest refId:nil];
}


// 从服务器-分页-获取最新的精品列表 - 每页20条数据
- (SNSubscribeCenterOperation *)loadSubHomeMoreDataFromServerWithPageNo:(NSInteger)pageNo {
    if (pageNo <= 1) {
        return nil;
    }
    if (_pageRefreshHomeDataRequest) {
        [_pageRefreshHomeDataRequest cancel];
    }
    
    NSString *baseUrlStr = [NSString stringWithFormat:kSubCenterAllSubMarroUrl, pageNo];
    NSMutableString *requestUrlStr = [NSMutableString stringWithString:baseUrlStr];
    // pageNo 如果大于1 则请求的结果不需要带推广  subType list
    [requestUrlStr appendString:@"&showAd=0&showType=0"];
    
    _pageRefreshHomeDataRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(requestUrlStr, self, [TTUserInfo topic:kTopicRefreshHomeMoreData]);
    
    [_pageRefreshHomeDataRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRefeshHomeMoreData request:_pageRefreshHomeDataRequest refId:nil];
}

#pragma mark -----------------刊物排行列表 rank list-----------------------------------------------------

// 从本地加载排行刊物
- (NSArray *)loadSubRankListFromDB {
    return [[SNDBManager currentDataBase] getSubscribeCenterAllSubscribesOnRankListArray];
}

// 从服务器获取最新的排行刊物
- (SNSubscribeCenterOperation *)loadSubRankListFromServer {
    if (_refreshSubRankListRequest) {
        [_refreshSubRankListRequest cancel];
         //(_refreshSubRankListRequest);
    }
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@&pageNo=1", kSubCenterAllSubRankListUrl];
    
    _refreshSubRankListRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:kTopicRefreshSubRankList]);
    [_refreshSubRankListRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRefreshSubRankList request:_refreshSubRankListRequest refId:nil];
}

// 从服务器获取更多排行的刊物
- (SNSubscribeCenterOperation *)loadSubMoreRankListFromServer:(NSInteger)pageNo {
    if (pageNo > 1) {
        if (_refreshSubRankListRequest) {
            [_refreshSubRankListRequest cancel];
             //(_refreshSubRankListRequest);
        }
        
        NSString *requestUrlstr = [NSString stringWithFormat:@"%@&pageNo=%ld", kSubCenterAllSubRankListUrl, pageNo];
        _refreshSubRankListRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(requestUrlstr, self, [TTUserInfo topic:kTopicRefreshSubMoreRankList]);
        [_refreshSubRankListRequest send];
        
        return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRefreshSubMoreRankList request:_refreshSubRankListRequest refId:nil];
    }
    
    return nil;
}

#pragma mark -----------------添加刊物评论 subComment.go ------------------------------------------------
- (SNSubscribeCenterOperation *)postSubComment:(NSString *)content author:(NSString *)author starGrade:(float)grade subId:(NSString *)subId {
    if ([content length] <= 0 || [author length] <= 0 || [subId length] <= 0 ) {
        SNDebugLog(@"%@-- %@ invalidate arguments content %@\nauthor %@\ngrade %f\nsubId %@",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd),
                   content,
                   author,
                   grade,
                   subId);
        return nil;
    }
    if (_postSubCommentRequest) {
        [_postSubCommentRequest cancel];
         //(_postSubCommentRequest);
        SNDebugLog(@"%@--%@ cancel last request", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    
    NSString *baseUrl = [NSString stringWithFormat:kSubCenterCommentPostUrl, subId, [author URLEncodedString], grade, [content URLEncodedString]];
    _postSubCommentRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:kTopicPostSubComment strongRef:subId weakRef:subId]);
    _postSubCommentRequest.httpMethod = @"POST";
    [_postSubCommentRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypePostSubComment request:_postSubCommentRequest refId:subId];
}


#pragma mark -----------------刊物 信息 评论信息----------------------------------------------------------

// 根据subId获取刊物详细数据 包括刊物信息和评论
- (SNSubscribeCenterOperation *)loadSubDetailFromServerBySubId:(NSString *)subId {
    if ([subId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate subId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId);
        return nil;
    }
    
    if (_refreshSubDetailRequest) {
        [_refreshSubDetailRequest cancel];
    }
    
    NSString *baseUrl = [NSString stringWithFormat:kSubDetailUrl, subId];
    _refreshSubDetailRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:kTopicSubDetail strongRef:subId weakRef:subId]);
    [_refreshSubDetailRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeSubDetail request:_refreshSubDetailRequest refId:subId];
}

// 根据subId获取刊物详细数据  根据topic更新数据库
- (SNSubscribeCenterOperation *)dealSubInfoFromServerBySubId:(NSString *)subId operationTopic:(NSString *)topic{
    if ([subId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate subId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId);
        return nil;
    }
    
    if (_subInfoRequests) {
        SNURLRequest *request = [_subInfoRequests objectForKey:subId];
        if (request && [request isLoading]) {
            SNDebugLog(@"%@--%@ there is already a request for subId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId);
            return nil;
        }
        
        [_subInfoRequests removeObjectForKey:subId];
        SNDebugLog(@"%@--%@ remove old request for subId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId);
    }
    
    NSString *baseUrl = [NSString stringWithFormat:kSubInfoUrl, subId];
    SNURLRequest *request = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:topic strongRef:subId weakRef:subId]);
    [request send];
    
    if (nil == _subInfoRequests) {
        self.subInfoRequests = [NSMutableDictionary dictionary];
    }
    
    [_subInfoRequests setObject:request forKey:subId];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeSubInfo request:request refId:subId];
}

// 根据subId获取刊物详细数据  不包括评论信息
- (SNSubscribeCenterOperation *)loadSubInfoFromServerBySubId:(NSString *)subId {
    if ([subId length] <= 0) {
        SNDebugLog(@"%@--%@ invalidate subId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId);
        return nil;
    }
    
    if (_subInfoRequests) {
        SNURLRequest *request = [_subInfoRequests objectForKey:subId];
        if (request && [request isLoading]) {
            SNDebugLog(@"%@--%@ there is already a request for subId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId);
            return nil;
        }
        
        [_subInfoRequests removeObjectForKey:subId];
        SNDebugLog(@"%@--%@ remove old request for subId %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId);
    }
    
    NSString *baseUrl = [NSString stringWithFormat:kSubInfoUrl, subId];
    SNURLRequest *request = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:kTopicSubInfo strongRef:subId weakRef:subId]);
    [request send];
    
    if (nil == _subInfoRequests) {
        self.subInfoRequests = [NSMutableDictionary dictionary];
    }
    
    [_subInfoRequests setObject:request forKey:subId];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeSubInfo request:request refId:subId];
}

// 根据subId获取刊物评论列表 默认每页返回20条数据
- (SNSubscribeCenterOperation *)loadSubCommentListFromServerBySubId:(NSString *)subId pageNo:(int)pageNo {
    if ([subId length] <= 0 || pageNo <= 0) {
        SNDebugLog(@"%@--%@ invalidate subId %@ pageNo %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), subId, pageNo);
        return nil;
    }
    
    if (_refreshSubDetailCommentRequest) {
        [_refreshSubDetailCommentRequest cancel];
         //(_refreshSubDetailCommentRequest);
    }
    
    NSString *requestKey = [NSString stringWithFormat:@"%@&%d", subId, pageNo];
    NSString *baseUrl = [NSString stringWithFormat:kSubCommentListUrl, subId];
    baseUrl = [baseUrl stringByAppendingFormat:@"&pageNo=%d", pageNo];
    
    _refreshSubDetailCommentRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(baseUrl, self, [TTUserInfo topic:kTopicSubComment strongRef:requestKey weakRef:subId]);
    [_refreshSubDetailCommentRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeSubComment request:_refreshSubDetailCommentRequest refId:subId];
}

- (SNSubscribeCenterOperation *)loadSubQRInfoFromServerBySubId:(NSString *)subId {
    if (subId.length == 0) {
        SNDebugLog(@"%@--%@: invalidate argument subId",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSString *requestUrl = [NSString stringWithFormat:kSubQRInfoUrl, subId];
    
    SNURLRequest *request = SUBCENTER_CONFIG_RETAINED_REQUEST(requestUrl, self, [TTUserInfo topic:kTopicSubQRInfo strongRef:subId weakRef:nil]);
    request.timeOut = 10;
    request.cachePolicy = TTURLRequestCachePolicyDefault;
    request.cacheExpirationAge = 60;
    [request send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeSubQRInfo request:nil refId:subId];
}

#pragma mark -----------------刊物信息页 刊物推荐---------------------------------------------------------

// 从服务器获取4条随机刊物推荐数据 通过回调返回
- (SNSubscribeCenterOperation *)loadSubRecommendFromServer {
    if (_refreshSubRecommendRequest) {
        [_refreshSubRecommendRequest cancel];
         //(_refreshSubRecommendRequest);
    }
    
    _refreshSubRecommendRequest = SUBCENTER_CONFIG_RETAINED_REQUEST(kSubRecommendListUrl, self, [TTUserInfo topic:kTopicSubRecommend]);
    [_refreshSubRecommendRequest send];
    
    return [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeSubRecommend request:_refreshSubRecommendRequest refId:nil];
}

#pragma mark -----------------推广位数据 ad list---------------------------------------------------------

- (NSArray *)loadAdListFromLocalDBForType:(SNSubCenterAdListType)type {
    return [[SNDBManager currentDataBase] getSubscribeCenterAdListForType:type];
}

#pragma mark ------------------添加、移除 观察者 回调相关 很重要--------------------------------------------

- (BOOL)addBackgroundOperation:(SNSubscribeCenterOperation *)operation {
    if (nil == operation) {
        SNDebugLog(@"%@--%@ invalidate listener", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    @synchronized(_operationQueue) {
        if (nil == _operationQueue) {
            self.operationQueue = [[NSMutableArray alloc] init];
        }
        [_operationQueue removeObject:operation];
        [_operationQueue addObject:operation];
    }
    return YES;
}

- (BOOL)removeBackgroundOperation:(SNSubscribeCenterOperation *)operation {
    if (nil == operation) {
        SNDebugLog(@"%@--%@ invalidate listener", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    @synchronized(_operationQueue) {
        if (_operationQueue) {
            [_operationQueue removeObject:operation];
        }
    }
    return YES;
}

- (BOOL)addListener:(id)listener {
    if (nil == listener) {
        SNDebugLog(@"%@--%@ invalidate listener", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    int keyIndex = SCServiceOperationTypeStart + 1;
    @synchronized(_listenerArrayDic) {
        while (keyIndex < SCServiceOperationTypeEnd) {
            NSString *keyStr = [NSString stringWithFormat:@"%d", keyIndex];
            NSMutableArray *lsArray = [_listenerArrayDic objectForKey:keyStr];
            if (nil == lsArray) {
                lsArray = [NSMutableArray array];
                [_listenerArrayDic setObject:lsArray forKey:keyStr];
            }
            
            keyIndex++;
        }
    }
    
    return YES;
}
- (BOOL)removeListener:(id)listener {
    if (nil == listener) {
        SNDebugLog(@"%@--%@ invalidate listener", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    @synchronized(_listenerArrayDic) {
        for (id key in _listenerArrayDic) {
            NSMutableArray *lsArray = [_listenerArrayDic objectForKey:key];
            if ([lsArray isKindOfClass:[NSMutableArray class]]) {
                [lsArray removeObject:listener];
            }
        }
    }
    return YES;
}

- (BOOL)addListener:(id)listener forOperation:(SCServiceOperationType)operation {
    if (nil == listener) {
        SNDebugLog(@"%@--%@ invalidate listener", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    if (operation <= SCServiceOperationTypeStart || operation >= SCServiceOperationTypeEnd) {
        SNDebugLog(@"%@--%@ invalidate operation", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    NSString *key = [NSString stringWithFormat:@"%d", operation];
    @synchronized(_listenerArrayDic) {
        NSMutableArray *lsArray = [_listenerArrayDic objectForKey:key];
        if (nil == lsArray) {
            lsArray = [NSMutableArray array];
            [_listenerArrayDic setObject:lsArray forKey:key];
        }
        
        [lsArray removeObject:listener];
        [lsArray addObject:listener];
    }
    return YES;
}
- (BOOL)removeListener:(id)listener forOperation:(SCServiceOperationType)operation {
    if (nil == listener) {
        SNDebugLog(@"%@--%@ invalidate listener", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    if (operation <= SCServiceOperationTypeStart || operation >= SCServiceOperationTypeEnd) {
        SNDebugLog(@"%@--%@ invalidate operation", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    NSString *keyStr = [NSString stringWithFormat:@"%d", operation];
    @synchronized(_listenerArrayDic) {
        NSMutableArray *lsArray = [_listenerArrayDic objectForKey:keyStr];
        if (nil == lsArray) {
            SNDebugLog(@"%@--%@ there is no array for operation %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), operation);
            return NO;
        }
        
        [lsArray removeObject:listener];
    }
    return YES;
}

- (void)cancelAllRequest {
    if (_refreshMySubRequest) {
        [_refreshMySubRequest cancel];
         //(_refreshMySubRequest);
    }
    
    if (_moreRecomSubRequest) {
        [_moreRecomSubRequest cancel];
         //(_moreRecomSubRequest);
    }
    
    if (_synchMySubOrderRequest) {
        [_synchMySubOrderRequest cancel];
         //(_synchMySubOrderRequest);
    }
    
    if (_refreshSubTypesRequest) {
        [_refreshSubTypesRequest cancel];
         //(_refreshSubTypesRequest);
    }
    
    if (_refreshSubHomeDataRequest) {
        [_refreshSubHomeDataRequest cancel];
         //(_refreshSubHomeDataRequest);
    }
    
    if (_refreshSubRankListRequest) {
        [_refreshSubRankListRequest cancel];
         //(_refreshSubRankListRequest);
    }
    
    if (_pageRefreshHomeDataRequest) {
        [_pageRefreshHomeDataRequest cancel];
         //(_pageRefreshHomeDataRequest);
    }
    
    if (_postSubCommentRequest) {
        [_postSubCommentRequest cancel];
         //(_postSubCommentRequest);
    }
    
    if (_refreshSubTypeItemsRequest) {
        [_refreshSubTypeItemsRequest cancel];
    }
    
    if (_refreshSubDetailRequest) {
        [_refreshSubDetailRequest cancel];
    }
    
    if (_refreshSubDetailCommentRequest) {
        [_refreshSubDetailCommentRequest cancel];
    }
    
    if (_refreshSubRecommendRequest) {
        [_refreshSubRecommendRequest cancel];
    }
    
    if (_addMySubRequests) {
        for (id key in _addMySubRequests) {
            SNURLRequest *request = [_addMySubRequests objectForKey:key];
            if ([request isKindOfClass:[SNURLRequest class]]) {
                [request cancel];
            }
        }
        
        [_addMySubRequests removeAllObjects];
    }
    
    if (_removeMySubRequests) {
        for (id key in _removeMySubRequests) {
            SNURLRequest *request = [_removeMySubRequests objectForKey:key];
            if ([request isKindOfClass:[SNURLRequest class]]) {
                [request cancel];
            }
        }
        
        [_removeMySubRequests removeAllObjects];
    }
    
    if (_addOrRemoveMySubsRequests) {
        for (id key in _addOrRemoveMySubsRequests) {
            SNURLRequest *request = [_addOrRemoveMySubsRequests objectForKey:key];
            if ([request isKindOfClass:[SNURLRequest class]]) {
                [request cancel];
            }
        }
        
        [_addOrRemoveMySubsRequests removeAllObjects];
    }
    
    if (_syncMyPushRequests) {
        for (id key in _syncMyPushRequests) {
            SNURLRequest *request = [_syncMyPushRequests objectForKey:key];
            if ([request isKindOfClass:[SNURLRequest class]]) {
                [request cancel];
            }
        }
        
        [_syncMyPushRequests removeAllObjects];
    }
    
    if (_syncMyPushArrayRequests) {
        for (id key in _syncMyPushArrayRequests) {
            SNURLRequest *request = [_syncMyPushArrayRequests objectForKey:key];
            if ([request isKindOfClass:[SNURLRequest class]]) {
                [request cancel];
            }
        }
        
        [_syncMyPushArrayRequests removeAllObjects];
    }
    
    if (_subInfoRequests) {
        for (id key in _subInfoRequests) {
            SNURLRequest *request = [_subInfoRequests objectForKey:key];
            if ([request isKindOfClass:[SNURLRequest class]]) {
                [request cancel];
            }
        }
        [_subInfoRequests removeAllObjects];
    }
}

+ (SNSubscribeCenterService *)defaultService {
    @synchronized(self) {
        if (nil == __sharedInstance) {
            __sharedInstance = [[SNSubscribeCenterService alloc] init];
        }
        return __sharedInstance;
    }
}

#pragma mark - TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    NSInvocationOperation *ivop = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(saveDataToDB:) object:request];
    
    if (nil == _dataCacheMainQueue) {
        self.dataCacheMainQueue = [[NSOperationQueue alloc] init];
        [_dataCacheMainQueue setMaxConcurrentOperationCount:1];
    }
    
    [_dataCacheMainQueue addOperation:ivop];
    
    SNDebugLog(@"add save data operation to queue : current queue size [%d]", _dataCacheMainQueue.operationCount);
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    TTUserInfo *userInfo = request.userInfo;
    
    SNSubscribeCenterCallbackDataSet *cbDataSet = nil;
    if ([kTopicMySubRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshMySub];
    }
    else if ([kTopicMoreRecomSub isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeMoreRecomSub];
    }
    else if ([kTopicMySubOrder isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubOrder];
    }
    else if ([kTopicSubTypesRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeList];
    }
    else if ([kTopicSubItemsFortypeRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeSubItems
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubMoreItemsFortypeRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeMoreSubItems
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubHomeDataRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubHomeData];
    }
    else if ([kTopicRefreshSubRankList isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubRankList];
    }
    else if ([kTopicAddMySub isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubToServer
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicRemoveMySub isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRemoveMySubToServer
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicAddOrRemoveMySubs isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSyncMyPush isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubPush
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSyncMyPushArray isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubsPushArray
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicRefreshHomeMoreData isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefeshHomeMoreData];
    }
    else if ([kTopicRefreshSubMoreRankList isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubMoreRankList];
    }
    else if ([kTopicPostSubComment isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypePostSubComment];
    }
    else if ([kTopicSubDetail isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubDetail
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubInfo isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubInfo
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubComment isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubComment
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubRecommend isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubRecommend];
    }
    else if ([kTopicAddMySubsAndPushSynch isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubsAndSynchPush
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubQRInfo isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubQRInfo
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    
    if (cbDataSet) {
        cbDataSet.lastError = error;
    }
    
    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
    [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    TTUserInfo *userInfo = request.userInfo;
    SNSubscribeCenterCallbackDataSet *cbDataSet = nil;
    
    if ([kTopicMySubRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshMySub];
    }
    else if([kTopicMoreRecomSub isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeMoreRecomSub];
    }
    else if ([kTopicMySubOrder isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubOrder];
    }
    else if ([kTopicSubTypesRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeList];
    }
    else if ([kTopicSubItemsFortypeRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeSubItems
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubMoreItemsFortypeRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeMoreSubItems
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubHomeDataRefresh isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubHomeData];
    }
    else if ([kTopicRefreshSubRankList isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubRankList];
    }
    else if ([kTopicAddMySub isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubToServer
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicRemoveMySub isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRemoveMySubToServer
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicAddOrRemoveMySubs isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSyncMyPush isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubPush
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSyncMyPushArray isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubsPushArray
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicRefreshHomeMoreData isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefeshHomeMoreData];
    }
    else if ([kTopicRefreshSubMoreRankList isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubMoreRankList];
    }
    else if ([kTopicPostSubComment isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypePostSubComment];
    }
    else if ([kTopicSubDetail isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubDetail
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubInfo isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubInfo
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubComment isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubComment
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubRecommend isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubRecommend];
    }
    else if ([kTopicAddMySubsAndPushSynch isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubsAndSynchPush
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    else if ([kTopicSubQRInfo isEqualToString:userInfo.topic]) {
        cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubQRInfo
                                                                     strongDataRef:userInfo.strongRef
                                                                       weakDataRef:nil];
    }
    
    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusCanceld];
    [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusCanceld];
}

#pragma mark - ---------------------------private methods-----------------------------------

- (void)saveDataToDB:(TTURLRequest *)request {
    
    @autoreleasepool {
        TTUserInfo *userInfo = request.userInfo;
        
        //id jsonData = [(SNURLJSONResponse *)request.response rootObject];
        
        //SNDebugLog(@"%@--%@-- jsonData=\n%@ userInfo.topic=%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), jsonData, userInfo.topic);
        
        if ([kTopicMySubRefresh isEqualToString:userInfo.topic]) {
            [self parseMySubRequest:request];
        }
        else if ([kTopicMoreRecomSub isEqualToString:userInfo.topic]) {
            [self parseAddMoreRecomSubRequest:request];
        }
        else if ([kTopicMySubOrder isEqualToString:userInfo.topic]) {
            [self parseSynchMySubOrderRequest:request];
        }
        else if ([kTopicSubTypesRefresh isEqualToString:userInfo.topic]) {
            [self parseSubTypesRequest:request];
        }
        else if ([kTopicSubItemsFortypeRefresh isEqualToString:userInfo.topic]) {
            [self parseSubItmesRequest:request];
        }
        else if ([kTopicSubMoreItemsFortypeRefresh isEqualToString:userInfo.topic]) {
            [self parseSubMoreItemsRequest:request];
        }
        else if ([kTopicSubHomeDataRefresh isEqualToString:userInfo.topic]) {
            [self parseSubHomeDataRequest:request];
        }
        else if ([kTopicRefreshHomeMoreData isEqualToString:userInfo.topic]) {
            [self parseSubHomeMoreDataRequest:request];
        }
        else if ([kTopicRefreshSubRankList isEqualToString:userInfo.topic]) {
            [self parseSubRankListRequest:request];
        }
        else if ([kTopicRefreshSubMoreRankList isEqualToString:userInfo.topic]) {
            [self parseSubMoreRankListRequest:request];
        }
        else if ([kTopicAddMySub isEqualToString:userInfo.topic]) {
            [self parseAddMySubRequest:request];
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:userInfo.strongRef,@"subId", [NSNumber numberWithBool:YES], @"subStatus", nil];
            [SNNotificationManager postNotificationName:kRefreshStockDetailButtonNotification object:nil userInfo:userDic];
        }
        else if ([kTopicRemoveMySub isEqualToString:userInfo.topic]) {
            [self parseRemoveMySubRequest:request];
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:userInfo.strongRef,@"subId", [NSNumber numberWithBool:NO], @"subStatus", nil];
            [SNNotificationManager postNotificationName:kRefreshStockDetailButtonNotification object:nil userInfo:userDic];
        }
        else if ([kTopicAddOrRemoveMySubs isEqualToString:userInfo.topic]) {
            [self parseAddOrRemoveMySubRequest:request];
        }
        else if ([kTopicSyncMyPush isEqualToString:userInfo.topic]) {
            [self parseSyncMyPushRequest:request];
        }
        else if ([kTopicSyncMyPushArray isEqualToString:userInfo.topic]) {
            [self parseSyncMyPushArrayRequest:request];
        }
        else if ([kTopicPostSubComment isEqualToString:userInfo.topic]) {
            [self parsePostSubCommentRequest:request];
        }
        else if ([kTopicSubDetail isEqualToString:userInfo.topic]) {
            [self parseSubDetailRequest:request];
        }
        else if ([kTopicSubInfo isEqualToString:userInfo.topic]) {
            [self parseSubInfoRequest:request];
        }
        else if ([kTopicSubComment isEqualToString:userInfo.topic]) {
            [self parseSubCommentRequest:request];
        }
        else if ([kTopicSubRecommend isEqualToString:userInfo.topic]) {
            [self parseSubRecommendRequest:request];
        }
        else if ([kTopicAddMySubsAndPushSynch isEqualToString:userInfo.topic]) {
            [self parseAddMySubsAndPushSynchRequest:request];
        }
        else if ([kTopicSubQRInfo isEqualToString:userInfo.topic]) {
            [self parseSubQRInfo:request];
        }
        else if ([kTopicAddSubInfo isEqualToString:userInfo.topic]){
            [self parseSubInfoRequest:request Subscribed:YES];
        }
        else if ([kTopicDelSubInfo isEqualToString:userInfo.topic]){
            [self parseSubInfoRequest:request Subscribed:NO];
        }
        
    }
}

- (SCSubscribeObject *)parseOneSubObjFromJsonObj:(NSDictionary *)jsonObj {
    if (!jsonObj || [jsonObj count] <= 0) {
        SNDebugLog(@"ERROR %@-- invalidate jsonObj", NSStringFromSelector(_cmd));
        return nil;
    }
    
    return [SCSubscribeObject subscribeObjFromJsonDic:jsonObj];
}

- (SCSubscribeTypeObject *)parseOneTypeObjFromJsonObj:(NSDictionary *)jsonObj {
    if (nil == jsonObj || [jsonObj count] <= 0) {
        SNDebugLog(@"ERROR %@-- invalidate jsonObj", NSStringFromSelector(_cmd));
        return nil;
    }
    
    SCSubscribeTypeObject *typeObj = [[SCSubscribeTypeObject alloc] init];
    
    typeObj.typeId = [jsonObj stringValueForKey:@"typeId" defaultValue:nil];
    typeObj.typeName = [jsonObj stringValueForKey:@"typeName" defaultValue:nil];
    typeObj.typeIcon = [jsonObj stringValueForKey:@"typeIcon" defaultValue:nil];
    typeObj.subId = [jsonObj stringValueForKey:@"subId" defaultValue:nil];
    typeObj.subName = [jsonObj stringValueForKey:@"subName" defaultValue:nil];
    
    return typeObj;
}

- (SCSubscribeAdObject *)parseOneAdObjFromJsonObj:(NSDictionary *)jsonObj {
    if (nil == jsonObj || [jsonObj count] <= 0) {
        SNDebugLog(@"%@-%@ invalidate jsonObj", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return nil;
    }
    
    SCSubscribeAdObject *adObj = [[SCSubscribeAdObject alloc] init];
    adObj.adName = [jsonObj stringValueForKey:@"adName" defaultValue:nil];
    adObj.adType = [jsonObj stringValueForKey:@"adType" defaultValue:nil];
    adObj.adImage = [jsonObj stringValueForKey:@"adImg" defaultValue:nil];
    adObj.refId = [jsonObj stringValueForKey:@"refId" defaultValue:nil];
    adObj.refText = [jsonObj stringValueForKey:@"refText" defaultValue:nil];
    adObj.refLink = [jsonObj stringValueForKey:@"refLink" defaultValue:nil];
    adObj.adId = [jsonObj stringValueForKey:@"adId" defaultValue:nil];
    
    return adObj;
}

- (SCSubscribeCommentObject *)parseOneSubCommentFromJsonObj:(NSDictionary *)jsonObj {
    if (nil == jsonObj || [jsonObj count] <= 0) {
        SNDebugLog(@"%@-%@ invalidate jsonObj", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return nil;
    }
    
    SCSubscribeCommentObject *cmtObj = [[SCSubscribeCommentObject alloc] init];
    cmtObj.author = [jsonObj stringValueForKey:kSubCommentAuthorKey defaultValue:@""];
    cmtObj.city = [jsonObj stringValueForKey:kSubCommentCityKey defaultValue:@""];
    cmtObj.content = [jsonObj stringValueForKey:kSubCommentContentKey defaultValue:@""];
    cmtObj.starGrade = [jsonObj stringValueForKey:kSubCommentStarGradeKey defaultValue:@""];
    cmtObj.ctime = [jsonObj stringValueForKey:kSubCommentCtimeKey defaultValue:@""];
    
    return cmtObj;
}

- (void)parseAddMoreRecomSubWithResponseData:(id)jsonData {
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        //recomSubList
        id recomSubListObj = [(NSDictionary *)jsonData objectForKey:kRecomSubListKey];
        if (recomSubListObj && [recomSubListObj isKindOfClass:[NSArray class]]) {
            NSArray *recomSubList = recomSubListObj;
            NSMutableArray *recomSublistArr = [NSMutableArray array];
            int sortIndex = 0;
            for (id subObj in recomSubList) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (subscribeObj) {
                        subscribeObj.isSubscribed = @"2";
                        subscribeObj.sortIndex = [NSString stringWithFormat:@"%d", sortIndex];
                        [recomSublistArr addObject:subscribeObj];
                        sortIndex++;
                    }
                }
            }
            //            [[SNDBManager currentDataBase] addSubscribeCenterMoreRecomSubscribes:recomSublistArr];
            SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeMoreRecomSub strongDataRef:recomSublistArr weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
            [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        }
    } else {  // 预防不靠谱的服务器抽风什么也不返回
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeMoreRecomSub];
        cbDataSet.lastError = [NSError errorWithDomain:@"moreRecomSub json data nil" code:SCServiceErrorCodeNil userInfo:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }

}

- (void)parseMySubRequestWithResponseData:(id)jsonData {
    
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        /////////////////////////////////我的订阅增加大开关参数///////////////////////////////////////////////////
        NSString *newsPushSet =  [(NSDictionary *)jsonData stringValueForKey:kNewsPushSet defaultValue:@"-1"];
        NSString *paperPushSet =  [(NSDictionary *)jsonData stringValueForKey:kPaperPushSet defaultValue:@"-1"];
        NSString *timestamp = [(NSDictionary *)jsonData stringValueForKey:@"timestamp" defaultValue:@"0"];
        [[NSUserDefaults standardUserDefaults] setObject:newsPushSet forKey:kNewsPushSet];
        [[NSUserDefaults standardUserDefaults] setObject:paperPushSet forKey:kPaperPushSet];
        NSString *slideSubscribe = [[NSUserDefaults standardUserDefaults] objectForKey:@"slideToSubscribe"];
        if ([slideSubscribe isEqualToString:@"1"]) {
            //            SNDebugLog(@"-------------slideSubscribe1:%@",slideSubscribe);
        } else {
            //            SNDebugLog(@"--------------slideSubscribe2:%@",slideSubscribe);
            [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kSubMySubLastTimestampKey];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"slideToSubscribe"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        //////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // 解析 新刊物提醒
        BOOL shouldShowNewSub = NO;
        int newCount = [(NSDictionary *)jsonData intValueForKey:@"newCount" defaultValue:0];
        NSString *newCountDate = [(NSDictionary *)jsonData stringValueForKey:@"newCountDate" defaultValue:nil];
        
        if (newCount > 0 && newCountDate.length > 0) {
            NSString *lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:kNewSubscribeUpdateTime];
            if (lastUpdateTime.length == 0) {
                shouldShowNewSub = YES;
            }
            else if (![newCountDate isEqualToString:lastUpdateTime]) {
                shouldShowNewSub = YES;
            }
        }
        
        // 提醒
        if (shouldShowNewSub) {
            [[NSUserDefaults standardUserDefaults] setObject:newCountDate forKey:kNewSubscribeUpdateTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[self class] setDisplayedFloatingCell:NO];
            [[self class] setHasNewSubscrbe:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SNNotificationManager postNotificationName:kDidFindNewSubscribeNotification object:nil];
            });
        }
        
        //subList
        id sublistObj = [(NSDictionary *)jsonData objectForKey:kSubListKey];
//        NSMutableArray *mySubNewArray = [NSMutableArray array];
        NSMutableArray *mySublist = [NSMutableArray array];
        if (sublistObj && [sublistObj isKindOfClass:[NSArray class]]) {
            NSArray *sublist = sublistObj;
            int sortIndex = 0;
            for (id subObj in sublist) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (subscribeObj) {
                        subscribeObj.isSubscribed = @"1";
                        subscribeObj.sortIndex = [NSString stringWithFormat:@"%d", sortIndex];
                        [mySublist addObject:subscribeObj];
                        sortIndex++;
                    }
                }
            }
//            if([SNUserManager isLogin]){
//                [_myFollowingArray addObjectsFromArray:mySublist];
//            }else{
                ///未登录 没有分页逻辑 一次全部返回
                [_myFollowingArray removeAllObjects];
                [_myFollowingArray addObjectsFromArray:mySublist];
//            }
            [[SNDBManager currentDataBase] addSubscribeCenterMySubscribes:_myFollowingArray];
//            [mySubNewArray addObjectsFromArray:mySublist];
            [[self class] saveMySubRefreshDate];
            
        }
        
        //recomSubList
//        id recomSubListObj = [(NSDictionary *)jsonData objectForKey:kRecomSubListKey];
//        if (recomSubListObj && [recomSubListObj isKindOfClass:[NSArray class]]) {
//            NSArray *recomSubList = recomSubListObj;
//            NSMutableArray *recomSublistArr = [NSMutableArray array];
//            int sortIndex = 0;
//            for (id subObj in recomSubList) {
//                if ([subObj isKindOfClass:[NSDictionary class]]) {
//                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
//                    if (subscribeObj) {
//                        subscribeObj.isSubscribed = @"2";
//                        subscribeObj.sortIndex = [NSString stringWithFormat:@"%d", sortIndex];
//                        [recomSublistArr addObject:subscribeObj];
//                        sortIndex++;
//                    }
//                }
//            }
//            [[SNDBManager currentDataBase] addSubscribeCenterRecomSubscribes:recomSublistArr];
//            [mySubNewArray addObjectsFromArray:recomSublistArr];
//            [[self class] saveMySubRefreshDate];
//        }
        
        // ad list
        id adListObj = [(NSDictionary *)jsonData objectForKey:kSubAdListKey];
        if (adListObj && [adListObj isKindOfClass:[NSArray class]]) {
            NSMutableArray *adListArray = [NSMutableArray array];
            for (id adObj in adListObj) {
                if ([adObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeAdObject *aNewAdObj = [self parseOneAdObjFromJsonObj:adObj];
                    if (aNewAdObj) {
                        [adListArray addObject:aNewAdObj];
                    }
                }
            }
            
            //广告位加载统计
            [SNStatisticsInfoAdaptor uploadSubPopularizeLoadInfo:adListArray];
            
            // 同步本地数据库
            [[SNDBManager currentDataBase] setSubscribeCenterAdList:adListArray ofType:SNSubCenterAdListTypeMySub];
        }
        
        id newCountObj = [(NSDictionary *)jsonData objectForKey:kNewCountKey];
        if ([newCountObj isKindOfClass:[NSString class]]) {
            _newCount = [[NSString alloc] initWithString:newCountObj];
        }
        
        // 解析广告定向数据
        // 4.2广告 解析缓存广告定向数据
        // 先清除之前的缓存
        [[SNDBManager currentDataBase] adInfoClearAdInfosByType:SNAdInfoTypeMySubBanner];
        
        NSArray *adInfoControls = [(NSDictionary *)jsonData arrayValueForKey:@"adControlInfos" defaultValue:nil];
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
                                                           withType:SNAdInfoTypeMySubBanner
                                                             dataId:kAdInfoDefaultCategoryId
                                                         categoryId:kAdInfoDefaultCategoryId];
        }
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshMySub
                                                                                                       strongDataRef:_myFollowingArray
                                                                                                         weakDataRef:mySublist];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshMySub];
        cbDataSet.lastError = [NSError errorWithDomain:@"mysub json data nil" code:SCServiceErrorCodeNil userInfo:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }

}

- (void)parseSynchMySubOrderRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    NSDictionary *jsonData = json.rootObject;
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        // 同步成功
        if ([[jsonData stringValueForKey:@"code" defaultValue:@""] isEqualToString:@"200"]) {
            // 需要同步一下数据库中的sord order
            TTUserInfo *userInfo = request.userInfo;
            if (userInfo && [userInfo isKindOfClass:[TTUserInfo class]] && [userInfo.strongRef isKindOfClass:[NSArray class]]) {
                NSArray *mySubs = userInfo.strongRef;
                [mySubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[SCSubscribeObject class]]) {
                        [(SCSubscribeObject *)obj setSortIndex:[NSString stringWithFormat:@"%lu", (unsigned long)idx]];
                    }
                }];
                [[SNDBManager currentDataBase] addSubscribeCenterMySubscribes:mySubs];
            }
            SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubOrder];
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
            [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        }
        // 同步失败
        else {
            NSString *errorMsg = [jsonData stringValueForKey:@"message" defaultValue:@""];
            NSInteger errorCode = [jsonData intValueForKey:@"code" defaultValue:0];
            SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubOrder];
            cbDataSet.lastError = [NSError errorWithDomain:errorMsg code:errorCode userInfo:nil];
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
            [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
        }
    }
}

- (void)parseSubTypesRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id typeListObj = [jsonData objectForKey:kTypeListKey];
        if (typeListObj && [typeListObj isKindOfClass:[NSArray class]]) {
            NSArray *typeList = typeListObj;
            NSMutableArray *newTypeListArray = [NSMutableArray array];
            
            for (id typeObj in typeList) {
                if ([typeObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeTypeObject *aTypeObj = [self parseOneTypeObjFromJsonObj:typeObj];
                    if (aTypeObj) {
                        [newTypeListArray addObject:aTypeObj];
                    }
                }
            }
            
            // 强制第一个为”精品推荐“ 第二位插入排行
            if ([newTypeListArray count] > 0) {
                SCSubscribeTypeObject *typeObj = [[SCSubscribeTypeObject alloc] init];
                typeObj.typeId = kSubTypeRankId;
                typeObj.typeName = @"排行";
                [newTypeListArray insertObject:typeObj atIndex:0];
                
                typeObj = [[SCSubscribeTypeObject alloc] init];
                typeObj.typeId = kSubTypeRecomendId;
                typeObj.typeName = @"精品";
                [newTypeListArray insertObject:typeObj atIndex:0];
            }
            
            
            if ([[SNDBManager currentDataBase] setSubscribeCenterSubTypes:newTypeListArray]) {
                // 从数据库从新获取一下最新的数据
                NSArray *subTypesInDB = [[SNDBManager currentDataBase] getSubscribeCenterSubTypes];
                newTypeListArray = [NSMutableArray arrayWithArray:subTypesInDB];
            }
            
            SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet
                                                           callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeList
                                                           strongDataRef:newTypeListArray
                                                           weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
            [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeList];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubItmesRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id sublistObj = [(NSDictionary *)jsonData objectForKey:kSubListKey];
        if (sublistObj && [sublistObj isKindOfClass:[NSArray class]]) {
            NSArray *sublist = sublistObj;
            
            NSMutableArray *mySublist = [NSMutableArray array];
            
            for (id subObj in sublist) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (subscribeObj) {
                        // 同步一下数据库中的订阅item
                        SCSubscribeObject *oldObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subscribeObj.subId];
                        if ([oldObj.isSubscribed isEqualToString:@"1"]) {
                            subscribeObj.isPush = oldObj.isPush;
                        }
                        else {
                            subscribeObj.defaultPush = subscribeObj.isPush;
                        }
                        
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subscribeObj addIfNotExist:YES];
                        if (subscribeObj.subId) {
                            [mySublist addObject:subscribeObj.subId];
                        }
                    }
                }
            }
            
            [[self class] saveSubItemsDateForType:userInfo.strongRef];
            
            [[SNDBManager currentDataBase] setSubscribeTypeRelationSubIds:mySublist forTypeId:userInfo.strongRef];
            
            SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeSubItems
                                                                                                           strongDataRef:userInfo.strongRef
                                                                                                             weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
            [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeSubItems
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
    
//    [_subItemsForTypeRequests removeObjectForKey:userInfo.strongRef];
}

- (void)parseSubMoreItemsRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id sublistObj = [(NSDictionary *)jsonData objectForKey:kSubListKey];
        NSMutableArray *moreSubs = [NSMutableArray array];
        
        if (sublistObj && [sublistObj isKindOfClass:[NSArray class]]) {
            NSArray *sublist = sublistObj;
            
            
            for (id subObj in sublist) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (subscribeObj) {
                        // 同步一下数据库中的订阅item
                        SCSubscribeObject *oldObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subscribeObj.subId];
                        if ([oldObj.isSubscribed isEqualToString:@"1"]) {
                            subscribeObj.isPush = oldObj.isPush;
                            subscribeObj.isSubscribed = @"1";
                        }
                        else {
                            subscribeObj.defaultPush = subscribeObj.isPush;
                            subscribeObj.isSubscribed = @"0";
                        }
                        
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subscribeObj addIfNotExist:YES];
                        [[SNDBManager currentDataBase] addSubscribeATypeRelation:userInfo.strongRef subId:subscribeObj.subId];
                        
                        [moreSubs addObject:subscribeObj];
                    }
                }
            }
            
            SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeMoreSubItems
                                                                                                           strongDataRef:userInfo.strongRef
                                                                                                             weakDataRef:nil];
            cbDataSet.reservedDataRef = moreSubs;
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
            [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubTypeMoreSubItems
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
    
//    [_subItemsForTypeRequests removeObjectForKey:userInfo.strongRef];
}

- (void)parseSubHomeDataRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    
    SNDebugLog(@"refresh sub home data jsonData = %@", jsonData);
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        // type list
        id typeListObj = [(NSDictionary *)jsonData objectForKey:kTypeListKey];
        NSMutableArray *newTypeListArray = [NSMutableArray array];
        
        if (typeListObj && [typeListObj isKindOfClass:[NSArray class]]) {
            NSArray *typeList = typeListObj;
            
            for (id typeObj in typeList) {
                if ([typeObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeTypeObject *aTypeObj = [self parseOneTypeObjFromJsonObj:typeObj];
                    if (aTypeObj) {
                        [newTypeListArray addObject:aTypeObj];
                    }
                }
            }
            
            // 强制第一个为”精品推荐“ 第二位插入排行
            if ([newTypeListArray count] > 0) {
                SCSubscribeTypeObject *typeObj = [[SCSubscribeTypeObject alloc] init];
                typeObj.typeId = kSubTypeRankId;
                typeObj.typeName = @"排行";
                [newTypeListArray insertObject:typeObj atIndex:0];
                
                typeObj = [[SCSubscribeTypeObject alloc] init];
                typeObj.typeId = kSubTypeRecomendId;
                typeObj.typeName = @"精品";
                [newTypeListArray insertObject:typeObj atIndex:0];
            }
            
            
            if ([[SNDBManager currentDataBase] setSubscribeCenterSubTypes:newTypeListArray]) {
                // 从数据库从新获取一下最新的数据
                NSArray *subTypesInDB = [[SNDBManager currentDataBase] getSubscribeCenterSubTypes];
                newTypeListArray = [NSMutableArray arrayWithArray:subTypesInDB];
            }
        }
        
        // sub list
        id subListObj = [(NSDictionary *)jsonData objectForKey:kSubListKey];
        if (subListObj && [subListObj isKindOfClass:[NSArray class]]) {
            NSArray *sublist = subListObj;
            
            NSMutableArray *mySublist = [NSMutableArray array];
            
            for (id subObj in sublist) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (subscribeObj) {
                        // 同步一下数据库中的订阅item
                        SCSubscribeObject *oldObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subscribeObj.subId];
                        if ([oldObj.isSubscribed isEqualToString:@"1"]) {
                            subscribeObj.isPush = oldObj.isPush;
                        }
                        else {
                            subscribeObj.defaultPush = subscribeObj.isPush;
                        }
                        
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subscribeObj addIfNotExist:YES];
                        [mySublist addObject:subscribeObj.subId];
                    }
                }
            }
            
            [[SNDBManager currentDataBase] setSubscribeTypeRelationSubIds:mySublist forTypeId:kSubTypeRecomendId];
            // 精品推荐的跟第一个分类不是一个事 -- 这里不需要更新关系表
        }
        
        [[self class] saveSubItemsDateForType:kSubTypeRecomendId];
        
        // ad list
        id adListObj = [(NSDictionary *)jsonData objectForKey:kSubAdListKey];
        if (adListObj && [adListObj isKindOfClass:[NSArray class]]) {
            NSMutableArray *adListArray = [NSMutableArray array];
            
            for (id adObj in adListObj) {
                if ([adObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeAdObject *aNewAdObj = [self parseOneAdObjFromJsonObj:adObj];
                    if (aNewAdObj) {
                        [adListArray addObject:aNewAdObj];
                    }
                }
            }
            //添加订阅推广位加载统计
//            [SNStatisticsInfoAdaptor uploadSubPopularizeLoadInfo:adListArray];
            // 同步本地数据库
            [[SNDBManager currentDataBase] setSubscribeCenterAdList:adListArray ofType:SNSubCenterAdListTypeSubCenter];
        }
        
        // 4.0广告 解析缓存广告定向数据
        // 先清除之前的缓存
        [[SNDBManager currentDataBase] adInfoClearAdInfosByType:SNAdInfoTypeSubCenterTopBanner];
        
        NSArray *adInfoControls = [(NSDictionary *)jsonData arrayValueForKey:@"adControlInfos" defaultValue:nil];
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
                                                           withType:SNAdInfoTypeSubCenterTopBanner
                                                             dataId:kAdInfoDefaultCategoryId
                                                         categoryId:kAdInfoDefaultCategoryId];
        }
        
        // save time
        [[self class] saveHomeDataRefreshDate];
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubHomeData
                                                                                                       strongDataRef:newTypeListArray
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubHomeData
                                                                                                       strongDataRef:nil
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubHomeMoreDataRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    
    NSString *typeId = kSubTypeRecomendId;
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        // sub list
        NSMutableArray *mySublist = [NSMutableArray array];
        
        id subListObj = [(NSDictionary *)jsonData objectForKey:kSubListKey];
        if (subListObj && [subListObj isKindOfClass:[NSArray class]]) {
            NSArray *sublist = subListObj;
            
            for (id subObj in sublist) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (subscribeObj) {
                        // 同步一下数据库中的订阅item
                        SCSubscribeObject *oldObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subscribeObj.subId];
                        if ([oldObj.isSubscribed isEqualToString:@"1"]) {
                            subscribeObj.isPush = oldObj.isPush;
                        }
                        else {
                            subscribeObj.defaultPush = subscribeObj.isPush;
                        }
                        
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subscribeObj addIfNotExist:YES];
                        [[SNDBManager currentDataBase] addSubscribeATypeRelation:typeId subId:subscribeObj.subId];
                        [mySublist addObject:subscribeObj];
                    }
                }
            }
        }
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefeshHomeMoreData
                                                                                                       strongDataRef:mySublist
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefeshHomeMoreData
                                                                                                       strongDataRef:nil
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubRankListRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id sublistObj = [(NSDictionary *)jsonData objectForKey:kSubListKey];
        if (sublistObj && [sublistObj isKindOfClass:[NSArray class]]) {
            NSArray *sublist = sublistObj;
            NSMutableArray *subIdsArray = [NSMutableArray array];
            for (id subObj in sublist) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (subscribeObj) {
                        SCSubscribeObject *oldObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subscribeObj.subId];
                        if ([oldObj.isSubscribed isEqualToString:@"1"]) {
                            subscribeObj.isPush = oldObj.isPush;
                        }
                        else {
                            subscribeObj.defaultPush = subscribeObj.isPush;
                        }
                        if (subscribeObj.subId) {
                            [subIdsArray addObject:subscribeObj.subId];
                        }
                        subscribeObj.isOnRank = @"1";
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subscribeObj addIfNotExist:YES];
                    }
                }
            }
            
            
            [[SNDBManager currentDataBase] setSubscribeTypeRelationSubIds:subIdsArray forTypeId:kSubTypeRankId];
        }
        
        [[self class] saveSubItemsDateForType:kSubTypeRankId];
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubRankList];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubRankList];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubMoreRankListRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *moreRank = [NSMutableArray array];
        id sublistObj = [(NSDictionary *)jsonData objectForKey:kSubListKey];
        if (sublistObj && [sublistObj isKindOfClass:[NSArray class]]) {
            NSArray *sublist = sublistObj;
            
            for (id subObj in sublist) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subscribeObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (subscribeObj) {
                        
                        SCSubscribeObject *oldObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subscribeObj.subId];
                        if ([oldObj.isSubscribed isEqualToString:@"1"]) {
                            subscribeObj.isPush = oldObj.isPush;
                            subscribeObj.isSubscribed = @"1";
                        }
                        else {
                            subscribeObj.defaultPush = subscribeObj.isPush;
                            subscribeObj.isSubscribed = @"0";
                        }
                        
                        subscribeObj.isOnRank = @"1";
                        [moreRank addObject:subscribeObj];
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subscribeObj addIfNotExist:YES];
                        [[SNDBManager currentDataBase] addSubscribeATypeRelation:kSubTypeRankId subId:subscribeObj.subId];
                    }
                }
            }
        }
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubMoreRankList
                                                                                                       strongDataRef:moreRank
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRefreshSubMoreRankList
                                                                                                       strongDataRef:nil
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)h5NewsAddMySubscribe:(id)jsonData
{
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id statusObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubStatusKey];
        if ([statusObj isKindOfClass:[NSString class]]) {
            // 返回200 成功 更新数据库
            if ([(NSString *)statusObj isEqualToString:kSubAddOrRemoveMySubSuccessRet]) {
//                SCSubscribeObject *cachedSubObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                
                // 优先缓存服务器返回的数据
                id subObjReturnData = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubSubObjKey];
                if (subObjReturnData && [subObjReturnData isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subObj = [self parseOneSubObjFromJsonObj:subObjReturnData];
                    if (subObj) {
                        subObj.isSubscribed = @"1";
                        subObj.defaultPush = subObj.isPush;
                        subObj.isTop = [subObj.stickTop intValue] ? @"1" : @"0";
                        if ([subObj.isTop isEqualToString:@"1"]) {
                            [subObj updateTopTime];
                        }
                        
                        NSArray *mySubArray = [[SNDBManager currentDataBase] getSubSortedArrayWithoutExpressOrYouMayLike];
                        SCSubscribeObject *lastMySub = [mySubArray lastObject];
                        if (lastMySub) {
                            subObj.sortIndex = [NSString stringWithFormat:@"%ld", [lastMySub.sortIndex integerValue] + 1];
                        }
                        
                        // todo 这里需要看服务器新给的top字段
                        if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES]) {//
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSMutableDictionary *notifyUserInfo = [NSMutableDictionary dictionary];
                                NSMutableArray *subIdsArray = [NSMutableArray array];
                                [subIdsArray addObject:subObj.subId];
                                [notifyUserInfo setObject:subIdsArray forKey:kSubcenterMySubDidChangedAddedSubIdArrayKey];
                                
                                [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:notifyUserInfo];
                            });
                        }
                    }
                    
                    // 如果关注成功之后 返回的刊物信息没有pubIds  依然需要强刷一下我的订阅
                    if (![(NSDictionary *)subObjReturnData objectForKey:@"pubIds"]) {
                        // 如果关注成功了  本地反而没有这个刊物  则需要强刷一下我的订阅  也许可以刷出这个刊物
                        [self performSelectorOnMainThread:@selector(loadMySubFromServer) withObject:nil waitUntilDone:YES];
                    }
                }
                // 再看本地数据库中有没有已经缓存的数据
//                else if (cachedSubObj) {
//                    cachedSubObj.isSubscribed = @"1";
//                    cachedSubObj.isPush = cachedSubObj.defaultPush;
//                    cachedSubObj.isTop = [cachedSubObj.stickTop intValue] ? @"1" : @"0";
//                    if ([cachedSubObj.isTop isEqualToString:@"1"]) {
//                        [cachedSubObj updateTopTime];
//                    }
//                    
//                    if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:cachedSubObj addIfNotExist:NO]) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            NSMutableDictionary *notifyUserInfo = [NSMutableDictionary dictionary];
//                            NSMutableArray *subIdsArray = [NSMutableArray array];
//                            [subIdsArray addObject:cachedSubObj.subId];
//                            [notifyUserInfo setObject:subIdsArray forKey:kSubcenterMySubDidChangedAddedSubIdArrayKey];
//                            
//                            [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:notifyUserInfo];
//                        });
//                    }
//                }
                // 服务器也没返回  本地也没有 强刷一下我的订阅
                else {
                    // 如果关注成功了  本地反而没有这个刊物  则需要强刷一下我的订阅  也许可以刷出这个刊物
                    [self performSelectorOnMainThread:@selector(loadMySubFromServer) withObject:nil waitUntilDone:YES];
                }
            }
            // 失败
            else {
            }
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        
    }
}

- (void)h5NewsRemoveMySubscribeSubId:(NSString *)subId
{
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
    if (subObj) {
        subObj.isSubscribed = @"0";
        subObj.isTop = @"0";
        subObj.openTimes = @"0";
        subObj.backPromotion = @"0";
        subObj.status = @"0";
        subObj.isPush = subObj.defaultPush;
        
        if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary *notifyUserInfo = [NSMutableDictionary dictionary];
                NSMutableArray *subIdsArray = [NSMutableArray array];
                [subIdsArray addObject:subObj.subId];
                [notifyUserInfo setObject:subIdsArray forKey:kSubcenterMySubDidChangedRemovedSubIdArrayKey];
                
                [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:notifyUserInfo];
            });
        }
    }
}

- (void)parseAddMySubWithResponseObject:(id)jsonData andSubId:(NSString *)subId {
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id statusObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubStatusKey];
        if ([statusObj isKindOfClass:[NSString class]]) {
            // 返回200 成功 更新数据库 -- 回调delegate
            if ([(NSString *)statusObj isEqualToString:kSubAddOrRemoveMySubSuccessRet]
                || [(NSString *)statusObj isEqualToString:kSubAddMySubSuccess290Ret]) {
                
                SCSubscribeObject *cachedSubObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubToServer strongDataRef:subId weakDataRef:nil];
                
                // 优先缓存服务器返回的数据
                id subObjReturnData = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubSubObjKey];
                if (subObjReturnData && [subObjReturnData isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subObj = [self parseOneSubObjFromJsonObj:subObjReturnData];
                    if (subObj) {
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:kRecomSubClick] == YES) {
                            subObj.isSubscribed = @"1";
                        } else {
                            subObj.isSubscribed = @"1";
                            subObj.defaultPush = subObj.isPush;
                            subObj.isTop = [subObj.stickTop intValue] ? @"1" : @"0";
                            if ([subObj.isTop isEqualToString:@"1"]) {
                                [subObj updateTopTime];
                            }
                            
                            NSArray *mySubArray = [[SNDBManager currentDataBase] getSubSortedArrayWithoutExpressOrYouMayLike];
                            SCSubscribeObject *lastMySub = [mySubArray lastObject];
                            if (lastMySub) {
                                subObj.sortIndex = [NSString stringWithFormat:@"%ld", [lastMySub.sortIndex integerValue] + 1];
                            }
                        }
                        
                        // todo 这里需要看服务器新给的top字段
                        if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSMutableDictionary *notifyUserInfo = [NSMutableDictionary dictionary];
                                NSMutableArray *subIdsArray = [NSMutableArray array];
                                [subIdsArray addObject:subObj.subId];
                                [notifyUserInfo setObject:subIdsArray forKey:kSubcenterMySubDidChangedAddedSubIdArrayKey];
                                
                                [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:notifyUserInfo];
                            });
                            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
                        }
                        else {
                            cbDataSet.lastError = [NSError errorWithDomain:@"update database failed" code:SCServiceErrorCodeUpdateExistObjError userInfo:nil];
                            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                        }
                    }
                    
                    // 如果关注成功之后 返回的刊物信息没有pubIds  依然需要强刷一下我的订阅
                    if (![(NSDictionary *)subObjReturnData objectForKey:@"pubIds"]) {
                        // 如果关注成功了  本地反而没有这个刊物  则需要强刷一下我的订阅  也许可以刷出这个刊物
                        [self performSelectorOnMainThread:@selector(loadMySubFromServer) withObject:nil waitUntilDone:YES];
                        
                        cbDataSet.lastError = [NSError errorWithDomain:@"no object exists for current sub id" code:SCServiceErrorCodeNoExistObj userInfo:nil];
                    }
                }
                // 再看本地数据库中有没有已经缓存的数据
                else if (cachedSubObj) {
                    cachedSubObj.isSubscribed = @"1";
                    cachedSubObj.isPush = cachedSubObj.defaultPush;
                    cachedSubObj.isTop = [cachedSubObj.stickTop intValue] ? @"1" : @"0";
                    if ([cachedSubObj.isTop isEqualToString:@"1"]) {
                        [cachedSubObj updateTopTime];
                    }
                    
                    if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:cachedSubObj addIfNotExist:NO]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSMutableDictionary *notifyUserInfo = [NSMutableDictionary dictionary];
                            NSMutableArray *subIdsArray = [NSMutableArray array];
                            [subIdsArray addObject:cachedSubObj.subId];
                            [notifyUserInfo setObject:subIdsArray forKey:kSubcenterMySubDidChangedAddedSubIdArrayKey];
                            
                            [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:notifyUserInfo];
                        });
                        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
                    }
                    else {
                        cbDataSet.lastError = [NSError errorWithDomain:@"update database failed" code:SCServiceErrorCodeUpdateExistObjError userInfo:nil];
                        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];

                    }
                }
                // 服务器也没返回  本地也没有 强刷一下我的订阅
                else {
                    // 如果关注成功了  本地反而没有这个刊物  则需要强刷一下我的订阅  也许可以刷出这个刊物
                    [self performSelectorOnMainThread:@selector(loadMySubFromServer) withObject:nil waitUntilDone:YES];
                    
                    cbDataSet.lastError = [NSError errorWithDomain:@"no object exists for current sub id" code:SCServiceErrorCodeNoExistObj userInfo:nil];
                }
            }
            // 失败
            else {
                id retmsgObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubMsgKey];
                NSString *domain = [retmsgObj isKindOfClass:[NSString class]] ? retmsgObj : @"error unKonwn";
                NSError *error = [NSError errorWithDomain:domain code:[statusObj integerValue] userInfo:nil];
                
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubToServer strongDataRef:subId weakDataRef:nil];
                cbDataSet.lastError = error;
                
                [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
            }
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        NSError *error = [NSError errorWithDomain:@"error unKonwn" code:SCServiceErrorCodeUnknown userInfo:nil];
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubToServer strongDataRef:subId weakDataRef:nil];
        cbDataSet.lastError = error;
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
    }

}

- (void)parseRemoveMySubWithResponseObject:(id)jsonData andSubId:(NSString *)subId {
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id statusObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubStatusKey];
        if ([statusObj isKindOfClass:[NSString class]]) {
            // 返回200 成功 //290 订阅超过400份 也是订阅成功，据说是服务端历史原因不能统一
            if ([(NSString *)statusObj isEqualToString:kSubAddOrRemoveMySubSuccessRet]
                || [(NSString *)statusObj isEqualToString:kSubAddMySubSuccess290Ret]) {
                
                SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRemoveMySubToServer strongDataRef:subId weakDataRef:nil];
                if (subObj) {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:kRecomSubClick] == YES) {
                        subObj.isSubscribed = @"2";
                    } else {
                        subObj.isSubscribed = @"0";
                        subObj.isTop = @"0";
                        subObj.openTimes = @"0";
                        subObj.backPromotion = @"0";
                        subObj.status = @"0";
                        subObj.isPush = subObj.defaultPush;
                    }
                    
                    if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSMutableDictionary *notifyUserInfo = [NSMutableDictionary dictionary];
                            NSMutableArray *subIdsArray = [NSMutableArray array];
                            [subIdsArray addObject:subObj.subId];
                            [notifyUserInfo setObject:subIdsArray forKey:kSubcenterMySubDidChangedRemovedSubIdArrayKey];
                            
                            [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:notifyUserInfo];
                        });
                        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
                    }
                    else {
                        cbDataSet.lastError = [NSError errorWithDomain:@"update database failed" code:SCServiceErrorCodeUpdateExistObjError userInfo:nil];
                        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                    }
                }
                else {
                    cbDataSet.lastError = [NSError errorWithDomain:@"no object exists for current sub id" code:SCServiceErrorCodeNoExistObj userInfo:nil];
                    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                }
            }
            // 失败
            else {
                id retmsgObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubMsgKey];
                NSString *domain = [retmsgObj isKindOfClass:[NSString class]] ? retmsgObj : @"error unKonwn";
                NSError *error = [NSError errorWithDomain:domain code:[statusObj integerValue] userInfo:nil];
                
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRemoveMySubToServer strongDataRef:subId weakDataRef:nil];
                cbDataSet.lastError = error;
                
                [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
            }
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        NSError *error = [NSError errorWithDomain:@"error unKonwn" code:SCServiceErrorCodeUnknown userInfo:nil];
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeRemoveMySubToServer strongDataRef:subId weakDataRef:nil];
        cbDataSet.lastError = error;
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
    }

}

- (void)parseAddOrRemoveMySubRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    SNDebugLog(@"%@--%@ jsonData %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), jsonData);
    
    SNDebugLog(@"%@-- statementObj %@", NSStringFromSelector(_cmd), userInfo.strongRef);
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id statusObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubStatusKey];
        if ([statusObj isKindOfClass:[NSString class]]) {
            // 返回200 成功
            if ([(NSString *)statusObj isEqualToString:kSubAddOrRemoveMySubSuccessRet]) {
                BOOL allSuccess = YES;
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer
                                                                                                               strongDataRef:userInfo.strongRef
                                                                                                                 weakDataRef:nil];
                
                NSMutableDictionary *notifyUserInfo = [NSMutableDictionary dictionary];
                NSMutableArray *subIdsArray = [NSMutableArray array];
                NSMutableArray *subIdsArrayRemove = [NSMutableArray array];
                
                [notifyUserInfo setObject:subIdsArray forKey:kSubcenterMySubDidChangedAddedSubIdArrayKey];
                [notifyUserInfo setObject:subIdsArrayRemove forKey:kSubcenterMySubDidChangedRemovedSubIdArrayKey];
                
                NSDictionary *statementObj = userInfo.strongRef;
                NSString *addStatement = [statementObj objectForKey:@"yes"];
                if (addStatement) {
                    addStatement = [addStatement stringByReplacingOccurrencesOfString:@"&yes=" withString:@""];
                    NSArray *subIds = [addStatement componentsSeparatedByString:@","];
                    
                    for (NSString *subId in subIds) {
                        
                        [subIdsArray addObject:subId];
                        
                        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                        if (subObj) {
                            subObj.isSubscribed = @"1";
                            subObj.isPush = subObj.defaultPush;
                            if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO]) {
                                
                            }
                            else {
                                allSuccess = NO;
                            }
                        }
                        else {
//                            allSuccess = NO; // 本地没有这个刊物  不一定代表没有添加关注成功
                        }
                    }
                    
                    if ([subIds count] == 1) {
                        id subObjReturnData = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubSubObjKey];
                        if (subObjReturnData && [subObjReturnData isKindOfClass:[NSDictionary class]]) {
                            SCSubscribeObject *subObj = [self parseOneSubObjFromJsonObj:subObjReturnData];
                            if (subObj) {
                                subObj.isSubscribed = @"1";
                                subObj.defaultPush = subObj.isPush;
                                if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES]) {
                                }
                            }
                            
                            // 如果关注成功之后 返回的刊物信息没有pubIds  依然需要强刷一下我的订阅
                            if (![(NSDictionary *)subObjReturnData objectForKey:@"pubIds"]) {
                                // 如果关注成功了  本地反而没有这个刊物  则需要强刷一下我的订阅  也许可以刷出这个刊物
                                [self performSelectorOnMainThread:@selector(loadMySubFromServer) withObject:nil waitUntilDone:YES];
                                
                                cbDataSet.lastError = [NSError errorWithDomain:@"no object exists for current sub id" code:SCServiceErrorCodeNoExistObj userInfo:nil];
                            }
                        }
                    }
                }
                
                NSString *removeStatement = [statementObj objectForKey:@"no"];
                if (removeStatement) {
                    removeStatement = [removeStatement stringByReplacingOccurrencesOfString:@"&no=" withString:@""];
                    NSArray *subIds = [removeStatement componentsSeparatedByString:@","];
                    
                    for (NSString *subId in subIds) {
                        
                        [subIdsArrayRemove addObject:subId];
                        
                        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                        if (subObj) {
                            subObj.isSubscribed = @"0";
                            subObj.isTop = @"0";
                            subObj.openTimes = @"0";
                            subObj.backPromotion = @"0";
                            subObj.status = @"0";
                            subObj.isPush = subObj.defaultPush;
                            if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO]) {
                            }
                            else {
                                allSuccess = NO;
                            }
                        }
                        else {
                            allSuccess = NO;
                        }
                    }
                }
                
                // notify did changed
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:notifyUserInfo];
                });
                
                if (allSuccess) {
                    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
                    [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
                }
                else {
                    cbDataSet.lastError = [NSError errorWithDomain:@"no all success" code:SCServiceErrorCodeNotAllSuccess userInfo:nil];
                    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                    [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
                }
            }
            // 失败
            else {
                id retmsgObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubMsgKey];
                NSString *domain = [retmsgObj isKindOfClass:[NSString class]] ? retmsgObj : @"error unKonwn";
                NSError *error = [NSError errorWithDomain:domain code:[statusObj integerValue] userInfo:nil];
                
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer
                                                                                                               strongDataRef:userInfo.strongRef
                                                                                                                 weakDataRef:nil];
                cbDataSet.lastError = error;
                
                [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
            }
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        NSError *error = [NSError errorWithDomain:@"error unKonwn" code:SCServiceErrorCodeUnknown userInfo:nil];
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddOrRemoveMySubsToServer
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        cbDataSet.lastError = error;
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSyncMyPushRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id retObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubStatusKey];
        if ([retObj isKindOfClass:[NSString class]]) {
            // 成功
            if ([retObj isEqualToString:kSubAddOrRemoveMySubSuccessRet]) {
                NSString *statementStr = [userInfo strongRef];
                NSString *subId = nil;
                BOOL isMyPush = ([statementStr rangeOfString:@"&yes="].location != NSNotFound);
                if (isMyPush) {
                    subId = [statementStr stringByReplacingOccurrencesOfString:@"&yes=" withString:@""];
                }
                else {
                    subId = [statementStr stringByReplacingOccurrencesOfString:@"&no=" withString:@""];
                }
                
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubPush
                                                                                                               strongDataRef:userInfo.strongRef
                                                                                                                 weakDataRef:nil];
                SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                if (subObj) {
                    subObj.isPush = isMyPush ? @"1" : @"0";
                    if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil];
                        });
                        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
                        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
                    }
                    else {
                        cbDataSet.lastError = [NSError errorWithDomain:@"update database failed" code:SCServiceErrorCodeUpdateExistObjError userInfo:nil];
                        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
                    }
                }
                else {
                    // 本地没有  需要强刷一下我的订阅
                    [self performSelectorOnMainThread:@selector(loadMySubFromServer) withObject:nil waitUntilDone:YES];
                    
                    cbDataSet.lastError = [NSError errorWithDomain:@"no object exists for current sub id" code:SCServiceErrorCodeNoExistObj userInfo:nil];
                    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                    [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
                }
            }
            // 失败
            else {
                id retmsgObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubMsgKey];
                NSString *domain = [retmsgObj isKindOfClass:[NSString class]] ? retmsgObj : @"error unKonwn";
                NSError *error = [NSError errorWithDomain:domain code:[retObj integerValue] userInfo:nil];
                
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubPush
                                                                                                               strongDataRef:userInfo.strongRef
                                                                                                                 weakDataRef:nil];
                cbDataSet.lastError = error;
                [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
            }
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        NSError *error = [NSError errorWithDomain:@"error unKonwn" code:SCServiceErrorCodeUnknown userInfo:nil];
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubPush
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        cbDataSet.lastError = error;
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSyncMyPushArrayRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id retObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubStatusKey];
        if ([retObj isKindOfClass:[NSString class]]) {
            // 成功
            if ([retObj isEqualToString:kSubAddOrRemoveMySubSuccessRet]) {
                BOOL allSuccess = YES;
                BOOL needRefreshMySub = NO;
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubsPushArray
                                                                                                               strongDataRef:userInfo.strongRef
                                                                                                                 weakDataRef:nil];
                
                NSDictionary *statementObj = userInfo.strongRef;
                NSString *addStatement = [statementObj objectForKey:@"yes"];
                if (addStatement) {
                    addStatement = [addStatement stringByReplacingOccurrencesOfString:@"&yes=" withString:@""];
                    NSArray *subIds = [addStatement componentsSeparatedByString:@","];
                    for (NSString *subId in subIds) {
                        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                        if (subObj) {
                            subObj.isPush = @"1";
                            if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO]) {
                                // todo notify
                            }
                            else {
                                allSuccess = NO;
                            }
                        }
                        else {
                            // 就算本地没有  不代表不需要将推送状态设置到数据库
                            SCSubscribeObject *newObj = [[SCSubscribeObject alloc] init];
                            newObj.subId = subId;
                            newObj.isPush = @"1";
                            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:newObj addIfNotExist:YES];
                            needRefreshMySub = YES;
                            allSuccess = NO;
                        }
                    }
                }
                
                NSString *removeStatement = [statementObj objectForKey:@"no"];
                if (removeStatement) {
                    removeStatement = [removeStatement stringByReplacingOccurrencesOfString:@"&no=" withString:@""];
                    NSArray *subIds = [removeStatement componentsSeparatedByString:@","];
                    for (NSString *subId in subIds) {
                        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                        if (subObj) {
                            subObj.isPush = @"0";
                            if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO]) {
                                // todo notify
                            }
                            else {
                                allSuccess = NO;
                            }
                        }
                        else {
                            // 就算本地没有  不代表不需要将推送状态设置到数据库
                            SCSubscribeObject *newObj = [[SCSubscribeObject alloc] init];
                            newObj.subId = subId;
                            newObj.isPush = @"0";
                            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:newObj addIfNotExist:YES];
                            needRefreshMySub = YES;
                            allSuccess = NO;
                        }
                    }
                }
                
                // notify did changed
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil];
                });
                
                if (needRefreshMySub) {
                    [self performSelectorOnMainThread:@selector(loadMySubFromServer) withObject:nil waitUntilDone:YES];
                }
                
                if (allSuccess) {
                    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
                    [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
                }
                else {
                    cbDataSet.lastError = [NSError errorWithDomain:@"no all success" code:SCServiceErrorCodeNotAllSuccess userInfo:nil];
                    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                    [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
                }
            }
            // 失败
            else {
                id retmsgObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubMsgKey];
                NSString *domain = [retmsgObj isKindOfClass:[NSString class]] ? retmsgObj : @"error unKonwn";
                NSError *error = [NSError errorWithDomain:domain code:[retObj integerValue] userInfo:nil];
                
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubsPushArray
                                                                                                               strongDataRef:userInfo.strongRef
                                                                                                                 weakDataRef:nil];
                cbDataSet.lastError = error;
                [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
            }
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        NSError *error = [NSError errorWithDomain:@"error unKonwn" code:SCServiceErrorCodeUnknown userInfo:nil];
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSynchronizeMySubsPushArray
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        cbDataSet.lastError = error;
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parsePostSubCommentRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    
    SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypePostSubComment];
    if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
        id resultObj = [(NSDictionary *)jsonData objectForKey:kPostSubCommentResultKey];
        if ([resultObj isKindOfClass:[NSString class]]) {
            if ([resultObj isEqualToString:@"200"]) {
                // 成功
                [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
                [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
            }
            else {
                // 失败
                NSString *errorString = [(NSDictionary *)jsonData stringValueForKey:@"message" defaultValue:@"评论失败"];
                cbDataSet.lastError = [NSError errorWithDomain:errorString code:SCServiceErrorCodeUnSuccess userInfo:nil];
                [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
            }
        }
        else {
            // 没有返回
            cbDataSet.lastError = [NSError errorWithDomain:@"评论失败" code:SCServiceErrorCodeUnknown userInfo:nil];
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
            [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
        }
    }
    else {
        // 异常
        cbDataSet.lastError = [NSError errorWithDomain:@"评论失败" code:SCServiceErrorCodeUnknown userInfo:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubDetailRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    
    SNDebugLog(@"%@-- jsonData %@", NSStringFromSelector(_cmd), jsonData);
    
    SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubDetail
                                                                                                   strongDataRef:userInfo.strongRef
                                                                                                     weakDataRef:nil];
    SCSubscribeObject *subObj = nil;
    if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *subDic = [(NSDictionary *)jsonData objectForKey:kSubCommentSubscribe];
        NSArray *subTypeIcons = nil;
        if (subDic && [subDic isKindOfClass:[NSDictionary class]]) {
            subObj = [self parseOneSubObjFromJsonObj:subDic];
            // 3.6 增加刊物类型图片
            subTypeIcons = [subDic arrayValueForKey:@"subTypeIcon" defaultValue:nil];
        }
        
        NSDictionary *commentDic = [(NSDictionary *)jsonData objectForKey:@"comment"];
        if (commentDic && [commentDic isKindOfClass:[NSDictionary class]]) {
            NSString *commentNum = [commentDic objectForKey:@"commentCount"];
            if (commentNum && [commentNum isKindOfClass:[NSString class]]) {
                if ([commentNum length] > 0) {
                    subObj.commentCount = commentNum;
                }
            }
            NSString *starGrade = [commentDic objectForKey:@"starGrade"];
            if (starGrade && [starGrade isKindOfClass:[NSString class]]) {
                if ([starGrade length] > 0) {
                    subObj.starGrade = starGrade;
                }
            }
            
            NSArray *commentsArray = [commentDic objectForKey:@"commentList"];
            if (commentsArray && [commentsArray isKindOfClass:[NSArray class]]) {
                NSMutableArray *commentObjsArray = [NSMutableArray array];
                for (id cmtObj in commentsArray) {
                    if ([cmtObj isKindOfClass:[NSDictionary class]]) {
                        SCSubscribeCommentObject *commentObj = [self parseOneSubCommentFromJsonObj:cmtObj];
                        commentObj.subId = userInfo.strongRef;
                        if (commentObj) {
                            [commentObjsArray addObject:commentObj];
                        }
                    }
                }
                [[SNDBManager currentDataBase] setSubscribeCenterSubCommentsArray:commentObjsArray forSubId:userInfo.strongRef];
            }
        }
        
        NSArray *subCommendArray = [(NSDictionary *)jsonData arrayValueForKey:@"subList" defaultValue:nil];
        NSMutableString *subIds = [NSMutableString string];
        
        if (subCommendArray) {
            for (NSDictionary *subDic in subCommendArray) {
                if ([subDic isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *subRecObj = [self parseOneSubObjFromJsonObj:subDic];
                    if (subRecObj) {
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subRecObj addIfNotExist:YES];
                        [subIds appendFormat:@"%@,", subRecObj.subId];
                    }
                }
            }
        }
        
        NSMutableArray *userInfoList = [NSMutableArray array];
        id userInfoObj = [(NSDictionary *)jsonData objectForKey:@"user_info"];
        if (userInfoObj && [userInfoObj isKindOfClass:[NSDictionary class]]) {
            [userInfoList addObject:userInfoObj];
        }
        else if (userInfoObj && [userInfoObj isKindOfClass:[NSArray class]]) {
            [userInfoList addObjectsFromArray:userInfoObj];
        }
        
        // userInfo需要提前置为空字符串 以防止服务器去掉这个节点不能同步去掉数据库中的节点
        subObj.userInfo = @"";
        
        // 更新一下数据库
        SCSubscribeObject *oldObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subObj.subId];
        if (userInfoObj && ([userInfoObj isKindOfClass:[NSDictionary class]] || [userInfoObj isKindOfClass:[NSArray class]])) {
            NSString *jsonStr = [userInfoObj yajl_JSONString];
            if (jsonStr.length > 0)
                subObj.userInfo = jsonStr;
        }
        if ([oldObj.isSubscribed isEqualToString:@"1"]) {
            subObj.isPush = oldObj.isPush;
        }
        else {
            subObj.defaultPush = subObj.isPush;
        }
        subObj.topNews2 = subIds;
        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        
        // 回调subIcon
        if (subTypeIcons) {
            NSDictionary *retObj = @{@"subId": subObj.subId, @"subTypeIcon" : subTypeIcons};
            
            SNSubscribeCenterCallbackDataSet *_tmpCb = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubDetailSubTypeIcon
                                                                                                        strongDataRef:retObj
                                                                                                          weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:_tmpCb status:SNSubscribeCenterServiceStatusSuccess];
        }
        
        // 回调 userInfo
        if (userInfoList.count > 0) {
            SNSubscribeCenterCallbackDataSet *_tmpCb = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubDetailUserInfo
                                                                                                        strongDataRef:userInfoList
                                                                                                          weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:_tmpCb status:SNSubscribeCenterServiceStatusSuccess];
        }
        else {
            SNSubscribeCenterCallbackDataSet *_tmpCb = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubDetailUserInfo
                                                                                                        strongDataRef:nil
                                                                                                          weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:_tmpCb status:SNSubscribeCenterServiceStatusFail];
        }
        
    }
    else {
        cbDataSet.lastError = [NSError errorWithDomain:@"error unknown" code:SCServiceErrorCodeUnknown userInfo:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubInfoRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    
    SNDebugLog(@"%@-- jsonData %@", NSStringFromSelector(_cmd), jsonData);
    
    SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubInfo
                                                                                                   strongDataRef:userInfo.strongRef
                                                                                                     weakDataRef:nil];
    SCSubscribeObject *subObj = nil;
    if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *subDic = [(NSDictionary *)jsonData objectForKey:kSubCommentSubscribe];
        NSArray *subTypeIcons = nil;
        if (subDic && [subDic isKindOfClass:[NSDictionary class]]) {
            subObj = [self parseOneSubObjFromJsonObj:subDic];
            subTypeIcons = [subDic arrayValueForKey:@"subTypeIcon" defaultValue:nil];
        }
        
        // 更新一下数据库
        SCSubscribeObject *oldObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subObj.subId];
        if ([oldObj.isSubscribed isEqualToString:@"1"]) {
            subObj.isPush = oldObj.isPush;
        }
        else {
            subObj.defaultPush = subObj.isPush;
        }

        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        
        //回调subTypeIcon
        if (subTypeIcons) {
            NSDictionary *retObj = @{@"subId": subObj.subId, @"subTypeIcon" : subTypeIcons};
            
            SNSubscribeCenterCallbackDataSet *_tmpCb = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubInfoSubTypeIcon
                                                                                                        strongDataRef:retObj
                                                                                                          weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:_tmpCb status:SNSubscribeCenterServiceStatusSuccess];
        }
    }
    else {
        cbDataSet.lastError = [NSError errorWithDomain:@"error unknown" code:SCServiceErrorCodeUnknown userInfo:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}


- (void)parseSubInfoRequest:(TTURLRequest *)request Subscribed:(BOOL)isSubscribed{
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    
    SNDebugLog(@"%@-- jsonData %@", NSStringFromSelector(_cmd), jsonData);
    
    SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubInfo
                                                                                                   strongDataRef:userInfo.strongRef
                                                                                                     weakDataRef:nil];
    SCSubscribeObject *subObj = nil;
    if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *subDic = [(NSDictionary *)jsonData objectForKey:kSubCommentSubscribe];
        NSArray *subTypeIcons = nil;
        if (subDic && [subDic isKindOfClass:[NSDictionary class]]) {
            subObj = [self parseOneSubObjFromJsonObj:subDic];
            subTypeIcons = [subDic arrayValueForKey:@"subTypeIcon" defaultValue:nil];
        }
        
        if (isSubscribed == YES) {
            subObj.isSubscribed = @"1";
        }
        else{
            subObj.isSubscribed = @"0";
        }
        
        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        
        //回调subTypeIcon
        if (subTypeIcons) {
            NSDictionary *retObj = @{@"subId": subObj.subId, @"subTypeIcon" : subTypeIcons};
            
            SNSubscribeCenterCallbackDataSet *_tmpCb = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubInfoSubTypeIcon
                                                                                                        strongDataRef:retObj
                                                                                                          weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:_tmpCb status:SNSubscribeCenterServiceStatusSuccess];
        }
    }
    else {
        cbDataSet.lastError = [NSError errorWithDomain:@"error unknown" code:SCServiceErrorCodeUnknown userInfo:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubCommentRequest:(TTURLRequest *)request {
    TTUserInfo *userInfo = request.userInfo;
    SNURLJSONResponse *json = request.response;
    id rootObj = json.rootObject;
    
    SNDebugLog(@"%@-- jsonData %@", NSStringFromSelector(_cmd), rootObj);
    
    NSString *statement = userInfo.strongRef;
    NSArray *ids = [statement componentsSeparatedByString:@"&"];
    if ([ids count] != 2) {
        SNDebugLog(@"%@--%@ invalidate statement %@ ~!!!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), statement);
        return;
    }
    
    NSString *subId = [ids objectAtIndex:0];
    
    NSMutableArray *commentObjsArray = [NSMutableArray array];
    
    if (rootObj && [rootObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *commentObj = [(NSDictionary *)rootObj objectForKey:@"comment"];
        
        if (commentObj && [commentObj isKindOfClass:[NSDictionary class]]) {
            
            NSArray *commentList = [commentObj objectForKey:@"commentList"];
            
            if (commentList && [commentList isKindOfClass:[NSArray class]]) {
                for (id cmtObj in commentList) {
                    if ([cmtObj isKindOfClass:[NSDictionary class]]) {
                        SCSubscribeCommentObject *commentObj = [self parseOneSubCommentFromJsonObj:cmtObj];
                        commentObj.subId = subId;
                        if (commentObj) {
                            [commentObjsArray addObject:commentObj];
                        }
                    }
                }
            }
        }
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubComment
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        cbDataSet.reservedDataRef = commentObjsArray;
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubComment
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubRecommendRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id rootObj = json.rootObject;
    if (rootObj && [rootObj isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *recSubList = [NSMutableArray array];
        id subListObj = [(NSDictionary *)rootObj objectForKey:@"subList"];
        if (subListObj && [subListObj isKindOfClass:[NSArray class]]) {
            for (id subObj in subListObj) {
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    SCSubscribeObject *newSubObj = [self parseOneSubObjFromJsonObj:subObj];
                    if (newSubObj) {
                        // 更新一下数据库
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:newSubObj addIfNotExist:YES];
                        [recSubList addObject:newSubObj];
                    }
                }
            }
        }
        if ([recSubList count] > 0) {
            SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubRecommend
                                                                                                           strongDataRef:recSubList
                                                                                                             weakDataRef:nil];
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
            [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
        }
        else {
            SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubRecommend];
            [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
            [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
        }
    }
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubRecommend];
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseAddMySubsAndPushSynchRequest:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    SNDebugLog(@"%@--%@ jsonData %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), jsonData);
    
    SNDebugLog(@"%@-- statementObj %@", NSStringFromSelector(_cmd), userInfo.strongRef);
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        id statusObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubStatusKey];
        if ([statusObj isKindOfClass:[NSString class]]) {
            // 返回200 成功
            if ([(NSString *)statusObj isEqualToString:kSubAddOrRemoveMySubSuccessRet]) {
                BOOL allSuccess = YES;
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubsAndSynchPush
                                                                                                               strongDataRef:userInfo.strongRef
                                                                                                                 weakDataRef:nil];
                
                NSDictionary *statementObj = userInfo.strongRef;
                NSString *addStatement = [statementObj objectForKey:@"yes"];
                
                BOOL bOpen = [[statementObj objectForKey:@"pushOpen"] boolValue];
                
                NSMutableArray *subsNeedToSynchPush = [NSMutableArray array];
                
                // for notify
                NSMutableDictionary *notifyUserInfo = [NSMutableDictionary dictionary];
                NSMutableArray *subIdsAdded = [NSMutableArray array];
                [notifyUserInfo setObject:subIdsAdded forKey:kSubcenterMySubDidChangedAddedSubIdArrayKey];
                
                if (addStatement) {
                    addStatement = [addStatement stringByReplacingOccurrencesOfString:@"&yes=" withString:@""];
                    NSArray *subIds = [addStatement componentsSeparatedByString:@","];
                    
                    for (NSString *subId in subIds) {
                        
                        [subIdsAdded addObject:subId];
                        
                        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                        if (subObj) {
                            subObj.isSubscribed = @"1";
                            if (subObj.defaultPush == nil || [subObj.defaultPush boolValue] != bOpen) {
                                subObj.isPush = [NSString stringWithFormat:@"%d", bOpen];
                                [subsNeedToSynchPush addObject:subObj];
                            }
                            else {
                                subObj.isPush = subObj.defaultPush;
                            }
                            
                            if ([[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO]) {
                            }
                            else {
                                allSuccess = NO;
                            }
                        }
                        else {
                            SCSubscribeObject *subObj = [[SCSubscribeObject alloc] init];
                            subObj.subId = subId;
                            subObj.isPush = [NSString stringWithFormat:@"%d", bOpen];
                            [subsNeedToSynchPush addObject:subObj];
//                            allSuccess = NO; // -- 本地没有这个刊物  不一定代表没有成功
                        }
                    }
                }
                
                // notify did changed
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:notifyUserInfo];
                });
                
                // 是否需要想服务器同步推送设置
                if ([subsNeedToSynchPush count] > 0) {
//                    [self synchronizeMySubsPushToServerBySubObjects:subsNeedToSynchPush]; // 在子线程中发起TT请求  会导致设置statusbar 的network indicator运动状态失败
                    [self performSelectorOnMainThread:@selector(synchronizeMySubsPushToServerBySubObjects:) withObject:subsNeedToSynchPush waitUntilDone:YES];
                }
                
                if (allSuccess) {
                    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
                    [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
                }
                else {
                    cbDataSet.lastError = [NSError errorWithDomain:@"no all success" code:SCServiceErrorCodeNotAllSuccess userInfo:nil];
                    [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                    [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
                }
            }
            // 失败
            else {
                id retmsgObj = [(NSDictionary *)jsonData objectForKey:kSubAddOrRemoveMySubMsgKey];
                NSString *domain = [retmsgObj isKindOfClass:[NSString class]] ? retmsgObj : @"error unKonwn";
                NSError *error = [NSError errorWithDomain:domain code:[statusObj integerValue] userInfo:nil];
                
                SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubsAndSynchPush
                                                                                                               strongDataRef:userInfo.strongRef
                                                                                                                 weakDataRef:nil];
                cbDataSet.lastError = error;
                
                [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
                [self callBackBackgroundListenerWithRefId:getTTUserInfoWeakRefAndClean(userInfo) operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
            }
        }
    }
    // 预防不靠谱的服务器抽风什么也不返回
    else {
        NSError *error = [NSError errorWithDomain:@"error unKonwn" code:SCServiceErrorCodeUnknown userInfo:nil];
        
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeAddMySubsAndSynchPush
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        cbDataSet.lastError = error;
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:nil operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)parseSubQRInfo:(TTURLRequest *)request {
    SNURLJSONResponse *json = request.response;
    NSDictionary *jsonData = json.rootObject;
    TTUserInfo *userInfo = request.userInfo;
    SNDebugLog(@"%@--%@ jsonData %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), jsonData);
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubQRInfo
                                                                                                       strongDataRef:jsonData
                                                                                                         weakDataRef:nil];
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusSuccess];
        [self callBackBackgroundListenerWithRefId:userInfo.strongRef operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusSuccess];
    }
    else {
        SNSubscribeCenterCallbackDataSet *cbDataSet = [SNSubscribeCenterCallbackDataSet callBackDataSetWithOperation:SCServiceOperationTypeSubQRInfo
                                                                                                       strongDataRef:userInfo.strongRef
                                                                                                         weakDataRef:nil];
        
        cbDataSet.lastError = [NSError errorWithDomain:@"error unKonwn" code:SCServiceErrorCodeUnknown userInfo:nil];
        
        [self callBackToDelegateWithCallbackDataSet:cbDataSet status:SNSubscribeCenterServiceStatusFail];
        [self callBackBackgroundListenerWithRefId:userInfo.strongRef operationType:cbDataSet.operation status:SNSubscribeCenterServiceStatusFail];
    }
}

- (void)callBackToDelegateWithCallbackDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet status:(SNSubscribeCenterServiceStatus)status{
    SEL selecor = nil;
    if (status == SNSubscribeCenterServiceStatusSuccess) {
        selecor = @selector(didFinishLoadDataWithDataSet:);
    }
    else if (status == SNSubscribeCenterServiceStatusFail) {
        selecor = @selector(didFailLoadDataWithDataSet:);
    }
    else if (status == SNSubscribeCenterServiceStatusCanceld) {
        selecor = @selector(didCancelLoadDataWithDataSet:);
    }
    
    SNDebugLog(@"%@-- _listenerArrayDic = %@", NSStringFromSelector(_cmd), _listenerArrayDic);
    SNDebugLog(@"%@-- operation type %d", NSStringFromSelector(_cmd), [dataSet operation]);
    @synchronized(_listenerArrayDic) {
        NSMutableArray *lsArray = [_listenerArrayDic objectForKey:[NSString stringWithFormat:@"%d", [dataSet operation]]];
        NSArray *_lsArray = [NSArray arrayWithArray:lsArray];
        for (id _delegate in _lsArray) {
            if ([_delegate respondsToSelector:selecor]) {
                SNDebugLog(@"perform callback to %@", _delegate);
                [_delegate performSelectorOnMainThread:selecor withObject:dataSet waitUntilDone:[NSThread isMainThread]];
            }
        }
    }
}

- (void)callBackBackgroundListenerWithRefId:(NSString *)refId operationType:(SCServiceOperationType)type status:(SNSubscribeCenterServiceStatus)status {
    // 后台callback
    if (_operationQueue) {
        
        SNDebugLog(@"--%@\n\n operation queue %@", NSStringFromSelector(_cmd), _operationQueue);
        SNSubscribeCenterOperation *opFinder = [[SNSubscribeCenterOperation alloc] init];
        opFinder.operationType = type;
        opFinder.subId = refId;
        
        @synchronized(_operationQueue) {
            NSInteger index = [_operationQueue indexOfObject:opFinder];
            if (index != NSNotFound) {
                SNSubscribeCenterOperation *operation = [_operationQueue objectAtIndex:index];
                SNDebugLog(@"--%@\n\n operation find %@", NSStringFromSelector(_cmd), operation);
                [operation fire:status == SNSubscribeCenterServiceStatusSuccess];
                [_operationQueue removeObject:operation];
            }
            else {
                SNDebugLog(@"--%@\n\n operation not found~!", NSStringFromSelector(_cmd));
            }
        }
        
        SNDebugLog(@"--%@\n\n after remove operation queue %@", NSStringFromSelector(_cmd), _operationQueue);
    }
}

@end
