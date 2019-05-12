//
//  WSMVVideoStatisticManager.m
//  sohunews
//
//  Created by handy wang on 10/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "WSMVVideoStatisticManager.h"
#import "WSMVConst.h"
#import "WSMVVideoPlayerView.h"
#import "SNVideoAd.h"
#import "SNStatisticsManager.h"
#import "SNPickStatisticRequest.h"

@interface WSMVVideoStatisticManager()
@property (nonatomic, strong)NSMutableArray *SVCache;
@property (nonatomic, assign)NSTimeInterval fflTimeCost;
@end

@implementation WSMVVideoStatisticManager

#pragma mark - Instance method
+ (WSMVVideoStatisticManager *)sharedIntance {
    static WSMVVideoStatisticManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WSMVVideoStatisticManager alloc] init];
    });
    
    return _sharedInstance;
}

+ (NSString *)networkReachability {
    BOOL isWifi = ![SNUtility getApplicationDelegate].isWWANNetworkReachable;
    return isWifi ? @"wifi" : @"2G,3G";
}


#pragma mark - Public

- (void)statVideoPV:(WSMVVideoStatisticModel *)statisticModel {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"show" forKey:@"_tp"];
    [params setValue:statisticModel.vid forKey:@"vid"];
    [params setValue:statisticModel.newsId forKey:@"newsId"];
    [params setValue:statisticModel.subId forKey:@"subId"];
    [params setValue:statisticModel.channelId forKey:@"channelId"];
    [params setValue:statisticModel.messageId forKey:@"mid"];
    [params setValue:[NSString stringWithFormat:@"%zd",statisticModel.refer] forKey:@"_refer"];
    [params setValue:statisticModel.recomInfo ? : @"" forKey:@"recomInfo"];
    
    [self statisticUploadRequestWithParams:params];
}

/**/
- (void)statNewVideoPV:(WSMVVideoStatisticModel *)statisticModel{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"show" forKey:@"_tp"];
    [params setValue:statisticModel.vid forKey:@"vid"];
    [params setValue:statisticModel.channelId forKey:@"channelId"];
    [params setValue:statisticModel.siteId forKey:@"siteId"];
    [params setValue:statisticModel.columnId forKey:@"columnId"];
    [params setValue:statisticModel.page forKey:@"page"];
    [params setValue:statisticModel.recomInfo ? : @"" forKey:@"recomInfo"];
    
    [self statisticUploadRequestWithParams:params];
    
    [SNUtility missingCheckReportWithUrl:[SNAPI aDotGifUrlWithParameters:[params toUrlString]]];
}

//VV统计
- (void)statNewVideoVV:(WSMVVideoStatisticModel *)statisticModel{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"vv" forKey:@"_tp"];
    [params setValue:statisticModel.vid forKey:@"vid"];
    [params setValue:statisticModel.channelId forKey:@"channelId"];
    [params setValue:[NSString stringWithFormat:@"%f",statisticModel.playtimeInSeconds*1000] forKey:@"ptime"];
    [params setValue:[NSString stringWithFormat:@"%f",statisticModel.totalTimeInSeconds*1000] forKey:@"ttime"];
    [params setValue:statisticModel.siteId forKey:@"siteId"];
    [params setValue:statisticModel.columnId forKey:@"columnId"];
    [params setValue:statisticModel.offline forKey:@"offline"];
    [params setValue:statisticModel.page forKey:@"page"];
    [params setValue:statisticModel.recomInfo ? : @"" forKey:@"recomInfo"];
    
    [self statisticUploadRequestWithParams:params];
    
    [SNUtility missingCheckReportWithUrl:[SNAPI aDotGifUrlWithParameters:[params toUrlString]]];
}

- (void)statNewVideoLoad:(WSMVVideoStatisticModel *)statisticModel{
    NSString *PVURL = [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=load&channelId=%@&screen=%@&net=%@"];
    NSString *_pvStatURLString = [NSString stringWithFormat:PVURL,
                                  statisticModel.channelId,
                                  statisticModel.screen,
                                  [statisticModel networkReachability]
                                  ];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"load" forKey:@"_tp"];
    [params setValue:statisticModel.screen forKey:@"screen"];
    [params setValue:statisticModel.channelId forKey:@"channelId"];
    [params setValue:statisticModel.newsId forKey:@"newsId"];
    
    [self statisticUploadRequestWithParams:params];
    
    [SNUtility missingCheckReportWithUrl:_pvStatURLString];
}

