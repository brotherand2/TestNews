//
//  WSMVVideoHelper.m
//  sohunews
//
//  Created by handy wang on 11/6/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "WSMVVideoHelper.h"
#import "SNVideoObjects.h"
#import "WSMVVideoPlayerView.h"
#import "SNDBManager.h"
#import "WSMVVideoStatisticManager.h"
#import "WSMVVideoStatisticModel.h"
#import "SNToast.h"
#import "SNNewAlertView.h"

#define kContinueDownloadVideoIn2G3GActionSheetTag                      (1000)
#define kVideoWithContinueDownloadVideoIn2G3GActionSheet                (@"kVideoWithContinueDownloadVideoIn2G3GActionSheet")

@interface WSMVVideoHelper()
@property (nonatomic, strong)SNActionSheet *actionSheetOfContinueDownloadVideoIn2G3G;
@end

@implementation WSMVVideoHelper

#pragma mark - Lifecycle
- (id)init {
    if (self = [super init]) {
        self.bContinueToPlayVideoIn2G3G = NO;
        self.hadEverAlert2G3GOfChannels = [NSMutableDictionary dictionary];
        
        self.actionSheetOfContinueDownloadVideoIn2G3G.delegate = nil;
        self.actionSheetOfContinueDownloadVideoIn2G3G = nil;
    }
    return self;
}

- (void)dealloc {
    self.bContinueToPlayVideoIn2G3G = NO;
    
    self.actionSheetOfContinueDownloadVideoIn2G3G.delegate = nil;
}

