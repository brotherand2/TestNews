//
//  SNLiveListModel.m
//  sohunews
//
//  Created by wang yanchen on 13-4-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveListModel.h"
//#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNDBManager.h"
#import "SNTimelineTrendObjects.h"
#import "SNSubscribeLiveRequest.h"
#import "SNSubHistoryListRequest.h"

typedef void (^LiveRefeshSuccessCallBack)(SNLiveListModel *listModel);
typedef void (^LiveRefeshFailureCallBack)(NSError *error);

@interface SNLiveListModel ()
@property (nonatomic, strong) SNSubscribeLiveRequest *subscribeLiveRequest;
@property (nonatomic, strong) SNSubHistoryListRequest *subHistoryLiveRequest;
@end

@implementation SNLiveDayObj
@synthesize liveDate = _liveDate, liveDateString, liveDay, lives;

- (void)dealloc {
     //(_liveDate);
     //(liveDateString);
     //(liveDay);
     //(lives);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"liveDay %@ \nliveDate %@ \nlives :\n%@", self.liveDay, self.liveDate, self.lives];
}

- (void)setLiveDate:(NSString *)liveDate {
    if (_liveDate != liveDate) {
         //(_liveDate);
        _liveDate = [liveDate copy];
        
        if (_liveDate.length > 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = TTCurrentLocale();
            formatter.dateFormat = @"MM月dd日";
            self.liveDateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_liveDate longLongValue] / 1000]];
        }
    }
}

@end

//////////////////////////////////////////////////////////////////////

@interface SNLiveListModel () {
//    SNURLRequest *_liveListRequest;
//    SNURLRequest *_liveHistoryRequest;
}

@property(nonatomic, strong) NSMutableArray *_focusLives;
@property(nonatomic, strong) NSMutableArray *_forecastLives;
@property(nonatomic, strong) NSMutableArray *_todayLives;
@property(nonatomic, strong) NSMutableArray *_historyLives;

@property(nonatomic, copy) NSString *_liveDate;
@property(nonatomic, copy) NSString *_liveDay;

- (LivingGameItem *)livingGameItemByDic:(NSDictionary *)dicInfo;
- (SNLiveDayObj *)livingDayItemByDic:(NSDictionary *)dicInfo;

@end

@implementation SNLiveListModel
@synthesize subId = _subId;
@synthesize _focusLives, _forecastLives, _todayLives, _historyLives;
@synthesize _liveDate, _liveDay;

- (id)initWithLiveSubId:(NSString *)subId {
    self = [super init];
    if (self) {
        self.subId = subId;
    }
    return self;
}

- (void)dealloc {
    [self cancelAllRequests];
    
     //(_liveListRequest);
     //(_liveHistoryRequest);
     //(_subId);
     //(_focusLives);
     //(_forecastLives);
     //(_todayLives);
     //(_historyLives);
    
     //(_liveDay);
     //(_liveDate);
}

#pragma mark - public

//- (void)refreshLiveListWithSuccess:(void (^)(SNLiveListModel *))success failure:(void (^)(NSError *))failure {
//    if (_liveListRequest && _liveListRequest.isLoading) {
//        SNDebugLog(@"%@->%@ : already a request for subId %@ is running !",
//                   NSStringFromClass([self class]),
//                   NSStringFromSelector(_cmd),
//                   self.subId);
//        return;
//    }
//    
//    if (!_liveListRequest) {
//        NSString *urlStr = [NSString stringWithFormat:SNLinks_Path_Live_Subscribe, self.subId];
//        _liveListRequest = [SNURLRequest requestWithURL:urlStr delegate:self];
//        _liveListRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
//        _liveListRequest.timeOut = 30;
//        _liveListRequest.response = [[SNURLJSONResponse alloc] init];
//        _liveListRequest.isShowNoNetWorkMessage = YES;
//    }
//    
//    LiveRefeshSuccessCallBack successCB = [success copy];
//    LiveRefeshFailureCallBack failureCB = [failure copy];
//    
//    NSDictionary *cbDic = @{@"success" : (successCB ? (id)successCB : [NSNull null]),
//                            @"failure" : (failureCB ? (id)failureCB : [NSNull null])};
//    
//    _liveListRequest.userInfo = cbDic;
//    
//     //(successCB);
//     //(failureCB);
//    
//    [_liveListRequest send];
//}

