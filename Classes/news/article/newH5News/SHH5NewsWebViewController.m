//
//  SHH5NewsWebViewController.h
//  sohunews
//
//  Created by 赵青 on 16/1/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHH5NewsWebViewController.h"
#import "SNArticle.h"
#import "SNNewsFaourService.h"
#import "SNNewsFavourCache.h"
#import "SNDBManager.h"
#import "SNNewsUninterestedService.h"
#import "SNMyFavouriteManager.h"
#import "SNSubscribeCenterService.h"
#import "SNCommentCacheManager.h"
#import "SNCommentToolBarView.h"
#import "SNNewsExposureManager.h"
#import "UIWebView+Utility.h"
#import "SNUserManager.h"
#import "SNProgressBar.h"
#import "SNCommonNewsController.h"
#import "SHHomePageArticleViewJSModel.h"
#import "SHUrlMaping.h"
#import "SNPhotoSlideshow.h"
#import "SNPhotoGallerySlideshowController.h"
#import "SNNewsGallerySlidershowController.h"
#import "SNUserUtility.h"
#import "SHWebView.h"
#import "SNH5NewsVideoPlayer.h"
#import "SNVideoAdContext.h"
#import "SNArticleRecomVideosWebService.h"
#import "RegexKitLite.h"
#import "SNSoundManager.h"
#import "SNGalleryPhotoView.h"
#import "SNSpaceId.h"
#import "SNNewAlertView.h"
#import "WSMVVideoStatisticModel.h"
#import "WSMVVideoStatisticManager.h"
#import "SNSearchWebViewController.h"
#import "SHMediaApi.h"
#import "SNLoadingImageAnimationView.h"
#import "SNCacheManager.h"
#import "SNArticleRecomService.h"
#import "SHADManager.h"
#import "SNGalleryBrowser.h"
#import "SNLongPressAlert.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNNewsShareManager.h"
#import "SNRollingNewsPublicManager.h"
#import "SNPhotoConfigs.h"
#import "SNUtility.h"
#import "SNArticleDownView.h" //SNArticleSheetDelegate中的举报操作callback
#import "SNRollingNewsUpdateRequest.h"
#import "SNAppConfigH5RedPacket.h"
#import "SNRedPacketManager.h"
#import "UIButton+WebCache.h"
#import "SNOfficialAccountsInfo.h"
#import "SNNewsLogin.h"
#import "SNClientRegister.h"
#import "SNPopOverMenu.h"
#import "SNCommentListByCursorRequest.h"
#import "SNAlertStackManager.h"
#import "SNSpecialActivity.h"
#import "SNNewsLoginManager.h"

#define kHFViewButtonFontSize ((kAppScreenWidth > 375.0) ? kThemeFontSizeF : kThemeFontSizeE)

#define WWWkSmallCorpusTabelHeight 54

#define kRechabilityChangedActionSheetTag (1000)
#define kTipsShadowHeight                 (6/2)
#define kSlideBackTipsWidth               (338/2)
#define kSlideBackTipsHeight              (92/2)
#define kSlideBackTipsHandLeft            (46/2)
#define kOfficialAccountViewHeight        (30)

@interface SHH5NewsWebViewController () <PostFollowDelegate, SNNewsFavourServiceDelegate, SNNewsFavourCacheDelegate, SNMyFavouriteManagerDelegate, SNCommentEditorPostDelegate, SNPhotoGallerySlideshowControllerDelegate, SNNewsGallerySlidershowControllerDelegate, SNGalleryBrowserDelegate, SNArticleSheetDelegate, SHWebViewShareDelegate> {
    BOOL _isWebViewLoaded;
    BOOL _isCommentNumLoad;
    BOOL _didShowSpecialAd;
    BOOL _isSendCount;
    BOOL _isFullScreenMode;
    BOOL _isOnlineMode;
    BOOL _supportContinuousReadingNext;
    BOOL _isVideoPlayerVisible;
    BOOL _isPvFired; //用户正文阅读pv统计 只记一次
    BOOL _isLastGroup;
    BOOL _isSmall;
    BOOL _isMiniVideoSwitch;
    BOOL _isKeyShow;
    BOOL _isPostFollowHiden;//标识正在执行滑动隐藏或显示的动画
    BOOL allowJumpAppStore;//允许跳转appstore subInfo
    BOOL isStartFresh;
    
    int _currentImageIndex;
    
    CGFloat _videoY;
    CGFloat _lastVerticalOffset;
    CGFloat _lastOffsetY;
    CGPoint _translation;
    CGFloat pinchScale;
    CGPoint clickBigImgPoint;
    
    NSNumber *_newsType;

    NSString *_clickImageUrl;
    NSString *_clickImageTitle;
    NSString *_h5Type;
    NSString *_h5WebLink;
    NSString *tempCommentTextFieldStr;//记录评论内容
    
    SNCommentSendType _commentType;
    MYFAVOURITE_REFER _myFavouriteRefer;
    SNGalleryPhotoView *_imageDetailView;
    SNSoundStatusType _status;
    SNArticleRecomService *_recommendService;
    SNOfficialAccountsInfo *_officialAccountsInfo;
    
    UIPinchGestureRecognizer *_pinchGesture;
    
    UIView *_backView;
    UIView *_blackView;
    UIView *statusBarView;
    NSDictionary *_h5SubInfo;
}

@property (nonatomic, copy) NSString *termId;
@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, copy) NSString *channelId;

//火车卡片相关
@property (nonatomic, copy) NSString *trainID;
@property (nonatomic, copy) NSString *trainIndex;

@property (nonatomic, copy) NSString *subId;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *gid;
@property (nonatomic, copy) NSString *newsCate;
@property (nonatomic, copy) NSString *referFrom;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString *notificationNews;
@property (nonatomic, copy) NSString *fromPush;
@property (nonatomic, copy) NSString *showType;
@property (nonatomic, copy) NSString *h5From;
@property (nonatomic, copy) NSString *recomInfo;//推荐流埋点上报参数
@property (nonatomic, strong) NSMutableDictionary *queryDict;

@property (nonatomic, strong) SHWebView *webView;
@property (nonatomic, strong) SNArticle *article;
@property (nonatomic, strong) GalleryItem *photoList;
@property (nonatomic, strong) NSDictionary *articleUserData;
@property (nonatomic, strong) NSOperationQueue *newsLoadOperationQueue;
@property (nonatomic, strong) SNActionMenuController *actionMenuController;
@property (nonatomic, strong) UIViewController *shareViewController;
@property (nonatomic, strong) SNNewsShareManager* shareManager;

@property (nonatomic, strong) SNActionMenuController *longActionMenuController;//暂时先这样 重构再说 @wangshun
@property (nonatomic, strong) NSString* shareContent;
@property (nonatomic, strong) SNNewsComment *shareComment;
@property (nonatomic, strong) SNNewsComment *replyComment;
@property (nonatomic, strong) SNCommentCacheManager *commentCacheManager;
@property (nonatomic, assign) SNReferFrom refer;
@property (nonatomic, strong) SNAnalyticsNewsReadTimer *analyticsTimer;
@property (nonatomic, strong) SNPhotoGallerySlideshowController *slideshowController;
@property (nonatomic, strong) NSIndexPath *returnIndex;
@property (nonatomic, strong) SNPhotoSlideshow *photoSlideshow;
@property (nonatomic, strong) SNNewsGallerySlidershowController *photoCtl;
@property (nonatomic) BOOL isShowBigPicView;

@property (nonatomic, strong) NSMutableArray * adInfos;
@property (nonatomic, strong) SNArticleRecomVideosWebService *recommendVideosWebService;
@property (nonatomic, strong) SNAdDataCarrier *sdkAdLastPic;
@property (nonatomic, strong) SNAdDataCarrier *sdkAdLastRecommend;
@property (nonatomic, strong) SNAdDataCarrier *sdkAd13371;

@property (nonatomic, strong) NSArray *videoPlayers;
@property (nonatomic) NSTimeInterval lastShareTime;
@property (nonatomic, strong) SNActionSheet *networkStatusActionSheet;
@property (nonatomic, strong) NSArray *recommendVideos;
@property (nonatomic, strong) NSString *soundUrl;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *updateTime;//新闻更新时间
@property (nonatomic, strong) SNLoadingImageAnimationView *animationImageView;
@property (nonatomic, assign) CGRect tmpVideoRect;
@property (nonatomic, strong) NSString *recomReasons;
@property (nonatomic, strong) NSString *recomTime;
@property (nonatomic, assign) BOOL isClickOpen;
@property (nonatomic, strong) SNGalleryBrowserController * galleryBrowser;
@property (nonatomic, copy) NSString *backWhere;
@property (nonatomic, strong) UIButton *redPacketBtn;
@property (nonatomic, strong) SNLongPressAlert *longPressAlert;
@property (nonatomic, strong) SNPopoverView *popOverView;
@property (nonatomic, strong) NSString *tempH5WebLink;
//收藏5次
@property (nonatomic,weak) SNCommentEditorViewController *commenteditor_vc;

@end

@implementation SHH5NewsWebViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        _isPvFired = NO;
        self.queryDict = [NSMutableDictionary dictionaryWithDictionary:query];
        self.newsId = [query objectForKey:kNewsId];
        self.channelId = [query objectForKey:kChannelId];
        self.trainID = [query objectForKey:kTrainId];
        self.trainIndex = [query objectForKey:kTrainIndex];
        self.termId = [query objectForKey:kTermId];
        self.referFrom = [query objectForKey:kReferFrom];
        self.type = [query objectForKey:kType];
        self.fromPush = [query objectForKey:@"fromPush"];
        self.updateTime = [query objectForKey:kUpdateTime];
        self.link = [query objectForKey:kLink];
        self.showType = [query objectForKey:@"showType"];
        self.h5From = [query objectForKey:@"h5from"];
        self.backWhere = [query objectForKey:SNNews_Push_Back_Key];
        self.recomInfo = [query objectForKey:kRecomInfo];
        
        allowJumpAppStore = NO;//默认不允许
        isStartFresh = NO;
        
        if (!self.link && [query objectForKey:kOpenProtocolOriginalLink2]) {
            self.link = [query objectForKey:kOpenProtocolOriginalLink2];
        }

        if (self.link) {
            if ([self.link rangeOfString:@"subId"].location != NSNotFound) {
                NSString *subId = [[self.link componentsSeparatedByString:@"subId="] lastObject];
                subId = [[subId componentsSeparatedByString:@"&"] firstObject];
                self.subId = subId;
            }
            if ([self.link rangeOfString:@"gid"].location != NSNotFound) {
                NSString *gid = [[self.link componentsSeparatedByString:@"gid="] lastObject];
                gid = [[gid componentsSeparatedByString:@"&"] firstObject];
                self.gid = gid;
            }
            if ([[self.link lowercaseString] hasPrefix:kProtocolNews] || [[self.link lowercaseString] hasPrefix:kProtocolVote]) {
                _newsType = [NSNumber numberWithInt:3];
            } else if ([[self.link lowercaseString] hasPrefix:kProtocolPhoto]) {
                _newsType = [NSNumber numberWithInt:4];
            }
            
            if ([self.link rangeOfString:@"newsCate"].location != NSNotFound) {
                NSString *newsCate = [[self.link componentsSeparatedByString:@"newsCate="] lastObject];
                newsCate = [[newsCate componentsSeparatedByString:@"&"] firstObject];
                self.newsCate = newsCate;
            } else if ([self.link rangeOfString:@"newscate"].location != NSNotFound) {
                NSString *newsCate = [[self.link componentsSeparatedByString:@"newscate="] lastObject];
                newsCate = [[newsCate componentsSeparatedByString:@"&"] firstObject];
                self.newsCate = newsCate;
            }
            if (self.fromPush && [self.fromPush isEqualToString:@"1"]) {
                self.link = [self.link stringByAppendingString:@"&fromPush=1"];
            }
            
            if (self.updateTime && self.updateTime.length > 0) {
                self.link = [self.link stringByAppendingString:[NSString stringWithFormat:@"&updateTime=%@", self.updateTime]];
            }
        }
        
        self.notificationNews = [query objectForKey:@"notification"];
        
        //不是从rollingnews页打开，没有termId，设置为-1
        if (self.termId.length <= 0) {
            self.termId = kDftChannelGalleryTermId;
        }
        self.channelId = [query objectForKey:kChannelId];
        if (self.channelId.length <= 0) {
            self.channelId = @"1";
        }
        
        NSString *onlineMode = [query objectForKey:kNewsMode];
        if ([onlineMode length] == 0) {
            _isOnlineMode = YES;
        } else {
            BOOL networkEnable = [[SNUtility getApplicationDelegate] isNetworkReachable];
            _isOnlineMode = networkEnable ? YES : [onlineMode isEqualToString:kNewsOnline];
        }
        
        if ([query objectForKey:kNewsSupportNext]) {
            _supportContinuousReadingNext = [[query objectForKey:kNewsSupportNext] boolValue];
        } else {
            _supportContinuousReadingNext = YES;
        }
        self.rollingNewsList = [query objectForKey:kNewsList];
        self.newsModel = [query objectForKey:kNewsModel];
        self.newsfrom = [query objectForKey:kNewsFrom];
        if (self.referFrom.length > 0) {
            if ([self.referFrom isEqualToString:kReferFromPublication]) {
                self.newsfrom = kSubscrieNews;
            };
        }
        
        if (self.newsfrom == nil || [self.newsfrom length] == 0) {
            self.newsfrom = kOtherNews;
        }
        
        self.isClickOpen = [[query objectForKey:kClickOpenNews] boolValue];
        
        _myFavouriteRefer = [[query objectForKey:kMyFavouriteRefer] intValue];

        _newsLoadOperationQueue = [[NSOperationQueue alloc] init];
        
        self.adInfos = [NSMutableArray array];
        
        self.videoPlayers = [NSArray array];
        
        NSString *newsDir = [query objectForKey:kNewsPaperDir];
        if (newsDir && [newsDir length] > 0) {
            _newsPaperDir = [newsDir copy];
        }
        
        self.recomReasons = [query objectForKey:kRecomReasons];
        self.recomTime = [query objectForKey:kRecomTime];
        
        _recommendService = [[SNArticleRecomService alloc] init];
    
        [SNNotificationManager addObserver:self selector:@selector(postCommentSucccess:) name:kPostCommentSuccessNotifiaction object:nil];
        [SNNotificationManager addObserver:self selector:@selector(audioStartNotification:) name:kAudioStartNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(onSoundDownloaded:) name:kSoundDownloaded object:nil];
        [SNNotificationManager addObserver:self selector:@selector(onSoundPlayFinished:) name:kSoundPlayFinished object:nil];
        [SNNotificationManager addObserver:self selector:@selector(onSoundStatusChanged:) name:kSoundPlayStatusChanged object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateFontTheme) name:kFontModeChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(openShareFloatView) name:kFromPushOpenShareFloatViewNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(wifiNetWorkChanged:) name:kReachabilityChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(replayCommentLoginSuccess) name:kLoginFromArticleReplayCommentNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(WillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (BOOL)panGestureEnable
{
    if (self.slideShowMode || self.isSlideShowMode) {
        return NO;
    }
    return YES;
}

- (void)WillResignActive
{
    [[SNSoundManager sharedInstance] stopAll];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self name:kPostCommentSuccessNotifiaction object:nil];    
    [SNNotificationManager removeObserver:self name:kAudioStartNotification object:nil];
    [SNNotificationManager removeObserver:self name:kSoundDownloaded object:nil];
    [SNNotificationManager removeObserver:self name:kSoundPlayFinished object:nil];
    [SNNotificationManager removeObserver:self name:kSoundPlayStatusChanged object:nil];
    [SNNotificationManager removeObserver:self name:kFontModeChangeNotification object:nil];
    [SNNotificationManager removeObserver:self name:kFromPushOpenShareFloatViewNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
    [SNNotificationManager removeObserver:self name:kLoginFromArticleReplayCommentNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    self.sdkAdLastPic.delegate = nil;
    self.sdkAdLastRecommend.delegate = nil;
    self.sdkAd13371.delegate = nil;
    
    for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
        [_videoPlayer stop];
        [_videoPlayer setDelegate:nil];
        [_videoPlayer clearMoviePlayerController];
        [_videoPlayer removeFromSuperview];
    }
    
    if (_webView)
    {
        _webView.scrollView.delegate = nil;
        _webView.shareDelegate = nil;
        _webView.jsDelegate = nil;
        [_webView stopObserveProgress];
    }
    
    if (_slideshowController) {
        _slideshowController.delegate = nil;
    }
    
    if (_photoCtl) {
        _photoCtl.delegate = nil;
        [_photoCtl.view removeFromSuperview];
    }
    
    if (_recommendService) {
        _recommendService.delegate = nil;
    }
    
    if (self.recommendVideosWebService) {
        self.recommendVideosWebService.delegate = nil;
        self.recommendVideosWebService = nil;
    }
    
    _postFollow._delegate = nil;
    _actionMenuController.delegate = nil;
    _longActionMenuController.delegate = nil;

    [SNMyFavouriteManager shareInstance].delegate = nil;
    
    _pinchGesture.delegate = nil;
    [self.view removeGestureRecognizer:_pinchGesture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelectorOnMainThread:@selector(updateTheme:) withObject:nil waitUntilDone:NO];
    if (self.newsId) {
        if (self.channelId) {
            [self loadNewsInOtherThreadWithNewsId:self.newsId channelId:self.channelId];
        } else if (self.termId) {
            [self loadNewsInOtherThreadWithNewsId:self.newsId termId:self.termId];
        }
    }
    
    if (![SNUtility isRightP1]) {
        [[SNClientRegister sharedInstance] registerClientAnyway];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [SNMyFavouriteManager shareInstance].isHandleFavorite = NO;
    self.webView.scrollView.scrollsToTop = YES;
    if (_postFollow) {
        _postFollow.isLiked = [self checkIfHadBeenMyFavourite];
        [_postFollow refreshCollectionImage];
    }
    
    if (!_isPvFired) {
        // 3.7 新闻正文pv统计
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlNewsContentPv, SNAnalyticsTimerPageTypeNewsArticle, self.refer, self.newsId];
        paramString = [paramString stringByAppendingFormat:@"&recomInfo=%@", self.recomInfo];
        [SNNewsReport reportADotGif:paramString];
        _isPvFired = YES;
    }
    
    // 阅读时常统计
    self.analyticsTimer = [SNAnalyticsNewsReadTimer timer];
    if (_newsType.intValue == 3) {
        self.analyticsTimer.page = SNAnalyticsTimerPageTypeNewsArticle;
    } else if (_newsType.intValue == 4) {
        self.analyticsTimer.page = SNAnalyticsTimerPageTypeNewsPhotoList;
    }
    self.analyticsTimer.newsId = self.newsId;
    self.analyticsTimer.subId = self.subId;
    self.analyticsTimer.channelId = self.channelId;
    self.analyticsTimer.newsfrom = self.newsfrom;
    self.analyticsTimer.recomInfo = self.recomInfo;
    self.analyticsTimer.link = self.link;
    
    [_officialAccountsInfo checkFollowedStatus];
    
    [SNUtility banUniversalLinkOpenInSafari];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _isPvFired = NO;
    [self pageTMStatistic];
    //从相关新闻返回到正文上报17
    self.newsfrom = kBackToNews;
    
    _isVideoPlayerVisible = NO;
    [self stopVideo];
    
    if (_animationImageView) {
        _animationImageView.status = SNImageLoadingStatusStopped;
    }
    
    [self.popOverView dismiss];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isVideoPlayerVisible = YES;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.newsfrom) {
        [dict setValue:self.newsfrom forKey:kNewsFrom];
    }
    
    if (self.isClickOpen) {
        NSString *with = nil;
        if (self.recomReasons && !self.recomTime) {
            with = @"1";
        }
        else if (!self.recomReasons && self.recomTime) {
            with = @"2";
        }
        else if (self.recomReasons && self.recomTime) {
            with = @"12";
        }
        if (with) {
            [dict setValue:with forKey:@"with"];
        }
    }

    [dict setValue:self.recomInfo forKey:@"recomInfo"];
    
    [self reportPVAnalyzeWithCurrentNavigationController:_commonNewsController.flipboardNavigationController ? _commonNewsController.flipboardNavigationController : self.flipboardNavigationController dictInfo:dict];

    /// 检查是否有符合条件的弹窗
    [[SNAlertStackManager sharedAlertStackManager] checkoutInStackAlertView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[SNSoundManager sharedInstance] stopAll];
    [_webView callJavaScript:@"cmtToolHide()" forKey:nil callBack:nil];
    
    if ([self isMemberOfClass:[SHH5NewsWebViewController class]]) {//正文页锚点 h5记录
         [_webView callJavaScript:@"getScrollTop()" forKey:nil callBack:nil];
    }
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = SNUICOLOR(kThemeBg5Color);
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        [self performSelectorOnMainThread:@selector(initWebViewAndElement) withObject:nil waitUntilDone:NO];
    }
    else {
        [self initWebViewAndElement];
    }
}

- (void)initWebViewAndElement {
    [self loadWebView];
    statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSystemBarHeight)];
    statusBarView.backgroundColor = SNUICOLOR(kThemeBg5Color);
    [self.view addSubview:statusBarView];
    
    self.animationImageView.status = SNImageLoadingStatusLoading;
    [self loadPostFollow];
    
    if ([self.backWhere isEqualToString:SNNews_Push_Back_RecomNews]) {
        [_postFollow creatUpdateNumberView];
        [self loadNewUpdateRequest:@"13557"];
    } else if ([self.backWhere isEqualToString:SNNews_Push_Back_FocusNews]) {
        [_postFollow creatUpdateNumberView];
        [self loadNewUpdateRequest:@"1"];
    }
    
    if ([self currentPage] == article_detail_txt || [self currentPage] == article_detail_pic) {
        //只有图文新闻、组图新闻显示红包按钮
        [self showRedPacketBtn];
        
        JsKitStorage *jsKitStorageMange  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
        //告知H5什么时候请求红包数据
        [jsKitStorageMange setItem:[NSNumber numberWithInt:0] forKey:@"isCloseH5PicTextRedPacket"];
    }
}

- (void)pageTMStatistic {
    [self setAnalyticsData];
    self.analyticsTimer.newsfrom = self.newsfrom;
    [self.analyticsTimer reportTM];
}

- (void)pagePVStatistic {
    if (self.analyticsTimer) {
        [self setAnalyticsData];
        self.analyticsTimer.newsfrom = kBackToNews;
        [self.analyticsTimer fire];
        self.analyticsTimer = nil;
    }
}

- (void)setAnalyticsData {
    NSString *hotLabel = nil;
    NSString *readLengthLabel = nil;
    if (self.gid.length > 1) {
        hotLabel = [NSString stringWithFormat:@"GnewsHotLable%@", self.gid];
        readLengthLabel = [NSString stringWithFormat:@"GreadLengthLable%@", self.gid];
    } else {
        hotLabel = [NSString stringWithFormat:@"newsHotLable%@", self.newsId];
        readLengthLabel = [NSString stringWithFormat:@"readLengthLable%@", self.newsId];
    }
    
    id isFavour = [_webView.jsKit.coreApi memoryItemForKey:hotLabel];
    id isEnd    = [_webView.jsKit.coreApi memoryItemForKey:readLengthLabel];
    
    if (isFavour) {
        if ([isFavour isKindOfClass:[NSNumber class]]) {
            self.analyticsTimer.isFavour = [isFavour integerValue];
        } else if ([isFavour isKindOfClass:[NSString class]] && ((NSString *)isFavour).length > 0) {
            self.analyticsTimer.isFavour = [isFavour integerValue];
        }
    } else {
        self.analyticsTimer.isFavour = 0;
    }
    
    if (isEnd) {
        if ([isEnd isKindOfClass:[NSNumber class]]) {
            self.analyticsTimer.isEnd = [isEnd boolValue];
        } else if ([isEnd isKindOfClass:[NSString class]] && ((NSString *)isEnd).length > 0) {
            self.analyticsTimer.isEnd = [(NSString *)isEnd isEqualToString:@"1"] ? YES : NO;
        }
    }
}

