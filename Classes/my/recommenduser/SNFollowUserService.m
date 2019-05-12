//
//  SNFollowUserService.m
//  sohunews
//
//  Created by lhp on 6/28/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNFollowUserService.h"
#import "SNURLJSONResponse.h"
#import "SNSubscribeCenterService.h"
#import "SNRelationOptRequest.h"

@interface SNFollowUserService ()

@end

@implementation SNFollowUserService
@synthesize delegate = _delegate;


- (void)cancelFollowUserWithFpid:(NSString *) idString{
    
    _requestType = SNRequestTypeCancelFollow;
    
    if (!idString) {
        
        if ([_delegate respondsToSelector:@selector(followedUserFailWithError:requestType:)]) {
            [_delegate followedUserFailWithError:nil requestType:_requestType];
        }
        return;
    }
    
//    NSString *url = [NSString stringWithFormat:kCancelFollowUserByPId,idString];
//    url = [SNUtility addParamsToURLForReadingCircle: url];
//    [self sendRequestWithUrl:url];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:@"cancelfollow" forKey:@"action"];
    [params setValue:idString forKey:@"fpid"];
    
    [[[SNRelationOptRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        // 无论关注还是取消关注某个用户  需要刷一下我的订阅 以保证与服务器的数据同步
        [[SNSubscribeCenterService defaultService] loadMySubFromServer];
        
        if ([_delegate respondsToSelector:@selector(followedUserSucceedWithType:)]) {
            [_delegate followedUserSucceedWithType:_requestType];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if ([_delegate respondsToSelector:@selector(followedUserFailWithError:requestType:)]) {
            [_delegate followedUserFailWithError:error requestType:_requestType];
        }
    }];
}

- (void)followUserWithFpid:(NSString *) idString{
    
    _requestType = SNRequestTypeAddFollow;
    
    if (!idString) {
        if ([_delegate respondsToSelector:@selector(followedUserFailWithError:requestType:)]) {
            [_delegate followedUserFailWithError:nil requestType:_requestType];
        }
        return;
    }
        
//    NSString *url = [NSString stringWithFormat:kFollowUserByPId,idString];
//    url = [SNUtility addParamsToURLForReadingCircle: url];
//    [self sendRequestWithUrl:url];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:@"addfollow" forKey:@"action"];
    [params setValue:idString forKey:@"fpid"];
    
    [[[SNRelationOptRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        // 无论关注还是取消关注某个用户  需要刷一下我的订阅 以保证与服务器的数据同步
        [[SNSubscribeCenterService defaultService] loadMySubFromServer];
        
        if ([_delegate respondsToSelector:@selector(followedUserSucceedWithType:)]) {
            [_delegate followedUserSucceedWithType:_requestType];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if ([_delegate respondsToSelector:@selector(followedUserFailWithError:requestType:)]) {
            [_delegate followedUserFailWithError:error requestType:_requestType];
        }
    }];
}

//- (void)sendRequestWithUrl:(NSString *) urlString{
//    
//    if (!_request) {
//        _request = [SNURLRequest requestWithURL:urlString delegate:self];
//        _request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    } else {
//        if (![_request.delegates containsObject:self]) {
//            [_request.delegates addObject:self];
//        }
//        _request.urlPath = urlString;
//    }
//    _request.response = [[SNURLJSONResponse alloc] init];
//    [_request send];
//}

- (void)cancelFollowRequest{
    
//    if (_request) {
//        [_request cancel];
//         //(_request);
//    }
}

#pragma mark - TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    // 无论关注还是取消关注某个用户  需要刷一下我的订阅 以保证与服务器的数据同步
    [[SNSubscribeCenterService defaultService] loadMySubFromServer];
    
    if ([_delegate respondsToSelector:@selector(followedUserSucceedWithType:)]) {
        [_delegate followedUserSucceedWithType:_requestType];
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    if ([_delegate respondsToSelector:@selector(followedUserFailWithError:requestType:)]) {
        [_delegate followedUserFailWithError:error requestType:_requestType];
    }
}

- (void)dealloc{
    
//    if (_request) {
//        [_request cancel];
//         //(_request);
//    }
}

@end
