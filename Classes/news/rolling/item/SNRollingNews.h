//
//  SNRollingNews.h
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//个性化
@interface SNNewsIndividuationInfo : NSObject
{
    NSString *idString;
    NSString *pic;
    NSString *link;
}

@property(nonatomic,copy) NSString *idString;
@property(nonatomic,copy) NSString *pic;
@property(nonatomic,copy) NSString *link;

@end

@interface SNNewsIndividuationNameInfo : NSObject

@property(nonatomic,copy) NSString *idString;
@property(nonatomic,copy) NSString *pic;
@property(nonatomic,copy) NSString *link;
@property(nonatomic,copy) NSString *desc;

@end

@interface SNNewsIndividuation : NSObject
@property(nonatomic,strong) NSMutableArray *individuationArray;//个性化模版数据
@property(nonatomic,strong) SNNewsIndividuationNameInfo *nameInfo;//冠名
@end


//应用
@interface SNNewsApp : NSObject
{
    NSString *appId;
    NSString *urlScheme;
    NSString *appName;
    NSString *appDesc;
    NSString *appIcon;
    NSString *downloadLink;
}

@property(nonatomic,copy) NSString *adID;
@property(nonatomic,copy) NSString *appId;
@property(nonatomic,copy) NSString *urlScheme;
@property(nonatomic,copy) NSString *appName;
@property(nonatomic,copy) NSString *appDesc;
@property(nonatomic,copy) NSString *appIcon;
@property(nonatomic,copy) NSString *downloadLink;

@end

//视频
@interface SNNewsVideoInfo : NSObject
{
    NSString *idString;
    NSString *columnId;
    NSString *columnName;
    NSString *duration;
    NSString *link;
    NSString *pic;
    NSString *siteName;
    NSString *title;
    NSString *vId;
    NSString *siteId;
}

@property(nonatomic,copy) NSString *idString;
@property(nonatomic,copy) NSString *columnId;
@property(nonatomic,copy) NSString *columnName;
@property(nonatomic,copy) NSString *duration;
@property(nonatomic,copy) NSString *link;
@property(nonatomic,copy) NSString *pic;
@property(nonatomic,copy) NSString *siteName;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *vId;
@property(nonatomic,copy) NSString *siteId;

@end

//广告
@interface SNNewsAd : NSObject
{
    NSString *adId;
    NSString *title;
    NSString *picUrl;
    NSString *viewMonitor;
    NSString *clickMonitor;
    NSString *appLink;
    NSString *h5Link;
    NSString *advertiser;
}

@property(nonatomic,copy)NSString *adId;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *picUrl;
@property(nonatomic,strong)NSArray *picUrls;
@property(nonatomic,strong)NSMutableDictionary *newsDataDic;
@property(nonatomic,strong)NSString *channelId;
@property(nonatomic,copy)NSString *adpType;
@property(nonatomic,copy)NSString *viewMonitor;
@property(nonatomic,copy)NSString *clickMonitor;
@property(nonatomic,copy)NSString *appLink;
@property(nonatomic,copy)NSString *h5Link;
@property(nonatomic,copy)NSString *advertiser;
@property(nonatomic,copy)NSString *phone;
@property (nonatomic, copy) NSString *source;//新品算广告标识（source:"0"）
@property (nonatomic, copy) NSString *predownload;//全屏广告zip
@property (nonatomic, strong) NSArray * admaster_imp;
@property (nonatomic, strong) NSArray * tracking_imp;
@property (nonatomic, strong) NSArray * tracking_imp_end;
@property (nonatomic, strong) NSArray * tracking_imp_Breakpoint;
@property (nonatomic, strong) NSArray * imp;
@property (nonatomic, strong) NSArray * miaozhen_imp;
@property (nonatomic, strong) NSArray * admaster_click_imp;
@property (nonatomic, strong) NSArray * miaozhen_click_imp;
@property (nonatomic, strong) NSArray *tel_imp;
@property (nonatomic, strong) NSString *adStyle;
@property (nonatomic, assign) BOOL isReported;
@property (nonatomic, assign) BOOL isReportedEndVP;
@property (nonatomic, assign) BOOL isReportedStartVP;
@property (nonatomic, copy) NSString *clicktype;

