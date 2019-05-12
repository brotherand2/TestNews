//
//  SNMyMessageModel.m
//  sohunews
//
//  Created by jialei on 13-7-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMyMessageModel.h"
#import "SNMsgRecRequest.h"
#import "RegexKitLite.h"
#import "SNNewsComment.h"
#import "SNMyMessage.h"
#import "SNFloorCommentItem.h"
#import "NSDictionaryExtend.h"
#import "SNTimelineTrendObjects.h"
//#import "NSObject+YAJL.h"
#import "SNBubbleBadgeObject.h"
//#import "SNURLJSONResponse.h"
#import "SNTimelineConfigs.h"

#define kCriticalCount  5

@implementation SNMyMessageModel

- (id)init
{
    self = [super init];
    if (self) {
        _preCursor = 0;
        _nextCursor = 0;
        self.hasMore = NO;
    }
    return self;
}

- (void)loadData:(BOOL)isMore {
    self.loadHistory = isMore;
//    _isLoadingMore = isMore;
    [self requestLatestComment];
}

- (void)dealloc
{
//    if (_request) {
//		[_request cancel];
//	}
     //(_request);
     //(_comments);
    
}

//- (void)requestLatestComment
//{
//    NSString *_url = [SNUtility addParamsToURLForReadingCircle:SNLinks_Path_UserMsgRec];
//    if (self.loadHistory && _nextCursor > 0) {
//        _url = [_url stringByAppendingFormat:@"&nextCursor=%d", _nextCursor];
//    }
//
//    SNDebugLog(@"url %@", _url);
//    if (_request) {
//        [_request cancel];
//         //(_request);
//    }
//    _request = [SNURLRequest requestWithURL:_url delegate:self];
//    _request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    _request.urlPath = _url;
//    _request.isFastScroll = YES;
//    _request.isShowNoNetWorkMessage = NO;
//
//	_request.response = [[SNURLJSONResponse alloc] init];
//    [_request send];
//}

- (void)requestLatestComment {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    if (self.loadHistory && _nextCursor > 0) {
        [params setValue:[NSString stringWithFormat:@"%zd",_nextCursor] forKey:@"nextCursor"];
    }
    [[[SNMsgRecRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootData) {
        _isLoading = NO;

        if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
            if (!self.loadHistory) {
                self.comments = [NSMutableArray array];
            }
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
//            [params setObject:_request forKey:@"kCurrentRequest"];
            [params setObject:rootData forKey:@"kRootData"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self updateCommentsToDB:params];
                //更新取最新评论时间
                if (!self.loadHistory)
                    self.lastRefreshDate = [NSDate date];
            });
        } else {
            [self requestDidFailLoadWithError:nil];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        [self requestDidFailLoadWithError:error];
    }];
}

