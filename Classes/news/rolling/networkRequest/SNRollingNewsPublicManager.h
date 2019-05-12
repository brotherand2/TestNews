//
//  SNRollingNewsPublicManager.h
//  sohunews
//
//  Created by lhp on 5/16/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCellMoreView.h"

typedef enum {
    SNRollingNewsModeNone,              //默认
    SNRollingNewsModeEdit,              //编辑模式
    SNRollingNewsModeRecommend,         //推荐模式
    SNRollingNewsModeV6,                //首页到流式推荐
}SNRollingNewsMode;

typedef enum {
    SNHomePageLeaveNone,                //默认
    SNHomePageLeave5Min,                //5分钟内
    SNHomePageLeave30Min,               //5-30分钟内
    SNHomePageLeave1Hour,               //5分钟-1小时内
    SNHomePageLeave2Hour,               //30分钟－2小时内
    SNHomePageLeaveOther,               //5.2.2 超过5分钟 //超过2小时
}SNHomePageLeave;

typedef enum {
    SNTopNewsDefault,           //置顶区数据没有更新
    SNTopNewsUpdate,            //置顶区数据有更新
    SNTopNewsNULL,              //没有置顶区数据
}SNTopNewsStatus;

typedef enum {
    SNRollingNewsSourceDefault,         //默认
    SNRollingNewsSourceTab,             //编辑模式
    SNRollingNewsSourceChannel,         //推荐模式
    SNRollingNewsSourceRefresh,         //首页到流式推荐
    SNRollingNewsSourceClickChannel,    //点击频道进入
}SNRollingNewsSource;

typedef enum {
    SNRollingNewsUserDefault,               //默认
    SNRollingNewsUserChangeTab,             //用户切换tab并刷新
    SNRollingNewsUserTabAndRefresh,         //用户点击当前频道刷新
    SNRollingNewsUserPullAndRefresh,        //用户手动下拉刷新
    SNRollingNewsUserOnlyRefresh,           //点击上次看到这里刷新
    SNRollingNewsUserSohuIconRefresh,       //点击搜狐ICON
}SNRollingNewUserAciton;

typedef enum {
    SNMoreCellLoadMore,             //加载更多
    SNMoreCellAllLoad,              //已经全部加载
    SNMoreCellRefreshAndBack,       //回顶并刷新
}SNRollingMoreCellStatus;

#define kDefaultContentToken            @"no_data"

@class SNListenNewsGuideView;

/*****************************记录频道新闻各种公用数据***************************
 ****************************************************************************/

@interface SNRollingNewsPublicManager : NSObject {
    SNCellMoreView *moreView;       //弹出更多
    SNRollingNewsMode newsMode;     //首页模式
    SNHomePageLeave leaveMode;      //离开首页时间模式
    
    int playerTop;                  //记录视频播放器位置，滚出屏幕外停止播放
    float leaveHomeTime;            //记录离开首页时间
    BOOL leaveModeGet;              //记录首页离开模式已使用
    BOOL appLaunch;                 //应用开启
    BOOL resetOpen;                 //重置开启
    BOOL refreshClose;              //关闭首页刷新请求(控制频道流手势滑动自动加载)
    BOOL channelRefreshClose;       //控制频道list更新后刷新首页
    BOOL homeRecordTimeClose;       //控制频道首页离开时间是否置零
    BOOL newsTableClick;            //新闻tab刷新操作
    BOOL widgetOpen;                //widget调起
    BOOL isNeighChannel;            //相邻频道
    BOOL resetHome;                 //首页重置
    BOOL refreshChannel;            //频道中刷新
    BOOL refreshStock;              //刷新股票频道标志
    BOOL refreshSubscribe;          //订阅频道有小红点时刷新
    BOOL showUpdateTips;
    BOOL showRecommend;             //首页频道下拉显示推荐流
    BOOL isHomePage;                //记录当前是否为首页编辑流
    BOOL clearAllCache;             //清除缓存
    BOOL pageViewTimer;             //管理焦点图定时器
    
    NSString *updateTime;           //我的频道更新时间
    NSString *mainFocalId;          //主焦点图ID
    NSString *viceFocalId;          //当前焦点图ID
    NSString *lastUpdateTime;       //编辑新闻更新时间（服务器返回值)
    NSString *loadMoreTips;         //加载编辑文案
    NSString *refreshChannelId;     //提示更新的channelid
    
    
    NSString *__weak focusPosition;  //存储频道焦点图位置
    NSInteger pageNum;               //加载页
    //5.3.2 功能需求参数
    NSTimer *refreshChannelTimer;    //记录频道刷新时间
    