- (void)refreshLiveListWithSuccess:(void (^)(SNLiveListModel *))success failure:(void (^)(NSError *))failure {
    if (_subscribeLiveRequest) {
        return;
    }
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    _subscribeLiveRequest = [[SNSubscribeLiveRequest alloc] initWithDictionary:@{@"subId":self.subId}];
    __weak typeof(self)weakself = self;
    [_subscribeLiveRequest send:^(SNBaseRequest *request, id rootObj) {
        _subscribeLiveRequest = nil;
        weakself._focusLives = [NSMutableArray array];
        weakself._forecastLives = [NSMutableArray array];
        weakself._todayLives = [NSMutableArray array];
        weakself._historyLives = [NSMutableArray array];
        
        BOOL bRetSuccess = NO;
        
        if (rootObj && [rootObj isKindOfClass:[NSDictionary class]]) {
            NSArray *focusArrayObj = [rootObj arrayValueForKey:@"focusLives" defaultValue:nil];
            NSArray *todayArrayObj = [rootObj arrayValueForKey:@"todayLives" defaultValue:nil];
            NSArray *foreArrayObj = [rootObj arrayValueForKey:@"foreLives" defaultValue:nil];
            NSArray *histArrayObj = [rootObj arrayValueForKey:@"historyLives" defaultValue:nil];
            
            // 解析shareRead 字段
            NSDictionary *shareReadDic = [rootObj dictionaryValueForKey:@"shareRead" defalutValue:nil];
            if (shareReadDic) {
                SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareReadDic];
                if (obj) [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypeLiveChannel contentId:weakself.subId];
            }
            
            weakself._liveDate = [rootObj stringValueForKey:@"liveDate" defaultValue:nil];
            weakself._liveDay = [rootObj stringValueForKey:@"liveDay" defaultValue:nil];
            
            // 焦点直播
            for (NSDictionary *dicInfo in focusArrayObj) {
                LivingGameItem *aGame = [weakself livingGameItemByDic:dicInfo];
                if (aGame) {
                    aGame.isToday = @"1";
                    aGame.isFocus = @"1";
                    [weakself._focusLives addObject:aGame];
                }
            }
            // 今日直播
            for (NSDictionary *dicInfo in todayArrayObj) {
                LivingGameItem *aGame = [weakself livingGameItemByDic:dicInfo];
                if (aGame) {
                    aGame.isToday = @"1";
                    aGame.isFocus = @"0";
                    [weakself._todayLives addObject:aGame];
                }
            }
            // 直播预告 数据结构不一样
            for (NSDictionary *dicInfo in foreArrayObj) {
                SNLiveDayObj *aDayLiveObj = [weakself livingDayItemByDic:dicInfo];
                if (aDayLiveObj.lives) [weakself._forecastLives addObjectsFromArray:aDayLiveObj.lives];
            }
            // 3.8增加往期
            for (NSDictionary *dicInfo in histArrayObj) {
                SNLiveDayObj *aDayLiveObj = [weakself livingDayItemByDic:dicInfo];
                if (aDayLiveObj.lives) [weakself._historyLives addObjectsFromArray:aDayLiveObj.lives];
            }
            
            bRetSuccess = YES;
        }
        
        if (bRetSuccess) {
            if (success) success(weakself);
        }
        else {
            if (failure) failure([NSError errorWithDomain:@"wrong return data" code:-1 userInfo:nil]);
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        _subscribeLiveRequest = nil;
        if (failure) failure(error);
    }];
}

