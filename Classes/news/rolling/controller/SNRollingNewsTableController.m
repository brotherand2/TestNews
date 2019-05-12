//
//  SNRollingNewsTableController.m
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsTableController.h"
#import "SNRollingNewsViewController.h"
#import "SNRollingNewsTableItem.h"
#import "SNNewsTableViewDelegate.h"
#import "SNTabBarItem.h"
#import "SNChannel.h"
#import "SNRollingNewsModel.h"
#import "SNRollingNewsTableCell.h"
#import "UIColor+ColorUtils.h"
#import "SNChannelScrollTabBarDataSource.h"
#import "SNRollingPhotoNewsTableCell.h"
#import "SNSearchHotV6Request.h"
#import "NSDictionaryExtend.h"
#import "SNTableHeaderDragRefreshView.h"
#import "SNPhotoTableCell.h"

#import "SNNewsDataSourceFactory.h"
#import "SNNewsTableViewDelegateFactory.h"
#import "SNUserLocationManager.h"
#import "UITableViewCell+ConfigureCell.h"
#import "SNNewsExposureManager.h"
#import "SNAppConfigManager.h"
#import "SNAppConfigActivity.h"
#import "SNRollingNewsPublicManager.h"
#import "SNCommonNewsDatasource.h"
#import "SNRollingNewsSubscribeDataSource.h"
#import "SNStatisticsManager.h"
#import "SNListenNewsGuideView.h"
#import "SNNewsSpeakerManager.h"
#import "SNRollingChannelWebViewController.h"
#import "UITableViewCell+ConfigureCell.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNNewsAd+analytics.h"
#import "SNTwinsLoadingView.h"
#import "SNTripletsLoadingView.h"

#import "SNPullAdData.h"
#import "SNPullDownAdManager.h"
#import "SNStatisticsManager.h"
#import "SNAdStatisticsManager.h"
#import "SNDynamicPreferences.h"
#import "SNCheckManager.h"
#import "TMCache.h"

#import "SNLocalChannelListViewController.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNCommonNewsController.h"
#import "SNWebController.h"
#import "SNRollingnewsMySubscribeCell.h"
#import "UIHomePageSearchBar.h"
#import "SNNewsReport.h"
#import "SNUserManager.h"
#import "SNUserRedPacketView.h"
#import "SNRedPacketManager.h"
#import "SNAppConfigFloatingLayer.h"
#import "UIButton+WebCache.h"
#import "SNNovelEntranceView.h"
#import "SNRollingPageViewCell.h"
#import "SNRollingTrainFocusCell.h"
#import "SNRollingAdIndividuationCell.h"
#import "SNLoadingImageAnimationView.h"
#import "SNStoryUtility.h"
#import "SNSpecialActivity.h"
#import "SNBookShelf.h"
#import "SNSubRollingNewsModel.h"

#define kPopOverViewWidth ((kAppScreenWidth > 375) ? 900.0/3 : ((kAppScreenWidth == 320) ? 570.0/2 : 580.0/2))
#define kPopOverViewHeight ((kAppScreenWidth > 375) ? 182.0/3 : ((kAppScreenWidth == 320) ? 100.0/2 : 105.0/2))

#import "SNNewsLoginManager.h"

#define kChannelBarHeight           66 / 2
#define kTableTopMargin             kChannelBarHeight / 4
#define kDefaultHeaderVisibleHeight 120.f
//#define kDefaultContentOffsetHeight 64.f   //@qz  适配iPhone X
#define kDefaultContentOffsetHeight         ([[SNDevice sharedInstance] isPhoneX] ? 88 : 64)
#define kFullScreenDefaultContentOffsetHeight         ([[SNDevice sharedInstance] isPhoneX] ? 34 : 10)

#define kShowListenNewsTips         @"kShowListenNewsTips"
#define kPullAdIsEmpty              (2)
#define kOffsetYValue               17
#define kDefaultOffsetHeight        0.f

@interface SNRollingNewsTableController ()<SNPullDownAdManagerDelegate> {
    SNListenNewsGuideView *_guideView;
    SNTripletsLoadingView *_tripletsLoadingView;
    UIView *_pullAdMaskMode;
    BOOL pullAdisNull;
    BOOL _isFullscreenMode;
    NSIndexPath *_indexPath;
    NSDictionary *_articleDict;
    BOOL _isNewsController;
    UIButton *_redPacketBtn;
    SNLoadingImageAnimationView *_animationImageView;
}

@property (nonatomic, assign) int firstCellIndex;
@property (nonatomic, strong) SNAnalyticsRollingSlideTimer *analyticsTimer;
@property (nonatomic, strong) NSString *year2015ImgName;
@property (nonatomic, strong) SNWebImageView *pullDownADView;
@property (nonatomic, strong) SNPullDownAdManager * pullAdManager;
@property (nonatomic, copy) NSString *pullAdUrl;
@property (nonatomic, strong) SNPullAdData *adData;
@property (nonatomic, strong) UIView *tableBGView;
@property (nonatomic, strong) SNPopoverView *popOverView;
@property (nonatomic, strong) UIHomePageSearchBar *searchBar;
@property (nonatomic, assign) BOOL homePageReset; //推荐流重置
@property (nonatomic, strong) NSArray *hotSearchWrods;
@property (nonatomic, strong) SNRollingChannelWebViewController *channelWebController;

@end

BOOL _hasReportNullAd = NO;
BOOL _hasReportLoadAd = NO;
BOOL _hasReportShowAd = NO;
BOOL _pullAdSwitchOpen = YES;

@implementation SNRollingNewsTableController
@synthesize tabBar;
@synthesize isViewAppeared;
@synthesize needForceLoadLocal;
@synthesize currentMinTimeline;
@synthesize isViewReleased;
@synthesize lastIndexPath;
@synthesize parentViewControllerForModalADView;
@synthesize firstCellIndex;
@synthesize isReuse;
@synthesize isFromSub;
@synthesize isH5;
@synthesize isNewChannel;
@synthesize isPreloadChannel;
@synthesize searchVc = _searchVc;
@synthesize selectedChanneType = _selectedChanneType;
@synthesize redPacketBtn = _redPacketBtn;
@synthesize hotSearchWrods = _hotSearchWrods;
@synthesize isMixStream;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.selectedChannelId = [query stringValueForKey:kChannelId defaultValue:nil];
        _channelType = [query intValueForKey:@"channelType" defaultValue:0];
    }
    return self;
}

- (CGRect)rectForLoadingView {
    return CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight - kHeaderHeightWithoutBottom - kToolbarHeightWithoutShadow);
}

- (void)loadView {
    [super loadView];
    
    [SNNotificationManager addObserver:self selector:@selector(updateLocalChannel:) name:kRollingChannelUpdateLocalNotification object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(updateLocalChannel:) name:kRollingHouseChannelUpdateLocalNotification object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(closeNewsAD) name:kCloseNewsADNotify object:nil];
    [SNNotificationManager addObserver:self selector:@selector(toastRefreshNotification) name:kToastRefreshNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(couponReceiveSucces:) name:kJoinRedPacketsStateChanged object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(showRedPacketTheme:) name:kShowRedPacketThemeNotification object:nil];
    
    self.tableView.frame = self.view.bounds;
    UIEdgeInsets r = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, 0.f, 0.f);
    self.tableView.contentInset = r;
    
    if (self.isHomePage && _isFullscreenMode) {//huangzhen TODO...
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
    }else{
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kHeadSelectViewHeight, 0.f, kToolbarViewHeight, 0.f);
    }
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, kToolbarViewHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = bottomView;
    [self initTableBGView];
    [self pullADViewUpdateTheme];
}

- (SNRollingChannelWebViewController *)channelWebController {
    if (!_channelWebController) {
        _channelWebController = [[SNRollingChannelWebViewController alloc] init];
        _channelWebController.delegate = self;
        [self.view addSubview:_channelWebController.view];
    }
    return _channelWebController;
}

- (SNRollingChannelWebViewController *)getChannelWebController {
    return _channelWebController;
}

- (void)initTableBGView {
    _tableBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    _tableBGView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = _tableBGView;
    
    CGFloat yValue = (kDefaultContentOffsetHeight + 40.0f) + kOffsetYValue;
    _pullDownADView = [[SNWebImageView alloc] initWithFrame:CGRectMake(14.0f, yValue, kAppScreenWidth - 28.0f, (kAppScreenWidth - 28.0f) / 6.4f)];
    _pullDownADView.backgroundColor = [UIColor clearColor];
    _pullAdSwitchOpen = [[SNAppConfigManager sharedInstance] pullAdSwitchOpen];
    if (_pullAdSwitchOpen) {
        _pullDownADView.hidden = NO;
    } else {
        _pullDownADView.hidden = YES;
    }
    
    _pullAdMaskMode = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _pullDownADView.frame.size.width, _pullDownADView.frame.size.height)];
    _pullAdMaskMode.backgroundColor = [UIColor blackColor];
    _pullAdMaskMode.alpha = 0.5f;//下拉广告夜间模式
    _pullAdMaskMode.hidden = YES;
    [_pullDownADView addSubview:_pullAdMaskMode];
    [_tableBGView addSubview:_pullDownADView];
}

- (void)updateUITemplate {
    if (self.isHomePage && _isFullscreenMode) {//huangzhen TODO...
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
    }else{
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kHeadSelectViewHeight, 0.f, kToolbarViewHeight, 0.f);
    }
}

- (void)requestPullAd {
    _pullAdSwitchOpen = [[SNAppConfigManager sharedInstance] pullAdSwitchOpen];
    if (_pullAdSwitchOpen) {
        [self.pullAdManager startRequsetPullAdWithInfo:self.selectedChannelId];
        [self addADView];
    }
}

- (void)addADView {
    if (_pullAdSwitchOpen) {
        if (_pullDownADView) {
            _pullDownADView.hidden = NO;
        }
    } else {
        if (_pullDownADView){
            _pullDownADView.hidden = YES;
        }
    }
}

