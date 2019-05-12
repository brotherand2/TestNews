//
//  SNStatInfo.h
//  sohunews
//
//  Created by jialei on 14-7-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//  定义统计操作的类型和属性,流内统计操作个性化参数
//  For ARC
//

#import <Foundation/Foundation.h>
#import "SNStatisticsConst.h"
#import "STADManagerForNews.h"

@interface SNStatInfo : NSObject

/*统计需求项(可选值范围可参考wiki)  子类重写返回需要的值
 * load	加载
 * show	曝光
 * clk 	点击
 * unintr  不感兴趣
 */
@property(nonatomic, strong, readonly) NSString *statType;

//广告sdk曝光类型
@property(nonatomic, assign, readonly) STADDisplayTrackType adTrackType;

//统计对象标识(保存objId,对于大幅的换量广告[应用下载]newsID的值就是adID且只有一个adID，对于小幅换量广告会有单独的adID key，且会有多个adID，必须)
@property(nonatomic, strong) NSArray *adIDArray;

//用于流类加载过滤token重复值(必须)
@property(nonatomic, strong) NSString *token;

//统计对象类型(流内都用templateType，非流内商业传itemspaceid, 非流内推广自定义，可参考wiki, 必须传)
@property(nonatomic, strong) NSString *objType;

//统计对象标签(商业 （流/非流）、推广（流/非流）,必须传)
@property(nonatomic, assign) SNStatInfoUseType objLabel;

//统计对象来源(news, video, subScribe，不必须)
@property(nonatomic, strong) NSString* objFrom;

//统计对象来源 的 唯一标识 (例如：objFrom=news&objFromId=${channelId}， 不必须)
@property(nonatomic, strong) NSString* objFromId;

//视频广告统计-广告已播放时长(毫秒)
@property(nonatomic, assign) NSTimeInterval videoAdPlayedTime;

//视频广告统计-广告总时长(毫秒)
@property(nonatomic, assign) NSTimeInterval videoAdTotalTime;

//统计事件标签 来源(不必须)
@property(nonatomic, strong) NSString* fromObjLabel;

//统计事件来源(不必须)
@property(nonatomic, assign) int fromObjType;

//SDK制作的广告View
@property(nonatomic, strong) UIView *adView;

//广告数据结构
//@property(nonatomic,retain)SNNewsAd *newsAd;

@property(nonatomic, strong) NSString *scope;

@property(nonatomic, strong) NSString *position;

@property(nonatomic, strong) NSString *reposition;

@property(nonatomic, strong) NSString *abposition;

//下拉刷新次数
@property(nonatomic, strong) NSString *refreshCount;

//上推加载更多次数
@property(nonatomic, strong) NSString *loadMoreCount;

//推荐流加载次数（包括下拉和上拉）
@property(nonatomic, strong) NSString *refreshRecomCount;

//频道ID
@property(nonatomic, strong) NSString *newsChannelId;

//渠道号
@property(nonatomic, strong) NSString *appChannelId;

//上报广告sdk参数，广告对应的itemspaceid
@property(nonatomic, strong) NSString *itemspaceid;

//上报广告sdk参数，广告检测关键值
@property(nonatomic, strong) NSString *monitorkey;

@property(nonatomic, strong) NSString *viewMonitor;

@property(nonatomic, strong) NSString *impId;
@property(nonatomic, strong) NSString *resource;
@property(nonatomic, strong) NSString *gbcode;
@property(nonatomic, strong) NSString *adpType;
@property(nonatomic, strong) NSString *iconText;
@property(nonatomic, strong) NSString *roomId;  //直播ID， 用于直播间冠名广告
@property (nonatomic, copy) NSString * blockId; //直播间类型
@property (nonatomic, copy) NSString * vp; //视频广告 vp=0 开始播放； vp=1 结束播放

@property(nonatomic, strong) NSMutableDictionary *requestFilter;   //请求参数

@property(nonatomic, strong) NSString *clickMonitor;

@property(nonatomic,assign) BOOL isReported;  // 是否报过

@property(nonatomic, strong) NSString *newsId;
@property(nonatomic, strong) NSString *subId;
@property(nonatomic, strong) NSString *newsType;
@property(nonatomic, strong) NSString *debugloc;
@property(nonatomic, copy) NSDictionary *jsonData;
@property(nonatomic, strong) NSString *newsCate;//push广告独有参数
@property(nonatomic, copy) NSString *source; //新品算广告标识（source:"0"）
@property(nonatomic, copy) NSString *adstyle;
@property(nonatomic, copy) NSString *clicktype;

@end
