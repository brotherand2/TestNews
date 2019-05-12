//
//  SNNewsVoteService.m
//  sohunews
//
//  Created by wang yanchen on 12-10-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNNewsVoteService.h"
#import "SNURLRequest.h"
#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNURLDataResponse.h"
#import "CacheObjects.h"
#import "SNDBManager.h"
#import "NSObject+YAJL.h"

#define kRequestTopicVoteDetail             (@"voteDetail")
#define kRequestTopicVoteSubmit             (@"voteSubmit")
#define kRequestTopicVoteRealTime           (@"voteRealTime")

@interface SNNewsVoteService () {
    SNURLRequest *_voteDetailRequest;
    SNURLRequest *_voteSubmitRequest;
    SNURLRequest *_voteRealTimeRequest;
}

@property(nonatomic, strong) SNURLRequest *voteDetailRequest;
@property(nonatomic, strong) SNURLRequest *voteSubmitRequest;
@property(nonatomic, strong) SNURLRequest *voteRealTimeRequest;

- (void)_refreshVoteDetail;
- (SNNewsVotesInfo *)_parseRealtimeVotesInfo:(NSDictionary *)realtimeJson;

@end

@implementation SNNewsVoteService
@synthesize newsID = _newsID;
@synthesize topicID = _topicID;
@synthesize delegate = _delegate;
@synthesize votesInfo = _votesInfo;
@synthesize voteDetailRequest = _voteDetailRequest;
@synthesize voteSubmitRequest = _voteSubmitRequest;
@synthesize voteRealTimeRequest = _voteRealTimeRequest;

- (id)initWithNewsId:(NSString *)newsId {
    self = [super init];
    if (self) {
        self.newsID = newsId;
    }
    return self;
}

- (void)dealloc {
     //(_newsID);
     //(_topicID);
     //(_votesInfo);
     //(_voteDetailRequest);
     //(_voteSubmitRequest);
     //(_voteRealTimeRequest);
}

#pragma mark - public methods
- (void)refreshVoteDetail {
    [self performSelector:@selector(_refreshVoteDetail)];
}

- (void)submitVotesWithTopicID:(NSString *)topicID newsID:(NSString *)newsID voteInfoString:(NSString *)voteInfoStr {
    if ([topicID length] == 0 ||
        [newsID length] == 0 ||
        [voteInfoStr length] == 0) {
        SNDebugLog(@"submitVotesWithTopicID : invalidte arguments!");
        return;
    }
    
    self.voteSubmitRequest = [SNURLRequest requestWithURL:[NSString stringWithFormat:kVoteSubmitUrl, topicID, newsID, voteInfoStr] delegate:self];
    _voteSubmitRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    _voteSubmitRequest.userInfo = [TTUserInfo topic:kRequestTopicVoteSubmit strongRef:nil weakRef:nil];
    _voteSubmitRequest.response = [[SNURLDataResponse alloc] init];
    [_voteSubmitRequest send];
}

- (void)refreshVotesRealTimeInfo:(NSString *)topicID newsID:(NSString *)newsID {
    if ([topicID length] == 0 || [newsID length] == 0) {
        SNDebugLog(@"refreshVotesRealTimeInfo : invalidate argument!");
        return;
    }
    self.topicID = topicID;
    self.voteRealTimeRequest = [SNURLRequest requestWithURL:[NSString stringWithFormat:kVoteRealTimerUrl, topicID, newsID] delegate:self];
    _voteRealTimeRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    _voteRealTimeRequest.userInfo = [TTUserInfo topic:kRequestTopicVoteRealTime strongRef:nil weakRef:nil];
    _voteRealTimeRequest.response = [[SNURLDataResponse alloc] init];
    
    [_voteRealTimeRequest send];
}

- (void)cancel {
    if (_voteRealTimeRequest && [_voteRealTimeRequest isLoading]) {
        [_voteRealTimeRequest cancel];
    }
    if (_voteDetailRequest && [_voteDetailRequest isLoading]) {
        [_voteDetailRequest cancel];
    }
    // todo 要不要取消已经提交的投票请求？
    if (_voteSubmitRequest && [_voteSubmitRequest isLoading]) {
        [_voteSubmitRequest cancel];
    }
}

