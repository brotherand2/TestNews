//
//  SNRollingNewsViewController.m
//  sohunews
//
//  Created by Chen Hong on 12-8-8.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsViewController.h"
#import "SNRollingNewsTableController.h"
#import "SNTabBarItem.h"
#import "UIColor+ColorUtils.h"
#import "SNDBManager.h"
#import "SNChannel.h"
#import "SNTabBarController.h"
#import "SNStatusBarMessageCenter.h"
#import "SNAPNSHandler.h"
#import "SNExposureRequest.h"
#import "Toast+UIView.h"
#import "SNAnalytics.h"
#import "SNChannelManageViewV2.h"
#import "SNNewsPreloader.h"
#import "SNNewsNotificationManager.h"
#import "SNUserManager.h"
#import "SNRollingNewsPublicManager.h"
#import "SNUserLocationManager.h"
#import "SNToast.h"
#import "SNAlertStackManager.h"
#import "SNFontSettingAlert.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNExternalLinkHandler.h"
#import "SNAppConfigManager.h"
#import "SNUserLocationManager.h"
#import "SNNewsReport.h"
#import "SNPopoverView.h"
#import "SNRollingNewsSubscribeDataSource.h"
#import "SNQRUtility.h"
#import "SNRedPacketManager.h"
#import "UIColor+ColorUtils.h"
#import "SNDynamicPreferences.h"
#import "SNVideoAdContext.h"
#import "SNADVideoCellAudioSession.h"
#import "SNSpecialActivityAlert.h"
#import "SNCloudSynAlert.h"
#import "SNLoadingImageAnimationView.h"
#import "SNSpecialActivity.h"
#import "SNCheckManager.h"
#import "SNSpecialActivity.h"
#import "SNSubRollingNewsModel.h"

#define kChannelBarHeight               66/2
#define kTableTopMargin                 kChannelBarHeight/4
#define kCOUNT                          3
#define kErrorViewOffset                0
#define kDefaultHeaderVisibleHeight     120.0
#define kEditAcitonTimeinterval         0.6  //限制频道打开关闭时间间隔

BOOL _slideToastShowing = NO;

@interface SNRollingNewsViewController () <SNRollingNewsLoadFlagDelegate> {
    
    NSMutableArray *_emptyImgArray; //空白占位图, 用于切换模式时查找替换夜间模式资源
    
    BOOL _bFirstLoad;
    BOOL _updateLocalChannel;
    BOOL _showLocalChannelUpdate;
    int _leftDragTimes;
    
    UIView *_channelManageViewContainer;
    SNChannelManageViewV2 *_channelManageView;
    SNChannel *_localChannel;
    
    BOOL _isExpandChannelView;
    
    NSInteger _currSelectedIndex;
    
    //由于频道操作不稳定, 加一个判断是否需要自动跳转到推荐频道的判断
    BOOL _isPushToIntro;
    
    //用于判断代码是否第一次启动直接进入推荐流
    BOOL _isFirstPushToIntro;
}
@property (nonatomic, strong) SNRollingNewsTableController *leftTableController;
@property (nonatomic, strong) SNRollingNewsTableController *currTableController;
@property (nonatomic, strong) SNRollingNewsTableController *rightTableController;

@property (nonatomic, assign) BOOL hasEditedChannels;
@property (nonatomic, strong) SNChannel *localChannel;

@property (nonatomic) BOOL canLoadFlag;
@property (nonatomic, strong) SNPopoverView *popoverView;
@property (nonatomic, strong) NSString *tipsString;
@property (nonatomic, assign) BOOL isWillShowEditNews;
@property (nonatomic, assign) BOOL isFrom3DTouch;
@property (nonatomic, strong) SNLoadingImageAnimationView *animationImageView;
@property (nonatomic, assign) BOOL haveAlreadyRightP1;

@end

@implementation SNRollingNewsViewController
@synthesize tabBar;
@synthesize channelDatasource = _channelDatasource;
@synthesize selectedChannelId = _selectedChannelId;
@synthesize cloudSaveService = _cloudSaveService;
@synthesize hasEditedChannels;
@synthesize localChannel = _localChannel;
@synthesize popoverView = _popoverView;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
	if (self) {
        self.canLoadFlag = YES;
        [self customTabbarStyle:@"icotab_news_v5.png"
                     activeIcon:@"icotab_newspress_v5.png"
                          title:NSLocalizedString(@"News", nil)];
        if (nil == _selectedChannelId) {
            self.selectedChannelId = @"1";
            _preOffsetX = 0;
            _curIndex = 0;
        }
        
        self.title = NSLocalizedString(@"News", @"News");
	}
	return self;
}

- (BOOL)isHomePage {
    BOOL isHome = NO;
    if (self.selectedChannelId &&
        [self.selectedChannelId isEqualToString:@"1"]) {
        isHome = YES;
    }
    return isHome;
}

- (SNRollingNewsTableController *)getCurrentTableController {
    return self.currTableController;
}

- (SNCCPVPage)currentPage {
    return tab_news;
}

- (NSArray *)iconNames {
    return [NSArray arrayWithObjects:@"icotab_news_v5.png", @"icotab_newspress_v5.png", nil];
}

- (NSString *)tabItemText {
    if ([SNUtility getTabBarName:0]) {
        return [SNUtility getTabBarName:0];
    }
    return NSLocalizedString(@"News", nil);
}

- (void)showTabbarView {
    if (_bLockTabbarView) {
        return;
    }
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat addHeight = 0.0;
    if (statusBarRect.size.height > 20.0) {
        addHeight = 20.0;
    }
    if (self.view.frame.size.height == kAppScreenHeight) {
        addHeight = 0;
    }
    SNTabbarView *tabView = self.tabbarView;
    [tabView removeFromSuperview];
    //@qz 改变tabbar Y坐标的地方
    tabView.top = self.view.height - tabView.height - addHeight;
    [self.view addSubview:tabView];
    
    self.tabbarSnapView = tabView;
    
    [self setTabbarViewLocked:YES];
}

- (void)setTabbarViewVisible:(BOOL)bVisible {
    if (!bVisible) self.tabbarSnapView = nil;
}

- (void)setTabbarViewLocked:(BOOL)bLocked {
    _bLockTabbarView = bLocked;
}

- (SNRollingNewsTableController *)loadScrollViewWithPage:(NSInteger)page {
    if (page < 0 || page >= _channelDatasource.model.subedChannels.count) {
        return nil;
    }
    
    SNRollingNewsTableController *controller = [_channelTableViewControllerArray objectAtIndex:page % kCOUNT];
    SNChannel *channel = [_channelDatasource.model.subedChannels objectAtIndex:page];
    
    controller.loadDelegate = self;
    controller.selectedChannelId = channel.channelId;
    controller.isH5 = [channel isH5Channel];
    controller.url = channel.link;
    controller.isNewChannel = [channel isNewChannel];
    controller.isMixStream = channel.isMixStream;
    controller.selectedChanneType = [channel.channelType intValue];
    controller.redPacketBtn.hidden = YES;
    controller.isPreloadChannel = channel.isPreloadChannel;
    
    if (nil == controller.view.superview) {
        controller.isAddToSuperView = NO;
        
        CGRect frame = _rollingNewsScrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        SNChannel *channel = [_channelDatasource.model.subedChannels objectAtIndex:page];
        if ([controller.selectedChannelId isEqualToString:@"176"] && channel.isPreloadChannel == YES) {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"slideToSubscribe"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [_rollingNewsScrollView addSubview:controller.view];
    } else {
        controller.isAddToSuperView = YES;
    }
    return controller;
}

- (BOOL)canLoadNews {
    return _canLoadFlag;
}

- (void)loadView {
    [super loadView];
    self.view.clipsToBounds = YES;
    
    [SNNotificationManager addObserver:self
                              selector:@selector(updateChannels:)
                                  name:kRollingChannelChangedNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(guideViewDidDissmiss:)
                                  name:kGuideViewDidDismiss
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(showSlideToChangeChannelGuide)
                                  name:kSlideToChangeChannelNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(hideChannelManageViewAfterClickSohuIcon) name:kHideChannelManageViewNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(showPopoverMessage)
                                  name:kTriggerPopoverMessage
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(refreshHomePageNotification:)
                                  name:kRefreshHomePageNotification
                                object:nil];
    
    //Refresh
    [SNNotificationManager addObserver:self
                              selector:@selector(refreshchannels) name:@"refreshchannelsnow"
                                object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(registDidSuccessRefreshChannel)
                                  name:kRegistGoSuccess
                                object:nil];

    //下面两个 为了在收到通知或者点击status bar跳转其他页面时 结束频道编辑模式  by jojo
    [SNNotificationManager addObserver:self
                              selector:@selector(handleStatusMessageTappedNotify:)
                                  name:kStatusBarMessageDidTappedNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(handleStatusMessageTappedNotify:)
                                  name:kNotifyDidReceive
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(showRefreshMessage:)
                                  name:kChannelRefreshMessageNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(handleTipsViewDidTapNotify:)
                                  name:kSNRefreshMessageViewDidTapTipsNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(loadChannelListFromServer:)
                                  name:kLoadChannelListNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(doTapAction:)
                                  name:kCloseTipsImageViewNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(autoRefresh)
                                  name:kAutoRefreshChannelNewsNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(focusOnToutiao:)
                                  name:kRecommendReadMoreDidClickNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(updateLocalChannel:)
                                  name:kRollingChannelUpdateLocalNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(reloadChannelInfo)
                                  name:kRollingChannelReloadNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(deleteNewsCellWithNotification:)
                                  name:kDeleteNewsCellNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(pushViewControllerCloseAction)
                                  name:kPushViewControllerNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(toastUninterested)
                                  name:SNToastNotificaionRollingCellUninterested
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(refreshDynamicSkin)
                                  name:kLoadFinishDynamicPreferencesNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(changePreviewChannelNotification:)
                                  name:kChangePreviewChannelNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(saveChannelsToCache:)
                                  name:kSaveChannelsToCacheNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(hideTabBarView)
                                  name:kSNSHideTabBarNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(showTabBarView)
                                  name:kSNSShowTabBarNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(reachabilityChanged:)
                                  name:kReachabilityChangedNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(videoCellWillDismiss) name:@"kSNRollingVideoCellDidDismiss"
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(setNewsFontSize:)
                                  name:kFontModeChangeNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(couponReceiveSucces:)
                                  name:kJoinRedPacketsStateChanged
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(showRedPacketTheme:)
                                  name:kShowRedPacketThemeNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(showSpecialActivity:)
                                  name:kSpecialActivityShowNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(pushToNextChannel)
                                  name:SNROLLINGNEWS_PUSHTONEXTCHANNEL
                                object:nil];
    
    //要闻改版
    [SNNotificationManager addObserver:self
                              selector:@selector(hideAnimationLoading)
                                  name:SNROLLINGNEWS_HIDEANIMATIONLOADING
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(pushToRecomChannel)
                                  name:SHROLLINGNEWS_PUSHTORECOMCHANNEL
                                object:nil];
    //返回首页
    [SNNotificationManager addObserver:self
                              selector:@selector(backToHomeChannel)
                                  name:kRecommendToEidtModeNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(setRedPacketShow)
                                  name:kShowRedPacketButtonNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(changeStatusBarFrameNotification)
                                  name:UIApplicationDidChangeStatusBarFrameNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(setRollingNewsStyle:)
                                  name:KABTestChangeAppStyleNotification
                                object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(handleEnterForeground)
                                  name:UIApplicationDidBecomeActiveNotification
                                object:nil];
    [SNNotificationManager addObserver:self selector:@selector(open3DTouch) name:kOpenClientFrom3DTouchNotification object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(initContent) name:kSNRollingNewsViewControllerInitContentNotification object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(finishFullscreenMode)
                                  name:kSNFullscreenModeFinishedNotification
                                object:nil];
}

- (void)backToHomeChannel {
    //回到首页已经重置刷新页面, 不需要再提示Toast
    [[SNRollingNewsPublicManager sharedInstance] resetLeaveHomeTime];
    [SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom = NO;
    //回到首页
    [_rollingNewsScrollView scrollRectToVisible:
     CGRectMake(_rollingNewsScrollView.frame.size.width * 0,
                _rollingNewsScrollView.frame.origin.y,
                _rollingNewsScrollView.frame.size.width,
                _rollingNewsScrollView.frame.size.height) animated:YES];
}

- (BOOL)checkIsIntroChannel {
    //判断第二个频道是不是推荐频道
    if (self.channelDatasource.model.subedChannels.count > 1) {
        SNChannel *channel = [self.channelDatasource.model.subedChannels objectAtIndex:1];
        //13557为推荐频道频道ID
        if ([channel.channelId isEqualToString:@"13557"]) {
            return YES;
        }
    }
    return NO;
}

- (void)pushToNextChannel {
    if (![self checkIsIntroChannel]) {
        return;
    }
    //判断当前频道是不是要闻频道
    if (![self.selectedChannelId isEqualToString:@"1"]) {
        return;
    }
    
    [[SNDBManager currentDataBase] clearAllOtherRollingNewsList:@"13557"];
    
    _isPushToIntro = YES;
    //滑动到下一个页面
    [_rollingNewsScrollView scrollRectToVisible:
     CGRectMake(_rollingNewsScrollView.frame.size.width * 1,
                _rollingNewsScrollView.frame.origin.y,
                _rollingNewsScrollView.frame.size.width,
                _rollingNewsScrollView.frame.size.height) animated:YES];
    
    NSString *paramStr = [NSString stringWithFormat:@"_act=channel2channel&_tp=pv&position=%@&channelid=%@&tochannelid=%@", @"1", @"1", @"13557"];
    [SNNewsReport reportADotGif:paramStr];
}

- (void)pushToRecomChannel {
    if (self.channelDatasource.model.subedChannels.count > 1 && self.tabBar.tabViews.count > 1) {
        SNChannelScrollTab *introTab = [self.tabBar.tabViews objectAtIndex:1];
        [self.tabBar tabTouchedUp:introTab];
        //刷新页面
        [self.currTableController.dragDelegate autoRefresh];
    }
}

- (void)pushViewControllerCloseAction {
    //关闭cell更多弹出view
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:YES];
    [[SNRollingNewsPublicManager sharedInstance] closeListenNewsGuideViewAnimation:YES];
    [[SNTimelineSharedVideoPlayerView sharedInstance] stop];
    [[SNAutoPlaySharedVideoPlayer sharedInstance] stop];

    //需要清除SHMovieController
    [SNTimelineSharedVideoPlayerView forceStop];
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
}

- (void)videoCellWillDismiss {
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:YES];
    [[SNRollingNewsPublicManager sharedInstance] closeListenNewsGuideViewAnimation:YES];
    [[SNTimelineSharedVideoPlayerView sharedInstance] pause];
}

