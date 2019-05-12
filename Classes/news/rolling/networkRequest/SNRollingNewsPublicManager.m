//
//  SNRollingNewsPublicManager.m
//  sohunews
//
//  Created by lhp on 5/16/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingNewsPublicManager.h"
#import "NSCellLayout.h"
#import "SNListenNewsGuideView.h"
#import "TMCache.h"

@interface SNRollingNewsPublicManager ()

@end

#define kMySubscribeUpdateTime     (@"kMySubscribeUpdateTime")

@implementation SNRollingNewsPublicManager

@synthesize moreView;
@synthesize newsMode;
@synthesize updateTime;
@synthesize playerTop;
@synthesize lastUpdateTime;
@synthesize mainFocalId;
@synthesize viceFocalId;
@synthesize appLaunch;
@synthesize resetOpen;
@synthesize refreshClose;
@synthesize loadMoreTips;
@synthesize channelRefreshClose;
@synthesize homeRecordTimeClose;
@synthesize newsTableClick;
@synthesize widgetOpen;
@synthesize isNeighChannel;
@synthesize resetHome;
@synthesize isNeedToPushToRecom;
@synthesize refreshChannel;
@synthesize moreCellStatus;
@synthesize pageNum;
@synthesize showUpdateTips;
@synthesize focusPosition;
@synthesize refreshStock;
@synthesize refreshSubscribe;
@synthesize isNeedToBackToTop;
@synthesize refreshChannelTimer;
@synthesize showRecommend;
@synthesize refreshChannelId;
@synthesize isHomePage;
@synthesize clearAllCache;
@synthesize newsSource;
@synthesize focusImageIndexDic;
@synthesize pageViewTimer;
@synthesize searchHotWord = _searchHotWord;
@synthesize novelSearchHotWord = _novelSearchHotWord;
@synthesize rollingNewsBeginTime;
@synthesize userAction;

+ (SNRollingNewsPublicManager *)sharedInstance {
    static SNRollingNewsPublicManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNRollingNewsPublicManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        newsMode = SNRollingNewsModeNone;
        leaveMode = SNHomePageLeaveNone;
        self.updateTime = [[NSUserDefaults standardUserDefaults] objectForKey:kMySubscribeUpdateTime];
        newsSource = SNRollingNewsSourceDefault;
        
        self.focusPosition = @"1";
        self.lastUpdateTime = @"0";
        self.mainFocalId = @"0";
        self.viceFocalId = @"0";
        
        self.focusImageIndexDic = [NSMutableDictionary dictionary];
        
        self.pageViewTimer = YES;
        
        self.searchHotWord = [NSArray array];
        self.novelSearchHotWord = [NSArray array];
        
        [self clearAllContentToken];//重置置顶token
        self.userAction = SNRollingNewsUserChangeTab;
    }
    return self;
}

- (void)showAnimationWithRight:(int)rightValue {
    if (rightValue > 0) {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.moreView.right = rightValue;
                         } completion:^(BOOL finished) {
                         }];
    }
}

- (void)closeListenNewsGuideViewAnimation:(BOOL)isAnimation {
    if (!self.listenNewsGuideView) {
        return;
    }
    
    if (isAnimation) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.listenNewsGuideView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 [self listenNewsGuideViewRelease];
                             }
                         }];
        
    } else {
        [self listenNewsGuideViewRelease];
    }
}

- (void)listenNewsGuideViewRelease {
    if (self.listenNewsGuideView) {
        [self.listenNewsGuideView removeFromSuperview];
    }
}

- (void)closeCellMoreViewAnimation:(BOOL)isAnimation {
    if (!self.moreView) {
        return;
    }
    
    if (isAnimation) {
        NSString *identifierString = self.moreView.identifier;
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.moreView.alpha = 0.0;
                             self.moreView.right = TTApplicationFrame().size.width + CONTENT_LEFT + self.moreView.width;
                         } completion:^(BOOL finished) {
                             if ([self.moreView.identifier isEqualToString:identifierString]) {
                                 [self cellMoreViewRelease];
                             }
                         }];
        
    } else {
        [self cellMoreViewRelease];
    }
}

- (void)cellMoreViewRelease {
    if (self.moreView) {
        [moreView removeFromSuperview];
        moreView = nil; // self.moveView will crash by jojo
    }
}

