//
//  SNLiveRoomViewController.m
//  sohunews
//
//  Created by Chen Hong on 4/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNLiveRoomViewController.h"
#import "SNPostConmentRequest.h"
#import "SNThemeManager.h"
#import "NSDictionaryExtend.h"
#import "UIColor+ColorUtils.h"
#import "SNDBManager.h"
#import "SNLiveSubscribeService.h"
#import "SNStatusBarMessageCenter.h"
#import "SNHeadSelectView.h"
#import "SNActionMenuController.h"
#import "SNUserinfo.h"
#import "SNLiveBannerView.h"
#import "SNLiveBannerViewWithTitle.h"
#import "SNLiveBannerViewWithMatchInfo.h"
#import "SNLiveBannerViewWithMatchVideo.h"
#import "SNLiveBannerViewWithTitleVideo.h"
#import "SNSoundManager.h"
#import "Toast+UIView.h"
#import "SNLiveRoomTopInfoView.h"
#import "SNLoginRegisterViewController.h"
#import "AMRWBRecorder.h"
#import "NSDate-Utilities.h"
#import "SNLiveRecHUD.h"
#import "SNLiveFlowersFallView.h"
#import "NSObject+YAJL.h"
#import "SNTimelinePostService.h"
#import "SNLiveRoomContentCellVideoCache.h"
#import "SNGuideRegisterManager.h"
#import "SNActionSheet.h"
#import "SNLiveInviteModel.h"
#import "SNDatabase+LiveInvite.h"
#import "SNBubbleBadgeObject.h"
#import "SNNotificaitonTableController.h" //从消息中心通知table返回时需要查询邀请状态
#import "SNImagePickerController.h"
#import "SNUserManager.h"
#import "SNLiveRoomConsts.h"
#import "SNWindow.h"
#import "SNBaseEditorViewController.h"
#import "SNUserManager.h"
#import "SNLiveRoomContentVideoPlayerView.h"
#import "SNVideoObjects.h"
#import "WSMVVideoHelper.h"
#import "SNShareConfigs.h"
#import "SNPreference.h"
#import "SNLiveWebController.h"
#import "WSMVVideoStatisticModel.h"
#import "WSMVVideoStatisticManager.h"
#import "SNVideoAdContext.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNNewsExposureManager.h"
#import "SNLiveSurportRequest.h"
#import "SNAdvertiseManager.h"
#import "SNAdDataCarrier.h"
#import "SNRollingNewsPublicManager.h"
#import "SNNewAlertView.h"
#import "SNLiveRoomAdvertisingBannerView.h"
#import "SNNewsUninterestedService.h"
#import "SNLiveInfoRequest.h"
#import "SNADReport.h"
#import "SNAdManager.h"
#import "SNNewsShareManager.h"
#define GRAY(c) [UIColor colorWithRed:(c&0xFF)/255.0 green:(c&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

#define MATCH_INFO_VIEW_HEIGHT (252/2 + kHeadBottomHeight)
#define MATCH_INFO_VIEW_SCROLLED_HEIGHT (108.0 / 2 + kHeadBottomHeight)
#define MATCH_TITLE_VIEW_HEIGHT (122.0 / 2 + kHeadBottomHeight)
#define SWITCH_VIWE_HEIGHT (98/2)

#define REFRESH_TIMER_INTERVAL 45
#define REFRESH_TIMER_INTERVAL_30 30

#define MAX_REC_TIME_DUR 60
#define kCancelOriginY          ([[UIScreen mainScreen]bounds].size.height-100)

//#define kTopicUpHost                    (@"upHost")
//#define kTopicUpVisit                   (@"upVisit")
#define kTableViewAnimationDuration     (0.5)

//#define kTopicPostComment               (@"postComment")
//#define kTopicLiveInfo                  (@"liveInfo")

#define kInputBarH          (49 + 40)
#define kEmptyViewTag       (1001)
#define kErrorViewTag       (1002)
#define kImageViewTag       (1003)
#define kDownloadBtnTag     (1004)
#define kLiveInviteAlertTag (1007)
#define kLiveMsgInfoViewTag (1008)

#define kReplyInfoViewOffset (6)

#define kCode @"code"
static const int kRechabilityChangedActionSheetTag = 10000;

#define TEST_LIVEID @"6900"  //6900 视频 6877 音频 6953 评论图片

#define BANNER_ADVERTISING  (1)

@interface SNLiveRoomViewController ()<SNLiveInviteModelDelegate, SNEmoticonScrollViewDelegate> {
    SNLiveRoomTableViewController *_liveTableViewController;//实况直播
    SNLiveRoomTableViewController *_chatTableViewController;//边看边聊
    SNLiveWebController *_statisticsWebController;//h5数据统计
    
    UIScrollView *_scrollView;
    SNActionMenuController *_actionMenuController;
    SNLiveContentMatchInfoObject *_infoObject;
    SNLiveInviteModel *_inviteModel;
    
    SNEmbededActivityIndicatorEx *_loadingView;
    
    UIView   *_imageDetailView;
    NSString *_liveId;
    NSTimer  *_refreshTimer;
    NSString *_shareComment;
    UIImage  *_selectedImage;
    
    BOOL _bNeedRefreshLiveInfo;
    BOOL _bHasSubscribed;
    BOOL _bLiveVideoHasStarted;
    BOOL _bViewDisappeared;
    
    UIView *_maskViewForKeyBoard;
    SNLiveToolbar *_toolbar;
    SNLiveInputBar *_inputbar;
    SNPicInputView *_picInputView;
    SNEmoticonTabView *_emoInputView;
    NSString *_contentText;
    
//    ASIFormDataRequest *_postCommentRequest;
    
    AMRWBRecorder     *_recorder;
    NSTimer           *_updateTimer;
    SNLiveRecHUD      *_hud;
    SNLiveFlowersFallView *_flowersFallView;
    
    int _lastMsgCount;
    
    UIView *_replyInfoView;
    CGPoint curTouchPoint;//触摸点
    BOOL canNotSend;//不能发送
    
    //输入框展开位于键盘顶部或选取图片view顶部
    BOOL _bInputBarOnTop;
    
    //记录当前mediaType, 如果有更新，则重置banner，处理图文与视频类型的切换
    BOOL _isMediaLiveMode;
    
    BOOL _isTopInfoExposured;//记录置顶曝光
    
    SNLiveRoomContentVideoPlayerView *_shortVideoPlayer;
    
    NSString *_fromClassStr;
    
    LiveTableEnum _liveTableTypeArray[kTableTabCount];
    
    BOOL _isFirstLiveInfo;
    BOOL _hasInviteStatusRequested;
    
    BOOL _exitFullScreenAutomatially;
    BOOL _needRefreshInviteStatusWhenLoginSucceed;
    double  _startTime;
    
    NSString * _fromChannelId;
}

@property (nonatomic,strong) SNActionMenuController *actionMenuController;
@property (nonatomic, copy) NSString *shareComment;
@property (nonatomic, copy) NSString *shareCommentImageUrl;
@property (nonatomic, strong) SNLiveRoomTopInfoView *topInfoView;
@property (nonatomic, strong) SNLiveRoomAdvertisingBannerView *advertisingBannerView;
@property (nonatomic, strong) SNVideoData                     *cellVideoModel;
@property (nonatomic, strong) SNLiveRoomContentCell           *playingVideoCell;
@property (nonatomic, strong) SNLiveRoomBaseObject            *playingVideoCellModel;
@property (nonatomic, strong) SNLiveRoomTableViewController   *playingCellVideoTableViewController;
@property (nonatomic, strong) SNActionSheet *networkStatusActionSheet;

@property (nonatomic, strong) SNAdDataCarrier *sdkAdSponsorShip; //直播冠名广告
@property (nonatomic, strong) SNAdLiveInfo *adBannerInfo;
@property (nonatomic, strong) SNNewsShareManager *shareManager;
@property (nonatomic, assign) BOOL isShowKeyBoard;//区分评论时是否显示键盘

- (void)resetBannerView;

@end

@implementation SNLiveRoomViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super init];
    if (self) {
        
        _fromChannelId = [query objectForKey:kCurrentChannelId] ? : @"";
        
        id obj = [query objectForKey:kLiveGameItem];
        if (obj) {
            self.livingGameItem = obj;
            _infoObject = [[SNLiveContentMatchInfoObject alloc] init];
            [_infoObject updateByLiveGameItem:obj];
            
            _liveId = [self.livingGameItem.liveId copy];//TEST_LIVEID;//
            _bNeedRefreshLiveInfo = YES;
        } else {
            if (_liveId.length == 0) {
                NSString *liveId = [query objectForKey:kLiveIdKey];
                _liveId = [liveId copy];//TEST_LIVEID;//
                
                NSString *liveType = [query objectForKey:kLiveTypeKey];
                _bNeedRefreshLiveInfo = YES;
                
                LivingGameItem *gameItem = [[SNDBManager currentDataBase] getLiveItemByLiveId:_liveId];
                if (gameItem) {
                    self.livingGameItem = gameItem;
                }
                else {
                    self.livingGameItem = [[LivingGameItem alloc] init];
                    self.livingGameItem.liveId = _liveId;
                    self.livingGameItem.liveType = liveType;
                }
                // 比赛信息缺省值
                _infoObject = [[SNLiveContentMatchInfoObject alloc] init];
                _infoObject.homeTeamTitle       = @"";
                _infoObject.visitingTeamTitle   = @"";
                _infoObject.homeTeamScore       = @"0";
                _infoObject.visitingTeamScore   = @"0";
                _infoObject.homeTeamIconURL     = nil;
                _infoObject.visitingTeamIconURL = nil;
                _infoObject.matchTitle          = @"";
                _infoObject.liveTime            = @"";
                _infoObject.liveType            = liveType;
            }
        }
        
        _bHasSubscribed = [[SNLiveSubscribeService sharedInstance] hasLiveGameSubscribed:_liveId];
        
        // 邀请
        _inviteModel = [[SNLiveInviteModel alloc] init];
        _inviteModel.delegate = self;
        
        _fromClassStr = [[query stringValueForKey:@"from" defaultValue:nil] copy];
        _newsfrom = [[query stringValueForKey:kNewsFrom defaultValue:kOtherNews] copy];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(audioStartNotification:)
                                                     name:kAudioStartNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleBannerVideoDidPlayNotification:)
                                                     name:kBannerVideoDidPlayNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleClickAudioViewInLiveCellNotification:)
                                                     name:kSNClickAudioViewInLiveCellNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleEnterBackgroundNotification)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(openShareFloatView) name:kFromPushOpenShareFloatViewNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(WillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        
		self.hidesBottomBarWhenPushed = YES;
        
        if (query) {
            self.queryDic = [NSMutableDictionary dictionaryWithDictionary:query];
        }
        
        if ([[query objectForKey:kNewsExpressType] intValue] == 1){
            self.isPush = YES;
        }
    }
    
    return self;
}

- (SNCCPVPage)currentPage {
    return live;
}

- (NSString *)currentOpenLink2Url {
    NSString *defaultLink = [NSString stringWithFormat:@"live://liveId=%@", _liveId];
    return [self.queryDic stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:defaultLink];
}

- (void)WillResignActive
{
    [[SNSoundManager sharedInstance] stopAll];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    [self resetShortVideoPlayer];
    if (_shortVideoPlayer) {
        _shortVideoPlayer.delegate = nil;
    }

    TT_INVALIDATE_TIMER(_refreshTimer);
    _inviteModel.delegate = nil;
    _topInfoView.delegate = nil;
    _liveTableViewController.parentController = nil;
    _chatTableViewController.parentController = nil;
    _actionMenuController.delegate = nil;
    _sdkAdSponsorShip.delegate = nil;
    if (_recorder) {
        _recorder->SetDelegate(nil);
        delete _recorder;
        _recorder = NULL;
    }
    if (_updateTimer) {
        [_updateTimer invalidate];
    }
}

- (void)layoutTableView {
    int tabIndex = 0;
    CGFloat tableTop, tableHeight;
    int advertisingH = 0;
    
    if ([self.adBannerInfo isValid] &&
        nil != _advertisingBannerView) {
        advertisingH = (_advertisingBannerView.height > 0) ? (_advertisingBannerView.height + 8 + 8) : (0);
    }
    
    if (self.topInfoView && self.topInfoView.alpha == 1) {
        if (self.topInfoView.hasExpanded) {
            [_liveTableViewController removeTableHeader];
            tableTop = self.topInfoView.bottom;
        } else {
            float tableHeaderH = 12;
            [_liveTableViewController addTableHeader:tableHeaderH];
            tableTop = self.liveBannerView.bottom - 6 + advertisingH;
        }
        tableHeight = kAppScreenHeight - tableTop - kToolbarViewTop;
        _liveTableViewController.view.frame = CGRectMake(0,
                                                         tableTop,
                                                         kAppScreenWidth,
                                                         tableHeight);
    } else {
        float tableHeaderH = 6;
        [_liveTableViewController addTableHeader:tableHeaderH];
        
        tableTop = self.liveBannerView.bottom - tableHeaderH + advertisingH;
        tableHeight = kAppScreenHeight - tableTop - kToolbarViewTop;
        _liveTableViewController.view.frame = CGRectMake(0,
                                                         tableTop,
                                                         kAppScreenWidth,
                                                         tableHeight);
    }
    _liveTableTypeArray[tabIndex++] = kLiveTableTab;
    
    float chatTableHeaderH = 6;
    [_chatTableViewController addTableHeader:chatTableHeaderH];
    CGFloat chatTableTop = self.liveBannerView.bottom - chatTableHeaderH + advertisingH;
    CGFloat chatTableHeight = kAppScreenHeight - chatTableTop - kToolbarViewTop;
    
    _chatTableViewController.view.frame = CGRectMake(_liveTableViewController.view.right, chatTableTop, kAppScreenWidth, chatTableHeight);
    _liveTableTypeArray[tabIndex++] = kChatTableTab;
    
    float left = _chatTableViewController.view.right;
    if (_statisticsWebController) {
        _statisticsWebController.view.frame = CGRectMake(left,
                                                         chatTableTop,
                                                         kAppScreenWidth,
                                                         chatTableHeight);
        _liveTableTypeArray[tabIndex++] = kStatTableTab;
    }
}

- (void)layoutTableView:(CGFloat)fromHeight toHeight:(CGFloat)toHeight {
    NSInteger y = 0;
    NSInteger advertisingH = (_advertisingBannerView.height > 0) ?(_advertisingBannerView.height + 8 + 8) : (0);
    
    if (self.topInfoView.hasExpanded) {
        y = self.liveBannerView.bottom + 8;
        if([self.adBannerInfo isValid] && nil != _advertisingBannerView){
            y = self.liveBannerView.bottom + 8 + advertisingH;
        }
    } else {
        y = self.liveBannerView.bottom;
        if ([self.adBannerInfo isValid] && nil != _advertisingBannerView){
            y = self.liveBannerView.bottom + advertisingH;
        }
    }
    
    self.topInfoView.frame = CGRectMake(self.liveBannerView.centerX - self.topInfoView.width / 2, y, self.topInfoView.width, toHeight);
    [self layoutTableView];
}