-(void)updateCommentsToDB:(id)params  {
    NSMutableDictionary *paramDic = (NSMutableDictionary *)params;
//    SNURLRequest *req = [paramDic objectForKey:@"kCurrentRequest"];
    id rootData = [paramDic objectForKey:@"kRootData"];
    
    id messageData = [rootData objectForKey:kMsgReceive];
    int curNextCursor = [rootData intValueForKey:kMsgNext defaultValue:0];
    int curPreCursor = [rootData intValueForKey:kMsgPre defaultValue:0];
    if (curNextCursor > 0) {
        _nextCursor = curNextCursor;
    }
    if (curPreCursor > 0) {
        _preCursor = curPreCursor;
    }

    if([messageData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *msgDataDic in messageData) {
            int msgType = [msgDataDic intValueForKey:kMsgType defaultValue:0];
            switch (msgType) {
                case SNMessageTypeCircleMsg:
                case SNMessageTypeCircleMsgReply: {
                    SNMyMessageItem *item = [[SNMyMessageItem alloc] init];
                    SNMyMessage *myMessage = [[SNMyMessage alloc] init];
                    myMessage.enableEnterProtocal = YES;
                    
                    //被回复内容
                    NSDictionary *beReplyCommentDic = [msgDataDic dictionaryValueForKey:kMsgReplyComment defalutValue:nil];
                    if (beReplyCommentDic && [beReplyCommentDic count] > 0) {
                        myMessage.replyComment = [SNTimelineCommentsObject timelineCommentObjFromDic:beReplyCommentDic];
                    }
                    
                    //阅读圈原文
                    NSString *actInfoStr = [msgDataDic stringValueForKey:kMsgRelateActInfo defaultValue:nil];
                    NSData *actInfoData = [actInfoStr dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *actInfoDic = [NSJSONSerialization JSONObjectWithData:actInfoData options:0 error:nil];
                    if (actInfoDic && [actInfoDic count] > 0) {
                        [self parseCircleMsg:actInfoDic messageInfo:myMessage];
                    }
                    
                    //回复内容
                    NSDictionary *actCommentDic = [msgDataDic dictionaryValueForKey:kMsgActComment defalutValue:nil];
                    if (actCommentDic && [actCommentDic count] > 0) {
                        myMessage.actComment = [SNTimelineCommentsObject timelineCommentObjFromDic:actCommentDic];
                    }
                    //二代协议
                    myMessage.userActUrl = [msgDataDic stringValueForKey:kMsgUserActUrl defaultValue:nil];
                    item.socialMsg = myMessage;
                    
                    [self.comments addObject:item];
                }
                    break;
                case SNMessageTypeApiMsg:
                case SNMessageTypeApiLive: {
                    id commentMsgDic = [msgDataDic stringValueForKey:kMsgApi defaultValue:nil];
                    if (commentMsgDic) {
                        SNNewsComment *comment = [self jsonStringToComment:commentMsgDic topicId:nil];
                        SNFloorCommentItem *item = [[SNFloorCommentItem alloc] init];
                        item.comment = comment;
                        
                        [self.comments addObject:item];
                    }
                }
                    break;
            }
        }
        if ([(NSArray*)messageData count] < kCriticalCount) {
            self.hasMore = NO;
        } else {
            self.hasMore = YES;
        }
    }
    else {
        self.hasMore = NO;
    }
    if ([(NSArray *)messageData count] > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidFinishLoad:)]) {
            [self.delegate performSelectorOnMainThread:@selector(commentListModelDidFinishLoad:)
                                            withObject:self
                                         waitUntilDone:[NSThread isMainThread]];
        }
    }
    else if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidFailToLoadWithError:)]) {
        self.lastErrorCode = kCommentErrorCodeNoData;
        [self.delegate performSelectorOnMainThread:@selector(commentListModelDidFailToLoadWithError:)
                                        withObject:self
                                     waitUntilDone:[NSThread isMainThread]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.loadHistory)
            [[SNBubbleNumberManager shareInstance] resetReply];
    });
}

