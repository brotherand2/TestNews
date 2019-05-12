//
//  SNNewsAd+analytics.m
//  sohunews
//
//  Created by jojo on 14-5-19.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsAd+analytics.h"
#import "STADManagerForNews.h"
#import "SNPreference.h"
#import "SNStatClickInfo.h"
#import "SNStatPlayInfo.h"
#import "SNStatExposureInfo.h"
#import "SNStatUninterestedInfo.h"
#import "SNStatisticsManager.h"
#import "SNAdStatisticsManager.h"
#import "SNRollingNewsConst.h"
#import "SNRollingNews.h"
#import "SNRollingNewsPublicManager.h"
#import "SNRollingNewsModel.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNUserLocationManager.h"
#import "SNAdvertiseManager.h"
#import "SNStatClickPhoneInfo.h"
#import <SCMobileAds/SCMobileAds.h>

@implementation SNNewsAd (analytics)

#pragma mark - 数据解析
- (NSDictionary *)adDataDic {
    return [self.newsDataDic dictionaryValueForKey:@"data" defalutValue:nil];
}

- (NSDictionary *)firstResourceDic {
    return [self.adDataDic dictionaryValueForKey:@"resource" defalutValue:nil];
}

- (NSString *)itemSpaceId {
    return [self.adDataDic stringValueForKey:@"itemspaceid" defaultValue:@""];
}

- (NSString *)impId {
    return [self.adDataDic stringValueForKey:@"impressionid" defaultValue:@""];
}

- (NSString *)monitorkey {
    return [self.adDataDic stringValueForKey:@"monitorkey" defaultValue:@""];
}

- (NSString *)reposition {
    return [self.newsDataDic stringValueForKey:@"position" defaultValue:@""];
}

- (NSString *)abposition {
    return [self.newsDataDic stringValueForKey:@"abposition" defaultValue:@""];
}

- (NSString *)rc {
    return [self.newsDataDic stringValueForKey:@"rc" defaultValue:@""];
}

- (NSString *)lc {
    return [self.newsDataDic stringValueForKey:@"lc" defaultValue:@""];
}

- (NSString *)rr {
    return [self.newsDataDic stringValueForKey:@"rr" defaultValue:@""];
}

- (NSString *)cid {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
}

- (NSString *)scope {
    return [self.newsDataDic stringValueForKey:adTrackParamScope defaultValue:nil];
}

- (NSString *)gbcode {
    return [self.newsDataDic stringValueForKey:adTrackParamGbcode defaultValue:nil];
}

- (NSString *)appChannel {
    return [self.newsDataDic stringValueForKey:adTrackParamAppChn defaultValue:nil];
}

- (NSString *)newsChannel {
    return [self.newsDataDic stringValueForKey:adTrackParamNewsChn defaultValue:nil];
}

// 第三方曝光参数，包含admaster pv监测地址
- (NSArray *)admaster_imp {
    return [self.firstResourceDic arrayValueForKey:@"admaster_imp" defaultValue:nil];
}

//包含第三方秒针pv监测地址
- (NSArray *)miaozhen_imp {
    return [self.firstResourceDic arrayValueForKey:@"miaozhen_imp" defaultValue:nil];
}

//包含adplus的pv监测和doubleclick的pv监测
- (NSArray *)normal_imp {
    return [self.firstResourceDic arrayValueForKey:@"imp" defaultValue:nil];
}

- (NSArray *)click_imp {
    return [self.firstResourceDic arrayValueForKey:@"click_imp" defaultValue:nil];
}

- (NSArray *)tel_imp {
    return [self.firstResourceDic arrayValueForKey:@"tel_imp" defaultValue:nil];
}

- (NSDictionary *)paramDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"10" forKey:@"adp_type"];
    [dic setObject:[SNPreference sharedInstance].marketId forKey:@"appchn"];
    if (self.channelId) {
        [dic setObject:self.channelId forKey:@"newschn"];
    }
    
    return dic;
}

#pragma mark - 统计方法
- (void)reportAdNotInterest:(SNRollingNews *)news {
    
    SNStatUninterestedInfo *info = [[SNStatUninterestedInfo alloc] init];
    
    [self updateInfoWithData:info data:news];
    info.objLabel = info.objLabel = [SNNewsAd getObjLebel:news.isPush spaceId:info.itemspaceid defaultLabel:news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd empty:NO];
    
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
}