- (void)statVideoVV:(WSMVVideoStatisticModel *)statisticModel inVideoPlayer:(WSMVVideoPlayerView *)videoPlayer {
    
    //---视频广告统计数据
    BOOL hasAd = [videoPlayer getMoviePlayer].isLoadAdvert;
    NSTimeInterval duration = videoPlayer.playingVideoModel.videoAd.duration;
    NSTimeInterval adPlaytime = (duration-[videoPlayer getMoviePlayer].advertCurrentPlaybackTime);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"vv" forKey:@"_tp"];
    [params setValue:statisticModel.vid forKey:@"vid"];
    [params setValue:statisticModel.newsId forKey:@"newsId"];
    [params setValue:statisticModel.subId forKey:@"subId"];
    [params setValue:statisticModel.channelId forKey:@"channelId"];
    [params setValue:statisticModel.messageId forKey:@"mid"];
    [params setValue:[NSString stringWithFormat:@"%zd",statisticModel.refer] forKey:@"_refer"];
    [params setValue:[NSString stringWithFormat:@"%f",statisticModel.playtimeInSeconds*1000] forKey:@"ptime"];
    [params setValue:[NSString stringWithFormat:@"%f",statisticModel.totalTimeInSeconds*1000] forKey:@"ttime"];
    [params setValue:statisticModel.siteId forKey:@"siteId"];
    [params setValue:statisticModel.columnId forKey:@"columnId"];
    [params setValue:statisticModel.offline forKey:@"offline"];
    [params setValue:[NSString stringWithFormat:@"%zd",hasAd] forKey:@"ad"];
    [params setValue:[NSString stringWithFormat:@"%f",adPlaytime*1000] forKey:@"adtime"];
    [params setValue:statisticModel.recomInfo ? : @"" forKey:@"recomInfo"];
    
    [self statisticUploadRequestWithParams:params];
}

//连播统计
- (void)cacheVideoSV:(WSMVVideoStatisticModel *)statisticModel {
    if (!statisticModel || statisticModel.vid.length <= 0) {
        NSLogError(@"Give up cacheVideoSV for invalid vid.");
        return;
    }
    if (!(self.SVCache)) {
        self.SVCache = [NSMutableArray array];
    }
    
    BOOL existed = NO;
    NSInteger  needReplaceIndex = NSNotFound;
    for (int i = 0; i < self.SVCache.count; i++) {
        WSMVVideoStatisticModel *cachedStatModel = [self.SVCache objectAtIndex:i];
        if ([cachedStatModel.vid isEqualToString:statisticModel.vid]) {
            existed = YES;
            if (statisticModel.playtimeInSeconds > cachedStatModel.playtimeInSeconds) {
                needReplaceIndex = i;
            }
        }
    }
    
    if (existed) {
        if (needReplaceIndex != NSNotFound) {
            [self.SVCache replaceObjectAtIndex:needReplaceIndex withObject:statisticModel];
        }
    }
    else {
        [self.SVCache addObject:statisticModel];
    }
}

- (void)statVideoSV {
    if (self.SVCache.count < 2) {
        NSLogError(@"Give up statVideoSV for %d cached video, at least need 2.", self.SVCache.count);
    }
    else {
        //ptimes
        NSString *ptimes = @"";
        for (WSMVVideoStatisticModel *statModel in self.SVCache) {
            if (ptimes.length <= 0) {
                ptimes = [NSString stringWithFormat:@"%@-%f", statModel.vid, statModel.playtimeInSeconds*1000];//毫秒
            }
            else {
                ptimes = [ptimes stringByAppendingFormat:@",%@-%f", statModel.vid, statModel.playtimeInSeconds*1000];//毫秒
            }
        }
        WSMVVideoStatisticModel *_firstModel = [self.SVCache objectAtIndex:0];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
        [params setValue:@"video" forKey:@"_act"];
        [params setValue:@"chainPlay" forKey:@"_tp"];
        [params setValue:_firstModel.vid forKey:@"vid"];
        [params setValue:_firstModel.newsId forKey:@"newsId"];
        [params setValue:_firstModel.messageId forKey:@"mid"];
        [params setValue:[NSString stringWithFormat:@"%zd",_firstModel.refer] forKey:@"_refer"];
        [params setValue:ptimes forKey:@"ptimes"];
        
        [self statisticUploadRequestWithParams:params];
    }
    
    [self.SVCache removeAllObjects];
}

//播放器行为统计
- (void)statVideoPlayerActions:(WSMVVideoStatisticModel *)statisticModel actionsData:(NSMutableDictionary *)actionData {
    if (actionData.count <= 0) {
        NSLogError(@"Give up statVideoPlayerActions for empty actions data.");
        return;
    }
    
    //actions
    NSString *_actions = @"";
    for (NSString *_actionKey in actionData.allKeys) {
        if (_actions.length <= 0) {
            _actions = [NSString stringWithFormat:@"%@-%d", _actionKey, [actionData intValueForKey:_actionKey defaultValue:0]];
        }
        else {
            _actions = [_actions stringByAppendingFormat:@",%@-%d", _actionKey, [actionData intValueForKey:_actionKey defaultValue:0]];
        }
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"playActs" forKey:@"_tp"];
    [params setValue:statisticModel.vid forKey:@"vid"];
    [params setValue:statisticModel.newsId forKey:@"newsId"];
    [params setValue:statisticModel.subId forKey:@"subId"];
    [params setValue:statisticModel.channelId forKey:@"channelId"];
    [params setValue:statisticModel.messageId forKey:@"mid"];
    [params setValue:statisticModel.recomInfo ? : @"" forKey:@"recomInfo"];
    [params setValue:[NSString stringWithFormat:@"%zd",statisticModel.refer] forKey:@"_refer"];
    [params setValue:_actions forKey:@"pacts"];
    
    [self statisticUploadRequestWithParams:params];
    
    
    [actionData removeAllObjects];
}

