//
//  SNStatisticsManager.h
//  sohunews
//
//  Created by jialei on 14-7-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//  向新闻客户端数据组上报统计参数

#import <Foundation/Foundation.h>
#import "SNStatInfo.h"
#import "SNStatExposureInfo.h"
#import "SNStatClickInfo.h"
#import "SNStatLoadInfo.h"
#import "SNStatEmptyInfo.h"
#import "SNStatUninterestedInfo.h"
#import "SNVideoAdContext.h"

@interface SNStatisticsManager : NSObject

+ (SNStatisticsManager *)shareInstance;

/*
 *实时上传广告推广位统计数据
 *@prarm  statInfo 统计数据对象实例
 */
- (void)uploadStaticsEvent:(SNStatInfo *)statInfo;

/**
 记录APP启动后到频道流内展示各个阶段的时间戳，并上报

 @param stage 阶段代号
 t0 应用启动的的时间
 t1 开始请求广告的时间
 t2 loading页广告显示出来的时间
 t3 loading页结束的时间
 t4 新手引导页展示的时间
 t5 新手引导页退出的时间
 t6 进入频道流页的时间
type = 1 为第一次启动（第一次启动的定义为：单个版本第一次启动时；包含覆盖安装和全新安装的情况）
 */
- (void)recordAppStartStage:(NSString *)stage;

@end