//- (void)refreshHistoryListWithSuccess:(void (^)(SNLiveListModel *))success failure:(void (^)(NSError *))failure {// ?subId=%@
//    if (_liveHistoryRequest && _liveHistoryRequest.isLoading) {
//        SNDebugLog(@"%@->%@ : already a request for subId %@ is running !",
//                   NSStringFromClass([self class]),
//                   NSStringFromSelector(_cmd),
//                   self.subId);
//        return;
//    }
//    
//    if (!_liveHistoryRequest) {
//        NSString *urlStr = [NSString stringWithFormat:SNLinks_Path_Live_SubHistory, self.subId];
//        _liveHistoryRequest = [SNURLRequest requestWithURL:urlStr delegate:self];
//        _liveHistoryRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
//        _liveHistoryRequest.timeOut = 30;
//        _liveHistoryRequest.response = [[SNURLJSONResponse alloc] init];
//        _liveHistoryRequest.isShowNoNetWorkMessage = YES;
//    }
//    
//    LiveRefeshSuccessCallBack successCB = [success copy];
//    LiveRefeshFailureCallBack failureCB = [failure copy];
//    
//    NSDictionary *cbDic = @{@"success" : (successCB ? (id)successCB : [NSNull null]),
//                            @"failure" : (failureCB ? (id)failureCB : [NSNull null])};
//    
//    _liveHistoryRequest.userInfo = cbDic;
//    
//     //(successCB);
//     //(failureCB);
//    
//    [_liveHistoryRequest send];
//}

