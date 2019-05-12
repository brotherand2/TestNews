//
//  SNRollingNewsTableItem.h
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRollingNews.h"
#import "SNRollingNewsModel.h"
#import "SNRollingNewsTableController.h"

typedef enum {
    NEWS_ITEM_TYPE_UNKNOWN = -1,
    NEWS_ITEM_TYPE_NORMAL = 0,          //图文
    NEWS_ITEM_TYPE_GROUP_PHOTOS,        //组图
    NEWS_ITEM_TYPE_SPECIAL_NEWS,        //专题
    NEWS_ITEM_TYPE_LIVE,                //直播
    NEWS_ITEM_TYPE_WEIBO,               //微闻
    NEWS_ITEM_TYPE_NEWSPAPER,           //报纸
    NEWS_ITEM_TYPE_SUBSCRIBE,           //搜索中的订阅
    NEWS_ITEM_TYPE_PUBLIC,              //彩票、世界杯通用类型
    NEWS_ITEM_TYPE_AD,                  //广告
    NEWS_ITEM_TYPE_MYSUBSCRIBE,         //我的订阅
    NEWS_ITEM_TYPE_VIDEO,               //视频
    NEWS_ITEM_TYPE_FINANCE,             //财经
    NEWS_ITEM_TYPE_APP,                 //下载应用
    NEWS_ITEM_TYPE_FOCUS_WEATHER,       //焦点天气
    NEWS_ITEM_TYPE_APP_ARRAY,           //批量应用
    NEWS_TIEM_TYPE_OTHER_NEWS,          //全网新闻
    NEWS_TIEM_TYPE_INDIVIDUATION,       //个性化
    NEWS_ITEM_TYPE_SUBSCRIBE_NEWS,      //订阅刊物新闻 (自定义非服务器设置)
    NEWS_ITEM_TYPE_SMART_FINANCE,       //智能报盘
    NEWS_ITEM_TYPE_NEWS_VIDEO,               //新闻视频
    NEWS_ITEM_TYPE_NEWS_FUNNYTEXT,               //段子
    NEWS_ITEM_TYPE_NEWS_BOOK,               //首页流小说
    NEWS_ITEM_TYPE_NEWS_BOOKSHELF,          //小说书架
} SNRollingNewsItemType;

typedef enum {
    NewsFromRecommend,                  //频道推荐
    NewsFromChannel,                    //频道新闻
    NewsFromSearch,                     //搜索
    NewsFromArticleRecommend,           //正文推荐
    NewsFromChannelSubscribe,           //频道刊物    
}SNRollingNewsExpressFromType;

