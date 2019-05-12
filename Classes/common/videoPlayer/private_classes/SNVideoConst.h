//
//  SNVideoConst.h
//  sohunews
//
//  Created by handy wang on 4/2/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TimelineVideoType_normalVideo = 0,
    TimelineVideoType_Speical= 1,
    TimelineVideoType_AppBanner = 2,
    TimelineVideoType_Complex = 3
} TimelineVideoType;

typedef enum {
    WSMVVideoPlayerRefer_Unknown = 0,
    WSMVVideoPlayerRefer_PushNotification = 1,
    WSMVVideoPlayerRefer_VideoTabTimeline = 2,
    WSMVVideoPlayerRefer_OfflinePlay      = 3,
    WSMVVideoPlayerRefer_NewsArticle      = 4,
    WSMVVideoPlayerRefer_LiveRoomList     = 5,
    WSMVVideoPlayerRefer_LiveRoomBanner   = 6
} WSMVVideoPlayerRefer;

typedef enum {
    VideoAuthorType_OrgnizationSelfMedia = 0,
    VideoAuthorType_SocialMedia = 1,
    VideoAuthorType_PersonalSelfMedia = 2,
    VideoAuthorType_SohuRecommend = 3
} VideoAuthorType;

typedef enum {
    WSMVVideoPlayType_Native = 0,
    WSMVVideoPlayType_HTML5  = 1
} WSMVVideoPlayType;

typedef enum {
    WSMVVideoDownloadType_CantDownload = 0,
    WSMVVideoDownloadType_CanDownload = 1,
    WSMVVideoDownloadType_CanDownloadOnly10Minutes = 2,
    WSMVVideoDownloadType_CanDownloadForPassportUsers = 3
} WSMVVideoDownloadType;

typedef enum {
    SNVideoDownloadViewMode_DownloadedView  = 0,
    SNVideoDownloadViewMode_DownloadingView = 1
} SNVideoDownloadViewMode;

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////4.2版本视频播放和广告控制相关参数//////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
static NSString * const SNVideoConst_kSite = @"site";//我方定义的视频源类型(4.2版本之前没有用过，4.2版本也不用)
static NSString * const SNVideoConst_kSite2 = @"site2";//与搜狐视频源类型兼容的视频源类型：1搜狐视频 2搜狐播客 3搜狐直播 其它类型在4.2版本暂未定义
static NSString * const SNVideoConst_kSiteName = @"siteName";//视频源名称，如"搜狐视频" “搜狐博客“等
static NSString * const SNVideoConst_kSiteId = @"siteId";//搜狐三种视频源的id
static NSString * const SNVideoConst_kPlayById = @"playById";//是否按siteId来播放视频; 1表示按siteId来播放视频, 0表示不按siteId来播放视频
static NSString * const SNVideoConst_kPlayAd = @"playAd";//是否播放广告; 1表示播放广告，0表示不播放广告
static NSString * const SNVideoConst_kAdServer = @"adServer";//当不通过siteId来播放视频而是通过url来播放视频时，adServer表示广告物料地址
static NSString * const SNVideoConst_kVid = @"vid";//vid
