//
//  SNFollowingViewController.m
//  sohunews
//
//  Created by weibin cheng on 13-12-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNFollowingViewController.h"
#import "SNFollowUserService.h"
#import "SNBubbleBadgeService.h"
#import "SNBubbleBadgeObject.h"
#import "SNFollowCell.h"


@interface SNFollowingViewController ()
{
    BOOL _shouldUpdateRefreshTime;
    BOOL _isLoading;
    BOOL _isLoadingMore;
    
    
}
@property(nonatomic, strong) NSString* pid;
-(void)loadMore;
-(void)refresh;
@end

@implementation SNFollowingViewController
@synthesize pid = _pid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNavigatorURL:URL query:query];
    if(self)
    {
        self.pid = [query objectForKey:@"pid"];
        _model = [[SNFollowUserModel alloc] initWithPid:_pid];
        _model.delegate = self;
        _model.isFollowing = YES;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self refresh];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[_tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
     //(_tableView);
     //(_dragView);
     //(_loadingView);
     //(_model);
     //(_pid);
     //(_moreCell);
     //(_emptyView);
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    CGRect rect = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth, kAppScreenHeight-kHeadSelectViewBottom-kToolbarViewTop-10);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0, kToolbarViewHeight, 0);
    _tableView.contentOffset = CGPointMake(0, -kHeaderHeightWithoutBottom);

    [self.view addSubview:_tableView];
    
    _dragView = [[SNTableHeaderDragRefreshView alloc]
                   initWithFrame:CGRectMake(0,
                                            -_tableView.bounds.size.height,
                                            _tableView.width,
                                            _tableView.bounds.size.height)];
    _dragView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    [_tableView addSubview: _dragView];
    
    _loadingView = [[SNEmbededActivityIndicator alloc] initWithFrame:CGRectMake(0, -40, _tableView.width, _tableView.height) andDelegate:self];
    _loadingView.hidesWhenStopped = YES;
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [_tableView addSubview:_loadingView];
    
    [self addToolbar];
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObjects:@"关注", nil]];
}
-(void)didTapRetry
{
    [_model refresh];
    _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
    _isLoading = YES;
}
-(void)loadMore
{
    if(!_isLoading && !_isLoadingMore)
    {
        _isLoadingMore = YES;
        [_model loadMore];
    }
}
-(void)refresh
{
    if(!_isLoading && !_isLoadingMore)
    {
        [_model refresh];
        [self modelDidStartLoad];
    }
}
-(void)updateTheme:(NSNotification *)notifiction
{
    [super updateTheme:notifiction];
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    [_tableView reloadData];
    [self updateEmptyView];
}

-(void)showEmptyView
{
    if(!_emptyView)
    {
        UIImage* image = [UIImage themeImageNamed:@"circle_no_following.png"];
        _emptyView = [[UIImageView alloc] initWithImage:image];
        _emptyView.left = (_tableView.width - image.size.width)/2;
        _emptyView.top = (_tableView.height - image.size.height)/2;
        _emptyView.size = image.size;
        [_tableView addSubview:_emptyView];
    }
    _emptyView.hidden = NO;
}

-(void)hideEmptyView
{
    if(_emptyView)
        _emptyView.hidden = YES;
}
-(void)updateEmptyView
{
    if(_emptyView)
        _emptyView.image = [UIImage themeImageNamed:@"circle_no_following.png"];
}

