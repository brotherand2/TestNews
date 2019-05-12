//
//  CacheObjects.h
//  CacheMgr
//
//  Created by 李 雪 on 11-6-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//订阅
#import "SNURLRequest.h"
#import "SNDownloadConfig.h"
#import "TBXML.h"

typedef enum
{
	CacheMgrURLRequestTypeNewsImage,
	CacheMgrURLRequestTypeNewspaperZip,
	CacheMgrURLRequestTypeGalleryPhoto,
    CacheMgrURLRequestTypeRecommendGallery
}CacheMgrURLRequestType;
@interface SubscribeItem : NSObject <NSCopying>
{
	int ID;
	NSString *pubTypeName;
	NSString *subId;
	NSString *subType;
	NSString *pubId;
	NSString *pubName;
	NSString *pubIcon;
	NSString *pubType;
	NSString *pubPush;
	NSString *termId;
    NSString *termTime;
	NSString *lastTermLink;
	NSString *orderIndex;
	NSString *iconPath;
	NSString *status;
	NSString *noReadCount;
	NSString *noReadTermIds;
	NSString *defaultSub;
    NSString *downloaded;
}

- (NSString *)toString;

@property(nonatomic,assign) int ID;
@property(nonatomic,copy) NSString *pubTypeName;
@property(nonatomic,copy) NSString *subId;
@property(nonatomic,copy) NSString *subType;
@property(nonatomic,copy) NSString *pubId;
@property(nonatomic,copy) NSString *pubName;
@property(nonatomic,copy) NSString *pubIcon;
@property(nonatomic,copy) NSString *pubType;
@property(nonatomic,copy) NSString *pubPush;
@property(nonatomic,copy) NSString *termId;
@property(nonatomic,copy) NSString *termTime;
@property(nonatomic,copy) NSString *lastTermLink;
@property(nonatomic,copy) NSString *orderIndex;
@property(nonatomic,copy) NSString *iconPath;
@property(nonatomic,copy) NSString *status;
@property(nonatomic,copy) NSString *noReadCount;
@property(nonatomic,copy) NSString *noReadTermIds;
@property(nonatomic,copy) NSString *defaultSub;
@property(nonatomic,copy) NSString *downloaded;

@end

@interface SubscribeHomeImageItem : NSObject <NSCopying>
{
	int ID;
	NSString	*subId;
	NSString	*pubId;
	NSString	*termId;
	NSString	*src;
	NSString	*link;
	NSString	*date;
	NSString	*termName;
	NSString	*pubName;
	NSString	*termType;
	NSString	*title;
	NSString	*path;
	NSString	*noReadCount;
	NSString	*noReadTermIds;
	NSString	*orderIndex;
}

@property(nonatomic,assign)int ID;
@property(nonatomic,copy)NSString	*subId;
@property(nonatomic,copy)NSString	*pubId;
@property(nonatomic,copy)NSString	*termId;
@property(nonatomic,copy)NSString	*src;
@property(nonatomic,copy)NSString	*link;
@property(nonatomic,copy)NSString	*date;
@property(nonatomic,copy)NSString	*termName;
@property(nonatomic,copy)NSString	*pubName;
@property(nonatomic,copy)NSString	*termType;
@property(nonatomic,copy)NSString	*title;
@property(nonatomic,copy)NSString	*path;
@property(nonatomic,copy)NSString	*noReadCount;
@property(nonatomic,copy)NSString	*noReadTermIds;
@property(nonatomic,copy)NSString	*orderIndex;

@end

//报纸
@interface NewspaperItem : NSObject
{
	int ID;
	NSString *subId;
	NSString *pubId;
	NSString *termId;
	NSString *termName;
    NSString *pushName;
	NSString *termTitle;
	NSString *termLink;
	NSString *termZip;
	NSString *termTime;
	NSString *newspaperPath;
	NSString *readFlag;
	NSString *downloadFlag;
    NSString *downloadTime;
    NSString *normalLogo;
    NSString *nightLogo;
    
    //v3.4
    NSString *publishTime;
    
    //Transient property
    BOOL isEditMode;
    //Transient property
    BOOL isSelected;
}

@property(nonatomic,assign) int ID;
@property(nonatomic,copy) NSString *subId;
@property(nonatomic,copy) NSString *pubId;
@property(nonatomic,copy) NSString *termId;
@property(nonatomic,copy) NSString *termName;
@property(nonatomic,copy) NSString *pushName;
@property(nonatomic,copy) NSString *termTitle;
@property(nonatomic,copy) NSString *termLink;
@property(nonatomic,copy) NSString *termZip;
@property(nonatomic,copy) NSString *termTime;

@property(nonatomic,copy) NSString *newspaperPath;
@property(nonatomic,copy) NSString *readFlag;
@property(nonatomic,copy) NSString *downloadFlag;
@property(nonatomic,copy) NSString *downloadTime;
@property(nonatomic,copy) NSString *normalLogo;
@property(nonatomic,copy) NSString *nightLogo;

@property(nonatomic,copy) NSString *publishTime;

//Transient property
@property(nonatomic,assign) BOOL isEditMode;
//Transient property
@property(nonatomic,assign) BOOL isSelected;

// 由于库中存储的是绝对路径，升级后绝对路径发生变化，此处根据相对路径取得当前版本的绝对路径
- (NSString *)realNewspaperPath;

@end

@interface NewsArticleItem : NSObject
{
	int ID;
	NSString *channelId;
//	NSString *pubId;
	NSString *newsId;
	NSString *termId;
	NSString *type;
	NSString *title;
    NSString *newsMark;
    NSString *originFrom;
    NSString *originTitle;
	NSString *time;
    NSString *updateTime;
	NSString *source;
	NSString *commentNum;
	NSString *digNum;
	NSString *content;
	NSString *link;
	NSString *readFlag;
	NSString *nextName;
	NSString *nextId;
    NSString *nextNewsLink;
    NSString *nextNewsLink2;
	NSString *preName;
	NSString *preId;
	NSString *shareContent;
    NSArray *shareImages;
    NSArray *thumbnailImages;
    NSInteger createAt;
    NSString *logoUrl;
    NSString *linkUrl;
}