- (void)addAndShow2015YearBg {
    [self addADView];
    //只在首页显示
    if (![self isHomePage]) {
        if (self.year2015Bg != nil) {
            _year2015Bg.hidden = YES;
        }
        return;
    }
    
    BOOL add = [SNCheckManager checkDynamicPreferences];
    if (add && [self isHomePage]) {
        //王洋洋
        UIImage *bgImage = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"icohome_loading_v5.png" ImageSize:CGSizeMake(kAppScreenWidth - 28.0f, (kAppScreenWidth - 28.0f) / 6.4f)];
        if (nil != bgImage && bgImage.size.width > 0 && bgImage.size.height > 0) {
            if (nil == self.year2015Bg) {
                float scale = bgImage.size.height / bgImage.size.width;
                _year2015Bg = [[UIImageView alloc] initWithImage:bgImage];
                [_tableBGView addSubview:self.year2015Bg];

                self.year2015Bg.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.width * scale);
            } else {
                self.year2015Bg.image = bgImage;
            }
        }
        CGFloat contentOffsetHeight = (_isFullscreenMode && self.isHomePage) ? kFullScreenDefaultContentOffsetHeight : kDefaultContentOffsetHeight;
        CGFloat yValue = (contentOffsetHeight + 40.0f) + kOffsetYValue;
        if (_pullAdSwitchOpen && pullAdisNull == NO && _adData && _pullDownADView.image) {
            yValue = _pullDownADView.frame.origin.y + _pullDownADView.frame.size.height;
        }
        CGRect frame = self.year2015Bg.frame;
        frame.origin.y = yValue;
        self.year2015Bg.frame = frame;
        _year2015Bg.hidden = NO;
    } else {
        if (self.year2015Bg != nil) {
            _year2015Bg.hidden =YES;
        }
    }
    _year2015Bg.alpha = themeImageAlphaValue();
}

- (void)refreshH5WebView {
    if (self.isH5) {
        self.animationImageView.hidden = YES;
        [_channelWebController webViewReload];
    } else {
        self.animationImageView.hidden = NO;
    }
}

- (void)adViewAnimationStopped {
    isAnimating = NO;
}

- (BOOL)isHomePage {
    BOOL isHome = NO;
    if (self.selectedChannelId &&
        [self.selectedChannelId isEqualToString:@"1"]) {
        isHome = YES;
    }
    return isHome;
}

- (BOOL)isIntroPage {
    //判断推荐频道
    BOOL isIntro = NO;
    if (self.selectedChannelId &&
        [self.selectedChannelId isEqualToString:@"13557"]) {
        isIntro = YES;
    }
    return isIntro;
}

- (BOOL)isLocalPage {
    //判断本地频道
    BOOL isLocal = NO;
    if (self.selectedChannelId &&
        [self.selectedChannelId isEqualToString:kLocalChannelUnifyID]) {
        isLocal = YES;
    }
    return isLocal;
}

//区分是否为小说频道
- (BOOL)isNovelChannelPage {
    BOOL isNovelChannel = NO;
    //13555为测试环境小说频道id
    //960415为正式环境小说频道id
    if (self.selectedChannelId &&
        ([self.selectedChannelId isEqualToString:@"13555"] ||
         [self.selectedChannelId isEqualToString:@"960415"])) {
        isNovelChannel = YES;
    }
    return isNovelChannel;
}

- (void)deleteNewsCellWithIndex:(int)index {
    if ([self.dataSource isKindOfClass:[SNRollingNewsDataSource class]]) {
        SNRollingNewsDataSource *newsDataSource = (SNRollingNewsDataSource *)self.dataSource;
        if (newsDataSource.isEdit) {
            return;
        }        
        if (index >= 0 && index < [newsDataSource.items count]) {
            //删除News
            SNRollingNewsTableItem *deleteItem = [newsDataSource.items objectAtIndex:index];
            [newsDataSource.newsModel deleteNewsWithNews:deleteItem.news];
            
            //删除Item
            [newsDataSource.items removeObjectAtIndex:index];
            if (index < [deleteItem.dataSource.allList count]) {
                [deleteItem.dataSource.allList removeObjectAtIndex:index];
            }
            
            //删除数据库缓存
            [[SNDBManager currentDataBase] deleteRollingNewsListItemByChannelId:deleteItem.news.channelId newsId:deleteItem.news.newsId];
        }
        NSIndexPath *index1 = [NSIndexPath indexPathForItem:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[index1] withRowAnimation: UITableViewRowAnimationTop];
    }
}

- (void)updateLocalChannel:(NSNotification *)notification {
    if (nil != notification
        && nil != notification.object
        && [notification.object isKindOfClass:[NSNumber class]]
        && ((NSNumber *)notification.object).integerValue == 1) {
        return;
    }
    
    if (nil != self.dataSource &&
        [self.dataSource isKindOfClass:[SNRollingNewsDataSource class]]) {
        SNRollingNewsDataSource *model = (SNRollingNewsDataSource *)self.dataSource;
        //model.newsModel.isLocalChannel表示这个频道不是买房频道就是本地频道
        //![model.newsModel.channelId isEqualToString:[SNUserLocationManager sharedInstance].localChannelId]表示这不是一个本地频道
        //那么就只能是买房频道
        //你问我买房频道怎么办？ 简单，买房频道在showModel和SNRollingNewsViewController的kRollingChannelUpdateLocalNotification里
        if (model.newsModel.isLocalChannel) {
            BOOL isHousePro = [SNUserLocationManager isHouseProLocalTypeWithChannelId:model.newsModel.channelId];
            if (isHousePro) {
                if ([notification.name isEqual:kRollingHouseChannelUpdateLocalNotification]) {
                    //买房频道
                    [model.newsModel load:TTURLRequestCachePolicyNoCache more:NO];
                }
            } else if ([notification.name isEqual:kRollingChannelUpdateLocalNotification]) {
                //本地频道
                [self.tabBar resetCurrentTabTitle:model.newsModel.channelName];
                [[SNDBManager currentDataBase] clearRollingNewsListByChannelId:_selectedChannelId];
            }
        }
    }
}

- (void)showModel:(BOOL)show {
    //TODO:待优化
    //下拉刷新的时候清理视频, 上拉不处理
    if ([self.model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *curModel = (SNRollingNewsModel *)self.model;
        if ([curModel getAction] != 2) {
            //2为上拉操作
            [SNTimelineSharedVideoPlayerView forceStop];
            if ([curModel.channelId isEqualToString:@"13557"]) {
                [SNAutoPlaySharedVideoPlayer forceStopVideo];
            }
        }
        if ([SNNewsFullscreenManager manager].fullscreenMode && [self isHomePage] && !curModel.more) { // 需要展示全屏焦点图样式
            // 处理要闻显示全屏焦点图时，从频道管理切换后直接切换旧版，这时候fullscreenMode还是YES，导致tableview展示出错的问题
            if (self.isMixStream != 2) {
                [SNNewsFullscreenManager manager].fullscreenMode = NO;
                [self.tabBar changeFullScreenMode:NO];
                [self changeFullscreenMode:NO];
                CGFloat offSet = ([[SNDevice sharedInstance] isPhoneX] ? 88 : 64);
                [self.tableView setContentInset:UIEdgeInsetsMake(offSet, 0.f, 0.f, 0.f)];
                [self.tableView setContentOffset:CGPointMake(0, -offSet) animated:NO];
                SNDebugLog(@"changeFullscreenMode--- %@",self.tableView);
            } else {
                [self.tabBar changeFullScreenMode:YES];
                [self changeFullscreenMode:YES];
            }
        }
    }
    
    if (([self isHomePage] &&
         !_isFullscreenMode) ||
        [self isIntroPage] ||
        [self isNovelChannelPage]) {
        //首页和推荐页面频道添加搜索栏
        self.tableView.tableHeaderView = self.searchBar;
    }
    
    if ([self isHomePage] || [self isIntroPage]) {
        //刷新热词
        NSArray *hotWords = [SNRollingNewsPublicManager sharedInstance].searchHotWord;
        if (hotWords.count > 0) {
            self.hotSearchWrods = [SNRollingNewsPublicManager sharedInstance].searchHotWord;
            [self.searchBar refreshHotWord:[hotWords objectAtIndex:0]];
        }
    }
    if (_tripletsLoadingView) {
        //如果创建无网络页面, 可以加载数据, 把这个无网络界面放到后面
        _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
        [self.view sendSubviewToBack:_tripletsLoadingView];
    }
    if ([self isHomePage]) {// 记录首页上次请求时间
        [SNUserDefaults setObject:[NSDate date] forKey:kRequestHomePageTimeKey];
    }
    
    [super showModel:show]; //这里会调用heightForRow
    if ([SNNewsFullscreenManager manager].focusToTrain) {
        if ([self.model isKindOfClass:[SNSubRollingNewsModel class]]) {
            SNSubRollingNewsModel * subModel = (SNSubRollingNewsModel *)self.model;
            NSInteger topNewsCount = [subModel curTopNewsCnt];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:topNewsCount inSection:0];
            CGRect rectInTableView = [_tableView rectForRowAtIndexPath:indexPath];
            CGRect rect2 = [_tableView convertRect:rectInTableView toView:[_tableView superview]];
            CGFloat offsetY = rect2.origin.y - _tableView.contentInset.top*2 + 14;//14是火车卡片上边距
            [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:NO];
            [SNNewsFullscreenManager manager].focusToTrain = NO;
        }
    }
    
    [self showListenNewsTips];
    
    [self refreshActionNotification];
    
    if ([SNRedPacketManager sharedInstance].pullRedPacket) {
        [SNRedPacketManager sharedInstance].pullRedPacket = NO;
    }
    
    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = YES;
}

- (void)showListenNewsTips {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kShowListenNewsTips] && !_guideView) {
        return;
    }
}

