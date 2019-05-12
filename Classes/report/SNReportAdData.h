//
//  SNReportData.h
//  sohunews
//
//  Created by Xiang Wei Jia on 4/4/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STADManagerForNews.h"

typedef NS_ENUM(NSInteger, ReportDataAdType)
{
    adReportTimeLineStream,   // 编辑流
    adReportRecommendStream,  // 推荐流
    adReportSDK,              // 非流内广告。走SDK的
    adReportPush,             // 从push来的广告
    adReportPopularizeTimeLine,  // 内部广告编辑流
    adReportPopularizeRecommend,  // 内部广告推荐流
};

typedef NS_ENUM(NSInteger, ReportDataAdTab)
{
    adReportTabNews,   // 新闻tab
    adReportTabViedo,  // 视频tab
    adReportTabMine,   // 我的tab
};

@interface SNReportAdData : NSObject

@property (nonatomic, readonly) NSInteger dataId;  // 数据结构的唯一标识符
@property (nonatomic) ReportDataAdType adType;  // 广告类型
@property (nonatomic, readonly) ReportDataAdTab tab;
@property (nonatomic, copy) NSString *spaceId;

// -------------这两个属性是上报模块专用，非上报模块请不要修改。-------------
@property (nonatomic, strong) NSMutableDictionary *serverParam;  // 服务器返回的上报数据
@property (nonatomic, strong) NSMutableDictionary *sdkParam;  // sdk返回的数据
@property (nonatomic, retain) UIView *sdkView;  // sdk返回的view，没用，上报的时候带回去即可
@property (nonatomic, strong) NSMutableDictionary *clientParam;  // 客户端生成的上报数据都放这里
// -------------这两个属性是上报模块专用，非上报模块请不要修改。-------------

// 是否是从缓存中加载的
@property (nonatomic) BOOL cache;

// 是否是空广告
@property (nonatomic, readonly) BOOL isEmptyAd;

// 查询是否上报过的状态。
- (BOOL)isReported:(STADDisplayTrackType)type;

// 这5个属性是为了写代码的时候更方便，本质上还是isReported:(STADDisplayTrackType)type
@property (nonatomic, readonly) BOOL isReportedLoad;
@property (nonatomic, readonly) BOOL isReportedExposure;
@property (nonatomic, readonly) BOOL isReportedEmpty;
@property (nonatomic, readonly) BOOL isReportedUninteresting;

// 是否是流内的广告
@property (nonatomic, readonly) BOOL isStreamAd;

- (instancetype)initWithId:(NSInteger)dataId adType:(ReportDataAdType)type tab:(ReportDataAdTab)tab;

// 生成流内SDK用的上报数据
- (NSMutableDictionary *)toSDKReportData:(STADDisplayTrackType)reportType;

// 生成上报给灿灿的数据.
// 别问我为什么取名是灿灿，
// 因为品控组我只认识她，也不知道品控组的后台服务器叫什么，统计买点怎么取名，根本没法命名啊
- (NSDictionary *)toStatisticsReportData:(STADDisplayTrackType)reportType;

// 上报标记。上报之后调这个标记为已经上报
- (void)report:(STADDisplayTrackType)type;

@end

// 客户端自己添加的上报参数
@interface SNReportAdData(SNReportAdDataClientData)

// 批量添加上报参数
- (void)addClientParams:(NSDictionary *)params;


// 添加视频上报的数据
- (void)addPTime:(NSTimeInterval)pTime;
- (void)addTTime:(NSTimeInterval)tTime;

// 添加新闻上报参数
- (void)addNewsId:(NSString *)newsId;

//
- (void)addExposureFrom:(NSInteger)from;
- (void)addgbcode:(NSString *)gbcode;

- (void)addRoomId:(NSString *)roomId;

@end