    SNRollingMoreCellStatus moreCellStatus;    //已全部加载
    SNRollingNewsSource newsSource;            //“点击，刷新”埋点参数
    NSMutableDictionary *focusImageIndexDic;   //焦点图轮播Index，channelId主键
    
    NSArray *searchHotWord;             //搜索热词
    NSArray *novelSearchHotWord;        //小说热词搜索
    
    NSDate *rollingNewsBeginTime; //开始访问当前频道时间，用于计算频道停留总时长
    SNRollingNewUserAciton userAction; //统计用户在频道流内刷新行为
}

@property (nonatomic, strong) SNCellMoreView *moreView;
@property (nonatomic, assign) SNRollingNewsMode newsMode;
@property (nonatomic, strong) SNListenNewsGuideView *listenNewsGuideView;
@property (nonatomic, assign) int playerTop;
@property (nonatomic, assign) int playerBigTop;
@property (nonatomic, assign) int playerMinTop;
@property (nonatomic, assign) BOOL appLaunch;
@property (nonatomic, assign) BOOL resetOpen;
@property (nonatomic, assign) BOOL refreshClose;
@property (nonatomic, assign) BOOL channelRefreshClose;
@property (nonatomic, assign) BOOL homeRecordTimeClose;
@property (nonatomic, assign) BOOL newsTableClick;
@property (nonatomic, assign) BOOL widgetOpen;
@property (nonatomic, assign) BOOL isNeighChannel;
@property (nonatomic, assign) BOOL resetHome;
@property (nonatomic, assign) BOOL refreshChannel;
@property (nonatomic, assign) SNRollingMoreCellStatus moreCellStatus;
@property (nonatomic, assign) BOOL refreshStock;//刷新股票频道标志
@property (nonatomic, assign) BOOL refreshSubscribe;
@property (nonatomic, assign) BOOL isHaveAlreadyLoadH5Channel;

@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *lastUpdateTime;
@property (nonatomic, copy) NSString *mainFocalId;
@property (nonatomic, copy) NSString *viceFocalId;
@property (nonatomic, copy) NSString *loadMoreTips;
@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger times;
@property (nonatomic, assign) BOOL showUpdateTips;
@property (nonatomic, weak) NSString *focusPosition;
@property (nonatomic, assign) int minTimelineIndex;

@property (nonatomic, strong) NSTimer *refreshChannelTimer;
@property (nonatomic, strong) NSString *refreshChannelId;
@property (nonatomic, assign) BOOL showRecommend;
@property (nonatomic, assign) BOOL isHomePage;
@property (nonatomic, assign) BOOL clearAllCache;
@property (nonatomic, assign) SNRollingNewsSource newsSource;
@property (nonatomic, strong) NSMutableDictionary *focusImageIndexDic;
@property (nonatomic, assign) BOOL pageViewTimer;
@property (nonatomic, assign) BOOL isClickTodayImportNews;

//判断是否正在切换本地频道
@property (nonatomic, assign) BOOL isChangingLocalChannel;

//要闻改版, 用于判断从新闻Tab的时候点击新闻Tab刷新
@property (nonatomic, assign) BOOL backToHomeAndRefreshForNewsChanged;

@property (nonatomic, strong) NSArray *searchHotWord;
@property (nonatomic, strong) NSArray *novelSearchHotWord;//小说热词搜索
@property (nonatomic, strong) NSString *noticeText;

@property (nonatomic, strong) NSDictionary *noticeDict;

@property (nonatomic, assign) BOOL isNeedToBackToTop;  //是否需要置顶
@property (nonatomic, assign) BOOL isNeedToPushToRecom;//是否需要跳转到推荐频道
@property (nonatomic, assign) BOOL isReadMoreArticles; //标记连续阅读

@property (nonatomic, assign) BOOL isClickBackToHomePage;
//当前页面是否显示了编辑流新闻
@property (nonatomic, assign) BOOL isRollingEditNewsShow;
//是否正在加载频道数据
@property (nonatomic, assign) BOOL isRequestChannelData;
//是否显示Toast
@property (nonatomic, assign) BOOL isShowInsertToast;

