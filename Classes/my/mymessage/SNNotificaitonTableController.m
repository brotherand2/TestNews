//
//  SNNotificaitonTableController.m
//  sohunews
//
//  Created by weibin cheng on 13-6-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNotificaitonTableController.h"
#import "SNNotificationCell.h"
#import "UIColor+ColorUtils.h"
#import "SNDBManager.h"
#import "SNDataBase_Notification.h"
#import "SNBubbleBadgeObject.h"
#import "SNTimelineConfigs.h"

#import "SNTripletsLoadingView.h"
#import "SNTwinsLoadingView.h"

#define kSNNotificationCellHight 58

@interface SNNotificaitonTableController ()<SNTripletsLoadingViewDelegate>
{
    BOOL _shouldUpdateRefreshTime;
    BOOL _isLoading;
    BOOL _isLoadingMore;
    //SNWeiboDetailMoreCell* _moreCell;
    SNTwinsLoadingView *_dragLoadingView;
    SNTripletsLoadingView *_loading;
}

-(void)loadMore;
-(void)refresh;
@end

@implementation SNNotificaitonTableController
@synthesize tableView = _tableView;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        kRefreshDeltaY = -64.0f;
        kHeaderVisibleHeight = 60.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    //[self refresh];
    _loadingView = [[SNEmbededActivityIndicator alloc] initWithFrame:CGRectMake(0, 3, _tableView.width, _tableView.height) andDelegate:self];
    _loadingView.hidesWhenStopped = YES;
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
//    [_tableView addSubview:_loadingView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadView
{
    [super loadView];
    
    _notificationModel = [[SNNotificationModel alloc] init];
    _notificationModel.notificationDelegate = self;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
//    _headerView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0,
//                                                                                 -_tableView.bounds.size.height,
//                                                                                 _tableView.width,
//                                                                                 _tableView.bounds.size.height)];
//    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [_headerView setUpdateDate:[_notificationModel getLastRefreshDate]];
//    [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
//    [_tableView addSubview:_headerView];
    //下拉刷新
    CGRect dragLoadingViewFrame = CGRectMake(0, 0, kAppScreenWidth, 44);
    _dragLoadingView = [[SNTwinsLoadingView alloc] initWithFrame:dragLoadingViewFrame andObservedScrollView:self.tableView];
    _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
    [self.view addSubview:_dragLoadingView];
    [self.view addSubview:_tableView];
    
    _loading = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, -60, self.view.frame.size.width, self.view.frame.size.height)];
    _loading.delegate = self;
    _loading.status = SNTripletsLoadingStatusStopped;
    [self.view addSubview:_loading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _tableView.frame = self.view.bounds;
}
- (void)firstRefresh
{
    if(_notificationModel.itemArray.count == 0)
    {
        [self refresh];
    }
}
- (void)dealloc
{
     //(_tableView);
//     //(_headerView);
     //(_noneNotificationView);
     //(_noneNotificationViewBack);
     //(_notificationModel);
     //(_moreCell);
     //(_loading);
     //(_dragLoadingView);
}

#pragma -mark private methods
-(void)showNoneNotificationView
{
    if(!_noneNotificationView)
    {
        UIImage* image = [UIImage themeImageNamed:@"none_notification.png"];
        CGRect rect;
        rect.origin.x = (_tableView.width - image.size.width) / 2;
        rect.origin.y = (_tableView.height - image.size.height) / 2;
        rect.size = image.size;
        _noneNotificationView = [[UIImageView alloc] initWithImage:image];
        _noneNotificationView.frame = rect;
        
        _noneNotificationViewBack = [[UIView alloc] initWithFrame:_tableView.frame];
        _noneNotificationViewBack.backgroundColor = SNUICOLOR(kBackgroundColor);
        [_tableView addSubview:_noneNotificationViewBack];
        [_tableView addSubview:_noneNotificationView];
        [_tableView bringSubviewToFront:_noneNotificationView];
    }
}

-(void)hideNoneNotificationView
{
    if(_noneNotificationView)
    {
        [_noneNotificationView removeFromSuperview];
         //(_noneNotificationView);
        [_noneNotificationViewBack removeFromSuperview];
         //(_noneNotificationViewBack);
    }
}

