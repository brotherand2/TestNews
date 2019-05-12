//
//  SNVideosViewController.m
//  sohunews
//
//  Created by chenhong on 13-8-27.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosViewController.h"
#import "SNTabBarController.h"
#import "SNVideosTableViewController.h"
#import "SNDBManager.h"
#import "SNChannelManageViewV2.h"
#import "SNChannelScrollTab.h"
#import "SNRefreshMessageView.h"
#import "SNVideosCheckService.h"
#import "WSMVVideoStatisticManager.h"
#import "WSMVConst.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNActionSheet.h"
#import "WSMVVideoHelper.h"
#import "SNAPNSHandler.h"
#import "SNVideoChannelManageView.h"
#import "Toast+UIView.h"
#import "SNVideoAdContext.h"
#import "SNRollingNewsPublicManager.h"

#import "SNNewAlertView.h"

#define kChannelBarHeight 66/2
#define kTableTopMargin kChannelBarHeight/4
#define kCOUNT 3
#define kTableViewControllerIdentifier    @"videoTableViewController"

#define kVideoChannelHasShownGuideKey        (@"kVideoChannelHasShownGuideKey")

#define kRechabilityChangedActionSheetTag                   (1000)

@interface SNVideosViewController ()<SNActionSheetDelegate> {
    NSMutableArray *_tableViewControllerArray;
    NSMutableArray *_emptyImgArray; // 空白占位图，用于切换模式时查找替换夜间模式资源
    
    // 刷新提示view
    SNRefreshMessageView *_messageView;
    
    BOOL isViewAppearedFromTabSelected;
    
    // channel management
    // fullscreen view added to window
    UIView *_channelManageView;
    SNChannelManageViewV2 *_channelPannelV2;
    
    // 记录热播管理中改变的项目
    NSMutableSet *_hotCategorySubChanged;
    
    BOOL _isEditingChannelsViewHidden;
    BOOL _is2G3GConfirmFloatViewVisiable;
    
}

@property (nonatomic, strong)SNActionSheet *networkStatusActionSheet;
@property(nonatomic, assign) BOOL hasEditedChannels;

@end

@implementation SNVideosViewController
@synthesize tabBar = _tabBar;
@synthesize channelDatasource = _channelDatasource;
@synthesize hasEditedChannels;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        NSString *videoTitle = [SNUtility getTabBarName:1];
        if (videoTitle.length == 0) {
            videoTitle = NSLocalizedString(@"videoTabbarName", nil);
        }
        [self customTabbarStyle:@"icotab_video_v5.png" activeIcon:@"icotab_videopress_v5.png"
                          title:videoTitle];
        
        if (nil == _selectedChannelId) {
            NSArray *channelList = [[SNDBManager currentDataBase] getVideoChannelList];
            if (channelList.count > 0) {
                NewsChannelItem *item = [channelList objectAtIndex:0];
                self.selectedChannelId = item.channelId;
            } else {
                self.selectedChannelId = @"1";
            }
            _isEditingChannelsViewHidden = YES;
        }
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleHotCategorySubDidChangeNotification:)
                                                     name:kVideoChannelHotCategorySubDidChangeNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self selector:@selector(handleNewVideoCntNotification:) name:kVideoTimelineCheckNewNotification object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(updateViewContentDataWhenAppBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self selector:@selector(handleRefreshMessageViewDidTapTipsToLoginNotification:) name:kSNRefreshMessageViewDidTapTipsToLoginNotification object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handlePushViewControllerNotification:)
                                                     name:kPushViewControllerNotification
                                                   object:nil];
    }
	
    return self;
}

- (SNCCPVPage)currentPage {
    return tab_video;
}

#pragma mark - tabbar icon

- (NSArray *)iconNames {
    return [NSArray arrayWithObjects:@"icotab_video_v5.png", @"icotab_videopress_v5.png", nil];
}

- (NSString *)tabItemText {
    if ([SNUtility getTabBarName:1]) {
        return [SNUtility getTabBarName:1];
    }
    return NSLocalizedString(@"videoTabbarName", nil);
}

- (void)showTabbarView {
    if (_bLockTabbarView) {
        return;
    }
    
    SNTabbarView *tabView = self.tabbarView;
    [tabView removeFromSuperview];
    tabView.top = self.view.height - tabView.height;
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

#pragma mark - 频道选择

- (void)tabBar:(SNChannelScrollTabBar*)tabBar tabSelected:(NSInteger)selectedIndex {
    if (selectedIndex < 0 || selectedIndex > _channelDatasource.subedChannels.count) {
        return;
    }
    
    self.selectedChannelId = self.tabBar.selectedTabItem.channelId;

    CGFloat destOffsetX = selectedIndex * self.view.width;
    
    [self recycleTablesByOffsetX:destOffsetX];
    
    SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:selectedIndex];
    selectedvc.tableView.scrollsToTop = YES;
    //selectedvc.view.left = destOffsetX;
    
    [self scrollToPageIndex:selectedIndex animated:NO];
    
    [selectedvc refreshIfNeeded];

    [self startPlayTimelineVideo];
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
}