- (void)updateLocalChannel:(NSObject *)userData {
    [self.channelDatasource.model updateLocalChannel];
    
    _updateLocalChannel = YES;
    [SNRollingNewsPublicManager sharedInstance].channelRefreshClose = YES;
    
    [self p_reloadChannels];
    
    NSMutableString *idString = nil;
    
    for (SNChannel *channel in self.channelDatasource.model.subedChannels) {
        if (idString) {
            [idString appendFormat:@",%@", channel.channelId];
        } else {
            idString = [NSMutableString stringWithString:channel.channelId];
        }
    }
    
    if (idString.length > 0) {
        [self saveChannelListWithIdString:idString];
    }
}

- (void)deleteNewsCellWithNotification:(NSNotification *)notification {
    NSNumber *indexNumber = (NSNumber *)notification.object;
    int timelineIndex = [indexNumber intValue];
    [self.currTableController deleteNewsCellWithIndex:timelineIndex];
}

- (void)reloadChannelInfo {
    _updateLocalChannel = YES;
    [SNRollingNewsPublicManager sharedInstance].channelRefreshClose = YES;
    [_channelDatasource loadFromServer];
}

- (void)saveChannelListWithIdString:(NSString *)idString {
    if (!saveChannelService) {
        saveChannelService = [[SNSaveChannelListService alloc] init];
    }
    [saveChannelService saveChannelRequestWithIdStirng:idString];
}

- (void)guideViewDidDissmiss:(NSNotification *)notification {
    [self performSelector:@selector(doTapAction:) withObject:nil afterDelay:5];
}

- (void)registDidSuccessRefreshChannel {
    if (!self.haveAlreadyRightP1 && _channelDatasource) {
        [_channelDatasource loadFromServer];
        self.haveAlreadyRightP1 = YES;
    }
    
    if ([SNUtility sharedUtility].isWrongP1RequestNewsList) {
        [self autoRefresh];
    }
}

- (void)refreshchannels {
    if (_channelDatasource == nil ||
        _channelDatasource.model == nil ||
        _channelDatasource.model.channels == nil)
        return;
    
    //首先本地刷新
    NSString *firstChannelId = nil;
    NSString *selectChannelId = nil;
    NSMutableArray *subArrayEx = [NSMutableArray arrayWithCapacity:0];
    NSArray *subArray = [[SNDBManager currentDataBase] getSubedNewsChannelList];
    for (NSInteger i = 0; i < [subArray count]; i++) {
        NewsChannelItem *item = (NewsChannelItem *)[subArray objectAtIndex:i];
        SNChannel *channel = (SNChannel *)[_channelDatasource.model createChannelByItem:item];
        [subArrayEx addObject:channel];
        
        if (i == 0)
            firstChannelId = item.channelId;
        if (item.channelId != nil &&
            [item.channelId isEqualToString:self.tabBar.selectedTabItem.channelId])
            selectChannelId = item.channelId;
    }
    
    NSMutableArray *unsubArrayEx = [NSMutableArray arrayWithCapacity:0];
    NSArray *unsubArray = [[SNDBManager currentDataBase] getUnSubedNewsChannelList];
    for (NewsChannelItem *item in unsubArray) {
        SNChannel *channel = (SNChannel *)[_channelDatasource.model createChannelByItem:item];
        [unsubArrayEx addObject:channel];
    }
    
    if (selectChannelId != nil)
        self.selectedChannelId = selectChannelId;
    else if (firstChannelId != nil)
        self.selectedChannelId = firstChannelId;
    else
        return;
    
    //TODO:怎么办?
    [_channelDatasource.model removeAllObjects];
    [_channelDatasource.model addObjectsFromArray:subArrayEx];
    [_channelDatasource.model addObjectsFromArray:unsubArrayEx];
    [_channelDatasource.model cacheChannelsInMutiThread];
    
    [self performSelectorOnMainThread:@selector(updateChannels:) withObject:nil waitUntilDone:YES];
    
    //然后触发服务器合并操作
    [_channelDatasource performSelector:@selector(loadFromServer) withObject:nil afterDelay:2.0];
}

- (void)loadChannelListFromServer:(NSNotification *)notification {
    _channelDatasource.savedIDString = [notification.userInfo stringValueForKey:kSavedChannelIDStingKey defaultValue:@""];
    [_channelDatasource loadFromServer];
}

- (void)initContent {
    if (!_rollingNewsScrollView) {
        [self createScrollView];
        if (self.channelDatasource.model.channels.count == 0) {
            if (![SNUtility shouldShowEditMode]) {
                self.tabBar.isChannelTempStatus = YES;
            }
            [_channelDatasource loadFromCache];
        }
        self.tabBar.isChannelTempStatus = NO;
        
        if (!self.haveAlreadyRightP1) {
            [_channelDatasource loadFromServer];
            self.haveAlreadyRightP1 = [SNUtility isRightP1];
        }
        
        NSInteger selected = self.tabBar.selectedTabIndex;
        if (NSIntegerMax == selected) {
            selected = 0;
        }

        if (![SNUtility isFirstInstallOrUpdateApp]) {
            if ([self getAnimationView]) {
                [[self getAnimationView] setStatus:SNImageLoadingStatusStopped];
                [[self getAnimationView] removeFromSuperview];
                _animationImageView = nil;
            }
        }
        
        [SNUtility recordShowEditModeNewsFromBack:NO];
        if (![SNNewsFullscreenManager newsChannelChanged]) {
            //判断启动后进入编辑流频道还是推荐流频道
            if (![SNUtility shouldShowEditMode] &&
                [self checkIsIntroChannel]) {
                self.tabBar.isChannelTempStatus = YES;
                selected = 1;
                self.tabBar.selectedTabIndex = 1;
                _isFirstPushToIntro = YES;
            }
        } else {
            if (![SNUtility shouldShowEditMode]) {
                //要闻改版后, 服务端配置默认进入频道
                NSString *defultEnterChannel = [[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsDefaultEnterChannelID];
                
                //测试
                //NSString *defultEnterChannel = @"283";
                NSArray *subChannels = self.channelDatasource.model.subedChannels;
                NSInteger index = 0;
                BOOL isChannelExist = NO;
                for (NSInteger i = 0; i < [subChannels count]; i++) {
                    SNChannel *channel = subChannels[i];
                    if ([defultEnterChannel isEqualToString:channel.channelId]) {
                        index = i;
                        isChannelExist = YES;
                        break;
                    }
                }
                
                if (index != 0 && isChannelExist) {
                    self.tabBar.isChannelTempStatus = YES;
                    selected = index;
                    self.tabBar.selectedTabIndex = index;
                    self.tabBar.selectedChannelId = defultEnterChannel;
                }
            }
        }
        self.tabBar.isChannelTempStatus = NO;

        [_rollingNewsScrollView setContentSize:CGSizeMake(kAppScreenWidth * _channelDatasource.model.subedChannels.count, _rollingNewsScrollView.size.height)];
        if (self.currTableController == nil) {
            self.currTableController = [self loadScrollViewWithPage:selected];
        }
        
        self.leftTableController = [_channelTableViewControllerArray objectAtIndex:(selected + kCOUNT - 1) % kCOUNT];
        self.rightTableController = [_channelTableViewControllerArray objectAtIndex:(selected + 1) % kCOUNT];
        _currSelectedIndex = selected;
        if (selected == 1) {
            [_rollingNewsScrollView setContentOffset:CGPointMake(_rollingNewsScrollView.frame.size.width * 1, _rollingNewsScrollView.frame.origin.y) animated:NO];
        }
        if (_tabbarSnapView && _tabbarSnapView.superview == nil) {
            [self.view addSubview:_tabbarSnapView];
        }
        //第一次启动app，首页显示字体引导(2017.9.14产品要求去掉字体设置浮层 liteng)
        //[self showFontSetterGuideGuide];
    }
    
    if ([SNUtility isFirstInstallOrUpdateApp]) {
        //首次安装启动App同步List.go
        [[self getAnimationView].targetView bringSubviewToFront:[self getAnimationView]];
    }
    
    if (![SNNewsFullscreenManager newsChannelChanged]) {
        return;
    }
    //每次程序启动清理一次
    //如果不是要闻频道改版, 不进行以下操作
    //清理不必要的历史记录数据
    for (SNChannel *channel in self.channelDatasource.model.subedChannels) {
        if ([@"1" isEqualToString:channel.channelId]) {
            //根据订阅频道ID按顺序清理频道历史
            [[SNDBManager currentDataBase] clearRollingNewsHistoryByChannelID:channel.channelId days:[[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsSaveDays]];
            break;
        }
    }
}

- (void)createScrollView {
    //Tabbar
    self.channelDatasource = [[SNChannelScrollTabBarDataSource alloc] initWithController:self];
    self.tabBar = [[SNChannelScrollTabBar alloc] initWithChannelId:_selectedChannelId showLogo:YES];
    tabBar.scrollTabType = SNChannelScrollTabTypeNews;
    tabBar.delegate = self;
    _channelDatasource.tabBar = tabBar;
    [self.tabBar.animationView resetLineNormalColor:NO];
    
    if (isViewReleased) {
        tabBar.isReleased = YES;
    }
    
    if (_rollingNewsScrollView) {
        //未找到根源，暂时修改？
        [_rollingNewsScrollView removeObserver:self.tabBar forKeyPath:@"contentOffset"];
    }
    
    CGRect frame = CGRectMake(0, kHeadSelectViewBottom,
                              kAppScreenWidth, kAppScreenHeight);
    //UIScrollView
    _rollingNewsScrollView = [[SNHomeScrollView alloc] initWithFrame:frame];
    _rollingNewsScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _rollingNewsScrollView.scrollsToTop = NO;
    _rollingNewsScrollView.delegate = self;
    _rollingNewsScrollView.showsHorizontalScrollIndicator = NO;
    _rollingNewsScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_rollingNewsScrollView];
    
    _rollingNewsScrollView.pagingEnabled = YES;
    _rollingNewsScrollView.bounces = NO;
    
    tabBar.frame = CGRectMake(0, 0, tabBar.width, tabBar.height);
    [self.view addSubview:tabBar];
    _rollingNewsScrollView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    [_rollingNewsScrollView addObserver:self.tabBar
                             forKeyPath:@"contentOffset"
                                options:NSKeyValueObservingOptionNew
                                context:NULL];
    
    //Page的占位图
    _emptyImgArray = [[NSMutableArray alloc] initWithCapacity:30];
    UIImage *defaultImage = [UIImage imageNamed:@"sohu_loading_1.png"];
    for (int i = 0; i < _channelDatasource.model.channels.count; ++i) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:defaultImage];
        imgView.center = CGPointMake(i * frame.size.width + frame.size.width / 2, _rollingNewsScrollView.center.y - kErrorViewOffset);
        [_rollingNewsScrollView addSubview:imgView];
        [_emptyImgArray addObject:imgView];
    }
    
    if (!_channelTableViewControllerArray) {
        _channelTableViewControllerArray = [[NSMutableArray alloc] initWithCapacity:kCOUNT];
        
        for (int i = 0; i < kCOUNT; ++i) {
            SNRollingNewsTableController *controller = [[SNRollingNewsTableController alloc] init];
            controller.parentViewControllerForModalADView = self;
            controller.tabBar = self.tabBar;
            [_channelTableViewControllerArray addObject:controller];
        }
    } else {
        for (int i = 0; i < kCOUNT; ++i) {
            SNRollingNewsTableController *controller = [_channelTableViewControllerArray objectAtIndex:i];
            controller.tabBar = self.tabBar;
        }
    }
    if (!_messageView) {
        _messageView = [[SNRefreshMessageView alloc] init];
        [self.view insertSubview:_messageView belowSubview:self.tabBar];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ///*****- viewDidLoad 中不要处理耗时操作，影响启动时间*****///
    _bFirstLoad = YES;
    //Fix:左滑页面为空
    self.leftTableController.isViewReleased = NO;
    self.rightTableController.isViewReleased = NO;
    // add by Cae. 处理外链调起的情况
    [[SNExternalLinkHandler sharedInstance] handleExternalLinker];
    [self.animationImageView setStatus:SNImageLoadingStatusLoading];
    ///*****- viewDidLoad 中不要处理耗时操作，影响启动时间*****///
}

