//
//  SNAllSubscribeTableViewController.m
//  sohunews
//
//  Created by lhp on 12/17/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNAllSubscribeTableViewController.h"
#import "SNSearchDataSource.h"
#import "SNRollingNewsTableItem.h"
#import "SNSearchScrollDelegate.h"
#import "SNTableMoreButton.h"
#import "SNWaitingActivityView.h"
#import "SNUserManager.h"

#import "SNNewsLoginManager.h"

@interface SNAllSubscribeTableViewController () {
    
    SNSearchScrollDelegate *_tableViewDelegate;
    SNSearchService *_searchService;
}

@end

#define kErrorViewTag 10010
#define kEmptyViewTag 10011
#define kLoadingViewTag 10012

@implementation SNAllSubscribeTableViewController
@synthesize subscribeArray;
@synthesize keyWord;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super init];
    if (self) {
        self.variableHeightRows = YES;
        _subsRunningOnAddToMySub = [[NSMutableArray alloc] init];
        _refer = REFER_SEARCH;
        self.keyWord = [query objectForKey:@"keyWord"];
        
        _searchService = [[SNSearchService alloc] init];
        _searchService.delegate = self;
    }
    return self;
}

- (void)addSubscribeNotification:(NSNotification *) notification
{
    SCSubscribeObject *subscribeObject = [notification object];
    if (subscribeObject) {
        [self allSubCellWillAddMySub:subscribeObject];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    self.view.backgroundColor = [UIColor colorFromString:backgroundColor];
    
    self.tableView.frame = CGRectMake(0, 20, self.view.width, TTApplicationFrame().size.height - 125);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableViewDelegate = [[SNSearchScrollDelegate alloc] init];
    _tableViewDelegate.viewController = self;
    self.tableView.delegate = _tableViewDelegate;
    
    [self addToolbar];
    
    [_searchService search:self.keyWord type:@"30"];
    [self showLoading:YES];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(addSubscribeNotification:)
                                                 name:kSearchAddSubscribeNotification
                                               object:nil];
    [SNNotificationManager addObserver:self
                                             selector:@selector(onUpdateSubItem:)
                                                 name:kSubscribeCenterMySubDidChangedNotify
                                               object:nil];
}

- (void)onUpdateSubItem:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo)
    {
        NSArray *subIdsAdded = [userInfo arrayValueForKey:kSubcenterMySubDidChangedAddedSubIdArrayKey defaultValue:nil];
        NSArray *subIdsRemoved = [userInfo arrayValueForKey:kSubcenterMySubDidChangedRemovedSubIdArrayKey defaultValue:nil];
        
        // 更新搜索列表中刊物的订阅状态
        BOOL needReload = NO;
        for (SNRollingNewsTableItem *item in self.subscribeArray) {
            if (item.type == NEWS_ITEM_TYPE_SUBSCRIBE) {
                if (item.news.subId.length) {
                    if ([subIdsAdded containsObject:item.news.subId]) {
                        item.news.isSubscribe = @"1";
                        needReload = YES;
                    } else if ([subIdsRemoved containsObject:item.news.subId]) {
                        item.news.isSubscribe = @"0";
                        needReload = YES;
                    }
                } // if
            } else {
                break; //订阅类型位于列表前面
            }
        } // for
        
        if (needReload) {
            [_tableView reloadData];
        }
    }
}

- (void)loadMoreSearchResult
{
    if (_searchService.hasMore && !_searchService.isLoading) {
        [_searchService loadNextPageWithKeyword:self.keyWord type:@"30"];
        [self updateDateSource];
    }
}

- (void)addToolbar
{
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    SNToolbar *toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - bg.size.height, kAppScreenWidth, bg.size.height)];
    [toolbarView setBackgroundColor:[UIColor clearColor]];
    [toolbarView setBackgroundImage:bg];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setAccessibilityLabel:@"返回"];
    [toolbarView setLeftButton:leftButton];
    
    [self.view addSubview:toolbarView];
}

- (void)updateDateSource
{
    NSMutableArray *allSubscribeArray = [NSMutableArray arrayWithArray:_searchService.allSubscribeList];;
    if ([_searchService.allSubscribeList count] >0 && _searchService.hasMore) {
        SNTableMoreButton *moreBtn = [SNTableMoreButton itemWithText:NSLocalizedString(@"Loading...", @"Loading...")];
        moreBtn.animating =  _searchService.isLoading;
        [allSubscribeArray addObject:moreBtn];
    }
    self.subscribeArray = allSubscribeArray;
    
    SNSearchDataSource *searchDataSource = [[SNSearchDataSource alloc] init];
    searchDataSource.items = allSubscribeArray;
    self.dataSource = searchDataSource;
    [self.tableView reloadData];
}

- (void)onBack {
    [[[TTNavigator navigator] topViewController].flipboardNavigationController popViewControllerAnimated:YES];
}