#pragma mark - FFL统计
//FFL stands for FIRST FRAME LOAING。

- (void)cacheFFLTimeCost:(NSTimeInterval)fflTimeCostInMilliseconds {
    self.fflTimeCost = fflTimeCostInMilliseconds;
}

//视频第一帧缓冲统计, 缓冲成功或失败都要统计
- (void)statFFL:(WSMVVideoStatisticModel *)statisticModel {
    //毫秒
    double loadingDurationInMillisecond = self.fflTimeCost;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"loading" forKey:@"_tp"];
    [params setValue:statisticModel.vid forKey:@"vid"];
    [params setValue:statisticModel.newsId forKey:@"newsId"];
    [params setValue:statisticModel.subId forKey:@"subId"];
    [params setValue:statisticModel.channelId forKey:@"channelId"];
    [params setValue:statisticModel.messageId forKey:@"mid"];
    [params setValue:[NSString stringWithFormat:@"%zd",statisticModel.refer] forKey:@"_refer"];
    [params setValue:[NSString stringWithFormat:@"%zd",(statisticModel.succeededToFFL ? 1 : 0)] forKey:@"suc"];
    [params setValue:[NSString stringWithFormat:@"%f",loadingDurationInMillisecond] forKey:@"ltime"];
    [params setValue:@"" forKey:@"ptime"];
    [params setValue:@"" forKey:@"ttime"];
    [params setValue:statisticModel.siteId forKey:@"siteId"];
    [params setValue:statisticModel.recomInfo ? : @"" forKey:@"recomInfo"];
    
    [self statisticUploadRequestWithParams:params];
}

#pragma mark - 视频广告统计
//广告加载上报
- (void)statVideoAdLoad:(id)statData {
    if (!!statData && [statData isKindOfClass:[SNStatLoadInfo class]]) {
        SNDebugLog(@"Stat video-ad load...");
        [[SNStatisticsManager shareInstance] uploadStaticsEvent:statData];
    } else {
        SNDebugLog(@"Give up stating video-ad load...");
    }
}

//广告VV上报
- (void)statVideoAdVV:(id)statData {
    if (!!statData && [statData isKindOfClass:[SNStatExposureInfo class]]) {
        SNDebugLog(@"Stat video-ad vv...");
        [[SNStatisticsManager shareInstance] uploadStaticsEvent:statData];
    } else {
        SNDebugLog(@"Give up stating video-ad vv...");
    }
}

//广告点击上报
- (void)statVideoAdClick:(id)statData {
    if (!!statData && [statData isKindOfClass:[SNStatClickInfo class]]) {
        SNDebugLog(@"Stat video-ad click...");
        [[SNStatisticsManager shareInstance] uploadStaticsEvent:statData];
    } else {
        SNDebugLog(@"Give up stating video-ad click...");
    }
}

#pragma mark - 视频Tab中行为统计
// 点击视频tab右上角 频道按钮
- (void)videoFireChannelsActionStatistic {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"tag" forKey:@"_tp"];
    
    [self statisticUploadRequestWithParams:params];
}

// 点击进入热播管理
- (void)videoFireHotColumnsActionStatistic {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"video" forKey:@"_act"];
    [params setValue:@"hot" forKey:@"_tp"];
    
    [self statisticUploadRequestWithParams:params];
}

// 点击添加或者取消某个热播栏目
- (void)videoFireHotColumnsSubActionStatisticWithActionData:(NSDictionary *)actionData {
    if (actionData && [actionData isKindOfClass:[NSDictionary class]]) {
        NSString *action = [actionData stringValueForKey:@"action" defaultValue:@""];
        NSString *columnId = [actionData stringValueForKey:@"columnId" defaultValue:@""];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
        [params setValue:@"video" forKey:@"_act"];
        [params setValue:@"hotset" forKey:@"_tp"];
        [params setValue:action forKey:@"action"];
        [params setValue:columnId forKey:@"columnId"];
        
        [self statisticUploadRequestWithParams:params];
    }
}

- (void)pgcVideoStaticWithType:(NSString *)type model:(WSMVVideoStatisticModel *)model {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"pgc_video" forKey:@"_act"];
    [params setValue:type forKey:@"_tp"];
    [params setValue:[NSString stringWithFormat:@"%f", model.totalTimeInSeconds] forKey:@"ttime"];
    [params setValue:model.newsId forKey:@"newsId"];
    [params setValue:model.vid forKey:@"vid"];
    [params setValue:model.recomInfo ? : @"" forKey:@"recomInfo"];
    [params setValue:[SNUtility sharedUtility].currentChannelId forKey:@"channelid"];
    [self statisticUploadRequestWithParams:params];
}

- (void)statisticUploadRequestWithParams:(NSDictionary *)params {
    
    [[[SNPickStatisticRequest alloc] initWithDictionary:params
                                       andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
}

@end
