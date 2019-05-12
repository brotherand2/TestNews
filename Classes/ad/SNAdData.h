//
//  SNAdData.h
//  sohunews
//
//  Created by Xiang Wei Jia on 3/18/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STADManagerForNews.h"

@interface SNAdData : NSObject

@property (nonatomic, copy) NSString *adId;

@property (nonatomic, readonly) NSString *imageUrl;  // 下载图片的URL
@property (nonatomic, readonly) NSString *clickUrl;
@property (nonatomic, readonly) NSString *shareText;
@property (nonatomic, readonly) NSString *noPicTitle;
@property (nonatomic, readonly) NSString *textLink;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *imagePath;  // 图片在磁盘上的缓存路径

// 原来一个广告位只有1个点击链接，现在有的广告位有2个点击链接，
// 使用的时候，所有只有1个链接的广告（大部分情况）使用adClickUrl
// 某些2个点击的广告位，在第二个点击用此接口adClickUrlAddtional
@property (nonatomic, readonly) NSString *clickUrlAddtional;

- (void)parseSDKData:(NSDictionary *)sdkData;

@end