typedef enum {
    SNRollingNewsCellTypeDefault,                      //一般带图片cell
    SNRollingNewsCellTypeTitle,                        //只要标题cell
    SNRollingNewsCellTypeAbstrac,                      //标题带摘要cell
    SNRollingNewsCellTypePhotos,                       //组图cell
    SNRollingNewsCellTypeWeather,                      //天气cell
    SNRollingNewsCellTypeFocus,                        //焦点图cell
    SNRollingNewsCellTypePicture,                      //大图新闻样式cell
    SNRollingNewsCellTypeFocusWeather,                 //焦点图带天气cell
    SNRollingNewsCellTypeSubscribe,                    //刊物cell
    SNRollingNewsCellTypeApp,                          //app的cell
    SNRollingNewsCellTypeVideo,                        //视频广告的cell
    SNRollingNewsCellTypeMatch,                        //世界杯比赛的cell
    SNRollingNewsCellTypeFinance,                      //财经股票的cell
    SNRollingNewsCellTypeCommon,                       //通用模版（例如:彩票）
    SNRollingNewsCellTypeAdDefault,                    //频道广告(图文)
    SNRollingNewsCellTypeAdPhotos,                     //频道广告（组图）
    SNRollingNewsCellTypeAdPicture,                    //频道广告(大图)
    SNRollingNewsCellTypeAdBanner,                     //广告banner模板
    SNRollingNewsCellTypeMySubscribe,                  //我的订阅
    SNRollingNewsCellTypeAppArray,                     //批量应用
    SNRollingNewsCellTypeIndividuation,                //个性化模版
    SNRollingNewsCellTypeGroupNews,                    //专题展开模版
    SNRollingNewsCellTypeLoadMore,                     //频道流加载更多模版
    SNRollingNewsCellTypeFocusAd,                      //焦点图广告
    SNRollingNewsCellTypeAppAd,                        //应用下载广告
    SNRollingNewsCellTypeAdMixpicDownload,             //频道广告（组图app下载）
    SNRollingNewsCellTypeAdBigpicDownload,             //频道广告（大图app下载）
    SNRollingNewsCellTypeAdSmallpicDownload,           //频道广告（图文app下载）
    SNRollingNewsCellTypeAdVideoDownload,              //频道广告（视频app下载）
    SNRollingNewsCellTypeAdMixpicPhone,                //频道广告（组图打电话模版）
    SNRollingNewsCellTypeAdBigpicPhone,                 //频道广告（大图打电话模版）
    SNRollingNewsCellTypeFocusLocal,                   //本地频道焦点图
    SNRollingNewsCellTypeFocusHouse,                   //房产频道焦点图
    SNRollingNewsCellTypeAdStock,                      //添加自选股
    SNRollingNewsCellTypeChangeCity,                   //切换城市
    SNRollingNewsCellTypeMoreFoucs,                     //多个焦点图轮播
    SNRollingNewsCellTypeCityScanAndTickets,         //切换城市  扫一扫  优惠券
    SNRollingNewsCellTypeRedPacket,                     //红包模版
    SNRollingNewsCellTypeRedPacketTip,                  //红包模版
    SNRollingNewsCellTypeCoupons,                       //优惠券模版
    SNRollingNewsCellTypeFunnyText,                      //段子模版
    SNRollingNewsCellTypeNewsVideo,                        //新闻视频的cell
    SNRollingNewsCellTypeSohuLive,                      //千帆直播Cell
    SNRollingNewsCellTypeAutoVideoBigImageType,                        //视频大图item
    SNRollingNewsCellTypeAutoVideoMidImageType,                        //视频中图item
    SNRollingNewsCellTypeRecomendItemTagType,           //推荐流标签类Item
    SNRollingNewsCellTypeBook,                          //小说Cell模板
    SNRollingNewsCellTypeBookShelf,                     //书架Cell模板
    SNRollingNewsCellTypeBookLabel,                     //书籍标签模板
    SNRollingNewsCellTypeBookBanner,                    //书籍Banner模板
    SNRollingNewsCellTypeSohuFeedPhotos,                //狐友Feed组图
    SNRollingNewsCellTypeSohuFeedBigPic,                //狐友Feed大图 狐友Feed视频
    SNRollingNewsCellAdIndividuation,                   //多图广告模板
    SNRollingNewsCellTypeTrainCard,                     //火车卡片模版
    
    SNRollingNewsCellTypeTopic,                        //（自定义）首页第一页提示
    SNRollingNewsCellTypeRefresh,                       //(自定义)流式频道“上次看到这里，点击刷新”
    SNRollingNewsCellTypeFullScreenFocus,               //（自定义）全屏焦点图
    SNRollingNewsCellTypeHistoryLine                   //（自定义）频道流历史提示CEll
}SNRollingNewsCellType;

@class SNCommonNewsDatasource;
@interface SNRollingNewsTableItem : TTTableSubtitleItem
{
    BOOL _isFocus;                                      //是否为焦点新闻
    BOOL _isRecommend;                                  //是否为推荐
    BOOL _isSearchNews;                                 //是否为搜索新闻 （搜索界面用到）
    BOOL _isLoading;                                    //订阅loading （搜索界面用到）
    BOOL _photoListNewsRecommend;                       //组图新闻正文推荐
    BOOL _isSubscribeAd;                                //订阅焦点广告
    BOOL _isExpand;                                     //段子是否为展开状态
    BOOL _hasHotcomment;                                //段子是否有热门评论
    BOOL _jokeHasImage;                                 //段子是否有图片
    BOOL _jokeDidRead;                                  //段子已读
    BOOL _jokeDidOpt;                                   //段子已点赞
    BOOL _jokeOnlyShortText;                                   //段子48字以内纯文本
    
    NSMutableArray *newsList;
    NSMutableArray *photoList;
    NSMutableArray *specailList;
    NSMutableArray *liveList;
    NSMutableArray *allList;
    NSMutableArray *focusList;
    
