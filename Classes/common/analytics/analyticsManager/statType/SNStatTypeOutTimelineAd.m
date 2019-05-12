//
//  SNStateTypeOutTimelineAd.m
//  sohunews
//
//  Created by jialei on 14-7-31.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatTypeOutTimelineAd.h"

@implementation SNStatTypeOutTimelineAd

//- (NSString *)dataServerUrl
//{
//    NSString *cDotUrl = [super dataServerUrl];
//    NSMutableString *url = [NSMutableString stringWithString:cDotUrl];
//    if (url.length > 0) {
//        [url appendFormat:@"&newschn=%@", self.info.newsChannelId ?: @""];
//        [url appendFormat:@"&appchn=%@", self.info.appChannelId ?: @""];
//    }
//    
//    return url;
//}

- (NSMutableDictionary *)dataServerParams {
    NSMutableDictionary *params = [super dataServerParams];
    
    if (params.count > 0) {
        [params setValue:(self.info.newsChannelId ?: @"") forKey:@"newschn"];
        [params setValue:(self.info.appChannelId ?: @"") forKey:@"appchn"];
    }
    return params;
}

- (void)uploadAdServerEvent
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    if (self.info.itemspaceid.length > 0) {
//        
//        dic[adTrackParamSpaceid] = self.info.itemspaceid;
//    }
//    if (self.info.monitorkey.length > 0) {
//        dic[adTrackParamMonitorkey] = self.info.monitorkey;
//    }
    if (self.info.reposition.length > 0) {
        dic[adTrackParamReposition] = self.info.reposition;
    }
    if (self.info.abposition.length > 0) {
        dic[adTrackParamAbposition] = self.info.abposition;
    }
    NSString *position = [self.info.requestFilter stringValueForKey:@"position" defaultValue:nil];
    if (position.length > 0) {
        NSInteger positionIntegerValue = [position integerValue];
        position = [NSString stringWithFormat:@"%ld",positionIntegerValue % 20];
        dic[adTrackParamPosition] = position;
    }

    NSString *lc = [self.info.requestFilter stringValueForKey:@"lc" defaultValue:nil];
    if (self.info.loadMoreCount.length > 0) {
        dic[adTrackParamLoadmoreCount] = self.info.loadMoreCount;
    }
    else if(lc.length > 0) {
        dic[adTrackParamLoadmoreCount] = lc;
    }
    
    if (self.info.refreshCount.length > 0) {
        dic[adTrackParamRefreshCount] = self.info.refreshCount;
    }
//    if (self.info.appChannelId.length > 0) {
//        dic[adTrackParamAppChn] = self.info.appChannelId;
//    }
//    if (self.info.newsChannelId.length > 0) {
//        dic[adTrackParamNewsChn] = self.info.newsChannelId;
//    }
    if (self.info.impId.length > 0) {
        dic[adTrackParamImpId] = self.info.impId;
//        dic[@"impid"] = self.info.impId;
    }
    if (self.info.gbcode.length > 0) {
        dic[adTrackParamGbcode] = self.info.gbcode;
    }
    
    if (self.info.roomId.length > 0) {
        dic[@"roomid"] = self.info.roomId;
    }

    if (self.info.newsId.length > 0) {
        dic[@"newsid"] = self.info.newsId; //应和琪boss要求，广告系统内newsid全小写。但是咱们自己的服务端和客户端全是newsId，注意下。
    }
    if (self.info.subId.length > 0) {
        dic[@"subid"] = self.info.subId;
    }
    if (self.info.blockId.length > 0) {
        dic[@"blockId"] = self.info.blockId;
    }
    if (self.info.newsCate.length > 0) {
        dic[@"newscate"] = self.info.newsCate;
    }
// 这个参数说好不传了
//    if (self.info.newsType) {
//        dic[@"newstype"] = self.info.newsId;
//    }
    
    NSString *adp_type = [self.info.requestFilter stringValueForKey:@"adp_type" defaultValue:nil];
    if (self.info.adpType.length > 0) {
        dic[adTrackParamADPType] = self.info.adpType;
    }
    else if(adp_type.length > 0) {
        dic[adTrackParamADPType] = adp_type;
    }
    
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    if (cid.length > 0) {
        dic[adTrackParamCid] = cid;
    }
    
    if (self.info.debugloc.length > 0) {
        dic[@"debugloc"] = self.info.debugloc;
    }
    if (!dic[adTrackParamAppDelayTrack]) {
        if (self.info.isReported) {
            dic[adTrackParamAppDelayTrack] = @"1";
        }else {
            dic[adTrackParamAppDelayTrack] = @"0";
        }
    }

    if (self.info.adTrackType == STADDisplayTrackTypeLoadImp) {
        SNDebugLog(@"uploadAdServerEvent load id = %@", self.info.objType);
        [[SNADManager sharedSTADManager] stadLoadImpTrackingForNews:self.info.adView andParam:dic];
    }
    else if (self.info.adTrackType == STADDisplayTrackTypeClick) {
        SNDebugLog(@"uploadAdServerEvent click id = %@", self.info.objType);
        [[SNADManager sharedSTADManager] stadClickTrackingForNews:self.info.adView andParam:dic];
    }
    else if (self.info.adTrackType == STADDisplayTrackTypeImp) {
        SNDebugLog(@"uploadAdServerEvent display id = %@", self.info.objType);
        [[SNADManager sharedSTADManager] stadImpTrackingForNews:self.info.adView andParam:dic];
    }
    else if (self.info.adTrackType == STADDisplayTrackTypeNullAD) {
        SNDebugLog(@"uploadAdServerEvent display id = %@", self.info.objType);
        [[SNADManager sharedSTADManager] stadNullADTrackingForNews:self.info.adView andParam:dic];
    }
}

@end