#pragma mark - methods for class
+ (NSString *)getVotesXMLFromData:(NSData *)data {
    if (data == nil || [data length] == 0) {
        return @"";
    }
    
    NSString *rootXML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange start = [rootXML rangeOfString:@"<votes>" options:NSCaseInsensitiveSearch];
    if (start.location == NSNotFound) {
        return @"";
    }
    NSRange end = [rootXML rangeOfString:@"</votes>" options:NSCaseInsensitiveSearch | NSBackwardsSearch];
    if (end.location == NSNotFound) {
        return @"";
    }
    if (start.location >= end.location) {
        return @"";
    }
    NSRange voteXMLRange = {start.location, end.location + end.length - start.location};
    return [rootXML substringWithRange:voteXMLRange];
}

+ (SNNewsVotesInfo *)votesInfoFromXMLElement:(TBXMLElement *)rootElement {
    if (rootElement == nil) {
        SNDebugLog(@"votesInfoFromXMLElement : invalidate argument!");
        return nil;
    }
    
    SNNewsVotesInfo *votesInfo = [[SNNewsVotesInfo alloc] init];
    
    votesInfo.topicId = [TBXML textForElement:[TBXML childElementNamed:kVoteTopicId parentElement:rootElement]];
    
    votesInfo.startTime = [TBXML textForElement:[TBXML childElementNamed:kVoteStartTime parentElement:rootElement]];
    
    votesInfo.endTime = [TBXML textForElement:[TBXML childElementNamed:kVoteEndTime parentElement:rootElement]];
    
    votesInfo.viewResultCond = [TBXML textForElement:[TBXML childElementNamed:kVoteViewResultCond parentElement:rootElement]];
    
    votesInfo.isRandomOrdered = [TBXML textForElement:[TBXML childElementNamed:kVoteIsRandomOrdered parentElement:rootElement]];
    
    votesInfo.voteTotal = [TBXML textForElement:[TBXML childElementNamed:kVoteVoteTotal parentElement:rootElement]];
    
    votesInfo.isOver = [TBXML textForElement:[TBXML childElementNamed:kVoteIsOver parentElement:rootElement]];
    
    votesInfo.isShowDetail = [TBXML textForElement:[TBXML childElementNamed:kVoteIsShowDetail parentElement:rootElement]];
    
    //<vote>
    NSMutableArray* votesList = [NSMutableArray array];
    
    TBXMLElement *voteItemElem = [TBXML childElementNamed:kVoteItem parentElement:rootElement];
    
    if (voteItemElem) {
        SNNewsVoteItem *voteItem = [self parseNewsVoteItemFromXMLElement:voteItemElem];
        
        [votesList addObject:voteItem];
        
        while ((voteItemElem = [TBXML nextSiblingNamed:kVoteItem searchFromElement:voteItemElem]) != nil) {
            
            SNNewsVoteItem *voteItem = [self parseNewsVoteItemFromXMLElement:voteItemElem];
            
            [votesList addObject:voteItem];
        }
    }
    
    votesInfo.voteArray = votesList;
    
    votesInfo.isVoted = [votesInfo hasMyVote] ? @"1" : @"0";
    
    return votesInfo;
}

