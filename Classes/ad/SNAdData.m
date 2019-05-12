//
//  SNAdData.m
//  sohunews
//
//  Created by Xiang Wei Jia on 3/18/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAdData.h"
#import "SNStatInfo.h"
#import "SNStatClickInfo.h"
#import "SNNewsAd+analytics.h"
#import "SNVideoAdContext.h"
#import "SNStatEmptyInfo.h"
#import "SNStatLoadInfo.h"
#import "SNStatExposureInfo.h"
#import "SNStatUninterestedInfo.h"

@interface SNAdData()

@end

@implementation SNAdData

- (void)parseSDKData:(NSDictionary *)sdkData
{
    _imageUrl = sdkData[@"image_url"];
    _adId = sdkData[@"adid"];
    _clickUrl = sdkData[@"click_url"];
    _shareText = sdkData[@"share_txt"];
    _noPicTitle = sdkData[@"nopic_txt"];
    _textLink = sdkData[@"ad_txt_link"];
    _title = sdkData[@"ad_txt"];
    _clickUrlAddtional = nil; // 协议数据没看到，看到了再来处理
}

- (NSString *)imagePath
{
    if (nil == _imageUrl)
    {
        return nil;
    }
    
    return [[SDImageCache sharedImageCache] defaultCachePathForKey:_imageUrl];
}

@end