- (void)tabBarBeginEdit:(SNChannelScrollTabBar *)tabBar {
    //增加点击时间间隔限制，防止频繁切换导致频道栏丢失
    NSTimeInterval editDate = [[NSDate date] timeIntervalSince1970];
    if (editDate - _channelActionDate < kSNChannelManageViewV2AnimationDuration  && (editDate - _channelActionDate) > 0) {
        return;
    }
    else {
        _channelActionDate = editDate;
    }
    
    if (_channelManageView) {
        _isEditingChannelsViewHidden = YES;
        [self actionChannelDone:nil];
        return;
    }
    
    _isEditingChannelsViewHidden = NO;
    [SNTimelineSharedVideoPlayerView fakeStop];
    
    // 增加video统计 by jojo
    [[WSMVVideoStatisticManager sharedIntance] videoFireChannelsActionStatistic];
    
    if (!_channelManageView) {
        CGFloat yOffset = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 0 : 20;
        _channelManageView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      yOffset,
                                                                      TTApplicationFrame().size.width,
                                                                      TTApplicationFrame().size.height)];
        [[SNUtility getApplicationDelegate].window addSubview:_channelManageView];
    }
    
    [self.tabBar removeFromSuperview];
    [_channelManageView addSubview:self.tabBar];
    
    if (!_channelPannelV2) {
        _channelPannelV2 = [[SNChannelManageViewV2 alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _channelManageView.height)];
        _channelPannelV2.isNotNewsTab = YES;
        _channelPannelV2.bottom = 0;
        _channelPannelV2.delegate = self;
        _channelPannelV2.shouldHideLocalsChannel = YES;
        [_channelManageView insertSubview:_channelPannelV2 belowSubview:_tabBar];
    }
    
    _channelPannelV2.currentSelectedChannelId = self.selectedChannelId;
    
    // for channels data array
    NSArray *channels = _channelDatasource.videoChannels;
    NSMutableArray *subed = [NSMutableArray array];
    NSMutableArray *unsubed = [NSMutableArray array];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL showRedDotForNewInstallApp = [userDefaults boolForKey:kShowRedDotForNewInstallApp];
    for (SNVideoChannelObject *ch in channels) {
        if (!showRedDotForNewInstallApp) {//新装用户则所有频道不显示红点
            ch.isNew = NO;
        }
        
        SNChannelManageObject *obj = [[SNChannelManageObject alloc] initWithObj:ch type:SNChannelManageObjTypeVideo];
        obj.addNew = ch.isNew;
        
        // 显示一次之后 去掉new标志
        ch.isNew = NO;
        
        // 热播频道 需要特殊处理
        if ([ch.channelId isEqualToString:kVideoTimelineMainChannelId]) {
            obj.channelViewClassString = NSStringFromClass([SNVideoChannelManageView class]);
        }
        
        if ([obj.isSubed isEqualToString:@"1"]) {
            [subed addObject:obj];
        }
        else {
            [unsubed addObject:obj];
        }
    }
    [userDefaults setBool:YES forKey:kShowRedDotForNewInstallApp];
    [userDefaults synchronize];
    
    [_channelPannelV2 setSubedArray:subed andUnsubedArray:unsubed isRollingNewsTab:NO];
    
    // start anmation
    [UIView animateWithDuration:kSNChannelManageViewV2AnimationDuration animations:^{
        _channelPannelV2.top = 0;
    } completion:^(BOOL finished) {
        [_tabBar showChannelManageMode:YES animated:YES isFromRollingNews:NO];
        
        id shownMark = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoChannelHasShownGuideKey];
        if (!shownMark) {
//            [[SNToast shareInstance] showToastWithTitle:@"单击可以管理热播频道内容"
//                                                  toUrl:nil
//                                                   mode:SNToastUIModeFeedBackCommon];
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kVideoChannelHasShownGuideKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)tabBarChannelReloaded {
    [self showBubbleAtChannelBar];
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width*_channelDatasource.subedChannels.count, _scrollView.frame.size.height)];
}

- (void)reloadAllTables {
    NSString *oldSelectedChannelID = self.tabBar.selectedTabItem.channelId;
    NSInteger selectedIndex = 0;//self.tabBar.selectedTabIndex;
    
    NSArray *tabItems = self.tabBar.tabItems;
    for (int i=0; i< tabItems.count; i++) {
        SNChannelScrollTabItem *channelItem = [tabItems objectAtIndex:i];
        if ([channelItem.channelId isEqualToString:oldSelectedChannelID]) {
            selectedIndex = i;
            break;
        }
    }
    
    if (NSIntegerMax == selectedIndex) {
        selectedIndex = 0;
    }
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * _channelDatasource.subedChannels.count, _scrollView.frame.size.height)];
    
    [self recycleAllTables];
    
    for (UIImageView *imgView in _emptyImgArray) {
        [imgView removeFromSuperview];
    }
     //(_emptyImgArray);
    
    _emptyImgArray = [[NSMutableArray alloc] initWithCapacity:30];
    UIImage *defaultImage = [UIImage imageNamed:@"info_sohu_news.png"];
    for (int i=0; i<_channelDatasource.subedChannels.count; ++i) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:defaultImage];
        imgView.center = CGPointMake(i*_scrollView.frame.size.width + _scrollView.frame.size.width/2, _scrollView.center.y);
        [_scrollView addSubview:imgView];
        [_emptyImgArray addObject:imgView];
    }
    
    //更新channel当前选择项
    [self.tabBar forceSetSelectedTabIndex:selectedIndex];
    
    [self loadTableViewWithPage:selectedIndex];
    
    if (selectedIndex > 0) {
        [self loadTableViewWithPage:selectedIndex - 1];
    }
    
    if (selectedIndex < _channelDatasource.subedChannels.count-1) {
        [self loadTableViewWithPage:selectedIndex+1];
    }
}

