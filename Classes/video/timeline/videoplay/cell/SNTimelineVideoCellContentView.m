//
//  SNTimelineVideoCellContentView.m
//  sohunews
//
//  Created by handy wang on 11/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTimelineVideoCellContentView.h"
#import "SNVideosCheckService.h"
#import "SNTimelineTrendObjects.h"
#import "SNVideoDetailRecommendModel.h"
#import "UIImageView+WebCache.h"
#import "SNTimelineVideoCellTitleView.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "WSMVVideoStatisticManager.h"
#import "WSMVVideoStatisticModel.h"
#import "SNWebImageView.h"
#import "SNVideoDownloadManager.h"
#import "SNMyFavouriteManager.h"
#import "SNDBManager.h"
#import "SNCheckManager.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNUserManager.h"
#import "SNShareConfigs.h"
#import "SNVideoAdContext.h"
#import "SNToast.h"

#import "SNTripletsLoadingView.h"
#import "SNWebImageView.h"
#import "SNVideoAdContext.h"
#import "UIFont+Theme.h"
#import "SNAutoPlayVideoContentView.h"
#import "SNNewAlertView.h"
#import "SNNewsShareManager.h"

#define kVideoMediaPortalFontSize           (22/2)
#define kVideoMediaPortalLeftSideMargin     (44/2.0f)
#define kVideoMediaPortalInitialWidth       (150/2.0f)
#define kVideoBottomActionBtnWidth          (64/2.0f)
#define kVideoBottomActionBtnHeight         (64/2.0f)
#define kVideoBottomActionBtnHPadding       (12.0f/2.0f)
#define kVideoBottomActionBtnMarginToPosterRight    (6.0f)
#define kVideoBottomActionBtnTopInset       (5.0f)
#define kExtendedWidthForFullScreenBtn      (15.0f)
#define kExtendedWidthForDownloadBtn        (25.0f)
#define kTitleViewHeight                    (286/2.0f)
#define kCopyRightLabelFontSize             (10.0f)
#define kCopyRightLabelHeight               (22.0f)
#define kCopyRightLabelLeft                 (5.0f)
#define kCopyRightLabelWidth                (342/2.0f)
#define kBottomMaskViewHeight               (88/2.0f)
#define kVideoMediaPortalAccessoryWidth     (10)
#define kVideoMediaPortalAccessoryInsetLeft (2)

@interface SNTimelineVideoCellContentView() <SNActionMenuControllerDelegate/*, SNClickItemOnHalfViewDelegate*/>

@property (nonatomic, retain) UIImageView *bgView;
@property (nonatomic, retain) SNWebImageView *poster;
@property (nonatomic, retain) UIImageView *logoImgView;
@property (nonatomic, retain) SNTimelineVideoCellTitleView *titleView;
@property (nonatomic, retain) UIImageView *bottomMaskView;
@property (nonatomic, retain) UIButton *posterPlayBtn;
@property (nonatomic, retain) UILabel *siteNameLabel;
@property (nonatomic, retain) UILabel *videoCopyRightLabel;
@property (nonatomic, retain) UILabel *durationLabel;
@property (nonatomic, retain) UIButton *videoMediaPortal;
@property (nonatomic, retain) UIButton *downloadBtn;
@property (nonatomic, retain) UIButton *shareBtn;
@property (nonatomic, retain) UIButton *fullscreenBtn;
@property (nonatomic, retain) SNActionMenuController *actionMenuController;
@property (nonatomic, retain) SNNewsShareManager* shareManager;
@property (nonatomic, retain) SNVideoDetailRecommendModel *recommendModel;
@property (nonatomic, retain) NSMutableArray *recommendVideos;
@property (nonatomic, retain) SNVideoData *willSharedVideo;
@property (nonatomic, retain) UILabel *msgLabel;
@property (nonatomic, strong) UIImageView *playNightMode;

@end

