//
//  SNBubbleBadgeService.m
//  sohunews
//
//  Created by weibin cheng on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBubbleBadgeService.h"
#import "SNTimeLinePropertyRequest.h"
#import "NSObject+YAJL.h"
#import "SNURLDataResponse.h"
#import "SNBubbleBadgeObject.h"
#import "SNUserinfo.h"
#import "SNUserinfoMediaObject.h"
#import "SNUserManager.h"

static SNBubbleBadgeService* _snBubbleService = nil;

@implementation SNBubbleBadgeService
+(SNBubbleBadgeService*)shareInstance
{
    @synchronized(self){
        if(_snBubbleService == nil)
        {
            _snBubbleService = [[SNBubbleBadgeService alloc] init];
        }
    }

    return _snBubbleService;
}
-(void)dealloc
{
//    if(_badgeRequest)
//    {
//        [_badgeRequest cancel];
//    }
}
-(NSDictionary*)getSubIdsTypes
{
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    if(userinfo && !userinfo.isShowManage)
    {
        NSArray* array = [userinfo getPersonMediaObjects];
        if(array.count > 0)
        {
            NSMutableString* subStr = [[NSMutableString alloc] init];
            NSMutableString* typeStr = [[NSMutableString alloc] init];
            for(SNUserinfoMediaObject* object in array)
            {
                [subStr appendFormat:@"%@,", object.subId];
                [typeStr appendFormat:@"%@,", @"omessage"];
            }
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:2];
            [dic setObject:subStr forKey:@"subIds"];
            [dic setObject:typeStr forKey:@"subTypes"];
            return dic;
        }
    }
    return nil;
}
//-(void)requestNewBadge
//{
//    if(![SNUserManager getUserId])
//        return;
//    if(_isRuning)
//        return;
//    if(_badgeRequest)
//    {
//        [_badgeRequest cancel];
//    }
//
//    NSMutableString* url = [NSMutableString stringWithString:SNLinks_Path_TimelineProperty];
//    [url appendString:@",livemsg"];
//    
//    NSDictionary* dic = [self getSubIdsTypes];
//    if(dic)
//    {
//        [url appendFormat:@"&subIds=%@&subTypes=%@", [dic objectForKey:@"subIds"], [dic objectForKey:@"subTypes"]];
//    }
//    SNURLRequest* request = [SNURLRequest requestWithURL:url delegate:self];
//    request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    request.timeOut = 30;
//    request.response = [[SNURLDataResponse alloc] init];
//    _badgeRequest = request;
//    [_badgeRequest send];
//    _isRuning = YES;
//}
-(void)requestNewBadge {
    
    if(![SNUserManager getUserId]) return;
    if(_isRuning) return;
//    if(_badgeRequest)
//    {
//        [_badgeRequest cancel];
//    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:@"ppfollowed,ppfollowing,ppreply,ppnotify,omessage,followingact,livemsg" forKey:@"types"];
    
    NSDictionary* dic = [self getSubIdsTypes];
    if(dic) [params setValuesForKeysWithDictionary:dic];
    
    [[[SNTimeLinePropertyRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        _isRuning = NO;
        if(!responseObject) return;
        NSArray* array = [responseObject objectForKey:@"timelinePropertys"];
        if([array isKindOfClass:[NSArray class]] && array.count > 0)
        {
            NSMutableDictionary* subDic = [NSMutableDictionary dictionaryWithCapacity:3];
            for(NSDictionary* dic in array)
            {
                NSString* type = [dic objectForKey:@"type"];
                int count = [dic intValueForKey:@"unread" defaultValue:0];
                id idCount = [dic objectForKey:@"unread"];
                if([type isEqualToString:@"ppfollowing"])
                {
                    [SNBubbleNumberManager shareInstance].ppfollowing = count;
                }
                else if([type isEqualToString:@"ppfollowed"])
                {
                    [SNBubbleNumberManager shareInstance].ppfollowed = count;
                }
                else if([type isEqualToString:@"ppreply"])
                {
                    [SNBubbleNumberManager shareInstance].ppreply = count;
                }
                else if([type isEqualToString:@"ppnotify"])
                {
                    [SNBubbleNumberManager shareInstance].ppnotify = count;
                }
                else if([type isEqualToString:@"omessage"])
                {
                    NSString* subId = [dic stringValueForKey:@"subId" defaultValue:@""];
                    if(subId.length > 0)
                    {
                        [subDic setObject:idCount forKey:subId];
                    }
                }
                else if ([type isEqualToString:@"livemsg"])
                {
                    [SNBubbleNumberManager shareInstance].livemsg = count;
                }
                else if([type isEqualToString:@"followingact"])
                {
                    [SNBubbleNumberManager shareInstance].followingact = count;
                }
            }
            if(subDic.count > 0)
            {
                [SNBubbleNumberManager shareInstance].subMessage = subDic;
            }
            [[SNBubbleNumberManager shareInstance] postBubbleBadgeChangeNotification];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        _isRuning = NO;
        SNDebugLog(@"%@",error.localizedDescription);
    }];
    _isRuning = YES;
 
}

//#pragma -mark TTURLRequestDelegate
//-(void)requestDidCancelLoad:(TTURLRequest *)request
//{
//    _isRuning = NO;
//}
//
//-(void)requestDidFinishLoad:(TTURLRequest *)request
//{
//    _isRuning = NO;
//    SNURLDataResponse* response = request.response;
//    NSDictionary* root = [response.data yajl_JSON];
//    if(!root)
//        return;
//    SNDebugLog(@"%@", root);
//    NSArray* array = [root objectForKey:@"timelinePropertys"];
//    if([array isKindOfClass:[NSArray class]] && array.count > 0)
//    {
//        NSMutableDictionary* subDic = [NSMutableDictionary dictionaryWithCapacity:3];
//        for(NSDictionary* dic in array)
//        {
//            NSString* type = [dic objectForKey:@"type"];
//            int count = [dic intValueForKey:@"unread" defaultValue:0];
//            id idCount = [dic objectForKey:@"unread"];
//            if([type isEqualToString:@"ppfollowing"])
//            {
//                [SNBubbleNumberManager shareInstance].ppfollowing = count;
//            }
//            else if([type isEqualToString:@"ppfollowed"])
//            {
//                [SNBubbleNumberManager shareInstance].ppfollowed = count;
//            }
//            else if([type isEqualToString:@"ppreply"])
//            {
//                [SNBubbleNumberManager shareInstance].ppreply = count;
//            }
//            else if([type isEqualToString:@"ppnotify"])
//            {
//                [SNBubbleNumberManager shareInstance].ppnotify = count;
//            }
//            else if([type isEqualToString:@"omessage"])
//            {
//                NSString* subId = [dic stringValueForKey:@"subId" defaultValue:@""];
//                if(subId.length > 0)
//                {
//                    [subDic setObject:idCount forKey:subId];
//                }
//            }
//            else if ([type isEqualToString:@"livemsg"])
//            {
//                [SNBubbleNumberManager shareInstance].livemsg = count;
//            }
//            else if([type isEqualToString:@"followingact"])
//            {
//                [SNBubbleNumberManager shareInstance].followingact = count;
//            }
//        }
//        if(subDic.count > 0)
//        {
//            [SNBubbleNumberManager shareInstance].subMessage = subDic;
//        }
//        [[SNBubbleNumberManager shareInstance] postBubbleBadgeChangeNotification];
//    }
//}
//
//-(void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error
//{
//    _isRuning = NO;
//
//}
@end
