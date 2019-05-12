//
//  SNVideosTableViewController.m
//  sohunews
//
//  Created by chenhong on 13-8-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosTableViewController.h"
#import "SNTwinsLoadingView.h"
#import "SNVideosTableMoreCell.h"
#import "SNVideosTableCell.h"
#import "UIColor+ColorUtils.h"
#import "SNVideoObjects.h"
#import "WSMVConst.h"
#import <objc/runtime.h>
#import "SNVideosTableCell.h"
#import "SNVideosTableSpecialCell.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNVideosTableAppCell.h"
#import "SNVideosViewController.h"
#import "SNVideosTableComplexCell.h"
#import "SNRollingNewsPublicManager.h"
#import "SNTipsView.h"


#define CELL_H 176
#define kDebugTimelinePlayableArea  (0)

// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
#define kRefreshDeltaY              (-65.0f)
#define kDefaultOffsetHeight        (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 65.f : 45.f)


@interface SNVideosTableViewController () {
    SNTwinsLoadingView *_dragLoadingView;
    SNVideosTableMoreCell *_moreCell;
    SNVideosModel *_model;
    SNTripletsLoadingView *_fullScreenNetworkErrorView;
    BOOL _shouldUpdateRefreshTime;
    BOOL _isLoading;
    BOOL _isLoadingMore;
    BOOL _isUploadClickStatistic;
}

#if kDebugTimelinePlayableArea
@property (nonatomic, retain)UIView *playableArea;
#endif

@end

@implementation SNVideosTableViewController
@synthesize tableView=_tableView;
@synthesize canBeReusable;
@synthesize channelId=_channelId;
@synthesize reuseIdentifier=_reuseIdentifier;

- (id)initWithIdentifier:(NSString *)aIdentifier {
	self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.canBeReusable = YES;
        self.reuseIdentifier = aIdentifier;
        
        [SNNotificationManager addObserver:self selector:@selector(handleFinishCheckTimelineVideosControlNotification:) name:kFinishCheckTimelineVideosControlNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleSupportVideoDownloadValueChangedNotification:) name:kSupportVideoDownloadValueChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(refresh) name:kAutoRefreshVideoNewsNotification object:nil];
    }
    
    return self;
}

- (void)resetTableViewContentInset {
    CGFloat edgeInsetTop = kHeadSelectViewHeight-10;//减10是为了在下拉刷新完成后，第一个cell能盖住loadingView
    _tableView.contentInset = UIEdgeInsetsMake(edgeInsetTop, 0.f, kToolbarViewHeight, 0.f);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(edgeInsetTop, 0.f, kToolbarViewHeight, 0.f);
}

- (void)loadView {
    [super loadView];
    CGRect frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth,
                              kAppScreenHeight - kToolbarViewTop - kHeadSelectViewBottom);
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    [self resetTableViewContentInset];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addTableHeader:12];
    
    // 下拉刷新
    CGRect dragLoadingViewFrame = CGRectMake(0, kDefaultOffsetHeight, kAppScreenWidth, 44.f);
    _dragLoadingView = [[SNTwinsLoadingView alloc] initWithFrame:dragLoadingViewFrame andObservedScrollView:_tableView];
    _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
    [self.view addSubview:_dragLoadingView];
    [self.view addSubview:_tableView];
    if (_model == nil) {
        _model = [[SNVideosModel alloc] initWithChannelId:_channelId];
        _model.delegate = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateTheme];
    //[self refresh];
}

