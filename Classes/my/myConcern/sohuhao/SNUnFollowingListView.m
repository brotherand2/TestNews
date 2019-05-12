//
//  SNUnFollowingListView.m
//  sohunews
//
//  Created by HuangZhen on 2017/6/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUnFollowingListView.h"
#import "SNUnFollowingListCatalogCell.h"
#import "SNUnFollowingListContentCell.h"
#import "SNOfficialAccountsInfo.h"
#import "SNSubscribeCenterService.h"
#import "SNSohuHaoChannelContentRequest.h"
#import "SNTwinsLoadingView.h"
#import "SNTwinsMoreView.h"
#import "SNLoadingImageAnimationView.h"
#import "SNSohuHaoModel.h"

static const CGFloat kRefreshDistanceY = -44.0f;

static const CGFloat kCatalogListCellHeight = 45.f;
static const CGFloat kContentListCellHeight = 80.f;

@interface SNUnFollowingListView ()<UITableViewDelegate,UITableViewDataSource,SNSubscribeEventDelegate>
{
    NSString * _selectedChannelId;
    NSInteger * _selectedChannelIndex;
    NSInteger _curPage;
    BOOL _allDidLoad;
    
    UIView * _tableFootView;
    UILabel *_allDidLoadView;
    UILabel *_noDataView;
    UIView *_bgView;
    UIButton *_notReachableIndicator;
    UIView * _notReachableBgView;
}

@property (nonatomic, strong) UITableView * catalogList;
@property (nonatomic, strong) UITableView * contentList;
@property (nonatomic, strong) UIView * segmentLine;

@property (nonatomic, strong) SNTwinsLoadingView * twinsLoadingView;
@property (nonatomic, strong) SNTwinsMoreView * moreView;
@property (nonatomic, strong) SNLoadingImageAnimationView * loadingImageView;

@property (nonatomic, strong) NSMutableArray * contentListArray;
@property (nonatomic, strong) NSArray * channelListArray;

@property (nonatomic, strong) SNSohuHao * lastSelectedSohuHao;

@end

@implementation SNUnFollowingListView

- (void)viewWillAppear {
    if (self.lastSelectedSohuHao && [[TTNavigator navigator].topViewController isKindOfClass:NSClassFromString(@"SNSProfileViewController")]) {
        [SNOfficialAccountsInfo checkFollowStatusWithSubId:self.lastSelectedSohuHao.subId completed:^(SNFollowedStatus followedStatus) {
            if (followedStatus == SNFollowedStatusFollowing || followedStatus == SNFollowedStatusFriend) {
                if (self.contentListArray.count > 0 && self.contentList) {
                    self.lastSelectedSohuHao.following = YES;
                    [self.superController refreshFollowingList];
                    [self.contentList reloadData];
                }
            }else if (followedStatus == SNFollowedStatusNone || followedStatus == SNFollowedStatusFollower || followedStatus == SNFollowedStatusSelf) {
                if (self.contentListArray.count > 0 && self.contentList) {
                    self.lastSelectedSohuHao.following = NO;
                    [self.superController refreshFollowingList];
                    [self.contentList reloadData];
                }
            }
        }];
    }
}

- (void)viewDidAppear {
}

- (void)viewScrollDidShow {
}

- (void)refreshCurrentTab {
    [self setSelectedChannelIndex:_selectedChannelIndex refresh:YES];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        [self initUI];
        _contentListArray = [NSMutableArray array];
        _selectedChannelIndex = 0;
        [self loadChannelList];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    self.catalogList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kRecomFollowCatalogListViewWidth, self.height) style:UITableViewStylePlain];
    self.catalogList.delegate = self;
    self.catalogList.dataSource = self;
    self.catalogList.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kRecomFollowCatalogListViewWidth, 15)];
    self.catalogList.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kRecomFollowCatalogListViewWidth, 15)];
    self.catalogList.separatorStyle = UITableViewCellSelectionStyleNone;
    self.catalogList.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    [self addSubview:self.catalogList];
    
    self.segmentLine = [[UIView alloc] initWithFrame:CGRectMake(kRecomFollowCatalogListViewWidth, -1, 0.5, self.height)];
    self.segmentLine.backgroundColor = SNUICOLOR(kThemeBg1Color);
    [self addSubview:self.segmentLine];
    
    self.contentList = [[UITableView alloc] initWithFrame:CGRectMake(kRecomFollowCatalogListViewWidth + 1, 0, self.width - kRecomFollowCatalogListViewWidth - 1, self.height) style:UITableViewStylePlain];
    self.contentList.delegate = self;
    self.contentList.dataSource = self;
    self.contentList.separatorStyle = UITableViewCellSelectionStyleNone;
    self.contentList.backgroundColor = [UIColor clearColor];
    [self initLoadingView];
    [self initMoreView];
    [self addSubview:self.contentList];
}

