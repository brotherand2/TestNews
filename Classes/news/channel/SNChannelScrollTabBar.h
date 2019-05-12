//
//  SNChannelScrollTabBar.h
//  sohunews
//
//  Created by Cong Dan on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNChannelScrollTab.h"
#import "SNChannelModel.h"
#import "SNCenterLinesAnimView.h"
#import "SNPopoverView.h"
#import "SNChannelSelectedLineView.h"

@class SNChannelScrollTabItem;
@class SNChannelScrollTab;
@class SNChannelScrollLogoButton;
@class SNChannelTitleLabel;

@protocol SNChannelScrollTabBarDelegate;
@protocol SNScrollTabBarDataSource;

typedef enum {
    SNChannelScrollTabTypeNews,
    SNChannelScrollTabTypeVideo
}SNChannelScrollTabType;

@interface SNChannelScrollTabBar : UIView <UIScrollViewDelegate> {
    NSInteger       _selectedTabIndex;
    NSInteger       _lastSelectedTabIndex;
    NSInteger       _currentSelectedTabIndex;
    
    NSArray         *_tabItems;
    NSMutableArray  *_tabViews;
    NSMutableArray  *_separators;
    
    CGSize  _contentSize;
    NSString *_currentTheme;
    NSString *_logoLink;
    NSTimeInterval _editChannelTime;
    
    UIScrollView *_scrollView;
    SNChannelSelectedLineView *_channelSelectedImageView;
    UIButton *_editButton;
    UIButton *_editDoneButton;
    UIButton *_channelManageEditButton;
    UIButton *_channelManageEditDoneButton;
    UIButton *_moreButton;
    UIButton *_searchButton;
    
    BOOL _contentSizeCached;
    BOOL isReleased;
    BOOL bForceScroll;
    BOOL isEditMode;
    BOOL _observeScrollEnable;
    BOOL showLogo;
    BOOL tabItemEditing;
    BOOL isUnRead;
    BOOL _ignoreScroll;
    BOOL _didMoveOut;

    id<SNChannelScrollTabBarDelegate> __weak _delegate;
    id<SNScrollTabBarDataSource> __weak _dataSource;
    
    SNChannelScrollLogoButton *channelLogoButton;
    SNChannelTitleLabel *_editModeTitleLabel;
    NSTimeInterval _channelActionDate;
    UIView *_shieldTabBarView;
    
    CGPoint _scrollViewContentOffset;
    UIImageView *_localChnBadgeView;
    UIView *lineView;//by 5.9.4 wangchuanwen add
}

@property (nonatomic) NSInteger   selectedTabIndex;
@property (nonatomic, weak) NSString *selectedChannelId;  // add by Cae.   2015.5.9

@property (nonatomic, weak) SNChannelScrollTabItem *selectedTabItem;
@property (nonatomic, weak) SNChannelScrollTab *selectedTabView;
@property (nonatomic, assign) SNChannelScrollTabType   scrollTabType;

@property (nonatomic, copy) NSString *channelId;

@property (nonatomic, copy) NSArray *tabItems;
@property (nonatomic, readonly) NSArray *tabViews;

@property (nonatomic, weak) id<SNChannelScrollTabBarDelegate> delegate;
@property (nonatomic, weak) id<SNScrollTabBarDataSource> dataSource;

@property (nonatomic, assign) BOOL isReleased;
@property (nonatomic, assign) BOOL observeScrollEnable;
@property (nonatomic, assign) BOOL needChannelEditModeButton;

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, copy) NSString *logoLink;
@property (nonatomic, copy) NSString *editModeTitleString; // 在频道编辑模式下 tabbar显示的
@property (nonatomic, strong) NSArray *positiveImageArray;//5.2 add动画序列正序数组
@property (nonatomic, strong) NSArray *reverseImageArray;//5.2 add动画序列逆序数组
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) UIButton *animationLaunchButton;
@property (nonatomic, strong) SNCenterLinesAnimView *animationView;
@property (nonatomic, assign) BOOL isFromRollingNews;//区分新闻、视频tab
@property (nonatomic, strong) SNPopoverView *popOverView;