@end



//彩票
@interface SNNewsLottery : NSObject
{
    NSString *title;
    NSString *description;
    NSString *pic;
    NSString *link;
    NSString *idString;
}

@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *description;
@property(nonatomic,copy)NSString *pic;
@property(nonatomic,copy)NSString *link;
@property(nonatomic,copy)NSString *idString;

@end

//财经
@interface SNNewsFinance:NSObject
{
    NSString *colour;
    NSString *name;
    NSString *rate;
    NSString *diff;
    NSString *price;
    NSString *link;
    NSString *idString;
    NSString *shortTitle;
}

@property(nonatomic,copy)NSString *colour;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *rate;
@property(nonatomic,copy)NSString *diff;
@property(nonatomic,copy)NSString *price;
@property(nonatomic,copy)NSString *link;
@property(nonatomic,copy)NSString *idString;
@property(nonatomic,copy)NSString *shortTitle;

@end


//段子
@interface SNNewsFunnyText:NSObject
{
    NSString *content;
    NSString *imgUrl;
    NSString *hotCount;
    NSString *hotcomment_ntime;
    NSString *hotcomment_city;
    NSString *hotcomment_authorImg;
    NSString *hotcomment_gen;
    NSString *hotcomment_ctime;
    NSString *hotcomment_passport;
    NSString *hotcomment_commentId;
    NSString *hotcomment_author;
    NSString *hotcomment_content;
    NSString *hotcomment_pid;

}
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *hotCount;
@property(nonatomic,copy)NSString *imgUrl;
@property(nonatomic,copy)NSString *hotcomment_ntime;
@property(nonatomic,copy)NSString *hotcomment_authorImg;
@property(nonatomic,copy)NSString *hotcomment_gen;
@property(nonatomic,copy)NSString *hotcomment_ctime;
@property(nonatomic,copy)NSString *hotcomment_passport;
@property(nonatomic,copy)NSString *hotcomment_commentId;
@property(nonatomic,copy)NSString *hotcomment_content;
@property(nonatomic,copy)NSString *hotcomment_pid;
@property(nonatomic,copy)NSString *hotcomment_author;
@property(nonatomic,copy)NSString *hotcomment_city;

+ (SNNewsFunnyText *)initWithFavorateInfoString:(NSString *)infoString;

@end

@interface SNBook : NSObject

@property (nonatomic, copy) NSString * bookId;
@property (nonatomic, copy) NSString * author;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * category;
@property (nonatomic, copy) NSString * imageUrl;
@property (nonatomic, copy) NSString * detailUrl;
@property (nonatomic, copy) NSString * readUrl;
@property (nonatomic, copy) NSString * lastUpdateBook;
@property (nonatomic, assign) BOOL showDot;
@property (nonatomic, assign) BOOL remind;

@end

/**
 *  书籍标签类
 *  @author     wangchuanwen
 *  @version    5.8.9
 */
@interface SNBookLabel : NSObject

@property (nonatomic, copy) NSString * labelId;//书籍标签id
@property (nonatomic, copy) NSString * name;//书籍标签名称
@property (nonatomic, copy) NSString * type;//书籍标签类型(运营标签和分类标签)
@property (nonatomic, copy) NSString * readUrl;//书籍标签跳转链接

@end

//比赛
@interface SNNewsMatch:NSObject
{
    NSString *hostIcon;
    NSString *hostTeam;
    NSString *hostTotal;
    NSString *visitorIcon;
    NSString *visitorTeam;
    NSString *visitorTotal;
}