- (void)updateTimeWithDateString:(NSString *)dateString {
    if (!dateString) {
        return;
    }
    
    if (![dateString isEqualToString:self.updateTime]) {
        self.updateTime = dateString;
        [[NSUserDefaults standardUserDefaults] setObject:self.updateTime forKey:kMySubscribeUpdateTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)compareUpdateTimeWithDateString:(NSString *)dateString {
    BOOL updated = NO;
    if (dateString.length >0) {
        if (self.updateTime.length >0) {
            updated = ([dateString doubleValue] - [self.updateTime doubleValue]) > 0 ? YES : NO;
        } else {
            updated = YES;
        }
    }
    
    return updated;
}

- (int)getNewsModeNum {
    if (self.resetOpen) {
        self.resetOpen = NO;
        return 0;
    }
    
    int modeNum;
    switch (newsMode) {
        case SNRollingNewsModeNone:
            modeNum = 0;
            break;
        case SNRollingNewsModeEdit:
            modeNum = 1;
            break;
        case SNRollingNewsModeRecommend:
            modeNum = 2;
            break;
        case SNRollingNewsModeV6:
            modeNum = 3;
            break;
        default:
            modeNum = 0;
            break;
    }
    return modeNum;
}

- (void)resetLeaveHomeTime {
    leaveMode = [self setleaveHomeTimeMode];
    leaveHomeTime = 0;
    leaveModeGet = NO;
}

- (void)recordLeaveHomeTime {
    if (leaveHomeTime != 0) {
        return;
    }
    
    leaveModeGet = YES;
    leaveMode = SNHomePageLeaveNone;
    leaveHomeTime = [[NSDate date] timeIntervalSince1970];
}

- (SNHomePageLeave)getLeaveHomeTimeMode {
    if (leaveModeGet) {
        leaveMode = SNHomePageLeaveNone;
        return leaveMode;
    }
    leaveModeGet = YES;
    return leaveMode;
}

- (SNHomePageLeave)setleaveHomeTimeMode {
    SNHomePageLeave timeMode = SNHomePageLeaveNone;
    if (leaveHomeTime > 0) {
        float nowTime = [[NSDate date] timeIntervalSince1970];
        float intervalTime = nowTime - leaveHomeTime;
        if (intervalTime <= 5 * 60) {
            timeMode = SNHomePageLeave5Min;
        } else if (intervalTime > 5 * 60 &&
                   intervalTime < 60 * 60) {
            timeMode = SNHomePageLeave1Hour;
        } else {
            timeMode = SNHomePageLeaveOther;
        }
    }
    return timeMode;
}

- (NSString *)addParameterWithUrl:(NSString *)url {
    if (self.lastUpdateTime.length <= 0) {
        self.lastUpdateTime = @"0";
    }
    url = [url stringByAppendingFormat:@"&lastUpdateTime=%@", self.lastUpdateTime];
    
    
    if (self.mainFocalId.length <= 0) {
        self.mainFocalId = @"0";
    }
    url = [url stringByAppendingFormat:@"&mainFocalId=%@", self.mainFocalId];
    
    if (self.viceFocalId.length <= 0) {
        self.viceFocalId = @"0";
    }
    url = [url stringByAppendingFormat:@"&viceFocalId=%@", self.viceFocalId];
    
    return url;
}

- (void)dealloc {
    [self.refreshChannelTimer invalidate];
    [SNNotificationManager removeObserver:self];
}

/*
 ********阅读轨迹 24小时后删除阅读历史*********
 */

#define kReadNewsList               @"readNewsList"
#define kOneDateTimeInterVal        24 * 60 * 60

//遍历阅读历史，删除阅读时长超过24小时的
+ (void)deleteReadTimeOutNews {
    NSObject *obj = [[TMCache sharedCache] objectForKey:kReadNewsList];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *valueDic = (NSMutableDictionary *)obj;
        if (valueDic == nil) {
            return;
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:valueDic];
        
        NSArray *keys = [dic allKeys];
        NSInteger count = [keys count];
        for (int i = 0; i < count; i++) {
            NSString *key = [keys objectAtIndex:i];
            NSDate *readDate = [valueDic objectForKey:key defalutObj:nil];
            NSDate *nowDate  = [NSDate date];
            NSTimeInterval secondsInterval= [nowDate timeIntervalSinceDate:readDate];
            if (readDate != nil && secondsInterval >= kOneDateTimeInterVal) {
                [valueDic removeObjectForKey:key];
            }
        }
        
        [[TMCache sharedCache] setObject:valueDic forKey:kReadNewsList];
    }
}

+ (void)saveReadNewsWithNewsId:(NSString *)newsId
                     ChannelId:(NSString *)channelId {
    if (newsId != nil && channelId != nil) {
        NSObject *obj = [[TMCache sharedCache] objectForKey:kReadNewsList];
        if (obj == nil || [obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *valueDic = nil;
            if (obj == nil) {
                valueDic = [[NSMutableDictionary alloc] init];
            } else {
                valueDic = (NSMutableDictionary *)obj;
            }
            
            NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, newsId];
            [valueDic setObject:[NSDate date] forKey:key];
            
            [[TMCache sharedCache] setObject:valueDic forKey:kReadNewsList];
        }
    }
}

+ (BOOL)isReadNewsWithNewsId:(NSString *)newsId
                   ChannelId:(NSString *)channelId {
    if (newsId != nil && channelId != nil) {
        NSObject *obj = [[TMCache sharedCache] objectForKey:kReadNewsList];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *valueDic = (NSMutableDictionary *)obj;
            if (valueDic == nil) {
                return NO;
            }
            
            NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, newsId];
            NSObject *obj = [valueDic objectForKey:key];
            if (obj != nil && [obj isKindOfClass:[NSDate class]]) {
                return YES;
            }
        }
    }
    
    return NO;
}

