//
//  SNVideoObjects.h
//  sohunews
//
//  Created by chenhong on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoConst.h"

@class SNVideoAd;

#define kVideosSpecialCellHeight        (85)

@interface SNVideoAuthor : NSObject

@property(nonatomic, copy)NSString *name;
@property(nonatomic, assign)int type;
@property(nonatomic, copy)NSString *icon;
@property (nonatomic, copy) NSString * subId;

- (id)initWithDict:(NSDictionary *)dict;
- (void)updateWithDict:(NSDictionary *)dict;

@end

@interface SNVideoUrl : NSObject

@property(nonatomic, copy)NSString *m3u8;
@property(nonatomic, copy)NSString *mp4;
@property(nonatomic, strong)NSArray *mp4s;

- (id)initWithDict:(NSDictionary *)dict;
- (void)updateWithDict:(NSDictionary *)dict;
- (NSString *)toJsonString;

@end

@interface SNVideoShare : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *h5Url;
@property (nonatomic, copy) NSString *weixinContent;
@property (nonatomic, assign) int ugcWordLimit;

- (id)initWithDict:(NSDictionary *)dict;
- (void)updateWithDict:(NSDictionary *)dict;

@end

@interface SNVideoSiteInfo : NSObject

@property(nonatomic,copy)NSString *site;
@property(nonatomic,copy)NSString *site2;
@property(nonatomic,copy)NSString *siteId;
@property(nonatomic,copy)NSString *siteName;
@property(nonatomic,copy)NSString *adServer;
@property(nonatomic,copy)NSString *playById;
@property(nonatomic,copy)NSString *playAd;

- (id)initWithDict:(NSDictionary *)dict;
- (void)updateWithDict:(NSDictionary *)dict;

@end


@interface SNVideoListInfo : NSObject

@property(nonatomic, assign)int count;
@property(nonatomic, assign)long long nextCursor;
@property(nonatomic, strong)NSString *preCursor;
@property(nonatomic, assign)int totalCount;
@property(nonatomic, assign)BOOL hasnext;

- (void)updateWithDict:(NSDictionary *)dict;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////Video类集//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
@class SNVideoData;
@class SNVideoDataDownload;
@class SNVideoBannerData;
@class SNVideoEntryData;

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////SNVideoData///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Video数据对象集
#pragma mark - SNVideoData
@interface SNVideoData : NSObject
@property (nonatomic, copy)NSString                  *vid;
@property (nonatomic, copy)NSString                  *messageId;
@property (nonatomic, copy)NSString                  *channelId;
@property (nonatomic, copy)NSString                  *link2;
@property (nonatomic, copy)NSString                  *title;
@property (nonatomic, copy)NSString                  *abstract;
@property (nonatomic, copy)NSString                  *columnName;
@property (nonatomic, copy)NSString                  *poster;
@property (nonatomic, copy)NSString                  *poster_4_3;
@property (nonatomic, copy)NSString                  *smallImageUrl;
@property (nonatomic, assign)WSMVVideoPlayType       playType;
@property (nonatomic, assign)WSMVVideoDownloadType   downloadType;
@property (nonatomic, strong)SNVideoUrl              *videoUrl;
@property (nonatomic, copy)NSString                  *wapUrl;
@property (nonatomic, strong)SNVideoShare            *share;
@property (nonatomic, assign)int                     duration;
@property (nonatomic, strong)SNVideoAuthor           *author;
@property (nonatomic, strong)SNVideoSiteInfo         *siteInfo;
@property (nonatomic, copy)NSString                  *mediaLink;
@property (nonatomic, strong)NSString                *templateType;
@property (nonatomic, assign)BOOL                    isActivePause;
@property (nonatomic, copy) NSString                 *recomInfo;
@property (nonatomic, copy) NSString                 *newsId;
@property (nonatomic, copy) NSString                 *newsType;//@qz 加reportSite.go接口需要
@property (nonatomic, copy) NSString                 *voidLink;

//////////////////////////////////Extended for timeline
@property(nonatomic, assign)int         status;
@property(nonatomic, assign)int         columnId;
@property(nonatomic, assign)int         action;
@property(nonatomic, assign)int         type;
@property(nonatomic, assign)int         playCount;
@property(nonatomic, strong)NSString    *templatePicUrl;
@property(nonatomic, assign)TimelineVideoType multipleType;           //模版结构类型
@property(nonatomic, assign)BOOL        hadLoadRecommendVideos;
//---App换量相关--------------------------------------------------------
@property(nonatomic, copy, readonly)NSString      *appContent;
@property(nonatomic, copy)NSString *bannerImgURLOfOpenApp;
@property(nonatomic, copy)NSString *bannerImgURLOfDownloadApp;
@property(nonatomic, copy)NSString *bannerImgURLOfUpgradeApp;
@property(nonatomic, copy)NSString *appDownloadLink;
@property(nonatomic, copy)NSString *appIdOfAppWillBeOpen;
@property(nonatomic, copy)NSString *appURLSchemaOfAppWillBeOpen;

