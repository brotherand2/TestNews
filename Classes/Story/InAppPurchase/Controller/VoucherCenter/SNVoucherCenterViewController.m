//
//  SNVoucherCenterViewController.m
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNVoucherCenterViewController.h"
#import "SNVoucherCenterViewModel.h"
#import "SNVoucherCenter.h"
#import "SNUtility.h"

#define kProductViewWidth           (103.f)
#define kProductViewHeight          (61.5)
#define kCountInRow                 (3)

@interface SNVoucherCenterViewController (){
    UIButton * _notReachableIndicator;
    UIView * _notReachBgView;
}

@property (nonatomic, strong) UICollectionViewFlowLayout * layout;
@property (nonatomic, strong) SNHeadSelectView         * headerView;
@property (nonatomic, strong) SNToolbar                * toolbarView;
@property (nonatomic, strong) SNVoucherCenterViewModel * viewModel;
@property (nonatomic, strong) UIButton * historyListBtn;
@property (nonatomic, strong) UIView * tableHeader;
@property (nonatomic, strong) UIView * tableFooter;

@end

@implementation SNVoucherCenterViewController

#pragma mark - LifeCircle

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self statusBarFrameDidChange:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self initViewModel];
    [self initHeader];
    [self initToolBar];
    [self initTableView];
    [self loadData];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector (statusBarFrameDidChange:) name : UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)loadData {
    //进入充值页面 刷新金币余额
    [SNVoucherCenter refreshBalance];
    //获取充值礼包产品
    [SNVoucherCenter getProductsCompleted:^(BOOL successed, NSArray *responseArray) {
        if (responseArray.count > 0) {
            self.viewModel.products = responseArray;
            [self.collectionView reloadData];
            [_notReachableIndicator removeFromSuperview];
            _notReachableIndicator = nil;
            [_notReachBgView removeFromSuperview];
            _notReachBgView = nil;
        }
        else{
            [self noNetworkView];
        }
    }];
}

- (void)statusBarFrameDidChange:(NSNotification *)notification {
    
    self.toolbarView.top =  kAppScreenHeight - [SNToolbar toolbarHeight];
    [self.view bringSubviewToFront:self.toolbarView];
}

- (void)initViewModel{
    self.viewModel = [[SNVoucherCenterViewModel alloc] init];
    self.viewModel.controller = self;
}

- (void)setupLayout {
    CGFloat space = 14.f;
    CGFloat itemWidth = (kAppScreenWidth - space * (kCountInRow + 1))/kCountInRow;
    if (itemWidth > kProductViewWidth) {
        itemWidth = kProductViewWidth;
    }
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(space, space, space, space);
    layout.minimumLineSpacing = space;
    layout.minimumInteritemSpacing = space;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(itemWidth, kProductViewHeight);
    layout.headerReferenceSize = CGSizeMake(kAppScreenWidth, 50);
    layout.footerReferenceSize = CGSizeMake(kAppScreenWidth, 250);
    self.layout = layout;
}

- (void)initTableView {
    UIColor *color = SNUICOLOR(kBackgroundColor);
    CGRect rect = CGRectMake(0, self.headerView.bottom, kAppScreenWidth, kAppScreenHeight-self.headerView.height-self.toolbarView.height);
    self.view.backgroundColor = color;
    [self customerTableBg];

    [self setupLayout];
    self.collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = color;
    self.collectionView.delegate = self.viewModel;
    self.collectionView.dataSource = self.viewModel;
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    [self.viewModel registAllCell];
}

- (void)customerTableBg {
    UIColor *color = SNUICOLOR(kBackgroundColor);
    self.collectionView.backgroundColor = color;
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
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"Voucher center",@"")]];
    CGSize titleSize = [NSLocalizedString(@"Voucher center",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    
    self.historyListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.historyListBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [self.historyListBtn setTitle:NSLocalizedString(@"Transaction history",@"") forState:UIControlStateNormal];
    [self.historyListBtn setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    [self.historyListBtn addTarget:self action:@selector(showTransactionList) forControlEvents:UIControlEventTouchUpInside];
    
    float historyListBtnHeight = kHeaderTotalHeight - 20;
    if ([[SNDevice sharedInstance] isPhoneX]) {
        historyListBtnHeight = kHeaderTotalHeight - 20 - 24;
    }
    self.historyListBtn.frame = CGRectMake(0, 0, 80, historyListBtnHeight);
    self.historyListBtn.right = kAppScreenWidth;
    self.historyListBtn.bottom = kHeaderTotalHeight;
    [self.headerView addSubview:self.historyListBtn];
    
}

- (void)showTransactionList{
    [SNUtility shouldUseSpreadAnimation:NO];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://transactionHistory"] applyAnimated:YES] applyQuery:nil];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)initToolBar{
    
    self.toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.accessibilityLabel = @"返回";
    [self.toolbarView setLeftButton:leftButton];
    [self.view addSubview:_toolbarView];
}

- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)rechargeDidFinished:(BOOL)successed {
    if (successed) {
        [self onBack:nil];
    }
}

- (void)updateTheme {
    [_headerView updateTheme];
    [_historyListBtn setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)noNetworkView {

    if (!_notReachableIndicator) {
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
    }

    if (!_notReachBgView) {
        _notReachBgView = [[UIView alloc] initWithFrame:self.view.bounds];
        _notReachBgView.backgroundColor = self.view.backgroundColor;
    }
    [_notReachBgView addSubview:_notReachableIndicator];
    [self.view addSubview:_notReachBgView];
    [self.view bringSubviewToFront:_notReachBgView];
}

- (void)retry {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    [self loadData];
}

@end