@implementation SNTimelineVideoCellContentView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //RecommendVideos
        self.recommendVideos = [NSMutableArray array];
        _isToFullScreen = NO;
        
        //Cell bgview
        CGRect bgViewFrame = CGRectMake(kTimelineCellBgViewSideMargin,
                                        kTimelineVideoCellSubContentViewsTopMargin,
                                        kAppScreenWidth - 2 *  kTimelineCellBgViewSideMargin,
                                        kTimelineVideoCellSubContentViewsHeight);
        _bgView = [[UIImageView alloc] initWithFrame:bgViewFrame];
        _bgView.image = [[UIImage imageNamed:@"timeline_videoplay_cellbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
        [self addSubview:_bgView];

        //Poster
        CGRect posterFrame = CGRectMake(kTimelineVideoCellSubContentViewsSideMargin,
                                        kTimelineVideoCellSubContentViewsTopMargin,
                                        kTimelineContentViewWidth,
                                        kPlayerViewHeight);
        _poster = [[SNWebImageView alloc] initWithFrame:posterFrame];
        _poster.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _poster.userInteractionEnabled = YES;
        _poster.contentMode = UIViewContentModeScaleAspectFill;
        _poster.clipsToBounds = YES;
        _poster.backgroundColor = [UIColor colorFromString:@"#e5e5e5"];
        [self addSubview:_poster];
        
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(posterTap:)];
        [_poster addGestureRecognizer:singleTap];
        
        //Logo image view
        _logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 140.f, 38.f)];
        _logoImgView.image = [UIImage imageNamed:@"videoplayer_nonfullscreen_posterlogo.png"];
        _logoImgView.backgroundColor = [UIColor clearColor];
        _logoImgView.center = self.poster.center;
        [_poster insertSubview:_logoImgView atIndex:0];
        
        //Poster button
        self.posterPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.posterPlayBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.posterPlayBtn.backgroundColor = [UIColor clearColor];
        self.posterPlayBtn.frame = CGRectMake(0, 0, 46, 46);
        self.posterPlayBtn.center = self.poster.center;
        [self.posterPlayBtn setImage:[UIImage imageNamed:@"icohome_ad_play_v5.png"] forState:UIControlStateNormal];
        [self.posterPlayBtn addTarget:self action:@selector(playVideoManually) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.posterPlayBtn];
        
        //SiteName
        CGRect siteNameLabelFrame = CGRectMake(0, 0, _poster.width-kTimelineSiteNameAndDurationLRMarginToPosterLRSide, kTimelineSiteNameAndDurationHeight);
        _siteNameLabel = [[UILabel alloc] initWithFrame:siteNameLabelFrame];
        _siteNameLabel.left = _poster.left+kTimelineSiteNameAndDurationLRMarginToPosterLRSide;
        _siteNameLabel.bottom = _poster.bottom-kTimelineSiteNameAndDurationHeight;
        _siteNameLabel.backgroundColor = [UIColor clearColor];
        _siteNameLabel.textColor = [UIColor whiteColor];
        _siteNameLabel.textAlignment = NSTextAlignmentLeft;
        _siteNameLabel.font = [UIFont systemFontOfSize:kTimelineSiteNameAndDurationFontSize];
        _siteNameLabel.hidden = YES;
        [self addSubview:_siteNameLabel];
        
        //Copyright label
        CGRect copyRightLabelFrame = CGRectMake(0, 0, kCopyRightLabelWidth, kCopyRightLabelHeight);
        _videoCopyRightLabel = [[UILabel alloc] initWithFrame:copyRightLabelFrame];
        _videoCopyRightLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _videoCopyRightLabel.left = _poster.left+kCopyRightLabelLeft;
        _videoCopyRightLabel.bottom = _poster.bottom-5;
        _videoCopyRightLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _videoCopyRightLabel.textColor = [UIColor whiteColor];
        _videoCopyRightLabel.textAlignment = NSTextAlignmentLeft;
        _videoCopyRightLabel.font = [UIFont systemFontOfSize:kCopyRightLabelFontSize];
        _videoCopyRightLabel.hidden = YES;
        [self addSubview:_videoCopyRightLabel];
        
        //Duration
        CGRect durationLabelFrame = CGRectMake(0, 0, _poster.width-kTimelineSiteNameAndDurationLRMarginToPosterLRSide, kTimelineSiteNameAndDurationHeight);
        _durationLabel = [[UILabel alloc] initWithFrame:durationLabelFrame];
        _durationLabel.right = _poster.right-kTimelineSiteNameAndDurationLRMarginToPosterLRSide;
        _durationLabel.bottom = _poster.bottom-kTimelineSiteNameAndDurationHeight;
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.font = [UIFont systemFontOfSize:kTimelineSiteNameAndDurationFontSize];
        [self addSubview:_durationLabel];
        
        //Author name label
        CGRect videoMediaPortalFrame =
        CGRectMake(kVideoMediaPortalLeftSideMargin + fabsf(kVideoMediaPortalAccessoryInsetLeft), _poster.bottom, kVideoMediaPortalInitialWidth, kTimelineVideoCellHeight - 2 * kTimelineVideoCellSubContentViewsTopMargin - _poster.height);
        self.videoMediaPortal = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoMediaPortal.frame = videoMediaPortalFrame;
        _videoMediaPortal.backgroundColor = [UIColor clearColor];
        _videoMediaPortal.titleLabel.font = [UIFont systemFontOfSize:kVideoMediaPortalFontSize];

        [_videoMediaPortal setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTimelineVideoMediaPortalNormalColor]] forState:UIControlStateNormal];
        [_videoMediaPortal setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTimelineVideoMediaPortalPressColor]] forState:UIControlStateHighlighted];
        [_videoMediaPortal setImage:[UIImage imageNamed:@"timeline_videomediaportal_btn_accessory.png"] forState:UIControlStateNormal];
        [_videoMediaPortal setImage:[UIImage imageNamed:@"timeline_videomediaportal_btn_accessory_press.png"] forState:UIControlStateHighlighted];
        [_videoMediaPortal setImageEdgeInsets:UIEdgeInsetsMake(0, kVideoMediaPortalAccessoryInsetLeft-kVideoMediaPortalAccessoryWidth, 0, 0)];
        _videoMediaPortal.userInteractionEnabled = NO;
        [self addSubview:_videoMediaPortal];

        //Fullscreen btn
        self.fullscreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullscreenBtn.frame = CGRectMake(kAppScreenWidth - 10 - kVideoBottomActionBtnMarginToPosterRight - kVideoBottomActionBtnWidth, _poster.bottom, kVideoBottomActionBtnWidth + kExtendedWidthForFullScreenBtn, kVideoBottomActionBtnHeight + 2 * kVideoBottomActionBtnTopInset);
        _fullscreenBtn.imageEdgeInsets = UIEdgeInsetsMake(kVideoBottomActionBtnTopInset, 0, kVideoBottomActionBtnTopInset, kExtendedWidthForFullScreenBtn);
        _fullscreenBtn.accessibilityLabel = @"全屏观看视频";
        [_fullscreenBtn setImage:[UIImage imageNamed:@"timeline_videoplay_fullscreen_btn.png"] forState:UIControlStateNormal];
        [_fullscreenBtn setImage:[UIImage imageNamed:@"timeline_videoplay_fullscreen_btn_press.png"] forState:UIControlStateHighlighted];
        [_fullscreenBtn addTarget:self action:@selector(fullscreenAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_fullscreenBtn];
        
        //Share btn
        self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.frame = CGRectMake(_fullscreenBtn.left - kVideoBottomActionBtnHPadding - kVideoBottomActionBtnWidth, _poster.bottom, kVideoBottomActionBtnWidth, kVideoBottomActionBtnHeight + 2 * kVideoBottomActionBtnTopInset);
        _shareBtn.imageEdgeInsets = UIEdgeInsetsMake(kVideoBottomActionBtnTopInset, 0, kVideoBottomActionBtnTopInset, 0);
        _shareBtn.accessibilityLabel = @"分享视频";
        [_shareBtn setImage:[UIImage imageNamed:@"timeline_videoplay_share.png"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"timeline_videoplay_sharepress.png"] forState:UIControlStateHighlighted];
        [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareBtn];
        
        //DownloadBtn
        self.downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadBtn.frame = CGRectMake(_shareBtn.left - kVideoBottomActionBtnHPadding - kVideoBottomActionBtnWidth - kExtendedWidthForDownloadBtn, _poster.bottom, kVideoBottomActionBtnWidth + kExtendedWidthForDownloadBtn, kVideoBottomActionBtnHeight + 2 * kVideoBottomActionBtnTopInset);
        _downloadBtn.imageEdgeInsets = UIEdgeInsetsMake(kVideoBottomActionBtnTopInset, kExtendedWidthForDownloadBtn, kVideoBottomActionBtnTopInset, 0);
        _downloadBtn.accessibilityLabel = @"下载视频";
        [_downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_download.png"] forState:UIControlStateNormal];
        [_downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_download_hl.png"] forState:UIControlStateHighlighted];
        [_downloadBtn addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
        _downloadBtn.hidden = YES;
        [self addSubview:_downloadBtn];
        
        //Msg label
        _msgLabel = [[UILabel alloc] initWithFrame:self.videoCopyRightLabel.frame];
        _msgLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _msgLabel.width = self.poster.width - 2 * kCopyRightLabelLeft;
        _msgLabel.left = self.poster.left + kCopyRightLabelLeft;
        _msgLabel.bottom = self.videoCopyRightLabel.bottom;
        _msgLabel.backgroundColor = [UIColor colorWithRed:0
                                                    green:0 blue:0 alpha:0.8];
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = [UIFont systemFontOfSize:kCopyRightLabelFontSize];
        _msgLabel.hidden = YES;
        [self addSubview:_msgLabel];
        
        //Notification observer
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleRecommendModelDidFinishLoad:) name:kSNVideoDetialRecommendModelDidFinishLoadNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleReachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
        
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    [self.recommendModel cancelRequest];
    self.recommendModel.delegate = nil;
    self.object = nil;
    
    _actionMenuController.delegate = nil;
    self.msgLabel = nil;
}

- (void)posterTap:(UIGestureRecognizer *)gesture
{
    
}

#pragma mark - Public
- (void)setObject:(SNVideoData *)object {
    self.hidden = NO;
    if (object && object != _object) {
        _object = object;
    
        //Author name
        NSString *videoMediaPortalText = nil;
        //1社交媒体、3搜狐视频推荐
        if (object.author.type == VideoAuthorType_SocialMedia ||
            object.author.type == VideoAuthorType_SohuRecommend) {
            videoMediaPortalText = object.author.name;
        }
        //0机构自媒体、2个人自媒体
        else {
            videoMediaPortalText = object.columnName;
        }
        [_videoMediaPortal setTitle:videoMediaPortalText forState:UIControlStateNormal];
        if (videoMediaPortalText.length > 0) {
            CGSize videoMediaPortalTextSize = [videoMediaPortalText sizeWithFont:[UIFont systemFontOfSize:kVideoMediaPortalFontSize]
                                                   constrainedToSize:CGSizeMake(NSIntegerMax, _videoMediaPortal.height)
                                         ];
            _videoMediaPortal.width = videoMediaPortalTextSize.width + kVideoMediaPortalAccessoryWidth;
        }
        
        //提示
        if (self.object.playType == WSMVVideoPlayType_HTML5) {
            self.videoCopyRightLabel.hidden = NO;
            self.siteNameLabel.hidden = YES;
            
            NSString *copyrightText = NSLocalizedString(@"timeline_video_copyright_msg", nil);
            [self setCopyRightLabelWidthBy:copyrightText];
            self.videoCopyRightLabel.text = copyrightText;
        }
        //来源
        else {
            self.siteNameLabel.hidden = NO;
            self.videoCopyRightLabel.hidden = YES;
            
            NSString *siteName = @"";
            if (_object.siteInfo.siteName.length > 0) {
                siteName = [NSString stringWithFormat:NSLocalizedString(@"timeline_videoplay_sitename", nil), _object.siteInfo.siteName];
            }
            _siteNameLabel.text = siteName;
        }
        
        //播放时长
        _durationLabel.text = [SNUtility getHumanReadableTime:self.object.duration];
        if (self.object.duration <= 0) {
            _durationLabel.hidden = YES;
        } else {
            _durationLabel.hidden = NO;
        }
        
        _object.hadLoadRecommendVideos = NO;
        [self.recommendVideos removeAllObjects];
        [self.recommendModel cancelRequest];
        self.recommendModel.delegate = nil;
        self.recommendModel = nil;
        
        __weak __typeof(&*self)weakSelf = self;
        self.logoImgView.hidden = NO;
        [self.poster setUrlPath:self.object.poster_4_3 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (nil != image) {
                weakSelf.logoImgView.hidden = YES;
            } else {
                weakSelf.logoImgView.hidden = NO;
            }
        }];
        self.poster.alpha = themeImageAlphaValue();
        
        //1社交媒体、3搜狐视频推荐
        if (object.author.type == VideoAuthorType_SocialMedia ||
            object.author.type == VideoAuthorType_SohuRecommend) {
            [self.titleView updateTitle:self.object.title subTitle:nil];
        }
        //0机构自媒体、2个人自媒体
        else {
            [self.titleView updateTitle:self.object.title subTitle:nil];
        }
        
        self.msgLabel.hidden = YES;
        
        //全屏按钮
        [self updateFullscreenBtn];
        
        [self updateDownloadBtn];
        
        //无障碍阅读
        if (self.object.title.length > 0) {
            self.posterPlayBtn.accessibilityLabel = self.object.title;
        } else {
            self.posterPlayBtn.accessibilityLabel = @"视频，连按两次来播放或暂停";
        }
    }
}

- (void)updateDownloadBtn {
    [self updateDownloadBtnForVideo:self.object];
}

- (void)updateDownloadBtnForVideo:(SNVideoData *)video {
    BOOL support = [[SNCheckManager sharedInstance] supportVideoDownload];
    //App禁用视频下载功能
    if (!support) {
        self.downloadBtn.hidden = YES;
        self.downloadBtn.left = _shareBtn.left - kVideoBottomActionBtnHPadding - kVideoBottomActionBtnWidth - kExtendedWidthForDownloadBtn;
    }
    //App开启视频下载功能
    else {
        self.downloadBtn.hidden = NO;
        self.downloadBtn.left = _shareBtn.left - kVideoBottomActionBtnHPadding - kVideoBottomActionBtnWidth - kExtendedWidthForDownloadBtn;
    }
    
    //当前视频不让下载
    if (video.downloadType != WSMVVideoDownloadType_CanDownload ||
        video.playType != WSMVVideoPlayType_Native) {
        [self.downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_cant_download.png"] forState:UIControlStateNormal];
        [self.downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_cant_download.png"] forState:UIControlStateHighlighted];
    }
    //当前视频可以下载
    else {
        [self.downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_download.png"] forState:UIControlStateNormal];
        [self.downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_download_hl.png"] forState:UIControlStateHighlighted];
    }
    
    //李健 2014.12.31 没办法的权宜之计，为了隐藏下面栏
    if (YES == _bgView.hidden) {
        self.downloadBtn.hidden = YES;
        self.videoMediaPortal.hidden = YES;
        self.fullscreenBtn.hidden = YES;
        self.shareBtn.hidden = YES;
    }
}

- (void)updateFullscreenBtn {
    //Visible or not
    BOOL autoplayTimeline = [[SNVideosCheckService sharedInstance] autoPlayTimelineVideos];
    BOOL canTimelineToDetailPage = [[SNVideosCheckService sharedInstance] canTimelineToDetailPage];
    if (!autoplayTimeline && canTimelineToDetailPage) {
        self.fullscreenBtn.hidden = YES;
        self.shareBtn.left = self.fullscreenBtn.left;
        self.downloadBtn.left = _shareBtn.left - kVideoBottomActionBtnHPadding - kVideoBottomActionBtnWidth - kExtendedWidthForDownloadBtn;
    } else {
        self.fullscreenBtn.hidden = NO;
        self.shareBtn.left = self.fullscreenBtn.left - kVideoBottomActionBtnHPadding - kVideoBottomActionBtnWidth;
        self.downloadBtn.left = _shareBtn.left - kVideoBottomActionBtnHPadding - kVideoBottomActionBtnWidth - kExtendedWidthForDownloadBtn;
    }
}

- (void)setCopyRightLabelWidthBy:(NSString *)text {
    if (text.length <= 0) {
        return;
    }
    
    UIFont *copyRightTextFont = [UIFont systemFontOfSize:kCopyRightLabelFontSize];
    CGSize constrainedSize = CGSizeMake(_poster.width - 2 * kCopyRightLabelLeft,
                                        kCopyRightLabelHeight);
    CGSize copyRightLabelSize = [text sizeWithFont:copyRightTextFont constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat copyRightLabelWidth = copyRightLabelSize.width + 4;
    if (copyRightLabelWidth > _poster.width - 2 * kCopyRightLabelLeft) {
        copyRightLabelWidth = _poster.width - 2 * kCopyRightLabelLeft;
    }
    self.videoCopyRightLabel.width = copyRightLabelWidth;
}

#pragma mark - Public
- (void)playVideoIfNeeded {
    BOOL autoplayTimeline = [[SNVideosCheckService sharedInstance] autoPlayTimelineVideos];
    NetworkStatus _netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    BOOL timelinePausedManually = [[SNTimelineSharedVideoPlayerView sharedInstance] isPausedManually];
    
    if (!timelinePausedManually &&
        autoplayTimeline &&
        _netStatus == ReachableViaWiFi) {
        [self playVideo];
        [self showMsgForAutoPlayTimelineVideoFirstTimeInWifi];
    }
}

- (void)playVideoIfNeededIn2G3G {
    [self playVideo];
}

- (void)playVideoManually {
    BOOL autoplayTimeline = [[SNVideosCheckService sharedInstance] autoPlayTimelineVideos];
    BOOL canTimelineToDetailPage = [[SNVideosCheckService sharedInstance] canTimelineToDetailPage];
    
    if (self.object.playType == WSMVVideoPlayType_HTML5) {
        [self toWapPage];
    }
    //如果是关闭自动播放且要进入Detail页面播放则打开播放页
    else if (!autoplayTimeline && canTimelineToDetailPage) {
        [SNTimelineSharedVideoPlayerView fakeStop];
        [SNTimelineSharedVideoPlayerView forceStop];
        [self toVideoDetailPage];
    } else {
        [self playVideo];
    }
}

- (void)autoPlayVideo {
    BOOL isWifi = ((![SNUtility isNetworkWWANReachable]) &&
                   [SNUtility isNetworkReachable]);
    if (isWifi && [SNUtility channelVideoSwitchStatus]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kIsAutoPlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self playVideoManually];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kVideoFirstPlayToast]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVideoFirstPlayToast];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"WiFi下自动播放视频" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
}

- (void)updatePlayNightMode {
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        [self.playNightMode removeFromSuperview];
        self.playNightMode = nil;
        if (nil == self.playNightMode) {
            self.playNightMode = [[UIImageView alloc] initWithFrame:player.frame];
            self.playNightMode.backgroundColor = [UIColor blackColor];
            self.playNightMode.alpha = 0.5;
            [self.superview addSubview:self.playNightMode];
        }

    } else {
        if ([self.playNightMode superview]) {
            [self.playNightMode removeFromSuperview];
        }
    }
}

- (void)playVideo {
    if (self.object.playType == WSMVVideoPlayType_HTML5) {
        return;
    }
    
    BOOL autoplayTimeline = [[SNVideosCheckService sharedInstance] autoPlayTimelineVideos];
    BOOL canTimelineToDetailPage = [[SNVideosCheckService sharedInstance] canTimelineToDetailPage];
    if (!autoplayTimeline && canTimelineToDetailPage) {
        return;
    }
    
    [SNTimelineSharedVideoPlayerView sharedInstance].isPausedManually = NO;
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self initPlayer];
    
    //清除AutoPlayVideoContentView
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
    
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    [player playCurrentVideo];
    [player setNeedsDisplay];//解决下拉刷新再播放时一直黑屏但有声音
    
    //load recommend
    [self.recommendModel cancelRequest];
    self.recommendModel.delegate = nil;

    if (!!(self.object) && !(self.object.hadLoadRecommendVideos)) {
        self.recommendModel = [[SNVideoDetailRecommendModel alloc] initRecomemndModelWithMid:self.object.messageId];
        self.recommendModel.delegate = self;
        [self.recommendModel loadRecommendVideosFromServer];
    } else if (self.object.hadLoadRecommendVideos &&
               self.recommendVideos.count > 0) {
        SNTimelineSharedVideoPlayerView *videoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
        [videoPlayer replaceAllPlaylist:self.recommendVideos];
        [videoPlayer replaceAllRecommendVieos:self.recommendVideos];
    }
}

- (void)initPlayer {
    [[SNVideoAdContext sharedInstance] setCurrentVideoAdPosition:SNVideoAdContextCurrentVideoAdPosition_VideoTimeline];
    
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    
    //sPlayID即连播ID，横流的连播ID相同即第一个视频(Timeline视频)的vid，一旦sPlayID不一样了说明要换成另一个cell开始播放了
    //sPlayID相同，则可以从上一次的暂停处继续播，实际场景为：分享presentViewController时player内部会通过通知暂停，但是分享完后应该继续从暂停处播放。
    if (![player.playingVideoModel.sPlayID isEqualToString:self.object.vid]) {
        [SNTimelineSharedVideoPlayerView forceStop];
        //NSLog(@"channel:%@",self.object.channelId);
        self.object.sPlayID = self.object.vid;
        [player initPlaylist:[NSArray arrayWithObject:self.object] initPlayingIndex:0];
        [player showTitleAndControlBarWithAnimation:NO];
        if (!self.object.isNewsVideo) {
            [player hideNonFullScreenControlBar];
            player.isNewsVideo = NO;
        } else {
            player.isNewsVideo = YES;
        }
        if ([self superview]) {
            [self.superview addSubview:player];
        }
        [self updatePlayNightMode];
    }
    player.delegate = self;
}

- (void)stopVideoPlayIfPlaying {
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    /**
     * 多判断(!player.playingVideoModel)原因是为了解决Bug:
     * Ticket #35688 (assigned bug) [搜狐新闻_iOS]_4.3.2_视频广告：加载视频频道内容后快速滑动至视频广告处，仍在播放第一个视频的声音。
     * 详细描述: Timeline里前两个是视频第三个是视频换量模板，当第一个视频在loading时快速向上滑动到视频换量模板，此时第一个视频就会播放。
     * 出现此Bug的原因: 第一个视频loading时一旦滑出屏幕则stopVideoPlayIfPlaying并把播放器的视频对象回收，但此时播放器还在加载并没有开始播放工作, 等滑动到视频换量模板时视频加载完并播放。其实在从第一个视频滑动到换量模板的过程中一直会调用stopVideoPlayIfPlaying, 但由于之前stopVideoPlayIfPlaying调用到，视频对象已经被回收也就进不了下面的逻辑。
     *   所以，这里多加一个判断：当播放器的视频对象空的时候再多fakeStop一下，确保之前第一个视频在播放器内部加载回来后也不要播放了
     */
    if ([player.playingVideoModel.sPlayID isEqualToString:self.object.vid] ||
        !player.playingVideoModel) {
        SNDebugLog(@"Stop play video for ending display cell.");
        [SNTimelineSharedVideoPlayerView fakeStop];
    }
}

- (BOOL)isFullScreen {
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    return [player isFullScreen];
}

- (BOOL)isPlaying {
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    return [player isPlaying];
}

- (BOOL)isPaused {
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    return [player isPaused];
}

- (BOOL)isLoading {
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    return [player isLoading];
}

- (void)videoToFullScreen {
    //如果进入全屏时分享的ActionSheet是显示着的就把它关了
    [SNNotificationManager postNotificationName:kHideActionMenuViewNotification object:nil];
    
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    [player toFullScreen];
}

- (void)videoExitFullScreen {
    _isToFullScreen = NO;
    //如果进入全屏时分享的ActionSheet是显示着的就把它关了
    [SNNotificationManager postNotificationName:kHideActionMenuViewNotification object:nil];
    
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    [player exitFullScreen];
    
    [[SNToast shareInstance] hideToast];
}

//lijian 2015.1.1 增加视频广告重新布局播放器
- (void)resetPlayerViewFrame:(CGRect)frame hiddenBottom:(BOOL)hidden {
    self.frame = frame;
    _isAdVideo = YES;
    _bgView.hidden = hidden;
    _videoMediaPortal.hidden = hidden;
    _fullscreenBtn.hidden = hidden;
    _shareBtn.hidden = hidden;
    _downloadBtn.hidden = hidden;
    _poster.frame = self.bounds;
    _logoImgView.center = _poster.center;
    _posterPlayBtn.frame = CGRectMake(0, 0, 46, 46);
    _posterPlayBtn.center = self.poster.center;
    
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    player.delegate = self;
    player.frame = frame;
    //lijian 20170911 李红力修改方案，解决黑屏问题，pgc视频和流内广告视频同在时有相互影响
    //player.moviePlayer.view.frame = player.bounds;
    //player.loadingMaskView.loadingView.center = player.moviePlayer.view.center;
    [player getMoviePlayer].view.frame = player.bounds;
    player.loadingMaskView.loadingView.center = [player getMoviePlayer].view.center;
}

- (void)pause {
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    return [player pause];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)didPlayToEnd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishPlayVideo)]) {
        [self.delegate performSelector:@selector(didFinishPlayVideo)];
    }
}
#pragma clang diagnostic pop