-(UITableViewCell*)createNoMoreCell
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nomorecell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIImage* image = [UIImage themeImageNamed:@"circle_no_following_more.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, kAppScreenWidth, image.size.height);
    [cell.contentView addSubview:imageView];
    return cell;
}
-(CGFloat)noMoreCellHeight
{
    UIImage* image = [UIImage themeImageNamed:@"circle_no_following_more.png"];
    return image.size.height;
}
#pragma -mark SNFollowUserModelDelegate
-(void)requestUserModelDidFinish:(BOOL)hasMore
{
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [_tableView reloadData];
    [self modelDidFinishLoad];
    //登录用户关注第一条是添加好友
    if(_model.userArray.count <= 1 && [SNUserinfoEx isSelfUser:self.pid])
    {
        [self showEmptyView];
    }
    
    else if(_model.userArray.count == 0)
    {
        [self showEmptyView];
    }
    else
        [self hideEmptyView];
}
-(void)requestUserModelDidNetworkError:(NSError*)error
{
    [self modelDidFailLoadWithError];
    if(_model.userArray.count > 0)
    {
        _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
    else
    {
        _loadingView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
    }
    [self hideEmptyView];
}
-(void)requestUserModelDidServerError:(NSString*)msg
{
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [self modelDidFailLoadWithError];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
    [self hideEmptyView];
}

#pragma -mark UITableViewDelegate
-(void)reuseCellWithIndexPath:(NSIndexPath*)indexPath recommendUserCell:(SNFollowCell*) userCell array:(NSArray*)aArray
{
    SNUserinfoEx *user = [aArray objectAtIndex:indexPath.row];
    [userCell reuseWithUser2:user cellIndexPath:indexPath];
}

-(void)reuseCellWithIndexPathAddFriends:(NSIndexPath*)indexPath recommendUserCell:(SNFollowCell*) userCell array:(NSArray*)aArray
{
    SNUserinfoEx *user = [aArray objectAtIndex:indexPath.row];
    [userCell reuseWithUser2_addFriend:user cellIndexPath:indexPath];
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = _model.userArray.count;
    if(_model.hasMore)
        ++count;
    else if(_model.userArray.count >= 20)
        ++count;
    return count;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row < _model.userArray.count)
        return USER_CELL_TOTALHEIGHT;
    else
        return [self noMoreCellHeight];
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row < _model.userArray.count)
    {
        NSString *cellIdentifier = @"userCell";
        SNFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
            cell = [[SNFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        if(indexPath.row == 0 && [SNUserinfoEx isSelfUser:self.pid])
            [self reuseCellWithIndexPathAddFriends:indexPath recommendUserCell:cell array:_model.userArray];
        else
            [self reuseCellWithIndexPath:indexPath recommendUserCell:cell array:_model.userArray];
        
        if([SNUserinfoEx isSelfUser:self.pid])
            [cell hideFollowedLabel];
        return cell;
    }
    else
    {
        return  [self createNoMoreCell];
    }
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row==0 && [SNUserinfoEx isSelfUser:self.pid])
    {
        [[SNBubbleNumberManager shareInstance] resetFollowing];
        TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://recommendUser"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:action];
    }
    else if(indexPath.row < [_model.userArray count])
    {
        SNUserinfoEx* userinfo = (SNUserinfoEx*)[_model.userArray objectAtIndex:indexPath.row];
        if(![userinfo isKindOfClass:[SNUserinfoEx class]] || userinfo.pid.length==0)
            return;
        
        TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : userinfo.pid}] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    
	if (scrollView.dragging && !_isLoading) {
		if (scrollView.contentOffset.y+_tableView.contentInset.top> kRefreshDeltaY
			&& scrollView.contentOffset.y+_tableView.contentInset.top < 0.0f) {
            
            if (_shouldUpdateRefreshTime) {
                NSDate* date = [_model lastRequestDate];
                if (date) {
                    [_dragView setUpdateDate:date];
                } else {
                    [_dragView setCurrentDate];
                }
                _shouldUpdateRefreshTime = NO;
            }
            
			[_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
			
		} else if (scrollView.contentOffset.y+_tableView.contentInset.top < kRefreshDeltaY) {
            
			[_dragView setStatus:TTTableHeaderDragRefreshReleaseToReload];
            
		}
	}
	
	// This is to prevent odd behavior with plain table section headers. They are affected by the
	// content inset, so if the table is scrolled such that there might be a section header abutting
	// the top, we need to clear the content inset.
	if (_isLoading) {
		if (scrollView.contentOffset.y + _tableView.contentInset.top>= 0) {
			_tableView.contentInset = UIEdgeInsetsMake(kHeadSelectViewHeight, 0, kToolbarViewHeight, 0);;
			
		} else if (scrollView.contentOffset.y + _tableView.contentInset.top< 0) {
			_tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight+kHeadSelectViewHeight, 0, 0, 0);
		}
	}
    
    //    SNDebugLog(@"scrollView.dragging %d && canLoadMore %d && isScrollingDown %d && _model.isLoading %d ", scrollView.dragging, canLoadMore, isScrollingDown, _model.isLoading);
    //SNDebugLog(@"size: %f offset: %f head: %f", scrollView.contentSize.height, scrollView.contentOffset.y, _headerView.height);
    if (scrollView.dragging && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height + 20 && _model.hasMore && !_isLoading)
    {
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
    } else {
        [_dragView setStatus:TTTableHeaderDragRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
        
        if (_tableView.contentOffset.y+_tableView.contentInset.top < 0) {
            _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight+kHeadSelectViewHeight, 0.0f, 0.0f, 0.0f);
        }
        [UIView commitAnimations];
        
        
        _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight+kHeadSelectViewHeight, 0.0f, 0.0f, 0.0f);
        
        // Grab the last refresh date if there is one.
        NSDate *date = [_model lastRequestDate];
        if (date) {
            [_dragView setUpdateDate:date];
        }
        _isLoading = YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad {
    if (_isLoadingMore) {
        _isLoadingMore = NO;
    } else {
        [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        
        _tableView.contentInset = UIEdgeInsetsMake(kHeadSelectViewHeight, 0, kToolbarViewHeight, 0);;
        if (_tableView.contentOffset.y+_tableView.contentInset.top < 0) {
            _tableView.contentOffset = CGPointMake(0, -kHeadSelectViewHeight);
        }
        [UIView commitAnimations];
        
        NSDate *date = [_model lastRequestDate];
        if (date) {
            [_dragView setUpdateDate:date];
        } else {
            [_dragView setCurrentDate];
        }
        _isLoading = NO;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFailLoadWithError {
    if (_isLoadingMore) {
        _isLoadingMore = NO;
    } else {
        [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(kHeadSelectViewHeight, 0, kToolbarViewHeight, 0);;
        if (_tableView.contentOffset.y+_tableView.contentInset.top < 0) {
            _tableView.contentOffset = CGPointMake(0, -kHeadSelectViewHeight);
        }
        [UIView commitAnimations];
        _isLoading = NO;
    }
}

@end