//李健 2015.03.31 直播间广告
//当用户关闭广告后, 上传用户ID参数, 12小时内该用户打开不再出现此条广告。当用户退出直播间, 再次进入时显示广告池中的广告, 若广告池中没有可以替换的广告则不再显示。
//NSString *url = @"http://gma.alicdn.com/bao/uploaded/i1/16391072247818708/TB2SGbRcXXXXXXNXpXXXXXXXXXX_!!26986391-0-saturn_solar.jpg_640x640.jpg";
- (void)layoutAdvertisingView {
    if ([self.adBannerInfo isValid] &&
        nil != _advertisingBannerView) {
        if (YES == _advertisingBannerView.hidden) {
            return;
        }
        //曝光
        [SNADReport reportExposure:self.adBannerInfo.reportID];
        _advertisingBannerView.frame = CGRectMake(10, self.liveBannerView.bottom + 8, kAppScreenWidth - 20, (CGFloat)((kAppScreenWidth - 20) / 6.4));
        _advertisingBannerView.alpha = themeImageAlphaValue();

        __weak typeof(self) weakSelf = self;
        __weak typeof(_advertisingBannerView) weakBannerView = _advertisingBannerView;
        [_advertisingBannerView loadUrlPath:self.adBannerInfo.imgUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [weakBannerView closeAdvetising:^{
                [UIView animateWithDuration:0.3f animations:^{
                    weakBannerView.top = weakSelf.liveBannerView.bottom;
                    weakBannerView.height = 0;
                    weakBannerView.alpha = 0.2;
                    [weakSelf layoutLiveInfoView];
                } completion:^(BOOL finished) {
                    [weakBannerView removeFromSuperview];
                    weakBannerView.hidden = YES;
                    [SNADReport reportUninteresting:weakSelf.adBannerInfo.reportID];
                }];
            }];
        }];
    }
}

- (void)layoutLiveInfoView {
    NSInteger advertisingH = (_advertisingBannerView.height > 0) ?(_advertisingBannerView.height + 8 + 8) : (0);
    if (self.topInfoView.hasExpanded) {
        if ([self.adBannerInfo isValid] && nil != _advertisingBannerView) {
            self.topInfoView.top = self.liveBannerView.bottom + 8 + advertisingH;
        } else {
            self.topInfoView.top = self.liveBannerView.bottom + 8;
        }
    } else {
        if ([self.adBannerInfo isValid] && nil != _advertisingBannerView) {
            self.topInfoView.top = self.liveBannerView.bottom + advertisingH;
        } else {
            self.topInfoView.top = self.liveBannerView.bottom;
        }
    }
    
    self.topInfoView.centerX = self.liveBannerView.centerX;
    
    [self layoutTableView];
}

- (void)customerViewBg {
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

- (void)initPostFollow {
    if (!_toolbar) {
        _toolbar = [[SNLiveToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 49, self.view.width, 49)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        _toolbar.delegate = self;
        
        BOOL recMode = [[NSUserDefaults standardUserDefaults] integerForKey:kLiveRoomInputModeKey] != 0;
        [_toolbar setupWithStatBtn:NO recMode:recMode];
        [self.view addSubview:_toolbar];
        
        
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            UIView *iphonexBg = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.height - 20, self.view.width, 20)];
            iphonexBg.backgroundColor = GRAY(0xea);
            [self.view addSubview:iphonexBg];
            
            _toolbar.frame = CGRectMake(0, self.view.height - 49- iphonexBg.frame.size.height, self.view.width, 49);
        }
    }
    
    if (!_inputbar) {
        _inputbar = [[SNLiveInputBar alloc] initWithFrame:CGRectMake(0, self.view.height - kInputBarH, self.view.width, kInputBarH)];
        _inputbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _inputbar.delegate = self;
        [self.view addSubview:_inputbar];
        _inputbar.hidden = YES;
    }
    
    if (_selectedImage) {
        [_inputbar setInputImage:_selectedImage];
    }
    
    if (_contentText!=nil) {
        [_inputbar setContent:_contentText];
    }
    
    if (!_picInputView) {
        _picInputView = [[SNPicInputView alloc] initWithFrame:kCommentInputViewRect];
        _picInputView.pickerDelegate = self;
        _picInputView.top = _inputbar.bottom;
        _picInputView.hidden = YES;
        [self.view addSubview:_picInputView];
    }
    
    if (!_emoInputView) {
        _emoInputView = [[SNEmoticonTabView alloc] initWithType:SNEmoticonConfigLive frame:kCommentInputViewRect];
        _emoInputView.top = _inputbar.bottom;
        _emoInputView.hidden = YES;
        _emoInputView.delegate = self;
        [self.view addSubview:_emoInputView];
    }
    
    return;
}

- (void)createTableView {
    int tabCnt = kTableTabCount;
    _liveTableViewController = [[SNLiveRoomTableViewController alloc] initWithMatchInfoObj:_infoObject livingGameItem:self.livingGameItem mode:LIVE_MODE];
    _liveTableViewController.parentController = self;
    
    _chatTableViewController = [[SNLiveRoomTableViewController alloc] initWithMatchInfoObj:_infoObject livingGameItem:self.livingGameItem mode:CHAT_MODE];
    _chatTableViewController.parentController = self;
    
    if ([_infoObject hasH5Statistics]) {
        _statisticsWebController = [[SNLiveWebController alloc] init];
    } else {
        tabCnt -= 1;
    }
    
    [_scrollView addSubview:_liveTableViewController.view];
    [_scrollView addSubview:_chatTableViewController.view];
    if (_statisticsWebController) {
        [_scrollView addSubview:_statisticsWebController.view];
    }
    
    _scrollView.contentSize = CGSizeMake(kAppScreenWidth * tabCnt,
                                         kAppScreenHeight);
    
    _chatTableViewController.tableView.scrollsToTop = NO;
    _liveTableViewController.tableView.scrollsToTop = YES;
    _statisticsWebController.scrollView.scrollsToTop = NO;
    
    [self hideLoading];
    
    [self layoutAdvertisingView];
    [self layoutLiveInfoView];
}

- (void)loadView {
    [super loadView];
    self.view.frame = CGRectMake(0.f, 0.f, kAppScreenWidth, kAppScreenHeight);
    
    [self customerViewBg];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.contentSize = CGSizeMake(kAppScreenWidth * kTableTabCount, kAppScreenHeight);
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    
    [self.view addSubview:_scrollView];
    
    [SNNotificationManager addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    
    NSString *name = [NSString stringWithFormat:@"%@_%@", kLiveContentModelInfoChanged, _liveId];
    [SNNotificationManager addObserver:self
                                             selector:@selector(onModelInfoChanged)
                                                 name:name
                                               object:nil];
    
    name = [NSString stringWithFormat:@"%@_%@", kLiveRefreshModelInfo, _liveId];
    [SNNotificationManager addObserver:self
                                             selector:@selector(onRefreshModelInfoNotification)
                                                 name:name
                                               object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(playerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(didReceiveNotification:)
                                                 name:kNotifyDidReceive
                                               object:nil];
    [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
    
    
    if (_bNeedRefreshLiveInfo) {
        [self showLoading];
        [self performSelector:@selector(refreshLiveInfo) withObject:nil afterDelay:0.01];
    }
    // 如果不需要刷新live info 则说明之前刷新过, 直接创建比赛面板
    else {
        [self createTableView];
        [self resetBannerView];
    }
    
    [self initPostFollow];
    
    if (_bInputBarOnTop) {
        [self focusInput];
    } else {
        if (_replyId.length && _replyName.length) {
            [self addReplyInfoView:_replyName];
        }
    }
}

-(void)updateTheme:(NSNotification *)notifiction {
    [self customerViewBg];
    [_toolbar updateTheme];
    [_inputbar updateTheme];
    [_picInputView updateTheme];
    [self.liveBannerView updateTheme];
    self.liveBannerView.alpha = themeImageAlphaValue();
    [_topInfoView updateTheme];
    
    if (_advertisingBannerView) {
        _advertisingBannerView.alpha = themeImageAlphaValue();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _recorder = new AMRWBRecorder();
    _recorder->SetDelegate(self);
}

- (void)clearMyCommentByClickCloseBtn {
    [self clearMyComment];
    [self maskViewDidTapped:nil];
}

- (void)clearMyComment {
    [self resetReplyParameters];
    [_inputbar setPlaceHolder:nil];
    [_inputbar setInputImage:nil];
    [self removeReplyInfoView];
}

- (void)resetReplyParameters {
    self.replyId = nil;
    self.replyPid = nil;
    self.replyType = nil;
    self.replyName = nil;
}

- (void)clearReply {
    [self removeReplyInfoView];
}

- (void)clearMyAudioComment {
    [self removeReplyInfoView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_liveTableViewController viewWillAppear:animated];
    [_chatTableViewController viewWillAppear:animated];
    _bViewDisappeared = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_liveTableViewController viewWillDisappear:animated];
    [_chatTableViewController viewWillDisappear:animated];
    
    [_liveBannerView stopVideo];
    self.liveBannerView.isVisible = NO;
    [self resetShortVideoPlayer];
    
    [SNNotificationManager removeObserver:self name:UIKeyboardWillShowNotification object:nil];

    [SNNotificationManager removeObserver:self name:kSNLiveInviteNotification object:nil];
    [SNNotificationManager removeObserver:self name:kSNBubbleBadgeChangeNotification object:nil];
    
    _bViewDisappeared = YES;
    
    if (_recorder && _recorder->IsRunning()) {
        [self stopRecord];
    }
    
    [self dismissActionSheet];
    
    [[NSUserDefaults standardUserDefaults] setInteger:([_toolbar isRecMode] ? 1 : 0) forKey:kLiveRoomInputModeKey];
    
    if (self.liveBannerView.isWorldCup) {
        [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:NO];
    }
    if (_inputbar) {
        [_inputbar resignFocus];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_liveTableViewController viewDidAppear:animated];
    [_chatTableViewController viewDidAppear:animated];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleInviteMessage:)
                                                 name:kSNLiveInviteNotification object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(onBubbleMessageChange)
                                                 name:kSNBubbleBadgeChangeNotification object:nil];
    
    [self updateStatusBarStyle];
    
    // 如果之前视频在播放 这里要让视频继续
    if (_bLiveVideoHasStarted && self.liveBannerView)
        [self.liveBannerView playVideo];
    
    // 从h5直播邀请打开直播间，如果未登录，提示登录，登录成功后再请求主持人绑定状态
    if (_needRefreshInviteStatusWhenLoginSucceed) {
        _needRefreshInviteStatusWhenLoginSucceed = NO;
        
        NSString *passport = [SNUserManager getUserId];
        if (passport.length > 0) {
            [self refreshLiveInviteStatus];
        }
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_newsfrom) {
        [dict setValue:_newsfrom forKey:kNewsFrom];
    }
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController dictInfo:dict];
    
    self.liveBannerView.isVisible = YES;
    _startTime = [[NSDate date] timeIntervalSince1970];
    [SNNewsReport shareInstance].startTime = _startTime;//进入直播间打卡
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimerAndSound];
    [self reportStayDuration];
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval stime  = currentTime - [[SNNewsReport shareInstance] startTime];
    [SNNewsReport reportADotGif:[NSString stringWithFormat:kLiveRoomDuration, self.liveId, stime, [SNUtility getCurrentChannelId]]];
}

- (void)reportStayDuration {
    double endTime = [[NSDate date] timeIntervalSince1970];
    double interval = endTime - _startTime;
    NSString *url = [NSString stringWithFormat:@"objType=n_stay_second&stayfrom=live&liveId=%@&stays=%f",_liveId, interval];
    [SNNewsReport reportADotGif:url];
}

- (void)onModelInfoChanged {
    [self onLiveInfoRefreshed:nil];
}

- (void)onRefreshModelInfoNotification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshLiveInfo) object:nil];
    [self performSelector:@selector(refreshLiveInfo) withObject:nil afterDelay:1];
}

// 播视频停音频
- (void)playerPlaybackStateDidChange:(NSNotification *)notification {
    MPMoviePlayerController* moviePlayerObj = [notification object];
    if (moviePlayerObj.playbackState == MPMoviePlaybackStatePlaying) {
        [[SNSoundManager sharedInstance] stopAll];
        [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
    }
}

// 播正文音频停直播间音频
- (void)audioStartNotification:(NSNotification *)notification {
    [[SNSoundManager sharedInstance] stopAll];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
}

// 收到推送
- (void)didReceiveNotification:(id)sender {
    [[SNSoundManager sharedInstance] stopAll];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
}

- (void)onLiveInfoRefreshed:(NSDictionary *)info {
    if (info) {
        [_infoObject updateByLiveInfoDictonary:info];
        // 分享阅读圈 解析shareRead字段 by jojo
        NSDictionary *shareReadDic = [info dictionaryValueForKey:@"shareRead" defalutValue:nil];
        if (shareReadDic) {
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareReadDic];
            if (obj) [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypeLive contentId:_liveId];
        }
    }
    
    if (_chatTableViewController == nil) {
        [self createTableView];
    }
    
    // 图文、视频类型切换
    BOOL needUpdateMediaMode = (_isMediaLiveMode != [_infoObject isMediaLiveMode]);
    
    if (_bNeedRefreshLiveInfo || needUpdateMediaMode) {
        // 如果存在老的比赛面板 移除之 创建新的
        [self resetBannerView];
        _bNeedRefreshLiveInfo = NO;
        _isMediaLiveMode = [_infoObject isMediaLiveMode];
    } else {
        // 刷新置顶
        if (_infoObject.top &&
            (_infoObject.top.top.length + _infoObject.top.topImage.length > 0)) {
            if (!(self.topInfoView && self.topInfoView.superview)) {
                // top 无->有
                if (!_isTopInfoExposured) {
                    [self topInfoExposure];
                }
                
                [self resetBannerView];
            } else {
                // top 更新内容
                if (![self.topInfoView.topObj isEqual:_infoObject.top]) {
                    self.topInfoView.topObj = _infoObject.top;
                    [self topInfoExposure];
                    [self layoutAdvertisingView];
                    [self layoutLiveInfoView];
                }
            }
        } else {
            if (self.topInfoView && self.topInfoView.superview) {
                // top 有->无
                [self resetBannerView];
            }
        }
    }
    
    // refresh
    self.liveBannerView.infoObj = _infoObject;
    
    [self refreshPostFollowBtns];
    
    self.livingGameItem.hostPic     = _infoObject.homeTeamIconURL;
    self.livingGameItem.visitorPic  = _infoObject.visitingTeamIconURL;
    self.livingGameItem.hostTotal   = _infoObject.homeTeamScore;
    self.livingGameItem.visitorTotal = _infoObject.visitingTeamScore;
    self.livingGameItem.status      = _infoObject.liveStatus;
    self.livingGameItem.pubType     = _infoObject.pubType;
    
    [[SNDBManager currentDataBase] updateLivingGame:self.livingGameItem];
}

