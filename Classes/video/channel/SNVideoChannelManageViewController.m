//
//  SNVideoChannelManageViewController.m
//  sohunews
//
//  Created by jojo on 13-9-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelManageViewController.h"
#import "SNVideoChannelManager.h"
#import "SNVideoChannelHotCategoryView.h"
#import "SNVideoChannelHotCategorySNSView.h"
#import "UIColor+ColorUtils.h"
#import "SNVideoChannelHotCategorySectionHeadView.h"
#import "SNTripletsLoadingView.h"


#define kHeaderViewHeight               (34 / 2)
#define kRowHeight                      (60)

@interface SNVideoChannelManageViewController () {
    //SNWeiboDetailMoreCell *_moreCell;
    SNTripletsLoadingView *_loadingView;
}

@property (nonatomic, strong) NSMutableArray *hotCategories;
@property (nonatomic, strong) NSMutableArray *hotSns;
@property (nonatomic, strong) NSMutableArray *hotCategorySections; // array of SNVideoHotChannelCategoriSectionObj
@property (nonatomic, strong) SNMultiColumnTableView *tableview;
@property (nonatomic, strong) SNVideoChannelHotCategorySNSView *currentBindCategoryView;
@property (nonatomic, assign) BOOL hasRefreshedNewData;

@end

@implementation SNVideoChannelManageViewController
@synthesize tableview = _tableview;
@synthesize hotCategories = _hotCategories;
@synthesize hotSns = _hotSns;
@synthesize hotCategorySections = _hotCategorySections;
@synthesize currentBindCategoryView = _currentBindCategoryView;
@synthesize hasRefreshedNewData;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.hotCategorySections = [NSMutableArray array];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleDidLoginNotify:)
                                                     name:kUserDidLoginNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleDidLoginNotify:)
                                                     name:kSharelistDidChangedNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleHotCategorySubDidChangeNotification:)
                                                     name:kVideoChannelHotCategorySubDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return video_column_manage;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
     //(_tableview);
     //(_hotCategories);
     //(_hotSns);
     //(_hotCategorySections);
     //(_currentBindCategoryView);
    _loadingView.delegate = nil;
     //(_loadingView);
    
     //(_moreCell);
}

- (void)loadView {
    [super loadView];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleHotCategoriesDidFinishLoadNotification:)
                                                 name:kVideoChannelDidFinishLoadCategoriesNotification
                                               object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleHotCategoriesDidStartLoadNotification:)
                                                 name:kVideoChannelDidStartLoadCategoriesNotification
                                               object:nil];
    [self addHeaderView];
    self.headerView.sections = @[@"热播管理"];
    
    self.tableview = [[SNMultiColumnTableView alloc] initWithFrame:CGRectMake(0,
                                                                               self.headerView.height - 8,
                                                                               self.view.width,
                                                                               self.view.height)
                                                              style:UITableViewStylePlain];
    self.tableview.mcDelegate = self;
    self.tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableview.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 0, 0);
    self.tableview.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    [self.view insertSubview:self.tableview belowSubview:self.headerView];
    
    [self createLoadingView];
    [self addToolbar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableview.height = self.view.height - self.headerView.height + 8 - self.toolbarView.height + 8;
}

