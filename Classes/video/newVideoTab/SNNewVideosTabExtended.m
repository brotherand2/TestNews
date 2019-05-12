//
//  SNNewVideosTabExtended.m
//  sohunews
//
//  Created by tt on 15/12/16.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNNewVideosTabExtended.h"
#import "SNUserManager.h"
//#import "AFNetworking.h"
//#import "ASIFormDataRequest.h"
#import "NSObject+YAJL.h"
#import "SNPostConmentRequest.h"
#import "SNCommentListByCursorRequest.h"

@implementation SNNewVideosTabExtended

+(void)postCommentWithTopicId:(long long)topicId
                  commentText:(NSString *)commentText
                      success:(PostCommentSuccess)success
                      failure:(PostCommentFailure)failure{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *userName = [SNUserManager getNickName];
    if (userName.length == 0) {
        userName = kDefaultUserName;
    }
//    NSString *p1 = [SNUserManager getP1];
//    NSString *url = SNLinks_Path_Comment_UserComment;
//    url = [SNUtility addNetSafeParametersForURL:url];//追加网安监控参数
//    NSString *passport = [SNUserManager getUserId];
//    NSString *pid = [SNUserManager getPid];
//    if (p1) {
//        [parameters setObject:p1 forKey:@"p1"];
//    }
//    if (pid) {
//        [parameters setObject:pid forKey:@"pid"];
//    }
    [parameters setObject:@"1" forKey:@"busiCode"];
    [parameters setObject:[NSString stringWithFormat:@"%lld",topicId] forKey:@"topicId"];
    [parameters setObject:userName forKey:@"author"];
    [parameters setObject:[NSString stringWithFormat:@"%lld", (long long)(1000 * [[NSDate date] timeIntervalSince1970])]
                   forKey:@"sendtime"];
    
//    if (passport.length > 0) {
//        [parameters setObject:passport forKey:kPassport];
//    }
    
    if (commentText) {
        [parameters setObject:commentText forKey:@"cont"];
        [parameters setObject:@"text" forKey:@"contType"];

    }
    
    [[[SNPostConmentRequest alloc] initWithDictionary:parameters] send:^(SNBaseRequest *request, id responseObject) {
        BOOL bSuccess = NO;
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (result) {
            NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
            id rootData = [jsonData yajl_JSON];
            if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
                SNDebugLog(@"%@", rootData);
                NSString *isSuccess = [rootData stringValueForKey:@"isSuccess" defaultValue:nil];
                if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
                    bSuccess = YES;
                } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
                }
            }
        }
        if (bSuccess) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSent", @"messageSent") toUrl:nil mode:SNCenterToastModeSuccess];
            [SNUtility requestRedPackerAndCoupon:nil type:@"3"];
            success(nil);
        } else {
            failure(nil);
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        failure(error);
    }];
    
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 10.f;
//    
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        BOOL bSuccess = NO;
//        if (result) {
//            NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
//            id rootData = [jsonData yajl_JSON];
//            if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
//                SNDebugLog(@"%@", rootData);
//                NSString *isSuccess = [rootData stringValueForKey:@"isSuccess" defaultValue:nil];
//                if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
//                    bSuccess = YES;
//                } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
//                }
//            }
//        }
//        if (bSuccess) {
//            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSent", @"messageSent") toUrl:nil mode:SNCenterToastModeSuccess];
//            [SNUtility requestRedPackerAndCoupon:nil type:@"3"];
//            success(nil);
//        } else {
//            failure(nil);
//        }
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        failure(error);
//    }];
//
//    
}