+ (WSMVVideoHelper *)sharedInstance {
    static WSMVVideoHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WSMVVideoHelper alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public
- (void)continueToPlayVideoIn2G3G {
    self.bContinueToPlayVideoIn2G3G = YES;
}

#pragma mark - Public - Can Download
- (BOOL)canDownload:(SNVideoData *)timelineVideo userInfo:(NSDictionary *)userInfo {
    return [self canDownload:timelineVideo withPlayerView:nil userInfo:userInfo];
}

- (BOOL)canDownload:(SNVideoData *)timelineVideo withPlayerView:(WSMVVideoPlayerView *)playerView {
    return [self canDownload:timelineVideo withPlayerView:playerView userInfo:nil];
}

- (BOOL)canDownload:(SNVideoData *)timelineVideo withPlayerView:(WSMVVideoPlayerView *)playerView userInfo:(NSDictionary *)userInfo {
    if (timelineVideo.downloadType != WSMVVideoDownloadType_CanDownload ||
        timelineVideo.playType != WSMVVideoPlayType_Native) {
        [self toastMessage:NSLocalizedString(@"the_video_cant_be_downloaded", nil) forPlayer:playerView];
        return NO;
    }
    
    //---下载空数据
    if (!timelineVideo) {
        [self toastMessage:NSLocalizedString(@"failed_to_download_video", nil) forPlayer:playerView];
        SNDebugLog(@"Failed to download, video is nil.");
        return NO;
    }
    //---
    
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    SNVideoDataDownload *tempDownloadVideo = [[SNDBManager currentDataBase] queryDownloadVideoByVID:timelineVideo.vid];
    
    //有Download数据表明有过下载行为
    if (!!tempDownloadVideo) {
        //已完成下载
        if (tempDownloadVideo.state == SNVideoDownloadState_Successful) {
//            [self toastActionMessage:NSLocalizedString(@"video_had_download", nil) videoDownloadViewMode:SNVideoDownloadViewMode_DownloadedView forPlayer:playerView];
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"video_had_download", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"video_had_download", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            SNDebugLog(@"Video is downloaded.");
            return NO;
        }
        //没有完成下载
        else {
            //无网
            if (networkStatus == NotReachable) {
                [self toastMessage:NSLocalizedString(@"cant_downloadvideo_for_not_network", nil) forPlayer:playerView];
                SNDebugLog(@"Already in downloading but cant download, because network is not reachable.");
                return NO;
            }
            //2G/3G
            else if (networkStatus == ReachableViaWWAN ||
                     networkStatus == ReachableVia2G ||
                     networkStatus == ReachableVia3G ||
                     networkStatus == ReachableVia4G ) {
                //正在离线
                if (tempDownloadVideo.state == SNVideoDownloadState_Downloading) {
                    [self toastMessage:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) forPlayer:playerView];
                    SNDebugLog(@"2G/3G, Video is downloading.");
                    return NO;
                }
                //已处于等待离线
                else if (tempDownloadVideo.state == SNVideoDownloadState_Waiting) {
                    [self toastMessage:NSLocalizedString(@"video_already_in_waiting_download", nil) forPlayer:playerView];
                    SNDebugLog(@"2G/3G, Cant download, because video was already in waiting.");
                    return NO;
                }
                //之前是暂停(SNVideoDownloadState_Pause)、失败(SNVideoDownloadState_Failed)、取消状态(SNVideoDownloadState_Canceled)
                else {
                    SNDebugLog(@"2G/3G, Will recover download for paused/failed/canceled video[%d].", tempDownloadVideo.state);
                    if ([playerView isFullScreen]) {
                        [playerView exitFullScreen];
                        double delayInSeconds = .5;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self showActionSheetForContinueDownloadIn2G3GWithVideo:timelineVideo videoPlayerView:playerView userInfo:userInfo];
                        });
                    }
                    else {
                        [self showActionSheetForContinueDownloadIn2G3GWithVideo:timelineVideo videoPlayerView:playerView userInfo:userInfo];
                    }
                    return NO;
                }
            }
            //Wifi
            else {
                //正在离线
                if (tempDownloadVideo.state == SNVideoDownloadState_Downloading) {
//                    [self toastMessage:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) forPlayer:playerView];
                    if ([playerView isFullScreen]) {
                        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
                    }else{
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
                    }
                    SNDebugLog(@"Wifi, Video is downloading.");
                    return NO;
                }
                //已处于等待离线
                else if (tempDownloadVideo.state == SNVideoDownloadState_Waiting) {
                    [self toastMessage:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) forPlayer:playerView];
                    SNDebugLog(@"Wifi, Cant download, because video was already in waiting.");
                    return NO;
                }
                //之前是暂停(SNVideoDownloadState_Pause)、失败(SNVideoDownloadState_Failed)、取消状态(SNVideoDownloadState_Canceled)
                else {
                    SNDebugLog(@"Wifi, Recover download for paused/failed/canceled video[%d].", tempDownloadVideo.state);
                    return YES;
                }
            }
        }
    }
    
    //从未下载过
    else {
        //无网
        if (networkStatus == NotReachable) {
            [self toastMessage:NSLocalizedString(@"cant_downloadvideo_for_not_network", nil) forPlayer:playerView];
            SNDebugLog(@"Cant download, network not reachable.");
            return NO;
        }
        //有网
        else {
            //2G/3G
            if (networkStatus == ReachableViaWWAN ||
                networkStatus == ReachableVia2G ||
                networkStatus == ReachableVia3G ||
                networkStatus == ReachableVia4G ) {
                SNDebugLog(@"2G/3G, Will download video with action sheet");
                if ([playerView isFullScreen]) {
                    [playerView exitFullScreen];
                    double delayInSeconds = .5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self showActionSheetForContinueDownloadIn2G3GWithVideo:timelineVideo videoPlayerView:playerView userInfo:userInfo];
                    });
                }
                else {
                    [self showActionSheetForContinueDownloadIn2G3GWithVideo:timelineVideo videoPlayerView:playerView userInfo:userInfo];
                }
                return NO;
            }
            //Wifi网络
            else {
                SNDebugLog(@"Wifi, Can download......");
                return YES;//可以继续正常下载
            }
        }
    }
}

- (void)toastMessage:(NSString *)msg forPlayer:(WSMVVideoPlayerView *)playerView {
    if ([playerView isFullScreen]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:msg toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}

- (void)toastActionMessage:(NSString *)msg videoDownloadViewMode:(SNVideoDownloadViewMode)viewMode forPlayer:(WSMVVideoPlayerView *)playerView {
    SNDebugLog(@"Toast action message: %@", msg);
    if ([playerView isFullScreen]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:msg toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil userInfo:nil mode:SNCenterToastModeSuccess];
    }
}

