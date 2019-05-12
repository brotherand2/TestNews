//
//  SHADConfigs.h
//  LiteSohuNews
//
//  Created by H on 16/1/18.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#ifndef SHADConfigs_h
#define SHADConfigs_h

/** 客户端广告位和sdk广告位对应关系：
 客户端广告位	sdk名称	sdk广告Id	说明
 1          sohu	12224	loading页
 2          sohu	12225	 自主运营的媒体账号首页banner广告头 ------  不需要
 3          sohu	12226	自主运营的媒体账号首页banner广告中  ------  不需要
 4          sohu	12227	自主运营的媒体账号首页banner广告尾  ------  不需要
 5          sohu	12228	广场banner广告一
 6          sohu	12229	广场banner广告二
 7          sohu	12230	广场banner广告三
 8          sohu	12231	广场banner广告四
 9          sohu	12232	图文新闻页面广告
 10         sohu	12233	大图浏览模式下最后一帧广告
 11         sohu	12234	各频道banner广告
 12         sohu	12235	视频包框广告                      ------  不需要
 13         sohu	12236	直播间口播广告
 14         sohu	12237	相关新闻最后一条
 15         sohu	12238	组图推荐最后一条
 */

// loading页
#define kSNAdSpaceIdLoading                             (@"12224")

// 广场banner广告一
#define kSNAdSpaceIdSubCenterAd0                        (@"12228")

// 广场banner广告二
#define kSNAdSpaceIdSubCenterAd1                        (@"12229")

// 广场banner广告三
#define kSNAdSpaceIdSubCenterAd2                        (@"12230")

// 广场banner广告四
#define kSNAdSpaceIdSubCenterAd3                        (@"12231")

// 正文页冠名广告
#define kSNAdSpaceIdNewsSponsorShip                     (@"12791")

//正文页内容中插入广告
#define kSNAdSpaceIdNewsArticleInsertad                 (@"15681")

// 测试服正文页冠名广告
#define kSNAdSpaceIdTestNewsSponsorShip                 (@"12434")

// 图文新闻页面广告
#define kSNAdSpaceIdArticleAd                           (@"12232")

// 大图浏览模式下最后一帧广告
#define kSNAdSpaceIdSlideshowTail                       (@"12233")

// 各频道banner广告
#define kSNAdSpaceIdChannelBanner                       (@"12234")

// 直播间口播广告
#define kSNAdSpaceIdLiveRoom                            (@"12236")

// 相关新闻最后一条
#define kSNAdSpaceIdArticleRecommendTail                (@"12237")

// 组图推荐最后一条
#define kSNAdSpaceIdGroupPicRecommendTail               (@"12238")

// 组图推荐倒数第二个广告位
#define kSNAdSpaceIdGroupPicRecommendPenult             (@"13371")
#define kSNAdSpaceIdGroupPicRecommendPenultTest         (@"12716")

// 订阅tab banner广告位
#define kSNAdSpaceIdMySubBanner                         (@"12264")

// 直播间冠名广告
#define kSNAdSpaceIdLiveSponsorShip                     (@"12838")

#define kSNAdSpaceIdLiveSponsorShipTestServer           (@"12442")

#pragma mark - notification
/** 由于广告sdk对应每个广告位的广告，一对多，广告加载完成之后 回调通过notify来做
 ** 有需求的自己添加观察者自己处理自己spaceId对应的广告就ok了  不做太复杂的delegate回调
 */

// 广告加载完成，成功显示 用户通过这个来确定合适展示广告，调整广告大小位置等
//#define kSNAdDidAppearNotification                      (@"kSNAdDidAppearNotification")

// 广告加载过程中的错误回调 - 并非全都是真正发生错误的回调 没有缓存数据也会回调这个
//#define kSNAdDidReceiveErrorNotification                (@"kSNAdDidReceiveErrorNotification")

// 广告action 回调
//#define kSNAdDidActNotification                         (@"kSNAdDidActNotification")

#pragma mark- UI

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kSNNewsSdkAdPicTextView_ImageViewWidth                      (kAppScreenWidth - 14*2)
#define kSNNewsSdkAdPicTextView_ImageViewHeight                     (int)(kSNNewsSdkAdPicTextView_ImageViewWidth /2 )
#define kSNSubCenterTopAdView_Width                                 (kAppScreenWidth)
#define kSNSubCenterTopAdView_Height                                (kAppScreenWidth / 6.4)
#define kAdvertiseLiveSponsorShipHeight                             (30 / 2)
#define kAdvertiseAdRecommendView_width                             (120)
#define kAdvertiseAdRecommendView_height                            (78)
#define kAdvertiseAdArticleInsertView_width                         (322)
#define kAdvertiseAdArticleInsertView_height                        (161)
#define kAdvertistGroupPicRecommendTail                             (114)
#define kAdvertistGroupPicRecommendPenult                           (74)

#pragma mark - notification

#define kSNPhotoSlideshowRecommendAd        @"kSNPhotoSlideshowRecommendAd"

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

#pragma mark- 业务相关统计常量

//统计模型来源
typedef NS_ENUM(NSInteger, SNBusinessStatisticsObjFrom)
{
    SNBusinessStatisticsObjFromDefault = 0,
    SNBusinessStatisticsObjFromNews    = 1
};

//统计模型
typedef NS_ENUM(NSInteger, SNBusinessStatisticsObjType)
{
    SNBusinessStatisticsObjTypeTimeline          = 0,
    SNBusinessStatisticsObjTypeArticleRecommend  = 5,       //article新闻正文推荐
    SNBusinessStatisticsObjTypeGalleryRecommend  = 6,       //组图新闻推荐
    SNBusinessStatisticsObjTypeLoading           = 7,       //loading页
    SNBusinessStatisticsObjTypeSubRecom          = 12,      //订阅推荐
};

static NSString *businessStatisticsLoadTypeDragUpLoadMore   = @"0";
static NSString *businessStatisticsLoadTypeDragDownRefresh  = @"1";

#endif /* SHADConfigs_h */
