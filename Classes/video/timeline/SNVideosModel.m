//
//  SNVideosModel.m
//  sohunews
//
//  Created by chenhong on 13-9-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosModel.h"
#import "SNURLJSONResponse.h"
#import "SNVideoObjects.h"
#import "SNDBManager.h"
#import "SNVideosCheckService.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"

 
#define VIDEOS_LIST_PAGE_SIZE 20


@interface SNVideosModel () {
    BOOL _bLoadMore;
    BOOL _hasNoMore;
}

@end

@implementation SNVideosModel

@synthesize delegate    = _delegate;
@synthesize delegateForDetail = _delegateForDetail;
@synthesize channelId   = _channelId;
@synthesize dataArray   = _dataArray;
@synthesize moreDataArray = _moreDataArray;
@synthesize listInfo    = _listInfo;

- (id)initWithChannelId:(NSString *)channelId {
    self = [super init];
    if (self) {
        _channelId      = [channelId copy];
        _dataArray      = [[NSMutableArray alloc] init];
        _listInfo       = [[SNVideoListInfo alloc] init];

    }
    return self;
}

- (void)dealloc {
    [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
    self.delegate = nil;
    self.delegateForDetail = nil;
    
    [self cancel];
	 //(_request);
    
     //(_channelId);
     //(_dataArray);
     //(_moreDataArray);
     //(_listInfo);

}

- (BOOL)isLoading {
    return _request.isLoading;
}

- (BOOL)hasNoMore {
    return _hasNoMore;
}

- (void)cancel {
	if (_request) {
		[_request cancel];
        [_request.delegates removeObject:self];
	}
}

- (BOOL)shouldReload {
    if (_dataArray.count == 0) {
        return YES;
    }
    
    BOOL needRefresh = [SNVideosModel needRefresh:_channelId];
    if (needRefresh) {
        return YES;
    }
    
    NSTimeInterval interval = kChannelVideoRefreshInterval;
    NSDate *lastdate = [self refreshedTime];
    if (lastdate) {
        return [(NSDate *)[lastdate dateByAddingTimeInterval:interval] compare:[NSDate date] ] < 0;
    } else {
        return YES;
    }
}

//加载第一页缓存
- (void)loadCache {    
    [self.dataArray removeAllObjects];

    NSArray *arr = [[SNDBManager currentDataBase] getVideoTimeLineListByChannelId:self.channelId];
    [self.dataArray addObjectsFromArray:arr];
    
    // 启动timer
    if ([self.channelId isEqualToString:kVideoTimelineMainChannelId]) {
        [[SNVideosCheckService sharedInstance] start];
    }
    
    self.listInfo.nextCursor = [self nextCursor];
}

- (void)checkRegist {
    // 没有p1并且不是注册接口，则调用一次注册接口
    if (![SNClientRegister sharedInstance].isRegisted) {
        SNDebugLog(@"no P1, try to regist");
        [[SNClientRegister sharedInstance] updateClientInfoToServer];
    }
}

// 请求最新
- (void)refresh {
    if (self.isLoading)
        return;
    
    if ([_channelId length] == 0) {
        return;
    }
    
    [self checkRegist];
    
    _bLoadMore = NO;
    
    NSString *url = [NSString stringWithFormat:NEW_VIDEO_TIMELINE_URL, _channelId];
        
    if (!_request) {
        _request = [SNURLRequest requestWithURL:url delegate:self];
        _request.cachePolicy = TTURLRequestCachePolicyNoCache;
        _request.isShowNoNetWorkMessage = YES;
    } else {
        if (![_request.delegates containsObject:self]) {
            [_request.delegates addObject:self];
        }
        _request.urlPath = url;
        SNDebugLog(@"%@", _request.urlPath);
    }
    
    _request.response = [[SNURLJSONResponse alloc] init];
    [_request send];
}

// 请求更多
- (void)loadMore {
    if (self.isLoading)
        return;
	
    _bLoadMore = YES;
    
    NSString *url = [NSString stringWithFormat:NEW_VIDEO_TIMELINE_URL, _channelId];
    
    url = [url stringByAppendingFormat:@"&cursor=%lld", self.listInfo.nextCursor];
    
    if (!_request) {
        _request = [SNURLRequest requestWithURL:url delegate:self];
        _request.cachePolicy = TTURLRequestCachePolicyNoCache;
        _request.isShowNoNetWorkMessage = YES;
    } else {
        if (![_request.delegates containsObject:self]) {
            [_request.delegates addObject:self];
        }
        _request.urlPath = url;
        SNDebugLog(@"loadMore: %@", _request.urlPath);
    }
    
    _request.response = [[SNURLJSONResponse alloc] init];
    [_request send];
}

#pragma mark - TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    SNURLJSONResponse *dataRes = (SNURLJSONResponse *)request.response;
    
    id rootData = dataRes.rootObject;
    
    BOOL bSuccess = [self requestDidFinishLoadWithData:rootData];
    
    if (bSuccess) {
        // 更新检测定时器，5分钟后再检测新视频数
        if ([self.channelId isEqualToString:kVideoTimelineMainChannelId]) {
            [[SNVideosCheckService sharedInstance] delayTheCheck];
        }
        
        [self callbackToDelegatesDidFinishLoad];
    } else {
        [self callbackToDelegatesDidFailLoadWithError:nil];
    }
}

