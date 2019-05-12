//
//  SNAdManager.h
//  sohunews
//
//  Created by Xiang Wei Jia on 2/25/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNReportAdData.h"
#import "SNAdvertiseObjects.h"

@class SNAdBaseController;
@protocol SNAdDelegate;

@interface SNAdManager : NSObject

/* 
  只请求SDK广告，不会生成上报数据，也不会自动上报空广告和加载
    spaceId:广告位id
    param:请求的广告参数  nil或者count == 0也会请求失败
*/
+(SNAdBaseController *) requestAdWithSpaceId:(NSString *)spaceId
                                       param:(NSDictionary *)param
                                  adDelegate:(id<SNAdDelegate>)delegate;

/* 
 请求SDK广告，并且自动解析上报数据，自动上报空广告和加载的一条龙服务接口

    spaceId:广告位id
    clientParam:请求者自带的广告参数，或者上报数据。如果是nil，则会全部出从数据中解析出来。
    adInfo: 服务器返回的adInfos数组的元素
    root: 服务器返回的数据根节点
    channel: 频道id
    type: 不同的模块和广告对应的type是不一样的，具体的请查看wiki
            常用的部分模块type填法:
            一般情况下传入adReportSDK,
            但是只要是广告来自push，不管是哪个模块，哪个流，统一填 adReportPush
    tab: 广告来自哪个tab(新闻tab，视频tab，我的tab).
*/
+(SNAdBaseController *) requestAdWithSpaceId:(NSString *)spaceId
                                 clientParam:(NSDictionary *)param
                                  adDelegate:(id<SNAdDelegate>)delegate
                                      adInfo:(NSDictionary *)adInfo
                                        root:(NSDictionary *)root
                                     channel:(NSString *)channel
                                      adType:(ReportDataAdType)type tab:(ReportDataAdTab)tab;

+ (void)setSDKEnable:(NSString *)enable;
+ (BOOL)isSDKEnable;

+ (NSMutableDictionary *)paramFromSNAdInfo:(SNAdInfo *)adInfo newsId:(NSString *)newsId;

///拼接一些5.6.0之前缺失的广告参数 【流内 server 广告】
+ (NSString *)urlByAppendingAdParameter:(NSString *)url;

//移动服务提供商
+ (NSString *)getCarrierName;

// 广告参数
+ (NSDictionary *)addAdParameters;

@end