- (SNLoadingImageAnimationView *)animationImageView {
    if (!_animationImageView) {
        _animationImageView = [[SNLoadingImageAnimationView alloc] init];
        _animationImageView.targetView = self.view;
    }
    return _animationImageView;
}

- (SNLoadingImageAnimationView *)getAnimationView {
    return _animationImageView;
}

- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_channel_tip.png"]];
        _tipImageView.origin = CGPointMake(2.5, 40 + kSystemBarHeight);
        [self.view addSubview:_tipImageView];
        _tipImageView.hidden = YES;
        _tipImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTapAction:)];
        [_tipImageView addGestureRecognizer:tap];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, _tipImageView.width - 20, _tipImageView.height - 6)];
        [label setText:@"新频道上线了，快添加看看"];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 101;
        [_tipImageView addSubview:label];
    }
    return _tipImageView;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    if (self.channelDatasource) {
        [self.channelDatasource removeObservers:self];
    }
    if (_rollingNewsScrollView && self.tabBar) {
        [_rollingNewsScrollView removeObserver:self.tabBar forKeyPath:@"contentOffset"];
    }
    _channelDatasource.tabBar = nil;
}

- (void)autoRefresh {
    //重置刷新，清空缓存
    if (self.currTableController.isNewChannel &&
        ![self.currTableController isHomePage]) {
        //流式频道保留最新20条缓存
        NSString *lChannelId = self.currTableController.selectedChannelId;
        [[SNDBManager currentDataBase] clearAllOtherRollingNewsList:lChannelId];
    }
    
    [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:0 channelId:self.currTableController.selectedChannelId];
    
    //频道点击tab,重置刷新，清空请求参数缓存
    [[SNRollingNewsPublicManager sharedInstance] deleteRequestParamsWithChannelId:self.currTableController.selectedChannelId];
    [self.currTableController.dragDelegate autoRefresh];
    [self.currTableController refreshH5WebView];
    
    if (!self.currTableController.isNewChannel ||
        [self.currTableController isHomePage]) {
        //重置刷新，清空缓存
        [[SNDBManager currentDataBase] clearRollingNewsListByChannelId:self.currTableController.selectedChannelId];
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [[TTURLCache sharedCache] removeAll:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /**********************************************************************/
    /*******- (void)viewWillAppear: 不要做过多的耗时操作，影响APP启动速度*******/
    /**********************************************************************/
    [self.currTableController viewWillAppear:animated];
    
    if (!self.currTableController.model.isLoading &&
        [self.currTableController.dragDelegate shouldReload]) {
        [self.currTableController.dragDelegate reload];
    }
    [self.currTableController stopPageTimer:NO];
    [SNUtility trigerSpecialActivity];
    if (!_channelManageView) {
        [self shouldChangeStatusBarTextColorToDefault:NO];
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    if (self.tabBar.selectedTabView) {
        self.tabBar.selectedTabView.selected = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate mainViewDidAppear];
    [self.currTableController viewDidAppear:animated];
    if ([SNNewsFullscreenManager manager].isFullscreenMode && [self isHomePage] && ![SNUtility isFromChannelManagerViewOpened]) {
        [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:YES];
    }else{
        [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:NO];
    }
    //恢复预加载队列
    [[SNNewsPreloader sharedLoader] resumeAllWifiDownloadOperationIfNeeded];

    //v5.2.2
    NSString *cidString = [[NSUserDefaults standardUserDefaults] objectForKey:kCloudSynchronousCid];
    if (cidString && _currSelectedIndex == 0) {//弹出同步浮层
        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            SNCloudSynAlert *cloudSynAlert = [[SNCloudSynAlert alloc] initWithAlertViewData:nil];
            [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:cloudSynAlert];
        }
    }

    self.tabBar.observeScrollEnable = YES;
    if (![[SNQRUtility sharedInstanced] isScanning]) {
        if (![SNUtility isFromChannelManagerViewOpened] && !_bFirstLoad) {
            [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeChannels majorkey:self.selectedChannelId];
        }
        /// 检查是否有符合条件的弹窗
        [[SNAlertStackManager sharedAlertStackManager] checkoutInStackAlertView];

    }
    if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
        [self showSpecialActivity:nil];
    }
    
    [SNUtility handleClipper];
    //[2012-10-16 chh added 立即加载相邻页]
    if (_bFirstLoad) {
        _bFirstLoad = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isViewAppearedFromTabSelected = NO;
    
    [self.currTableController viewWillDisappear:animated];

    [self doTapAction:nil];
    self.tabBar.observeScrollEnable = NO;
    
    //暂停预加载队列
    [[SNNewsPreloader sharedLoader] pauseAllWifiDownloadOperations];
    
    [self.tabBar.popOverView dismiss];
    [self.currTableController stopPageTimer:YES];
    
    //广告视频 wangshun 切换单音模式 RollingVideoCell
    [SNADVideoCellAudioSession sharedInstance].isADVideo = NO;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [[SNSpecialActivity shareInstance] dismissLastChannelSpecialAlert];

    [self shouldChangeStatusBarTextColorToDefault:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.currTableController viewDidDisappear:animated];
}

- (void)updateTheme:(NSNotification *)notifiction {
    [self customTheme];
}

//取得当前选中的频道Index
- (NSInteger)p_getCurrentSelectedIndex {
    NSArray *channelList = _channelDatasource.model.subedChannels;
    NSInteger selected = 0;
    for (NSInteger i = 0; i < channelList.count; ++i) {
        SNChannel *item = [channelList objectAtIndex:i];
        if ([_selectedChannelId isEqualToString:item.channelId]) {
            selected = i;
            break;
        }
    }
    return selected;
}

//从频道管理页面跳转到频道流, 刷新页面
- (void)p_reloadChannels {
    NSArray *channelList = _channelDatasource.model.subedChannels;
    _curIndex = [self p_getCurrentSelectedIndex];
    
    if (channelList.count == 0) {
        self.selectedChannelId = @"1";
    }
    
    [self.tabBar reloadChannels:_curIndex channelId:self.selectedChannelId];
}

- (void)updateChannels:(NSNotification *)notifiction {
    id data = [notifiction object];
    
    NSArray *channelList = _channelDatasource.model.subedChannels;
    
    if (channelList.count == 0) {
        [self hideAnimationLoading];
        return;
    }
    _curIndex = [self p_getCurrentSelectedIndex];
    
    //重新刷新
    [self.tabBar reloadChannels];
    
    CGRect frame = _rollingNewsScrollView.frame;
    //如果两边的Count不相等, 再创建
    if (channelList.count > 0 &&
        channelList.count != _emptyImgArray.count) {
        [_rollingNewsScrollView setContentSize:CGSizeMake(frame.size.width * channelList.count, frame.size.height)];
        [_rollingNewsScrollView setContentOffset:CGPointMake(_curIndex * frame.size.width, 0)];
        
        UIImage *defaultImage = [UIImage imageNamed:@"sohu_loading_1.png"];
        for (UIImageView *placeholderImg in _emptyImgArray) {
            [placeholderImg removeFromSuperview];
        }
        [_emptyImgArray removeAllObjects];
        
        for (int i = 0; i < channelList.count; ++i) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:defaultImage];
            imgView.center = CGPointMake(i * frame.size.width + frame.size.width / 2, _rollingNewsScrollView.center.y - kErrorViewOffset);
            [_rollingNewsScrollView insertSubview:imgView atIndex:0];
            [_emptyImgArray addObject:imgView];
        }
    }
    
    //判断List.go是否成功, 先不用PENG
    if (data && [data isKindOfClass:[NSNumber class]]) {
        BOOL isSyncChannelList = NO;
        NSNumber *isSync = (NSNumber *)data;
        if (isSync) {
            isSyncChannelList = [isSync boolValue];
        }
        if (![SNUtility isListGOSync]) {
            [SNUtility recordListGOSync:isSyncChannelList];
        }
    }
    [self refreshCurrTableController];
}

- (void)recreateChannelTabbar {
    if (self.tabBar) {
        self.tabBar.delegate = nil;
        [self.tabBar removeFromSuperview];
        [_rollingNewsScrollView removeObserver:self.tabBar
                                    forKeyPath:@"contentOffset"];
    }
    
    self.channelDatasource = [[SNChannelScrollTabBarDataSource alloc] init];
    self.tabBar = [[SNChannelScrollTabBar alloc] initWithChannelId:_selectedChannelId];
    
    [_rollingNewsScrollView addObserver:self.tabBar
                             forKeyPath:@"contentOffset"
                                options:NSKeyValueObservingOptionNew
                                context:NULL];
    
    self.tabBar.isReleased = YES;
    self.tabBar.delegate = self;
    self.tabBar.dataSource = _channelDatasource;
    _channelDatasource.tabBar = tabBar;
    [_channelDatasource loadFromCache];
    [self.view addSubview:self.tabBar];
    
    for (SNRollingNewsTableController *controller in _channelTableViewControllerArray) {
        controller.tabBar = self.tabBar;
    }
}

- (void)changeViewBg {
    self.view.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    _rollingNewsScrollView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}

- (void)customTheme {
    [self customTitleView];
    [self changeViewBg];
    [self.tabBar updateTheme];
    
    if (self.currTableController.isViewLoaded) {
        [self.currTableController updateTheme];
    }
    if (self.leftTableController.isViewLoaded) {
        [self.leftTableController updateTheme];
    }
    if (self.rightTableController.isViewLoaded) {
        [self.rightTableController updateTheme];
    }
    
    //Page的占位图
    UIImage *defaultImage = [UIImage imageNamed:@"sohu_loading_1.png"];
    for (UIImageView *imgView in _emptyImgArray) {
        imgView.image = defaultImage;
    }
}

- (void)scrollToPageIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (selectedIndex < 0 ||
        selectedIndex >= _channelDatasource.model.subedChannels.count) {
        return;
    }
    
    if (selectedIndex * self.view.frame.size.width != _rollingNewsScrollView.contentOffset.x) {
        [_rollingNewsScrollView setContentOffset:CGPointMake(selectedIndex * self.view.frame.size.width, 0) animated:animated];
    }
}

