//
//  SNThemeViewController.h
//  sohunews
//
//  Created by qi pei on 5/8/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
#import "SNNavigationView.h"

@interface SNThemeTableViewController : TTTableViewController <UIScrollViewDelegate>{
    NSString *currentTheme;
    SNNavigationView *_navigationView;
}
@property(nonatomic,copy) NSString *currentTheme;
@property(nonatomic, readonly) SNNavigationView *navigationView;

- (void)customTabbarStyle:(NSString *)icon activeIcon:(NSString *)activeIcon title:(NSString *)title;

- (void)customerTableBg;

- (void)customTitleView;

-(void)updateThemeIfChanged;

-(void)loadMoreSearchResult;

- (NSArray *)getSectionTitles;

@end
