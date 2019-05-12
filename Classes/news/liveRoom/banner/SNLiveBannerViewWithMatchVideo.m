//
//  SNLiveBannerViewWithMatchVideo.m
//  sohunews
//
//  Created by wang yanchen on 13-5-3.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveBannerViewWithMatchVideo.h"
#import "UIColor+ColorUtils.h"
#import "SNSoundManager.h"
#import "SNLiveRoomConsts.h"
#import "SNVideoAdContext.h"
#import "SNVideoAdMaskHelper.h"
#import "WSMVVideoStatisticModel.h"
#import "WSMVVideoStatisticManager.h"
#import "SNVideoAdContext.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNTripletsLoadingView.h"
#import "SNSkinManager.h"
#import "SNNewAlertView.h"

#define kViewHeight                 ((540 + 14)/ 2 + kSystemBarHeight)
#define kViewHeight_S               ((220 + 0) / 2 + kSystemBarHeight)

#define kVideoPlayerTopMargin       ((120-4 + 14) / 2 + kSystemBarHeight)
#define kVideoPlayerTopMargin_S     (18 / 2 + kSystemBarHeight)
#define kVideoPlayerSideMargin      (20 / 2)
#define kVideoPlayerSideMargin_S    (22 / 2)
#define kVideoPlayerHeight          (360 / 2)
#define kVideoPlayerWidth_S         (260 / 2)
#define kVideoPlayerHeight_S        (146 / 2)

//Live Status
#define kLiveStatusFont             (18 / 2)
#define kLiveStatusBottomMargin     (14 / 2)
#define kLiveStatusLeftMargin       (338 / 2)
#define kLiveStatusLeftMargin_S     (338 / 2)

#define kTeamNameTopMargin          (32 / 2 + kSystemBarHeight)
#define kTeamNameTopMargin_S        (98 / 2 + kSystemBarHeight)
#define kTeamNameFont               (26 / 2)
#define kTeamNameWidth              ([[SNDevice sharedInstance] isMoreThan320] ? (80 + 30) : (160 / 2))
#define kTeamNameWidthS             ([[SNDevice sharedInstance] isMoreThan320] ? (75 + 20) : (150 / 2))

//VS
#define kVSLabelTopMargin           (96 / 2 + kSystemBarHeight)
#define kVSLabelWidth               (28 / 2)
#define kVSLabelHeight              (26 / 2)

//Score
#define kScoreFont                  (70 / 2)
#define kScoreTopMargin             (8 / 2 + kSystemBarHeight)
#define kScoreH                     (kScoreFont + 2)
#define kScoreLeftMargin_S          (22/2)

//Up
#define kUPLabelFont                (18 / 2)
#define kUpLabelTopMargin           (13 / 2)
#define kUpImageLabelSpace          (10 / 2)

#define kLiveBannerSegmentViewExBtnFont                 (22 / 2)
#define kLiveBannerSegmentViewExBtnBottomMargin         (14 / 2)
#define kLiveBannerSegmentViewExBtnRightMargin          (18 / 2)
#define kLiveBannerSegmentViewExBtnRightMargin_S        (34 / 2)
#define kLiveBannerSegmentViewExBtnMidSpace             (10 / 2)
#define kLiveBannerSegmentViewExBtnImageRightMargin     (50 / 2)

#define kLiveBannerViewWithMatchInfoScoreDotsTopMargin      (kScoreTopMargin)
#define kLiveBannerViewWithMatchInfoScoreDotsFontBig        (50 / 2)

#define kLiveBannerViewWithMatchInfoScroeOffset             (6)

#define kDotsX (358 / 2 /2)

#define kLiveBannerViewWithMatchInfoWorldCupTopMargin       (3 + kSystemBarHeight)
#define kLiveBannerViewWithMatchInfoWorldCupTopMarginS      (10)

static const int kRechabilityChangedActionSheetTag = 10001;

@interface SNLiveBannerViewWithMatchVideo () {
    UIView *mpView;
    UIInterfaceOrientation interfaceOrientation;
    BOOL canRotateVideo;
}


@property(nonatomic, strong) UITapGestureRecognizer *videoTapGestrue;
@property (nonatomic, strong) SNActionSheet *networkStatusActionSheet;
@property(nonatomic, copy) NSString *hostUp;
@property(nonatomic, copy) NSString *visitUp;

@end

@implementation SNLiveBannerViewWithMatchVideo
@synthesize videoTapGestrue = _videoTapGestrue;