/*
 ********频道请求记录 刷新时删除*********
 */

#define kParamPageNum           @"page"
#define kParamPageTimes         @"times"
#define kParamMainFocalId       @"mainFocalId"
#define kParamFocusPosition     @"focusPosition"
#define kParamViceFocalId       @"viceFocalId"
#define kParamLastUpdateTime    @"lastUpdateTime"
#define kParamShowUpdateTips    @"showUpdateTips"
#define kRequestParamCache      @"kRequestparamCache"
#define kParamContentToken      @"contentToken"
#define kParamNewsMode          @"newsMode"
#define kMinTimelineIndex       @"minTimelineIndex"

+ (void)saveRollingPage:(int)pageNum channelId:(NSString *)channelId{
    NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, kParamPageNum];
    [[TMCache sharedCache] setObject:[NSNumber numberWithInteger:pageNum] forKey:key];
}

+ (void)saveRollingTimes:(int)times channelId:(NSString *)channelId{
    NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, kParamPageTimes];
    [[TMCache sharedCache] setObject:[NSNumber numberWithInteger:times] forKey:key];
}

+ (void)saveRollingMinTimelineIndex:(int)minTimelineIndex channelId:(NSString *)channelId{
    NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, kMinTimelineIndex];
    [[TMCache sharedCache] setObject:[NSNumber numberWithInteger:minTimelineIndex] forKey:key];
}

- (void)saveRequestParamsWithChannelId:(NSString *)channelId {
    if (channelId == nil || [channelId length] == 0) {
        return;
    }
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSNumber numberWithInteger:self.pageNum] forKey:kParamPageNum];
    
    [paramDic setObject:[NSNumber numberWithInteger:self.times] forKey:kParamPageTimes];
    [paramDic setObject:[NSNumber numberWithInteger:self.minTimelineIndex] forKey:kMinTimelineIndex];
    
    if (self.mainFocalId != nil) {
        [paramDic setObject:self.mainFocalId forKey:kParamMainFocalId];
    }
    if (self.focusPosition != nil) {
        [paramDic setObject:self.focusPosition forKey:kParamFocusPosition];
    }
    if (self.viceFocalId != nil) {
        [paramDic setObject:self.viceFocalId forKey:kParamViceFocalId];
    }
    if (self.lastUpdateTime != nil) {
        [paramDic setObject:self.lastUpdateTime forKey:kParamLastUpdateTime];
    }
    [paramDic setObject:[NSNumber numberWithBool:self.showUpdateTips] forKey:kParamShowUpdateTips];
    [paramDic setObject:[NSNumber numberWithInt:self.newsMode] forKey:kParamNewsMode];
    
    
    NSMutableDictionary *valueDic = [[TMCache sharedCache] objectForKey:kRequestParamCache];
    if (valueDic == nil) {
        valueDic = [[NSMutableDictionary alloc] init];
    }
    
    [valueDic setObject:paramDic forKey:channelId];
    
    [[TMCache sharedCache] setObject:valueDic forKey:kRequestParamCache];
}


