//
//  SNRollingVideoCell.m
//  sohunews
//
//  Created by lhp on 5/7/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingVideoCell.h"
#import "SNVideoAdContext.h"
#import "SNRollingNewsTitleCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WSMVLoadingView.h"
#import "SNNewsAd+analytics.h"
#import "WSMVVideoPlayerView.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNADVideoCellAudioSession.h"

//lijian 2015.1.1 增加视频广告
@interface SNRollingVideoCell ()<SNCellMoreViewFullactionDelegate> {
    UIButton *playButton;
    UIButton *bgButton;
    SNImageView *cellImageView;
    WSMVLoadingView *indicatorView;
    SHMoviePlayerController *player;
    
    SNTimelineVideoCellContentView *cellContentView;
    
    UIView *_adAppBackgroundView;
    UILabel *_adAppLabel;
    UIView *_adAppLineView;
    UIButton *_adAppDownloadButton;
}

@property (nonatomic, strong) SNVideoData *playerData;

@end

@implementation SNRollingVideoCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    BOOL isMultLineTitle = [self isMultiLineTitleWithItem:newsItem];
    //这里对item.titleString赋值，所以不能删
    int titleHeight = [self getTitleHeightWithItem:newsItem isMultLine:isMultLineTitle];
    //by 5.9.4 wangchuanwen modify
    CGFloat cellHeight = CONTENT_TOP + titleHeight + VIDEO_CELL_PLAYERHEIGHT + MARKTEXT_HEIGHT + COMMENT_BOTTOM + 7 + CELLITEM_HEIGHT;
    //modify end
    if ([newsItem.news.templateType isEqualToString:@"77"]) {
        cellHeight += 42;//视频广告
    }
    return cellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        CGRect cellContentViewFrame = CGRectMake(CONTENT_LEFT, CONTENT_IMAGE_TOP, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT);
        cellContentView = [[SNTimelineVideoCellContentView alloc] initWithFrame:cellContentViewFrame];
        cellContentView.delegate = self;
        [self addSubview:cellContentView];
        
        self.showSlectedBg = NO;
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        detailButton.frame = CGRectMake(0, 0, 150, 35);
        detailButton.bottom = VIDEO_CELL_HEIGHT;
        [detailButton addTarget:self action:@selector(openVideoDetail) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:detailButton];
        [self initAdDownloadView];
    }
    return self;
}

- (void)initAdDownloadView {
    CGRect downloadViewRect = CGRectMake(CONTENT_LEFT, cellContentView.bottom, kAppScreenWidth - 2 * CONTENT_LEFT, 42);
    if (!_adAppBackgroundView) {
        _adAppBackgroundView = [[UIView alloc] initWithFrame:downloadViewRect];
        //by 5.9.4 wangchuanwen modify
        _adAppBackgroundView.backgroundColor = SNUICOLOR(kRefreshBgColor);
        //modify end
        _adAppBackgroundView.hidden = YES;
        [self addSubview:_adAppBackgroundView];
    }
    
    if (!_adAppLabel) {
        _adAppLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 0, _adAppBackgroundView.width - 136 / 2 - CONTENT_LEFT * 4, _adAppBackgroundView.height)];
        _adAppLabel.textColor = SNUICOLOR(kThemeText2Color);
        _adAppLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _adAppLabel.hidden = YES;
        [_adAppBackgroundView addSubview:_adAppLabel];
    }
    
    if (!_adAppLineView) {
        _adAppLineView = [[UIView alloc] initWithFrame:CGRectMake(_adAppBackgroundView.width -CONTENT_LEFT * 2 - 136 / 2, (84 - 56) / 4, 0.5, 56 / 2)];
        _adAppLineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        _adAppLineView.hidden = YES;
        [_adAppBackgroundView addSubview:_adAppLineView];
    }
    
    if (!_adAppDownloadButton) {
        _adAppDownloadButton = [[UIButton alloc] initWithFrame:CGRectMake(_adAppBackgroundView.width -CONTENT_LEFT - 136 / 2, (84 - 56) / 4, 136 / 2, 56 / 2)];
        _adAppDownloadButton.layer.cornerRadius = 2.0f;
        _adAppDownloadButton.layer.borderWidth = 0.5f;
        _adAppDownloadButton.layer.borderColor = SNUICOLOR(kThemeBlue1Color).CGColor;
        _adAppDownloadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _adAppDownloadButton.titleLabel.font = [UIFont systemFontOfSize:28 / 2.0f];
        [_adAppDownloadButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
        [_adAppDownloadButton addTarget:self action:@selector(clickDownloadButton) forControlEvents:UIControlEventTouchUpInside];
        _adAppDownloadButton.hidden = YES;
        [_adAppBackgroundView addSubview:_adAppDownloadButton];
    }
}

