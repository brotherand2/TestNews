//
//  SNBaseViewController.m
//  sohunews
//
//  Created by Chen Hong on 12-9-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNBaseViewController.h"

@interface SNBaseViewController ()

@end

@implementation SNBaseViewController
@synthesize headerView=_headerView;
@synthesize toolbarView=_toolbarView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addHeaderView
{
    if (!_headerView)
    {
        _headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderTotalHeight)];
        [self.view addSubview:_headerView];
    }
}

- (void)addToolbar
{
    //_toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight)];    
    // 返回按钮
    _toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setAccessibilityLabel:@"返回"];
    [_toolbarView setLeftButton:leftButton];
    
    [self.view addSubview:_toolbarView];
}

- (void)onBack:(id)sender {
    
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewController];
    }
}

- (void)updateTheme:(NSNotification *)notifiction {
    [_headerView updateTheme];
    
    UIButton *leftButton = _toolbarView.leftButton;
    [leftButton setImage:[UIImage imageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
}

- (void)resetToolBarOrigin {
    [UIView animateWithDuration:0.25 animations:^{
        self.toolbarView.frame = CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight]);
    }];
//    self.toolbarView.origin = CGPointMake(0, kAppScreenHeight - kToolbarHeight);
}

@end