#pragma mark -
#pragma mark SNAdBannerViewDelegate
- (void)didFinishLoadAds:(int)adsCount {
    if (isAnimating) {
        return;
    }
}

- (void)didTapCloseButton {
    [SNNotificationManager postNotificationName:kCloseNewsADNotify object:nil];
}

- (void)closeNewsAD {
    if (isAnimating) {
        return;
    }
}

#pragma mark -
#pragma mark DragRefresh
- (void)refresh {
    if ([self.model isMemberOfClass:[SNRollingNewsModel class]]
        && nil != _loadDelegate && ![_loadDelegate canLoadNews]) {
        return;
    }
    _flags.isViewInvalid = YES;
    _flags.isModelDidRefreshInvalid = YES;
    
    BOOL loading = self.model.isLoading;
    BOOL loaded = self.model.isLoaded;
    if (!loading && !loaded && [self shouldLoad]) {
        if (self.isNewChannel && [[SNAppStateManager sharedInstance] appFinishLaunchLoadNewsWithChannelId:_selectedChannelId]) {
            //流式频道保留最新20条缓存, 要闻频道（服务端默认流式）不按流式频道逻辑处理
            if (![self isHomePage]) {
                [[SNDBManager currentDataBase] clearAllOtherRollingNewsList:_selectedChannelId];
            }
        }
        
        //TODO:需要改进
        if (([self.model isKindOfClass:[SNRollingNewsModel class]] && ((SNRollingNewsModel *)self.model).isLocalChannel) && [[SNUserLocationManager sharedInstance] refreshFromNetwork]) {
            [self.model load:TTURLRequestCachePolicyNetwork more:NO];
        } else {
            [self.model load:TTURLRequestCachePolicyLocal more:NO];
        }
        
        BOOL needRequestNetwork = [_dragDelegate shouldRequestNetwork];
        if (needRequestNetwork) {
            [self.model load:TTURLRequestCachePolicyNetwork more:NO];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"slideToSubscribe"];
        }
    } else if (!loading && loaded && [self shouldReload]) {
        [self.model load:TTURLRequestCachePolicyNetwork more:NO];
    } else if (!loading && [self shouldLoadMore]) {
        [self.model load:TTURLRequestCachePolicyDefault more:YES];
    } else {
        _flags.isModelDidLoadInvalid = YES;
        if (_isViewAppearing) {
            [self updateView];
        }
    }
}
// 子类实现这个方法主要是为了解决火车卡片加载时出现的问题(火车卡片的model与频道流是同一个), 暂时这样处理, 待下期分离为两个model
- (void)updateView {
    SNNewsDataSource *ds = (SNNewsDataSource *)self.dataSource;
    if ([ds.model isKindOfClass:[SNSubRollingNewsModel class]]) {
        SNSubRollingNewsModel *model = (SNSubRollingNewsModel *)ds.model;
        if ([model getAction] == 3) return;
    }
    [super updateView];
}

- (BOOL)canShowModel {
    SNNewsDataSource *ds = (SNNewsDataSource *)self.dataSource;
    return ![ds isModelEmpty];
}

- (BOOL)shouldLoad {
    if (self.isH5) {
        return YES;
    }
    SNNewsDataSource *ds = (SNNewsDataSource *)self.dataSource;
    if ([ds.model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *model = (SNRollingNewsModel *)ds.model;
        if (model.rollingNews.count == 0) {
            return YES;
        }
    }
    return [ds isModelEmpty];
}

- (void)createModel {
    //TODO
    _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
    
    self.tableView.hidden = self.isH5 ? YES : NO;
    if (self.isH5) {
        [_dragDelegate setModel:nil];
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
        
        if (![SNRollingNewsPublicManager sharedInstance].isHaveAlreadyLoadH5Channel) {
            _channelWebController.dragLoadingView.hidden = YES;
            self.animationImageView.status = SNImageLoadingStatusLoading;
        }
        
        [self.channelWebController doRequest:[SNUtility sharedUtility].currentChannelId];
        return;
    } else {
        if (_channelWebController) {
            [_channelWebController.view removeFromSuperview];
            _channelWebController.delegate = nil;
            _channelWebController = nil;
        }
    }
    
    [self createDelegate];
    
    SNNewsDataSource *ds = [SNNewsDataSourceFactory dataSourceWithNewsChannelType:_channelType channelId:self.selectedChannelId channelName:self.tabBar.selectedTabItem.title isMixStream:self.isMixStream];

    if (ds) {
        _dragDelegate.dragLoadingView.hidden = YES;
        
        ds.controller = self;
        [_dragDelegate setModel:ds.model];
        
        SNNewsModel *model = (SNNewsModel *)ds.model;
        model.isPreloadChannel = isPreloadChannel;
        model.isFromSub = self.isFromSub;
        model.isNewChannel = self.isNewChannel;
        model.link = _url;
        model.isMixStream = self.isMixStream;
        self.dataSource = ds; //设置数据的地方
    }
}

- (void)recalculateCellHeight {
    if ([self.dataSource
         isKindOfClass:[SNRollingNewsDataSource class]]) {
        SNRollingNewsDataSource *tmpDataSource = (SNRollingNewsDataSource *)self.dataSource;
        int i = 0;
        for (SNRollingNewsTableItem *item in tmpDataSource.items) {
            Class cellClass = [tmpDataSource tableView:nil cellClassForObject:item];
            if ([cellClass respondsToSelector:@selector(calculateCellHeight:)]) {
                [cellClass calculateCellHeight:item];
                i++;
            }
        }
    }
}

- (void)reCreateModel {
    [self createModel];
}

- (void)processH5ChannelLoading {
    self.animationImageView.status = SNImageLoadingStatusStopped;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^() {
        _channelWebController.dragLoadingView.hidden = NO;
    });
    if ([SNUtility isNetworkReachable]) {
        [SNRollingNewsPublicManager sharedInstance].isHaveAlreadyLoadH5Channel = YES;
    } else {
        [self resetH5TripletsLoadingView];
    }
}

- (id<TTTableViewDelegate>)createDelegate {
    SNDragRefreshView *headView = nil;
    self.dragDelegate = [SNNewsTableViewDelegateFactory tableViewDelegateWithNewsChannelType:_channelType channelId:_selectedChannelId controller:self headView:headView];
    //5.0 新版下拉刷新
    if (!headView) {
        [self.dragDelegate hasNoCache];
        [self.dragDelegate setDragLoadingViewType:SNNewsDragLoadingViewTypeTwins];
    }
    
    [self resetTableDelegate:_dragDelegate];
	return (id)_dragDelegate;
}

- (void)didShowModel:(BOOL)firstTime {
    [super didShowModel:firstTime];
    
    if (isViewReleased) {
        if (lastIndexPath) {
            if (lastIndexPath.row < [self.tableView numberOfRowsInSection:0]) {
                [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            }
        }
        isViewReleased = NO;
    }
    lastIndexPath = nil;
}

- (void)setSelectedChannelId:(NSString *)selectedChannelId {
    for (SNChannel *channel in [[(SNChannelScrollTabBarDataSource *)self.tabBar.dataSource model] subedChannels]) {
        if ([channel.channelId isEqualToString:selectedChannelId]) {
            [SNUtility sharedUtility].currentChannelCategoryID = channel.channelCaterotyID;
            [SNRollingNewsPublicManager sharedInstance].newsSource = SNRollingNewsSourceClickChannel;
            if ([channel.channelType intValue] == NewsChannelTypeLive) {
                _channelType = NewsChannelTypeLive;
            } else if ([channel.channelType intValue] == NewsChannelTypeWeiboHot) {
                _channelType = NewsChannelTypeWeiboHot;
            } else if ([channel.channelType intValue] == NewsChannelTypePhotos) {
                _channelType = NewsChannelTypePhotos;
            } else {
                _channelType = NewsChannelTypeNews;
            }
            break;
        }
    }
    
    if (![_selectedChannelId isEqualToString:selectedChannelId]) {
        _selectedChannelId = selectedChannelId;
        [SNUtility sharedUtility].currentChannelId = _selectedChannelId;

    }
}

#pragma mark -
#pragma mark Tab select
- (BOOL)shouldBackToChannelTop {
    if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"] && _isFullscreenMode) {
        return NO;
    }
    //非相邻频道切换，频道置顶 王洋洋
    if ([SNRollingNewsPublicManager sharedInstance].isNeighChannel == NO) {
        return YES;
    }
    [SNRollingNewsPublicManager sharedInstance].isNeighChannel = NO;
    
    if ([SNRollingNewsPublicManager sharedInstance].isNeedToBackToTop) {
        [SNRollingNewsPublicManager sharedInstance].isNeedToBackToTop = NO;
        return YES;
    }
    
    return NO;
}