- (void)initLoadingView {
    CGRect loadingViewFrame = CGRectMake(_contentList.origin.x, _contentList.origin.y, _contentList.width, 44);
    self.twinsLoadingView = [[SNTwinsLoadingView alloc] initWithFrame:loadingViewFrame andObservedScrollView:self.contentList];
    [self addSubview:self.twinsLoadingView];
    self.twinsLoadingView.status = SNTwinsLoadingStatusPullToReload;
}

- (void)initMoreView {
    CGRect twinsMoreViewRect = CGRectMake(0, 10, _contentList.width, 40);
    if (!_tableFootView) {
        _tableFootView = [[UIView alloc] initWithFrame:twinsMoreViewRect];
        _tableFootView.backgroundColor = SNUICOLOR(kBackgroundColor);
        self.moreView = [[SNTwinsMoreView alloc] initWithFrame:twinsMoreViewRect];
        self.moreView.statusLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [_tableFootView addSubview:self.moreView];
    }
    self.moreView.hidden = YES;
    self.moreView.statusLabel.text = @"上拉加载更多";
    _contentList.tableFooterView = _tableFootView;
}

- (void)addAllDidLoadView {
    if (!_allDidLoadView) {
        _allDidLoadView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        _allDidLoadView.text = @"已全部加载";
        _allDidLoadView.textAlignment = NSTextAlignmentCenter;
        [_allDidLoadView setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
        [_allDidLoadView setTextColor:SNUICOLOR(kThemeText4Color)];
    }
    self.moreView.hidden = YES;
    _contentList.tableFooterView = _allDidLoadView;
    _allDidLoad = YES;
}

- (void)removeAllDidLoadView {
    if (_allDidLoadView) {
        [_allDidLoadView removeFromSuperview];
        _allDidLoadView = nil;
        _contentList.tableFooterView = nil;
    }
    self.moreView.hidden = NO;
}

- (void)resetLoadMoreView {
    _allDidLoad = NO;
    [self removeAllDidLoadView];
    [self initMoreView];
}

- (void)showNoNetworkView:(BOOL)full {
    CGFloat indicatorWidth = floorf(415/2.0f);
    CGFloat indicatorHeight = floorf(150/2.0f);
    CGFloat indicatorLeft = full ? (self.frame.size.width-indicatorWidth)/2.0f : (self.width - kRecomFollowCatalogListViewWidth - indicatorWidth)/2.0f ;
    CGFloat indicatorTop = full ? (self.frame.size.height-indicatorHeight)/2.0f : (self.height-indicatorHeight)/2.0f;
    if (!_notReachableBgView) {
        _loadingImageView.status = SNImageLoadingStatusStopped;
        UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeC];
        NSString *labelColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
        UIColor *fontColor = [UIColor colorFromString:labelColorString];
        
        UIImage *image = [UIImage imageNamed:@"sohu_loading_1.png"];
        _notReachableIndicator = [UIButton buttonWithType:UIButtonTypeCustom];
        _notReachableIndicator.frame = CGRectMake(indicatorLeft, indicatorTop, indicatorWidth, indicatorHeight);
        [_notReachableIndicator setImage:image forState:UIControlStateNormal];
        [_notReachableIndicator setImage:image forState:UIControlStateHighlighted];
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
        _notReachableBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _notReachableBgView.backgroundColor = self.backgroundColor;
        [_notReachableBgView addSubview:_notReachableIndicator];
        [self addSubview:_notReachableBgView];
    }
    if (full) {
        _notReachableBgView.frame = CGRectMake(0, 0, self.width, self.height);
    }else{
        _notReachableBgView.frame = CGRectMake(kRecomFollowCatalogListViewWidth + 1, 0, self.width - kRecomFollowCatalogListViewWidth , self.height);
    }
    _notReachableIndicator.frame = CGRectMake(indicatorLeft, indicatorTop, indicatorWidth, indicatorHeight);
    _notReachableIndicator.center = CGPointMake(_notReachableBgView.width/2.f, _notReachableBgView.height/2.f);
    _notReachableBgView.hidden = NO;
    _noDataView.hidden = YES;
    [self bringSubviewToFront:_notReachableBgView];

}

