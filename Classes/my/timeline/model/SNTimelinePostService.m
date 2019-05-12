//
//  SNTimelinePostService.m
//  sohunews
//
//  Created by jojo on 13-6-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelinePostService.h"
#import "NSObject+YAJL.h"
#import "SNStatusBarMessageCenter.h"
#import "SNUserManager.h"
#import "SNDBManager.h"
#import "SNTimelineConfigs.h"


#define kTopicShareToTimeline           (@"分享阅读圈")
#define kTopicPostCommentToTimeline     (@"评论发表")
#define kTopicReplyCommentToTimeline    (@"回复评论")
#define kTopicDeleteTrend               (@"删除动态")
#define kTopicApprovalTimeline          (@"赞")
#define kTopicCancelApprovalTimeline    (@"取消赞")

#define kTrendApprovalParam (@"userActV2?action=topAct&actId=%@&isTop=%d&pid=%@")

@interface SNTimelinePostResponse : NSObject<TTURLResponse>

@property(nonatomic, copy) NSString *dataId;
@property(nonatomic, strong) NSDictionary *allHeaderFields;
@property(nonatomic, assign) NSInteger statusCode;

@end

@implementation SNTimelinePostResponse
@synthesize dataId = _dataId;
@synthesize allHeaderFields = _allHeaderFields;
@synthesize statusCode = _statusCode;

- (void)dealloc {
     //(_dataId);
     //(_allHeaderFields);
}

- (NSError*)request:(TTURLRequest*)request
    processResponse:(NSHTTPURLResponse*)response
               data:(id)data {
    NSError *error = nil;
    
    self.statusCode = response.statusCode;
    self.allHeaderFields = response.allHeaderFields;
    
    // 返回200 发送成功
    if (self.statusCode == 200)
        self.dataId = [[response allHeaderFields] stringValueForKey:@"X-LinkedIn-Id" defaultValue:nil];
    // 服务器请求失败
    else
        error = [NSError errorWithDomain:@"request failed" code:response.statusCode userInfo:nil];
    
    return error;
}

@end

@implementation SNTimelinePostService

+ (SNTimelinePostService *)sharedService {
    static SNTimelinePostService *__gInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __gInstance = [SNTimelinePostService new];
    });
    return __gInstance;
}