- (void)viewDidUnload {
     //(_dragLoadingView);
     //(_fullScreenNetworkErrorView);
     //(_moreCell);
     //(_tableView);
    
    #if kDebugTimelinePlayableArea
     //(_playableArea);
    #endif
    [super viewDidUnload];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    _dragLoadingView.status = SNTwinsLoadingStatusNil;
    [_dragLoadingView removeFromSuperview];
    
//    [_model cancel]; // 这个model有可能还在别的地方用 不需要cancel 在model的dealloc里面会cancel by jojo
    _model.delegate = nil;
     //(_model);
     //(_dragLoadingView);
     //(_fullScreenNetworkErrorView);
     //(_moreCell);
     //(_tableView);
     //(_reuseIdentifier);
     //(_channelId);
    
    #if kDebugTimelinePlayableArea
     //(_playableArea);
    #endif
}

- (void)addTableHeader:(float)height {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, height)];
    _tableView.tableHeaderView = headerView;
     //(headerView);
}

- (void)removeTableHeader {
    _tableView.tableHeaderView = nil;
}

- (void)updateTheme {
    if ([self isViewLoaded]) {
        self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    }
}

- (void)scrollToTop {
    _tableView.contentOffset = CGPointMake(0, -_tableView.contentInset.top);
}

#pragma mark - model & request

- (void)setChannelId:(NSString *)channelId {
    if (![self.channelId isEqualToString:channelId]) {
        
        _channelId = [channelId copy];
        
        // 更新model
        [_model cancel];
         //(_model);

        if (_channelId) {
            _model = [[SNVideosModel alloc] initWithChannelId:_channelId];
            _model.delegate = self;
            [_model loadCache];

            [self view];
        } else {
            [_model cancel];
        }
        
        self.canBeReusable = (channelId == nil);
        
        [_tableView setContentOffset:CGPointMake(0,-_tableView.contentInset.top) animated:NO];
        [_tableView reloadData];

        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            [self setNetworkErrorViewVisible:NO];
            
            if ([_model shouldReload]) {
                [self refresh];
            }
        } else {
            if (_model.dataArray.count == 0) {
                [self setNetworkErrorViewVisible:YES];
            }
            else {
                [self setNetworkErrorViewVisible:NO];
            }
        }
    }
}

- (void)refresh {
    if ([self willRefreshSelectedVC]) {
        [SNTimelineSharedVideoPlayerView fakeStop];
        [SNTimelineSharedVideoPlayerView forceStop];
    }
    
    if (_isLoading) {
        return;
    }

    [_model refresh];
    [self modelDidStartLoad];
    [self setNetworkErrorViewVisible:NO];
    _isUploadClickStatistic = YES;
}

- (void)refreshIfNeeded {
    if ([self willRefreshSelectedVC]) {
        [SNTimelineSharedVideoPlayerView fakeStop];
        [SNTimelineSharedVideoPlayerView forceStop];
    }
    
    if (_isLoading) {
        return;
    }

    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        return;
    }
    
    if (_channelId) {
        if ([_model shouldReload]) {
            //[_tableView setContentOffset:CGPointMake(0,-_tableView.contentInset.top) animated:NO];
            [self refresh];
        }
    }
}

- (BOOL)willRefreshSelectedVC {
    SNVideosViewController *videosVC = (SNVideosViewController *)(self.delegate);
    NSString *selectedChannelID = videosVC.selectedChannelId;
    NSString *modelChannelID = _model.channelId;
    return  [selectedChannelID isEqualToString:modelChannelID];
}