- (CGRect)viewFrame:(BOOL)bShrinkMode {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect frame = CGRectMake(0, 0, appFrame.size.width, (bShrinkMode?kViewHeight_S:kViewHeight));
    return frame;
}

- (id)initWithMode:(BOOL)bShrinkMode {
    CGRect frame = [self viewFrame:bShrinkMode];
    self = [super initWithFrame:frame];
    if (self) {
        self.hasExpanded = !bShrinkMode;
        self.clipsToBounds = YES;
        
        [SNNotificationManager
         addObserver:self selector:@selector(audioStartNotification:)
         name:kAudioStartNotification object:nil];
        
        [SNNotificationManager
         addObserver:self selector:@selector(didReceiveNotification:)
         name:kNotifyDidReceive object:nil];
        
        [SNNotificationManager
         addObserver:self selector:@selector(handleShortVideoDidStopNotification:)
         name:kSNShortVideoDidStopNotification object:nil];
    }
    return self;
}

- (void)createSubviews {
    // 背景图
    if (self.isWorldCup) {
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 10)];
        bg.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        bg.backgroundColor = [UIColor colorFromString:@"#e24508"];
        [self addSubview:bg];
        

        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wc_live_bg.png"]];
        self.backgroundImageView.top = -10;

        [self addSubview:self.backgroundImageView];
    }
    
    _liveStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLiveStatusLeftMargin, self.height - kLiveStatusBottomMargin - kLiveStatusFont - 1, 125, kLiveStatusFont + 1)];
    _liveStatusLabel.backgroundColor = [UIColor clearColor];
    _liveStatusLabel.font = [UIFont systemFontOfSize:kLiveStatusFont];
    _liveStatusLabel.textAlignment = NSTextAlignmentLeft;
    _liveStatusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_liveStatusLabel];
    
    _vsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                         kVSLabelTopMargin,
                                                         kVSLabelWidth,
                                                         kVSLabelHeight)];
    _vsLabel.backgroundColor = [UIColor clearColor];
    _vsLabel.text = @"vs";
    _vsLabel.font = [UIFont digitAndLetterFontOfSize:_vsLabel.height - 1];
    _vsLabel.centerX = kDotsX;
    _vsLabel.alpha = 0;
    _vsLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_vsLabel];
    
    _scoreDotsLabel = [[UILabel alloc]
                       initWithFrame:CGRectMake(0,
                        kLiveBannerViewWithMatchInfoScoreDotsTopMargin + kLiveBannerViewWithMatchInfoScroeOffset, 10,kLiveBannerViewWithMatchInfoScoreDotsFontBig + 1)];
    _scoreDotsLabel.centerX = CGRectGetMidX(self.bounds);
    _scoreDotsLabel.font = [UIFont digitAndLetterFontOfSize:kLiveBannerViewWithMatchInfoScoreDotsFontBig];
    _scoreDotsLabel.backgroundColor = [UIColor clearColor];
    _scoreDotsLabel.textAlignment = NSTextAlignmentCenter;
    _scoreDotsLabel.text = @":";
    [self addSubview:_scoreDotsLabel];
    
    _hostScore = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                           kScoreTopMargin,
                                                           100,
                                                           kScoreH)];
    _hostScore.backgroundColor = [UIColor clearColor];
    _hostScore.font = [UIFont digitAndLetterFontOfSize:kScoreFont];
    _hostScore.textAlignment = NSTextAlignmentRight;
    _hostScore.right = _scoreDotsLabel.left - 15;
    _hostScore.text = @"000";
    [self addSubview:_hostScore];
    
    _visitScore = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                            _hostScore.top,
                                                            _hostScore.width,
                                                            _hostScore.height)];
    _visitScore.backgroundColor = [UIColor clearColor];
    _visitScore.font = _hostScore.font;
    _visitScore.left = _scoreDotsLabel.right + 15;
    _visitScore.text = @"000";
    [self addSubview:_visitScore];
    
    _hostTeamName = [[UILabel alloc] initWithFrame:CGRectMake(kVideoPlayerSideMargin, kTeamNameTopMargin, kTeamNameWidth, kTeamNameFont + 1)];
    _hostTeamName.backgroundColor = [UIColor clearColor];
    _hostTeamName.font = [UIFont systemFontOfSize:kTeamNameFont];
    _hostTeamName.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_hostTeamName];
    
    _visitTeamName = [[UILabel alloc] initWithFrame:CGRectMake(self.width - kVideoPlayerSideMargin - kTeamNameWidth, _hostTeamName.top, _hostTeamName.width, _hostTeamName.height)];
    _visitTeamName.textAlignment = NSTextAlignmentRight;
    _visitTeamName.backgroundColor = [UIColor clearColor];
    _visitTeamName.font = [UIFont systemFontOfSize:kTeamNameFont];
    [self addSubview:_visitTeamName];
    
    _hostUpView = [[UIView alloc] initWithFrame:CGRectMake(kVideoPlayerSideMargin, _hostTeamName.bottom, _hostTeamName.width, 66 / 2)];
    [self addSubview:_hostUpView];
    
    UITapGestureRecognizer *hostUpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hostUpTapped:)];
    [_hostUpView addGestureRecognizer:hostUpTap];
     //(hostUpTap);

    UIImage *hostUpIconImage = [UIImage imageNamed:@"live_host_up.png"];
    UIImageView *hostUpIcon = [[UIImageView alloc] initWithImage:hostUpIconImage];
    [_hostUpView addSubview:hostUpIcon];
    
    _hostUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(hostUpIcon.right + kUpImageLabelSpace, kUpLabelTopMargin, _hostUpView.width, kUPLabelFont + 1)];
    _hostUpLabel.backgroundColor = [UIColor clearColor];
    _hostUpLabel.font = [UIFont digitAndLetterFontOfSize:kUPLabelFont];
    _hostUpLabel.textAlignment = NSTextAlignmentLeft;
    _hostUpLabel.text = @"0";
    [_hostUpView addSubview:_hostUpLabel];
    hostUpIcon.centerY = _hostUpLabel.centerY;
    
    _visitUpView = [[UIView alloc] initWithFrame:CGRectMake(self.width - kVideoPlayerSideMargin - _hostUpView.width, _hostUpView.top, _hostUpView.width, _hostUpView.height)];
    [self addSubview:_visitUpView];
    
    UITapGestureRecognizer *visitUpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(visitUpTapped:)];
    [_visitUpView addGestureRecognizer:visitUpTap];
     //(visitUpTap);
    
    UIImage *visitUpIconImage = [UIImage imageNamed:@"live_visitor_up.png"];
    UIImageView *visitUpIcon = [[UIImageView alloc] initWithImage:visitUpIconImage];
    visitUpIcon.right = _visitUpView.width;
    [_visitUpView addSubview:visitUpIcon];
    
    _visitUpLabel = [[UILabel alloc]
                     initWithFrame:CGRectMake(0, kUpLabelTopMargin, _visitUpView.width, kUPLabelFont + 1)];
    _visitUpLabel.backgroundColor = [UIColor clearColor];
    _visitUpLabel.font = [UIFont digitAndLetterFontOfSize:kUPLabelFont];
    _visitUpLabel.textAlignment = NSTextAlignmentRight;
    _visitUpLabel.right = visitUpIcon.left - kUpImageLabelSpace;
    _visitUpLabel.text = @"0";
    [_visitUpView addSubview:_visitUpLabel];
    visitUpIcon.centerY = _visitUpLabel.centerY;
    
    [self updateTheme];
}