- (SNNewsComment *)jsonStringToComment:(NSString *)jsonDataString topicId:(NSString *)topicId {
    NSData *jsonData = [jsonDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *commentDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    SNNewsComment *comment = [[SNNewsComment alloc] init];

    comment.commentId = [commentDic stringValueForKey:kCommentId defaultValue:nil];
    comment.author    = [commentDic objectForKey:kAuthor];
    comment.city      = [commentDic objectForKey:kCity];
    comment.content   = [commentDic stringValueForKey:kContent defaultValue:@""];
    comment.replyNum  = [commentDic objectForKey:kReplyNum];
    NSNumber *dNum    = [commentDic objectForKey:kDigNum];
    comment.digNum    = [dNum stringValue];
    comment.from      = [commentDic objectForKey:kFrom];
    comment.ctime     = [commentDic stringValueForKey:kCtime defaultValue:nil];
    comment.passport  = [commentDic objectForKey:kPassport];
    comment.linkStyle = [commentDic objectForKey:kLinkStyle];
    comment.spaceLink = [commentDic objectForKey:kSpaceLink];
    comment.pid       = [commentDic stringValueForKey:kPid defaultValue:nil];
    comment.authorimg = [commentDic objectForKey:kAuthorimg];
    comment.newsTitle = [commentDic objectForKey:kCommentNewsTitle];
    comment.newsLink  = [commentDic objectForKey:kCommentNewsLink];
    comment.commentImage = [commentDic objectForKey:kCommentImage];
    comment.commentImageSmall = [commentDic objectForKey:kCommentImageSmall];
    comment.commentImageBig = [commentDic objectForKey:kCommentImageBig];
    comment.commentAudLen = [commentDic intValueForKey:kCommentAudLen defaultValue:0];
    comment.commentAudUrl = [commentDic objectForKey:kCommentAudUrl];
    comment.userComtId = [commentDic objectForKey:kCommentUserComtId];
    comment.cmtStatus    = [commentDic stringValueForKey:kCmtStatus defaultValue:nil];
    comment.cmtHint      = [commentDic stringValueForKey:kCmtHint defaultValue:nil];
    comment.busiCode     = [commentDic stringValueForKey:kCmtBusiCode defaultValue:nil];
    //回复我的中通过二代类型协议判断busiCode
    if (comment.newsLink.length > 0) {
        NSDictionary *linkDic = [SNUtility parseLinkParams:comment.newsLink];
        if (NSNotFound != [comment.newsLink rangeOfString:kProtocolLive options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kLiveIdKey defaultValue:nil];
        }
        else if (NSNotFound != [comment.newsLink rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kSNNewsId defaultValue:nil];
            comment.busiCode = @"2";
        }
        else if (NSNotFound != [comment.newsLink rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kGid defaultValue:nil];
            comment.busiCode = @"3";
        }
    }
    comment.attachList   = commentDic[kCmtAttachList];
    if (topicId) {
        comment.topicId   = topicId;
    } else  {
        comment.topicId   = [commentDic objectForKey:kTopicId];
    }
//    [self filterHTML:comment];
    
    id floorsData = [commentDic objectForKey:kFloors];
    if ([floorsData isKindOfClass:[NSArray class]]) {
        comment.floors = [NSMutableArray array];
        for (NSDictionary *floorDic in floorsData) {
            if ([floorDic isKindOfClass:[NSDictionary class]]) {
                SNNewsComment *floorComment = [[SNNewsComment alloc] init];
                floorComment.commentId = [floorDic stringValueForKey:kCommentId defaultValue:nil];
                floorComment.author    = [floorDic objectForKey:kAuthor];
                floorComment.passport  = [floorDic objectForKey:kPassport];
                floorComment.spaceLink = [floorDic objectForKey:kSpaceLink];
                floorComment.pid       = [floorDic stringValueForKey:kPid defaultValue:nil];
                floorComment.linkStyle = [floorDic objectForKey:kLinkStyle];
                floorComment.city      = [floorDic objectForKey:kCity];
                floorComment.content   = [floorDic stringValueForKey:kContent defaultValue:@""];
                floorComment.replyNum  = [floorDic objectForKey:kReplyNum];
                NSNumber *dNum         = [floorDic objectForKey:kDigNum];
                floorComment.digNum    = [dNum stringValue];
                floorComment.from      = [floorDic objectForKey:kFrom];
                floorComment.ctime     = [commentDic stringValueForKey:kCtime defaultValue:nil];
                floorComment.commentImage = [floorDic objectForKey:kCommentImage];
                floorComment.commentImageBig= [floorDic objectForKey:kCommentImageBig];
                floorComment.commentImageSmall = [floorDic objectForKey:kCommentImageSmall];
                floorComment.commentAudLen = [floorDic intValueForKey:kCommentAudLen defaultValue:0];
                floorComment.commentAudUrl = [floorDic objectForKey:kCommentAudUrl];
                floorComment.userComtId = [floorDic objectForKey:kCommentUserComtId];
                if (topicId) {
                    floorComment.topicId   = topicId;
                } else  {
                    floorComment.topicId   = [floorDic objectForKey:kTopicId];
                }
                
//                [self filterHTML:floorComment];
                [comment.floors addObject:floorComment];
                 //(floorComment);
            }
        }
    }
    return comment;
}

- (void)parseCircleMsg:(NSDictionary *)socialDic messageInfo:(SNMyMessage *)myMessage
{
    myMessage.content = [socialDic stringValueForKey:kMyMsgContent defaultValue:nil];
    myMessage.myContent = [socialDic stringValueForKey:kMyMsgOrignalContent defaultValue:nil];
    myMessage.commentType = [socialDic objectForKey:kMyMsgCommentType];
    myMessage.ctime = [socialDic stringValueForKey:@"time" defaultValue:nil];
    myMessage.gender = [socialDic stringValueForKey:kMyMsgGender defaultValue:@"0"];
    myMessage.headUrl = [socialDic stringValueForKey:kMyMsgHeadUrl defaultValue:nil];
    myMessage.fromLink = [socialDic stringValueForKey:kMyMsgFromLink defaultValue:nil];
    myMessage.cmtStatus      = [socialDic objectForKey:kCmtStatus];
    myMessage.cmtHint      = [socialDic objectForKey:kCmtHint];
    if (myMessage.fromLink.length > 0) {
        NSRange findRange = [myMessage.fromLink rangeOfString:@"shareId="];
        if (findRange.length > 0)  {
            myMessage.shareId = [myMessage.fromLink substringFromIndex:findRange.location + findRange.length];
        }
    }
    myMessage.msgId = [socialDic objectForKey:kMyMsgId];
    myMessage.nickName = [socialDic objectForKey:kMyMsgNickName];
    myMessage.pid = [socialDic stringValueForKey:kMyMsgPid defaultValue:nil];
    myMessage.city = [socialDic objectForKey:kMyMsgCity];
    
    NSDictionary *shareInfoDic = [socialDic dictionaryValueForKey:kMyMsgShareInfo defalutValue:nil];
    if (shareInfoDic && [shareInfoDic count] > 0) {
        SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareInfoDic];
        //针对服务器返回不同业务逻辑进行适配，使数据结构符合UI层格式
        if (obj.title.length <= 0) {
            obj.title = [socialDic stringValueForKey:@"actTitle" defaultValue:nil];
        }
        myMessage.shareObj = obj;
    }
}

