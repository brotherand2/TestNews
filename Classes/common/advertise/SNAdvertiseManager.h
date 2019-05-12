//
//  SNAdvertiseManager.h
//  sohunews
//
//  Created by jojo on 13-12-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNAdvertiseObjects.h"
#import "SNAdDataCarrier.h"
#import "SNAdvertiseConfigs.h"
#import "SNChannelsAdData.h"

typedef void(^SNOpenAssetLoadFinishedBlock)(BOOL success,UIViewController * controller, NSTimeInterval oadInterval);
typedef void(^SNOpenAssetPlayFinishedBlock)(BOOL success,UIViewController * controller);
typedef void(^SNOpenAssetClickBlock)(NSString * loadingString);

@interface SNAdvertiseManager : NSObject

@property (nonatomic, copy) NSString * currentLocalChannelId;

@property (nonatomic, copy) SNOpenAssetLoadFinishedBlock openAdLoadFinishedBlock;
@property (nonatomic, copy) SNOpenAssetPlayFinishedBlock openAdPlayFinishedBlock;
@property (nonatomic, copy) SNOpenAssetClickBlock openAdClickBlock;

+ (SNAdvertiseManager *)sharedManager;

- (BOOL)isSDKAdEnable;

/** 获取广告数据接口
 * @spaceId : 具体广告位的id，通过接口能拿到
 * @param   : 接口返回的广告定向数据 (里面包含spaceId)
 */
// 获取loading广告数据
//- (SNAdDataCarrier *)generateLoadingAdDataCarrierWithSpaceId:(NSString *)spaceId adInfoParam:(NSDictionary *)param;
// 获取普通非loading页广告数据
- (SNAdDataCarrier *)generateNormalAdDataCarrierWithSpaceId:(NSString *)spaceId adInfoParam:(NSDictionary *)param;

// 直接读取本地数据库缓存的广告数据
- (NSDictionary *)adInfoDicForAdSpaceId:(NSString *)spaceId;

- (void)cleanCacheAdDataCarrier:(SNAdDataCarrier *)carrier;

/**
 *  passport id 上报接口
 *
 *  @param passportId passportId必须有值
 */
- (void)sendPassportIdForLoginSuccessed:(NSString *)passportId;

/**
 *  获取当前网络类型
 *
 *  @return wifi，2g，3g等
 */
- (NSString *)getCurrentNetworkType;

/**
 *  开机广告预加载方法
 *
 *  @param param 开机广告的ADParam
 */
- (void)snadStartPerdonwloadWithParam;

/**
 *  loading页广告接口
 *  @param param  请求参数
 *  @param isFirstLoad   是否第一次加载启动图，不是则不显示倒计时
 */
- (void)getNewsOpenisFirstLoad:(BOOL)isFirstLoad loadDidFinished:(SNOpenAssetLoadFinishedBlock)loadFinished playDidFinished:(SNOpenAssetPlayFinishedBlock)playFinished didClicked:(SNOpenAssetClickBlock)click;

//分享数据获取
- (NSDictionary *)getShareInfo;

//右滑切换广告
- (void)switchOpenAD;


#pragma mark - 非标广告/渠道广告

/**
 获取渠道广告物料
 */
- (void)updateChannelADs:(NSDictionary *)jsonData;

/**
 分享浮层上的广告
 */
@property (nonatomic, strong) SNChannelsAdData * sharePageAD;

/**
 搜索页面的广告
 */
@property (nonatomic, strong) SNChannelsAdData * searchPageAD;

@end
