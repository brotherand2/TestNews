//
//  SNLiveStatisticTableViewController.m
//  sohunews
//
//  Created by wang yanchen on 13-4-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveStatisticTableViewController.h"
#import "NSDictionaryExtend.h"
#import "SNLiveStatisticColumnHeadView.h"
#import "SNLiveStatisticRowCell.h"
#import "SNEmbededActivityIndicator.h"
#import "SNLiveStatisticTeamInfoView.h"
#import "UIColor+ColorUtils.h"

#define kSideMargin             (20 / 2)

#define kTableTopMargin         (34 / 2)
#define kLeftTableWidth         (200 / 2)
#define kRightColumnWidth       (90 / 2)

#define kSectionHeaderHeight    (58 / 2)
#define kSectionHeight          (kSectionHeaderHeight)

#define kRowHeight              (60 / 2)
#define kSectionSpace           (14 / 2)

@interface SNLiveStatisticTableViewController () {
    SNLiveStatisticModel *_model;
    BOOL _isLoaded;
    
    SNEmbededActivityIndicator *_loadView;
    
    UIView *_emptyView;
    
    SNLiveStatisticTeamInfoView *_teamInfoView;
    
    UIImageView *_rightShadowView;
}

@property(nonatomic, copy) NSString *liveId;
@property(nonatomic, copy) NSString *hostName;
@property(nonatomic, copy) NSString *visitName;

// view
@property(nonatomic, strong) UITableView *leftTableView;
@property(nonatomic, strong) UITableView *rightTableView;
@property(nonatomic, strong) UIScrollView *rightScrollView;

- (void)reloadData;

@end

@implementation SNLiveStatisticTableViewController
@synthesize liveId = _liveId;
@synthesize leftTableView = _leftTableView;
@synthesize rightScrollView = _rightScrollView;
@synthesize rightTableView = _rightTableView;
@synthesize hostName = _hostName;
@synthesize visitName = _visitName;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.liveId = [query stringValueForKey:@"liveId" defaultValue:nil];
        self.hostName = [query stringValueForKey:@"hostName" defaultValue:@""];
        self.visitName = [query stringValueForKey:@"visitName" defaultValue:@""];
        
        _model = [[SNLiveStatisticModel alloc] initWithLiveId:self.liveId];
        _model.hostName = self.hostName;
        _model.visitName = self.visitName;
        _model.delegate = self;
        
        if (query) {
            self.queryDic = [NSMutableDictionary dictionaryWithDictionary:query];
        }
        
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return live_statistic;
}

- (NSString *)currentOpenLink2Url {
    return [self.queryDic stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:nil];
}

- (void)dealloc {
     //(_leftTableView);
     //(_rightTableView);
     //(_rightScrollView);
     //(_teamInfoView);
     //(_rightShadowView);
    
     //(_liveId);
     //(_hostName);
     //(_visitName);
    
    [_model cancelAndCleanDelegate];
     //(_model);
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _teamInfoView = [[SNLiveStatisticTeamInfoView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_teamInfoView];
    
    self.leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kLeftTableWidth, self.view.frame.size.height)
                                                       style:UITableViewStylePlain];
    self.leftTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    self.leftTableView.showsVerticalScrollIndicator = NO;
    self.leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.leftTableView.bounces = NO;
    [self.view addSubview:self.leftTableView];
    
    self.rightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.leftTableView.frame.size.width,
                                                                           0,
                                                                           self.view.frame.size.width - self.leftTableView.frame.size.width - 2 * kSideMargin,
                                                                           self.view.frame.size.height)];
    self.rightScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.rightScrollView.showsHorizontalScrollIndicator = NO;
    self.rightScrollView.showsVerticalScrollIndicator = NO;
    self.rightScrollView.bounces = NO;
    self.rightScrollView.delegate = self;
    [self.view addSubview:self.rightScrollView];
    
    self.rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         kRightColumnWidth * (_model.columnsTitleForHost.count - 1),
                                                                         self.view.frame.size.height)
                                                        style:UITableViewStylePlain];
    self.rightTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    self.rightTableView.showsVerticalScrollIndicator = NO;
    self.rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.rightTableView.bounces = NO;
    [self.rightScrollView addSubview:self.rightTableView];
    
    [self addHeaderView];
    [self.headerView setSections:@[@"技术统计"]];
    [self addToolbar];
    
    // todo reset tableviews frame
    _teamInfoView.top = self.headerView.bottom;
    
    self.leftTableView.frame = CGRectMake(kSideMargin,
                                          _teamInfoView.bottom,
                                          kLeftTableWidth,
                                          self.view.height - self.headerView.height - _teamInfoView.height - self.tabbarView.height + 8 - kToolbarHeight);
    
    self.rightScrollView.frame = CGRectMake(self.leftTableView.right,
                                            self.leftTableView.top,
                                            self.rightScrollView.width,
                                            self.leftTableView.height);
    self.rightTableView.frame = CGRectMake(0, 0,
                                           self.rightTableView.width,
                                           self.rightScrollView.height);
    
    self.rightScrollView.contentSize = self.rightTableView.size;
    // 下方留几像素空白 标明表已经到底了
    self.leftTableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    self.rightTableView.contentInset = self.leftTableView.contentInset;
    
    UIImage *shadowImage = [UIImage imageNamed:@"live_statistic_left_mask.png"];
    _rightShadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, shadowImage.size.width, self.rightScrollView.height)];
    _rightShadowView.right = self.rightScrollView.right;
    _rightShadowView.top = self.rightScrollView.top;
    _rightShadowView.image = [shadowImage stretchableImageWithLeftCapWidth:0 topCapHeight:10];
    [self.view addSubview:_rightShadowView];
    
    [self updateTheme:nil];
    
    [self.view bringSubviewToFront:self.headerView];
    [self.view bringSubviewToFront:self.toolbarView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [_model refreshLiveStatisticFromServer];
    [self showLoading:YES];
}