- (void)doTapAction:(UITapGestureRecognizer *)tap {
    if (self.tipImageView.hidden)
        return;
    
    [UIView animateWithDuration:.5 animations:^{
        self.tipImageView.alpha = 0;
    } completion:^(BOOL finished) {
        self.tipImageView.hidden = YES;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"hasNewChannel"]) {
        BOOL hasNewChannel = [(NSNumber *)[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (hasNewChannel) {
            //防止打开正文后仍弹出提示
            if (!self.currTableController.isViewAppeared) {
                return;
            }
            
            self.tipImageView.image = [UIImage imageNamed:@"new_channel_tip.png"];
            self.tipImageView.alpha = 0;
            self.tipImageView.hidden = NO;
            
            UILabel *label = (UILabel *)[self.tipImageView viewWithTag:101];
            [label setText:@"新频道上线了，快添加看看"];
            
            [UIView animateWithDuration:.5 animations:^{
                self.tipImageView.alpha = 1;
            }completion:^(BOOL finished) {
                if (![[SNUtility getApplicationDelegate] isGuideViewShow]) {
                    [self performSelector:@selector(doTapAction:) withObject:nil afterDelay:3];
                }
            }];
        }
    } else if ([keyPath isEqualToString:@"firstLaunch"]) {
        BOOL firstLaunch = [(NSNumber *)[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (firstLaunch) {
            self.tipImageView.image = [UIImage imageNamed:@"new_channel_tip.png"];
            self.tipImageView.alpha = 0;
            self.tipImageView.hidden = NO;
            
            UILabel *label = (UILabel *)[self.tipImageView viewWithTag:101];
            [label setText:@"编辑我的频道"];
            
            [UIView animateWithDuration:.5 animations:^{
                self.tipImageView.alpha = 1;
            } completion:^(BOOL finished) {
                if (![[SNUtility getApplicationDelegate] isGuideViewShow]) {
                    [self performSelector:@selector(doTapAction:) withObject:nil afterDelay:5];
                }
            }];
        }
    } else if ([keyPath isEqualToString:@"showLogo"]) {
        [self.tabBar updateShowLogo: self.channelDatasource.model.showLogo
                            logoUrl:self.channelDatasource.model.icon
                               link:self.channelDatasource.model.link];
    }
}

- (void)focusOnToutiao:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    if (info.count > 0) {
        NSNumber *infoNum = [info valueForKey:kClickTabToRefreshHomeKey];
        if (infoNum) {
            ClickTabToRefreshHome enumKey = [infoNum integerValue];
            switch (enumKey) {
                case ClickTabToRefreshHome_Tab: {
                    [SNRollingNewsPublicManager sharedInstance].backToHomeAndRefreshForNewsChanged = YES;
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    if ([SNRollingNewsPublicManager sharedInstance].isClickTodayImportNews) {
        [self.currTableController.dragDelegate loadLocal];
    }
    [SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow = YES;
    [SNRollingNewsPublicManager sharedInstance].isRecommendAfterEditNews = NO;
    [SNRollingNewsPublicManager sharedInstance].isClickBackToHomePage = YES;
    [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
    [[SNVideoAdContext sharedInstance] setCurrentTabIndex:0];
   
    _currSelectedIndex = 0;
    [self.tabBar setSelectedTabIndex:0];
    [self.tabBar toScrollingAnimation:0 haveAnimation:YES];

    [[SNRollingNewsPublicManager sharedInstance] setFocusImageIndex:0 channelId:self.currTableController.selectedChannelId];
    [self performSelector:@selector(focusAutoPlay) withObject:nil afterDelay:1.0];
}

- (void)focusAutoPlay {
    [self.currTableController.dragDelegate transformationAutoPlayTop:(TTTableView *)self.currTableController.tableView];
}

#pragma mark - SNChannelScrollTabBarDelegate
#pragma mark Tab select
- (void)tabBar:(SNChannelScrollTabBar *)aTabBar
   tabSelected:(NSInteger)selectedIndex {
    if (selectedIndex != 0) {
        [self.tabBar.popOverView dismiss];
    }
    
    [self dismissPopoverMessage];
    
    //v5.2.2
    NSString *cidString = [[NSUserDefaults standardUserDefaults] objectForKey:kCloudSynchronousCid];
    if (cidString && selectedIndex == 0) {
        //弹出同步浮层
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
            return;
        }
        SNCloudSynAlert *cloudSynAlert = [[SNCloudSynAlert alloc] initWithAlertViewData:nil];
        [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:cloudSynAlert];
    }
    
    //关闭cell更多弹出view
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:YES];
    
    if (selectedIndex < 0 ||
        selectedIndex >= _channelDatasource.model.subedChannels.count) {
        return;
    }
    
    BOOL channelChanged = YES;
    if ([self.tabBar.selectedTabItem.channelId isEqualToString:self.selectedChannelId]) {
        channelChanged = NO;
    } else {
        //频道切换，上报服务端频道停留总时长
        int totalSec = [[SNRollingNewsPublicManager sharedInstance] rollingNewsTotalTime];
        if (totalSec != 0) {
            //上报总时长
            [SNNewsReport reportChannelStayDuration:totalSec channelID:self.currTableController.selectedChannelId];
        }
    }
    [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = !channelChanged;
    
    self.selectedChannelId = self.tabBar.selectedTabItem.channelId;
    [SNNewsNotificationManager sharedInstance].channelId = self.selectedChannelId;
    
    if ([self isHomePage]) {
        //点击首页频道按钮跳转首页时需要手动调用一下didScroll: offset传0即可
        [self.tabBar rollingNewsTableViewDidScroll:self.tabBar.homeTableViewOffsetY];
        if (channelChanged) {
            [[SNRollingNewsPublicManager sharedInstance] resetLeaveHomeTime];
            [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = NO;
        } else {
            [SNRollingNewsPublicManager sharedInstance].refreshClose = YES;
        }
        if (_updateLocalChannel) {
            _updateLocalChannel = NO;
            [SNRollingNewsPublicManager sharedInstance].refreshClose = YES;
        }
    } else {
        if (_updateLocalChannel) {
            _updateLocalChannel = NO;
        }
        [[SNRollingNewsPublicManager sharedInstance] recordLeaveHomeTime];
    }
    
    //首页下拉有时候不响应请求
    if ([self isHomePage]) {
        [SNRollingNewsPublicManager sharedInstance].refreshClose = NO;
    }
    
    _canLoadFlag = NO;
    
    //5.2.2 相邻频道逻辑判断
    if (labs(_currSelectedIndex - selectedIndex) == 1 ||
        _currSelectedIndex == selectedIndex) {
        [SNRollingNewsPublicManager sharedInstance].isNeighChannel = YES;
    }
    //NSArray的count方法返回的是无符号整型,没有负数，当数组为空时,条件a>array.count-1中,array.count -1是一个非常大的正数,正确写法，a+1>array.count
    if (_currSelectedIndex + 1 > [_channelDatasource.model.subedChannels count]) {
        //避免取最后一个元素，数组越界
        _currSelectedIndex = [_channelDatasource.model.subedChannels count] - 1;
    }
    SNChannel *channel = [_channelDatasource.model.subedChannels objectAtIndex:_currSelectedIndex];
    [SNUtility sharedUtility].currentChannelCategoryID = channel.channelCaterotyID;
   
    if (_currSelectedIndex == selectedIndex &&
        ([self.tabBar.selectedChannelId isEqualToString:@"13555"] ||
         [self.tabBar.selectedChannelId isEqualToString:@"960415"])){
    } else {
        [self.currTableController hideNovelPopover];
        for (id vc in _channelTableViewControllerArray) {
            if ([vc isKindOfClass:[SNRollingNewsTableController class]]) {
                [(SNRollingNewsTableController *)vc hideNovelPopover];
            }
        }
    }
    _currSelectedIndex = selectedIndex;
    
    SNRollingNewsTableController *selectedTableController = [self loadScrollViewWithPage:selectedIndex];
    if (selectedTableController == self.currTableController) {
        selectedTableController.isReuse = YES;
    } else {
        selectedTableController.isReuse = NO;
        [self.currTableController stopPageTimer:YES];
    }
    
    _canLoadFlag = YES;
    
    self.currTableController = selectedTableController;
    self.currTableController.tableView.scrollsToTop = YES;
    self.leftTableController = [_channelTableViewControllerArray objectAtIndex:(selectedIndex - 1 + kCOUNT) % kCOUNT];
    if (self.leftTableController.isViewLoaded) {
        self.leftTableController.tableView.scrollsToTop = NO;
    }
    
    self.rightTableController = [_channelTableViewControllerArray objectAtIndex:(selectedIndex + 1) % kCOUNT];
    if (self.rightTableController.isViewLoaded) {
        self.rightTableController.tableView.scrollsToTop = NO;
    }
    [self scrollToPageIndex:selectedIndex animated:NO];    

    CGRect frame = self.currTableController.view.frame;
    self.currTableController.view.frame = CGRectMake(selectedIndex * self.view.frame.size.width, 0, frame.size.width, frame.size.height);
    
    //Add by Cae.
    //原始代码是这样的 [self.currTableController.dataSource.model cancel];
    //无条件cancel. 后来加了买房频道之后，这样会引起问题，就改成了只有在本地频道和买房频道里，并且没有地理位置权限的时候才cancel,以触发加载失败逻辑
    if ([SNRollingNewsModel isLocalChannel:self.tabBar.selectedChannelId]) {
        if (![SNUserLocationManager sharedInstance].hasLocationAuthorization) {
            [self.currTableController.dataSource.model cancel];
        }
    }
    
    if (selectedIndex < _channelDatasource.model.subedChannels.count) {
        SNChannel *channel = [_channelDatasource.model.subedChannels objectAtIndex:selectedIndex];
        channel.isPreloadChannel = NO;
        if ([channel.channelId isEqualToString:@"283"]) {
            //30分钟更新本地频道, 防止本地频道刷新两次
            if (![SNUtility resetLocationChannelWithChannelID:_selectedChannelId]) {
                [selectedTableController tabBar:aTabBar channelSelected:channel];
            }
        } else {
            [selectedTableController tabBar:aTabBar channelSelected:channel];
        }

        if ([self.currTableController respondsToSelector:@selector(rollingNewsTableDidSelected)]) {
            [self.currTableController rollingNewsTableDidSelected];
            [self refreshCurrentChannel];
        }
        [selectedTableController reportPopularizeStatExposureInfo];
        if (!selectedTableController.isViewAppeared) {
            [selectedTableController viewWillAppear:NO];
            [selectedTableController viewDidAppear:NO];
        } else {
            if ([SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose) {
                [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = NO;
            }
        }
        
        if (![self isHomePage]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"getBarHeight_first"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    // 更新wifi预加载当前频道状态
    if (self.currTableController.dragDelegate &&
        self.currTableController.dragDelegate.enablePreload) {
        [self.currTableController.dragDelegate startFetchDataInWifi];
    }
    
    if (!self.tipImageView.hidden) {
        [self doTapAction:nil];
    }
    
    [selectedTableController stopPageTimer:NO];

    [SNUtility sharedUtility].currentChannelId = self.selectedChannelId;
    SNTabbarView *tabview = (SNTabbarView *)[TTNavigator navigator].topViewController.tabbarView;
    if (tabview.currentSelectedIndex == 0 &&
        [self.selectedChannelId isEqualToString:@"1"]) {
    }
    
    [self setRedPacketShow];
    
    NSString *currentChannelId = [SNUtility sharedUtility].currentChannelId;
    if (LoadingSwitch) {
        SNSplashModel *splashModel = [SNUtility getApplicationDelegate].splashModel;
        if ([currentChannelId isEqualToString:@"1"] && !splashModel.isSplashVisible) {
            NSString *specialActivityMD5 = [[NSUserDefaults standardUserDefaults] objectForKey:kSpecialActivityMD5Key];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kNewUserGuideHadEndShown] && specialActivityMD5.length > 0) {
                [SNUtility trigerSpecialActivity];
            }
        }
        if (!splashModel.isSplashVisible && [[TTNavigator navigator].topViewController isKindOfClass:[SNRollingNewsViewController class]] && !_channelManageViewContainer) {
            [SNUtility handleClipper];
        }
    } else {
        SNSplashViewController *splashViewController = [SNUtility getApplicationDelegate].splashViewController;
        if ([currentChannelId isEqualToString:@"1"] && !splashViewController.isSplashViewVisible) {
            NSString *specialActivityMD5 = [[NSUserDefaults standardUserDefaults] objectForKey:kSpecialActivityMD5Key];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kNewUserGuideHadEndShown] && specialActivityMD5.length > 0) {
                [SNUtility trigerSpecialActivity];
            }
        }
        if (!splashViewController.isSplashViewVisible && [[TTNavigator navigator].topViewController isKindOfClass:[SNRollingNewsViewController class]] && !_channelManageViewContainer) {
            [SNUtility handleClipper];
        }
    }
    if ([SNNewsFullscreenManager manager].isFullscreenMode
        && [self isHomePage]
        && self.tabBar.homeTableViewOffsetY == 0
        && ![SNUtility isFromChannelManagerViewOpened]) {
        [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:YES];
    }else {
        [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:NO];
    }
    /// 检查是否有符合条件的弹窗
    [[SNAlertStackManager sharedAlertStackManager] checkoutInStackAlertView];
}

- (void)tabBarAutoRefresh:(SNChannelScrollTabBar *)tabBar {
    if ([SNRollingNewsPublicManager sharedInstance].resetOpen == YES && ![SNNewsFullscreenManager newsChannelChanged]) {
        [self autoRefresh];
        return;
    }
    
    if ([_channelDatasource.model.subedChannels count] > _currSelectedIndex) {
        SNChannel *channel = [_channelDatasource.model.subedChannels objectAtIndex:_currSelectedIndex];
        [self.currTableController changeModelToNewChannel:channel];
    }
    if (self.currTableController.isNewChannel || self.currTableController.isMixStream == NewsChannelEditAndRecom) {
        //流式频道点击频道名刷新，非重置
        [self.currTableController resetTableAndRefresh];
        [self dismissPopoverMessage];
    } else {
        if ([self isHomePage]) {
            [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
        }
        [self autoRefresh];
    }
}

- (void)tabBarBeginEdit:(SNChannelScrollTabBar *)tabBar {
    if (_channelManageViewContainer) {
        if ([_selectedChannelId isEqualToString:@"176"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"slideToSubscribe"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [SNRollingNewsPublicManager sharedInstance].channelRefreshClose = YES;
        [self channelMangeViewHideAction:nil];
        [SNUtility handleClipper];
        return;
    }
    
    [SNUtility shouldUseSpreadAnimation:NO];
    
    //离开首页计时
    if ([self isHomePage]) {
        [[SNRollingNewsPublicManager sharedInstance] recordLeaveHomeTime];
    }
    //进入频道预览上报频道停留总时长
    int totalSec = [[SNRollingNewsPublicManager sharedInstance] rollingNewsTotalTime];
    if (totalSec != 0) {
        //上报总时长
        [SNNewsReport reportChannelStayDuration:totalSec channelID:self.currTableController.selectedChannelId];
    }
    
    self.hasEditedChannels = NO;
    
    if (!_channelManageViewContainer) {
        _channelManageViewContainer = [[UIView alloc]
                                       initWithFrame:CGRectMake(0, 0, kAppScreenWidth, TTApplicationFrame().size.height)];
        [self.view addSubview:_channelManageViewContainer];
        
        [self shouldChangeStatusBarTextColorToDefault:YES];
        
        [self.tabBar resetTopScrollBarBackColor:YES];
    }
    
    [self.tabBar removeFromSuperview];
    [_channelManageViewContainer addSubview:self.tabBar];
    
    if (!_channelManageView) {
        if ([SNCheckManager checkDynamicPreferences]) {
            self.tabBar.scrollView.hidden = YES;
            [self.tabBar shouldShowSohuLogo:NO];
        }
        
        _channelManageView = [[SNChannelManageViewV2 alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _channelManageViewContainer.height)];
        _channelManageView.isNotNewsTab = NO;
        _channelManageView.delegate = self;
        _channelManageView.bottom = 0;
        [_channelManageViewContainer insertSubview:_channelManageView belowSubview:self.tabBar];
    }
    _channelManageView.currentSelectedChannelId = self.selectedChannelId;
    
    NSArray *channels = _channelDatasource.model.channels;
    NSMutableArray *subed = [NSMutableArray array];
    NSMutableArray *unsubed = [NSMutableArray array];
    for (SNChannel *ch in channels) {
        SNChannelManageObject *obj = [[SNChannelManageObject alloc] initWithObj:ch type:SNChannelManageObjTypeChannel];
        obj.addNew = ch.add;
        if ([obj.isSubed isEqualToString:@"1"]) {
            [subed addObject:obj];
        } else {
            [unsubed addObject:obj];
        }
    }
    
    [_channelManageView setSubedArray:subed
                      andUnsubedArray:unsubed isRollingNewsTab:YES];
    
    [self.tabBar channelsEditViewWillAnimate:YES];
    //Start Anmation
    [UIView animateWithDuration:kSNChannelManageViewV2AnimationDuration
                     animations:^{
        //如果视频播放, 关闭视频
        [SNTimelineSharedVideoPlayerView forceStop];
        [SNAutoPlaySharedVideoPlayer forceStopVideo];
        _isExpandChannelView = YES;
        //_channelManageView.top = self.tabBar.height - 8 - ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? 50 : 0);
        _channelManageView.top = 0;
        [self.tabBar.animationView resetLineNormalColor:YES];
    } completion:^(BOOL finished) {
        [self.tabBar showChannelManageMode:YES animated:YES
                         isFromRollingNews:YES];
        if ([SNCheckManager checkDynamicPreferences]) {
            self.tabBar.scrollView.hidden = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tabBar shouldShowSohuLogo:YES];
            });
        }
    }];

    if (!self.tipImageView.hidden) {
        [self doTapAction:nil];
    }
    [self hideTabBarView];
    
    //频道列表曝光PV、UV
    [self exposure];
}

/*
 *组装上传数据，
 *格式：@statType_objFrom_objFromId_objType_token_objId(,objId)@statType_objFrom_objFromId_objType_token_objId(,objId)
 *return NSString *组装好的字符串
 */
- (void)exposure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *channelIDS = nil;
        NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
        if ([channelList count] > 0) {
            for (NewsChannelItem *item in channelList) {
                if (!channelIDS) {
                    channelIDS = item.channelId;
                } else {
                    channelIDS = [channelIDS stringByAppendingFormat:@",%@", item.channelId];
                }
            }
        }
        NSString *uploadData = [NSString stringWithFormat:@"@show_1_1_exps18_%@_%@", [SNUserManager getToken], channelIDS];
        
        [[[SNExposureRequest alloc] initWithUploadString:uploadData] send:^(SNBaseRequest *request, id responseObject) {
        } failure:nil];
    });
}

- (void)hideTabBarView {
    self.tabbarView.hidden = YES;
}

- (void)showTabBarView {
    self.tabbarView.hidden = NO;
}

- (void)refreshTableViewDataWhenAppBecomeActive {
    //TODO:这个方法需要干掉不能这么操作
    if ([SNUtility resetLocationChannelWithChannelID:_selectedChannelId]) {
        //30分钟更新本地频道
        if ([SNUtility shouldShowEditMode]) {
            //跳转到要闻
            [self focusOnToutiao:nil];
        } else if ([self.currTableController.dragDelegate
                    isRecommendChannel]) {
            //娱乐等频道刷新数据
            if ([SNUtility isTimeToResetChannel]) {
                [SNUtility deleteChannelParamsWithChannelId:[SNUtility sharedUtility].currentChannelId];
                [self.currTableController resetTableAndRefresh];
            } else if ([SNUtility shouldResetChannel]) {
                [self.currTableController resetTableAndRefresh];
            }
        }
        return;
    }
    
    //App激活时，满足刷新条件，重置刷新，不需要获取本地缓存  wyy 5.3
    if ([self.currTableController.dragDelegate shouldReSetLoad]) {
        //30分钟重置时，无法显示加载动画，延迟1S执行，正常 wyy 5.6
        //首页
        if ([self.currTableController.selectedChannelId isEqualToString:@"1"] &&
            ![SNUtility shouldShowEditMode] &&
            [SNUtility isNetworkWWANReachable] &&
            ![SNNewsFullscreenManager newsChannelChanged]) {
            //跳转到推荐, 逻辑不做任何操作
        } else {
            if ([SNUtility shouldShowEditMode]) {
                [self focusOnToutiao:nil];
            } else {
                if ([SNNewsFullscreenManager newsChannelChanged]) {
                    //要闻改版新版本刷新逻辑
                    [self.currTableController resetTableAndRefresh];
                    return;
                } else {
                    //旧版本刷新逻辑
                    //如果是推荐频道回到要闻频道时不再跳转
                    if ([self.currTableController.selectedChannelId isEqualToString:@"13557"]) {
                        [SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom = NO;
                    }
                    //后台调起1小时刷新，会在loading页消失时，发送通知SNROLLINGNEWS_PUSHTONEXTCHANNEL，这里不应再刷新要闻频道
                    if (![self.currTableController.selectedChannelId isEqualToString:@"1"]) {
                        [self.currTableController resetTableAndRefresh];
                    }
                }
            }
        }
        return;
    }
    
    //退到后台计时刷新处理
    if ([self isHomePage]) {
        [[SNRollingNewsPublicManager sharedInstance] resetLeaveHomeTime];
    }
    SNRollingNewsTableController *tableController = nil;
    tableController = self.currTableController;

    if ([tableController.dragDelegate shouldReload]) {
        if (![[NSUserDefaults standardUserDefaults]
              boolForKey:@"firstInstall"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES
                                                    forKey:@"firstInstall"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
        
        if ([SNRollingNewsPublicManager sharedInstance].widgetOpen) {
            [SNRollingNewsPublicManager sharedInstance].widgetOpen = NO;
            return;
        }
        [tableController.dragDelegate reload];
    }
}

- (void)refreshOnTappingTabBarItem {
    isViewAppearedFromTabSelected = YES;

    SNTabBarController *tabBarController = (SNTabBarController *)self.tabBarController;
    if ([tabBarController isBubbleAnimatingAtTabBarIndex:TABBAR_INDEX_NEWS]) {
        // 有红点->跳转到要闻频道
        [self.tabBar setSelectedTabIndex:0];
    }
}

- (void)showSlideToChangeChannelGuide {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSlideToChangeChannelGuideKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)handleTipsViewDidTapNotify:(id)sender {
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *link = [(NSNotification *)sender object];
        if ([link isKindOfClass:[NSString class]]) {
            //点击tips引导登陆 需要增加登陆来源统计 by jojo
            if ([link hasPrefix:@"tt://"]) {
                [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_TIPS referId:self.selectedChannelId referAct:SNReferActSubscribe];
            }
            SNReferFrom refer = [SNUtility referFromWithProtocolV2:link];
            
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"s5=Tips&channelId=%@&refer=%d", self.selectedChannelId, refer]];
        }
    }
}

#pragma mark - channel manage delegate
- (void)channelManageViewDidSelectChannel:(SNChannelManageObject *)channelObject {
    self.tabbarView.hidden = NO;
    NSArray *subedChannels = [_channelManageView subedArray];
    NSArray *unsubedChannels = [_channelManageView unsubedArray];
    self.hasEditedChannels = _channelManageView.hasEditedChannel;
    
    double delayInSeconds = kSNChannelManageViewV2AnimationDuration + kDelayDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self selectChannelIfNotExistAppend:channelObject subedChannels:subedChannels unsubedChannels:unsubedChannels];
    });
    
    [self hideChannelManageView];
    
    if ([channelObject.ID isEqualToString:@"960415"] ||
        [channelObject.ID isEqualToString:@"13555"]) {//选择小说频道进入
        //小说频道埋点统计
        [SNNewsReport reportADotGif:@"act=fic_channel&tp=pv&from=1"];
    }
}

- (void)channelManageViewWillClose:(SNChannelManageViewV2 *)channelManageView {
    [self channelMangeViewHideAction:nil];
}

- (void)changePreviewChannelNotification:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NewsChannelItem *item = [dict objectForKey:@"newsChannelItemFromChannel"];
    [self addAndSelectExternalChannel:item];
}

- (int)addAndSelectExternalChannel:(NewsChannelItem *)selectedItem {
    if (nil == selectedItem) {
        return -1;
    }
    //兼容之前的复杂逻辑 这里直接把原来的步骤copy过来 by jojo
    [_channelDatasource.model.channels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNChannel *channel = (SNChannel *)obj;
        channel.add = NO;
    }];
    
    //判断是否存在
    int index = 0;
    for (index = 0; index < _channelDatasource.model.channels.count; index++) {
        SNChannel *channel = _channelDatasource.model.channels[index];
        if (nil != channel &&
            [channel.channelId isEqualToString:selectedItem.channelId]) {
            //5.2.2 端内二代协议频道跳转 刷新频道
            channel.link = selectedItem.link;
            if ([channel.channelName isEqualToString:selectedItem.channelName]) {
                [SNRollingNewsPublicManager sharedInstance].refreshChannel = YES;
            }
            break;
        }
    }
    
    //放到最后一个
    //有相同的，设置为当前频道即可，并且订阅
    if (index < _channelDatasource.model.channels.count) {
        SNChannel *channel = _channelDatasource.model.channels[index];
        channel.isChannelSubed = @"1";
    } else {
        //没有，新增一个
        SNChannel *newChannel = [_channelDatasource.model createChannelByItem:selectedItem];
        [_channelDatasource.model addObjectForArray:newChannel];
        
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"localChannelChangeFlag"];
    }

    //频道删除
    if ([selectedItem.channelStatusDelete isEqualToString:kChannelDeleteFromChannelPreview]) {
        SNChannel *channel = _channelDatasource.model.channels[index];
        [_channelDatasource.model removeObjectFromArray:channel];
    }
    
    [_channelDatasource.model cacheChannelsInMutiThread];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![SNRollingNewsPublicManager sharedInstance].isRequestChannelData) {
            [self p_reloadChannels];
        }
    });
    
    //5.0改为无论是否登录都请求云同步
    NSMutableString *idString = nil;
    NSArray *subedbArray = _channelDatasource.model.subedChannels;
    
    for (SNChannel *c in subedbArray) {
        if (idString) {
            [idString appendFormat:@",%@", c.channelId];
        } else {
            idString = [NSMutableString stringWithString:c.channelId];
        }
    }
    
    if (idString.length > 0) {
        [self saveChannelListWithIdString:idString];
    }
    
    return index;
}

