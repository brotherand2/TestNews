//
//  SNTabBarController.m
//  Three20Learning
//
//  Created by zhukx on 5/15/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNTabBarController.h"
#import "SNRollingNewsViewController.h"
#import "SNVideosViewController.h"
#import "SNNavigationController.h"
#import "SNBubbleTipView.h"
#import "SNTabBarController+SVTab.h"
#import "SNVideoAdContext.h"
#import "SNRollingNewsPublicManager.h"
#import "SNTabbarView.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNUserPortrait.h"

#import "SNMySDK.h"
#import "SNAppStateManager.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNRedPacketManager.h"
#import "SNNewMeViewController.h"
#import "SNTabBarController+SVTab.h"
#import <SohuLiveSDK-News/SohuLiveSDK-News.h>


@implementation UIViewController (customTabbarController)

- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed {
}

- (NSArray *)iconNames {
    return nil;
}

- (NSString *)tabItemText {
    return nil;
}

- (SNTabbarView *)tabbarView {
    if ([self.tabBarController isKindOfClass:[SNTabBarController class]]) {
        return [(SNTabBarController *)self.tabBarController tabbarView];
    }
    return nil;
}

+ (NSNumber *)tabIndexToStatistics:(NSInteger)tabIndex {
    return nil;
}

- (void)showTabbarView {
}

- (void)setTabbarViewVisible:(BOOL)bVisible {
    
}

- (void)setTabbarViewLocked:(BOOL)bLocked {
    
}

- (void)printSubviewsInView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        [self printSubviewsInView:subView];
    }
}

@end

#define FADE_BARITEM_DURATION 3
#define BADGE_VIEW_TAG 100
#define BUBBLE_VIEW_TAG 300

BOOL _animating[TABBAR_INDEX_TOTAL];

@interface SNTabBarController()
- (UIView *)getTabBarButtonAtIndex:(int)index;
@end

@implementation SNTabBarController
@synthesize tabbarView = _tabbarView;

#pragma mark - Override
- (void)viewDidLoad {
    //不要在这里直接初始化4个tab，会卡住splash太久，让splash回调上面的loadTabs方法
    //内存警告时不要再重新创建4个tab，会崩溃。
    [super viewDidLoad];
    [self addSVTabObserver];

    [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(couponReceiveSucces:) name:kJoinRedPacketsStateChanged object:nil];
    
    //[SNUserPortrait OpenWindow:self.view];//用户画像，貌似跟红包显示的冲突了
}

- (void)updateTheme {
    [self setNeedsStatusBarAppearanceUpdate];
    [_tabbarView updateTheme];
}

- (void)viewWillAppear:(BOOL)animated {
    //不知道为什么去掉Super
    //[super viewWillAppear:animated];
    self.tabBar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-20, [UIScreen mainScreen].bounds.size.width, 0);
    self.tabBar.hidden = YES;
    self.tabBar.alpha = 0;
    
    //Adjust frame
    UIView *container = [self findSubViewByClassName:@"UITransitionView"
                                              inView:self.view];
    container.height = TTScreenBounds().size.height;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
     //(_tabbarView);
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (self.selectedIndex != selectedIndex) {
        [[SNVideoAdContext sharedInstance] setCurrentTabIndex:selectedIndex];
        
        [super setSelectedIndex:selectedIndex];
        
        [[SNMySDK sharedInstance] updateSnsSessionWithTabbarSelectedIndex:selectedIndex];
        
        _tabbarView.currentSelectedIndex = selectedIndex;
    }
    
    if (selectedIndex == 3) {
        if (![SNUserDefaults boolForKey:kIdentifyImageOnMeTabKey]) {
            [SNUserDefaults setBool:YES forKey:kIdentifyImageOnMeTabKey];
        }
        if ([_tabbarView.tabButtons count] > 3) {
            SNTabBarButton *button = [_tabbarView.tabButtons objectAtIndex:3];
            [button removeIdendifyOnButton];
        }
    }
}

- (BOOL)isTabIndexSelected:(int)index {
    return self.selectedIndex == index;
}