@property(nonatomic,assign)int ID;
@property(nonatomic,copy) NSString *channelId;
//@property(nonatomic,copy) NSString *pubId;
@property(nonatomic,copy) NSString *newsId;
@property(nonatomic,copy) NSString *termId;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *newsMark;
@property(nonatomic,copy) NSString *originFrom;
@property(nonatomic,copy) NSString *originTitle;
@property(nonatomic,copy) NSString *time;
@property(nonatomic,copy) NSString *updateTime;
@property(nonatomic,copy) NSString *from;
@property(nonatomic,copy) NSString *commentNum;
@property(nonatomic,copy) NSString *digNum;
@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *link;
@property(nonatomic,copy) NSString *readFlag;
@property(nonatomic,copy) NSString *nextName;
@property(nonatomic,copy) NSString *nextId;
@property(nonatomic,copy) NSString *nextNewsLink;
@property(nonatomic,copy) NSString *nextNewsLink2;
@property(nonatomic,copy) NSString *preName;
@property(nonatomic,copy) NSString *preId;
@property(nonatomic,copy) NSString *shareContent;
@property(nonatomic,copy) NSString *action;
@property(nonatomic,copy) NSString *isPublished;
@property(nonatomic,copy) NSString *editNewsLink;
@property(nonatomic,strong) NSArray *shareImages;
@property(nonatomic,strong) NSArray *thumbnailImages;
@property(nonatomic,assign)NSInteger createAt;
@property(nonatomic,copy) NSString *subId; // 所属刊物
@property(nonatomic,copy) NSString *operators;
@property(nonatomic,copy)NSString *cmtStatus; //文章是否评论状态
@property(nonatomic,copy)NSString *cmtHint;
@property(nonatomic,assign)BOOL cmtRead;
@property(nonatomic,copy)NSString *logoUrl;
@property(nonatomic,copy)NSString *linkUrl;
@property(nonatomic,assign)BOOL favour;
@property(nonatomic, assign)NSInteger newsType;
@property(nonatomic, strong)NSString *h5link;
@property(nonatomic, assign)NSInteger openType;
@property(nonatomic, strong)NSString *favIcon;
@property(nonatomic, strong)NSString *mediaName;
@property(nonatomic, strong)NSString *mediaLink;
@property(nonatomic, strong)NSString *optimizeRead;
@property(nonatomic, strong)NSString *tagChannelsStr;
@property(nonatomic, strong)NSArray *tagChannels;
@property(nonatomic, strong)NSString *stocksStr;
@property(nonatomic, strong)NSArray *stocks;
@end

@interface NewsImageItem : NSObject
{
	int ID;
	NSString *termId;
	NSString *newsId;
	NSString *imageId;
	NSString *type;//"share",nil
	NSString *time;
	NSString *link;
	NSString *url;
	NSString *path;
    NSString *title;
    NSInteger width;
    NSInteger height;
    NSInteger createAt;
    
    //transient property
    CGRect imgRect;                 // 在webView中的frame
}

@property(nonatomic,assign) int ID;
@property(nonatomic,copy) NSString *termId;
@property(nonatomic,copy) NSString *newsId;
@property(nonatomic,copy) NSString *imageId;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,copy) NSString *time;
@property(nonatomic,copy) NSString *link;
@property(nonatomic,copy) NSString *url;
@property(nonatomic,copy) NSString *path;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,assign) NSInteger width;
@property(nonatomic,assign) NSInteger height;
@property(nonatomic,assign) NSInteger createAt;
@property(nonatomic,assign) CGRect imgRect;
@end

@interface NewsTagChannelItem : NSObject
{
    NSString *name;
    NSString *link;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *link;

@end

@interface NewsStockItem : NSObject
{
    NSString *name;
    NSString *link;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *link;

@end


@interface NewsChannelItem : NSObject
{
	int ID;
    NSString *channelCategoryName;
    NSString *channelCategoryID;
    NSString *channelIconFlag;
	NSString *name;
	NSString *channelID;
    NSString *channelIcon;
    NSString *channelType;              // 频道类型：0：新闻类别。1：直播频道。2：视频频道
    NSString *channelPosition;
    NSString *channelTop;
    NSString *channelTopTime;
    NSString *isChannelSubed;           // 频道是否已选
    NSString *lastModify;
    NSString *isSelected;               //频道在下载设置里是否为已选
    NSString *currPosition;             //本地新闻位置、在列表还是在tab中
    NSString *localType;                //是否为本地新闻
    NSString *isRecom;
    NSString *tips;
    NSString *link;
    int tipsInterval;
    NSString *serverVersion;            //接口版本号
    NSString *channelShowType;
    int isMixStream;
    //Transient properties
    SNDownloadStatus _downloadStatus;
}

@property(nonatomic,assign) int ID;
@property(nonatomic,copy) NSString *channelCategoryName;
@property(nonatomic,copy) NSString *channelCategoryID;
@property(nonatomic,copy) NSString *channelIconFlag;
@property(nonatomic,copy) NSString *channelName;
@property(nonatomic,copy) NSString *channelId;
@property(nonatomic,copy) NSString *channelIcon;
@property(nonatomic,copy) NSString *channelType;
@property(nonatomic,copy) NSString *channelPosition;
@property(nonatomic,copy) NSString *channelTop;
@property(nonatomic,copy) NSString *channelTopTime;
@property(nonatomic,copy) NSString *isChannelSubed;
@property(nonatomic,copy) NSString *lastModify;
@property(nonatomic,copy) NSString *isSelected;
@property(nonatomic,assign)SNDownloadStatus downloadStatus;
@property(nonatomic,copy) NSString *subId;
@property(nonatomic,copy) NSString *currPosition;
@property(nonatomic,copy) NSString *localType;
@property(nonatomic,copy) NSString *isRecom;
@property(nonatomic,copy) NSString *tips;
@property(nonatomic,copy) NSString *link;
@property(nonatomic,assign) int tipsInterval;
@property(nonatomic,copy) NSString *gbcode;
@property(nonatomic, copy) NSString *channelStatusDelete;//删除频道字段
@property(nonatomic, copy) NSString *serverVersion;
@property (nonatomic, copy) NSString *channelShowType;
@property(nonatomic, assign) int isMixStream;

-(BOOL)isChanged:(NewsChannelItem *)item;

@end

@interface WeiboHotChannelItem : NewsChannelItem

- (BOOL)isLaterThan:(WeiboHotChannelItem *)other;

@end


@interface GalleryItem : NSObject
{
	int ID;
	NSString	*termId;
    NSString	*newsId;
    NSString	*gId;
	NSString	*title;
    NSString    *newsMark;
    NSString    *originFrom;
	NSString	*time;
    NSString    *updateTime;
	NSString	*type;
	NSString	*commentNum;
	NSString	*digNum;
	NSString	*shareContent;
	NSArray		*gallerySubItems;
    
    //add 2011-12-21
    NSString    *nextId;
    NSString    *nextNewsLink;
    NSString    *nextNewsLink2;
    NSString    *nextName;
    NSString    *preId;
    NSString    *preName;
    NSArray     *moreRecommends;
    