- (BOOL)doesNeedRefresh {
    if (_isLoading) {
        return NO;
    }
    
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        return NO;
    }
    
    if (_channelId) {
        if ([_model shouldReload]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isLoading {
    return _model.isLoading;
}

- (BOOL)shouldReload {
    if (_channelId && [_model shouldReload]) {
        return YES;
    }
    return NO;
}

- (void)loadMore {
    if (!_isLoadingMore && !_model.isLoading) {
        _isLoadingMore = YES;
        [_model loadMore];
        [self modelDidStartLoad];
    }
}

#pragma mark - model delegate

- (void)videosDidFinishLoad {
    [self.tableView reloadData];
    
    [self modelDidFinishLoad];

    [self setNetworkErrorViewVisible:(_model.dataArray.count == 0)];
}

- (void)videosDidFailLoadWithError:(NSError *)error {
    [self modelDidFailLoadWithError:error];
    if (_model.dataArray.count == 0) {
        [self setNetworkErrorViewVisible:YES];
    }
}

- (void)videosDidCancelLoad {
    [self modelDidCancelLoad];
}

# pragma mark - 网络错误界面
#define kErrorViewOffset (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 100 : 0.f)
- (void)setNetworkErrorViewVisible:(BOOL)visible {
	if (visible) {
		if (_model.dataArray.count <= 0) {
            if (!_fullScreenNetworkErrorView) {
                CGRect frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height - kErrorViewOffset);
                _fullScreenNetworkErrorView = [[SNTripletsLoadingView alloc] initWithFrame:frame];
                _fullScreenNetworkErrorView.delegate = self;
                [self.tableView addSubview:_fullScreenNetworkErrorView];
            }
            _fullScreenNetworkErrorView.status = SNTripletsLoadingStatusNetworkNotReachable;
            _fullScreenNetworkErrorView.hidden = NO;
		}
	} else {
        _fullScreenNetworkErrorView.status = SNTripletsLoadingStatusStopped;
        _fullScreenNetworkErrorView.hidden = YES;
	}
}

#pragma mark - UITableView datasource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _model.dataArray.count) {
        SNVideoData *videoItem = [_model.dataArray objectAtIndex:indexPath.row];
        return [[self class] cellHeightWithItem:videoItem];
    } else {
        //return [SNVideosTableMoreCell height];
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    NSInteger total = _model.dataArray.count;
    return (total > 0 ? total + 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {    
    if (indexPath.row < _model.dataArray.count) {
        SNVideoData *videoItem = [_model.dataArray objectAtIndex:indexPath.row];
        Class cellClass = [[self class] cellForClass:videoItem];
        
        NSString *videoCellIdentifier = NSStringFromClass(cellClass);
        SNVideosTableBaseCell *cell = (SNVideosTableBaseCell *)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
        if (cell == nil) {
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:videoCellIdentifier];
            if ([cell respondsToSelector:@selector(setDelegate:)]) {
                cell.delegate = self;
            }
        }
        
        cell.object = videoItem;
        cell.videosTableViewController = self;
        
        __block typeof(self) wself = self;
        __weak SNVideosModel* model = _model;
        if([cell isKindOfClass:[SNVideosTableComplexCell class]])
        {
            SNVideosTableComplexCell* complexCell = (SNVideosTableComplexCell*)cell;
            complexCell.channelId = wself.channelId;
            complexCell.uninterestBlock = ^(SNVideoData* data)
            {
                [model.dataArray removeObject:data];
                [wself.tableView reloadData];
                [wself saveUninterestTime];
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"此类型内容将减少" toUrl:nil mode:SNCenterToastModeOnlyText];
            };
        }
        
        return cell;
    }
    else {
        if (_moreCell == nil) {
            _moreCell = [[SNVideosTableMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
        }
        return _moreCell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[SNVideosTableMoreCell class]]) {
        if (!_isLoadingMore) {
            //[_moreCell showLoading:NO];
            //[_moreCell setHasNoMore:_model.hasNoMore];
        } else {
            //[_moreCell showLoading:YES];
        }
    }
    else if([cell isKindOfClass:[SNVideosTableComplexCell class]])
    {
        if(_isUploadClickStatistic)
        {
            SNVideosTableComplexCell* complextCell = (SNVideosTableComplexCell*)cell;
            if(complextCell.object)
                [complextCell.object uploadDisplayStatistics:self.channelId];
            _isUploadClickStatistic = NO;
        }
    }
}

//iOS 6.0以下此方法会被回调
- (void)didEndDisplayingCell:(UITableViewCell *)cell {
    [self tableView:self.tableView didEndDisplayingCell:cell forRowAtIndexPath:[self.tableView indexPathForCell:cell]];
}

//iOS 6.0及以上此方法被回调
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([cell isKindOfClass:[SNVideosTableCell class]]) {
        SNVideosTableCell *videosCell = (SNVideosTableCell *)cell;
        [videosCell stopVideoPlayIfPlaying];
    }
    else if ([cell isKindOfClass:[SNVideosTableComplexCell class]])
    {
        [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    if ([self willRefreshSelectedVC]) {//当前选中channel正在刷新都要禁用转屏功能
        [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = NO;
    }
    
    if (scrollView.dragging && !_isLoading) {
        if ((scrollView.contentOffset.y+scrollView.contentInset.top) > -[_dragLoadingView minDistanceCanReleaseToReload]) {
            _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        } else {
            _dragLoadingView.status = SNTwinsLoadingStatusReleaseToReload;
        }
    }
	   
    /*CGFloat scrollingHeight = scrollView.contentOffset.y+scrollView.contentInset.top+_tableView.height+[SNVideosTableMoreCell height]+30;
    CGFloat actualHeight = scrollView.contentSize.height;
    BOOL isItTimeToLoad = scrollingHeight > actualHeight;
    if (scrollView.dragging && _model.dataArray.count > 0 && isItTimeToLoad && !_model.hasNoMore && !_model.isLoading) {
        [self loadMore];
    }*/
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
    
	// If dragging ends and we are far enough to be fully showing the header view trigger a
	// load as long as we arent loading already
	if (scrollView.contentOffset.y + scrollView.contentInset.top <= kRefreshDeltaY && !_isLoading) {
        [self refresh];
	}
    
    _shouldUpdateRefreshTime = YES;
    
    if (!decelerate) {
        NSLogFatal(@"#######################End dragging and no decelerate.");
        if ([self.delegate respondsToSelector:@selector(startPlayTimelineVideo)]) {
            [self.delegate startPlayTimelineVideo];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
    
    [SNNotificationManager postNotificationName:kTipsViewRefreshNotification object:nil];
    
    NSLogFatal(@"======================End decelerating and no dragging.");
    if ([self.delegate respondsToSelector:@selector(startPlayTimelineVideo)]) {
        [self.delegate startPlayTimelineVideo];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    SNDebugLog(@"Did scroll to  top.");
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
    if ([self.delegate respondsToSelector:@selector(startPlayTimelineVideo)]) {
        [self.delegate startPlayTimelineVideo];
    }
}

#pragma mark - TableView Model Delegate
- (void)modelDidStartLoad {
    
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        return;
    }
    if (_isLoadingMore) {
        //[_moreCell showLoading:YES];
        
    } else {
        _dragLoadingView.status = SNTwinsLoadingStatusLoading;
        [UIView animateWithDuration:ttkDefaultTransitionDuration animations:^{
           _tableView.contentOffset = CGPointMake(0, -_tableView.contentInset.top);
        }];
        _isLoading = YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad {
    if (_isLoadingMore) {
        //[_moreCell showLoading:NO];
        _isLoadingMore = NO;
        //[_moreCell setHasNoMore:_model.hasNoMore];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(videosDidFinishLoadFromTableViewController:isMore:)]) {
                [self.delegate videosDidFinishLoadFromTableViewController:self isMore:YES];
            }
        });
    } else {
        _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        [UIView animateWithDuration:ttkDefaultTransitionDuration animations:^{
            [self resetTableViewContentInset];
        } completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(videosDidFinishLoadFromTableViewController:isMore:)]) {
                    [self.delegate videosDidFinishLoadFromTableViewController:self isMore:NO];
                }
            });
        }];
        _isLoading = NO;
    }
    
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFailLoadWithError:(NSError *)error {
    if (_isLoadingMore) {
        //[_moreCell showLoading:NO];
        _isLoadingMore = NO;
        //[_moreCell setHasNoMore:_model.hasNoMore];
    } else {
        _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        [UIView animateWithDuration:ttkDefaultTransitionDuration animations:^{
            [self resetTableViewContentInset];
        }];
        
        _isLoading = NO;
    }
    
    [SNTimelineSharedVideoPlayerView sharedInstance].isEnableFullScreen = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad {
    if (_isLoadingMore) {
        //[_moreCell showLoading:NO];
        _isLoadingMore = NO;
        //[_moreCell setHasNoMore:_model.hasNoMore];
    } else {
        _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        [UIView animateWithDuration:ttkDefaultTransitionDuration animations:^{
            [self resetTableViewContentInset];
        }];
        
        _isLoading = NO;
    }
}

#pragma mark - SNTripletsLoadingViewDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        _fullScreenNetworkErrorView.status = SNTripletsLoadingStatusLoading;
        [self refresh];
    }
}