- (void)layoutStatusLabel {
    if (_segmentView.hasExpanded) {
        _scoreDotsLabel.centerX = CGRectGetMidX(self.bounds);
        _hostScore.right = _scoreDotsLabel.left - 5;
        _visitScore.left = _scoreDotsLabel.right + 5;
        
        _liveStatusLabel.frame = CGRectMake((self.width-_liveStatusLabel.width)/2, _hostScore.bottom + 2, _liveStatusLabel.width, _liveStatusLabel.height);
    } else {
        _liveStatusLabel.frame = CGRectMake(kScoreLeftMargin_S,
                                            kTeamNameTopMargin_S + _hostTeamName.height + 8,
                                            _liveStatusLabel.width,
                                            _liveStatusLabel.height);
        _hostScore.left = kScoreLeftMargin_S;
        _scoreDotsLabel.centerX = _hostScore.right + 15 + _scoreDotsLabel.width / 2;
        _visitScore.left = _scoreDotsLabel.right + 15;
    }
    
    // 判断是否显示 独家
    if (self.infoObj.pubType.integerValue == 1) {
        if (!_pubTypeLabel) {
            _pubTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _pubTypeLabel.backgroundColor = [UIColor clearColor];
            _pubTypeLabel.font = _liveStatusLabel.font;
            _pubTypeLabel.textColor = [SNSkinManager color:SkinRed];
            _pubTypeLabel.text = kPubTypeName;
            [self addSubview:_pubTypeLabel];
        }
        
        _pubTypeLabel.frame = _liveStatusLabel.frame;
        _pubTypeLabel.width = 22.0;
        if (_segmentView.hasExpanded) {
            _pubTypeLabel.left = _liveStatusLabel.left - 11;
        }
        
        _liveStatusLabel.left = _pubTypeLabel.right;
        _pubTypeLabel.hidden = NO;
    } else {
        _pubTypeLabel.hidden = YES;
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    [_bannerVideoPlayer stop];
    [_bannerVideoPlayer clearMoviePlayerController];
    _bannerVideoPlayer.delegate = nil;
    
}

- (void)playVideo {
    self.isStoppedByForce = NO;
    [_bannerVideoPlayer playCurrentVideo];
}

- (void)stopVideo {
    self.isStoppedByForce = YES;
    [self stopVideoForShrinkAnimation];
}

- (void)pauseVideo {
    self.isStoppedByForce = NO;
    [_bannerVideoPlayer pause];
}

- (void)resumeVideo {
    if (self.isVisible) {
        self.isStoppedByForce = NO;
        [_bannerVideoPlayer playCurrentVideo];
    }
}

- (void)segmentViewWillExpand {
    [_bannerVideoPlayer addControlBarTemporarily];
    self.videoTapGestrue.enabled = !(_segmentView.hasExpanded);
}

- (void)segmentViewWillShrink {
    [_bannerVideoPlayer removeControlBarTemporarily];
    self.videoTapGestrue.enabled = !(_segmentView.hasExpanded);
}

#pragma mark -  UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return (!(_segmentView.hasExpanded) && gestureRecognizer == self.videoTapGestrue);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (!(_segmentView.hasExpanded) && gestureRecognizer == self.videoTapGestrue);
}
#pragma mark - actions & signals