- (void)actionChannelDone:(id)sender {
    // hide all toast
    [SNNotificationCenter hideMessage];
    [self.tabBar finishChannelManageMode];
    
    NSArray *subedChannels = [_channelPannelV2 subedArray];
    NSArray *unsubedChannels = [_channelPannelV2 unsubedArray];
    self.hasEditedChannels = _channelPannelV2.hasEditedChannel;
    
    [UIView animateWithDuration:kSNChannelManageViewV2AnimationDuration animations:^{
        _channelPannelV2.bottom = 0;
    } completion:^(BOOL finished) {
        
        [_channelPannelV2 removeFromSuperview];
         //(_channelPannelV2);
        
        [_tabBar showChannelManageMode:NO animated:YES isFromRollingNews:NO];
        
        [_tabBar removeFromSuperview];
        [self.view addSubview:_tabBar];

//        [_channelManageView removeFromSuperview];
//         //(_channelManageView);
    }];
    
    // 选中当前的频道
    double delayInSeconds = kSNChannelManageViewV2AnimationDuration + 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.hasEditedChannels) {
            [self syncVideoChannelsWithSubedChannels:subedChannels unsubedChannels:unsubedChannels];
        }
        else {
            [self setCurrentSelectChannelId:self.selectedChannelId];
        }
        /**
         * 从上面移到这里的目的：
         * 为了Fix bug: 
         * 前提：服务器开启了视频Tab Timeline的自动播放
         * Bug: Ticket #29794
         * [搜狐新闻_IOS]_3.8_视频播放：关闭频道浮层点击播放页面第二个视频时又自动播放第一个视频[搜狐新闻_IOS]_3.8_视频播放：关闭频道浮层点击播放页面第二个视频时又自动播放第一个视频
         * By Handy
         */
        [_channelManageView removeFromSuperview];
         //(_channelManageView);
    });
}

- (void)actionVideoDownloadManage:(id)sender {
    [SNTimelineSharedVideoPlayerView fakeStop];
    [SNTimelineSharedVideoPlayerView forceStop];
    
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://videoDownloadViewController"] applyAnimated:YES] applyQuery:nil];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

#pragma mark - channel manage delegate

- (void)hideChannelManageView {
    if (_channelPannelV2) {
        [UIView animateWithDuration:kSNChannelManageViewV2AnimationDuration animations:^{
            _channelPannelV2.bottom = 0;
            _isEditingChannelsViewHidden = YES;
        } completion:^(BOOL finished) {
            [_channelPannelV2 removeFromSuperview];
             //(_channelPannelV2);
            
            [self.tabBar showChannelManageMode:NO animated:YES isFromRollingNews:NO];
            
            [self.tabBar removeFromSuperview];
            [self.view addSubview:self.tabBar];
            [_channelManageView removeFromSuperview];
             //(_channelManageView);
        }];
    }
}

- (void)channelManageViewDidSelectChannel:(SNChannelManageObject *)channelObject {
    NSArray *subedChannels = [_channelPannelV2 subedArray];
    NSArray *unsubedChannels = [_channelPannelV2 unsubedArray];
    self.hasEditedChannels = _channelPannelV2.hasEditedChannel;
    
    double delayInSeconds = kSNChannelManageViewV2AnimationDuration + 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.selectedChannelId = channelObject.ID;
        if (self.hasEditedChannels) {
            [self syncVideoChannelsWithSubedChannels:subedChannels unsubedChannels:unsubedChannels];
        }
        else {
            [self setCurrentSelectChannelId:self.selectedChannelId];
        }
    });
    
    [self hideChannelManageView];
}

- (void)channelManageViewWillClose:(SNChannelManageViewV2 *)channelManageView {
    _isEditingChannelsViewHidden = YES;
    [self actionChannelDone:nil];
}

- (void)syncVideoChannelsWithSubedChannels:(NSArray *)subedChannels unsubedChannels:(NSArray *)unsubedChannels {
    NSMutableArray *allChannels = [NSMutableArray array];
    for (SNChannelManageObject *chObj in subedChannels) {
        if ([chObj.orignalObj isKindOfClass:[SNVideoChannelObject class]]) {
            SNVideoChannelObject *vObj = (SNVideoChannelObject *)chObj.orignalObj;
            vObj.up = @"1";
            [allChannels addObject:vObj];
        }
    }
    for (SNChannelManageObject *chObj in unsubedChannels) {
        if ([chObj.orignalObj isKindOfClass:[SNVideoChannelObject class]]) {
            SNVideoChannelObject *vObj = (SNVideoChannelObject *)chObj.orignalObj;
            vObj.up = @"0";
            [allChannels addObject:vObj];
        }
    }
    
    [_channelDatasource sychAllVideoChannels:allChannels];
    
    // reload 会重置chennel id 所以这里给记录一下
    NSString *lastSelectedChannelId = [self.selectedChannelId copy];
    [self reloadAllTables];
    self.selectedChannelId = lastSelectedChannelId;
    
    int index = 0;
    for (int i = 0; i < subedChannels.count; ++i) {
        SNChannelManageObject *ch = subedChannels[i];
        if ([ch.ID isEqualToString:self.selectedChannelId]) {
            index = i;
            break;
        }
    }

    [self.tabBar reloadChannels:index channelId:self.selectedChannelId];
}

- (void)onVideoChannelDidSelectManage:(id)sender {
    [self actionChannelDone:nil];
    
    TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://videoChannelManage"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:action];
    
    // video 统计 by jojo
    [[WSMVVideoStatisticManager sharedIntance] videoFireHotColumnsActionStatistic];
}