- (void)viewDidUnload {
    // remove listener
    [SNNotificationManager removeObserver:self name:kVideoChannelDidStartLoadCategoriesNotification object:nil];
    [SNNotificationManager removeObserver:self name:kVideoChannelDidFinishLoadCategoriesNotification object:nil];

     //(_tableview);
     //(_moreCell);
    _loadingView.delegate = nil;
     //(_loadingView);
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.hasRefreshedNewData) {
        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            [[SNVideoChannelManager sharedManager] refreshHotCategories];
            self.hasRefreshedNewData = YES;
        }
        else {
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            _loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

#pragma mark - SNVideoChannelManager actions

- (void)handleDidFinishLoadMoreCategoriesNotification:(NSNotification *)notification {
//    [self.hotCategories addObjectsFromArray:[[SNVideoChannelManager sharedManager] testDataHotChannelCategories]];
//    [self.tableview reloadData];
//    
//    [_moreCell showLoading:NO];
//    [_moreCell setHasNoMore:NO];
}

- (void)handleHotCategoriesDidFinishLoadNotification:(NSNotification *)notification {
    [self.hotCategorySections removeAllObjects];
    [self.hotCategorySections addObjectsFromArray:[SNVideoChannelManager sharedManager].hotChannelCategories];
    [self.tableview reloadData];
    if (self.hotCategorySections.count == 0) {
        _loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
    } else {
        _loadingView.status = SNTripletsLoadingStatusStopped;
    }
}

- (void)handleHotCategoriesDidStartLoadNotification:(NSNotification *)notification {
    if (self.hotCategorySections.count == 0) {
        _loadingView.status = SNTripletsLoadingStatusLoading;
    } else {
        _loadingView.status = SNTripletsLoadingStatusStopped;
    }
}

- (void)handleDidLoginNotify:(id)sender {
    if (self.currentBindCategoryView) {
        [[SNVideoChannelManager sharedManager] subscribeACategoryWithColumnId:self.currentBindCategoryView.categoryObj.categoryId];
    }
    else {
        [[SNVideoChannelManager sharedManager] refreshHotCategories];
    }
}

- (void)handleHotCategorySubDidChangeNotification:(NSNotification *)notification {
    NSString *categoryId = [notification.userInfo stringValueForKey:kVideoChannelHotCategoryIdKey defaultValue:nil];
    if ([categoryId isEqualToString:self.currentBindCategoryView.categoryObj.categoryId]) {
        [[SNVideoChannelManager sharedManager] refreshHotCategories];
        self.currentBindCategoryView = nil;
    }
}

#pragma mark - SNVideoChannelHotCategoryViewDelegate

- (BOOL)shouldUnsubCategory:(SNVideoChannelHotCategoryView *)categoryView {
    // 保证至少留一个热播栏目
    if ([self subedVideoHotCategoryTotalCount] == 1) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请至少选中1个栏目" toUrl:nil mode:SNCenterToastModeOnlyText];
        return NO;
    }
    
    return YES;
}

- (void)snsCategoryWillSub:(SNVideoChannelHotCategoryView *)categoryView {
    if ([categoryView isKindOfClass:[SNVideoChannelHotCategorySNSView class]]) {
        self.currentBindCategoryView = (SNVideoChannelHotCategorySNSView *)categoryView;
    }
}

#pragma mark - SNMultiColumnTableViewDelegate

- (NSInteger)mcTableView:(SNMultiColumnTableView *)tableview numberOfItemsInSeciont:(NSInteger)section {
    if (section % 2 == 0 || section == 1) {//section == 1时显示的是腾讯微博入口，5.2.1屏蔽入口
        return 1;
    }
    else {
        SNVideoHotChannelCategoriSectionObj *sectionObj = [self.hotCategorySections objectAtIndex:(section - 1) / 2];
        return sectionObj.categories.count;
    }
    
    return 0;
}