- (void)videoViewTapped:(id)sender {
    if ([_bannerVideoPlayer isPlaying]) {
        [_bannerVideoPlayer tapBannerViewToPause];
    } else {
        // 停止音频
        [[SNSoundManager sharedInstance] stopAll];
        [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
        
        [_bannerVideoPlayer tapBannerViewToPlay];
    }
}

// 收到推送  如果是全屏模式  推出全屏 并且暂停
- (void)didReceiveNotification:(id)sender {
}

// 播正文音频停直播间音频
- (void)audioStartNotification:(NSNotification *)notification {
    [_bannerVideoPlayer pause];
}

- (void)stopVideoForShrinkAnimation {
    [_bannerVideoPlayer stop];
    [_bannerVideoPlayer clearMoviePlayerController];
}

- (void)hostUpTapped:(id)sender {
    if (_delegate &&
        [_delegate respondsToSelector:@selector(bannerTappedHostUp)]) {
        [_delegate bannerTappedHostUp];
    }
}

- (void)visitUpTapped:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerTappedVisitUp)]) {
        [_delegate bannerTappedVisitUp];
    }
}

#pragma mark - override
- (void)setInfoObj:(SNLiveContentMatchInfoObject *)infoObj {
    [[SNVideoAdContext sharedInstance] setCurrentVideoAdPosition:SNVideoAdContextCurrentVideoAdPosition_LiveBanner];

    [super setInfoObj:infoObj];
    
    _hostTeamName.text = self.infoObj.homeTeamTitle;
    _visitTeamName.text = self.infoObj.visitingTeamTitle;
    _hostScore.text = self.infoObj.homeTeamScore;
    _visitScore.text = self.infoObj.visitingTeamScore;
    
    _hostUpLabel.text = self.infoObj.homeTeamSupportNum.length > 0 ? [SNUtility statisticsDataChangeType:self.infoObj.homeTeamSupportNum] : @"0";
    _visitUpLabel.text = self.infoObj.visitingTeamSupportNum.length > 0 ? [SNUtility statisticsDataChangeType:self.infoObj.visitingTeamSupportNum] : @"0";
    //重构后的视频控件
    NSString *_videoUrl = self.infoObj.mediaObj.mediaUrl.length > 0 ? self.infoObj.mediaObj.mediaUrl : @"";
    if (![SNAPI isWebURL:_videoUrl]) {
        _videoUrl = [NSString stringWithFormat:@"%@%@",[SNAPI rootScheme], _videoUrl];
    }
    
    SNVideoData *videoData = nil;
    if (_videoUrl.length > 0) {
        videoData = [[SNVideoData alloc] init];
        videoData.vid        = self.infoObj.mediaObj.vid;
        videoData.messageId  = nil;
        videoData.title      = @"直播";
        videoData.abstract   = nil;
        videoData.columnName = nil;
        videoData.link2      = nil;
        
        videoData.poster     = self.infoObj.mediaObj.mediaImage;
        videoData.poster_4_3 = nil;
        videoData.smallImageUrl  = nil;
        videoData.wapUrl         = nil;
        
        SNVideoUrl *videoURL = [[SNVideoUrl alloc] init];
        videoURL.m3u8 = _videoUrl;
        videoData.videoUrl   = videoURL;
        videoData.author     = nil;
        videoData.share      = nil;
        videoData.siteInfo   = [[SNVideoSiteInfo alloc] init];
        videoData.siteInfo.site = self.infoObj.mediaObj.site;
        videoData.siteInfo.site2 = self.infoObj.mediaObj.site2;
        videoData.siteInfo.siteName = self.infoObj.mediaObj.siteName;
        videoData.siteInfo.siteId = self.infoObj.mediaObj.siteId;
        videoData.siteInfo.playById = self.infoObj.mediaObj.playById;
        videoData.siteInfo.playAd = self.infoObj.mediaObj.playAd;
        videoData.siteInfo.adServer = self.infoObj.mediaObj.adServer;
        
        // 把 nil 赋值给 int 啊 ! ... v5.2.0
        videoData.type       = nil;
        videoData.status     = nil;
        videoData.columnId   = nil;
        videoData.duration   = nil;
        videoData.action     = nil;
        videoData.playType   = WSMVVideoPlayType_Native;
        videoData.playCount  = nil;
        videoData.downloadType = WSMVVideoDownloadType_CantDownload;
        
        videoData.templatePicUrl = nil;
        videoData.multipleType = nil;
        videoData.mediaLink = nil;//视频媒体页
    }
    
    if (!_bannerVideoPlayer) {
        CGRect _videoPlayerFrame    = self.hasExpanded ? [self videoFrameForExpandMode] : [self videoFrameForShrinkMode];
        _bannerVideoPlayer = [[SNLiveRoomBannerVideoPlayerView alloc] initWithFrame:_videoPlayerFrame andDelegate:self];
        _bannerVideoPlayer.videoPlayerRefer = WSMVVideoPlayerRefer_LiveRoomBanner;
        if (videoData){
            [_bannerVideoPlayer initPlaylist:[NSArray arrayWithObject:videoData] initPlayingIndex:0];
        }
        [self addSubview:_bannerVideoPlayer];
        
        if (!self.hasExpanded) {
            [_bannerVideoPlayer removeControlBarTemporarily];
        }
        
        //给VideoView加一个点击事件，以便于在“收起”模式时，点VideoView暂停
        self.videoTapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoViewTapped:)];
        self.videoTapGestrue.delegate = self;
        [_bannerVideoPlayer addGestureRecognizer:self.videoTapGestrue];
        self.videoTapGestrue.enabled = !self.hasExpanded;
    } else {
        SNDebugLog(@"\n Updating video model when setInfoObj...");
        [_bannerVideoPlayer updateVideoModelIfChanged:videoData];
    }
    
    
    [_hostScore sizeToFit];
    [_visitScore sizeToFit];
    [_liveStatusLabel sizeToFit];
    [self layoutStatusLabel];
}

