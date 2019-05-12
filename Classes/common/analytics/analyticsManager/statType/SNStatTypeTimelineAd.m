//
//  SNStateTypeTimelineAd.m
//  sohunews
//
//  Created by jialei on 14-7-31.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatTypeTimelineAd.h"
#import "SNUserLocationManager.h"
#import <SCMobileAds/SCMobileAds.h>

@implementation SNStatTypeTimelineAd

- (NSMutableDictionary *)dataServerParams {
    NSMutableDictionary *params = [super dataServerParams];
    
    if (params.count > 0) {
        [params setValue:(self.info.scope ?: @"") forKey:@"scope"];
        [params setValue:(self.info.position ?: @"") forKey:@"position"];
        [params setValue:(self.info.reposition ?: @"") forKey:@"reposition"];
        [params setValue:(self.info.abposition ?: @"") forKey:@"abposition"];
        [params setValue:(self.info.refreshCount ?: @"") forKey:@"rc"];
        [params setValue:(self.info.loadMoreCount ?: @"") forKey:@"lc"];
        [params setValue:(self.info.newsChannelId ?: @"") forKey:@"newschn"];
        [params setValue:(self.info.appChannelId ?: @"") forKey:@"appchn"];
        [params setValue:[NSString stringWithFormat:@"%zd",(self.info.isReported ? 1 : 0)] forKey:@"appdelaytrack"];

    }
    return params;
}