- (BOOL)requestDidFinishLoadWithData:(id)rootData {
    
    if ([rootData isKindOfClass:[NSDictionary class]]) {
        
        if ([[rootData objectForKey:@"isSuccess"] isEqualToString:@"F"]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"加载失败" toUrl:nil mode:SNCenterToastModeWarning];
            return NO;
        }

        [self.listInfo updateWithDict:rootData];
        
        [self.moreDataArray removeAllObjects];
        NSMutableArray *oldArray = nil;
        if (!_bLoadMore) {
            [self setRefreshedTime];
            
            // 重置更新flag
            [SNVideosModel setNeedRefresh:NO channelId:_channelId];
            
            // 缓存nextCursor，用于下次loadCache后加载更多的cursor参数
            [self setNextCursor:self.listInfo.nextCursor];
            
            oldArray = [NSMutableArray arrayWithArray:self.dataArray];
            self.dataArray = [NSMutableArray array];
        }

        _hasNoMore = !self.listInfo.hasnext;
        
        NSArray *data = [rootData arrayValueForKey:@"data" defaultValue:nil];
        SNDebugLog(@"got %d", data.count);
        for (NSDictionary *dict in data) {
            SNVideoData* item = [[SNVideoData alloc] initWithDict:dict];
            item.channelId = self.channelId;
            if(item.multipleType == 3)
            {
                [item uploadLoadStatistics:self.channelId];
                if ([self shouldFilterUninterestData:item.uninterestInterval])
                {
                    continue;
                }
            }

            if (![self.dataArray containsObject:item]) {
                [self.dataArray addObject:item];
            }
            if (![self.moreDataArray containsObject:item]) {
                [self.moreDataArray addObject:item];                
            }
        }
        
        if (!_bLoadMore) {
            // 内容已更新提示
            if (self.dataArray.count > 0) {
                NSInteger topNewCnt = 0;
                
                if (oldArray.count > 0) {
                    for (SNVideoData *item in self.dataArray) {
                        if (![oldArray containsObject:item]) {
                            ++topNewCnt;
                        } else {
                            break;
                        }
                    }
                } else {
                    topNewCnt = self.dataArray.count;
                }
            
                if (topNewCnt > 0) {
                    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"video_timeline_refresh_msg", nil), topNewCnt];
                    NSDictionary *messageDic = @{@"message":msg, @"channelId":self.channelId};
                    [SNNotificationManager postNotificationName:kVideoTimelineRefreshMsgNotification object:messageDic];
                }
            }
            
            // 视频tab新视频数置为0
            if ([self.channelId isEqualToString:kVideoTimelineMainChannelId]) {
                if (self.listInfo.preCursor) {
                    [[NSUserDefaults standardUserDefaults] setValue:self.listInfo.preCursor forKey:kVideoTimelinePrecursor];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                [SNNotificationManager postNotificationName:kVideoTimelineCheckNewNotification
                                                                    object:nil
                                                                  userInfo:@{kVideoTimelineCntForNew:@(0)}];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[SNDBManager currentDataBase] clearVideoTimeLineListByChannelId:self.channelId];
                if (self.dataArray.count > 0) {
                    [[SNDBManager currentDataBase] addVideoTimeLineList:self.dataArray channelId:self.channelId];
                }
            });
        }
        
        return YES;
    } //root
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"内容暂时无法加载" toUrl:nil mode:SNCenterToastModeWarning];
    return NO;
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    [self callbackToDelegatesDidFailLoadWithError:error];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    [self callbackToDelegatesDidCancelLoad];
}

