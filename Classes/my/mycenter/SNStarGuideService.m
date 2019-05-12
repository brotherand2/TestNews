//
//  SNStarGuideService.m
//  sohunews
//
//  Created by weibin cheng on 13-12-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNStarGuideService.h"
#import "SNURLJSONResponse.h"
#import "SNUserinfo.h"
#import "SNUserManager.h"
#import "SNRelationOptRequest.h"

@interface SNStarGuideService ()
@property(nonatomic, strong) SNURLRequest* starRequest;
@property(nonatomic, strong) SNURLRequest* followReqeust;
@end

static SNStarGuideService* _shareStarGuideService = nil;
@implementation SNStarGuideService
@synthesize starArray = _starArray;
@synthesize delegate = _delegate;
@synthesize starRequest = _starRequest;
@synthesize followReqeust = _followReqeust;

+(SNStarGuideService*)shareInstance
{
    if(_shareStarGuideService == nil)
    {
        @synchronized(self)
        {
            _shareStarGuideService = [[SNStarGuideService alloc] init];
        }
    }
    return _shareStarGuideService;
}

-(void)dealloc
{
    [_starRequest cancel];
    [_starRequest.delegates removeObject:self];
     //(_starRequest);
    
    [_followReqeust cancel];
    [_followReqeust.delegates removeObject:self];
     //(_followReqeust);
    
     //(_starArray);
}

-(void)startReqeustStar
{
    self.starRequest = [SNURLRequest requestWithURL:kUrlStarGuide delegate:self];
    _starRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    _starRequest.timeOut = 30;
    _starRequest.response = [[SNURLJSONResponse alloc] init];
    [_starRequest send];
}

-(void)followAllStar
{
    if(_starArray.count == 0) {
        return;
    }
    
    NSMutableString* fpids = [NSMutableString stringWithCapacity:50];
    for(SNUserinfoEx* userinfo in _starArray) {
        [fpids appendFormat:@"%@,", userinfo.pid];
    }
//    NSString* url = [NSString stringWithFormat:kUrlBatchFollowUser, fpids];
//    
//    self.followReqeust = [SNURLRequest requestWithURL:url delegate:self];
//    _followReqeust.cachePolicy = TTURLRequestCachePolicyNoCache;
//    _followReqeust.timeOut = 30;
//    _followReqeust.response = [[SNURLJSONResponse alloc] init];
//    [_followReqeust send];
    
//    ?action=batchAddfollow&version=1.0&fpids=%@
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:@"batchAddfollow" forKey:@"action"];
    [params setValue:@"1.0" forKey:@"version"];
    [params setValue:fpids forKey:@"fpids"];
    
    [[[SNRelationOptRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootDic) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @try {
                if(rootDic && [rootDic isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary* dic = [rootDic objectForKey:@"value"];
                    if(dic && [rootDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [dic intValueForKey:@"code" defaultValue:0];
                        NSString* msg = [dic stringValueForKey:@"msg" defaultValue:nil];
                        if(code == 200)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(_delegate && [_delegate respondsToSelector:@selector(followStarDidFinished:)])
                                    [_delegate followStarDidFinished:[msg intValue]];
                            });
                        }
                    }
                }
            } @catch (NSException *exception) {
                SNDebugLog(@"SNRelationOptRequest exception reason--%@", exception.reason);
            } @finally {
                
            }
        });

    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
}

-(SNUserinfoEx*)getStarByIndex:(NSInteger)index
{
    if(index >= 0 && index < _starArray.count)
        return [_starArray objectAtIndex:index];
    return nil;
}

-(void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error
{
    
}

-(void)requestDidFinishLoad:(TTURLRequest *)request
{
    if(request == self.starRequest)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SNURLJSONResponse* response = request.response;
            NSDictionary* rootDic = response.rootObject;
            SNDebugLog(@"%@",rootDic);
            if(rootDic && [rootDic isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* dic = [rootDic objectForKey:@"value"];
                if(dic && [rootDic isKindOfClass:[NSDictionary class]])
                {
                    NSArray* recommendList = [dic objectForKey:@"recommendList"];
                    if(recommendList && [recommendList isKindOfClass:[NSArray class]])
                    {
                        if(_starArray == nil)
                        {
                            _starArray = [[NSMutableArray alloc] init];
                        }
                        for(NSDictionary* dic in recommendList)
                        {
                            SNUserinfoEx* userinfo = [[SNUserinfoEx alloc] init];
                            userinfo.headImageUrl = [dic stringValueForKey:@"headUrl" defaultValue:nil];
                            userinfo.nickName = [dic stringValueForKey:@"nickName" defaultValue:nil];
                            userinfo.pid = [dic stringValueForKey:@"pid" defaultValue:nil];
                            [_starArray addObject:userinfo];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(_delegate && [_delegate respondsToSelector:@selector(requestStarDidFinished)])
                                [_delegate requestStarDidFinished];
                        });

                    }
                }
                
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            SNURLJSONResponse* response = request.response;
            NSDictionary* rootDic = response.rootObject;
            SNDebugLog(@"%@",rootDic);
            if(rootDic && [rootDic isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* dic = [rootDic objectForKey:@"value"];
                if(dic && [rootDic isKindOfClass:[NSDictionary class]])
                {
                    int code = [dic intValueForKey:@"code" defaultValue:0];
                    NSString* msg = [dic stringValueForKey:@"msg" defaultValue:nil];
                    if(code == 200)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(_delegate && [_delegate respondsToSelector:@selector(followStarDidFinished:)])
                                [_delegate followStarDidFinished:[msg intValue]];
                        });
                    }
                }
            }
        });
    }
}
@end
