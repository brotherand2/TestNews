//
//  SNAdTemplateFactory.m
//  sohunews
//
//  Created by Xiang Wei Jia on 2/26/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAdTemplateFactory.h"

#import "SNSpaceId.h"

#import "SNAd12238Controller.h"
#import "SNAd12233Controller.h"

@implementation SNAdTemplateFactory

// 通过广告ID加载流内广告模板
+ (SNAdBaseController *)loadStreamTemplateWithSpaceId:(NSString *)spaceId delegate:(id<SNAdDelegate>)delegate
{
    return nil;
}

// 通过广告ID加载SDK中来的广告模板
+ (SNAdBaseController *)loadSDKTemplateWithSpaceId:(NSString *)spaceId delegate:(id<SNAdDelegate>)delegate filter:(NSDictionary *)filter
{
    switch (spaceId.integerValue)
    {
        case SpaceId12233Integer:
            return [[SNAd12233Controller alloc] initWithSpaceId:spaceId delegate:delegate filter:filter];
        case SpaceId12238Integer:
        case SpaceId13371Integer:
        case SpaceId12716Integer:
            // 12238和13371用1个模板
            return [[SNAd12238Controller alloc] initWithSpaceId:spaceId delegate:delegate filter:filter];
        default:
            return nil;
    }
}

// 通过广告ID加载视频广告模板
+ (SNAdBaseController *)loadVideoTemplateWithSpaceId:(NSString *)spaceId delegate:(id<SNAdDelegate>)delegate
{
    return nil;
}


@end