#pragma mark - 恢复/记录tab索引
- (void)restoreLastSavedTabIndex {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    NSString *key = [NSString stringWithFormat:@"selectedTabIndex_%@", version];
    
    id selectIndexObj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (selectIndexObj == nil) {
        self.selectedIndex = TABBAR_INDEX_NEWS;
    } else {
        self.selectedIndex = [selectIndexObj intValue];
    }
}

- (void)saveCurrentTabIndex {
    //在更多tab页退出时，保存为订阅页，下次启动进入订阅
    NSInteger index = self.selectedIndex;
    if (index == TABBAR_INDEX_MORE) {
        index = TABBAR_INDEX_NEWS;
    }
   
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    NSString *key = [NSString stringWithFormat:@"selectedTabIndex_%@", version];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)index] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAppTheme {
    [self customTabbarView];
    [SNNotificationManager postNotificationName:kThemeDidChangeNotification object:@([[SNThemeManager sharedThemeManager] isNightTheme])];
}

- (void)refreshTabbarView {
    if (_tabbarView){
        [_tabbarView refreshTabButton];
    }
}

- (UIView *)findSubViewByClassName:(NSString *)className inView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([NSStringFromClass(subView.class) isEqualToString:className]) {
            return subView;
        }
        UIView *v = [self findSubViewByClassName:className inView:subView];
        if (v != nil) {
            return v;
        }
    }
    return nil;
}

- (void)loadTabs {
    self.delegate = self;
    [self setTabURLs:[NSArray arrayWithObjects:
                      @"tt://rollingNews",
                      @"tt://videos",
                      @"tt://more",
                      @"tt://newMe",
                      nil]];
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:[SNNavigationController class]]) {
            ((SNNavigationController *)viewController).delegate = self;
        }
    }
    
    self.selectedIndex = 0;
    
    self.tabBar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-20, [UIScreen mainScreen].bounds.size.height, 0);
    self.tabBar.hidden = YES;
    self.tabBar.alpha = 0;
    
    //Adjust frame
    UIView *container = [self findSubViewByClassName:@"UITransitionView"
                                              inView:self.view];
    container.height = TTScreenBounds().size.height;
    
    [self customTabbarView];
}

#pragma mark -
- (void)customTabbarView {
    //TODO:需要优化
    if (!_tabbarView) {
        NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
        for (UIViewController *vc in self.viewControllers) {
            UIViewController *tmpVc = nil;
            if ([vc respondsToSelector:@selector(topViewController)]) {
                tmpVc = [vc performSelector:@selector(topViewController)];
            } else {
                tmpVc = vc;
            }
            if (tmpVc) {
                [viewControllers addObject:tmpVc];
            }
        }
        self.tabbarView = [SNTabbarView tabbarViewWithViewControllers:viewControllers];
        _tabbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _tabbarView.delegate = self;
        _tabbarView.bottom = self.view.height;
        [self.tabBar.superview addSubview:_tabbarView];
        
        _tabbarView.currentSelectedIndex = self.selectedIndex;
    }
    
    [_tabbarView updateTheme];
    
    for (SNTabBarButton *tabBarBtn in _tabbarView.tabButtons) {
        [tabBarBtn updateTheme];
        
        UIImageView *badge = (UIImageView *)[tabBarBtn viewWithTag:BADGE_VIEW_TAG];
        if (badge != nil) {
            badge.image = [UIImage imageNamed:@"icohome_dot_v5.png"];
        }
        SNBubbleTipView *bubble = (SNBubbleTipView *)[tabBarBtn viewWithTag:BUBBLE_VIEW_TAG];
        if (bubble != nil) {
            [bubble updateTheme];
        }
    }
}

- (UIView *)getTabBarButtonAtIndex:(int)index {
    if (index < _tabbarView.tabButtons.count) {
        return [_tabbarView.tabButtons objectAtIndex:index];
    }
    
    return nil;
}