- (void)loadNewUpdateRequest:(NSString *)channelId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:channelId forKey:kChannelId];
    NSString *forceRefresh = @"0";
    
    if ([channelId isEqualToString:@"13557"]) {
        if ([SNRollingNewsPublicManager sharedInstance].isRecomForceRefresh || ![SNUserDefaults boolForKey:kChannelforceRefreshKey]) {
            //同推荐流强制刷新逻辑，请求推荐流强制刷新数
            forceRefresh = @"1";
            [SNRollingNewsPublicManager sharedInstance].isRecomForceRefresh = NO;
        }
    }
    [params setObject:forceRefresh forKey:@"forceRefresh"];

    [[[SNRollingNewsUpdateRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootData) {
        if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = [rootData objectForKey:@"data"];
            NSNumber *updateNub = [dict objectForKey:@"unreadNum"];
            [_postFollow setUpdateNumber:updateNub.integerValue backWhere:self.backWhere];
        }
    } failure:nil];
}

- (void)handlePinchFrom:(UIPinchGestureRecognizer *)pinch {
    if (pinch.state == UIGestureRecognizerStateEnded) {
        if (pinch.scale > pinchScale) {
            [SNUtility setBiggerFontSize];
        } else if(pinch.scale < pinchScale) {
            [SNUtility setSmallerFontSize];
        }
    } else if(pinch.state == UIGestureRecognizerStateBegan) {
        pinchScale = pinch.scale;
    }
}

#pragma mark--- SNArticleSheetDelegate
- (void)nightShiftOperation:(BOOL)nightMode {
    //@qz abtest 更多页面 设置夜间模式 埋点
    [SNNewsReport reportADotGif:@"_act=cc&fun=112"];
    [self setNightMode:nightMode];
}

- (void)tipOffOperation {
    [self onClickReport];
}

- (void)updateFontSize:(NSInteger)fontSize {
    [self setNewsFontSize:fontSize];
}

//正文更多浮层功能（字体调整、夜间模式、举报功能实现）
//调整字体  2小，3中，4大
- (void)setNewsFontSize:(NSInteger)fontSize
{
    //跟设置页面的setNewsFontSize不统一
    //@qz abtest 埋点
    [SNNewsReport reportADotGif:@"_act=cc&fun=113"];
    [SNUtility setH5NewsFontSize:fontSize];
}

//设置夜间模式
- (void)setNightMode:(BOOL)nightMode
{
    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.nightModeChanged" withObject:[NSNumber numberWithBool:nightMode]];
    if (nightMode) {
        [[SNThemeManager sharedThemeManager] launchCurrentTheme:kThemeNight];
        JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
        [jsKitStorage setItem:[NSNumber numberWithBool:YES] forKey:@"settings_nightMode"];
        [SNUtility sendSettingModeType:SNUserSettingDayMode mode:@"1"];
    } else {
        [[SNThemeManager sharedThemeManager] launchCurrentTheme:kThemeDefault];
        JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
        [jsKitStorage setItem:[NSNumber numberWithBool:NO] forKey:@"settings_nightMode"];
        [SNUtility sendSettingModeType:SNUserSettingDayMode mode:@"0"];
    }
}

- (void)updateFontTheme
{
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage setItem:[NSNumber numberWithInteger:[SNUtility getNewsFontSizeIndex] - 2] forKey:@"settings_fontSize"];
    
    if ([NSThread isMainThread]) {
        [self.webView callJavaScript:[NSString stringWithFormat:@"window.changeFontSize(%@)",[NSNumber numberWithInteger:[SNUtility getNewsFontSizeIndex] - 2]] forKey:nil callBack:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView callJavaScript:[NSString stringWithFormat:@"window.changeFontSize(%@)",[NSNumber numberWithInteger:[SNUtility getNewsFontSizeIndex] - 2]] forKey:nil callBack:nil];
        });
    }
}

- (void)addSwipeGesture
{
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeUp.delegate = self;
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer* swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeDown.delegate = self;
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
 
    if ([_h5Type isEqualToString:@"0"]) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
        _pinchGesture.delegate = self;
        [self.view addGestureRecognizer:_pinchGesture];
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGesture];
}

#pragma mark load subviews
- (void)loadWebView
{
    CGFloat height = kAppScreenHeight - kSystemBarHeight - kHeaderHeight;
    self.webView = [[SHWebView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, height)];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.scrollView.scrollsToTop = YES;
    [self.webView setBackgroundColor:SNUICOLOR(kThemeBg5Color)];
    self.webView.scrollView.delegate = self;
    self.webView.shareDelegate = self;
    self.webView.opaque = NO; // 设成YES会使夜间模式时，视频新闻背景色闪白一下
    //用于接收JS事件
    SHHomePageArticleViewJSModel *jsModel = [[SHHomePageArticleViewJSModel alloc] init];
    jsModel.newsH5WebViewController = self;
    jsModel.queryDict = self.queryDict;
    jsModel.subId = self.subId;

    self.webView.jsDelegate = self;
    [self.webView registerJavascriptInterface:jsModel forName:@"newsApi"];
  
    SHMediaApi *mediaApiModel = [[SHMediaApi alloc] init];
    mediaApiModel.newsH5WebViewController = self;
    [self.webView registerJavascriptInterface:mediaApiModel forName:@"mediaApi"];

    [self.view addSubview:self.webView];
}

- (void)shareClick:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:@"share" object:sender];
    [self handleShareNotify:notification];
}

- (SNLoadingImageAnimationView *)animationImageView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.view.frame];
        _backView.backgroundColor = SNUICOLOR(kThemeBg5Color);
        [self.view addSubview:_backView];
    }
    if (!_animationImageView) {
        _animationImageView = [[SNLoadingImageAnimationView alloc] init];
        _animationImageView.targetView = _backView;
    }
    
    return _animationImageView;
}

- (void)stopProgress:(NSInteger)isLonging {
    if (isLonging == 0) {
        self.animationImageView.status = SNImageLoadingStatusStopped;
        _backView.hidden = YES;
        [self showSlideBackTips];
        [self jsKitStorageGetItem];
        _officialAccountsInfo.newsId = self.newsId;
        _officialAccountsInfo.channelId = self.channelId;
        
        if (!_didShowSpecialAd) {
            _didShowSpecialAd = [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeNewsDetail majorkey:SNArticleADDefaultSpaceID];
        }
        if (!_didShowSpecialAd) {
            [self performSelector:@selector(onlyOnceScreenSharePopOverView) withObject:nil afterDelay:0.25];
        } else {
            NSString *s = [SNUserDefaults objectForKey:kFirstShowScreenShareKey2];
            if (!s) {
                [SNUserDefaults setObject:@"1" forKey:kFirstShowScreenShareKey2];
            }
        }
    } else {
        self.animationImageView.status = SNImageLoadingStatusLoading;
        _backView.hidden = NO;
    }
}

- (void)scrollToTop {
    [self.webView.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)showSlideBackTips {
    if (![SNUserDefaults boolForKey:kFirstSlideBackTipsKey]) {
        [SNUserDefaults setBool:YES forKey:kFirstSlideBackTipsKey];
        [SNUtility sharedUtility].isShowRightSlipeTips = YES;
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSlideBackTipsWidth + kTipsShadowHeight*2, kSlideBackTipsHeight + kTipsShadowHeight*2)];
        bgImageView.image = [[UIImage imageNamed:@"icozw_bg_v5.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
        bgImageView.center = self.view.center;
        [self.view addSubview:bgImageView];
        
        UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(kSlideBackTipsHandLeft + 11, 26/2 + kTipsShadowHeight, 38/2, 14/2)];
        arrowImage.image = [UIImage imageNamed:@"icozw_arrow_v5.png"];
        [bgImageView addSubview:arrowImage];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSlideBackTipsHandLeft + 37.0, kTipsShadowHeight, kSlideBackTipsWidth - 100/2, kSlideBackTipsHeight)];
        titleLabel.text = kFirstSlideBackTips;
        titleLabel.font = [UIFont systemFontOfSize:28/2];
        titleLabel.textColor = SNUICOLOR(kThemeCheckLineColor);
        [bgImageView addSubview:titleLabel];
        
        UIImageView *handImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSlideBackTipsHandLeft, 30/2 + kTipsShadowHeight, 32/2, 42/2)];
        handImageView.image = [UIImage imageNamed:@"icozw_hand_v5.png"];
        [bgImageView addSubview:handImageView];
    
        [UIView animateWithDuration:1.0f animations:^{
            handImageView.centerX = 106/2;
            handImageView.alpha = 0;
        } completion:^(BOOL finished) {
            handImageView.centerX = kSlideBackTipsHandLeft + 16/2;
            handImageView.alpha = 1;
            [UIView animateWithDuration:1.0f animations:^{
                handImageView.centerX = 106/2;
                handImageView.alpha = 0;
            } completion:^(BOOL finished) {
                handImageView.centerX = kSlideBackTipsHandLeft + 16/2;
                handImageView.alpha = 1;
                [UIView animateWithDuration:1.0f animations:^{
                    handImageView.centerX = 106/2;
                    handImageView.alpha = 0;
                } completion:^(BOOL finished) {
                    handImageView.centerX = kSlideBackTipsHandLeft + 16/2;
                    handImageView.alpha = 1;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:.2f animations:^{
                            bgImageView.alpha = 0;
                        } completion:^(BOOL finished) {
                            [bgImageView removeFromSuperview];
                            [SNUtility sharedUtility].isShowRightSlipeTips = NO;
                        }];
                    });
                }];
            }];
        }];
    }
}

- (void)loadPostFollow
{
    if (!_postFollow) {
        NSString *str = NSLocalizedString(@"ComposeComment", nil);
        SNPostFollow *h5postFollow = [[SNPostFollow alloc] init];
        self.postFollow = h5postFollow;
        _postFollow._strPostOrComment = str;
        _postFollow.recomInfo = self.recomInfo;
        _postFollow._viewController = self;
        _postFollow._delegate = self;
        [_postFollow createInitStatus];
        return;
        
        //TODO:
        NSString *strTitle = NSLocalizedString(@"ComposeComment", nil);
        SNPostFollow *postFollow = [[SNPostFollow alloc] init];
        self.postFollow = postFollow;
        _postFollow._strPostOrComment = strTitle;
        _postFollow._viewController = self;
        _postFollow._delegate = self;
        [_postFollow createWithType:SNPostFollowTypeBackAndCommentAndCollectionAndShare];
        [_postFollow setShareBtnEnabel:YES];
        _postFollow.isLiked = [self checkIfHadBeenMyFavourite];
        [_postFollow refreshCollectionImage];
        [_postFollow setButton:2 enabled:NO];
        [_postFollow setButton:3 enabled:NO];
        
    } else {
        _postFollow.isLiked = [self checkIfHadBeenMyFavourite];
        [_postFollow refreshCollectionImage];
    }
}

- (void)hideOrShowCollection:(NSNumber *)showType {
    if (showType.intValue == 0) {
        [_postFollow hideCollectionView:YES];
    } else {
        [_postFollow hideCollectionView:NO];
    }
    
}

- (SNCCPVPage)currentPage {
    if (_newsType.integerValue == 3) {
        return article_detail_txt;
    } else if (_newsType.integerValue == 4) {
        return article_detail_pic;
    }
    return nil;
}

- (NSString *)currentOpenLink2Url {
    NSString *link = [self.queryDict stringValueForKey:kLink defaultValue:nil];
    return [self.queryDict stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:link];
}

- (void)updateTheme:(NSNotification *)notifiction {
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.nightModeChanged" withObject:[NSNumber numberWithBool:YES]];
    } else {
        [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.nightModeChanged" withObject:[NSNumber numberWithBool:NO]];
    }
    [_officialAccountsInfo updateTheme];
    statusBarView.backgroundColor = SNUICOLOR(kThemeBg5Color);
    self.view.backgroundColor = SNUICOLOR(kThemeBg5Color);
    self.webView.backgroundColor = SNUICOLOR(kThemeBg5Color);
    [_postFollow updateTheme];
    if (self.redPacketBtn) {
        [self updateRedPacketImage];
    }
}

- (NSString *)refererTypeFromNewsFrom:(NSString *)newsFrom {
    if ([self.newsfrom isEqualToString:kChannelEditionNews]) {
         return @"1";
    }
    else if ([self.newsfrom isEqualToString:kChannelRecomNews]) {
        return @"2";
    }
    else if ([self.newsfrom isEqualToString:kSearchNews]) {
        return @"3";
    }
    else if ([self.newsfrom isEqualToString:kNewsRecomNews]) {
        return @"4";
    }
    else if ([self.newsfrom isEqualToString:khotSearch]) {
        return khotSearch;
    }
    else if ([self.newsfrom isEqualToString:kArticleBlueWordsSearch]) {
        return kArticleBlueWordsSearch;
    }
    else if ([self.newsfrom isEqualToString:kHomePagePullSearch]) {
        return kHomePagePullSearch;
    }
    else if ([self.newsfrom isEqualToString:kChannelListSearch]) {
        return kChannelListSearch;
    }
    
    return @"1";
}

- (void)viewShouldStartLoadWithURL:(NSString *)articleURL {
    
    NSString *URL = nil;
    if ([[articleURL lowercaseString] hasPrefix:kProtocolHTTP]) {
        URL = articleURL;
    } else if ([[articleURL lowercaseString] hasPrefix:kProtocolNews]) {
        URL = [NSString stringWithFormat:@"%@?%@&refererType=%@", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [self getH5ArticleParames:articleURL], [self refererTypeFromNewsFrom:self.newsfrom]];
    } else if ([[articleURL lowercaseString] hasPrefix:kProtocolPhoto]) {
        URL = [NSString stringWithFormat:@"%@?%@&newstype=4&refererType=%@", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [self getH5ArticleParames:articleURL], [self refererTypeFromNewsFrom:self.newsfrom]];
    } else if ([[articleURL lowercaseString] hasPrefix:kProtocolVote]) {
        URL = [NSString stringWithFormat:@"%@?%@&newstype=vote&refererType=%@", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [self getH5ArticleParames:articleURL], [self refererTypeFromNewsFrom:self.newsfrom]];
    }  else if ([[articleURL lowercaseString] hasPrefix:kProtocolJoke]) {
        URL = [NSString stringWithFormat:@"%@?%@&newstype=62&goCmt", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [self getH5ArticleParames:articleURL]];
    }
    
    if (self.showType.length > 0) {
        URL = [URL stringByAppendingFormat:@"&showType=%@", self.showType];
    }
    if (self.h5From.length > 0) {
        URL = [URL stringByAppendingFormat:@"&h5from=%@", self.h5From];
    }
    
    _isLastGroup = NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
}

#pragma mark - Load news
- (void)loadWebViewWithNewsArticle:(SNArticle *)atl {
    [self viewShouldStartLoadWithURL:self.link];
}

- (NSString *)getH5ArticleParames:(NSString *)article {
    NSString *secondProtocal = article;
    if (secondProtocal.length > 0) {
        NSArray *lastURLString = [secondProtocal componentsSeparatedByString:@"//"];
        if (lastURLString.count > 0) {
            NSString *param = [lastURLString lastObject];
            if (param.length > 0) {
                return param;
            }
        }
    }
    return nil;
}

//注意这个方法需要用另一个线程调
- (void)loadNewsThreadAction:(NSMutableArray *)param {
    if (param) {
        [self performSelectorOnMainThread:@selector(loadWebViewWithNewsArticle:)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

//注意这个方法需要用另一个线程调
- (void)loadRollingNewsThreadAction:(NSMutableArray *)param {
    if (param) {
        [self performSelectorOnMainThread:@selector(loadWebViewWithNewsArticle:)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)loadNewsInOtherThreadWithNewsId:(NSString *)newsId
                                 termId:(NSString *)termId {
    [self loadNewsInOtherThreadWithNewsId:newsId termId:termId userData:nil];
}

- (void)loadNewsInOtherThreadWithNewsId:(NSString *)newsId
                                 termId:(NSString *)termId
                               userData:(NSDictionary *)userData {
    if (!newsId || !termId) {
        return;
    }
    
    self.article = nil;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:4];
    if (userData) {
        [dic addEntriesFromDictionary:userData];
    }
    
    NSMutableArray *param = [[NSMutableArray alloc] init];
    [param addObject:(newsId == nil) ? (id)[NSNull null] : (id)newsId];
    [param addObject:(termId == nil) ? (id)[NSNull null] : (id)termId];
    [param addObject:(dic == nil) ? (id)[NSNull null] : (id)dic];
    
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadNewsThreadAction:) object:param];
    [_newsLoadOperationQueue addOperation:op];
}

- (void)loadNewsInOtherThreadWithNewsId:(NSString *)newsId
                              channelId:(NSString *)channelId {
    [self loadNewsInOtherThreadWithNewsId:newsId channelId:channelId userData:nil];
}

- (void)loadNewsInOtherThreadWithNewsId:(NSString *)newsId
                              channelId:(NSString *)channelId
                               userData:(NSDictionary *)userData {
    
    if (!newsId || !channelId) {
        return;
    }
    
    self.article = nil;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:4];
    if (userData) {
        [dic addEntriesFromDictionary:userData];
    }
    
    NSMutableArray *param	= [[NSMutableArray alloc] init];
    [param addObject:(newsId == nil) ? (id)[NSNull null] : (id)newsId];
    [param addObject:(channelId == nil) ? (id)[NSNull null] : (id)channelId];
    
    if (nil != self.queryDict) {
        NSString *subID = [self.queryDict objectForKey:kSubId];
        if(nil != subID && [subID length] > 0){
            [dic setObject:subID forKey:kSubId];
        }
    }
    
    [param addObject:(dic == nil) ? (id)[NSNull null] : (id)dic];
    
    
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                     selector:@selector(loadRollingNewsThreadAction:)
                                                                       object:param];
    [_newsLoadOperationQueue addOperation:op];
}

#pragma mark - UIGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _translation = [gesture locationInView:self.view];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translation1 = [gesture locationInView:self.view];
        if (translation1.x >= 0 && fabsf(_translation.y - translation1.y) < 50 && _translation.x - translation1.x > 100) {
            //找不到commonNews信息，直接返回
            if (!_commonNewsController) {
                return;
            }
            if (self.galleryBrowser) {
                return;
            }
            //如果在大图页 触发该事件 不允许左滑跳转下一页 // add by cuiliangliang 2016.05.11
            if (self.photoCtl && [self.photoCtl.view superview] ) {
                return;
            }
            //如果在组图页 触发该事件 不允许左滑跳转下一页 // add by cuiliangliang 2016.05.12
            if (self.slideshowController && [self.slideshowController.view superview]) {
                return;
            }
            //如果在视频播放滑动推荐视频时  触发该事件 不允许左滑跳转下一页 // add by cuiliangliang 2016.05.11
            for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
                if (_videoPlayer.relativeVideosView.alpha == 1 ||
                    _videoPlayer.controlBarNonFullScreen.alpha == 1) {
                    CGPoint point = [gesture locationInView:self.webView.scrollView];
                    if (point.y > _videoPlayer.frame.origin.y &&
                        point.y < (_videoPlayer.frame.origin.y + _videoPlayer.frame.size.height)) {
                        return;
                    }
                }
                if (_isSmall == YES) {
                    CGPoint point = [gesture locationInView:self.view];
                    if (point.x > _videoPlayer.frame.origin.x &&
                        point.x < (_videoPlayer.frame.origin.x + _videoPlayer.frame.size.width) &&
                        point.y > _videoPlayer.frame.origin.y && point.y < (_videoPlayer.frame.origin.y + _videoPlayer.frame.size.height)) {
                        return;
                    }
                }
            }
            
            //需要切换页面
            if (_commonNewsController != nil &&
                [_commonNewsController swithController:[self newsId] type:_type]) {
                //标记连续阅读
                
                [self resetSDKAd];
                [SNRollingNewsPublicManager sharedInstance].isReadMoreArticles = YES;
                return;
            }
            if (!self.article.nextId || self.article.nextId.length == 0) {
                if ([self.rollingNewsList count] != 0) {
                    //频道预览打开正文页时，self.rollingNewsList为nil
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"AlreadyLastNews", @"Already last news") toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
        }
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gesture {
    if (self.galleryBrowser) {
        return;
    }

    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        if ([SNPreference sharedInstance].autoFullscreenMode) {
            if (!_isFullScreenMode) {
                [self enterFullScreenMode];
            }
        }
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        if ([SNPreference sharedInstance].autoFullscreenMode) {
            if (_isFullScreenMode) {
                [self exitFullScreenMode];
            }
        }
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        if (_isFullScreenMode) {
            [self exitFullScreenMode];
        }
        [_postFollow changeUserName];
    }
}

#pragma mark full screen
- (void)enterFullScreenMode
{
    _isFullScreenMode = YES;
    CGFloat height;
    if ([_h5Type isEqualToString:@"1"]) {
        height = kAppScreenHeight;
    } else {
        height = kAppScreenHeight-kSystemBarHeight;
    }

    SNH5NewsVideoPlayer *_videoPlayer;
    if (self.videoPlayers.count > 0 ) {
        _videoPlayer = self.videoPlayers[0];
    }
    [UIView animateWithDuration:0.4 animations:^{
        _isPostFollowHiden = YES;
        self.webView.height = height;
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarHeight + 20, 0);;
        if (_videoPlayer) {
            _videoPlayer.isAnimation = YES;
            _videoPlayer.isShowNavView = NO;
        }
        [self.postFollow show:NO];
        if (_videoPlayer && _videoPlayer.videoWindowType == SNVideoWindowType_normal && !_videoPlayer.isBeingChange && _videoPlayer.frame.size.height != self.tmpVideoRect.size.height) {
            _videoPlayer.height = self.tmpVideoRect.size.height;
        }
        _postFollow.updateNubImageView.alpha = 0;
    } completion:^(BOOL finished) {
        _isPostFollowHiden = NO;
        if (_videoPlayer) {
            _videoPlayer.isAnimation = NO;
            if (_videoPlayer.isBecomingMini == YES) {
                [_videoPlayer setSmallVideoAnimation:YES];
                _isSmall = YES;
                _videoPlayer.isBecomingMini = NO;
            }
        }
    }];
}

- (void)exitFullScreenMode
{
    _isFullScreenMode = NO;
    CGFloat height;
    if ([_h5Type isEqualToString:@"1"]) {
        height = kAppScreenHeight-kSystemBarHeight-44;
    } else {
        height = kAppScreenHeight-kSystemBarHeight-kToolbarViewTop;
    }

    SNH5NewsVideoPlayer *_videoPlayer;
    if (self.videoPlayers.count > 0 ) {
        _videoPlayer = self.videoPlayers[0];
    }
    [UIView animateWithDuration:0.8 animations:^{
        _isPostFollowHiden = YES;
        self.webView.height = height;
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarHeight, 0);
        
        [self.postFollow show:YES];
        _postFollow.updateNubImageView.alpha = 1;
    } completion:^(BOOL finished) {
        _isPostFollowHiden = NO;
        if (_videoPlayer && _videoPlayer.videoWindowType == SNVideoWindowType_normal && !_videoPlayer.isBeingChange) {
            _videoPlayer.frame = self.tmpVideoRect;
        }
    }];
}

- (UIView *)nightModeView {
    if (!_nightModeView) {
        _nightModeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.webView.width, self.webView.height)];
        UIColor *color = SNUICOLOR(kThemeBgRIColor);
        _nightModeView.backgroundColor = color;
        _nightModeView.alpha = 0.5;
    } else {
        _nightModeView.alpha = 0.5;
    }
    [_nightModeView setFrame:CGRectMake(0, 0, self.webView.scrollView.contentSize.width, self.webView.scrollView.contentSize.height)];
    return _nightModeView;
}

- (void)setWebviewNightModeView:(BOOL)isNight
{
    if (isNight) {
        if ([self.webView.subviews count] > 0 && [[self.webView.subviews objectAtIndex:0].subviews count] > 0) {
            UIView *view = [[self.webView.subviews objectAtIndex:0].subviews objectAtIndex:0];
            [view addSubview:self.nightModeView];
            self.webView.backgroundColor = [UIColor colorFromString:@"#aaaaaa"];
        }
    } else {
        if (_nightModeView) {
            _nightModeView.alpha = 0;
        }
    }
}

#pragma mark - SubInfo
- (void)addOfficialAccountViewWithInfo:(NSDictionary *)subInfo {
    if (!_officialAccountsInfo) {
        CGFloat posionY = [subInfo floatValueForKey:kOffsetTopKey defaultValue:-1];
        if (posionY >= 0) {
            _officialAccountsInfo = [[SNOfficialAccountsInfo alloc] initWithTargetWebView:self.webView position:CGPointMake(0, posionY) h5Type:@"0"];
            _officialAccountsInfo.controller = self.commonNewsController ? : self;
            [_officialAccountsInfo show];
        }
    }
    [_officialAccountsInfo updateWithJSON:subInfo];
}

