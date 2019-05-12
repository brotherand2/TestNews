//
//  SNSearchViewController.m
//  sohunews
//
//  Created by Chen Hong on 13-1-10.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSearchViewController.h"
#import "SNSubCenterSearchView.h"
#import "SNSearchCategoryView.h"
#import "SNDBManager.h"
#import "SNConsts.h"
#import "UIColor+ColorUtils.h"
#import "NSDictionaryExtend.h"
#import "CacheObjects.h"
#import "SNSearchService.h"
#import "SNUserTrack.h"
#import "SNSearchScrollDelegate.h"
#import "SNSearchDataSource.h"
#import "SNGuideRegisterManager.h"
#import "SNSubCenterSearch.h"
#import "SNTableMoreButton.h"
#import "SNRollingNewsTableItem.h"
#import "SNNewsExposureManager.h"
#import "UITableViewCell+ConfigureCell.h"
#import "SNAppConfigManager.h"
#import "SNAnalytics.h"
#import "SNImageView.h"
#import "SNUserManager.h"
#import "SNNewsLoginManager.h"
#import "SNWaitingActivityView.h"

#define kErrorViewTag 10010
#define kEmptyViewTag 10011
#define kLoadingViewTag 10012

#define kSearchViewHeight               (110/2)
#define kSearchLogoHeight               (84/2)
#define kSearchLogoHeadHeight           (80/2)
#define kSogouButtonWidth               (80/2)
#define kSogouButtonHeight              (90/2)
#define kSogouHotwordHeight             (400/2)
#define kSearchToolbarHeight            (88/2)
#define kSearchTypeHeight               (60/2)

#define kTableOffsetForHideSearchView (kSearchViewHeight - 7)
#define kHistoryMax 10

#pragma mark -

@interface SNSogouButton : UIButton

@property(nonatomic,assign)int buttonIndex;
@property(nonatomic,strong)NSString *searchLink;

@end

@implementation SNSogouButton
@synthesize buttonIndex;
@synthesize searchLink;

- (id)initWithFrame:(CGRect)frame title:(NSString *) title imageUrl:(NSString *) imageUrl link:(NSString *) link
{
    self = [super initWithFrame:frame];
    if (self) {
        self.searchLink = link;
        
        SNImageView *imageView = [[SNImageView alloc] initWithFrame:CGRectMake(10, 0, 20, 20)];
        imageView.ignorePictureMode = YES;
        [imageView loadImageWithUrl:imageUrl defaultImage:nil];
        [self addSubview:imageView];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, kSogouButtonWidth, 12)];
        titleLabel.textColor = RGBCOLOR(0x8e, 0x8e, 0x8e);
        titleLabel.font = [UIFont systemFontOfSize:21/2.0f];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        [self addTarget:self action:@selector(sogouSearch) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)sogouSearch
{
    if (self.searchLink.length > 0) {
        [SNUtility openProtocolUrl:self.searchLink];
        
        // 触发相应的cc统计
        SNUserTrack *curPage = [SNUserTrack trackWithPage:search link2:nil];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:sohu_http_web link2:nil];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_joke_listen];
        paramString = [paramString stringByAppendingFormat:@"_%d&searchButtonIndex=%d", self.buttonIndex, self.buttonIndex];
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
}

- (void)dealloc
{
     //(searchLink);
}

@end

#pragma mark -

@interface SNSearchViewController () {
    SNSubCenterSearchView *_searchView;             // 搜索框
    SNSearchCategoryView    *_categoryView;         // 分类视图(pop)
    SNSearchCategoryMaskView *_maskView;            // 遮挡popView之外的视图交互
    SNEmbededActivityIndicator *_loadView;          // 网络错误提示
    SNSearchHotwordsView *_hotwordsView;            // 搜索热词
    SNToolbar *toolbarView;
    
    UIView *_sogouIconView;                         // 搜索icon列表
    UIView *_logoHeadView;                          // 包含logo的headView
    UIImageView *_logoImageView;                    // logo图片
    UIImageView *_shadowView;                       // 滚动阴影遮罩
    UIScrollView *_searchScrollView;                // 搜狗搜索界面scrollView
    UIButton *backButton;                           // 返回按钮
    NSMutableArray *_subsRunningOnAddToMySub;

    SNSearchScrollDelegate *_tableViewDelegate;
    SNSearchService *_searchService;                // 搜索结果请求
    SNSogouSearchService *_sogouSearchService;      // 搜狗icon和热词请求
    
    NSString *_keyword;                             // 搜索关键词
    NSString *_lastSuggestWord;                     // 记录搜索词语防止二次搜索
    NSMutableArray *_searchHistoryWords;            // 搜索网络提示词
    NSMutableArray *_suggestFromHistoryWords;       // 搜索提示词优先匹配历史搜索
    NSDictionary *_query;
    
    int _refer;                                     // 统计刊物订阅来源是否是热词还是普通搜索
    BOOL keyBoardSearch;                            // 判断是键盘点击搜索 还是边输入边搜索
    BOOL showLogo;
    BOOL searchMoveToTop;
    BOOL contentScorllEnabled;
}

@end