#pragma mark - About - Timeline video play
- (void)startPlayTimelineVideo {
    SNVideosTableBaseCell *cellOfShouldPlay = [self getCellOfShouldPlay];
    [cellOfShouldPlay playVideoIfNeeded];
    
    if (!cellOfShouldPlay) {
        NSLogError(@"There is no proper cell to play video.");
    }
}

- (void)startPlayTimelineVideoIn2G3G {
    SNVideosTableBaseCell *cellOfShouldPlay = [self getCellOfShouldPlay];
    [cellOfShouldPlay playVideoIfNeededIn2G3G];
    
    if (!cellOfShouldPlay) {
        NSLogError(@"There is no proper cell to play video in 2G/3G.");
    }
}

- (SNVideosTableBaseCell *)getCellOfShouldPlay {
    SNVideosTableBaseCell *cellOfShouldPlay = nil;
    
    if (_model.dataArray.count > 0) {
        CGFloat visibleAreaTop = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? kHeaderTotalHeight : kHeadBottomHeight;
        CGFloat visibleAreaBottom = _tableView.height-kToolbarViewHeight;
        
        CGFloat visibleAreaHeight = visibleAreaBottom-visibleAreaTop;
        CGFloat leftAreaHeight = (visibleAreaHeight - [SNVideosTableCell height])/2.0f;
        
        CGFloat playableAreaTop = visibleAreaTop+leftAreaHeight;
        CGFloat playableAreaBottom = playableAreaTop+[SNVideosTableCell height];// - (kTimelineVideoCellSubContentViewsHeight - kPlayerViewHeight);
        
        NSArray *visibleCells = _tableView.visibleCells;
        
        for (SNVideosTableBaseCell *cell in visibleCells) {
            if ([cell isKindOfClass:[SNVideosTableBaseCell class]]) {
                UIView *cellSuperView = cell.superview;
                CGPoint cellCenter = [_tableView convertPoint:cell.center fromView:cellSuperView];
                CGFloat cellCenterVOffsetInVisibleArea = cellCenter.y-_tableView.contentOffset.y;
                if (cellCenterVOffsetInVisibleArea > playableAreaTop && cellCenterVOffsetInVisibleArea < playableAreaBottom && !cellOfShouldPlay) {
                    cellOfShouldPlay = cell;//lijian 2015.02.13 自动播放视频的奇葩功能，plus上该怎么算？？
                }
                else {
                    [cell stopVideoPlayIfPlaying];
                }
            }
        }
        
        #if kDebugTimelinePlayableArea
        if (!_playableArea) {
            _playableArea = [[UIView alloc] initWithFrame:CGRectMake(0, playableAreaTop, self.tableView.width, [SNVideosTableCell height])];
            _playableArea.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
            [self.view addSubview:_playableArea];
            _playableArea.userInteractionEnabled = NO;
        }
        #endif
    }
    
    return cellOfShouldPlay;
}