- (void)addSubscribeWithInfo:(NSDictionary *)subInfo {
    if (!_h5Type) {
        _h5SubInfo = subInfo;
    } else if ([_h5Type isEqualToString:@"0"]) {
        [self addOfficialAccountViewWithInfo:subInfo];
    } else if ([_h5Type isEqualToString:@"1"]) {
        [self loadOfficialAccountView];
        [_officialAccountsInfo h5UpdateWithJSON:subInfo];
        
        NSNumber* supportDownload = [subInfo objectForKey:@"supportDownload"];
        if (supportDownload.integerValue == 1) {
            allowJumpAppStore = YES;
        }
        else{
            allowJumpAppStore = NO;
        }
    }
}

- (void)loadOfficialAccountView {
    if (!_officialAccountsInfo) {
        _officialAccountsInfo = [[SNOfficialAccountsInfo alloc] initWithTargetWebView:self.webView position:CGPointMake(0, kSystemBarHeight) h5Type:_h5Type];
        _officialAccountsInfo.controller = self.commonNewsController ? : self;
        [_officialAccountsInfo show];
    }
}

#pragma mark comment
- (void)setCommentNum:(NSString *)count
{
    if (count.length > 0 && [count intValue] > 0) {
        [_postFollow setCommentNum:count];
    } else {
        [_postFollow setCommentNum:@"0"];
    }
}

- (void)setCommentNumEnble
{
    if (!_isCommentNumLoad) {
        [_postFollow setButton:2 enabled:YES];
        _isCommentNumLoad = YES;
    }
}

- (void)commentNumBtnClicked
{
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=cm&_tp=vv&newsId=%@&channelId=%@", self.newsId, self.channelId]];
    [self.webView callJavaScript:@"viewComment(0)" forKey:nil callBack:nil];
}

#pragma mark - Collection

- (void)setCollectionNum:(int)count
{
    if (_postFollow) {
        _postFollow.collectionNum = count;
        //组图浏览切换到下条新闻时，更新收藏状态
        _postFollow.isLiked = [self checkIfHadBeenMyFavourite];
        [_postFollow refreshCollectionImage];
        [_postFollow setButton:3 enabled:YES];
    }
}

- (void)setCollectionCount:(int)count
{
    if (_h5Type && [_h5Type isEqualToString:@"1"]) {
        return;
    }
    [self setCollectionNum:count];
}

#pragma mark - PostComment
- (void)postCommentSucccess:(NSNotification *)notification
{
    SNDebugLog(@"test postCommentSucccess");
    NewsCommentItem *newsCommentItem = [notification object];
    if ([self.newsId isEqualToString:newsCommentItem.newsId]) {
        NSDictionary *dict = [self creatNewsCommentItem:newsCommentItem];
        if (dict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *jsonStr = [dict translateDictionaryToJsonString];
                [_webView callJavaScript:[NSString stringWithFormat:@"commentAddNew(%@)", jsonStr] forKey:nil callBack:nil];
            });
        }
    }
}

- (NSDictionary *)creatNewsCommentItem:(NewsCommentItem *)newsCommentItem
{
    if (newsCommentItem) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *userCommentId = newsCommentItem.userComtId; // 评论增加删除功能,服务端下发userCommentId参数,传给H5 2017.5.15
        [dict setObject:newsCommentItem.author forKey:@"authorName"];
        [dict setObject:newsCommentItem.ctime forKey:@"longTime"];
        [dict setObject:@"刚刚" forKey:@"formatTime"];
        [dict setObject:newsCommentItem.content forKey:@"content"];
        [dict setObject:newsCommentItem.digNum ? newsCommentItem.digNum : @"" forKey:@"digNum"];
        [dict setObject:@"" forKey:@"resource"];
        [dict setObject:@"" forKey:@"signList"];
        [dict setObject:@"" forKey:@"tag"];
        [dict setObject:@"" forKey:@"emotion"];
        [dict setObject:@"0" forKey:@"allCount"];
        [dict setObject:@"" forKey:@"authorCity"];
        [dict setObject:@"" forKey:@"authorCityAll"];
        if ([newsCommentItem.type isEqualToString:@"reply"]) {
            NSMutableDictionary *contentDic = [newsCommentItem.content translateJsonStringToDictionary].mutableCopy;
            if ([contentDic objectForKey:@"imageBig"] && [[contentDic objectForKey:@"imageBig"] length] > 0) {
                NSString *fileName = [[TTURLCache sharedCache] keyForURL:[contentDic objectForKey:@"imageBig"]];
                NSString *filePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:fileName];
                filePath = [@"jskitfile:" stringByAppendingString:filePath];
                [contentDic setObject:filePath forKey:@"imageBig"];
                [contentDic setObject:filePath forKey:@"imageSmall"];
            } else if ([contentDic objectForKey:@"imageSmall"] && [[contentDic objectForKey:@"imageSmall"] length] > 0) {
                NSString *fileName = [[TTURLCache sharedCache] keyForURL:[contentDic objectForKey:@"imageSmall"]];
                NSString *filePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:fileName];
                [contentDic setObject:filePath forKey:@"imageBig"];
                [contentDic setObject:filePath forKey:@"imageSmall"];
            }
            
            if (![contentDic objectForKey:@"content"]) {
                [contentDic setObject:@"" forKey:@"content"];
            }
            
            [contentDic setObject:newsCommentItem.pid forKey:@"pid"];
            NSString *passport = [SNUserManager getUserId];
            if (passport.length > 0) {
                [contentDic setValue:passport forKey:kPassport];
            }
            if (userCommentId && userCommentId.length > 0) {
                [contentDic setObject:userCommentId forKey:@"userCommentId"];
            } else {
                [contentDic setObject:@"0" forKey:@"userCommentId"];
            }
            [contentDic setObject:@"0" forKey:@"commentId"];
            NSString *jsonStr = [contentDic translateDictionaryToJsonString];
            [dict setObject:jsonStr forKey:@"mFloorData"];
        } else {
            NSMutableDictionary *floorDict = [NSMutableDictionary dictionary];
            [floorDict setObject:newsCommentItem.content forKey:@"content"];
            [floorDict setObject:newsCommentItem.author forKey:@"author"];
            [floorDict setObject:@"" forKey:@"gen"];
            [floorDict setObject:newsCommentItem.pid forKey:@"pid"];
            NSString *passport = [SNUserManager getUserId];
            if (passport.length > 0) {
                [floorDict setValue:passport forKey:kPassport];
            }
            [floorDict setObject:@"" forKey:@"egHomePage"];
            if (newsCommentItem.imagePath) {
                NSString *fileName = [[TTURLCache sharedCache] keyForURL:newsCommentItem.imagePath];
                NSString *filePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:fileName];
                filePath = [@"jskitfile:" stringByAppendingString:filePath];
                [floorDict setObject:filePath forKey:@"imageSmall"];
                [floorDict setObject:filePath forKey:@"imageBig"];
            } else {
                [floorDict setObject:@"" forKey:@"imageSmall"];
                [floorDict setObject:@"" forKey:@"imageBig"];
            }
            [floorDict setObject:newsCommentItem.audioDuration ? newsCommentItem.audioDuration : @"" forKey:@"audLen"];
            [floorDict setObject:newsCommentItem.audioPath ? newsCommentItem.audioPath : @"" forKey:@"audUrl"];
            [floorDict setObject:newsCommentItem.authorImage ? newsCommentItem.authorImage : @"" forKey:@"authorimg"];
            [floorDict setObject:newsCommentItem.digNum ? newsCommentItem.digNum : @"" forKey:@"digNum"];
            [floorDict setObject:newsCommentItem.ctime forKey:@"ctime"];
            if (userCommentId && userCommentId.length > 0) {
                [floorDict setObject:userCommentId forKey:@"userCommentId"];
            } else {
                [floorDict setObject:@"0" forKey:@"userCommentId"];
            }
            [floorDict setObject:@"0" forKey:@"commentId"];
            [floorDict setObject:@"" forKey:@"replyNum"];
            [floorDict setObject:@"" forKey:@"city"];
            [floorDict setObject:@"" forKey:@"floors"];
            NSString *jsonStr = [floorDict translateDictionaryToJsonString];
            [dict setObject:jsonStr forKey:@"mFloorData"];
        }
        return (NSDictionary *)dict;
    }
    return nil;
}

- (void)keyboardDidHide
{
    _isKeyShow = NO;
}

- (void)postFollowEditor
{
    if (_isKeyShow) { //键盘完全收起才能再次点击评论
        return;
    }
    _replyComment = nil;
    [self presentCommentEidtorController:NO];
}

- (void)textFieldDidBeginAction {

    [self presentCommentEidtorController:NO];
}

- (void)replayCommentLoginSuccess
{
    [self presentCommentEidtorController:NO];
}

- (void)guideLoginSuccess
{
    [self presentCommentEidtorController:NO];
}

- (void)presentCommentEidtorController:(BOOL)isEmoticon
{
    if ([[TTNavigator navigator].topViewController isKindOfClass:[SNCommentEditorViewController class]]) {
        return;
    }
    NSString *controlStaus = self.article.comtStatus;
    NSString *controlHint  =  self.article.comtHint;
    if (!_commentCacheManager) {
        self.commentCacheManager = [[SNCommentCacheManager alloc] init];
    }
    
    if (![SNUtility needCommentControlTip:controlStaus
                            currentStatus:kCommentStsForbidAll
                                      tip:controlHint
                                 isBottom:YES]) {
        
        //只有发布的文章可以操作
        if ([self canShareAndComment]) {
            
            NSNumber *toolbarType = [NSNumber numberWithInteger:SNCommentToolBarTypeTextAndRecAndEmoticonAndCam];
            NSNumber *viewType = [NSNumber numberWithInteger:SNComment];
            
            NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
            [dic setObject:toolbarType forKey:kCommentToolBarType];
            [dic setObject:viewType forKey:kEditorKeyViewType];
            if (controlStaus.length > 0) {
                [dic setObject:controlStaus forKey:kEditorKeyComtStatus];
            }
            if (controlHint.length > 0) {
                [dic setObject:controlHint forKey:kEditorKeyComtHint];
            }
            //缓存评论
            if (self.commentCacheManager.cmtObj) {
                [dic setObject:self.commentCacheManager.cmtObj forKey:kEditorKeyCacheComment];
            }
            
            //发评论数据结构
            SNSendCommentObject *cmtObj = [SNSendCommentObject new];
            // 评论来源
            if ([_referFrom length] > 0) {
                if ([kReferFromRollingNews isEqualToString:_referFrom]) {
                    //来自及时新闻
                    cmtObj.refer = REFER_ROLLINGNEWS;
                } else if ([kReferFromPublication isEqualToString:_referFrom]) {
                    //来自刊物新闻
                    cmtObj.refer = REFER_PAPER;
                }
            }

            if ([kDftGroupGalleryTermId isEqualToString:_termId]) {
                cmtObj.gid = self.newsId;
                cmtObj.busiCode = commentBusicodePhoto;
            } else if ([kDftChannelGalleryTermId isEqualToString:_termId]) {
                cmtObj.newsId = self.newsId;
                cmtObj.busiCode = commentBusicodeNews;
            } else {
                cmtObj.newsId = self.newsId;
                cmtObj.busiCode = commentBusicodeNews;
            }

            if (_replyComment.author.length > 0) {
                cmtObj.replyName = _replyComment.author;
            }
            if (self.newsId.length > 0) {
                cmtObj.newsId = self.newsId;
            }
            if (self.channelId.length > 0) {
                cmtObj.channelId = self.channelId;
            }
            //回复评论数据结构
            int replyTarget = 1;
            cmtObj.replyComment = [SNNewsComment createReplyComment:_replyComment replyType:replyTarget];
            
            //缓存评论
            [self.commentCacheManager setCacheValue:cmtObj];
            
            if (cmtObj) {
                [dic setObject:cmtObj forKey:kEditorKeySendCmtObj];
            }
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"0" forKey:@"contentId"];
            if (_newsType) {
                [dict setObject:_newsType forKey:@"sourceType"];
            }
            [dict setObject:@"" forKey:@"abstract"];
            [dict setObject:@"" forKey:@"picUrl"];
            [dict setObject:@"" forKey:@"link"];
            
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineH5UGCOriginalObjFromDic:dict];
            
            if (obj) {
                obj.contentId = self.newsId;
            }
            [dic setObject:@(isEmoticon) forKey:@"isEmoticon"];
            if (tempCommentTextFieldStr && tempCommentTextFieldStr.length>0) {
                [dic setObject:tempCommentTextFieldStr forKey:@"textfield.text"];
                tempCommentTextFieldStr = nil;
            }
            SNCommentEditorViewController *commentEditorViewController = [[SNCommentEditorViewController alloc] initWithParams:dic];
            commentEditorViewController.sendDelegateController = self;
            self.commenteditor_vc = commentEditorViewController;
            
            [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:commentEditorViewController animated:NO];
            
            _isKeyShow = !isEmoticon;
            [self stopVideo];
            [[SNSoundManager sharedInstance] stopAll];
            [_webView callJavaScript:@"cmtToolHide()" forKey:nil callBack:nil];
            
            dic = nil;
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kArticleUnPublicNotShare toUrl:nil mode:SNCenterToastModeWarning];
            
        }
    }
}

- (void)commentLogin:(id)sender{
    NSString *str = @"一键登录，留下你的态度";
    NSString *n   = @"100031";
    NSString *en  = @"1";
    NSDictionary* halfDic = @{@"halfScreenTitle":str, @"loginFrom":n, @"pprefer":@"comment",@"entrance":en};
    if (_replyComment.content.length > 0) {
        str = @"一键登录即可畅所欲言";
        n = @"100033";
        en = @"2";
        halfDic = @{@"halfScreenTitle" : str, @"loginFrom" : n,@"entrance":en};
    }
    
    [SNNewsLoginManager halfLoginData:halfDic Successed:^(NSDictionary *info) {
        SNDebugLog(@"test login success");
        [self presentCommentEidtor];
        [self autoPostComment:sender];
    } Failed:^(NSDictionary *errorDic) {
        if (sender && [sender isKindOfClass:[SNSendCommentObject class]]) {
            SNSendCommentObject* obj = (SNSendCommentObject*)sender;
            tempCommentTextFieldStr = obj.cmtText;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentCommentEidtorController:NO];
        });
    }];
}

//不弹起，仅用于评论登录回来自动发送
- (void)presentCommentEidtor{
    if ([[TTNavigator navigator].topViewController isKindOfClass:[SNCommentEditorViewController class]]) {
        return;
    }
    NSString *controlStaus = self.article.comtStatus;
    NSString *controlHint  =  self.article.comtHint;
    if (!_commentCacheManager) {
        self.commentCacheManager = [[SNCommentCacheManager alloc] init];
    }
    
    if (![SNUtility needCommentControlTip:controlStaus
                            currentStatus:kCommentStsForbidAll
                                      tip:controlHint
                                 isBottom:YES]) {
        
        //只有发布的文章可以操作
        if ([self canShareAndComment]) {
            NSNumber *toolbarType = [NSNumber numberWithInteger:SNCommentToolBarTypeTextAndRecAndEmoticonAndCam];
            NSNumber *viewType = [NSNumber numberWithInteger:SNComment];
            
            NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
            [dic setObject:toolbarType forKey:kCommentToolBarType];
            [dic setObject:viewType forKey:kEditorKeyViewType];
            if (controlStaus.length > 0) {
                [dic setObject:controlStaus forKey:kEditorKeyComtStatus];
            }
            if (controlHint.length > 0) {
                [dic setObject:controlHint forKey:kEditorKeyComtHint];
            }
            //缓存评论
            if (self.commentCacheManager.cmtObj) {
                [dic setObject:self.commentCacheManager.cmtObj forKey:kEditorKeyCacheComment];
            }
            
            //发评论数据结构
            SNSendCommentObject *cmtObj = [SNSendCommentObject new];
            // 评论来源
            if ([_referFrom length] > 0) {
                if ([kReferFromRollingNews isEqualToString:_referFrom]) {
                    //来自及时新闻
                    cmtObj.refer = REFER_ROLLINGNEWS;
                } else if ([kReferFromPublication isEqualToString:_referFrom]) {
                    //来自刊物新闻
                    cmtObj.refer = REFER_PAPER;
                }
            }
            
            if ([kDftGroupGalleryTermId isEqualToString:_termId]) {
                cmtObj.gid = self.newsId;
                cmtObj.busiCode = commentBusicodePhoto;
            } else if ([kDftChannelGalleryTermId isEqualToString:_termId]) {
                cmtObj.newsId = self.newsId;
                cmtObj.busiCode = commentBusicodeNews;
            } else {
                cmtObj.newsId = self.newsId;
                cmtObj.busiCode = commentBusicodeNews;
            }
            
            if (_replyComment.author.length > 0) {
                cmtObj.replyName = _replyComment.author;
            }
            if (self.newsId.length > 0) {
                cmtObj.newsId = self.newsId;
            }
            //回复评论数据结构
            int replyTarget = 1;
            cmtObj.replyComment = [SNNewsComment createReplyComment:_replyComment replyType:replyTarget];
            
            //缓存评论
            [self.commentCacheManager setCacheValue:cmtObj];
            
            if (cmtObj) {
                [dic setObject:cmtObj forKey:kEditorKeySendCmtObj];
            }
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"0" forKey:@"contentId"];
            if (_newsType) {
                [dict setObject:_newsType forKey:@"sourceType"];
            }
            [dict setObject:@"" forKey:@"abstract"];
            [dict setObject:@"" forKey:@"picUrl"];
            [dict setObject:@"" forKey:@"link"];
            
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineH5UGCOriginalObjFromDic:dict];
            
            if (obj) {
                obj.contentId = self.newsId;
            }
            [dic setObject:@"1" forKey:@"noshow"];
            SNCommentEditorViewController *commentEditorViewController = [[SNCommentEditorViewController alloc] initWithParams:dic];
            commentEditorViewController.sendDelegateController = self;
            self.commenteditor_vc = commentEditorViewController;
            
            [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:commentEditorViewController animated:NO];
            
            _isKeyShow = YES;
            [self stopVideo];
            [[SNSoundManager sharedInstance] stopAll];
            [_webView callJavaScript:@"cmtToolHide()" forKey:nil callBack:nil];
            dic = nil;
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kArticleUnPublicNotShare toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
}

- (void)autoPostComment:(id)sender {
    //contentsWillPost
    SNDebugLog(@"test autoPostComment");
    [self.commenteditor_vc autoPostComment:sender];
    [self keyboardDidHide];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.commenteditor_vc popViewController];
    });
}

#pragma mark - commentListAction
//回复
- (void)replyComment:(NSDictionary *)comment {
    _replyComment = nil;
    _replyComment = [self jsonStringToComment:comment topicId:nil];
    [self stopVideo];
    
    [self presentCommentEidtorController:NO];
}

- (SNNewsComment *)jsonStringToComment:(NSDictionary *)commentDic topicId:(NSString *)topicId {
    SNNewsComment *comment = [[SNNewsComment alloc] init];
    
    comment.commentId = [commentDic stringValueForKey:kCommentId defaultValue:nil];
    comment.author    = [commentDic objectForKey:kAuthor];
    comment.city      = [commentDic objectForKey:kCity];
    comment.content   = [commentDic stringValueForKey:kContent defaultValue:@""];
    comment.replyNum  = [commentDic objectForKey:kReplyNum];
    comment.digNum    = [commentDic objectForKey:kDigNum];
    comment.from      = [[commentDic objectForKey:kFrom] stringValue];
    comment.ctime     = [commentDic stringValueForKey:kCtime defaultValue:nil];
    comment.passport  = [commentDic objectForKey:kPassport];
    comment.linkStyle = [commentDic objectForKey:kLinkStyle];
    comment.spaceLink = [commentDic objectForKey:kSpaceLink];
    comment.pid       = [commentDic stringValueForKey:kPid defaultValue:nil];
    comment.authorimg = [commentDic objectForKey:kAuthorimg];
    comment.newsTitle = [commentDic objectForKey:kCommentNewsTitle];
    comment.newsLink  = [commentDic objectForKey:kCommentNewsLink];
    comment.commentImage = [commentDic objectForKey:kCommentImage];
    comment.commentImageSmall = [commentDic objectForKey:kCommentImageSmall];
    comment.commentImageBig = [commentDic objectForKey:kCommentImageBig];
    comment.commentAudLen = [commentDic intValueForKey:kCommentAudLen defaultValue:0];
    comment.commentAudUrl = [commentDic objectForKey:kCommentAudUrl];
    comment.userComtId = [commentDic stringValueForKey:kCommentUserComtId defaultValue:@""];
    comment.cmtStatus    = [commentDic stringValueForKey:kCmtStatus defaultValue:nil];
    comment.cmtHint      = [commentDic stringValueForKey:kCmtHint defaultValue:nil];
    comment.busiCode     = [commentDic stringValueForKey:kCmtBusiCode defaultValue:nil];
    //回复我的中通过二代类型协议判断busiCode
    if (comment.newsLink.length > 0) {
        NSDictionary *linkDic = [SNUtility parseLinkParams:comment.newsLink];
        if (NSNotFound != [comment.newsLink rangeOfString:kProtocolLive options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kLiveIdKey defaultValue:nil];
        }
        else if (NSNotFound != [comment.newsLink rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kSNNewsId defaultValue:nil];
            comment.busiCode = @"2";
        }
        else if (NSNotFound != [comment.newsLink rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kGid defaultValue:nil];
            comment.busiCode = @"3";
        }
    }
    comment.attachList = commentDic[kCmtAttachList];
    if (topicId) {
        comment.topicId = topicId;
    } else  {
        comment.topicId   = [commentDic stringValueForKey:kTopicId defaultValue:@""];
    }
    
    id floorsData = [commentDic objectForKey:kFloors];
    if ([floorsData isKindOfClass:[NSArray class]]) {
        comment.floors = [NSMutableArray array];
        for (NSDictionary *floorDic in floorsData) {
            if ([floorDic isKindOfClass:[NSDictionary class]]) {
                SNNewsComment *floorComment = [[SNNewsComment alloc] init];
                floorComment.commentId = [floorDic stringValueForKey:kCommentId defaultValue:nil];
                floorComment.author    = [floorDic objectForKey:kAuthor];
                floorComment.passport  = [floorDic objectForKey:kPassport];
                floorComment.spaceLink = [floorDic objectForKey:kSpaceLink];
                floorComment.pid       = [floorDic stringValueForKey:kPid defaultValue:nil];
                floorComment.linkStyle = [floorDic objectForKey:kLinkStyle];
                floorComment.city      = [floorDic objectForKey:kCity];
                floorComment.content   = [floorDic stringValueForKey:kContent defaultValue:@""];
                floorComment.replyNum  = [floorDic objectForKey:kReplyNum];
                NSNumber *dNum         = [floorDic objectForKey:kDigNum];
                floorComment.digNum    = [dNum stringValue];
                floorComment.from      = [floorDic objectForKey:kFrom];
                floorComment.ctime     = [commentDic stringValueForKey:kCtime defaultValue:nil];
                floorComment.commentImage = [floorDic objectForKey:kCommentImage];
                floorComment.commentImageBig= [floorDic objectForKey:kCommentImageBig];
                floorComment.commentImageSmall = [floorDic objectForKey:kCommentImageSmall];
                floorComment.commentAudLen = [floorDic intValueForKey:kCommentAudLen defaultValue:0];
                floorComment.commentAudUrl = [floorDic objectForKey:kCommentAudUrl];
                floorComment.userComtId = [floorDic objectForKey:kCommentUserComtId];
                if (topicId) {
                    floorComment.topicId = topicId;
                } else {
                    floorComment.topicId = [floorDic stringValueForKey:kTopicId defaultValue:@""];
                }
                [comment.floors addObject:floorComment];
            }
        }
    }
    return comment;
}

- (void)emptyCommentListClicked {
    [self stopVideo];
    [self postFollowEditor];
}

- (void)copyComment:(NSString *)content {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [content trim];
}

- (void)shareContent:(NSString *)content
{
    if (content) {
        SNNewsComment *comment = [[SNNewsComment alloc] init];
        comment.content = content;
        [self shareComment:comment];
    }
}

- (void)actionmenuDidSelectItemTypeCallback:(SNActionMenuOption)type {
    if (self.videoPlayers.count > 0) {
        SNH5NewsVideoPlayer *_videoPlayer = self.videoPlayers[0];
        if ([_videoPlayer isPaused]) {
            return;
        }
    }
    
    if (type == SNActionMenuOptionMySOHU) {
        [self stopVideo];
    }
}