- (void)refreshPostFollowBtns {
    BOOL bRecMode = _toolbar.isRecMode;
    if (_isFirstLiveInfo) {
        if (_infoObject.ctrlInfo.inputShowType == LiveInputRec && [self liveToolBarCanRec:NO]) {
            bRecMode = YES;
        }
        
        if (self.liveBannerView.isWorldCup) {
            [_toolbar setPlaceholderForWorldCup];
        }
        
        _isFirstLiveInfo = NO;
    }
    
    if ([SNAPI isWebURL:_infoObject.liveStatistics] ||
        [_infoObject.statisticsType intValue] == 1) {
        if (!_toolbar.hasStatBtn || bRecMode != _toolbar.isRecMode) {
            [_toolbar setupWithStatBtn:YES recMode:bRecMode];
        }
    } else {
        if (_toolbar.hasStatBtn || bRecMode != _toolbar.isRecMode) {
            [_toolbar setupWithStatBtn:NO recMode:bRecMode];
        }
    }
}

- (void)stopTimerAndSound {
    // 停止定时器
    [_flowersFallView stopTimer];
    [_liveTableViewController destroyTimer];
    [_chatTableViewController destroyTimer];
    
    [[SNSoundManager sharedInstance] stopAll];
    [[SNSoundManager sharedInstance] cancelAllDownloads];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self stopTimerAndSound];
    }
}

- (void)onBack:(id)sender {
    [self performSelector:@selector(stopTimerAndSound)
               withObject:nil afterDelay:0];
    if (self.isPush) {
        [SNUtility popViewToPreViewController];
    } else {
        [super onBack:sender];
    }
}

//#pragma mark - TTURLRequestDelegate
- (void)upHostSucc {
    SNDebugLog(@"upHostSucc");
}

- (void)upVisitSucc {
    SNDebugLog(@"upVisitSucc");
}
//
//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//    [request.delegates removeAllObjects];
//    if ([request.userInfo isKindOfClass:[TTUserInfo class]]) {
//        TTUserInfo *userInfo = request.userInfo;
//        SNURLJSONResponse *json = request.response;
//        if ([userInfo.topic isEqualToString:kTopicUpHost]) {
//            if (json && [json.rootObject isKindOfClass:[NSDictionary class]]) {
//                NSDictionary *dic = json.rootObject;
//                id obj = [dic objectForKey:@"result"];
//                if (obj && ([obj intValue] == 1)) {
//                    return [self upHostSucc];
//                }
//            }
//        } else if ([userInfo.topic isEqualToString:kTopicUpVisit]) {
//            if (json && [json.rootObject isKindOfClass:[NSDictionary class]]) {
//                NSDictionary *dic = json.rootObject;
//                id obj = [dic objectForKey:@"result"];
//                if (obj && ([obj intValue] == 1)) {
//                    return [self upVisitSucc];
//                }
//            }
//        } else if ([userInfo.topic isEqualToString:kTopicPostComment]) {
//            if (json && [json.rootObject isKindOfClass:[NSDictionary class]]) {
//                NSDictionary *dic = json.rootObject;
//                id obj = [dic objectForKey:@"result"];
//                if (obj && ([obj intValue] == 1)) {
//                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSent", @"messageSent") toUrl:nil mode:SNCenterToastModeSuccess];
//                    [SNUtility requestRedPackerAndCoupon:[_liveId URLEncodedString] type:@"3"];
//                    return;
//                }
//            }
//        } else if ([userInfo.topic isEqualToString:kTopicLiveInfo]) {
//            if (json && [json.rootObject isKindOfClass:[NSDictionary class]]) {
//                [self hideLoading];
//                NSDictionary *dic = json.rootObject;
//                SNDebugLog(@"liveInfo finishLoad: %@", dic);
//                
//                _isFirstLiveInfo = YES;
//                
//                //李健 2015.04.01 解析banner广告
//                NSDictionary *adInfo = [dic dictionaryValueForKey:@"adinfo" defalutValue:nil];
//                NSInteger reportID = [SNADReport parseLiveRoomStreamData:adInfo root:dic];
//                if (adInfo) {
//                    SNAdLiveInfo *info = [[SNAdLiveInfo alloc] initWithJsonDic:adInfo];
//                    //空广告
//                    if(nil == info){
//                        [SNADReport reportEmpty:reportID];
//                    }else{
//                        info.blockId = [dic stringValueForKey:@"blockId" defaultValue:@""];
//                        self.livingGameItem.blockId = [dic stringValueForKey:@"blockId" defaultValue:@""];
//                        if ([info isValid]) {
//                            self.adBannerInfo = info;
//                        }
//                        
//                        self.adBannerInfo.reportID = reportID;
//                        //加载
//                        [SNADReport reportLoad:self.adBannerInfo.reportID];
//                    }
//                }
//                [self onLiveInfoRefreshed:dic];
//                
//                if (!_bViewDisappeared) {
//                    [self updateStatusBarStyle];
//                }
//                
//                // 初始状态为收起
//                if (!self.liveBannerView.hasExpanded) {
//                    [self.liveBannerView doShrinkAnimation];
//                }
//                
//                // 刷新邀请状态
//                if (!_hasInviteStatusRequested) {
//                    [self refreshLiveInviteStatus];
//                    _hasInviteStatusRequested = YES;
//                }
//                
//                //解析广告
//                NSArray *adInfoControls = [dic arrayValueForKey:@"adControlInfos" defaultValue:nil];
//                if (adInfoControls) {
//                    NSMutableArray *parsedAdInfos = [NSMutableArray array];
//                    for (NSDictionary *adInfoDic in adInfoControls) {
//                        if ([adInfoDic isKindOfClass:[NSDictionary class]]) {
//                            SNAdControllInfo *adControlInfo = [[SNAdControllInfo alloc] initWithJsonDic:adInfoDic];
//                            [parsedAdInfos addObject:adControlInfo];
//                        }
//                    }
//                    
//                    if (parsedAdInfos.count > 0) {
//                        SNAdControllInfo *adCtrlInfo = parsedAdInfos[0];
//                        for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
//                            if (([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdLiveSponsorShip] ||
//                                 [adInfo.adSpaceId isEqualToString:kSNAdSpaceIdLiveSponsorShipTestServer]) &&
//                                !self.sdkAdSponsorShip) {
//                                //[adInfo.filterInfo setObject:_fromChannelId forKey:@"newschn"];
//                                self.sdkAdSponsorShip = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId adInfoParam:adInfo.filterInfo];
//                                self.sdkAdSponsorShip.delegate = self;
//                                self.sdkAdSponsorShip.appChannel = adInfo.appChannel;
//                                //self.sdkAdSponsorShip.newsChannel = _fromChannelId ? : adInfo.newsChannel;
//                                self.sdkAdSponsorShip.newsChannel = _fromChannelId ? : [adInfo.filterInfo objectForKey:@"newschn"];
//                                self.sdkAdSponsorShip.gbcode = adInfo.gbcode;
//                                self.sdkAdSponsorShip.adId = adInfo.adId;
//                                self.sdkAdSponsorShip.roomId = _liveId;
//                                [self.sdkAdSponsorShip refreshAdData:NO];
//                            }
//                        }
//                    }
//                }
//            } else {
//                [self showError];
//            }
//        }
//    }
//}
//
//- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
//    [request.delegates removeAllObjects];
//    if ([request.userInfo isKindOfClass:[TTUserInfo class]]) {
//        TTUserInfo *userInfo = request.userInfo;
//        if ([userInfo.topic isEqualToString:kTopicUpHost]) {
//        }
//        else if ([userInfo.topic isEqualToString:kTopicUpVisit]) {
//        }
//        else if ([userInfo.topic isEqualToString:kTopicPostComment]) {
//            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSendFailed", nil) toUrl:nil mode:SNCenterToastModeWarning];
//        }
//        else if ([userInfo.topic isEqualToString:kTopicLiveInfo]) {
//            [self showError];
//        }
//    }
//}

#pragma mark - SNHeadSelectViewDelegate
- (void)setScrollsToTopAtIndex:(int)index {
    LiveTableEnum type = _liveTableTypeArray[index];
    _chatTableViewController.tableView.scrollsToTop = (type == kChatTableTab);
    _liveTableViewController.tableView.scrollsToTop = (type == kLiveTableTab);
    _statisticsWebController.scrollView.scrollsToTop = (type == kStatTableTab);
}

- (void)headView:(SNHeadSelectView *)headView didSelectIndex:(int)index {
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    [_scrollView setContentOffset:CGPointMake(index * frame.size.width, 0)
                         animated:NO];
    [self setScrollsToTopAtIndex:index];
    [self hideKeyboard];
}

#pragma mark - SNLiveBannerViewDelegate
- (void)bannerIndexDidChanged:(int)index {
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    _scrollView.contentOffset = CGPointMake(index * frame.size.width, 0);
    _liveBannerView.currentIndex = index;
    
    [self setScrollsToTopAtIndex:index];
    
    [self hideKeyboard];
    
    if (_liveTableTypeArray[index] == kChatTableTab) {
        [self onLiveChatTabDidSelected];
    }
    
    // 推荐，数据统计tab隐藏toolbar上的按钮
    [self hideToolbarBtnsByIndex:index];
    
    if (_liveTableTypeArray[index] == kStatTableTab) {
        [_statisticsWebController openWithUrl:_infoObject.statisticsUrl];
    }
}

- (void)hideToolbarBtnsByIndex:(int)index {
    BOOL bHide = _liveTableTypeArray[index] != kLiveTableTab && _liveTableTypeArray[index] != kChatTableTab;
    [_toolbar hideAllBtns:bHide];
}