- (void)selectChannelIfNotExistAppend:(SNChannelManageObject *)channelObject subedChannels:(NSArray *)subedArray unsubedChannels:(NSArray *)unsubedArray {
    self.selectedChannelId = channelObject.ID;
    
    // 兼容之前的复杂逻辑 这里直接把原来的步骤copy过来 by jojo
    [_channelDatasource.model.channels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNChannel *channel = (SNChannel *)obj;
        channel.add = NO;
    }];
    
    [_channelDatasource.model removeAllObjects];
    NSMutableArray *subedChannels = [NSMutableArray array];
    NSMutableArray *unsubedChannels = [NSMutableArray array];
    NSString *currentDateString = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    
    for (SNChannelManageObject *obj in subedArray) {
        SNChannel *channel = obj.orignalObj;
        channel.lastModify = currentDateString;
        channel.isChannelSubed = obj.isSubed;
        [subedChannels addObject:channel];
    }
    for (SNChannelManageObject *obj in unsubedArray) {
        SNChannel *channel = obj.orignalObj;
        channel.lastModify = currentDateString;
        channel.isChannelSubed = obj.isSubed;
        [unsubedChannels addObject:channel];
    }

    [_channelDatasource.model addObjectsFromArray:subedChannels];
    [_channelDatasource.model addObjectsFromArray:unsubedChannels];
    
    [_channelDatasource.model cacheChannelsInMutiThread];
    
    if (![SNRollingNewsPublicManager sharedInstance].isRequestChannelData) {
        [self p_reloadChannels];
    }
    
    if (self.hasEditedChannels) {
        //5.0改为无论是否登录都请求云同步
        NSMutableString *idString = nil;
        for (SNChannelManageObject *obj in subedArray) {
            SNChannel *channel = obj.orignalObj;
            if (idString) {
                [idString appendFormat:@",%@",channel.channelId];
            } else {
                idString = [NSMutableString stringWithString:channel.channelId];
            }
        }
        if (idString.length > 0) {
            [self saveChannelListWithIdString:idString];
        }
    }
}

- (void)channelMangeViewHideAction:(id)sender {
    self.hasEditedChannels = _channelManageView.hasEditedChannel;
//    BOOL needResetSelectChannelId = NO;
    if (_channelManageView.currentSelectedChannelId.length > 0 && self.hasEditedChannels) {
        self.selectedChannelId = _channelManageView.currentSelectedChannelId;
//        needResetSelectChannelId = YES;
        SNChannelManageObject *channelObject = [[SNChannelManageObject alloc] init];
        channelObject.ID = self.selectedChannelId;
        [self selectChannelIfNotExistAppend:channelObject subedChannels:[_channelManageView subedArray] unsubedChannels:[_channelManageView unsubedArray]];
    }
    
    [self hideChannelManageView];
//    NSArray *subedChannels = [_channelManageView subedArray];
//    NSArray *unsubedChannels = [_channelManageView unsubedArray];
//
//    if (needResetSelectChannelId) {
//        SNChannelManageObject *channelObject = [[SNChannelManageObject alloc] init];
//        channelObject.ID = self.selectedChannelId;
//        [self selectChannelIfNotExistAppend:channelObject subedChannels:subedChannels unsubedChannels:unsubedChannels];
//    }
//    else {
//        [self handleChannelManageDidFinishWithSubedChannels:subedChannels unsubedChannels:unsubedChannels];
//    }
}