- (void)refreshHistoryListWithSuccess:(void (^)(SNLiveListModel *))success failure:(void (^)(NSError *))failure {
    if (_subHistoryLiveRequest) {
        return;
    }
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    _subHistoryLiveRequest = [[SNSubHistoryListRequest alloc] initWithDictionary:@{@"subId":self.subId}];
    __weak typeof(self)weakself = self;
    [_subHistoryLiveRequest send:^(SNBaseRequest *request, id rootObj) {
        
        _subHistoryLiveRequest = nil;
        weakself._historyLives = [NSMutableArray array];
        
        BOOL bRetSuccess = NO;

        if (rootObj && [rootObj isKindOfClass:[NSDictionary class]]) {
            NSArray *historyLiveObjs = [rootObj arrayValueForKey:@"historyLives" defaultValue:nil];
            for (NSDictionary *dicInfo in historyLiveObjs) {
                SNLiveDayObj *aDayLiveObj = [self livingDayItemByDic:dicInfo];
                if (aDayLiveObj) [weakself._historyLives addObject:aDayLiveObj];
            }
            bRetSuccess = YES;
        }
        
        if (bRetSuccess) {
            if (success) success(self);
        }
        else {
            if (failure) failure([NSError errorWithDomain:@"wrong return data" code:-1 userInfo:nil]);
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        _subHistoryLiveRequest = nil;
        if (failure) failure(error);
    }];
}

- (NSArray *)focusLives {
    if (self._focusLives)
        return [NSArray arrayWithArray:self._focusLives];
    else
        return nil;
}

- (NSArray *)forecastLives {
    if (self._forecastLives)
        return [NSArray arrayWithArray:self._forecastLives];
    else
        return nil;
}

- (NSArray *)todayLives {
    if (self._todayLives)
        return [NSArray arrayWithArray:self._todayLives];
    else
        return nil;
}

- (NSArray *)historyLives {
    if (self._historyLives)
        return [NSArray arrayWithArray:self._historyLives];
    else
        return nil;
}

- (NSString *)liveDate {
    return self._liveDate;
}

- (NSString *)liveDay {
    return self._liveDay;
}

- (void)cancelAllRequests {
//    if (_liveListRequest) {
//        [_liveListRequest.delegates removeObject:self];
//        [_liveListRequest cancel];
//         //(_liveListRequest);
//    }
//    
//    if (_liveHistoryRequest) {
//        [_liveHistoryRequest.delegates removeObject:self];
//        [_liveHistoryRequest cancel];
//         //(_liveHistoryRequest);
//    }
}

//#pragma mark - TTURLRequestDelegate
//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//    if (request == _liveListRequest) {
//        self._focusLives = [NSMutableArray array];
//        self._forecastLives = [NSMutableArray array];
//        self._todayLives = [NSMutableArray array];
//        self._historyLives = [NSMutableArray array];
//        
//        LiveRefeshSuccessCallBack successCB = [request.userInfo objectForKey:@"success"];
//        LiveRefeshFailureCallBack failureCB = [request.userInfo objectForKey:@"failure"];
//        
//        BOOL bRetSuccess = NO;
//        SNURLJSONResponse *json = request.response;
//        NSDictionary *rootObj = json.rootObject;
//        if (rootObj && [rootObj isKindOfClass:[NSDictionary class]]) {
//            NSArray *focusArrayObj = [rootObj arrayValueForKey:@"focusLives" defaultValue:nil];
//            NSArray *todayArrayObj = [rootObj arrayValueForKey:@"todayLives" defaultValue:nil];
//            NSArray *foreArrayObj = [rootObj arrayValueForKey:@"foreLives" defaultValue:nil];
//            NSArray *histArrayObj = [rootObj arrayValueForKey:@"historyLives" defaultValue:nil];
//            
//            // 解析shareRead 字段
//            NSDictionary *shareReadDic = [rootObj dictionaryValueForKey:@"shareRead" defalutValue:nil];
//            if (shareReadDic) {
//                SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareReadDic];
//                if (obj) [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypeLiveChannel contentId:self.subId];
//            }
//            
//            self._liveDate = [rootObj stringValueForKey:@"liveDate" defaultValue:nil];
//            self._liveDay = [rootObj stringValueForKey:@"liveDay" defaultValue:nil];
//           
//            // 焦点直播
//            for (NSDictionary *dicInfo in focusArrayObj) {
//                LivingGameItem *aGame = [self livingGameItemByDic:dicInfo];
//                if (aGame) {
//                    aGame.isToday = @"1";
//                    aGame.isFocus = @"1";
//                    [self._focusLives addObject:aGame];
//                }
//            }
//            // 今日直播
//            for (NSDictionary *dicInfo in todayArrayObj) {
//                LivingGameItem *aGame = [self livingGameItemByDic:dicInfo];
//                if (aGame) {
//                    aGame.isToday = @"1";
//                    aGame.isFocus = @"0";
//                    [self._todayLives addObject:aGame];
//                }
//            }
//            // 直播预告 数据结构不一样
//            for (NSDictionary *dicInfo in foreArrayObj) {
//                SNLiveDayObj *aDayLiveObj = [self livingDayItemByDic:dicInfo];
//                if (aDayLiveObj.lives) [self._forecastLives addObjectsFromArray:aDayLiveObj.lives];
//            }
//            // 3.8增加往期
//            for (NSDictionary *dicInfo in histArrayObj) {
//                SNLiveDayObj *aDayLiveObj = [self livingDayItemByDic:dicInfo];
//                if (aDayLiveObj.lives) [self._historyLives addObjectsFromArray:aDayLiveObj.lives];
//            }
//            
//            bRetSuccess = YES;
//        }
//        
//        if (bRetSuccess) {
//            if (successCB) successCB(self);
//        }
//        else {
//            if (failureCB) failureCB([NSError errorWithDomain:@"wrong return data" code:-1 userInfo:nil]);
//        }
//    }
//    else if (request == _liveHistoryRequest) {
//        self._historyLives = [NSMutableArray array];
//        LiveRefeshSuccessCallBack successCB = [request.userInfo objectForKey:@"success"];
//        LiveRefeshFailureCallBack failureCB = [request.userInfo objectForKey:@"failure"];
//        
//        BOOL bRetSuccess = NO;
//        SNURLJSONResponse *json = request.response;
//        NSDictionary *rootObj = json.rootObject;
//        if (rootObj && [rootObj isKindOfClass:[NSDictionary class]]) {
//            NSArray *historyLiveObjs = [rootObj arrayValueForKey:@"historyLives" defaultValue:nil];
//            for (NSDictionary *dicInfo in historyLiveObjs) {
//                SNLiveDayObj *aDayLiveObj = [self livingDayItemByDic:dicInfo];
//                if (aDayLiveObj) [self._historyLives addObject:aDayLiveObj];
//            }
//            bRetSuccess = YES;
//        }
//        
//        if (bRetSuccess) {
//            if (successCB) successCB(self);
//        }
//        else {
//            if (failureCB) failureCB([NSError errorWithDomain:@"wrong return data" code:-1 userInfo:nil]);
//        }
//    }
//}
//
//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
//    LiveRefeshFailureCallBack failureCB = [request.userInfo objectForKey:@"failure"];
//    if (failureCB) failureCB(error);
//}

//- (void)requestDidCancelLoad:(TTURLRequest*)request {
//    LiveRefeshFailureCallBack failureCB = [request.userInfo objectForKey:@"failure"];
//    if (failureCB) failureCB([NSError errorWithDomain:@"request canceled" code:-1 userInfo:nil]);
//}

#pragma mark - private

- (LivingGameItem *)livingGameItemByDic:(NSDictionary *)dicInfo {
    if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
        LivingGameItem *aGame = [[LivingGameItem alloc] init];
        aGame.liveType = [dicInfo objectForKey:@"liveType" defalutObj:@""];
        aGame.liveCat = [dicInfo objectForKey:@"subsName" defalutObj:@""];
        aGame.liveSubCat = [dicInfo objectForKey:@"liveSubCat" defalutObj:@"赛事"];
        aGame.liveId = [dicInfo objectForKey:@"liveId" defalutObj:@""];
        aGame.title = [dicInfo objectForKey:@"title" defalutObj:@""];
        aGame.status = [dicInfo objectForKey:@"status" defalutObj:@""];
        aGame.isHot = [dicInfo objectForKey:@"isHot" defalutObj:@""];
        aGame.liveTime = [dicInfo objectForKey:@"liveTime" defalutObj:@""];
        aGame.mediaType = [dicInfo intValueForKey:@"mediaType" defaultValue:0];
        
        aGame.visitorId = [dicInfo objectForKey:@"vistorId" defalutObj:@""];
        aGame.visitorName = [dicInfo objectForKey:@"vistorName" defalutObj:@""];
        aGame.visitorPic = [dicInfo objectForKey:@"vistorPic" defalutObj:@""];
        aGame.visitorInfo = [dicInfo objectForKey:@"vistorInfo" defalutObj:@""];
        aGame.visitorTotal = [dicInfo objectForKey:@"vistorTotal" defalutObj:@""];
        
        aGame.hostId = [dicInfo objectForKey:@"hostId" defalutObj:@""];
        aGame.hostName = [dicInfo objectForKey:@"hostName" defalutObj:@""];
        aGame.hostPic = [dicInfo objectForKey:@"hostPic" defalutObj:@""];
        aGame.hostInfo = [dicInfo objectForKey:@"hostInfo" defalutObj:@""];
        aGame.hostTotal = [dicInfo objectForKey:@"hostTotal" defalutObj:@""];
        
        aGame.livePic = [dicInfo objectForKey:@"livePic" defalutObj:@""];
        
        aGame.liveDay = [dicInfo objectForKey:@"liveDay" defalutObj:@""];
        aGame.liveDate = [dicInfo objectForKey:@"liveDate" defalutObj:@""];
        
        return aGame;
    }
    
    return nil;
}

- (SNLiveDayObj *)livingDayItemByDic:(NSDictionary *)dicInfo {
    if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
        SNLiveDayObj *aDayObj = [[SNLiveDayObj alloc] init];
        aDayObj.liveDate = [dicInfo stringValueForKey:@"liveDate" defaultValue:@""];
        aDayObj.liveDay = [dicInfo stringValueForKey:@"liveDay" defaultValue:@""];
        NSArray *lives = [dicInfo arrayValueForKey:@"lives" defaultValue:nil];
        for (NSDictionary *dic in lives) {
            LivingGameItem *aGame = [self livingGameItemByDic:dic];
            if (aGame) {
                aGame.isFocus = @"0";
                aGame.isToday = @"0";
                if (!aDayObj.lives) {
                    aDayObj.lives = [NSMutableArray array];
                }
                [aDayObj.lives addObject:aGame];
            }
        }
        return aDayObj;
    }
    return nil;
}

@end
