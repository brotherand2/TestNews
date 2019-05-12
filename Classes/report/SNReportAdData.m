//
//  SNReportData.m
//  sohunews
//
//  Created by Xiang Wei Jia on 4/4/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNReportAdData.h"
#import "SNStatInfo.h"
#import "SNStatisticsConst.h"

@interface SNReportAdData()

@end

@implementation SNReportAdData

- (instancetype)initWithId:(NSInteger)dataId adType:(ReportDataAdType)type tab:(ReportDataAdTab)tab
{
    self = [super init];
    
    _tab = tab;
    _adType = type;
    _dataId = dataId;
    _clientParam = [[NSMutableDictionary alloc] init];
    _serverParam = [[NSMutableDictionary alloc] init];
    _sdkParam = [[NSMutableDictionary alloc] init];
    _cache = NO;
    
    return self;
}

- (BOOL)isStreamAd
{
    switch (_adType)
    {
        case adReportTimeLineStream:
        case adReportRecommendStream:
        case adReportPopularizeTimeLine:
        case adReportPopularizeRecommend:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)isReported:(STADDisplayTrackType)type
{
    switch (type)
    {
        case STADDisplayTrackTypeNotInterest:    //不感兴趣
        {
            return _isReportedUninteresting;
        }
        case STADDisplayTrackTypeClick:          //点击
        {
            return NO;
        }
        case STADDisplayTrackTypeLoadImp:        //加载曝光 （曝光）
        {
            return _isReportedLoad;
        }
        case STADDisplayTrackTypeImp:            //展示曝光 （有效曝光）
        {
            return _isReportedExposure;
        }
        case STADDisplayTrackTypeNullAD:         //空广告曝光
        {
            return _isReportedEmpty;
        }
        default:
        {
            // 不认识的上报统一表示为已经上报过了。
            return YES;
        }
    }
}

- (void)report:(STADDisplayTrackType)type
{
    switch (type)
    {
        case STADDisplayTrackTypeNotInterest:    //不感兴趣
        {
            _isReportedUninteresting = YES;
            
            break;
        }
        case STADDisplayTrackTypeLoadImp:        //加载曝光 （曝光）
        {
            _isReportedLoad = YES;
            
            break;
        }
        case STADDisplayTrackTypeImp:            //展示曝光 （有效曝光）
        {
            _isReportedExposure = YES;
            
            break;
        }
        case STADDisplayTrackTypeNullAD:         //空广告曝光
        {
            _isReportedEmpty = YES;
            
            break;
        }
        default:
        {
            break;
        }
    }
}

- (NSMutableDictionary *)toSDKReportData:(STADDisplayTrackType)reportType
{
    NSMutableDictionary *reportData = [NSMutableDictionary dictionary];
    if (((NSString *)_serverParam[adTrackParamAppChn]).length > 0)
    {
        reportData[adTrackParamAppChn] = _serverParam[adTrackParamAppChn];
    }
    else
    {
        reportData[adTrackParamAppChn] = [NSString stringWithFormat:@"%d", [SNUtility marketID]];
    }
    
    reportData[adTrackParamNewsChn] = _serverParam[@"channel"] ? : @"";
    reportData[adTrackParamGbcode] = _serverParam[adTrackParamGbcode] ? : @"";
    reportData[adTrackParamADPType] = _serverParam[adTrackParamADPType] ? : @"";
    reportData[@"debugloc"] = _serverParam[adTrackParamGbcode] ? : @"";
    
    NSString * blockId = _serverParam[@"blockId"] ? : @"";
    if (blockId.length > 0) {
        reportData[@"blockId"] = blockId;
    }
    // 如果服务器的参数和sdk的冲突，以SDK为准
    [reportData addEntriesFromDictionary:_sdkParam];
    
    // 如果客户端的参数和服务器返回的冲突，以客户端的为准
    [reportData addEntriesFromDictionary:_clientParam];

    
    if (nil != _sdkParam)
    {
        [reportData addEntriesFromDictionary:_sdkParam];    
    }

    [reportData addEntriesFromDictionary:_clientParam];
    
    // 缓存标志
    reportData[@"appdelaytrack"] = _cache ? @"1" : @"0";
    
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    
    reportData[adTrackParamCid] = cid == nil ? @"" : cid;

    if (nil != _serverParam[@"jsondata"]) {
        reportData[@"jsondata"] = _serverParam[@"jsondata"];
    }
    if ([reportData[adTrackParamSpaceid] isEqualToString:@"12224"] || [reportData[adTrackParamSpaceid] isEqualToString:@"12717"] || [reportData[adTrackParamSpaceid] isEqualToString:@"12718"] || [reportData[adTrackParamSpaceid] isEqualToString:@"13372"] || [reportData[adTrackParamSpaceid] isEqualToString:@"13373"]) {
        if (reportData[adTrackParamPosition]) {
            [reportData removeObjectForKey:adTrackParamPosition];
        }
        if (reportData[adTrackParamReposition]) {
            [reportData removeObjectForKey:adTrackParamReposition];
        }
        if (reportData[adTrackParamAbposition]) {
            [reportData removeObjectForKey:adTrackParamAbposition];
        }
        if (reportData[adTrackParamRefreshCount]) {
            [reportData removeObjectForKey:adTrackParamRefreshCount];
        }
        if (reportData[adTrackParamLoadmoreCount]) {
            [reportData removeObjectForKey:adTrackParamLoadmoreCount];
        }
        
    }
    return reportData;
}

- (NSInteger)objLabel:(BOOL)empty
{
    // 然后才判断adType
    switch (_adType)
    {
        case adReportTimeLineStream:
        {
            return empty ? (SNStatInfoUseTypeTimelineAd + 10)
                         : SNStatInfoUseTypeTimelineAd;
        }
        case adReportRecommendStream:
        {
            return empty ? (SNStatInfoUseTypeRecommed + 10)
                         : SNStatInfoUseTypeRecommed;
        }
        case adReportSDK:
        {
            return empty ? (SNStatInfoUseTypeOutTimelineAd  + 10)
                         : SNStatInfoUseTypeOutTimelineAd ;
        }
        case adReportPush:
        {
            return empty ? (SNStatInfoUseTypePushAd + 10) : SNStatInfoUseTypePushAd;
        }
        case  adReportPopularizeTimeLine:
        {
            return empty ? (SNStatInfoUseTypeOutTimelinePopularize + 10)
                         : SNStatInfoUseTypeOutTimelinePopularize;
        }
        case adReportPopularizeRecommend:
        {
            return empty ? (SNStatInfoUseTypeEmptyOutTimelinePopularize + 10)
                         : SNStatInfoUseTypeEmptyOutTimelinePopularize;
        }
    }
}

+ (NSString *)stateType:(STADDisplayTrackType)reportType
{
    switch (reportType)
    {
        case STADDisplayTrackTypeNotInterest:
            return @"unintr";
        case STADDisplayTrackTypeClick:
            return @"clk";
        case STADDisplayTrackTypeLoadImp:
            return @"load";
        case STADDisplayTrackTypeImp:
            return @"show";
        case STADDisplayTrackTypeNullAD:
            // 不要奇怪，约定的就是空广告传load. 为什么这么约定不要找我，不是我约定的. 我来了就是这样的 by Cae
            return @"load";
        default:
            return @"";
    }
}

- (NSString *)objType
{
    // objType还有其他的值，现在使用到的只有spaceId，等全面接管首页流内上报的时候就有其他的值了
    return _spaceId;
}

- (NSString *)objFrom
{
    switch (_tab)
    {
        case adReportTabNews:
            return @"news";
            break;
        case adReportTabViedo:
            return @"video";
            break;
        case adReportTabMine:
            return @"mine";
            break;
        default:
            return @"unknown";
    }
}

- (NSDictionary *)toStatisticsReportData:(STADDisplayTrackType)reportType
{
    // 做一个字典是为了率重
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSObject *adId = _serverParam[@"adid"];
    [parameters setObject:adId ? : @"" forKey:@"objId"];
    
    parameters[@"ad_gbcode"] =  _serverParam[@"gbcode"] ? : @"";
    parameters[@"objLabel"] = @([self objLabel:reportType == STADDisplayTrackTypeNullAD]);
    parameters[@"statType"] = [SNReportAdData stateType:reportType];
    parameters[@"objType"] = [NSString stringWithFormat:@"ad_%@", [self objType]];
    parameters[@"token"] = _serverParam[@"token"] ? : @"";
    parameters[@"objFrom"] = [self objFrom];
    parameters[@"objFromId"] = _serverParam[@"channel"] ? : @"";
    parameters[@"appchn"] = _serverParam[@"appchn"] ? : @"";
    parameters[@"appdelaytrack"] = @(_cache ? 1 : 0);
    parameters[@"newschn"] = _serverParam[@"newschn"] ?: @"";
    parameters[@"position"] = _serverParam[@"position"] ?: @"";
    parameters[@"reposition"] = _serverParam[@"reposition"] ?: @"";
    parameters[@"abposition"] = _serverParam[@"abposition"] ? : @"";
    parameters[@"scope"] = _serverParam[@"scope"] ?: @"";
    parameters[@"rc"] = _serverParam[@"rc"] ?: @"";
    parameters[@"apid"] = self.spaceId;
    
    // 如果服务器的参数和sdk的冲突，以SDK为准
    [parameters addEntriesFromDictionary:_sdkParam];
    
    // 如果客户端的参数和服务器返回的冲突，以客户端的为准
    [parameters addEntriesFromDictionary:_clientParam];
    
    [self delUnsuedReportParams:parameters];
    
    return parameters;
}

// 删除上报不需要的数据。
// 必须要删除，因为某些不需要的数据可能因为上get的数据过大，导致上报失败
- (void)delUnsuedReportParams:(NSMutableDictionary *)dic
{
    [dic removeObjectForKey:@"click_url"];
    [dic removeObjectForKey:@"image_url"];
}

- (BOOL)isEmptyAd
{
    // 是SDK的广告，以sdk的返回值为准
    if (nil != _sdkView)
    {
        // 如果SDK有广告，sdkParam的内容肯定不是0个
        return _sdkParam.count == 0;
    }
    else
    {
        // server to server的广告，以server的返回值为准
        NSString *adType = _serverParam[@"adType"];
        NSString *error = _serverParam[@"error"];
        
        return (nil != adType && adType.integerValue == 2)
        || (nil != error && [error isEqualToString:@"1"]);
    }
}

@end

@implementation SNReportAdData(SNReportAdDataClientData)

- (void)addClientParams:(NSDictionary *)params
{
    
}

- (void)addPTime:(NSTimeInterval)pTime
{
    _clientParam[@"ptime"] = [NSString stringWithFormat:@"%g", pTime];
}

- (void)addTTime:(NSTimeInterval)tTime
{
    _clientParam[@"ttime"] = [NSString stringWithFormat:@"%g", tTime];
}

- (void)addExposureFrom:(NSInteger)from
{
    _clientParam[@"exposureFrom"] = @(from);
}

- (void)addNewsId:(NSString *)newsId
{
    _clientParam[@"newsid"] = [newsId copy];
}

- (void)addgbcode:(NSString *)gbcode
{
    _clientParam[@"gbcode"] = [gbcode copy];
}

- (void)addRoomId:(NSString *)roomId
{
    _clientParam[@"roomid"] = [roomId copy];
}

@end
