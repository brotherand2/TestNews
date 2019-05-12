//
//  SNSpecialActivity.h
//  sohunews
//
//  Created by yangln on 2017/9/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSpecialADTools.h"

@class SNSpecialActivityAlert;
@interface SNSpecialActivity : NSObject

@property (nonatomic, assign) BOOL isDownLoading;
@property (nonatomic, strong) NSDictionary *activityInfo;

+ (SNSpecialActivity *)shareInstance;
- (void)requestActivityInfo;

/**
 准备展示浮层广告

 @param ADType 广告类型
 @param mkey 广告位id
 @return 是否成功展示（如果广告当前不可用则展示失败）
 */
- (BOOL)prepareShowFloatingADWithType:(SNFloatingADType)ADType majorkey:(NSString *)mkey;

/**
 手动dismiss之前的频道流浮层广告
 */
- (void)dismissLastChannelSpecialAlert;

/**
 设置当前的alert ，用于dismiss

 @param alert 当前alert
 */
- (void)setCurrentShowingChannelAlert:(SNSpecialActivityAlert *)alert;

/**
 当前频道是否正在展示频道流浮层广告

 @return YES = 正在展示
 */
- (BOOL)isShowingChannelSpecialAd;

/**
 请求浮层广告配置信息，并刷新本地存储的配置信息
 */
- (void)fetchSpecialADConfig;

/**
 存储广告状态到本地
 */
- (void)saveSpecialAdState;

/**
 清理广告缓存
 */
- (void)clearSNSpecialADCache;

@end