#pragma mark - 2G3G提示
- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style forPlayerView:(WSMVVideoPlayerView *)playerView {
    if ([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
        [self.delegate alert2G3GIfNeededByStyle:style forPlayerView:playerView];
    }
}

#pragma mark - Static
+ (id)cellForClass:(SNVideoData *)item {
    switch (item.multipleType) {
        case TimelineVideoType_normalVideo:
            return [SNVideosTableCell class];
        case TimelineVideoType_Speical:
            return [SNVideosTableSpecialCell class];
        case TimelineVideoType_AppBanner:
            return [SNVideosTableAppCell class];
        case TimelineVideoType_Complex:
            return [SNVideosTableComplexCell class];
        default:
            return [SNVideosTableSpecialCell class];
    }
}

+ (CGFloat)cellHeightWithItem:(SNVideoData *)item {
    switch (item.multipleType) {
        case TimelineVideoType_normalVideo:
            return [SNVideosTableCell height];
        case TimelineVideoType_Speical:
            return [SNVideosTableSpecialCell height];
        case TimelineVideoType_AppBanner:
            return [SNVideosTableAppCell height];
        case TimelineVideoType_Complex:
            return [SNVideosTableComplexCell heightForVideoData:item];
        default:
            return 0;
    }
}

#pragma mark -
- (void)toVideoDetailPage:(SNVideoData *)videoItem {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (!!_model) {
        [dict setObject:_model forKey:kDataKey_VideoTabTimelineVideoModel];
    }
    if (!!videoItem) {
        [dict setValue:videoItem forKey:kDataKey_TimelineVideo];
    }
    if (!!(_model.dataArray)) {
        [dict setValue:_model.dataArray forKey:kDataKey_TimelineVideos];
    }
    if (self.channelId.length > 0) {
        [dict setValue:self.channelId forKey:@"channelId"];
    }
    if (videoItem.columnId > 0) {
        [dict setValue:@(videoItem.columnId) forKey:@"columnId"];
    }
    if (videoItem.messageId.length > 0) {
        [dict setValue:videoItem.messageId forKey:@"mid"];
    }

    if (videoItem.link2.length) {
        [SNUtility openProtocolUrl:videoItem.link2 context:dict];
    } else {
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://videoDetail"] applyAnimated:YES] applyQuery:dict];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (BOOL)isTableViewControllerLoading {
    return [self isLoading];
}

- (BOOL)isVideoTimelineVisiable {
    if ([_delegate respondsToSelector:@selector(isVideoTimelineVisiable)]) {
        return [_delegate isVideoTimelineVisiable];
    } else {
        return YES;
    }
}

#pragma mark -
- (void)handleFinishCheckTimelineVideosControlNotification:(NSNotification *)notification {
    for (UITableViewCell *visibleCell in self.tableView.visibleCells) {
        if ([visibleCell isKindOfClass:[SNVideosTableCell class]]) {
            SNVideosTableCell *videoCell = (SNVideosTableCell *)visibleCell;
            [videoCell updateFullscreenBtn];
        }
    }
}

- (void)handleSupportVideoDownloadValueChangedNotification:(NSNotification *)notification {
    for (UITableViewCell *visibleCell in self.tableView.visibleCells) {
        if ([visibleCell isKindOfClass:[SNVideosTableCell class]]) {
            SNVideosTableCell *videoCell = (SNVideosTableCell *)visibleCell;
            [videoCell updateDownloadBtn];
        }
    }
}

#pragma mark - SNVideosTableCellDelegate
- (BOOL)canRespondRotate {
    if ([self.delegate respondsToSelector:@selector(canRespondRotate)]) {
        return [self.delegate canRespondRotate];
    }
    else {
        return NO;
    }
}

#pragma mark - uninterest
- (void)saveUninterestTime
{
    NSString* key = @"kVideoCellUnintrestTime_";
    key = [key stringByAppendingString:_model.channelId];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });

}




@end
