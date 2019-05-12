//
//  SNVoucherCenterViewController.m
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRechargeHelpViewController.h"
#import "SNRechargeHelpViewModel.h"

@interface SNRechargeHelpViewController ()

@property (nonatomic, strong) UITableView              * tableView;
@property (nonatomic, strong) SNHeadSelectView         * headerView;
@property (nonatomic, strong) SNToolbar                * toolbarView;
@property (nonatomic, strong) SNRechargeHelpViewModel * viewModel;

@end

@implementation SNRechargeHelpViewController

#pragma mark - LifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewModel];
    [self initHeader];
    [self initToolBar];
    [self initTableView];
}

- (void)initViewModel{
    self.viewModel = [[SNRechargeHelpViewModel alloc] init];
}

- (void)initTableView {
    UIColor *color = SNUICOLOR(kBackgroundColor);
    self.tableView.backgroundColor = color;
    self.view.backgroundColor = color;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, kAppScreenWidth, kAppScreenHeight-self.headerView.height-self.toolbarView.height) style:UITableViewStylePlain];
    [self customerTableBg];
    self.tableView.delegate = self.viewModel;
    self.tableView.dataSource = self.viewModel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0, kToolbarHeightWithoutShadow, 0);
//    self.tableView.contentOffset = CGPointMake(0, -kHeaderHeightWithoutBottom);
    [self.view addSubview:self.tableView];
}

- (void)customerTableBg {
    UIColor *color = SNUICOLOR(kBackgroundColor);
    self.tableView.backgroundColor = color;
    self.view.backgroundColor = color;
}

- (void)initHeader{
    self.headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderTotalHeight)];
    [self.view addSubview:_headerView];
    /*
     //充值
     "Voucher center"            = "充值"
     "Recharge help"             = "充值帮助"
     "Transaction history"       ="充值记录";
     */
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"Recharge help",@"")]];
    CGSize titleSize = [NSLocalizedString(@"Recharge help",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    
}

- (void)initToolBar{
    self.toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight)];
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.accessibilityLabel = @"返回";
    [_toolbarView setLeftButton:leftButton];
    
    [self.view addSubview:_toolbarView];
}

- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)updateTheme {
    [_headerView updateTheme];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
