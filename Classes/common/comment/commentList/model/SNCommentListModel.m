//
//  SNCommentListModel.m
//  sohunews
//
//  Created by jialei on 13-8-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentListModel.h"
//#import "SNURLJSONResponse.h"
#import "SNDBManager.h"
#import "SNNewsComment.h"
//#import "NSObject+YAJL.h"
#import "RegexKitLite.h"
#import "GTMNSString+HTML.h"
#import "SNFloorCommentItem.h"
#import "SNCommentListCell.h"
//#import "SNConsts.h"
#import "SNCommentListByCursorRequest.h"

#define kCommentRootData    @"kRootData"
#define kCommentSameLimitCount 3
#define kDefaultAuthor      @"搜狐网友"

@interface SNCommentListModel()
{
    NSString        *_newsId;
    NSString        *_gid;
//    SNURLRequest    *_request;
    int             _commentSameTimes;   //请求回评论数据重复次数
    
    BOOL            _isLoading;
    BOOL            _isFirst;
    dispatch_queue_t _commentQueue;
}

@property  (nonatomic, copy)NSString  *newsId;
@property  (nonatomic, copy)NSString  *gid;

@end

@implementation SNCommentListModel

@synthesize delegate = _delegate;
@synthesize lastErrorMsg = _lastErrorMsg;
@synthesize lastErrorCode = _lastErrorCode;
@synthesize hasMore = _hasMore;
@synthesize loadHistory = _loadHistory;
@synthesize isFirst = _isFirst;
@synthesize lastCommentId = _lastCommentId;
@synthesize firstCommentId = _firstCommentId;
@synthesize loadPageNum;
@synthesize commentCellHeight;
@synthesize readCount = _readCount;
@synthesize commentCount = _commentCount;
@synthesize stpAudCmtRsn = _stpAudCmtRsn;
@synthesize requestSource = _requestSource;
@synthesize busiCode = _busiCode;
@synthesize tag;
@synthesize userInfo;
@synthesize isHotTab;
@synthesize hasSameData;

- (id)initWithCommentModelWithNewsId:(NSString *)newsId gid:(NSString*)gid
{
    self = [super init];
    
    if (self) {
        self.newsId = newsId;
        self.gid = gid;
        self.loadPageNum = 0;
        self.commentCellHeight = 0;
        self.hasMore = NO;
        self.isFirst = YES;
        self.hasSameData = NO;
        self.changeRequest = NO;
        self.lastCommentId = @"-1";
        self.firstCommentId = @"-1";
        _commentSameTimes = 0;
        
        if (gid.length) {
            self.busiCode = @"3";
        } else {
            self.busiCode = @"2";
        }
    }
    
    return self;
}

//+ (SNCommentListModel*)commentModelWithGId:(NSString *)gid type:(NSString *)type
//{
//    SNCommentListModel*  model = [[SNCommentListModel alloc]init];
//    model.reqType = type;
//    model.gid = gid;
//    if ([model.type isEqualToString:KCommentTypeHot]) {
//        model.isHotTab = YES;
//    }
//    return [model autorelease];
//}

- (id)init
{
	self = [super init];
	if (self)
    {
        _commentSameTimes = 0;
        self.loadPageNum = 0;
        self.commentCellHeight = 0;
        self.loadPageSize = KPaginationNum;
        self.hasMore = NO;
        self.isFirst = YES;
        self.hasSameData = NO;
        self.changeRequest = NO;
        self.lastCommentId = @"-1";
        self.firstCommentId = @"-1";
    }
	return self;
}

- (void)dealloc
{
//    if (_request)
//    {
//		[_request cancel];
//	}
}

- (void)cancel
{
//	if (_request)
//    {
//		[_request cancel];
//	}
}

- (void)resetData {
    if(self.comments.count > 0) {
        [self.comments removeAllObjects];
    }
}

- (BOOL)getIsLoading {
    
    return _isLoading;
}

- (void)loadData:(BOOL)more
{
    _loadHistory = more;
    if (_loadHistory) {
        if (self.isHotTab) {
            self.loadPageSize = kHotCommentNextPageSize;
        } else {
            self.loadPageSize = kNewCommentNextPageSize;
        }
    }
    if (!_hadDingComments)
    {
        NSString *newsType = _newsId ? kNewsId : kGid;
        NSString *nId = _newsId ? _newsId : _gid;
        _hadDingComments = [[[SNDBManager currentDataBase] getHadDingFloorComment:_type andNewsId:nId andNewsType:newsType] mutableCopy];
    }
    
	if (!_isLoading)
    {
        _isLoading = YES;
		[self requestLatestComment];
    }
}