    //add 2011-12-29
    NSString    *source;
    
    //add 2012-03-30
    NSString    *isLike;
    NSString    *likeCount;
    NSString    *stpAudCmtRsn;          //禁止语音评论
    NSInteger   createAt;
}

@property(nonatomic,assign)int ID;
@property(nonatomic,copy)NSString *termId;
@property(nonatomic,copy)NSString *newsId;
@property(nonatomic,copy)NSString *gId;
@property(nonatomic,copy)NSString *channelId;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *newsMark;
@property(nonatomic,copy)NSString *originFrom;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *updateTime;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *commentNum;
@property(nonatomic,copy)NSString *digNum;
@property(nonatomic,copy)NSString *shareContent;
@property(nonatomic,strong)NSArray *gallerySubItems;

@property(nonatomic,copy)NSString *nextId;
@property(nonatomic,copy)NSString *nextNewsLink;
@property(nonatomic,copy)NSString *nextNewsLink2;
@property(nonatomic,copy)NSString *nextName;
@property(nonatomic,copy)NSString *preId;
@property(nonatomic,copy)NSString *preName;
@property(nonatomic,strong)NSArray *moreRecommends;
@property(nonatomic,copy)NSString *from;
@property(nonatomic,copy)NSString *isLike;
@property(nonatomic,copy)NSString *likeCount;
@property(nonatomic,assign)NSInteger createAt;
@property(nonatomic,copy)NSString *subId;
@property(nonatomic,copy)NSString *stpAudCmtRsn;
@property(nonatomic,copy)NSString *cmtStatus;
@property(nonatomic,copy)NSString *cmtHint;
@property(nonatomic,assign)BOOL cmtRead;
@property(nonatomic,copy)NSString *favIcon;
@property(nonatomic,copy)NSString *h5link;
@property(nonatomic,copy)NSString *mediaName;
@property(nonatomic,copy)NSString *mediaLink;
@end

//相关组图
@interface RecommendGallery :  NSObject  {
    int ID;
    NSString    *rTermId;
    NSString    *rNewsId;
	NSString	*termId;
	NSString	*newsId;//gid
	NSString	*title;
	NSString	*time;
	NSString	*type;
    NSString    *iconUrl;
    NSString    *iconPath;
    NSInteger   createAt;
}

@property(nonatomic,assign)int ID;
@property(nonatomic,copy)NSString *releatedTermId;
@property(nonatomic,copy)NSString *releatedNewsId;
@property(nonatomic,copy)NSString *termId;
@property(nonatomic,copy)NSString *newsId;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *iconUrl;
@property(nonatomic,copy)NSString *iconPath;
@property(nonatomic,assign)NSInteger createAt;
@end


@interface PhotoItem : NSObject
{
	int ID;
	NSString *termId;
	NSString *newsId;
	NSString *abstract;
	NSString *ptitle;
	NSString *shareLink;
	NSString *url;
	NSString *path;
	NSString *time;
    NSInteger createAt;
}

@property(nonatomic,assign) int ID;
@property(nonatomic,copy) NSString *termId;
@property(nonatomic,copy) NSString *newsId;
@property(nonatomic,copy) NSString *abstract;
@property(nonatomic,copy) NSString *ptitle;
@property(nonatomic,copy) NSString *shareLink;
@property(nonatomic,copy) NSString *url;
@property(nonatomic,copy) NSString *path;
@property(nonatomic,copy) NSString *time;
@property(nonatomic,assign) NSInteger createAt;
@property(nonatomic,assign) float height;
@property(nonatomic,assign) float width;

@end

@interface RollingNewsListItem : NSObject
{
	int		 ID;
	NSString *channelId;
	NSString *pubId;
	NSString *pubName;
	NSString *newsId;
	NSString *type;
	NSString *title;
	NSString *description;
	NSString *time;
	NSString *commentNum;
	NSString *digNum;
	NSString *listPic;
	NSString *link;
	NSString *readFlag;
	NSString *downloadFlag;
    NSString *from;
    NSString *listPicsNumber;
    NSString *timelineIndex;
    NSString *hasVideo;
    NSString *updateTime;
    NSString *expired;
    NSInteger createAt;
    NSString *recomIconDay;
    NSString *recomIconNight;
    NSString *isWeather;    //天气标识
    NSString *city;         //天气城市
    NSString *tempHigh;     //最高气温
    NSString *tempLow;      //最低气温
    NSString *weatherIoc;   //天气图标
    NSString *weather;      //天气情况
    NSString *weak;
    NSString *liveTemperature; //当前温度
    NSString *pm25;
    NSString *quality;
    NSString *wind;         //风
    NSString *gbcode;       //城市国标码
    NSString *date;         //天气日期
    NSString *localIoc;     //天气图标(local)
    NSString *isRecom;
    NSString *recomType;
    NSString *liveStatus;
    NSString *local;
    NSString *thirdPartUrl;
    NSString *templateId;
    NSString *templateType;
    NSString *dataString;
    NSString *playTime;
    NSString *liveType;
    NSString *token;
    NSString *isFlash;
    NSString *position;
    NSString *isHasSponsorships;
    NSString *iconText;
    NSString *sponsorships;     //冠名信息
    NSString *cursor;
    NSString * subId;
    BOOL isTopNews;         //置顶新闻
    BOOL isLatest;          //最新新闻
    
    //红包信息
    NSString *bgPic;                //背景图片
    NSString *sponsoredIcon;        //冠名图片
    NSString *redPacketTitle;       //红包信息
    NSString *redPacketID;          //红包ID
    
    NSString *tvPlayTime;
    NSString *tvPlayNum;
    NSString *playVid;
    NSString *tvUrl;
    NSString *sourceName;
    int siteValue;
    