- (void)fadeOutTabButtonBadgeAtIndex:(int)index {
    UIView *tmpBtn = [self getTabBarButtonAtIndex:index];
    if (!tmpBtn) return;
    UIImageView *badge = (UIImageView *)[tmpBtn viewWithTag:BADGE_VIEW_TAG];
    if (badge == nil) {
        if ([tmpBtn isKindOfClass:[SNTabBarButton class]]) {
            SNTabBarButton *tabbarBtn = (SNTabBarButton *)tmpBtn;
            CGFloat x = tabbarBtn.tabBarImageView.right;
            CGFloat y = tabbarBtn.maskButton.imageView.top;
            badge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
            badge.image = [UIImage imageNamed:@"icohome_dot_v5.png"];
            badge.left = x + 1;//微调
            badge.top = y + 2;//微调
            [tabbarBtn addSubview:badge];
        }
    }
    badge.alpha = 1.0f;
    badge.hidden = NO;
    badge.tag = BADGE_VIEW_TAG;
}

- (void)showBubbleTip:(int)count atIndex:(int)index {
    UIView *tabBarButton = [self getTabBarButtonAtIndex:index];
    if (!tabBarButton)
        return;
    SNBubbleTipView *bubble = (SNBubbleTipView *)[tabBarButton viewWithTag:BUBBLE_VIEW_TAG];
    if (bubble == nil) {
        bubble = [[SNBubbleTipView alloc] initWithType:SNTabbarBubbleType];
        bubble.frame = CGRectMake(63, 1, 4, 4);
        bubble.tag = BUBBLE_VIEW_TAG;
        [tabBarButton addSubview:bubble];
    }
}

- (void)flashTabBarItem:(BOOL)flash atIndex:(int)index {
    if (flash) {
        if (!_animating[index]) {
            [self fadeOutTabButtonBadgeAtIndex:index];
            _animating[index] = YES;
        }
    } else {
        _animating[index] = NO;
        UIView *tabBarButton = [self getTabBarButtonAtIndex:index];
        UIImageView *badge = (UIImageView *)[tabBarButton viewWithTag:BADGE_VIEW_TAG];
        badge.hidden = YES;
        [badge removeFromSuperview];
    }
}

- (BOOL)isBubbleAnimatingAtTabBarIndex:(int)index {
    if (index >= 0 && index < TABBAR_INDEX_TOTAL) {
        UIView *tabBarButton = [self getTabBarButtonAtIndex:index];
        UIImageView *badge = (UIImageView *)[tabBarButton viewWithTag:BADGE_VIEW_TAG];
        if (badge) {
            return badge.hidden == NO;
        }
    }
    return NO;
}

#pragma mark - SNTabbarViewDelegate
- (void)tabbarViewIndexWillChanged:(NSInteger)index {
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    [self tabBarController:self willUnSelectViewController:vc];
}