- (void)enterUserCenter:(id)jsonData
{
    [SNUtility shouldUseSpreadAnimation:NO];
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if (now - _lastShareTime < 1) {
        return;
    }
    _lastShareTime = now;
    
    NSDictionary *dict = (NSDictionary *)jsonData;
    
    NSMutableDictionary *referInfo = [NSMutableDictionary dictionary];
    if (self.newsId.length > 0) {
        [referInfo setObject:self.newsId forKey:kReferValue];
        [referInfo setObject:@"Newsid" forKey:kReferType];
    }
    if (self.gid.length > 1) {
        [referInfo setObject:self.gid forKey:kReferValue];
        [referInfo setObject:@"gid" forKey:kReferType];
    }
    // 添加channelId参数 2017.5.9 by liteng
    NSString *channalId = [dict stringValueForKey:kChannelId defaultValue:nil];
    if (channalId) {
        [referInfo setObject:channalId forKey:kChannelId];
    }
    [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Article_CommentUser] forKey:kRefer];
    NSString *passport;
    if ([[dict objectForKey:kCommentId] integerValue] == 0) {
        passport = [SNUserManager getUserId];
    } else {
        passport =[dict objectForKey:kPassport];
    }
    
    [SNUserUtility openUserWithPassport:passport
                                               spaceLink:@""
                                               linkStyle:@"" pid:[dict objectForKey:@"pid"]
                                                    push:@"0" refer:referInfo];
}

#pragma mark - openCommentImage
- (void)showImageWithUrl:(NSString *)urlPath {
    if (_imageDetailView == nil) {
        CGRect applicationFrame = [[UIScreen mainScreen] bounds];
        applicationFrame.size.height = kAppScreenHeight;
        _imageDetailView = [[SNGalleryPhotoView alloc] initWithFrame:applicationFrame];
    }
    [_imageDetailView loadImageWithUrlPath:urlPath];
    
    [[TTNavigator navigator].topViewController.flipboardNavigationController.view addSubview:_imageDetailView];
    
    _imageDetailView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _imageDetailView.alpha = 1.0;
    }];
}

#pragma mark UIWebViewDelegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //force portrait by changing the view stack to force rechect of autorotate!
    if ([UIDevice currentDevice].orientation != UIInterfaceOrientationPortrait) {
        if (![viewController isKindOfClass: [SHH5NewsWebViewController class]]) {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIView *view = [window.subviews objectAtIndex:0];
            [view removeFromSuperview];
            [window insertSubview:view atIndex:0];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([_h5Type isEqualToString:@"1"]) {
        NSString* url = request.URL.absoluteString;
        if ([url isEqualToString:_h5WebLink] || navigationType == UIWebViewNavigationTypeLinkClicked) {
            self.tempH5WebLink = url;
        }
        
        if ([url containsString:@"itunes.apple.com"] && allowJumpAppStore == NO) {//如果是跳转appstore
            return NO;
        }
        
        if ([SNUtility isWhiteListURL:[NSURL URLWithString:url]]) {
            //如果白名单里有也不能跳 产品需求 2017.6.20 wangshun
            return NO;
        }

        return YES;
    }
    
    [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification object:nil userInfo:nil];
    NSString* url = request.URL.absoluteString;
    if([url isEqualToString:self.link]) {
        return YES;
    } else {
        url = [url URLDecodedString];
        if (NSNotFound != [url rangeOfString:kProtocolLandscape options:NSCaseInsensitiveSearch].location) {
            NSString *link = [[url componentsSeparatedByString:[NSString stringWithFormat:@"%@url=",kProtocolLandscape]]lastObject];
            if (NSNotFound != [link rangeOfString:@"https" options:NSCaseInsensitiveSearch].location && ![link hasPrefix:@":"]) {
                NSMutableString *urlMutable = [NSMutableString stringWithString:url];
                [urlMutable insertString:@":" atIndex:21];
                url = [NSString stringWithString:urlMutable];
            } else if (NSNotFound != [link rangeOfString:@"http" options:NSCaseInsensitiveSearch].location && ![link hasPrefix:@":"]) {
                NSMutableString *urlMutable = [NSMutableString stringWithString:url];
                [urlMutable insertString:@":" atIndex:20];
                url = [NSString stringWithString:urlMutable];
            }
            return ![SNUtility openProtocolUrl:url context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:AdvertisementWebViewType], kUniversalWebViewType, nil]];
        }
        if ([url hasPrefix:@"js:"]) {
            url = [url substringFromIndex:3];
        }
        if ([url hasPrefix:kProtocolNews]) {
            NSDictionary *dict = [SNUtility parseURLParam:url schema:kProtocolNews];
            CGFloat linkTop = [[dict stringValueForKey:kH5LinkTop defaultValue:@""] floatValue];
            [SNUserDefaults setDouble:linkTop forKey:kRememberCellOriginYInScreen];
            [SNUtility shouldUseSpreadAnimation:YES];
        } else {
            [SNUtility shouldUseSpreadAnimation:NO];
            if ([url hasPrefix:kSohuNewsPrivatemessage]) { // 评论私信跳转 2017.5.8 by liteng
                BOOL result = [SNUtility openProtocolUrl:request.URL.absoluteString context:nil];
                return !result;
            }
        }
        
        BOOL isFromH5 = [url containsString:kH5NoTriggerIOSClick] && [SNUtility isProtocolV2:url];
        if(navigationType == UIWebViewNavigationTypeLinkClicked || isFromH5) {
            if (NSNotFound != [url rangeOfString:kProtocolSearch options:NSCaseInsensitiveSearch].location) {
                url = [url stringByAppendingFormat:@"&refertype=%d", SNSearchReferArticle];
            }
            if ((NSNotFound !=[url rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location) || (NSNotFound !=[url rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location) || (NSNotFound != [url rangeOfString:kProtocolVote options:NSCaseInsensitiveSearch].location)) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:kNewsRecomNews forKey:kNewsFrom];
                [self stopVideo];
                return ![SNUtility openProtocolUrl:url context:dic];
            }
            
            if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
                return NO;
            }
            [self stopVideo];
            //区分是否使用JSkit打开
            NSDictionary *dict = nil;
            if ([request.URL.absoluteString containsString:@"stockprofile=1"]) {
                dict = @{kUniversalWebViewType:[NSNumber numberWithInteger:StockMarketWebViewType]};
            }
            
            return ![SNUtility openProtocolUrl:request.URL.absoluteString context:dict];
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self jsKitStorageGetItem];
    
    [self setCommentNumEnble];
    
    [_officialAccountsInfo checkFollowedStatus];
    
    [SNUtility banUniversalLinkOpenInSafari];
    
    if (isStartFresh == YES) {
        [self stopProgress:0];
        isStartFresh = NO;
    }
}

//从JsKitStorage获取正文数据
- (void)jsKitStorageGetItem
{
    NSString *methodStr = nil;
    if (self.newsId.length > 1) {
        methodStr = [NSString stringWithFormat:@"article%@", self.newsId];
    }
    if (self.gid.length > 1) {
        methodStr = [NSString stringWithFormat:@"gallery%@", self.gid];
    }
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    id jsonData = [jsKitStorage getItem:methodStr];
    if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
        if (_newsType.intValue == 3 && !self.article) {
            [self getArticle:(NSDictionary *)jsonData];
        } else if (_newsType.intValue == 4 && !_photoList) {
            [self getGalleryItem:(NSDictionary *)jsonData];
        }
    }
}

- (void)getArticle:(id)jsonData
{
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        _article = [[SNArticle alloc] init];
        if (self.channelId) {
            self.article.channelId= self.channelId;
        }
        if (self.termId) {
            self.article.termId   = self.termId;
        }
        self.article.newsId       = self.newsId;
        self.article.optimizeRead = [jsonData objectForKey:kOptimizeRead];
        self.article.time         = [jsonData objectForKey:kTime];
        self.article.title        = [jsonData objectForKey:kTitle];
        self.article.originFrom   = [jsonData objectForKey:kOriginFrom];
        self.article.originTitle  = [jsonData objectForKey:kOriginTitle];
        self.article.h5link       = [jsonData objectForKey:kH5link];
        self.article.favIcon      = [jsonData objectForKey:kFavIcon];
        self.article.newsMark     = [jsonData objectForKey:kNewsMark];
        self.article.content      = [jsonData objectForKey:kContent];
        self.article.updateTime   = [jsonData stringValueForKey:kUpdateTime defaultValue:@""];
        self.article.newsType     = [jsonData objectForKey:kNewsType];
        self.article.nextId       = [jsonData stringValueForKey:kNextGid defaultValue:@""];
        
        NSDictionary *subInfo = [jsonData objectForKey:@"subInfo"];
        if (subInfo && [subInfo isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *subInfoDic = [NSMutableDictionary dictionaryWithDictionary:subInfo];
            self.article.subId = [NSString stringWithFormat:@"%@", [subInfoDic objectForKey:@"subId"]];
            self.subId = self.article.subId;
            [subInfoDic setValue:self.article.subId forKey:@"subId"];
            [subInfoDic setValue:[NSString stringWithFormat:@"%@", [subInfoDic objectForKey:@"needLogin"]] forKey:@"needLogin"];
            SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromJsonDic:subInfoDic];
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        }
        
        NSArray *tvAdInfos = [jsonData objectForKey:@"tvAdInfos"];
        if (tvAdInfos && [tvAdInfos isKindOfClass:[NSArray class]]) {
            self.article.tvAdInfos = tvAdInfos;
        }
        
        NSArray *tvInfos = [jsonData objectForKey:@"tvInfos"];
        if (tvInfos && [tvInfos isKindOfClass:[NSArray class]]) {
            self.article.tvInfos = tvInfos;
        }
        
        NSDictionary *comtRel = [jsonData objectForKey:@"comtRel"];
        if (comtRel) {
            self.article.comtRemarkTips = [comtRel stringValueForKey:kCmtRemarkTips defaultValue:@""];
            self.article.comtHint       = [comtRel stringValueForKey:kCmtHint defaultValue:@""];
            self.article.comtStatus     = [comtRel stringValueForKey:kCmtStatus defaultValue:@""];
            [SNUtility setCmtRemarkTips:_article.comtRemarkTips];
        }
        
        NSDictionary* mediaDic  = [jsonData objectForKey:kMedia];
        if(mediaDic && [mediaDic isKindOfClass:[NSDictionary class]])
        {
            self.article.mediaName = [mediaDic stringValueForKey:kMediaName defaultValue:@""];
            self.article.mediaLink = [mediaDic stringValueForKey:kMediaLink defaultValue:@""];
        }

        NSMutableArray *photos = [[NSMutableArray alloc] init];
        NSArray *photoArray = [jsonData objectForKey:kPhotos];
        //数组
        if (photoArray) {
            for (NSDictionary *pDic in photoArray) {
                NewsImageItem *imageItem = [[NewsImageItem alloc] init];
                imageItem.termId        = self.termId;
                imageItem.newsId        = self.newsId;
                imageItem.type          = NEWSSHAREIMAGE_TYPE;
                imageItem.url           = [pDic objectForKey:kPic];
                if (imageItem.url) {
                    imageItem.url = [imageItem.url trim];
                }
                imageItem.title   = [pDic objectForKey:@"description"];
                imageItem.width = [pDic[@"width"] floatValue];
                imageItem.height = [pDic[@"height"] floatValue];
                if (imageItem) {
                    [photos addObject:imageItem];
                }
            }
            self.article.newsImageItems = photos;
        }
    }
}

- (void)getGalleryItem:(id)resData
{
    if ([resData isKindOfClass:[NSDictionary class]]) {
        _photoList = [[GalleryItem alloc] init];
        self.photoList.newsId = self.newsId;
        self.photoList.type         = [resData objectForKey:kType];
        self.photoList.title        = [resData objectForKey:kTitle];
        self.photoList.commentNum   = [resData objectForKey:kCommentNum];
        self.photoList.shareContent = [resData objectForKey:kShareContent];
        self.photoList.newsMark     = [resData objectForKey:kNewsMark];
        self.photoList.originFrom   = [resData objectForKey:kOriginFrom];
        self.photoList.time         = [resData objectForKey:kTime];
        self.photoList.nextId       = [resData objectForKey:@"nextGid"];
        self.photoList.nextName     = [resData objectForKey:kNextName];
        self.photoList.preId        = [resData objectForKey:kPreId];
        self.photoList.isLike       = [resData objectForKey:kIsLike];
        self.photoList.likeCount    = [resData objectForKey:kLikeCount];
        self.photoList.termId       = [resData objectForKey:kTermId];
        NSDictionary* mediaDic  = [resData objectForKey:kMedia];
        if(mediaDic)
        {
            self.photoList.mediaName = [mediaDic objectForKey:kMediaName];
            self.photoList.mediaLink = [mediaDic objectForKey:kMediaLink];
        }
        NSMutableDictionary *subInfoDic = [NSMutableDictionary dictionaryWithDictionary:[resData objectForKey:@"subInfo"]];
        if (subInfoDic && [subInfoDic isKindOfClass:[NSDictionary class]]) {
            self.photoList.subId = [NSString stringWithFormat:@"%@", [subInfoDic objectForKey:@"subId"]];
            self.subId = self.photoList.subId;
            [subInfoDic setValue:self.photoList.subId forKey:@"subId"];
            [subInfoDic setValue:[NSString stringWithFormat:@"%@", [subInfoDic objectForKey:@"needLogin"]] forKey:@"needLogin"];
            SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromJsonDic:subInfoDic];
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        }
        
        NSMutableArray * photos = [[NSMutableArray alloc] init];
        id gallery = [resData objectForKey:kGallery];
        //数组
        if ([gallery isKindOfClass:[NSArray class]]) {
            for (NSDictionary *pDic in gallery) {
                PhotoItem *photo    = [[PhotoItem alloc] init];
                photo.termId        = _photoList.termId;
                photo.newsId        = _photoList.newsId;
                photo.ptitle        = [pDic objectForKey:kPTitle];
                photo.url           = [pDic objectForKey:kPic];
                if (photo.url) {
                    photo.url = [photo.url trim];
                }
                photo.abstract      = [pDic objectForKey:kAbstract];
                photo.shareLink     = [pDic objectForKey:kShareLink];
                photo.width = [pDic[@"width"] floatValue];
                photo.height = [pDic[@"height"] floatValue];
                if (photo) {
                    [photos addObject:photo];
                }
            }
        }
        //单个
        else if ([gallery isKindOfClass:[NSDictionary class]]) {
            PhotoItem *photo    = [[PhotoItem alloc] init];
            photo.termId        = _photoList.termId;
            photo.newsId        = _photoList.newsId;
            photo.ptitle        = [gallery objectForKey:kPTitle];
            photo.url           = [gallery objectForKey:kPic];
            if (photo.url) {
                photo.url = [photo.url trim];
            }
            photo.abstract      = [gallery objectForKey:kAbstract];
            photo.shareLink     = [gallery objectForKey:kShareLink];
            photo.width = [gallery[@"width"] floatValue];
            photo.height = [gallery[@"height"] floatValue];
            if (photo) {
                [photos addObject:photo];
            }
        }
        
        self.photoList.gallerySubItems  = photos;
        
        //更多推荐
        //推荐组图不再具备 termId和newsId属性，只有一个gid属性。访问推荐组图时，也只用带上gid一个参数,不用带上termId和newsId。为简化此情况的处理，同新闻组图共存与一个数据库表中，推荐组图仍保留termId和newsId，但termId 始终为0,newsId对应gid。在请求下载推荐组图时，如果发现组图termId为0，只带参数gid,否则，带上termId和newsId。
        NSMutableArray *moreRecommend = [[NSMutableArray alloc] init];
        id more = [resData objectForKey:kMore];
        if ([more isKindOfClass:[NSArray class]]) {
            for (NSDictionary *pDic in more) {
                RecommendGallery *recommend = [[RecommendGallery alloc] init];
                recommend.releatedTermId    = _photoList.termId;
                recommend.releatedNewsId    = _photoList.newsId;
                recommend.termId            = kDftSingleGalleryTermId;
                recommend.newsId            = [pDic objectForKey:kGroupPicId];
                recommend.title             = [pDic objectForKey:kGroupPicTitle];
                recommend.iconUrl           = [pDic objectForKey:kGroupPicIconUrl];
                if (recommend.iconUrl) {
                    recommend.iconUrl = [recommend.iconUrl trim];
                }
                
                [moreRecommend addObject:recommend];
            }
        }
        else if([more isKindOfClass:[NSDictionary class]]){
            RecommendGallery *recommend = [[RecommendGallery alloc] init];
            recommend.releatedTermId    = _photoList.termId;
            recommend.releatedNewsId    = _photoList.newsId;
            recommend.termId            = kDftSingleGalleryTermId;
            recommend.newsId            = [more objectForKey:kGroupPicId];
            recommend.title             = [more objectForKey:kGroupPicTitle];
            recommend.iconUrl           = [more objectForKey:kGroupPicIconUrl];
            if (recommend.iconUrl) {
                recommend.iconUrl = [recommend.iconUrl trim];
            }
            [moreRecommend addObject:recommend];
        }
        
        self.photoList.moreRecommends = moreRecommend;
    }
}

#pragma mark - SNArticleRecomServiceDelegate
- (void)getRecommendNewsSucceed
{
    [self loadAdvertise];
}

#pragma mark 广告
- (void)loadRecommendNews
{
    _recommendService.newsId = self.newsId;
    _recommendService.termId = self.termId;
    _recommendService.subId = self.subId;
    _recommendService.channelId = self.channelId;
    _recommendService.fromPush = self.fromPush;
    if (_newsType.integerValue == 3) {
        _recommendService.adType = SNAdInfoTypeArticle;
    } else if (_newsType.integerValue == 4) {
        _recommendService.adType = SNAdInfoTypePhotoListNews;
    }
    _recommendService.userData = [NSDictionary dictionaryWithObjectsAndKeys:self.link, @"link", nil];
    _recommendService.delegate = self;
    
    if ([_recommendService.adInfoArray count] == 0) {
        [[SHADManager sharedManager].articleAdDic removeAllObjects];
        [[SHADManager sharedManager].itemspaceidArr removeAllObjects];
        [_recommendService loadRecommendNews];
    }
}

- (void)dealSlideAds:(NSDictionary *)adInfo {
    if (adInfo) {
        [self.adInfos removeAllObjects];
        SNAdControllInfo *adControllInfo = [[SNAdControllInfo alloc] initWithJsonDic:adInfo];
        if (adControllInfo) {
            [self.adInfos addObject:adControllInfo];
        }
        
        [self loadAdvertise];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.adInfos count] > 0) {
                // 添加到缓存
                [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:self.adInfos withType:SNAdInfoTypePhotoListNews dataId:_newsId categoryId:_channelId];
            }
        });
    }
}

- (void)loadAdvertise {
    // 4.0加载sdk广告
    if(_newsType.integerValue == 4) {
        [self loadPhotoGroupAdvertise];
    }else if(_newsType.integerValue == 3) {
        [self loadImageTextNewsAdvertise];
    }
}

- (void)loadImageTextNewsAdvertise {
    if ([SNAdvertiseManager sharedManager].isSDKAdEnable) {
        NSString *newsId = self.newsId;
        NSString *categoryId = self.channelId.length > 0 ? self.channelId : self.termId;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *adCtrolInfos = [[SNDBManager currentDataBase] adInfoGetAdInfosByType:SNAdInfoTypeArticle dataId:newsId categoryId:categoryId];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (adCtrolInfos.count > 0) {
                    SNAdControllInfo *adCtrlInfo = adCtrolInfos[0];
                    for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
                        NSString *newsId = nil;
                        if (self.newsId.length > 0) {
                            newsId = self.newsId;
                        } else if (self.gid.length > 1) {
                            newsId = self.gid;
                        }
                        [adInfo.filterInfo setObject:newsId forKey:@"newsid"];
                        [adInfo.filterInfo removeObjectForKey:@"newsId"];
                        if (self.subId.length > 0) {
                            [adInfo.filterInfo setObject:self.subId forKey:@"subid"];
                        }
                        if (self.newsCate.length > 0) {
                            [adInfo.filterInfo setObject:self.newsCate forKey:@"newscate"];
                        }
                        //文章页中插广告
                        if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdNewsArticleInsertad]) {
                            NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                [[SHADManager sharedManager] getAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            } else {
                                [[SHADManager sharedManager] getAdDataFromSDKWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            }
                        }
                        // 图文广告
                        else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdArticleAd]) {
                            NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                [[SHADManager sharedManager] getAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            } else {
                                [[SHADManager sharedManager] getAdDataFromSDKWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            }
                        }
                        // 相关推荐最后一条
                        else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdArticleRecommendTail]) {
                            NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                [[SHADManager sharedManager] getAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            } else {
                                [[SHADManager sharedManager] getAdDataFromSDKWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            }
                        }
                        // 大图模式下 最后一张
                        else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdSlideshowTail] &&!self.sdkAdLastPic) {
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                                self.sdkAdLastPic = [[SNAdDataCarrier alloc] initWithAdSpaceId:adInfo.adSpaceId];
                                self.sdkAdLastPic.delegate = self;
                                [[SHADManager sharedManager] getBigPicAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId carrier:self.sdkAdLastPic];
                            } else {
                                self.sdkAdLastPic = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId adInfoParam:adInfo.filterInfo];
                                self.sdkAdLastPic.delegate = self;
                                self.sdkAdLastPic.appChannel = adInfo.appChannel;
                                self.sdkAdLastPic.newsChannel = adInfo.newsChannel;
                                self.sdkAdLastPic.gbcode = adInfo.gbcode;
                                self.sdkAdLastPic.adId = adInfo.adId;
                                self.sdkAdLastPic.newsID = newsId;
                                self.sdkAdLastPic.subId = self.subId;
                                self.sdkAdLastPic.newsCate = self.newsCate;
                                [self.sdkAdLastPic refreshAdData:NO];
                            }
                        }
                    }
                }
            });
        });
    }
}