//复杂换量模板
@property(nonatomic, strong)SNVideoBannerData* banerData;
@property(nonatomic, strong)NSArray* entryData;
@property(nonatomic, assign)int uninterestInterval;
@property(nonatomic, strong)NSString* bannerString;
@property(nonatomic, strong)NSString* entryString;
//---前贴片广告相关--------------------------------------------------------
@property(nonatomic, strong)SNVideoAd *videoAd;
//---------------------------------------------------------------------

@property(nonatomic, strong)NSString* playTime;

@property(nonatomic, assign)BOOL isNewsVideo;
@property(nonatomic, assign)BOOL isRecommend;

#pragma mark - Public
- (id)initWithDict:(NSDictionary *)dict;

- (void)uploadLoadStatistics:(NSString*)fromId;

- (void)uploadDisplayStatistics:(NSString*)fromId;

- (void)uploadClickStatistics:(NSString*)dataId fromId:(NSString*)fromId;

//////////////////////////////////Extended for videoplayer
@property (nonatomic, copy)NSString                     *subtitle;
@property(nonatomic, strong)NSMutableArray              *sources;
@property(nonatomic, copy)NSString                      *sPlayID;//视频tab Timeline相关流连播时会用到
@property(nonatomic, strong)NSDictionary                *userInfo;
//以下属性用于统计相关
@property(nonatomic, assign, readonly)NSTimeInterval    totalTime;
@property(nonatomic, strong)NSMutableDictionary         *totalTimeMap;
@property(nonatomic, assign, readonly)NSTimeInterval    playedTime;
@property(nonatomic, strong)NSMutableDictionary         *playedTimeMap;
//Transient
//@property(nonatomic, assign)int                         duration;
@property(nonatomic, assign)CGFloat                     recommendCellHeight;
@property(nonatomic, assign)BOOL                        willPlay;//与新闻正文页非全屏时相关视频有联系
@property(nonatomic, assign)BOOL                        hadEverAlert2G3G;
@property(nonatomic, assign)BOOL                        callbackWillPlayNextIn5Seconds;

//////////////////////////////////Extended for download&offlinePlay
@property (nonatomic, assign)BOOL                       offlinePlay;
@property (nonatomic, assign)NSTimeInterval             finishDownloadTimeInterval;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////SNVideoDataDownload///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
@interface SNVideoDataDownload : SNVideoData
@property (nonatomic, strong)NSString               *videoSources;
@property (nonatomic, strong)NSString               *downloadURL;
@property (nonatomic, strong)NSString               *videoType;
@property (nonatomic, strong)NSString               *localRelativePath;
@property (nonatomic, strong)NSString               *localM3U8URL;
@property (nonatomic, assign)SNVideoDownloadState   state;
@property (nonatomic, assign)NSTimeInterval         beginDownloadTimeInterval;
@property (nonatomic, assign)NSTimeInterval         finishDownloadTimeInterval;

@property (nonatomic, assign)CGFloat                downloadBytes;
@property (nonatomic, assign)CGFloat                totalBytes;
@property (nonatomic, assign)CGFloat                downloadProgress;

//Transient properties
@property (nonatomic, strong)NSMutableDictionary    *eachSegmentDownloadBytes;
@property (nonatomic, strong)NSMutableDictionary    *eachSegmentTotalBytes;
@property (nonatomic, assign)BOOL                   isEditing;
@property (nonatomic, assign)BOOL                   isSelected;
@end

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////SNVideoBannerData///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
@interface SNVideoBannerData : NSObject
@property (nonatomic, strong) NSString* bannerId;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* iconOpen;
@property (nonatomic, strong) NSString* iconDown;
@property (nonatomic, strong) NSString* appDownloadLink;
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* urlScheme;
@property (nonatomic, strong) NSString* version;

- (id)initWithDic:(NSDictionary*)dic;
@end

@interface SNVideoEntryData : NSObject
@property (nonatomic, strong) NSString* entryId;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, assign) int linkType;
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* urlScheme;
@property (nonatomic, strong) NSString* version;
@property (nonatomic, strong) NSString* appDownloadLink;
@property (nonatomic, strong) NSString* link;

- (id)initWithDic:(NSDictionary*)dic;
@end