- (BOOL)shouldReloadLocalWithChannelId:(NSString *)channelId {
    //H5页面
    if (self.isH5 || _dragDelegate == nil) {
        return YES;
    }
    
    if ([SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow && [SNRollingNewsPublicManager sharedInstance].isClickBackToHomePage && [SNRollingNewsPublicManager sharedInstance].resetOpen) {
        if ([SNNewsFullscreenManager newsChannelChanged]) {
            //新版本避免请求两次
            if ([SNRollingNewsPublicManager sharedInstance].backToHomeAndRefreshForNewsChanged) {
                [SNRollingNewsPublicManager sharedInstance].backToHomeAndRefreshForNewsChanged = NO;
                return YES;
            }
        } else {
            return YES;
        }
    }
    
    BOOL needReloadLocal = [_dragDelegate shouldReloadLocalWithChannelId:channelId];
    if (needReloadLocal == NO) {
        //5.2.2 房产和本地切换城市的时候，刷新
        if ([SNRollingNewsModel isLocalChannel:channelId] &&
            [[SNUserLocationManager sharedInstance] canNotifyDefault]) {
            return YES;
        }
    }
    return needReloadLocal;
}

- (void)tabBar:(SNChannelScrollTabBar *)tabBar channelSelected:(SNChannel *)channel {
   [[SNRollingNewsPublicManager sharedInstance] recordRollingNewsBeginTime];
    
    [SNUtility sharedUtility].currentChannelId = channel.channelId;
    if ([SNRollingNewsPublicManager sharedInstance].touchChannel) {
        [SNRollingNewsPublicManager sharedInstance].touchChannel = NO;
    }
    [self updateUITemplate];
    if (channel && channel.channelId) {
        if ([channel.channelId isEqualToString:kLocalChannelUnifyID]) {
            SNChannel *saveChannel = [[SNChannel alloc] init];
            saveChannel.channelName = channel.channelName;
            saveChannel.channelId = channel.channelId;
            saveChannel.gbcode = channel.gbcode;
            [SNUtility saveHistoryShowWithChannel:channel isHouseChannel:NO];
        }
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if (![userDefault objectForKey:kRequestLocalChannelTimeKey]) {
            [userDefault setObject:[NSDate date]
                            forKey:kRequestLocalChannelTimeKey];
            [userDefault synchronize];
        }
        
        if ([channel.channelId isEqualToString:@"1"]) {
            if ([SNUtility needResetHomePageChannel]) {
                [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
            } else {
                if (!([SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow && [SNRollingNewsPublicManager sharedInstance].isClickBackToHomePage && [SNRollingNewsPublicManager sharedInstance].resetOpen)) {
                    [SNRollingNewsPublicManager sharedInstance].resetOpen = NO;
                }
            }
        }
        
        if (![self isHomePage] || ![channel isHomeChannel]) {
            [SNRollingNewsPublicManager sharedInstance].isHomePage = NO;
        } else {
            [SNRollingNewsPublicManager sharedInstance].isHomePage = YES;
        }
        
        isPreloadChannel = channel.isPreloadChannel;
        BOOL needReloadLocal = YES;
        self.isH5 = [channel isH5Channel];
        self.url = channel.link;
        self.isNewChannel = [channel isNewChannel];
        BOOL needBackToTop = [self shouldBackToChannelTop];
    
        needReloadLocal = [self shouldReloadLocalWithChannelId:channel.channelId];
        if (needReloadLocal == NO) {
            [self changeModelToNewChannel:channel];
        }
      
        if (([self isHomePage] && ![SNNewsFullscreenManager manager].isFullscreenMode) || [self isIntroPage]) {
            if (!self.searchBar) {
                [self initSearchBar];
            }
            //小说频道和推荐，要闻同一VC时，避免扫一扫丢失
            [self.searchBar hideQrCodeBtn:NO];
            
            //2017-04-24 wangchuanwen 5.8.9 begin
            //因为加了小说的热词，切回要闻、推荐，要刷新，而因要闻、推荐是两个不同的self，故而造成hotSearchWrods为nil
            if ([SNRollingNewsPublicManager needResetHotWords]) {
                [self p_updateHotWord];
            }
            //2017-04-24 wangchuanwen 5.8.9 end
            self.tableView.tableHeaderView = self.searchBar;
        } else if ([self isNovelChannelPage]) {
            //@qz 2017.4.12 小说增加搜索入口
            [self initSearchBar];
            [self customSetNovelHeader];
            [SNStoryUtility getNovelAchor];//获取小说锚点
            //小说热词搜索
            [SNUtility novelSearchHotWord:^(NSArray *hotNovelWords) {
                if (hotNovelWords && hotNovelWords.count > 0) {
                    [self.searchBar refreshHotWord:[hotNovelWords firstObject]];
                }
            }];
        } else {
            self.tableView.tableHeaderView = nil;
        }

        CGFloat offsetY = [self getBarHeight];
        
        if (needBackToTop) {
            if ([SNNewsFullscreenManager manager].isFullscreenMode && [self isHomePage]) {
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            }else{
                [self.tableView setContentOffset:CGPointMake(0, -kDefaultContentOffsetHeight + offsetY) animated:NO];
            }
        }
        if (!isViewReleased) {
            if (needReloadLocal || needForceLoadLocal) {
                needForceLoadLocal = NO;
                [self.tableView setContentOffset:CGPointMake(0, -kDefaultContentOffsetHeight + offsetY) animated:NO];
                [self hideToastAndGuide];
                
                //重新组装当前table的数据
                [self reCreateModel];
            } else {
                BOOL needRequestNetwork = [_dragDelegate shouldRequestNetwork];
                if (needRequestNetwork) {
                    //控制频道更新刷新问题
                    if ([SNRollingNewsPublicManager sharedInstance].channelRefreshClose && [channel isHomeChannel]) {
                        [SNRollingNewsPublicManager sharedInstance].channelRefreshClose = NO;
                    }
                }
            }
        }

        if ([self isNovelChannelPage]) {
            SNRollingNewsDataSource *dataSource = (SNRollingNewsDataSource *)self.dataSource;
            if (dataSource.newsModel.rollingNews.count) {
                [self showNovelPopOverView];
            }
        }

        if ([self isHomePage] && ![SNNewsFullscreenManager newsChannelChanged]) {
            [self.dragDelegate.dragLoadingView setStatusLabel:@""];
        }
        [SNNotificationManager postNotificationName:kResetTopNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:self.isH5] forKey:kScrollsToTopStatusKey]];
    }
    [self.dragDelegate resetTableViewFullscreenMode];
}

- (void)customSetNovelHeader {
    _tableView.tableHeaderView = _searchBar;
    [_searchBar hideQrCodeBtn:YES];
}

- (BOOL)judgeIfSelectedController {
    if ([[TTNavigator navigator].rootViewController isKindOfClass:[SNTabBarController class]]) {
        SNTabBarController *tabBarVc = (SNTabBarController *)[TTNavigator navigator].rootViewController;
        if ([[tabBarVc.viewControllers objectAtIndex:0] isKindOfClass:[SNNavigationController class]]) {
            SNNavigationController *naviVc = ((SNNavigationController *)[tabBarVc.viewControllers objectAtIndex:0]);
            if ([naviVc.currentViewController isKindOfClass:[SNRollingNewsViewController class]]) {
                SNRollingNewsViewController *vc = (SNRollingNewsViewController *)naviVc.currentViewController;
                if (self == [vc getCurrentTableController]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)hideNovelPopover {
    if (_popOverView) {
        [_popOverView dismiss];
    }
}

- (void)showNovelPopOverView {
    if (![self judgeIfSelectedController]) {
        return; // @qz 如果当前不是选中的小说 那就返回
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kFirstShowNovelPopKey]) {
        [userDefaults setBool:YES forKey:kFirstShowNovelPopKey];
        [userDefaults synchronize];
        CGSize size = CGSizeMake(kPopOverViewWidth, kPopOverViewHeight);
        self.popOverView = [[SNPopoverView alloc] initWithTitle:@"点此处查看加入书架的内容" Point:[SNNovelEntranceView popOverPoint] size:size leftImageName:@"ico_homehand_v5.png"];
        [self.popOverView show];
    }
}

- (void)reportPopularizeStatExposureInfo {
    if ([self.dataSource isKindOfClass:[SNRollingNewsDataSource class]]) {
        SNRollingNewsDataSource *newsDataSource = (SNRollingNewsDataSource *)(self.dataSource);
        if (newsDataSource.newsModel.isCacheModel) {
            return;
        }
        NSArray *rollingnewsItems = newsDataSource.items;
        NSArray *indexPaths = self.tableView.indexPathsForVisibleRows;
        for (NSIndexPath *indexPath in indexPaths) {
            NSInteger row = indexPath.row;
            if (row < rollingnewsItems.count) {
                id newsItem = [rollingnewsItems objectAtIndex:row];
                if ([newsItem isKindOfClass:[SNRollingNewsTableItem class]]) {
                    SNRollingNewsTableItem *rollingnewsItem = (SNRollingNewsTableItem *)newsItem;
                    [SNStatisticsInfoAdaptor cacheTimelineNewsShowBusinessStatisticsInfo:rollingnewsItem.news];
                    if ([rollingnewsItem.news.templateType isEqualToString:@"76"] && rollingnewsItem.news.topAdNews.count > 0) {
                        for (SNRollingNews *adNews in rollingnewsItem.news.topAdNews) {
                            [adNews.newsAd reportAdOneDisplay:adNews];
                        }
                    }
                    [rollingnewsItem.news.newsAd reportAdOneDisplay:rollingnewsItem.news];
                    //流内冠名展示上报
                    if (rollingnewsItem.news.sponsorshipsObject) {
                        [rollingnewsItem.news.sponsorshipsObject reportSponsorShipOneDisplay:rollingnewsItem.news];
                    }
                    //订阅频道广告展示上报
                    if (rollingnewsItem.subscribeAdObject && rollingnewsItem.type == NEWS_ITEM_TYPE_AD) {
                        [SNStatisticsInfoAdaptor uploadSubPopularizeDisplayInfo:rollingnewsItem.subscribeAdObject];
                    }
                }
            }
        }
    }
    if ([self.dataSource isKindOfClass:[SNRollingNewsSubscribeDataSource class]]) {
        SNRollingNewsSubscribeDataSource *subDataSource = (SNRollingNewsSubscribeDataSource *)(self.dataSource);
        NSArray *rollingnewsItems = subDataSource.items;
        NSArray *indexPaths = self.tableView.indexPathsForVisibleRows;
        for (NSIndexPath *indexPath in indexPaths) {
            NSInteger row = indexPath.row;
            if (row < rollingnewsItems.count) {
                id newsItem = [rollingnewsItems objectAtIndex:row];
                if ([newsItem isKindOfClass:[SNRollingNewsTableItem class]]) {
                    SNRollingNewsTableItem *rollingnewsItem = (SNRollingNewsTableItem *)newsItem;
                    //订阅频道广告展示上报
                    if (rollingnewsItem.subscribeAdObject &&
                        rollingnewsItem.type == NEWS_ITEM_TYPE_AD) {
                        [SNStatisticsInfoAdaptor uploadSubPopularizeDisplayInfo:rollingnewsItem.subscribeAdObject];
                    }
                }
                if ([newsItem isKindOfClass:[SNRollingSubscribeRecomItem class]]) {
                    SNRollingSubscribeRecomItem *item = (SNRollingSubscribeRecomItem *)newsItem;
                    
                    if (item.subscribeObject.subId) {
                        [SNStatisticsInfoAdaptor cacheRecomSubscribeShowBusinessStatisticsInfo:item.subscribeObject];
                    }
                }
            }
        }
    }
}

- (void)changeViewBg {
    self.view.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}

- (void)updateTheme {
    [self customTheme];
    [_loadView updateTheme];
    [self pullADViewUpdateTheme];
    [self addAndShow2015YearBg];
    [self.searchBar updateTheme];
    [self updateRedPacketImage];
}

- (void)customerTableBg {
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)customTheme {
    [self customerTableBg];
    [self changeViewBg];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTheme];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //下拉广告请求
    self.pullAdManager = [[SNPullDownAdManager alloc] init];
    self.pullAdManager.delegate = self;
    
    if (@available(iOS 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];

        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    } else {
        // Fallback on earlier versions
    }
    
    if (([self isHomePage] && ![SNNewsFullscreenManager manager].isFullscreenMode) || [self isIntroPage]) {
        //首页和推荐页面频道添加搜索栏
        [self initSearchBar];
        self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    }
    if ([self isHomePage]) {
        [SNRollingNewsPublicManager sharedInstance].isHomePage = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_dragDelegate setDragLoadingViewNil];
    [[TTURLCache sharedCache] removeAll:NO];
    [[SDImageCache sharedImageCache] clearMemory];
    [[TMMemoryCache sharedCache] removeAllObjects];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.dataSource.model cancel];
    isViewAppeared = NO;
    [[SNNewsSpeakerManager shareManager] closeNewsSpeakerView];
    //@qz 离开页面的时候 隐藏小说的popover
    [self hideNovelPopover];
    if ([self isHomePage]) {
        [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = NO;
        [SNRollingNewsPublicManager sharedInstance].refreshClose = NO;
        [[SNRollingNewsPublicManager sharedInstance] recordLeaveHomeTime];
    }

    if (self.loadDelegate && [self.loadDelegate respondsToSelector:@selector(dismissPopoverMessage)]) {
        [self.loadDelegate dismissPopoverMessage];
    }
    
    //进入正文页上报频道停留总时长
    int totalSec = [[SNRollingNewsPublicManager sharedInstance] rollingNewsTotalTime];
    if (totalSec != 0) {
        //上报总时长
        [SNNewsReport reportChannelStayDuration:totalSec
                                      channelID:self.selectedChannelId];
    }
    
    if (_animationImageView) {
        _animationImageView.status = SNImageLoadingStatusStopped;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self customerTableBg];
    
    if (isViewReleased) {
        [self reCreateModel];
    }

    [super viewWillAppear:animated];
    isViewAppeared = YES;
    
    [[SNRollingNewsPublicManager sharedInstance] recordRollingNewsBeginTime];
    
    if ([self isHomePage]) {
        if ([SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose) {
            [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = NO;
        } else {
            [[SNRollingNewsPublicManager sharedInstance] resetLeaveHomeTime];
        }
    } else if ([self isNovelChannelPage]) {
        [SNBookShelf getBooks:@"" count:@"" complete:nil];
    }

    if(![SNRedPacketManager sharedInstance].redPacketShowing) {
        SNTabbarView *tabview = (SNTabbarView *)[TTNavigator navigator].topViewController.tabbarView;
        [tabview showCoverLayer:NO];
    }
    
    if (_channelWebController) {
        [SNNotificationManager postNotificationName:kResetTopNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:self.isH5] forKey:kScrollsToTopStatusKey]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //_dragDelegate == SNRollingNewsTableViewDelegate
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNRollingNewsViewController class]]) {
        [self.dragDelegate transformationAutoPlayTop:(TTTableView *)self.tableView];
    }
}

- (void)initTripletsLoadingView {
    if (_tripletsLoadingView == nil) {
        _tripletsLoadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight - kDefaultOffsetHeight)];
        _tripletsLoadingView.delegate = self;
        _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
        _tripletsLoadingView.backgroundColor = [UIColor redColor];
        [self.view addSubview:_tripletsLoadingView];
    }
}

