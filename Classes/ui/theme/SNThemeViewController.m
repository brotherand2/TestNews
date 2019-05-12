//
//  SNThemeViewController.m
//  sohunews
//
//  Created by qi pei on 5/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNThemeViewController.h"
#import "SNTabBarItem.h"
#import "UIColor+ColorUtils.h"

@interface SNThemeViewController()
{
    NSString *_statusbarStyle;
}
@end
@implementation SNThemeViewController
@synthesize currentTheme;
@synthesize navigationView = _navigationView;
@synthesize tabbarSnapView = _tabbarSnapView;
@synthesize queryDic = _queryDic;
@synthesize newsfrom = _newsfrom;
@synthesize isPush = _isPush;

- (SNNavigationView *)navigationView {

    return _navigationView;
}

-(void)updateTheme:(NSNotification *)notifiction {
    SNDebugLog(@"implements updateTheme in subclass");
}

- (void)updateNonePicMode:(NSNotification *)notifiction {
    SNDebugLog(@"implements updateNonePicMode in subclass");
}

- (void)viewControllerWillResignActive {

}
- (BOOL)isLiveGameShowing:(NSString*)aLiveId {
    return NO;
}
- (void)refreshTableViewDataWhenAppBecomeActive {

}
- (void)loadView
{
    [SNNotificationManager addObserver:self
                                             selector:@selector(updateTheme:)
                                                 name:kThemeDidChangeNotification
                                               object:nil];
    
    [SNNotificationManager addObserver:self 
                                             selector:@selector(updateNonePicMode:) 
                                                 name:kNonePictureModeChangeNotification 
                                               object:nil];
    [SNNotificationManager addObserver:self selector:@selector(updateStatusbarStyle:) name:kStatusBarStyleChangedNotification object:nil];

    [super loadView];
    self.currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

- (void)viewDidUnload
{
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
    [SNNotificationManager removeObserver:self name:kNonePictureModeChangeNotification object:nil];
     [SNNotificationManager removeObserver:self name:kStatusBarStyleChangedNotification object:nil];
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

- (void)updateStatusbarStyle:(NSNotification *)note
{
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if (![themeManager.currentTheme isEqualToString:@"night"])
    {
        _statusbarStyle = [note object][@"style"];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}
//Only works for iOS7 and greater.
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

//Only works for iOS7 and greater.
- (UIStatusBarStyle)preferredStatusBarStyle {
//    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
//    if ([themeManager.currentTheme isEqualToString:@"night"]) {
//        return UIStatusBarStyleLightContent;
//    }
//    else {
//        return UIStatusBarStyleDefault;
//    }
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"])
    {
        return UIStatusBarStyleLightContent;
    }
    else
    {
        if (_statusbarStyle && [_statusbarStyle isEqualToString:@"lightContent"])
        {
            return UIStatusBarStyleLightContent;
        }
        else
        {
            return UIStatusBarStyleDefault;
        }
    }
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
    [SNNotificationManager removeObserver:self name:kNonePictureModeChangeNotification object:nil];
    [SNNotificationManager removeObserver:self name:kStatusBarStyleChangedNotification object:nil];
     //(currentTheme);
     //(_navigationView);
     //(_tabbarSnapView);
     //(_queryDic);
     //(_newsfrom);
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

-(void)updateThemeIfChanged {
    if (![self.currentTheme isEqualToString:[[SNThemeManager sharedThemeManager] currentTheme]]) {
        [self updateTheme:nil];
        self.currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    }
}

@end
