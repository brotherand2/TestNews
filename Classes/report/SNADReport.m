//
//  SNADReport.m
//  sohunews
//
//  Created by yangln on 2016/12/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNADReport.h"
//#import "AFNetworking.h"
#import "SNPickStatisticRequest.h"

@interface SNADReport ()
//@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;
@property (nonatomic, strong) NSMutableDictionary *allAdData;
@property (nonatomic) NSInteger idCounter;

@end

@implementation SNADReport

+ (SNADReport *)shareInstance {
    static SNADReport* adReport = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adReport = [[SNADReport alloc] init];
    });
    return adReport;
}

- (id)init {
    self = [super init];
    if (self) {
        self.allAdData = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark report
+ (SNReportAdData *)reportData:(NSInteger)dataId {
    return [SNADReport shareInstance].allAdData[@(dataId)];
}

+ (void)reportLoad:(NSInteger)dataId {
    [[self shareInstance] report:dataId type:STADDisplayTrackTypeLoadImp];
}

+ (void)reportClick:(NSInteger)dataId {
    [[self shareInstance] report:dataId type:STADDisplayTrackTypeClick];
}

+ (void)reportExposure:(NSInteger)dataId {
    [[self shareInstance] report:dataId type:STADDisplayTrackTypeImp];
}

+ (void)reportEmpty:(NSInteger)dataId {
    [[self shareInstance] report:dataId type:STADDisplayTrackTypeNullAD];
}

+ (void)reportUninteresting:(NSInteger)dataId {
    [[self shareInstance] report:dataId type:STADDisplayTrackTypeNotInterest];
}

+ (void)removeUnusedAd:(NSInteger)dataId {
    [[SNADReport shareInstance].allAdData removeObjectForKey:@(dataId)];
}

+ (BOOL)isEmptyAd:(NSInteger)dataId {
    SNReportAdData *data = [SNADReport reportData:dataId];
    return nil == data ? YES : data.isEmptyAd;
}

- (void)report:(NSInteger)dataId type:(STADDisplayTrackType)type
{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        SNReportAdData *data = [SNADReport reportData:dataId];
        
        // 没数据，或者报过了，就不报了
        if (!data || [data isReported:type]) {
            return;
        }
        
        [data report:type];
        NSMutableDictionary *sdkDic = [data toSDKReportData:type];
        // 报广告SDK
        if (data.isStreamAd) {
            [[SNADManager sharedSTADManager] stadServerToServerTrackWithType:type andParamDict:sdkDic];
        }
        else {
            switch (type) {
                case STADDisplayTrackTypeLoadImp:
                    [[SNADManager sharedSTADManager] stadLoadImpTrackingForNews:data.sdkView andParam:sdkDic];
                    break;
                case STADDisplayTrackTypeClick:
                    [[SNADManager sharedSTADManager] stadClickTrackingForNews:data.sdkView andParam:sdkDic];
                    break;
                case STADDisplayTrackTypeImp:
                    [[SNADManager sharedSTADManager] stadImpTrackingForNews:data.sdkView andParam:sdkDic];
                    break;
                case STADDisplayTrackTypeNullAD:
                    [[SNADManager sharedSTADManager] stadNullADTrackingForNews:data.sdkView andParam:sdkDic];
                    break;
                default:
                    break;
            }
        }
        
        __block NSDictionary *statDic = [data toStatisticsReportData:type];
        
        // 这个函数挂过，原因不明，还是try catch住吧
        @try {
            [[[SNPickStatisticRequest alloc] initWithDictionary:statDic
                                               andStatisticType:PickLinkDotGifTypeC
                                                 needAESEncrypt:NO] send:nil failure:nil];
            
        }
        @catch (NSException *exception) {
        }
        @finally {
            if (type == STADDisplayTrackTypeNullAD) {
                // 报了空广告，这个结构肯定可以删除了。 因为没有广告可以继续上报了。
                [SNADReport removeUnusedAd:dataId];
            }
        }
    //});
}

#pragma mark parse
+ (void)parseAdDictionary:(NSDictionary *)beParse value:(NSMutableDictionary *)save {
    for (NSString *key in beParse) {
        // 这个key对上报没用
        if ([key hasPrefix:@"resource"]) {
            continue;
        }
        
        NSObject *obj = beParse[key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self parseAdDictionary:(NSDictionary *)obj value:save];
        }
        else {
            save[key] = obj;
        }
    }
}

+ (NSInteger)parseStreamData:(NSDictionary *)data root:(NSDictionary *)root tab:(ReportDataAdTab)tab channel:(NSString *)channelId adType:(ReportDataAdType)adType {
    if (!data || data.count == 0 || !root || root.count == 0) {
        return 0;
    }
    
    SNReportAdData *r = [[SNReportAdData alloc] initWithId:[SNADReport shareInstance].idCounter++ adType:adType tab:tab];
    [self parseAdDictionary:data value:r.serverParam];
    
    r.serverParam[@"jsondata"] = data[@"data"];
    r.serverParam[@"blockId"] = root[@"blockId"]?:@"";
    r.cache = NO;
    r.spaceId = r.serverParam[@"itemspaceid"];
    
    if (nil != channelId) {
        r.serverParam[@"channel"] = channelId;
    }
    
    [SNADReport shareInstance].allAdData[@(r.dataId)] = r;
    
    return r.dataId;
}
+ (NSInteger)parseLiveRoomStreamData:(NSDictionary *)data root:(NSDictionary *)root {
    NSInteger dataId = [SNADReport parseStreamData:data root:root tab:adReportTabNews channel:[[SNVideoAdContext sharedInstance] getCurrentChannelID] adType:adReportTimeLineStream];
    if (0 == dataId){
        return 0;
    }
    
    SNReportAdData *report = [SNADReport reportData:dataId];
    [report.serverParam setObject:@"news" forKey:@"objFrom"];
    [report addRoomId:data[@"roomId"]];
    
    // 直播间顶部banner
    if ([SpaceId12355 isEqualToString:report.spaceId]) {
        // 这个广告位的objLabel和sdk的广告一样
        report.adType = adReportSDK;
    }
    
    if (report.isEmptyAd) {
        // 空广告，报了就丢弃了，没必要保存和返回id
        [SNADReport reportEmpty:report.dataId];
        return 0;
    }
    return report.dataId;
}

+ (NSInteger)parseSDKData:(NSDictionary *)adInfo root:(NSDictionary *)root channel:(NSString *)channel adType:(ReportDataAdType)type tab:(ReportDataAdTab)tab {
    if (nil == adInfo || adInfo.count == 0)
    {
        return 0;
    }
    
    SNReportAdData *r = [[SNReportAdData alloc] initWithId:[SNADReport shareInstance].idCounter++ adType:type tab:tab];
    [self parseAdDictionary:adInfo value:r.serverParam];
    
    r.cache = NO;
    r.spaceId = r.serverParam[@"itemspaceid"];
    
    if (nil != channel) {
        r.serverParam[@"channel"] = channel;
    }
    
    if (nil != root[@"token"]) {
        r.serverParam[@"token"] = root[@"token"];
    }
    
    if (nil != root[@"ctx"]) {
        r.serverParam[@"ctx"] = root[@"ctx"];
    }
    
    [SNADReport shareInstance].allAdData[@(r.dataId)] = r;
    
    return r.dataId;
}

+ (void)addSdkParam:(NSInteger)dataId sdkParam:(NSDictionary *)param {
    if (!param || param.count == 0) {
        return ;
    }
    
    SNReportAdData *data = [SNADReport reportData:dataId];
    if (data) {
        [data.sdkParam addEntriesFromDictionary:param];
    }
}

+ (void)addSdkView:(NSInteger)dataId sdkView:(UIView *)view {
    if (!view) {
        return;
    }
    
    SNReportAdData *data = [SNADReport reportData:dataId];
    if (data) {
        data.sdkView = view;
    }
}

+ (void)addSpaceId:(NSInteger)dataId spaceId:(NSString *)spaceId {
    SNReportAdData *data = [SNADReport reportData:dataId];
    if (data){
        data.spaceId = spaceId;
    }
}

+ (void)addClientParams:(NSInteger)dataId params:(NSDictionary *)params {
    SNReportAdData *data = [SNADReport reportData:dataId];
    if (data){
        [SNADReport parseAdDictionary:params value:data.clientParam];
    }
}

@end