- (void)bannerIndexDidSelected:(int)selectIndex {
    if (selectIndex == _liveBannerView.currentIndex) {
        LiveTableEnum tableType = _liveTableTypeArray[selectIndex];
        if (tableType == kLiveTableTab) {
            [_liveTableViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else if (tableType == kChatTableTab) {
            [_chatTableViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else if (tableType == kStatTableTab) {
            [_statisticsWebController.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

- (void)bannerWillExpand {
    CGFloat bannerHeight = [_liveBannerView viewExpandHeight];
    [UIView animateWithDuration:0.3 animations:^{
        _liveBannerView.height = bannerHeight;
        if (_liveBannerView.hasVideo) {
            self.topInfoView.alpha = 0;
        }
        [self layoutAdvertisingView];
        [self layoutLiveInfoView];
    }];
    
    [self onliveBannerViewSizeChanged:f_expansion];
}

- (void)bannerWillShrink {
    CGFloat bannerHeight = [_liveBannerView viewShrinkHeight];
    [UIView animateWithDuration:0.3 animations:^{
        _liveBannerView.height = bannerHeight;
        if (_liveBannerView.hasVideo) {
            self.topInfoView.alpha = 1;
        }
        [self layoutAdvertisingView];
        [self layoutLiveInfoView];
    }];
    
    [self onliveBannerViewSizeChanged:f_shrink];
}

- (void)bannerTappedHostIcon {
    [self hideKeyboard];
    NSString *url = _liveTableViewController.infoObject.homeTeamInfoURL;
    if ([SNAPI isWebURL:url]) {
        [SNUtility openProtocolUrl:url];
    }
}

- (void)bannerTappedVisitIcon {
    [self hideKeyboard];
    
    NSString *url = _liveTableViewController.infoObject.visitingTeamInfoURL;
    if ([SNAPI isWebURL:url]) {
        [SNUtility openProtocolUrl:url];
    }
}

- (void)bannerTappedHostUp {
    [self hideKeyboard];
    
    if ([self.livingGameItem.reserveFlag intValue] & (1 << LiveGameFlagHasUp)) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您已经支持过了" toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        [self sendUpRequest:YES];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"支持成功！" toUrl:nil mode:SNCenterToastModeSuccess];
        
        int flag = [self.livingGameItem.reserveFlag intValue];
        flag |= 1 << LiveGameFlagHasUp;
        self.livingGameItem.reserveFlag = [NSString stringWithFormat:@"%d", flag];
        [[SNDBManager currentDataBase] updateLivingGame:self.livingGameItem];
        
        //支持数立即+1
        int n = [_infoObject.homeTeamSupportNum intValue];
        _infoObject.homeTeamSupportNum = [NSString stringWithFormat:@"%d", n + 1];
        if ([_liveBannerView respondsToSelector:@selector(setHostUp:)]) {
            [_liveBannerView performSelector:@selector(setHostUp:) withObject:_infoObject.homeTeamSupportNum];
        }
    }
}

- (void)bannerTappedVisitUp {
    [self hideKeyboard];
    
    if ([self.livingGameItem.reserveFlag intValue] & (1 << LiveGameFlagHasUp)) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您已经支持过了" toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        [self sendUpRequest:NO];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"支持成功！" toUrl:nil mode:SNCenterToastModeSuccess];
        
        int flag = [self.livingGameItem.reserveFlag intValue];
        flag |= 1 << LiveGameFlagHasUp;
        self.livingGameItem.reserveFlag = [NSString stringWithFormat:@"%d", flag];
        [[SNDBManager currentDataBase] updateLivingGame:self.livingGameItem];
        
        //支持数立即+1
        int n = [_infoObject.visitingTeamSupportNum intValue];
        _infoObject.visitingTeamSupportNum = [NSString stringWithFormat:@"%d", n + 1];
        if ([_liveBannerView respondsToSelector:@selector(setVisitUp:)]) {
            [_liveBannerView performSelector:@selector(setVisitUp:) withObject:_infoObject.visitingTeamSupportNum];
        }
    }
}

- (void)bannerVideoDidStart {
    _bLiveVideoHasStarted = YES;
}

- (void)bannerVideoDidStop {
    if (!_bViewDisappeared && !self.liveBannerView.isStoppedByForce)
        _bLiveVideoHasStarted = NO;
}

- (void)showPopNewMarkAtLive:(BOOL)bShow {
    [_liveBannerView showPopNewMark:bShow atIndex:kLiveTableTab];
}

- (void)showPopNewMarkAtChat:(BOOL)bShow {
    [_liveBannerView showPopNewMark:bShow atIndex:kChatTableTab];
}

- (void)clearOtherPlayer {
    UIView *player = [self.playingVideoCell.bgnImgView viewWithTag:100];
    [self resetShortVideoPlayer];
    [player removeFromSuperview];
}

- (void)showContentVideo:(SNVideoData *)videoModel
                fromCell:(SNLiveRoomContentCell *)cell
   videoPlaceHolderFrame:(CGRect)videoPlaceHolderFrame {
    //清除播放器
    if ([self.liveBannerView isKindOfClass:[SNLiveBannerViewWithMatchVideo class]]) {
        SNLiveBannerViewWithMatchVideo *bannerView = (SNLiveBannerViewWithMatchVideo *)self.liveBannerView;
        [[bannerView getBannerVideoPlayer] stop];
        [[bannerView getBannerVideoPlayer] clearMoviePlayerController];
    }
    
    UIView *player = [self.playingVideoCell.bgnImgView viewWithTag:100];
    [self resetShortVideoPlayer];
    [player removeFromSuperview];
    
    self.cellVideoModel = videoModel;
    self.playingVideoCell = cell;
    if ([cell.object isKindOfClass:[SNLiveContentObject class]] ||
        [cell.object isKindOfClass:[SNLiveCommentObject class]]) {
        self.playingVideoCellModel = cell.object;
    } else {
        return;
    }
    
    // 停止音频
    [[SNSoundManager sharedInstance] stopAll];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
    
    // 停止直播间视频
    [SNNotificationManager postNotificationName:kSNLiveBannerViewPauseVideoNotification object:nil];
    
    //新版视频控件
    if (self.cellVideoModel.sources.count > 0) {
        LiveTableEnum tabType = [self currentTabType];
        if (tabType == kLiveTableTab) {
            self.playingCellVideoTableViewController = _liveTableViewController;
        } else if (tabType == kChatTableTab) {
            self.playingCellVideoTableViewController = _chatTableViewController;
        }
        
        if (!_shortVideoPlayer) {
            _shortVideoPlayer = [[SNLiveRoomContentVideoPlayerView alloc] initWithFrame:videoPlaceHolderFrame andDelegate:self];
            _shortVideoPlayer.videoPlayerRefer = WSMVVideoPlayerRefer_LiveRoomList;
            _shortVideoPlayer.tag = 100;
        }
        [_shortVideoPlayer initPlaylist:[NSArray arrayWithObject:_cellVideoModel] initPlayingIndex:0];
        _shortVideoPlayer.hidden = NO;
        [self.playingVideoCell.bgnImgView addSubview:_shortVideoPlayer];
        if (![_shortVideoPlayer getMoviePlayer]) {
            _shortVideoPlayer.moviePlayer.view.frame = _shortVideoPlayer.bounds;
        }
        [_shortVideoPlayer playCurrentVideo];
        
        //标记cell对应的model数据为正在播放视频
        NSString *_key = [[SNLiveRoomContentCellVideoCache sharedInstance] createPlayingVideoKey:self.playingVideoCellModel];
        [[SNLiveRoomContentCellVideoCache sharedInstance] setPlayingVideoKey:_key];
    }
}

#pragma mark - Public for SNLiveRoomTableViewController calling
- (void)tableViewController:(SNLiveRoomTableViewController *)tableViewController whetherShowVideoPlayerByCell:(SNLiveRoomContentCell *)cell {
    if (self.playingCellVideoTableViewController != tableViewController) {
        return;
    }
    
    NSString *_key = [[SNLiveRoomContentCellVideoCache sharedInstance] createPlayingVideoKey:cell.object];
    NSString *_playingVideoKey = [[SNLiveRoomContentCellVideoCache sharedInstance] playingVideoKey];
    
    if ((_key.length > 0) && [_key isEqualToString:_playingVideoKey]) {
        self.playingVideoCell = cell;
        _shortVideoPlayer.hidden = NO;
    }
}

//不可见的cell刚好是播放视频的cell时，视频播放器隐藏。
- (void)tableViewController:(SNLiveRoomTableViewController *)tableViewController didEndDisplayingCell:(SNLiveRoomContentCell *)cell {
    if (self.playingCellVideoTableViewController != tableViewController) {
        return;
    }
    
    NSString *_key = [[SNLiveRoomContentCellVideoCache sharedInstance] createPlayingVideoKey:cell.object];
    NSString *_playingVideoKey = [[SNLiveRoomContentCellVideoCache sharedInstance] playingVideoKey];
    if ((_key.length > 0) && [_key isEqualToString:_playingVideoKey]) {
        [_shortVideoPlayer setHidden:YES];
    }
}

//当且仅当短视频所在的那个tableViewController reload且不是全屏时必须停止播放短视频
- (void)stopPlayingVideoInCellWhenReloadData:(SNLiveRoomTableViewController *)tableViewController {
    if (self.playingCellVideoTableViewController == tableViewController &&
        ![_shortVideoPlayer isFullScreen]) {
        [self resetShortVideoPlayer];
    }
}

#pragma mark - WSMVVideoPlayerViewDelegate
- (void)didPlayVideo:(SNVideoData *)video {
    /**
     * 2G/3G模式block提示并播放后才调到这里并进全屏
     * 2G/3G模式toast提示时，在toast提示的逻辑里，真正toast前进入全屏，然后调到这里。这种情况下这里的进全屏可以无视
     * wifi模式下，开始播放则调到这里并进全屏
     */
    [_shortVideoPlayer toFullScreen];
    
    //标记cell对应的model数据为正在播放视频
    NSString *_key = [[SNLiveRoomContentCellVideoCache sharedInstance] createPlayingVideoKey:self.playingVideoCellModel];
    [[SNLiveRoomContentCellVideoCache sharedInstance] setPlayingVideoKey:_key];
}

- (void)didExitFullScreen:(WSMVVideoPlayerView *)videoPlayerView {
    if (_exitFullScreenAutomatially) {
        _exitFullScreenAutomatially = NO;
        [_shortVideoPlayer pause];
    } else {
        [_shortVideoPlayer hideTitleAndControlBarWithAnimation:NO];
        [_shortVideoPlayer stop];
        [_shortVideoPlayer clearMoviePlayerController];
        [_shortVideoPlayer removeFromSuperview];
    }
    
    //如果当前是2G/3G环境，就不自动播bannervideo
    Reachability *currentReach = [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability];
    NetworkStatus currentNetStatus = [currentReach currentReachabilityStatus];
    if (currentNetStatus == ReachableViaWiFi) {
        [SNNotificationManager postNotificationName:kSNShortVideoDidStopNotification object:nil];
    }
}

- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style
                   forPlayerView:(WSMVVideoPlayerView *)playerView {
    if (style == WSMV2G3GAlertStyle_Block) {
        [playerView pause];
        SNDebugLog(@"Will show 2G3G alert with blockUI.");
        
        // 全屏状态下 先退出全屏
        if (playerView.isFullScreen) {
            _exitFullScreenAutomatially = YES;
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
            [_shortVideoPlayer toFullScreen];//在2G/3G下播放需要非阻断式提示时，先进全屏再提示
            [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
        }
    }
    else if (style == WSMV2G3GAlertStyle_NetChangedTo2G3GToast) {
        SNDebugLog(@"Toast for network changed to 2G/3G.");
        
        UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
        BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
    }
    else if (style == WSMV2G3GAlertStyle_NotReachable) {
        [playerView pause];
        if ([playerView isFullScreen]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network_unavailable_cant_play_video", nil) toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
    else {
        SNDebugLog(@"Needn't show 2G3G alert UI currently.");
    }
}

- (void)showNetworkWarningAciontSheetForPlayer:(WSMVVideoPlayerView *)playerView {

    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"2g3g_actionsheet_info_content", nil) cancelButtonTitle:NSLocalizedString(@"2g3g_actionsheet_option_cancel", nil) otherButtonTitle:NSLocalizedString(@"2g3g_actionsheet_option_play", nil)];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        playerView.playingVideoModel.hadEverAlert2G3G = NO;
        [self resetShortVideoPlayer];
    }otherButtonHandler:^{
        playerView.playingVideoModel.hadEverAlert2G3G = YES;
        [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
        [playerView playCurrentVideo];
        
    }];

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
    
    SHMedia *shMedia = [_shortVideoPlayer getMoviePlayer].currentPlayMedia;
    SHMediaSourceType movieSourceType = shMedia.sourceType;
    if (movieSourceType == SHLocalDownload) {
        _vStatModel.offline = kWSMVStatVV_Offline_YES;
    }
    else {
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
    SNDebugLog(@"Tapped actionSheet at buttonIndex %d", buttonIndex);
    
    if (actionSheet.tag == kRechabilityChangedActionSheetTag) {
        WSMVVideoPlayerView *playerView = [[actionSheet userInfo] objectForKey:kPlayerViewWithActionSheet];
        if (buttonIndex == 0) {//取消
            playerView.playingVideoModel.hadEverAlert2G3G = NO;
            [self resetShortVideoPlayer];
        }
        else if (buttonIndex == 1) {//播放
            playerView.playingVideoModel.hadEverAlert2G3G = YES;
            [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
            [playerView playCurrentVideo];
        }
    }
    else if (actionSheet.tag == kLiveInviteAlertTag) {
        SNLiveInviteFeedbackEnum ack = LIVE_INVITE_FEEDBACK_ACCEPT;
        if (buttonIndex == 0) {
            // 拒绝邀请
            ack = LIVE_INVITE_FEEDBACK_DENY;
            
        } else if (buttonIndex == 1) {
            // 接受邀请
            ack = LIVE_INVITE_FEEDBACK_ACCEPT;
        }
        
        NSString *passport = [SNUserManager getUserId];
        if (passport.length > 0) {
            [_inviteModel sendInviteFeedback:ack
                                  withLiveId:_liveId
                                    passport:passport];
        }
    }
}

#pragma mark -
- (void)scrolltoVertical:(BOOL)hideFlag
{
    if (hideFlag)
    {
        //隐藏
        [UIView animateWithDuration:.3f animations:^{
            float top = SYSTEM_VERSION_LESS_THAN(@"7.0") ? 30.f : 19.f;
            
            self.liveBannerView.bottom = top + kSystemBarHeight;
            _liveTableViewController.view.top = self.liveBannerView.bottom - 8.f;
            _chatTableViewController.view.top = _liveTableViewController.view.top;
            
            if (self.topInfoView.hasExpanded)
            {
                self.topInfoView.top = self.liveBannerView.bottom + 8;
            }
            else
            {
                self.topInfoView.top = self.liveBannerView.bottom;
            }
            
            
        } completion:^(BOOL finished) {
            _liveTableViewController.view.height = kAppScreenHeight - kToolbarViewTop - self.liveBannerView.bottom + 8.f;
            _chatTableViewController.view.height = _liveTableViewController.view.height;
        }];
    }
    else
    {
        //显示
        [UIView animateWithDuration:.3f animations:^{
            self.liveBannerView.top = kSystemBarHeight;
            _liveTableViewController.view.top = self.liveBannerView.bottom - 8.f;
            _chatTableViewController.view.top = _liveTableViewController.view.top;
            if (self.topInfoView.hasExpanded)
            {
                self.topInfoView.top = self.liveBannerView.bottom + 8;
            }
            else
            {
                self.topInfoView.top = self.liveBannerView.bottom;
            }
            
        } completion:^(BOOL finished) {
            _liveTableViewController.view.height = kAppScreenHeight - kToolbarViewTop - self.liveBannerView.bottom + 8.f;
            _chatTableViewController.view.height = _liveTableViewController.view.height;
        }];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_liveBannerView scrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    int index = scrollView.contentOffset.x / frame.size.width;
    [self setScrollsToTopAtIndex:index];
    
    [_liveBannerView setCurrentIndex:index];
    [self hideKeyboard];
    
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if ([contextMenu isMenuVisible]) {
        [contextMenu setMenuVisible:NO];
    }
    
    if (_liveTableTypeArray[index] == kChatTableTab) {
        [self onLiveChatTabDidSelected];
    }
    
    // 推荐tab隐藏toolbar上的按钮
    [self hideToolbarBtnsByIndex:index];
    
    if (_liveTableTypeArray[index] == kStatTableTab) {
        //[_statisticsWebController refreshInSilence];
        [_statisticsWebController openWithUrl:_infoObject.statisticsUrl];
    }
}

- (int)currentTabIndex {
    int index = _scrollView.contentOffset.x / _scrollView.frame.size.width;
    return index;
}

- (LiveTableEnum)currentTabType {
    int index = _scrollView.contentOffset.x / _scrollView.frame.size.width;
    return _liveTableTypeArray[index];
}

#pragma mark - SNLiveContentMatchInfoViewDelegate
- (void)matchViewWillBeginCompressing {
    CGRect tableFrame = _liveTableViewController.view.frame;
    tableFrame.origin.y -= 5.0;
    tableFrame.size.height += 5.0;
    _liveTableViewController.view.frame = tableFrame;
    
    tableFrame = _chatTableViewController.view.frame;
    tableFrame.origin.y -= 5.0;
    tableFrame.size.height += 5.0;
    _chatTableViewController.view.frame = tableFrame;
    
    //    self.tableView.frame
    [UIView beginAnimations:@"Compressing" context:nil];
    [UIView setAnimationDuration:kTableViewAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat Y = kHeaderHeightWithoutBottom + MATCH_INFO_VIEW_SCROLLED_HEIGHT - 4.0f;
    CGFloat H = applicationFrame.size.height - kHeaderHeightWithoutBottom - MATCH_INFO_VIEW_SCROLLED_HEIGHT - kToolbarViewTop + 4.0f;
    
    _liveTableViewController.view.frame = CGRectMake(0, Y, applicationFrame.size.width, H);
    
    _chatTableViewController.view.frame = CGRectMake(applicationFrame.size.width, Y, applicationFrame.size.width, H);
    
    //[_chatTableViewController layoutSubViews];
    
    [UIView commitAnimations];
    
    [self hideKeyboard];
}

- (void)matchViewWillBeginExpanding {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:kTableViewAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat Y = kHeaderHeightWithoutBottom + MATCH_INFO_VIEW_HEIGHT - 4.0f;
    CGFloat H = applicationFrame.size.height - kHeaderHeightWithoutBottom - MATCH_INFO_VIEW_HEIGHT - kToolbarViewTop + 4.0f;
    
    _liveTableViewController.view.frame = CGRectMake(0, Y, applicationFrame.size.width, H);
    
    _chatTableViewController.view.frame = CGRectMake(applicationFrame.size.width, Y, applicationFrame.size.width, H);
    
    //[_chatTableViewController layoutSubViews];
    
    [UIView commitAnimations];
    
    [self hideKeyboard];
}

- (void)matchViewDidTapped {
    [self hideKeyboard];
}

#pragma mark - SNLiveContentMatchInfoViewDelegate
//- (void)sendUpRequest:(BOOL)isHost {// ?liveId=%@&team=%@
//    NSString *reqUrl = nil;
//    reqUrl = [NSString stringWithFormat:SNLinks_Path_Live_Surport, _liveId, isHost ? @"host" : @"vistor"];
//    SNDebugLog(@"up reqUrl = %@", reqUrl);
//    
//    SNURLRequest *request = [SNURLRequest requestWithURL:reqUrl delegate:self];
//    request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    request.isShowNoNetWorkMessage = YES;
//    request.response = [[SNURLJSONResponse alloc] init];
//    request.userInfo = [TTUserInfo topic:isHost ? kTopicUpHost : kTopicUpVisit strongRef:self weakRef:nil];
//    [request send];
//}

- (void)sendUpRequest:(BOOL)isHost {
    
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:_liveId forKey:@"liveId"];
    [params setValue:(isHost ? @"host" : @"vistor") forKey:@"team"];
    
    [[[SNLiveSurportRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        if (isHost) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = responseObject;
                id obj = [dic objectForKey:@"result"];
                if (obj && ([obj intValue] == 1)) {
                    return [self upHostSucc];
                }
            }
        } else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = responseObject;
                id obj = [dic objectForKey:@"result"];
                if (obj && ([obj intValue] == 1)) {
                    return [self upVisitSucc];
                }
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error);
    }];
}

- (void)upHost {
    [self hideKeyboard];
    
    if ([self.livingGameItem.reserveFlag intValue] & (1 << LiveGameFlagHasUp)) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您已经支持过了" toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        [self sendUpRequest:YES];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"支持成功！" toUrl:nil mode:SNCenterToastModeSuccess];
        
        int flag = [self.livingGameItem.reserveFlag intValue];
        flag |= 1 << LiveGameFlagHasUp;
        self.livingGameItem.reserveFlag = [NSString stringWithFormat:@"%d", flag];
        [[SNDBManager currentDataBase] updateLivingGame:self.livingGameItem];
        
        //支持数立即+1
        int n = [_infoObject.homeTeamSupportNum intValue];
        _infoObject.homeTeamSupportNum = [NSString stringWithFormat:@"%d", n + 1];
        [_liveBannerView setInfoObj:_infoObject];
    }
}

- (void)upVisit {
    [self hideKeyboard];
    
    if ([self.livingGameItem.reserveFlag intValue] & (1 << LiveGameFlagHasUp)) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您已经支持过了" toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        [self sendUpRequest:NO];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"支持成功！" toUrl:nil mode:SNCenterToastModeSuccess];
        
        int flag = [self.livingGameItem.reserveFlag intValue];
        flag |= 1 << LiveGameFlagHasUp;
        self.livingGameItem.reserveFlag = [NSString stringWithFormat:@"%d", flag];
        [[SNDBManager currentDataBase] updateLivingGame:self.livingGameItem];
        
        //支持数立即+1
        int n = [_infoObject.visitingTeamSupportNum intValue];
        _infoObject.visitingTeamSupportNum = [NSString stringWithFormat:@"%d", n + 1];
        [_liveBannerView setInfoObj:_infoObject];
    }
}

- (void)viewHostInfo {
    [self hideKeyboard];
    NSString *url = _liveTableViewController.infoObject.homeTeamInfoURL;
    if ([SNAPI isWebURL:url]) {
        [SNUtility openProtocolUrl:url];
    }
}

- (void)viewVisitInfo {
    [self hideKeyboard];
    
    NSString *url = _liveTableViewController.infoObject.visitingTeamInfoURL;
    if ([SNAPI isWebURL:url]) {
        [SNUtility openProtocolUrl:url];
    }
}

#pragma mark - show game statistics
- (void)showLiveStatistics:(id)sender {
    
    // 篮球
    if ([_infoObject.statisticsType intValue] == 1) {
        [SNUtility shouldUseSpreadAnimation:NO];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        if (_liveId) [info setObject:_liveId forKey:@"liveId"];
        if (_liveTableViewController.infoObject.homeTeamTitle) [info setObject:_liveTableViewController.infoObject.homeTeamTitle forKey:@"hostName"];
        if (_liveTableViewController.infoObject.visitingTeamTitle) [info setObject:_liveTableViewController.infoObject.visitingTeamTitle forKey:@"visitName"];
        TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://liveStatistic"] applyAnimated:YES] applyQuery:info];
        [[TTNavigator navigator] openURLAction:action];
    }
    else {
        NSString *stat = _liveTableViewController.infoObject.liveStatistics;
        
        if ([stat length] > 0 && [SNAPI isWebURL:stat]) {
            [SNUtility openProtocolUrl:stat];
        }
    }
}

#pragma mark - 直播查询
//- (void)refreshLiveInfo {
//    NSString *url = nil;
//    if ([_liveId length] > 0) {
//        NSString *passport = [SNUserManager getUserId];
//        url = [NSString stringWithFormat:SNLinks_Path_Live_Info, _liveId];
//        if (passport.length > 0) url = [url stringByAppendingFormat:@"&passport=%@", passport];
//        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        url = [SNAdManager urlByAppendingAdParameter:url];
//        SNDebugLog(@"%@",url);
//        
//        SNURLRequest *request = [SNURLRequest requestWithURL:url delegate:self];
//        request.cachePolicy = TTURLRequestCachePolicyNoCache;
//        request.response = [[SNURLJSONResponse alloc] init];
//        request.userInfo = [TTUserInfo topic:kTopicLiveInfo strongRef:self weakRef:nil];
//        [request send];
//    } else {
//        [self hideLoading];
//    }
//}

- (void)refreshLiveInfo {
    if ([_liveId length] > 0) {
        [[[SNLiveInfoRequest alloc] initWithDictionary:@{@"liveId":_liveId}] send:^(SNBaseRequest *request, id responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                [self hideLoading];
                NSDictionary *dic = responseObject;
                SNDebugLog(@"liveInfo finishLoad: %@", dic);
                
                _isFirstLiveInfo = YES;
                
                //李健 2015.04.01 解析banner广告
                NSDictionary *adInfo = [dic dictionaryValueForKey:@"adinfo" defalutValue:nil];
                NSInteger reportID = [SNADReport parseLiveRoomStreamData:adInfo root:dic];
                if (adInfo) {
                    SNAdLiveInfo *info = [[SNAdLiveInfo alloc] initWithJsonDic:adInfo];
                    //空广告
                    if(nil == info){
                        [SNADReport reportEmpty:reportID];
                    } else {
                        info.blockId = [dic stringValueForKey:@"blockId" defaultValue:@""];
                        self.livingGameItem.blockId = [dic stringValueForKey:@"blockId" defaultValue:@""];
                        if ([info isValid]) {
                            self.adBannerInfo = info;
                        }
                        
                        self.adBannerInfo.reportID = reportID;
                        //加载
                        [SNADReport reportLoad:self.adBannerInfo.reportID];
                    }
                }
                [self onLiveInfoRefreshed:dic];
                
                if (!_bViewDisappeared) {
                    [self updateStatusBarStyle];
                }
                
                // 初始状态为收起
                if (!self.liveBannerView.hasExpanded) {
                    [self.liveBannerView doShrinkAnimation];
                }
                
                // 刷新邀请状态
                if (!_hasInviteStatusRequested) {
                    [self refreshLiveInviteStatus];
                    _hasInviteStatusRequested = YES;
                }
                
                //解析广告
                NSArray *adInfoControls = [dic arrayValueForKey:@"adControlInfos" defaultValue:nil];
                if (adInfoControls) {
                    NSMutableArray *parsedAdInfos = [NSMutableArray array];
                    for (NSDictionary *adInfoDic in adInfoControls) {
                        if ([adInfoDic isKindOfClass:[NSDictionary class]]) {
                            SNAdControllInfo *adControlInfo = [[SNAdControllInfo alloc] initWithJsonDic:adInfoDic];
                            [parsedAdInfos addObject:adControlInfo];
                        }
                    }
                    
                    if (parsedAdInfos.count > 0) {
                        SNAdControllInfo *adCtrlInfo = parsedAdInfos[0];
                        for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
                            if (([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdLiveSponsorShip] ||
                                 [adInfo.adSpaceId isEqualToString:kSNAdSpaceIdLiveSponsorShipTestServer]) &&
                                !self.sdkAdSponsorShip) {
                                //[adInfo.filterInfo setObject:_fromChannelId forKey:@"newschn"];
                                self.sdkAdSponsorShip = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId adInfoParam:adInfo.filterInfo];
                                self.sdkAdSponsorShip.delegate = self;
                                self.sdkAdSponsorShip.appChannel = adInfo.appChannel;
                                //self.sdkAdSponsorShip.newsChannel = _fromChannelId ? : adInfo.newsChannel;
                                self.sdkAdSponsorShip.newsChannel = _fromChannelId ? : [adInfo.filterInfo objectForKey:@"newschn"];
                                self.sdkAdSponsorShip.gbcode = adInfo.gbcode;
                                self.sdkAdSponsorShip.adId = adInfo.adId;
                                self.sdkAdSponsorShip.roomId = _liveId;
                                [self.sdkAdSponsorShip refreshAdData:NO];
                            }
                        }
                    }
                }
            } else {
                [self showError];
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            [self showError];
        }];
        
    } else {
        [self hideLoading];
    }
}

- (void)refreshLiveInviteStatus {
    NSString *passport = [SNUserManager getUserId];
    
    if (passport.length > 0) {
        // 查询数据库表中是否有邀请
        SNLiveInviteStatusObj *statusObj = [[SNDBManager currentDataBase] getLiveInviteItemByLiveId:_liveId
                                                                                           passport:passport];
        SNDebugLog(@"refreshLiveInviteStatus: %@", statusObj);
        if ((statusObj && ([statusObj.inviteStatus intValue] == LIVE_INVITING ||
                           [statusObj.inviteStatus intValue] == LIVE_INVITE_SUC ||
                           [statusObj.inviteStatus intValue] == LIVE_INVITE_UNKNOWN)) ||
            ([_fromClassStr isEqualToString:NSStringFromClass([SNNotificaitonTableController class])])) {
            
            NSString *code = [self.queryDic objectForKey:kCode];
            if (code) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.queryDic];
                [dict removeObjectForKey:kLiveIdKey];
                [dict removeObjectForKey:kOpenProtocolOriginalLink2];
                _inviteModel.userInfo = dict;
            }
            [_inviteModel requestInviteStatusByLiveId:_liveId passport:passport];
        }
        else {
            NSString *code = [self.queryDic objectForKey:kCode];
            if (code) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.queryDic];
                [dict removeObjectForKey:kLiveIdKey];
                [dict removeObjectForKey:kOpenProtocolOriginalLink2];
                _inviteModel.userInfo = dict;
                [_inviteModel requestInviteStatusByLiveId:_liveId passport:passport];
                
                SNLiveInviteStatusObj *inviteObj = [[SNLiveInviteStatusObj alloc] init];
                inviteObj.liveId = _liveId;
                inviteObj.inviteStatus = [NSNumber numberWithInt:LIVE_INVITE_UNKNOWN];
                inviteObj.passport = passport;
                [[SNDBManager currentDataBase] addOrUpdateLiveInviteItem:inviteObj];
            }
        }
    } else {
        SNDebugLog(@"has not login");
        NSString *code = [self.queryDic objectForKey:kCode];
        if (code) {
            _needRefreshInviteStatusWhenLoginSucceed = YES;
            [SNGuideRegisterManager showGuideWithH5LiveInvite];
        }
    }
}

