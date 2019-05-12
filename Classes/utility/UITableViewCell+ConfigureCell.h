//
//  UITableViewCell+ConfigureCell.h
//  sohunews
//
//  Created by jialei on 14-3-5.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNStatClickInfo.h"
#import "SNStatExposureInfo.h"
#import "SNStatLoadInfo.h"
#import "SNRollingNews.h"

@interface UITableViewCell (ConfigureCell)

- (void)setObject:(id)item;
- (void)setDelegate:(id)delegate;
- (NSString *)getExposureFrom;
- (BOOL)showListenNewsTips;
- (void)moreAction;

/**
 * 发送搜狐新闻投放广告的点击数据
 * 搜狐新闻投放的广告，有如：大幅[kNewsTypeApp 18]、小幅换量广告[kNewsTypeAppArray 23]
 *
 *  @return 搜狐新闻投放广告的曝光数据
 */
- (void)reportPopularizeStatClickInfo:(SNNewsApp *)newsApp;

/**
 * 发送搜狐新闻投放广告的曝光数据
 * 搜狐新闻投放的广告，有如：大幅[kNewsTypeApp 18]、小幅换量广告[kNewsTypeAppArray 23]
 */
- (void)reportPopularizeStatExposureInfo;

/**
 * 发送搜狐新闻投放广告的不感兴趣数据
 * 搜狐新闻投放的广告，有如：大幅[kNewsTypeApp 18]、小幅换量广告[kNewsTypeAppArray 23]
 */
- (void)reportPopularizeStatUninterestInfo;

@end