- (void)loadPhotoGroupAdvertise {
    if ([[SNAdvertiseManager sharedManager] isSDKAdEnable]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *cId = (self.channelId ? self.channelId :
                             (self.termId ? self.termId : (kAdInfoDefaultCategoryId)));
            
            NSArray *adCtrlInfos = [[SNDBManager currentDataBase] adInfoGetAdInfosByType:SNAdInfoTypePhotoListNews dataId:self.newsId categoryId:cId];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (adCtrlInfos.count > 0) {
                    SNAdControllInfo *adCtrlInfo = adCtrlInfos[0];
                    for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
                        NSString *newsId = nil;
                        if (self.newsId.length > 0) {
                            newsId = self.newsId;
                        } else if (self.gid.length > 1) {
                            newsId = self.gid;
                        }
                        [adInfo.filterInfo setObject:newsId forKey:@"newsid"];
                        [adInfo.filterInfo removeObjectForKey:@"newsId"];
                        if (self.subId.length > 0) {
                            [adInfo.filterInfo setObject:self.subId forKey:@"subid"];
                        }
                        if (self.newsCate.length > 0) {
                            [adInfo.filterInfo setObject:self.newsCate forKey:@"newscate"];
                        }
                        //文章下图文广告
                        if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdArticleAd]) {
                            NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                [[SHADManager sharedManager] getAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            } else {
                                [[SHADManager sharedManager] getAdDataFromSDKWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            }
                        }
                        //文章页下相关推荐最后一条
                        else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdArticleRecommendTail]) {
                            NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                [[SHADManager sharedManager] getAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            } else {
                                [[SHADManager sharedManager] getAdDataFromSDKWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId];
                            }
                        }
                        //大图最后一针
                        else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdSlideshowTail] &&!self.sdkAdLastPic
                            ) {
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                                self.sdkAdLastPic = [[SNAdDataCarrier alloc] initWithAdSpaceId:adInfo.adSpaceId];
                                self.sdkAdLastPic.delegate = self;
                                [[SHADManager sharedManager] getBigPicAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId carrier:self.sdkAdLastPic];
                            } else {
                                self.sdkAdLastPic = [[SNAdvertiseManager sharedManager]
                                                     generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                     adInfoParam:adInfo.filterInfo];
                                self.sdkAdLastPic.delegate = self;
                                self.sdkAdLastPic.appChannel = adInfo.appChannel;
                                self.sdkAdLastPic.newsChannel = adInfo.newsChannel;
                                self.sdkAdLastPic.gbcode = adInfo.gbcode;
                                self.sdkAdLastPic.adId = adInfo.adId;
                                self.sdkAdLastPic.newsID = newsId;
                                self.sdkAdLastPic.subId = self.subId;
                                self.sdkAdLastPic.newsCate = self.newsCate;
                                [self.sdkAdLastPic refreshAdData:NO];
                            }
                        }
                        //组图推荐倒数第二条
                        else if (([adInfo.adSpaceId isEqualToString:SpaceId13371] || [adInfo.adSpaceId isEqualToString:SpaceId12716]) &&!self.sdkAd13371
                            ){
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                                self.sdkAd13371 = [[SNAdDataCarrier alloc] initWithAdSpaceId:adInfo.adSpaceId];
                                self.sdkAd13371.delegate = self;
                                [[SHADManager sharedManager] getBigPicAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId carrier:self.sdkAd13371];
                            } else {
                                self.sdkAd13371 = [[SNAdvertiseManager sharedManager]
                                                   generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                   adInfoParam:adInfo.filterInfo];
                                self.sdkAd13371.delegate = self;
                                self.sdkAd13371.appChannel = adInfo.appChannel;
                                self.sdkAd13371.newsChannel = adInfo.newsChannel;
                                self.sdkAd13371.gbcode = adInfo.gbcode;
                                self.sdkAd13371.adId = adInfo.adId;
                                self.sdkAd13371.newsID = newsId;
                                self.sdkAd13371.subId = self.subId;
                                self.sdkAd13371.newsCate = self.newsCate;
                                [self.sdkAd13371 refreshAdData:NO];
                            }
                        }
                        //组图推荐最后一条
                        else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendTail] &&!self.sdkAdLastRecommend
                            ) {
                            if ([[adInfo.filterInfo stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
                                NSDictionary *adInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:adInfo.adSpaceId, @"itemspaceid", adInfo.adId, @"adId", self.newsId, @"newsid", adInfo.filterInfo, @"filterInfo", nil];
                                self.sdkAdLastRecommend = [[SNAdDataCarrier alloc] initWithAdSpaceId:adInfo.adSpaceId];
                                self.sdkAdLastRecommend.delegate = self;
                                [[SHADManager sharedManager] getBigPicAdDataFromSCADWithInfo:adInfoDic itemspaceid:adInfo.adSpaceId carrier:self.sdkAdLastRecommend];
                            } else {
                                self.sdkAdLastRecommend = [[SNAdvertiseManager sharedManager]
                                                           generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                           adInfoParam:adInfo.filterInfo];
                                self.sdkAdLastRecommend.delegate = self;
                                self.sdkAdLastRecommend.appChannel = adInfo.appChannel;
                                self.sdkAdLastRecommend.newsChannel = adInfo.newsChannel;
                                self.sdkAdLastRecommend.gbcode = adInfo.gbcode;
                                self.sdkAdLastRecommend.adId = adInfo.adId;
                                self.sdkAdLastRecommend.newsID = newsId;
                                self.sdkAdLastRecommend.subId = self.subId;
                                self.sdkAdLastRecommend.newsCate = self.newsCate;
                                [self.sdkAdLastRecommend refreshAdData:NO];
                            }
                        }
                    }
                }
            });
        });
    }
}

- (void)adViewDidAppearWithCarrier:(SNAdDataCarrier *)carrier {
    if ([carrier.adSpaceId isEqualToString:kSNAdSpaceIdSlideshowTail]) {
        self.sdkAdLastPic = carrier;
    }
    else if ([carrier.adSpaceId isEqualToString:SpaceId13371] || [carrier.adSpaceId isEqualToString:SpaceId12716]) {
        self.sdkAd13371 = carrier;
    }
    else if ([carrier.adSpaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendTail]) {
        self.sdkAdLastRecommend = carrier;
    }
    
    //大图广告设置
    [self.galleryBrowser setLastBigAd:self.sdkAdLastPic];
    [self.galleryBrowser setLastRecomAd:self.sdkAdLastRecommend lastSecond:self.sdkAd13371];

    if (![[carrier.filter stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
        [carrier reportForLoadTrack];
    }
}

- (void)adViewDidFailToLoadWithCarrier:(SNAdDataCarrier *)carrier{
    [carrier setNewsCate:self.newsCate];
    if (self.sdkAdLastPic == carrier) {
        self.sdkAdLastPic.delegate = nil;
        self.sdkAdLastPic = nil;
    }
    
    if (self.sdkAdLastRecommend == carrier) {
        self.sdkAdLastRecommend.delegate = nil;
        self.sdkAdLastRecommend = nil;
    }
    
    if (self.sdkAd13371 == carrier) {
        self.sdkAd13371.delegate = nil;
        self.sdkAd13371 = nil;
    }
}

#pragma  mark  进入大图

- (void)clickImage:(NSString *)imageUrl title:(NSString *)title rect:(CGRect)rect
{
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
    _clickImageUrl = [imageUrl copy];
    _clickImageTitle = [title copy];
 
    [self showBigImageSlideViewx:rect];
}

- (void)showBigImageSlideViewx:(CGRect)rect {
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if(now - _lastShareTime < 1)
    {
        return;
    }
    _lastShareTime = now;
    
//    ///进大图之前，给 statusBar 截图
//    if (_officialAccountsInfo && !_officialAccountsInfo.needHideStatusBar) {
//        [_officialAccountsInfo cropCurrentStatusBar];
//    }
    
    if (_newsType.intValue == 3) { //图文新闻大图浏览
        if (_article == nil) {
            [self jsKitStorageGetItem];
        }
        NSUInteger index = 0;
        for (NewsImageItem *item in _article.newsImageItems) {
            if (![item.url isEqualToString:_clickImageUrl]) {
                ++index;
            } else {
                break;
            }
        }
        if (index < _article.newsImageItems.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.galleryBrowser) {
                    self.galleryBrowser = [SNGalleryBrowser showGalleryWithArticle:_article currentImageUrl:_clickImageUrl currentIndex:index fromRect:rect fromView:self.view info:nil dismissBlock:^(UIImage *image, NSInteger index) {
                        _pinchGesture.enabled = YES;
                    }];
                    self.galleryBrowser.delegate = self;
                    self.galleryBrowser.newsId = self.newsId;
                    self.galleryBrowser.channelId = self.channelId;
                    [self.galleryBrowser setLastBigAd:self.self.sdkAdLastPic];
                    _pinchGesture.enabled = NO;
                }
            });
        }
        
    } else if (_newsType.intValue == 4) { //组图新闻大图浏览
        if (!_photoList) {
            [self jsKitStorageGetItem];
        }
        NSUInteger index = 0;
        for (PhotoItem *item in _photoList.gallerySubItems) {
            if (![item.url isEqualToString:_clickImageUrl]) {
                ++index;
            } else {
                break;
            }
        }
        if (index < _photoList.gallerySubItems.count) {
            CGRect rectTag = rect;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.galleryBrowser) {
                    self.galleryBrowser = [SNGalleryBrowser showGalleryWithArticle:_photoList currentImageUrl:_clickImageUrl currentIndex:index fromRect:rectTag fromView:self.view info:nil dismissBlock:^(UIImage *image, NSInteger index) {
                        _pinchGesture.enabled = YES;
                    }];
                    self.galleryBrowser.delegate = self;
                    self.galleryBrowser.allNewsId = _rollingNewsList;
                    self.galleryBrowser.newsId = self.newsId;
                    self.galleryBrowser.channelId = self.channelId;
                    
                    [self.galleryBrowser setLastBigAd:self.sdkAdLastPic];
                    [self.galleryBrowser setLastRecomAd:self.sdkAdLastRecommend lastSecond:self.sdkAd13371];
                    _pinchGesture.enabled = NO;
                }
            });
        }
    }
}

- (void)openGroupPhotoSlideShow:(int)beginIndex dateSource:(SNPhotoSlideshow *)ds newsId:(NSString *)aNewsId from:(CGRect)rect {
    self.slideshowController = [[SNPhotoGallerySlideshowController alloc] initWithGallery:ds];
    self.slideshowController.delegate = self;
    self.slideshowController.allItems = self.rollingNewsList;
    self.slideshowController.newsModel = self.newsModel;
    if ([self.termId isEqualToString:kDftChannelGalleryTermId]) {
        self.slideshowController.gallerySourceType = GallerySourceTypeGroupPhoto;
    }
    else
    {
        if (self.rollingNewsList && [self.rollingNewsList count] && [self.photoList.newsId length] != [self.rollingNewsList[0] length])
        {
            self.slideshowController.gallerySourceType = GallerySourceTypeRecommend;
        }
        else
        {
            self.slideshowController.gallerySourceType = GallerySourceTypeNewsPaper;
        }
    }
    self.slideshowController.termId = self.termId;
    
    //---------
    GalleryItem *gallery = self.photoList;
    
    self.slideshowController.pubDate = gallery.time;
    
    SNDebugLog(@"_termId: %@, _myFavouriteRefer:%d", _termId, _myFavouriteRefer);
    
    //刊物组图PhotoList进入PhotoSlideShow
    if (_termId && ![_termId isEqualToString:kDftChannelGalleryTermId]) {
        self.slideshowController.myFavouriteReferInSlideShow = _myFavouriteRefer;
    }
    //滚动新闻的组图PhotoList进入PhotoSlideShow
    else if (_channelId) {
        self.slideshowController.myFavouriteReferInSlideShow = _myFavouriteRefer;
    }
    
    _slideshowController.supportContinuousReadingNext = _supportContinuousReadingNext;
    BOOL bShow = [_slideshowController showPhotoByIndex:beginIndex
                                               fromRect:rect
                                                 inView:self.view animated:YES];
    if (!bShow) {
        _slideshowController.delegate = nil;
    } else {
        [self getTopNavigation].view.userInteractionEnabled = NO;
        _pinchGesture.enabled = NO;
    }
}

- (void)openNewsPhotoSlideShow:(int)beginIndex dateSource:(SNPhotoSlideshow *)ds newsId:(NSString *)aNewsId from:(CGRect)rect
{
    if (_isShowBigPicView) {
        return;
    }

    self.photoCtl = [[SNNewsGallerySlidershowController alloc] initWithGallery:ds];
    self.photoCtl.delegate = self;
    self.photoCtl.sdkAdDataLastPic = self.sdkAdLastPic;

    BOOL bShow = [_photoCtl showPhotoByIndex:beginIndex
                                      inView:self.view
                                      newsId:aNewsId
                                        from:rect];
    if (bShow) {
        [self getTopNavigation].view.userInteractionEnabled = NO;
        _pinchGesture.enabled = NO;
        _isShowBigPicView = bShow;
    } else {
        self.photoCtl.delegate = nil;
        [self.photoCtl.view removeFromSuperview];
    }
}

- (id)prepareSNPhotos {
    if ([_newsType intValue] == 3) {
        SNPhotoSlideshow *ss = [[SNPhotoSlideshow alloc] init];
        ss.subId = _article.subId;
        ss.photos = [NSMutableArray array];
        ss.newscate = self.newsCate;
        
        int i = 0;
        for (NewsImageItem *newsItem in _article.newsImageItems) {
            @autoreleasepool {
                SNPhoto *photo = [[SNPhoto alloc] init];
                photo.url	= newsItem.url;
                photo.index = i++;
                photo.caption = _article.title;
                photo.info = newsItem.title;
                photo.photoSource = ss;
                [ss.photos addObject:photo];
            }
        }
        return ss;
    } else if ([_newsType intValue] == 4) {
        SNPhotoSlideshow *ss = [[SNPhotoSlideshow alloc] init];
        ss.subId = _photoList.subId;
        ss.photos = [NSMutableArray array];
        ss.moreRecommends = [NSArray arrayWithArray:_photoList.moreRecommends];
        ss.termId = self.termId;
        ss.newsId = self.newsId;
        ss.channelId = self.channelId;
        ss.nextGid  = self.article.nextId;
        ss.shareContent = _photoList.shareContent;
        ss.newscate = self.newsCate;
        
        int i = 0;
        for (PhotoItem *photoItem in _photoList.gallerySubItems) {
            @autoreleasepool {
                SNPhoto *photo = [[SNPhoto alloc] init];
                photo.url	= photoItem.url;
                photo.index = i++;
                photo.caption = _photoList.title;
                photo.info = photoItem.abstract;
                photo.photoSource = ss;
                [ss.photos addObject:photo];
            }
        }

        ss.sdkAdLastPic = self.sdkAdLastPic;
        ss.sdkAdLastRecommend = self.sdkAdLastRecommend;
        ss.sdkAd13371 = self.sdkAd13371;

        return ss;
    }
    return nil;
}

- (void)longTouchImage:(NSString *)url{
    UIViewController *topVc = [TTNavigator navigator].topViewController;
    if ([topVc isEqual:self] || [topVc isEqual:self.commonNewsController]) {
        
        __weak typeof(self)weakself = self;
        [self.longPressAlert showLongPressAlertWithShareBlock:^{
            [weakself shareOnePic:url];
        } andSaveBlock:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *img_url = [NSURL URLWithString:url];
                NSData *data = [NSData dataWithContentsOfURL:img_url];
                UIImage *saveImage = [UIImage imageWithData:data];
                UIImageWriteToSavedPhotosAlbum(saveImage, weakself,
                                               @selector(image:didFinishSavingWithError:contextInfo:), nil);
            });
            [SNNewsReport reportADotGif:@"_act=download&_tp=pho&from=news"];
        }];
    }
}

- (SNLongPressAlert *)longPressAlert  {
    if (_longPressAlert == nil) {
        _longPressAlert = [[SNLongPressAlert alloc] init];
    }
    return _longPressAlert;
}

- (void)shareOnePic:(NSString*)imgUrl{
    //wangshun share test
    NSMutableDictionary* d = [self createImageShare:imgUrl];
    [self callShare:d];
}

- (NSMutableDictionary*)createImageShare:(NSString*)imageUrl{
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    [dicShareInfo setObject:imageUrl forKey:SNNewsShare_ImageUrl];
    [dicShareInfo setObject:imageUrl forKey:SNNewsShare_Url];
    [dicShareInfo setObject:@"" forKey:SNNewsShare_content];
    [dicShareInfo setObject:@"0" forKey:@"newsId"];
    [dicShareInfo setObject:@"qqZone,copyLink" forKey:SNNewsShare_disableIcons];
    [dicShareInfo setObject:@"pho_news" forKey:SNNewsShare_LOG_type];
        
    NSMutableDictionary* isNoGifData = [self mainBodyShareData];
    if(isNoGifData){
        [dicShareInfo setObject:isNoGifData forKey:@"isNoGif"];//gif图分享 兼容 刘乐需求
    }

    return dicShareInfo;
}

- (NSMutableDictionary*)mainBodyShareData{//获取正文分享数据 仅用于 分享gif图
    NSMutableDictionary* dic = [self createActionMenuContentContext];
    
    if (self.link.length > 0) {
        [dic setObject:self.link forKey:SNNewsShare_Url];
    }
    [dic setObject:[SNUtility getShareNewsSourceType:self.link type:1] forKey:SNNewsShare_ShareOn_contentType];
    
    NSString *referStr = nil;
    if ([self.link containsString:@"gid="]) {
        referStr = @"gid=%@";
    }
    else {
        referStr = @"newsId=%@";
    }
    [dic setObject:[NSString stringWithFormat:referStr, self.newsId] forKey:SNNewsShare_ShareOn_referString];
    
    if (self.showType) {
        [dic setObject:self.showType forKey:@"showType"];
    }
    
    if (_newsType.integerValue == 3) {
        [dic setObject:@"news" forKey:SNNewsShare_LOG_type];
    }
    else{
        [dic setObject:@"pics" forKey:SNNewsShare_LOG_type];
    }
    
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeNews contentId:self.article.newsId];
    if (obj) {
        [dic setObject:[NSString stringWithFormat:@"%d",obj.sourceType] forKey:SNNewsShare_V4Upload_sourceType];
    } else {
        [dic setObject:[NSString stringWithFormat:@"%d",_newsType.integerValue] forKey:SNNewsShare_V4Upload_sourceType];
    }
    
    NSString* str = [NSString stringWithFormat:@"%d",(_newsType.integerValue == 3) ? SNTimelineContentTypeNews : SNTimelineContentTypePhoto];
    [dic setObject:str forKey:@"timelineContentType"];
    [dic setObject:self.newsId forKey:@"timelineContentId"];
    return dic;
}

#pragma mark - SNGalleryBrowserDelegate
/**
 图集浏览器的打开回调
 */
- (void)galleryBrowserDidShow {
    [SNUtility banUniversalLinkOpenInSafari];
    [self pagePVStatistic];
}

/**
 图集浏览器关闭回调
 */
- (void)galleryBrowserDidClose{
    self.galleryBrowser.delegate = nil;
    self.galleryBrowser = nil;
    [SNUtility banUniversalLinkOpenInSafari];
}

/**
 图集浏览器切换图片
 
 @param url 图片的url
 @param index 图片的index
 */
- (void)galleryBrowserDidChangePhoto:(NSString *)url index:(NSUInteger)index{
    _currentImageIndex = index;
    [self jsKitStorageGetItem];
}

/**
 根据图片url返回图片在正文的rect
 
 @param imageUrl 图片url
 @return 图片在正文页的rect
 */
- (CGRect)rectForgalleryBrowserImageUrl:(NSString *)imageUrl{
    return [self imageRectForUrl:imageUrl];
}

/**
 图集浏览器切换到下一新闻
 
 @param gid 下一组图新闻的gid
 */
- (void)galleryBrowserDidChangeNews:(NSString *)gid newsId:(NSString *)newsId channelId:(NSString *)channelId {
    if (!gid && newsId.length <= 8) {
        gid = newsId;
    }
    if (gid && [gid length] > 1)
    {
        self.newsId = gid;
        self.lastNewsId = self.newsId;
        self.gid = gid;
        self.termId = kDftSingleGalleryTermId;
        //图像页切换到下一条新闻后重置新闻model
        self.photoList = nil;
        
        NSString *URL = [NSString stringWithFormat:@"%@?%@", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [NSString stringWithFormat:@"gid=%@&channelId=%@&newstype=4", gid,channelId]];
        _isLastGroup = NO;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
        [SNRollingNewsPublicManager sharedInstance].isReadMoreArticles = YES;
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:gid ChannelId:self.channelId];

    }else if (newsId && newsId.length > 0) {
        self.newsId = newsId;
        self.lastNewsId = self.newsId;
        self.gid = gid;
        self.termId = kDftSingleGalleryTermId;
        //图像页切换到下一条新闻后重置新闻model
        self.photoList = nil;
        
        NSString *URL = [NSString stringWithFormat:@"%@?%@", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [NSString stringWithFormat:@"newsId=%@&channelId=%@&newstype=4",newsId,channelId]];
        _isLastGroup = NO;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
        [SNRollingNewsPublicManager sharedInstance].isReadMoreArticles = YES;
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:self.channelId];
    }
    
    [self resetSDKAd];
    [self loadRecommendNews];
    
    if ([self.channelId isEqualToString:@"47"] || [self.channelId isEqualToString:@"54"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:photoListSlideshowDidChange object:gid];
    }
}

/**
 new galleryBrowser大图模式的分享

 @param isGroupPhotos 是否是组图
 @param index 当前所在index
 @param image 当前要分享的image
 @param isAd 是否是广告
 */
- (void)sharePhotoWithGalleryType:(BOOL)isGroupPhotos currentIndex:(NSInteger)index photo:(UIImage *)image isAD:(BOOL)isAd {
    if (isGroupPhotos) {
        [self shareGroupPhotos:image currentIndex:index isAD:isAd];
    }else{
        [self sliderShowWillShare:index isAd:isAd];
    }
}

- (void)shareLongpressPhoto:(UIImage *)image imgUrl:(NSString *)url index:(NSInteger)index {
    [self shareOnePic:url];
}

- (void)getADShareContentDictionary
{
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString* title = [self.sdkAdLastPic adTitle];
    NSString* imageUrl = [self.sdkAdLastPic adImageUrl];
    [mDic setObject:title forKey:SNNewsShare_content];
    [mDic setObject:imageUrl?:@"" forKey:kShareInfoKeyImageUrl];
    [mDic setObject:imageUrl?:@"" forKey:SNNewsShare_Url];

    [self callShare:mDic];
}

- (void)shareGroupPhotos:(UIImage *)image currentIndex:(NSInteger)index isAD:(BOOL)isAd
{
    //wangshun share test
    if (isAd) {
        [self getADShareContentDictionary];
        return;
    }
    
    NSMutableDictionary* mDic = [self createGroupPhotoActionMenuContentContextWithImage:image isAd:isAd];
    
    NSString *referString = nil;
    NSString *linkUrl = nil;
    if (self.gid.length > 1) {
        referString = @"gid=%@";
        linkUrl = [NSString stringWithFormat:@"photo://channelId=%@&gid=%@", self.channelId, self.newsId];
    }
    else {
        referString = @"newsId=%@";
    }
    
    [mDic setObject:[NSString stringWithFormat:referString,self.newsId] forKey:@"referString"];
    if (linkUrl) {
        [mDic setObject:linkUrl forKey:@"url"];
        [mDic setObject:@"group" forKey:@"contentType"];
    }
    [mDic setObject:isAd ? @"" : @"group" forKey:@"contentType"];
    
    SNTimelineOriginContentObject *oobj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto contentId:self.newsId];
    NSString* sourceType = [NSString stringWithFormat:@"%d",oobj ? oobj.sourceType : 4];
    [mDic setObject:sourceType?:@"" forKey:@"sourceType"];
    [mDic setObject:sourceType?:@"pics" forKey:SNNewsShare_LOG_type];
    
    [self callShare:mDic];
}

- (NSMutableDictionary *)createGroupPhotoActionMenuContentContextWithImage:(UIImage *)image isAd:(BOOL)isAd
{
    NSString *referStr = nil;
    if (self.gid.length > 1) {//美图频道
        referStr = @"gid=";
    }
    else {
        referStr = @"newsId=";
    }
    NSMutableDictionary *shareInfoDict = [NSMutableDictionary dictionary];
    NSString *content = self.shareContent;
    if (isAd)
    {
        content = [self.sdkAdLastPic adShareText];
    }
    NSString *shareContent = content.length > 0 ? content : NSLocalizedString(@"SMS share to friends for splash", @"");
    shareInfoDict[kShareInfoKeyContent] = shareContent;
    NSString * protocoUrl = [NSString stringWithFormat:@"%@%@%@&subId=%@&from=channel&channelId=%@",kProtocolPhoto,referStr,self.newsId,@"",self.channelId?:@""];
    [shareInfoDict setObject:protocoUrl forKey:@"url"];
    //log
    if (content.length > 0)
    {
        shareInfoDict[kShareInfoKeyShareContent] = content;
    }
    NSString *newsID = self.newsId;
    if (newsID.length > 0)
    {
        shareInfoDict[kShareInfoKeyNewsId] = newsID;
    }
    
    //weixin
    NSString *imageUrl = nil;
    UIImage *saveImage = image;
    
    if (saveImage)
    {
        shareInfoDict[@"saveImage"] = saveImage;
    }
    if ([imageUrl length] > 0)
    {
        shareInfoDict[kShareInfoKeyImageUrl] = imageUrl;
    }
    if ([self.subId length] > 0)
    {
        shareInfoDict[kShareInfoKeySubId] = self.subId;
    }
    if ([self.title length] > 0)
    {
        shareInfoDict[kShareInfoKeyTitle] = self.title;
    }
    return shareInfoDict;
}