- (void)showActionSheetForContinueDownloadIn2G3GWithVideo:(SNVideoData *)timelineVideo
                                          videoPlayerView:(WSMVVideoPlayerView *)videoPlayerView
                                                 userInfo:(NSDictionary *)userInfo {
//    if ([SNBaseFloatView isFloatViewShowed]) {
//        return;
//    }
    
    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_info_content", nil) cancelButtonTitle:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_option_cancel", nil) otherButtonTitle:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_option_continue", nil)];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
        SNVideoDataDownload *outterDownloadVideo = [userInfo objectForKey:kToBeDownloadedVideoModel];
        SNVideoData *outterTimelineVideo = timelineVideo;
        [self statDownloadAction:outterTimelineVideo];
        
        if (!outterDownloadVideo) {
            //---为离线完成后离线播放做准备
            SNVideoData *timelineVideo = [[SNDBManager currentDataBase] getVideoTimeLineByVid:outterTimelineVideo.vid];
            if (!timelineVideo) {
                if (outterTimelineVideo.channelId.length <= 0) {
                    outterTimelineVideo.channelId = kDefaultChannelIdForVideoDownload;
                }
                [[SNDBManager currentDataBase] addVideoData:outterTimelineVideo channelId:outterTimelineVideo.channelId];
            }
            //---
            
            SNVideoDataDownload *downloadVideo = [[SNVideoDataDownload alloc] init];
            downloadVideo.title = outterTimelineVideo.title;
            downloadVideo.videoSources = [outterTimelineVideo.videoUrl toJsonString];
            downloadVideo.vid = outterTimelineVideo.vid;
            downloadVideo.state = SNVideoDownloadState_Waiting;
            downloadVideo.poster = outterTimelineVideo.poster_4_3;
            [[SNVideoDownloadManager sharedInstance] downloadVideoInThread:downloadVideo];
            [SNNotificationManager postNotificationName:kVideoWillStartDownloadIn2G3GNotification object:downloadVideo];
            //(downloadVideo);
        }
        else {
            [[SNVideoDownloadManager sharedInstance] downloadVideoInThread:outterDownloadVideo];
            [SNNotificationManager postNotificationName:kVideoWillStartDownloadIn2G3GNotification object:outterDownloadVideo];
        }
        
        if ([videoPlayerView isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
        }

    }];
}

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SNDebugLog(@"Tapped actionSheet at buttonIndex %d", buttonIndex);
    
    if (actionSheet.tag == kContinueDownloadVideoIn2G3GActionSheetTag) {
        if (buttonIndex == 0) {//取消
            //放弃下载
        }
        else if (buttonIndex == 1) {//继续下载
            SNVideoDataDownload *outterDownloadVideo = [[actionSheet userInfo] objectForKey:kToBeDownloadedVideoModel];
            SNVideoData *outterTimelineVideo = [[actionSheet userInfo] objectForKey:kVideoWithContinueDownloadVideoIn2G3GActionSheet];
            [self statDownloadAction:outterTimelineVideo];
            
            if (!outterDownloadVideo) {
                //---为离线完成后离线播放做准备
                SNVideoData *timelineVideo = [[SNDBManager currentDataBase] getVideoTimeLineByVid:outterTimelineVideo.vid];
                if (!timelineVideo) {
                    if (outterTimelineVideo.channelId.length <= 0) {
                        outterTimelineVideo.channelId = kDefaultChannelIdForVideoDownload;
                    }
                    [[SNDBManager currentDataBase] addVideoData:outterTimelineVideo channelId:outterTimelineVideo.channelId];
                }
                //---
                
                SNVideoDataDownload *downloadVideo = [[SNVideoDataDownload alloc] init];
                downloadVideo.title = outterTimelineVideo.title;
                downloadVideo.videoSources = [outterTimelineVideo.videoUrl toJsonString];
                downloadVideo.vid = outterTimelineVideo.vid;
                downloadVideo.state = SNVideoDownloadState_Waiting;
                downloadVideo.poster = outterTimelineVideo.poster_4_3;
                [[SNVideoDownloadManager sharedInstance] downloadVideoInThread:downloadVideo];
                [SNNotificationManager postNotificationName:kVideoWillStartDownloadIn2G3GNotification object:downloadVideo];
                 //(downloadVideo);
            }
            else {
                [[SNVideoDownloadManager sharedInstance] downloadVideoInThread:outterDownloadVideo];
                [SNNotificationManager postNotificationName:kVideoWillStartDownloadIn2G3GNotification object:outterDownloadVideo];
            }
        }
    }
}

- (void)statDownloadAction:(SNVideoData *)videoModel {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = videoModel.channelId;
    _vStatModel.messageId = videoModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    [[WSMVVideoStatisticManager sharedIntance] statVideoPlayerActions:_vStatModel
                                                          actionsData:[NSMutableDictionary dictionaryWithObject:@(1) forKey:@"dwn"]];
}

@end
