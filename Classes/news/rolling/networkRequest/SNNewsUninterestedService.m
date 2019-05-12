//
//  SNNewsUninterestedService.m
//  sohunews
//
//  Created by lhp on 5/26/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNNewsUninterestedService.h"
#import "SNURLJSONResponse.h"
#import "SNUserManager.h"

@interface SNNewsUninterestedService ()
{
    NSMutableDictionary *requestDic;
    NSMutableDictionary *requestFailDic;
}
@end


@implementation SNNewsUninterestedService

+ (SNNewsUninterestedService *)sharedInstance {
    static SNNewsUninterestedService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNNewsUninterestedService alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        requestDic = [[NSMutableDictionary alloc] init];
        requestFailDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)uninterestedNewsWithType:(NSString *) newsType newsId:(NSString *) idString
{
    if (!idString) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([SNUserManager getP1]) {
        [params setObject:[SNUserManager getP1] forKey:@"p1"];
    }
    if (idString) {
        [params setObject:idString forKey:@"id"];
    }
    if (newsType) {
        [params setObject:newsType forKey:@"type"];
    }
    [params setObject:@"1" forKey:@"act"];
    
    NSMutableString* postBodyString = [NSMutableString stringWithString:@""];
    for (NSString *key in [params allKeys]) {
        NSString* p = [NSString stringWithFormat:@"%@=%@",key,[[params valueForKey:key] URLEncodedString]];
        if([postBodyString length]==0)
            [postBodyString appendString:p];
        else
            postBodyString = [NSMutableString stringWithFormat:@"%@&%@",postBodyString,p];
    }
   
    NSString *keyString = [SNUtility CreateUUID];
    TTURLRequest *uninterestedRequest = [TTURLRequest requestWithURL:kNewsUninterestedUrl delegate:self];
    uninterestedRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    uninterestedRequest.response = [[SNURLJSONResponse alloc] init];
    [uninterestedRequest setHttpMethod:@"POST"];
    [uninterestedRequest setContentType:@"application/x-www-form-urlencoded"];
    [uninterestedRequest setHttpBody:[postBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    uninterestedRequest.userInfo = [TTUserInfo topic:keyString];
    [requestDic setObject:uninterestedRequest forKey:keyString];
    [uninterestedRequest send];
}

- (void)cancelAllRequest
{
    for (SNURLRequest *request in requestDic) {
        [request cancel];
    }
}

#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
    SNDebugLog(@"news uninterested succeed!");
    
    TTUserInfo *userInfo = request.userInfo;
    NSString *key = userInfo.topic;
    if (key.length > 0) {
        [requestDic removeObjectForKey:key];
        [requestFailDic removeObjectForKey:key];
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"news uninterested failed!");
    
    TTUserInfo *userInfo = request.userInfo;
    NSString *key = userInfo.topic;
    if (key.length > 0) {
        //请求失败，重新发送请求3次
        int requestTimes = [requestFailDic intValueForKey:key defaultValue:0];
        if (requestTimes <= 3) {
            requestTimes++;
            [request send];
            [requestFailDic setObject:[NSNumber numberWithInt:requestTimes] forKey:key];
        }
    }
}

- (void)dealloc
{
    [self cancelAllRequest];
     //(requestDic);
     //(requestFailDic);
}

@end