@implementation SNSearchViewController

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        _query = [query copy];
        self.variableHeightRows = YES;
        _refer = REFER_SEARCH;
        showLogo = YES;
        selectedSearchType = CATEGORY_ALL;
        
        NSString *keyword = [query stringValueForKey:kSearchWord defaultValue:nil];
        if ([keyword length] > 0) {
            _keyword = [keyword copy];
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.variableHeightRows = YES;
        _refer = REFER_SEARCH;
        selectedSearchType = CATEGORY_ALL;
        showLogo = YES;
        
        [SNNotificationManager addObserver:self selector:@selector(onUpdateSubItem:) name:kSubscribeCenterMySubDidChangedNotify object:nil];
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return search;
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
        if (selectedSearchType == CATEGORY_ALL) {
            for (NSArray *items in self.searchList) {
                if ([items isKindOfClass:[NSArray class]]) {
                    needReload = [self handleSubscribeWithNewsArray:items
                                                   subIdsAddedArray:subIdsAdded
                                                 subIdsRemovedArray:subIdsRemoved];
                }
            }
        }else {
            needReload = [self handleSubscribeWithNewsArray:self.searchList
                                           subIdsAddedArray:subIdsAdded
                                         subIdsRemovedArray:subIdsRemoved];
        }
        
        if (needReload) {
            [self updateDataSourceWithType:dataSourceType];
            [_tableView reloadData];
        }
    }
}

- (BOOL)handleSubscribeWithNewsArray:(NSArray *) newsArray
                    subIdsAddedArray:(NSArray *) addArray
                  subIdsRemovedArray:(NSArray *) removeArray
{
    BOOL needReload = NO;
    for (SNRollingNewsTableItem *item in newsArray) {
        if (item.type == NEWS_ITEM_TYPE_SUBSCRIBE) {
            if (item.news.subId.length) {
                if ([addArray containsObject:item.news.subId]) {
                    item.news.isSubscribe = @"1";
                    needReload = YES;
                } else if ([removeArray containsObject:item.news.subId]) {
                    item.news.isSubscribe = @"0";
                    needReload = YES;
                }
            }
        }
        
        if (needReload) {
            return needReload;
        }
    }
    return needReload;
}

- (void)updateDataSourceWithType:(SNSearchDataSourceType) sourceType
{
    dataSourceType = sourceType;
    SNSearchDataSource *searchDataSource = [[SNSearchDataSource alloc] init];
    if (selectedSearchType == CATEGORY_ALL) {
        if ([_searchService.searchSectionsList count]) {
            searchDataSource.sections = _searchService.searchSectionsList;
        } else {
            searchDataSource.sections = nil;
        }
    }else {
        searchDataSource.sections = nil;
    }
    searchDataSource.viewController = self;
    switch (sourceType) {
        case SNSearchDataSourceTypeSearch:
            searchDataSource.items = [self getAllSearchList];
            break;
        case SNSearchDataSourceTypeSuggest:
            searchDataSource.items = [self getAllSuggestList];
            searchDataSource.sections = nil;
            break;
        case SNSearchDataSourceTypeHistory:
            searchDataSource.items = [self getAllHistoryList];
            searchDataSource.sections = nil;
            break;
        default:
            break;
    }
    self.dataSource = searchDataSource;
    [self.tableView reloadData];
    _tableView.hidden = NO;
    _searchScrollView.scrollEnabled = NO;
}


- (int)getTableViewHeight
{
    int tableViewTop = showLogo ? kSystemBarHeight + _logoHeadView.height + _searchView.height : kSystemBarHeight+_searchView.height;
    int tableViewHeight = kAppScreenHeight - tableViewTop - kSearchToolbarHeight;
    return tableViewHeight;
}

- (void)loadView
{
    [super loadView];
    
    [self initScrollView];
    
    int tableViewHeight = [self getTableViewHeight];
    self.tableView.frame = CGRectMake(0, kSystemBarHeight+_searchView.bottom, self.view.width, tableViewHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view bringSubviewToFront:self.tableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [_tableView addGestureRecognizer:tap];
    
    _tableViewDelegate = [[SNSearchScrollDelegate alloc] init];
    _tableViewDelegate.viewController = self;
    self.tableView.delegate = _tableViewDelegate;
    
    [self updateDataSourceWithType:SNSearchDataSourceTypeSearch];
    
    // _categoryView
    _categoryView = [[SNSearchCategoryView alloc] initWithFrame:CGRectMake(4, _searchView.bottom - 10, 0, 0)];
    _categoryView.delegate = self;
    [self.view addSubview:_categoryView];
    _categoryView.exclusiveTouch = YES;
    _categoryView.alpha = 0;
    
    _maskView = [[SNSearchCategoryMaskView alloc] initWithFrame:TTApplicationFrame()];
    _maskView.delegate = self;
    
    // 订阅网络请求
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
    
    _subsRunningOnAddToMySub = [[NSMutableArray alloc] init];
    _searchService = [[SNSearchService alloc] init];
    _searchService.delegate = self;
    
    _sogouSearchService = [[SNSogouSearchService alloc] init];
    _sogouSearchService.delegate = self;
    [_sogouSearchService getSearchIconRequest];
    [_sogouSearchService getSearchHotWordRequest];
    
    if (_keyword.length > 0) {
        [self showHotwords:NO];
        [_searchView setText:_keyword];
        [_searchView showCancelButtonWithAnimation:NO];
    } else {
        [self showHotwords:YES];
        [self performSelector:@selector(showCancelButtonWithAnimation) withObject:nil afterDelay:0.1];
    }
    
    [self addToolbar];
    
    _loadView = [[SNEmbededActivityIndicator alloc] initWithDelegate:self];
    _loadView.frame = CGRectMake(0, 64, kAppScreenWidth, kAppScreenHeight - 108);
    _loadView.hidesWhenStopped = YES;
    _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [self.view addSubview:_loadView];
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
}

- (void)handleSwipeRight
{
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)addToolbar
{
    toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight)];
    [self.view addSubview:toolbarView];
    
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [backButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setAccessibilityLabel:@"返回"];
    [toolbarView setLeftButton:backButton];
}