-(void)updateTheme:(NSNotification *)notifiction
{
    [_tableView reloadData];
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    if(_noneNotificationView)
    {
        UIImage* image = [UIImage themeImageNamed:@"none_notification.png"];
        _noneNotificationView.image = image;
        _noneNotificationViewBack.backgroundColor = SNUICOLOR(kBackgroundColor);
    }
}

- (void)refresh
{
    [_notificationModel refresh];
    [self modelDidStartLoad];
    [self showError:NO];
    [self hideNoneNotificationView];
}

- (void)loadMore
{
    if(!_isLoading && !_isLoadingMore)
    {
        _isLoadingMore = YES;
        [_notificationModel loadMore];
        //[_moreCell showLoading:YES];
    }
}
# pragma mark - 网络错误界面
-(void)showError:(BOOL)show {
    if (show) {
        _loadingView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
    } else {
        _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    }
}

-(void)didTapRetry
{
    [self refresh];
}
#pragma -mark SNNotificationModelDelegate
-(void)didFailLoadWithError:(NSError *)error
{
    SNDebugLog(@"%s", __FUNCTION__);
    [self modelDidFailLoadWithError];
    if([_notificationModel.itemArray count] == 0)
    {
        [self showError:YES];
    }
    else
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

-(void)didFinishLoadNotificaiton:(NSInteger)num
{
    SNDebugLog(@"%s", __FUNCTION__);
    if(!_isLoadingMore)
    {
        [[SNBubbleNumberManager shareInstance] resetNotify];
    }
    [self modelDidFinishLoad];
    [self.tableView reloadData];
    if([_notificationModel.itemArray count] == 0)
    {
        [self showNoneNotificationView];
    }
    else
    {
        [self hideNoneNotificationView];
    }
}

#pragma -mark UITableViewDelegate and UITableviewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = _notificationModel.itemArray.count;
    if(_notificationModel.hasMore)
        ++count;
    return count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* NotificationCell = @"NotificationCell";
    static NSString* SimpleCell = @"SimpleCell";
    if(indexPath.row < _notificationModel.itemArray.count)
    {
        SNNotificationItem* item = [_notificationModel getNotificationItem:indexPath.row];
        if(item.nickName.length > 0)
        {
            SNNotificationCell* cell = (SNNotificationCell*)[tableView dequeueReusableCellWithIdentifier:NotificationCell];
            if(cell == nil)
            {
                cell = [[SNNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NotificationCell];
            }
            [cell updateContent:item];
            return cell;
        }
        else
        {
            SNSimpleNotificationCell* cell = (SNSimpleNotificationCell*)[tableView dequeueReusableCellWithIdentifier:SimpleCell];
            if(cell == nil)
            {
                cell = [[SNSimpleNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleCell];
            }
            [cell updateContent:item];
            return cell;
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SNNotificationItem* item = [_notificationModel.itemArray objectAtIndex:[indexPath row]];
    if(item.url.length > 0)
    {
        [SNUtility openProtocolUrl:item.url context:@{ @"from" : NSStringFromClass([self class]) }];
    }
    /*
    SNNotificationItem* item = [[SNNotificationModel shareNotificationModel].itemArray objectAtIndex:[indexPath row]];
    NSString* pid = item.dataPid;
    int type = [item.type intValue];
    switch (type)
    {
        case 1:
        case 2:
        case 3:
        {
            //android平台使用，ios不做处理
            break;
        }
        case 21:
        case 22:
        case 23:
        {
            //打开个人中心页面
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: pid, @"pid", nil];
            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:_urlAction];
            break;
        }
        default:
        {
            //升级页面
        }
            break;
    }*/
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < _notificationModel.itemArray.count)
    {
        SNNotificationItem* item = [_notificationModel getNotificationItem:indexPath.row];
        if(item)
            return item.height;
        else
            return kSNNotificationCellHight;
    }
    return kSNNotificationCellHight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma mark UIScrollViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    
	if (scrollView.dragging && !_isLoading) {
//		if (scrollView.contentOffset.y+_tableView.contentInset.top> kRefreshDeltaY
//			&& scrollView.contentOffset.y+_tableView.contentInset.top < 0.0f) {
//            
//            if (_shouldUpdateRefreshTime) {
//                NSDate* date = [_notificationModel getLastRefreshDate];
//                if (date) {
//                    [_headerView setUpdateDate:date];
//                } else {
//                    [_headerView setCurrentDate];
//                }
//                _shouldUpdateRefreshTime = NO;
//            }
//            
//			[_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
//			
//		} else if (scrollView.contentOffset.y+_tableView.contentInset.top < kRefreshDeltaY) {
//            
//			[_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
//            
//		}
        if ((scrollView.contentOffset.y+scrollView.contentInset.top) > -[_dragLoadingView minDistanceCanReleaseToReload]) {
            _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        } else {
            _dragLoadingView.status = SNTwinsLoadingStatusReleaseToReload;
        }
	}
	
	// This is to prevent odd behavior with plain table section headers. They are affected by the
	// content inset, so if the table is scrolled such that there might be a section header abutting
	// the top, we need to clear the content inset.
//	if (_isLoading) {
//		if (scrollView.contentOffset.y + _tableView.contentInset.top>= 0) {
//			_tableView.contentInset = UIEdgeInsetsMake(kHeadSelectViewHeight, 0, kToolbarViewHeight, 0);;
//			
//		} else if (scrollView.contentOffset.y + _tableView.contentInset.top< 0) {
//			_tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight, 0, 0, 0);
//		}
//	}
    
    //    SNDebugLog(@"scrollView.dragging %d && canLoadMore %d && isScrollingDown %d && _model.isLoading %d ", scrollView.dragging, canLoadMore, isScrollingDown, _model.isLoading);
    //SNDebugLog(@"size: %f offset: %f head: %f", scrollView.contentSize.height, scrollView.contentOffset.y, _headerView.height);
    if (scrollView.dragging && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height + 20 && _notificationModel.hasMore && !_isLoading) {
        [self loadMore];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
	
	// If dragging ends and we are far enough to be fully showing the header view trigger a
	// load as long as we arent loading already
	if (scrollView.contentOffset.y+_tableView.contentInset.top<= kRefreshDeltaY && !_isLoading) {
        [self refresh];
	}
    
    _shouldUpdateRefreshTime = YES;
}


- (void)modelDidStartLoad {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        return;
    }
    if (_isLoadingMore) {
        //[_moreCell showLoading:YES];
        
    } else {
//        [_headerView setStatus:TTTableHeaderDragRefreshLoading];
        _dragLoadingView.status = SNTwinsLoadingStatusLoading;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
        
        // Grab the last refresh date if there is one.
//        NSDate *date = [_notificationModel getLastRefreshDate];
//        if (date) {
//            [_headerView setUpdateDate:date];
//        }
        _isLoading = YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad {
    _loading.status = SNTripletsLoadingStatusStopped;
    if (_isLoadingMore) {
        //[_moreCell showLoading:NO];
        _isLoadingMore = NO;
        //[_moreCell setHasNoMore:!_notificationModel.hasMore];
    } else {
//        [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
        _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarHeightWithoutShadow, 0);
        [UIView commitAnimations];
        
//        NSDate *date = [_notificationModel getLastRefreshDate];
//        if (date) {
//            [_headerView setUpdateDate:date];
//        } else {
//            [_headerView setCurrentDate];
//        }
        _isLoading = NO;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFailLoadWithError {
    _loading.status = SNTripletsLoadingStatusNetworkNotReachable;
    if (_isLoadingMore) {
        //[_moreCell showLoading:NO];
        _isLoadingMore = NO;
        //[_moreCell setHasNoMore:!_notificationModel.hasMore];
    } else {
//        [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
        _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarViewHeight * 2, 0);
        [UIView commitAnimations];
        _isLoading = NO;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad {
    if (_isLoadingMore) {
        //[_moreCell showLoading:NO];
        _isLoadingMore = NO;
        //[_moreCell setHasNoMore:!_notificationModel.hasMore];
    } else {
//        [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
        _dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(kHeadSelectViewHeight, 0, kToolbarViewHeight, 0);
        if (_tableView.contentOffset.y+_tableView.contentInset.top < 0) {
            _tableView.contentOffset = CGPointMake(0, -kHeadSelectViewHeight);
        }
        [UIView commitAnimations];
        _isLoading = NO;
    }
}

#pragma mark - SNTripletsLoadingViewDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    [self refresh];
    _loading.status = SNTripletsLoadingStatusLoading;
}

@end