- (void)clickDownloadButton {
    if ([self.item.news.templateType isEqualToString:@"77"]) {
        if (self.item.news.newsAd.appLink && self.item.news.newsAd.appLink.length > 0) {
            self.item.news.newsAd.clicktype = @"1";
            [self.item.news.newsAd reportAdClick:self.item.news];
            [SNUtility openProtocolUrl:self.item.news.newsAd.appLink];
        }
    }
}

- (void)updateTheme {
    [super updateTheme];
    [self setNeedsDisplay];
    [self downloadUpdataTheme];
}

- (void)updateContentView {
    [super updateContentView];
    
    self.item.delegate = self;
    self.item.selector = @selector(didSelect);
    [self updateNewsContent];
    [self setReadStyleByMemory];
    
    if (self.video == self.item.news.video) {
        if (nil != self.playerData) {
            //by 5.9.4 wangchuanwen modify
            [cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, self.item.titleHeight + 12, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT) hiddenBottom:YES];
            //modify end
            [self updateAdDownloadView];
            if ([cellContentView isPaused]) {
                return;
            }
        }
        return;
    }
    
    [SNTimelineSharedVideoPlayerView forceStop];
    //刷新数据
    self.video = self.item.news.video;
    
    self.playerData = [[SNVideoData alloc] init];
    self.playerData.poster = self.video.pic;
    self.playerData.poster_4_3 = self.video.pic;
    self.playerData.videoUrl = [[SNVideoUrl alloc] init];
    if (self.item.news.channelId) {//@qz reportSite.go接口需要 因此加
        self.playerData.channelId = [NSString stringWithFormat:@"%@",self.item.news.channelId];
    }
    if (self.item.news.newsId) {//@qz reportSite.go接口需要 因此加
        self.playerData.newsId = [NSString stringWithFormat:@"%@",self.item.news.newsId];
    }
    if(self.item.news.newsType){//@qz reportSite.go接口需要 因此加
       self.playerData.newsType = [NSString stringWithFormat:@"%@",self.item.news.newsType];
    }
    if ([self.item.news.video.link hasSuffix:@"mp4"]) {
        self.playerData.videoUrl.mp4 = self.video.link;
    } else {
        self.playerData.videoUrl.m3u8 = self.video.link;
    }
    //by 5.9.4 wangchuanwen modify
    //item间距调整 cellContentView
    [cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, self.item.titleHeight + 12, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT) hiddenBottom:YES];
    //modify end
    [cellContentView setObject:self.playerData];//
    [self updateAdDownloadView];
}

- (void)downloadUpdataTheme {
    if ([self.item.news.templateType isEqualToString:@"77"]) {
        //by 5.9.4 wangchuanwen modify
        _adAppBackgroundView.backgroundColor = SNUICOLOR(kRefreshBgColor);
        //modify end
        _adAppLabel.textColor = SNUICOLOR(kThemeText2Color);
        _adAppLineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        _adAppDownloadButton.layer.borderColor = SNUICOLOR(kThemeBlue1Color).CGColor;
        [_adAppDownloadButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    }
}

- (void)updateAdDownloadView {
    if ([self.item.news.templateType isEqualToString:@"77"]) {
        _adAppBackgroundView.hidden = NO;
        _adAppBackgroundView.top = cellContentView.bottom;
        _adAppLabel.text = self.item.news.newsAd.advertiser;
        [_adAppDownloadButton setTitle:@"立即下载" forState:UIControlStateNormal];
        _adAppLabel.hidden = NO;
        _adAppLineView.hidden = NO;
        _adAppDownloadButton.hidden = NO;
    } else {
        _adAppBackgroundView.hidden = YES;
        _adAppLabel.hidden = YES;
        _adAppLineView.hidden = YES;
        _adAppDownloadButton.hidden = YES;
    }
}

//kPushViewControllerNotification
- (void)clickPlayButton:(SNVideoData *)data {
    [SNADVideoCellAudioSession sharedInstance].isADVideo = YES;
    
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
    if(NO == [cellContentView isFullScreen]){
        //by 5.9.4 wangchuanwen modify
        [cellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, self.item.titleHeight + 12, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT) hiddenBottom:YES];
    }
    
    //广告点击曝光
    if (self.item.type == NEWS_ITEM_TYPE_AD) {
        [self.item.news.newsAd reportAdVideoPlay:self.item.news];
        self.item.news.newsAd.isReportedStartVP = YES;
        self.item.news.newsAd.isReportedEndVP = NO;
    }
}

- (void)autoPlay {
    SNTimelineSharedVideoPlayerView *play = [SNTimelineSharedVideoPlayerView sharedInstance];
    SNAutoPlaySharedVideoPlayer *videoPlayer = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (/*[videoPlayer getMoviePlayer].playbackState != SHMoviePlayStatePlaying &&*/
        play.moviePlayer) {
        if ([videoPlayer getMoviePlayer].playbackState == SHMoviePlayStatePlaying) {
            [SNAutoPlaySharedVideoPlayer forceStopVideo];
        }
        
        [SNADVideoCellAudioSession sharedInstance].isADVideo = YES;
        
        [cellContentView autoPlayVideo];
    }
}