- (void)onBack:(id)sender
{
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewController];
    }
}

- (void)initScrollView
{
    NSString *scrollBackgroundcolorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSearchHotwordViewBackgroundColor];
    NSString *backgroundColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    
    int scrollViewHeight = kAppScreenHeight - kSystemBarHeight - kSearchToolbarHeight;
    _searchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, self.view.width, scrollViewHeight)];
    _searchScrollView.backgroundColor = [UIColor colorFromString:scrollBackgroundcolorString];
    _searchScrollView.delegate = self;
    [self.view addSubview:_searchScrollView];
    
    _logoHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kSearchLogoHeadHeight)];
    _logoHeadView.backgroundColor = [UIColor colorFromString:backgroundColorString];
    [_searchScrollView addSubview:_logoHeadView];
    
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110,13, 190/2, 50/2)];
    _logoImageView.image = [UIImage imageNamed:@"search_sogoulogo.png"];
    _logoImageView.center = CGPointMake(kAppScreenWidth/2, 28);
    [_logoHeadView addSubview:_logoImageView];
    
    // 搜索框
    _searchView = [[SNSubCenterSearchView alloc] initWithFrame:CGRectMake(0,0, self.view.width, kSearchViewHeight)];
    _searchView.delegate = self;
    _searchView.top = _logoHeadView.bottom;
    _searchView.searchBoxAlphaAnim = YES;
    [_searchView setType:selectedSearchType];
    [_searchScrollView addSubview:_searchView];
    
    _shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_shadow.png"]];
    _shadowView.top = kSearchViewHeight;
    [_searchView addSubview:_shadowView];
    _shadowView.hidden = YES;
    
    //iconList
    _sogouIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kSearchViewHeight)];
    _sogouIconView.top = _searchView.bottom;
    _sogouIconView.backgroundColor = [UIColor colorFromString:backgroundColorString];
    _sogouIconView.hidden = YES;
    [_searchScrollView addSubview:_sogouIconView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTaped:)];

    [_sogouIconView addGestureRecognizer:tap];
     //(tap);
    
    //hotwords
    _hotwordsView = [[SNSearchHotwordsView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kSogouHotwordHeight)];
    _hotwordsView.top = _searchView.bottom + 5;
    _hotwordsView.delegate = self;
    [_searchScrollView addSubview:_hotwordsView];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTaped:)];
    [_hotwordsView addGestureRecognizer:tap];
     //(tap);
    
    _searchScrollView.contentSize = CGSizeMake(self.view.width, kAppScreenHeight + 40);
    _searchScrollView.scrollEnabled = NO;
}

// Cae. 手势和点击操作是Cae所加，为了缩回键盘
- (void)onTaped:(id)sender {
    
    [self hideKeyboard];
}

- (void)createSogouButtons
{
    if (![[SNAppConfigManager sharedInstance] searchSogouButtonShow]) {
        return;
    }
    
    if ([_sogouSearchService.iconArray count] == 0) {
        return;
    }
    
    _sogouIconView.hidden = NO;
    
    int button_x = 30;
    int buttton_y = 9;
    for (int i = 0; i < [_sogouSearchService.iconArray count]; i++) {
        SNSearchIconModel *iconModel = [_sogouSearchService.iconArray objectAtIndex:i];
        CGRect buttonRect = CGRectMake(button_x, buttton_y, kSogouButtonWidth, kSogouButtonHeight);
        SNSogouButton *sougouButton = [[SNSogouButton alloc] initWithFrame:buttonRect
                                                                     title:iconModel.name
                                                                  imageUrl:iconModel.iconurl
                                                                      link:iconModel.url];
        sougouButton.buttonIndex = i+1;
        [_sogouIconView addSubview:sougouButton];
        
        button_x += kSogouButtonWidth+15;
        if ((i+1) % 5 == 0) {
            buttton_y += kSogouButtonHeight + 15;
            button_x = 30;
        }
    }
    
    _sogouIconView.height = buttton_y + kSogouButtonHeight +20;
    
    [UIView animateWithDuration:0.4 animations:^(void) {
        _hotwordsView.top = _sogouIconView.bottom + 5;
    }];
    
    
    if (_hotwordsView.bottom > kAppScreenHeight - kSystemBarHeight - kSearchToolbarHeight) {
        contentScorllEnabled = YES;
        _searchScrollView.scrollEnabled = showLogo ? YES : NO;
        int scrollContentMinHeight = MAX(kAppScreenHeight , kSystemBarHeight + _hotwordsView.bottom);
        _searchScrollView.contentSize = CGSizeMake(self.view.width, scrollContentMinHeight);
    }
}