- (void)setCurrentSelectChannelId:(NSString *)channelId {
    NSInteger index = 0;
    for (SNChannelScrollTab *tab in _tabBar.tabViews) {
        if ([tab.tabItem.channelId isEqualToString:channelId]) {
            index = [_tabBar.tabItems indexOfObject:tab.tabItem];
            break;
        }
        index++;
    }
    if (index >= _tabBar.tabItems.count) {
        index = 0;
        if (_tabBar.tabViews.count > 0) {
            SNChannelScrollTab *tab = [_tabBar.tabViews objectAtIndex:0];
            channelId = tab.tabItem.channelId;
        }
    }
    [self.tabBar reloadChannels:index channelId:channelId];
}

#pragma mark - actions
- (void)handleStatusMessageTappedNotify:(id)sender {
    if (_channelPannelV2) {
        [self actionChannelDone:nil];
    }
}

#pragma mark - view cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateThemeIfChanged];
    
    if (_hotCategorySubChanged != nil) {
        [self setCurrentSelectChannelId:kVideoTimelineMainChannelId];
    }
    
    if (isViewAppearedFromTabSelected ||
        ([self.selectedChannelId isEqualToString:kVideoTimelineMainChannelId] && _hotCategorySubChanged.count > 0)) {
        SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
        if ([selectedvc shouldReload]) {
            [selectedvc scrollToTop];
        }
    }
    
    [SNNotificationManager postNotificationName:kVideosViewControllerWillAppearNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBar.observeScrollEnable = YES;
    
    if (isViewAppearedFromTabSelected) {
        isViewAppearedFromTabSelected = NO;
        SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
        [selectedvc refreshIfNeeded];
    }
    
    // 修改热播订阅后，返回热播频道需要自动刷新
    else if ([self.selectedChannelId isEqualToString:kVideoTimelineMainChannelId]) {
        if (_hotCategorySubChanged.count > 0) {
            SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
            [selectedvc refreshIfNeeded];
        }
    }
    
    [_hotCategorySubChanged removeAllObjects];
     //(_hotCategorySubChanged);
    
    [self startPlayTimelineVideo];
    
    [[SNAPNSHandler sharedInstance] handleReciveNotifyWithFromBack:NO];
    
    if (_channelDatasource.hasNew) {
        [self performSelector:@selector(showNewChannelMessage) withObject:nil afterDelay:3];
        _channelDatasource.hasNew = NO;
    }
    
    [self updateVideoChannelIfNotYet];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBar.observeScrollEnable = NO;
    if (_channelManageView) {
        [self.tabBar removeFromSuperview];
        [self.view addSubview:self.tabBar];
        [self.tabBar showChannelManageMode:NO];
        
        
        [_channelPannelV2 removeFromSuperview];
         //(_channelPannelV2);
        [_channelManageView removeFromSuperview];
         //(_channelManageView);
    }
    [SNNotificationCenter hideMessage];
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)updateTheme:(NSNotification *)notifiction {
    if (![self isViewAppearing]) {
        return;
    }
    self.currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    
    [self customTheme];
}

- (void)customTheme {
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    [self.tabBar updateTheme];
    
    for (SNVideosTableViewController *vc in _tableViewControllerArray) {
        [vc updateTheme];
    }
    
    // page的占位图
    UIImage *defaultImage = [UIImage imageNamed:@"info_sohu_news.png"];
    for (UIImageView *imgView in _emptyImgArray) {
        imgView.image = defaultImage;
    }
}

- (void)loadView {
    [super loadView];
    self.view.clipsToBounds = YES;
    
    [SNNotificationManager addObserver:self selector:@selector(reloadAllTables) name:kRefreshChannelTabNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(showRefreshMessage:) name:kVideoTimelineRefreshMsgNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(showAddHotVideoMsg:) name:kSNAddHotVideoNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(onVideoChannelDidSelectManage:) name:kSNVideoChannelManageViewDidSelectManageNotify object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(handleStatusMessageTappedNotify:) name:kNotifyDidReceive object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleStatusMessageTappedNotify:) name:kStatusBarMessageDidTappedNotification object:nil];
    
    [self createScrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTheme];
    
    if (_tabbarSnapView && _tabbarSnapView.superview == nil) {
        [self.view addSubview:_tabbarSnapView];
    }
}

- (void)viewDidUnload {
    [SNNotificationManager removeObserver:self name:kRefreshChannelTabNotification object:nil];
    [SNNotificationManager removeObserver:self name:kVideoTimelineRefreshMsgNotification object:nil];
    [SNNotificationManager removeObserver:self name:kSNAddHotVideoNotification object:nil];
    [SNNotificationManager removeObserver:self name:kSNVideoChannelManageViewDidSelectManageNotify object:nil];
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
    [SNNotificationManager removeObserver:self name:kStatusBarMessageDidTappedNotification object:nil];
    self.selectedChannelId = self.tabBar.selectedTabItem.channelId;
    
     //(_emptyImgArray);
     //(_tableViewControllerArray);
    
    if (_scrollView && self.tabBar) {
        [_scrollView removeObserver:self.tabBar forKeyPath:@"contentOffset"];
    }
    
     //(_messageView);
    
     //(_tabBar);
     //(_scrollView);
    _channelDatasource.tabBar = nil;
    if (_channelDatasource) {
        [_channelDatasource removeObserver:self forKeyPath:@"hasNew" context:NULL];
    }
     //(_channelDatasource);
    
     //(_channelPannelV2);
    if (_channelManageView) {
        [_channelManageView removeFromSuperview];
         //(_channelManageView);
    }
    
    [super viewDidUnload];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    self.networkStatusActionSheet.delegate = nil;
    
    
     //(_emptyImgArray);
     //(_tableViewControllerArray);
    
    if (_scrollView && self.tabBar) {
        [_scrollView removeObserver:self.tabBar forKeyPath:@"contentOffset"];
    }
    
     //(_messageView);
    
     //(_tabBar);
     //(_scrollView);
    _channelDatasource.tabBar = nil;
    
    if (_channelDatasource) {
        [self.channelDatasource removeObserver:self forKeyPath:@"hasNew" context:NULL];
    }
     //(_channelDatasource);
    
     //(_channelPannelV2);
     //(_channelManageView);
    
     //(_hotCategorySubChanged);
    
//     //(confirmView);
    
}

