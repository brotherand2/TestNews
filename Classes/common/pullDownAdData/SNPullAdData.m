//
//  SNPullAdData.m
//  sohunews
//
//  Created by H on 15/4/2.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNPullAdData.h"

#import "SNStatEmptyInfo.h"
#import "SNStatLoadInfo.h"
#import "SNStatClickInfo.h"
#import "SNStatExposureInfo.h"
#import "SNStatUninterestedInfo.h"
#import "SNVideoAdContext.h"
#import "SNUserManager.h"

@implementation SNPullAdData

- (void)dealloc
{
     //(_weight);
     //(_online);
     //(_clickmonitor);
     //(_viewmonitor);
     //(_tag);
     //(_size);
     //(_position);
     //(_onform);
     //(_offline);
     //(_monitorkey);
     //(_impressionid);
     //(_adp_type);
     //(_appchn);
     //(_jsonData); // v5.2.0
}

-(SNStatInfo *)createAdReportInfo:(STADDisplayTrackType)reportType
{
    SNStatInfo *info = nil;
    
    switch (reportType)
    {
        case STADDisplayTrackTypeNullAD:
        {
            info = [[SNStatEmptyInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeEmptyTimelineAd;
            break;
        }
        case STADDisplayTrackTypeLoadImp:
        {
            info = [[SNStatLoadInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeTimelineAd;
            
            break;
        }
        case STADDisplayTrackTypeClick:
        {
            info = [[SNStatClickInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeTimelineAd;
            
            break;
        }
        case STADDisplayTrackTypeImp:
        {
            info = [[SNStatExposureInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeTimelineAd;
            
            break;
        }
        case STADDisplayTrackTypeNotInterest:
        {
            info = [[SNStatUninterestedInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeTimelineAd;
            
            break;
        }
        default:
        {
            return nil;
        }
    }
    
    [self updateInfoWithData:info];
    
    return info;
}

- (SNStatInfo *)createUploadStatInfo:(STADDisplayTrackType)reportType
{
    SNStatInfo *info = nil;
    
    switch (reportType)
    {
        case STADDisplayTrackTypeNullAD:
        {
            info = [[SNStatEmptyInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeEmptyTimelineAd;
            
            break;
        }
        case STADDisplayTrackTypeLoadImp:
        {
            info = [[SNStatLoadInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeTimelineAd;
            
            break;
        }
        case STADDisplayTrackTypeClick:
        {
            info = [[SNStatClickInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeTimelineAd;
            
            break;
        }
        case STADDisplayTrackTypeImp:
        {
            info = [[SNStatExposureInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeTimelineAd;
            
            break;
        }
        case STADDisplayTrackTypeNotInterest:
        {
            info = [[SNStatUninterestedInfo alloc] init];
            info.objLabel = SNStatInfoUseTypeTimelineAd;
            
            break;
        }
        default:
        {
            return nil;
            
        }
    }
    
    [self updateInfoWithData:info];
    info.objType = [SNPreference sharedInstance].testModeEnabled ? @"12715" : @"13370";
    info.objFromId = self.newsChannel;
    info.clickMonitor = self.clickmonitor;
    info.impId = self.impressionid;
    info.monitorkey = self.monitorkey;
    info.position = self.position;
    info.adpType = self.adp_type;
    info.gbcode = self.gbcode;
    info.token = [SNUserManager getToken];
    
    /*@property (nonatomic, copy) NSString * clickmonitor;
     @property (nonatomic, copy) NSString * impressionid;
     @property (nonatomic, copy) NSString * monitorkey;
     @property (nonatomic, copy) NSString * offline;
     @property (nonatomic, copy) NSString * onform;
     @property (nonatomic, copy) NSString * online;
     @property (nonatomic, copy) NSString * position;
     @property (nonatomic, copy) NSString * size;
     @property (nonatomic, copy) NSString * tag;
     @property (nonatomic, copy) NSString * viewmonitor;
     @property (nonatomic, copy) NSString * weight;
     @property (nonatomic, copy) NSString * newsChannel;
     @property (nonatomic, copy) NSString * gbcode;
     @property (nonatomic, retain) NSDictionary * resource;
     @property (nonatomic, copy) NSString * spaceId;
     @property (nonatomic, copy) NSString * appchn;
     @property (nonatomic, copy) NSString * adp_type;
*/
    return info;
}

- (void)updateInfoWithData:(SNStatInfo *)info
{
    if (self.adId.length > 0)
    {
        info.adIDArray = @[self.adId];
    }
    
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    info.newsChannelId = self.newsChannel;
    info.gbcode = _gbcode;
    info.debugloc = _gbcode;
    info.clickMonitor = self.clickmonitor;
    info.viewMonitor = self.viewmonitor;
    info.impId = self.impressionid;
    info.monitorkey = self.monitorkey;
    info.position = self.position;
    info.adpType = self.adp_type;
    info.gbcode = self.gbcode;
    info.token = [SNUserManager getToken];
    info.appChannelId = self.appchn;
    info.itemspaceid = [SNPreference sharedInstance].testModeEnabled || [SNPreference sharedInstance].simulateOnLineEnabled ? @"12715" : @"13370";
    info.jsonData = self.jsonData;
    info.refreshCount = [[SNAnalytics sharedInstance] rc]?:@"0";
//    info.loadMoreCount = [[SNAnalytics sharedInstance] lc]?:@"1";
    
    info.refreshCount = [[[SNAnalytics sharedInstance] channelRcs] objectForKey:self.newsChannel] ? : @"0";

}

@end
