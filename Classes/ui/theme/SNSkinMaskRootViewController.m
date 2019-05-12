//
//  SNSkinMaskRootViewController.m
//  sohunews
//
//  Created by Gao Yongyue on 14-5-12.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSkinMaskRootViewController.h"

@interface SNSkinMaskRootViewController ()

@end

@implementation SNSkinMaskRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.alpha = 0.f;
    // Do any additional setup after loading the view.
}


- (void)setLightContentMode:(BOOL)lightContentMode
{
    _lightContentMode = lightContentMode;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setHideStatusbar:(BOOL)hideStatusbar
{
    _hideStatusbar = hideStatusbar;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return _hideStatusbar;
}

//Only works for iOS7 and greater.
- (UIViewController *)childViewControllerForStatusBarStyle {
    return nil;
}

//Only works for iOS7 and greater.
- (UIStatusBarStyle)preferredStatusBarStyle {
    return _lightContentMode ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