- (void)hideChannelManageView {
    if (!_channelManageView) {
        return;
    }
    self.tabbarView.hidden = NO;
    _isExpandChannelView = NO;
    [self.tabBar channelsEditViewWillAnimate:NO];
    [UIView animateWithDuration:kSNChannelManageViewV2AnimationDuration
                     animations:^{
        _channelManageView.bottom = 0;
        [self.tabBar.animationView resetLineNormalColor:NO];
    } completion:^(BOOL finished) {
        [_channelManageView removeFromSuperview];
        [self.tabBar showChannelManageMode:NO animated:YES isFromRollingNews:YES];
        [self.tabBar removeFromSuperview];
        self.tabBar.frame = CGRectMake(0, 0, kAppScreenWidth, [SNChannelScrollTabBar channelBarHeight]);
        [self.view addSubview:self.tabBar];
        
        if (!self.hasEditedChannels) {
            [self.tabBar toScrollingAnimation:self.tabBar.selectedTabIndex haveAnimation:NO];
        }
        
        [_channelManageViewContainer removeFromSuperview];
        _channelManageViewContainer = nil;
        _channelManageView = nil;
        
        if ([[TTNavigator navigator].topViewController isKindOfClass:[self class]]) {
            [self shouldChangeStatusBarTextColorToDefault:NO];
            [self.tabBar.animationView resetLineNormalColor:NO];
        }
        
        [self.tabBar resetTopScrollBarBackColor:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.currTableController.dragDelegate transformationAutoPlayTop:(TTTableView *)self.currTableController.tableView];
        });
    }];
}

- (void)hideChannelManageViewAfterClickSohuIcon {
    //self.selectedChannelId若在此时赋值，在频道预览子界面点击Sohu Logo不能回到首页
    NSArray *subedChannels = [_channelManageView subedArray];
    NSArray *unsubedChannels = [_channelManageView unsubedArray];
    SNChannelManageObject *channelObject = [[SNChannelManageObject alloc] init];
    channelObject.ID = self.selectedChannelId;
    [self selectChannelIfNotExistAppend:channelObject subedChannels:subedChannels unsubedChannels:unsubedChannels];

    self.tabbarView.hidden = NO;
    _channelManageView.bottom = 0;
    [_channelManageView removeFromSuperview];
    [self.tabBar.animationView resetLineNormalColor:NO];
    [self.tabBar channelsEditViewWillAnimate:NO];
    [self.tabBar showChannelManageMode:NO animated:YES isFromRollingNews:YES];
    [self.tabBar removeFromSuperview];
    //重新赋值self.tabBar.frame 防止页面错乱
    self.tabBar.frame = CGRectMake(0, 0, kAppScreenWidth, [SNChannelScrollTabBar channelBarHeight]);
    [self.view addSubview:self.tabBar];
    [_channelManageViewContainer removeFromSuperview];
    _channelManageViewContainer = nil;
    _channelManageView = nil;
    
    [self shouldChangeStatusBarTextColorToDefault:NO];
    
    [self.tabBar resetTopScrollBarBackColor:NO];
}

- (void)handleChannelManageDidFinishWithSubedChannels:(NSArray *)subedArray unsubedChannels:(NSArray *)unsubedArray {
    //兼容之前的复杂逻辑 这里直接把原来的步骤copy过来 by jojo
    [_channelDatasource.model.channels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNChannel *channel = (SNChannel *)obj;
        channel.add = NO;
    }];
    
    self.selectedChannelId = self.tabBar.selectedTabItem.channelId;
    
    [_channelDatasource.model removeAllObjects];

    NSMutableArray *subedChannels = [NSMutableArray array];
    NSMutableArray *unsubedChannels = [NSMutableArray array];
    NSString *currentDateString = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];

    for (SNChannelManageObject *obj in subedArray) {
        SNChannel *channel = obj.orignalObj;
        channel.lastModify = currentDateString;
        channel.isChannelSubed = obj.isSubed;
        [subedChannels addObject:channel];
    }
    for (SNChannelManageObject *obj in unsubedArray) {
        SNChannel *channel = obj.orignalObj;
        channel.lastModify = currentDateString;
        channel.isChannelSubed = obj.isSubed;
        [unsubedChannels addObject:channel];
    }

    [_channelDatasource.model addObjectsFromArray:subedChannels];
    [_channelDatasource.model addObjectsFromArray:unsubedChannels];

    [_channelDatasource.model cacheChannelsInMutiThread];

    if (self.hasEditedChannels) {
        [self showInsertToastWithText:@"频道编辑已完成"];
    }
    
    [self p_reloadChannels];
    
    //5.0改为无论是否登录都请求云同步
    NSMutableString *idString = nil;
    for (SNChannelManageObject *obj in subedArray) {
        SNChannel *channel = obj.orignalObj;
        if (idString) {
            [idString appendFormat:@",%@", channel.channelId];
        } else {
            idString = [NSMutableString stringWithString:channel.channelId];
        }
    }
    if (idString.length > 0) {
        [self saveChannelListWithIdString:idString];
    }
}

- (void)handleStatusMessageTappedNotify:(id)sender {
    if (_channelManageView) {
        [self channelMangeViewHideAction:nil];
    }
}

- (void)showRefreshMessage:(NSNotification *)notification {
    //此通知添加时机有问题，需要后期修改
    //需要动画消失结束之后再添加这个Toast
    NSDictionary *messageDic = [notification object];
    self.tipsString = [messageDic objectForKey:@"message"];
    self.isWillShowEditNews = [[messageDic objectForKey:kRollingNewsPullStatus] boolValue];
    self.currTableController.dragDelegate.tipsMessage = self.tipsString;
        
    if (self.tipsString.length > 0) {
        [self showInsertToastWithText:self.tipsString];
    }
}

- (void)showSplash {
    if (!LoadingSwitch) {
        SNSplashViewController *splashViewController = [SNUtility getApplicationDelegate].splashViewController;
        splashViewController.isFirstShow = NO;
        if (splashViewController.isSplashDecelorating) {
            return;
        }
    }
    NSDictionary * obj = @{@"refer":@"slide"};
    [SNNotificationManager postNotificationName:kShowSplashViewNotification
                                         object:obj];
}

#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _preOffsetX = scrollView.contentOffset.x;
//    BOOL isIPHONE_6s = NO;
//    NSString *platformString = [SNUtility platformStringForSohuNews];
//    if ([platformString isEqualToString:IPHONE_6SPLUS_NAMESTRING] ||
//        [platformString isEqualToString:IPHONE_6S_NAMESTRING] ||
//        [platformString isEqualToString:IPHONE_7_NAMESTRING]  ||
//        [platformString isEqualToString:IPHONE_7PLUS_NAMESTRING]) {
//        isIPHONE_6s = YES;
//    }

    CGPoint traslation = [scrollView.panGestureRecognizer translationInView:self.view];
    //处理页面显示问题
    NSString *channelID = self.currTableController.selectedChannelId;
    if (0 == scrollView.contentOffset.x && [channelID isEqualToString:@"1"]) {
        if (traslation.x >= 0) {
            CGPoint vel = [scrollView.panGestureRecognizer velocityInView:self.view];
            if (vel.x > 100 &&
                vel.x > vel.y) {
                [self showSplash];
                [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=right_toad&_tp=pv&apid=%@&channelid=%@", @"12224", channelID]];
            }
        }
    }
}

- (void)configurePagerIndexByProgress:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    offsetX = MAX(0, offsetX);
    CGFloat width = CGRectGetWidth(scrollView.frame);
    CGFloat floorIndex = floor(offsetX / width);
    CGFloat progress = offsetX / width - floorIndex;
    NSArray *tabArray = [self getTabArrayFromSubviews];

    if (floorIndex >= tabArray.count) {
        return;
    }

    int direction = offsetX > _preOffsetX ? 0 : 1;
    
    NSInteger fromIndex = 0, toIndex = 0;
    if (direction == 0) {
        if (floorIndex >= tabArray.count - 1) {
            return;
        }
        fromIndex = floorIndex;
        toIndex = MIN(tabArray.count - 1, fromIndex + 1);
    } else {
        toIndex = floorIndex;
        fromIndex = MIN(tabArray.count - 1, toIndex + 1);
        progress = 1.0 - progress;
    }
    [self setUnderLineFrameWithfromIndex:fromIndex
                                 toIndex:toIndex progress:progress];
    
    [self configurePagerIndex:scrollView progress:progress tabArray:tabArray];
}

- (void)configurePagerIndex:(UIScrollView *)scrollView
                   progress:(CGFloat)progress
                   tabArray:(NSArray *)tabArray {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = CGRectGetWidth(scrollView.frame);
    
    //Scroll direction
    NSInteger direction = offsetX > _preOffsetX ? 0 : 1;
    
    NSInteger index = 0;
    //When scroll progress percent will change index
    CGFloat percentChangeIndex = 1.0 - progress;
    
    //Caculate cur index
    if (direction == 0) {
        index = ceil(offsetX / width + progress);
        if (index > _curIndex && progress > 0.5) {
            index--;
        }
    } else {
        index = ceil(offsetX / width - percentChangeIndex);
    }
    
    if (index < 0) {
        index = 0;
    } else if (index >= tabArray.count) {
        index = tabArray.count - 1;
    }
    
    //If index not same, change index
    if (index != _curIndex) {
        SNChannelScrollTab *scrollTab = tabArray[index];
        _curIndex = index;
        CGFloat offsetx = scrollTab.center.x - self.tabBar.scrollView.width * 0.5;
        CGFloat offsetMax = self.tabBar.scrollView.contentSize.width - self.tabBar.scrollView.width;
        //在最左和最右时，标签没必要滚动到中间位置。
        if (offsetx > offsetMax) {
            offsetx = offsetMax;
        }
        if (offsetx < 0) {
            offsetx = 0;
        }    // !!!注意上下这两行代码的顺序,如果调换,offsetx还是有可能<0的 bg liteng
        
        [UIView animateWithDuration:.25 animations:^{
            self.tabBar.scrollView.contentOffset = CGPointMake(offsetx, 0);
        }];
    }
}

- (void)setUnderLineFrameWithfromIndex:(NSInteger)fromIndex
                               toIndex:(NSInteger)toIndex
                              progress:(CGFloat)progress {
    NSArray *tabArray = [self getTabArrayFromSubviews];
    SNChannelScrollTab *labelLeft = tabArray[fromIndex];
    SNChannelScrollTab *labelRight = tabArray[toIndex];
    
    CGRect fromCellFrame = labelLeft.frame;
    CGRect toCellFrame = labelRight.frame;
    CGFloat channelSelectedImageViewWidth = 16.0;
    CGFloat progressFromEdging = (fromCellFrame.size.width - channelSelectedImageViewWidth) / 2;
    CGFloat progressToEdging = (toCellFrame.size.width - channelSelectedImageViewWidth) / 2;

    CGFloat progressY = self.tabBar.channelSelectedImageView.frame.origin.y;
    CGFloat progressX, width;
    NSInteger _cellSpacing = 0;

    if (fromCellFrame.origin.x < toCellFrame.origin.x) {
        if (progress <= 0.5) {
            progressX = fromCellFrame.origin.x + progressFromEdging;
            width = (toCellFrame.size.width - progressToEdging + progressFromEdging + _cellSpacing) * 2 * progress + fromCellFrame.size.width - 2 * progressFromEdging;
        } else {
            if (progress > 0.92) {
                progressX = (toCellFrame.origin.x - progressFromEdging - channelSelectedImageViewWidth) + (progressFromEdging + progressToEdging + channelSelectedImageViewWidth) * progress;
                width = CGRectGetMaxX(toCellFrame) - progressToEdging - progressX;
            } else {
                progressX = fromCellFrame.origin.x + progressFromEdging + (fromCellFrame.size.width - progressFromEdging + progressToEdging + _cellSpacing) * (progress - 0.5) * 2;
                width = CGRectGetMaxX(toCellFrame) - progressToEdging - progressX;
            }
        }
    } else {
        if (progress <= 0.5) {
            progressX = fromCellFrame.origin.x + progressFromEdging - (toCellFrame.size.width - progressToEdging+progressFromEdging + _cellSpacing) * 2 * progress;
            width = CGRectGetMaxX(fromCellFrame) - progressFromEdging - progressX;
        } else {
            progressX = toCellFrame.origin.x + progressToEdging;
            width = (fromCellFrame.size.width - progressFromEdging+progressToEdging + _cellSpacing) * (1 - progress) * 2 + toCellFrame.size.width - 2 * progressToEdging;
        }
    }
    self.tabBar.channelSelectedImageView.frame = CGRectMake(progressX, progressY,  width, self.tabBar.channelSelectedImageView.frame.size.height);
    self.tabBar.channelSelectedImageView.maskView.frame = self.tabBar.channelSelectedImageView.bounds;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tabBar rollingNewsScrollViewDidScroll:scrollView.contentOffset.x];
    
    if (_rollingNewsScrollView.height != _rollingNewsScrollView.contentSize.height) {
        _rollingNewsScrollView.contentSize = CGSizeMake(_rollingNewsScrollView.contentSize.width, _rollingNewsScrollView.height);
    }
    
    if (scrollView.contentOffset.x != 0 &&
        !_rollingNewsScrollView.bounces) {
        _rollingNewsScrollView.bounces = YES;
    }
    // 防止在最左侧的时候，再滑，下划线位置会偏移，颜色渐变会混乱。
    CGFloat value = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (value < 0) {
        value = 0;
    }
    
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
     // 防止滑到最右，再滑，数组越界，从而崩溃
    NSArray *tabArray = [self getTabArrayFromSubviews];
    if (tabArray.count == 0) {
        return;
    }
    if (rightIndex >= tabArray.count) {
        rightIndex = tabArray.count - 1;
    }
    
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft  = 1 - scaleRight;
    
    SNChannelScrollTab *labelLeft  = tabArray[leftIndex];
    SNChannelScrollTab *labelRight = tabArray[rightIndex];
    
    if (self.tabBar.isChannelTempStatus) {
        scaleLeft = 0;
    }
    if (leftIndex != rightIndex) {
        labelLeft.scale  = scaleLeft;
        labelRight.scale = scaleRight;
        if (scaleLeft == 1 && scaleRight < 0.0) {
            return;
        }
        // 下划线动态跟随滚动
        [self configurePagerIndexByProgress:scrollView];
    }
}