    NSString *recomInfo;//推荐流上报参数
}

@property(nonatomic,assign) int ID;
@property(nonatomic,assign) NSInteger createAt;

@property (nonatomic,copy) NSString * subId;
@property(nonatomic,copy) NSString *channelId;
@property(nonatomic,copy) NSString *pubId;
@property(nonatomic,copy) NSString *pubName;
@property(nonatomic,copy) NSString *newsId;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *description;
@property(nonatomic,copy) NSString *time;
@property(nonatomic,copy) NSString *commentNum;
@property(nonatomic,copy) NSString *digNum;
@property(nonatomic,copy) NSString *listPic;
@property(nonatomic,copy) NSString *link;
@property(nonatomic,copy) NSString *readFlag;
@property(nonatomic,copy) NSString *downloadFlag;
@property(nonatomic,copy) NSString *form;
@property(nonatomic,copy) NSString *listPicsNumber;
@property(nonatomic,copy) NSString *timelineIndex;
@property(nonatomic,copy) NSString *hasVideo;
@property(nonatomic,copy) NSString *hasVote;
@property(nonatomic,copy) NSString *hasAudio;
@property(nonatomic,copy) NSString *updateTime;
@property(nonatomic,copy) NSString *expired;
@property(nonatomic,copy) NSString *recomIconDay;
@property(nonatomic,copy) NSString *recomIconNight;
@property(nonatomic,copy) NSString *media;
@property(nonatomic,copy) NSString *isWeather;
@property(nonatomic,copy) NSString *city;
@property(nonatomic,copy) NSString *tempHigh;
@property(nonatomic,copy) NSString *tempLow;
@property(nonatomic,copy) NSString *weatherIoc;
@property(nonatomic,copy) NSString *weather;
@property(nonatomic,copy) NSString *weak;
@property(nonatomic,copy) NSString *liveTemperature;
@property(nonatomic,copy) NSString *pm25;
@property(nonatomic,copy) NSString *quality;
@property(nonatomic,copy) NSString *wind;
@property(nonatomic,copy) NSString *gbcode;
@property(nonatomic,copy) NSString *date;
@property(nonatomic,copy) NSString *localIoc;
@property(nonatomic,copy) NSString *isRecom;
@property(nonatomic,copy) NSString *recomType;
@property(nonatomic,copy) NSString *liveStatus;
@property(nonatomic,copy) NSString *local;
@property(nonatomic,copy) NSString *thirdPartUrl;
@property(nonatomic,copy) NSString *templateId;
@property(nonatomic,copy) NSString *templateType;
@property(nonatomic,copy) NSString *dataString;
@property(nonatomic,copy) NSString *playTime;
@property(nonatomic,copy) NSString *liveType;
@property(nonatomic,copy) NSString *token;
@property(nonatomic,copy) NSString *isFlash;
@property(nonatomic,copy) NSString *position;
@property(nonatomic,copy) NSString *isHasSponsorships;
@property(nonatomic,copy) NSString *iconText;
@property(nonatomic,copy) NSString *newsTypeText;
@property(nonatomic,copy) NSString *sponsorships;
@property(nonatomic,copy) NSString *cursor;
@property(nonatomic,assign)SNRollingNewsStatsType newsStatsType;
@property(nonatomic, assign)BOOL isTopNews;
@property(nonatomic, assign)BOOL isLatest;

//小说
@property(nonatomic, copy)NSString *novelAuthor;
@property(nonatomic, copy)NSString *novelBookId;
@property(nonatomic, copy)NSString *novelCategory;

@property(nonatomic,copy) NSString *recomReasons;
@property(nonatomic,copy) NSString *recomTime;
@property(nonatomic,copy) NSString *blueTitle;

//统计数据
@property(nonatomic, copy)NSString *adType;
@property(nonatomic, copy)NSString *scope;
@property(nonatomic, assign)int adAbPosition;         //广告绝对位置
@property(nonatomic, assign)int adPosition;           //广告相对位置
@property(nonatomic, assign)int refreshCount;         //刷新次数
@property(nonatomic, assign)int loadMoreCount;        //加载更多次数
@property(nonatomic, assign)int morePageNum;          //加载编辑新闻页数
@property(nonatomic, assign)int appChannel;
@property(nonatomic, assign)int newsChannel;

//Transient properties
@property(nonatomic, assign) BOOL isDownloadFinished;

@property(nonatomic) int adReportState;

@property(nonatomic, copy) NSString *recomInfo;
@property(nonatomic, copy) NSString *trainCardId;

//红包信息
@property(nonatomic, copy) NSString *bgPic;                //背景图片
@property(nonatomic, copy) NSString *sponsoredIcon;        //冠名图片
@property(nonatomic, copy) NSString *redPacketTitle;       //红包信息
@property(nonatomic, copy) NSString *redPacketID;           //红包ID

@property(nonatomic, copy) NSString *tvPlayTime;
@property(nonatomic, copy) NSString *tvPlayNum;
@property(nonatomic, copy) NSString *playVid;
@property(nonatomic, copy) NSString *tvUrl;
@property(nonatomic, copy) NSString *sourceName;
@property(nonatomic, assign)int siteValue;

@end

@interface NewsCommentItem : NSObject
{
	int		 ID;
	NSString *newsId;
	NSString *commentId;
	NSString *type;
	NSString *ctime;
	NSString *author;
    NSString *passport;
    NSString *linkStyle;
    NSString *spaceLink;
    NSString *pid;
	NSString *content;
    BOOL     hadDing;
    NSString *digNum;
    NSString *imagePath;
    NSString *authorImage;
    NSString *audioPath;
    NSString *audioDuration;
    NSString *userComtId;
}

@property(nonatomic,assign) int ID;
@property(nonatomic,copy) NSString *newsId;
@property(nonatomic,copy) NSString *commentId;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,copy) NSString *ctime;
@property(nonatomic,copy) NSString *author;
@property(nonatomic,copy) NSString *passport;
@property(nonatomic, copy)NSString *linkStyle;
@property(nonatomic, copy)NSString *spaceLink;
@property(nonatomic, copy)NSString *pid;
@property(nonatomic,copy) NSString *content;
@property(nonatomic,readwrite)BOOL hadDing;
@property(nonatomic,copy) NSString *digNum;
@property(nonatomic,copy) NSString *imagePath;
@property(nonatomic,copy) NSString *authorImage;
@property(nonatomic,strong) NSString *audioPath;
@property(nonatomic,strong) NSString *audioDuration;
@property(nonatomic,strong) NSString *userComtId;
@property(nonatomic,copy) NSString *channelId;

@end


@interface NickNameObj : NSObject
{
    int         ID;
    NSString    *nickName;
}
@property(nonatomic,assign) int ID;
@property(nonatomic,copy) NSString *nickName;
-(id)initWithNickName:(NSString *)nick;

@end

#import "SNDatabase.h"
@protocol SNDatabaseRequestDelegate;

@interface CacheMgrURLRequest : SNURLRequest
{
	CacheMgrURLRequestType nRequestType;
	int nRetryCount;
	id<SNDatabaseRequestDelegate> __weak _urlRequestDelegate;
	NSString *url;
	NSString *path;
}

@property(nonatomic,assign)CacheMgrURLRequestType nRequestType;
@property(nonatomic,assign)int nRetryCount;
@property(nonatomic,weak)id<SNDatabaseRequestDelegate> urlRequestDelegate;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) NSString *path;

@end


