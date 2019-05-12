//
//  SNThemeViewController.m
//  sohunews
//
//  Created by qi pei on 5/8/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNThemeTableViewController.h"
#import "SNTabBarItem.h"
#import "UIColor+ColorUtils.h"


@implementation SNThemeTableViewController
@synthesize currentTheme;
@synthesize navigationView = _navigationView;

- (SNNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [SNNavigationView defautlNavigationView];
        _navigationView.hidden = YES;
        [self.view addSubview:_navigationView];
    }
    return _navigationView;
}

-(void)updateTheme:(NSNotification *)notifiction {
    SNDebugLog(@"implements updateTheme in subclass");
}

- (void)updateNonePicMode:(NSNotification *)notifiction {
    SNDebugLog(@"implements updateNonePicMode in subclass");
}

- (void)loadView
{
    [super loadView];
    [SNNotificationManager addObserver:self 
                                             selector:@selector(updateTheme:) 
                                                 name:kThemeDidChangeNotification 
                                               object:nil];
    
    [SNNotificationManager addObserver:self 
                                             selector:@selector(updateNonePicMode:) 
                                                 name:kNonePictureModeChangeNotification 
                                               object:nil];
    self.currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
}

- (void)viewDidUnload
{
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
    [SNNotificationManager removeObserver:self name:kNonePictureModeChangeNotification object:nil];
     //(_navigationView);
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_navigationView) {
        [self.view bringSubviewToFront:_navigationView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

//Only works for iOS7 and greater.
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

//Only works for iOS7 and greater.
- (UIStatusBarStyle)preferredStatusBarStyle {
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"]) {
        return UIStatusBarStyleLightContent;
    }
    else {
        return UIStatusBarStyleDefault;
    }
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
    [SNNotificationManager removeObserver:self name:kNonePictureModeChangeNotification object:nil];
     //(currentTheme);
     //(_navigationView);
}

-(void)customerTableBg {
    //update by linan4
    self.tableView.backgroundView = nil;
//    self.tableView.backgroundColor = [UIColor clearColor];//[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    UIColor *color = SNUICOLOR(kBackgroundColor);
    self.tableView.backgroundColor = color;
    self.view.backgroundColor = color;
}

-(void)customTitleView {

    UIImage *_titleImage = [UIImage imageNamed:@"publication_title.png"];
    UIImageView *_titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _titleImage.size.width, _titleImage.size.height)];
    [_titleView setImage:_titleImage];
    //    self.navigationItem.titleView = _titleView;
    self.navigationView.titleView = _titleView;
}

-(void)customTabbarStyle:(NSString *)icon activeIcon:(NSString *)activeIcon title:(NSString *)title {

    UIColor *normalColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTabbarNormalTextColor]];
    UIColor *selectedColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTabbarSelectedTextColor]];
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        SNTabBarItem *tabItem = [[SNTabBarItem alloc] initWithTitle:title image:nil tag:0];  
        UIImage* image = [UIImage imageNamed:icon];
        UIImage* imageActive = [UIImage imageNamed:activeIcon]; 
        tabItem.cSelectedImage=imageActive;  
        tabItem.cUnselectedImage=image; 
        self.tabBarItem=tabItem;
         //(tabItem); 
    } else {
        UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:title image:nil tag:0];
        self.tabBarItem = tabItem;
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:activeIcon] withFinishedUnselectedImage:[UIImage imageNamed:icon]];
        [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 selectedColor, UITextAttributeTextColor,
                                                 nil] forState:UIControlStateSelected];
        [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 normalColor, UITextAttributeTextColor,
                                                 nil] forState:UIControlStateNormal];
         //(tabItem); 
    }
}

-(void)updateThemeIfChanged {
    if (![self.currentTheme isEqualToString:[[SNThemeManager sharedThemeManager] currentTheme]]) {
        [self updateTheme:nil];
        self.currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    }
}

-(void)loadMoreSearchResult {
    //搜索加载更多
}


- (NSArray *)getSectionTitles {
    //获取搜索sectiontitles
    return nil;
}

@end