- (void)didFinishPlayVideo {
    if (self.item.news.newsAd.isReportedEndVP == YES) {
        return;
    }
    if (self.item.type == NEWS_ITEM_TYPE_AD) {
        [self.item.news.newsAd reportAdVideoFinishedPlay:self.item.news];
        self.item.news.newsAd.isReportedEndVP = YES;
        self.item.news.newsAd.isReportedStartVP = NO;
    }
}

- (void)didStop {
    self.item.news.newsAd.isReportedStartVP = NO;
}

- (void)fullScreenMode {
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
    if ([cellContentView isPaused] ||
        [cellContentView isPlaying] ||
        [cellContentView isLoading]) {
        [cellContentView videoToFullScreen];
    } else {
        [cellContentView fullscreenAction:nil];
    }
}

- (void)didDisplay {
}

- (void)autoPlayInWifi {
    BOOL isWifi = ((![SNUtility isNetworkWWANReachable]) && [SNUtility isNetworkReachable]);
    if (isWifi) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 500), dispatch_get_main_queue(), ^{
            [cellContentView playVideoManually];
        });
        MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
        mpc.volume = 0;
        
    }
}

- (void)moreAction {
    [super moreAction];
    if (self.moreView) {
        self.moreView.fullActionDelegate = self;
    }
}

- (void)fullScreenEnjoy {
    [self fullScreenMode];
}

- (void)didSelect {
    if (self.item.news.newsAd.h5Link.length > 0) {
        NSString *link = self.item.news.newsAd.h5Link;
        if (self.item.news.newsAd.predownload && self.item.news.newsAd.predownload.length > 0) {
            link = [link stringByAppendingString:[NSString stringWithFormat:@"predownload:%@", item.news.newsAd.predownload]];
            [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:FullScreenADWebViewType], kUniversalWebViewType, nil]];
        } else {
            [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:AdvertisementWebViewType], kUniversalWebViewType, nil]];
        }
        if ([self.item.news.templateType isEqualToString:@"77"]) {
            self.item.news.newsAd.clicktype = @"0";
        }
        [self.item.news.newsAd reportAdClick:self.item.news];
    }
}

- (void)uninterested {
    [cellContentView pause];
    [super uninterested];
}

//查看详情 视频广告
- (void)openVideoDetail {
    if (self.item.news.newsAd.h5Link.length > 0) {
        NSString *link = item.news.link;
        if (item.news.newsAd.predownload && item.news.newsAd.predownload.length > 0) {
            link = [link stringByAppendingString:[NSString stringWithFormat:@"predownload:%@", item.news.newsAd.predownload]];
            [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:FullScreenADWebViewType], kUniversalWebViewType, nil]];
        } else {
            [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:AdvertisementWebViewType], kUniversalWebViewType, nil]];
        }

        [self.item.news.newsAd reportAdClick:self.item.news];
    }
}

- (void)dealloc {
    [cellContentView pause];
}

#pragma mark - 屏幕旋转
#pragma mark - Private
#pragma mark - Rotation
- (void)beginMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications];
    //Tell it to start monitoring the accelerometer for orientation
    [SNNotificationManager addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)endMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [SNNotificationManager removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
    [device endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)notification {
    //是否要响应旋转
    id obj = notification.object;
    if ([obj isKindOfClass:[UIDevice class]]) {
        UIDeviceOrientation o = [(UIDevice *)obj orientation];
        switch (o) {
            case UIDeviceOrientationPortrait: {
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown: {
                break;
            }
            case UIDeviceOrientationLandscapeLeft: {
                break;
            }
            case UIDeviceOrientationLandscapeRight: {
                break;
            }
            default:
                break;
        }
        
        //没有播放则不能自动全屏
        BOOL isStopped = !([SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel);
        if (isStopped) {
            SNDebugLog(@"Neednt rotate, player view is stopped.");
            return;
        }
        
        //已转为横屏：
        if ((o == UIDeviceOrientationLandscapeLeft || o == UIDeviceOrientationLandscapeRight)
            && ![cellContentView isFullScreen]
            && ([cellContentView isPlaying] || [cellContentView isPaused] || [cellContentView isLoading])) {
            [cellContentView videoToFullScreen];
        }
        
        //已转为竖屏：如果当前是全屏，则变为竖屏时则自动恢复到非全屏
        if ((o == UIDeviceOrientationPortrait || o == UIDeviceOrientationPortraitUpsideDown)
            && [cellContentView isFullScreen]) {
            [cellContentView videoExitFullScreen];
        }
    }
}

@end