+ (SNNewsVoteItem *)parseNewsVoteItemFromXMLElement:(TBXMLElement *)voteItemElem {
    if (voteItemElem == nil) {
        SNDebugLog(@"parseNewsVoteItemFromXMLElement : invalidate argument!");
        return nil;
    }
    
    SNNewsVoteItem *voteItem = [[SNNewsVoteItem alloc] init];
    
    voteItem.voteId = [TBXML textForElement:[TBXML childElementNamed:kVoteItemId parentElement:voteItemElem]];
    
    voteItem.content = [TBXML textForElement:[TBXML childElementNamed:kVoteItemContent parentElement:voteItemElem]];
    
    voteItem.voteType = [TBXML textForElement:[TBXML childElementNamed:kVoteItemVoteType parentElement:voteItemElem]];
    
    voteItem.postion = [TBXML textForElement:[TBXML childElementNamed:kVoteItemPosition parentElement:voteItemElem]];
    
    voteItem.minVoteNum = [TBXML textForElement:[TBXML childElementNamed:kVoteItemMinVoteNum parentElement:voteItemElem]];
    
    voteItem.maxVoteNum = [TBXML textForElement:[TBXML childElementNamed:kVoteItemMaxVoteNum parentElement:voteItemElem]];
    
    //<option>
    NSMutableArray* optionList = [NSMutableArray array];
    
    TBXMLElement *optionElem = [TBXML childElementNamed:kVoteItemOption parentElement:voteItemElem];
    
    if (optionElem) {
        SNNewsVoteItemOption *optionItem = [[SNNewsVoteItemOption alloc] init];
        
        optionItem.optionId = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionId parentElement:optionElem]];
        optionItem.name = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionName parentElement:optionElem]];
        optionItem.position = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionPos parentElement:optionElem]];
        optionItem.picPath = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionPic parentElement:optionElem]];
        optionItem.smallPicPath = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionSmallPic parentElement:optionElem]];
        optionItem.optionDesc = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionDesc parentElement:optionElem]];
        optionItem.type = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionType parentElement:optionElem]];
        
        [optionList addObject:optionItem];
        
        while ((optionElem = [TBXML nextSiblingNamed:kVoteItemOption searchFromElement:optionElem]) != nil) {
            
            SNNewsVoteItemOption *optionItem = [[SNNewsVoteItemOption alloc] init];
            
            optionItem.optionId = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionId parentElement:optionElem]];
            optionItem.name = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionName parentElement:optionElem]];
            optionItem.position = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionPos parentElement:optionElem]];
            optionItem.picPath = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionPic parentElement:optionElem]];
            optionItem.smallPicPath = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionSmallPic parentElement:optionElem]];
            optionItem.optionDesc = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionDesc parentElement:optionElem]];
            optionItem.type = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionType parentElement:optionElem]];
            
            [optionList addObject:optionItem];
        }
        
    }
    //</option>
    voteItem.optionArray = optionList;
    
    return voteItem;
}

+ (SNNewsVotesInfo *)parseVoteDetailData:(id)jsonObj {
    SNNewsVotesInfo *votesInfo = nil;
    if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataInfo = jsonObj;
        NSString *value = nil;
        votesInfo = [[SNNewsVotesInfo alloc] init];
        
        value = [dataInfo objectForKey:kVoteTopicId];
        if (value) votesInfo.topicId = value;
        
        value = [dataInfo objectForKey:kVoteStartTime];
        if (value) votesInfo.startTime = value;
        
        value = [dataInfo objectForKey:kVoteEndTime];
        if (value) votesInfo.endTime = value;
        
        value = [dataInfo objectForKey:kVoteViewResultCond];
        if (value) votesInfo.viewResultCond = value;
        
        value = [dataInfo objectForKey:kVoteIsRandomOrdered];
        if (value) votesInfo.isRandomOrdered = value;
        
        value = [dataInfo objectForKey:kVoteVoteTotal];
        if (value) votesInfo.voteTotal = value;
        
        // <vote>
        id voteObj = [dataInfo objectForKey:kVoteItem];
        if (voteObj && [voteObj isKindOfClass:[NSArray class]]) {
            NSArray *votes = voteObj;
            NSMutableArray *votesList = [NSMutableArray array];
            for (id oneVoteObj in votes) {
                if ([oneVoteObj isKindOfClass:[NSDictionary class]]) {
                    SNNewsVoteItem *item = [self parseOneVote:oneVoteObj];
                    if (item) [votesList addObject:item];
                }
            }
            
            votesInfo.voteArray = votesList;
        }
    }
    return votesInfo;
}