- (void)uploadAdServerEvent {
    @synchronized (self) {
        //流内统一使用通用上报接口
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (self.info.itemspaceid.length > 0) {
            dic[adTrackParamSpaceid] = self.info.itemspaceid;
        }
        if (self.info.monitorkey.length > 0) {
            dic[adTrackParamMonitorkey] = self.info.monitorkey;
        }
        
        // 这两个字段必须上报，服务器没传就上报空，不能不报
        dic[adTrackParamViewMonitorkey] = self.info.viewMonitor.length > 0 ? self.info.viewMonitor : @"";
        dic[adTrackParamClickMonitorkey] = self.info.clickMonitor.length > 0 ? self.info.clickMonitor : @"";
        
        if (self.info.position.length > 0) {
            dic[adTrackParamPosition] = self.info.position;
        }
        if (self.info.reposition.length > 0) {
            dic[adTrackParamReposition] = self.info.reposition;
        }
        if (self.info.abposition.length > 0) {
            dic[adTrackParamAbposition] = self.info.abposition;
        }
        if (self.info.appChannelId.length > 0) {
            dic[adTrackParamAppChn] = self.info.appChannelId;
        } else {
            NSString *marketID = [NSString stringWithFormat:@"%d", [SNUtility marketID]];
            dic[adTrackParamAppChn] = marketID ? : @"";
        }
        if (self.info.newsChannelId.length > 0) {
            dic[adTrackParamNewsChn] = self.info.newsChannelId;
        }
        if (self.info.impId.length > 0) {
            dic[@"impid"] = self.info.impId;
        }
        if (self.info.gbcode.length > 0) {
            dic[adTrackParamGbcode] = self.info.gbcode;
        } else if ([dic[adTrackParamSpaceid] isEqualToString:@"13015"] || [dic[adTrackParamSpaceid] isEqualToString:@"12452"]) {
            dic[adTrackParamGbcode] = [SNUserLocationManager sharedInstance].currentChannelGBCode;
        }
        if (self.info.roomId.length > 0) {
            dic[@"roomid"] = self.info.roomId;
        }
        
        if (self.info.newsId) {
            dic[@"newsid"] = self.info.newsId;
        }
        
        if (self.info.newsType) {
            dic[@"newsType"] = self.info.newsType;
        }
        
        if (self.info.debugloc.length > 0) {
            dic[@"debugloc"] = self.info.debugloc;
        }
        if (self.info.blockId.length > 0) {
            dic[@"blockId"] = self.info.blockId;
        }
        dic[@"appdelaytrack"] = @"0";
        
        dic[adTrackParamADPType] = self.info.adpType ?: @"";
        
        if (self.info.videoAdTotalTime > 0.0){
            dic[adTrackParamTTime] = [NSString stringWithFormat:@"%lf",self.info.videoAdTotalTime];
        }
        
        if (self.info.videoAdPlayedTime > 0.0){
            dic[adTrackParamPTime] = [NSString stringWithFormat:@"%lf",self.info.videoAdPlayedTime];
        }
        
        if (self.info.vp.length > 0) {
            dic[adTrackParamVP] = self.info.vp;
        }
        
        if (self.info.adstyle.length > 0) {
            dic[adTrackParamAdstyle] = self.info.adstyle;
        }
        
        if (self.info.clicktype.length > 0 && self.info.adTrackType == STADDisplayTrackTypeClick) {
            dic[adTrackParamClicktype] = self.info.clicktype;
        }
        
        //推荐流上报rr，编辑流上报lc和rc
        if ([dic[adTrackParamSpaceid] isEqualToString:@"13016"] || [dic[adTrackParamSpaceid] isEqualToString:@"12451"]) {
            if (self.info.refreshRecomCount.integerValue > 0) {
                dic[adTrackParamRefreshRecomCount] = self.info.refreshRecomCount;
            }
        } else {
            if (self.info.loadMoreCount.length > 0) {
                dic[adTrackParamLoadmoreCount] = self.info.loadMoreCount;
            }
            if (self.info.refreshCount.length > 0) {
                dic[adTrackParamRefreshCount] = self.info.refreshCount;
            }
        }
        
        NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
        if (cid.length > 0) {
            dic[@"cid"] = cid;
        }
        if ([dic[adTrackParamSpaceid] isEqualToString:@"12224"] || [dic[adTrackParamSpaceid] isEqualToString:@"12717"] || [dic[adTrackParamSpaceid] isEqualToString:@"12718"] || [dic[adTrackParamSpaceid] isEqualToString:@"13372"] || [dic[adTrackParamSpaceid] isEqualToString:@"13373"]) {
            if (dic[adTrackParamPosition]) {
                [dic removeObjectForKey:adTrackParamPosition];
            }
            if (dic[adTrackParamReposition]) {
                [dic removeObjectForKey:adTrackParamReposition];
            }
            if (dic[adTrackParamAbposition]) {
                [dic removeObjectForKey:adTrackParamAbposition];
            }
            if (dic[adTrackParamRefreshCount]) {
                [dic removeObjectForKey:adTrackParamRefreshCount];
            }
            if (dic[adTrackParamLoadmoreCount]) {
                [dic removeObjectForKey:adTrackParamLoadmoreCount];
            }
        }
        
        if ([dic[adTrackParamSpaceid] isEqualToString:@"13015"] || [dic[adTrackParamSpaceid] isEqualToString:@"12452"]) {
            if (dic[adTrackParamReposition]) {
                [dic removeObjectForKey:adTrackParamReposition];
            }
            if (dic[adTrackParamAbposition]) {
                [dic removeObjectForKey:adTrackParamAbposition];
            }
        }
        
        if ([dic[adTrackParamSpaceid] isEqualToString:@"12355"] || [dic[adTrackParamSpaceid] isEqualToString:@"12451"] || [dic[adTrackParamSpaceid] isEqualToString:@"12433"] || [dic[adTrackParamSpaceid] isEqualToString:@"13016"] || [dic[adTrackParamSpaceid] isEqualToString:@"12790"]|| [dic[adTrackParamSpaceid] isEqualToString:@"12715"]|| [dic[adTrackParamSpaceid] isEqualToString:@"13370"]) {
            if (dic[adTrackParamPosition]) {
                [dic removeObjectForKey:adTrackParamPosition];
            }
        }
        
        if ([dic[adTrackParamSpaceid] isEqualToString:@"12441"] || [dic[adTrackParamSpaceid] isEqualToString:@"12837"]) {
            if (dic[adTrackParamPosition]) {
                [dic removeObjectForKey:adTrackParamPosition];
            }
            if (dic[adTrackParamReposition]) {
                [dic removeObjectForKey:adTrackParamReposition];
            }
            if (dic[adTrackParamAbposition]) {
                [dic removeObjectForKey:adTrackParamAbposition];
            }
        }
        
        if (nil != self.info.jsonData && self.info.jsonData.count > 0) {
            NSString *source = [self.info.jsonData stringValueForKey:@"source" defaultValue:@""];
            if (source && [source isEqualToString:@"0"]) {
                SCADTrackingType newAdTrackType = [self conversionType:self.info.adTrackType];
                dic[@"longitude"] = [[SNUserLocationManager sharedInstance] getLongitude];
                dic[@"latitude"] = [[SNUserLocationManager sharedInstance] getLatitude];
                [[SCADTrackingManager sharedInstance] trackWithType:newAdTrackType params:dic];
            } else {
                dic[@"jsondata"] = self.info.jsonData;
                [[SNADManager sharedSTADManager] stadServerToServerTrackWithType:self.info.adTrackType andParamDict:dic];
            }
        } else {
            if (self.info.source && [self.info.source isEqualToString:@"0"]) { //新品算广告上报
                SCADTrackingType newAdTrackType = [self conversionType:self.info.adTrackType];
                
                dic[@"longitude"] = [[SNUserLocationManager sharedInstance] getLongitude];
                dic[@"latitude"] = [[SNUserLocationManager sharedInstance] getLatitude];
                
                [[SCADTrackingManager sharedInstance] trackWithType:newAdTrackType params:dic];
            } else {
                [[SNADManager sharedSTADManager] stadDisplayTrackWithType:self.info.adTrackType andParamDict:dic];
            }
        }
    }
}

- (SCADTrackingType)conversionType:(STADDisplayTrackType)type {
    SCADTrackingType newAdTrackType = SCADTrackingTypeNormal;
    if (type == STADDisplayTrackTypeNullAD) {
        newAdTrackType = SCADTrackingTypeNullAd;
    } else if (type == STADDisplayTrackTypeLoadImp) {
        newAdTrackType = SCADTrackingTypeLoad;
    } else if (type == STADDisplayTrackTypeImp) {
        newAdTrackType = SCADTrackingTypeImpression;
    } else if (type == STADDisplayTrackTypeClick || type == STADDisplayTrackTypeTelImp) {
        newAdTrackType = SCADTrackingTypeClick;
    } else if (type == STADDisplayTrackTypePlaying) {
        newAdTrackType = SCADTrackingTypeVideo;
    }
    return newAdTrackType;
}

@end
