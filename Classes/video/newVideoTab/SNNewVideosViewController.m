//
//  SNNewVideosViewController.m
//  sohunews
//
//  Created by tt on 15/12/11.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNNewVideosViewController.h"
#import "SHVideoForNewsSDK.h"
#import "SVChannelsViewController.h"
#import <UIKit/UIKit.h>
#import "DKNightVersionManager.h"

@interface SNNewVideosViewController ()

@end

@implementation SNNewVideosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        [DKNightVersionManager nightFalling];
    }else{
        [DKNightVersionManager dawnComing];
    }
//    SVChannelsViewController *vc = [SHVideoForNewsSDK channelViewControllerForNews];
//    UINavigationController *root = [[UINavigationController alloc] initWithRootViewController:vc];
//    [self.view addSubview:root.view];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = [UIColor blackColor];
    button.frame = CGRectMake(50, 50, 100, 100);
    [button addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)test{
    
    
    
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:method,@"method", nil];
//    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:dic];
//    [[TTNavigator navigator] openURLAction:_urlAction];
//#pragma clang diagnostic pop
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - tabbar icon

- (NSArray *)iconNames {
    return [NSArray arrayWithObjects:@"icotab_video_v5.png", @"icotab_videopress_v5.png", nil];
}

- (NSString *)tabItemText {
    if ([SNUtility getTabBarName:1]) {
        return [SNUtility getTabBarName:1];
    }
    return NSLocalizedString(@"videoTabbarName", nil);
}

//- (void)showTabbarView {
//    if (_bLockTabbarView) {
//        return;
//    }
//    SNTabbarView *tabView = self.tabbarView;
//    [tabView removeFromSuperview];
//    tabView.top = self.view.height - tabView.height;
//    [self.view addSubview:tabView];
//    self.tabbarSnapView = tabView;
//    [self setTabbarViewLocked:YES];
//}
//
//- (void)setTabbarViewVisible:(BOOL)bVisible {
//    if (!bVisible) self.tabbarSnapView = nil;
//}
//
//- (void)setTabbarViewLocked:(BOOL)bLocked {
//    _bLockTabbarView = bLocked;
//}

@end