@property(nonatomic,copy)NSString *hostIcon;
@property(nonatomic,copy)NSString *hostTeam;
@property(nonatomic,copy)NSString *hostTotal;
@property(nonatomic,copy)NSString *visitorIcon;
@property(nonatomic,copy)NSString *visitorTeam;
@property(nonatomic,copy)NSString *visitorTotal;

@end

@class SNRollingNews;
//冠名
@interface SNNewsSponsorships:NSObject
{
    NSString *title;
    NSString *adType;
    NSString *adId;
    NSString *gbcode;
    NSString *position;
}

@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *adId;
@property(nonatomic,copy)NSString *adType;
@property(nonatomic,copy)NSString *gbcode;
@property(nonatomic,copy)NSString *position;
@property(nonatomic,copy)NSString *abposition;
@property(nonatomic,copy)NSString *lc;
@property(nonatomic,copy)NSString *rc;
@property(nonatomic,copy)NSString *scope;
@property(nonatomic,copy)NSString *newschn;
@property(nonatomic,copy)NSString *appchn;
@property(nonatomic,copy)NSString *monitorkey;
@property(nonatomic,copy)NSString *itemspaceid;
@property(nonatomic,copy)NSString *impId;
@property(nonatomic,copy)NSString *clickMonitor;
@property(nonatomic,copy)NSString *viewMonitor;
@property(nonatomic,copy)NSString* adpType;
@property(nonatomic,strong)NSArray *miaozhen_imp;
@property(nonatomic,strong)NSArray *admaster_imp;
@property(nonatomic,strong)NSArray *click_imp;
@property(nonatomic,strong)NSArray *normal_imp;

@property(nonatomic,assign)BOOL reportDisplay;
@property(nonatomic,assign)BOOL isReported;

//流内冠名展示上报
- (void)reportSponsorShipOneDisplay:(SNRollingNews *)news;
//流内冠名加载上报
- (void)reportSponsorShipLoad:(SNRollingNews *)news;
//流内冠名空上报
- (void)reportSponsorShipEmpty:(SNRollingNews *)news;

@end

@interface SNNewsSohuLive : NSObject{
    int liveCount;    //直播在线人数
    NSString *nickName;     //直播来源
    NSString *showTime;     //直播时间
    int liveStatus;   //直播状态
}

@property (nonatomic, assign) int liveCount;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *showTime;
@property (nonatomic, assign) int liveStatus;

@end

@interface SNNewsSohuFeed : NSObject{
    NSString    *feedId;
    int         repostsCount;
    int         feedType;//图文14；视频17；直播18
    NSString    *userId;
    NSString    *userName;
    NSString    *avatarUrl;
    int         commentCnt;
    NSString    *openFlag;
}

@property (nonatomic, strong) NSString    *feedId;
@property (nonatomic, strong) NSString    *createTime;
@property (nonatomic, assign) int         repostsCount;
@property (nonatomic, assign) int         feedType;
@property (nonatomic, strong) NSString    *userId;
@property (nonatomic, strong) NSString    *userName;
@property (nonatomic, strong) NSString    *avatarUrl;
@property (nonatomic, assign) int         commentCnt;
@property (nonatomic, strong) NSString    *openFlag;

@end

typedef enum AdReportState {
    
    AdReportStateNo,  // 没有报过任何东西
    AdReportStateLoad,  // 报了加载
    AdReportStateDisplay,  // 报了曝光， 报了曝光就肯定报过加载，不加载怎么能曝光呢
    AdReportStateClick,  // 报了点击，报了点击就肯定报了曝光，不曝光怎么点击呢
}AdReportState;

@interface SNRollingNews : NSObject {
    