- (void)readRequestParamsWithChannelId:(NSString *)channelId {
    NSMutableDictionary *valueDic = [NSMutableDictionary dictionaryWithDictionary:[[TMCache sharedCache] objectForKey:kRequestParamCache]];

    NSDictionary *itemDic = [valueDic objectForKey:channelId defalutObj:nil];
    self.mainFocalId = [itemDic objectForKey:kParamMainFocalId defalutObj:@"0"];
    self.viceFocalId = [itemDic objectForKey:kParamViceFocalId defalutObj:@"0"];
    self.lastUpdateTime = [itemDic objectForKey:kParamLastUpdateTime defalutObj:@"0"];
    self.pageNum = [[itemDic objectForKey:kParamPageNum defalutObj:nil] integerValue];
    self.showUpdateTips = [[itemDic objectForKey:kParamShowUpdateTips defalutObj:nil] boolValue];
    self.focusPosition = [itemDic objectForKey:kParamFocusPosition defalutObj:@"1"];
    self.newsMode = [[itemDic objectForKey:kParamNewsMode defalutObj:nil] integerValue];
    self.times = [[itemDic objectForKey:kParamPageTimes defalutObj:nil] integerValue];
    self.minTimelineIndex = [[itemDic objectForKey:kMinTimelineIndex defalutObj:nil] integerValue];
}

+ (int)readRollingPageWithChannelId:(NSString *)channelId{
    NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, kParamPageNum];
    return [self readShareCacheWith:key];
}

+ (int)readRollingTimesWithChannelId:(NSString *)channelId{
    NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, kParamPageTimes];
    return [self readShareCacheWith:key];
}

+ (int)readRollingMinTimelineIndexWithChannelId:(NSString *)channelId{
    NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, kMinTimelineIndex];
    return [self readShareCacheWith:key];
}

+ (int)readShareCacheWith:(NSString *)key{
    id obj = [[TMCache sharedCache] objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)obj;
        return number.intValue;
    }
    return 0;
}

- (void)deleteRequestParamsWithChannelId:(NSString *)channelId {
    if (channelId.length == 0) {
        return;
    }
    NSMutableDictionary *valueDic = [NSMutableDictionary dictionaryWithDictionary:[[TMCache sharedCache] objectForKey:kRequestParamCache]];
    if (valueDic == nil || [valueDic count] == 0) {
        return;
    }
    [valueDic removeObjectForKey:channelId];
    
    [[TMCache sharedCache] setObject:valueDic forKey:kRequestParamCache];
    
    self.focusPosition = @"1";
    self.lastUpdateTime = @"0";
    self.mainFocalId = @"0";
    self.viceFocalId = @"0";
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", channelId, kParamPageNum];
    [[TMCache sharedCache] removeObjectForKey:key];
    key = [NSString stringWithFormat:@"%@_%@", channelId, kParamPageTimes];
    [[TMCache sharedCache] removeObjectForKey:key];
    key = [NSString stringWithFormat:@"%@_%@", channelId, kMinTimelineIndex];
    [[TMCache sharedCache] removeObjectForKey:key];
}

- (void)deleteAllChannelsRequestParams {
    [[TMCache sharedCache] removeObjectForKey:kRequestParamCache];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", [SNUtility sharedUtility].currentChannelId, kParamPageNum];
    [[TMCache sharedCache] removeObjectForKey:key];
    key = [NSString stringWithFormat:@"%@_%@", [SNUtility sharedUtility].currentChannelId, kParamPageTimes];
    [[TMCache sharedCache] removeObjectForKey:key];
    key = [NSString stringWithFormat:@"%@_%@", [SNUtility sharedUtility].currentChannelId, kMinTimelineIndex];
    [[TMCache sharedCache] removeObjectForKey:key];
}

- (void)saveFocusPosition:(NSString *)positon
            withChannelId:(NSString *)channelId {
    if(channelId.length > 0) {
        NSMutableDictionary *valueDic = [NSMutableDictionary dictionaryWithDictionary:[[TMCache sharedCache] objectForKey:kRequestParamCache]];
        if (valueDic == nil || [valueDic count] == 0) {
            return;
        }
        
        NSMutableDictionary *itemDic = [valueDic objectForKey:channelId];
        if (itemDic != nil) {
            self.focusPosition = positon;
            [itemDic setObject:self.focusPosition forKey:kParamFocusPosition];
            [[TMCache sharedCache] setObject:valueDic
                                      forKey:kRequestParamCache];
        }
    }
}

