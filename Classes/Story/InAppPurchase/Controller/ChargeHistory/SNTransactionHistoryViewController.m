//
//  SNVoucherCenterViewController.m
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNTransactionHistoryViewController.h"
#import "SNTransactionHistoryViewModel.h"
#import "SNTwinsLoadingView.h"
#import "SNTwinsMoreView.h"
#import "SNLoadingImageAnimationView.h"
#import "SNPopOverMenu.h"

@interface SNTransactionHistoryViewController ()<SNTransactionHistoryViewModelDelegate>
{
    UILabel * _statusLabel;
    UIView * _tableFootView;
    UIView *_bgView;
    UIButton *_notReachableIndicator;
}
@property (nonatomic, strong) UITableView              * tableView;
@property (nonatomic, strong) UIImageView              * nodataView;
@property (nonatomic, strong) SNHeadSelectView         * headerView;
@property (nonatomic, strong) SNToolbar                * toolbarView;
@property (nonatomic, strong) SNTransactionHistoryViewModel * viewModel;
@property (nonatomic, strong) SNTwinsLoadingView * loadingView;
@property (nonatomic, strong) SNTwinsMoreView * moreView;
@property (nonatomic, strong) SNLoadingImageAnimationView * loadingImageView;

@end

@implementation SNTransactionHistoryViewController

#pragma mark - LifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewModel];
    [self initHeader];
    [self initToolBar];
    [self initTableView];
//    [self initLoadingView];
    [self initMoreView];
    [self initLoadingImagesView];
    self.viewModel.tableView = self.tableView;
    self.viewModel.controller = self;
    [self.view bringSubviewToFront:self.tableView];
    [self.view bringSubviewToFront:_bgView];
    [self.view bringSubviewToFront:self.headerView];
    [self.view bringSubviewToFront:self.toolbarView];
    [self.viewModel loadData];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector (statusBarFrameDidChange:) name : UIApplicationDidChangeStatusBarFrameNotification object:nil];

    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [self noNetworkView];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)initLoadingImagesView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.view.frame];
        _bgView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        [self.view addSubview:_bgView];
    }
    if (!self.loadingImageView) {
        self.loadingImageView = [[SNLoadingImageAnimationView alloc] init];
        self.loadingImageView.targetView = _bgView;
    }
    self.loadingImageView.status = SNImageLoadingStatusLoading;
    _bgView.hidden = NO;
}

- (void)initLoadingView {
    CGRect loadingViewFrame = CGRectMake(0, kSystemBarHeight + kHeaderHeight, kAppScreenWidth, 44);
    self.loadingView = [[SNTwinsLoadingView alloc] initWithFrame:loadingViewFrame andObservedScrollView:self.tableView];
    [self.view addSubview:self.loadingView];
    self.loadingView.status = SNTwinsLoadingStatusPullToReload;
}

- (void)initMoreView {
    CGRect twinsMoreViewRect = CGRectMake(0, 10, kAppScreenWidth, 40);
    
    _tableFootView = [[UIView alloc] initWithFrame:twinsMoreViewRect];
    _tableFootView.backgroundColor = SNUICOLOR(kBackgroundColor);
    _tableView.tableFooterView = _tableFootView;
    
    self.moreView = [[SNTwinsMoreView alloc] initWithFrame:twinsMoreViewRect];
    self.moreView.hidden = NO;
    self.moreView.statusLabel.text = @"上拉加载更多";
    [_tableFootView addSubview:self.moreView];
}

- (void)initViewModel{
    self.viewModel = [[SNTransactionHistoryViewModel alloc] init];
}

- (void)initTableView {
    
    UIColor *color = SNUICOLOR(kBackgroundColor);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = color;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, kAppScreenWidth, kAppScreenHeight-self.headerView.height-self.toolbarView.height) style:UITableViewStylePlain];
    [self customerTableBg];
    self.tableView.delegate = self.viewModel;
    self.tableView.dataSource = self.viewModel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

}

- (void)customerTableBg {
    self.tableView.backgroundView = nil;
    UIColor *color = SNUICOLOR(kBackgroundColor);
    self.tableView.backgroundColor = [UIColor clearColor];
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
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"Transaction history",@"")]];
    CGSize titleSize = [NSLocalizedString(@"Transaction history",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
}

- (void)initToolBar{
    self.toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.accessibilityLabel = @"返回";
    [_toolbarView setLeftButton:leftButton];
    [self.view addSubview:_toolbarView];
    
    NSString *imageName = @"icotext_more_v5.png";
    NSString *pressImageName = @"icotext_morepress_v5.png";
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [button setImage:[UIImage themeImageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage themeImageNamed:pressImageName] forState:UIControlStateHighlighted];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarView setRightButton:button];
}

- (void)more:(id)sender {
    UIButton *button = (UIButton *)sender;
    [SNPopOverMenu showForSender:button
                     senderFrame:button.frame
                        withMenu:@[@"刷新"]
                  imageNameArray:@[@"icowebview_refresh.png"]
                       doneBlock:^(NSInteger selectedIndex) {
                           [self.viewModel loadData];
                       } dismissBlock:^{
                       }];
}

- (void)statusBarFrameDidChange:(NSNotification *)notification {
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    if (statusBarRect.size.height == 40) {
        //开启了热点
        self.toolbarView.bottom = self.view.height - 20;
    }else{
        self.toolbarView.bottom = self.view.height;
    }
}

- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)updateTheme {
    [_headerView updateTheme];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [_toolbarView.rightButton setImage:[UIImage themeImageNamed:@"icotext_more_v5.png"] forState:UIControlStateNormal];
    [_toolbarView.rightButton setImage:[UIImage themeImageNamed:@"icotext_morepress_v5.png"] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)noNetworkView {
    _loadingImageView.status = SNImageLoadingStatusStopped;
    UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeC];
    NSString *labelColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
    UIColor *fontColor = [UIColor colorFromString:labelColorString];
    CGFloat indicatorWidth = floorf(415/2.0f);
    CGFloat indicatorHeight = floorf(150/2.0f);
    CGFloat indicatorLeft = (self.view.frame.size.width-indicatorWidth)/2.0f;
    CGFloat indicatorTop = (self.view.frame.size.height-indicatorHeight)/2.0f;
    
    UIImage *image = [UIImage imageNamed:@"sohu_loading_1.png"];
    _notReachableIndicator = [UIButton buttonWithType:UIButtonTypeCustom];
    _notReachableIndicator.frame = CGRectMake(indicatorLeft, indicatorTop, indicatorWidth, indicatorHeight);
    [_notReachableIndicator setImage:image forState:UIControlStateNormal];
    [_notReachableIndicator setTitle:@"点击屏幕 重新加载" forState:UIControlStateNormal];
    [_notReachableIndicator.titleLabel setFont:font];
    [_notReachableIndicator setTitleColor:fontColor forState:UIControlStateNormal];
    [_notReachableIndicator addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    _notReachableIndicator.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _notReachableIndicator.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    CGSize size = _notReachableIndicator.frame.size;
    CGFloat imgViewEdgeInsetLeft = (size.width - image.size.width)/2;
    CGFloat imgViewEdgeInsetTop = _notReachableIndicator.imageView.top;
    CGFloat titleLabelEdgeInsetLeft = (size.width - _notReachableIndicator.titleLabel.size.width)/2 - image.size.width - 50;
    CGFloat titleLabelEdgeInsetTop  = imgViewEdgeInsetTop + image.size.height + 12;
    UIEdgeInsets imgViewEdgeInsets = UIEdgeInsetsMake(0, imgViewEdgeInsetLeft, 0, 0);
    UIEdgeInsets titleLabelEdgeInsets = UIEdgeInsetsMake(titleLabelEdgeInsetTop, titleLabelEdgeInsetLeft, 0, 0);
    [_notReachableIndicator setImageEdgeInsets:imgViewEdgeInsets];
    [_notReachableIndicator setTitleEdgeInsets:titleLabelEdgeInsets];
    
    [self.view addSubview:_notReachableIndicator];
    [self.view bringSubviewToFront:_notReachableIndicator];
}

- (void)retry {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        return;
    }
    [_notReachableIndicator removeFromSuperview];
    _notReachableIndicator = nil;
    [self.viewModel loadData];
    self.loadingImageView.status = SNImageLoadingStatusLoading;
}


#pragma mark - SNTransactionHistoryViewModelDelegate
- (void)willRefresh {
    _loadingView.status = SNTwinsLoadingStatusPullToReload;
}

- (void)shouldRefresh {
    _loadingView.status = SNTwinsLoadingStatusReleaseToReload;
}

- (void)didRefresh{
    _loadingView.status = SNTwinsLoadingStatusLoading;
}

- (void)refreshFinished{
    self.loadingImageView.status = SNImageLoadingStatusStopped;
    _bgView.hidden = YES;
    [_notReachableIndicator removeFromSuperview];
    _notReachableIndicator = nil;

    if (self.viewModel.dataArr.count == 0) {
        //没数据
        if (!self.nodataView) {
            self.nodataView = [[UIImageView alloc] initWithFrame:TTScreenBounds()];
            self.nodataView.backgroundColor = SNUICOLOR(kBackgroundColor);
            UIImageView * imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 323/2.f, 314/2.f)];
            imageview.image = [UIImage themeImageNamed:@"icofiction_nodata_v5.png"];
            imageview.centerX = self.view.width/2.f;
            imageview.centerY = self.view.height/3.f;
            [self.nodataView addSubview:imageview];
            [self.tableView addSubview:self.nodataView];
        }
    }else{
        [self.nodataView removeFromSuperview];
        self.nodataView = nil;
    }
    _loadingView.status = SNTwinsLoadingStatusPullToReload;
    [_loadingView setUpdateDate:[NSDate date]];
}

- (void)willLoadMore{
    _moreView.hidden = NO;
    _statusLabel.text = @"上拉加载更多";
}

- (void)didLoadMore{
    _moreView.status = SNTwinsMoreStatusLoading;
    _statusLabel.text = @"正在加载...";
}

- (void)loadMoreFinished{
    _moreView.status = SNTwinsMoreStatusStop;
    _statusLabel.text = @"加载完毕";
}

- (void)allDidLoad {
    _moreView.status = SNTwinsMoreStatusStop;
    _statusLabel.text = @"已加载全部";
}

- (void)dealloc {
    [self.loadingView removeObserver];
    [SNNotificationManager removeObserver:self];
    _loadingView.status = SNTwinsLoadingStatusNil;
    [_loadingView removeFromSuperview];
    _moreView.status = SNTwinsMoreStatusStop;
    [_moreView removeFromSuperview];
}
@end