    NSString *channelId;            //频道ID
    NSString *newsId;               //新闻ID（对于滚动的专题新闻来说，从JSON数据中得到的newsId就是termId）
    NSString *newsType;             //数据类型(新闻、组图、直播、广告、微文)
    NSString *time;                 //时间
    NSString *title;                //标题
    NSString *digNum;               //顶数量
    NSString *commentNum;           //评论数
    NSString *abstract;             //描述信息
    NSString *link;                 //跳转连接
    NSString *picUrl;               //图片连接
    NSString *listPicsNumber;       //图片个数
    NSString *timelineIndex;        //数据库中排序编号
    NSString *from;                 //统计来源(频道、推荐、频道刊物、搜索)
    NSString *hasVideo;             //是否为视频新闻
    NSString *updateTime;           //更新时间
    NSString *recomDay;             //推荐图标(日间)
    NSString *recomNight;           //推荐图标（夜间）
    NSString *media;                //媒体来源
    NSString *starGrade;            //刊物评价几星
    NSString *subId;                //刊物ID
    NSString *needLogin;            //刊物订阅是否需要登录
    NSString *isSubscribe;          //是否订阅刊物
    NSString *isRecom;              //是否为推荐新闻
    NSString *recomType;            //推荐类型
    NSString *liveStatus;           //直播状态
    NSString *local;                //本地新闻图标
    NSString *isWeather;            //天气标识
    NSString *city;                 //天气城市
    NSString *tempHigh;             //最高气温
    NSString *tempLow;              //最低气温
    NSString *weatherIoc;           //天气图标
    NSString *weather;              //天气情况
    NSString *pm25;                 //pm2.5
    NSString *week;                 //时间week
    NSString *quality;              //空气质量
    NSString *wind;                 //风
    NSString *gbcode;               //城市国标码
    NSString *date;                 //天气日期
    NSString *localIoc;             //天气图标(local)
    NSString *thirdPartUrl;         //推荐外网地址
    NSString *templateId;           //cell模板ID
    NSString *templateType;         //cell模板类型
    NSString *dataString;           //特殊模板数据
    NSString *playTime;             //直播日期
    NSString *liveType;             //比分直播：liveType=1,话题直播：liveType=2
    NSString *token;                //用于曝光统计
    NSString *isFlash;              //是否为快讯
    NSString *position;             //相对位置
    NSString *adType;               //广告类型
    NSString *isHasSponsorships;    //是否有冠名广告
    NSString *iconText;             //新闻类型文字
    NSString *newsTypeText;         //新闻类型文字，区分iconText
    NSString *sponsorships;         //冠名Json信息
    NSString *cursor;               //游标
    
    BOOL localWeather;              //本地新闻焦点
    BOOL fromSub;                   //是否为频道刊物
    BOOL isRead;                    //是否已读
    BOOL showUpdateTips;            //频道新闻更新红点显示
    int morePageNum;                //编辑加载更多的页数
    BOOL isTopNews;                 //置顶新闻
    BOOL isLatestNews;              //流式频道最新新闻标志
    
    //红包信息
    NSString *bgPic;                //背景图片
    NSString *sponsoredIcon;        //冠名图片
    NSString *redPacketTitle;       //红包信息
    NSString *redPacketId;          //红包ID
    NSString *couponId;             //优惠券ID
    
    //
    NSString *tvPlayTime;
    NSString *tvPlayNum;
    NSString *playVid;
    NSString *tvUrl;
    NSString *sourceName;
    int siteValue;
    BOOL autoPlay;

    NSMutableArray *newsInfoArray;  //存储个性化模版、专题展开模版新闻信息（存储的为NSDictionary） （优化）
    NSMutableArray *newsFocusArray; //存储焦点图轮播新闻
    NSMutableArray *newsHotWordsArray;   //存储推荐流标签类Item （优化）
    NSMutableArray *newsItemArray;  //存储火车卡片新闻，焦点图下两条
    