- (void)createScrollView {
    
     //(_scrollView);
     //(_tabBar);
     //(_tableViewControllerArray);
     //(_messageView);
    
    // tabbar
    if (_channelDatasource) {
        [self.channelDatasource removeObserver:self forKeyPath:@"hasNew" context:NULL];
    }
    self.channelDatasource = [[SNVideoChannelTabbarDataSource alloc] init];
    [self.channelDatasource addObserver:self forKeyPath:@"hasNew" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.tabBar = [[SNChannelScrollTabBar alloc] initWithChannelId:_selectedChannelId];
    _tabBar.scrollTabType = SNChannelScrollTabTypeVideo;
    _tabBar.delegate = self;
    _channelDatasource.tabBar = _tabBar;
    
    // 缓存视频的入口
//    #if kSupportVideoDownload
//    UIButton *moreButton = [[UIButton alloc] init];
//    [moreButton addTarget:self action:@selector(actionVideoDownloadManage:) forControlEvents:UIControlEventTouchUpInside];
//    [moreButton setImage:[UIImage themeImageNamed:@"channel_more.png"] forState:UIControlStateNormal];
//    moreButton.adjustsImageWhenDisabled = NO;
//    moreButton.adjustsImageWhenHighlighted = NO;
//    _tabBar.moreButton = moreButton;
//     //(moreButton);
//    #endif
    
    [_channelDatasource loadFromCache];
    
    CGRect frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    
    // UIScrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    [_scrollView setContentSize:CGSizeMake(frame.size.width*_channelDatasource.subedChannels.count, frame.size.height)];
    _scrollView.pagingEnabled = YES;
    
    _tabBar.frame = CGRectMake(0, 0, _tabBar.width, _tabBar.height);
    [self.view addSubview:_tabBar];
    
    [_scrollView addObserver:self.tabBar forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    
    // page的占位图
    _emptyImgArray = [[NSMutableArray alloc] initWithCapacity:30];
    UIImage *defaultImage = [UIImage imageNamed:@"info_sohu_news.png"];
    for (int i=0; i<_channelDatasource.subedChannels.count; ++i) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:defaultImage];
        imgView.center = CGPointMake(i*frame.size.width + frame.size.width/2, _scrollView.center.y);
        [_scrollView addSubview:imgView];
        [_emptyImgArray addObject:imgView];
    }
    
    NSInteger selected = self.tabBar.selectedTabIndex;
    if (NSIntegerMax == selected) {
        selected = 0;
    }
    
    SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:selected];
    if (selected > 0) {
        [self loadTableViewWithPage:selected-1];
    }
    if (selected + 1 < _channelDatasource.subedChannels.count) {
        [self loadTableViewWithPage:selected+1];
    }
    
    if (!_messageView) {
        _messageView = [[SNRefreshMessageView alloc] init];
        [self.view insertSubview:_messageView belowSubview:self.tabBar];
    }
    
    for (SNVideosTableViewController *vc in _tableViewControllerArray) {
        vc.tableView.scrollsToTop = (selectedvc == vc);
    }
    
    // 刷新频道列表
    [_channelDatasource loadFromServer];
}

// 回收可复用的TableViewController
- (void)recycleTablesByOffsetX:(CGFloat)offsetX {
    for (SNVideosTableViewController *vc in _tableViewControllerArray) {
        vc.delegate = nil;
        if (abs(vc.view.left - offsetX) >= 2 *vc.view.width) {
            if (!vc.canBeReusable) {
                vc.canBeReusable = YES;
                SNDebugLog(@"channel %@ recycled", vc.channelId);
            }
        }
        vc.tableView.scrollsToTop = NO;
    }
}

- (void)recycleAllTables {
    for (SNVideosTableViewController *vc in _tableViewControllerArray) {
        vc.delegate = nil;
        vc.canBeReusable = YES;
        [vc setChannelId:nil];
        if ([vc isViewLoaded] && nil != vc.view.superview) {
            [vc.view removeFromSuperview];
        }
    }
}

- (SNVideosTableViewController *)dequeReusableTableViewControllerWithIdentifier:(NSString *)identifier {
    SNVideosTableViewController *vc = nil;
    
    for (vc in _tableViewControllerArray) {
        if (vc.canBeReusable && [vc.reuseIdentifier isEqualToString:identifier]) {
            return vc;
        }
    }
    
    vc = [[SNVideosTableViewController alloc] initWithIdentifier:identifier];
    vc.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 0, 0);

    if (!_tableViewControllerArray) {
        _tableViewControllerArray = [[NSMutableArray alloc] initWithCapacity:kCOUNT];        
    }

    [_tableViewControllerArray addObject:vc];
    
    if (_tableViewControllerArray.count > 3) {
        SNDebugLog(@"logic possiblly wrong!");
    }
    return vc;
}