#pragma mark - drag refresh time

- (NSDate *)refreshedTime {
    
	NSDate *time = nil;
    
    NSString *timeKey = [NSString stringWithFormat:@"%@_video_refresh_time", _channelId];
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
	if (data && [data isKindOfClass:[NSDate class]]) {
		time = data;
	}
    
	return time;
}

- (void)setRefreshedTime {
	NSString *timeKey = [NSString stringWithFormat:@"%@_video_refresh_time", _channelId];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:timeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)needRefresh:(NSString *)channelId {
    NSString *refreshKey = [NSString stringWithFormat:@"%@_video_need_refresh", channelId];
    NSNumber *needRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:refreshKey];
    return [needRefresh boolValue];
}

+ (void)setNeedRefresh:(BOOL)bRefresh channelId:(NSString *)channelId {
    if (channelId.length) {
        NSString *refreshKey = [NSString stringWithFormat:@"%@_video_need_refresh", channelId];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:bRefresh] forKey:refreshKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (long long)nextCursor {
    NSString *nextCursorKey = [NSString stringWithFormat:@"%@_video_next_cursor", _channelId];
	NSNumber *nextCursor = [[NSUserDefaults standardUserDefaults] objectForKey:nextCursorKey];
    return [nextCursor longLongValue];
}

- (void)setNextCursor:(long long)nextCursor {
    NSString *nextCursorKey = [NSString stringWithFormat:@"%@_video_next_cursor", _channelId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:nextCursor] forKey:nextCursorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -

- (NSMutableArray *)moreDataArray {
    if (!_moreDataArray) {
        _moreDataArray = [[NSMutableArray alloc] init];
    }
    return _moreDataArray;
}

- (void)callbackToDelegatesDidFinishLoad {
    if ([_delegate respondsToSelector:@selector(videosDidFinishLoad)]) {
        [_delegate videosDidFinishLoad];
    }
    
    if ([_delegateForDetail respondsToSelector:@selector(videosDidFinishLoad)]) {
        [_delegateForDetail videosDidFinishLoad];
    }
}

- (void)callbackToDelegatesDidCancelLoad {
    if ([_delegate respondsToSelector:@selector(videosDidCancelLoad)]) {
        [_delegate videosDidCancelLoad];
    }
    
    if ([_delegateForDetail respondsToSelector:@selector(videosDidCancelLoad)]) {
        [_delegateForDetail videosDidCancelLoad];
    }
}

- (void)callbackToDelegatesDidFailLoadWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(videosDidFailLoadWithError:)]) {
        [_delegate videosDidFailLoadWithError:nil];
    }
    
    if ([_delegateForDetail respondsToSelector:@selector(videosDidFailLoadWithError:)]) {
        [_delegateForDetail videosDidFailLoadWithError:nil];
    }
}

- (BOOL)shouldFilterUninterestData:(NSTimeInterval)interval
{
    if(interval <= 0)
        return NO;
    NSString* key = @"kVideoCellUnintrestTime_";
    key = [key stringByAppendingString:self.channelId];
    NSDate* date = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(!date)
        return NO;
    NSDate* curDate = [NSDate date];
    NSTimeInterval curInterval = [curDate timeIntervalSinceDate:date];
    if(curInterval <= interval)
    {
        return YES;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
}

@end