    SNNewsFinance *leftFinance;                     //财经（左）
    SNNewsFinance *rightFinance;                    //财经（右）
    SNNewsFinance *entryFinance;                    //智能报盘
    SNNewsMatch *match;                             //比赛
    SNNewsLottery *leftLottery;                     //彩票（左）
    SNNewsLottery *rightLottery;                    //彩票（右）
    SNNewsAd *newsAd;                               //广告
    SNNewsVideoInfo *video;                         //视频
    SNNewsApp *app;                                 //应用
    SNNewsIndividuation *individuation;             //个性化
    SNNewsSponsorships *sponsorshipsObject;         //冠名
    SNNewsFunnyText *funnyText;                     //段子
    SNNewsSohuLive *sohuLive;                       //千帆直播
    SNNewsSohuFeed *sohuFeed;
    
    NSString *trainCardId;  //火车卡片ID
    NSString *trainPos;
}

@property(nonatomic, copy)NSString *channelId;
@property(nonatomic, copy)NSString *newsId;
@property(nonatomic, copy)NSString *newsType;
@property(nonatomic, copy)NSString *time;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *blueTitle;
@property(nonatomic, copy)NSString *digNum;
@property(nonatomic, copy)NSString *commentNum;
@property(nonatomic, copy)NSString *abstract;
@property(nonatomic, copy)NSString *link;
@property(nonatomic, copy)NSString *picUrl;
@property(nonatomic, copy)NSArray *picUrls;
@property(nonatomic, copy)NSString *listPicsNumber;
@property(nonatomic, copy)NSString *timelineIndex;
@property(nonatomic, copy)NSString *from;
@property(nonatomic, copy)NSString *hasVideo;
@property(nonatomic, copy)NSString *hasAudio;
@property(nonatomic, copy)NSString *hasVote;
@property(nonatomic, copy)NSString *updateTime;
@property(nonatomic, copy)NSString *recomDay;
@property(nonatomic, copy)NSString *recomNight;
@property(nonatomic, copy)NSString *media;
@property(nonatomic, copy)NSString *starGrade;
@property(nonatomic, copy)NSString *subId;
@property(nonatomic, copy)NSString *needLogin;
@property(nonatomic, copy)NSString *isSubscribe;
@property(nonatomic, copy)NSString *isWeather;
@property(nonatomic, copy)NSString *city;
@property(nonatomic, copy)NSString *tempHigh;
@property(nonatomic, copy)NSString *tempLow;
@property(nonatomic, copy)NSString *weatherIoc;
@property(nonatomic, copy)NSString *weather;
@property(nonatomic, copy)NSString *pm25;
@property(nonatomic, copy)NSString *weak;
@property(nonatomic, copy)NSString *liveTemperature;
@property(nonatomic, copy)NSString *quality;
@property(nonatomic, copy)NSString *isRecom;
@property(nonatomic, copy)NSString *recomType;
@property(nonatomic, copy)NSString *liveStatus;
@property(nonatomic, copy)NSString *local;
@property(nonatomic, copy)NSString *wind;
@property(nonatomic, copy)NSString *gbcode;
@property(nonatomic, copy)NSString *date;
@property(nonatomic, copy)NSString *localIoc;
@property(nonatomic, copy)NSString *thirdPartUrl;
@property(nonatomic, copy)NSString *templateId;
@property(nonatomic, copy)NSString *templateType;
@property(nonatomic, copy)NSString *dataString;
@property(nonatomic, copy)NSString *playTime;
@property(nonatomic, copy)NSString *liveType;
@property(nonatomic, copy)NSString *token;
@property(nonatomic, copy)NSString *isFlash;
@property(nonatomic, copy)NSString *position;
@property(nonatomic, copy)NSString *adType;
@property(nonatomic, copy)NSString *isHasSponsorships;
@property(nonatomic, copy)NSString *iconText;
@property(nonatomic, copy)NSString *newsTypeText;
@property(nonatomic, copy)NSString *sponsorships;
@property(nonatomic, copy)NSString *cursor;
@property(nonatomic, strong)NSArray *tel_imp;
@property (nonatomic, strong) NSMutableArray *topAdNews;//本地频道四个按钮广告数据

