//
//  SNNewsFullscreenManager.h
//  sohunews
//
//  Created by HuangZhen on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsFullscreenManager : NSObject

/**
 是否是全屏模式
 焦点图 火车cell以及频道导航栏等等会根据此变量进行适配
 */
@property (nonatomic, assign, getter=isFullscreenMode) BOOL fullscreenMode;

/**
 焦点图轮播的锚点
 */
@property (nonatomic, assign) CGFloat rollingFocusAnchor;

//全屏变火车的距离
@property (nonatomic, assign) CGFloat trainAnimationDistance;
//记录首页要闻contentOffset
@property (nonatomic, assign) CGFloat homeTableViewOffsetY;

@property (nonatomic, assign) BOOL openAppFlag;//启动app标志
@property (nonatomic, assign) BOOL focusToTrain;
@property (nonatomic, assign) int  newsPullTimes;//要闻上拉次数


//新版要闻全屏模式管理类单例
+ (SNNewsFullscreenManager *)manager;

//全屏幕显示焦点图开关 (默认只针对首页)
+ (BOOL)isFullScreanSwitch;
+ (void)setFullScreanSwitch:(BOOL)value;

//判断是否要闻改版
+ (BOOL)newsChannelChanged;

+ (void)setOpenAppToday:(BOOL)isFirst;
+ (BOOL)isFirstOpenAppToday;//是否每天第一次启动
+ (void)userNewsPullTimes:(int)pullTime;//设置要闻频道可上拉加载次数
+ (int)getUserNewsPullTimes;//获取要闻频道可上拉加载次数
/*
 标识是否进行焦点图变火车的动画 needTrainAnimation==YES 进行变换动画
 */
+ (void)setNeedTrainAnimation:(BOOL)need;
+ (BOOL)needTrainAnimation;

//处理系统状态条颜色通用方法
+ (void)resetStatusBarStyleIfFullscreenMode:(BOOL)fullscreenMode;

@end