- (void)reportAdVideoPlay:(SNRollingNews *)news{
    SNStatPlayInfo *info = [[SNStatPlayInfo alloc] init];
    
    [self updateInfoWithData:info data:news];
    info.objLabel = [SNNewsAd getObjLebel:news.isPush spaceId:info.itemspaceid defaultLabel:news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd empty:NO];
    
    info.isReported = [news isReportAd:AdReportStateClick];
    
    if ([news.templateType isEqualToString:@"22"] || [news.templateType isEqualToString:@"77"]) {
        if (info.videoAdPlayedTime == 0) { //从头播放
           
            info.vp = @"0";
           
            [self.tracking_imp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeNormal];
                }
            }];
        }else { //断点续播
            
            info.vp = @"2";
            
            [self.tracking_imp_Breakpoint   enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeNormal];
                }
            }];
        }
    }
    
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];

}

- (void)reportAdVideoFinishedPlay:(SNRollingNews *)news{
    SNStatPlayInfo *info = [[SNStatPlayInfo alloc] init];
    
    [self updateInfoWithData:info data:news];
    info.objLabel = [SNNewsAd getObjLebel:news.isPush spaceId:info.itemspaceid defaultLabel:news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd empty:NO];
    
    info.isReported = [news isReportAd:AdReportStateClick];
   
    if ([news.templateType isEqualToString:@"22"] || [news.templateType isEqualToString:@"77"]) {
        info.vp = @"1";
    }

    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    
    [self.tracking_imp_end enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeNormal];
        }
    }];
    
    
}

- (void)reportAdClickPhone:(SNRollingNews *)news {
    if (news.newsAd.phone.length == 0) {
        return;
    }
    SNStatClickPhoneInfo *info = [[SNStatClickPhoneInfo alloc] init];
    
    [self updateInfoWithData:info data:news];
    info.objLabel = [SNNewsAd getObjLebel:news.isPush spaceId:info.itemspaceid defaultLabel:news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd empty:NO];
    
    info.isReported = [news isReportAd:AdReportStateClick];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    
    news.adReportState = AdReportStateClick;
    // 第三方点击曝光
    [[self tel_imp] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeNormal];
        }
    }];
}

- (void)reportAdClick:(SNRollingNews *)news {
    
    if (news.link.length == 0) {
        return;///没有落地页不报c
    }
    
    SNStatClickInfo *info = [[SNStatClickInfo alloc] init];
    
    [self updateInfoWithData:info data:news];
    info.objLabel = [SNNewsAd getObjLebel:news.isPush spaceId:info.itemspaceid defaultLabel:news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd empty:NO];
    
    info.isReported = [news isReportAd:AdReportStateClick];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    if (news.newsAd.adStyle.length > 0) {
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=advertorial&_tp=pv&newsId=%@&channelid=%@&adStyle=%@", news.newsId, news.channelId, news.newsAd.adStyle]];
    } else {
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=advertorial&_tp=pv&newsId=%@&channelid=%@&adStyle=%@", news.newsId, news.channelId, @"1"]];
    }
    
    news.adReportState = AdReportStateClick;
    // 第三方点击曝光
    [[self click_imp] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if (info.source && [info.source isEqualToString:@"0"]) {
                if ([obj rangeOfString:@"MIAOZHEN_SDK_IMP"].location != NSNotFound ) {
                    [[SCADTrackingManager sharedInstance] trackWithType:SCADTrackingTypeMiaoZhen urlString:obj];
                } else if ([obj rangeOfString:@"ADMASTER_SDK_IMP"].location != NSNotFound) {
                    [[SCADTrackingManager sharedInstance] trackWithType:SCADTrackingTypeAdMasterClick urlString:obj];
                } else {
                    [[SCADTrackingManager sharedInstance] trackWithType:SCADTrackingTypeNormal urlString:obj];
                }
            } else {
                [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeNormal];
            }
        }
    }];
}

- (void)reportAdLoad:(SNRollingNews *)news {
    //空广告木有加载统计
    if (news.adType.length > 0 && [news.adType isEqualToString:@"2"]) {
        return;
    }
    
    SNStatLoadInfo *info = [[SNStatLoadInfo alloc] init];

    [self updateInfoWithData:info data:news];
    info.objLabel = [SNNewsAd getObjLebel:news.isPush spaceId:info.itemspaceid defaultLabel:news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd empty:NO];
    
    info.isReported = [news isReportAd:AdReportStateLoad];

    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    
    if (!info.isReported) {
        [[self normal_imp] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                if (info.source && [info.source isEqualToString:@"0"]) {
                    if ([obj rangeOfString:@"MIAOZHEN_SDK_IMP"].location != NSNotFound ) {
                        [[SCADTrackingManager sharedInstance] trackWithType:SCADTrackingTypeMiaoZhen urlString:obj];
                    } else if ([obj rangeOfString:@"ADMASTER_SDK_IMP"].location != NSNotFound) {
                        [[SCADTrackingManager sharedInstance] trackWithType:SCADTrackingTypeAdMasterLoad urlString:obj];
                    } else {
                        [[SCADTrackingManager sharedInstance] trackWithType:SCADTrackingTypeNormal urlString:obj];
                    }
                } else {
                    [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeNormal];
                }
            }
        }];
    }
    
    news.adReportState = AdReportStateLoad;
}