- (void)showEmptyView {
    if (!_noDataView) {
        _noDataView = [[UILabel alloc] initWithFrame:CGRectMake(kRecomFollowCatalogListViewWidth + 1, 0, self.width - kRecomFollowCatalogListViewWidth , self.height)];
        _noDataView.text = @"暂无新的推荐，看看其他分类";
        _noDataView.backgroundColor = self.backgroundColor;
        _noDataView.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _noDataView.textColor = SNUICOLOR(kThemeText3Color);
        _noDataView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_noDataView];
    }
    _noDataView.hidden = NO;
    [self bringSubviewToFront:_noDataView];
    _notReachableBgView.hidden = YES;
}

- (void)retry {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    _notReachableBgView.hidden = YES;
    _noDataView.hidden = YES;
    if (_notReachableBgView.width == self.width) {
        [self loadChannelList];
    }else{
        [self setSelectedChannelIndex:_selectedChannelIndex refresh:YES];
    }
}

- (void)showLoadingImagesViewFull:(BOOL)full {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        _bgView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        [self addSubview:_bgView];
    }
    if (!self.loadingImageView) {
        self.loadingImageView = [[SNLoadingImageAnimationView alloc] init];
        self.loadingImageView.targetView = _bgView;
    }
    if (full) {
        _bgView.frame = CGRectMake(0, -64, self.width, self.height + 64);
    }else{
        _bgView.frame = CGRectMake(kRecomFollowCatalogListViewWidth + 1, 0, self.width - kRecomFollowCatalogListViewWidth, self.height);
    }
    self.loadingImageView.status = SNImageLoadingStatusLoading;
    _bgView.hidden = NO;
}

- (void)hideLoadingImagesView {
    self.loadingImageView.status = SNImageLoadingStatusStopped;
    _bgView.hidden = YES;
}

