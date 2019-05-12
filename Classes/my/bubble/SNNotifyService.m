//
//  SNNotifyService.m
//  sohunews
//
//  Created by weibin cheng on 13-9-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNotifyService.h"
#import "SNURLDataResponse.h"
#import "SNNotifyRequest.h"
#import "NSObject+YAJL.h"
#import "SNBubbleBadgeService.h"
#import "NSDictionaryExtend.h"
//#import "SNMessageMgr.h"
#import "SNUserManager.h"

#define kSNNotificationPid (@"pid")
#define kSNNotificationMsgid (@"msgId")
#define kSNNotificationType (@"type")
#define kSNNotificationAlert (@"alert")
#define kSNNotificationNickName (@"nickName")
#define KSNNotificationHeadUrl (@"headurl")
#define kSNNotificationData (@"data")
#define kSNNotificationTime (@"time")
#define kSNNotificationMaxMsgId (@"maxMsgId")


static SNNotifyService* _snNotifyService = nil;

@implementation SNNotifyService
+(SNNotifyService*)shareInstance
{
    @synchronized(self)
    {
        if(_snNotifyService == nil)
        {
            _snNotifyService = [[SNNotifyService alloc] init];
        }
    }
    return _snNotifyService;
}
-(void)dealloc
{
//    if(_notificationRequest)
//    {
//        [_notificationRequest cancel];
//         //(_notificationRequest);
//    }
}
-(void)parseNotiArray:(NSArray*)array
{
    if(![SNUserManager isLogin])
        return;
    BOOL hasBubbleNotify = NO;
    int maxMsgId = [SNNotifyService getMaxMsgId];
    for(NSString* str in array)
    {
        NSDictionary* dic = [str yajl_JSON];
        int msgId = [dic intValueForKey:kSNNotificationMsgid defaultValue:0];
        if(msgId > maxMsgId)
            maxMsgId = msgId;
        int type = [dic intValueForKey:kSNNotificationType defaultValue:-1];
        if(type == 26)//气泡通知
        {
            hasBubbleNotify = YES;
        }
        else if(type == 81)//热播视频通知
        {
            [SNNotificationManager postNotificationName:kSNAddHotVideoNotification object:nil userInfo:dic];
        }
    }
    [SNNotifyService saveMaxMsgId:maxMsgId];
    if(hasBubbleNotify)
        [[SNBubbleBadgeService shareInstance] requestNewBadge];
}
//-(void)startRequestNotify
//{
//    if([[SNMessageMgr sharedInstance] isConnected])
//        return;
//    if(_isRunning)
//        return;
//    if(_notificationRequest)
//    {
//        [_notificationRequest cancel];
//         //(_notificationRequest);
//    }
//    SNURLRequest* request = [SNURLRequest requestWithURL:SNLinks_Path_Notify delegate:self];
//    request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    request.timeOut = 30;
//    request.response = [[SNURLDataResponse alloc] init];
//    [request send];
//    _isRunning = YES;
//    _notificationRequest = request;
//}

- (void)startRequestNotify {
    //if([[SNMessageMgr sharedInstance] isConnected]) return;
    if(_isRunning) return;
    [[[SNNotifyRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        _isRunning = NO;

        if(responseObject == nil) return;
        NSDictionary* result = [responseObject objectForKey:@"result"];
        if([[result objectForKey:@"code"] intValue] == 200)
        {
            [[SNBubbleBadgeService shareInstance] requestNewBadge];
            NSArray* notiArray = [responseObject objectForKey:@"notifys"];
            if([notiArray isKindOfClass:[NSArray class]])
            {
                SNDebugLog(@"%@", notiArray);
                if([notiArray count] > 0)
                {
                    [self parseNotiArray:notiArray];
                }
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        _isRunning = NO;
        SNDebugLog(@"%@",error.localizedDescription);
    }];
    _isRunning = YES;
}

-(void)cancelRequestNotify
{
//    if(_notificationRequest)
//       [_notificationRequest cancel];
}

#pragma -mark TTURLRequestDelegate
-(void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error
{
    _isRunning = NO;
}

-(void)requestDidFinishLoad:(TTURLRequest *)request
{
    _isRunning = NO;
    SNURLDataResponse* response = request.response;
    NSDictionary* dic = [response.data yajl_JSON];
    if(dic == nil)
        return;
    NSDictionary* result = [dic objectForKey:@"result"];
    if([[result objectForKey:@"code"] intValue] == 200)
    {
        [[SNBubbleBadgeService shareInstance] requestNewBadge];
        NSArray* notiArray = [dic objectForKey:@"notifys"];
        if([notiArray isKindOfClass:[NSArray class]])
        {
            SNDebugLog(@"%@", notiArray);
            if([notiArray count] > 0)
            {
                [self parseNotiArray:notiArray];
            }
        }
    }
}

-(void)requestDidCancelLoad:(TTURLRequest *)request
{
    _isRunning = NO;
}

+(void)saveMaxMsgId:(int)msgId
{
    if([SNNotifyService generateMaxMsgKey])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", msgId] forKey:[SNNotifyService generateMaxMsgKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+(NSString*)generateMaxMsgKey
{
    if([SNUserManager isLogin])
    {
        if(![[SNUserManager getPid] isEqualToString:@"-1"])
        {
            NSString* str = [NSString stringWithFormat:@"snmaxmsgid_%@", [SNUserManager getPid]];
            return str;
        }
        else
            return nil;
    }
    else
        return nil;
}

+(int)getMaxMsgId
{
    if([SNNotifyService generateMaxMsgKey])
    {
        NSString* newMaxMsg = [[NSUserDefaults standardUserDefaults] objectForKey:[SNNotifyService generateMaxMsgKey]];
        if(newMaxMsg && [newMaxMsg length]>0)
            return [newMaxMsg intValue];
    }
    return -1;
}
@end