- (void)timelineShareWithContent:(NSString *)content
                     originContent:(SNTimelineOriginContentObject *)originContent
                       fromShareId:(NSString *)shareId {
    
    if (!originContent) {
        SNDebugLog(@"%@-%@:invalidate arguments", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
    
    NSDictionary *baseInfoDic = [SNUtility paramsDictionaryForReadingCircle];
    if (baseInfoDic)
        [bodyDic setObject:baseInfoDic forKey:@"baseInfo"];
    
    NSString *userName = [SNUserManager  getNickName];
    
//    SNUserinfoEx* obj = (SNUserinfoEx*)[SNUserinfoEx userinfo];
//    
//    if(obj._nickname != nil && [obj._nickname length] > 0)
//        userName = obj._nickname;
//    else if(obj._username != nil)
//        userName = obj._username;
//    else if(obj._uid != nil)
//        userName = obj._uid;
    
    if (userName)
        [bodyDic setObject:userName forKey:@"nickName"];
    
    [bodyDic setObject:content ? content : @"" forKey:kShareInfoKeyContent];
    
    if ([SNUserManager getPid])
        [bodyDic setObject:[SNUserManager getPid] forKey:@"pid"];
    
    if (shareId)
        [bodyDic setObject:shareId forKey:@"fromShareId"];
    
    NSDictionary *originDic = [originContent toDictionary];
    if (originDic)
        [bodyDic setObject:originDic forKey:@"originContent"];
    
    NSString *bodyString = [bodyDic yajl_JSONString];
    SNDebugLog(@"%@-%@ : json string :\n%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), bodyString);
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@share/shareInfo", kTimelineServer];
    SNURLRequest *request = [SNURLRequest requestWithURL:requestUrl delegate:self];
    request.contentType = @"application/json";
    request.httpMethod = @"POST";
    request.timeOut = 30;
    request.cachePolicy = TTURLRequestCachePolicyNoCache;
    request.httpBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [[request headers] setObject:@"CREATE" forKey:@"X-RestLi-Method"];
    request.userInfo = [TTUserInfo topic:kTopicShareToTimeline];
    request.response = [[SNTimelinePostResponse alloc] init];

    [request send];
}

- (void)timelinePostComment:(NSString *)commentContent
                      actId:(NSString *)actId
                       spid:(NSString *)spid {
    if (commentContent.length == 0 ||
        actId.length == 0) {
        SNDebugLog(@"%@-%@:invalidate arguments", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    // 本地评论假数据
    NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
    [commentDic setObject:commentContent forKey:kShareInfoKeyContent];
    [commentDic setObject:actId forKey:@"actId"];
    if (spid)[commentDic setObject:spid forKey:@"spid"];
    //SNUserinfoEx* obj = (SNUserinfoEx*)[SNUserinfoEx userinfo];
    
    NSString *userName = [SNUserManager getNickName];
    
//    if(obj._nickname != nil && [obj._nickname length] > 0)
//        userName = obj._nickname;
//    else if(obj._username != nil)
//        userName = obj._username;
//    else if(obj._uid != nil)
//        userName = obj._uid;
    
    if (userName) {
        [commentDic setObject:userName forKey:@"author"];
    }
    if ([SNUserManager getPid]) {
        [commentDic setObject:[SNUserManager getPid] forKey:@"pid"];
    }
    
    
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
    
    NSDictionary *baseInfoDic = [SNUtility paramsDictionaryForReadingCircle];
    if (baseInfoDic)
        [bodyDic setObject:baseInfoDic forKey:@"baseInfo"];
    
    [bodyDic setObject:commentContent forKey:kShareInfoKeyContent];
    [bodyDic setObject:actId forKey:@"actId"];
    [bodyDic setObject:@"1" forKey:@"commentType"]; // 对分享评论是 1；  对人评论进行回复是2；
    if (spid)[bodyDic setObject:spid forKey:@"spid"];
    
    NSString *bodyString = [bodyDic yajl_JSONString];
    SNDebugLog(@"%@-%@ : json string :\n%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), bodyString);
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@commentV2", kCircleTimelineServer];
    SNURLRequest *request = [SNURLRequest requestWithURL:requestUrl delegate:self];
    request.contentType = @"application/json";
    request.httpMethod = @"POST";
    request.timeOut = 30;
    request.cachePolicy = TTURLRequestCachePolicyNoCache;
    request.httpBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [[request headers] setObject:@"CREATE" forKey:@"X-RestLi-Method"];
    request.userInfo = [TTUserInfo topic:kTopicPostCommentToTimeline strongRef:commentDic weakRef:nil];
    request.response = [[SNTimelinePostResponse alloc] init];
    
    [request send];
}

- (void)timelineReplyComment:(NSString *)replyContent
                       actId:(NSString *)actId
                        spid:(NSString *)spid
                   commentId:(NSString *)commentId
                        fpid:(NSString *)fpid
                   fnickName:(NSString *)fnickName {
    if (replyContent.length == 0 ||
        actId.length == 0 ||
        commentId.length == 0 ||
        fpid.length == 0 ||
        fnickName.length == 0) {
        SNDebugLog(@"%@-%@:invalidate arguments", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    // 本地评论假数据
    NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
    [commentDic setObject:replyContent forKey:kShareInfoKeyContent];
    [commentDic setObject:actId forKey:@"actId"];
    [commentDic setObject:commentId forKey:@"commentId"];
    [commentDic setObject:fpid forKey:@"fpid"];
    if (spid) {
        [commentDic setObject:spid forKey:@"spid"];
    }
    [commentDic setObject:fnickName forKey:@"fnickName"];
    
    //SNUserinfoEx* obj = (SNUserinfoEx*)[SNUserinfoEx userinfo];
    
    NSString *userName = [SNUserManager getNickName];
    
//    if(obj._nickname != nil && [obj._nickname length] > 0)
//        userName = obj._nickname;
//    else if(obj._username != nil)
//        userName = obj._username;
//    else if(obj._uid != nil)
//        userName = obj._uid;
    
    if (userName) {
        [commentDic setObject:userName forKey:@"author"];
    }
    if ([SNUserManager getPid]) {
        [commentDic setObject:[SNUserManager getPid] forKey:@"pid"];
    }
    
    
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
    
    NSDictionary *baseInfoDic = [SNUtility paramsDictionaryForReadingCircle];
    if (baseInfoDic)
        [bodyDic setObject:baseInfoDic forKey:@"baseInfo"];
    
    [bodyDic setObject:replyContent forKey:kShareInfoKeyContent];
    [bodyDic setObject:actId forKey:@"actId"];
    [bodyDic setObject:@"2" forKey:@"commentType"]; // 对分享评论是 1；  对人评论进行回复是2；
    [bodyDic setObject:commentId forKey:@"commentId"];
    [bodyDic setObject:fpid forKey:@"fpid"];
    if (spid) [bodyDic setObject:spid forKey:@"spid"];
    
    NSString *bodyString = [bodyDic yajl_JSONString];
    SNDebugLog(@"%@-%@ : json string :\n%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), bodyString);
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@commentV2", kCircleTimelineServer];
    SNURLRequest *request = [SNURLRequest requestWithURL:requestUrl delegate:self];
    request.contentType = @"application/json";
    request.httpMethod = @"POST";
    request.timeOut = 30;
    request.cachePolicy = TTURLRequestCachePolicyNoCache;
    request.httpBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [[request headers] setObject:@"CREATE" forKey:@"X-RestLi-Method"];
    request.userInfo = [TTUserInfo topic:kTopicReplyCommentToTimeline strongRef:commentDic weakRef:nil];
    request.response = [[SNTimelinePostResponse alloc] init];
    
    [request send];
}

- (void)timelineDeleteTrend:(NSString *)actId
                        pid:(NSString *)pid
                   userInfo:(NSDictionary *)dic
{
    
    NSString *requestUrl = [NSString stringWithFormat:kTimelineDeleteTrendUrl, pid, actId];
    SNURLRequest *request = [SNURLRequest requestWithURL:requestUrl delegate:self];

    request.urlPath = requestUrl;
    request.timeOut = 30;
    request.cachePolicy = TTURLRequestCachePolicyNoCache;
    request.userInfo = [TTUserInfo topic:kTopicDeleteTrend strongRef:dic weakRef:nil];
    request.response = [[SNTimelinePostResponse alloc] init];
    
    [request send];
}

- (void)timelineTrendApproval:(NSString *)actId spid:(NSString *)spid approvalType:(int)type
{
    NSString *requestParam = [NSString stringWithFormat:kTrendApprovalParam, actId, type, [SNUserManager getPid]];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", kTimelineServer, requestParam];
    SNURLRequest *request = [SNURLRequest requestWithURL:requestUrl delegate:self];
    request.contentType = @"application/json";
    request.httpMethod = @"GET";
    request.timeOut = 30;
    request.cachePolicy = TTURLRequestCachePolicyNoCache;
    if (type == 1) {
        request.userInfo = [TTUserInfo topic:kTopicApprovalTimeline];
    } else if (type == 0) {
        request.userInfo = [TTUserInfo topic:kTopicCancelApprovalTimeline];
    }
    request.response = [[SNTimelinePostResponse alloc] init];
    
    [request send];
}

- (void)sohunewsShareToTrend:(NSString *)newsId
{
    
}

#pragma mark - TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest *)request {
    SNTimelinePostResponse *response = request.response;
    
    SNDebugLog(@"request response code %d \nheaders %@", response.statusCode, response.allHeaderFields);
    
    TTUserInfo *userInfo = request.userInfo;
    if (userInfo) {

        NSDictionary *dic = userInfo.strongRef;
        NSMutableDictionary *infoDic = nil;
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            infoDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
        
        if ([userInfo.topic isEqualToString:kTopicPostCommentToTimeline] || [userInfo.topic isEqualToString:kTopicReplyCommentToTimeline]) {
            NSString *msg = [NSString stringWithFormat:@"%@成功", userInfo.topic];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeSuccess];
            
            if (response.dataId) {
                [infoDic setObject:response.dataId forKey:@"dataId"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (userInfo && infoDic) {
                    [SNNotificationManager postNotificationName:kTLTrendSendCommentSucNotification
                                                                        object:nil
                                                                      userInfo:infoDic];
                }
            });
        }
        else if ([userInfo.topic isEqualToString:kTopicDeleteTrend]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (userInfo && infoDic) {
                    [SNNotificationManager postNotificationName:kTLTrendCellDeleteNotification
                                                                        object:nil
                                                                      userInfo:infoDic];
                }
            });
        }
    }
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
    TTUserInfo *userInfo = request.userInfo;
    if ([userInfo.topic isEqualToString:kTopicPostCommentToTimeline] || [userInfo.topic isEqualToString:kTopicReplyCommentToTimeline]) {
        NSString *msg = [NSString stringWithFormat:@"%@失败", userInfo.topic];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
    }
}

@end
