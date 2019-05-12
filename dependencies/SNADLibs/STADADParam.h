//
//  STADADParam.h
//  STAD
//
//  Created by jinkai on 13-9-11.
//  Copyright (c) 2013年 sohu All rights reserved.
//

#import <UIKit/UIKit.h>

#define STAD_Deprecated(_c_str_) __attribute__((deprecated(_c_str_)))

typedef NS_ENUM(NSInteger, STADAdMod){
    STADAdModOad = 1,   //前贴片
    STADAdModPad  ,     //暂停
    STADAdModOpen,      //开机
    STADAdModMad,       //中插片
    STADAdModEad,       //后贴片
    STADAdModBanner,    //播放页通栏
    STADAdModFlogo,     //角标
    STADAdModBarrage,   //弹幕
    STADAdModWrapframe, //包框
    STADAdModBand,      // 压屏条
    STADAdModOverfly,   //视频浮层广告
    STADAdModFocus,     //视频焦点图广告
    STADAdModImgBanner, //非播放页通栏
    STADAdModUnkown     //其他
};

typedef NS_ENUM(NSInteger, STADDevicePlatform){
    STADDevicePlatformiPad = 1,      //iPad
    STADDevicePlatformiPhone,        //iPhone
    STADDevicePlatformAPad,          //AnroidPad
    STADDevicePlatformAPhone,        //AndroidPhone
    STADDevicePlatformUnkown
};

typedef NS_ENUM(NSInteger, STADNetState){
    STADNetState2G = 1,         //2G网络
    STADNetState3G,             //3G网络
    STADNetState4G,             //4G网络
    STADNetStateWifi,           //Wifi
    STADNetStateUnkown          //无网络
};

//Banner广告位置ID
typedef NS_ENUM(NSInteger,kStadBannerId){
    kStadBanner_Unknown = -1,
    kStadBanner_MyChannel=1,            //我的频道
    kStadBanner_SearchResult,           //搜索结果页
    kStadBanner_HomePageBanner,         //首页banner
    kStadBanner_BrandZone,              //首页品牌专区
    kStadBanner_TV,                     //电视频道页banner
    kStadBanner_Movie,                  //电影频道页banner
    kStadBanner_Variety,                //综艺频道页banner
    kStadBanner_Sports,                 //体育频道页banner
    kStadBanner_Member,                 //会员频道页banner
    kStadBanner_Comic,                  //动漫频道页banner
    kStadBanner_AmericanTV,             //美剧频道页banner
    kStadBanner_KoreanTV,               //韩日剧频道页banner
    kStadBanner_Documentary,            //纪录片频道页banner
    kStadBanner_Classroom,              //课堂频道页banner
    kStadBanner_Entertainment,          //娱乐频道页banner
    kStadBanner_Selfmedia,              //自媒体频道页banner
    kStadBanner_Tab_Selfmedia,          //自媒体tab页banner
    kStadBanner_Detail_Relation,        //详情页伴随banner
    kStadBanner_Detail_Series,          //详情页剧集banner
    kStadBanner_Detail_Bottom           //详情页底部banner
};

@interface STADADParam : NSObject

@property (nonatomic, copy) NSString *baseURL;        //服务端地址

//-----------------Required-------------------//
@property (nonatomic, copy) NSString *source;         //入口来源
/*
 入口来源(source)：
 	iPad:
 首页：0；电视剧：101；电影：100；综艺：106；直播：9002；动漫：115；新闻：122；纪录片：107；
 音乐：121；娱乐：112；星尚：130；教育：119；搜狐出品：9004；VIP：9003；排行榜：100001；
 搜索：10000；播放历史：10001；订阅：10002；收藏：10003；上传：10004；PUSH：10005；
 下载：10006；好声音：10007；Action打开：10008；
 
 	iPhone:
 首页：0；电视剧：101；电影：100；综艺：106；直播：9002；动漫：115；新闻：122；纪录片：107；
 音乐：121；娱乐：112；星尚：130；教育：119；搜狐出品：9004；VIP：9003；排行榜：100001；
 搜索：10000；播放历史：10001；订阅：10002；收藏：10003；上传：10004；PUSH：10005；
 下载：10006；好声音：10007；Action打开：10008；
 
 	android Pad:
 首页：0；电视剧：101；电影：100；综艺：106；动漫：115；新闻：122；纪录片：107；
 音乐：121；娱乐：112；星尚：130；搜狐出品：9004；VIP：9003； 搜索：10000；
 播放历史：10001；订阅：10002；收藏：10003；PUSH：10005；下载：10006；好声音：10007；
 Action打开：10008；
 
 	android Phone:
 首页：0；电视剧：101；电影：100；综艺：106；直播：9002；动漫：115；新闻：122；纪录片：107；
 音乐：121；娱乐：112；星尚：130；教育：119；搜狐出品：9004；VIP：9003；排行榜：100001；
 搜索：10000；播放历史：10001；订阅：10002；收藏：10003；上传：10004；PUSH：10005；
 下载：10006；好声音：10007；Action打开：10008；
 */