//小说
@property(nonatomic, copy)NSString *novelAuthor;
@property(nonatomic, copy)NSString *novelBookId;
@property(nonatomic, copy)NSString *novelCategory;
@property(nonatomic, copy)NSString *novelChannelLink;//小说频道跳转

@property (nonatomic, copy) NSString *recomReasons;//推荐理由
@property (nonatomic, copy) NSString *recomTime;//推荐时间
@property (nonatomic, copy) NSString *recomInfo;//推荐上报信息
//统计数据
@property(nonatomic, copy)NSString *scope;
@property(nonatomic, copy)NSString *appChannel;
@property(nonatomic, copy)NSString *newsChannel;

@property(nonatomic, assign)int adAbPosition;         //广告绝对位置
@property(nonatomic, assign)int adPosition;           //广告相对位置
@property(nonatomic, assign)int refreshCount;         //刷新次数
@property(nonatomic, assign)int loadMoreCount;        //加载更多次数
@property(nonatomic, assign)int morePageNum;

@property(nonatomic, assign)BOOL isRead;
@property(nonatomic, assign)BOOL localWeather;
@property(nonatomic, assign)BOOL fromSub;
@property(nonatomic, assign)BOOL hasStatistics;
@property(nonatomic, assign)BOOL showUpdateTips;
@property(nonatomic, assign)BOOL isTopNews;
@property(nonatomic, assign)BOOL isLatestNews;
@property(nonatomic, assign)BOOL isAvailableRecomForAD;

//红包信息
@property(nonatomic, copy) NSString *bgPic;                //背景图片
@property(nonatomic, copy) NSString *sponsoredIcon;        //冠名图片
@property(nonatomic, copy) NSString *redPacketTitle;       //红包信息
@property(nonatomic, copy) NSString *redPacketId;           //红包ID
@property(nonatomic, copy) NSString *couponId;              //优惠券ID
//流内视频播放
@property(nonatomic, copy) NSString *tvPlayTime;              //新闻视频播放时长
@property(nonatomic, copy) NSString *tvPlayNum;              //新闻视频观看人数
@property(nonatomic, copy) NSString *playVid;
@property(nonatomic, copy) NSString *tvUrl;
@property(nonatomic, copy) NSString *sourceName;
@property(nonatomic, assign)int siteValue;
@property (nonatomic, assign)BOOL autoPlay;

@property(nonatomic,strong)SNNewsFinance *leftFinance;
@property(nonatomic,strong)SNNewsFinance *rightFinance;
@property(nonatomic,strong)SNNewsFinance *entryFinance;
@property(nonatomic,strong)SNNewsMatch *match;
@property(nonatomic,strong)SNNewsLottery *leftLottery;
@property(nonatomic,strong)SNNewsLottery *rightLottery;
@property(nonatomic,strong)SNNewsAd *newsAd;
@property(nonatomic,strong)SNNewsVideoInfo *video;
@property(nonatomic,strong)SNNewsApp *app;
@property(nonatomic,strong)SNNewsIndividuation *individuation;
@property(nonatomic,strong)SNNewsSponsorships *sponsorshipsObject;
@property(nonatomic,strong)SNNewsFunnyText *funnyText;
@property(nonatomic,strong)SNNewsSohuLive *sohuLive;
@property(nonatomic,strong)SNNewsSohuFeed *sohuFeed;
@property (nonatomic, strong)NSString *financeUnreadMsg;

@property (nonatomic, strong) NSString *trainCardId;
@property (nonatomic, assign) NSInteger createAt;
@property (nonatomic, strong) NSString *trainPos;

//5.1 add累计阅读数
@property(nonatomic, strong)NSString *countShowText;

// add by Cae. 判断是否从缓存中读取
@property(nonatomic) AdReportState reportState;     // 是否报过加载