- (SNLoadingImageAnimationView *)animationImageView {
    if (!_animationImageView) {
        _animationImageView = [[SNLoadingImageAnimationView alloc] init];
        _animationImageView.targetView = self.view;
    }
    return _animationImageView;
}

- (void)showLoading:(BOOL)show {
    if ([self shouldLoad]) {
        _pullDownADView.hidden = show;
    }
    
    if (![self isHomePage]) {
        self.year2015Bg.hidden = YES;
    }
    else {
        self.year2015Bg.hidden = NO;
    }
    
    if (self.isH5) {
        //处理h5页专用
        [self dealH5TripletsLoadingView:show];
    } else {
        if (show && ([self.dragDelegate hasNoCache])) {
            [self initTripletsLoadingView];
            self.loadingView.hidden = YES;
            self.animationImageView.status = SNImageLoadingStatusLoading;
            _dragDelegate.dragLoadingView.hidden = YES;
            self.searchBar.hidden = YES;
        } else {
            _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
            self.loadingView.hidden = YES;
            self.animationImageView.status = SNImageLoadingStatusStopped;
            _dragDelegate.dragLoadingView.hidden = NO;
            self.searchBar.hidden = NO;
        }
    }
    
    [self.view bringSubviewToFront:_tripletsLoadingView];
    
    //@qz 小说频道第一次进没数据的时候不能显示页头
    if ([self isNovelChannelPage] && [self.dataSource isKindOfClass:[SNRollingNewsDataSource class]]) {
        SNRollingNewsDataSource *dataSource = (SNRollingNewsDataSource *)self.dataSource;
        if (dataSource.newsModel.rollingNews.count == 0) {
            _tableView.tableHeaderView = nil;
        }else{
            [self showNovelPopOverView];
            [self customSetNovelHeader];
        }
    }
}

- (void)showError:(BOOL)show {
    if ([SNUtility isFirstInstallOrUpdateApp]) {
        //首次安装启动App同步List.go
        return;
    }
    
    //首次启动后收起Loading
    //首次安装启动App同步List.go
    [SNNotificationManager postNotificationName:SNROLLINGNEWS_HIDEANIMATIONLOADING object:nil];
    
    if ([self.dataSource isKindOfClass:[SNRollingNewsSubscribeDataSource class]]) {
        if (!show) {
            _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
            self.loadingView.hidden = YES;
            self.animationImageView.status = SNImageLoadingStatusStopped;
            _dragDelegate.dragLoadingView.hidden = NO;
            self.searchBar.hidden = NO;
        }
        return;
    }
    
    if (show) {
        [self initTripletsLoadingView];
        if (!self.isH5) {
            //数据错误显示无网络提示
            _tripletsLoadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
        }
        self.loadingView.hidden = NO;
    } else {
        if ([[SNUtility getApplicationDelegate] isNetworkReachable]) {
            _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
            self.loadingView.hidden = YES;
        } else {
            [self.view bringSubviewToFront:_tripletsLoadingView];
        }
    }
    self.animationImageView.status = SNImageLoadingStatusStopped;
    _dragDelegate.dragLoadingView.hidden = NO;
    self.searchBar.hidden = NO;
    
    [self.view bringSubviewToFront:_tripletsLoadingView];
    
    //本地频道错误提示
    if ([self.selectedChannelId isEqualToString:@"-1"] || [SNRollingNewsModel isLocalChannel:self.selectedChannelId]) {
        _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
        self.loadingView.hidden = YES;
        self.animationImageView.status = SNImageLoadingStatusStopped;
        _dragDelegate.dragLoadingView.hidden = NO;
        self.searchBar.hidden = NO;
        [super showError:show];
        _loadView.status = SNEmbededActivityIndicatorStatusLocalChannelError;
    }
}

- (void)dealH5TripletsLoadingView:(BOOL)show {
    if (show && ([self.dragDelegate hasNoCache])) {
        [self initTripletsLoadingView];
        self.loadingView.hidden = YES;
        if (![SNRollingNewsPublicManager sharedInstance].isHaveAlreadyLoadH5Channel) {
            self.animationImageView.status = SNImageLoadingStatusLoading;
        } else {
            [self resetH5TripletsLoadingView];
        }
        
        _dragDelegate.dragLoadingView.hidden = YES;
        self.searchBar.hidden = YES;
    } else {
        if ([[SNUtility getApplicationDelegate] isNetworkReachable]) {
            _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
        } else {
            _tripletsLoadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
        }
        self.loadingView.hidden = YES;
        _dragDelegate.dragLoadingView.hidden = NO;
        self.searchBar.hidden = NO;
    }
}

- (void)resetH5TripletsLoadingView {
    if ([SNUtility isNetworkReachable]) {
        _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
    } else {
        _tripletsLoadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
    }
}

#pragma mark - SNTripletsLoadingViewDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if (self.isH5) {
        tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
        [_channelWebController doRequest:[SNUtility sharedUtility].currentChannelId];
        return;
    }
    
    //首页数据库中没有数据时，请求强制重置（刷新请求入口太多，各种打补丁）
    if ([self.model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *newsModel = (SNRollingNewsModel *) _model;
        if ([newsModel.channelId isEqualToString:@"1"]) {
            [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
        }
    }
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];
}

