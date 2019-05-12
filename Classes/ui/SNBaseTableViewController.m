//
//  SNBaseTableViewController.m
//  sohunews
//
//  Created by Chen Hong on 12-9-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNBaseTableViewController.h"

@interface SNBaseTableViewController ()

@end

@implementation SNBaseTableViewController

@synthesize headerView  = _headerView;
@synthesize toolbarView = _toolbarView;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addHeaderView {
    _headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderTotalHeight)];
    [self.view addSubview:_headerView];
}

- (void)addToolbar {
    _toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    
    //@Dan: tell what to read for blind people
    leftButton.accessibilityLabel = @"返回";
    
    [_toolbarView setLeftButton:leftButton];
    
    [self.view addSubview:_toolbarView];
}

- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)updateTheme {
    [_headerView updateTheme];
    
//    UIImage *bg = [UIImage themeImageNamed:@"postTab0.png"];
//    [_toolbarView setBackgroundImage:bg];
    
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
}

@end