+ (SNNewsVoteItem *)parseOneVote:(id)aVote {
    SNNewsVoteItem *oneVoteItem = nil;
    if ([aVote isKindOfClass:[NSDictionary class]]) {
        NSDictionary *aVoteInfo = aVote;
        NSString *value = nil;
        oneVoteItem = [[SNNewsVoteItem alloc] init];
        
        value = [aVoteInfo objectForKey:kVoteItemId];
        if (value) oneVoteItem.voteId = value;
        
        value = [aVoteInfo objectForKey:kVoteItemContent];
        if (value) oneVoteItem.content = value;
        
        value = [aVoteInfo objectForKey:kVoteItemVoteType];
        if (value) oneVoteItem.voteType = value;
        
        value = [aVoteInfo objectForKey:kVoteItemPosition];
        if (value) oneVoteItem.postion = value;
        
        value = [aVoteInfo objectForKey:kVoteItemMinVoteNum];
        if (value) oneVoteItem.minVoteNum = value;
        
        value = [aVoteInfo objectForKey:kVoteItemMaxVoteNum];
        if (value) oneVoteItem.maxVoteNum = value;
        
        // <option>
        id optionObj = [aVoteInfo objectForKey:kVoteItemOption];
        if (optionObj && [optionObj isKindOfClass:[NSArray class]]) {
            NSArray *optios = optionObj;
            NSMutableArray *optiosList = [NSMutableArray array];
            for (id oneOption in optios) {
                if (oneOption && [oneOption isKindOfClass:[NSDictionary class]]) {
                    SNNewsVoteItemOption *option = [self parseOneOption:oneOption];
                    if (option) [optiosList addObject:option];
                }
            }
            
            oneVoteItem.optionArray = optiosList;
        }
    }
    return oneVoteItem;
}

+ (SNNewsVoteItemOption *)parseOneOption:(id)aOption {
    SNNewsVoteItemOption *oneOption = nil;
    if (aOption && [aOption isKindOfClass:[NSDictionary class]]) {
        NSDictionary *optionInfo = aOption;
        NSString *value = nil;
        oneOption = [[SNNewsVoteItemOption alloc] init];
        
        value = [optionInfo objectForKey:kVoteItemOptionId];
        if (value) oneOption.optionId = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionName];
        if (value) oneOption.name = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionPos];
        if (value) oneOption.position = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionDesc];
        if (value) oneOption.optionDesc = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionType];
        if (value) oneOption.type = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionPic];
        if (value) oneOption.picPath = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionSmallPic];
        if (value) oneOption.smallPicPath = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionIsMyVote];
        if (value) oneOption.isMyVote = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionVoteTotal];
        if (value) oneOption.optVoteTotal = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionPersent];
        if (value) oneOption.optPersent = value;
        
        value = [optionInfo objectForKey:kVoteItemOptionMsg];
        if (value) oneOption.myMsg = value;
    }
    return oneOption;
}