- (UIView *)mcTableView:(SNMultiColumnTableView *)tableView viewForIndexPath:(NSIndexPath *)indexPath fromProvider:(id<SNMultiColumnTableViewReuseViewProvider>)provider {
    
    SNVideoHotChannelCategoriSectionObj *sectionObj = [self.hotCategorySections objectAtIndex:(indexPath.section - 1) / 2];
    BOOL isLastRow = NO;
    NSInteger rowIndex = indexPath.row;
    SNVideoChannelHotCategoryViewSepline lineType = 0;
    
    if (rowIndex % 2 == 0) {
        lineType = SNVideoChannelHotCategoryViewSeplineBottomRight | SNVideoChannelHotCategoryViewSeplineRight;
        if (rowIndex == sectionObj.categories.count - 1) {
            isLastRow = YES;
        }
        else if (rowIndex + 1 == sectionObj.categories.count - 1) {
            isLastRow = YES;
        }
    }
    else {
        lineType = SNVideoChannelHotCategoryViewSeplineBottomLeft;
        if (rowIndex == sectionObj.categories.count - 1) {
            isLastRow = YES;
        }
    }
    
    if (isLastRow) {
        lineType &= ~(SNVideoChannelHotCategoryViewSeplineBottomLeft | SNVideoChannelHotCategoryViewSeplineBottomRight);
    }
    
    // 社交网络绑定 三个入口
    if ([sectionObj.categoryType intValue] == 1) {
        SNVideoChannelHotCategorySNSView *snsView = (SNVideoChannelHotCategorySNSView *)[provider reusableViewForIndexPath:indexPath];
        if (!snsView) {
            snsView = [[SNVideoChannelHotCategorySNSView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
            snsView.delegate = self;
        }
        
        SNVideoChannelCategoryObject *cgObj = [sectionObj.categories objectAtIndex:indexPath.row];
        snsView.categoryObj = cgObj;
        snsView.seplineType = lineType;
        
        return snsView;
    }
    // 精品栏目 可以从服务器获取
    else {
        SNVideoChannelHotCategoryView *categoryView = (SNVideoChannelHotCategoryView *)[provider reusableViewForIndexPath:indexPath];
        if (!categoryView) {
            categoryView = [[SNVideoChannelHotCategoryView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
            categoryView.delegate = self;
        }
        
        SNVideoChannelCategoryObject *cgObj = [sectionObj.categories objectAtIndex:indexPath.row];
        categoryView.categoryObj = cgObj;
        categoryView.seplineType = lineType;
        
        return categoryView;
    }
}

- (NSInteger)numberOfSectionInMCTableView:(SNMultiColumnTableView *)tableView {
    // 栏目section 个数  以服务器返回的数据为准 本地不再写死
    return self.hotCategorySections.count * 2;
    
    // 社交账号 + 精品栏目 + 加载更多的cell
    return 3;
}

- (NSInteger)mcTableView:(SNMultiColumnTableView *)tableView numberOfColumnInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)mcTableView:(SNMultiColumnTableView *)tableview cellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *customCell = nil;
    static NSString *cellIdty = @"customCell";
    if (indexPath.section % 2 == 0 && (indexPath.section / 2) < self.hotCategorySections.count) {
        SNVideoHotChannelCategoriSectionObj *sectionObj = [self.hotCategorySections objectAtIndex:(indexPath.section / 2)];
        customCell = [tableview dequeueReusableCellWithIdentifier:cellIdty];
        
        if (!customCell) {
            customCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdty];
            customCell.selectionStyle = UITableViewCellSelectionStyleNone;
            customCell.backgroundColor = [UIColor clearColor];
        }
        static int viewTag = 1000;
        UIView *contentView = [customCell viewWithTag:viewTag];
        if (contentView) {
            [contentView removeFromSuperview];
        }
        
        if ([sectionObj.categoryType integerValue] == 1) {
//            SNVideoChannelHotCategorySectionHeadView *headView = [SNVideoChannelHotCategorySectionHeadView headViewWithTitle:@"绑定社交账号,观看好友分享的视频" headType:SNVideoSectionHeadTypeCenterTitleWithOutLine];
//            headView.tag = 1000;
//            headView.size = CGSizeMake(tableview.width, kHeaderViewHeight);
//            [customCell addSubview:headView];
            
//            SNVideoChannelHotCategorySectionHeadViewV2 *headViewV2 = [SNVideoChannelHotCategorySectionHeadViewV2 headViewWithTitle:@"社交" infoString:@"绑定社交账号,观看好友分享的视频"];
            SNVideoChannelHotCategorySectionHeadViewV2 *headViewV2 = [SNVideoChannelHotCategorySectionHeadViewV2 headViewWithTitle:@"绑定社交账号,观看好友分享的视频" infoString:nil];
            headViewV2.tag = viewTag;
            headViewV2.size = CGSizeMake(tableview.width, kHeaderViewHeight);
            headViewV2.top = 5;
            [customCell addSubview:headViewV2];
        }
        else {
//            SNVideoChannelHotCategorySectionHeadView *headView = [SNVideoChannelHotCategorySectionHeadView headViewWithTitle:sectionObj.categoryTitle headType:SNVideoSectionHeadTypeLeadingTitleWithLine];
//            headView.tag = 1000;
//            headView.size = CGSizeMake(tableview.width, kHeaderViewHeight);
//            [customCell addSubview:headView];
            
            SNVideoChannelHotCategorySectionHeadViewV2 *headViewV2 = [SNVideoChannelHotCategorySectionHeadViewV2 headViewWithTitle:sectionObj.categoryTitle infoString:nil];
            headViewV2.tag = viewTag;
            headViewV2.size = CGSizeMake(tableview.width, kHeaderViewHeight);
            headViewV2.top = 5;
            [customCell addSubview:headViewV2];
        }
    }
    
    return customCell;
}

- (BOOL)mcTableView:(SNMultiColumnTableView *)tableview shouldUseCustomCellInSection:(NSInteger)section {
    return section % 2 == 0;
}

- (CGRect)mcTableView:(SNMultiColumnTableView *)tableview viewFrameAtIndexPath:(NSIndexPath *)indexPath andViewIndex:(NSInteger)index {
    if (index == 0) {
        return CGRectMake(10, 0, tableview.width / 2 - 10, kRowHeight);
    }
    else {
        return CGRectMake(tableview.width / 2, 0, tableview.width / 2 - 10, kRowHeight);
    }
    return CGRectZero;
}

- (CGFloat)mcTableView:(SNMultiColumnTableView *)tableview heightForRowInSection:(NSInteger)section {
    if (section % 2 == 0) {
        return kHeaderViewHeight + 10;
    }
    return kRowHeight;
}

- (void)mcTableView:(SNMultiColumnTableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#if 0
// section head

- (CGFloat)mcTableView:(SNMultiColumnTableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return kHeaderViewHeight;
}

- (UIView *)mcTableView:(SNMultiColumnTableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 社交网络
//    if (section == 0) {
//        return [self sectionHeadViewWithTitle:@"社交网络"];
//    }
    // 精品栏目
//    else if (section == 1) {
//        return [self sectionHeadViewWithTitle:@"精品栏目"];
//    }
    
    SNVideoHotChannelCategoriSectionObj *sectionObj = [self.hotCategorySections objectAtIndex:section];
    if ([sectionObj.categoryType intValue] == 1) {
        return [SNVideoChannelHotCategorySectionHeadView headViewWithTitle:@"绑定社交账号,观看好友分享的视频" headType:SNVideoSectionHeadTypeCenterTitleWithOutLine];
    }
    else {
        return [SNVideoChannelHotCategorySectionHeadView headViewWithTitle:sectionObj.categoryTitle headType:SNVideoSectionHeadTypeLeadingTitleWithLine];
    }

    return nil;
}

#endif

#pragma mark - SNTripletsLoadingViewDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNVideoChannelManager sharedManager] refreshHotCategories];
    }
    else {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    }
}

#pragma mark - private
- (void)createLoadingView {
    if (!_loadingView) {
        _loadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0,
                                                                               _headerView.bottom,
                                                                               self.view.width,
                                                                               kAppScreenHeight - kSystemBarHeight - 50)];
        _loadingView.delegate = self;
        [self.view insertSubview:_loadingView aboveSubview:self.tableview];
    }
}

- (int)subedVideoHotCategoryTotalCount {
    int totalCount = 0;
    for (SNVideoHotChannelCategoriSectionObj *sectionObj in self.hotCategorySections) {
        for (SNVideoChannelCategoryObject *cgObj in sectionObj.categories) {
            if ([cgObj.sub isEqualToString:@"1"] && cgObj.isUnsubLoading == NO) {
                totalCount++;
            }
        }
    }
    return totalCount;
}

@end
