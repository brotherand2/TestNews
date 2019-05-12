//
//  SNWeiboSettingController.m
//  sohunews
//
//  Created by 李 雪 on 11-6-30.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNWeiboSettingController.h"
#import "SNWeiboSettingDelegate.h"
#import "SNWeiboSettingDataSource.h"
#import "SNWeiboSettingModel.h"
#import "SNWeiboSettingItem.h"
#import "SNNotificationCenter.h"
#import "UIColor+ColorUtils.h"


@implementation SNWeiboSettingController

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.hidesBottomBarWhenPushed = YES;
    }
	
    return self;
}


- (void)createModel {
	SNWeiboSettingDataSource *dataSource = [[SNWeiboSettingDataSource alloc] init];
	((SNWeiboSettingModel *)dataSource.weiboSettingModel).controller = self;
	self.dataSource = dataSource;
}

- (id/*<TTTableViewDelegate>*/)createDelegate {
	SNWeiboSettingDelegate *delegate = [[SNWeiboSettingDelegate alloc] initWithController:self];
	delegate.model = ((SNWeiboSettingDataSource *)(self.dataSource)).weiboSettingModel;
	return delegate;
}

#pragma mark - SNShareManagerDelegate
- (void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController {
    [self presentViewController:authNaviController animated:YES completion:nil];
}

- (void)shareManagerDidAuthSuccess:(SNShareManager *)manager {
    [self reload];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"绑定成功" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManagerDidCancelBindingSuccess:(SNShareManager *)manager {
    [self reload];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:kRelieveSinaSucceed toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManagerDidCancelBindingFail:(SNShareManager *)manager {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法解除绑定" toUrl:nil mode:SNCenterToastModeWarning];
}

- (void)shareManagerDidCancelAuth:(SNShareManager *)manager {
    
}

- (void)shareManager:(SNShareManager *)manager didAuthFailedWithError:(NSError *) error {
    [SNNotificationCenter showExclamation:@"暂无法绑定"];
}

- (void)showDefaultLoading:(BOOL)bLoading {
    if (bLoading) {
        _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
    }
    else {
        _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
    }
}

- (void)refreshShareList {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        _loadView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
        return;
    }
    [self showDefaultLoading:YES];
    [SNShareList shareInstance].delegate = self;
    [[SNShareList shareInstance] refreshShareListForce];
}

- (void)loadView{
    [super loadView];
    [self customerTableBg];
    
    loadEmptyView = [[UIView alloc] initWithFrame:self.tableView.frame];
    loadEmptyView.backgroundColor = [UIColor clearColor];
    loadEmptyView.hidden = YES;
    [self.view addSubview:loadEmptyView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshShareList)];
    [loadEmptyView addGestureRecognizer:tapGesture];
    [self.view addSubview:loadEmptyView];
    
    NSString *fileName = @"app_logo.png";
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
    imageView.center = CGPointMake(loadEmptyView.center.x, loadEmptyView.center.y - 70);
    [loadEmptyView addSubview:imageView];
    
    UILabel *infolabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height, loadEmptyView.frame.size.width, 50)];
	[infolabel setTextAlignment:NSTextAlignmentCenter];
	[infolabel setTextColor:[UIColor lightGrayColor]];
	[infolabel setFont:[UIFont systemFontOfSize:18]];
	[infolabel setBackgroundColor:[UIColor clearColor]];
    infolabel.text = NSLocalizedString(@"LoadFailRefresh", @"分享列表加载失败，点击屏幕刷新");
    [loadEmptyView addSubview:infolabel];
    
    
    
    [self addHeaderView];
    [self addToolbar];
    
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"shareSetting",@"")]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect screenFrame = TTApplicationFrame();
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.frame = CGRectMake(0, kHeaderTotalHeight-kHeadBottomHeight, screenFrame.size.width, screenFrame.size.height - kHeaderTotalHeight - bg.size.height + 15);
    
    if ([[[SNShareManager defaultManager] shareList] count] <= 0) {
    }
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry
{
    [self refreshShareList];
}


#pragma mark - SNShareListDelegate
- (void)refreshShareListSucc {
    [self showDefaultLoading:NO];
    SNDebugLog(@"share list %@",[[SNShareManager defaultManager] shareList]);
    [self.model load:TTURLRequestCachePolicyDefault more:NO];
}

- (void)refreshShareListFail {
    [self showDefaultLoading:NO];
    loadEmptyView.hidden = YES;
}

- (void)refreshShareListGetNoData {
    [self showDefaultLoading:NO];
    loadEmptyView.hidden = YES;
}
@end