- (void) updateHotWords
{
    [_hotwordsView updateHotwordWithArray:_sogouSearchService.hotwordArray];
}

- (void)searchNotification:(NSNotification *) notification
{
    NSString *searchText = [notification.userInfo objectForKey:@"searchText"];
    if ([notification.userInfo objectForKey:kSearchType]) {
        int type = [[notification.userInfo objectForKey:kSearchType] intValue];
        selectedSearchType = type;
        [_searchView setType:type];
    }
    [self doSearch:searchText];
}

- (void)setKeywordNotification:(NSNotification *) notification
{
    NSString *keywordString = [notification.userInfo objectForKey:@"keyWord"];
    [self setKeyword:keywordString];
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
    [self customTheme];
    [SNNotificationManager addObserver:self
                                             selector:@selector(searchNotification:)
                                                 name:kSearchKeyWordNotification
                                               object:nil];
    [SNNotificationManager addObserver:self
                                              selector:@selector(setKeywordNotification:)
                                                 name:kSearchSetKeyWordNotification
                                               object:nil];
    [SNNotificationManager addObserver:self
                                             selector:@selector(clearHistoryList)
                                                 name:kSearchClearHistoryNotification
                                               object:nil];
    [SNNotificationManager addObserver:self
                                             selector:@selector(addSubscribeNotification:)
                                                 name:kSearchAddSubscribeNotification
                                               object:nil];
    [SNNotificationManager addObserver:self
                                             selector:@selector(hideKeyboard)
                                                 name:kSearchCloseKeyboardNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [NSObject cancelPreviousPerformRequestsWithTarget:_tableView selector:@selector(reloadData) object:nil];
//    [[SNSubscribeCenterService defaultService] removeListener:self];
    
    _searchView.delegate = nil;
     //(_searchView);
    
    _maskView.delegate = nil;
     //(_maskView);
    
    _categoryView.delegate = nil;
     //(_categoryView);
    
    _tableView.delegate = nil;
     //(_tableView);
    
     //(_shadowView);
     //(_subsRunningOnAddToMySub);
     //(_tableViewDelegate);
    _searchService.delegate = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    [[SNSubscribeCenterService defaultService] removeListener:self];    
    [_searchView removeFromSuperview];
    _searchView.delegate = nil;
    _maskView.delegate = nil;
    _categoryView.delegate = nil;
    _tableView.delegate = nil;
    _searchService.delegate = nil;
    _sogouSearchService.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTheme:nil];
    if (_query) {
        NSString *keyword = [_query stringValueForKey:kSearchWord defaultValue:nil];
        if ([keyword length] > 0) {
            _keyword = [keyword copy];
            
            int type = [_query intValueForKey:kSearchType defaultValue:0];
            [_searchView setType:type];
            [self doSearch:_keyword];
            SNDebugLog(@"keyword = %@ type = %d", _keyword, type);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 请求热词
    if (_query) {
         //(_query);
    }
    [_tableView reloadData];
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideKeyboard];
}

- (void)updateTheme:(NSNotification*)notification
{
    [self customTheme];
}

- (BOOL)isSupportRightPan
{
    return NO;
}

- (void)customTheme
{
    [self changeViewBg];
    _shadowView.image = [UIImage imageNamed:@"search_shadow.png"];
    [backButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    NSString *scrollBackgroundcolorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSearchHotwordViewBackgroundColor];
    NSString *backgroundColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    _searchScrollView.backgroundColor = [UIColor colorFromString:scrollBackgroundcolorString];
    _logoHeadView.backgroundColor = [UIColor colorFromString:backgroundColorString];
    _sogouIconView.backgroundColor = [UIColor colorFromString:backgroundColorString];
    _hotwordsView.backgroundColor = [UIColor colorFromString:backgroundColorString];

    [_searchView updateTheme];
    [_hotwordsView updateTheme];
    [_categoryView updateTheme];
}

- (void)changeViewBg
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    _tableView.backgroundColor = self.view.backgroundColor;
}

- (void)showHotwords:(BOOL)bShow
{
    _sogouIconView.hidden = [_sogouSearchService.iconArray count] > 0 ? !bShow : YES;
    _hotwordsView.hidden = !bShow;
    _tableView.hidden = bShow;
    _searchScrollView.scrollEnabled = contentScorllEnabled ? bShow : NO;
}

- (void)showLogoAnimation:(BOOL) isShow
{
    showLogo = isShow;
    int scrollViewTop = isShow ? 0 : kSearchLogoHeadHeight;
    [_searchScrollView setContentOffset:CGPointMake(0, scrollViewTop) animated:YES];
    
    float duration = showLogo ? 0.4 : 0.3 ;
    [UIView animateWithDuration:duration animations:^(void) {
        _tableView.top = isShow ? kSystemBarHeight + _logoHeadView.height + _searchView.height: kSystemBarHeight+_searchView.height;
    } completion:^(BOOL finished) {
        self.tableView.height = [self getTableViewHeight];
    }];
    
    if (isShow) {
        [self hideKeyboard];
    }
}


