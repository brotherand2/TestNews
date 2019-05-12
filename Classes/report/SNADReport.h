//
//  SNADReport.h
//  sohunews
//
//  Created by yangln on 2016/12/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNReportAdData.h"
#import "STADManagerForNews.h"
#import "SNSpaceId.h"
#import "SNVideoAdContext.h"

@interface SNADReport : NSObject

+ (SNADReport *)shareInstance;

// 获取上报的数据结构.
// dataId: parseAdData返回的ID
+ (SNReportAdData *)reportData:(NSInteger)dataId;

// 助手函数， 将beParse里的所有内容都变成一个一维字典复制到save中
+ (void)parseAdDictionary:(NSDictionary *)beParse value:(NSMutableDictionary *)save;

// 通用的上报接口。 用户没有客户端生成的上报数据的情况。
// 如果有客户端生成的上报数据，需要调用分类里的相关接口来上报
+ (void)reportLoad:(NSInteger)dataId;
+ (void)reportClick:(NSInteger)dataId;
+ (void)reportExposure:(NSInteger)dataId;
+ (void)reportEmpty:(NSInteger)dataId;
+ (void)reportUninteresting:(NSInteger)dataId;

// 不用的广告需要调用此接口删除，释放内存
+ (void)removeUnusedAd:(NSInteger)dataId;

// 是否是空广告
+ (BOOL)isEmptyAd:(NSInteger)dataId;

/*
 通用解析server to server的广告接口，参数较多，如果不方便使用，可以定制接口，比如流内直播间广告那样
 通用流内解析接口，如果有解析不了的数据需要定制新接口
 解析流内广告数据，返回广告ID,上报时需要。
 data: 服务器返回的自身数据节点
 root: 服务器返回的数据根节点
 tab: 当前的标签，新闻，我的，视频
 channelId: 广告所在的频道id. 没有频道填nil，或者使用服务器返回的channel，也填nil. 但并不是每个广告服务器都会返回channel
 adType: 比较复杂. 具体的填法不清楚问Cae
 adReportTimeLineStream   编辑流
 adReportRecommendStream  推荐流
 adReportSDK,             走SDK的广告
 adReportPush,            从push来的广告，不管是编辑流，推荐流，还是sdk的广告，只要来自push，就填这
 adReportPopularizeTimeLine   内部广告编辑流  CMS模板专用
 adReportPopularizeRecommend  内部广告推荐流  正文页热词专用
 */
+ (NSInteger)parseStreamData:(NSDictionary *)data root:(NSDictionary *)root tab:(ReportDataAdTab)tab channel:(NSString *)channelId adType:(ReportDataAdType)adType;

// 解析直播间各种流内数据的接口
/*
 通用流内解析接口，如果有解析不了的数据需要定制新接口
 解析流内广告数据，返回广告ID,上报时需要。
 data: 服务器返回的自身数据节点
 root: 服务器返回的数据根节点
 */
+ (NSInteger)parseLiveRoomStreamData:(NSDictionary *)data root:(NSDictionary *)root;

// sdk广告的各种接口
/*
 通用SDK接口，如果有解析不了的数据需要定制新接口
 解析流内广告数据，返回广告ID,上报时需要。
 adInfo: 服务器返回的adInfos数组的元素
 root: 服务器返回的数据根节点
 channel: 频道id
 type: 不同的模块和广告对应的type是不一样的，具体的请查看wiki
 常用的部分模块type填法:
 一般情况下传入adReportSDK,
 但是只要是广告来自push，不管是哪个模块，哪个流，统一填 adReportPush
 tab: 广告来自哪个tab(新闻tab，视频tab，我的tab).
 */
+ (NSInteger)parseSDKData:(NSDictionary *)adInfo root:(NSDictionary *)root channel:(NSString *)channel adType:(ReportDataAdType)type tab:(ReportDataAdTab)tab;

+ (void)addSdkParam:(NSInteger)dataId sdkParam:(NSDictionary *)param;
+ (void)addSdkView:(NSInteger)dataId sdkView:(UIView *)view;
+ (void)addSpaceId:(NSInteger)dataId spaceId:(NSString *)spaceId;

+ (void)addClientParams:(NSInteger)dataId params:(NSDictionary *)params;

@end
