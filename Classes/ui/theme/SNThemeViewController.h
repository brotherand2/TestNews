//
//  SNThemeViewController.h
//  sohunews
//
//  Created by qi pei on 5/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNNavigationView.h"

@interface SNThemeViewController : TTBaseViewController {
    NSString *currentTheme;
    SNNavigationView *__weak _navigationView;
    
    UIView *_tabbarSnapView;
    BOOL _bLockTabbarView;
    
    NSString *_newsfrom;
    BOOL _isPush;
}
@property(nonatomic,copy) NSString *currentTheme;
@property(weak, nonatomic, readonly) SNNavigationView *navigationView;
@property(nonatomic, strong) UIView *tabbarSnapView;
@property(nonatomic, strong) NSMutableDictionary *queryDic;
@property(nonatomic, strong) NSString *newsfrom;
@property(nonatomic, assign) BOOL isPush;

-(void)customTabbarStyle:(NSString *)icon activeIcon:(NSString *)activeIcon title:(NSString *)title;

-(void)customTitleView;

-(void)updateThemeIfChanged;

- (void)viewControllerWillResignActive;


/**
 用于直播间收到push的处理

 @param aLiveId liveId
 @return 正在直播
 */
- (BOOL)isLiveGameShowing:(NSString*)aLiveId;


/**
 APP激活时需要刷新数据
 */
- (void)refreshTableViewDataWhenAppBecomeActive;

@end