- (void)requestLatestComment
{
    self.requestSource = KCommentSourceComment;
    if  (!_loadHistory) {
        self.loadPageNum = 0;
        self.requestSource = KCommentSourceNews;
        self.rollType = 1;
        _commentSameTimes = 0;
    } else {
        self.rollType = 2;
        //如果是最热评论加载完再去下拉刷新则请求最新评论，rollType重置为1，去从第一条请求最新评论
        if (self.changeRequest) {
            self.rollType = 1;
            self.changeRequest = NO;
        }
    }
    if (self.refererType == 0) {
        [self getRefererType];
    }
//    //分页方式获取评论
////    [self urlWithPage];
//    //游标方式获取评论
//    [self urlWithCursor];
//    // 添加打开article或photolist的link所带的所有字段
//    if (self.userInfo) {
//        NSString *params = [self.userInfo toUrlString];
//        _url = [_url stringByAppendingString:params];
//    }
//    
//    if (_request) {
//        [_request cancel];
//    }
//    
//    if (_url.length > 0) {
//        _request = [SNURLRequest requestWithURL:_url delegate:self];
//        _request.cachePolicy = TTURLRequestCachePolicyNoCache;
//        _request.urlPath = _url;
//        _request.isFastScroll = YES;
//        if ([_comments count] <= 0)
//            _request.isShowNoNetWorkMessage = NO;
//        
//        _request.response = [[SNURLJSONResponse alloc] init];
//        [_request send];
//    }
    [self sendRequest];
}

- (void)sendRequest {
    
    self.commentType = (self.isHotTab ? 5:3);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [params setValue:self.busiCode forKey:@"busiCode"];
    [params setValue:[self sourceId] forKey:@"id"];
    [params setValue:[self cursorId] forKey:@"cursorId"];
    [params setValue:[NSString stringWithFormat:@"%zd",self.rollType] forKey:@"rollType"];
    [params setValue:[NSString stringWithFormat:@"%zd",self.loadPageSize] forKey:@"size"];
    [params setValue:self.requestSource forKey:@"source"];
    [params setValue:[NSString stringWithFormat:@"%zd",self.commentType] forKey:@"type"];
    [params setValue:[NSString stringWithFormat:@"%zd",self.refererType] forKey:@"refererType"];
    
    // 添加打开article或photolist的link所带的所有字段
    if (self.userInfo) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        [self.userInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isKindOfClass:[NSString class]] && [key isEqualToString:kOpenProtocolOriginalLink2]) {
                return;
            }
            [info setValue:obj forKey:key];
        }];
        [params setValuesForKeysWithDictionary:info];
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidStartLoad:)]) {
        [self.delegate performSelectorOnMainThread:@selector(commentListModelDidStartLoad:)
                                        withObject:self
                                     waitUntilDone:[NSThread isMainThread]];
    }
    [[[SNCommentListByCursorRequest alloc] initWithDictionary:params
                                        needNetSafeParameters:NO] send:^(SNBaseRequest *request, id responseObject) {
        _isLoading = NO;
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:responseObject forKey:@"kRootData"];
            
            //快速滑动组图时闪退  modify by wangyy
            // should be DISPATCH_QUEUE_SERIAL , not DISPATCH_QUEUE_CONCURRENT
            if (!_commentQueue) {
                _commentQueue = dispatch_queue_create([@"COMMENTPARSE_QUEUE_T" UTF8String], DISPATCH_QUEUE_SERIAL);
            }
            dispatch_async(_commentQueue, ^{
                [self parseDataFromCursorRequest:params];
                //更新取最新评论时间
                if (!_loadHistory)
                    self.lastRefreshDate = [NSDate date];
                
            });
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidFailToLoadWithError:)]) {
                self.lastErrorCode = kCommentErrorCodeNoData;
                [self.delegate performSelectorOnMainThread:@selector(commentListModelDidFailToLoadWithError:)
                                                withObject:self
                                             waitUntilDone:[NSThread isMainThread]];
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        _isLoading = NO;
        self.lastErrorCode = (int)error.code;
        self.lastErrorMsg = error.domain;
        //网络错误，设置为还有更多，用户下拉加载
        self.hasMore = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidFailToLoadWithError:)]) {
            [self.delegate performSelectorOnMainThread:@selector(commentListModelDidFailToLoadWithError:)
                                            withObject:self
                                         waitUntilDone:[NSThread isMainThread]];
        }
    }];
}

- (void)getRefererType {
    if (self.userInfo) {
        if ([[self.userInfo objectForKey:kNewsFrom] isEqualToString:kChannelEditionNews]) {
            self.refererType = 1;
        } else if ([[self.userInfo objectForKey:kNewsFrom] isEqualToString:kChannelRecomNews]) {
            self.refererType = 2;
        } else if ([[self.userInfo objectForKey:kNewsFrom] isEqualToString:kSearchNews]) {
            self.refererType = 3;
        } else if ([[self.userInfo objectForKey:kNewsFrom] isEqualToString:kNewsRecomNews]) {
            self.refererType = 4;
        } else {
            self.refererType = 1;
        }
    }
}

//- (void)urlWithPage {
//    if (_newsId) {
//        _url = [NSString stringWithFormat:kV3UrlNewsCommentListByNewsId, self.requestSource, _newsId, _type, self.loadPageNum + 1, self.loadPageSize];
//        [self.userInfo removeObjectForKey:kNewsId];
//    } else {
//        _url = [NSString stringWithFormat:kV3UrlNewsCommentListByGid, self.requestSource, _gid, _type, self.loadPageNum + 1, self.loadPageSize];
//        [self.userInfo removeObjectForKey:kGid];
//    }
//}