- (NSString *)getFocusPositionWithChannelId:(NSString *)channelId {
    NSMutableDictionary *valueDic = [NSMutableDictionary dictionaryWithDictionary:[[TMCache sharedCache] objectForKey:kRequestParamCache]];
    if (valueDic == nil || [valueDic count] == 0) {
        return nil;
    }
    
    NSDictionary *itemDic = [valueDic objectForKey:channelId];
    if (itemDic != nil) {
        return [itemDic objectForKey:kParamFocusPosition defalutObj:nil];
    }
    
    return nil;
}

- (void)clearAllContentToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kParamContentToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteContentTokenWithChannelId:(NSString *)channelId {
    if(channelId.length > 0) {
        NSObject *obj = [[[NSUserDefaults standardUserDefaults] objectForKey:kParamContentToken] mutableCopy];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            dic = (NSMutableDictionary *)obj;
        }
        [dic removeObjectForKey:channelId];
        
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kParamContentToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)saveContentToken:(NSString *)token
           withChannelId:(NSString *)channelId {
    if(channelId.length > 0 && token.length > 0) {
        NSObject *obj = [[[NSUserDefaults standardUserDefaults] objectForKey:kParamContentToken] mutableCopy];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            dic = (NSMutableDictionary *)obj;
        }
        [dic setObject:token forKey:channelId];
    
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kParamContentToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)getContentTokenWithChannelId:(NSString *)channelId {
    if (channelId.length > 0) {
        NSObject *obj = [[[NSUserDefaults standardUserDefaults] objectForKey:kParamContentToken] mutableCopy];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)obj;
            return [dic objectForKey:channelId defalutObj:kDefaultContentToken];
        }
    }
    
    return kDefaultContentToken;
}

- (SNTopNewsStatus)getTopNewsStatus:(NSString *)token
                          channelId:(NSString *)channelId {
    if ([token isEqualToString:kDefaultContentToken]) {
        return SNTopNewsNULL;
    }
    
    NSString *contentToken = [self getContentTokenWithChannelId:channelId];
    return [contentToken isEqualToString:token] ? SNTopNewsDefault : SNTopNewsUpdate;
}

#pragma mark 焦点图轮播Index
- (void)setFocusImageIndex:(int)index
                 channelId:(NSString *)channelId {
    if (channelId.length <= 0) {
        return;
    }
    [self.focusImageIndexDic setObject:[NSNumber numberWithInt:index]
                                forKey:channelId];
}

- (int)getFocusImageIndexWithChannelId:(NSString *)channelId {
    NSNumber *indexNum = [self.focusImageIndexDic
                          objectForKey:channelId defalutObj:nil];
    if (indexNum == nil) {
        return 0;
    }
    
    return [indexNum intValue];
}

#pragma mark 当前频道停留总时长
- (void)recordRollingNewsBeginTime {
    rollingNewsBeginTime = [NSDate date];
}

- (NSTimeInterval)rollingNewsTotalTime {
    if (self.rollingNewsBeginTime == nil) {
        //不上报
        return 0;
    }
    
    NSTimeInterval start = [self.rollingNewsBeginTime timeIntervalSince1970];
    NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval value = end - start;
    
    //重置开始时间，避免重复计时 如果设置[NSDate date], 正文页点击搜狐重置，统计时间有误
    self.rollingNewsBeginTime = nil;
    
    return value;
}

+ (BOOL)needResetCurChannel {
//    NSMutableDictionary *valueDic = [[TMCache sharedCache] objectForKey:kRequestParamCache];
//
//    NSDictionary *itemDic = [valueDic objectForKey:[SNUtility sharedUtility].currentChannelId defalutObj:nil];
//
//    int times = 0;
//    if (itemDic != nil) {
//        times = [[itemDic objectForKey:kParamPageTimes defalutObj:nil] integerValue];
//    }
    int times = [SNRollingNewsPublicManager readRollingTimesWithChannelId:[SNUtility sharedUtility].currentChannelId];

    return times == 0;
}

+ (BOOL)needResetHotWords {
    int page = [SNRollingNewsPublicManager readRollingPageWithChannelId:@"1"];
    int times = [SNRollingNewsPublicManager readRollingTimesWithChannelId:@"1"];
//    return [SNRollingNewsPublicManager sharedInstance].pageNum == 1 && [SNRollingNewsPublicManager sharedInstance].times == 1;
    return (page == 1) && (times == 1);
}

@end