@property (nonatomic, assign) BOOL touchChannel;
@property (nonatomic, assign) BOOL banScreenLandScape;
@property (nonatomic, assign) BOOL isBeginHomeSearch;

//首页推荐流加载计数，程序运行期间一直累加，重启置0，每天6点置0
@property (nonatomic, assign) NSInteger homeADCount;
//推荐频道加载计数，程序运行期间一直累加，重启置0，每天6点置0
@property (nonatomic, assign) NSInteger recomADCount;
//本地频道加载计数，程序运行期间一直累加，重启置0，每天6点置0，切换城市置0
@property (nonatomic, assign) NSInteger localADCount;
//娱乐频道加载计数，程序运行期间一直累加，重启置0，每天6点置0
@property (nonatomic, assign) NSInteger entertainmentADCount;
//编辑流加载几屏后，加载推荐流
@property (nonatomic, assign) BOOL isRecommendAfterEditNews;
@property (nonatomic, assign) BOOL isReloadChannelList;//是否请求了v7/list.go
//开始访问当前频道时间，用于计算频道停留总时长
@property (nonatomic, strong) NSDate *rollingNewsBeginTime;
//外链、push频道二代协议中传的newsID，在请求news.go时加上，服务端置顶新闻用到
@property (nonatomic, strong) NSString *channelProtocolNewsID;
//记录正文是否请求推荐流强制刷新数
@property (nonatomic, assign) BOOL isRecomForceRefresh;
@property (nonatomic, assign) BOOL isOpenNewsFromPush;//push调起app
@property (nonatomic, assign) SNRollingNewUserAciton userAction;

+ (SNRollingNewsPublicManager *)sharedInstance;
- (void)showAnimationWithRight:(int) rightValue;
- (void)closeListenNewsGuideViewAnimation:(BOOL)isAnimation;
- (void)closeCellMoreViewAnimation:(BOOL)isAnimation;
- (void)updateTimeWithDateString:(NSString *)dateString;
- (void)recordLeaveHomeTime;
- (void)resetLeaveHomeTime;
- (SNHomePageLeave)getLeaveHomeTimeMode;
- (BOOL)compareUpdateTimeWithDateString:(NSString *)dateString;
- (NSString *)addParameterWithUrl:(NSString *)url;
- (void)saveFocusPosition:(NSString *)positon
            withChannelId:(NSString *)channelId;
- (NSString *)getFocusPositionWithChannelId:(NSString *)channelId;
- (void)saveContentToken:(NSString *)token
           withChannelId:(NSString *)channelId;
- (NSString *)getContentTokenWithChannelId:(NSString *)channelId;
- (SNTopNewsStatus)getTopNewsStatus:(NSString *)token
                          channelId:(NSString *)channelId;
- (void)clearAllContentToken;
- (void)deleteContentTokenWithChannelId:(NSString *)channelId;

+ (void)deleteReadTimeOutNews;
+ (void)saveReadNewsWithNewsId:(NSString *)newsId
                     ChannelId:(NSString *)channelId;
+ (BOOL)isReadNewsWithNewsId:(NSString *)newsId
                   ChannelId:(NSString *)channelId;

- (void)saveRequestParamsWithChannelId:(NSString *)channelId;
- (void)readRequestParamsWithChannelId:(NSString *)channelId;
- (void)deleteRequestParamsWithChannelId:(NSString *)channelId;
- (void)deleteAllChannelsRequestParams;

- (int)getNewsModeNum;

- (void)setFocusImageIndex:(int)index channelId:(NSString *)channelId;
- (int)getFocusImageIndexWithChannelId:(NSString *)channelId;

- (void)recordRollingNewsBeginTime;//设置访问频道开始时间为当前时间
- (NSTimeInterval)rollingNewsTotalTime;//当前频道停留总时长
+ (BOOL)needResetCurChannel;//times=0，表示重置
+ (BOOL)needResetHotWords;//每次重置的时候，更新搜索热词

+ (void)saveRollingPage:(int)pageNum channelId:(NSString *)channelId;
+ (void)saveRollingTimes:(int)times channelId:(NSString *)channelId;
+ (void)saveRollingMinTimelineIndex:(int)minTimelineIndex channelId:(NSString *)channelId;
+ (int)readRollingPageWithChannelId:(NSString *)channelId;
+ (int)readRollingTimesWithChannelId:(NSString *)channelId;
+ (int)readRollingMinTimelineIndexWithChannelId:(NSString *)channelId;

@end
