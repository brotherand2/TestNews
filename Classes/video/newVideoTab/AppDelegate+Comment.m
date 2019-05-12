//
//  AppDelegate+Comment.m
//  iPhoneVideo
//
//  Created by LHL on 15/12/14.
//  Copyright © 2015年 SOHU. All rights reserved.
//

#import "AppDelegate+Comment.h"
#import "SNNewVideosTabExtended.h"
#import "SNUserManager.h"
#import "AFNetworking.h"
#import "ASIFormDataRequest.h"
#import "NSObject+YAJL.h"
#import "SNPostConmentRequest.h"

static const char *AppDelegate_Comment_PostCompletionBlock = "AppDelegate_Comment_PostCompletionBlock";
static const char *AppDelegate_Comment_GetCompletionBlock = "AppDelegate_Comment_GetCompletionBlock";
static const char *AppDelegate_Comment_PostFailtureBlock = "AppDelegate_Comment_PostFailtureBlock";
static const char *AppDelegate_Comment_GetFailtureBlock = "AppDelegate_Comment_GetFailtureBlock";
static const char *AppDelegate_Comment_CurrentPage = "AppDelegate_Comment_CurrentPage";


@implementation sohunewsAppDelegate (Comment)



- (CommentPostCommpletionBlock)commentPostCommpletionBlock {
    return objc_getAssociatedObject(self, &AppDelegate_Comment_PostCompletionBlock);
}

- (void)setCommentPostCommpletionBlock:(CommentPostCommpletionBlock)commentPostCommpletionBlock{
    [self willChangeValueForKey:@"commentPostCommpletionBlock"];
    objc_setAssociatedObject(self,
                             &AppDelegate_Comment_PostCompletionBlock,
                             commentPostCommpletionBlock,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"commentPostCommpletionBlock"];
}

- (CommentGetCommpletionBlock)commentGetCommpletionBlock {
    return objc_getAssociatedObject(self, &AppDelegate_Comment_GetCompletionBlock);
}

- (void)setCommentGetCommpletionBlock:(CommentGetCommpletionBlock)commentGetCommpletionBlock{
    [self willChangeValueForKey:@"commentGetCommpletionBlock"];
    objc_setAssociatedObject(self,
                             &AppDelegate_Comment_GetCompletionBlock,
                             commentGetCommpletionBlock,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"commentGetCommpletionBlock"];
}



- (CommentPostFailtureBlock)commentPostFailtureBlock {
    return objc_getAssociatedObject(self, &AppDelegate_Comment_PostFailtureBlock);
}

- (void)setCommentPostFailtureBlock:(CommentPostFailtureBlock)commentPostFailtureBlock{
    [self willChangeValueForKey:@"commentPostFailtureBlock"];
    objc_setAssociatedObject(self,
                             &AppDelegate_Comment_PostFailtureBlock,
                             commentPostFailtureBlock,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"commentPostFailtureBlock"];
}

- (CommentGetFailtureBlock)commentGetFailtureBlock {
    return objc_getAssociatedObject(self, &AppDelegate_Comment_GetFailtureBlock);
}

- (void)setCommentGetFailtureBlock:(CommentGetFailtureBlock)commentGetFailtureBlock{
    [self willChangeValueForKey:@"commentGetFailtureBlock"];
    objc_setAssociatedObject(self,
                             &AppDelegate_Comment_GetFailtureBlock,
                             commentGetFailtureBlock,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"commentGetFailtureBlock"];
}

- (NSInteger)commentCurrentPage{
    return [objc_getAssociatedObject(self, &AppDelegate_Comment_CurrentPage) integerValue];
}

- (void)setCommentCurrentPage:(NSInteger)commentCurrentPage{
    [self willChangeValueForKey:@"commentCurrentPage"];
    objc_setAssociatedObject(self,
                             &AppDelegate_Comment_CurrentPage,
                             @(commentCurrentPage),
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"commentCurrentPage"];
}



/**
 *  发送评论
 *
 *  @param topicId                     帖子id
 *  @param commentText                 评论的内容
 *  @param commentPostCommpletionBlock 发布成功后回调
 *  @param commentPostFailtureBlock    发布失败后回调
 */
- (void)postCommentRequestWithTopicId:(NSString *)topicId
                                title:(NSString *)title
                             videoUrl:(NSString *)videoUrl
                          commentText:(NSString *)commentText
          commentPostCommpletionBlock:(CommentPostCommpletionBlock)commentPostCommpletionBlock
             commentPostFailtureBlock:(CommentPostFailtureBlock)commentPostFailtureBlock

