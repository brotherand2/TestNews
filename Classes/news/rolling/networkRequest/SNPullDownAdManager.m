//
//  SNPullDownAdManager.m
//  sohunews
//
//  Created by H on 15/4/2.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//


#define kPlatformId                     (@"5")
#define kPullAdDownLoadSuccess          (1)
#define kPullAdIsEmpty                  (2)

#import "SNPullDownAdManager.h"
#import "SNURLDataResponse.h"
#import "SNURLJSONResponse.h"
#import "SNUserLocationManager.h"
#import "SNUserManager.h"
#import "SNPullAdData.h"
#import "SNAdManager.h"
#import "SNPullAdRequest.h"

@implementation SNPullDownAdManager


- (void)startRequsetPullAdWithInfo:(NSString *)channelId {
    
    [[[SNPullAdRequest alloc] initWithDictionary:@{@"channelId":channelId}] send:^(SNBaseRequest *request, id rootData) {
        NSString * imageUrl = nil;
        NSMutableDictionary * infoDic = [NSMutableDictionary dictionary];

        if ([rootData isKindOfClass:[NSDictionary class]]) {
            if ([rootData[@"s"] integerValue] == kPullAdDownLoadSuccess) {
                
                SNPullAdData * pullAdData = [[SNPullAdData alloc] init];
                
                if ([rootData[@"adType"] integerValue] == kPullAdIsEmpty) {
                    NSDictionary *adData = rootData[@"data"];
                    
                    pullAdData.adId = adData[@"adid"] ? : @"";
                    pullAdData.spaceId = adData[@"itemspaceid"];
                    pullAdData.clickmonitor = adData[@"clickmonitor"] ? : @"";
                    pullAdData.impressionid = adData[@"impressionid"] ? : @"";
                    pullAdData.monitorkey = adData[@"monitorkey"] ? : @"";
                    pullAdData.offline = adData[@"offline"] ? : @"";
                    pullAdData.onform = adData[@"onform"] ? : @"";
                    pullAdData.online = adData[@"online"] ? : @"";
                    pullAdData.position = adData[@"position"] ? : @"";
                    pullAdData.size = adData[@"size"] ? : @"";
                    pullAdData.tag = adData[@"tag"] ?:@"";
                    pullAdData.appchn = rootData[@"appchn"]?:@"";
                    pullAdData.adp_type = rootData[@"adp_type"] ?:@"";
                    pullAdData.gbcode = rootData[@"gbcode"] ?:@"";
                    pullAdData.jsonData = adData;
                    pullAdData.viewmonitor = adData[@"viewmonitor"] ? : @"";
                    pullAdData.weight = adData[@"weight"] ? : @"";
                    pullAdData.resource = adData[@"resource"];
                    pullAdData.newsChannel = [rootData[@"realChannelId"] stringValue] ? : @"";
                    [infoDic setObject:pullAdData forKey:@"adData"];
                    [infoDic setObject:rootData[@"adType"] forKey:@"adType"];
                }else {
                    
                    NSDictionary * adData = rootData[@"data"];
                    
                    pullAdData.adId = adData[@"adid"] ? : @"";
                    pullAdData.spaceId = adData[@"itemspaceid"];
                    pullAdData.clickmonitor = adData[@"clickmonitor"] ? : @"";
                    pullAdData.impressionid = adData[@"impressionid"] ? : @"";
                    pullAdData.monitorkey = adData[@"monitorkey"] ? : @"";
                    pullAdData.offline = adData[@"offline"] ? : @"";
                    pullAdData.onform = adData[@"onform"] ? : @"";
                    pullAdData.online = adData[@"online"] ? : @"";
                    pullAdData.position = adData[@"position"] ? : @"";
                    pullAdData.size = adData[@"size"] ? : @"";
                    pullAdData.tag = adData[@"tag"] ?:@"";
                    pullAdData.appchn = rootData[@"appchn"]?:@"";
                    pullAdData.adp_type = rootData[@"adp_type"] ?:@"";
                    pullAdData.gbcode = rootData[@"gbcode"] ?:@"";
                    
                    pullAdData.viewmonitor = adData[@"viewmonitor"] ? : @"";
                    pullAdData.weight = adData[@"weight"] ? : @"";
                    pullAdData.resource = adData[@"resource"];
                    pullAdData.newsChannel = [rootData[@"realChannelId"] stringValue] ? : @"";
                    
                    pullAdData.jsonData = adData;
                    imageUrl = pullAdData.resource[@"file"];
                    [infoDic setObject:imageUrl forKey:@"imageUrl"];
                    [infoDic setObject:pullAdData forKey:@"adData"];
                    [infoDic setObject:rootData[@"adType"] forKey:@"adType"];
                }
            } else {
                SNDebugLog(@" pull down image downLoad failed");
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestFnishedWithAdInfo:)]) {
            [self.delegate requestFnishedWithAdInfo:infoDic];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestFnishedWithAdInfo:)]) {
            [self.delegate requestFnishedWithAdInfo:nil];
        }
    }];
}


- (void)dealloc {
    self.delegate = nil;
}


@end