#pragma mark - UIdownloadimagebutton
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    SNDebugLog(@"照片失败%@", [error localizedDescription]);
    [[SNUtility getApplicationDelegate] image:image didFinishSavingWithError:error contextInfo:contextInfo];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_nightModeView) {
        _nightModeView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    }
    //操作栏未显示时无需发通知
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) {
        [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification object:nil userInfo:nil];
    }
    
    if (_isFullScreenMode) {
        BOOL bBottomEx = [self scorllViewToBottomEx:scrollView];
        if (bBottomEx || (scrollView.contentOffset.y <= 0 && !_isPostFollowHiden)) // 从底部向上拖拽较长距离或者滑到顶部
        {
            [self exitFullScreenMode];
        }
    }
    
    if (!_isMiniVideoSwitch) {
        return;
    }
    if (self.webView.scrollView.contentOffset.y - _videoY > 0 && self.webView.scrollView.contentOffset.y > self.tmpVideoRect.origin.y && self.webView.scrollView.contentOffset.y + kOfficialAccountViewHeight > self.tmpVideoRect.origin.y + self.tmpVideoRect.size.height) {
        for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
            if (_videoPlayer.isPlaying && !_isSmall) {
                if (_videoPlayer.isAnimation == NO) {
                    [SNNewsReport reportADotGif:@"_act=litevideo&_tp=centerclick"];
                    [_videoPlayer setSmallVideoAnimation:YES];
                    _isSmall = YES;
                } else {
                    _videoPlayer.isBecomingMini = YES;
                }
            }
        }
    }
    if (self.webView.scrollView.contentOffset.y - _videoY < 0 && self.webView.scrollView.contentOffset.y > self.tmpVideoRect.origin.y && self.webView.scrollView.contentOffset.y + kOfficialAccountViewHeight < self.tmpVideoRect.origin.y + self.tmpVideoRect.size.height) {
        for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
            if (_isSmall) {
                [_videoPlayer closeView:NO animation:YES];
                _isSmall = NO;
            }
        }
    }
    if (self.webView.scrollView.contentOffset.y - _videoY < 0 && self.webView.scrollView.contentOffset.y + kAppScreenHeight - kToolbarHeight - kSystemBarHeight < self.tmpVideoRect.origin.y + self.tmpVideoRect.size.height && self.webView.scrollView.contentOffset.y + kAppScreenHeight - kToolbarHeight - kSystemBarHeight < self.tmpVideoRect.origin.y) {
        for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
            if (_videoPlayer.isPlaying && !_isSmall) {
                if (_videoPlayer.videoWindowType == SNVideoWindowType_normal) {
                    [SNNewsReport reportADotGif:@"_act=litevideo&_tp=centerclick"];
                    [_videoPlayer setSmallVideoAnimation];
                    _isSmall = YES;
                } else {
                    _videoPlayer.isBecomingSmall = YES;
                }
            }
        }
    }
    if (self.webView.scrollView.contentOffset.y - _videoY > 0 && self.webView.scrollView.contentOffset.y + kAppScreenHeight - kToolbarHeight - kSystemBarHeight < self.tmpVideoRect.origin.y + self.tmpVideoRect.size.height && self.webView.scrollView.contentOffset.y + kAppScreenHeight - kToolbarHeight - kSystemBarHeight > self.tmpVideoRect.origin.y) {
        for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
            if (_isSmall && _videoPlayer.videoWindowType == SNVideoWindowType_small) {
                [_videoPlayer closeView:NO animation:NO];
                _isSmall = NO;
            }
        }
    }
    _videoY = self.webView.scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.webView callJavaScript:[NSString stringWithFormat:@"window.scrollViewWillBegin(%@)", [NSNumber numberWithBool:YES]] forKey:nil callBack:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.webView callJavaScript:[NSString stringWithFormat:@"window.scrollViewWillBegin(%@)", [NSNumber numberWithBool:NO]] forKey:nil callBack:nil];
//    [_officialAccountsInfo autoHideFakeStatusBar];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self.webView callJavaScript:[NSString stringWithFormat:@"window.scrollViewWillBegin(%@)", [NSNumber numberWithBool:NO]] forKey:nil callBack:nil];
//        [_officialAccountsInfo autoHideFakeStatusBar];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrolling];
}

//点击回顶或者点击评论数跳转动画完，需要再次判断小窗是否需要收起
- (void)scrollViewDidEndScrolling {
    if (self.tmpVideoRect.origin.y + self.tmpVideoRect.size.height > self.webView.scrollView.contentOffset.y && self.tmpVideoRect.origin.y < self.webView.scrollView.contentOffset.y + kAppScreenHeight - kToolbarHeight - kSystemBarHeight) {
        for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
            if (_isSmall) {
                [_videoPlayer closeView:NO animation:YES];
                _isSmall = NO;
            }
        }
    }
}

// scrollView已滚动到底部，又继续向上拖拽一定距离
- (BOOL)scorllViewToBottomEx:(UIScrollView*)scrollView
{
    float Offset = scrollView.contentOffset.y +TTApplicationFrame().size.height;
    float content = scrollView.contentSize.height;
    return  (Offset > (content + 70) ? YES:NO);
}

- (void)webViewMore:(UIButton *)button {
    NSMutableArray *titleArray = [NSMutableArray array];
    NSMutableArray *imageArray = [NSMutableArray array];
    [titleArray addObject:@"刷新"];
    [imageArray addObject:@"icowebview_refresh.png"];

    [titleArray addObject:@"举报"];//wangshun
    [imageArray addObject:@"icowebview_report.png"];
    
    __weak typeof(self)weakself = self;
    [SNPopOverMenu showForSender:button senderFrame:button.frame withMenu:titleArray imageNameArray:imageArray doneBlock:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0:
                //外链页面更多按钮刷新点击
                //@qz 埋点
                [weakself h5WebViewReload];
                [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=h5news_refresh&_tp=clk&channelid=%@&newsId=%@&newstype=8", self.channelId, self.newsId]];
                break;
            case 1:
                [weakself onClickReport];
                [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=h5news_report&_tp=clk&channelid=%@&newsId=%@&newstype=8", self.channelId, self.newsId]];
                break;
        }
    } dismissBlock:^{
    }];
}

- (void)h5WebViewReload{
    [self.webView reload];
}

- (void)h5PostFollow:(SNPostFollow*)postFollow andButtonTag:(int)iTag{
    switch (iTag){
        case 1: {
            if ([self.webView canGoBack] && ![self.tempH5WebLink isEqualToString:_h5WebLink]) {
                [self.webView goBack];
                [_postFollow showCloseBtn];
            }
            else{
                if ([self.notificationNews isEqualToString:@"notify"]) {
                    _postFollow.isFromPushNews = YES;
                }
                
                [_postFollow changeUserName];
                
                //2017-05-10  wangchuanwen 5.9.0 add begin
                //移除红包浮层(正文页阅读到90%触发红包，会有延迟，返回到频道弹出红包浮层)
                if ([self currentPage] == article_detail_txt || [self currentPage] == article_detail_pic) {
                    
                    JsKitStorage *jsKitStorageMange  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
                    //告知H5不在调红包弹框接口
                    [jsKitStorageMange setItem:[NSNumber numberWithInt:1] forKey:@"isCloseH5PicTextRedPacket"];
                }
                //2017-05-10  wangchuanwen 5.9.0 add begin
            }
            break;
        }
        case 2: {
            if ([self.notificationNews isEqualToString:@"notify"]) {
                _postFollow.isFromPushNews = YES;
            }
            
            [_postFollow changeUserName];
            
            //2017-05-10  wangchuanwen 5.9.0 add begin
            //移除红包浮层(正文页阅读到90%触发红包，会有延迟，返回到频道弹出红包浮层)
            if ([self currentPage] == article_detail_txt || [self currentPage] == article_detail_pic) {
                JsKitStorage *jsKitStorageMange  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
                //告知H5不在调红包弹框接口
                [jsKitStorageMange setItem:[NSNumber numberWithInt:1] forKey:@"isCloseH5PicTextRedPacket"];
            }
            //2017-05-10  wangchuanwen 5.9.0 add begin
            break;
        }
        case 3: {
            [self addOrRemoveMyFavourite];
            break;
        }
        case 4: {
            [self shareActionFromPostFollow];
            break;
        }
        default:
            break;
    }
    return;
}

-(void)h5PostFollow:(SNPostFollow *)postFollow WithButton:(UIButton *)btn{
    if (btn.tag == 5) {
        [self webViewMore:btn];
    }
}

#pragma mark PostFollowDelegate
- (void)postFollow:(SNPostFollow*)postFollow andButtonTag:(int)iTag
{
    if (postFollow.type == SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh) {
        [self h5PostFollow:postFollow andButtonTag:iTag];
        return;
    }
    
    switch (iTag)
    {
        case 1: {
            if ([self.notificationNews isEqualToString:@"notify"]) {
                _postFollow.isFromPushNews = YES;
            }
            
            [_postFollow changeUserName];
            
            //2017-05-10  wangchuanwen 5.9.0 add begin
            //移除红包浮层(正文页阅读到90%触发红包，会有延迟，返回到频道弹出红包浮层)
            if ([self currentPage] == article_detail_txt || [self currentPage] == article_detail_pic) {
                
                JsKitStorage *jsKitStorageMange  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
                //告知H5不在调红包弹框接口
                [jsKitStorageMange setItem:[NSNumber numberWithInt:1] forKey:@"isCloseH5PicTextRedPacket"];
            }
            //2017-05-10  wangchuanwen 5.9.0 add begin
            break;
        }
        case 2: {
            [self commentNumBtnClicked];
            break;
        }
        case 3: {
            [self addOrRemoveMyFavourite];
            break;
        }
        case 4: {
            [self shareActionFromPostFollow];
            break;
        }
        default:
            break;
    }
}
- (void)postFollowDidShowKeyboard:(SNPostFollow *)postFollow
{
}

- (void)postFollowDidHideKeyboard:(SNPostFollow *)postFollow
{
}

// 调起评论表情键盘
- (void)h5PostFollow:(SNPostFollow *)postFollow emojiBtnClick:(UIButton *)emojiBtn {
    [self presentCommentEidtorController:YES];
}

#pragma mark - share 分享

- (BOOL)canShareAndComment
{
    return nil == self.article.isPublished || [self.article.isPublished isEqualToString:@"1"];
}


- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

//正文分享
- (void)shareAction {
    [self.popOverView dismiss];
    //wangshun share test
    if ([self canShareAndComment]) {
        NSMutableDictionary* dic = [self createActionMenuContentContext];
        //[dicShareInfo setObject:SNNewsShare_Icons_ScreenShot forKey:SNNewsShare_addIcons];
        
        if (self.link.length > 0) {
            [dic setObject:self.link forKey:SNNewsShare_Url];
        }
        [dic setObject:[SNUtility getShareNewsSourceType:self.link type:1] forKey:SNNewsShare_ShareOn_contentType];
        
        NSString *referStr = nil;
        if ([self.link containsString:@"gid="]) {
            referStr = @"gid=%@";
        }
        else {
            referStr = @"newsId=%@";
        }
        [dic setObject:[NSString stringWithFormat:referStr, self.newsId] forKey:SNNewsShare_ShareOn_referString];
        
        if (self.showType) {
            [dic setObject:self.showType forKey:@"showType"];
        }
        
        if (_newsType.integerValue == 3) {
            [dic setObject:@"news" forKey:SNNewsShare_LOG_type];
        }
        else{
            [dic setObject:@"pics" forKey:SNNewsShare_LOG_type];
        }
        
        SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeNews contentId:self.article.newsId];
        if (obj) {
            [dic setObject:[NSString stringWithFormat:@"%d",obj.sourceType] forKey:SNNewsShare_V4Upload_sourceType];
        } else {
            [dic setObject:[NSString stringWithFormat:@"%d",_newsType.integerValue] forKey:SNNewsShare_V4Upload_sourceType];
        }
        
        NSString* str = [NSString stringWithFormat:@"%d",(_newsType.integerValue == 3) ? SNTimelineContentTypeNews : SNTimelineContentTypePhoto];
        [dic setObject:str forKey:@"timelineContentType"];
        [dic setObject:self.newsId forKey:@"timelineContentId"];
        
        if ([_h5Type isEqualToString:@"1"]) {
            [dic setObject:@"1" forKey:kH5WebType];
            [dic setObject:_h5WebLink forKey:@"h5weblink"];
        }
        
        [self callShare:dic];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kArticleUnPublicNotShare toUrl:nil mode:SNCenterToastModeWarning];
    }
}


//正文分享
- (void)shareActionFromPostFollow {
    [self.popOverView dismiss];
    
    //wangshun share test
    if ([self canShareAndComment]) {
        NSMutableDictionary* dic = [self createActionMenuContentContext];
        [dic setObject:SNNewsShare_Icons_ScreenShot forKey:SNNewsShare_addIcons];
        
        if (self.link.length > 0) {
            [dic setObject:self.link forKey:SNNewsShare_Url];
        }
        [dic setObject:[SNUtility getShareNewsSourceType:self.link type:1] forKey:SNNewsShare_ShareOn_contentType];
        
        NSString *referStr = nil;
        if ([self.link containsString:@"gid="]) {
            referStr = @"gid=%@";
        }
        else {
            referStr = @"newsId=%@";
        }
        [dic setObject:[NSString stringWithFormat:referStr, self.newsId] forKey:SNNewsShare_ShareOn_referString];
        
        if (self.showType) {
            [dic setObject:self.showType forKey:@"showType"];
        }
        
        if (_newsType.integerValue == 3) {
            [dic setObject:@"news" forKey:SNNewsShare_LOG_type];
        }
        else{
            [dic setObject:@"pics" forKey:SNNewsShare_LOG_type];
        }
        
        SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeNews contentId:self.article.newsId];
        if (obj) {
            [dic setObject:[NSString stringWithFormat:@"%d",obj.sourceType] forKey:SNNewsShare_V4Upload_sourceType];
        } else {
            [dic setObject:[NSString stringWithFormat:@"%d",_newsType.integerValue] forKey:SNNewsShare_V4Upload_sourceType];
        }
        
        NSString* str = [NSString stringWithFormat:@"%d",(_newsType.integerValue == 3) ? SNTimelineContentTypeNews : SNTimelineContentTypePhoto];
        [dic setObject:str forKey:@"timelineContentType"];
        [dic setObject:self.newsId forKey:@"timelineContentId"];
        
        if ([_h5Type isEqualToString:@"1"]) {
            [dic setObject:@"1" forKey:kH5WebType];
            [dic setObject:_h5WebLink forKey:@"h5weblink"];
        }
        
        [self callShare:dic];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kArticleUnPublicNotShare toUrl:nil mode:SNCenterToastModeWarning];
    }
}


//评论分享
- (void)shareComment:(SNNewsComment *)newsComment
{
    if (!newsComment) {
        return;
    }
    self.shareComment = newsComment;
    
    //wangshun share test
    NSMutableDictionary* dic = [self createActionMenuContentContext];

    if (self.showType) {
        [dic setObject:self.showType forKey:@"showType"];
    }
    
    [dic setObject:@"comment" forKey:SNNewsShare_LOG_type];
    
    if (self.link.length > 0) {
        [dic setObject:self.link forKey:SNNewsShare_Url];
    }
    [dic setObject:[SNUtility getShareNewsSourceType:self.link type:1] forKey:SNNewsShare_ShareOn_contentType];
    
    NSString *referString = nil;
    if ([self.link containsString:@"gid="]) {
        referString = @"gid=%@";
    }
    else {
        referString = @"newsId=%@";
    }
    [dic setObject:[NSString stringWithFormat:referString, self.newsId] forKey:SNNewsShare_ShareOn_referString];
    [dic setObject:[NSString stringWithFormat:@"%d",3] forKey:SNNewsShare_V4Upload_sourceType];
    
    //这两个参数仅狐友用
    [dic setObject:newsComment.commentId?:@"" forKey:@"commentId"];
    [dic setObject:newsComment.passport?:@"" forKey:@"passport"];
    
    [dic setObject:@"4" forKey:@"entrance"];//埋点值 登录 2017.11.27 登录埋点区分来源 评论分享至狐友 wangshun
    
    [self callShare:dic];
}

//正文快速分享
- (void)shareFastTo:(SNActionMenuOption)menuOption
{
    //只有发布的文章可以操作
    if ([self canShareAndComment]) {
        NSTimeInterval now = [NSDate date].timeIntervalSince1970;
        
        if(now - _lastShareTime < 1)
        {
            return;
        }
        
        _lastShareTime = now;
        if (nil == self.actionMenuController) {
            self.actionMenuController = [[SNActionMenuController alloc] init];
        }
        
        NSString *referStr = nil;
        if ([self.link containsString:@"gid="]) {
            referStr = @"gid=%@";
        }
        else {
            referStr = @"newsId=%@";
        }
        
        _actionMenuController.contextDic = [self createActionMenuContentContext];
        [_actionMenuController.contextDic setObject:self.link forKey:@"url"];
        [_actionMenuController.contextDic setObject:[NSString stringWithFormat:referStr,self.newsId] forKey:@"referString"];
        [_actionMenuController.contextDic setObject:[SNUtility getShareNewsSourceType:self.link type:1] forKey:@"contentType"];
        if (self.showType) {
            [_actionMenuController.contextDic setObject:self.showType forKey:@"showType"];
        }
        _actionMenuController.timelineContentType = (_newsType.integerValue == 3) ?SNTimelineContentTypeNews : SNTimelineContentTypePhoto;
        _actionMenuController.timelineContentId = self.newsId;
        _actionMenuController.shareLogType = @"fastshare";
        _actionMenuController.shareSubType = ShareSubTypeQuoteCard;
        _actionMenuController.delegate = self;
        _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
        _actionMenuController.disableCopyLinkBtn = YES;
        SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeNews contentId:self.article.newsId];
        if (obj) {
            _actionMenuController.sourceType = obj.sourceType;
        } else {
            _actionMenuController.sourceType = _newsType.integerValue;
        }
        [_actionMenuController halfFloatViewActionMenu:menuOption];
        
    } else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kArticleUnPublicNotShare toUrl:nil mode:SNCenterToastModeWarning];
    }
}

- (void)actionmenuDidSelectLikeBtn {
    [self addOrRemoveMyFavourite];
}

- (void)addOrRemoveMyFavourite {
    
    if ([SNMyFavouriteManager shareInstance].isHandleFavorite) {
        return;
    }
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    [SNMyFavouriteManager shareInstance].isFromArticle = YES;
    [SNMyFavouriteManager shareInstance].isHandleFavorite = YES;
    if ([self checkIfHadBeenMyFavourite]) {
        [self executeFavouriteNews:nil];
    } else {
        [SNUtility executeFloatView:self selector:@selector(executeFavouriteNews:)];
    }
}

- (void)clikItemOnHalfFloatView:(NSDictionary *)dict {
    [self executeFavouriteNews:dict];
}

- (void)executeFavouriteNews:(NSDictionary *)dict {
    _postFollow.isLiked = ![self checkIfHadBeenMyFavourite];
    [_postFollow refreshCollectionImage];
    [_postFollow showCollectionAnimation];
    [SNMyFavouriteManager shareInstance].delegate = self;
    NSMutableDictionary *favouriteDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if ([self.newsfrom isEqualToString:kChannelEditionNews]) {
        [favouriteDict setObject:kEditionNewsCollection forKey:kCollectionFrom];
    } else if ([self.newsfrom isEqualToString:kChannelRecomNews]) {
        [favouriteDict setObject:kRecomNewsCollection forKey:kCollectionFrom];
    } else if ([self.newsfrom isEqualToString:kNewsRecomNews]) {
        [favouriteDict setObject:kNewsRecomNewsCollection forKey:kCollectionFrom];
    } else if ([self.newsfrom isEqualToString:kSearchNews]) {
        [favouriteDict setObject:kSearchNewsCollection forKey:kCollectionFrom];
    } else {
        [favouriteDict setObject:kOtherCollection forKey:kCollectionFrom];
    }
    if (_h5Type && [_h5Type isEqualToString:@"1"]) {
        [favouriteDict setObject:_h5Type forKey:kH5WebType];
    }
    if (_newsType.integerValue == 3) {
        SNNewsContentFavourite *newsContentFavourite = [[SNNewsContentFavourite alloc] init];
        newsContentFavourite.title = self.article.title;
        newsContentFavourite.publicationDate = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]*1000];
        
        //刊物新闻最终页收藏
        if (_termId && ![_termId isEqualToString:kDftChannelGalleryTermId]) {
            newsContentFavourite.type = MYFAVOURITE_REFER_NEWS_IN_PUB;
            newsContentFavourite.contentLevelFirstID = _termId;
        } else if (_channelId) {//滚动新闻最终页收藏
            //其中也包括了推荐来的普通新闻
            newsContentFavourite.type = MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWS;
            newsContentFavourite.contentLevelFirstID = _channelId;
        }
        newsContentFavourite.contentLevelSecondID = _newsId;
        newsContentFavourite.showType = self.showType;
        
        //正文页记录5次点击收藏 弹出登录 wangshun 2017.10.12
        [[SNMyFavouriteManager shareInstance] addOrDeleteFavouriteFromSHH5Web:newsContentFavourite corpusDict:favouriteDict];
    } else if (_newsType.integerValue == 4) {
        GalleryItem *gallery = self.photoList;
        
        SNGroupPicturesContentFavourite *groupPicturesContentFavourite = [[SNGroupPicturesContentFavourite alloc] init];
        groupPicturesContentFavourite.title = gallery.title;
        groupPicturesContentFavourite.publicationDate = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]*1000];
        
        //取第一张图的地址；注意：这里的URL内容在PhotoListModel层会根据在线模式或离线内容来动态设内容，
        //所以用户在离线内容里收藏时url值是本地路径，实时阅读时url值是http打头的真实URL值；
        if ([gallery.gallerySubItems count] > 0) {
            PhotoItem *photo = gallery.gallerySubItems[0];
            if (![@"" isEqualToString:photo.url]) {
                groupPicturesContentFavourite.imageUrl = photo.url;
            }
        }
        groupPicturesContentFavourite.type = _myFavouriteRefer;
        groupPicturesContentFavourite.contentLevelSecondID = _newsId;
        
        if (_channelId) {
            //MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS 滚动新闻组图进入PhotoList
            //也报过推荐来的  MYFAVOURITE_REFER_RECOMMEND_NEWS_IN_CHANNEL
            groupPicturesContentFavourite.contentLevelFirstID = _channelId;
        }
        
        if (_gid.length > 1) {
            groupPicturesContentFavourite.contentLevelSecondID = _gid;
            groupPicturesContentFavourite.contentLevelFirstID = kCorpusNewsGidExist;
        }
        
        [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:groupPicturesContentFavourite corpusDict:favouriteDict];
    }
}

- (void)addToMyFavourite:(BOOL)success {
    if (success != _postFollow.isLiked) {
        _postFollow.isLiked = success;
        [_postFollow refreshCollectionImage];
    }
    [SNMyFavouriteManager shareInstance].isHandleFavorite = NO;
}

- (void)handleShareNotify:(NSNotification*)notification
{
    self.shareContent = [NSString stringWithFormat:(NSString *)[notification object],self.article.title,self.article.link ? self.article.link : @""];
    
    //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    SNDebugLog(@"title:%@",[mDic objectForKey:@"title"]);
    NSString* logType = [NSString stringWithFormat:@"%@",(_newsType.integerValue == 3)?@"news":@"pics"];
    [mDic setObject:logType forKey:SNNewsShare_LOG_type];
    
    NSString *referStrUrl = nil;
    if ([self.link containsString:@"gid="]) {
        referStrUrl = @"gid=%@";
    }
    else {
        referStrUrl = @"newsId=%@";
    }
    
    if (self.link) {
        [mDic setObject:self.link forKey:@"url"];
    }
   
    [mDic setObject:[NSString stringWithFormat:referStrUrl, self.newsId] forKey:SNNewsShare_ShareOn_referString];
    [mDic setObject:[SNUtility getShareNewsSourceType:self.link type:1] forKey:SNNewsShare_ShareOn_contentType];
    
    if (self.showType) {
        [mDic setObject:self.showType forKey:@"showType"];
    }
    
    SNTimelineOriginContentObject *oobj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeNews contentId:self.article.newsId];
    NSString* sourceType = [NSString stringWithFormat:@"%d",oobj?oobj.sourceType:_newsType.integerValue];
    [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    [self callShare:mDic];
}

- (BOOL)checkIfHadBeenMyFavourite
{
    if (_newsType.integerValue == 3) {
        SNNewsContentFavourite *newsContentFavourite = [[SNNewsContentFavourite alloc] init];
        
        if (_termId && ![_termId isEqualToString:kDftChannelGalleryTermId])
        {
            //来源于订阅tab下的，刊物新闻最终页收藏
            newsContentFavourite.type = MYFAVOURITE_REFER_NEWS_IN_PUB;
            newsContentFavourite.contentLevelFirstID = _termId;
        }
        else if (_channelId)
        {
            //来源于新闻tab下的，滚动新闻最终页收藏
            newsContentFavourite.type = MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWS;
            newsContentFavourite.contentLevelFirstID = _channelId;
        }
        newsContentFavourite.contentLevelSecondID = _newsId;
        return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:newsContentFavourite];
    } else if (_newsType.integerValue == 4) {
        SNGroupPicturesContentFavourite *groupPicturesContentFavourite = [[SNGroupPicturesContentFavourite alloc] init];
        groupPicturesContentFavourite.type = _myFavouriteRefer;
        groupPicturesContentFavourite.contentLevelSecondID = _newsId;
        
        if (_termId)
        {
            groupPicturesContentFavourite.contentLevelFirstID = _termId;
        }
        return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:groupPicturesContentFavourite];
    }
    return YES;
}