#pragma mark -
- (void)showMsgForAutoPlayTimelineVideoFirstTimeInWifi {
    BOOL timelineVideoHadEverAutoPlayInWifi = [[NSUserDefaults standardUserDefaults] boolForKey:kTimelineVideoHadEverAutoPlayInWifi];
    if (!timelineVideoHadEverAutoPlayInWifi) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"timeline_video_firsttime_autoplay_wifi", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTimelineVideoHadEverAutoPlayInWifi];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toWapPage {
    [SNTimelineSharedVideoPlayerView fakeStop];
    [SNTimelineSharedVideoPlayerView forceStop];

    NSString *_url = self.object.wapUrl;
    if (![SNAPI isWebURL:[_url lowercaseString]]) {
        _url = [[SNAPI rootScheme] stringByAppendingString:_url];
    }
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:_url forKey:@"address"];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

- (void)toVideoDetailPage {
    if ([self.delegate respondsToSelector:@selector(toVideoDetailPage:)]) {
        [self.delegate toVideoDetailPage:self.object];
    }
}

#pragma mark - Private
#pragma mark - Video media
- (void)toVideoMedia:(UIButton *)btn {
    [SNTimelineSharedVideoPlayerView fakeStop];
    [SNTimelineSharedVideoPlayerView forceStop];
    
    NSString *mediaLink = nil;
    if (self.object.mediaLink.length > 0) {
        mediaLink = self.object.mediaLink;
    } else if (self.object.columnId > 0) {
        mediaLink = [NSString stringWithFormat:@"%@columnId=%d", kProtocolVideoMidia, self.object.columnId];
    }
    
    if (mediaLink.length > 0) {
        if ([SNPreference sharedInstance].debugModeEnabled) {
            NSDictionary *parsedRst = [SNUtility parseURLParam:mediaLink schema:kProtocolVideoMidia];
            NSLogFatal(@"To media page, subId is %@", [parsedRst objectForKey:kSubId]);
        }
        [SNUtility openProtocolUrl:mediaLink context:nil];
        
        if (self.object.siteInfo.siteId.length > 0) {
            NSDictionary *siteIdInfo = @{@"siteId": self.object.siteInfo.siteId};
            mediaLink = [siteIdInfo appendParamToUrlString:mediaLink];
        }
        
        //CC统计
        SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_video link2:nil];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:video_media link2:mediaLink];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
}

