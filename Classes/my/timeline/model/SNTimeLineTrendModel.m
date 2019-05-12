//
//  SNTimeLineTrendModel.m
//  sohunews
//
//  Created by jialei on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimeLineTrendModel.h"
#import "SNURLJSONResponse.h"
#import "SNTimelineConfigs.h"

@implementation SNTimeLineTrendModel

+ (SNTimeLineTrendModel *)modelForUserWithPid:(NSString *)pid {
    SNTimeLineTrendModel *aModel = [SNTimeLineTrendModel new];
    aModel.pid = pid;
    aModel.isForOneUser = YES;
    [aModel loadCache];
    return aModel;
}

+ (SNTimeLineTrendModel *)modelForDetailWithActId:(NSString *)actId
{
    SNTimeLineTrendModel *aModel = [SNTimeLineTrendModel new];
//    aModel.pid = pid;
    aModel.actId = actId;
    aModel.isForOneUser = YES;
    return aModel;
}

- (id)init {
    self = [super init];
    if (self) {
        self.commentObjects = [NSMutableArray array];
    }
    return self;
}

- (void)timelineRefresh {
    _requestUrl = [NSString stringWithFormat:@"%@userActV2/1?fpid=%@", kTimelineServer, self.pid];
    _requestUrl = [SNUtility addParamsToURLForReadingCircle:_requestUrl];
    [self timelineSendRefresh];
}

- (void)timelineDetailRefresh {
    _requestUrl = [NSString stringWithFormat:@"%@userActV2?action=actDetail&actId=%@&getBaseInfo=1", kCircleTimelineServer, self.actId];
    _requestUrl = [SNUtility addParamsToURLForReadingCircle:_requestUrl];
    [self timelineSendRefresh];
}

- (void)timelineDetailGetMore:(NSString *)nextCommentCursor {
    _requestUrl = [NSString stringWithFormat:@"%@userActV2?action=actDetail&actId=%@&getBaseInfo=0&commentNextCursor=%@",
                   kCircleTimelineServer, self.actId, nextCommentCursor];
    _requestUrl = [SNUtility addParamsToURLForReadingCircle:_requestUrl];
    [self timelineSendRefresh];
}

- (void)timelineGetMore {
    _requestUrl = [NSString stringWithFormat:@"%@userActV2/1?nextCursor=%d&fpid=%@", kTimelineServer, self.nextCursor, self.pid];
    _requestUrl = [SNUtility addParamsToURLForReadingCircle:_requestUrl];
    [self timelineSendGetMore];
}

- (void)dealloc {
     //(_commentObjects);
     //(_detailItem);
     //(_actId);
}

#pragma mark - TTURLRequestDelegate
- (void)requestDidStartLoad:(TTURLRequest*)request {
    [super requestDidStartLoad:request];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    if (request == self.request) {
        SNURLJSONResponse *rtJson = self.request.response;
        NSDictionary *jsonDic = rtJson.rootObject;
        
        //阅读圈详情页会多封装一层value，这是个why
        if ([jsonDic dictionaryValueForKey:@"value" defalutValue:nil]) {
            jsonDic = [jsonDic dictionaryValueForKey:@"value" defalutValue:nil];
        } else {
            [super requestDidFinishLoad:request];
            return;
        }
        
        SNDebugLog(@"%@--%@:time line json obj %@",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd),
                   jsonDic);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL bResultSuccess = NO;
            if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultObj = [jsonDic dictionaryValueForKey:@"result" defalutValue:nil];
                [super parseResult:resultObj];
                
                if (self.lastErrorCode == 200) {
                    self.nextCursor = [jsonDic intValueForKey:@"nextCursor" defaultValue:0];
                    self.preCursor = [jsonDic intValueForKey:@"preCursor" defaultValue:0];
                    
                    self.allNum = [jsonDic stringValueForKey:@"allNum" defaultValue:nil];
                    self.lastRefreshDate = [NSDate date];

                    //详情页解析
                    self.detailItem = [SNTimelineTrendItem timelineTrendFromDic:jsonDic];
                    if (self.detailItem.commentsArray.count > 0) {
                        [self.commentObjects addObjectsFromArray:self.detailItem.commentsArray];
                        self.commentNextCursor = self.detailItem.commentNextCursor;
                    }
                    self.hasMoreComment = NO;
                    if (self.detailItem.commentNextCursor.length > 0 &&
                        self.detailItem.commentPreCursor.length > 0 &&
                        self.detailItem.commentNum > kTimelineDetailCommentPageNum) {
                        self.hasMoreComment = (![self.detailItem.commentNextCursor isEqualToString:self.detailItem.commentPreCursor]);
                    }
                    bResultSuccess = YES;

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
                    NSError *error = [NSError errorWithDomain:self.lastErrorMsg code:self.lastErrorCode userInfo:nil];
                    if (self.timelineObjects.count == 0) {
                        self.lastErrorCode = kSNCircleErrorCodeNoData;
                    }
                    [_delegate performSelectorOnMainThread:@selector(timelineModelDidFailToLoadWithError:)
                                                withObject:error
                                             waitUntilDone:[NSThread isMainThread]];
                }
            }
        });
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    [super request:request didFailLoadWithError:error];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    [super requestDidCancelLoad:request];
}


@end