- (void)refreshTableViewDataWhenAppBecomeActive {
    [SNNewsReport shareInstance].startTime = [[NSDate date] timeIntervalSince1970];
    if (_scrollView) {
        LiveTableEnum tabType = [self currentTabType];
        if (tabType == kChatTableTab) {
            [_chatTableViewController refreshTableViewDataWhenAppBecomeActive];
        } else if (tabType == kLiveTableTab) {
            [_liveTableViewController refreshTableViewDataWhenAppBecomeActive];
        }
    }
}

#pragma mark -
#pragma share
- (void)commentWillPost:(NSMutableDictionary *)commentData sendType:(SNEditorType)sendType{
    NSString* sendContent = [commentData objectForKey:kCommentDataKeyText];
    
    //分享到阅读圈
    if (sendType == SNEditorTypeShare) {
        SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase]getTimelineOriginObjByType:SNTimelineContentTypeLive
                                                                                            contentId:_liveId];
        
        if (obj) {
            [[SNTimelinePostService sharedService]timelineShareWithContent:sendContent
                                                             originContent:obj
                                                               fromShareId:nil];
        }
    }
}

#pragma mark - 评论
- (void)postComment:(NSString *)text liveId:(NSString *)liveId type:(SNLiveCommentType)type {
    NSString *userName = [SNUserManager getNickName];
    if (userName.length == 0) {
        userName = kDefaultUserName;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [params setValue:@"1" forKey:@"busiCode"];
    [params setValue:liveId forKey:@"id"];
    [params setValue:userName forKey:@"author"];
    [params setValue:[NSString stringWithFormat:@"%lld", (long long)(1000 * [[NSDate date] timeIntervalSince1970])] forKey:@"sendtime"];

    if (self.replyId.length > 0) {
        [params setValue:[self.replyId trim] forKey:@"replyId"];
    }
    
    if (self.replyType.length > 0) {
        [params setValue:self.replyType forKey:@"replyType"];
    }
    
    if (self.replyPid.length > 0) {
        [params setValue:self.replyPid forKey:@"replyPid"];
    }
    NSData *imageData = nil;
    NSData *audioData = nil;
    NSDictionary *userInfo = [NSDictionary dictionary];
    if (self.audioFilePath && [[NSFileManager defaultManager] fileExistsAtPath:self.audioFilePath] && type == SNLiveCommentTypeAudio) {
        audioData = [NSData dataWithContentsOfFile:self.audioFilePath];
        if (audioData) {
            [params setValue:@"aud" forKey:@"contType"];
            userInfo = @{@"comType": @(type),
                         @"audio"  : self.audioFilePath
                         };
        }
    } else if (_inputbar.editedImage != nil && type == SNLiveCommentTypePicAndTxt) {
        imageData = UIImageJPEGRepresentation(_inputbar.editedImage, 1.0f);//这里不需要压缩在拍照时候已经压缩完成
        if (imageData) {
            [params setValue:@"img" forKey:@"contType"];
        }
        if (text) {
            [params setValue:text forKey:@"cont"];
            userInfo = @{@"comType": @(type),
                         @"cont"   : text
                         };
        }
    } else {
        if (text) {
            [params setValue:text forKey:@"cont"];
            [params setValue:@"text" forKey:@"contType"];
            userInfo = @{@"comType": @(type),
                         @"cont"   : text
                         };
        }
    }

    [[[SNPostConmentRequest alloc] initWithDictionary:params withCommentImageData:imageData andCommentAudioData:audioData] send:^(SNBaseRequest *request, id responseObject) {
        
        BOOL bSuccess = NO;
        NSString *errCode = nil;
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            SNDebugLog(@"%@", responseObject);
            NSString *isSuccess = [responseObject stringValueForKey:@"isSuccess" defaultValue:nil];
            if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
                bSuccess = YES;
            } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
                bSuccess = NO;
                errCode = [responseObject stringValueForKey:@"error" defaultValue:nil];
            }
        }
        
        if (bSuccess) {
            NSString *txt = [userInfo objectForKey:@"cont"];
            if ([txt isEqualToString:@"撒花"]) {
                [self strewFlowers];
            }
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSent", @"messageSent") toUrl:nil mode:SNCenterToastModeSuccess];
            
            SNLiveCommentType type = (SNLiveCommentType)[userInfo intValueForKey:@"comType" defaultValue:SNLiveCommentTypePicAndTxt];
            [_inputbar postSucccess:type];
            [SNUtility requestRedPackerAndCoupon:[_liveId URLEncodedString] type:@"3"];
        } else {
            [self showError:errCode];
            
            NSString *txt = [userInfo objectForKey:@"cont"];
            [_inputbar postFailure:txt];
        }
 
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self showError:nil];
        
        NSString *txt = [userInfo objectForKey:@"cont"];
        [_inputbar postFailure:txt];
    }];

}

- (void)addMaskView {
    if (!_maskViewForKeyBoard) {
        _maskViewForKeyBoard = [[UIView alloc] initWithFrame:self.view.bounds];
        
        if ([SNPreference sharedInstance].testModeEnabled) {
            _maskViewForKeyBoard.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
        } else {
            _maskViewForKeyBoard.backgroundColor = [UIColor clearColor];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewDidTapped:)];
        [_maskViewForKeyBoard addGestureRecognizer:tap];
         //(tap);
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewDidTapped:)];
        [_maskViewForKeyBoard addGestureRecognizer:pan];
         //(pan);
        
        [self.view bringSubviewToFront:_inputbar];
        [self.view bringSubviewToFront:_picInputView];
        [self.view bringSubviewToFront:_emoInputView];
        [self.view insertSubview:_maskViewForKeyBoard belowSubview:_inputbar];
        UIView *msgInfoView = [self msgInfoView];
        if (msgInfoView) [self.view bringSubviewToFront:msgInfoView];
    }
}