#pragma mark - Notification handle
- (void)handleReachabilityChangedNotification:(NSNotification *)notification {
    Reachability *currentReach = [notification object];
    NSParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus currentNetStatus = [currentReach currentReachabilityStatus];
    if (currentReach == [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability]
        && !(self.logoImgView.hidden) && currentNetStatus != NotReachable) {
        __weak __typeof(&*self)weakSelf = self;
        [self.poster setUrlPath:self.object.poster_4_3 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (nil != image) {
                weakSelf.logoImgView.hidden = YES;
            } else {
                weakSelf.logoImgView.hidden = NO;
            }
        }];
	}
}

- (void)updateTheme:(NSNotification *)notifiction {
    self.poster.alpha = themeImageAlphaValue();
    
    //Cell bgview
    _bgView.image = [[UIImage imageNamed:@"timeline_videoplay_cellbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
    
    //Share btn
    [self.shareBtn setImage:[UIImage imageNamed:@"timeline_videoplay_share.png"] forState:UIControlStateNormal];
    [self.shareBtn setImage:[UIImage imageNamed:@"timeline_videoplay_sharepress.png"] forState:UIControlStateHighlighted];
    
    //Fullscreen btn
    [_fullscreenBtn setImage:[UIImage imageNamed:@"timeline_videoplay_fullscreen_btn.png"] forState:UIControlStateNormal];
    [_fullscreenBtn setImage:[UIImage imageNamed:@"timeline_videoplay_fullscreen_btn_press.png"] forState:UIControlStateHighlighted];
    
    //VideoMediaPortal btn
    NSString *videoMediaPortalTitleNormalColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTimelineVideoMediaPortalNormalColor];
    [_videoMediaPortal setTitleColor:[UIColor colorFromString:videoMediaPortalTitleNormalColor] forState:UIControlStateNormal];
    NSString *videoMediaPortalTitlePressColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTimelineVideoMediaPortalPressColor];
    [_videoMediaPortal setTitleColor:[UIColor colorFromString:videoMediaPortalTitlePressColor] forState:UIControlStateHighlighted];
    [_videoMediaPortal setImage:[UIImage imageNamed:@"timeline_videomediaportal_btn_accessory.png"] forState:UIControlStateNormal];
    [_videoMediaPortal setImage:[UIImage imageNamed:@"timeline_videomediaportal_btn_accessory_press.png"] forState:UIControlStateHighlighted];
    
    //video download btn
    //不能下载
    if (self.object.downloadType != WSMVVideoDownloadType_CanDownload ||
        self.object.playType != WSMVVideoPlayType_Native) {
        [self.downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_cant_download.png"] forState:UIControlStateNormal];
        [self.downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_cant_download.png"] forState:UIControlStateHighlighted];
    }
    //能下载
    else {
        self.downloadBtn.alpha = 1;
        [self.downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_download.png"] forState:UIControlStateNormal];
        [self.downloadBtn setImage:[UIImage imageNamed:@"timeline_videoplay_download_hl.png"] forState:UIControlStateHighlighted];
    }

    [self.posterPlayBtn setImage:[UIImage themeImageNamed:@"icohome_ad_play_v5.png"] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    [self updatePlayNightMode];
}

#pragma mark - SNVideoDetailRecommendModelDelegate
- (void)videoRecommendModelDidStartLoad:(SNVideoDetailRecommendModel *)recModel {
}

- (void)handleRecommendModelDidFinishLoad:(NSNotification *)notification {
    if (notification.object == self.recommendModel) {
        NSDictionary *resultDic = notification.userInfo;
        int resultCode = [resultDic intValueForKey:@"result" defaultValue:-1];
        if (resultCode == 0) {
            //More
            if ([[resultDic objectForKey:@"isMore"] boolValue]) {
                NSArray *moreData = [resultDic arrayValueForKey:@"moreData" defaultValue:nil];
                NSArray *moreRecommendArray = moreData;
                if (moreRecommendArray.count > 0) {
                    for (SNVideoData *model in moreRecommendArray) {
                        model.sPlayID = self.object.vid;
                        model.channelId = self.object.channelId;
                    }
                    
                    SNTimelineSharedVideoPlayerView *videoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
                    [videoPlayer appendPlaylist:moreRecommendArray];
                    [videoPlayer appendRecommendVideos:moreRecommendArray];
                    [self.recommendVideos addObjectsFromArray:moreRecommendArray];
                }
            }
            //First
            else {
                [self didFinishLoadFirstPageRecommendList];
            }
        }
    }
}

- (void)didFinishLoadFirstPageRecommendList {
    NSArray *recommendArray = self.recommendModel.videos;
    if (recommendArray.count > 0) {
        self.object.hadLoadRecommendVideos = YES;//加载第一批相关视频后视为已加载过相关，防止反复加载第一批。更多的相关通过播放器内部触发

        NSMutableArray *tempArray = [NSMutableArray array];
        SNVideoData *timelineVideo = self.object;
        if (!!timelineVideo) {
            [tempArray addObject:timelineVideo];
        }
        [tempArray addObjectsFromArray:recommendArray];
        for (SNVideoData *model in tempArray) {
            model.sPlayID = self.object.vid;
            model.channelId = self.object.channelId;
        }
        
        SNTimelineSharedVideoPlayerView *videoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
        
        [videoPlayer replaceAllPlaylist:tempArray];
        [videoPlayer replaceAllRecommendVieos:tempArray];

        [self.recommendVideos removeAllObjects];
        [self.recommendVideos addObjectsFromArray:tempArray];
    }
}

- (NSArray *)recommendVideosOfVideoModel:(SNVideoData *)playingVideoModel
                                    more:(BOOL)more {
    //此种情况：当横屏的相关列表layout时没有相关数据，会再回调一次此处以再尝试加载相关
    if (!more) {
        [self didFinishLoadFirstPageRecommendList];
        return nil;
    }
    //在相关列表中往后滚动加载更多相关时回调此处
    else {
        [self loadMoreRecommendVideos];
        return nil;
    }
}

//---如果连续播放列表中剩余的视频个数不足三个时，则发起追加播放列表的请求
- (void)needMoreRecommendIntoPlaylist {
    [self loadMoreRecommendVideos];
}

- (void)loadMoreRecommendVideos {
    if (self.recommendModel.hasMore) {
        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            [self.recommendModel loadRecommendVideosMoreFromServer];
        }
    }
}

#pragma mark - WSMVVideoPlayerViewDelegate
- (BOOL)isVideoPlayerVisible {
    if ([_delegate respondsToSelector:@selector(isVideoTimelineVisiable)]) {
        return [_delegate isVideoTimelineVisiable];
    } else {
        return YES;
    }
}

- (void)willPlayVideo:(SNVideoData *)video {
    [self updateDownloadBtnForVideo:video];
}

//- (void)thereIsNoPreVideo:(WSMVVideoPlayerView *)playerView {
//    if ([playerView isFullScreen]) {
//        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"alreadFirstVideo", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
//    }
//}

//- (void)willPlayPreVideo:(SNVideoData *)video {
//    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
//    [player replaceAllRecommendVieos:self.recommendVideos];
//}

//- (void)thereisNoNextVideo:(WSMVVideoPlayerView *)playerView {
//    if ([playerView isFullScreen]) {
//        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"alreadLastVideo", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
//    } else {
//        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"alreadLastVideo", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
//    }
//}

//- (void)willPlayNextVideo:(SNVideoData *)video {
//    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
//    [player replaceAllRecommendVieos:self.recommendVideos];
//}

//- (void)willPlayNextVideoIn5Seconds:(SNVideoData *)video {
//    [self bringSubviewToFront:self.msgLabel];
//    
//    CGFloat maxWidth = self.poster.width - 2 * kCopyRightLabelLeft;
//    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"will_play_nextvideo_in5seconds_msg", nil), video.title];
//    if (text.length > 0) {
//        text = [text stringByAppendingString:@"  "];
//    }
//    UIFont *textFont            = [UIFont systemFontOfSize:kCopyRightLabelFontSize];
//    CGSize constrainedToSize    = CGSizeMake(maxWidth, kCopyRightLabelHeight);
//    CGSize textSize = [text sizeWithFont:textFont constrainedToSize:constrainedToSize lineBreakMode:NSLineBreakByTruncatingTail];
//    
//    self.msgLabel.text = text;
//    if (textSize.width > maxWidth) {
//        self.msgLabel.width = maxWidth;
//    } else {
//        self.msgLabel.width = textSize.width;
//    }
//    
//    self.msgLabel.hidden = NO;
//    [UIView animateWithDuration:0.3 delay:3 options:0
//                     animations:^{
//                         self.msgLabel.alpha = 0;
//                     } completion:^(BOOL finished) {
//                         self.msgLabel.hidden = YES;
//                         self.msgLabel.alpha = 1;
//                     }
//     ];
//}

- (void)didPlayVideo:(SNVideoData *)video {
    self.willSharedVideo = video;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(clickPlayButton:)]) {
        [self.delegate clickPlayButton:video];
    }
}

- (void)didStopVideo:(SNVideoData *)video {
}

- (void)handleAppDidBecomeActive {    
    SNVideoAdContextCurrentTabValue currentTab = [[SNVideoAdContext sharedInstance] getCurrentTab];
    if (currentTab == SNVideoAdContextCurrentTabValue_News) {
        [SNTimelineSharedVideoPlayerView fakeStop];
    }
}

//视频tab 全屏分享
- (void)willShareVideo:(SNVideoData *)video
            fromPlayer:(WSMVVideoPlayerView *)player {
    self.willSharedVideo = video;
    
#if 1 //wangshun share test 这好像不走了
    return;
#endif

    if (nil == self.actionMenuController)
    {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    _actionMenuController.delegate = self;
    _actionMenuController.sourceType = 41;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    NSString *protocolUrl = [NSString stringWithFormat:@"%@vid=%@&mid=%@&columnId=%d&from=channel&channelId=%@", kProtocolVideo, self.willSharedVideo.vid, self.willSharedVideo.messageId, self.willSharedVideo.columnId, self.willSharedVideo.channelId];
    [_actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    [_actionMenuController.contextDic setObject:self.willSharedVideo.author.subId?:@"" forKey:kSubId];
    [_actionMenuController.contextDic setObject:@"video" forKey:@"contentType"];
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:@"mid=%@",self.willSharedVideo.messageId] forKey:@"referString"];

    _actionMenuController.shareLogType = @"video";
    _actionMenuController.sourceType = 14;
    _actionMenuController.disableLikeBtn = NO;
    _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
    [_actionMenuController showActionMenuFromLandscapeView:player];
}

- (void)didEnterFullScreen:(WSMVVideoPlayerView *)videoPlayerView {
    self.hidden = YES;
    if (YES == _isAdVideo) {
        videoPlayerView.controlBarFullScreen.shareBtn.hidden = YES;
        videoPlayerView.controlBarFullScreen.downloadBtn.hidden = YES;
        videoPlayerView.titleView.recommendBtn.hidden = YES;
        
        videoPlayerView.controlBarFullScreen.previousVideoBtn.enabled = NO;
        videoPlayerView.controlBarFullScreen.nextVideoBtn.enabled = NO;
    }
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(enterToFullScreen)]) {
        [self.delegate enterToFullScreen];
    }
}

