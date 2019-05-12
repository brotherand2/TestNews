//
//  SNCheckManager.h
//  sohunews
//
//  Created by qi pei on 7/3/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

// history:
// 1.0 广告主动监测
// 2.0 扩展check接口 去服务端获取各种标志位
// 3.0 增加了 搜狐广告sdk监测等
// 4.0 移除了所有广告相关的代码 转变为纯check服务
// ……

#import <Foundation/Foundation.h>

typedef enum {
	MinimumRefreshInterval = 20,
	DefaultRefreshInterval = 60 * 5
} RefreshInterval;

@interface SNCheckManager : NSObject {
    int _interval;
    NSMutableArray *allAds;
    NSTimer *_adTimer;
    int _serverInterval;
    int _contentRefreshInterval;    // 正文返回刷新时间间隔
}

@property (atomic, strong) NSMutableArray *allAds;
@property (assign) BOOL isAccurateAd; // 是否为新的精准广告
@property (nonatomic, assign) int contentRefreshInterval;

+ (SNCheckManager *)sharedInstance;

+ (void)startCheckService:(RefreshInterval)interval;
+ (void)stopCheckService;

+ (BOOL)hasNewfeedback;
+ (void)changeToNoNewFB;
+ (BOOL)checkNewVersion;
+ (BOOL)checkDynamicPreferences;

- (BOOL)supportVideoDownload;

@end