# pragma mark - 网络错误界面
- (void)showError:(BOOL)show {
    SNSearchCategoryMaskView *overlayView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kErrorViewTag];
    if (show) {
        if (overlayView == nil) {
            overlayView = [[SNSearchCategoryMaskView alloc] initWithFrame:_tableView.bounds];
            overlayView.tag = kErrorViewTag;
            overlayView.isAccessibilityElement = YES;
            overlayView.accessibilityLabel = @"网络不给力无法加载";
            [_tableView addSubview:overlayView];
            _tableView.scrollEnabled = NO;
            
            UIImageView *errorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tb_error_bg.png"]];
            errorView.center = CGPointMake(_tableView.center.x, _tableView.center.y - 120);
            errorView.tag = kErrorViewTag;
            [overlayView addSubview:errorView];
            _tableView.scrollEnabled = NO;
            
        }
    } else {
        _tableView.scrollEnabled = YES;
        if (overlayView) {
            [overlayView removeFromSuperview];
            overlayView = nil;
        }
    }
}

- (void)showEmpty:(BOOL)show {
    
    if (_searchService.isLoading) {
        return;
    }
    
    SNSearchCategoryMaskView *overlayView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kEmptyViewTag];
    if (show) {
        if (overlayView == nil) {
            overlayView = [[SNSearchCategoryMaskView alloc] initWithFrame:_tableView.bounds];
            overlayView.tag = kEmptyViewTag;
            overlayView.isAccessibilityElement = YES;
            overlayView.accessibilityLabel = @"黑夜给了我黑色的眼睛，可我什么也没找到";
            [_tableView addSubview:overlayView];
            _tableView.scrollEnabled = NO;
            
            UIImageView *emptyView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_empty.png"]];
            emptyView.center = CGPointMake(_tableView.center.x, _tableView.center.y - 120);
            [overlayView addSubview:emptyView];
            
            _tableView.scrollEnabled = NO;
        }
    } else {
        _tableView.scrollEnabled = YES;
        
        if (overlayView) {
            [overlayView removeFromSuperview];
            overlayView = nil;
        }
    }
}

- (void)showLoading:(BOOL)show {
    SNSearchCategoryMaskView *overlayView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kLoadingViewTag];
    if (show) {
        if (overlayView == nil) {
            overlayView = [[SNSearchCategoryMaskView alloc] initWithFrame:_tableView.bounds];
            overlayView.isAccessibilityElement = YES;
            overlayView.accessibilityLabel = @"正在搜索";
            overlayView.tag = kLoadingViewTag;
            [_tableView addSubview:overlayView];
            _tableView.scrollEnabled = NO;
            
            UIImageView *_logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_logo.png"]];
            _logo.center = CGPointMake(_tableView.centerX, _tableView.center.y - 160);
            [overlayView addSubview:_logo];
            
            SNWaitingActivityView *_loading = [[SNWaitingActivityView alloc] init];
            
            [_loading updateTheme];
            
            _loading.center = CGPointMake(_logo.center.x, _logo.origin.y - _loading.height/2);
            [_loading startAnimating];
            [overlayView addSubview:_loading];
            
        }
        
    } else {
        _tableView.scrollEnabled = YES;
        if (overlayView) {
            [overlayView removeFromSuperview];
            overlayView = nil;
        }
    }
}

#pragma mark - SNSearchResultSubscribeCellDelegate

- (void)allSubCellWillAddMySub:(SCSubscribeObject *)subObj {
    if (!subObj.subId) {
        return;
    }
    
    if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:subObj]) {
        [SNGuideRegisterManager showGuideWithSubId:subObj.subId];
        return;
    }
    
    if (![SNUserManager isLogin]) {//login
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
#pragma clang diagnostic pop
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method",[NSNumber numberWithInteger:SNGuideRegisterTypeSubscribe], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
        //[SNUtility openLoginViewWithDict:dict];
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {
            
        } Failed:nil];
        
        return ;
    }
    else{
    
        [_subsRunningOnAddToMySub addObject:subObj.subId];
        SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:subObj.subId];
        NSString *sucMsg = [subObj succSubMsg];
        NSString *failMsg = [subObj failSubMsg];
        [opt addBackgroundListenerWithSuccMsg:sucMsg failMsg:failMsg];
        
        subObj.from = _refer;
        
        [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:subObj];
    }
}

#pragma mark -
#pragma mark SNSearchServiceDelegate

- (void)searchDidFinishLoadWithPageNo:(int)pageNo {
    [self showLoading:NO];
    [self showError:NO];
    
    if (_searchService.resultList.count == 0) {
        [self showEmpty:YES];
    } else {
        [self showEmpty:NO];
    }
    [self updateDateSource];
}

- (void)searchDidFailLoadWithPageNo:(int)pageNo andError:(NSError *)error {
    if (_searchService.allSubscribeList.count == 0) {
        [self showLoading:NO];
        [self showEmpty:NO];
        [self showError:YES];
    } else {
        [self showError:NO];
//        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

#pragma mark - SNSubscribeCenterServiceDelegate

- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [_subsRunningOnAddToMySub removeObject:subId];
        for (SNRollingNewsTableItem *item in self.subscribeArray) {
            if ([item.news.subId isEqualToString:subId]) {
                item.news.isSubscribe = @"1";
                break;
            }
        }
        [_tableView reloadData];
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [_subsRunningOnAddToMySub removeObject:subId];
        [_tableView reloadData];
        return;
    }
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [_subsRunningOnAddToMySub removeObject:subId];
        [_tableView reloadData];
        return;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [SNNotificationManager removeObserver: self];
}

@end