- (void)initOnlineCountLabel {
}

- (void)initLiveStatusLabel {
    _liveStatusLabel.text =
    [NSString stringWithFormat:@"%@人参与  %@",[SNUtility statisticsDataChangeType:self.onlineCount], self.liveStatus];
}

- (void)setHostUp:(NSString *)hostUp {
    if (hostUp && _hostUp && [hostUp intValue] <= [_hostUp intValue]) {
        return;
    }
    
    if (_hostUp != hostUp) {
         //(_hostUp);
        _hostUp = [hostUp copy];
    }
    
    _hostUpLabel.text = [SNUtility statisticsDataChangeType:_hostUp];
}

- (void)setVisitUp:(NSString *)visitUp {
    if (visitUp && _visitUp && [visitUp intValue] <= [_visitUp intValue]) {
        return;
    }
    
    if (_visitUp != visitUp) {
         //(_visitUp);
        _visitUp = [visitUp copy];
    }

    _visitUpLabel.text = [SNUtility statisticsDataChangeType:_visitUp];
}

- (CGFloat)viewExpandHeight {
    return kViewHeight;
}

- (CGFloat)viewShrinkHeight {
    return kViewHeight_S;
}

- (void)doExpandAnimation {
    [super doExpandAnimation];
    
    _bottomShadowView.top = self.height;
    _liveStatusLabel.frame = CGRectMake(kLiveStatusLeftMargin,
                                        self.height - kLiveStatusBottomMargin - _liveStatusLabel.height,
                                        _liveStatusLabel.width,
                                        _liveStatusLabel.height);
    
    _hostTeamName.frame = CGRectMake(kVideoPlayerSideMargin,
                                     kTeamNameTopMargin,
                                     kTeamNameWidth,
                                     kTeamNameFont + 1);
    
    _visitTeamName.frame = CGRectMake(self.width - kVideoPlayerSideMargin - kTeamNameWidth, _hostTeamName.top, _hostTeamName.width, _hostTeamName.height);

    [self layoutStatusLabel];
    
    [self expandBannerVideoPlayer];
    
    _vsLabel.alpha = 0;
    _hostUpView.alpha = 1;
    _visitUpView.alpha = 1;
}

