//
//  SNCommentManager.m
//  sohunews
//
//  Created by Dan Cong on 8/28/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNCommentManager.h"
#import "SNASIRequest.h"
#import "DesBase64EncryptUtil.h"
#import "ASIFormDataRequest.h"
#import "SNUserManager.h"
#import "NSJSONSerialization+String.h"
#import "SNDelCommentRequest.h"

static NSMutableArray *_delegates = nil;

@implementation SNCommentManager

+ (SNCommentManager *)defaultManager {
    static SNCommentManager *_defaultManager = nil;

    @synchronized (self) {
        if (!_defaultManager) {
            _defaultManager = [[SNCommentManager alloc] init];
            _delegates = [[NSMutableArray alloc] init];
        }
    }
    return _defaultManager;
}

- (void)sendDeleteCommentRequestByCommentId:(NSString *)commentId theId:(NSString *)theId subId:(NSString *)subId busiCode:(NSString *)busiCode
{
    if (commentId.length > 0) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
        [params setValue:busiCode forKey:@"busiCode"];
        [params setValue:theId forKey:@"id"];
        [params setValue:commentId forKey:@"comtId"];
        if (subId.length > 0) {
            [params setValue:subId forKey:@"subId"];
        }
        NSString *passport = [SNUserManager getUserId];
        if (passport.length > 0) {
            [params setValue:passport forKey:@"passport"];
        }
        
        [[[SNDelCommentRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
            NSString *result = [responseObject objectForKey:@"isSuccess"];
            if ([result isEqualToString:@"S"]) {
                
            } else {
                
            }
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            
        }];
    }
    
    
//    [ASIFormDataRequest setShouldUpdateNetworkActivityIndicator:NO];
//    NSString *_urlString = nil;
//    if (commentId.length > 0) {
//        _urlString = kUrlDeleteComment;
//    } else {
//        SNDebugLog(@"===INFO: commentId is nil");
//        return;
//    }
//    
//    //post 方式请求删除评论
//    ASIFormDataRequest *_request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_urlString]];
//    SNDebugLog(@"===INFO: sendDeleteCommentRequest from url : %@", _request.url.absoluteString);
//    [_request setValidatesSecureCertificate:NO];
//    [_request setPostValue:busiCode forKey:@"busiCode"];
//    [_request setPostValue:theId forKey:@"id"];
//    [_request setPostValue:commentId forKey:@"comtId"];
//    if (subId.length > 0) {
//        [_request setPostValue:subId forKey:@"subId"];
//    }
//    [_request setPostValue:[SNUtility getP1] forKey:@"p1"];
//    [_request setPostValue:[DesBase64EncryptUtil encryptWithText:[SNUserManager getUserId]] forKey:@"passport"];
//    [_request setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
//    _request.defaultResponseEncoding = NSUTF8StringEncoding;
//    [_request startSynchronous];
//    
//    NSString *jsonString = [_request responseString];
//    if (!jsonString || [@"" isEqualToString:jsonString]) {
//        return;
//    } else {
//        SNDebugLog(@"===INFO: jsonstring:%@", jsonString);
//    }
//    
//    NSDictionary *rootData = [NSJSONSerialization JSONObjectWithString:jsonString
//                                                               options:NSJSONReadingMutableLeaves
//                                                                 error:NULL];
//    if (rootData) {
//        NSString *result = [rootData objectForKey:@"isSuccess"];
//        if ([result isEqualToString:@"S"]) {
//            
//        } else {
//            
//        }
//    }
}

////retain返回单例本身
//- (id)retain
//{
//    return self;
//}
////引用计数总是为1
//- (NSUInteger)retainCount
//{
//    return 1;
//}
////release不做任何处理
//- (oneway void)release
//{
//    
//}
////autorelease返回单例本身
//- (id)autorelease
//{
//    return self;
//}

@end