{
    self.commentPostCommpletionBlock = commentPostCommpletionBlock;
    self.commentPostFailtureBlock = commentPostFailtureBlock;
    
    NSString *userName = [SNUserManager getNickName];
    if (userName.length == 0) {
        userName = kDefaultUserName;
    }
    
//    NSString *p1 = [SNUserManager getP1];
//    NSString *url = SNLinks_Path_Comment_UserComment;
//    url = [SNUtility addNetSafeParametersForURL:url];//追加网安监控参数
//    NSString *passport = [SNUserManager getUserId];
//    NSString *pid = [SNUserManager getPid];

    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
////    request.timeOutSeconds = 30;
//    [request setNumberOfTimesToRetryOnTimeout:1];
//    request.delegate = self;
//    if (p1) {
//        [request addPostValue:p1 forKey:@"p1"];
//    }
//    if (pid) {
//        [request addPostValue:pid forKey:@"pid"];
//    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"7" forKey:@"busiCode"];
    [params setValue:@"18" forKey:@"refer"];
    [params setValue:title forKey:@"topicTitle"];
    [params setValue:videoUrl forKey:@"topicUrl"];
    [params setValue:topicId forKey:@"topicId"];
    [params setValue:userName forKey:@"author"];
    [params setValue:[NSString stringWithFormat:@"%lld", (long long)(1000 * [[NSDate date] timeIntervalSince1970])] forKey:@"sendtime"];
    
//    [request addPostValue:@"7" forKey:@"busiCode"];
//    [request addPostValue:@"18" forKey:@"refer"];
//    [request addPostValue:title forKey:@"topicTitle"];
//    [request addPostValue:videoUrl forKey:@"topicUrl"];
//    [request addPostValue:topicId forKey:@"topicId"];
//    [request addPostValue:userName forKey:@"author"];
//    [request addPostValue:[NSString stringWithFormat:@"%lld", (long long)(1000 * [[NSDate date] timeIntervalSince1970])]
//                   forKey:@"sendtime"];
    
//    if (passport.length > 0) {
////        [request addPostValue:passport forKey:kPassport];
//        [params setValue:passport forKey:kPassport];
//    }
    

    if (commentText) {
        [params setValue:commentText forKey:@"cont"];
        [params setValue:@"text" forKey:@"contType"];
//            [request addPostValue:commentText forKey:@"cont"];
//            [request addPostValue:@"text" forKey:@"contType"];
    }
    
//    [request startAsynchronous];
    
    
    [[[SNPostConmentRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            SNDebugLog(@"%@", responseObject);
            NSString *isSuccess = [responseObject stringValueForKey:@"isSuccess" defaultValue:nil];
            if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
            } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
                NSString *errCode = [responseObject stringValueForKey:@"error" defaultValue:nil];
                SNDebugLog(@"%@",errCode);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
    
    if (self.commentPostCommpletionBlock) {
        self.commentPostCommpletionBlock(@{@"id":@"123456"});
    }

    
}
//#pragma mark - asi http delegate
//- (void)requestFinished:(ASIHTTPRequest *)request {
//    
//    SNDebugLog(@"%d, %@", request.responseStatusCode, request.responseString);
//    NSString *errCode = nil;
//    
//    NSString *jsonString = [[request responseString] copy];
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    id rootData = [jsonData yajl_JSON];
//    
//    if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
//        SNDebugLog(@"%@", rootData);
//        NSString *isSuccess = [rootData stringValueForKey:@"isSuccess" defaultValue:nil];
//        if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
//        } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
//            errCode = [rootData stringValueForKey:@"error" defaultValue:nil];
//        }
//    }
//    
//    [jsonString release];
//}
//
//- (void)requestFailed:(ASIHTTPRequest *)request {
//    
//    SNDebugLog(@"%d, %@", request.responseStatusCode, request);
////    if (self.commentPostFailtureBlock) {
////        self.commentPostFailtureBlock(nil);
////    }
//    
//}

/**
 *  加载评论列表
 *
 *  @param vid                        视频id
 *  @param cid                        视频来源id
 *  @param site                       和搜狐视频vid绑定（1：vrs数据，2：ugc数据）
 *  @param more                       是否是加载更多，即是否是加载第一页评论和更多页评论
 *  @param commentGetCommpletionBlock 获取评论完成后回调
 *  @param commentGetFailtureBlock    获取评论失败回调
 */
- (void)getLoadPageCommentAndTopicVid:(NSNumber *)vid
                                  cid:(NSNumber *)cid
                                 site:(NSNumber *)site
                                title:(NSString *)title
                        lastCommentId:(NSNumber *)lastCommentId
                             videoUrl:(NSString *)videoUrl
                                 more:(BOOL)more
           commentGetCommpletionBlock:(CommentGetCommpletionBlock)commentGetCommpletionBlock
              commentGetFailtureBlock:(CommentGetFailtureBlock)commentGetFailtureBlock

{
    self.commentGetCommpletionBlock = commentGetCommpletionBlock;
    self.commentGetFailtureBlock = commentGetFailtureBlock;
    
    [SNNewVideosTabExtended getCommentWithTopicVid:[vid longLongValue] cid:[cid longValue] site:[site longValue] lastCommentId:(NSNumber *)lastCommentId more:more success:^(id responseObject) {
        
        NSDictionary *_responseObject = responseObject;
        
        if (_responseObject && [_responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *response = _responseObject[@"response"];
            if (response && [response isKindOfClass:[NSDictionary class]]) {
                CommentModel *item = [[CommentModel alloc] initWithDic:[SNNewVideosTabExtended returnCommentListDic:response]];
                if (self.commentGetCommpletionBlock) {
                    self.commentGetCommpletionBlock(more, item);
                }
                [item release];
            }else{
                if (self.commentGetFailtureBlock) {
                    self.commentGetFailtureBlock(more, nil);
                }
            }
        }else{
            if (self.commentGetFailtureBlock) {
                self.commentGetFailtureBlock(more, nil);
            }
        }
        
    } failure:^(id responseObject) {
        if (self.commentGetFailtureBlock) {
            self.commentGetFailtureBlock(NO, nil);
        }
    }];
}


@end