- (SNVideosTableViewController *)loadTableViewWithPage:(NSInteger)page {
    //SNDebugLog(@"*********** loadScrollViewWithPage: %d", page);
    if (page < 0) return nil;
    if (page >= _channelDatasource.subedChannels.count) return nil;
    
    SNVideoChannelObject *channel = [_channelDatasource.subedChannels objectAtIndex:page];
    
    SNVideosTableViewController *vc = nil;
    SNVideosTableViewController *oldvc = nil;
    
    CGRect frame = _scrollView.frame;
    CGFloat destX = frame.size.width * page;
    
    for (SNVideosTableViewController *tbl in _tableViewControllerArray) {
        if (oldvc == nil && (int)(tbl.view.frame.origin.x) == (int)destX) {
            oldvc = tbl;
        }
        
        if (vc == nil && [tbl.channelId isEqualToString:channel.channelId]) {
            vc = tbl;
        }
        
        if (oldvc && vc) {
            break;
        }
    }
    
    if (vc == nil) {
        vc = [self dequeReusableTableViewControllerWithIdentifier:kTableViewControllerIdentifier];
        [vc setChannelId:channel.channelId];
        SNDebugLog(@"reloadData: %@ %@", channel.channelId, channel.title);
    } else {
        vc.canBeReusable = NO;
    }

    // 将原来这个位置的table的移到不可见处，避免与复用的vc位置重合
    if (oldvc && oldvc != vc) {
        oldvc.view.top = frame.size.height * 10;
    }
    
    // 设置当前vc的位置
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    vc.view.frame = frame;
    
    if (nil == vc.view.superview) {
        [_scrollView addSubview:vc.view];
    }
    
    vc.delegate = self;
    return vc;
}

- (void)scrollToPageIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (selectedIndex < 0 || selectedIndex >= _channelDatasource.subedChannels.count) {
        return;
    }
    
    if (selectedIndex * self.view.frame.size.width != _scrollView.contentOffset.x) {
        [_scrollView setContentOffset:CGPointMake(selectedIndex * self.view.frame.size.width, 0) animated:animated];
        if (!animated) {
            [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
        }
    }
}

#pragma mark - scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
    
    int selectedIndex = (int)((scrollView.contentOffset.x + self.view.frame.size.width/2) /self.view.frame.size.width);
    if (selectedIndex < 0 || selectedIndex > _channelDatasource.subedChannels.count) {
        return;
    }
    
    if (self.tabBar.selectedTabIndex == selectedIndex) {
        return;
    }
    
    // 更新channel当前选择项
    [self.tabBar setSelectedTabIndex:selectedIndex];
    
    if (selectedIndex > 0) {
        [self loadTableViewWithPage:selectedIndex - 1];
    }
    
    if (selectedIndex < _channelDatasource.subedChannels.count-1) {
        [self loadTableViewWithPage:selectedIndex+1];
    }
}

// 设置当前table的scrollToTop属性
- (void)enableScrollToTop
{
    SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
    selectedvc.tableView.scrollsToTop = YES;
}

- (void)showRefreshMessage:(NSNotification *) notification {
    NSDictionary *messageDic = [notification object];
    NSString *messageString = [messageDic stringValueForKey:@"message" defaultValue:nil];
    NSString *channelId = [messageDic stringValueForKey:@"channelId" defaultValue:nil];
    
    if (messageString && !_messageView.showTips) {
        //判断更新提示是否为当前频道ID
        if (channelId && self.selectedChannelId) {
            if ([channelId isEqualToString:self.selectedChannelId]) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:messageString toUrl:nil mode:SNCenterToastModeOnlyText];
            }
        }
    }
}

- (void)showAddHotVideoMsg:(NSNotification *) notification {
}

- (void)handlePushViewControllerNotification:(NSNotification *)notification {
    [[SNTimelineSharedVideoPlayerView sharedInstance] stop];
}

- (void)handleRefreshMessageViewDidTapTipsToLoginNotification:(NSNotification *)notification {
    //loading / playing
    if ([[SNTimelineSharedVideoPlayerView sharedInstance] isLoading]) {
        [[SNTimelineSharedVideoPlayerView sharedInstance] forceStop];
    }
    else if ([[SNTimelineSharedVideoPlayerView sharedInstance] isPlaying]) {
        [[SNTimelineSharedVideoPlayerView sharedInstance] pause];
    }
}

- (void)handleNewVideoCntNotification:(NSNotification *) notification {
    NSString *num = [notification.userInfo objectForKey:kVideoTimelineCntForNew];
    SNTabBarController* tabBarController = [[SNUtility getApplicationDelegate] appTabbarController];

    //视频更新数大于0且当前选中的tabitem不是视频时才显示视频tabitem上的红点
    if (num.intValue > 0 && tabBarController.selectedIndex != TABBAR_INDEX_VIDEO) {
        [[NSUserDefaults standardUserDefaults] setValue:num forKey:kVideoTimelineCntForNew];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tabBarController flashTabBarItem:[num intValue] > 0 atIndex:TABBAR_INDEX_VIDEO];
        [self showBubbleAtChannelBar];
        SNDebugLog(@"\n===== VideoTimeline: Showing bubble at video tab =====\n");
    }
    else {
        if (num.intValue <= 0) {
            SNDebugLog(@"\n===== VideoTimeline: No new video update =====\n");
        }
        else {
            if (tabBarController.selectedIndex == TABBAR_INDEX_VIDEO) {
                SNDebugLog(@"\n===== VideoTimeline: New videos need to update, but in video tab =====\n");
            }
        }
    }
}