#pragma mark - 搜索
- (NSMutableArray *)subsRunningOnAddToMySub {
    return _subsRunningOnAddToMySub;
}

- (NSMutableArray *)getAllSuggestList {
    NSMutableArray *allSuggestList = [NSMutableArray arrayWithArray:self.suggestList];
    [allSuggestList addObjectsFromArray:self.suggestFromHistoryWords];
    for (SearchSuggestItem *item in allSuggestList) {
        item.keyword = self.keyword;
    }
    return allSuggestList;
}

- (NSMutableArray *)getAllHistoryList {
    NSMutableArray *allHistoryList = [NSMutableArray arrayWithArray:_searchHistoryWords];
    if ([allHistoryList count] >0) {
        SearchHistoryItem *clearHistoryItem = [[SearchHistoryItem alloc] init];
        clearHistoryItem.content = @"删除搜索记录";
        clearHistoryItem.isClear = YES;
        [allHistoryList addObject:clearHistoryItem];
    }
    return allHistoryList;
}

- (NSMutableArray *)getAllSearchList {
    NSMutableArray *allSearchList = nil;
    if (selectedSearchType == CATEGORY_SUBSCRIBE) {
        allSearchList = [NSMutableArray arrayWithArray:_searchService.allSubscribeList];
    }else {
        allSearchList = [NSMutableArray arrayWithArray:_searchService.resultList];
    }
    
    if (selectedSearchType != CATEGORY_ALL) {
        for (SNRollingNewsTableItem *item in allSearchList) {
            item.keyWord = self.keyword;
            item.isSearchNews = YES;
            if (item.news.subId && ![item.news.subId isEqualToString:@""]) {
                item.isLoading = [_subsRunningOnAddToMySub indexOfObject:item.news.subId] != NSNotFound;
            }else {
                item.isLoading = NO;
            }
        }
        if ([allSearchList count] >0 && _searchService.hasMore) {
            SNTableMoreButton *moreBtn = [SNTableMoreButton itemWithText:NSLocalizedString(@"Loading...", @"Loading...")];
            moreBtn.animating =  _searchService.isLoading;
            [allSearchList addObject:moreBtn];
        }
    }else {
        for (NSArray *searchArray in allSearchList) {
            for (SNRollingNewsTableItem *item in searchArray) {
                item.keyWord = self.keyword;
                item.isSearchNews = YES;
                if (item.news.subId && ![item.news.subId isEqualToString:@""]) {
                    item.isLoading = [_subsRunningOnAddToMySub indexOfObject:item.news.subId] != NSNotFound;
                }else {
                    item.isLoading = NO;
                }
            }
        }
    }
    return allSearchList;
}

- (NSArray *)getSectionTitles {
    if (selectedSearchType == CATEGORY_ALL) {
        NSArray *sectionTitles = nil;
        switch (dataSourceType) {
            case SNSearchDataSourceTypeSearch:
                if ([_searchService.searchSectionsList count] == 0) {
                    sectionTitles = nil;
                }else {
                    sectionTitles = _searchService.searchSectionsList;
                }
                break;
            default:
                break;
        }
        return sectionTitles;
    } else {
        return nil;
    }
}

- (NSArray *)suggestList {
    return _searchService.suggestList;
}