- (void)removeMaskView {
    if (_maskViewForKeyBoard) {
        [_maskViewForKeyBoard removeFromSuperview];
        _maskViewForKeyBoard = nil;
    }
}

- (void)maskViewDidTapped:(id)sender {
    if (_maskViewForKeyBoard) {
        [_maskViewForKeyBoard removeFromSuperview];
        _maskViewForKeyBoard = nil;
    }
    if ([_inputbar isFirstResponder]) {
        [self hideKeyboard];
    } else {
        [self hideInputBar];
    }
    if (self.replyId && self.replyName && self.isShowKeyBoard) {
        //self.replyId、self.replyName、键盘显示三个条件都满足时，显示浮层
        [self addReplyInfoView:self.replyName];
    }
}

- (void)hideKeyboard {
    _inputbar.pickingImage = NO;
    [_inputbar resignFocus];
    
    //[self hideInputBar];
}

//直播间分享
- (void)shareAction:(NSString *)comment {
    self.shareComment = comment;
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    NSString * protocol = [NSString stringWithFormat:@"%@liveId=%@",kProtocolLive,_liveId];
    [mDic setObject:protocol forKey:SNNewsShare_Url];
    [mDic setObject:@"live" forKey:SNNewsShare_ShareOn_contentType];
    [mDic setObject:@"live" forKey:SNNewsShare_LOG_type];
    [mDic setObject:[NSString stringWithFormat:@"liveId=%@",self.liveId] forKey:SNNewsShare_ShareOn_referString];
    
    SNTimelineOriginContentObject *oobj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeLive contentId:_liveId];
    NSString* sourceType = [NSString stringWithFormat:@"%d",oobj?oobj.sourceType:SNShareSourceTypeLive];
    [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    //live://liveId=32551&mediaType=0&from=channel&channelId=1&position=22&page=1
    NSString * protocolUrl = [NSString stringWithFormat:@"%@liveId=%@",kProtocolLive,_liveId];
    [_actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    [_actionMenuController.contextDic setObject:@"live" forKey:@"contentType"];
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:@"liveId=%@",self.liveId] forKey:@"referString"];
    _actionMenuController.timelineContentId = _liveId;
    _actionMenuController.timelineContentType = SNTimelineContentTypeLive;
    _actionMenuController.shareLogType = @"live";
    _actionMenuController.disableLikeBtn = YES;
    _actionMenuController.delegate = self;
    if ([comment length] > 0)
    {
        //        _actionMenuController.hasShareToTimeline = NO;
    }
    [_actionMenuController showActionMenu];
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeLive
                                                                                         contentId:_liveId];
    if (obj) {
        self.actionMenuController.sourceType = obj.sourceType;
        _actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    } else {
        self.actionMenuController.sourceType = SNShareSourceTypeLive;
        _actionMenuController.shareSubType = ShareSubTypeQuoteText;
    }
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

//直播间评论分享
- (void)shareCommentAction:(NSDictionary *)commentDic {
    
    self.shareComment = [commentDic stringValueForKey:@"commentContent" defaultValue:nil];
    self.shareCommentImageUrl = [commentDic stringValueForKey:@"commentImageUrl" defaultValue:nil];
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    NSString * protocol = [NSString stringWithFormat:@"%@liveId=%@",kProtocolLive,_liveId];
    [mDic setObject:protocol forKey:SNNewsShare_Url];
    [mDic setObject:@"live" forKey:SNNewsShare_ShareOn_contentType];
    [mDic setObject:@"live" forKey:SNNewsShare_LOG_type];
    [mDic setObject:self.shareComment?self.shareComment:@"" forKey:SNNewsShare_shareComment];
    [mDic setObject:[NSString stringWithFormat:@"liveId=%@",self.liveId] forKey:SNNewsShare_ShareOn_referString];
    
    SNTimelineOriginContentObject *oobj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeLive contentId:_liveId];
    NSString* sourceType = [NSString stringWithFormat:@"%d",oobj?oobj.sourceType:SNShareSourceTypeLive];
    [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.disableLikeBtn = YES;
    _actionMenuController.shareSubType = ShareSubTypeComment;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    NSString * protocolUrl = [NSString stringWithFormat:@"%@liveId=%@",kProtocolLive,_liveId];
    [_actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    [_actionMenuController.contextDic setObject:commentDic[@"commentId"]?:@"" forKey:@"commentId"];
    [_actionMenuController.contextDic setObject:@"live" forKey:@"contentType"];
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:@"liveId=%@",self.liveId] forKey:@"referString"];
    _actionMenuController.shareLogType = @"live";
    _actionMenuController.delegate = self;
    _actionMenuController.sourceType = SNShareSourceTypeLive;

    if ([self.shareComment length] > 0 || self.shareCommentImageUrl.length > 0)
    {
        //        _actionMenuController.hasShareToTimeline = NO;
    }
    [_actionMenuController showActionMenu];
}

#pragma mark - shareinfoController delegate
- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    if ([_liveId length] > 0) {
        [dicInfo setObject:_liveId forKey:kShareInfoKeyNewsId];
    }
    
    NSString *shareContent = _infoObject.shareContent;
    
    NSString *shareLink = SNLinks_FixedUrl_3gk;
    
    if (shareContent.length) {
        NSString *link = [SNUtility getLinkFromShareContent:shareContent];
        if (link.length) {
            shareLink = link;
        }
    }
    
    if (shareContent.length == 0) {
        if ([_infoObject.liveType intValue] == 1) {
            shareContent = [NSString stringWithFormat:@"我正在用搜狐新闻看直播\"%@ vs %@\" %@",
                            _infoObject.homeTeamTitle, _infoObject.visitingTeamTitle,SNLinks_FixedUrl_3gk];
        } else {
            shareContent = [NSString stringWithFormat:@"我正在用搜狐新闻看直播\"%@\" %@",
                            _infoObject.matchTitle,SNLinks_FixedUrl_3gk];
        }
    }
    
    if (_infoObject.matchTitle.length > 0) {
        [dicInfo setObject:_infoObject.matchTitle forKey:kShareInfoKeyTitle];
    }
    
    if (shareLink.length > 0) {
        [dicInfo setObject:shareLink forKey:kShareInfoKeyShareLink];
    }
    
    if ([shareContent length] > 0) {
        if ([shareContent length] > 120) {
            shareContent = [[shareContent substringToIndex:120] stringByAppendingString:@"..."];
        }
        [dicInfo setObject:shareContent forKey:kShareInfoKeyContent];
    }
    
    if ([self.shareComment length] > 0 || self.shareCommentImageUrl.length > 0) {
        
        if (self.shareComment) {
            NSString *content = self.shareComment;
//            if (shareLink) {
//                content = [content stringByAppendingFormat:@" %@", shareLink];
//            }
            if (content) {
                [dicInfo setObject:content forKey:kShareInfoKeyComment];
            }
        }
        else {
            if (shareLink) {
                [dicInfo setObject:shareLink forKey:kShareInfoKeyContent];
            }
        }
        
        if (self.shareCommentImageUrl) {
            [dicInfo setObject:self.shareCommentImageUrl forKey:kShareInfoKeyImageUrl];
        } else {
            NSString *screenShotPath = [UIImage screenshotImagePathFromView:self.view];
            [dicInfo setObject:screenShotPath forKey:kShareInfoKeyScreenImagePath];
        }
        
        self.shareComment = nil;
        self.shareCommentImageUrl = nil;
        
    } else {
        NSString *screenShotPath = [UIImage screenshotImagePathFromView:self.view];
        [dicInfo setObject:screenShotPath forKey:kShareInfoKeyScreenImagePath];
    }
    
    //log
    if ([_liveId length] > 0) {
        [dicInfo setObject:_liveId forKey:kShareInfoKeyNewsId];
    }
    if ([shareContent length] > 0) {
        [dicInfo setObject:shareContent forKey:kShareInfoKeyShareContent];
    }
    
    return dicInfo;
}

- (void)resetBannerView {
    //    BOOL bInit = (self.liveBannerView == nil);
    if (self.liveBannerView && self.liveBannerView.superview) {
        [self.liveBannerView removeFromSuperview];
        self.liveBannerView = nil;
    }
    if (self.topInfoView && self.topInfoView.superview) {
        [self.topInfoView removeFromSuperview];
        self.topInfoView = nil;
    }
    // 双方比赛
    if ([_infoObject.liveType intValue] == 1) {
        
        // 视频、音频直播
        if ([_infoObject isMediaLiveMode]) {
            
            BOOL bShrinkMode;
            if (_isFirstLiveInfo) {
                bShrinkMode = _infoObject.mediaObj.displayMode == kVideoDisplayModeShrink;
            } else {
                bShrinkMode = NO;//!self.liveBannerView.hasExpanded;
            }
            
            self.liveBannerView = [[SNLiveBannerViewWithMatchVideo alloc] initWithMode:bShrinkMode];
            self.liveBannerView.isWorldCup = _infoObject.isWorldCup;
            [self.liveBannerView createSubviews];
            self.liveBannerView.hasExpandButton = YES;
            self.liveBannerView.alpha = themeImageAlphaValue();
        }
        // 普通文字直播
        else {
            self.liveBannerView = [[SNLiveBannerViewWithMatchInfo alloc] initWithFrame:CGRectZero];
            self.liveBannerView.isWorldCup = _infoObject.isWorldCup;
            [self.liveBannerView createSubviews];
            self.liveBannerView.hasExpandButton = YES;
        }
        
        if ([_infoObject hasH5Statistics]) {
            [self.liveBannerView setSectionTitleArray:@[ @"实况直播", @"边看边聊", @"数据统计" ]];
        } else {
            [self.liveBannerView setSectionTitleArray:@[ @"实况直播", @"边看边聊" ]];
        }
    }
    // 特殊直播
    else {
        // 视频、音频直播
        if ([_infoObject isMediaLiveMode]) {
            BOOL bShrinkMode;
            if (_isFirstLiveInfo) {
                bShrinkMode = _infoObject.mediaObj.displayMode == kVideoDisplayModeShrink;
            } else {
                bShrinkMode = NO;//!self.liveBannerView.hasExpanded;
            }
            self.liveBannerView = [[SNLiveBannerViewWithTitleVideo alloc] initWithMode:bShrinkMode];
            self.liveBannerView.hasExpandButton = YES;
        }
        // 普通文字直播
        else {
            self.liveBannerView = [[SNLiveBannerViewWithTitle alloc] initWithFrame:CGRectZero];
        }
        
        if ([_infoObject hasH5Statistics]) {
            [self.liveBannerView setSectionTitleArray:@[ @"实况直播", @"边看边聊", @"数据统计" ]];
        } else {
            [self.liveBannerView setSectionTitleArray:@[ @"实况直播", @"边看边聊" ]];
        }

        self.liveBannerView.hasLeftVerticleLine = NO;
    }
    
    if (_maskViewForKeyBoard) {
        [self.view insertSubview:self.liveBannerView belowSubview:_maskViewForKeyBoard];
    } else {
        [self.view addSubview:self.liveBannerView];
    }
    
    self.liveBannerView.delegate = self;
    self.liveBannerView.infoObj = _infoObject;
    self.liveBannerView.currentIndex = (int)(_scrollView.contentOffset.x/_scrollView.width);
    [self scrollViewDidScroll:_scrollView]; // 重新设置bannerView底下的segmentView
    
    if (_infoObject.top && (_infoObject.top.top.length + _infoObject.top.topImage.length > 0)) {
        self.topInfoView = [[SNLiveRoomTopInfoView alloc] initWithTopObject:_infoObject.top];
        self.topInfoView.delegate = self;
        [_scrollView addSubview:self.topInfoView];
    }
    
    //lijian 创建广告banner
    if([self.adBannerInfo isValid]){
        if(nil == _advertisingBannerView){
            _advertisingBannerView = [[SNLiveRoomAdvertisingBannerView alloc] initWithFrame:CGRectZero];
            _advertisingBannerView.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advertisingBannerTap:)];
            [_advertisingBannerView addGestureRecognizer:singleTap];
            [self.view addSubview:_advertisingBannerView];
            _advertisingBannerView.alpha = themeImageAlphaValue();
        }
    }
    
    if (self.liveBannerView.hasVideo && self.liveBannerView.hasExpanded) {
        self.topInfoView.alpha = 0;
    }
    self.liveBannerView.top = 0;
    [self layoutAdvertisingView];
    [self layoutLiveInfoView];
}

//lijian 2015.04.01 点击广告
- (void)advertisingBannerTap:(id)sender
{
    if([self.adBannerInfo isValid]){
        
        if ([SNUtility openProtocolUrl:self.adBannerInfo.clickUrl] && self.adBannerInfo.clickUrl.length > 0) {
            [SNADReport reportClick:self.adBannerInfo.reportID];
        }        
    }
}

- (void)focusInput {
    _inputbar.pickingImage = NO;
    
    //录音模式不弹出键盘，显示回复提示view
    if (self.replyName.length && [_toolbar isRecMode]) {
        [self addReplyInfoView:self.replyName];
        UIView *msgInfoView = [self msgInfoView];
        _replyInfoView.bottom = kAppScreenHeight - _toolbar.height + 6;
        msgInfoView.bottom = _replyInfoView.top;
    } else {
        [_inputbar focus];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (_scrollView.contentOffset.x <= 0) {
        return YES;
    }
    
    return NO;
}

- (void)showError:(NSString *)errCode {
    if (errCode) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:errCode toUrl:nil mode:SNCenterToastModeOnlyText];
    } else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSendFailed", nil) toUrl:nil mode:SNCenterToastModeWarning];
    }
}

//#pragma mark - asi http delegate
//- (void)requestFinished:(ASIHTTPRequest *)request {
//    SNDebugLog(@"%d, %@", request.responseStatusCode, request.responseString);
//    BOOL bSuccess = NO;
//    NSString *errCode = nil;
//    
//    NSString *jsonString = [[request responseString] copy];
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    id rootData = [jsonData yajl_JSON];
//    
//    if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
//        SNDebugLog(@"%@", rootData);
//        NSString *isSuccess = [rootData stringValueForKey:@"isSuccess" defaultValue:nil];
//        if ([isSuccess caseInsensitiveCompare:@"S"] == NSOrderedSame) {
//            bSuccess = YES;
//        } else if ([isSuccess caseInsensitiveCompare:@"F"] == NSOrderedSame) {
//            bSuccess = NO;
//            errCode = [rootData stringValueForKey:@"error" defaultValue:nil];
//        }
//    }
//    
//    if (bSuccess) {
//        NSString *txt = [request.userInfo objectForKey:@"cont"];
//        if ([txt isEqualToString:@"撒花"]) {
//            [self strewFlowers];
//        }
//
//        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"messageSent", @"messageSent") toUrl:nil mode:SNCenterToastModeSuccess];
//        
//        SNLiveCommentType type = (SNLiveCommentType)[request.userInfo intValueForKey:@"comType" defaultValue:SNLiveCommentTypePicAndTxt];
//        [_inputbar postSucccess:type];
//        [SNUtility requestRedPackerAndCoupon:[_liveId URLEncodedString] type:@"3"];
//    } else {
//        [self showError:errCode];
//        
//        NSString *txt = [request.userInfo objectForKey:@"cont"];
//        [_inputbar postFailure:txt];
//    }
//}
//
//- (void)requestFailed:(ASIHTTPRequest *)request {
//    [self showError:nil];
//    
//    NSString *txt = [request.userInfo objectForKey:@"cont"];
//    [_inputbar postFailure:txt];
//}

