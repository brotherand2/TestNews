//
//  SNNewsAd+analytics.h
//  sohunews
//
//  Created by jojo on 14-5-19.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

/**
 * 主要用于流内广告的统计
 *
 */

#import "SNRollingNews.h"
#import "SNStatisticsConst.h"

@interface SNNewsAd (analytics)

- (NSString *)itemSpaceId;
- (NSString *)monitorkey;
- (NSString *)gbcode;

// 不感兴趣
- (void)reportAdNotInterest:(SNRollingNews *)news;

//点击打电话曝光
- (void)reportAdClickPhone:(SNRollingNews *)news;

// 点击曝光
- (void)reportAdClick:(SNRollingNews *)news;

// 加载曝光
- (void)reportAdLoad:(SNRollingNews *)news;

// 展示曝光（imp）
- (void)reportAdOneDisplay:(SNRollingNews *)news;

// 空广告位曝光
- (void)reportEmptyLoad:(SNRollingNews *)news;

// 流内视频模板播放曝光
- (void)reportAdVideoPlay:(SNRollingNews *)news;

// 流内视频模板完整播放完成曝光
- (void)reportAdVideoFinishedPlay:(SNRollingNews *)news;

// 流内视频模板断点续播曝光
//- (void)reportAdVideoPlayBreakpoint:(SNRollingNews *)news;

+ (SNStatInfoUseType)getObjLebel:(BOOL)isPush spaceId:(NSString *)spaceId defaultLabel:(SNStatInfoUseType)defaultLabel empty:(BOOL)isEmpty;

@end