//新闻zip包下载对象
@interface NewspaperZipRequestItem : CacheMgrURLRequest
{
	NewspaperItem *newspaperInfo;
}

@property(nonatomic,strong)NewspaperItem *newspaperInfo;

@end

//图片下载对象
@interface PhotoRequestItem : CacheMgrURLRequest
{
	PhotoItem *photoInfo;
}

@property(nonatomic,strong)PhotoItem *photoInfo;

@end

//推荐组图下载对象
@interface RecommendGalleryRequestItem : CacheMgrURLRequest
{
	RecommendGallery *recommendGalleryInfo;
}

@property(nonatomic,strong)RecommendGallery *recommendGalleryInfo;

@end

@interface GroupPhotoItem : NSObject {
    NSInteger ID;
    NSString *newsId;
    NSString *title;
    NSString *time;
    NSString *commentNum;
    NSString *favoriteNum;
    NSString *imageNum;
    NSMutableArray *images;
    NSString *type;
    NSString *typeId;
    NSString *timelineIndex;
    NSString *sublink;
    int readFlag;
    int createAt;
}
@property(nonatomic,assign)NSInteger ID;
@property(nonatomic,copy)NSString *newsId;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *typeId;
@property(nonatomic,copy)NSString *commentNum;
@property(nonatomic,copy)NSString *favoriteNum;
@property(nonatomic,copy)NSString *imageNum;
@property(nonatomic,copy)NSString *timelineIndex;
@property(nonatomic,copy)NSString *sublink;
@property(nonatomic,readwrite)int readFlag;
@property(nonatomic,strong)NSMutableArray *images;
@property(nonatomic,assign)int createAt;

@end


@interface SNTagItem : NSObject {
    NSInteger ID;
    NSString *tagId;
    NSString *tagName;
    NSString *tagValue;
}
@property(nonatomic,assign)NSInteger ID;
@property(nonatomic,copy)NSString *tagId;
@property(nonatomic,copy)NSString *tagName;
@property(nonatomic,copy)NSString *tagValue;

@end

@interface CategoryItem : NSObject {
    NSInteger ID;
    NSString *categoryId;
    NSString *name;
    NSString *icon;
    NSString *position;
    NSString *top;
    NSString *topTime;
    NSString *lastModify;
}
@property(nonatomic,assign) NSInteger ID;
@property(nonatomic,copy)NSString *categoryID;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *icon;
@property(nonatomic,copy)NSString *position;
@property(nonatomic,copy)NSString *top;
@property(nonatomic,copy)NSString *topTime;
@property(nonatomic,copy)NSString *isSubed;
@property(nonatomic,copy)NSString *lastModify;

- (void)setTopTimeBySeconds:(NSString *)_topTime;
- (void)setTopTime:(NSString *)_topTime formatter:(NSString *)format;


- (BOOL)isLaterThan:(CategoryItem *)other;
- (BOOL)isChanged:(CategoryItem *)item;


@end


//Home V3接口数据“我的订阅”和“所有订阅”的父类
@interface SubscribeHomePO : NSObject

@property(nonatomic, readwrite)int ID;
@property(nonatomic, copy)NSString *defaultSub;
@property(nonatomic, copy)NSString *subscribeTypeName;
@property(nonatomic, copy)NSString *subId;
@property(nonatomic, copy)NSString *subKind;//1表示报纸订阅，2表示RSS订阅；
@property(nonatomic, copy)NSString *subName;
@property(nonatomic, copy)NSString *subIcon;
@property(nonatomic, copy)NSString *subInfo;
@property(nonatomic, copy)NSString *pubIds;
@property(nonatomic, copy)NSString *termId;
@property(nonatomic, copy)NSString *lastTermLink;
@property(nonatomic, copy)NSString *myPush;
@property(nonatomic, copy)NSString *moreInfo;
@property(nonatomic, copy)NSString *unReadCount;

- (NSString *)toString;

@end


//Home V3接口数据“我的订阅”类
@interface SubscribeHomeMySubscribePO : SubscribeHomePO

@property(nonatomic, copy)NSString *orderIndex;//我的订阅项的顺序
@property(nonatomic, copy)NSString *status;//用于记录是否有新的一期
@property(nonatomic, copy)NSString *downloaded;//最新一期是否已被下载过
@property(nonatomic, copy)NSString *pushName;
//Transient property
@property(nonatomic, copy)NSString *termTime;
//Transient property
@property(nonatomic, assign)SNDownloadStatus downloadStatus;
//Transient property
@property(nonatomic, copy)NSString *tmpDownloadZipPath;
//Transient property
@property(nonatomic, copy)NSString *finalDownloadZipPath;
//Transient property
@property(nonatomic, copy)NSString *termName;
//Transient property
@property(nonatomic, copy)NSNumber *tmpProgress;
//Transient property
@property(nonatomic, assign)BOOL isCanceled;
@property(nonatomic, copy)NSString *isSelected;
//离线下载地址
@property(nonatomic, copy)NSString *zipUrl;

//以下两个方法是为了支持SNNewsPaperWebController，因为旧版接口数据有pubId和pubName两个避属性，但HomeV3接口的数据不一样；
- (NSString *)pubId;
- (NSString *)pubName;

@end

// subscribe center V3.2

/* SCSubscribeObject status字段  二进制各个位的说明
 *      0000000000000000000000000  00-刊物的三种状态显示
 */

typedef enum {
    SCSubObjStatusFlagSubStatus = 0,
    SCSubObjStatusXX = 2
}SCSubObjStatusFlag;