- (NSMutableDictionary *)createActionMenuContentContext {
    
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    
    if (self.article.link) {
        dicShareInfo[kShareInfoKeyNoteSourceURL] = self.article.link;
    }
    
    NSString *content = self.shareContent;
    if (!content) {
        content = self.article.shareContent;
    }
    
    if (content.length > 0) {
        [dicShareInfo setObject:content forKey:kShareInfoKeyContent];
    }
    
    if (self.article.title) {
        [dicShareInfo setObject:self.article.title forKey:kShareInfoKeyTitle];
    }
    
    if (_newsType.integerValue == 3) {
        [dicShareInfo setObject:self.article.title?:@"" forKey:kShareInfoKeyTitle];
    } else if (_newsType.integerValue == 4) {
        [dicShareInfo setObject:self.photoList.title?:@"" forKey:kShareInfoKeyTitle];
    }
    
    if (self.gid) {
        [dicShareInfo setObject:self.gid?:@"" forKey:@"gid"];
    }
    
    //总是获取不到标题
    NSString* title = [dicShareInfo objectForKey:kShareInfoKeyTitle];
    SNDebugLog(@"self.article.title:::%@",title);
    if(title == nil || [title isEqualToString:@""]){
        [self jsKitStorageGetItem];
        if (_newsType.integerValue == 3) {
            [dicShareInfo setObject:self.article.title?:@"" forKey:kShareInfoKeyTitle];
        } else if (_newsType.integerValue == 4) {
            [dicShareInfo setObject:self.photoList.title?:@"" forKey:kShareInfoKeyTitle];
        }
        title = [dicShareInfo objectForKey:kShareInfoKeyTitle];
    }
    SNDebugLog(@"self.article.title:::%@",title);
    
    if (self.article.subId) {
        [dicShareInfo setObject:self.article.subId forKey:kShareInfoKeySubId];
    }
    
    if (self.article.link) {
        [dicShareInfo setObject:self.article.link forKey:kShareInfoKeyShareLink];
    }
    
    if (self.shareComment) {
        if ([self.shareComment.content length] > 0) {
            [dicShareInfo setObject:self.shareComment.content forKey:kShareInfoKeyShareComment];
        }
        UIImage *image = [[TTURLCache sharedCache] imageForURL:self.shareComment.commentImageBig fromDisk:YES];
        NSString *shareImage = nil;
        if(image!=nil)
            shareImage = self.shareComment.commentImageBig;
        else
            shareImage = self.shareComment.commentImageSmall;
        
        if (shareImage.length > 0) {
            [dicShareInfo setObject:shareImage forKey:kShareInfoKeyImageUrl];
            [dicShareInfo setObject:shareImage forKey:kShareInfoKeyImagePath];
        }
    }
    
    self.shareComment = nil;
    
    if (self.article.newsId) {
        [dicShareInfo setObject:self.article.newsId forKey:kShareInfoKeyNewsId];
    }
    else if (self.newsId) {
        [dicShareInfo setObject:self.newsId forKey:kShareInfoKeyNewsId];
    }
    
    if (self.article.subId.length > 0) {
        [dicShareInfo setObject:self.article.subId forKey:kShareInfoLogKeySubId];
    }
    
    return dicShareInfo;
}

//举报
- (void)onClickReport
{
    if (_newsId) {
        [self stopVideo];
        
        if(![SNUserManager isLogin])
        {
            [SNUtility shouldUseSpreadAnimation:NO];
            [SNNewsLoginManager halfLoginData:@{@"halfScreenTitle":@"登录后才能使用举报哦",@"entrance":@"5"} Successed:^(NSDictionary *info) {
                
                [self performSelector:@selector(openReportPage) withObject:nil afterDelay:0.2];
            } Failed:nil];
    
            return;
        }
        
        [self openReportPage];
    }
}

- (void)openReportPage{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_newsId,@"newsId", nil];
    NSString *urlString = [NSString stringWithFormat:kUrlReport,@"1"];
    urlString = [SNUtility addParamP1ToURL:urlString];
    urlString = [NSString stringWithFormat:@"%@&newsId=%@", urlString, _newsId];
    urlString = [NSString stringWithFormat:@"%@&channelId=%@", urlString, _channelId];
    [dic setObject:urlString forKey:kLink];
    [dic setObject:[NSNumber numberWithInt:ReportWebViewType] forKey:kUniversalWebViewType];
    [SNUtility openUniversalWebView:dic];
}

- (SNNavigationController*)getTopNavigation
{
    return [TTNavigator navigator].topViewController.flipboardNavigationController;
}

#pragma mark SNNewsGallerySlidershowControllerDelegate method

-(void)sliderShowDidClose {
    self.webView.scrollView.scrollsToTop = YES;
    _isShowBigPicView = NO;
    _slideShowMode = NO;
    _currentImageIndex = 0;
    
    self.photoCtl.delegate = nil;
    [self.photoCtl.view removeFromSuperview];
}

-(void)sliderShowDidShow {
    [self getTopNavigation].view.userInteractionEnabled = YES;
    self.webView.scrollView.scrollsToTop = NO;
    _slideShowMode = YES;
}

- (void)sliderShowWillShare:(int)index isAd:(BOOL)isAd{
    if (isAd == YES) {
        [self getADShareContentDictionary];
        return;
    }
    else{
        [self sliderShowWillShare:index];
    }
}

- (void)sliderShowWillShare:(int)index
{
    if ([self canShareAndComment])
    {
        _currentImageIndex = index;
        
        //wangshun share test
        NSMutableDictionary* mDic = [self createActionMenuContentContext];
        NSString* logType = [NSString stringWithFormat:@"%@",(_newsType.integerValue == 3)?@"news":@"pics"];
        [mDic setObject:logType forKey:SNNewsShare_LOG_type];
        
        NSString *referStrUrl = nil;
        if ([self.link containsString:@"gid="]) {
            referStrUrl = @"gid=%@";
        }
        else {
            referStrUrl = @"newsId=%@";
        }
        
        if (self.link) {
            [mDic setObject:self.link forKey:SNNewsShare_Url];
        }
        
        [mDic setObject:[NSString stringWithFormat:referStrUrl, self.newsId] forKey:SNNewsShare_ShareOn_referString];
        [mDic setObject:[SNUtility getShareNewsSourceType:self.link type:1] forKey:SNNewsShare_ShareOn_contentType];
        [mDic setObject:_clickImageUrl forKey:SNNewsShare_ImageUrl];
        if (self.showType) {
            [mDic setObject:self.showType forKey:@"showType"];
        }
        [self callShare:mDic];
    }
    else
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kArticleUnPublicNotShare toUrl:nil mode:SNCenterToastModeWarning];
    }
}

- (CGRect)rectForImageUrl:(NSString *)url
{
    return [self scrollToImageRectForUrl:url];
}

- (void)hiddenImageForUrl:(NSString *)url
{
    [self hideImageForUrl:url];
}

#pragma mark - images
- (void)hideImageForUrl:(NSString *)url
{
    NSString *tag = [NSString stringWithFormat:@"img%@",[[TTURLCache sharedCache] keyForURL:url]];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var imgs = document.getElementsByName('%@'); \
                                                      for (var i = 0; i < imgs.length; ++i) { imgs[i].style.visibility = 'hidden'; }", tag]];
}

- (void)showImageForUrl:(NSString *)url
{
    NSString *tag = [NSString stringWithFormat:@"img%@",[[TTURLCache sharedCache] keyForURL:url]];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var img = document.getElementById('%@'); \
                                                      for (var i = 0; i < imgs.length; ++i) { imgs[i].style.visibility = 'visible'; }",tag]];
}

- (CGRect)imageRectForUrl:(NSString *)url
{
    id imageSize = [_webView callJavaScript:[NSString stringWithFormat:@"window.backMagnifyImage('%@')", url] forKey:nil callBack:nil];
    //增加类型保护 by cuiliangliang
    if (imageSize && [imageSize isKindOfClass:[NSDictionary class]]) {
        id x = [imageSize objectForKey:@"x"];
        id y = [imageSize objectForKey:@"y"];
        id width = [imageSize objectForKey:@"w"];
        id height = [imageSize objectForKey:@"h"];
        if (width && height && ![width isKindOfClass:[NSNull class]] && ![height isKindOfClass:[NSNull class]]) {
            return CGRectMake((x && ![x isKindOfClass:[NSNull class]] && [NSString stringWithFormat:@"%@",x].floatValue > 0) ? [NSString stringWithFormat:@"%@",x].floatValue : 14, ![y isKindOfClass:[NSNull class]] ? [NSString stringWithFormat:@"%@",y].floatValue : 120, [NSString stringWithFormat:@"%@",width].floatValue, [NSString stringWithFormat:@"%@",height].floatValue);
        } else {
            return CGRectZero;
        }
    }
        
    return CGRectZero;
}

- (CGRect)scrollToImageRectForUrl:(NSString *)url
{
    CGRect rect = [self imageRectForUrl:url];
    return rect;
}

- (void)onClickVideo:(CGRect)rect
{
    if (_article == nil) {
        [self jsKitStorageGetItem];
    }
    [self createVideoViewsIfNeeded:rect tvInfo:nil];
}

- (void)playVideo:(CGRect)rect tvInfo:(NSDictionary *)tvInfo
{
    [self createVideoViewsIfNeeded:rect tvInfo:tvInfo];
}

#pragma mark - Statistic
- (void)statVideoPV:(SNVideoData *)willPlayModel playerView:(SNH5NewsVideoPlayer *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = willPlayModel.vid.length > 0 ? willPlayModel.vid : @"";
    _vStatModel.subId = self.article.subId.length > 0 ? self.article.subId : @"";
    _vStatModel.newsId = self.article.newsId.length > 0 ? self.article.newsId : @"";
    _vStatModel.channelId = self.article.channelId.length > 0 ? self.article.channelId : @"";
    _vStatModel.messageId = @"";
    _vStatModel.refer = [self videoStatRefer];
    [[WSMVVideoStatisticManager sharedIntance] statVideoPV:_vStatModel];
}

- (void)statVideoVV:(SNVideoData *)finishedPlayModel playerView:(SNH5NewsVideoPlayer *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = finishedPlayModel.vid.length > 0 ? finishedPlayModel.vid : @"";
    _vStatModel.subId = self.article.subId.length > 0 ? self.article.subId : @"";
    _vStatModel.newsId = self.article.newsId.length > 0 ? self.article.newsId : @"";
    _vStatModel.channelId = self.article.channelId.length > 0 ? self.article.channelId : @"";
    _vStatModel.messageId = @"";
    _vStatModel.refer = [self videoStatRefer];
    _vStatModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + finishedPlayModel.playedTime;
    _vStatModel.totalTimeInSeconds = finishedPlayModel.totalTime;
    _vStatModel.siteId = finishedPlayModel.siteInfo.siteId;
    _vStatModel.columnId = @"";
    _vStatModel.offline = kWSMVStatVV_Offline_NO;
    [[WSMVVideoStatisticManager sharedIntance] statVideoVV:_vStatModel inVideoPlayer:videoPlayerView];
}

//累计连播数据以便在调起播放器页不再使用播放器时统计连播
- (void)cacheVideoSV:(SNVideoData *)videoModel playerView:(SNH5NewsVideoPlayer *)videoPlayerView {
    WSMVVideoStatisticModel *_statModel = [[WSMVVideoStatisticModel alloc] init];
    _statModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _statModel.newsId = self.article.newsId.length > 0 ? self.article.newsId : @"";
    _statModel.messageId = @"";
    _statModel.refer = [self videoStatRefer];
    _statModel.playtimeInSeconds = [videoPlayerView curretnPlayTime] + videoModel.playedTime;
    [[WSMVVideoStatisticManager sharedIntance] cacheVideoSV:_statModel];
}

- (void)statVideoAV:(SNVideoData *)videoModel playerView:(SNH5NewsVideoPlayer *)videoPlayerView {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = self.article.subId.length > 0 ? self.article.subId : @"";
    _vStatModel.newsId = self.article.newsId.length > 0 ? self.article.newsId : @"";
    _vStatModel.channelId = self.article.channelId.length > 0 ? self.article.channelId : @"";
    _vStatModel.messageId = @"";
    _vStatModel.refer = [self videoStatRefer];
    [[WSMVVideoStatisticManager sharedIntance] statVideoPlayerActions:_vStatModel actionsData:videoPlayerView.playerActionsStatData];
}

- (void)statFFL:(SNVideoData *)videoModel playerView:(SNH5NewsVideoPlayer *)videoPlayerView succeededToLoad:(BOOL)succeededToLoad {
    WSMVVideoStatisticModel *_vStatModel = [[WSMVVideoStatisticModel alloc] init];
    _vStatModel.vid = videoModel.vid.length > 0 ? videoModel.vid : @"";
    _vStatModel.subId = self.article.subId.length > 0 ? self.article.subId : @"";
    _vStatModel.newsId = self.article.newsId.length > 0 ? self.article.newsId : @"";
    _vStatModel.channelId = self.article.channelId.length > 0 ? self.article.channelId : @"";
    _vStatModel.messageId = @"";
    _vStatModel.siteId = videoModel.siteInfo.siteId;
    _vStatModel.refer = [self videoStatRefer];
    _vStatModel.succeededToFFL = succeededToLoad;
    [[WSMVVideoStatisticManager sharedIntance] statFFL:_vStatModel];
}

- (VideoStatRefer)videoStatRefer {
    return VideoStatRefer_RollingNews;
}

#pragma mark - video
- (void)createVideoViewsIfNeeded:(CGRect)rect tvInfo:(NSDictionary *)tvInfo
{
    self.tmpVideoRect = rect;
    
    for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
        [_videoPlayer stop];
        [_videoPlayer setDelegate:nil];
        [_videoPlayer clearMoviePlayerController];
        [_videoPlayer removeFromSuperview];
        _isSmall = NO;
    }
    
    NSDictionary *tvinfoDic;
    if (tvInfo) {
        tvinfoDic = tvInfo;
    } else {
        NSArray *_videos = self.article.tvInfos;
        if (_videos && _videos.count > 0) {
            tvinfoDic = [_videos objectAtIndex:0];
        }
    }
    if (tvinfoDic && [tvinfoDic isKindOfClass:[NSDictionary class]]) {
        
        if (!_blackView) {
            _blackView = [[UIView alloc] initWithFrame:rect];
            _blackView.backgroundColor = [UIColor blackColor];
            [_webView.scrollView addSubview:_blackView];
        } else {
            _blackView.frame = rect;
        }
        
        [[SNVideoAdContext sharedInstance] setCurrentVideoAdPosition:SNVideoAdContextCurrentVideoAdPosition_Article];
        SNVideoData *_videoModel        = [[SNVideoData alloc] init];
        _videoModel.title               = [tvinfoDic stringValueForKey:@"tvName" defaultValue:@""];
        _videoModel.subtitle            = nil;
        
        NSString *_playlistStr          = [tvinfoDic stringValueForKey:@"playlist" defaultValue:@""];
        NSMutableArray *_playlistArray  = [[_playlistStr componentsSeparatedByString:@","] mutableCopy];
        _videoModel.sources             = _playlistArray;
        
        _videoModel.poster              = [tvinfoDic stringValueForKey:@"tvPic" defaultValue:@""];
        _videoModel.vid                 = [tvinfoDic stringValueForKey:@"vid" defaultValue:@""];
        
        _videoModel.playType            = [tvinfoDic intValueForKey:@"playType" defaultValue:0];
        _videoModel.downloadType        = [tvinfoDic intValueForKey:@"download" defaultValue:0];
        
        _videoModel.share               = [[SNVideoShare alloc] init];
        _videoModel.share.h5Url         = [tvinfoDic stringValueForKey:@"h5Url" defaultValue:@""];
        _videoModel.share.content       = [tvinfoDic stringValueForKey:@"shareContent" defaultValue:@""];
        
        _videoModel.wapUrl              = [tvinfoDic stringValueForKey:@"wapUrl" defaultValue:@""];
        self.article.autoplayVideo      = [tvinfoDic intValueForKey:@"autoplayVideo" defaultValue:NO];
        
        _videoModel.siteInfo            = [[SNVideoSiteInfo alloc] init];
        _videoModel.siteInfo.site       = [tvinfoDic stringValueForKey:SNVideoConst_kSite defaultValue:@""];
        _videoModel.siteInfo.site2      = [tvinfoDic stringValueForKey:SNVideoConst_kSite2 defaultValue:@""];
        _videoModel.siteInfo.siteName   = [tvinfoDic stringValueForKey:SNVideoConst_kSiteName defaultValue:@""];
        _videoModel.siteInfo.siteId     = [tvinfoDic stringValueForKey:SNVideoConst_kSiteId defaultValue:@""];
        _videoModel.siteInfo.playById   = [tvinfoDic stringValueForKey:SNVideoConst_kPlayById defaultValue:@""];
        _videoModel.siteInfo.playAd     = [tvinfoDic stringValueForKey:SNVideoConst_kPlayAd defaultValue:@""];
        _videoModel.siteInfo.adServer   = [tvinfoDic stringValueForKey:SNVideoConst_kAdServer defaultValue:@""];
        
        //@qz 2017.11.20 checksite.go接口需要
        if (![_videoModel newsId]) {
            [_videoModel setNewsId:[NSString stringWithFormat:@"%@",self.article.newsId]];
        }
        _videoModel.newsType = [NSString stringWithFormat:@"%@",self.article.newsType];
        SNH5NewsVideoPlayer *_videoView = [[SNH5NewsVideoPlayer alloc] initWithFrame:rect andDelegate:self];
        _videoView.moviePlayer.view.frame = _videoView.bounds;
        [_videoView getMoviePlayer].movieScaleMode = SHMovieScaleModeAspectFit;
        _videoView.videoPlayerRefer = WSMVVideoPlayerRefer_NewsArticle;
        [_videoView hideTitleAndControlBarWithAnimation:NO];
        CGFloat width = [[NSString stringWithFormat:@"%@", [tvinfoDic objectForKey:@"width" defalutObj:@"0"]] floatValue];
        CGFloat height = [[NSString stringWithFormat:@"%@", [tvinfoDic objectForKey:@"height" defalutObj:@"0"]] floatValue];
        if (width > 0 && height > 0) {
            _videoView.originalWidth = width;
            _videoView.originalHeight = height;
        } else {
            _videoView.originalWidth = 4.0f;
            _videoView.originalHeight = 3.0f;
        }
        NSString *miniVideo = [SNUserDefaults objectForKey:kNewsMiniVideoModeKey];
        if (miniVideo && [miniVideo isEqualToString:@"1"]) {
            _isMiniVideoSwitch = NO;
        } else {
            _isMiniVideoSwitch = YES;
        }
        
        _videoView.isPlayingRecommendList = YES;
        _videoView.supportSwitchVideoByLRGestureInNonFullscreenMode = NO;
        _videoView.isFromNewsContent = YES;
        _videoView.supportRelativeVideosViewInNonFullscreenMode = YES;
        _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_videoView initPlaylist:[NSArray arrayWithObject:_videoModel] initPlayingIndex:0];
        self.videoPlayers = [NSArray arrayWithObject:_videoView];
        [_webView.scrollView addSubview:_videoView];
        
        [SNNotificationManager postNotificationName:kPrintSHMoviePlayerCurrentViewInfo object:nil];
        
        [_videoView playCurrentVideo];
        [self loadRecommendVideos];
    }
}
- (void)exitFullScreenIfNeeded {
    for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
        [_videoPlayer exitFullScreen];
    }
}

- (void)pauseVideo {
    for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
        [_videoPlayer pause];
    }
}

- (void)stopVideo {
    if (_videoPlayers.count > 0) {
        for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
            if (![_videoPlayer isPaused]) {
                // 打开链接时，停止所有视频
                [SNNotificationManager postNotificationName:kSNPlayerViewStopVideoNotification object:nil];
                if ([_videoPlayer getMoviePlayer]) {
                    [_videoPlayer clearMoviePlayerController];
                }
            }
        }
    }
}

- (void)pauseVideoIfPlayingOtherwiseForceStop {
    for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
        if ([_videoPlayer isPlaying]) {
            [_videoPlayer pause];
        }
        else {
            [_videoPlayer stop];
        }
    }
}
//by cuiliangliang
- (void)continuePlayAudio{
    for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
        if ([_videoPlayer isPaused]) {
            [[_videoPlayer getMoviePlayer] play];
        }
    }
}
#pragma mark - audio
- (void)stopAudio {
    // 新的需求是打开新的新闻就停止播放音视频
    [[SNSoundManager sharedInstance] stopAll];
}

- (void)audioStartNotification:(NSNotification *)notification {
    [self pauseVideo];
}
#pragma mark - Private - Recommend Videos
- (void)autoplayIfNeeded{
    //Wifi环境下自动开始播放---
    NetworkStatus _netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (((_netStatus == ReachableViaWiFi) && _videoPlayers.count > 0)) {
        SNH5NewsVideoPlayer *_firstVideoPlayer = [_videoPlayers objectAtIndex:0];
        [_firstVideoPlayer playCurrentVideo];
    }
}

- (void)loadRecommendVideos {
    [self.recommendVideosWebService cancel];
    self.recommendVideosWebService = [[SNArticleRecomVideosWebService alloc] init];
    self.recommendVideosWebService.newsId = self.article.newsId;
    self.recommendVideosWebService.channelId = self.article.channelId;
    self.recommendVideosWebService.subId = self.article.subId;
    self.recommendVideosWebService.delegate = self;
    [self.recommendVideosWebService startAsynchrously];
}

#pragma mark - SNArticleRecomVideosWebServiceDelegate
- (void)didFinishLoadRecommendVideos:(NSArray *)recommendVideos {
    self.recommendVideos = recommendVideos;
    for (SNH5NewsVideoPlayer *_playerView in _videoPlayers) {
        [_playerView appendPlaylist:self.recommendVideos];
        [_playerView replaceAllRecommendVieos:self.recommendVideos];
    }
}

- (void)didFailLoadWithError:(NSError *)error {
    //Do nothing.
}

#pragma mark - WSMVVideoPlayerViewDelegate
- (BOOL)isVideoPlayerVisible {
    return _isVideoPlayerVisible;
}

- (void)thereIsNoPreVideo:(SNH5NewsVideoPlayer *)playerView {
    if ([playerView isFullScreen]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"alreadFirstVideo", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeWarning];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"alreadFirstVideo", nil) toUrl:nil mode:SNCenterToastModeWarning];
    }
}

- (void)willPlayPreVideo:(SNVideoData *)video {
    for (SNH5NewsVideoPlayer *_playerView in _videoPlayers) {
        [_playerView replaceAllRecommendVieos:self.recommendVideos];
    }
}

- (void)thereisNoNextVideo:(SNH5NewsVideoPlayer *)playerView {
    if ([playerView isFullScreen]) {
        [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"alreadLastVideo", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeWarning];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"alreadLastVideo", nil) toUrl:nil mode:SNCenterToastModeWarning];
    }
}

- (void)willPlayNextVideoIn5Seconds:(SNVideoData *)video {
    if (self.videoPlayers.count > 0) {
        SNH5NewsVideoPlayer *playerView = self.videoPlayers[0];
        if ([playerView isFullScreen]) {
            [playerView showWillPlayNextVideoToastWithVideo:video];
        }
    }
}

- (void)willPlayNextVideo:(SNVideoData *)video {
    for (SNH5NewsVideoPlayer *_playerView in _videoPlayers) {
        [_playerView replaceAllRecommendVieos:self.recommendVideos];
    }
}

//全屏的栏目按钮展开，一直查看更多不足时会回调此方法
- (NSArray *)recommendVideosOfVideoModel:(SNVideoData *)playingVideoModel more:(BOOL)more {
    //经产品经理苏伟确认3.7非视频Tab视频的推荐内容一次性加载，没有分页加载更新需求。
    return nil;
}

//一直切换下一个视频不足时会回调此方法
- (void)needMoreRecommendIntoPlaylist {
    //经产品经理苏伟确认3.7非视频Tab视频的推荐内容一次性加载，没有分页加载更新需求。
}

- (void)willShareVideo:(SNVideoData *)video fromPlayer:(SNH5NewsVideoPlayer *)player {
}