- (NSArray *)getTabArrayFromSubviews {
    return self.tabBar.tabViews;
}

- (void)scrollingToAnimation:(UIScrollView *)scrollView {
    //获得索引
    int index = (int)((scrollView.contentOffset.x + self.view.frame.size.width / 2) / self.view.frame.size.width);
    if (index < 0 || index >= _channelDatasource.model.subedChannels.count) {
        return;
    }
    //滚动标题栏到中间位置
    NSArray *tabArray = [self getTabArrayFromSubviews];
    if (tabArray.count <= index) {
        return;
    }
    SNChannelScrollTab *scrollTab = tabArray[index];
    CGFloat offsetx = scrollTab.center.x - self.tabBar.scrollView.width * 0.5;
    CGFloat offsetMax = self.tabBar.scrollView.contentSize.width - (self.tabBar.scrollView.width - 80);
    //在最左和最右时，标签没必要滚动到中间位置。
    if (offsetx > offsetMax) {
        offsetx = offsetMax;
    }
    
    if (offsetx < 0) {
        offsetx = 0;
    }
    
    [self.tabBar.scrollView setContentOffset:CGPointMake(offsetx, 0) animated:YES];
    scrollTab.selected = YES;
    // 下划线滚动
    [UIView animateWithDuration:0.5 animations:^{
        self.tabBar.channelSelectedImageView.centerX = scrollTab.centerX;
    }];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    //补丁, 修改启动跳转推荐频道的问题
    //默认推荐频道是第二个, 如果改变了需要对应修改
    if (scrollView.contentOffset.x > 0 && _isPushToIntro) {
        _isPushToIntro = NO;
        CGPoint offset = CGPointMake(scrollView.size.width,
                                     scrollView.contentOffset.y);
        if (offset.x != scrollView.contentOffset.x) {
            scrollView.contentOffset = offset;
        }
    }
    
    //如果是打开App滑动到这个界面, 需要刷新页面
    [SNRollingNewsPublicManager sharedInstance].isRequestChannelData = NO;
    
    //如果是首页
    if (_rollingNewsScrollView.frame.origin.x == 0) {
        [SNRollingNewsPublicManager sharedInstance].isNeedToBackToTop = YES;
    }
    
    //调整首页的偏移量
    [self scrollViewDidEndDecelerating:scrollView];
    
    //刷新页面
    [self.currTableController.dragDelegate autoRefresh];
    
    if ([self.leftTableController.selectedChannelId isEqualToString:@"1"]) {
        //如果首页数据未加载, 不显示搜索栏
        if (_isFirstPushToIntro) {
            _isFirstPushToIntro = NO;
            [self.leftTableController.tableView setContentOffset:CGPointMake(0, -20) animated:NO];
        }
        self.leftTableController.tableView.scrollsToTop = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0 &&
        _rollingNewsScrollView.bounces) {
        _rollingNewsScrollView.bounces = NO;
    }
    
    int selectedIndex = (int)((scrollView.contentOffset.x + self.view.frame.size.width / 2) / self.view.frame.size.width);
    if (selectedIndex < 0 ||
        selectedIndex >= _channelDatasource.model.subedChannels.count) {
        return;
    }
    
    if (self.tabBar.selectedTabIndex == selectedIndex) {
        NSString *tabChannelID = self.tabBar.selectedTabItem.channelId;
        NSString *channelID = self.currTableController.selectedChannelId;
        if ([tabChannelID isEqualToString:channelID]) {
            NSArray *tabArray = [self getTabArrayFromSubviews];
            if (tabArray.count <= selectedIndex) {
                return;
            }
            SNChannelScrollTab *scrollTab = tabArray[selectedIndex];
            scrollTab.selected = YES;
            return;
        }
    }
    
    //self.currTableController离开的频道
    NSInteger totalSec = [[SNRollingNewsPublicManager sharedInstance] rollingNewsTotalTime];
    if (totalSec != 0) {
        //上报总时长
        [SNNewsReport reportChannelStayDuration:totalSec channelID:self.currTableController.selectedChannelId];
    }
    
    //TODO:保证两个ChannelID对应上
    self.currTableController = [self loadScrollViewWithPage:selectedIndex];
    
    self.currTableController.tableView.scrollsToTop = YES;
    
    if ([self.selectedChannelId isEqualToString:@"1"]) {
        self.currTableController.year2015Bg.hidden = NO;
    } else {
        self.currTableController.year2015Bg.hidden = YES;
    }
    
    //造成频道显示错乱的问题
    //[self refreshCurrentChannel];
    
    CGRect frame = self.currTableController.view.frame;
    // 页面向右滑动
    if (self.leftTableController == self.currTableController) {
        if (selectedIndex > 0) {
            SNChannel *channel = [_channelDatasource.model.subedChannels objectAtIndex:selectedIndex - 1];
          
            channel.isPreloadChannel = YES;
            self.leftTableController = [self loadScrollViewWithPage:selectedIndex - 1];
            self.leftTableController.view.frame = CGRectMake((selectedIndex - 1) * self.view.width, 0, frame.size.width, frame.size.height);
            //[self.leftTableController.dataSource.model cancel];
            
            if ([channel isHomeChannel]) {
                [SNRollingNewsPublicManager sharedInstance].refreshClose = YES;
            }
            if (self.leftTableController.isAddToSuperView) {
                [self.leftTableController tabBar:self.tabBar channelSelected:channel];
            }
            self.leftTableController.tableView.scrollsToTop = NO;
        } else {
            //滑动到边缘时不需要初始化
            //self.leftTableController = [self loadScrollViewWithPage:(selectedIndex - 1 + kCOUNT) % kCOUNT];
        }
        self.rightTableController = [_channelTableViewControllerArray objectAtIndex:(selectedIndex + 1) % kCOUNT];
        self.rightTableController.tableView.scrollsToTop = NO;
    }
    // 页面向左滑动
    else if (self.rightTableController == self.currTableController) {
        if (selectedIndex + 1 < _channelDatasource.model.subedChannels.count) {
            SNChannel *channel = [_channelDatasource.model.subedChannels objectAtIndex:selectedIndex + 1];
      
            channel.isPreloadChannel = YES;
            self.rightTableController = [self loadScrollViewWithPage:selectedIndex + 1];
            self.rightTableController.view.frame = CGRectMake((selectedIndex + 1) * self.view.width, 0, frame.size.width, frame.size.height);

            if (self.rightTableController.isAddToSuperView) {
                [self.rightTableController tabBar:self.tabBar channelSelected:channel];
            }
            self.rightTableController.tableView.scrollsToTop = NO;
        } else {
            //滑动到边缘时不需要初始化
            //self.rightTableController = [self loadScrollViewWithPage:(selectedIndex + 1) % kCOUNT];
        }
        
        self.leftTableController = [_channelTableViewControllerArray objectAtIndex:(selectedIndex - 1 + kCOUNT) % kCOUNT];
        self.leftTableController.tableView.scrollsToTop = NO;
    }

    if (_slideToastShowing) {
        [self.view closeToast];
        _slideToastShowing = NO;
    }
    
    [self.leftTableController stopPageTimer:YES];
    [self.rightTableController stopPageTimer:YES];
    [self.currTableController stopPageTimer:NO];
    
    if ([self.selectedChannelId isEqualToString:@"960415"] ||
        [self.selectedChannelId isEqualToString:@"13555"]) {//滑动进入小说频道
        //小说频道埋点统计
        [SNNewsReport reportADotGif:@"act=fic_channel&tp=pv&from=1"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSlideToChangeChannelGuideKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSlideToChangeChannelGuideKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    SNTimelineSharedVideoPlayerView *timelineVideoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
    [timelineVideoPlayer stop];
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
    
    if (self.currTableController.isAddToSuperView) {
        [self.tabBar setSelectedTabIndex:selectedIndex];
    } else {
        //TODO:启动时，推荐频道左（右）滑动切换，再滑动到推荐频道时，推荐频道被多次请求1次；原因：滑动时isAddToSuperView = NO _selectedIndex没有被正确修改
        [self.tabBar resetSelectedTabIndex:selectedIndex];
        self.selectedChannelId = self.tabBar.selectedTabItem.channelId;
        if ([self.currTableController respondsToSelector:@selector(rollingNewsTableDidSelected)]) {
            [self.currTableController rollingNewsTableDidSelected];
        }
        [SNUtility sharedUtility].currentChannelId = self.selectedChannelId;
    }
    //为解决全屏及非常弱网情况下，要闻正在loading，频道栏消失，此时切换频道，再滑回要闻频道loading状态与频道栏同时存在的问题
    if ([self.leftTableController.selectedChannelId isEqualToString:@"1"] && [SNNewsFullscreenManager manager].isFullscreenMode) {
        if ([self.leftTableController.model isLoading] && !self.leftTableController.model.isLoadingMore) {
            [self.leftTableController.model cancel];
            self.tabBar.homeTableViewOffsetY = 0.0;
            [SNNewsFullscreenManager manager].homeTableViewOffsetY = 0.0;
        }
    }
}

// 设置当前Table的ScrollToTop属性
- (void)enableScrollToTop {
    self.currTableController.tableView.scrollsToTop = YES;
}

#pragma mark - toast
- (void)toastUninterested {
    if ([SNNewsFullscreenManager manager].fullscreenMode == YES
        && [self isHomePage]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kUnintrestedTips toUrl:nil mode:SNCenterToastModeOnlyText];
    }else{
        [self showInsertToastWithText:kUnintrestedTips];
    }
}

#pragma mark -DynamicSkin
- (void)refreshDynamicSkin {
    //刷新搜狐log 上边栏背景色
    [self.tabBar reloadScrollTabBar];
    
    //刷新频道管理颜色
    if (_channelManageView) {
        [self.tabBar.animationView resetLineNormalColor:YES];
    }
    else {
        [self.tabBar.animationView resetLineNormalColor:NO];
    }
    
    
    //拉刷新区域宣传图
    [self.currTableController addAndShow2015YearBg];
}

- (void)saveChannelsToCache:(NSNotification *)notification {
    NSArray *subedChannels = [_channelManageView subedArray];
    NSArray *unsubedChannels = [_channelManageView unsubedArray];
    SNChannelManageObject *channelObject = [[SNChannelManageObject alloc] init];
    channelObject.ID = self.selectedChannelId;
    [self selectChannelIfNotExistAppend:channelObject subedChannels:subedChannels unsubedChannels:unsubedChannels];
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *curReach = [note object];
    if ([curReach isKindOfClass:[Reachability class]]) {
        NetworkStatus status = [curReach currentReachabilityStatus];
        //如果网络切换，且为wifi，加载频道流图片（无图模式）
        if (status == ReachableViaWiFi) {
            if (self.currTableController.isH5) {
                [self.currTableController reCreateModel];
            }
            else {
                [self.currTableController.tableView reloadData];
            }
        }
    }
}

#pragma mark SNPopoverView
- (void)showPopoverMessage {
    [self.popoverView dismiss];

    CGPoint point = [tabBar getChannelPoint];
    if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
        point = CGPointMake(point.x, point.y + 24);
    }
    CGSize size = [SNDevice sharedInstance].isPlus ? CGSizeMake(1000 / 3, 182 / 3) : CGSizeMake(604 / 2, 105 / 2);
    self.popoverView = [[SNPopoverView alloc]
                        initWithTitle:@"点击频道名称，回到顶部刷新"
                        Point:point size:size
                        leftImageName:@"ico_homehand_v5.png"];
    self.popoverView.endInterval = 5.0f;
    [self.popoverView show];
}

- (void)dismissPopoverMessage {
    [self.popoverView dismiss];
}

- (void)tabBarDismissPopoverMessage:(SNChannelScrollTabBar *)tabBar {
    [self dismissPopoverMessage];
}