+(void)getCommentWithTopicVid:(long long)vid
                          cid:(long)cid
                         site:(long)site
                lastCommentId:(NSNumber *)lastCommentId
                         more:(BOOL)more
                      success:(GetCommentSuccess)success
                      failure:(GetCommentFailure)failure{
    NSString *rollType = @"1";
    if (more) {
        rollType = @"2";
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"7" forKey:@"busiCode"];
    [params setValue:[NSString stringWithFormat:@"%zd",vid] forKey:@"id"];
    [params setValue:rollType forKey:@"rollType"];
    [params setValue:@"20" forKey:@"size"];
    [params setValue:@"comment" forKey:@"source"];
    [params setValue:@"3" forKey:@"type"];
    if (lastCommentId) {
        [params setValue:lastCommentId.stringValue forKey:@"cursorId"];
    }

    [[[SNCommentListByCursorRequest alloc] initWithDictionary:params needNetSafeParameters:YES] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            SNDebugLog(@"%@", responseObject);
            NSString *isSuccess = [responseObject stringValueForKey:@"isSuccess" defaultValue:nil];
            if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
                success(responseObject);
            } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
                failure(nil);
            }
        }else{
            failure(nil);
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        failure(error);
    }];
    
//    NSString* url = [[self class] returnGetCommentUrl:more :vid];
//    if (url && url.length > 0) {
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        
//        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//         manager.requestSerializer.timeoutInterval = 10.f;
//        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
//        NSString *encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        [manager GET:encodedUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
//                SNDebugLog(@"%@", responseObject);
//                NSString *isSuccess = [responseObject stringValueForKey:@"isSuccess" defaultValue:nil];
//                if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
//                    success(responseObject);
//                } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
//                    failure(nil);
//                }
//            }else{
//                failure(nil);
//            }
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            failure(error);
//        }];
//    }else{
//        failure(nil);
//    }
}

//+(NSString*)returnGetCommentUrl:(BOOL)more :(long long)_id{
//    
//    NSString *url = nil;
//    NSString *rollType = @"1";
//    if (more) {
//        rollType = @"2";
//    }
//    NSString *p1 = [SNUserManager getP1];
//    if (p1) {
//        url = [NSString stringWithFormat:[SNAPI rootUrl:@"api/comment/getCommentListByCursor.go?busiCode=%d&id=%lld&rollType=%@&size=%d&source=comment&p1=%d&type=3"],7,_id,rollType,20,p1];
//    }else{
//        url = [NSString stringWithFormat:[SNAPI rootUrl:@"api/comment/getCommentListByCursor.go?busiCode=%d&id=%lld&rollType=%@&size=%d&source=comment&type=3"],7,_id,rollType,20];
//    }
//    return [SNUtility addNetSafeParametersForURL:url];
//    
//}

+(NSMutableDictionary* _Nonnull )returnCommentListDic:(NSDictionary* _Nonnull)response{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString  *topicId  = response[@"topicId"];
    NSString  *allCount  = response[@"allCount"];
    if (topicId) {
        [dict setObject:topicId forKey:@"topic_id"]; // 每个视频贴的主题
    }
    if (allCount) {
        [dict setObject:[NSString stringWithFormat:@"%@",allCount] forKey:@"cmt_sum"]; // 评论数
    }
    
    NSArray *array = response[@"commentList"];
    if (array && [array isKindOfClass:[NSArray class]]) {
        NSMutableArray *commentArray = [NSMutableArray array];
        for (NSDictionary *comment in array) {
            // 普通帖
            NSMutableDictionary *subComment = [NSMutableDictionary dictionary];
            
            [subComment setObject:[NSString stringWithFormat:@"%@",comment[@"content"]] forKey:@"content"];
            // 地点
            [subComment setObject:[NSString stringWithFormat:@"%@",comment[@"city"]]  forKey:@"address"];
            // 评论时间
            [subComment setObject:[NSString stringWithFormat:@"%@",comment[@"ctime"]] forKey:@"create_time"];
            // 评论的id
            [subComment setObject:[NSString stringWithFormat:@"%@",comment[@"commentId"]] forKey:@"comment_id"];
            //评论人的信息
            [subComment setObject:@{@"nickname":[NSString stringWithFormat:@"%@",comment[@"author"]],
                                    @"img_url":[NSString stringWithFormat:@"%@",comment[@"authorimg"]],
                                    @"user_id" : [NSString stringWithFormat:@"%@",comment[@"pid"]]} forKey:@"passport"];
            [commentArray addObject:subComment];
        }
        if (commentArray.count > 0) {
            [dict setObject:commentArray forKey:@"comments"];
        }
        
    }
    return dict;
}

@end
