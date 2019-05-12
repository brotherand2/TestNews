//
//  SNVideosCheckService.m
//  sohunews
//
//  Created by chenhong on 13-10-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosCheckService.h"
#import "SNURLRequest.h"
#import "SNURLJSONResponse.h"


#define kVideosCheckServiceLastTimeKey @"kVideosCheckServiceLastTimeKey"

/// 定时检测新视频条数
@interface SNVideosCheckService () {
    NSTimeInterval  _checkInterval; // 检测新视频时间间隔，0表示不检测
    NSTimer         *_checkTimer;
    SNURLRequest    *_checkReq;
}

@end

@implementation SNVideosCheckService

+ (SNVideosCheckService *)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = [[self alloc] init];});
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _checkInterval  = 5;
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)start {
    if (_checkTimer && _checkTimer.isValid) {
        return;
    }
    
    if (_checkInterval > 0) {
        _checkTimer = [NSTimer scheduledTimerWithTimeInterval:_checkInterval
                                                        target:self
                                                      selector:@selector(sendCheckReq)
                                                      userInfo:nil
                                                       repeats:NO];
        SNDebugLog(@"start: %f", _checkInterval);
    }
}

- (void)restart {
    [_checkTimer invalidate];
     //(_checkTimer);
    [self start];
}

- (void)delayTheCheck {
    if (_checkInterval > 0) {
        _checkInterval = 300;
        [self restart];
    }
}

- (void)checkAfterTimeInterval:(NSTimeInterval)interval {
    [_checkTimer invalidate];
     //(_checkTimer);
    
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                    target:self
                                                  selector:@selector(sendCheckReq)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)checkIfNeeded {
    NSTimeInterval interval = 2 * 60;
    NSDate *lastdate = nil;
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:kVideosCheckServiceLastTimeKey];
	if (data && [data isKindOfClass:[NSDate class]]) {
		lastdate = data;
	}
    
    BOOL needCheck = NO;
    
    if (lastdate) {
        needCheck = [(NSDate *)[lastdate dateByAddingTimeInterval:interval] compare:[NSDate date] ] < 0;
    } else {
        needCheck = YES;
    }
    
    if (needCheck) {
        [[SNVideosCheckService sharedInstance] checkAfterTimeInterval:0];
    } else {
        [self start];
    }
}

- (void)stop {
    [_checkReq cancel];
    [_checkReq.delegates removeObject:self];
     //(_checkReq);
    [_checkTimer invalidate];
     //(_checkTimer);
}

// 检测服务端'热播‘频道新视频数
- (void)sendCheckReq {
    NSString *vcursor   = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoTimelinePrecursor];
    if ([vcursor intValue] <= 0) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:VIDEO_TIMELINE_CHECK_URL, vcursor];
    
    [_checkReq cancel];
     //(_checkReq);
    
    _checkReq = [SNURLRequest requestWithURL:url delegate:self];
    _checkReq.cachePolicy = TTURLRequestCachePolicyNoCache;
    _checkReq.isShowNoNetWorkMessage = NO;
    _checkReq.userInfo = [TTUserInfo topic:vcursor];
    _checkReq.response = [[SNURLJSONResponse alloc] init];
    [_checkReq send];
}

- (BOOL)autoPlayTimelineVideos {
    id autoPlayTimelineVideosObj = [[NSUserDefaults standardUserDefaults] objectForKey:kAutoPlayTimelineVideos];
    if (!autoPlayTimelineVideosObj) {
        return YES;
    }
    else {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kAutoPlayTimelineVideos];
    }
}

- (BOOL)canTimelineToDetailPage {
    id canTimelineToVideoDetailPageObj = [[NSUserDefaults standardUserDefaults] objectForKey:kCanTimelineToVideoDetailPage];
    if (!canTimelineToVideoDetailPageObj) {
        return NO;
    }
    else {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kCanTimelineToVideoDetailPage];
    }
}
#pragma mark - TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    SNURLJSONResponse *dataRes = (SNURLJSONResponse *)request.response;

    // 检测unread
    id rootData = dataRes.rootObject;
    if ([rootData isKindOfClass:[NSDictionary class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kVideosCheckServiceLastTimeKey];
        SNDebugLog(@"%@", rootData);
        
        // 若当前vcursor与发送查询请求时的vcursor不同，则不提示新视频数
        NSString *vcursor   = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoTimelinePrecursor];
        if ([request.userInfo isKindOfClass:TTUserInfo.class]) {
            TTUserInfo *userInfo = request.userInfo;
            if ([vcursor isEqualToString:userInfo.topic]) {
                NSString *num = [rootData stringValueForKey:@"unReadNum" defaultValue:nil];
                
                [self parseTimelineVideoControl:rootData];
                
                if ([num intValue] > 0) {
                    NSString *msg = [NSString stringWithFormat:@"%@个新视频，下拉刷新看看", num];
                    NSDictionary *messageDic = @{@"message":msg,
                                                 @"channelId":kVideoTimelineMainChannelId,
                                                 @"duration":@(5.0)};
                    [SNNotificationManager postNotificationName:kVideoTimelineRefreshMsgNotification
                                                                        object:messageDic];
                }
            } else {
                SNDebugLog(@"vcursor changed, the check result is invalid");
            }
        }
        
        NSString *nextTime = [rootData stringValueForKey:@"nextTime" defaultValue:nil];
        if ([nextTime intValue] > 0) {
            _checkInterval = [nextTime intValue];
            [self restart];
        } else {
            [self stop];
        }
    } else {
        if (_checkInterval > 0) {
            _checkInterval += 60;
        }
        [self restart];
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    if (_checkInterval > 0) {
        _checkInterval += 60;
    }
    [self restart];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    [self restart];
}

#pragma mark -
- (void)parseTimelineVideoControl:(id)rootData {
    BOOL autoPlayTimeline = YES;
    BOOL canTimelineToVideoDetailPage = NO;
    
    if (!!rootData && [rootData isKindOfClass:[NSDictionary class]]) {
        id playInfos = [rootData objectForKey:@"playInfos" defalutObj:nil];
        
        if (!!playInfos && [playInfos isKindOfClass:[NSArray class]]) {
            NSArray *playInfoArray = (NSArray *)playInfos;
            for (id playInfoObj in playInfoArray) {
                if ([playInfoObj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *playInfoDic = (NSDictionary *)playInfoObj;
                    NSNumber *platformNum = [playInfoDic objectForKey:@"platform" defalutObj:nil];
                    if ([platformNum intValue] == 1) {//1表示iOS平台
                        NSNumber *autoPlayTimelineNum = [playInfoObj objectForKey:@"timelinePlay" defalutObj:@(1)];
                        NSNumber *canTimelineToVideoDetailPageNum = [playInfoObj objectForKey:@"toLink2" defalutObj:@(0)];
                        
                        autoPlayTimeline = [autoPlayTimelineNum intValue] == 0 ? NO : YES;
                        canTimelineToVideoDetailPage = [canTimelineToVideoDetailPageNum intValue] == 0 ? NO : YES;
                    }
                }
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:autoPlayTimeline forKey:kAutoPlayTimelineVideos];
    [[NSUserDefaults standardUserDefaults] setBool:canTimelineToVideoDetailPage forKey:kCanTimelineToVideoDetailPage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SNNotificationManager postNotificationName:kFinishCheckTimelineVideosControlNotification object:nil];
}
@end