- (void)didExitFullScreen:(WSMVVideoPlayerView *)videoPlayerView {
    self.hidden = NO;
    [videoPlayerView.controlBarNonFullScreen disableDownload];
    if (self.object.isNewsVideo) {
        videoPlayerView.titleView.hidden = YES;
    }
    
    [[SNTimelineSharedVideoPlayerView sharedInstance] exitFullScreen];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(exitFullScreen)]){
        [self.delegate exitFullScreen];
    }
}

#pragma mark - Fullscreen
- (void)fullscreenAction:(UIButton *)fullscreenBtn {
    BOOL isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(isTableViewControllerLoading)]) {
        isLoading = [self.delegate isTableViewControllerLoading];
    }
    if (isLoading) {
        return;
    }
    
    SNTimelineSharedVideoPlayerView *playerView = [SNTimelineSharedVideoPlayerView sharedInstance];
    if ([playerView.playingVideoModel.sPlayID isEqualToString:self.object.vid]) {
        [self playVideoManually];
    } else {
        [SNTimelineSharedVideoPlayerView fakeStop];
        [SNTimelineSharedVideoPlayerView forceStop];
        [self playVideoManually];
    }

    //---Fixed bug:Ticket #32308 非WiFi网络下点击全屏按钮，阻断式提示被遮挡
    BOOL canContinueBeforePlayCurrentVideo = [[SNTimelineSharedVideoPlayerView sharedInstance] canContinueBeforePlayCurrentVideo];
    if (canContinueBeforePlayCurrentVideo) {
        [playerView toFullScreen];
    }
    //---
}