// 热播管理修改通知
- (void)handleHotCategorySubDidChangeNotification:(NSNotification *)notification {
    NSString *categoryId = [notification.userInfo stringValueForKey:kVideoChannelHotCategoryIdKey
                                                       defaultValue:nil];
    if (!_hotCategorySubChanged) {
        _hotCategorySubChanged = [[NSMutableSet alloc] init];
    }
    if ([_hotCategorySubChanged containsObject:categoryId]) {
        [_hotCategorySubChanged removeObject:categoryId];
    } else {
        [_hotCategorySubChanged addObject:categoryId];
    }

    SNDebugLog(@"hot sub changed: %d", _hotCategorySubChanged.count);

    BOOL bChanged = (_hotCategorySubChanged.count > 0);
    [SNVideosModel setNeedRefresh:bChanged
                        channelId:kVideoTimelineMainChannelId];
}

// 热播频道显示红点提示
- (void)showBubbleAtChannelBar {
    // 需求暂时去掉
    return;
    
    int num = [[[NSUserDefaults standardUserDefaults] objectForKey:kVideoTimelineCntForNew] intValue];
    
    int mainChannelIndex = -1;
    @synchronized(_channelDatasource.videoChannels) {
        for (int i=0; i<_channelDatasource.videoChannels.count; ++i) {
            SNVideoChannelObject *channelObj = [_channelDatasource.videoChannels objectAtIndex:i];
            if ([channelObj.channelId isEqualToString:kVideoTimelineMainChannelId]) {
                mainChannelIndex = i;
                break;
            }
        }
    }

    if (mainChannelIndex >= 0) {
        [self.tabBar showTabBubble:num atIndex:mainChannelIndex];
    }
}

//点视频tabitem时触发
- (void)refreshOnTappingTabBarItem {
    isViewAppearedFromTabSelected = YES;
    
    [self refreshHotChannelWhenHaveNew];

    [[SNVideosCheckService sharedInstance] checkIfNeeded];
}

//点视频Tab，有红点则切到热播频道并刷新
- (void)refreshHotChannelWhenHaveNew {
    SNTabBarController* tabBarController = [[SNUtility getApplicationDelegate] appTabbarController];
    //切到视频Tab时，视频Tab上有红点
    if ([tabBarController isBubbleAnimatingAtTabBarIndex:TABBAR_INDEX_VIDEO]) {
        
        //去掉红点效果
        [tabBarController flashTabBarItem:0 atIndex:TABBAR_INDEX_VIDEO];
        
        //如果当前不是热播频道则切到热播频道
        if (![self.selectedChannelId isEqualToString:kVideoTimelineMainChannelId]) {
            [self setCurrentSelectChannelId:kVideoTimelineMainChannelId];
        }
        
        //刷新热播频道数据
        SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
        [selectedvc scrollToTop];
        
        // 重置更新flag
        [SNVideosModel setNeedRefresh:YES channelId:kVideoTimelineMainChannelId];
        [selectedvc refreshIfNeeded];
    }
}

//点非视频tabitem时触发
- (void)tabBarControllerWillChanged {
    [SNTimelineSharedVideoPlayerView fakeStop];
    [SNTimelineSharedVideoPlayerView forceStop];
    
    [[SNVideosCheckService sharedInstance] stop];
}

// AppResignActive
- (void)viewControllerWillResignActive {
    [[SNVideosCheckService sharedInstance] stop];
}

// AppBecomeActive
- (void)refreshTableViewDataWhenAppBecomeActive {
    [[SNVideosCheckService sharedInstance] checkIfNeeded];
    
    //Fixed: 视频在播放的时候进后台，再回到前台继续播放，但是由于refreshIfNeeded会被暂停。
    SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
    if (![[SNTimelineSharedVideoPlayerView sharedInstance] isFullScreen]) {
        BOOL needRefresh = [selectedvc doesNeedRefresh];
        if (needRefresh) {
            [selectedvc performSelector:@selector(refreshIfNeeded) withObject:nil afterDelay:1];
        }
    }
}

#pragma mark - About - Timeline video play
- (void)startPlayTimelineVideo {
    [self updateCurrentChannelID];
    
    BOOL isSelfVisible = self.isViewLoaded && self.view.window;
    UIViewController *topSubVC = [self.flipboardNavigationController topSubcontroller];
    BOOL isSelfRootVC = topSubVC == self;
    SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
    if (_isEditingChannelsViewHidden && isSelfVisible && isSelfRootVC && ![selectedvc isLoading]) {
        NSLogFatal(@"###### Start play timeline video.");
        [selectedvc startPlayTimelineVideo];
    }
    else if ([selectedvc isLoading]) {
        NSLogFatal(@"###### Model is loading, so dont play timeline video.");
    }
}

- (void)updateCurrentChannelID {
    SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
    NSString *channelID = selectedvc.channelId;
    [[SNVideoAdContext sharedInstance] setCurrentChannelID:channelID];
}

- (void)startPlayTimelineVideoIn2G3G {
    BOOL isSelfVisible = self.isViewLoaded && self.view.window;
    
    UIViewController *topSubVC = [self.flipboardNavigationController topSubcontroller];
    BOOL isSelfRootVC = topSubVC == self;
    
    SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
    
    if (isSelfVisible && isSelfRootVC && ![selectedvc isLoading]) {
        NSLogFatal(@"###### Start play timeline video.");
        [selectedvc startPlayTimelineVideoIn2G3G];
    }
    else if ([selectedvc isLoading]) {
        NSLogFatal(@"###### Model is loading, so dont play timeline video.");
    }
}

