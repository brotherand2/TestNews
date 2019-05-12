//
//  SNLiveRoomTableViewController.m
//  sohunews
//
//  Created by chenhong on 13-4-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomTableViewController.h"
#import "SNLiveRoomViewController.h"
#import "SNLiveSubscribeService.h"
#import "SNStatusBarMessageCenter.h"
#import "UIColor+ColorUtils.h"
#import "SNLiveLoadMoreCell.h"
#import "SNLiveRoomContentCell.h"
#import "SNLiveRoomCommentCell.h"
#import "SNLiveRoomCommentRightCell.h"
#import "SNLiveRoomContentCellVideoCache.h"
#import "SNLiveRoomTableHeaderDragRefreshView.h"
#import "SNGalleryPhotoView.h"

#import "SNADReport.h"

#define REFRESH_TIMER_INTERVAL 45
#define REFRESH_TIMER_INTERVAL_30 30

// override
#define kEmptyViewTag     (1001)
#define kErrorViewTag     (1002)
#define kImageViewTag     (1003)
#define kDownloadBtnTag   (1004)

#pragma mark -

@interface SNLiveRoomTableViewController () {
    SNLiveRoomTableHeaderDragRefreshView *_headerView;
    SNLiveRoomModel *_model;
    BOOL _shouldUpdateRefreshTime;
    BOOL _isLoading;
    BOOL _isLoadingMore;
    BOOL _bHasSubscribed;
    BOOL _isCellAnimating; //cell动画未结束

    SNLiveContentViewMode _mode; //0-直播 1-聊天

    SNLiveLoadMoreCell *_moreCell;
    
    SNGalleryPhotoView *_imageDetailView;
    
    CGFloat _scrollOffsetLiveContent;
    CGFloat _scrollOffsetLiveComment;
    
    NSString *_liveId;
    
    NSTimer  *_refreshTimer;
    NSTimer *_insertItemTimer;

    UITapGestureRecognizer *_singleTap; // 收起键盘
    
    BOOL _hideTitleFlag;
    
    NSUInteger _pusNumber;
    NSUInteger _pushMaxValue;
    
    NSMutableArray *_receiveAdContentObjArr;
    NSMutableArray *_requestAdArr;
    
    BOOL _isRefresNews;
}

@end

@implementation SNLiveRoomTableViewController
@synthesize tableView=_tableView;
@synthesize livingGameItem;
@synthesize parentController=_parentController;
@synthesize infoObject=_infoObject;

- (id)initWithMatchInfoObj:(SNLiveContentMatchInfoObject *)infoObj livingGameItem:(LivingGameItem *)gameItem mode:(SNLiveContentViewMode)mode {
    self = [super init];
    if (self) {
        self.infoObject = infoObj;
        
        self.livingGameItem = gameItem;
        
        _liveId = [gameItem.liveId copy];
        
        _mode = mode;
        
        _bHasSubscribed = [[SNLiveSubscribeService sharedInstance] hasLiveGameSubscribed:_liveId];
        
		self.hidesBottomBarWhenPushed = YES;
        
        _pusNumber = 0;
        _pushMaxValue = 10;
        _receiveAdContentObjArr = [[NSMutableArray alloc] initWithCapacity:20];
        _requestAdArr = [[NSMutableArray alloc] initWithCapacity:20];
        _isRefresNews = NO;
    }
    return self;
}

- (void)dealloc {
    [_headerView removeObserver];
    [_model cancel];
    TT_INVALIDATE_TIMER(_refreshTimer);
    TT_INVALIDATE_TIMER(_insertItemTimer);

    // 处理request的deleagte 出现过crash: adModel未释放，网络回调后继续delegate 但当前vc已经被释放了
    for (SNLiveRoomRollAdModel *adModel in _requestAdArr) {
        if ([adModel isKindOfClass:[SNLiveRoomRollAdModel class]]) {
            adModel.delegate = nil;
        }
    }
}

- (void)loadView {
	[super loadView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
        
    // 下拉刷新
    _headerView = [[SNLiveRoomTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0, -_tableView.bounds.size.height, _tableView.width, _tableView.bounds.size.height)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
    [_tableView addSubview:_headerView];

    if (_model == nil) {
        _model = [[SNLiveRoomModel alloc] initWithLiveId:_liveId type:(_mode == LIVE_MODE ? @"1" : @"0")];
        _model.matchInfo = self.infoObject;
        _model.delegate = self;
    }
    
    NSDate* date = [_model refreshedTime];
    [_headerView setUpdateDate:date];
}

- (void)addTableHeader:(float)height {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, height)];
    headerView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = headerView;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(height, 0, 0, 0);
}

- (void)removeTableHeader {
    _tableView.tableHeaderView = nil;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)refresh {
    if (_isLoading) {
        return;
    }
    [self modelDidStartLoad];
    [_model refresh];
    [self showError:NO];
}

