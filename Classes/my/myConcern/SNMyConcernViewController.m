//
//  SNMyConcernViewController.m
//  sohunews
//
//  Created by 赵青 on 16/8/29.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNMyConcernViewController.h"
#import "SNSubscribeNewsModel.h"
#import "SNRollingNewsSubscribeDataSource.h"
#import "SNSubscribeNewsTableViewDelegate.h"
#import "SNNewsDataSourceFactory.h"
#import "SNTripletsLoadingView.h"

@implementation SNMyConcernViewController
{
    SNTripletsLoadingView *_tripletsLoadingView;
    UIView *_emptyBgView;
    UIButton *_emptyButton;
    UIImageView *_emptyImageView;
    UILabel *_emptyLabel;
}

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    if (self = [super initWithNavigatorURL:URL query:query])
    {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)loadView
{
    [super loadView];
    
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height + 44);
    UIEdgeInsets r = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, 0.f, 0.f);
    self.tableView.contentInset = r;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kHeadSelectViewHeight, 0.f, kToolbarViewHeight, 0.f);
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, kToolbarViewHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = bottomView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[TTNavigator navigator].topViewController isKindOfClass:NSClassFromString(@"SNSProfileViewController")]) {
        [self localRefresh];
    }
}

- (void)showModel:(BOOL)show{
    [super showModel:show];
}

- (void)createModel{
    [self createDelegate];
    
    SNRollingNewsSubscribeDataSource *ds = [[SNRollingNewsSubscribeDataSource alloc] initWithChannelId:@""];
    
    if (ds) {
        ds.myConcernController = self;
        [_dragDelegate setModel:ds.newsModel];
        ((SNSubscribeNewsModel *)ds.model).followEvetnDelegate = self.superController;
        self.dataSource = ds;
    }
}

- (void)reCreateModel
{
    [self createModel];
}

- (BOOL)canShowModel
{
    SNRollingNewsSubscribeDataSource *ds = (SNRollingNewsSubscribeDataSource *)self.dataSource;
    return ![ds isModelEmpty];
}

- (BOOL)shouldLoad
{
    SNRollingNewsSubscribeDataSource *ds = (SNRollingNewsSubscribeDataSource *)self.dataSource;
    return [ds isModelEmpty];
}

-(id<UITableViewDelegate>)createDelegate
{
    _dragDelegate = [[SNSubscribeNewsTableViewDelegate alloc] initWithController:self headView:nil];
    _dragDelegate.enablePreload = NO;
    
    [_dragDelegate setDragLoadingViewType:SNNewsDragLoadingViewTypeTwins];
    
    [self resetTableDelegate:_dragDelegate];
    return (id)_dragDelegate;
}

- (void)didShowModel:(BOOL)firstTime
{
    [super didShowModel:firstTime];
}

-(void)refresh
{
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];
}

-(void)refreshWithNoAnimation {
    [(SNSubscribeNewsModel *)self.model refreshWithNoAnimation];
}

- (void)localRefresh {
    [(SNSubscribeNewsModel *)self.model localRefresh];
}

- (void)showFollowingEmpty:(BOOL)show {
    _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
    if (show) {
        self.emptyView.hidden = NO;
    }else{
        if (_emptyBgView) {
            self.emptyView.hidden = YES;
        }
    }
}

- (UIView *)emptyView {
    if (!_emptyBgView) {
        _emptyBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height + 44)];
        _emptyBgView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        
        _emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
        _emptyImageView.image = [UIImage themeImageNamed:@"icosohuh_zwgz_v5.png"];
        _emptyImageView.contentMode = UIViewContentModeScaleAspectFit;
        _emptyImageView.centerY = self.view.height * 0.35;
        [_emptyBgView addSubview:_emptyImageView];
        
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
        _emptyLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _emptyLabel.textColor = SNUICOLOR(kThemeText4Color);
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.text = @"关注搜狐号，发现更多精彩";
        _emptyLabel.top = _emptyImageView.bottom + 20;
        [_emptyBgView addSubview:_emptyLabel];
        
        _emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emptyButton setTitle:@"去关注" forState:UIControlStateNormal];
        [_emptyButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
        [_emptyButton setBackgroundColor:SNUICOLOR(kThemeRed1Color)];
        [_emptyButton addTarget:self action:@selector(goFollowRecom) forControlEvents:UIControlEventTouchUpInside];
        _emptyButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _emptyButton.layer.cornerRadius = 5;
        _emptyButton.clipsToBounds = YES;
        _emptyButton.frame = CGRectMake(0, 0, 150, 40);
        _emptyButton.centerX = self.view.width/2.f;
        _emptyButton.top = _emptyLabel.bottom + 20;
        [_emptyBgView addSubview:_emptyButton];
        [self.view addSubview:_emptyBgView];
    }
    [self.view bringSubviewToFront:_emptyBgView];
    return _emptyBgView;
}

- (void)goFollowRecom {
    if (self.superController) {
        [self.superController switchTab:1];
    }
}

//- (void)showLoading:(BOOL)show
//{
//    if (show == YES && [self.dragDelegate hasNoCache]) {
//        [self initTripletsLoadingView];
//        _tripletsLoadingView.status = SNTripletsLoadingStatusLoading;
//    }
//    else{
//        _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
//    }
//    
//    [self.view bringSubviewToFront:_tripletsLoadingView];
//}
//
//- (void)initTripletsLoadingView{
//    if (_tripletsLoadingView == nil) {
//        _tripletsLoadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, _headerView.frame.size.height, kAppScreenWidth, kAppScreenHeight - _headerView.frame.size.height - _toolbarView.frame.size.height + 2)];
//        _tripletsLoadingView.delegate = self;
//        _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
//        _tripletsLoadingView.backgroundColor = [UIColor redColor];
//        [self.view addSubview:_tripletsLoadingView];
//    }
//}

- (void)showError:(BOOL)show
{
    _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
}

-(void)dealloc
{
    _tripletsLoadingView.delegate = nil;
    [_dragDelegate dragLoadingViewRemove];
}

@end
