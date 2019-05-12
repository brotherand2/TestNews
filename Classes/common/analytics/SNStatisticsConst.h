//
//  SNStatisticsConst.h
//  sohunews
//
//  Created by jialei on 14-7-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNStatisticsConst_h
#define sohunews_SNStatisticsConst_h

//statType
//static NSString* statisticsEventLoad = @"load";
//static NSString* statisticsEventShow = @"show";
//static NSString* statisticsEventClk = @"clk";
//static NSString* statisticsEventUninterested = @"unintr";
typedef NS_ENUM(NSInteger, SNStatisticsEventType){
    SNStatisticsEventTypeLoad,
    SNStatisticsEventTypeShow,
    SNStatisticsEventTypeClick,
    SNStatisticsEventTypeUninterested
};

//objFrom
static NSString* statisticsObjFromNews = @"news";
static NSString* statisticsObjFromVideo= @"video";
static NSString* statisticsObjFromsubscribe = @"subscribe";

//objType
static NSString *const kObjTypeOfRecommendPosionInMySubBanner = @"1001";
static NSString *const kObjTypeOfVideoAd = @"1002";

typedef NS_ENUM(NSInteger, SNShnAdFrom) {
    SNShnAdFrom_EditingTimeline,
    SNShnAdFrom_RecommendedTimeline
};

//objLabel  对应服务端objLabel参数  和  客户端广告统计模版
typedef NS_ENUM(NSInteger, SNStatInfoUseType) {
    SNStatInfoUseTypeTimelineAd = 1,            //商业广告编辑流
    SNStatInfoUseTypeOutTimelineAd = 2,         //商业广告非流内
    SNStatInfoUseTypeTimelinePopularize = 3,    //内部推广编辑流
    SNStatInfoUseTypeOutTimelinePopularize = 4,  //内部推广非流内
    SNStatInfoUseTypeEmptyTimelineAd = 11,        //商业广告编辑流（空广告）
    SNStatInfoUseTypeEmptyOutTimelineAd = 21,     //商业广告非流内（空广告）
    SNStatInfoUseTypeEmptyTimelinePopularize = 31,     //内部推广编辑流（空广告）
    SNStatInfoUseTypeEmptyOutTimelinePopularize = 41,   //内部推广非流内（空广告）
    SNStatInfoUseTypeRecommed = 5,  // 商业广告推荐流
    SNStatInfoUseTypeEmptyRecommed = 51,  // 商业广告推荐流（空广告）
    SNStatInfoUseTypePushAd = 7,   // push定向广告
    SNStatInfoUseTypeEmptyPushAd = 71,  // push定向空广告
};

#pragma mark- 广告SDK通用上报接口参数
//static NSString* adTrackParamSpaceid = @"itemspaceid";
static NSString* adTrackParamSpaceid = @"apid";
//static NSString* adTrackParamMonitorkey = @"monitorkey";
static NSString* adTrackParamMonitorkey = @"mkey";
static NSString* adTrackParamViewMonitorkey = @"viewmonitor";
static NSString* adTrackParamClickMonitorkey = @"clickmonitor";
static NSString* adTrackParamReposition = @"reposition";
static NSString* adTrackParamAbposition = @"abposition";
static NSString* adTrackParamPosition   = @"position";
static NSString* adTrackParamRefreshCount = @"rc";
static NSString* adTrackParamLoadmoreCount = @"lc";
static NSString* adTrackParamRefreshRecomCount = @"rr";
static NSString* adTrackParamAppChn = @"appchn";
static NSString* adTrackParamNewsChn = @"newschn";
static NSString* adTrackParamADPType = @"adp_type";
//static NSString* adTrackParamImpId = @"impressionid";
static NSString* adTrackParamImpId = @"impid";
static NSString* adTrackParamResource = @"resource";
static NSString* adTrackParamScope = @"scope";
static NSString* adTrackParamGbcode = @"gbcode";
static NSString* adTrackParamCid = @"cid";
static NSString* adTrackParamTTime = @"ttime";
static NSString* adTrackParamPTime = @"ptime";
static NSString* adTrackParamVP = @"vp";
static NSString* adTrackParamAppDelayTrack= @"appdelaytrack";
static NSString* adTrackParamAdstyle = @"adstyle";
static NSString* adTrackParamClicktype = @"clicktype";

#pragma mark- 业务相关统计常量

//统计模型来源
typedef NS_ENUM(NSInteger, SNBusinessStatisticsObjFrom)
{
    SNBusinessStatisticsObjFromDefault = 0,
    SNBusinessStatisticsObjFromNews    = 1,
    SNBusinessStatisticsObjFromPGC     = 5
};

//统计模型
typedef NS_ENUM(NSInteger, SNBusinessStatisticsObjType)
{
    SNBusinessStatisticsObjTypeTimeline          = 0,
    SNBusinessStatisticsObjTypeArticleRecommend  = 5,       //article新闻正文推荐
    SNBusinessStatisticsObjTypeGalleryRecommend  = 6,       //组图新闻推荐
    SNBusinessStatisticsObjTypeLoading           = 7,       //loading页
    SNBusinessStatisticsObjTypeSubRecom          = 12,      //订阅推荐
    SNBusinessStatisticsObjTypeRedPacket         = 17,      //频道流内红包曝光
    SNBusinessStatisticsObjTypeZNPaopan          = 19,      //频道流内智能报盘
};

static NSString *businessStatisticsLoadTypeDragUpLoadMore   = @"0";
static NSString *businessStatisticsLoadTypeDragDownRefresh  = @"1";

#endif