//视频tab分享
#pragma mark - Share
- (void)shareAction:(UIButton *)shareBtn {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }

    //点分享的cell和正在播的cell是一个cell
    NSString *sPlayID = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.sPlayID;
    if ([sPlayID isEqualToString:self.object.vid]) {
        self.willSharedVideo = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel;
    }
    //否则，把被点分享的self.object作为分享数据
    else {
        self.willSharedVideo = self.object;
    }
    //video://vid=4683632&mid=31184766&columnId=3506&from=channel&channelId=36&position=2&page=1
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    NSString * protocol = [NSString stringWithFormat:@"%@vid=%@&mid=%@&columnId=%d&from=channel&channelId=%@", kProtocolVideo, self.willSharedVideo.vid, self.willSharedVideo.messageId, self.willSharedVideo.columnId, self.willSharedVideo.channelId];
    [mDic setObject:protocol forKey:@"url"];
    [mDic setObject:self.willSharedVideo.author.subId?:@"" forKey:kSubId];
    [mDic setObject:@"video" forKey:@"contentType"];
    [mDic setObject:[NSString stringWithFormat:@"mid=%@",self.willSharedVideo.messageId] forKey:@"referString"];
    [mDic setObject:@"video" forKey:@"shareLogType"];
    NSString* sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeVedio];//14
    [mDic setObject:sourceType forKey:@"sourceType"];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    _actionMenuController.delegate = self;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    NSString * protocolUrl = [NSString stringWithFormat:@"%@vid=%@&mid=%@&columnId=%d&from=channel&channelId=%@", kProtocolVideo, self.willSharedVideo.vid, self.willSharedVideo.messageId, self.willSharedVideo.columnId, self.willSharedVideo.channelId];
    [_actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    [_actionMenuController.contextDic setObject:self.willSharedVideo.author.subId?:@"" forKey:kSubId];
    [_actionMenuController.contextDic setObject:@"video" forKey:@"contentType"];
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:@"mid=%@",self.willSharedVideo.messageId] forKey:@"referString"];

    _actionMenuController.shareLogType = @"video";
    _actionMenuController.disableLikeBtn = NO;
    _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
    _actionMenuController.sourceType = 14;
    [_actionMenuController showActionMenu];
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}