//- (void)urlWithCursor {
//    //"api/comment/%@?busiCode=%@&id=%@&cursorId=%@&rollType=%d&size=%d&source=%@"
//    if (self.isHotTab) {
//        self.commentType = 5;
//        _url = [NSString stringWithFormat:SNLinks_Path_Comment_CommentList, self.busiCode, [self sourceId],
//                [self cursorId], self.rollType, self.loadPageSize, self.requestSource, self.commentType, self.refererType];
//    } else {
//        self.commentType = 3;
//        _url = [NSString stringWithFormat:SNLinks_Path_Comment_CommentList, self.busiCode, [self sourceId],
//                [self cursorId], self.rollType, self.loadPageSize, self.requestSource, self.commentType, self.refererType];
//    }
//}

- (NSString *)sourceId {
    return self.gid.length > 1 ? self.gid : self.newsId;
}

- (NSString *)cursorId {
    if (_loadHistory) {
        return self.lastCommentId;
    } else {
        return self.firstCommentId;
    }
}

#pragma mark - parseData
-(void)readFirstPageCachedCommentsFromDB
{
    NSString *newsType = _newsId ? kNewsId : kGid;
    NSString *nId = _newsId ? _newsId : _gid;
    NSMutableArray *cacheJsonList = [[[SNDBManager currentDataBase] getFirstCachedFloorComment:_type andNewsId:nId andNewsType:newsType] mutableCopy];
    [self resetData];
    [self parseFloorComment:cacheJsonList];
    
}

- (void)parseFloorComment:(id)floorsData parseComment:(SNNewsComment *)comment
{
    if ([floorsData isKindOfClass:[NSArray class]]) {
        comment.floors = [NSMutableArray array];
        for (NSDictionary *floorDic in floorsData) {
            if ([floorDic isKindOfClass:[NSDictionary class]]) {
                SNNewsComment *floorComment = [[SNNewsComment alloc] init];
                floorComment.commentId = [floorDic stringValueForKey:kCommentId defaultValue:@""];
                floorComment.author    = [floorDic stringValueForKey:kAuthor defaultValue:kDefaultAuthor];
                if (floorComment.author.length <= 0) {
                    floorComment.author = kDefaultAuthor;
                }
                floorComment.passport  = [floorDic stringValueForKey:kPassport defaultValue:@""];
                floorComment.spaceLink = [floorDic stringValueForKey:kSpaceLink defaultValue:@""];
                floorComment.pid       = [floorDic stringValueForKey:kPid defaultValue:@""];
                floorComment.linkStyle = [floorDic stringValueForKey:kLinkStyle defaultValue:@""];
                floorComment.city      = [floorDic stringValueForKey:kCity defaultValue:@""];
                floorComment.content   = [floorDic stringValueForKey:kContent defaultValue:@""];
                floorComment.replyNum  = [floorDic objectForKey:kReplyNum defalutObj:@""];
                floorComment.authorimg = [floorDic stringValueForKey:kAuthorimg defaultValue:@""];
                floorComment.commentImage = [floorDic stringValueForKey:kCommentImage defaultValue:@""];
                floorComment.commentImageSmall = [floorDic stringValueForKey:kCommentImageSmall defaultValue:@""];
                floorComment.commentImageBig = [floorDic stringValueForKey:kCommentImageBig defaultValue:@""];
                floorComment.commentAudLen = [floorDic intValueForKey:kCommentAudLen defaultValue:0];
                floorComment.commentAudUrl = [floorDic stringValueForKey:kCommentAudUrl defaultValue:@""];
                floorComment.userComtId = [floorDic stringValueForKey:kCommentUserComtId defaultValue:@""];
                NSString *status  = [floorDic stringValueForKey:kStatus defaultValue:nil];
                floorComment.status    = [status intValue];
                floorComment.isAuthor = self.isAuthor;
//                floorComment.badgeListArray = commentDic[kBadgeList];
                NSNumber *dNum         = [floorDic objectForKey:kDigNum];
                if ([SNNewsComment commentHadDing:floorComment.commentId dingComments:_hadDingComments]) {
                    int ding = [dNum intValue] + 1;
                    floorComment.hadDing = YES;
                    floorComment.digNum = [NSString stringWithFormat:@"%d",ding];
                } else {
                    floorComment.digNum    = [dNum stringValue];
                }
                floorComment.from      = [floorDic stringValueForKey:kFrom defaultValue:@""];
                floorComment.ctime     = [floorDic stringValueForKey:kCtime defaultValue:@""];
                floorComment.topicId   = [floorDic stringValueForKey:kTopicId defaultValue:@""];
                [self filterHTML:floorComment];
                [comment.floors addObject:floorComment];
            }
        }
    }
}

- (void)parseFloorComment:(NSMutableArray *)cacheJsonList
{
    if (!self.comments)
        self.comments = [NSMutableArray array];
    
    for (CommentFloor *comJson in cacheJsonList)
    {
        NSString *topicId = comJson.topicId;
        NSString *jsonDataString = comJson.commentJson;
        SNFloorCommentItem *item = [[SNFloorCommentItem alloc]init];
        SNNewsComment *comment = [self jsonStringToComment:jsonDataString topicId:topicId];
        comment.cid = comJson.ID;
        comment.digNum = [NSString stringWithFormat:@"%ld",(long)comJson.digNum];
        comment.hadDing = comJson.hadDing;
        comment.isCommentOpen = NO;
        comment.isAuthor = self.isAuthor;
        item.isAuthor = self.isAuthor;
        item.newsId = self.newsId;
        item.comment = comment;
        float height = [SNCommentListCell heightForCommentListCell:item];
        self.commentCellHeight += height;
        item.cellHeight = height;
        
        [self.comments addObject:item];
    }
    if (self.comments.count > 0) {
        self.hasMore = YES;
    }
}