- (void)requestDidFailLoadWithError:(NSError*)error
{
    _isLoading = NO;
    self.lastErrorCode = error.code;
    self.lastErrorMsg = error.domain;
    //网络错误，设置为还有更多，用户下拉加载
    self.hasMore = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidFailToLoadWithError:)])
    {
        [self.delegate performSelectorOnMainThread:@selector(commentListModelDidFailToLoadWithError:)
                                        withObject:self
                                     waitUntilDone:[NSThread isMainThread]];
    }
}


//#pragma mark -
//#pragma mark TTURLRequestDelegate
//- (void)requestDidStartLoad:(id)data {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidStartLoad:)]) {
//        [self.delegate performSelectorOnMainThread:@selector(commentListModelDidStartLoad:)
//                                        withObject:self
//                                     waitUntilDone:[NSThread isMainThread]];
//    }
//}
//
//- (void)requestDidFinishLoad:(id)data {
//    _isLoading = NO;
//	SNURLJSONResponse *dataResponse = (SNURLJSONResponse *)_request.response;
//	id rootData = dataResponse.rootObject;
//    if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
//        if (!self.loadHistory) {
//            self.comments = [NSMutableArray array];
//        }
//        
//        NSMutableDictionary *params = [NSMutableDictionary dictionary];
////        [params setObject:_request forKey:@"kCurrentRequest"];
//        [params setObject:rootData forKey:@"kRootData"];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self updateCommentsToDB:params];
//            //更新取最新评论时间
//            if (!self.loadHistory)
//                self.lastRefreshDate = [NSDate date];
//        });
//	} else {
//        [self request:_request didFailLoadWithError:nil];
//	}
//}
//
//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
//{
//    _isLoading = NO;
//    self.lastErrorCode = error.code;
//    self.lastErrorMsg = error.domain;
//    //网络错误，设置为还有更多，用户下拉加载
//    self.hasMore = YES;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidFailToLoadWithError:)])
//    {
//        [self.delegate performSelectorOnMainThread:@selector(commentListModelDidFailToLoadWithError:)
//                                        withObject:self
//                                     waitUntilDone:[NSThread isMainThread]];
//    }
//}

@end