#pragma mark - tabbar shadow
- (void)scrollViewWillBeginDragging {
    [self addAndShow2015YearBg];
    
    //关闭Cell弹出的更多View
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:YES];
    [[SNRollingNewsPublicManager sharedInstance] closeListenNewsGuideViewAnimation:YES];
    [self.tabBar.popOverView dismiss];
    
    //@qz http://jira.sohuno.com/browse/NEWSCLIENT-17848
    [self hideNovelPopover];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willBeDecelerate:(NSNumber *)decelerateNum {
    BOOL decelerate = [decelerateNum boolValue];
    if (!decelerate) {
        [self doWhenEndScrolling];
    }
    if (_hasReportShowAd) {
        return;//只上报一次
    }
    
    double offset_y = scrollView.contentOffset.y;
    if (offset_y < - 120.f) {
        [self report:STADDisplayTrackTypeImp];
        _hasReportShowAd = YES;
    }
}

- (void)scrollViewDidEndDecelerating {
    [self doWhenEndScrolling];
    
    _year2015Bg.hidden = YES;
    if ([self.dataSource isKindOfClass:[SNRollingNewsDataSource class]]) {
        SNRollingNewsDataSource *dataSource = (SNRollingNewsDataSource *)self.dataSource;
        NSDictionary *dict = dataSource.exposureDictiongary;
        [[SNNewsExposureManager sharedInstance] exposureNewsInfoWithDic:dict];
        [dataSource.exposureDictiongary removeAllObjects];
    }
    if (![SNRollingNewsPublicManager sharedInstance].isRequestChannelData) {
        //如果在下拉刷新中, 不调用自动播放
        [self.dragDelegate transformationAutoPlayTop:(TTTableView *)self.tableView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"] && _isFullscreenMode) {//huangzhen TODO...
        [self.tabBar rollingNewsTableViewDidScroll:scrollView.contentOffset.y];
    }
}

- (void)doWhenEndScrolling {
    [SNNotificationManager postNotificationName:kTipsViewRefreshNotification object:nil];
    
    NSArray *cells = self.tableView.visibleCells;
    if (cells.count > 0) {
        UITableViewCell *firstCell = cells[0];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:firstCell];
        if (indexPath) {
            if ([firstCell isKindOfClass:[SNRollingPageViewCell class]] || [firstCell isKindOfClass:[SNRollingTrainFocusCell class]]) {
                NSNumber *stopFlagNum = [NSNumber numberWithBool:NO];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:_selectedChannelId, @"stopChannelId", stopFlagNum, @"stopFlag", nil];
                
                [SNNotificationManager postNotificationName:kStopPageTimerNotification object:nil userInfo:dic];
            } else {
                NSNumber *stopFlagNum = [NSNumber numberWithBool:YES];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:_selectedChannelId, @"stopChannelId", stopFlagNum, @"stopFlag", nil];
                [SNNotificationManager postNotificationName:kStopPageTimerNotification object:nil userInfo:dic];
            }
        }
    }
}

- (void)cacheCellIndexPath:(UITableViewCell *)aCell {
    self.lastIndexPath = [self.tableView indexPathForCell:aCell];
}

#pragma mark - Memory
- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    self.parentViewControllerForModalADView = nil;
    _tripletsLoadingView.delegate = nil;
    _channelWebController.delegate = nil;
}

#pragma mark - 下拉广告位
- (void)pullDownADViewInit:(NSNotification *)notice {
}

- (void)pullADViewUpdateTheme {
    BOOL theme = [[SNThemeManager sharedThemeManager] isNightTheme];
    if (theme && _pullDownADView.image && !_pullDownADView.hidden) {
        _pullAdMaskMode.hidden = NO;
    } else {
        _pullAdMaskMode.hidden = YES;
    }
}

- (void)layoutPullAdWithAdInfo:(NSDictionary *)info {
    NSString *imgUrl = info[@"imageUrl"];
    self.adData = info[@"adData"];
    
    UIImage *cachedImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgUrl];
    if (cachedImg) {
        if (_pullDownADView) {
            _pullDownADView.contentMode = UIViewContentModeScaleToFill;
            [_pullDownADView setImage:cachedImg];
            _hasReportLoadAd = YES;
        }
    } else {
        if (imgUrl.length > 0) {
            [_pullDownADView loadUrlPath:imgUrl];
            [[SDImageCache sharedImageCache] storeImage:self.pullDownADView.image forKey:imgUrl toDisk:YES];
            _hasReportLoadAd = YES;
        } else {
            _pullDownADView.image = nil;
        }
    }

    if ([info[@"adType"] integerValue] == kPullAdIsEmpty) {
        //空广告
        pullAdisNull = YES;
        _hasReportNullAd = YES;
    } else {
        pullAdisNull = NO;
    }

    [self addAndShow2015YearBg];
    [self pullADViewUpdateTheme];
}

- (void)requestFnishedWithAdInfo:(NSDictionary *)info {
    NSString *imgUrl = info[@"imageUrl"];
    self.adData = info[@"adData"];
 
    UIImage *cachedImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgUrl];
    
    if (cachedImg) {
        if (_pullDownADView) {
            _pullDownADView.contentMode = UIViewContentModeScaleToFill;
            [_pullDownADView setImage:cachedImg];
            
            _hasReportLoadAd = YES;
        }
    } else {
        if (imgUrl.length > 0) {
            [_pullDownADView loadUrlPath:imgUrl];
            [[SDImageCache sharedImageCache] storeImage:self.pullDownADView.image forKey:imgUrl toDisk:YES];
            _hasReportLoadAd = YES;
        } else {
            _pullDownADView.image = nil;
        }
    }
    
    if ([info[@"adType"] integerValue] == kPullAdIsEmpty) {
        //空广告
        pullAdisNull = YES;
        [self report:STADDisplayTrackTypeNullAD];//空广告曝光
        _hasReportNullAd = YES;
    } else {
        [self report:STADDisplayTrackTypeLoadImp];
        pullAdisNull = NO;
    }
    
    [self addAndShow2015YearBg];
    [self pullADViewUpdateTheme];
}

- (void)reportPullAdShow {
    if (_adData && !pullAdisNull) {
        [self report:STADDisplayTrackTypeImp];
    }
}

- (void)report:(STADDisplayTrackType)type {
    if (!_pullAdSwitchOpen) {
        return;
    }

    if (self.adData.gbcode.length == 0) {
        self.adData.gbcode = [SNUserLocationManager sharedInstance].currentChannelGBCode;
    }
    
    SNStatInfo *adReport = [_adData createAdReportInfo:type];
    SNStatInfo *upload = [_adData createUploadStatInfo:type];
    
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:upload];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEventSync:adReport];
}

#pragma mark - 流内广告加载上报
//当前频道被选择
- (void)rollingNewsTableDidSelected {
    [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeChannels majorkey:self.selectedChannelId];
    if ([SNRollingNewsPublicManager sharedInstance].isHomePage) {
        return;
    }
    if ([self.dataSource isKindOfClass:[SNRollingNewsDataSource class]]) {
        SNRollingNewsDataSource *newsDataSource = (SNRollingNewsDataSource *)(self.dataSource);
        if (!newsDataSource.newsModel.isPreloadChannel) {
            return;
        }
        NSArray *emptyAds = newsDataSource.newsModel.preloadEmptyADs;
        for (SNRollingNews *news in emptyAds) {
            if (news) {
                [news.newsAd reportEmptyLoad:news];
            }
        }
        [newsDataSource.newsModel.preloadEmptyADs removeAllObjects];
        
        NSArray *rollingnewsItems = newsDataSource.newsModel.preloadNews;
        for (SNRollingNews *newsItem in rollingnewsItems) {
            if (![newsItem isKindOfClass:[SNRollingNews class]]) {
                break;
            }
            //广告类型
            if ([newsItem.newsType isEqualToString:kNewsTypeAd] &&
                !newsItem.newsAd.isReported) {
                [newsItem.newsAd reportAdLoad:newsItem];
                newsItem.newsAd.isReported = YES;
            }
            if (([newsItem.templateType isEqualToString:kTemplateTypeFullScreenFocus] || [newsItem isMoreFocusNews]) && newsItem.newsFocusArray.count > 0) {
                for (SNRollingNews *adNews in newsItem.newsFocusArray) {
                    if (adNews && [adNews.adType isEqualToString:@"2"]) {
                        [adNews.newsAd reportEmptyLoad:adNews];
                    } else if ([adNews.newsType isEqualToString:kNewsTypeAd] &&
                        !adNews.newsAd.isReported) {
                        [adNews.newsAd reportAdLoad:adNews];
                        adNews.newsAd.isReported = YES;
                    }
                }
            }
            if ([newsItem.templateType isEqualToString:kTemplateTypeTrainCard] && newsItem.newsItemArray.count > 0) {
                for (SNRollingNews *adNews in newsItem.newsItemArray) {
                    if (adNews && [adNews.adType isEqualToString:@"2"]) {
                        [adNews.newsAd reportEmptyLoad:adNews];
                    } else if ([adNews.newsType isEqualToString:kNewsTypeAd] &&
                               !adNews.newsAd.isReported) {
                        [adNews.newsAd reportAdLoad:adNews];
                        adNews.newsAd.isReported = YES;
                    }
                }
            }
            if ([newsItem.templateType isEqualToString:@"76"] && newsItem.topAdNews.count > 0) {
                for (SNRollingNews *adNews in newsItem.topAdNews) {
                    if ([adNews.newsType isEqualToString:kNewsTypeAd] &&
                        !adNews.newsAd.isReported) {
                        [adNews.newsAd reportAdLoad:adNews];
                        adNews.newsAd.isReported = YES;
                    }
                }
            }
            //流内冠名加载上报，如果有SNNewsSponsorships节点，表明有冠名广告
            if ([newsItem respondsToSelector:@selector(sponsorshipsObject)]) {
                SNNewsSponsorships *sponsorshipsObject = [newsItem performSelector:@selector(sponsorshipsObject)];
                if ([sponsorshipsObject.adType isEqualToString:@"1"] && !sponsorshipsObject.isReported) {
                    [sponsorshipsObject reportSponsorShipLoad:newsItem];
                    sponsorshipsObject.isReported = YES;
                } else if ([sponsorshipsObject.adType isEqualToString:@"2"] &&
                           !sponsorshipsObject.isReported) {
                    [sponsorshipsObject reportSponsorShipEmpty:newsItem];
                    sponsorshipsObject.isReported = YES;
                }
            }
        }
        [newsDataSource.newsModel.preloadNews removeAllObjects];
    }
}