@property (nonatomic, strong) SNChannelSelectedLineView *channelSelectedImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *rightCoverImageView;
@property (nonatomic, strong) UIImageView *middleCoverImageView;
@property (nonatomic, strong) UIImageView *fullscreenMaskImageView;
@property (nonatomic, strong) UIImageView *shadowImageView;

@property (nonatomic, assign) BOOL isChannelTempStatus;//临时变量，弱网或快速滑动loading页，要闻和推荐均为选中状态
@property (nonatomic, assign) CGFloat tempChannelPositionX;//记录初始位置，避免左右滑动坐标发生变化
@property (nonatomic, assign) BOOL isUseDynamicSkin;//是否使用动态皮肤
@property (nonatomic, assign) BOOL isManagerChannelViewHide;
@property (nonatomic, assign) CGFloat homeTableViewOffsetY;
@property (nonatomic, assign, readonly) BOOL isFullScreenMode;//是否是全屏透明模式

- (id)initWithChannelId:(NSString *)channelId;
- (id)initWithChannelId:(NSString *)channelId showLogo:(BOOL)isShow;

/**
 导航条切换全屏透明模式与普通default模式

 @param fullscreen YES 为全屏透明模式
 */
- (void)changeFullScreenMode:(BOOL)fullscreen;

/**
 首页大scrollview滚动通知，用于全屏模式下channelTabBar的变化

 @param contentOffsetX scrollview.contentOffsetX
 */
- (void)rollingNewsScrollViewDidScroll:(CGFloat)contentOffsetX;

/**
 首页tableview 滚动

 @param offsetY contentoffsetY
 */
- (void)rollingNewsTableViewDidScroll:(CGFloat)offsetY;

/**
 频道管理页即将展示或消失

 @param show YES为即将展示
 */
- (void)channelsEditViewWillAnimate:(BOOL)show;

- (void)updateTheme;

- (void)reloadChannels;
- (void)reloadChannels:(NSInteger)index channelId:(NSString *)channelId;

- (void)showChannelManageMode:(BOOL)show;
- (void)showChannelManageMode:(BOOL)show animated:(BOOL)animated isFromRollingNews:(BOOL)isFromRollingNews;
- (void)finishChannelManageMode;

- (void)setMoreButtonSelected:(BOOL)selected;

- (void)beginEdit;

- (void)showTabBubble:(int)count atIndex:(int)index;
- (void)updateShowLogo:(BOOL)isShow
               logoUrl:(NSString *)url link:(NSString *)link;

- (void)forceSetSelectedTabIndex:(NSInteger)selectedTabIndex;

- (void)reloadScrollTabBar;

- (void)resetCurrentTabTitle:(NSString *)title;

- (void)tabTouchedUp:(SNChannelScrollTab *)tab;

- (CGPoint)getChannelPoint;
+ (CGFloat)channelBarHeight;

- (void)toScrollingAnimation:(NSInteger)index haveAnimation:(BOOL)haveAnimation;

- (void)resetSelectedTabIndex:(NSInteger)selectedTabIndex;

- (void)resetTopScrollBarBackColor:(BOOL)isNormal;//重新设置顶部频道栏背景色

- (void)shouldShowSohuLogo:(BOOL)show;

@end


@protocol SNChannelScrollTabBarDelegate <NSObject>

- (void)tabBar:(SNChannelScrollTabBar *)tabBar tabSelected:(NSInteger)selectedIndex;
- (void)tabBarBeginEdit:(SNChannelScrollTabBar *)tabBar;
- (void)tabBarAutoRefresh:(SNChannelScrollTabBar*)tabBar;
- (void)tabBarDismissPopoverMessage:(SNChannelScrollTabBar *)tabBar;

@optional
- (void)tabBarChannelReloaded;

@end

@protocol SNScrollTabBarDataSource <NSObject>

@required
- (NSUInteger)numberOfItemsForTabBar:(SNChannelScrollTabBar *)tabBar;
- (SNChannelScrollTabItem *)tabBar:(SNChannelScrollTabBar *)tabBar tabBarItemForIndex:(NSUInteger)index;

@end