- (void)viewDidUnload {
     //(_leftTableView);
     //(_rightTableView);
     //(_rightScrollView);
     //(_teamInfoView);
     //(_rightShadowView);
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)updateTheme:(NSNotification *)notifiction {
    self.leftTableView.backgroundView = nil;
    self.leftTableView.backgroundColor = [UIColor clearColor];
    self.rightTableView.backgroundView = nil;
    self.rightTableView.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    UIImage *shadowImage = [UIImage imageNamed:@"live_statistic_left_mask.png"];
    _rightShadowView.image = [shadowImage stretchableImageWithLeftCapWidth:0 topCapHeight:10];
}

#pragma mark tableview datasource & delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.rightTableView) {
        self.leftTableView.contentOffset = self.rightTableView.contentOffset;
    }
    else if (scrollView == self.leftTableView) {
        self.rightTableView.contentOffset = self.leftTableView.contentOffset;
    }
    else if (scrollView == self.rightScrollView) {
        if (!_emptyView)
            _rightShadowView.hidden = (scrollView.contentOffset.x + scrollView.width == scrollView.contentSize.width);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return kSectionSpace;
    
    return kSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return [[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, kSectionHeight)];
    SNLiveStatisticColumnHeadView *columnView = [[SNLiveStatisticColumnHeadView alloc] initWithFrame:CGRectMake(0,
                                                                                                          headView.height - kSectionHeaderHeight,
                                                                                                          headView.width,
                                                                                                          kSectionHeaderHeight)];
    
    
    // 显示球队
    if (tableView == self.leftTableView) {
        // 主队
        if (section == 0) {
            columnView.colunmDataArray = [NSArray arrayWithObject:[_model.columnsTitleForHost objectAtIndex:0]];
        }
        else {
            columnView.colunmDataArray = [NSArray arrayWithObject:[_model.columnsTitleForVisit objectAtIndex:0]];
        }
        columnView.isTitleColumn = YES;
    }
    // 显示其他的column
    else {
        NSMutableArray *columns = [NSMutableArray array];
        [columns addObjectsFromArray:_model.columnsTitleForHost];
        [columns removeObjectAtIndex:0];
        columnView.colunmDataArray = columns;
    }
    
    [headView addSubview:columnView];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _isLoaded ? 3 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1)
        return 0;
    
    // 主队
    if (section == 0) {
        if (_model.sectionArray.count >= 1) {
            NSArray *hostArray = [_model.sectionArray objectAtIndex:0];
            return hostArray.count;
        }
    }
    // 客队
    else if (section == 2) {
        if (_model.sectionArray.count > 1) {
            NSArray *visitArray = [_model.sectionArray objectAtIndex:1];
            return visitArray.count;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNLiveStatisticRowCell *cell = nil;
    if (self.leftTableView == tableView) {
        static NSString *leftCellIdty = @"leftCellIdty";
        cell = [tableView dequeueReusableCellWithIdentifier:leftCellIdty];
        if (!cell) {
            cell = [[SNLiveStatisticRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftCellIdty];
        }
        
        NSArray *sectionArray = nil;
        // 主队
        if ([indexPath section] == 0) {
            sectionArray = [_model.sectionArray objectAtIndex:0];
        }
        // 客队
        else if ([indexPath section] == 2) {
            sectionArray = [_model.sectionArray objectAtIndex:1];
        }
        if (sectionArray.count >= 1) {
            NSArray *rowArray = [sectionArray objectAtIndex:[indexPath row]];
            cell.rowDataArray = [NSArray arrayWithObject:[rowArray objectAtIndex:0]];
        }
        cell.isTitleColumn = YES;
    }
    else {
        static NSString *rightCellIdty = @"rightCellIdty";
        cell = [tableView dequeueReusableCellWithIdentifier:rightCellIdty];
        if (!cell) {
            cell = [[SNLiveStatisticRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rightCellIdty];
        }
        
        NSArray *sectionArray = nil;
        // 主队
        if ([indexPath section] == 0) {
            sectionArray = [_model.sectionArray objectAtIndex:0];
        }
        // 客队
        else if ([indexPath section] == 2) {
            sectionArray = [_model.sectionArray objectAtIndex:1];
        }
        NSArray *rowArray = [sectionArray objectAtIndex:[indexPath row]];
        NSMutableArray *realArray = [NSMutableArray array];
        [realArray addObjectsFromArray:rowArray];
        [realArray removeObjectAtIndex:0];

        cell.rowDataArray = realArray;
    }
    
    return cell;
}

#pragma mark - SNLiveStatisticModelDelegate

- (void)didFinishLoadStatistic {
    _isLoaded = YES;
    [self showLoading:NO];
    
    _teamInfoView.liveModel = _model;
    
    if (_model.sectionArray.count > 1) {
        [self reloadData];
        _rightShadowView.hidden = NO;
    }
    else {
        [self showEmpty:YES];
    }
}

- (void)didFailToLoadStatisticWithError:(NSError *)error {
    [self showLoading:NO];
    
    SNDebugLog(@"%@: error %@", NSStringFromSelector(_cmd), error);
    if (error.code == 404) {
        [self showEmpty:YES];
    }
    else {
        [self showError:YES];
    }
}

#pragma mark - UIGestrueGecognizerDelegate
// 在右侧scroll滑动的时候 不返回 否则很容易误操作 by jojo

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (gestureRecognizer == _swipGR && self.rightScrollView.contentOffset.x == 0)
//        return YES;
//    
//    return NO;
//}

- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    return self.rightScrollView.contentOffset.x <= 0;
}

#pragma mark - empty error views

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
	if (show) {
        if (!_loadView) {
            _loadView = [[SNEmbededActivityIndicator alloc] initWithDelegate:self];
            _loadView.frame = CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height - self.tabbarView.height);
            _loadView.hidesWhenStopped = YES;
            _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
            [self.view addSubview:_loadView];
            
        }
        
        _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
        _rightShadowView.hidden = YES;
		
	} else {
        _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
        [_loadView removeFromSuperview];
         //(_loadView);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
    if (show) {
        if (!_emptyView) {
            _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            _emptyView.userInteractionEnabled = NO;
            [self.view addSubview:_emptyView];
            
            UIImage *emptyImage = [UIImage imageNamed:@"live_statistic_empty.png"];
            UIImageView *emptyImageView = [[UIImageView alloc] initWithImage:emptyImage];
            emptyImageView.centerX = CGRectGetMidX(_emptyView.bounds);
            emptyImageView.centerY = CGRectGetMidY(_emptyView.bounds);
            [_emptyView addSubview:emptyImageView];
        }
        _rightShadowView.hidden = YES;
    }
    else {
        if (_emptyView) {
            [_emptyView removeFromSuperview];
             //(_emptyView);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
	if (show) {
        if (!_loadView) {
            _loadView = [[SNEmbededActivityIndicator alloc] initWithDelegate:self];
            _loadView.hidesWhenStopped = YES;
            _loadView.frame = CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height - self.tabbarView.height);
            _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
            [self.view addSubview:_loadView];
            [self.view sendSubviewToBack:_loadView];
        }

        _loadView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
        _rightShadowView.hidden = YES;
		
	} else {
        _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
        [_loadView removeFromSuperview];
         //(_loadView);
	}
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry {
    [_model refreshLiveStatisticFromServer];
}

#pragma mark - private

- (void)reloadData {
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
}

#pragma mark - actions
- (void)doBack {
    [self showLoading:NO];
    [self showError:NO];
    [self showEmpty:NO];
    [_model cancelAndCleanDelegate];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self doBack];
    }
}

- (void)onBack:(id)sender {
    
    [self doBack];
    
    [super onBack:sender];
}

@end