    SNRollingNews *news;
    SNRollingNewsItemType type;                         //新闻类型newsType
    SNRollingNewsModel *_newsModel;
    SNRollingNewsTableController    *__weak controller;
    SNCommonNewsDatasource *__weak dataSource;
    SNRollingNewsExpressFromType expressFrom;           //曝光统计来源
    SNRollingNewsCellType cellType;                     //模版类型
    SCSubscribeAdObject *subscribeAdObject;             //订阅流广告
    
    int titleHeight;                                    //标题高度
    int abstractHeight;                                 //摘要高度
    int cellHeight;                                     //Cell高度
    int titlelineCnt;                                   //标题行数
    
    NSString *subscribeCount;                           //刊物总数 （搜索界面用到）
    NSString *keyWord;                                  //搜索关键词 （搜索界面用到）
    NSMutableAttributedString *titleString;             //标题
    NSMutableAttributedString *abstractString;          //摘要
}

@property(nonatomic, assign)BOOL isFocus;
@property(nonatomic, assign)BOOL isRecommend;
@property(nonatomic, assign)BOOL isSearchNews;
@property(nonatomic, assign)BOOL isLoading;
@property(nonatomic, assign)BOOL photoListNewsRecommend;
@property(nonatomic, assign)BOOL isSubscribeAd;
@property(nonatomic, assign)BOOL isExpand;
@property(nonatomic, assign)BOOL hasHotcomment;
@property(nonatomic, assign)BOOL jokeHasImage;
@property(nonatomic, assign)BOOL jokeDidRead;
@property(nonatomic, assign)BOOL jokeDidOpt;
@property(nonatomic, assign)BOOL jokeOnlyShortText;

@property(nonatomic, assign)int titleHeight;
@property(nonatomic, assign)int abstractHeight;
@property(nonatomic, assign)int cellHeight;
@property (nonatomic, assign) int lastCellHeight;       //段子展开前的高度 （好奇葩的需求）
@property (nonatomic, assign) int titlelineCnt;

@property(nonatomic, assign)SNRollingNewsItemType type;
@property(nonatomic, assign)SNRollingNewsExpressFromType expressFrom;
@property(nonatomic, assign)SNRollingNewsCellType cellType;

@property(nonatomic, strong)SNRollingNewsModel *newsModel;
@property(nonatomic, strong)SNRollingNews *news;
@property(nonatomic, weak)SNRollingNewsTableController *controller;
@property(nonatomic, weak)SNCommonNewsDatasource* dataSource;
@property(nonatomic, strong)SCSubscribeAdObject *subscribeAdObject;

@property(nonatomic, strong)NSMutableArray *newsList;
@property(nonatomic, strong)NSMutableArray *photoList;
@property(nonatomic, strong)NSMutableArray *specailList;
@property(nonatomic, strong)NSMutableArray *liveList;
@property(nonatomic, strong)NSMutableArray *allList;
@property(nonatomic, strong)NSMutableArray *focusList;

@property(nonatomic, strong)NSMutableAttributedString *titleString;
@property(nonatomic, strong)NSMutableAttributedString *abstractString;

@property(nonatomic, strong)NSString *subscribeCount;
@property(nonatomic, strong)NSString *keyWord;


- (BOOL)hasImage;
- (BOOL)hasGroupImages;
- (BOOL)hasNewsTypeIcon;
- (BOOL)hasVideo;
- (BOOL)hasVote;
- (BOOL)hasComments;
- (BOOL)hasFavorites;
- (BOOL)hasReport;
- (BOOL)isFlashNews;
- (BOOL)isH5Link;
- (BOOL)isChannelLink;
- (BOOL)hiddenMoreButton;
- (BOOL)hiddenCellLine;//5.9.4 wangchuanwen add
- (BOOL)checkInstallApp;
- (NSInteger)getGroupImagesCount;
- (NSString *)getExposureFrom;
- (SNCCPVPage)getCurrentPage;
- (SNTimelineContentType)getShareContentType;
- (NSString *)getShareContentId;
- (NSString *)getShareLogoType;
- (int)getShareSourceType;
- (void)setItemNewsType;
- (void)setItemCellTypeWithTemplate;
- (NSString *)getNewsTypeString;
- (NSString *)getNewsTypeTextString;

@end