#pragma mark - loading status
- (void)showLoading {
	if (!_loadingView) {
		_loadingView = [[SNEmbededActivityIndicatorEx alloc] initWithFrame:CGRectZero andDelegate:self];
        _loadingView.hidesWhenStopped = YES;
        _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
	}
    
	[_loadingView setFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
}

- (void)hideLoading {
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [_loadingView removeFromSuperview];
}

- (void)showError {
    _loadingView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [self.view addSubview:_loadingView];
        [self.view bringSubviewToFront:_toolbar];
    }
}

- (void)hideError {
    _loadingView.status = SNEmbededActivityIndicatorStatusInit;
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry
{
    [self refreshLiveInfo];
}

#pragma mark - SNLiveToolbarDelegate

- (void)liveToolBarBack {
    [self onBack:nil];
}

- (void)liveToolBarInput {
    [SNUtility shouldUseSpreadAnimation:NO];
    if (![SNUserManager isLogin]){
        [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_LIVE referId:_liveId referAct:SNReferActCommentText];
        [self liveInputBarDoLogin];
        [SNUtility setUserDefaultSourceType:kUserActionIdForLiveChat keyString:kLoginSourceTag];
        return;
    }
    else {
        //BOOL isOpenMobileBind = [SNUtility isOpenMobileBindSwitch:kUserActionIdForLiveChat];
//        SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
//        if (!userInfoEx.isRealName) {
//            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle", nil];
//            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
//            [[TTNavigator navigator] openURLAction:_urlAction];
//        }
//        else {
            _inputbar.hidden = NO;
            [_inputbar focus];
//        }
    }
}

- (BOOL)liveToolBarCanRec:(BOOL)showMsg {
    if ([_infoObject isForbiddenAudio]) {
        if (showMsg) {
            NSString *hint = _infoObject.comtHint.length > 0 ? _infoObject.comtHint : NSLocalizedString(@"audioCommentIsForbidden", nil);
            [[SNCenterToast shareInstance] showCenterToastWithTitle:hint toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        return NO;
    }
    return YES;
}

- (void)liveToolBarStat {
    [self showLiveStatistics:nil];
}

- (void)liveToolBarShare {
    [self shareAction:nil];
}

- (void)liveToolBarRecBtnLongPressBegin {
    if ([_infoObject isForbiddenAudio]) {
        NSString *hint = _infoObject.comtHint.length > 0 ? _infoObject.comtHint : NSLocalizedString(@"audioCommentIsForbidden", nil);
        [[SNCenterToast shareInstance] showCenterToastWithTitle:hint toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }

    if (![SNUserManager isLogin]) {
        [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_LIVE referId:_liveId referAct:SNReferActCommentAudio];
        [self liveInputBarDoLogin];
        return;
    }
    else {
        //BOOL isOpenMobileBind = [SNUtility isOpenMobileBindSwitch:kUserActionIdForLiveChat];
//        SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
//        if (!userInfoEx.isRealName) {
//            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle", nil];
//            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
//            [[TTNavigator navigator] openURLAction:_urlAction];
//            return;
//        }
    }
    
    // 检查系统是否授权录音
    BOOL bHaveMicPermission = [SNSoundManager isMicrophoneEnabled];
    if (!bHaveMicPermission) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"MicrophoneForbidden", nil) toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    
    // 录音遮罩
    [self addRecHUD];
    
    // 开始录音
    [self startRecord];
    
    canNotSend = NO;
}

- (void)liveToolBarRecBtnLongPressEnd {
    // 移除录音遮罩
    [self removeRecHUD];
    if (_recorder && _recorder->IsRunning()) {
        // 录音结束
        [self stopRecord];
        
        float dur = _recorder->GetFileDuration();
        BOOL bInvalid = dur < AUDIO_REC_MIN_DUR;
        
        // 发送录音
        if (canNotSend || bInvalid) {
            if (self.audioFilePath) {
                [[NSFileManager defaultManager] removeItemAtPath:self.audioFilePath error:nil];
            }
            if (bInvalid) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"audioDurationTooShort", nil) toUrl:nil mode:SNCenterToastModeWarning];
            }
        } else {
            if (self.audioFilePath) {
                SNDebugLog(@"fileSize: %d", [NSString getFileSize:self.audioFilePath]);
            }
            
            [self postComment:nil liveId:_liveId type:SNLiveCommentTypeAudio];
        }
    }
    [self clearMyAudioComment];
}

#pragma mark - SNLiveInputBarDelegate
- (void)liveInputBarDoLogin {
    // 收起输入框
    [self maskViewDidTapped:nil];
    
    [SNGuideRegisterManager showGuideWithContentComment:kLoginFromLive];
}

- (void)liveInputBarPostImageDoLogin {
    [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_LIVE referId:_liveId referAct:SNReferActCommentPic];
    [self liveInputBarDoLogin];
}

- (void)liveInputBarDoPost {
    if (_inputbar.strContent.length > 0 || _inputbar.editedImage != nil) {
        // 收起输入框
        [self maskViewDidTapped:nil];
        [self postComment:_inputbar.strContent liveId:_liveId type:SNLiveCommentTypePicAndTxt];
        [self clearMyComment];
    } else {
    }
}

- (void)liveInputBarDoImagePick {
    _picInputView.hidden = NO;
    _emoInputView.hidden = YES;
}

- (void)liveInputBarDoEmoPick {
    _emoInputView.hidden = NO;
    _picInputView.hidden = YES;
    [_inputbar changeTextColorToGray:_emoInputView.currentType==SNEmoticonDynamic];
}

- (void)liveInputBarDoRecord {
    // 收起输入框
    [self maskViewDidTapped:nil];
    [_toolbar onRecBtn:nil];
}