- (NSMutableArray *)suggestFromHistoryWords {
    if (_suggestFromHistoryWords == nil) {
        _suggestFromHistoryWords = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _suggestFromHistoryWords;
}

- (NSString *)keyword {
    return _searchView.keyword;
}

- (void)setKeyword:(NSString *)keyword {
    [_searchView setText:keyword];
}

- (NSMutableArray *)searchList {
    return _searchService.resultList;
}

- (NSMutableArray *)historyList {
    if (_searchHistoryWords == nil) {
        NSArray *words = [[SNDBManager currentDataBase] getSearchHistoryItems:kHistoryMax];
        _searchHistoryWords = [[NSMutableArray alloc] initWithArray:words];
    }
    return _searchHistoryWords;
}

- (void)clearHistoryList {
    [[SNDBManager currentDataBase] clearAllSearchHistoryItems];
    [_searchHistoryWords removeAllObjects];
    [self updateDataSourceWithType:SNSearchDataSourceTypeHistory];
    
    if (_searchView.keyword.length == 0) {
        // 显示热词
        [self showHotwords:YES];
    }
}

- (void)deleteHistoryAtIndex:(NSInteger)index {
    if (index < _searchHistoryWords.count) {
        SearchHistoryItem *item = [_searchHistoryWords objectAtIndex:index];
        [[SNDBManager currentDataBase] deleteSearchHistoryItem:item.content];
        [_searchHistoryWords removeObjectAtIndex:index];
    }
    [self updateDataSourceWithType:SNSearchDataSourceTypeHistory];
}

- (BOOL)hasMoreSearchResult {
    return _searchService.hasMore;
}

- (BOOL)isLoading {
    return _searchService.isLoading;
}

- (void)hideKeyboard {
    [_searchView endEditing:YES];
}

- (void)doSearch:(NSString *)keyword {
    [self hideKeyboard];
    _searchView.text = keyword;
    _refer = REFER_SEARCH;
    
    [self searchViewDoSearch:_searchView];
}

- (void)loadMoreSearchResult {
    
    if (_keyword.length == 0) {
        return;
    }
    if ([self hasMoreSearchResult] && !self.isLoading) {
        if (dataSourceType == SNSearchDataSourceTypeSearch) {
            [_searchService loadNextPageWithKeyword:_keyword type:_searchView.type];
            [self updateDataSourceWithType:SNSearchDataSourceTypeSearch];
        }
    }
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
    if ([object isKindOfClass:[TTTableMoreButton class]]) {
        [self loadMoreSearchResult];
    }
}

#pragma mark - 热词
- (void)selectedTag:(SNTagItem *)tagItem {
    selectedSearchType = CATEGORY_ALL;
    [_searchView setType:selectedSearchType];
    [self doSearch:tagItem.tagValue];
    [self showHotwords:NO];
    _refer = REFER_SEARCH_HOTWORDS;
}

- (void)didTouchBeganInTagView {
    [self hideKeyboard];
}

#pragma mark - search delegate

- (BOOL)canFocus {
    return YES;
}

- (void)searchViewBeginSearch:(SNSubCenterSearchView *)searchView {
    if (self.historyList.count > 0) {
        if (_searchView.keyword.length == 0) {
            [self showEmpty:NO];
            [self showError:NO];
            [self showHotwords:NO];
            [self updateDataSourceWithType:SNSearchDataSourceTypeHistory];
        }
    }
    
    [self showLogoAnimation:NO];
}

- (void)searchViewWillEndSearch:(SNSubCenterSearchView *)searchView {
    
}

- (void)searchViewDidEndSearch:(SNSubCenterSearchView *)searchView {
    
    [self showLogoAnimation:YES];
    
    if (dataSourceType == SNSearchDataSourceTypeSuggest || dataSourceType == SNSearchDataSourceTypeHistory) {
        [self showHotwords:YES];
    }
    return;
    
    [_searchService cancel];
    [_searchService.suggestList removeAllObjects];
    [_searchService.resultList removeAllObjects];
    
    [[SNSubscribeCenterService defaultService] removeListener:self];
    searchView.delegate = nil;
    
    [self.flipboardNavigationController popViewControllerAnimated:NO];
}

- (void)searchViewDoSearch:(SNSubCenterSearchView *)searchView {
    
    
    [self showEmpty:NO];
    [self showError:NO];
    
    keyBoardSearch = YES;
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    [_searchService.suggestList removeAllObjects];
    [_searchService.resultList removeAllObjects];
    
    NSString *keyword = _searchView.keyword;
    NSString *type = _searchView.type;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:_searchService];
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    _keyword = [keyword copy];
    
    if (keyword.length > 0) {
        SNDebugLog(@"search: keyword = %@, type = %@", keyword, type);
        
        // 添加到搜索历史
        SearchHistoryItem *historyItem = [[SearchHistoryItem alloc] init];
        historyItem.content = keyword;
        historyItem.time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        BOOL result = [[SNDBManager currentDataBase] addSearchHistoryItem:historyItem];
        if (result) {
            if (self.historyList.count >= kHistoryMax) {
                SearchHistoryItem *last = [self.historyList lastObject];
                [[SNDBManager currentDataBase] deleteSearchHistoryItemsBefore:last];
                [self.historyList removeObjectsInRange:NSMakeRange(kHistoryMax-1, self.historyList.count - kHistoryMax + 1)];
            }
            
            NSArray *words = [[SNDBManager currentDataBase] getSearchHistoryItems:kHistoryMax];
            [self.historyList removeAllObjects];
            [self.historyList addObjectsFromArray:words];
        }
        
        [_searchService search:keyword type:type];
        [self updateDataSourceWithType:SNSearchDataSourceTypeSearch];
        [self showLoading:YES];
    }
    
     //(_lastSuggestWord);
}

- (void)searchViewDidChange:(SNSubCenterSearchView *)searchView text:(NSString *)text {
    SNDebugLog(@"suggest: keyword = %@", text);
    [self showEmpty:NO];
    [self showError:NO];
    [self showLoading:NO];
    
    keyBoardSearch = NO;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length > 0) {
        [self updateDataSourceWithType:SNSearchDataSourceTypeSuggest];
        [self showHotwords:NO];
        
        if (![text isEqualToString:_lastSuggestWord]) {
            // 匹配搜索历史
            [self.suggestFromHistoryWords removeAllObjects];
            
            for (SearchHistoryItem *item in self.historyList) {
                if ([item.content rangeOfString:text].length > 0 && !item.isClear) {
                    SearchSuggestItem *suggestItem = [[SearchSuggestItem alloc] init];
                    suggestItem.content = item.content;
                    [self.suggestFromHistoryWords addObject:suggestItem];
                }
            }
            
            if (self.suggestFromHistoryWords.count > 0) {
                [_tableView reloadData];
            }
            
            // 从网络请求suggest
            [NSObject cancelPreviousPerformRequestsWithTarget:_searchService];
            [_searchService performSelector:@selector(suggest:) withObject:text afterDelay:0.2];
        }
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:_searchService];
        [_searchService.suggestList removeAllObjects];
        [self.suggestFromHistoryWords removeAllObjects];
        
        if (self.historyList.count > 0) {
            [self updateDataSourceWithType:SNSearchDataSourceTypeHistory];
        } else {
            [self showHotwords:YES];
        }
    }
    
     //(_lastSuggestWord);
    _lastSuggestWord = [text copy];
}