- (void)doShrinkAnimation {
    [super doShrinkAnimation];
    _bottomShadowView.top = self.height;
    // 左对齐显示
    CGSize hostTeamSize = [_hostTeamName.text
                           sizeWithFont:_hostTeamName.font
                           forWidth:kTeamNameWidthS
                           lineBreakMode:_hostTeamName.lineBreakMode];
    CGFloat hostTeamNameLeft = kScoreLeftMargin_S;
    _hostTeamName.frame = CGRectMake(hostTeamNameLeft,
                                     kTeamNameTopMargin_S,
                                     hostTeamSize.width,
                                     _hostTeamName.height);
    
    _vsLabel.centerX = hostTeamNameLeft + hostTeamSize.width + 5 + _vsLabel.width / 2;
    
    CGSize visitTeamSize =
    [_visitTeamName.text sizeWithFont:_visitTeamName.font
                             forWidth:kTeamNameWidthS
                        lineBreakMode:_visitTeamName.lineBreakMode];
    CGFloat visitTeamNameLeft = _vsLabel.right + 5;
    _visitTeamName.frame = CGRectMake(visitTeamNameLeft,
                                      kTeamNameTopMargin_S,
                                      visitTeamSize.width,
                                      _visitTeamName.height);
    
    [self layoutStatusLabel];
    
    [self shrinkBannerVideoPlayer];
    
    _vsLabel.alpha = 1;
    _hostUpView.alpha = 0;
    _visitUpView.alpha = 0;
}

- (CGRect)videoFrameForExpandMode {
    return CGRectMake(0,
                      kVideoPlayerTopMargin,
                      self.width,
                      kVideoPlayerHeight);
}

- (CGRect)videoFrameForShrinkMode {
    return CGRectMake(self.width - kVideoPlayerSideMargin_S - kVideoPlayerWidth_S,
                      kVideoPlayerTopMargin_S,
                      kVideoPlayerWidth_S,
                      kVideoPlayerHeight_S);
}

- (void)expandBannerVideoPlayer {
    _bannerVideoPlayer.frame = [self videoFrameForExpandMode];
    _bannerVideoPlayer.defaultLogo.bounds = CGRectMake(0, 0, 140.0, 38.0);
    _bannerVideoPlayer.defaultLogo.center = CGPointMake(_bannerVideoPlayer.frame.size.width/2, _bannerVideoPlayer.frame.size.height/2);
    [SNVideoAdMaskHelper expandLiveBannerPlayerMask:_bannerVideoPlayer];
    
    //李健 2015.01.22 纠正一下切成小播放器的动画位置
    _bannerVideoPlayer.loadingMaskView.loadingView.center = _bannerVideoPlayer.loadingMaskView.center;
}

- (void)shrinkBannerVideoPlayer {
    _bannerVideoPlayer.frame = [self videoFrameForShrinkMode];
    _bannerVideoPlayer.defaultLogo.bounds = CGRectMake(0, 0, 111, 30);
    _bannerVideoPlayer.defaultLogo.center = CGPointMake(_bannerVideoPlayer.frame.size.width / 2, _bannerVideoPlayer.frame.size.height / 2);
    [SNVideoAdMaskHelper shrinkLiveBannerPlayerMask:_bannerVideoPlayer];
    
    //李健 2015.01.22 纠正一下切成小播放器的动画位置
    _bannerVideoPlayer.loadingMaskView.loadingView.center = _bannerVideoPlayer.loadingMaskView.center;
}

