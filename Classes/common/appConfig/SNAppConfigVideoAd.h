//
//  SNAppConfigVideoAd.h
//  sohunews
//
//  Created by handy wang on 5/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigVideoAd : NSObject

@property(nonatomic, assign) BOOL isAppVideoAdvOn;//视频广告总开关
@property(nonatomic, strong) NSArray *newsChannelIDsOfVideoAdvOn;//开启视频广告的新闻频道的集合
@property(nonatomic, strong) NSArray *videoChannelIDsOfVideoAdvOn;//开启视频广告的视频Tab频道的集合
@property(nonatomic, strong) NSArray *subIDsOfVideoOn;//开启视频广告的刊物集合

- (void)updateWithDic:(NSDictionary *)configDic;

@end