- (void)loadMore {
    if (!_isLoadingMore && !_model.isLoading) {
        _isLoadingMore = YES;
        [_model loadMore];
        [self modelDidStartLoad];
    }
}

- (void)changeViewBg {
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    _tableView.backgroundColor = self.view.backgroundColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTheme];
    [self refresh];
}

- (void)viewDidUnload {

    _isLoading = NO;
    _isLoadingMore = NO;

    [_model cancel];

    TT_INVALIDATE_TIMER(_refreshTimer);
    TT_INVALIDATE_TIMER(_insertItemTimer);

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [self canShowModel]; 
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_refreshTimer.isValid || !_insertItemTimer.isValid) {
        [self launchTimer];
    }
    [self checkNetConnection:nil];
}

- (void)refreshTableViewDataWhenAppBecomeActive {
    if (!_refreshTimer.isValid || !_insertItemTimer.isValid) {
        [self launchTimer];
    }
    [self checkNetConnection:nil];
}

-(void)updateTheme:(NSNotification *)notification {
    [self customTheme];
}

-(void)customTheme {
    [self changeViewBg];
}

# pragma mark - 网络错误界面
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
	if (show) {
        BOOL canShowModel = ([_model getObjectsArray].count > 0);
        
		if (!canShowModel) {
            UIView *errorView = [self.tableView viewWithTag:kErrorViewTag];
            if (errorView) {
                [errorView removeFromSuperview];
            }
            
            UIImage* image = [self imageForError:nil];
            errorView = [[UIImageView alloc] initWithImage:image];
            errorView.clipsToBounds = YES;
            errorView.contentMode = UIViewContentModeCenter;
            errorView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;
            errorView.center = CGPointMake(self.tableView.width/2, self.tableView.height/2);
            
            errorView.tag = kErrorViewTag;
            
            [self.tableView addSubview:errorView];
		}
	} else {
		UIView *errorView = [self.tableView viewWithTag:kErrorViewTag];
		if (errorView) {
            [errorView removeFromSuperview];
        }
	}
}

- (BOOL)canShowModel {
    NSUInteger count = [_model getObjectsArray].count;
    BOOL canShowModel = (count > 0);
    
    [self showCustomEmpty:!canShowModel];
    
    return canShowModel;
}

- (void)showCustomEmpty:(BOOL)show {
    if (_mode == LIVE_MODE) {
        [self showEmptyLiveMode:show];
    } else {
        [self showEmptyChatMode:show];
    }
}

- (UIImage*)imageForEmpty {
    NSString *name = ([_model.type intValue] == 1 ? ([_infoObject isMediaLiveMode] ? @"live_tab_empty.png" : @"live_channel_empty.png") : @"mycomment_empty.png");
	return [UIImage imageNamed:name];
}

- (UIImage*)imageForError:(NSError*)error {
	return [UIImage imageNamed:@"tb_error_bg.png"];
}

- (void)showEmptyChatMode:(BOOL)show {
    if (show) {
        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            UIView *emptyView = [self.tableView viewWithTag:kEmptyViewTag];
            if (emptyView) {
                [emptyView removeFromSuperview];
            }

            UIImage* image = [self imageForEmpty];
            emptyView = [[UIImageView alloc] initWithImage:image];
            emptyView.clipsToBounds = YES;
            emptyView.contentMode = UIViewContentModeCenter;
            emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;
            emptyView.center = CGPointMake(self.tableView.width/2, self.tableView.height/2);

            emptyView.tag = kEmptyViewTag;
            
            [self.tableView addSubview:emptyView];
            
        } else {
            UIView *emptyView = [self.tableView viewWithTag:kEmptyViewTag];
            if (emptyView) {
                [emptyView removeFromSuperview];
            }
            [self showError:YES];
        }
	} else {
        UIView *emptyView = [self.tableView viewWithTag:kEmptyViewTag];
        if (emptyView) {
            [emptyView removeFromSuperview];
        }
        [self showError:NO];
	}
}