- (void)updateTheme {
    [super updateTheme];
    
    UIColor *onlineColor = self.isWorldCup ? kLiveWorldCupWhiteColor : [SNSkinManager color:SkinText4];
    
    _liveStatusLabel.textColor = onlineColor;
    _hostUpLabel.textColor = onlineColor;
    _visitUpLabel.textColor = onlineColor;
    
    UIColor *titleColor = self.isWorldCup ? kLiveWorldCupWhiteColor : [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameInfoTextColor]];
    
    _hostTeamName.textColor = titleColor;
    _visitTeamName.textColor = titleColor;
    
    UIColor *scoreColor = self.isWorldCup ? kLiveWorldCupWhiteColor : [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameScoreTextColor]];
    
    _scoreDotsLabel.textColor = scoreColor;
    _hostScore.textColor = scoreColor;
    _visitScore.textColor = scoreColor;
    _vsLabel.textColor = scoreColor;
}

- (BOOL)hasVideo {
    return YES;
}

#pragma mark - WSMVVideoPlayerViewDelegate
- (void)didPlayVideo:(SNVideoData *)video {
    // 停止音频
    [[SNSoundManager sharedInstance] stopAll];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
    
    // 停止短视频
    [SNNotificationManager postNotificationName:kBannerVideoDidPlayNotification object:nil];
}

- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style
                   forPlayerView:(WSMVVideoPlayerView *)playerView {
    if (style == WSMV2G3GAlertStyle_Block) {
        [playerView pause];
        //全屏状态下 先退出全屏
        if (playerView.isFullScreen) {
            [playerView exitFullScreen];
            double delayInSeconds = .5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self showNetworkWarningAciontSheetForPlayer:playerView];
            });
        }
        //竖屏状态下直接弹出流量提醒
        else {
            [self showNetworkWarningAciontSheetForPlayer:playerView];
        }
    } else if (style == WSMV2G3GAlertStyle_VideoPlayingToast) {
        UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
        BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
            } else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
    }  else if (style == WSMV2G3GAlertStyle_NetChangedTo2G3GToast) {
        SNDebugLog(@"Toast for network changed to 2G/3G.");
        
        UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
        BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
    } else if (style == WSMV2G3GAlertStyle_NotReachable) {
        [playerView pause];
        if ([playerView isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
    } else {
        SNDebugLog(@"Needn't show 2G3G alert UI currently.");
    }
}

- (void)showNetworkWarningAciontSheetForPlayer:(WSMVVideoPlayerView *)playerView {
    UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
    BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
    if (isActionSheetInvisible) {
        self.networkStatusActionSheet.delegate = nil;
        
        SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"2g3g_actionsheet_info_content", nil) cancelButtonTitle:NSLocalizedString(@"2g3g_actionsheet_option_cancel", nil) otherButtonTitle:NSLocalizedString(@"2g3g_actionsheet_option_play", nil)];
        [alert show];
        [alert actionWithBlocksCancelButtonHandler:^{
            playerView.playingVideoModel.hadEverAlert2G3G = NO;
            [playerView pause];
        }otherButtonHandler:^{
            playerView.playingVideoModel.hadEverAlert2G3G = YES;
            [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
            [playerView playCurrentVideo];
            
        }];

    }
}

- (void)dismissActionSheetByTouchBgView:(SNActionSheet *)actionSheet {
}

#pragma mark - 视频统计相关
- (void)statVideoPV:(SNVideoData *)willPlayModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    
    NSString *siteID = willPlayModel.siteInfo.siteId;
    _vStatModel.vid = siteID.length > 0 ? siteID : @"";
    
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    
    NSString *currentChannelID = [[SNVideoAdContext sharedInstance] getCurrentChannelID];
    _vStatModel.channelId = currentChannelID.length > 0 ? currentChannelID : @"";
    
    _vStatModel.messageId = @"";
    _vStatModel.refer = [self videoStatRefer];
    [[WSMVVideoStatisticManager sharedIntance] statVideoPV:_vStatModel];
}