@interface SCSubscribeObject : NSObject
@property(nonatomic,assign)NSInteger ID;
@property(nonatomic, copy)NSString *defaultSub;
@property(nonatomic, copy)NSString *subId;
@property(nonatomic, copy)NSString *subName;
@property(nonatomic, copy)NSString *subIcon;
@property(nonatomic, copy)NSString *subInfo; // 刊物简介
@property(nonatomic, copy)NSString *moreInfo; // 刊物push时间介绍
@property(nonatomic, copy)NSString *pubIds;
@property(nonatomic, copy)NSString *termId;
@property(nonatomic, copy)NSString *lastTermLink;
@property(nonatomic, copy)NSString *isPush; // 是否打开推送
@property(nonatomic, copy)NSString *defaultPush;
@property(nonatomic, copy)NSString *publishTime;
@property(nonatomic, copy)NSString *unReadCount;  //刊物内容未读提醒
@property(nonatomic, copy)NSString *subPersonCount;
@property(nonatomic, copy)NSString *topNews;
@property(nonatomic, copy)NSString *topNews2;
@property(nonatomic, copy)NSString *isSubscribed; // (0, 1, 2) (v5.3.2新增2推荐订阅标识)
@property(nonatomic, copy)NSString *isDownloaded; // (0,1)
@property(nonatomic, copy)NSString *isOnRank; // (0,1)
@property(nonatomic, copy)NSString *isTop; // 是否置顶 (0,1)
@property(nonatomic, copy)NSString *topTime; // 置顶时间
@property(nonatomic, copy)NSString *indexValue; // 第一位  是否置顶 后面的publishTime
@property(nonatomic, copy)NSString *starGrade; // 刊物评级
@property(nonatomic, copy)NSString *commentCount; // 刊物评论数目
@property(nonatomic, copy)NSString *openTimes; // 刊物打开的次数 用在没订阅的前提下提示用户订阅；需要在用户订阅的时候重新置0 (1,2,3...)
@property(nonatomic, copy)NSString *backPromotion; // 刊物返回是否提示用户订阅，用在没有订阅用户在刊物内返回的时候提示用户订阅 (0 / 1)
@property(nonatomic, copy)NSString *templeteType; // 刊物模板类型
@property(nonatomic, copy)NSString *status; // 各种本地化的标志位  按位取值
@property(nonatomic, copy)NSString *isSelected;//在离线设置里是否被勾选
@property(nonatomic, copy)NSString *zipUrl;//在离线设置地址
@property(nonatomic, copy)NSString *stickTop; //是否默认置顶(3.5)
@property(nonatomic, copy)NSString *buttonTxt; //功能插件详情页大按钮文本(3.5)
@property(nonatomic, copy)NSString *needLogin; // 刊物是否需要登录才能订阅或者发表评论等操作(3.5.1)
@property(nonatomic, copy)NSString *canOffline; // 刊物能否离线(3.5.1)
@property(nonatomic, copy)NSString *userInfo; // json string data (3.5.1) 缓存刊物作者用户列表

// 下面这两个属性 主要用在刊物详情页 控制评论和相关刊物推荐两个tab是否显示 (ps. add in v3.6, 不会缓存到数据库)
@property(nonatomic, copy)NSString *showComment; // 1 显示评论， 0 不显示
@property(nonatomic, copy)NSString *showRecmSub; // 1 显示相关订阅，0不显示

// 3.4 订阅中心 增加新闻、组图、微博、直播等频道
// api version >= 12
// 增加两个字段

// 打开资源link：刊物：paper://   数据流：dataFlow:// 新闻频道: newsChannel:// 微博频道：weiboChannel://  组图频道：groupPicChannel:// 直接访问网页：http:// https://--
@property(nonatomic, copy)NSString *link;

// 刊物类型 订阅类型：刊物：31   数据流：32 频道新闻:33 功能插件:38 ...
@property(nonatomic, copy)NSString *subShowType;

// for open method
@property(nonatomic, strong)NSDictionary *openContext; // clean after open

//Transient Properties
@property(nonatomic, copy)NSString *termName;//期刊名，形如：4.27 第一财经周刊
@property(nonatomic, assign)SNDownloadStatus downloadStatus;//标识下载状态
@property(nonatomic, copy)NSString *tmpDownloadZipPath;
@property(nonatomic, copy)NSString *finalDownloadZipPath;
@property(nonatomic, assign)BOOL isSpecifiedTerm;
@property(nonatomic, assign)int from; //订阅/退订统计 - 来源

@property(nonatomic, copy)NSString *topNewsAbstracts;
@property(nonatomic, copy)NSString *topNewsLink;
@property(nonatomic, strong)NSArray *topNewsPics; // 存数据库时序列化为json string
@property(nonatomic, copy)NSString *topNewsPicsString; // topNewsPics数组序列化为json string

@property(nonatomic, copy)NSString *sortIndex; // 4.3新版订阅 排序相关属性

@property(nonatomic, copy)NSString *topNewsString;      // 5.0订阅刊物新闻数据json string
@property(nonatomic, strong)NSMutableArray *topNewsArray; // 5.0订阅频道流
@property(nonatomic, copy)NSString *countShowText;//累计阅读数/累计播放数

// 解析方法
+ (SCSubscribeObject *)subscribeObjFromJsonDic:(NSDictionary *)dic;
+ (SCSubscribeObject *)subscribeObjFromXMLData:(TBXMLElement *)xmlElm;

- (int)statusValueWithFlag:(SCSubObjStatusFlag)flag;
- (BOOL)setStatusValue:(int)value forFlag:(SCSubObjStatusFlag)flag;
- (SubscribeHomeMySubscribePO *)toSubscribeHomeMySubscribePO;

- (void)updateTopTime;

// open some view controller that fits self.link and self.subShowType
// will clean open context property
- (BOOL)open;

// open SubDetail view controller by subId;
// will clean open context property 
- (BOOL)openDetail;

// 判断是否功能插件
- (BOOL)isPlugin;

// 订阅成功提示语
- (NSString *)succSubMsg;

// 订阅失败提示语
- (NSString *)failSubMsg;

// 退订成功提示语
- (NSString *)succUnsubMsg;

// 退订失败提示语
- (NSString *)failUnsubMsg;

- (NSArray *)userInfoListArray;

@end

// 刊物分类数据
@interface SCSubscribeTypeObject : NSObject
@property(nonatomic,assign)NSInteger ID;
@property(nonatomic, copy)NSString *typeId;
@property(nonatomic, copy)NSString *typeName;
@property(nonatomic, copy)NSString *typeIcon;
@property(nonatomic, copy)NSString *subId;
@property(nonatomic, copy)NSString *subName;

@end

// 订阅中心 ad list
@interface SCSubscribeAdObject : NSObject
{
    NSString *adImg;
}
@property(nonatomic,assign)NSInteger ID;
@property(nonatomic, copy)NSString *adName;
@property(nonatomic, copy)NSString *adType;
@property(nonatomic, copy)NSString *adImage;
@property(nonatomic, copy)NSString *refText;
@property(nonatomic, copy)NSString *refId;
@property(nonatomic, copy)NSString *refLink;
@property(nonatomic, copy)NSString *type;
@property(nonatomic, copy)NSString *adId;
@property(nonatomic, assign)BOOL isReportStatistics;

@end

// 刊物评论数据
@interface SCSubscribeCommentObject : NSObject

@property(nonatomic,assign)NSInteger ID;
@property(nonatomic, copy)NSString *subId;
@property(nonatomic, copy)NSString *author;
@property(nonatomic, copy)NSString *ctime;
@property(nonatomic, copy)NSString *content;
@property(nonatomic, copy)NSString *starGrade;
@property(nonatomic, copy)NSString *city;
@property(nonatomic, assign)int contentLinesNum;