- (void)tabbarViewIndexDidChanned:(NSInteger)index {
    [[SNMySDK sharedInstance] clickTabLastSelsct:(int)self.selectedIndex andClickSelext:(int)index];
    
    BOOL isNewsTab = NO;
    if (index == self.selectedIndex) {
        switch (index) {
            case 0:
            {
                if (self.tabbarView.isForceClick) {
                    self.tabbarView.isForceClick = NO;
                } else {
                    isNewsTab = YES;
                }
            }
                break;
            case 1:
                [SNNotificationManager postNotificationName:kAutoRefreshVideoNewsNotification object:nil];
                break;
            case 2:
                [SNNotificationManager postNotificationName:kAutoRefreshUserInfoNotification object:nil];
                break;
            default:
                break;
        }
    }
    
    UIViewController *videoVc = [self.viewControllers objectAtIndex:self.selectedIndex];
    if (index == 1 && index == self.selectedIndex) {
        SNNavigationController *navigationController = (SNNavigationController *)videoVc;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if([navigationController.currentViewController respondsToSelector:@selector(tapTabBarRefush)]){
            [navigationController.currentViewController performSelector:@selector(tapTabBarRefush)];
        }
#pragma clang diagnostic pop
    }
    
    if (index != self.selectedIndex) {
        //关闭之前弹出的更多View
        [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:YES];
        [[SNRollingNewsPublicManager sharedInstance] closeListenNewsGuideViewAnimation:YES];
        [SNNotificationManager postNotificationName:kSearchWebViewCancle object:nil];
        
        SNTimelineSharedVideoPlayerView *timelineVideoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
        [timelineVideoPlayer pause];

        UIViewController *vc = [self.viewControllers objectAtIndex:index];
        [self tabBarController:self didSelectViewController:vc];
    }
    
    //如果从其他Tab点击首页Tab不进行刷新
    if (isNewsTab || (index == 0 && index == self.selectedIndex)) {
        [SNRollingNewsPublicManager sharedInstance].isHomePage = YES;
        [SNRollingNewsPublicManager sharedInstance].newsSource = SNRollingNewsSourceTab;
        [SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom = NO;
        
        [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:@{kClickTabToRefreshHomeKey : [NSNumber numberWithInteger:ClickTabToRefreshHome_Tab]}];
    }

    self.selectedIndex = index;
    
    if (!isNewsTab) {
        [SNRollingNewsPublicManager sharedInstance].isHomePage = NO;
    }
    if (index == 0) {
        [SNRollingNewsPublicManager sharedInstance].isHomePage = YES;
    }
    
    [SNRollingNewsPublicManager sharedInstance].resetHome = NO;
    [[SNAppStateManager sharedInstance] resetAppStateDate];
}

#pragma mark - SNNavigationControllerDelegate
- (void)navigationController:(SNNavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if (![self checkIfViewControllerIsTop4Controller:viewController]) {
        UIViewController *topVC = [navigationController.viewControllers objectAtIndex:0];
        [topVC setTabbarViewLocked:NO];
        [topVC showTabbarView];
    } else {
        [viewController setTabbarViewLocked:NO];
        [viewController showTabbarView];
        //@qz 适配iPhone X
        if([viewController isKindOfClass:NSClassFromString(@"SNSPlaygroundViewController")]){
            if ([viewController.tabbarView isKindOfClass:[SNTabbarView class]]) {
                SNTabbarView *tabview = (SNTabbarView *)viewController.tabbarView;
                if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
                    tabview.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - [SNTabbarView tabBarHeightForiPhoneX], [UIScreen mainScreen].bounds.size.width, [SNTabbarView tabBarHeightForiPhoneX]);
                }
            }
        }
    }
}

- (void)navigationController:(SNNavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if ([self checkIfViewControllerIsTop4Controller:viewController]) {
        [viewController setTabbarViewVisible:NO];
        if ([self.tabBar.superview.subviews count] == 3) {
            [_tabbarView removeFromSuperview];
        }
        _tabbarView.bottom = self.view.height;
        [self.tabBar.superview addSubview:_tabbarView];
        [viewController setTabbarViewLocked:NO];
    }
    
//    if ([viewController isKindOfClass:[SNNewMeViewController class]]) {//wangshun 用户画像 产品说不做了
//        [SNUserPortrait closeUserWindow];
//    }
}

#pragma mark - UINavigationControllerDelegate
- (BOOL)checkIfViewControllerIsTop4Controller:(UIViewController *)viewController {
    if ([viewController isMemberOfClass:[SNRollingNewsViewController class]]) {
        return YES;
    }
    if ([viewController isMemberOfClass:[SNNewMeViewController class]]) {
        return YES;
    } else if ([viewController isMemberOfClass:[SNVideosViewController class]]) {
        return YES;
    } else if ([viewController isMemberOfClass:NSClassFromString(@"SNSPlaygroundViewController")]) {
        return YES;
    }
    return NO;
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return (tabBarController.selectedViewController != viewController);
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[SNNavigationController class]]) {
        SNNavigationController *nav = (SNNavigationController *)viewController;
        UIViewController *topViewController = [nav.viewControllers lastObject];
        
        [nav.delegate navigationController:nav didShowViewController:topViewController animated:NO];
        
        [SHVideoForNewsSDK destroyVideoPlayer];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([topViewController respondsToSelector:@selector(refreshOnTappingTabBarItem)]) {
            [topViewController performSelector:@selector(refreshOnTappingTabBarItem)];
        }
    } else {
        TTNavigationController *naviCon = (TTNavigationController *)viewController;
        if ([naviCon topViewController]) {
            UIViewController *rootViewController = [naviCon topViewController];
            if ([rootViewController isKindOfClass:[SVChannelsViewController class]]) {
                [SHVideoForNewsSDK destroyVideoPlayer];
            }
            if ([rootViewController respondsToSelector:@selector(refreshOnTappingTabBarItem)]) {
                [rootViewController performSelector:@selector(refreshOnTappingTabBarItem)];
            }
        }
    }