#pragma mark 首页搜索回调
- (void)changeLayOut:(BOOL)change {
    if (![SNRollingNewsPublicManager sharedInstance].isBeginHomeSearch) {
        return;
    }
    CGFloat offsetY = self.tabBar.frame.size.height;
    if (change == YES) {
        offsetY = -offsetY;
    }
    
    CGRect frame = self.tabBar.frame;
    frame.origin.y += offsetY;
    if (!change) {
        frame.origin.y = 0;
    }
    self.tabBar.frame = frame;
    
    if (SYSTEM_VERSION_GREATER_THAN(@"7.0")) {
        if (change == NO) {
            offsetY -= 20;
        } else {
            offsetY += 20;
        }
    }
    
    frame = _rollingNewsScrollView.frame;
    frame.origin.y += offsetY;
    frame.size.height += -offsetY;
    _rollingNewsScrollView.frame = frame;
    _rollingNewsScrollView.scrollEnabled = !change;
}

- (void)hiddenTabar:(BOOL)hidden {
    self.tabBar.hidden = hidden;
    self.tabbarView.hidden = hidden;
}

- (void)hiddenTabarView:(BOOL)hidden {
     self.tabbarView.hidden = hidden;
}

- (void)EnabledTabar:(BOOL)enable {
    [self.tabbarView setUserInteractionEnabled:enable];
}

#pragma mark 刷新首页
- (void)refreshHomePageNotification:(NSNotification *)notification {
    BOOL isNewChannel = NO;
    if (notification.userInfo != nil) {
        isNewChannel = [[notification.userInfo objectForKey:@"isNewChannel"] boolValue];
    }
    if ([_selectedChannelId isEqualToString:@"1"]) {
        [self.currTableController setNewChannel:isNewChannel];
        [self.currTableController.model cancel];
        [self autoRefresh];
    }
}

- (void)setNewsFontSize:(NSNotification *)notification {
    [SNUtility customSettingChange:YES];
    
    NSNumber *state = notification.object;
    BOOL tochange = ![state boolValue];
    if (tochange) {
        if (self.leftTableController.selectedChannelId != nil) {
            self.leftTableController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.leftTableController recalculateCellHeight];
            [self.leftTableController.tableView reloadData];
        }
        
        if (self.rightTableController.selectedChannelId != nil) {
            self.rightTableController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.rightTableController recalculateCellHeight];
            [self.rightTableController.tableView reloadData];
        }
    }
    
    self.currTableController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.currTableController recalculateCellHeight];
    [self.currTableController.tableView reloadData];
}

#pragma mark ABTest appstyle

- (void)setRollingNewsStyle:(NSNotification *)notification {
    if (self.leftTableController.selectedChannelId != nil) {
        self.leftTableController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.leftTableController.tableView reloadData];
    }
    
    if (self.rightTableController.selectedChannelId != nil) {
        self.rightTableController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.rightTableController.tableView reloadData];
    }

    self.currTableController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.currTableController.tableView reloadData];
}

#pragma mark 红包功能
- (void)couponReceiveSucces:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *state = notification.object;//Notification.object就是开关
        BOOL shown = [state boolValue];
        [SNRedPacketManager sharedInstance].joinActivity = shown;
        [self refreshDynamicSkin];
    });
}

- (void)showRedPacketTheme:(NSNotification *)notification{
    [self refreshDynamicSkin];
    [self setRedPacketShow];
}

- (void)setRedPacketShow {

    NSString *selectedChannelID = self.currTableController.selectedChannelId;
    if (([selectedChannelID isEqualToString:@"13557"] ||
        [selectedChannelID isEqualToString:@"1"]) &&
        ![[SNSpecialActivity shareInstance] isShowingChannelSpecialAd]) {
        [self.currTableController showRedPacketBtn];
    } else {
        self.currTableController.redPacketBtn.hidden = YES;
    }
    [self changeStatusBarFrameNotification];
}

- (void)changeStatusBarFrameNotification {
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat offsetY = [SNDevice sharedInstance].isPlus ? 3.0 : -4.0;
    CGFloat pointY = kAppScreenHeight - 107.0 - offsetY;
    if (statusBarRect.size.height > 20.0) {
        self.currTableController.redPacketBtn.top = pointY - 20.0;
    } else {
        self.currTableController.redPacketBtn.top = pointY;
    }
}

- (void)refreshCurrentChannel {
    //v5.8.3_0106_股票频道：客户端停留在股票频道恢复网络时不能加载  其他频道刷新不需要判断网络环境
    if (self.currTableController.isH5 && ![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        return;
    }
    
    [SNUtility sharedUtility].currentChannelId = self.currTableController.selectedChannelId;
    if ([self.currTableController.dragDelegate shouldReSetLoad]) {
        [self.currTableController resetTableAndRefresh];
    }
    
    //刷新自动播放的问题
    [self.currTableController.dragDelegate transformationAutoPlayTop:(TTTableView *)self.currTableController.tableView];
}

- (void)showInsertToastWithText:(NSString *)text {
    if (![[[TTNavigator navigator] topViewController] isKindOfClass:[SNRollingNewsViewController class]]) {
        return;
    }
    CGFloat delayTime = 0.0;
    SNRollingNewsTableController *tableController = nil;
    tableController = self.currTableController;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableController.dragDelegate initInsertToast:text channelId:self.selectedChannelId];
        [tableController.dragDelegate insertToastAnimation];
    });
}

- (void)showSpecialActivity:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *dict = notification.userInfo;
        BOOL isHomePage = NO;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([[TTNavigator navigator].topViewController isKindOfClass:[SNRollingNewsViewController class]]) {
            if (([dict objectForKey:kSpecialActivityShouldShowKey] || [[userDefaults objectForKey:kSpecialActivityCountKey] isEqualToString:@"1"]) && [[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
                isHomePage = YES;
                [userDefaults setObject:@"0" forKey:kSpecialActivityCountKey];
            }
        } else {
            //push、外链、widget打开
            [userDefaults setObject:@"1" forKey:kSpecialActivityCountKey];
        }
        [userDefaults synchronize];
        
        if (isHomePage) {
            if ([SNUtility shouldShowSpecialActivity]) {
                NSDictionary *activityInfo = [SNSpecialActivity shareInstance].activityInfo;
                SNSpecialActivityAlert *specialActivity = [[SNSpecialActivityAlert alloc] initWithAlertViewData:activityInfo];
                [specialActivity setAdType:SNFloatingADTypeHomePage];
                [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:specialActivity];
            }
        }
    });
}

#pragma mark 新手引导

#define kFontSetterGuideShow        @"kFontSetterGuideShow"

- (BOOL)isFontSetterGuideShow{
    int isFirst = [[NSUserDefaults standardUserDefaults] integerForKey:kFontSetterGuideShow];
    if (isFirst > 0) {//兼容abtest时，第二次弹出字体切换功能，可能取2
        return NO;
    }
   
    return YES;
}

- (void)setFontSetterGuideShowKey{
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kFontSetterGuideShow];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showFontSetterGuideGuide {

    //外链或push第一次打开app，进入正文页，不显示字体设置
    if ([self isFontSetterGuideShow]) {
        SNFontSettingAlert *fontAlert = [[SNFontSettingAlert alloc] initWithAlertViewData:nil];
        [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:fontAlert];
    } else {
        [self setFontSetterGuideShowKey];
    }
}

#pragma mark progress clipper
- (void)handleEnterForeground {
    if (self.isFrom3DTouch) {
        self.isFrom3DTouch = NO;
        return;
    }
    
    if ([SNUtility sharedUtility].isOpenFromUniversalLinks) {
        [SNUtility sharedUtility].isOpenFromUniversalLinks = NO;
        return;
    }
    
    if (![[[TTNavigator navigator] topViewController] isKindOfClass:[SNRollingNewsViewController class]] || [SNRollingNewsPublicManager sharedInstance].isBeginHomeSearch || _channelManageViewContainer) {
        return;
    }
    [SNUtility handleClipper];
}

- (void)open3DTouch {
    self.isFrom3DTouch = YES;
}

- (void)shouldChangeStatusBarTextColorToDefault:(BOOL)change {
    NSDictionary *dict = nil;
    if (change) {
        dict = @{@"style": @"default"};
    }
    else {
        dict = @{@"style": @"lightContent"};
    }

//    if ([SNNewsFullscreenManager manager].isFullscreenMode && [[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
//        //当前为全屏模式并且为首页频道，使用白色状态条
//        [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:YES];
//    }else {
//        [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:NO];
        if ([[SNDynamicPreferences sharedInstance] statusTextColorShouldChange] && ![[SNThemeManager sharedThemeManager] isNightTheme]) {
            [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:dict];
        }
//    }
}

- (void)hideAnimationLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self getAnimationView]) {
            [[self getAnimationView] setStatus:SNImageLoadingStatusStopped];
            [[self getAnimationView] removeFromSuperview];
            _animationImageView = nil;
        }
    });
}

- (void)refreshCurrTableController {
    //list.go变化时，需要先刷新self.currTableController
    if ([_channelDatasource.model.subedChannels count] > _currSelectedIndex) {
        if (_curIndex != _currSelectedIndex) {
            CGRect frame = _rollingNewsScrollView.frame;
            CGFloat currentX = frame.size.width * _curIndex;
            self.currTableController.view.left = currentX;
            _currSelectedIndex = _curIndex;
        }

        SNChannel *channel = [_channelDatasource.model.subedChannels objectAtIndex:_currSelectedIndex];
        
        self.currTableController.selectedChannelId = channel.channelId;
        self.currTableController.isH5 = [channel isH5Channel];
        self.currTableController.url = channel.link;
        self.currTableController.isNewChannel = [channel isNewChannel];
        
        BOOL isChangeNewsLayout = NO;
        
        //测试
        //isChangeNewsLayout = YES;
        SNNewsChannelMixSteamType type = 0;
        if ([channel.channelId isEqualToString:@"1"] &&
            channel.isMixStream != self.currTableController.isMixStream) {
            if (channel.isMixStream == NewsChannelEditAndRecom) {
                type = NewsChannelEditAndRecom;
            } else {
                type = NewsChannelEdit;
            }
            isChangeNewsLayout = YES;
        }
        self.currTableController.isMixStream = channel.isMixStream;
        self.currTableController.selectedChanneType = [channel.channelType intValue];

        if (isChangeNewsLayout) {
            //要闻改版
            if ([SNUtility isFirstInstallOrUpdateApp]) {
                //首次安装启动App同步List.go, 样式改版了需要重新创建
                [SNUtility recordIsFirstInstallOrUpdateApp:NO];
            }
            //如果是改版需要清空要闻之前的缓存数据并重置
            [self.currTableController reCreateModel];
            
            if (type == NewsChannelEdit) {
                [self.currTableController reCreateSearchBar];
            }
        } else {
            if ([SNUtility isFirstInstallOrUpdateApp]) {
                //首次安装启动App同步List.go
                [SNUtility recordIsFirstInstallOrUpdateApp:NO];
                [self.currTableController refresh];
            }
        }
        
        //对要闻频道的逻辑进行处理
        if ([SNNewsFullscreenManager newsChannelChanged]) {
            //如果是新版, 判断两边频道有没有要闻, 如果有需要reCreateModel
            if (_leftTableController && [_leftTableController.selectedChannelId
                                         isEqualToString:@"1"]) {
                if (![_leftTableController.model isKindOfClass:[SNSubRollingNewsModel class]]) {
                    _leftTableController.isMixStream = NewsChannelEditAndRecom;
                    [_leftTableController reCreateModel];
                }
            } else if (_rightTableController && [_rightTableController.selectedChannelId
                                                isEqualToString:@"1"]) {
                if (![_rightTableController.model isKindOfClass:[SNSubRollingNewsModel class]]) {
                    _rightTableController.isMixStream = NewsChannelEditAndRecom;
                    [_rightTableController reCreateModel];
                }
            }
        } else {
            //如果是旧版, 判断两边频道有没有要闻, 如果有需要reCreateModel
            if (_leftTableController && [_leftTableController.selectedChannelId
                                         isEqualToString:@"1"]) {
                if ([_leftTableController.model isKindOfClass:[SNSubRollingNewsModel class]]) {
                    _leftTableController.isMixStream = NewsChannelEdit;
                    [_leftTableController reCreateModel];
                }
            } else if (_rightTableController && [_rightTableController.selectedChannelId
                                                 isEqualToString:@"1"]) {
                if ([_rightTableController.model isKindOfClass:[SNSubRollingNewsModel class]]) {
                    _rightTableController.isMixStream = NewsChannelEdit;
                    [_rightTableController reCreateModel];
                }
            }
        }
    } else {
        //出现异常
        if ([SNUtility isFirstInstallOrUpdateApp]) {
            [SNUtility recordIsFirstInstallOrUpdateApp:NO];
        }
    }
}

- (void)finishFullscreenMode {
    if ([SNNewsFullscreenManager manager].fullscreenMode == YES) {
        [SNNewsFullscreenManager manager].fullscreenMode = NO;
        [self.tabBar changeFullScreenMode:NO];
        if ([self.currTableController.selectedChannelId isEqualToString:@"1"]) {
            [self.currTableController changeFullscreenMode:NO];
        }else if ([self.leftTableController.selectedChannelId isEqualToString:@"1"]) {
            [self.leftTableController changeFullscreenMode:NO];
        }
    }
}

@end