- (void)reportAdOneDisplay:(SNRollingNews *)news {
    //曝光统计虑重
    NSString *forOnceKey = NSStringFromSelector(_cmd);
    NSString * currentChannelId = [SNUtility getCurrentChannelId];
    if (![news.channelId isEqualToString:currentChannelId]) {
        return;
    }
    
    if ([self.newsDataDic stringValueForKey:forOnceKey defaultValue:nil]) {
        return;
    }
    
    //空广告木有曝光统计
    if (news.adType.length > 0 && [news.adType isEqualToString:@"2"]) {
        return;
    }
    
    [self.newsDataDic setObject:forOnceKey forKey:forOnceKey];
    
    SNStatExposureInfo *info = [[SNStatExposureInfo alloc] init];

    [self updateInfoWithData:info data:news];
    info.objLabel = [SNNewsAd getObjLebel:news.isPush spaceId:info.itemspaceid defaultLabel:news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd empty:NO];
    
    info.isReported = [news isReportAd:AdReportStateDisplay];
    if (info.isReported) {
        info.isReported = self.isReported;
    }
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    self.isReported = YES;
    news.adReportState = AdReportStateDisplay;
}

- (void)reportEmptyLoad:(SNRollingNews *)news{
    SNStatEmptyInfo *info = [[SNStatEmptyInfo alloc] init];
    
    [self updateInfoWithData:info data:news];
    info.objLabel = [SNNewsAd getObjLebel:news.isPush
                                  spaceId:info.itemspaceid
                             defaultLabel:news.isRecomNews ? SNStatInfoUseTypeEmptyRecommed : SNStatInfoUseTypeEmptyTimelineAd
                                    empty:YES];

    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    
    SNDebugLog(@"SNNewsAd+analytics reportEmptyLoad adInfo %@" , info.refreshCount);
}

+ (SNStatInfoUseType)getObjLebel:(BOOL)isPush spaceId:(NSString *)spaceId defaultLabel:(SNStatInfoUseType)defaultLabel empty:(BOOL)isEmpty {
 
    if (isPush
        &&([@"12237" isEqualToString:spaceId]
           || [@"12232" isEqualToString:spaceId]
           || [@"12434" isEqualToString:spaceId]
           || [@"12791" isEqualToString:spaceId]))
    {
        return isEmpty ? SNStatInfoUseTypeEmptyPushAd : SNStatInfoUseTypePushAd;
    }
    
    return defaultLabel;
}

- (void)updateInfoWithData:(SNStatInfo *)info data:(SNRollingNews *)news
{
    NSString *newsID = news.newsAd.adId;
    if (newsID.length > 0) {
        info.adIDArray = @[newsID];
    }
    
    info.token = news.token;
    info.objType = news.templateType;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    info.objFromId = news.newsAd.channelId;
    info.scope = news.newsAd.scope;
    info.refreshCount = news.newsAd.rc;
//    info.refreshCount = [SNAnalytics sharedInstance].rc ? : @"1";
    info.loadMoreCount = news.newsAd.lc;
    info.refreshRecomCount = news.newsAd.rr;
    info.position = news.newsAd.reposition;
    info.adstyle = news.newsAd.adStyle;
    info.clicktype = news.newsAd.clicktype;
    
    if (!news.isRecomNews) {//推荐流去掉reposition  abposition
        info.reposition = news.newsAd.reposition;
        info.abposition = news.newsAd.abposition;
    }
    
    info.appChannelId = news.newsAd.appChannel;
    info.newsChannelId = [news.newsAd.newsDataDic stringValueForKey:adTrackParamNewsChn defaultValue:@"0"];
    if ([info.newsChannelId isEqualToString:@"0"] && news.channelId) {
        info.newsChannelId = news.channelId;
    }
    info.itemspaceid = news.newsAd.itemSpaceId;
    info.monitorkey = news.newsAd.monitorkey;
    info.impId = news.newsAd.impId;
    info.gbcode = news.newsAd.gbcode;
    info.adpType = news.newsAd.adpType;
    info.viewMonitor = news.newsAd.viewMonitor;
    info.clickMonitor = news.newsAd.clickMonitor;
    info.source = news.newsAd.source;
    
    //视频广告位置
    if ([news.templateType isEqualToString:@"22"] || [news.templateType isEqualToString:@"77"]) {
        SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
        info.videoAdTotalTime = [player getMoviePlayer].duration * 1000.0;
        info.videoAdPlayedTime = [player getMoviePlayer].currentPlaybackTime * 1000.0;
    }
}


@end