@end

// ShareList “一键分享”列表数据类
@interface ShareListItem : NSObject

@property(nonatomic, assign)int ID;
@property(nonatomic, assign)int appLevel; // 应用级别，用于列表排序，level级别越高的排在前面，值越小level级别越高
@property(nonatomic, copy)NSString *status; // 0：已绑定，1：未(或已取消)绑定(需再绑定)，2：已失效(需再绑定)
@property(nonatomic, copy)NSString *appID; // 应用id
@property(nonatomic, copy)NSString *appName; // 应用名称
@property(nonatomic, copy)NSString *appIconUrl; // 应用icon url
@property(nonatomic, copy)NSString *appGrayIconUrl; // 应用icon gray url

@property(nonatomic, copy)NSString *userName; // 绑定用户的信息：名称
@property(nonatomic, copy)NSString *requestUrl; // 请求授权的url

@property(nonatomic, copy)NSString *openId;

@end

typedef enum {
    LiveGameFlagReserve = 0,
    LiveGameFlagHasUp
}LiveGameFlag;
// 直播间比赛数据类
@interface LivingGameItem : NSObject
{
    NSString *flag;
}
@property(nonatomic,assign)NSInteger ID;
@property(nonatomic, copy)NSString *reserveFlag;  // 用来保留各种标志位
@property(nonatomic, copy)NSString *isToday;        // 1 0 是否为今天的直播
@property(nonatomic, copy)NSString *isFocus;        // 1 0 是否为焦点赛事
@property(nonatomic, copy)NSString *liveId; 
@property(nonatomic, copy)NSString *livePic;        // 如果是焦点赛事  则会有焦点图
@property(nonatomic, copy)NSString *isHot;          // 1 0 是否是热点比赛
@property(nonatomic, copy)NSString *liveType;       // 直播类型，1-双方比赛 2-多放比赛
@property(nonatomic, copy)NSString *liveCat;        // 比赛类别名称 "体育"
@property(nonatomic, copy)NSString *liveSubCat;     // 比赛类别名称 "NBA"
@property(nonatomic, copy)NSString *title;          // 比赛title "NBA:老鹰VS凯尔特人"
@property(nonatomic, copy)NSString *status;         // 比赛状态 1-预告 2-直播中 3-直播结束
@property(nonatomic, copy)NSString *liveTime;       // 比赛时间,时间的long值
@property(nonatomic, copy)NSString *liveDay;        // 比赛日期 直播预告 周几
@property(nonatomic, copy)NSString *liveDate;       // 比赛具体日期 几月几号
@property(nonatomic, assign) int  mediaType;        // LiveMediaText  = 0, LiveMediaVideo = 1, LiveMediaSound = 2  0非多媒体直播 1视频片段 2音频 3视频直播

@property (nonatomic, copy) NSString *pubType;      // 1 0 是否独家

@property (nonatomic, copy) NSString *blockId;      //直播分类信息

// 客队
@property(nonatomic, copy)NSString *visitorId;       // 客队id
@property(nonatomic, copy)NSString *visitorName;     // 客队名称
@property(nonatomic, copy)NSString *visitorPic;      // 客队队标 http url
@property(nonatomic, copy)NSString *visitorInfo;     // 客队信息 http url
@property(nonatomic, copy)NSString *visitorTotal;    // 客队得分

// 主队
@property(nonatomic, copy)NSString *hostId;         // 主队id
@property(nonatomic, copy)NSString *hostName;       // 主队名称
@property(nonatomic, copy)NSString *hostPic;        // 主队队标 http url
@property(nonatomic, copy)NSString *hostInfo;       // 主队信息 http url
@property(nonatomic, copy)NSString *hostTotal;      // 主队得分

@property(nonatomic, assign)NSInteger createAt;

- (id)initWithDictionary:(NSDictionary *)dict;

@end

//直播间 直播分类
@interface LiveCategoryItem : NSObject

@property(nonatomic, copy)NSString *subId;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *link;

- (id)initWithDictionary:(NSDictionary *)dict;

@end

@interface CommentFloor : NSObject

@property(nonatomic, readwrite)int ID;
@property(nonatomic, copy)NSString *commentJson;
@property(nonatomic, copy)NSString *commentId;
@property(nonatomic, readwrite)double ctime;
@property(nonatomic, copy)NSString *newsId;
@property(nonatomic, copy)NSString *type;
@property(nonatomic, copy)NSString *topicId;
@property(nonatomic, copy)NSString *newsType;
@property(nonatomic, assign)NSInteger digNum;
@property(nonatomic, readwrite)BOOL hadDing;
@property(nonatomic, assign)NSInteger createAt;

@end

// 天气预报
@interface City : NSObject

@property(nonatomic, copy)NSString *city; // 城市名
@property(nonatomic, copy)NSString *code; // 城市代码，用于请求天气时用
@property(nonatomic, copy)NSString *gbcode; // 城市的国标码
@property(nonatomic, copy)NSString *index; // 城市首字母索引
@property(nonatomic, copy)NSString *province; // 省份

@end

@interface WeatherReport : NSObject {
    NSInteger ID;
    NSString *city;
    NSString *cityCode;
    NSString *cityGbcode;
    NSString *shareLink; // 天气分享连接
    NSString *weatherIndex; // 在三天预报中的index顺序
    NSString *chuanyi; // 穿衣指数
    NSString *date; // 日期
    NSString *chineseDate; // 农历
    NSString *ganmao; // 感冒指数
    NSString *jiaotong; // 交通指数
    NSString *lvyou; // 旅游建议
    NSString *platformId; // ?
    NSString *tempHigh; // 最高气温
    NSString *tempLow; // 最低气温
    NSString *weather; // 天气
    NSString *weatherIoc; //
    NSString *weatherLocalIoc; //
    NSString *wind; // 风力
    NSString *wuranservice; // 污染指数
    NSString *yundong; // 运动
    NSString *pm25;   // pm2.5
    NSString *quality; // 空气质量
    NSString *copywriting;
    NSString *morelink; //详情
}

