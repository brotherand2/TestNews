//
//  SNRefreshTableViewController.m
//  sohunews
//
//  Created by lhp on 6/24/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNRefreshTableViewController.h"
#import "UIColor+ColorUtils.h"

@interface SNRefreshTableViewController ()

@end

@implementation SNRefreshTableViewController

@synthesize tableView = _tableView;
@synthesize headerView = _headerView;
@synthesize isLoading = _isLoading;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    self = [super initWithNavigatorURL:URL query:query];
    return self;
}

- (void)loadView {
    [super loadView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topHeight, self.view.width, self.view.height -_topHeight-_bottomHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.clipsToBounds = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_tableView];

    _tableView.backgroundColor = SNUICOLOR(kThemeBg3Color);
    self.view.backgroundColor = SNUICOLOR(kThemeBg3Color);
    
    _loadingView = [[SNEmbededActivityIndicatorEx alloc] initWithFrame:CGRectZero andDelegate:self];
    _loadingView.hidesWhenStopped = YES;
    [_loadingView setFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [self.view addSubview:_loadingView];
    
    [self addHeaderView];
}

- (void)addHeaderView
{
    _headerView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0, -_tableView.bounds.size.height-10, _tableView.width, _tableView.bounds.size.height)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
    [_headerView setCurrentDate];
    [_tableView addSubview:_headerView];
}

#pragma mark - StatusBarStyle for iOS7+
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"]) {
        return UIStatusBarStyleLightContent;
    }
    else {
        return UIStatusBarStyleDefault;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadNew{
    
}

- (void)loadMore{
    
}

- (void)refresh{
        [self loadNew];
        [self showRefreshHeaderView];
}

- (void)showRefreshHeaderView
{
    [_headerView setStatus:TTTableHeaderDragRefreshLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
    
    if (_tableView.contentOffset.y < 0) {
        _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight, 0.0f, 0.0f, 0.0f);
    }
    [UIView commitAnimations];
    
    _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight, 0.0f, 0.0f, 0.0f);
}

- (void)hideRefreshHeaderView
{
    [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    
    _tableView.contentInset = UIEdgeInsetsZero;
    if (_tableView.contentOffset.y < 0) {
        _tableView.contentOffset = CGPointZero;
    }
    [UIView commitAnimations];
    
    [_headerView setCurrentDate];
}

#pragma mark -
#pragma mark SNEmbededActivityIndicatorDelegate

- (void)didTapRetry{
    [self loadNew];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)dealloc
{
     //(_tableView);
     //(_headerView);
     //(_loadingView);
}




@end