- (void)parseDataFromPageRequest:(id)params
{
    NSMutableDictionary *paramDic = (NSMutableDictionary *)params;
    id rootData = [paramDic objectForKey:kCommentRootData];
    self.commentCount = [[rootData objectForKey:kPlCount] stringValue];
    self.readCount = [[rootData objectForKey:kReadCount] stringValue];
    self.stpAudCmtRsn = [rootData objectForKey:kStpAudCmtRsn];
    self.comtStatus = [rootData stringValueForKey:kCmtStatus defaultValue:nil];
    self.comtHint = [rootData stringValueForKey:kCmtHint defaultValue:nil];
    
    [self updateCommentsToDB:rootData];
}

- (void)parseDataFromCursorRequest:(id)params
{
    NSMutableDictionary *paramDic = (NSMutableDictionary *)params;
    id rootData = [paramDic objectForKey:kCommentRootData];
    id responseData = [rootData objectForKey:@"response"];
    self.readCount = [responseData stringValueForKey:kReadCount defaultValue:nil];
    self.commentCount = [responseData stringValueForKey:kPlCount defaultValue:nil];
    self.stpAudCmtRsn = [responseData stringValueForKey:kStpAudCmtRsn defaultValue:nil];
    self.comtStatus = [responseData stringValueForKey:kCmtStatus defaultValue:nil];
    self.comtHint = [responseData stringValueForKey:kCmtHint defaultValue:nil];
    
    [self updateCommentsToDB:responseData];
}

-(void)updateCommentsToDB:(id)rootData  {
    @autoreleasepool {
        id commentData = [rootData objectForKey:kCommentList];
        //请求最新数据清空历史数据
        if (!_loadHistory) {
            [self resetData];
        }
        //    int countBeforeMerge = [self.comments count];
        //缓存数据
        NSMutableArray * commentItems = [[NSMutableArray alloc] init];
        if ([commentData isKindOfClass:[NSArray class]]) {
            NSArray *commentArray = (NSArray *)commentData;
            if (!_loadHistory && !self.comments && commentArray.count > 0) {
                self.comments = [NSMutableArray array];
            }
            for (NSDictionary *commentDic in commentData) {
                if ([commentDic isKindOfClass:[NSDictionary class]]) {
                    //need show on table
                    SNNewsComment *comment = [[SNNewsComment alloc] init];
                    comment.commentId = [commentDic stringValueForKey:kCommentId defaultValue:nil];
                    comment.author    = [commentDic stringValueForKey:kAuthor defaultValue:kDefaultAuthor];
                    if (comment.author.length <= 0) {
                        comment.author = kDefaultAuthor;
                    }
                    comment.passport  = [commentDic stringValueForKey:kPassport defaultValue:nil];
                    comment.linkStyle = [commentDic stringValueForKey:kLinkStyle defaultValue:nil];
                    comment.spaceLink = [commentDic stringValueForKey:kSpaceLink defaultValue:nil];
                    comment.pid       = [commentDic stringValueForKey:kPid defaultValue:nil];
                    comment.city      = [commentDic stringValueForKey:kCity defaultValue:nil];
                    comment.content   = [commentDic stringValueForKey:kContent defaultValue:nil];
                    comment.replyNum  = [commentDic stringValueForKey:kReplyNum defaultValue:nil];
                    comment.authorimg = [commentDic stringValueForKey:kAuthorimg defaultValue:nil];
                    comment.commentImage = [commentDic stringValueForKey:kCommentImage defaultValue:nil];
                    comment.commentImageSmall = [commentDic stringValueForKey:kCommentImageSmall defaultValue:nil];
                    comment.commentImageBig = [commentDic stringValueForKey:kCommentImageBig defaultValue:nil];
                    comment.commentAudLen = [commentDic intValueForKey:kCommentAudLen defaultValue:0];
                    comment.commentAudUrl = [commentDic stringValueForKey:kCommentAudUrl defaultValue:nil];
                    comment.userComtId   = [commentDic stringValueForKey:kCommentUserComtId defaultValue:nil];
                    comment.cmtStatus    = [commentDic stringValueForKey:kCmtStatus defaultValue:nil];
                    comment.cmtHint      = [commentDic stringValueForKey:kCmtHint defaultValue:nil];
                    comment.orgHomePage  = [commentDic stringValueForKey:kOrgHomePage defaultValue:nil];
                    comment.mediaType    = [commentDic intValueForKey:kMediaType defaultValue:nil];
                    comment.isCommentOpen = NO;
                    comment.isAuthor = self.isAuthor;
                    //                comment.badgeListArray = commentDic[kBadgeList];
                    NSString *role    = [commentDic stringValueForKey:kRole defaultValue:nil];
                    comment.roleType  = role.length > 0 ? [role intValue] : 0;
                    
                    int dNum = [commentDic intValueForKey:kDigNum defaultValue:0];
                    if ([SNNewsComment commentHadDing:comment.commentId dingComments:_hadDingComments]) {
                        int ding = dNum + 1;
                        comment.hadDing = YES;
                        comment.digNum = [NSString stringWithFormat:@"%d",ding];
                    } else {
                        comment.digNum = [NSString stringWithFormat:@"%d",dNum];
                    }
                    comment.from      = [commentDic stringValueForKey:kFrom defaultValue:nil];
                    comment.ctime     = [commentDic stringValueForKey:kCtime defaultValue:nil];
                    comment.fromIcon  = [commentDic stringValueForKey:kFromIcon defaultValue:nil];
                    comment.status  = [commentDic intValueForKey:kStatus defaultValue:@"0"];
                    comment.topicId   = [rootData stringValueForKey:kTopicId defaultValue:nil];
                    [self filterHTML:comment];
                    
                    //解析楼层信息
                    id floorsData = [commentDic objectForKey:kFloors];
                    [self parseFloorComment:floorsData parseComment:comment];
                    
                    //服务器返回数据去重
                    [self addCommentItem:comment items:commentItems];
                }
            }
            //最新评论插入前面，更多评论插入后面
            [self addCommentsData:commentItems];
            
            //不缓存数据库
            //        if (!_loadHistory && [_type isEqualToString:KCommentTypeLatest] && !isHotTab) {
            //            [self insertMyComments];
            //        }
            
            if ([commentData isKindOfClass:[NSArray class]] && [(NSArray *)commentData count] > 0) {
                //返回数小于请求数认为没有更多评论
                if ([(NSArray *)commentData count] == self.loadPageSize) {
                    self.hasMore = YES;
                }
                else {
                    self.hasMore = NO;
                }
                self.loadPageNum++;
                //记录最后一条commentId
                NSMutableDictionary *commentDic = [(NSArray *)commentData lastObject];
                self.lastCommentId = [commentDic stringValueForKey:kCommentId defaultValue:@"-1"];
            } else {
                self.hasMore = NO;
            }
        } else {
            self.hasMore = NO;
        }
        
        //服务器返回数据有可能全部重复，如果虑重后数据没有增加再去请求一次
        //    int countAfterMerge = [self.comments count];
        //    if (countBeforeMerge == countAfterMerge && _loadHistory) {
        //        _commentSameTimes++;
        //        self.hasSameData = YES;
        //    } else {
        //        self.hasSameData = NO;
        //    }
        if (_commentSameTimes > kCommentSameLimitCount) {
            _commentSameTimes = 0;
            self.hasMore = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidFailToLoadWithError:)]) {
                self.lastErrorCode = kCommentErrorCodeNoData;
                [self.delegate performSelectorOnMainThread:@selector(commentListModelDidFailToLoadWithError:)
                                                withObject:self
                                             waitUntilDone:[NSThread isMainThread]];
            }
        }
        else if ([commentData isKindOfClass:[NSArray class]] && [(NSArray *)commentData count] > 0) {
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
    }
}