#pragma mark - SNVideosTableViewControllerDelegate
- (void)videosDidFinishLoadFromTableViewController:(SNVideosTableViewController *)tableViewController isMore:(BOOL)isMore {
    NSLogFatal(@"###### Model finished to load, play timeline.");
    
    BOOL isSelfVisible = self.isViewLoaded && self.view.window;
    UIViewController *topSubVC = [self.flipboardNavigationController topSubcontroller];
    BOOL isSelfRootVC = topSubVC == self;
    if (isSelfVisible && isSelfRootVC) {
        
        //频道整体刷新的时候，重置当前频道Toast提示记录
        SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
        NSString *channelID = selectedvc.channelId;
        if (!isMore && channelID.length > 0) {
            [[WSMVVideoHelper sharedInstance].hadEverAlert2G3GOfChannels setObject:@(NO) forKey:channelID];
        }

        [self startPlayTimelineVideo];
    }
    else {
        SNDebugLog(@"Dont play video, because isSelfVisible:%d, isSelfRootVC:%d", isSelfVisible, isSelfRootVC);
    }
}

- (BOOL)isVideoTimelineVisiable {
    BOOL isSelfVisible = self.isViewLoaded && self.view.window;
    
    UIViewController *topSubVC = [self.flipboardNavigationController topSubcontroller];
    BOOL isSelfRootVC = topSubVC == self;
    
    SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
    BOOL isSelectedVCVisiable = selectedvc.isViewLoaded && selectedvc.view.window;
    
    if (isSelfVisible && isSelfRootVC && isSelectedVCVisiable && ![selectedvc isLoading]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 2G3G提示
- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style forPlayerView:(WSMVVideoPlayerView *)playerView {
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
                [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
            }
            else {
                
                SNVideosTableViewController *selectedvc = [self loadTableViewWithPage:self.tabBar.selectedTabIndex];
                NSString *channelID = selectedvc.channelId;
                if (channelID.length > 0) {
                    BOOL hadEverAlert2G3GOfSelectedChannel = [[[WSMVVideoHelper sharedInstance].hadEverAlert2G3GOfChannels objectForKey:channelID] boolValue];
                    if (!hadEverAlert2G3GOfSelectedChannel) {
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"using_2g3g_currently_pls_note", nil) toUrl:nil mode:SNCenterToastModeWarning];
                        [[WSMVVideoHelper sharedInstance].hadEverAlert2G3GOfChannels setObject:@(YES) forKey:channelID];
                    }
                }
            }
        }
    }
    else if (style == WSMV2G3GAlertStyle_NetChangedTo2G3GToast) {
        SNDebugLog(@"Toast for network changed to 2G/3G.");
        
        UIView *superViewOfActionSheet = self.networkStatusActionSheet.superview;
        BOOL isActionSheetInvisible = (superViewOfActionSheet == nil);
        if (isActionSheetInvisible) {
            if ([playerView isFullScreen]) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil mode:SNCenterToastModeWarning];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"videoplayer_net_changed_to_2g3g_msg", nil) toUrl:nil mode:SNCenterToastModeWarning];
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
    }otherButtonHandler:^{
        playerView.playingVideoModel.hadEverAlert2G3G = YES;
        [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
        [self startPlayTimelineVideoIn2G3G];
    }];
}

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SNDebugLog(@"Tapped actionSheet at buttonIndex %d", buttonIndex);
    
    WSMVVideoPlayerView *playerView = [[actionSheet userInfo] objectForKey:kPlayerViewWithActionSheet];
    if (actionSheet.tag == kRechabilityChangedActionSheetTag) {
        if (buttonIndex == 0) {//取消
            playerView.playingVideoModel.hadEverAlert2G3G = NO;
            
            SNDebugLog(@"Cancel play video in actioin sheet.");
        }
        else if (buttonIndex == 1) {//播放
            playerView.playingVideoModel.hadEverAlert2G3G = YES;
            [[WSMVVideoHelper sharedInstance] continueToPlayVideoIn2G3G];
            
            [self startPlayTimelineVideoIn2G3G];
        }
    }
}

- (void)dismissActionSheetByTouchBgView:(SNActionSheet *)actionSheet {
    SNDebugLog(@"Cancel play video in dismissActionSheetByTouchBgView.");
}

- (void)showNewChannelMessage {
    if ([self isViewLoaded]) {
//        [[SNToast shareInstance] showToastWithTitle:@"新频道上线了，快添加看看"
//                                              toUrl:nil
//                                               mode:SNToastUIModeFeedBackCommon];
    }
}

#pragma mark - SNVideosTableCellDelegate
- (BOOL)canRespondRotate {
    BOOL isSelfVisible = self.isViewLoaded && self.view.window;
    
    UIViewController *topSubVC = [self.flipboardNavigationController topSubcontroller];
    BOOL isSelfRootVC = topSubVC == self;
    
    return isSelfVisible && isSelfRootVC;
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _channelDatasource && [keyPath isEqualToString:@"hasNew"]) {
        if (_channelDatasource.hasNew) {
            [self performSelector:@selector(showNewChannelMessage) withObject:nil afterDelay:3];
            _channelDatasource.hasNew = NO;
        }
    }
}

#pragma mark - update stats when app become active
- (void)updateVideoChannelIfNotYet {
    if (!_channelDatasource.hasRefreshedSuccessForOnce) {
        [_channelDatasource loadFromServer];
    }
}

- (void)updateVideoChannelIfNeeded {
    if ([_channelDatasource shouldReload]) {
        [_channelDatasource loadFromServerInSilence];
    }
}

- (void)updateViewContentDataWhenAppBecomeActive {
    [self updateVideoChannelIfNeeded];
}

@end
