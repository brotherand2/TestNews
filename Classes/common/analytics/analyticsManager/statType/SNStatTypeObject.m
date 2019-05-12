//
//  SNStateType.m
//  sohunews
//
//  Created by jialei on 14-7-31.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatTypeObject.h"
#import "SNStatTypeOutTimelineAd.h"
#import "SNStatTypeOutTimelinePopularize.h"
#import "SNStatTypeTimelineAd.h"
#import "SNStatTypeTimelinePopularize.h"
#import "SNStatisticsConst.h"

@implementation SNStatTypeObject

+ (Class)classForStatisticsType:(SNStatInfoUseType)type
{
    switch (type) {
        case SNStatInfoUseTypeTimelineAd:
        case SNStatInfoUseTypeEmptyTimelineAd:
        case SNStatInfoUseTypeRecommed:
        case SNStatInfoUseTypeEmptyRecommed:
            return [SNStatTypeTimelineAd class];
        case SNStatInfoUseTypeOutTimelineAd:
        case SNStatInfoUseTypeEmptyOutTimelineAd:
        case SNStatInfoUseTypePushAd:
        case SNStatInfoUseTypeEmptyPushAd:
            return [SNStatTypeOutTimelineAd class];
        case SNStatInfoUseTypeTimelinePopularize:
        case SNStatInfoUseTypeEmptyTimelinePopularize:
            return [SNStatTypeTimelinePopularize class];
        case SNStatInfoUseTypeOutTimelinePopularize:
        case SNStatInfoUseTypeEmptyOutTimelinePopularize:
            return [SNStatTypeOutTimelinePopularize class];
        default:
            return [SNStatTypeObject class];
    }
    return nil;
}

- (id)initWithStateInfo:(SNStatInfo *)statInfo
{
    self = [super init];
    if (self) {
        self.info = statInfo;
    }
    
    return self;
}

//- (NSString *)dataServerUrl
//{
//    NSString *adIDs = [_info.adIDArray componentsJoinedByString:@","];
//    NSString *cDotGifUrl = [SNAPI cDotGifUrlPrefixWithParameters:@""];
//    NSMutableString *url = [NSMutableString stringWithString:cDotGifUrl];
//    if (url.length > 0) {
//        [url appendFormat:@"&ad_gbcode=%@", _info.gbcode ?: @""];
//        [url appendFormat:@"&statType=%@", _info.statType ?: @""];
//        [url appendFormat:@"&objType=ad_%@", _info.objType ?: @""];
//        [url appendFormat:@"&objLabel=%ld", _info.objLabel];
//        [url appendFormat:@"&objId=%@", adIDs ?: @""];
//        [url appendFormat:@"&token=%@", _info.token ?: @""];
//        [url appendFormat:@"&objFrom=%@", _info.objFrom ?: @""];
//        [url appendFormat:@"&objFromId=%@", _info.objFromId ?: @""];
//        NSString *pTime = @"";
//        if (_info.videoAdPlayedTime > 0) {
//            pTime = [NSString stringWithFormat:@"%g", _info.videoAdPlayedTime];
//        }
//        [url appendFormat:@"&ptime=%@", pTime];
//        NSString *tTime = @"";
//        if (_info.videoAdTotalTime) {
//            tTime = [NSString stringWithFormat:@"%g", _info.videoAdTotalTime];
//        }
//        [url appendFormat:@"&ttime=%@", tTime];
//
//        if (self.info.newsType){
//            [url appendFormat:@"&newsType=%@", self.info.newsType];
//        }
//        
//        if (self.info.newsId) {
//            [url appendFormat:@"&newsId=%@", self.info.newsId];
//        }
//    }
//    
//    return url;
//}

- (NSMutableDictionary *)dataServerParams {
    NSString *adIDs = [_info.adIDArray componentsJoinedByString:@","];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:(_info.gbcode ?: @"") forKey:@"ad_gbcode"];
    [params setValue:(_info.statType ?: @"") forKey:@"statType"];
    [params setValue:[NSString stringWithFormat:@"ad_%@",(_info.objType ?: @"")] forKey:@"objType"];
    [params setValue:[NSString stringWithFormat:@"%ld",_info.objLabel] forKey:@"objLabel"];
    [params setValue:(adIDs ?: @"") forKey:@"objId"];
    [params setValue:(_info.token ?: @"") forKey:@"token"];
    [params setValue:(_info.objFrom ?: @"") forKey:@"objFrom"];
    [params setValue:(_info.objFromId ?: @"") forKey:@"objFromId"];
    
    NSString *pTime = @"";
    if (_info.videoAdPlayedTime > 0) {
        pTime = [NSString stringWithFormat:@"%g", _info.videoAdPlayedTime];
    }
    [params setValue:pTime forKey:@"ptime"];
    
    NSString *tTime = @"";
    if (_info.videoAdTotalTime) {
        tTime = [NSString stringWithFormat:@"%g", _info.videoAdTotalTime];
    }
    [params setValue:tTime forKey:@"ttime"];
    
    if (self.info.newsType){
        [params setValue:self.info.newsType forKey:@"newsType"];
    }
    
    if (self.info.newsId) {
        [params setValue:self.info.newsId forKey:@"newsId"];
    }
    return params;

}

- (void)uploadAdServerEvent
{
    
}

@end