- (void)showEmptyLiveMode:(BOOL)show {
    if (show) {
        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            
            UIView *emptyView = (UIView *)[self.tableView viewWithTag:kEmptyViewTag];
            if (emptyView) {
                [emptyView removeFromSuperview];
            }
            
            if ([_infoObject.liveStatus intValue] != WAITING_STATUS) {
                [self showEmptyChatMode:show];
                return;
            }
            
            emptyView = [[UIView alloc] initWithFrame:self.tableView.frame];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            NSString *btnTitle = _bHasSubscribed ? NSLocalizedString(@"unsubscribeLive", @"unsubscribe") : NSLocalizedString(@"subscribeLive", @"subscribe");
            [btn setTitle:btnTitle forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(1, 24, 0, 0)];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [btn setTitleColor:RGBCOLOR(208, 0, 0) forState:UIControlStateNormal];
            
            NSString *btnImgName = _bHasSubscribed ? @"live_subscribe_btn.png" : @"live_unsubscribe_btn.png";
            NSString *btnImgHLName = _bHasSubscribed ? @"live_subscribe_btn_hl.png" : @"live_unsubscribe_btn_hl.png";
           
            UIImage *btnImg = [UIImage imageNamed:btnImgName];
            UIImage *btnImgHL = [UIImage imageNamed:btnImgHLName];
            [btn setBackgroundImage:btnImg forState:UIControlStateNormal];
            [btn setBackgroundImage:btnImgHL forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(subscribeGame:) forControlEvents:UIControlEventTouchUpInside];
            [emptyView addSubview:btn];

            emptyView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
            
            CGRect frame = self.tableView.frame;
            emptyView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            emptyView.tag = kEmptyViewTag;
            emptyView.contentMode = UIViewContentModeCenter;
            emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;
            [self.tableView addSubview:emptyView];
            
            btn.frame = CGRectMake((TTScreenBounds().size.width - btnImg.size.width)/2, (emptyView.frame.size.height-40-btn.size.height)/2, btnImg.size.width, btnImg.size.height);
            
            btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            
        } else {
            UIView *emptyView = [self.tableView viewWithTag:kEmptyViewTag];
            if (emptyView) {
                [emptyView removeFromSuperview];
            }
            [self showError:YES];
        }
	} else {
        UIView *emptyView = [self.tableView viewWithTag:kEmptyViewTag];
        if (emptyView) {
            [emptyView removeFromSuperview];
        }
        [self showError:NO];
	}
}

- (void)subscribeGame:(id)sender {
    if (_bHasSubscribed) {
        // 取消提醒
        BOOL bSuccess = [[SNLiveSubscribeService sharedInstance] unsubscribeLiveGame:_liveId];
        
        if (bSuccess) {
            _bHasSubscribed = !_bHasSubscribed;
            [self showCustomEmpty:YES];

            [SNNotificationManager postNotificationName:kLiveSubscribeChangedNotification object:nil userInfo:@{@"liveId": _liveId}];
        }
    } else {
        // 比赛提醒
        BOOL bSuccess = [[SNLiveSubscribeService sharedInstance] subscribeWithLiveGame:self.livingGameItem];
        
        if (bSuccess) {
            _bHasSubscribed = !_bHasSubscribed;
            [self showCustomEmpty:YES];
            
            [SNNotificationManager postNotificationName:kLiveSubscribeChangedNotification object:nil userInfo:@{@"liveId": _liveId}];
        }
    }
}

- (void)checkNetConnection:(NSTimer *)timer{
    if (!_model.isLoading) {
        // 比赛已开始
        if ([[NSDate date] timeIntervalSince1970] > [self.livingGameItem.liveTime longLongValue]/1000) {
            // 重连
            SNDebugLog(@"try to connect again");
            [self updateLatest];
        }
    }
}

- (void)updateLatest {
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    BOOL bKeepTableDataUnchanged = _tableView.contentOffset.y > 100 || [contextMenu isMenuVisible] || _isCellAnimating;
    
    if (!bKeepTableDataUnchanged) {
        _isRefresNews =YES;
        [self refresh];
    }
}

- (void)handleReceiveItemTimer:(NSTimer*)timer{
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    BOOL bKeepTableDataUnchanged = _tableView.contentOffset.y > 100 || [contextMenu isMenuVisible] ||
                                    self.tableView.isDragging || _isCellAnimating;

    BOOL bFocus = [self isFocus];
    
    if (!bKeepTableDataUnchanged) {
        if ([_model getReceivedItemsCount] >= 10) {
            [_model mergeReceivedItemsWithModelArray];
            [self.tableView reloadData];

            if (bFocus) {
                [self showMark:NO];
            } else {
                [self showMark:YES];
            }
            
            if ([_parentController respondsToSelector:@selector(stopPlayingVideoInCellWhenReloadData:)]) {
                SNDebugLog(@"INFO: Stop playing when reload, normal handleReceiveItemTimer...");
                [_parentController stopPlayingVideoInCellWhenReloadData:self];
            }
            
            SNDebugLog(@"mergeAll: %d", [_model getReceivedItemsCount]);            
        } else {
            SNLiveContentObject * lastItem = [_model extractLastReceivedItem];
            if (lastItem) {
                
                //lijian 2015.04.04 如果收到有效push，则报告
                if([_model.type intValue] == 1){
                    [self receivedLiveContentPush];
                }
                
                [[_model getObjectsArray] insertObject:lastItem atIndex:0];
                
                @try {
                    _isCellAnimating = YES;
                    [CATransaction begin];
                    [CATransaction setCompletionBlock: ^{
                        _isCellAnimating = NO;
                    }];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [CATransaction commit];
                }
                @catch (NSException *exception) {
                    _isCellAnimating = NO;
                    
                    [_tableView reloadData];
                    if ([_parentController respondsToSelector:@selector(stopPlayingVideoInCellWhenReloadData:)]) {
                        SNDebugLog(@"INFO: Stop playing when reload, exception handleReceiveItemTimer...");
                        [_parentController stopPlayingVideoInCellWhenReloadData:self];
                    }
                    
                    SNDebugLog(@"### insertRowsAtIndexPaths:withRowAnimation: with exception %@", exception);
                }
                
                if (bFocus) {
                    [self showMark:NO];
                } else {
                    [self showMark:YES];
                }
            } else {
                
                if (bFocus) [self showMark:NO];
            }
        }
    } else {
        if ([_model getReceivedItemsCount] > 0) {
            [self showMark:YES];
        }
    }
}