#pragma mark - 2G3G提示
- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style forPlayerView:(SNH5NewsVideoPlayer *)playerView {
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
    }
    else if (style == WSMV2G3GAlertStyle_VideoPlayingToast) {
        SNDebugLog(@"Will show 2G3G alert with toastUI.");
        UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
        BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeWarning];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil mode:SNCenterToastModeWarning];
            }
        }
    }
    else if (style == WSMV2G3GAlertStyle_NetChangedTo2G3GToast) {
        SNDebugLog(@"Toast for network changed to 2G/3G.");
        UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
        BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil mode:SNCenterToastModeWarning];
            }
        }
    }
    else if (style == WSMV2G3GAlertStyle_NotReachable) {
        [playerView pause];
        if ([playerView isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
            
        }
    }
    else {
        SNDebugLog(@"Needn't show 2G3G alert UI currently.");
    }
    
    // 如果网络恢复了 并且相关推荐还没有加载出来  重新加载
    if ([SNUtility getApplicationDelegate].isNetworkReachable && self.recommendVideos.count <= 0) {
        [self loadRecommendVideos];
    }
}

- (void)videoNomalForToSmallPlayerView:(WSMVVideoPlayerView *)playerView
{
    CGPoint point = [self.webView.scrollView convertPoint:CGPointMake(self.tmpVideoRect.origin.x, self.tmpVideoRect.origin.y) toView:self.view];
    playerView.top = point.y;
    playerView.left = point.x;
    [playerView removeFromSuperview];
    [self.view addSubview:playerView];
}

- (void)videoSmallToNomalForPlayerView:(WSMVVideoPlayerView *)playerView
{
    CGPoint point = [self.webView.scrollView convertPoint:CGPointMake(playerView.frame.origin.x, playerView.frame.origin.y) fromView:self.view];
    [playerView removeFromSuperview];
    
    [_webView.scrollView addSubview:playerView];
    playerView.top = point.y;
    playerView.left = point.x;
}

- (void)setIsSmallVideo:(BOOL)isSmall
{
    _isSmall = isSmall;
}

- (void)showNetworkWarningAciontSheetForPlayer:(SNH5NewsVideoPlayer *)playerView {
    
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

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SNDebugLog(@"Tapped actionSheet at buttonIndex %d", buttonIndex);
    
    SNH5NewsVideoPlayer *playerView = [[actionSheet userInfo] objectForKey:kPlayerViewWithActionSheet];
    if (actionSheet.tag == kRechabilityChangedActionSheetTag) {
        if (buttonIndex == 0) {//取消
            playerView.playingVideoModel.hadEverAlert2G3G = NO;
            [playerView pause];
        }
        else if (buttonIndex == 1) {//播放
            playerView.playingVideoModel.hadEverAlert2G3G = YES;
            [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
            [playerView playCurrentVideo];
        }
    }
}

- (void)dismissActionSheetByTouchBgView:(SNActionSheet *)actionSheet {
    SNH5NewsVideoPlayer *playerView = [[actionSheet userInfo] objectForKey:kPlayerViewWithActionSheet];
    [playerView pause];
}

#pragma mark SNGroupPicturesSlideshowViewControllerDelegate
- (void)slideshowDidShow:(SNGroupPicturesSlideshowContainerViewController *)slideshowController
{
    [self getTopNavigation].view.userInteractionEnabled = YES;
    if (self.photoList.moreRecommends.count < 8) {
        [_slideshowController refreshAd:nil ad13371:nil ad12233:self.sdkAdLastPic];
    } else {
        [_slideshowController refreshAd:self.sdkAdLastRecommend ad13371:self.sdkAd13371 ad12233:self.sdkAdLastPic];
    }
    _isSlideShowMode = YES;
}

- (void)slideshowDidChange:(SNGroupPicturesSlideshowContainerViewController *)slideshowController photoIndex:(int)index
{
    if (_returnIndex && _returnIndex.row != index) {

    }
}

- (CGRect)slideshowPhotoFrameShouldReturn:(SNPhotoGallerySlideshowController *)slideshowController photoIndex:(NSInteger)index
{
    [self jsKitStorageGetItem];

    if (slideshowController == nil) {
        return CGRectZero;
    }
    if (index < 0 || index >= _photoList.gallerySubItems.count) {
        return CGRectZero;
    }
    PhotoItem *item = [_photoList.gallerySubItems objectAtIndex:index];
    if (item) {
        return [self imageRectForUrl:item.url];
    }
    return CGRectZero;   
}

- (void)slideshowDidChange:(SNPhotoGallerySlideshowController *)slideshowController galleryId:(NSString *)gid
{
    if (gid && [gid length] > 0)
    {
        self.lastNewsId = self.newsId;
        self.gid = gid;
        self.termId = kDftSingleGalleryTermId;
        //图像页切换到下一条新闻后重置新闻model
        self.photoList = nil;
        
        NSString *URL = [NSString stringWithFormat:@"%@?%@", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [NSString stringWithFormat:@"gid=%@&channelId=47&newstype=4", gid]];
        _isLastGroup = NO;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
        [self resetSDKAd];
        [self loadRecommendNews];
    }
}

- (void)resetSDKAd{
    [_officialAccountsInfo hide];
    //切换下一组图，重新加载相关推荐,重置广告数据
    self.sdkAdLastPic = nil;
    self.sdkAdLastRecommend = nil;
    self.sdkAd13371 = nil;

    self.sdkAdLastPic.delegate = nil;
    self.sdkAdLastRecommend.delegate = nil;
    self.sdkAd13371.delegate = nil;
    [_recommendService.adInfoArray removeAllObjects];
}

- (void)slideshowDidChange:(SNPhotoGallerySlideshowController *)slideshowController termId:(NSString *)termId newsId:(NSString *)newsId slideToNextGroup:(BOOL)isNextGroup
{
    self.lastNewsId = self.newsId;
    self.newsId = newsId;
    self.termId = termId;
    //图像页切换到下一条新闻后重置新闻model
    self.photoList = nil;

    if (!isNextGroup) {
        _isLastGroup = YES;
    }
    if ([termId isEqualToString:@"0"]) {
        self.gid = newsId;
        NSString *URL = [NSString stringWithFormat:@"%@?%@&newstype=4", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [NSString stringWithFormat:@"gid=%@&channelId=47&newstype=4", newsId]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
    } else {
        NSString *URL = [NSString stringWithFormat:@"%@?%@&newstype=4", [SHUrlMaping getLocalPathWithKey:SH_JSURL_ARTICLE], [NSString stringWithFormat:@"newsId=%@&newstype=4", newsId]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
    }
   
    [self resetSDKAd];
    [self loadRecommendNews];
}

- (void)slideshowWillDismiss:(SNGroupPicturesSlideshowContainerViewController *)slideshowController
{
    if (![self.lastNewsId isEqualToString:self.newsId]) {
        self.lastNewsId = self.newsId;
    }
    [self getTopNavigation].view.userInteractionEnabled = NO;
}

//组图进组图新闻
- (void)slideshowDidDismiss:(SNGroupPicturesSlideshowContainerViewController *)slideshowController {
    if (_slideshowController) {
        _slideshowController.delegate = nil;
    }

    [self getTopNavigation].view.userInteractionEnabled = YES;
    _pinchGesture.enabled = YES;
    _isSlideShowMode = NO;
    if (![SNUtility getApplicationDelegate].isNetworkReachable)
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

#pragma mark soundPlay
- (void)soundPlay:(NSString *)url commentId:(NSString *)commentId
{
    if (url.length > 0 && commentId.length > 0) {
        self.soundUrl = url;
        self.commentId = commentId;
        NSString *localPath = [SNSoundManager soundFileDownloadPathWithURL:url];
        
        // mp3在线播放不下载
        BOOL bMP3 = [url hasSuffix:@".mp3"];
        
        if (!bMP3 && ![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            SNSoundItem *sndItem = [[SNSoundItem alloc] init];
            sndItem.url = url;
            sndItem.localPath = localPath;
            
            [[SNSoundManager sharedInstance] stopAll];
            
            if (![[SNSoundManager sharedInstance] isSoundItemDownloading:sndItem]) {
                [[SNSoundManager sharedInstance] cancelAllDownloads];
                [[SNSoundManager sharedInstance] downloadSoundItem:sndItem];
                [self setStatus:SNSoundStatusDownloading commentId:self.commentId];
                [SNSoundManager sharedInstance].playCommentId = self.commentId;
                [[SNSoundManager sharedInstance] setSndItemNextToPlay:sndItem];
            } else {
                [[SNSoundManager sharedInstance] cancelAllDownloads];
                [self setStatus:SNSoundStatusDefault commentId:self.commentId];
                [SNSoundManager sharedInstance].playCommentId = nil;
                [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
            }
        } else {
            [[SNSoundManager sharedInstance] cancelAllDownloads];
            
            SNSoundStatusType sndStatus = [[SNSoundManager sharedInstance] statusForSoundUrl:url];

            if (sndStatus == SNSoundStatusPlaying && [self isSameCommentId]) {
                [self setStatus:SNSoundStatusDefault commentId:self.commentId];
                
                [[SNSoundManager sharedInstance] stopAll];
                [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
                [SNSoundManager sharedInstance].playCommentId = nil;
                
            } else {
                if (![self isSameCommentId]) {
                    [self setStatus:SNSoundStatusDefault commentId:[SNSoundManager sharedInstance].playCommentId];
                }
                SNSoundItem *sndItem = [[SNSoundItem alloc] init];
                sndItem.url = url;
                sndItem.localPath = localPath;
                [SNSoundManager sharedInstance].playCommentId = self.commentId;
                BOOL bOK = [[SNSoundManager sharedInstance] playSound:sndItem];
                if (bOK) {
                    [self setStatus:bMP3?SNSoundStatusDownloading:SNSoundStatusPlaying commentId:self.commentId];
                    
                } else {
                    [self setStatus:SNSoundStatusDefault commentId:self.commentId];
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"无法播放该音频" toUrl:nil mode:SNCenterToastModeWarning];
                    
                    // 删除无法播放的本地文件
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                        NSError *removeError = nil;
                        [[NSFileManager defaultManager] removeItemAtPath:localPath error:&removeError];
                    }
                }
                [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
            }
        }
    }
}

- (void)onSoundPlayFinished:(NSNotification *)notification {
    if (self.soundUrl) {
        NSDictionary *userInfo = (NSDictionary *)notification.object;
        
        NSString *tag = [[TTURLCache sharedCache] keyForURL:self.soundUrl];
        NSString *sndId = [NSString stringWithFormat:@"snd%@", tag];
        
        if ([sndId isEqualToString:[userInfo objectForKey:@"id"]]) {
            if ([NSThread isMainThread]) {
                [self setStatus:SNSoundStatusDefault commentId:self.commentId];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setStatus:SNSoundStatusDefault commentId:self.commentId];
                });
            }
        }
    }
}

- (void)stopSoundPlay
{
    [self setStatus:SNSoundStatusDefault commentId:self.commentId];
    [[SNSoundManager sharedInstance] stopByUrl:self.soundUrl];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
}

- (BOOL)isSameCommentId {
    BOOL isSame;
    if ([SNSoundManager sharedInstance].playCommentId &&
        self.commentId &&
        [self.commentId isKindOfClass:[NSString class]] &&
        [[SNSoundManager sharedInstance].playCommentId isKindOfClass:[NSString class]]) {
        if ([[SNSoundManager sharedInstance].playCommentId isEqualToString:self.commentId]) {
            isSame = YES;
        }else{
            isSame = NO;
        }
    } else {
        isSame = NO;
        if (![SNSoundManager sharedInstance].playCommentId &&
            !self.commentId) {
            isSame = YES;
        }
    }
    return isSame;
}

- (void)setUrl:(NSString *)url_ {
    if (self.soundUrl != url_) {
        self.soundUrl = nil;
        self.soundUrl = url_;
    }
    
    if (self.soundUrl.length > 0) {
        SNSoundStatusType status = [[SNSoundManager sharedInstance] statusForSoundUrl:self.soundUrl];
        if (status == SNSoundStatusPlaying && ![self isSameCommentId]) {
            status = SNSoundStatusDefault;
        }
        [self setStatus:status commentId:self.commentId];
    }
}

- (void)setStatus:(SNSoundStatusType)status commentId:(NSString *)commentId
{
    if (_status == status) {
        return;
    }
    _status = status;
    switch (status) {
        case SNSoundStatusDefault:
            if ([NSThread isMainThread]) {
                if (commentId && commentId.length > 0) {
                    [self.webView callJavaScript:[NSString stringWithFormat:@"onAudioStateChanged(%@,'%@')", [NSNumber numberWithInt:2], commentId] forKey:nil callBack:nil];
                }
                for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
                    if ([_videoPlayer getMoviePlayer].isInAdvertMode) {
                        [_videoPlayer playActiveVideo];
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (commentId && commentId.length > 0) {
                        [self.webView callJavaScript:[NSString stringWithFormat:@"onAudioStateChanged(%@,'%@')", [NSNumber numberWithInt:2], commentId] forKey:nil callBack:nil];
                    }
                    for (SNH5NewsVideoPlayer *_videoPlayer in _videoPlayers) {
                        if ([_videoPlayer getMoviePlayer].isInAdvertMode) {
                            [_videoPlayer playActiveVideo];
                        }
                    }
                });
            }
            break;
        case SNSoundStatusPlaying:
            if ([NSThread isMainThread]) {
                if (commentId && commentId.length > 0) {
                    [self.webView callJavaScript:[NSString stringWithFormat:@"onAudioStateChanged(%@,'%@')", [NSNumber numberWithInt:1], commentId] forKey:nil callBack:nil];
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (commentId && commentId.length > 0) {
                        [self.webView callJavaScript:[NSString stringWithFormat:@"onAudioStateChanged(%@,'%@')", [NSNumber numberWithInt:1], commentId] forKey:nil callBack:nil];
                    }
                });
            }
            break;
        case SNSoundStatusDownloading:
            if ([NSThread isMainThread]) {
                if (commentId && commentId.length > 0) {
                    [self.webView callJavaScript:[NSString stringWithFormat:@"onAudioStateChanged(%@,'%@')", [NSNumber numberWithInt:2], commentId] forKey:nil callBack:nil];
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (commentId && commentId.length > 0) {
                        [self.webView callJavaScript:[NSString stringWithFormat:@"onAudioStateChanged(%@,'%@')", [NSNumber numberWithInt:2], commentId] forKey:nil callBack:nil];
                    }
                });
            }
            break;
        case SNSoundStatusDownloadFailed:
            if ([NSThread isMainThread]) {
                if (commentId && commentId.length > 0) {
                    [self.webView callJavaScript:[NSString stringWithFormat:@"onAudioStateChanged(%@,'%@')", [NSNumber numberWithInt:3], commentId] forKey:nil callBack:nil];
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (commentId && commentId.length > 0) {
                        [self.webView callJavaScript:[NSString stringWithFormat:@"onAudioStateChanged(%@,'%@')", [NSNumber numberWithInt:3], commentId] forKey:nil callBack:nil];
                    }
                });
            }
            break;
        default:
            break;
    }
}

- (void)onSoundDownloaded:(NSNotification *)notification {
    if (self.soundUrl) {
        SNSoundItem *nextToPlayItem = [SNSoundManager sharedInstance].sndItemNextToPlay;
        if (nextToPlayItem && [nextToPlayItem.url isEqualToString:self.soundUrl] && [self isSameCommentId]) {
            NSDictionary* userInfo = (NSDictionary*)notification.object;
            
            NSString *tag = [[TTURLCache sharedCache] keyForURL:self.soundUrl];
            NSString *sndId = [NSString stringWithFormat:@"snd%@", tag];
            
            if ([sndId isEqualToString:[userInfo objectForKey:@"id"]]) {
                NSString *localPath = [SNSoundManager soundFileDownloadPathWithURL:self.soundUrl];
                if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                    SNSoundItem *sndItem = [[SNSoundItem alloc] init];
                    sndItem.url = _soundUrl;
                    sndItem.localPath = localPath;
                    SNDebugLog(@"onSoundDownloaded: %@, %@", self, localPath);
                    SNSoundStatusType sndStatus = [[SNSoundManager sharedInstance] statusForSoundItem:sndItem];
                    
                    BOOL bOK = NO;
                    if (sndStatus == SNSoundStatusPlaying) {
                        bOK = YES;
                    } else {
                        bOK = [[SNSoundManager sharedInstance] playSound:sndItem];
                    }
                    
                    if (bOK) {
                        [self setStatus:SNSoundStatusPlaying commentId:self.commentId];
                        [SNSoundManager sharedInstance].playCommentId = self.commentId;
                    } else {
                        [self setStatus:SNSoundStatusDefault commentId:self.commentId];
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"无法播放该音频" toUrl:nil mode:SNCenterToastModeWarning];
                    }
                } else {
                    [self setStatus:SNSoundStatusDownloadFailed commentId:self.commentId];
                    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"无网络连接，无法播放该音频" toUrl:nil mode:SNCenterToastModeWarning];
                    }
                }
            }
        }
    }
}

- (void)onSoundStatusChanged:(NSNotification *)notification {
    if (self.soundUrl) {
        if ([NSThread isMainThread]) {
            SNSoundStatusType sndStatus = [[SNSoundManager sharedInstance] statusForSoundUrl:self.soundUrl];
            if ([self isSameCommentId]) {
                [self setStatus:sndStatus commentId:self.commentId];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                SNSoundStatusType sndStatus = [[SNSoundManager sharedInstance] statusForSoundUrl:self.soundUrl];
                if ([self isSameCommentId]) {
                    [self setStatus:sndStatus commentId:self.commentId];
                }
            });
        }
    }
}

- (void)openShareFloatView {
    self.newsfrom = kPushShareNews;
    [self shareActionFromPostFollow];
}

- (void)handleEnterBackground {
    [SNNotificationManager removeObserver:self name:kFromPushOpenShareFloatViewNotification object:nil];
}

- (void)wifiNetWorkChanged:(NSNotification* )note {
    Reachability *curReach = [note object];
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    //如果网络切换，且为wifi
    if (status == ReachableViaWiFi) {
        [_webView callJavaScript:@"imgLoadingGo()" forKey:nil callBack:nil];
    }
}

- (void)backViewController {
    [_postFollow backViewController];
}

- (void)showRedPacketBtn{
    if (self.redPacketBtn == nil) {
        [self createRedPacketBtn];
    }
    
    SNAppConfigH5RedPacket *h5RedPacket = [SNAppConfigManager sharedInstance].configH5RedPacket;
    self.redPacketBtn.hidden = !h5RedPacket.redPacketFloatBtnIsShow;
}

- (void)createRedPacketBtn {
    int offsetY = [SNDevice sharedInstance].isPlus ? 3 : -4;
    self.redPacketBtn = [[UIButton alloc] initWithFrame:CGRectMake(kAppScreenWidth - 56, kAppScreenHeight - 107.0 - offsetY, 56, 57)];
    self.redPacketBtn.backgroundColor = [UIColor clearColor];
    [self.redPacketBtn addTarget:self action:@selector(gotoRedPacketDeatil) forControlEvents:UIControlEventTouchUpInside];
    [self updateRedPacketImage];
    [self.view addSubview:self.redPacketBtn];
    
    [SNRedPacketManager sharedInstance].isInArticleShowRedPacket = YES;
}

- (void)updateRedPacketImage {
    SNAppConfigH5RedPacket *h5RedPacket = [SNAppConfigManager sharedInstance].configH5RedPacket;
    NSURL *imageUrl = [NSURL URLWithString:h5RedPacket.redPacketPicUrl];
    [self.redPacketBtn sd_setImageWithURL:imageUrl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icohongbao_hbyu_v5.png"]];
    [self.redPacketBtn sd_setImageWithURL:imageUrl forState:UIControlStateHighlighted placeholderImage:[UIImage imageNamed:@"icohongbao_hbyu_v5.png"]];
}

- (void)gotoRedPacketDeatil {
    [SNUtility shouldUseSpreadAnimation:NO];
    [SNRedPacketManager showRedPacketActivityInfo];
}

- (void)setH5Type:(NSString *)h5Type h5Link:(NSString *)h5WebLink {
    [self jsKitStorageGetItem];
    if ([h5Type isEqualToString:@"0"]) {
        _h5Type = h5Type;
        [self loadRecommendNews];
        [_postFollow setH5WebType:SNPostFollowTypeBackAndCommentAndCollectionAndShare];
        if (_h5SubInfo) {
            [self addSubscribeWithInfo:_h5SubInfo];
        }
    } else {
        _h5Type = h5Type;
        _h5WebLink = h5WebLink;
        [_postFollow setH5WebType:SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh];
        self.webView.top = kSystemBarHeight + 44;
        self.webView.height = kAppScreenHeight - kSystemBarHeight - 44*2;
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            [self setWebviewNightModeView:YES];
        }
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:_h5WebLink] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0];
        [_webView loadRequest:req];
        isStartFresh = YES;
        
        [self loadCollectionNumRequest];
        
        [self loadOfficialAccountView];
        if (_h5SubInfo) {
            [_officialAccountsInfo h5UpdateWithJSON:_h5SubInfo];
        }
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=h5news_page&_tp=pv&channelid=%@&newsId=%@&newstype=8", self.channelId, self.newsId]];
    }
    [self addSwipeGesture];
}

- (void)loadCollectionNumRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [params setValue:self.gid.length > 1 ? @"3" : @"2" forKey:@"busiCode"];
    [params setValue:self.newsId forKey:@"id"];
    [params setValue:@"" forKey:@"cursorId"];
    [params setValue:[NSString stringWithFormat:@"%@",@"1"] forKey:@"rollType"];
    [params setValue:[NSString stringWithFormat:@"%@",@"1"] forKey:@"size"];
    [params setValue:@"news" forKey:@"source"];
    [params setValue:[NSString stringWithFormat:@"%@",@"3"] forKey:@"type"];
    [params setValue:[NSString stringWithFormat:@"%@",[self refererTypeFromNewsFrom:self.newsfrom]] forKey:@"refererType"];
    
    [[[SNCommentListByCursorRequest alloc] initWithDictionary:params
                                        needNetSafeParameters:NO] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:responseObject forKey:@"kRootData"];
            id rootData = [params objectForKey:@"kRootData"];
            if ([rootData objectForKey:@"isSuccess"] && [[rootData objectForKey:@"isSuccess"] isEqualToString:@"S"]) {
                id responseData = [rootData objectForKey:@"response"];
                NSString *collectionCount = [responseData stringValueForKey:kFavoriteCount defaultValue:nil];
                [self setCollectionNum:collectionCount.integerValue];
            } else {
                [self setCollectionNum:0];
            }
        } else {
            [self setCollectionNum:0];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self setCollectionNum:0];
    }];
}

///////////////////////////////////////////////////////////////////////////
//TODO:本期去掉 wangshun
#define SNNewsScreenShare_PopOverViewWidth ((kAppScreenWidth > 375) ? 900.0/3 : ((kAppScreenWidth == 320) ? 570.0/2 : 580.0/2))
#define SNNewsScreenShare_PopOverViewHeight ((kAppScreenWidth > 375) ? 182.0/3 : ((kAppScreenWidth == 320) ? 100.0/2 : 105.0/2))
#define SNNewsScreenShare_PopOverViewOriginX ((kAppScreenWidth > 375) ? (kAppScreenWidth - 20.0) : ((kAppScreenWidth == 320) ? (kAppScreenWidth - 28.0) : (kAppScreenWidth - 28.0)))

//截屏分享 弹窗 弹出一次
- (void)onlyOnceScreenSharePopOverView {
    //第二次显示这个 wangshun 二期需求
    NSString *s = [SNUserDefaults objectForKey:kFirstShowScreenShareKey2];
    if (s) {
        if ([s isEqualToString:@"1"]) {
            [SNUserDefaults setObject:@"2" forKey:kFirstShowScreenShareKey2];
            
            BOOL isPlus = [[SNDevice sharedInstance] isPlus];
            CGFloat f = 0;
            if (isPlus) {
                f = 10;
            }
            CGPoint point = CGPointMake(SNNewsScreenShare_PopOverViewOriginX-f, self.view.bounds.size.height - 44 - 68);
            CGSize size = CGSizeMake(SNNewsScreenShare_PopOverViewWidth, SNNewsScreenShare_PopOverViewHeight);
            
            if (self.popOverView == nil) {
                self.popOverView = [[SNPopoverView alloc] initWithDownTitle:kFirstShowScreenShareTitle Point:point size:size leftImageName:@"ico_homehand_v5.png"];
                [self.popOverView showView:self.view];
                [self performSelector:@selector(dismissPopOverView) withObject:nil afterDelay:2.0];
            }
        }
    } else {
        [SNUserDefaults setObject:@"1" forKey:kFirstShowScreenShareKey2];
    }
}

- (void)dismissPopOverView {
    [self.popOverView dismiss];
}

@end