- (void)downloadAction:(UIButton *)downloadBtn {
    SNVideoData *video = nil;
    //点下载的cell和正在播的cell是一个cell，则下载正在播的视频数据
    NSString *sPlayID = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.sPlayID;
    if ([sPlayID isEqualToString:self.object.vid]) {
        video = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel;
    }
    //否则，把被点下载的cell的 object作为下载数据
    else {
        video = self.object;
    }
    
    //Check视频是否已下载或正在下载
    if (![[WSMVVideoHelper sharedInstance] canDownload:video withPlayerView:[SNTimelineSharedVideoPlayerView sharedInstance]]) {
        return;
    }

    //---为离线完成后离线播放做准备
    SNVideoData *timelineVideo = [[SNDBManager currentDataBase] getVideoTimeLineByVid:video.vid];
    if (!timelineVideo) {
        if (video.channelId.length <= 0) {
            video.channelId = kDefaultChannelIdForVideoDownload;
        }
        [[SNDBManager currentDataBase] addVideoData:video channelId:video.channelId];
    }
    //---
    
    SNVideoDataDownload *downloadVideo = [[SNVideoDataDownload alloc] init];
    downloadVideo.title = video.title;
    downloadVideo.videoSources = [video.videoUrl toJsonString];
    downloadVideo.vid = video.vid;
    downloadVideo.state = SNVideoDownloadState_Waiting;
    downloadVideo.poster = video.poster_4_3;
    [[SNVideoDownloadManager sharedInstance] downloadVideoInThread:downloadVideo];
     //(downloadVideo);
    
    //统计下载行为
    [self statDownloadAction:video];
    
    if ([[SNTimelineSharedVideoPlayerView sharedInstance] isFullScreen]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
    } else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"succeed_to_add_video_to_downloading", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
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

- (BOOL)checkIfHadBeenMyFavourite
{
    SNVideoFavourite *videoFavourite = [[SNVideoFavourite alloc] init];
    videoFavourite.type = MYFAVOURITE_REFER_VIDEO;
    videoFavourite.contentLevelFirstID = @"100";//相关推荐没有channelID,默认视频的channelID传100
    if ([self.object.vid isEqualToString:[SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.sPlayID]) {
        videoFavourite.contentLevelSecondID = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.messageId;
        videoFavourite.link2 = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.link2;
    } else {
        videoFavourite.contentLevelSecondID = self.object.messageId;
        videoFavourite.link2 = self.object.link2;
    }
    return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:videoFavourite];
}

- (void)actionmenuDidSelectLikeBtn {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if ([self checkIfHadBeenMyFavourite]) {
        [self executeFavouriteNews:nil];
    } else {
        [SNUtility executeFloatView:self
                           selector:@selector(executeFavouriteNews:)];
    }
}

- (void)clikItemOnHalfFloatView:(NSDictionary *)dict {
    [self executeFavouriteNews:dict];
}

- (void)executeFavouriteNews:(NSDictionary *)dict {
    SNVideoFavourite *videoFavourite = [[SNVideoFavourite alloc] init];
    videoFavourite.type = MYFAVOURITE_REFER_VIDEO;
    videoFavourite.contentLevelFirstID = @"100";//相关推荐没有channelID,默认视频的channelID传100
    if ([self.object.vid isEqualToString:[SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.sPlayID]) {
        videoFavourite.contentLevelSecondID = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.messageId;
        videoFavourite.link2 = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.link2;
        videoFavourite.title = [SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel.title;
    } else {
        videoFavourite.contentLevelSecondID = self.object.messageId;
        videoFavourite.link2 = self.object.link2;
        videoFavourite.title = self.object.title;
    }
    if ([self isFullScreen] && ![SNUserManager isLogin]) {
        [self videoExitFullScreen];
        double delayInSeconds = .6f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:videoFavourite corpusDict:dict];
        });
    } else {
        [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:videoFavourite corpusDict:dict];
    }
}

- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    if (self.willSharedVideo.vid.length > 0) {
        [dicInfo setObject:self.willSharedVideo.vid forKey:@"vid"];
    }
    
    if (self.willSharedVideo.messageId.length > 0) {
        //Message id
        [dicInfo setObject:self.willSharedVideo.messageId forKey:@"mid"];
    }
    
    if (self.willSharedVideo.share.content.length > 0) {
        [dicInfo setObject:self.willSharedVideo.share.content forKey:kShareInfoKeyContent];
    }
    
    // generate share read content
    SNTimelineOriginContentObject *shareRead = [[SNTimelineOriginContentObject alloc] init];
    shareRead.title = self.willSharedVideo.title;
    shareRead.abstract = self.willSharedVideo.abstract;
    shareRead.description = self.willSharedVideo.abstract;
    shareRead.sourceType = SNShareSourceTypeVedio;
    shareRead.link = self.willSharedVideo.share.h5Url;
    shareRead.ugcWordLimit = self.willSharedVideo.share.ugcWordLimit;
    
    if (self.willSharedVideo.poster_4_3.length > 0) {
        shareRead.picsArray = [NSMutableArray arrayWithObject:self.willSharedVideo.poster_4_3];
        shareRead.subId = nil;
        [dicInfo setObject:self.willSharedVideo.poster_4_3
                    forKey:kShareInfoKeyImageUrl];
    }
    
    if (shareRead) {
        [dicInfo setObject:shareRead forKey:kShareInfoKeyShareRead];
    }
    
    if (self.willSharedVideo.share.h5Url.length > 0) {
        [dicInfo setObject:self.willSharedVideo.share.h5Url forKey:kShareInfoKeyMediaUrl];
    }
    
    //Log
    if ([self.willSharedVideo.messageId length] > 0) {
        [dicInfo setObject:self.willSharedVideo.messageId
                    forKey:kShareInfoKeyNewsId];
    }
    if ([self.willSharedVideo.share.content length] > 0) {
        [dicInfo setObject:self.willSharedVideo.share.content forKey:kShareInfoKeyShareContent];
    }
    //mail title
    if (self.willSharedVideo.title.length > 0) {
        [dicInfo setObject:self.willSharedVideo.title forKey:kShareInfoKeyTitle];
    }
    
    return dicInfo;
}

#pragma mark - Statistic
- (void)statVideoPV:(SNVideoData *)willPlayModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = willPlayModel.vid.length > 0 ? willPlayModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = willPlayModel.channelId;
    _vStatModel.messageId = willPlayModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    [[WSMVVideoStatisticManager sharedIntance] statVideoPV:_vStatModel];
}

- (void)statVideoVV:(SNVideoData *)finishedPlayModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = finishedPlayModel.vid.length > 0 ? finishedPlayModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = finishedPlayModel.channelId;
    _vStatModel.messageId = finishedPlayModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    _vStatModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + finishedPlayModel.playedTime;
    _vStatModel.totalTimeInSeconds = finishedPlayModel.totalTime;
    _vStatModel.siteId = finishedPlayModel.siteInfo.siteId;
    _vStatModel.columnId = [NSString stringWithFormat:@"%d", finishedPlayModel.columnId];
    
    SHMedia *shMedia = [[SNTimelineSharedVideoPlayerView sharedInstance] getMoviePlayer].currentPlayMedia;
    SHMediaSourceType mediaSourceType = shMedia.sourceType;
    if (mediaSourceType == SHLocalDownload) {
        _vStatModel.offline = kWSMVStatVV_Offline_YES;
    } else {
        _vStatModel.offline = kWSMVStatVV_Offline_NO;
    }
    
    [[WSMVVideoStatisticManager sharedIntance] statVideoVV:_vStatModel inVideoPlayer:videoPlayerView];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (self.delegate && [self.delegate respondsToSelector:@selector(didStop)]) {
        [self.delegate performSelector:@selector(didStop)];
    }
#pragma clang diagnostic pop
}

//累计连播数据以便在调起播放器页不再使用播放器时统计连播
- (void)cacheVideoSV:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_statModel = [[WSMVVideoStatisticModel alloc] init];
    _statModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _statModel.newsId = @"";
    _statModel.messageId = videoModel.messageId;
    _statModel.refer = VideoStatRefer_VideoTabTimeline;
    _statModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + videoModel.playedTime;
    [[WSMVVideoStatisticManager sharedIntance] cacheVideoSV:_statModel];
}

- (void)statVideoAV:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = videoModel.channelId;
    _vStatModel.messageId = videoModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    [[WSMVVideoStatisticManager sharedIntance] statVideoPlayerActions:_vStatModel actionsData:videoPlayerView.playerActionsStatData];
}

- (void)statFFL:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView succeededToLoad:(BOOL)succeededToLoad {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    _vStatModel.channelId = videoModel.channelId;
    _vStatModel.messageId = videoModel.messageId;
    _vStatModel.refer = VideoStatRefer_VideoTabTimeline;
    _vStatModel.succeededToFFL = succeededToLoad;
    _vStatModel.siteId = videoModel.siteInfo.siteId;
    [[WSMVVideoStatisticManager sharedIntance] statFFL:_vStatModel];
}

#pragma mark - 2G3G提示
- (void)showNetworkWarningAciontSheetForPlayer:(WSMVVideoPlayerView *)playerView {

    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"2g3g_actionsheet_info_content", nil) cancelButtonTitle:NSLocalizedString(@"2g3g_actionsheet_option_cancel", nil) otherButtonTitle:NSLocalizedString(@"2g3g_actionsheet_option_play", nil)];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        playerView.playingVideoModel.hadEverAlert2G3G = NO;
        [playerView pause];
    }otherButtonHandler:^{
        playerView.playingVideoModel.hadEverAlert2G3G = YES;
        [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
        if (self.isToFullScreen) {
            [playerView toFullScreen];
            [playerView playCurrentVideo];
            self.isToFullScreen = NO;
        } else {
            [playerView playCurrentVideo];
        }
    }];

}

- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style
                   forPlayerView:(WSMVVideoPlayerView *)playerView {
    if ([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
        [self.delegate alert2G3GIfNeededByStyle:style
                                  forPlayerView:playerView];
        return;
    }
    //李健 2015.1.1 增加视频广告的视频播放器基础类要加改功能，就不用上层cell处理了
    if (style == WSMV2G3GAlertStyle_Block) {
        [playerView pause];
        SNDebugLog(@"Will show 2G3G alert with blockUI.");
        
        // 全屏状态下 先退出全屏
        if (playerView.isFullScreen) {
            [playerView exitFullScreen];
            double delayInSeconds = .5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self showNetworkWarningAciontSheetForPlayer:playerView];
            });
        }
        // 竖屏状态下直接弹出流量提醒
        else {
            [self showNetworkWarningAciontSheetForPlayer:playerView];
        }
    } else if (style == WSMV2G3GAlertStyle_VideoPlayingToast) {
        BOOL isActionSheetInvisible = YES;
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
            } else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
    } else if (style == WSMV2G3GAlertStyle_NetChangedTo2G3GToast) {
        BOOL isActionSheetInvisible = YES;
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil mode:SNCenterToastModeWarning];
            } else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil mode:SNCenterToastModeWarning];
            }
        }
    } else if (style == WSMV2G3GAlertStyle_NotReachable) {
        [playerView pause];
        if ([playerView isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
}

@end