- (void)showMark:(BOOL)bShow {
    if (_mode == LIVE_MODE) {
        [_parentController showPopNewMarkAtLive:bShow];
    } else {
        [_parentController showPopNewMarkAtChat:bShow];
    }
}

- (BOOL)isFocus {
    LiveTableEnum tabType = [_parentController currentTabType];
    if (_mode == LIVE_MODE) {
        return tabType == kLiveTableTab;
    } else if (_mode == CHAT_MODE) {
        return tabType == kChatTableTab;
    }
    return NO;
}

- (void)onReceivedModelItems {
}

- (void)launchTimer {
    TT_INVALIDATE_TIMER(_refreshTimer);
    int  interval = REFRESH_TIMER_INTERVAL;
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(checkNetConnection:) userInfo:nil repeats:YES];

    TT_INVALIDATE_TIMER(_insertItemTimer);
    _insertItemTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleReceiveItemTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_insertItemTimer forMode:NSRunLoopCommonModes];
}

- (void)destroyTimer {
    TT_INVALIDATE_TIMER(_refreshTimer);
    TT_INVALIDATE_TIMER(_insertItemTimer);
}

#pragma mark - UIScrollViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    
	if (scrollView.dragging && !_isLoading) {
		if (scrollView.contentOffset.y > kLiveRefreshDeltaY
			&& scrollView.contentOffset.y < 0.0f) {
            
            if (_shouldUpdateRefreshTime) {
                NSDate* date = [_model refreshedTime];
                if (date) {
                    [_headerView setUpdateDate:date];
                } else {
                    [_headerView setCurrentDate];
                }
                _shouldUpdateRefreshTime = NO;
            }
            
			[_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
			
		} else if (scrollView.contentOffset.y < kLiveRefreshDeltaY) {
            
			[_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
            
		}
	}
	
	if (_isLoading) {
		if (scrollView.contentOffset.y >= 0) {
			_tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
			
		} else if (scrollView.contentOffset.y < 0) {
			_tableView.contentInset = UIEdgeInsetsMake(kLiveHeaderVisibleHeight, 0, kToolbarViewHeight, 0);
		}
	}
    
    if (scrollView.dragging && [_model getObjectsArray].count > 0 && scrollView.contentOffset.y > scrollView.contentSize.height - _headerView.height + 20 && !_model.hasNoMore && !_model.isLoading) {
        [self loadMore];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
	
	// If dragging ends and we are far enough to be fully showing the header view trigger a
	// load as long as we arent loading already
	if (scrollView.contentOffset.y <= kLiveRefreshDeltaY && !_isLoading) {
        [self refresh];
	}
    
    _shouldUpdateRefreshTime = YES;
    
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if ([contextMenu isMenuVisible]) {
        [contextMenu setMenuVisible:NO];
    }
}

- (void)modelDidStartLoad {
    
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        return;
    }
    if (_isLoadingMore) {
        [_moreCell showLoading:YES];
        
    } else {
        [_headerView setStatus:TTTableHeaderDragRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
        
        if (_tableView.contentOffset.y < 0) {
            _tableView.contentInset = UIEdgeInsetsMake(kLiveHeaderVisibleHeight, 0.0f, kToolbarViewHeight, 0.0f);
        }
        [UIView commitAnimations];
        
        
        _tableView.contentInset = UIEdgeInsetsMake(kLiveHeaderVisibleHeight, 0.0f, kToolbarViewHeight, 0.0f);
        
        // Grab the last refresh date if there is one.
        NSDate *date = [_model refreshedTime];
        if (date) {
            [_headerView setUpdateDate:date];
        }
        _isLoading = YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad {
    if (_isLoadingMore) {
        [_moreCell showLoading:NO];
        _isLoadingMore = NO;
        [_moreCell setHasNoMore:_model.hasNoMore];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        
        _tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
        if (_tableView.contentOffset.y < 0) {
            _tableView.contentOffset = CGPointZero;
        }
        [UIView commitAnimations];
        
        NSDate *date = [_model refreshedTime];
        if (date) {
            [_headerView setUpdateDate:date];
        } else {
            [_headerView setCurrentDate];
        }
        _isLoading = NO;
        });
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFailLoadWithError:(NSError *)error {
    if (_isLoadingMore) {
        [_moreCell showLoading:NO];
        _isLoadingMore = NO;
        [_moreCell setHasNoMore:_model.hasNoMore];
    } else {
        [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
        if (_tableView.contentOffset.y < 0) {
            _tableView.contentOffset = CGPointZero;
        }
        [UIView commitAnimations];
        _isLoading = NO;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad {
    if (_isLoadingMore) {
        [_moreCell showLoading:NO];
        _isLoadingMore = NO;
        [_moreCell setHasNoMore:_model.hasNoMore];
    } else {
        [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
        if (_tableView.contentOffset.y < 0) {
            _tableView.contentOffset = CGPointZero;
        }
        [UIView commitAnimations];
        _isLoading = NO;
    }
}

#pragma mark - table datasource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_model getObjectsArray].count) {
        id obj = [[_model getObjectsArray] objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[SNLiveContentObject class]]) {
            return [SNLiveRoomContentCell tableView:tableView rowHeightForObject:obj];
        } else if ([obj isKindOfClass:[SNLiveCommentObject class]]) {
            return [SNLiveRoomCommentCell tableView:tableView rowHeightForObject:obj];
        }
    }else {
        return [SNLiveLoadMoreCell height];
    }
    return 0;
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
    NSUInteger num = [_model getObjectsArray].count;
    if (num > 0) {
        num += 1;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *contentCellIdentifier = @"ContentCell";
    static NSString *commentCellIdentifier = @"CommentCell";
    static NSString *mycommentCellIdentifier = @"MyCommentCell";
    
    if (indexPath.row < [_model getObjectsArray].count) {
        id obj = [[_model getObjectsArray] objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[SNLiveContentObject class]]) {
            SNLiveRoomContentCell *cell = (SNLiveRoomContentCell *)[tableView dequeueReusableCellWithIdentifier:contentCellIdentifier];
            if (cell == nil) {
                cell = [[SNLiveRoomContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentCellIdentifier];
                cell.viewController = self;
            }
            cell.object = obj;
            cell.tableViewController = self;
            return cell;
        } else if ([obj isKindOfClass:[SNLiveCommentObject class]]) {
            SNLiveRoomCommentCell *cell = nil;
            if ([(SNLiveCommentObject *)obj isMyComment]) {
                cell = (SNLiveRoomCommentRightCell *)[tableView dequeueReusableCellWithIdentifier:mycommentCellIdentifier];
                if (cell == nil) {
                    cell = [[SNLiveRoomCommentRightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mycommentCellIdentifier];
                    cell.viewController = self;
                }
            } else {
                cell = (SNLiveRoomCommentCell *)[tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
                if (cell == nil) {
                    cell = [[SNLiveRoomCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIdentifier];
                    cell.viewController = self;
                }
            }

            cell.object = obj;
            cell.tableViewController = self;
            return cell;
        }
    } else {
        if (_moreCell == nil) {
            _moreCell = [[SNLiveLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
        }
        return _moreCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[SNLiveLoadMoreCell class]]) {
        if (!_isLoadingMore) {
            [_moreCell showLoading:NO];
            [_moreCell setHasNoMore:_model.hasNoMore];
        } else {
            [_moreCell showLoading:YES];
        }
        
        if (!_model.hasNoMore) {
            //[self loadMore];
        }
    }
    
    //当cell将要可见时，在插入新cell后，如果visible cell中有正在播视频的cell则更新videoPlayer的frame
    if ([cell isKindOfClass:[SNLiveRoomContentCell class]]
        && [_parentController respondsToSelector:@selector(tableViewController:whetherShowVideoPlayerByCell:)]) {
        //SNDebugLog(@"INFO: Will display cell...");
        [_parentController tableViewController:self whetherShowVideoPlayerByCell:(SNLiveRoomContentCell *)cell];
    }
}

//iOS 6.0以前此方向会被cell手动回调到这里
- (void)didEndDisplayingCell:(UITableViewCell *)cell {
    [self tableView:self.tableView didEndDisplayingCell:cell forRowAtIndexPath:[self.tableView indexPathForCell:cell]];
}

//iOS 6.0及以上，此方向会被回调
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([cell isKindOfClass:[SNLiveRoomContentCell class]]
        && [_parentController respondsToSelector:@selector(tableViewController:didEndDisplayingCell:)]) {
        [_parentController tableViewController:self didEndDisplayingCell:(SNLiveRoomContentCell *)cell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reloadRowByContentObj:(id)obj {
    NSEnumerator *enumerator = [_model getObjectsArray].objectEnumerator;
    id nextObj;
    int index = 0;
    
    while (nextObj = [enumerator nextObject]) {
        if (obj == nextObj) {
            break;
        }
        ++index;
    }
    
    if (index < [_model getObjectsArray].count) {
        dispatch_async(dispatch_get_main_queue(),  ^{
           [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

#pragma mark - model delegate
- (void)liveRoomDidFinishLoad {
    [self.tableView reloadData];
    
    if ([_parentController respondsToSelector:@selector(stopPlayingVideoInCellWhenReloadData:)]) {
        SNDebugLog(@"INFO: Stop playing short video when reload, liveRoomDidFinishLoad...");
        [_parentController stopPlayingVideoInCellWhenReloadData:self];
    }
    
    [self modelDidFinishLoad];
    if ([_model getObjectsArray].count == 0) {
        [self showCustomEmpty:YES];
    } else {
        [self showCustomEmpty:NO];
    }

}

- (void)liveRoomDidFailLoadWithError:(NSError *)error {
    [self modelDidFailLoadWithError:error];
    if ([_model getObjectsArray].count == 0) {
        [self showError:YES];
    }
}

- (void)liveRoomDidCancelLoad {
    [self modelDidCancelLoad];
}

- (void)receivedLiveContentPush
{
    NSInteger firstAd = [self searchFirstAdIndex:_model.contentsArray]; //-1代表没找到，

    if(0 == _pushMaxValue){
        return;
    }
    
    if(firstAd >= _pushMaxValue - 1){
        SNLiveRoomRollAdModel *adModel = [[SNLiveRoomRollAdModel alloc] initWithLiveId:_liveId];
        adModel.delegate = self;
        [adModel requestAdvertising];
        adModel.isLoadMore = NO;
        
        [_requestAdArr addObject:adModel];
    }
}

- (void)liveRoomFirstToRequestAd:(NSInteger)count;
{
    //lijian 2015.04.04 只对直播加载广告
    if (_mode == LIVE_MODE) {
        for(int i = 0;i < count;i++)
        {
            SNLiveRoomRollAdModel *adModel = [[SNLiveRoomRollAdModel alloc] initWithLiveId:_liveId];
            adModel.delegate = self;
            [adModel requestAdvertising];
            [_requestAdArr addObject:adModel];
            adModel.isFirstLoad = YES;
        }
    }
}

- (void)liveRoomloadMore:(NSInteger)loadNum firstContentID:(long long)contentID;
{
    if(loadNum > 0){
        NSInteger loop = (loadNum + _pushMaxValue - 1 )/ _pushMaxValue;
        for (int i = 0; i < loop; i++) {
            SNLiveRoomRollAdModel *adModel = [[SNLiveRoomRollAdModel alloc] initWithLiveId:_liveId];
            adModel.delegate = self;
            [adModel requestAdvertising];
            
            adModel.isLoadMore = YES;
            adModel.loadNum = loadNum;
            adModel.searchContentID = contentID;
            
            [_requestAdArr addObject:adModel];
        }
    }
}

//lijian 2015.04.04
//该调用广告了
#pragma mark - SNLiveRoomRollAdModelDelegate
- (void)liveRoomRollAdShouldThrowAdvertising:(NSArray *)array maxNumber:(NSUInteger)maxNum;
{
    if(0 == maxNum)
        return;
    
    _pushMaxValue = maxNum;
    
    NSInteger firstAd = [self searchFirstAdIndex:_model.contentsArray]; //-1代表没找到
    [_receiveAdContentObjArr addObjectsFromArray:array];
    
    if(firstAd >= _pushMaxValue){
        
        for (SNLiveRollAdContentObject * adObj in _receiveAdContentObjArr) {
            //插入的
            if(YES == adObj.isPushAd){
                NSInteger insertPos = 0;
                //如果小于0，表示没找到，则在第一条加入广告
                if(firstAd < (NSInteger)adObj.step){
                    return;
                }else{
                    if((firstAd - (NSInteger)adObj.step) >= 0){
                        
                        SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:(firstAd - adObj.step)];
                        if(nil != obj){
                            adObj.contentId = obj.contentId;
                        }
                        insertPos = (firstAd - adObj.step);
                        [_model.contentsArray insertObject:adObj atIndex:(firstAd - adObj.step)];
                    }else{
                        return;
                    }
                    
                }
                //曝光
                [SNADReport reportExposure:adObj.adInfo.reportID];
                @try {
                    _isCellAnimating = YES;
                    [CATransaction begin];
                    [CATransaction setCompletionBlock: ^{
                        _isCellAnimating = NO;
                    }];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertPos inSection:0];
                    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    [CATransaction commit];
                }
                @catch (NSException *exception) {
                    _isCellAnimating = NO;
                    
                    [_tableView reloadData];
                    if ([_parentController respondsToSelector:@selector(stopPlayingVideoInCellWhenReloadData:)]) {
                        SNDebugLog(@"INFO: Stop playing when reload, exception handleReceiveItemTimer...");
                        [_parentController stopPlayingVideoInCellWhenReloadData:self];
                    }
                    
                    SNDebugLog(@"### insertRowsAtIndexPaths:withRowAnimation: with exception %@", exception);
                }
                
                break;
            }
        }
    }
    
}

- (void)liveRoomRollAdShouldAddAdvertising:(NSArray *)array loadNum:(NSInteger)num
{
    [_receiveAdContentObjArr addObjectsFromArray:array];
    
    for (SNLiveRollAdContentObject * adObj in _receiveAdContentObjArr) {
        
        if(NO == adObj.isPushAd){
            NSInteger insertPos = 0;
            NSInteger lastAd = [self searchLastAdIndex:_model.contentsArray]; //-1代表没找到，
            //如果小于0，表示没找到，则在第一条加入广告
            if(lastAd < 0){
                SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:[_model.contentsArray count]-1];
                if(nil != obj){
                    adObj.contentId = obj.contentId;
                }
                [_model.contentsArray insertObject:adObj atIndex:[_model.contentsArray count]];
                insertPos = [_model.contentsArray count];
            }else{
                if(lastAd + adObj.step + 1 < [_model.contentsArray count]){
                    
                    SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:(lastAd + adObj.step + 1)];
                    if(nil != obj){
                        adObj.contentId = obj.contentId;
                    }
                    [_model.contentsArray insertObject:adObj atIndex:(lastAd + adObj.step + 1)];
                    insertPos = (lastAd + adObj.step + 1);
                }else{
                    return;
                }
            }
            
            //曝光
            [SNADReport reportExposure:adObj.adInfo.reportID];

            @try {
                _isCellAnimating = YES;
                [CATransaction begin];
                [CATransaction setCompletionBlock: ^{
                    _isCellAnimating = NO;
                }];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertPos inSection:0];
                [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [CATransaction commit];
            }
            @catch (NSException *exception) {
                _isCellAnimating = NO;
                
                [_tableView reloadData];
                if ([_parentController respondsToSelector:@selector(stopPlayingVideoInCellWhenReloadData:)]) {
                    SNDebugLog(@"INFO: Stop playing when reload, exception handleReceiveItemTimer...");
                    [_parentController stopPlayingVideoInCellWhenReloadData:self];
                }
                
                SNDebugLog(@"### insertRowsAtIndexPaths:withRowAnimation: with exception %@", exception);
            }
            
            [_receiveAdContentObjArr removeObject:adObj];
            break;
        }
    }
}

- (void)liveRoomRollAdShouldInsertFirstLoadAdvertising:(NSArray *)array
{
    [_receiveAdContentObjArr addObjectsFromArray:array];
    
    for (SNLiveRollAdContentObject * adObj in _receiveAdContentObjArr)
    {
        if([_model.contentsArray count] > 0)
        {
            NSInteger insertPos = 0;
            NSInteger firstAd = [self searchLastAdIndex:_model.contentsArray]; //-1代表没找到，
            //如果小于0，表示没找到，则在第一条加入广告
            if(firstAd < 0){
                SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:[_model.contentsArray count]-1];
                if(nil != obj){
                    adObj.contentId = obj.contentId;
                }
                insertPos = [_model.contentsArray count];
                [_model.contentsArray insertObject:adObj atIndex:[_model.contentsArray count]];
            }else{
                if((firstAd - (NSInteger)adObj.step) >= 0){

                    SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:(firstAd - adObj.step)];
                    if(nil != obj){
                        adObj.contentId = obj.contentId;
                    }
                    insertPos = (firstAd - adObj.step);
                    [_model.contentsArray insertObject:adObj atIndex:(firstAd - adObj.step)];
                }else{
                    return;
                }
                
            }
            
            //曝光
            [SNADReport reportExposure:adObj.adInfo.reportID];
            
            @try {
                _isCellAnimating = YES;
                [CATransaction begin];
                [CATransaction setCompletionBlock: ^{
                    _isCellAnimating = NO;
                }];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertPos inSection:0];
                [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [CATransaction commit];
            }
            @catch (NSException *exception) {
                _isCellAnimating = NO;
                
                [_tableView reloadData];
                if ([_parentController respondsToSelector:@selector(stopPlayingVideoInCellWhenReloadData:)]) {
                    SNDebugLog(@"INFO: Stop playing when reload, exception handleReceiveItemTimer...");
                    [_parentController stopPlayingVideoInCellWhenReloadData:self];
                }
                
                SNDebugLog(@"### insertRowsAtIndexPaths:withRowAnimation: with exception %@", exception);
            }
            [_tableView reloadData];
            [_receiveAdContentObjArr removeObject:adObj];
            break;
        }
    }
}

- (void)insertAdContentObjLoadNum:(NSInteger)num
{
    for (SNLiveRollAdContentObject * adObj in _receiveAdContentObjArr) {
        //插入的
        if(YES == adObj.isPushAd){
            NSInteger insertPos = 0;
            NSInteger firstAd = [self searchLastAdIndex:_model.contentsArray]; //-1代表没找到，
            //如果小于0，表示没找到，则在第一条加入广告
            if(firstAd < (NSInteger)adObj.step){
                return;
            }else{
                if((firstAd - (NSInteger)adObj.step) >= 0){
                    
                    SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:(firstAd - adObj.step)];
                    if(nil != obj){
                        adObj.contentId = obj.contentId;
                    }
                    insertPos = (firstAd - adObj.step);
                    [_model.contentsArray insertObject:adObj atIndex:(firstAd - adObj.step)];
                }else{
                    return;
                }
                
            }
            //曝光
            [SNADReport reportExposure:adObj.adInfo.reportID];
            @try {
                _isCellAnimating = YES;
                [CATransaction begin];
                [CATransaction setCompletionBlock: ^{
                    _isCellAnimating = NO;
                }];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertPos inSection:0];
                [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [CATransaction commit];
            }
            @catch (NSException *exception) {
                _isCellAnimating = NO;
                
                [_tableView reloadData];
                if ([_parentController respondsToSelector:@selector(stopPlayingVideoInCellWhenReloadData:)]) {
                    SNDebugLog(@"INFO: Stop playing when reload, exception handleReceiveItemTimer...");
                    [_parentController stopPlayingVideoInCellWhenReloadData:self];
                }
                
                SNDebugLog(@"### insertRowsAtIndexPaths:withRowAnimation: with exception %@", exception);
            }
            
            break;
        }
        //更多的
        else{
            NSInteger firstAd = [self searchLastAdIndex:_model.contentsArray]; //-1代表没找到，
            //如果小于0，表示没找到，则在第一条加入广告
            if(firstAd < 0){
                SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:[_model.contentsArray count]-1];
                if(nil != obj){
                    adObj.contentId = obj.contentId;
                }
                [_model.contentsArray insertObject:adObj atIndex:[_model.contentsArray count]];
            }else{
                if(firstAd + adObj.step + 1 < [_model.contentsArray count]){
                    
                    SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:(firstAd + adObj.step + 1)];
                    if(nil != obj){
                        adObj.contentId = obj.contentId;
                    }
                    [_model.contentsArray insertObject:adObj atIndex:(firstAd + adObj.step + 1)];
                }else{
                    return;
                }
                
            }
            [_tableView reloadData];
        }
        
        [_receiveAdContentObjArr removeObject:adObj];
        break;
    }
}

- (NSInteger)searchFirstAdIndex:(NSArray *)array
{
    if([array count] <= 0)
        return -1;
    
    for(NSInteger i = 0; i < [array count];i++)
    {
        SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:i];
        if([obj isKindOfClass:[SNLiveRollAdContentObject class]]){
            return i;
        }
    }
    
    return -1;
}

- (NSInteger)searchLastAdIndex:(NSArray *)array
{
    if([array count] <= 0)
        return -1;
    
    for(NSInteger i = [array count] - 1; i >= 0;i--)
    {
        SNLiveContentObject * obj = [_model.contentsArray objectAtIndex:i];
        if([obj isKindOfClass:[SNLiveRollAdContentObject class]]){
            return i;
        }
    }
    
    return -1;
}

- (void)liveRoomRollAdDidFinishLoad {
}
- (void)liveRoomRollAdDidFailLoadWithError:(NSError *)error {
}
- (void)liveRoomRollAdDidCancelLoad {
}

- (void)replyComment:(NSString *)rid type:(NSString *)type name:(NSString *)name pid:(NSString *)pid {
    self.parentController.replyId = rid;
    self.parentController.replyType = type;
    self.parentController.replyName = name;
    self.parentController.replyPid = pid;
    [self.parentController focusInput];
}

- (void)shareComment:(NSString *)comment {
    [self.parentController shareAction:comment];
}

- (void)shareCommentWithDic:(NSDictionary *)commentDic {
    [self.parentController shareCommentAction:commentDic];
}

- (BOOL)isLiveGameShowing:(NSString*)aLiveId {
    if ([aLiveId isEqualToString:_liveId]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)showImageWithUrl:(NSString *)urlPath {
    if (_imageDetailView == nil) {
        CGRect applicationFrame = self.parentController.flipboardNavigationController.view.bounds;
        _imageDetailView   = [[SNGalleryPhotoView alloc] initWithFrame:applicationFrame];
    }

    [_imageDetailView loadImageWithUrlPath:urlPath];
    
    [self.parentController.flipboardNavigationController.view addSubview:_imageDetailView];
    
    _imageDetailView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _imageDetailView.alpha = 1.0;
    }];
}

@end