- (BOOL)liveInputBarImageAllowed:(BOOL)showMsg {
    if ([_infoObject isForbiddenPic]) {
        if (showMsg) {
            NSString *hint = _infoObject.comtHint.length > 0 ? _infoObject.comtHint : NSLocalizedString(@"picCommentIsForbidden", nil);
            [[SNCenterToast shareInstance] showCenterToastWithTitle:hint toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        return NO;
    }
    return YES;
}

- (void)liveInputBarFrameChanged:(CGRect)frame {
    _replyInfoView.bottom = _inputbar.top + kReplyInfoViewOffset;
    UIView *msgInfoView = [self msgInfoView];
    msgInfoView.bottom = _replyInfoView ? _replyInfoView.top : _inputbar.top + kReplyInfoViewOffset;
}

#pragma mark - Keyboard notification methods
- (void) keyboardWillAppear:(NSNotification*)notification {
    self.isShowKeyBoard = YES;
    [self addMaskView];
    [self addReplyInfoView:self.replyName];
    UIView *msgInfoView = [self msgInfoView];
    
    //Get begin, ending rect and animation duration
    CGRect beginRect = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //Transform rects to local coordinates
    beginRect = [self fixKeyboardRect:beginRect];
    endRect = [self fixKeyboardRect:endRect];
    
    CGRect selfEndingRect = CGRectMake(endRect.origin.x,
                                       endRect.origin.y - _inputbar.frame.size.height,
                                       endRect.size.width,
                                       _inputbar.frame.size.height);

    [_inputbar setHidden:NO];
    [_picInputView setHidden:NO];
    
    if (animDuration == 0) {
        _inputbar.frame = selfEndingRect;
        _picInputView.top = selfEndingRect.origin.y + selfEndingRect.size.height;
        _emoInputView.top = selfEndingRect.origin.y + selfEndingRect.size.height;
        _replyInfoView.bottom = selfEndingRect.origin.y + kReplyInfoViewOffset;
        msgInfoView.bottom = _replyInfoView ? _replyInfoView.top : _inputbar.top + kReplyInfoViewOffset;
        return;
    }
    
    [UIView animateWithDuration:animDuration
                     animations:^(void){
                         _inputbar.frame = selfEndingRect;
                         _inputbar.alpha = 1.0f;
                         _picInputView.top = selfEndingRect.origin.y + selfEndingRect.size.height;
                         _emoInputView.top = selfEndingRect.origin.y + selfEndingRect.size.height;
                         _replyInfoView.bottom = selfEndingRect.origin.y + kReplyInfoViewOffset;
                         msgInfoView.bottom = _replyInfoView ? _replyInfoView.top : _inputbar.top + kReplyInfoViewOffset;
                     }];
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    //Get begin, ending rect and animation duration
    self.isShowKeyBoard = NO;
    CGRect beginRect = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //Transform rects to local coordinates
    beginRect = [self fixKeyboardRect:beginRect];
    endRect = [self fixKeyboardRect:endRect];
    
    CGRect selfEndingRect = CGRectMake(endRect.origin.x,
                                       endRect.origin.y - _inputbar.frame.size.height,
                                       endRect.size.width,
                                       _inputbar.frame.size.height);
    
    UIView *msgInfoView = [self msgInfoView];
    
    if (!_inputbar.pickingImage) {
        [UIView animateWithDuration:animDuration
                         animations:^(void){
                             _inputbar.frame = selfEndingRect;
                             _inputbar.alpha = 0.0f;
                             _picInputView.top = selfEndingRect.origin.y + selfEndingRect.size.height;
                             _emoInputView.top = selfEndingRect.origin.y + selfEndingRect.size.height;
                             _replyInfoView.bottom = endRect.origin.y - _toolbar.height + 6;
                             msgInfoView.bottom = _replyInfoView ? _replyInfoView.top : endRect.origin.y - _toolbar.height + 6;
                         }];
    } else {
        [UIView animateWithDuration:animDuration
                         animations:^(void) {
                             _inputbar.top = endRect.origin.y - _picInputView.height - _inputbar.height;
                             _picInputView.top = endRect.origin.y - _picInputView.height;
                             _emoInputView.top = endRect.origin.y - _picInputView.height;
                             _replyInfoView.bottom = endRect.origin.y - _picInputView.height - _inputbar.height + kReplyInfoViewOffset;
                             msgInfoView.bottom = _replyInfoView ? _replyInfoView.top : endRect.origin.y - _picInputView.height - _inputbar.height + kReplyInfoViewOffset;
                         }];
    }
}

- (CGRect)fixKeyboardRect:(CGRect)originalRect {
    //Get the UIWindow by going through the superviews
    UIView * referenceView = _inputbar.superview;
    while ((referenceView != nil) && ![referenceView isKindOfClass:[UIWindow class]]) {
        referenceView = referenceView.superview;
    }
    
    //If we finally got a UIWindow
    CGRect newRect = originalRect;
    if ([referenceView isKindOfClass:[UIWindow class]]){
        //Convert the received rect using the window
        UIWindow *myWindow = (UIWindow *)referenceView;
        newRect = [myWindow convertRect:originalRect toView:_inputbar.superview];
    }
    
    return newRect;
}

- (void)hideInputBar {
    _inputbar.pickingImage = NO;
    CGFloat applicationFrameH = kAppScreenHeight;
    CGFloat applicationFrameW = kAppScreenWidth;
    CGRect selfEndingRect = CGRectMake(0,
                                       applicationFrameH - _inputbar.frame.size.height,
                                       applicationFrameW,
                                       _inputbar.frame.size.height);
    
    UIView *msgInfoView = [self msgInfoView];
    
    //Animate view
    [UIView animateWithDuration:0.25f
                     animations:^(void){
                         _inputbar.frame = selfEndingRect;
                         _inputbar.alpha = 0.0f;
                         _picInputView.top = applicationFrameH +20;
                         _emoInputView.top = applicationFrameH +20;
                         _replyInfoView.bottom = applicationFrameH - _toolbar.height + 6;
                         msgInfoView.bottom = _replyInfoView ? _replyInfoView.top : applicationFrameH - _toolbar.height + 6;
                     }];
}


#pragma mark -
#pragma mark SNCommentImageInputViewDelegate
- (void)commentImageFromCamera {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kCameraDenyAlertText message:@"" delegate:nil cancelButtonTitle:kCameraDenyAlertConfirm otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    else
        [[SNStatusBarMessageCenter sharedInstance] setAlpha:0];
    
    SNImagePickerController *imagePicker = [[SNImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)commentImageFromPhotoLibrary
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;
    if ([picker respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
        [picker performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    else
        [picker dismissViewControllerAnimated:YES completion:nil];
    
    [[SNStatusBarMessageCenter sharedInstance] setAlpha:1];
    
    //确保view已经Load
    [self view];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        //等拍照视图消失再设置图像
        [_inputbar performSelector:@selector(setInputImage:) withObject:image afterDelay:0.2];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;

    if ([picker respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
        [picker performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    else
        [picker dismissViewControllerAnimated:YES completion:nil];

    [[SNStatusBarMessageCenter sharedInstance] setAlpha:1];
}

#pragma mark - 录音
- (void)startRecord {
    [[SNSoundManager sharedInstance] stopAll];
    [[SNSoundManager sharedInstance] setSndItemNextToPlay:nil];
    
    [SNNotificationManager postNotificationName:kSNLiveBannerViewPauseVideoNotification object:nil];
    
    //Start the recorder
    NSString *name = [NSDate stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
    name = [name stringByAppendingString:@".amr"];
    
    self.audioFilePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:name];
    
    if (_recorder) {
        _recorder->StartRecord((__bridge CFStringRef)self.audioFilePath);
    }
    
    [self startLevelMeterTimer];
}

- (void)stopRecord {
    [_updateTimer invalidate];

    if (_recorder) {
        _recorder->StopRecord();
    }
    
    [_hud setLevelMeterDB:0];
    
    [SNNotificationManager postNotificationName:kSNLiveBannerViewResumeVideoNotification object:nil];
}

- (void)startLevelMeterTimer {
    if (_updateTimer) {
        [_updateTimer invalidate];
    }
    
    _updateTimer = [NSTimer
                     scheduledTimerWithTimeInterval:0.2
                     target:self
                     selector:@selector(refreshLevelMeter)
                     userInfo:nil
                     repeats:YES];
}

- (void)refreshLevelMeter {
    float avgPower = 0, peakPower = 0;
    if (_recorder == NULL) {
        return;
    }
    
    _recorder->UpdateLevelMeter(&avgPower, &peakPower);
    [_hud setTime:[NSString stringWithFormat:@"%d''", (int)_recorder->GetFileDuration()]];
    [_hud setLevelMeterDB:avgPower];
    
    // 超过60s强制结束
    CGFloat maxRecTimeDur = MAX_REC_TIME_DUR;
    if (_infoObject.ctrlInfo.compAudLen > 0) {
        maxRecTimeDur = _infoObject.ctrlInfo.compAudLen;
    }
    if (_recorder && _recorder->GetFileDuration() >= maxRecTimeDur) {
        [self liveToolBarRecBtnLongPressEnd];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"语音已达最大长度" toUrl:nil mode:SNCenterToastModeWarning];
    }
}

#pragma mark - HUD
- (void)addRecHUD {
    if (!_hud) {
        _hud = [[SNLiveRecHUD alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_hud];
        
        [self addScreenTouchObserver];
    }
}

- (void)removeRecHUD {
    if (_hud) {
        [_hud removeFromSuperview];
        _hud = nil;
    }
}

#pragma mark - 移除触摸观察者
- (void)removeScreenTouchObserver {
    [SNNotificationManager removeObserver:self name:@"nScreenTouch" object:nil];//移除nScreenTouch事件
    
    SNWindow *window = (SNWindow *)[SNUtility getApplicationDelegate].window;
    window.listenScreenTouch = NO;
}
#pragma mark - 添加触摸观察者
- (void)addScreenTouchObserver {
    SNWindow *window = (SNWindow *)[SNUtility getApplicationDelegate].window;
    window.listenScreenTouch = YES;
    
    [SNNotificationManager addObserver:self selector:@selector(onScreenTouch:) name:@"nScreenTouch" object:nil];
}

- (void)onScreenTouch:(NSNotification *)notification {
    UIEvent *event=[notification.userInfo objectForKey:@"data"];
    NSSet *allTouches = event.allTouches;
    
    //如果未触摸或只有单点触摸
    if ((curTouchPoint.x == CGPointZero.x &&
         curTouchPoint.y == CGPointZero.y) || allTouches.count == 1) {
        [self transferTouch:[allTouches anyObject]];
    } else {
        //遍历touch,找到最先触摸的那个touch
        for (UITouch *touch in allTouches){
            CGPoint prePoint = [touch previousLocationInView:nil];
            
            if (prePoint.x == curTouchPoint.x && prePoint.y == curTouchPoint.y)
                [self transferTouch:touch];
        }
    }
}
//传递触点
- (void)transferTouch:(UITouch*)_touch{
    CGPoint point = [_touch locationInView:nil];
    switch (_touch.phase) {
        case UITouchPhaseBegan:
            [self touchBegan:point];
            break;
        case UITouchPhaseMoved:
            [self touchMoved:point];
            break;
        case UITouchPhaseCancelled:
        case UITouchPhaseEnded:
            [self touchEnded:point];
            break;
        default:
            break;
    }
}
#pragma mark - 触摸开始
- (void)touchBegan:(CGPoint)_point{
    curTouchPoint = _point;
}

#pragma mark - 触摸移动
- (void)touchMoved:(CGPoint)_point{
    curTouchPoint = _point;
    //判断是否移动到取消区域
    canNotSend = _point.y < kCancelOriginY ? YES : NO;
    
    //设置取消动画
    [_hud changeToCancelState:canNotSend];
}

#pragma mark - 触摸结束
- (void)touchEnded:(CGPoint)_point {
    curTouchPoint = CGPointZero;
    [self removeScreenTouchObserver];
    
    [self liveToolBarRecBtnLongPressEnd];
}

#pragma mark -
- (void)addReplyInfoView:(NSString *)replyName {
    if (replyName.length == 0) {
        return;
    }
    
    if (_replyInfoView == nil) {
        _replyInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height-43-33, self.view.width, 33)];
        _replyInfoView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [self.view addSubview:_replyInfoView];
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.width, 33)];
        info.backgroundColor = [UIColor clearColor];
        info.font = [UIFont systemFontOfSize:14];
        info.textColor = [UIColor whiteColor];
        info.text = [NSString stringWithFormat:@"回复%@：", replyName];
        info.tag = 101;
        [_replyInfoView addSubview:info];
        
        //关闭按钮
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"toast_close.png"] forState:UIControlStateNormal];
        closeBtn.frame = CGRectMake(_replyInfoView.width - 45, (_replyInfoView.height-45) / 2, 45, 45);
        [closeBtn addTarget:self action:@selector(clearMyCommentByClickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        [_replyInfoView addSubview:closeBtn];
    } else {
        UILabel *info = (UILabel *)[_replyInfoView viewWithTag:101];
        info.text = [NSString stringWithFormat:@"回复%@：", replyName];
        [self.view bringSubviewToFront:_replyInfoView];
    }
}

- (void)removeReplyInfoView {
    if (_replyInfoView) {
        UIView *msgInfoView = [self msgInfoView];
        msgInfoView.bottom = _replyInfoView.bottom;
        [_replyInfoView removeFromSuperview];
        _replyInfoView = nil;
    }
}

- (void)strewFlowers {
    if (_flowersFallView == nil) {
        _flowersFallView = [[SNLiveFlowersFallView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_flowersFallView];
    }
    [_flowersFallView strewFlowers];
}

#pragma mark - Private
- (void)handleBannerVideoDidPlayNotification:(NSNotification *)notification {
    [_shortVideoPlayer pause];
}

- (void)handleClickAudioViewInLiveCellNotification:(NSNotification *)notification {
    [_shortVideoPlayer pause];
}

- (void)resetShortVideoPlayer {
    [_shortVideoPlayer hideTitleAndControlBarWithAnimation:NO];
    [_shortVideoPlayer stop];
    [_shortVideoPlayer clearMoviePlayerController];
    [[SNLiveRoomContentCellVideoCache sharedInstance] setPlayingVideoKey:nil];
}

#pragma mark - About Video progress slider
- (void)videoProgressBarBeginSlide:(NSNotification *)notification {
}

- (void)videoProgressBarEndSlide:(NSNotification *)notification {
}

- (void)videoProgressBarCancelSlide:(NSNotification *)notification {
}


#pragma mark - SNLiveRoomTopInfoViewDelegate
- (void)expandTopInfoViewFromHeight:(CGFloat)fromH toHeight:(CGFloat)toH {
    [UIView animateWithDuration:kSNLiveRoomTopInfoViewAnimationDuration animations:^{
        [self layoutTableView:fromH toHeight:toH];
    }];

    //展开置顶
    if (toH > fromH) {
        [self topInfoExposure];
    }
}

#pragma mark - SNNavigationController
- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    if (_scrollView.contentOffset.x <= 0) {
        if ([_inputbar isFirstResponder]) {
            return NO;
        } else {
            if (!_inputbar.hidden && _inputbar.alpha > 0) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)shouldRecognizerPanGesture:(UIPanGestureRecognizer*)panGestureRecognizer {
    if (_scrollView.contentOffset.x <= 0 && ![_inputbar isFirstResponder] && (_inputbar.hidden || _inputbar.alpha == 0)) {
        return YES;
    }
    return NO;
}

#pragma mark - 消息提醒
- (void)showBubbleMessage:(NSString *)msg {
    UIView *msgInfoView = [UIView viewForMessage:msg image:nil activity:NO];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(msgInfoViewTapped:)];
    tap.delegate = self;
    [msgInfoView addGestureRecognizer:tap];
    
    float bottom;
    if (_inputbar.pickingImage || [_inputbar isFirstResponder]) {
        bottom = _replyInfoView ? _replyInfoView.top : _inputbar.top;
    } else {
        bottom = _replyInfoView ? _replyInfoView.top : _toolbar.top + 6;
    }
    [self.view showToast:msgInfoView
                duration:5
                position:[NSValue valueWithCGPoint:CGPointMake(160, bottom-msgInfoView.height/2)]
               rightIcon:@"toast_arrow.png"];
    msgInfoView.tag = kLiveMsgInfoViewTag;
}

- (UIView *)msgInfoView {
    UIView *msgInfoView = [self.view viewWithTag:kLiveMsgInfoViewTag];
    return msgInfoView;
}

- (void)msgInfoViewTapped:(id)sender {
    [self.view closeToast];
    
    if(![SNUserManager isLogin])
    {
        [SNGuideRegisterManager myMessage];
    } else {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], @"showNotification", nil];
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://myMessage"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:_urlAction];
        _lastMsgCount = 0;
    }
}

- (void)onBubbleMessageChange {
    int msgCount = [SNBubbleNumberManager shareInstance].livemsg;
    if (msgCount > 0 && msgCount != _lastMsgCount) {
        _lastMsgCount = msgCount;
        NSString *msg;
        if (msgCount > 99) {
            msg = @"您收到了99+条新消息";
        } else {
            msg = [NSString stringWithFormat:@"您收到了%d条新消息", msgCount];
        }
        [self showBubbleMessage:msg];
    }
}

#pragma mark - 直播邀请
// 弹框选择‘接受’or‘拒绝’
- (void)showInviteActionSheet:(NSString *)titleString
                      content:(NSString *)contentString {
    SNActionSheet *actionSheet = [[SNActionSheet alloc] initWithTitle:titleString
                                                             delegate:self
                                                            iconImage:[SNUtility chooseActDefaultIconImage]
                                                              content:contentString
                                                           actionType:SNActionSheetTypeDefault
                                                    cancelButtonTitle:@"不再提醒我"
                                               destructiveButtonTitle:@"接受邀请"
                                                    otherButtonTitles:nil];
    actionSheet.tag = kLiveInviteAlertTag;
    actionSheet.disableDismissAction = YES;
    [[TTNavigator navigator].window addSubview:actionSheet];
    [actionSheet showActionViewAnimation];
}

- (void)dismissActionSheet {
    SNActionSheet *actionSheet = (SNActionSheet *)[[TTNavigator navigator].window viewWithTag:kLiveInviteAlertTag];
    if ([actionSheet isKindOfClass:[SNActionSheet class]]) {
        actionSheet.delegate = nil;
        [actionSheet closeAction];
    }
}

- (void)handleInviteMessage:(NSNotification *)notification {
    NSString *passport = [SNUserManager getUserId];
    if (passport.length > 0) {
        [self refreshLiveInviteStatus];
    }
}

- (BOOL)isLiveGameShowing:(NSString*)aLiveId {
    if ([aLiveId isEqualToString:_liveId]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - liveInviteModelDelegate
- (void)requestInviteStatusFinished:(SNLiveInviteStatusObj *)statusObj {
    if (statusObj) {
        // 更新邀请状态
        SNLiveInviteStatusObj *cachedStatusObj = [[SNDBManager currentDataBase] getLiveInviteItemByLiveId:statusObj.liveId passport:statusObj.passport];
        if ([statusObj.inviteStatus intValue] == LIVE_INVITING) {
            NSString *content = statusObj.showmsg;
            if (content.length == 0) {
                content = (cachedStatusObj.showmsg.length > 0 ? cachedStatusObj.showmsg : @"邀请您成为嘉宾");
                statusObj.showmsg = content;
            }
            [self showInviteActionSheet:@"直播邀请" content:content];
        } else if ([statusObj.inviteStatus intValue] == LIVE_INVITE_SUC) {
            //Toast提示
            if (statusObj.showmsg.length > 0) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:statusObj.showmsg toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
        [[SNDBManager currentDataBase] addOrUpdateLiveInviteItem:statusObj];
    }
}

- (void)requestInviteStatusFailedWithError:(NSError *)error {
    SNDebugLog(@"requestInviteStatusFailedWithError %@", error);
}

- (void)sendInviteFeedbackFinished:(SNLiveInviteStatusObj *)statusObj {
    SNDebugLog(@"sendInviteFeedbackFinished %@", statusObj);
    // 更新邀请状态
    [[SNDBManager currentDataBase] addOrUpdateLiveInviteItem:statusObj];
    
    // toast提示
    if (statusObj.showmsg.length > 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:statusObj.showmsg toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}

- (void)sendInviteFeedbackFailedWithError:(NSError *)error {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"邀请应答失败" toUrl:nil mode:SNCenterToastModeWarning];
}

#pragma mark - for 登陆拦截
- (void)onLiveChatTabDidSelected {
    // 这里什么也不做  其实就是给登陆拦截一个机会去拦截
}

#pragma mark - 统计

- (void)onliveBannerViewSizeChanged:(SNCCPVFuction)fun {
    SNUserTrack *userTrack = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], fun];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

#pragma mark - statusbar style

- (void)updateStatusBarStyle {
    if (self.liveBannerView.isWorldCup) {
        [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:YES];
    }
}

#pragma mark- emoticonScrollDelegate
- (void)emoticonDidSelect:(SNEmoticonObject *)emoticon {
    if (emoticon.type == SNEmoticonDynamic) {
        // 动态大表情直接发送
        // 收起输入框
        [self maskViewDidTapped:nil];
        [self postComment:emoticon.chineseName liveId:_liveId type:SNLiveCommentTypeDynamicEmo];
        
        //去掉回复
        [self clearReply];
    } else if (emoticon.type == SNEmoticonStatic) {
        //普通小表情将表情文本插入到textView中
        [_inputbar textViewInsertText:emoticon.chineseName];
    }

    [self emotionUserTrack:emoticon.type];
}

- (void)emoticonDidDelete {
    [_inputbar textViewDeleteEmoticon];
}

- (void)emoticonTabSelect:(SNEmoticonType)type {
    [_inputbar changeTextColorToGray:type==SNEmoticonDynamic];
}

#pragma mark - SNAdDataCarrierDelegate
- (void)adViewDidAppearWithCarrier:(SNAdDataCarrier *)carrier {
    if ([kSNAdSpaceIdLiveSponsorShip isEqualToString:carrier.adSpaceId] ||
        [kSNAdSpaceIdLiveSponsorShipTestServer isEqualToString:carrier.adSpaceId]) {
        carrier.blockId = self.livingGameItem.blockId ? : @"";
        //SDK广告加载统计
        [carrier reportForLoadTrack];
        self.liveBannerView.adDataSponsorShip = carrier;
    }
}

- (void)adViewDidFailToLoadWithCarrier:(SNAdDataCarrier *)carrier {
    if (self.sdkAdSponsorShip == carrier) {
        self.sdkAdSponsorShip.delegate = self;
        self.sdkAdSponsorShip = nil;
    }
    carrier.blockId = self.livingGameItem.blockId ? : @"";
    if (carrier.errorType == kStadErrorForNewsTypeNodata &&
        ([carrier.adSpaceId isEqualToString:@"12442"] ||
         [carrier.adSpaceId isEqualToString:@"12838"])) {
        //空广告统计
        [carrier reportForEmptyTrack];
    }
}

//置顶曝光统计
- (void)topInfoExposure {
    if (_infoObject.top.topLink.length > 0) {
        NSString *link = [_infoObject.top.topLink stringByAppendingString:@"&exposureFrom=8"];
        [[SNNewsExposureManager sharedInstance] exposureNewsInfoWithLink:link];
        _isTopInfoExposured = YES;
    }
}

//表情CC统计
- (void)emotionUserTrack:(SNEmoticonType)type {
    SNUserTrack *userTrack= [SNUserTrack trackWithPage:live link2:nil];
    NSInteger fun = 0;
    if (type == SNEmoticonDynamic) {
        fun = f_live_bigemotion;
    } else if (type == SNEmoticonStatic) {
        fun = f_live_smallemotion;
    }
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], fun];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

//退到后台后停止语音
- (void)handleEnterBackgroundNotification {
    [[SNSoundManager sharedInstance] stopAll];
    [SNNotificationManager removeObserver:self name:kFromPushOpenShareFloatViewNotification object:nil];
}

- (void)viewControllerWillResignActive {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval stime  = currentTime - [[SNAnalytics sharedInstance] startTime];
    [SNNewsReport reportADotGif:[NSString stringWithFormat:kLiveRoomDuration, self.liveId, stime, [SNUtility getCurrentChannelId]]];
}

- (void)openShareFloatView {
    self.newsfrom = kPushShareNews;
    [self shareAction:nil];
}

@end
