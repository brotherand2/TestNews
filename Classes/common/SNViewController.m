//
//  SNViewController.m
//  sohunews
//
//  Created by 郭亚伦 on 10/17/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNViewController.h"

@interface SNViewController ()

@end

@implementation SNViewController

- (id)init
{
    if (self = [super init])
    {
        [SNNotificationManager addObserver:self selector:@selector(updateStatusbarStyle:) name:kStatusBarStyleChangedNotification object:nil];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self name:kStatusBarStyleChangedNotification object:nil];
}

- (void)updateStatusbarStyle:(NSNotification *)note
{
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if (![themeManager.currentTheme isEqualToString:@"night"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[note object][@"style"] forKey:@"statusbarStyle"];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

//Only works for iOS7 and greater.
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

//Only works for iOS7 and greater.
- (UIStatusBarStyle)preferredStatusBarStyle {
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"])
    {
        return UIStatusBarStyleLightContent;
    }
    else
    {
        NSString *statusbarStyle = [[NSUserDefaults standardUserDefaults] objectForKey:@"statusbarStyle"];
        if (statusbarStyle && [statusbarStyle isEqualToString:@"lightContent"])
        {
            return UIStatusBarStyleLightContent;
        }
        else
        {
            return UIStatusBarStyleDefault;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