- (SNNewsComment *)jsonStringToComment:(NSString *)jsonDataString topicId:(NSString *)topicId {
    NSData *jsonData = [jsonDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *commentDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    SNNewsComment *comment = [[SNNewsComment alloc] init];
    comment.commentId = [commentDic stringValueForKey:kCommentId defaultValue:@""];
    comment.author    = [commentDic objectForKey:kAuthor];
    comment.city      = [commentDic objectForKey:kCity];
    comment.content   = [commentDic stringValueForKey:kContent defaultValue:@""];
    comment.replyNum  = [commentDic objectForKey:kReplyNum];
    NSNumber *dNum    = [commentDic objectForKey:kDigNum];
    comment.digNum    = [dNum stringValue];
    comment.from      = [commentDic objectForKey:kFrom];
    comment.ctime     = [commentDic objectForKey:kCtime];
    comment.passport  = [commentDic objectForKey:kPassport];
    comment.linkStyle = [commentDic objectForKey:kLinkStyle];
    comment.spaceLink = [commentDic objectForKey:kSpaceLink];
    comment.pid       = [commentDic stringValueForKey:kPid defaultValue:nil];
    comment.authorimg = [commentDic objectForKey:kAuthorimg];
    comment.commentImage = [commentDic objectForKey:kCommentImage];
    comment.commentImageSmall = [commentDic objectForKey:kCommentImageSmall];
    comment.commentImageBig = [commentDic objectForKey:kCommentImageBig];
    comment.commentAudLen = [commentDic intValueForKey:kCommentAudLen defaultValue:0];
    comment.commentAudUrl = [commentDic objectForKey:kCommentAudUrl];
    comment.userComtId = [commentDic objectForKey:kCommentUserComtId];
//    comment.badgeListArray = commentDic[kBadgeList];
    
    NSString *status  = [commentDic stringValueForKey:kStatus defaultValue:nil];
    comment.status    = [status intValue];
    NSString *role    = [commentDic stringValueForKey:kRole defaultValue:nil];
    comment.roleType  = role.length > 0? [role intValue] : 0;
    
    if (topicId) {
        comment.topicId   = topicId;
    } else  {
        comment.topicId   = [commentDic objectForKey:kTopicId];
    }
    [self filterHTML:comment];
    
    id floorsData = [commentDic objectForKey:kFloors];
    if ([floorsData isKindOfClass:[NSArray class]]) {
        comment.floors = [NSMutableArray array];
        for (NSDictionary *floorDic in floorsData) {
            if ([floorDic isKindOfClass:[NSDictionary class]]) {
                SNNewsComment *floorComment = [[SNNewsComment alloc] init];
                floorComment.commentId = [floorDic stringValueForKey:kCommentId defaultValue:@""];
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
                floorComment.ctime     = [floorDic objectForKey:kCtime];
                floorComment.commentImage = [floorDic objectForKey:kCommentImage];
                floorComment.commentImageBig= [floorDic objectForKey:kCommentImageBig];
                floorComment.commentImageSmall = [floorDic objectForKey:kCommentImageSmall];
                floorComment.commentAudLen = [floorDic intValueForKey:kCommentAudLen defaultValue:0];
                floorComment.commentAudUrl = [floorDic objectForKey:kCommentAudUrl];
                floorComment.userComtId = [floorDic objectForKey:kCommentUserComtId];
                NSString *status  = [floorDic stringValueForKey:kStatus defaultValue:nil];
                floorComment.status    = [status intValue];
                floorComment.isAuthor = self.isAuthor;
//                floorComment.badgeListArray = commentDic[kBadgeList];
                if (topicId) {
                    floorComment.topicId   = topicId;
                } else  {
                    floorComment.topicId   = [floorDic objectForKey:kTopicId];
                }
                
                [self filterHTML:floorComment];
                [comment.floors addObject:floorComment];
            }
        }
    }
    return comment;
}

- (void)parseJsonData:(id)aData {
    id commentData = [aData objectForKey:kCommentList];
    if ([commentData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *commentDic in commentData) {
            if ([commentDic isKindOfClass:[NSDictionary class]]) {
                SNNewsComment *comment = [[SNNewsComment alloc] init];
                comment.commentId = [commentDic stringValueForKey:kCommentId defaultValue:@""];
                comment.author    = [commentDic objectForKey:kAuthor];
                comment.passport  = [commentDic objectForKey:kPassport];
                comment.linkStyle = [commentDic objectForKey:kLinkStyle];
                comment.spaceLink = [commentDic objectForKey:kSpaceLink];
                comment.pid       = [commentDic stringValueForKey:kPid defaultValue:nil];
                comment.city      = [commentDic objectForKey:kCity];
                comment.content   = [commentDic stringValueForKey:kContent defaultValue:@""];
                comment.replyNum  = [commentDic objectForKey:kReplyNum];
                NSNumber *dNum    = [commentDic objectForKey:kDigNum];
                comment.digNum    = [dNum stringValue];
                comment.from      = [commentDic objectForKey:kFrom];
                comment.ctime     = [commentDic objectForKey:kCtime];
                comment.topicId   = [aData objectForKey:kTopicId];
                NSString *status  = [commentDic stringValueForKey:kStatus defaultValue:nil];
                comment.status    = [status intValue];
                NSString *role    = [commentDic stringValueForKey:kRole defaultValue:nil];
                comment.roleType  = role.length > 0? [role intValue] : 0;
                
                id floorsData = [commentDic objectForKey:kFloors];
                if ([floorsData isKindOfClass:[NSArray class]]) {
                    comment.floors = [NSMutableArray array];
                    for (NSDictionary *floorDic in floorsData) {
                        SNNewsComment *floorComment = [[SNNewsComment alloc] init];
                        floorComment.commentId = [floorDic stringValueForKey:kCommentId defaultValue:@""];
                        floorComment.author    = [floorDic objectForKey:kAuthor];
                        floorComment.passport  = [floorDic objectForKey:kPassport];
                        floorComment.linkStyle = [floorDic objectForKey:kLinkStyle];
                        floorComment.spaceLink = [floorDic objectForKey:kSpaceLink];
                        floorComment.pid       = [floorDic stringValueForKey:kPid defaultValue:nil];
                        floorComment.city      = [floorDic objectForKey:kCity];
                        floorComment.content   = [commentDic stringValueForKey:kContent defaultValue:@""];
                        floorComment.replyNum  = [floorDic objectForKey:kReplyNum];
                        NSNumber *dNum         = [floorDic objectForKey:kDigNum];
                        floorComment.digNum    = [dNum stringValue];
                        floorComment.from      = [floorDic objectForKey:kFrom];
                        floorComment.ctime     = [floorDic objectForKey:kCtime];
                        floorComment.topicId   = [aData objectForKey:kTopicId];
                        NSString *status  = [floorDic stringValueForKey:kStatus defaultValue:nil];
                        floorComment.status    = [status intValue];
                        floorComment.isAuthor = self.isAuthor;
//                        floorComment.badgeListArray = commentDic[kBadgeList];
                        [self filterHTML:floorComment];
                        [comment.floors addObject:floorComment];
                    }
                }
                [self.comments addObject:comment];
            }
        }
        
        if ([commentData isKindOfClass:[NSArray class]] && [(NSArray *)commentData count] == KPaginationNum) {
            self.loadPageNum++;
            self.hasMore = YES;
        } else {
            self.hasMore = NO;
        }
    } else {
        self.hasMore = NO;
    }
}

- (void)addCommentsData:(NSMutableArray *)commentItems
{
    if ([commentItems count] > 0) {
        if (_loadHistory) {
            [self.comments addObjectsFromArray:commentItems];
        } else {
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, commentItems.count)];
            [self.comments insertObjects:commentItems atIndexes:set];
        }
    }
}