#pragma mark - data
- (void)loadChannelList {
    [self showLoadingImagesViewFull:YES];
    [SNSohuHaoModel getSohuHaoChannelList:^(NSArray *data) {
        [self hideLoadingImagesView];
        if (data.count > 0) {
            self.channelListArray = [NSArray arrayWithArray:data];
            [self.catalogList reloadData];
            [self setSelectedChannelIndex:0 refresh:NO];
            [self.catalogList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        }else{
            //无数据无网络页面
            [self showNoNetworkView:YES];
        }
    }];
}

- (void)setSelectedChannelIndex:(NSInteger)index refresh:(BOOL)forceRefresh{
    if (_channelListArray && index < _channelListArray.count) {
        _selectedChannelIndex = index;
        SNSohuHaoChannel * channel = _channelListArray[index];
        if ([channel isKindOfClass:[SNSohuHaoChannel class]]) {
            if ([_selectedChannelId isEqualToString:channel.channelId] && self.contentListArray.count > 0 && !forceRefresh) {
                return;
            }
            _contentList.alpha = 0.0;
            _notReachableBgView.hidden = YES;
            _noDataView.hidden = YES;
            [self resetLoadMoreView];
            [_contentList scrollToTop:NO];
            [self.contentListArray removeAllObjects];
            [_contentList reloadData];
            _selectedChannelId = channel.channelId;
            [self loadChannelDataWithChannelId:_selectedChannelId Page:0];
        }
    }
}

- (void)loadChannelDataWithChannelId:(NSString *)channelId Page:(NSInteger)page {

    if (page == 1 || page == 0) {
        _curPage = 1;
        self.twinsLoadingView.status = SNTwinsLoadingStatusLoading;
//        if (page == 0) {
//            [self showLoadingImagesViewFull:NO];
//        }
    }else{
        if (_allDidLoad) {
            self.moreView.status = SNTwinsMoreStatusStop;
            return;
        }
        self.moreView.status = SNTwinsMoreStatusLoading;
        self.moreView.statusLabel.text = @"正在加载";
        _curPage += 1;
    }

    [SNSohuHaoModel getSohuHaoListWithChannelId:channelId page:_curPage completed:^(NSArray *data) {
        if ([channelId isEqualToString:_selectedChannelId]) {
            //        [self hideLoadingImagesView];
            if (data.count > 0) {
                if (_curPage == 1) {
                    [self.contentListArray removeAllObjects];
                }
                [self.contentListArray addObjectsFromArray:data];
                [_contentList reloadData];
                if (data.count < 20) {
                    [self addAllDidLoadView];
                }else{
                    [self removeAllDidLoadView];
                }
                
                if (_curPage == 1) {
                    [UIView animateWithDuration:0.1 animations:^{
                        _contentList.alpha = 1.0;
                    }];
                    self.twinsLoadingView.status = SNTwinsLoadingStatusPullToReload;
                }else{
                    self.moreView.status = SNTwinsMoreStatusStop;
                    self.moreView.statusLabel.text = @"上拉加载更多";
                }
            }else{
                if (_curPage == 1) {
                    if ([[SNUtility getApplicationDelegate] isNetworkReachable]) {
                        [self showEmptyView];
                    }else{
                        [self showNoNetworkView:NO];
                    }
                }
                self.moreView.status = SNTwinsMoreStatusStop;
                self.moreView.statusLabel.text = @"上拉加载更多";
                self.twinsLoadingView.status = SNTwinsLoadingStatusPullToReload;
            }
        }
    }];
}

#pragma mark - SNSubscribeEventDelegate
- (void)subscribeFinished:(BOOL)success {
    if (success) {
        [self.superController refreshFollowingList];
    }
}

#pragma mark - UIScrollowViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.contentList) {
        if (scrollView.contentOffset.y+_contentList.contentInset.top<= kRefreshDistanceY) {
            [self loadChannelDataWithChannelId:_selectedChannelId Page:1];
        }
        else if (scrollView.contentOffset.y+_contentList.contentInset.top < 0 && scrollView.contentOffset.y+_contentList.contentInset.top > kRefreshDistanceY){
            self.twinsLoadingView.status = SNTwinsLoadingStatusReleaseToReload;
        }
        else if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height)) {
            [self loadChannelDataWithChannelId:_selectedChannelId Page:(_curPage + 1)];
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _catalogList) {
        return kCatalogListCellHeight;
    }else if (tableView == _contentList){
        return kContentListCellHeight;
    }else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _catalogList) {
        [self setSelectedChannelIndex:indexPath.row refresh:NO];
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=recomchannel&_tp=pv&channelid=%@",_selectedChannelId]];
    }else if(tableView == _contentList) {
        SNSohuHao * sohuHao = [self.contentListArray objectAtIndex:indexPath.row];
        NSString * link = [NSString stringWithFormat:@"subHome://subId=%@&passport=%@",sohuHao.subId,sohuHao.passport];
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=subrecomm&_tp=pv&subid=%@&channelid=%@",sohuHao.subId,_selectedChannelId]];
//        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=subscribe&_tp=recom&subid=%@",sohuHao.subId]];
        NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
        [referInfo setObject:@"0" forKey:kReferValue];
        [referInfo setObject:@"0" forKey:kReferType];
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Subscribe_MeMedia] forKey:kRefer];
        if ([SNUtility openProtocolUrl:link context:referInfo]) {
            self.lastSelectedSohuHao = sohuHao;
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _contentList) {
        return _contentListArray.count > 0 ? _contentListArray.count : 0;
    }else if (tableView == _catalogList) {
        return _channelListArray.count > 0 ? _channelListArray.count : 0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _catalogList) {
        SNUnFollowingListCatalogCell * cell = [tableView dequeueReusableCellWithIdentifier:@"kCatalogListCellIdentifier"];
        if (nil == cell) {
            cell = [[SNUnFollowingListCatalogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"kCatalogListCellIdentifier"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
         }
        if (indexPath.row == 0) {
            [cell setSelected:YES animated:NO];
        }
        SNSohuHaoChannel * channel = self.channelListArray[indexPath.row];
        [cell setContentWithChannel:channel];
        return cell;
    }else if (tableView == _contentList) {
        SNUnFollowingListContentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"kContentListCellIdentifier"];
        if (nil == cell) {
            cell = [[SNUnFollowingListContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"kContentListCellIdentifier"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.subscribeDelegate = self;
        SNSohuHao * sohuHao = _contentListArray[indexPath.row];
        [cell setObject:sohuHao];
        return cell;
    }
    return nil;
}

- (void)dealloc {
    _twinsLoadingView.status = SNTwinsLoadingStatusNil;
    [_twinsLoadingView removeObserver];
    [_twinsLoadingView removeFromSuperview];
    
    _moreView.status = SNTwinsMoreStatusStop;
    [_moreView removeFromSuperview];

    if (self.catalogList) {
        self.catalogList.delegate = nil;
        self.catalogList = nil;
    }
    
    if (self.contentList) {
        self.contentList.delegate = nil;
        self.contentList = nil;
    }
}

@end