@property (nonatomic, assign) STADAdMod pt;            //广告形式
@property (nonatomic, assign) STADDevicePlatform plat;      //移动平台
@property (nonatomic, assign) STADNetState wt;              //网络状态
@property (nonatomic, assign) CGSize size;              //播放窗口大小
@property (nonatomic, copy) NSString *sver;           //客户端版本
@property (nonatomic, copy) NSString *c;              //频道
@property (nonatomic, copy) NSString *vc;             //Vrs分类
@property (nonatomic, copy) NSString *pn;             //设备名称
@property (nonatomic, copy) NSString *al;             //专辑
@property (nonatomic, copy) NSString *du;             //视频时长
@property (nonatomic, copy) NSString *vid;            //视频ID
@property (nonatomic, copy) NSString *tvid;           //视频ID2
@property (nonatomic, copy) NSString *tuv;            //用户唯一标识
@property (nonatomic, copy) NSString *crid;           //版权公司

//------------------Mad 中插广告------------------//
@property (nonatomic, copy) NSString *ptime;        //中插打点时间，单位为秒
@property (nonatomic, copy) NSString *inx;          //第几个点，从1开始（只有该参数在使用）
@property (nonatomic, copy) NSString *tot;          //总共多少个点

//------------------Banner 广告------------------//
@property (nonatomic, copy) NSString *poscode;            //位置ID
@property (nonatomic, copy) NSString *pagecode;           //页面ID

//------------------Optional------------------//
@property (nonatomic, copy) NSString *sysver;         //系统版本
@property (nonatomic, copy) NSString *partner;        //渠道ID
@property (nonatomic, copy) NSString *poid;           //产品ID
@property (nonatomic, copy) NSString *ag;             //用户年龄
@property (nonatomic, copy) NSString *st;             //明星
@property (nonatomic, copy) NSString *ar;             //产地
@property (nonatomic, copy) NSString *vu;             //VIP用户 用户名 (是否是VIP用户，是传用户名，否传空字符串)
@property (nonatomic, copy) NSString *adpr;           //去广告特权 （1去广告，0不去）
@property (nonatomic, copy) NSString *latitude;       //纬度
@property (nonatomic, copy) NSString *longitude;      //经度
@property (nonatomic, copy) NSString *udid;           //openUdid
@property (nonatomic, copy) NSString *offline;        //是否为离线资源
@property (nonatomic, copy) NSString *videoType;      //播放类型

//------------------启动图／暂停 广告------------------//
@property (nonatomic, copy) NSString *width;          //广告展示窗体宽度
@property (nonatomic, copy) NSString *height;         //广告展示窗体高度

@property (nonatomic, copy) NSString *lid;            //直播ID
@property (nonatomic, copy) NSString *islocaltv;      //是否播放的本地缓存视频
@property (nonatomic, copy) NSString *pay;            //付费频道，VIP
@property (nonatomic, copy) NSString *guid;           //广告库存统计

@property (nonatomic, copy) NSString *playstyle;      //当前播放的播放器形态playstyle参数（1：默认值；2：流播放——热点流和流式详情页传）
@property (nonatomic, copy) NSString *qt;             //角标和弹幕广告请求请求引擎时间点

@property (nonatomic,assign) NSTimeInterval timeleft;  //请求包框广告剩余时间，秒

/*MRAID广告展示区域示例，不遮挡原有倒计时等元素
 ********************************************************************
 *                                                                  *
 *                                                                  *
 ******************************mraidWidth****************************
 *                                                                  *
 *                                                              mraidHeight
 *                                                                  *
 *                                                                  *
 ********************************************************************
 *                                                                  *
 *                                                                  *
 ********************************************************************
 */
@property (nonatomic, assign) NSInteger mraidWidth;   //MRAID广告展示区域宽度
@property (nonatomic, assign) NSInteger mraidHeight;  //MRAID广告展示区域高度

//未定义属性
@property (nonatomic, copy) NSString *res;    //默认为空
@property (nonatomic, copy) NSString *prot;   //默认Vast
@property (nonatomic, copy) NSString *app;    //默认TV
@property (nonatomic, copy) NSString *appid;  //来自哪个App
@property (nonatomic, copy) NSString *screenstate;  //标识显示器是否全屏

/// 外部扩展字段，sdk透传！！将废弃
@property (nonatomic, strong) NSMutableDictionary *params STAD_Deprecated("重构后版本将废弃，使用extensibleParams");

/// 外部扩展字段，sdk透传！！
@property (nonatomic, strong) NSDictionary *extensibleParams;

//------------------------------SDK 内部使用---------------------------
- (void)changeByParamDict:(NSDictionary *)paramDict;
- (NSDictionary *)changeByParam:(STADADParam *)adparam;
- (void)cleanAllParam;

- (NSString *)getUrlString;
- (NSString *)getOADUrlString;
- (NSString *)getPADUrlString;
- (NSString *)getFlogoUrlString;
- (NSString *)getBandUrlString;
- (NSString *)getOverflyURLString;
- (NSString *)getFocusURLString;
- (NSString *)getOpenUrlString;
- (NSString *)getBADUrlString;
- (NSString *)getBarrageUrlString;
- (NSString *)getWrapframeUrlString;
- (NSString *)imageBannerUrlString;
- (NSString *)imageBannerID:(kStadBannerId)type;
@end