- (void)addCommentItem:(SNNewsComment *)comment items:(NSMutableArray *)items
{
    //没有重复加入显示列表
    if (![self hasEqualComment:comment searchArray:self.comments] &&
        ![self hasEqualComment:comment searchArray:items]) {
        
        SNFloorCommentItem *commentItem = [[SNFloorCommentItem alloc]initWithComment:comment];
        commentItem.newsId = self.newsId;
        commentItem.isAuthor = self.isAuthor;
        [items addObject:commentItem];

    }
}

- (BOOL)hasEqualComment:(SNNewsComment *)comment searchArray:(NSArray *)array {
    BOOL isHasSame = NO;
    for (SNFloorCommentItem *item in array) {
        if (item && item.comment && [item.comment isKindOfClass:[SNNewsComment class]]) {
            SNNewsComment *toComment = (SNNewsComment *)item.comment;
            if ((comment.commentId.length > 0 && toComment.commentId.length > 0 &&
                [comment.commentId isEqualToString:toComment.commentId]) ||
                (comment.userComtId.length > 0 && toComment.userComtId.length > 0 &&
                 [comment.userComtId isEqualToString:toComment.userComtId])) {
                isHasSame = YES;
                break;
            }
        }
    }
    return isHasSame;
}

- (void)insertMyComments {
    //my comment
    NSString *nId = _newsId ? _newsId : _gid;
    NSArray *newsCommentList = [[SNDBManager currentDataBase] getNewsCommentByNewsId:nId];
    //SNDebugLog(_newsId);
    NSMutableArray *myComments = nil;
    
    if ([newsCommentList count] > 0) {
        myComments = [NSMutableArray array];
        int cnt = (int)newsCommentList.count;
        for (int i = cnt-1; i >= 0; --i) {
            NewsCommentItem *item = [newsCommentList objectAtIndex:i];
            SNNewsComment *comment = nil;
            if ([item.type isEqualToString:@"reply"]) {
                comment = [self jsonStringToComment:item.content topicId:nil];
                comment.userComtId = item.userComtId;
                
                //发布新评论缓存增加评论ID
                if (!comment.commentId) {
                    comment.commentId = [NSString stringWithUUID];
                    comment.isCache = YES;
                }
            } else {
                comment = [[SNNewsComment alloc] init];
                comment.ctime = item.ctime;
                comment.author = item.author;
                comment.passport = item.passport;
                comment.linkStyle = item.linkStyle;
                comment.spaceLink = item.spaceLink;
                comment.pid       = item.pid;
                comment.content = item.content;
                comment.digNum = item.digNum;
                comment.hadDing = item.hadDing;
                comment.cid = item.ID;
                comment.authorimg = item.authorImage;
                comment.commentAudUrl = item.audioPath;
                comment.commentAudLen = [item.audioDuration intValue];
                comment.userComtId = item.userComtId;
                comment.passport = [[SNUserinfo userinfo] getUsername];
                comment.commentImageSmall = item.imagePath;
                comment.commentImage = item.imagePath;
                comment.commentImageBig = item.imagePath;
            }
            
            SNFloorCommentItem *commentItem = [[SNFloorCommentItem alloc]initWithComment:comment];
            commentItem.newsId = self.newsId;
            commentItem.isAuthor = self.isAuthor;
 
            [myComments insertObject:commentItem atIndex:0];
            
        }
        
        //合并前做去重操作
        //2012 12 12 by diaochunmeng
        NSMutableArray* delArray = [NSMutableArray arrayWithCapacity:0];
        for(NSInteger i= [myComments count] - 1; i>=0; i--)
        {
            SNFloorCommentItem *myCommentItem = (SNFloorCommentItem*)[myComments objectAtIndex:i];
            SNNewsComment *myobj = myCommentItem.comment;
            for(NSInteger j=0; j<[self.comments count]; j++)
            {
                SNFloorCommentItem *commentItem = (SNFloorCommentItem*)[self.comments objectAtIndex:j];
                SNNewsComment *objreal = commentItem.comment;
                if([SNNewsComment IsEqualObject:myobj obj2:objreal])
                {
                    if([myobj hasImage] && ![SNAPI isWebURL:objreal.commentImageSmall])
                    {
                        NSData* image = [[TTURLCache sharedCache] dataForURL:myobj.commentImageSmall];
                        if(image)
                        {
                            if(objreal.commentImageSmall)
                                [[TTURLCache sharedCache] storeData:image forURL:objreal.commentImageSmall];
                            if(objreal.commentImage)
                                [[TTURLCache sharedCache] storeData:image forURL:objreal.commentImage];
                            if(objreal.commentImageBig)
                                [[TTURLCache sharedCache] storeData:image forURL:objreal.commentImageBig];
                            //删除缓存会导致先出现默认图再去加载原图
//                            [[TTURLCache sharedCache] removeURL:myobj.commentImageSmall fromDisk:YES];
//                            [[TTURLCache sharedCache] removeURL:myobj.commentImage fromDisk:YES];
//                            [[TTURLCache sharedCache] removeURL:myobj.commentImageBig fromDisk:YES];
                        }
                    }
                    if(myobj.commentAudUrl.length > 0 && ![SNAPI isWebURL:myobj.commentAudUrl])
                    {
                        NSData* data = [[TTURLCache sharedCache] dataForURL:myobj.commentAudUrl];
                        if(data)
                        {
                            if(objreal.commentAudUrl)
                            {
                                [[TTURLCache sharedCache] storeData:data forKey:objreal.commentAudUrl];
                            }
                            objreal.commentAudLen = myobj.commentAudLen;
                            [[TTURLCache sharedCache] removeURL:myobj.commentAudUrl fromDisk:YES];
                        }
                    }
                    [delArray addObject:myCommentItem];
                    [[SNDBManager currentDataBase] deleteNewsCommentByctime:myobj.ctime];
                    //break;
                }
            }
        }
        if([delArray count]>0)
            [myComments removeObjectsInArray:delArray];
        
        //如果合并后的myComments队列长度为0 返回不继续合并了
        if([myComments count]==0)
            return;
        
        NSMutableArray *array = [NSMutableArray array];
        int m = 0, n = 0;
        for (int i = 0; i < self.comments.count + myComments.count; ++i) {
            if (m < self.comments.count && n < myComments.count) {
                SNFloorCommentItem *comment1 = [self.comments objectAtIndex:m];
                SNFloorCommentItem *comment2 = [myComments objectAtIndex:n];
                
                if (comment1.comment.ctime &&
                    comment2.comment.ctime &&
                    ([comment1.comment.ctime doubleValue] > [comment2.comment.ctime doubleValue])) {
                    [array addObject:comment1];
                    ++m;
                } else {
                    [array addObject:comment2];
                    ++n;
                }
                continue;
            } else {
                for (; m < self.comments.count; ++m) {
                    [array addObject:[self.comments objectAtIndex:m]];
                }
                for (; n < myComments.count; ++n) {
                    [array addObject:[myComments objectAtIndex:n]];
                }
                break;
            }
        }
        self.comments = array;
    }
}