// 弹出分类选择视图
- (void)showCategoryView {
    [_categoryView setSelectedSearchType:selectedSearchType];
    [_categoryView show];
    _categoryView.top = showLogo ? kSystemBarHeight + _logoHeadView.height + 30: kSystemBarHeight +30;
    [self.view insertSubview:_maskView belowSubview:_categoryView];
    [_searchView toggleCategoryBtn];
}

// 隐藏分类选择视图
- (void)hideCategoryView {
    [_categoryView hide];
    [_maskView removeFromSuperview];
    [_searchView toggleCategoryBtn];
}

- (void)clickSearchCategoryBtn {
    if (_categoryView.isShowing) {
        [self hideCategoryView];
    } else {
        [self showCategoryView];
    }
}

- (void)searchViewDidBeginTouch {
    [self hideKeyboard];
}

#pragma mark -
#pragma mark SNSearchHotwordsViewDelegate

- (void)getHotwordsRefreshRequest
{
    [_sogouSearchService getSearchHotWordRequest];
}

#pragma mark -
#pragma mark SNEmbededActivityIndicator Delegate

- (void)didTapRetry
{
    [self searchViewDoSearch:_searchView];
}

#pragma mark - SNTripletsLoadingViewDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView
{
    [self searchViewDoSearch:_searchView];
}

#pragma mark - SNSearchCategoryViewDelegate
- (void)didSelectedCategoryType:(SearchCategoryType)type {
    
    selectedSearchType = type;
    [_searchView setType:type];
    [self doSearch:_searchView.keyword];
    [self hideCategoryView];
    
    // 触发相应的cc统计
    NSString *link = [NSString stringWithFormat:@"search://typeId=%d", type];
    SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:link];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [curPage toFormatString], f_select];
    [SNNewsReport reportADotGifWithTrack:paramString];
    
}

#pragma mark - SNSearchCategoryMaskViewDelegate
- (void)didTouchBeganInMaskView:(UIView *)view {
    if (view == _maskView) {
        [self hideCategoryView];
    } else {
        [self hideKeyboard];
    }
}


#pragma mark -
#pragma mark SNSogouSearchServiceDelegate

- (void)sogouSearchIconDidFinishLoad
{
    [self createSogouButtons];
}

- (void)sogouSearchHotwordDidFinishLoad
{
    [self updateHotWords];
}

#pragma mark - SNSearchServiceDelegate

// 搜索结果
- (void)searchDidFinishLoadWithPageNo:(int)pageNo {
    
    [self showLoading:NO];
    [self showError:NO];
    
    if (_searchService.resultList.count == 0) {
        if (keyBoardSearch) {
            [self showEmpty:YES];
        }
    } else {
        [self showEmpty:NO];
    }
    
    [self updateDataSourceWithType:SNSearchDataSourceTypeSearch];
}

- (void)searchDidFailLoadWithPageNo:(int)pageNo andError:(NSError *)error {
    if (_searchService.resultList.count == 0) {
        [self showLoading:NO];
        [self showEmpty:NO];
        [self showError:YES];
    } else {
        [self showError:NO];
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    }
}

- (void)searchDidCancelLoadWitPageNo:(int)pageNo {
    if (_searchService.resultList.count == 0) {
        [self showLoading:NO];
    }
    
    if (pageNo > 1) {
        //[_searchTableViewDelegate setMoreCellLoading:NO hasNoMore:!_searchService.hasMore];
    }
}

// 搜索提示
- (void)searchSuggestDidFinishLoad {
    
    [self showLoading:NO];
    [self showEmpty:NO];
    [self showError:NO];
    
    [self updateDataSourceWithType:SNSearchDataSourceTypeSuggest];
    [_tableView reloadData];
}

#pragma mark - SNSearchResultSubscribeCellDelegate

- (void)allSubCellWillAddMySub:(SCSubscribeObject *)subObj {
    if (!subObj.subId) {
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
    
    if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:subObj]) {
        [SNGuideRegisterManager showGuideWithSubId:subObj.subId];
        return;
    }
    
    [_subsRunningOnAddToMySub addObject:subObj.subId];
    SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:subObj.subId];
    NSString *sucMsg = [subObj succSubMsg];
    NSString *failMsg = [subObj failSubMsg];
    [opt addBackgroundListenerWithSuccMsg:sucMsg failMsg:failMsg];
    
    subObj.from = _refer;
    [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:subObj];
}


#pragma mark - SNSubscribeCenterServiceDelegate

- (void)handleSubscribeNewsWithSubId:(NSString *) subId newsArray:(NSArray *) newsArray
{
    if (subId.length > 0) {
        for (SNRollingNewsTableItem *item in newsArray) {
            if ([item.news.subId isEqualToString:subId]) {
                item.news.isSubscribe = @"1";
                break;
            }
        }
    }
}

- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [_subsRunningOnAddToMySub removeObject:subId];
        
        if (selectedSearchType == CATEGORY_ALL) {
            for (NSArray *newsArray in _searchService.resultList) {
                [self handleSubscribeNewsWithSubId:subId newsArray:newsArray];
            }
        }else {
            [self handleSubscribeNewsWithSubId:subId newsArray:_searchService.resultList];
        }
        
        [self updateDataSourceWithType:dataSourceType];
        [_tableView reloadData];
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [_subsRunningOnAddToMySub removeObject:subId];
        [self updateDataSourceWithType:dataSourceType];
        [_tableView reloadData];
        return;
    }
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [_subsRunningOnAddToMySub removeObject:subId];
        [self updateDataSourceWithType:dataSourceType];
        [_tableView reloadData];
        return;
    }
}

# pragma mark - 网络错误界面
- (void)showError:(BOOL)show {
    SNSearchCategoryMaskView *emptyView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kEmptyViewTag];
    SNSearchCategoryMaskView *loadingView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kLoadingViewTag];
    if (emptyView) {
        [emptyView removeFromSuperview];
        emptyView = nil;
    }
    if (loadingView) {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
    if (show) {
        _tableView.scrollEnabled = NO;
        if (!_tripletsLoadingView) {
            _tripletsLoadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight-108)];
            _tripletsLoadingView.delegate = self;
            _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
            _tripletsLoadingView.center = CGPointMake(_tableView.center.x, _tableView.center.y - 120);
            [self.tableView addSubview:_tripletsLoadingView];
        }
        _tripletsLoadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
    } else {
        _tableView.scrollEnabled = YES;
        _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
    }
}

- (void)showEmpty:(BOOL)show
{
    if (!keyBoardSearch) {
        return;
    }
    _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
    _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
    SNSearchCategoryMaskView *overlayView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kEmptyViewTag];
    SNSearchCategoryMaskView *loadingView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kLoadingViewTag];
    if (loadingView) {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
    if (show) {
        if (overlayView == nil) {
            overlayView = [[SNSearchCategoryMaskView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight - 108)];
            overlayView.delegate = self;
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

- (void)showLoading:(BOOL)show
{
    _tripletsLoadingView.status = SNTripletsLoadingStatusStopped;
    _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
    SNSearchCategoryMaskView *overlayView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kLoadingViewTag];
    SNSearchCategoryMaskView *emptyView = (SNSearchCategoryMaskView *)[_tableView viewWithTag:kEmptyViewTag];
    if (emptyView) {
        [emptyView removeFromSuperview];
        emptyView = nil;
    }
    if (show) {
        if (overlayView == nil) {
            BOOL isIOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0;
            int changeHeight = isIOS7 ? 0 : kSearchViewHeight;
            int logoHeight = showLogo ? kSearchLogoHeight : 0;
            overlayView = [[SNSearchCategoryMaskView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight - 108)];
            overlayView.delegate = self;
            overlayView.center = CGPointMake(kAppScreenWidth/2, kSystemBarHeight + changeHeight + kAppScreenHeight/2 - logoHeight);
            overlayView.isAccessibilityElement = YES;
            overlayView.accessibilityLabel = @"正在搜索";
            overlayView.tag = kLoadingViewTag;
            [_tableView addSubview:overlayView];
            _tableView.scrollEnabled = NO;
            
            UIImageView *_logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_logo.png"]];
            _logo.center = CGPointMake(_tableView.centerX, _tableView.center.y - 160);
            [overlayView addSubview:_logo];
            
            SNWaitingActivityView *_loading = [[SNWaitingActivityView alloc] init];
            
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

#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _searchScrollView && scrollView.contentSize.height >  kAppScreenHeight - kSearchToolbarHeight - kSystemBarHeight) {
        int scrollViewTop = scrollView.contentOffset.y;
        //点击搜索框滚动位置时不触发切换view操作
        if (scrollViewTop == 40) {
            return;
        }
        
        if (scrollViewTop > kSearchLogoHeadHeight) {
            if (searchMoveToTop) {
                return;
            }
            searchMoveToTop = YES;
            showLogo = NO;
            [_searchView removeFromSuperview];
            [self.view addSubview:_searchView];
            _searchView.top = kSystemBarHeight;
        }else {
            if (!searchMoveToTop) {
                return;
            }
            searchMoveToTop = NO;
            showLogo = YES;
            [_searchView removeFromSuperview];
            [_searchScrollView insertSubview:_searchView aboveSubview:_hotwordsView];
            _searchView.top = _logoHeadView.bottom;
        }
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideKeyboard];
    if (scrollView == _tableView) {
        NSInteger rows = [_tableView numberOfRowsInSection:0];
        if (rows > 0) {
            _shadowView.hidden = NO;
        }
    }
    if (scrollView == _searchScrollView) {
        _shadowView.hidden = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _shadowView.hidden = YES;
    
    //统计曝光
    NSArray *cells = self.tableView.visibleCells;
    NSMutableDictionary *exposureDic = [NSMutableDictionary dictionary];
    for (UITableViewCell *cell in cells) {
        [cell reportPopularizeStatExposureInfo];
    }
    
    [[SNNewsExposureManager sharedInstance] exposureNewsInfoWithDic:exposureDic];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        _shadowView.hidden = YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return NO;
}

- (void)showCancelButtonWithAnimation {
    [_searchView showCancelButtonWithAnimation:YES];
}

- (BOOL)needPanGesture
{
    return NO;
}

- (BOOL)isSupportPushBack {
    return NO;
}
@end