- (void)statVideoVV:(SNVideoData *)finishedPlayModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    
    NSString *siteID = finishedPlayModel.siteInfo.siteId;
    _vStatModel.vid = siteID.length > 0 ? siteID : @"";
    
    _vStatModel.newsId = @"";
    
    NSString *currentChannelID = [[SNVideoAdContext sharedInstance] getCurrentChannelID];
    _vStatModel.channelId = currentChannelID.length > 0 ? currentChannelID : @"";
    
    _vStatModel.messageId = finishedPlayModel.messageId;
    _vStatModel.refer = [self videoStatRefer];
    _vStatModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + finishedPlayModel.playedTime;
    _vStatModel.totalTimeInSeconds = finishedPlayModel.totalTime;
    _vStatModel.siteId = finishedPlayModel.siteInfo.siteId;
    _vStatModel.columnId = [NSString stringWithFormat:@"%d", finishedPlayModel.columnId];
    
    SHMedia *shMedia = [_bannerVideoPlayer getMoviePlayer].currentPlayMedia;
    SHMediaSourceType movieSourceType = shMedia.sourceType;
    if (movieSourceType == SHLocalDownload) {
        _vStatModel.offline = kWSMVStatVV_Offline_YES;
    } else {
        _vStatModel.offline = kWSMVStatVV_Offline_NO;
    }
    
    [[WSMVVideoStatisticManager sharedIntance] statVideoVV:_vStatModel inVideoPlayer:videoPlayerView];
}

//累计连播数据以便在调起播放器页不再使用播放器时统计连播
- (void)cacheVideoSV:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_statModel = [[WSMVVideoStatisticModel alloc] init];

    
    NSString *siteID = videoModel.siteInfo.siteId;
    _statModel.vid = siteID.length > 0 ? siteID : @"";
    
    _statModel.newsId = @"";
    _statModel.messageId = videoModel.messageId;
    _statModel.refer = [self videoStatRefer];
    _statModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + videoModel.playedTime;
    [[WSMVVideoStatisticManager sharedIntance] cacheVideoSV:_statModel];
}

- (void)statVideoAV:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    
    NSString *siteID = videoModel.siteInfo.siteId;
    _vStatModel.vid = siteID.length > 0 ? siteID : @"";
    
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    NSString *currentChannelID = [[SNVideoAdContext sharedInstance] getCurrentChannelID];
    _vStatModel.channelId = currentChannelID.length > 0 ? currentChannelID : @"";
    _vStatModel.messageId = videoModel.messageId;
    _vStatModel.refer = [self videoStatRefer];
    [[WSMVVideoStatisticManager sharedIntance] statVideoPlayerActions:_vStatModel actionsData:videoPlayerView.playerActionsStatData];
}

- (void)statFFL:(SNVideoData *)videoModel playerView:(WSMVVideoPlayerView *)videoPlayerView succeededToLoad:(BOOL)succeededToLoad {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    
    NSString *siteID = videoModel.siteInfo.siteId;
    _vStatModel.vid = siteID.length > 0 ? siteID : @"";
    
    _vStatModel.subId = @"";
    _vStatModel.newsId = @"";
    NSString *currentChannelID = [[SNVideoAdContext sharedInstance] getCurrentChannelID];
    _vStatModel.channelId = currentChannelID.length > 0 ? currentChannelID : @"";
    _vStatModel.messageId =  videoModel.messageId;
    _vStatModel.refer = [self videoStatRefer];
    _vStatModel.succeededToFFL = succeededToLoad;
    _vStatModel.siteId = videoModel.siteInfo.siteId;
    [[WSMVVideoStatisticManager sharedIntance] statFFL:_vStatModel];
}

- (VideoStatRefer)videoStatRefer {
    return VideoStatRefer_LiveRoom;
}

#pragma mark - SNActionSheetDelegate
- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kRechabilityChangedActionSheetTag) {
        WSMVVideoPlayerView *playerView = [[actionSheet userInfo] objectForKey:kPlayerViewWithActionSheet];
        if (buttonIndex == 0) {
            //取消
            playerView.playingVideoModel.hadEverAlert2G3G = NO;
        } else if (buttonIndex == 1) {
            //播放
            playerView.playingVideoModel.hadEverAlert2G3G = YES;
            [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
            [playerView playCurrentVideo];
        }
    }
}

#pragma mark - private
- (void)handleShortVideoDidStopNotification:(NSNotification *)notificatioin {
    if ([_bannerVideoPlayer getMoviePlayer] == nil) {
        _bannerVideoPlayer.moviePlayer.view.frame = _bannerVideoPlayer.bounds;
    }
    [_bannerVideoPlayer playCurrentVideo];
}

- (SNLiveRoomBannerVideoPlayerView *)getBannerVideoPlayer {
    return _bannerVideoPlayer;
}

- (void)clearOtherPlayer {
    if ([self.delegate respondsToSelector:@selector(clearOtherPlayer)]) {
        [self.delegate clearOtherPlayer];
    }
}

@end