//过滤html
- (void)filterHTML:(SNNewsComment *)c {
    if ([c.content isKindOfClass:[NSString class]]) {
        @autoreleasepool {
            c.content = [c.content stringByReplacingOccurrencesOfRegex:@"<[^<|>]*>" withString:@""];
            c.content = [c.content gtm_stringByUnescapingFromHTML];
        }
    }
}

//#pragma mark - TTURLRequestDelegate
//- (void)requestDidStartLoad:(TTURLRequest*)request
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidStartLoad:)])
//    {
//        [self.delegate performSelectorOnMainThread:@selector(commentListModelDidStartLoad:)
//                                        withObject:self
//                                     waitUntilDone:[NSThread isMainThread]];
//    }
//}
//
//- (void)requestDidFinishLoad:(TTURLRequest*)request
//{
//    _isLoading = NO;
//    SNURLJSONResponse *dataResponse = (SNURLJSONResponse *)_request.response;
//	id rootData = dataResponse.rootObject;
//    
//    if (rootData && [rootData isKindOfClass:[NSDictionary class]])
//    {
//        NSMutableDictionary *params = [NSMutableDictionary dictionary];
//        [params setObject:_request forKey:@"kCurrentRequest"];
//        [params setObject:rootData forKey:@"kRootData"];
//        
//        //快速滑动组图时闪退  modify by wangyy
//        // should be DISPATCH_QUEUE_SERIAL , not DISPATCH_QUEUE_CONCURRENT
//        if (!_commentQueue) {
//            _commentQueue = dispatch_queue_create([@"COMMENTPARSE_QUEUE_T" UTF8String], DISPATCH_QUEUE_SERIAL);
//        }
//        dispatch_async(_commentQueue, ^{
//            [self parseDataFromCursorRequest:params];
//            //更新取最新评论时间
//            if (!_loadHistory)
//                self.lastRefreshDate = [NSDate date];
//
//        });
//
////        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//////            [self parseDataFromPageRequest:params];
////            [self parseDataFromCursorRequest:params];
////            //更新取最新评论时间
////            if (!_loadHistory)
////                self.lastRefreshDate = [NSDate date];
////        });
//	}
//    else
//    {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(commentListModelDidFailToLoadWithError:)])
//        {
//            self.lastErrorCode = kCommentErrorCodeNoData;
//            [self.delegate performSelectorOnMainThread:@selector(commentListModelDidFailToLoadWithError:)
//                                            withObject:self
//                                         waitUntilDone:[NSThread isMainThread]];
//        }
//	}
//}

//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
//{
//    _isLoading = NO;
//    self.lastErrorCode = (int)error.code;
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
//
//- (void)requestDidCancelLoad:(TTURLRequest*)request {
//    _isLoading = NO;
//}

@end