@property(nonatomic, assign) NSInteger ID;
@property(nonatomic, copy)NSString *city; 
@property(nonatomic, copy)NSString *cityCode; 
@property(nonatomic, copy)NSString *cityGbcode;
@property(nonatomic, copy)NSString *shareLink; // 天气分享连接
@property(nonatomic, copy)NSString *weatherIndex; // 在三天预报中的index顺序
@property(nonatomic, copy)NSString *chuanyi; // 穿衣指数
@property(nonatomic, copy)NSString *date; // 日期
@property(nonatomic, copy)NSString *chineseDate; // 农历
@property(nonatomic, copy)NSString *ganmao; // 感冒指数
@property(nonatomic, copy)NSString *jiaotong; // 交通指数
@property(nonatomic, copy)NSString *lvyou; // 旅游建议 
@property(nonatomic, copy)NSString *platformId; // ?
@property(nonatomic, copy)NSString *tempHigh; // 最高气温 
@property(nonatomic, copy)NSString *tempLow; // 最低气温
@property(nonatomic, copy)NSString *weather; // 天气
@property(nonatomic, copy)NSString *weatherIconUrl; // 天气icon图片 复用之前的属性 不要搞错
@property(nonatomic, copy)NSString *weatherLocalIconUrl; // 天气大的背景图片 不要搞错
@property(nonatomic, copy)NSString *wind; // 风力
@property(nonatomic, copy)NSString *wuran; // 污染指数
@property(nonatomic, copy)NSString *yundong; // 运动
@property(nonatomic, copy)NSString *pm25;   // pm2.5
@property(nonatomic, copy)NSString *quality; // 空气质量
@property(nonatomic, copy)NSString *shareContent;
@property(nonatomic, assign)int ugcWordLimit;
@property(nonatomic, copy)NSString *copywriting;
@property(nonatomic, copy)NSString *morelink; //详情

- (id)initWithDictionary:(NSDictionary *)dict;

@end


// 投票
@interface VotesInfo : NSObject

@property(nonatomic,assign)NSInteger ID;
@property(nonatomic, copy)NSString *newsID;
@property(nonatomic, copy)NSString *topicID;
@property(nonatomic, copy)NSString *isVoted;
@property(nonatomic, copy)NSString *voteXML;
@property(nonatomic, copy)NSString *isOver;
@property(nonatomic, assign)NSInteger createAt;

@end

// 微热议
@interface WeiboHotItem : NSObject {
    NSArray *_usersList;
}
@property(nonatomic, assign) NSInteger ID;
@property(nonatomic, copy) NSString *weiboId;
@property(nonatomic, copy) NSString *nick;
@property(nonatomic, copy) NSString *head;
@property(nonatomic, copy) NSString *homeUrl;
@property(nonatomic, copy) NSString *wapUrl;
@property(nonatomic, copy) NSString *isVip;
@property(nonatomic, copy) NSString *time; // 服务器改成了时间戳
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *type; //(0 - tencent, 1 - sina, 2 - sohu)
@property(nonatomic, copy) NSString *icon;
@property(nonatomic, copy) NSString *commentCount;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *abstract;
@property(nonatomic, copy) NSString *focusPic;
@property(nonatomic, copy) NSString *weight;
@property(nonatomic, copy) NSString *userJson;
@property(nonatomic, copy) NSString *pageNo;
@property(nonatomic, copy) NSString *readMark;
@property(nonatomic, readonly) NSArray *usersList;
// 详细
@property(nonatomic, copy) NSString *newsId;
@property(nonatomic, strong) NSArray *resourceList;
@property(nonatomic, copy) NSString *shareContent;
@property(nonatomic, assign) CGFloat cellHeight; // 缓存cell高度
@property(nonatomic, assign)NSInteger createAt;
//Transient properties
@property(nonatomic, assign)BOOL isDownloadFinished;

@end

// 微博用户Item
@interface WeiboHotUserItem : NSObject

@property(nonatomic, copy) NSString *userId;
@property(nonatomic, copy) NSString *head;
@property(nonatomic, copy) NSString *nick;
@property(nonatomic, copy) NSString *isVip;

@end


@interface WeiboHotItemDetail : NSObject

@property(nonatomic, assign) NSInteger ID;
@property(nonatomic, copy) NSString *weiboId;
@property(nonatomic, copy) NSString *nick;
@property(nonatomic, copy) NSString *isVip;
@property(nonatomic, copy) NSString *head;
@property(nonatomic, copy) NSString *homeUrl;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *time; // 服务器改成了时间戳
@property(nonatomic, copy) NSString *weiboType;
@property(nonatomic, copy) NSString *source;
@property(nonatomic, copy) NSString *commentCount;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *newsId;
@property(nonatomic, copy) NSString *wapUrl;
@property(nonatomic, copy) NSString *shareContent;
@property(nonatomic, copy) NSString *resourceJSON;
@property(nonatomic, assign) CGFloat cellHeight; // 缓存cell高度

@property(nonatomic, strong) NSArray *resourceList;

@property(nonatomic, assign)NSInteger createAt;
@property(nonatomic, strong)NSString *stpAudCmtRsn;
@property(nonatomic, strong)NSString *cmtStatus;
@property(nonatomic, strong)NSString *cmtHint;

@end
// 微博评论Item
@interface WeiboHotCommentItem : NSObject

@property(nonatomic, assign)NSInteger ID;
@property(nonatomic, copy) NSString *commentId;
@property(nonatomic, copy) NSString *nick;
@property(nonatomic, copy) NSString *head;
@property(nonatomic, copy) NSString *isVip;
@property(nonatomic, copy) NSString *type;      //评论类型，0表示微博原始评论，1表示搜狐我说评论
@property(nonatomic, copy) NSString *homeUrl;   //用户微博wap地址，搜狐自身用户给出用户中心地址,用户没有用户中心时不返回头像和用户中心地址
@property(nonatomic, copy) NSString *spaceLink; //搜狐我说评论的空间地址
@property(nonatomic, copy) NSString *pid;
@property(nonatomic, copy) NSString *linkStyle; //控制开关,1：使用homeUrl 0：使用spaceLink
@property(nonatomic, copy) NSString *time;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *weiboId;
@property(nonatomic, assign) CGFloat cellHeight; // 缓存cell高度
@property(nonatomic, assign)NSInteger createAt;
@property(nonatomic, copy) NSString *audUrl;
@property(nonatomic, copy) NSString *audLen;
@property(nonatomic, copy) NSString *image;
@property(nonatomic, copy) NSString *imageSmall;
@property(nonatomic, copy) NSString *imageBig;
@property(nonatomic, copy) NSString *userComtId;
@property(nonatomic, assign) int gender;
@property(nonatomic, assign) BOOL isOpenComment;

- (BOOL)isSameWith:(WeiboHotCommentItem *)obj;
- (BOOL)hasImage;

@end


// 搜索历史
@interface SearchHistoryItem : TTTableLinkedItem

@property(nonatomic, assign)NSInteger ID;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,strong)NSNumber *time;
@property(nonatomic,assign)BOOL isClear;

@end


@interface SearchSuggestItem : TTTableLinkedItem
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *keyword;

@end