#pragma clang diagnostic pop

    [[SNAutoPlaySharedVideoPlayer sharedInstance] clearMoviePlayerController];
    [[SNTimelineSharedVideoPlayerView sharedInstance] clearMoviePlayerController];
}

- (void)tabBarController:(UITabBarController *)theTabBarController willUnSelectViewController:(UIViewController *)viewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([viewController isKindOfClass:[SNNavigationController class]]) {
        SNNavigationController *nav = (SNNavigationController *)viewController;
        UIViewController *topViewController = [nav.viewControllers lastObject];
        if ([topViewController respondsToSelector:@selector(tabBarControllerWillChanged)]) {
            [topViewController performSelector:@selector(tabBarControllerWillChanged)];
        }
    } else {
        TTNavigationController *naviCon = (TTNavigationController *)viewController;
        UIViewController *rootViewController = [naviCon topViewController];
        if ([rootViewController respondsToSelector:@selector(tabBarControllerWillChanged)]) {
            [rootViewController performSelector:@selector(tabBarControllerWillChanged)];
        }
    }
#pragma clang diagnostic pop

}

+ (NSNumber *)tabIndexToStatistics:(NSInteger)tabIndex {
    switch (tabIndex) {
        case TABBAR_INDEX_NEWS:
            return @(1);
        case TABBAR_INDEX_VIDEO:
            return @(2);
        default:
            return @(0);
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (BOOL)shouldAutorotate {
    //查看当前视图是否是千帆直播间，如果是则由千帆sdk决定旋转设置
    SNNavigationController *currentNavi = self.selectedViewController;
    if(currentNavi.viewControllers.count > 0){
        UIViewController *topVC = currentNavi.topSubcontroller;
        if ([NSStringFromClass([topVC class]) isEqualToString:@"SLLiveRoomViewController"]) {
            return [[SLNewsApplication sharedApplication] shouldAutorotate];
        }
    }
    
    if (self.tabbarView.currentSelectedIndex == 1) {
        return NO; //解决播放器大小窗，statusBar不旋转问题
    } else {
        if ([[[TTNavigator navigator] topViewController] isKindOfClass:NSClassFromString(@"VideoDetailViewController")] || [[[TTNavigator navigator] topViewController] isKindOfClass:NSClassFromString(@"SHVideoPlayerViewController_iPhone")] || [[[TTNavigator navigator] topViewController] isKindOfClass:NSClassFromString(@"WebViewController")]) {
            return NO;
        }
        return YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //查看当前视图是否是千帆直播间，如果是则由千帆sdk决定旋转设置
    SNNavigationController *currentNavi = self.selectedViewController;
    if (currentNavi.viewControllers.count > 0) {
        UIViewController *topVC = currentNavi.topSubcontroller;
        if ([NSStringFromClass([topVC class]) isEqualToString:@"SLLiveRoomViewController"]) {
            if ([SNRollingNewsPublicManager sharedInstance].banScreenLandScape) {                
                [SNUtility forceScreenPortrait];
                return UIInterfaceOrientationMaskPortrait;
            }
            return [[SLNewsApplication sharedApplication] supportedInterfaceOrientations];
        }
    }
    return UIInterfaceOrientationMaskPortrait;//解决iOS8+presentVC后dismiss出现的各种旋转以及UI错位问题
}

- (void)couponReceiveSucces:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *state = notification.object;//notification.object就是开关
        BOOL shown = [state boolValue];
        [SNRedPacketManager sharedInstance].joinActivity = shown;
        [self refreshTabbarView];
    });
}
#endif

@end