+ (SNNewsVotesInfo *)votesInfoFromLocalDBByNewsID:(NSString *)newsID {
    if (nil == newsID || [newsID length] == 0) {
        SNDebugLog(@"votesInfoFromLocalDBByNewsID : invalidate argument!");
        return nil;
    }
    SNNewsVotesInfo *votesInfo = nil;
    VotesInfo *voteObj = [[SNDBManager currentDataBase] getVotesInfoByNewsID:newsID];
    if (voteObj) {
        BOOL isXML = [[voteObj.voteXML trim] startWith:@"<"];
        // parse xml
        if (isXML) {
            TBXML *xmlObj = [TBXML tbxmlWithXMLString:voteObj.voteXML];
            if (xmlObj &&xmlObj.rootXMLElement) {
                votesInfo = [self votesInfoFromXMLElement:xmlObj.rootXMLElement];
            }
        } else {
            // parse json
            NSData *jsonData = [voteObj.voteXML dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            id jsonObj = [jsonData yajl_JSON:&error];
            if (error == nil && [jsonObj isKindOfClass:[NSDictionary class]]) {
                id voteDetailObj = [(NSDictionary *)jsonObj objectForKey:@"detail"];
                votesInfo = [self parseVoteDetailData:voteDetailObj];
            }
            if (votesInfo) {
                votesInfo.isVoted = voteObj.isVoted;
                votesInfo.isOver = voteObj.isOver;
            }
        }
    }
    
    return votesInfo;
}

#pragma mark - TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    TTUserInfo *userInfo = request.userInfo;
    if ([userInfo.topic isEqualToString:kRequestTopicVoteDetail]) {
        SNURLDataResponse *data = request.response;
        SNDebugLog(@"data to string  = %@", [NSString stringWithUTF8String:[data.data bytes]]);
        NSError *error = nil;
        id jsonObj = [data.data yajl_JSON:&error];
        if (nil == error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            SNNewsVotesInfo *votesInfo = [[self class] parseVoteDetailData:jsonObj];
            if (votesInfo) {
                SNNewsVotesInfo *votesInfoDB = [[self class] votesInfoFromLocalDBByNewsID:self.newsID];
                if (votesInfoDB) votesInfo.isVoted = votesInfoDB.isVoted;
            }
            if ([_delegate respondsToSelector:@selector(voteDetailDidFinishLoad:)]) {
                [_delegate voteDetailDidFinishLoad:votesInfo];
            }
        }
    }
    else if ([userInfo.topic isEqualToString:kRequestTopicVoteSubmit]) {
        SNURLDataResponse *data = request.response;
        SNDebugLog(@"data to string  = %@", [NSString stringWithUTF8String:[data.data bytes]]);
        NSError *error = nil;
        id jsonObj = [data.data yajl_JSON:&error];
        if (error == nil && jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataInfo = jsonObj;
            NSString *status = [dataInfo objectForKey:@"status"];
            if ([@"200" isEqualToString:status]) {
                SNNewsVotesInfo *votesInfo = nil;
                NSDictionary *details = [dataInfo objectForKey:@"detail"];
                if (details) {
                    NSString *value = nil;
                    votesInfo = [[self class] parseVoteDetailData:details];
                    if (votesInfo) votesInfo.isVoted = @"1";
                    
                    VotesInfo *votesInfoObj = [[VotesInfo alloc] init];
                    votesInfoObj.newsID = self.newsID;
                    
                    value = [details objectForKey:kVoteTopicId];
                    if (value) votesInfoObj.topicID = value;
                    votesInfoObj.isVoted = @"1";
                    NSString *voteXml = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
                    if ([voteXml length]) {
                        votesInfoObj.voteXML = voteXml;
                        [[SNDBManager currentDataBase] addOrUpdateOneVoteInfo:votesInfoObj];
                    }
                }
                
                if (votesInfo == nil) {
                    votesInfo = [[self class] votesInfoFromLocalDBByNewsID:self.newsID];
                }
                
                if ([_delegate respondsToSelector:@selector(voteSubmitDidFinishLoad:)]) {
                    [_delegate voteSubmitDidFinishLoad:votesInfo];
                }
            }
            else {
                if ([_delegate respondsToSelector:@selector(voteSubmitDidFailWithErrorCode:errorMsg:)]) {
                    [_delegate voteSubmitDidFailWithErrorCode:[status intValue] errorMsg:[dataInfo objectForKey:@"msg"]];
                }
            }
        }
    }
    else if ([userInfo.topic isEqualToString:kRequestTopicVoteRealTime]) {
        SNURLDataResponse *data = request.response;
        SNDebugLog(@"data to string  = %@", [NSString stringWithUTF8String:[data.data bytes]]);
        NSError *error = nil;
        id jsonObj = [data.data yajl_JSON:&error];
        if (error == nil && jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataInfo = jsonObj;
            // 解析实时
            SNNewsVotesInfo *votesInfo = [self _parseRealtimeVotesInfo:dataInfo];
            votesInfo.isVoted = [votesInfo hasMyVote] ? @"1" : @"0";
            
            NSDictionary *details = [dataInfo objectForKey:@"detail"];
            // 如果有detail update一下db
            if (details) {
                NSString *value = nil;
                VotesInfo *votesInfoObj = [[VotesInfo alloc] init];
                votesInfoObj.newsID = self.newsID;
                
                value = [details objectForKey:kVoteTopicId];
                if (value) votesInfoObj.topicID = value;
                
                value = [dataInfo objectForKey:kVoteIsOver];
                if (value) votesInfoObj.isOver = value;
                
                if (votesInfo.isVoted) votesInfoObj.isVoted = votesInfo.isVoted;
                
                NSString *voteXml = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
                if ([voteXml length]) {
                    votesInfoObj.voteXML = voteXml;
                    [[SNDBManager currentDataBase] addOrUpdateOneVoteInfo:votesInfoObj];
                }
            }
            if ([_delegate respondsToSelector:@selector(voteRealTimeInfoDidFinishLoad:)]) {
                [_delegate voteRealTimeInfoDidFinishLoad:votesInfo];
            }
        }
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    TTUserInfo *userInfo = request.userInfo;
    if ([userInfo.topic isEqualToString:kRequestTopicVoteDetail]) {
    }
    else if ([userInfo.topic isEqualToString:kRequestTopicVoteSubmit]) {
        if ([_delegate respondsToSelector:@selector(voteSubmitDidFailWithErrorCode:errorMsg:)]) {
            [_delegate voteSubmitDidFailWithErrorCode:SNNewsVoteSubmitErrNetworkError errorMsg:@""];
        }
    }
    else if ([userInfo.topic isEqualToString:kRequestTopicVoteRealTime]) {
        if ([_delegate respondsToSelector:@selector(voteRealTimeInfoDidFail)]) {
            [_delegate voteRealTimeInfoDidFail];
        }
    }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    
}

#pragma mark - private methods
- (void)_refreshVoteDetail {
    @autoreleasepool {
        NSString *requestUrl = [NSString stringWithFormat:kVotesDetailUrl, self.newsID];
        self.voteDetailRequest = [SNURLRequest requestWithURL:requestUrl delegate:self];
        _voteDetailRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
        _voteDetailRequest.response = [[SNURLDataResponse alloc] init];
        _voteDetailRequest.userInfo = [TTUserInfo topic:kRequestTopicVoteDetail strongRef:nil weakRef:nil];
        
        [_voteDetailRequest send];
    }
}

- (SNNewsVotesInfo *)_parseRealtimeVotesInfo:(NSDictionary *)realtimeJson {
    SNNewsVotesInfo *votesInfo = nil;
    if (realtimeJson) {
        NSDictionary *details = [realtimeJson objectForKey:@"detail"];
        NSString *value = nil;
        if (details) {
            votesInfo = [[self class] parseVoteDetailData:details];
        }
        
        if (!votesInfo) {
            votesInfo = [[self class] votesInfoFromLocalDBByNewsID:self.newsID];
        }
        
        if (votesInfo) {
            value = [realtimeJson objectForKey:kVoteVoteTotal];
            if (value) votesInfo.voteTotal = value;
            
            value = [realtimeJson objectForKey:kVoteStartTime];
            if (value) votesInfo.startTime = value;
            
            value = [realtimeJson objectForKey:kVoteEndTime];
            if (value) votesInfo.endTime = value;
            
            value = [realtimeJson objectForKey:kVoteIsOver];
            if (value) votesInfo.isOver = value;
            
            value = [realtimeJson objectForKey:kVoteIsShowDetail];
            if (value) votesInfo.isShowDetail = value;
            
            value = [realtimeJson objectForKey:kVoteViewResultCond];
            if (value) votesInfo.viewResultCond = value;
            
            value = [realtimeJson objectForKey:kVoteIsRandomOrdered];
            if (value) votesInfo.isRandomOrdered = value;
        }
    }
    
    return votesInfo;
}

@end
