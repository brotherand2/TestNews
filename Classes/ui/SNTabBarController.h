//
//  SNTabBarController.h
//  Three20Learning
//
//  Created by zhukx on 5/15/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNTabbarView.h"

typedef enum {
    TABBAR_INDEX_NEWS,
    TABBAR_INDEX_VIDEO,
    TABBAR_INDEX_MORE,
    TABBAR_INDEX_TOTAL
} TABBAR_INDEX_ENUM;

@interface SNTabBarController : UITabBarController<UITabBarControllerDelegate, UINavigationControllerDelegate, SNNavigationControllerDelegate> {
    SNTabbarView *_tabbarView;
}

@property (nonatomic, strong) SNTabbarView *tabbarView;

// 启动TabbarButton动画
- (void)flashTabBarItem:(BOOL)flash atIndex:(int)index;

// 是否有红点动画
- (BOOL)isBubbleAnimatingAtTabBarIndex:(int)index;

// 指定tab是否当前选中的
- (BOOL)isTabIndexSelected:(int)index;

-(void)updateAppTheme;

- (void)loadTabs;

- (void)showBubbleTip:(int)count atIndex:(int)index;

// 记住tab的状态，下次进入时依然进入过上次离开的tab
- (void)restoreLastSavedTabIndex;

- (void)saveCurrentTabIndex;

- (void)refreshTabbarView;

@end

// ------------------------------------------
// Category for custom uitabbarcontroller
// by jojo

@interface UIViewController (customTabbarController)

// prevent UITabbarController.tabbar come out again
- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed;

// icon names array
- (NSArray *)iconNames;

- (NSString *)tabItemText;

//Read only method to provide tabbar view
- (SNTabbarView *)tabbarView;

//Show sntabbarview snapshot
- (void)showTabbarView;

//Show or hide sntabbar snapshot
- (void)setTabbarViewVisible:(BOOL)bVisible;

- (void)setTabbarViewLocked:(BOOL)bLocked;

//For debug
- (void)printSubviewsInView:(UIView *)view;

+ (NSNumber *)tabIndexToStatistics:(NSInteger)tabIndex;

@end
