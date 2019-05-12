//
//  SNAdvertiseConfigs.h
//  sohunews
//
//  Created by jojo on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNAdvertiseConfigs_h
#define sohunews_SNAdvertiseConfigs_h

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

#define kSNSubCenterTopAdView_Width                                 (kAppScreenWidth)//(640 / 2)
#define kSNSubCenterTopAdView_Height                                (kAppScreenWidth / 6.4)
#define kAdvertiseSponsorShipWidth                                  (120 / 2)
#define kAdvertiseSponsorShipHeight                                 (24 / 2)
#define kAdvertiseLiveSponsorShipHeight                             (30 / 2)
#define kAdvertiseAdRecommendView_width                             (120)
#define kAdvertiseAdRecommendView_height                            (78)

#pragma mark - notification


#endif
