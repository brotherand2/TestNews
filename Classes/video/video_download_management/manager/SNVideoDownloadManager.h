//
//  SNVideoDownloadManager.h
//  sohunews
//
//  Created by handy wang on 8/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoObjects.h"

#define kDownloadVideoType_M3U8                             (@"m3u8")
#define kDownloadVideoType_MP4                              (@"mp4")
#define kDownloadVideoType_Other                            (@"other")

#define kDownloadingVideoItem                               (@"kDownloadingVideoItem")

#define kDownloadingVideoType                               (@"kDownloadingVideoType")

#define kVideoDownloadedBytes                               (@"kVideoDownloadedBytes")
#define kVideoTatalBytes                                    (@"kVideoTatalBytes")
#define kDownloadingVideoModel                              (@"kDownloadingVideoModel")

#define kDownloadingM3U8VID                                 (@"kDownloadingM3U8VID")
#define kSegmentsCount                                      (@"kSegmentsCount")
#define kSegmentOrder                                       (@"kSegmentOrder")

#define kM3U8_Download_Result                               (@"kM3U8_Download_Result")
#define kM3U8_Download_Result_Success                       (@"kM3U8_Download_Result_Success")
#define kM3U8_Download_Result_Fail                          (@"kM3U8_Download_Result_Fail")

#define kSegmentInfo                                        (@"kSegmentInfo")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SNVideoDownloadConfig : NSObject
+ (NSString *)rootDir;
+ (NSString *)normalVideoDir;
+ (NSString *)normalVideoTmpDir;
+ (NSString *)m3u8VideoDir:(NSString *)vid;
+ (NSString *)m3u8VideoTmpDir;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/** 注意：需要存与视频相关的以下数据：
 * vid: 播放器内部大量用到了vid
 * channelId: 用于反查视频所在频道的视频流
 * messageId: 用到反查视频数据对象本身以及相关视频流
 * title: 视频title
 * subTitle: 视频子标题
 * columnName: 栏目名称
 * authorType: 媒体类型（机构自媒体、社交媒体、个人自媒体、搜狐视频推荐)，可以枚举VideoAuthorType
 * authorName: 媒体名称
 * siteName: 网站来源名称
 * poster: 视频的封面图
 * videoLink2: 视频的2代协议
 * playType: native或内置浏览器播放（注：内置浏览器播放说明是有版权问题）
 * videoURLForPlayingInNativePlayer:
 * videoURLForPlayingInInnerWeb:
 * mediaLink: 视频媒体的2代协议
 * contentForSharingShow: 视频分享的用户可看的文本
 * contentForSharingTo: 视频分享的实际分享出去的文本
 * h5URLForSharingTo: 视频分享的H5页面url
 */
@interface SNVideoOfflinePlayModel : NSObject
@property (nonatomic, copy)NSString *vid;
@property (nonatomic, copy)NSString *channelId;
@property (nonatomic, copy)NSString *messageId;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *subTitle;
@property (nonatomic, assign)VideoAuthorType authorType;
@property (nonatomic, copy)NSString *authorName;
@property (nonatomic, copy)NSString *columnName;
@property (nonatomic, copy)NSString *siteName;
@property (nonatomic, copy)NSString *poster;
@property (nonatomic, copy)NSString *videoLink2;
@property (nonatomic, assign)WSMVVideoPlayType *playType;
@property (nonatomic, copy)NSString *videoURLForPlayingInNativePlayer;
@property (nonatomic, copy)NSString *videoURLForPlayingInInnerWeb;
@property (nonatomic, copy)NSString *mediaLink;
@property (nonatomic, copy)NSString *contentForSharingShow;
@property (nonatomic, copy)NSString *contentForSharingTo;
@property (nonatomic, copy)NSString *h5URLForSharingTo;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SNVideoDownloadManager : NSObject
+ (SNVideoDownloadManager *)sharedInstance;
- (NSMutableArray *)itemsForDownloadingView;
- (void)removeSelectedItem:(SNVideoDataDownload *)selectedItem;
- (NSMutableArray *)successfulItems;

- (void)downloadVideoInThread:(SNVideoDataDownload *)videoModel;
- (void)pauseDownloadingVideo:(SNVideoDataDownload *)videoModel;
- (void)diskSpaceNotEnoughAndPauseAllIfNeededWithResponseHeaders:(NSDictionary *)responseHeaders;
- (void)pauseAllVideo;
- (void)resumeDownloadingVideo:(SNVideoDataDownload *)videoModel;
- (void)retryDownloadingVideo:(SNVideoDataDownload *)videoModel;
@end