//4.3.1
@property(nonatomic,strong)NSMutableArray *appArray;
@property(nonatomic,assign)SNRollingNewsStatsType statsType;

//4.3.2
@property(nonatomic,strong)NSMutableArray *newsInfoArray;

//5.4.2
@property(nonatomic,strong)NSMutableArray *newsFocusArray;

@property(nonatomic,strong)NSMutableArray *newsItemArray;

//书架
@property (nonatomic, strong) NSMutableArray * bookShelf;
@property (nonatomic, strong) NSMutableArray *newsHotWordsArray;
@property (nonatomic, strong) NSMutableArray * bookLabelArray;//书籍标签数组
// add by Cae 是否是push来的
@property(nonatomic) BOOL isPush;

//小说运营banner(startTime title templateType link pic endTime)
@property(nonatomic,strong) NSString *startTime;//banner开始时间
@property (nonatomic, strong) NSString *endTime;//banner结束时间
@property (nonatomic, assign) BOOL hiddenLine;//cell分割线，YES：隐藏

@property (nonatomic, assign) NSInteger trainCellIndex;//记录火车卡片模板的锚点
@property (nonatomic, assign) CGFloat trainCellContentOffsetX;//记录火车卡片模板的锚点
@property (nonatomic, assign) BOOL isCardsFromFocus;//记录火车卡片是由全屏焦点图变化而成
@property (nonatomic, assign) BOOL trainDataAllDidLoad;//记录火车卡片已经完全加载

#if DEBUG_MODE
- (void)print;
#endif

- (BOOL)isReportAd:(AdReportState)reportType;
- (void)setAdReportState:(AdReportState)adReportState;
- (AdReportState)adReportState;

- (BOOL)isRecomNews;
- (BOOL)isFocusNews;
- (BOOL)isLoadMore;
- (void)setWeatherInfoWithDic:(NSDictionary *) newsdic;
- (void)setDataStringWithDic:(NSDictionary *)newsDic;
- (void)setNewsVideoWithDic:(NSDictionary *)newsDic;
- (void)setSponsorshipsWithDic:(NSDictionary *) newsDic;
- (void)setSponsorshipsWithJson:(NSString *) jsonString;
- (void)setDateStringWithJson:(NSString *) jsonString;
- (BOOL)shouldBeHiddenWith:(BOOL)preload;//带是否为预加载的参数
- (BOOL)isEmptyAdNews;
- (BOOL)isMoreFocusNews;
- (void)setNewsFocusItems:(NSArray *)newsItems;
- (BOOL)isGroupPhotoNews;
- (BOOL)isRedPacketNews;
- (void)setRedPacketNewsItem:(NSDictionary *)newDic;
- (void)setCouponsNesItem:(NSDictionary *)newsDic;
- (BOOL)isRedPacketTips;
- (BOOL)isCouponsNews;
- (BOOL)isSohuLive; //千帆直播
- (BOOL)isRecomendHotWrods;
- (BOOL)isSohuFeed;
- (BOOL)isSohuFeedPhotos;
- (BOOL)isSohuFeedVideo;
- (BOOL)isSohuFeedLive;
- (BOOL)isFullScreenFocusNews;//焦点图内元素
- (BOOL)isFullScreenFocusNewsItem;//自定义的焦点图模版
- (BOOL)isTowTopNews;
- (BOOL)isTrainCardNews;//火车开片内的新闻元素
- (BOOL)isTrainCardNewsItem;//自定义的火车模版
- (BOOL)isRollingTopNews;
- (void)setTrainInfoDataDic:(NSDictionary *)newsDic;
- (BOOL)showNewTopArea;
- (void)setAdDataWithDic:(NSDictionary *)newsDataDic;
/**
 小说book对象

 @param bookDic 服务器返回的json
 @return book对象
 */
+ (SNBook *)createBookWithDictionary:(NSDictionary *)bookDic;
@end