#pragma mark 3DTouch
- (void)check3DTouch {
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (!indexPath ||
        [self.presentedViewController isKindOfClass:[SNWebController class]] ||
        [self.presentedViewController isKindOfClass:[SNCommonNewsController class]]) {
        return nil;
    }
    
    _indexPath = indexPath;
    
    SNRollingNewsTitleCell *cell = (SNRollingNewsTitleCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    previewingContext.sourceRect = cell.frame;
    
    if ([cell isKindOfClass:[SNRollingNewsMySubscribeCell class]]) {
        return nil;
    }
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.preferredContentSize = CGSizeMake(0.0f, [[UIScreen mainScreen] bounds].size.height - 100);
    
    if (cell.item.news.newsType != nil &&
        [SNCommonNewsController supportContinuation:cell.item.news.newsType]) {
        if (nil != cell.item.news.link
            && cell.item.news.link.length > 0
            && [cell.item.news.link hasPrefix:kProtocolChannel]) {
            NSDictionary *query = [NSMutableDictionary dictionary];
            [query setValue:cell.item.news.link forKey:@"address"];
            _articleDict = query;
            _isNewsController = NO;
            SNWebController *webController= [[SNWebController alloc] initWithParams:query URL:[NSURL URLWithString:@"tt://simpleWebBrowser"]];
            webController.sourceVC = self;
            viewController = webController;
        } else {
            NSMutableDictionary *dic = [cell.item.dataSource getContentDictionary:cell.item.news];

            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            if (dic.count > 0) {
                if (cell.item.expressFrom == NewsFromRecommend) {
                    [dic setObject:kChannelRecomNews forKey:kNewsFrom];
                } else if (cell.item.expressFrom == NewsFromChannel) {
                    [dic setObject:kChannelEditionNews forKey:kNewsFrom];
                }
                [query setValuesForKeysWithDictionary:dic];
            }
            _articleDict = query;
            _isNewsController = YES;
            SNCommonNewsController *newsController = [[SNCommonNewsController alloc] initWithParams:query URL:[NSURL URLWithString:@"tt://commonNewsController"]];
            newsController.sourceVC = self;
            viewController = newsController;
        }
    } else if (cell.item.news.link.length > 0 &&
               [SNAPI isWebURL:cell.item.news.link]) {
        NSDictionary *query = [NSMutableDictionary dictionary];
        [query setValue:cell.item.news.link forKey:@"address"];
        _articleDict = query;
        _isNewsController = NO;
        SNWebController *webController= [[SNWebController alloc] initWithParams:query URL:[NSURL URLWithString:@"tt://simpleWebBrowser"]];
        webController.sourceVC = self;
        viewController = webController;
    } else {
        return nil;
    }
    return viewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit {
    SNRollingNewsTitleCell *cell = (SNRollingNewsTitleCell *)[self.tableView cellForRowAtIndexPath:_indexPath];
    if (cell.item.delegate && cell.item.selector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cell.item.delegate performSelector:cell.item.selector
                                 withObject:cell.item];
#pragma clang diagnostic pop
    }
}

- (void)openNewsFrom3DTouch {
    if (_isNewsController) {
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:_articleDict];
        [[TTNavigator navigator] openURLAction:urlAction];
    } else {
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:_articleDict];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

#pragma mark toastRefreshNotification
- (void)resetTableAndRefresh {
    CGFloat offsetY = [self getBarHeight];
    if (self.tableView.contentOffset.y <= -kDefaultContentOffsetHeight + offsetY) {
        [self onlyRefresh];
    } else {
        if ([SNNewsFullscreenManager manager].isFullscreenMode && [self isHomePage]) {
            offsetY = 0;
        }else{
            offsetY = -kDefaultContentOffsetHeight + offsetY;
        }
        [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        [self performSelector:@selector(onlyRefresh)
                   withObject:self afterDelay:0.1];
    }
}

- (void)onlyRefresh {
    if (self.isH5) {
        [_channelWebController doRequest:[SNUtility sharedUtility].currentChannelId];
        return;
    }
    
    if ([self isHomePage]) {
        [SNRollingNewsPublicManager sharedInstance].isRecommendAfterEditNews = NO;
        [SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow = YES;
        
        [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:0 channelId:self.selectedChannelId];
    }
    
    [self.dragDelegate onlyRefresh];
}

- (void)toastRefreshNotification {
    if ([_selectedChannelId isEqualToString:[SNRollingNewsPublicManager sharedInstance].refreshChannelId]) {
        SNRollingNewsTableController *vc = self;
        CGFloat offsetY = [self getBarHeight];
        if ([SNNewsFullscreenManager manager].isFullscreenMode && [self isHomePage]) {
            offsetY = 0;
        }else{
            offsetY = -kDefaultContentOffsetHeight + offsetY;
        }
        [vc.tableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        [vc performSelector:@selector(onlyRefresh) withObject:vc afterDelay:0.1];
    }
}

#pragma mark refreshActionNotification  下拉刷新通知
- (void)refreshActionNotification {
    self.dragDelegate.isAutoPlay = YES;
    if ([self isHomePage]) {
        [SNRollingNewsPublicManager sharedInstance].showRecommend = NO;
    }
    
    if ([self isLocalPage] || [self isIntroPage]) {
        //流式频道视频自动播放等下拉红点动画结束后再进入处理
    } else {
        //[self.dragDelegate transformationAutoPlayTop:(TTTableView *)self.tableView];
    }
}

#pragma mark --服务bar和搜索bar
- (void)initSearchBar {
    if (!_searchBar) {
        
        float searchBarHeight = [SNNewsFullscreenManager newsChannelChanged] ? 44.0 : 54;
        if ([self.selectedChannelId isEqualToString:@"13557"]) {//推荐频道与搜索框间距过大，稍作调整
            searchBarHeight = 44.0;
        }
        self.searchBar = [[UIHomePageSearchBar alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, searchBarHeight)];
        self.searchBar.channelId = self.selectedChannelId;
        
        self.searchBar.delegate = self;
        [self.searchBar setBackgroundImage:[[UIImage alloc] init]];
        [self.searchBar setTranslucent:YES];
        [self.searchBar addSearchButtonWithTarget:self action:@selector(searchBarWillBeginSearch)];
    }
    self.searchBar.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}

- (CGFloat)getBarHeight {
    BOOL isFirst = ![[NSUserDefaults standardUserDefaults] boolForKey:@"getBarHeight_first"];
    if (isFirst) {
        return 0.0f;
    }
    
    if ([self isHomePage]) {
        //默认搜索栏露出
        //return self.searchBar.size.height;
    }
    return 0.0f;
}

- (void)showSearchView {
    if (self.searchVc == nil) {
        self.searchVc = [[SNSearchWebViewController alloc] init];
        self.searchVc.searchBarDelegate = self;
        
        if ([self isNovelChannelPage]) {
            self.searchVc.homeSearch = NO;
            self.searchVc.refertype = SNSearchReferNovel;
        } else {
            self.searchVc.refertype = SNSearchReferHomePage;
            self.searchVc.homeSearch = YES;
        }
        
        [self.view.superview.superview addSubview:self.searchVc.view];
    }
    self.searchVc.view.frame = CGRectMake(0, 64, kAppScreenWidth, kAppScreenHeight);
    self.searchVc.view.hidden = NO;
    self.searchBar.hidden = YES;
    
    [self.searchVc beginSearchAndreloadHotWords];
}

- (void)searchWebViewLoadView {
    [self.loadDelegate hiddenTabar:YES];
}

- (void)searchBarEndSearch {
    //如果退出搜索页面, 视频继续播放
    [self.dragDelegate transformationAutoPlayTop:(TTTableView *)self.tableView];
    
    if (self.searchVc) {
        [self.searchVc.view removeFromSuperview];
        self.searchVc = nil;
    }
    self.searchBar.hidden = NO;
    
    [self.loadDelegate hiddenTabar:NO];
    if ([self.loadDelegate respondsToSelector:@selector(shouldChangeStatusBarTextColorToDefault:)]) {
        [self.loadDelegate shouldChangeStatusBarTextColorToDefault:NO];
    }
    [UIView animateWithDuration:.3 animations:^{
        [self.loadDelegate changeLayOut:NO];
        [SNRollingNewsPublicManager sharedInstance].isBeginHomeSearch = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SNUtility handleClipper];
        });
    }];
    
    [[SNRollingNewsPublicManager sharedInstance] recordRollingNewsBeginTime];
    [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeChannels majorkey:self.selectedChannelId];
}

- (void)searchBarWillBeginSearch {
    [SNRollingNewsPublicManager sharedInstance].isBeginHomeSearch = YES;
    [self showSearchView];
    if ([self.loadDelegate respondsToSelector:@selector(shouldChangeStatusBarTextColorToDefault:)]) {
        [self.loadDelegate shouldChangeStatusBarTextColorToDefault:YES];
    }

    [UIView animateWithDuration:.3 animations:^{
        [self.loadDelegate changeLayOut:YES];
        self.searchVc.view.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    } completion:^(BOOL finished) {
        //如果进入搜索页面, 关闭视频播放
        [SNTimelineSharedVideoPlayerView forceStop];
        [SNAutoPlaySharedVideoPlayer forceStopVideo];
    }];

    if ([self isNovelChannelPage]) {
        //@qz 小说搜索的埋点
        [self hideNovelPopover];    //@qz http://jira.sohuno.com/browse/NEWSCLIENT-19457
        [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"objType=fic_search_clk&fromObjType=more&statType=clk"]];
    } else {
        [self.tabBar.popOverView dismiss];   //@qz http://jira.sohuno.com/browse/NEWSCLIENT-19457
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=tosearch&_tp=pv&channelid=%@",  [SNUtility getFirstChannelID]]];
    }
    //进入搜索页面
    int totalSec = [[SNRollingNewsPublicManager sharedInstance] rollingNewsTotalTime];
    if (totalSec != 0) {
        //上报总时长
        [SNNewsReport reportChannelStayDuration:totalSec
                                      channelID:self.selectedChannelId];
    }
    [[SNSpecialActivity shareInstance] dismissLastChannelSpecialAlert];
}

