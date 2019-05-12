//
//  SNRollingNewsTableController.h
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDragRefreshTableViewController.h"
#import "SNNewsTableViewDelegate.h"
#import "SNChannelScrollTabBar.h"
#import "SNRollingNewsDataSource.h"
#import "SNLiveDataSource.h"
#import "SNDBManager.h"
#import "SNRollingGroupPhotoDataSource.h"
#import "SNNewsChannelType.h"
#import "SNSearchWebViewController.h"

@class SNChannel;

@protocol SNRollingNewsLoadFlagDelegate <NSObject>
- (BOOL)canLoadNews;
- (void)dismissPopoverMessage;
- (void)changeLayOut:(BOOL)change;
- (void)hiddenTabar:(BOOL)hidden;
- (void)EnabledTabar:(BOOL)enable;
- (void)hiddenTabarView:(BOOL)hidden;
- (void)shouldChangeStatusBarTextColorToDefault:(BOOL)change;
@end

@interface SNRollingNewsTableController : SNDragRefreshTableViewController<UISearchBarDelegate, UISearchDisplayDelegate, SNSearcbBarDelegate> {
    SNChannelScrollTabBar *tabBar;
    SNNewsChannelType _channelType;
    
    BOOL isViewReleased;
    BOOL needForceLoadLocal;
    BOOL isAnimating;
    BOOL isReuse;
    BOOL isH5;
    BOOL isPreloadChannel;//标记此为预加载的频道
    BOOL isNewChannel;//标记新版本频道
    int isMixStream;//标记混流频道
    
    NSString *currentMinTimeline;
    NSIndexPath *lastIndexPath;
    NSInteger currentPage;
}

@property (nonatomic, strong) NSString *selectedChannelId;
@property (nonatomic, assign) int selectedChanneType;
@property (nonatomic, strong) NSString *currentMinTimeline;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, strong) SNNewsTableViewDelegate *dragDelegate;
@property (nonatomic, strong) SNChannelScrollTabBar *tabBar;
@property (nonatomic, strong) UIButton *redPacketBtn;
@property (nonatomic, assign) BOOL isViewAppeared;
@property (nonatomic, assign) BOOL needForceLoadLocal;
@property (nonatomic, assign) BOOL isViewReleased;
@property (nonatomic, assign) BOOL isReuse;
//判断此Controller.view是否加载到其他View上
@property (nonatomic, assign) BOOL isAddToSuperView;
@property (nonatomic, assign) BOOL isFromSub;
@property (nonatomic, assign) BOOL isH5;
@property (nonatomic, assign) BOOL isNewChannel;
@property (nonatomic, assign) BOOL isPreloadChannel;
@property (nonatomic, assign) int isMixStream;//标记混流频道
@property (nonatomic, weak) id<SNRollingNewsLoadFlagDelegate> loadDelegate;

//For ad
@property (nonatomic, weak) UIViewController *parentViewControllerForModalADView;
@property (nonatomic, strong) SNSearchWebViewController *searchVc;
@property (nonatomic, strong) UIImageView *year2015Bg;

- (void)tabBar:(SNChannelScrollTabBar *)tabBar channelSelected:(SNChannel *)channel;
- (void)scrollViewWillBeginDragging;
- (void)scrollViewDidEndDecelerating;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)cacheCellIndexPath:(UITableViewCell *)aCell;
- (void)updateTheme;

- (void)createModel;
- (void)reCreateModel;
- (void)deleteNewsCellWithIndex:(int)index;
- (void)refreshH5WebView;
- (void)resetH5TripletsLoadingView;
- (void)processH5ChannelLoading;

- (void)reportPopularizeStatExposureInfo;
- (void)addAndShow2015YearBg;
- (void)requestPullAd;
- (void)reportPullAdShow;
- (void)rollingNewsTableDidSelected;
- (void)openNewsFrom3DTouch;
- (CGFloat)getBarHeight;
- (void)dismissRecommendTable;
- (void)resetTableAndRefresh;
- (void)setNewChannel:(BOOL)isNew;
- (BOOL)isHomePage;
- (BOOL)isIntroPage;
- (BOOL)isLocalPage;
- (void)showRedPacketBtn;
- (void)stopPageTimer:(BOOL)stop;
- (void)loadHotSearchWords;
- (void)hideNovelPopover;
- (void)reCreateSearchBar;

//重新计算CELL高度
- (void)recalculateCellHeight;

- (void)changeModelToNewChannel:(SNChannel *)channel;

- (void)changeFullscreenMode:(BOOL)isFullscreen;

@end
