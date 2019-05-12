//
//  SNSohuHaoViewController.m
//  sohunews
//
//  Created by HuangZhen on 2017/6/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSohuHaoViewController.h"
#import "SNMyConcernViewController.h"
#import "SNSegmentControl.h"
#import "SNUnFollowingListView.h"

@interface SNSohuHaoViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) SNHeadSelectView         * headerView;
@property (nonatomic, strong) SNToolbar                * toolbarView;
@property (nonatomic, strong) SNSegmentControl         * segmentControl;
@property (nonatomic, strong) UIScrollView             * scrollView;

@property (nonatomic, strong)  SNMyConcernViewController    * followingListController;
@property (nonatomic, strong)  SNUnFollowingListView        * unfollowingListView;

@end

@implementation SNSohuHaoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.followingListController viewWillAppear:animated];
    [self.unfollowingListView viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=public&_tp=pv"]];
    if (_scrollView.contentOffset.x == 0) {
        [self reportTabPVWithIndex:0];
    }else if (_scrollView.contentOffset.x == (_segmentControl.tabsCount - 1) * _scrollView.width) {
        [self reportTabPVWithIndex:1];
    }
    [self.followingListController viewDidAppear:animated];
    [self.unfollowingListView viewDidAppear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeader];
    [self initToolBar];
    [self initSegment];
    [self initScrollView];
    [self.segmentControl setScrollView:self.scrollView];
    [self.view bringSubviewToFront:self.headerView.shadowImageView];
    [self initScrollContent];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector (statusBarFrameDidChange:) name : UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)statusBarFrameDidChange:(NSNotification *)notification {
    //self.toolbarView.top =  kAppScreenHeight - kToolbarHeight;
    self.toolbarView.top =  kAppScreenHeight - [SNToolbar toolbarHeight];
    [self.view bringSubviewToFront:self.toolbarView];
}

- (void)initHeader{
    self.headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderTotalHeight)];
    [self.view addSubview:_headerView];
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"Sohu Hao",@"")]];
    CGSize titleSize = [NSLocalizedString(@"Sohu Hao",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
}

- (void)initToolBar{
    //self.toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight)];
    // 返回按钮
    self.toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    self.toolbarView.origin = CGPointMake(self.toolbarView.origin.x, self.toolbarView.origin.y + 1);
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.accessibilityLabel = @"返回";
    [self.toolbarView setLeftButton:leftButton];
    [self.view addSubview:_toolbarView];
}

- (void)initSegment {
    self.segmentControl = [[SNSegmentControl alloc] initWithFrame:CGRectMake(0, self.headerView.bottom + 1, self.view.width, 76/2.f)];
    [self.segmentControl setTabs:@[@"已关注",@"推荐"]];
    [self.view addSubview:self.segmentControl];
}

- (void)initScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.segmentControl.bottom, self.view.width, self.view.height - self.headerView.height - self.segmentControl.height - self.toolbarView.height)];
    self.scrollView.backgroundColor = self.view.backgroundColor;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void)initScrollContent {
    self.followingListController = [[SNMyConcernViewController alloc] init];
    
    CGFloat originY = 64;
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        originY = 80;
    }
    self.followingListController.view.frame = CGRectMake(0, -originY, _scrollView.width, _scrollView.height + originY);

    [self.scrollView addSubview:_followingListController.view];
    self.followingListController.superController = self;
    
    self.unfollowingListView = [[SNUnFollowingListView alloc] initWithFrame:CGRectMake(_scrollView.width, 0, _scrollView.width, _scrollView.height)];
    self.unfollowingListView.superController = self;
    [self.scrollView addSubview:self.unfollowingListView];
}

- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)switchTab:(NSInteger)index {
    [self.scrollView setContentOffset:CGPointMake(index * _scrollView.width, 0) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.segmentControl removeListener];
    [SNNotificationManager removeObserver:self];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0) {
        [self reportTabPVWithIndex:0];
        [self reportTabClkWithIndex:0];
        [self refreshUnFollowingList];
    }else if (scrollView.contentOffset.x == (_segmentControl.tabsCount - 1) * scrollView.width) {
        [self reportTabPVWithIndex:1];
        [self reportTabClkWithIndex:1];
        [_unfollowingListView viewScrollDidShow];
    }
}

#pragma mark - SNFollowEventDelegate
- (void)mySubscribeListUnFollowEvent {
    [self refreshUnFollowingList];
}

- (void)refreshFollowingList {
    [_followingListController refreshWithNoAnimation];
}

- (void)refreshUnFollowingList {
    [_unfollowingListView refreshCurrentTab];
}

#pragma mark - 埋点
/// 埋点上报
- (void)reportTabClkWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            ///已关注tab pvuv
            NSString *paramStr = [NSString stringWithFormat:@"_act=focus_tab&_tp=clk"];
            [SNNewsReport reportADotGif:paramStr];
            break;
        }
        case 1:
        {
            ///推荐tab pvuv
            NSString *paramStr = [NSString stringWithFormat:@"_act=recom_tab&_tp=clk"];
            [SNNewsReport reportADotGif:paramStr];
            break;
        }
        default:
            break;
    }
}

- (void)reportTabPVWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=focus_page&_tp=pv"]];
            break;
        }
        case 1:
        {
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=recom_page&_tp=pv"]];
            break;
        }
        default:
            break;
    }
}
- (BOOL)recognizeSimultaneouslyWithGestureRecognizer {
    if (_scrollView.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}

@end