#pragma mark 本地频道bar
- (void)setNewChannel:(BOOL)isNew {
    self.isNewChannel = isNew;
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
        newsModel.isNewChannel = isNew;
    }
}

#pragma mark 红包
- (void)showUserRedPacket {
    if ([SNRedPacketManager sharedInstance].pullRedPacket) {
        SNRedPacketType typeValue = SNRedPacketNormal;
        if ([SNRedPacketManager sharedInstance].redPacketItem.redPacketType == 2) {
            typeValue = SNRedPacketTask;
        }
        SNUserRedPacketView *userRedPacket = [[SNUserRedPacketView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight) redPacketType:typeValue];
        userRedPacket.backgroundColor = [UIColor clearColor];
        
        [userRedPacket updateContentView:[SNRedPacketManager sharedInstance].redPacketItem];
        [SNRedPacketManager sharedInstance].redPacketItem.redPacketInValid = 0;
        
        [userRedPacket showUserRedPacket];
        [[TTNavigator navigator].topViewController.view addSubview:userRedPacket];
        if ([[TTNavigator navigator].topViewController.tabbarView isKindOfClass:[SNTabbarView class]]) {
            SNTabbarView *tabview = (SNTabbarView *)[TTNavigator navigator].topViewController.tabbarView;
            [tabview showCoverLayer:YES];
        }
        
        [SNRedPacketManager sharedInstance].redPacketShowing = YES;
        [SNNewsReport reportADotGif:@"_act=luckmoney&_tp=pop"];
    }
    
    [SNRedPacketManager sharedInstance].redPacketItem.showAnimated = YES;
    [SNRedPacketManager sharedInstance].redPacketItem.delayTime = 0;
}

- (void)showRedPacketBtn {
    if (self.redPacketBtn == nil) {
        [self createRedPacketBtn];
    }
    
    self.redPacketBtn.hidden = ![[SNRedPacketManager sharedInstance] showRedPacketActivityTheme];
}

- (void)createRedPacketBtn {
    int offsetY = [SNDevice sharedInstance].isPlus ? 3 : -4;
    self.redPacketBtn = [[UIButton alloc] initWithFrame:CGRectMake(kAppScreenWidth - 56, kAppScreenHeight - 107.0 - offsetY, 56, 57)];
    self.redPacketBtn.backgroundColor = [UIColor clearColor];
    [self.redPacketBtn addTarget:self action:@selector(gotoRedPacketDeatil) forControlEvents:UIControlEventTouchUpInside];
    [self updateRedPacketImage];
    [self.view addSubview:self.redPacketBtn];
    
    [SNRedPacketManager sharedInstance].isInArticleShowRedPacket = NO;
}

- (void)updateRedPacketImage {
    SNAppConfigFloatingLayer *floatingLayer = [SNAppConfigManager sharedInstance].floatingLayer;
    NSURL *imageUrl = [NSURL URLWithString:floatingLayer.picUrl];
    [self.redPacketBtn sd_setImageWithURL:imageUrl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icohongbao_hbyu_v5.png"]];
    [self.redPacketBtn sd_setImageWithURL:imageUrl forState:UIControlStateHighlighted placeholderImage:[UIImage imageNamed:@"icohongbao_hbyu_v5.png"]];
}

- (void)gotoRedPacketDeatil {
    [SNUtility shouldUseSpreadAnimation:NO];
    [SNRedPacketManager showRedPacketActivityInfo];
}

//我是土豪
- (void)couponReceiveSucces:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *state = notification.object;//就是开关
        BOOL shown = [state boolValue];
        [SNRedPacketManager sharedInstance].joinActivity = shown;
        [SNNotificationManager postNotificationName:kShowRedPacketButtonNotification object:nil];
        if (shown == 1) {
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kRedPacketTopicItem"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSNumber *joinNumber = [NSNumber numberWithBool:[SNRedPacketManager sharedInstance].joinActivity];
        [[NSUserDefaults standardUserDefaults] setObject:joinNumber forKey:kJoinRedPacketsValue];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

//红包皮肤总开关通知
- (void)showRedPacketTheme:(NSNotification *)notification {
}

- (void)stopPageTimer:(BOOL)stop {
    if (![self.dataSource isKindOfClass:[SNRollingNewsDataSource class]]) {
        return;
    }
    SNRollingNewsDataSource *newsDataSource = (SNRollingNewsDataSource *)self.dataSource;
    if (newsDataSource.newsModel.rollingNews.count > 0) {
        SNRollingNews *firtNews = [newsDataSource.newsModel.rollingNews objectAtIndex:0];
        if ([firtNews isMoreFocusNews]) {
            NSNumber *stopFlagNum = [NSNumber numberWithBool:stop];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:firtNews.channelId, @"stopChannelId", stopFlagNum, @"stopFlag", nil];
            [SNNotificationManager postNotificationName:kStopPageTimerNotification object:nil userInfo:dic];
        }
    }
}

- (void)hideToastAndGuide{
    
    //当前VC显示toast，切换频道，该频道和切换前共用VC时，toast不消失
    UIView *view = [self.view viewWithTag:kInsertToastTag];
    if (view != nil) {
        [view removeFromSuperview];
    }
    
    //当前VC显示新手引导，切换频道，该频道和切换前共用VC时，新手引导不消失
    UIView *pullGuide = [self.view viewWithTag:kPullGuideTag];
    if (pullGuide && [pullGuide isKindOfClass:NSClassFromString(@"SNPullNewGuide")]) {
        [pullGuide removeFromSuperview];
    }

}

- (void)changeModelToNewChannel:(SNChannel *)channel{
    if (!self.isH5) {
        //股票频道为webview，无model，无需进行修改
        //list.go下发频道类型修改，需要及时修改model对应的newschannel
        SNNewsModel *model = (SNNewsModel *)self.dataSource.model;
        if ([model isKindOfClass:[SNNewsModel class]]) {
            model.isNewChannel = [channel isNewChannel];
            model.isMixStream = channel.isMixStream;
        }
    }
}

- (void)p_updateHotWord {
    if ([SNRollingNewsPublicManager sharedInstance].searchHotWord.count > 0) {
        self.hotSearchWrods = [SNRollingNewsPublicManager sharedInstance].searchHotWord;
        [self.searchBar refreshHotWord:[self.hotSearchWrods objectAtIndex:0]];
    }
}

#pragma mark -
#pragma mark - 全屏模式
- (void)changeFullscreenMode:(BOOL)isFullscreen {
    if (![self isHomePage]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isFullscreen == _isFullscreenMode) {
            if (isFullscreen) {
                [self.dragDelegate newsFullscreenModeToast];
            }
            return;
        }
        _isFullscreenMode = isFullscreen;
        [self.dragDelegate resetTableViewContentInset];
        
        if (_isFullscreenMode) {
            //huangzhen TODO...
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
        } else {
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kHeadSelectViewHeight, 0.f, kToolbarViewHeight, 0.f);
        }
        [self addAndShow2015YearBg];
        if (isFullscreen) {
            [self.searchBar removeFromSuperview];
            self.searchBar = nil;
            self.tableView.tableHeaderView = nil;
        } else {
            if ([self isHomePage]) {
                [self initSearchBar];
                self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
                self.tableView.tableHeaderView = self.searchBar;
                
                //更新热词
                NSArray *hotWords = [SNRollingNewsPublicManager sharedInstance].searchHotWord;
                if (hotWords.count > 0) {
                    [self.searchBar refreshHotWord:
                     [hotWords objectAtIndex:0]];
                }
            }
        }
        [self.dragDelegate newsFullscreenModeToast];
    });
}

- (void)reCreateSearchBar {
    float searchBarHeight = [SNNewsFullscreenManager newsChannelChanged] ? 44.0 : 54;
    if ([self.selectedChannelId isEqualToString:@"13557"]) {//推荐频道与搜索框间距过大，稍作调整
        searchBarHeight = 44.0;
    }
    self.searchBar.frame = CGRectMake(0, 0, kAppScreenWidth, searchBarHeight);
    float value = [SNNewsFullscreenManager newsChannelChanged] ? 10 : 20;
    if ([self isIntroPage]) {//推荐频道与搜索框间距过大，稍作调整
        value = 10;
    }
    [self.searchBar setSearchbarHeight:value];
}

//- (void)reLayOutSearchBar{
//    if ([SNNewsFullscreenManager newsChannelChanged] && ( [self isHomePage] || [self isIntroPage])) {
//        //有文本置顶
//        BOOL hasTitleTop = NO;
//        SNNewsDataSource *ds = (SNNewsDataSource *)self.dataSource;
//        if ([ds.model isKindOfClass:[SNRollingNewsModel class]]) {
//            SNRollingNewsModel *model = (SNRollingNewsModel *)ds.model;
//            if (model.rollingNews.count > 0) {
//                SNRollingNews *news = [model.rollingNews objectAtIndex:0];
//                if ([news isRollingTopNews]) {
//                    hasTitleTop = YES;
//                }
//            }
//        }
//        if (self.searchBar == nil) {
//            [self initSearchBar];
//        }
//        float searchBarHeight = hasTitleTop ? 54 : 44;
//        self.searchBar.frame = CGRectMake(0, 0, kAppScreenWidth, searchBarHeight);
//        CGFloat value = hasTitleTop ? 20 : 10;
//        [self.searchBar setSearchbarHeight:value];
//    }
//}

@end
