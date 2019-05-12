//
//  SNSubCenterAllListViewController.m
//  sohunews
//
//  Created by Chen Hong on 12-11-20.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#define kAdViewHeight                           ([[UIScreen mainScreen] bounds].size.width / 6.4)
                                                //订阅广场广告位 比例6.4:1

#define kTypeTableWidth                         (164 / 2)

#import "SNSubCenterAllListViewController.h"
#import "SNSubCenterTypesHelper.h"
#import "SNSubCenterSubsHelper.h"
#import "SNSubCenterTopAdView.h"
#import "SNHeadSelectView.h"
#import "SNToolbar.h"
#import "UIColor+ColorUtils.h"
#import "SNAdvertiseManager.h"
#import "SNDBManager.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNTripletsLoadingView.h"


@interface SNSubCenterAllListViewController ()<SNAdDataCarrierDelegate, SNAdDataCarrierActionDelegate> {
    CGRect _viewFrame;
    
    SNSubCenterTopAdView *_adView;
    
    UITableView *_typeTableView;
    UITableView *_subTableView;
    
    UIImageView *_viticleSepLine;
    
    SNSubCenterTypesHelper *_typesHelper;
    SNSubCenterSubsHelper *_subsHelper;
    
    BOOL _bAdViewShown;
    BOOL _bAdViewAnimating;
    BOOL _bViewLoaded;
    
    BOOL _bNeedLoading;

    SNTripletsLoadingView *_sublistLoadingView;
    SNTripletsLoadingView *_fullscreenLoadingView;
    
    BOOL _bNeedRemoveAdViewData;
}

@property (nonatomic, strong) NSMutableArray *topAds; // 订阅中心 老版本广告数据
@property (nonatomic, strong) NSMutableArray *topAdDataCarriers;
@property (nonatomic, assign) BOOL isSdkAdDisplay;

- (void)setTopAdViewShown:(BOOL)bShow animated:(BOOL)bAnimated;

@end

@implementation SNSubCenterAllListViewController
@synthesize topAdDataCarriers = _topAdDataCarriers;
@synthesize topAds = _topAds;
@synthesize isSdkAdDisplay;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithNibName:nil bundle:nil];
    _viewFrame = frame;
	return self;
}

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    self.hidesBottomBarWhenPushed = YES;
    _viewFrame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth, kAppScreenHeight - kToolbarViewTop-kHeadSelectViewBottom);
    return self;
}

- (SNCCPVPage)currentPage {
    return paper_square;
}

- (void)dealloc {
    [_typesHelper stopListen];
    [_subsHelper stopListen];
    
     //(_adView);
     //(_typeTableView);
     //(_subTableView);
     //(_viticleSepLine);
    
     //(_typesHelper);
     //(_subsHelper);
    
    for (SNAdDataCarrier *adDataCarrier in _topAdDataCarriers) {
        adDataCarrier.delegate = nil;
//        [[SNAdvertiseManager sharedManager] cleanCacheAdDataCarrier:adDataCarrier];
    }
    [_topAdDataCarriers removeAllObjects];
    
     //(_topAdDataCarriers);
     //(_topAds);
}

- (NSMutableArray *)topAdDataCarriers {
    if (!_topAdDataCarriers) {
        _topAdDataCarriers = [[NSMutableArray alloc] init];
    }
    return _topAdDataCarriers;
}

- (NSMutableArray *)topAds {
    if (!_topAds) {
        _topAds = [[NSMutableArray alloc] init];
    }
    return _topAds;
}

- (void)createSubListLoadingView {
    if (!_sublistLoadingView) {
        CGRect sublistLoadingViewFrame = CGRectMake(_subTableView.left + 2,
                                                    _subTableView.top + 4,
                                                    _subTableView.width,
                                                    _subTableView.height
                                                    );
        _sublistLoadingView = [[SNTripletsLoadingView alloc] initWithFrame:sublistLoadingViewFrame];
        _sublistLoadingView.delegate = self;
        [self.view addSubview:_sublistLoadingView];
    }
}

- (void)createFullscreenLoadingView {
    if (!_fullscreenLoadingView) {
        CGRect loadingViewFrame = CGRectMake(0, 0, self.view.width, TTScreenBounds().size.height);
        _fullscreenLoadingView = [[SNTripletsLoadingView alloc] initWithFrame:loadingViewFrame];
        _fullscreenLoadingView.delegate = self;
        [self.view addSubview:_fullscreenLoadingView];
    }
}

- (void)addSearchButton
{
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.headerView.width-43, kSystemBarHeight, 42, 42)];
    [searchBtn addTarget:self action:@selector(onSearch:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setImage:[UIImage imageNamed:@"icosquare_search_v5.png"] forState:UIControlStateNormal];
    searchBtn.accessibilityLabel = @"搜索";
    searchBtn.tag = 1000;
    [self.headerView addSubview:searchBtn];
}

-(void)customerViewBg {
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

- (void)loadView {
    [super loadView];
    
    [self customerViewBg];
    
    // 默认先不显示adview
    // ad view
    _adView = [[SNSubCenterTopAdView alloc] initWithFrame:CGRectMake(0, _viewFrame.origin.y - kAdViewHeight, _viewFrame.size.width, kAdViewHeight)];
    _adView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_adView];
    
    // type list tableview
    _typeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _viewFrame.origin.y, kTypeTableWidth, _viewFrame.size.height) style:UITableViewStylePlain];
    _typeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _typeTableView.showsVerticalScrollIndicator = NO;
    _typeTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_typeTableView];
    
    _typesHelper = [[SNSubCenterTypesHelper alloc] initWithTableView:_typeTableView delegate:self];
    [_typesHelper startListen];
    
    // sub list tableview
    _subTableView = [[UITableView alloc] initWithFrame:CGRectMake(_typeTableView.right, _typeTableView.top, _viewFrame.size.width - _typeTableView.width, _typeTableView.height) style:UITableViewStylePlain];
    _subTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _subTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_subTableView];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        _typeTableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, kToolbarViewHeight, 0.f);
        _typeTableView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
        
        _subTableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, kToolbarViewHeight, 0.f);
        _subTableView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
    }
    
    _subsHelper = [[SNSubCenterSubsHelper alloc] initWithTableView:_subTableView delegate:self];
    [_subsHelper startListen];
    
    // viticleSepLine
    UIEdgeInsets sepLineImageInsets = UIEdgeInsetsMake(1, 0, 1, 0);
    UIImage *sepLineImage = [[UIImage imageNamed:@"subcenter_allsub_vrticle_sep_line.png"] resizableImageWithCapInsets:sepLineImageInsets resizingMode:UIImageResizingModeStretch];
    _viticleSepLine = [[UIImageView alloc] initWithFrame:CGRectMake(_subTableView.left, _subTableView.top, sepLineImage.size.width, _viewFrame.size.height)];
    _viticleSepLine.image = sepLineImage;
    _viticleSepLine.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:_viticleSepLine];

    [self createSubListLoadingView];
    [self createFullscreenLoadingView];
    
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"subcenter_title",@""), nil]];
    self.headerView.delegate = self;
    CGSize titleSize = [NSLocalizedString(@"subcenter_title",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(6, self.headerView.height-2, titleSize.width+8, 2)];
    
    [self addSearchButton];
    [self addToolbar];
    
    if (_bNeedLoading) {
        _bNeedLoading = NO;
        _fullscreenLoadingView.status = SNTripletsLoadingStatusLoading;
    }
    else {
        if ([_typesHelper.typesArray count] <= 0) {
            _fullscreenLoadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
        }
    }
    
    // 加载老版本&sdk广告 如果订阅中心接口正在刷新 不去load广告数据
    if (!_typesHelper.isLoading) {
        [self reloadOldAdsFromCache];
        [self reloadAdDataFromCache];
    }
    
    // 如果没有sdk广告 直接看有没有老版本广告
    if (self.topAdDataCarriers.count == 0 && self.topAds.count > 0) {
        _adView.adDataCarriers = nil;
        _adView.adListArray = self.topAds;
        [self setTopAdViewShown:YES animated:NO];
    }
}

- (void)handleHeadviewDoubleTap:(UITapGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        [SNUtility getApplicationDelegate].showViewBorder = ![SNUtility getApplicationDelegate].showViewBorder;
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _bViewLoaded = YES;
}

- (void)viewDidUnload {
    [_typesHelper stopListen];
    [_subsHelper stopListen];
    
     //(_typesHelper);
     //(_subsHelper);
     //(_toolbarView);
     //(_adView);
     //(_typeTableView);
     //(_subTableView);
     //(_viticleSepLine);
    
    
    _bViewLoaded = NO;
    _bAdViewShown = NO;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 解决 登陆 或者注销之后 需要强制刷新本地缓存
    if (_fullscreenLoadingView.status == SNTripletsLoadingStatusStopped &&
        [SNSubscribeCenterService shouldReloadHomeData] &&
        !_typesHelper.isLoading) {
        [_typesHelper refreshDataWithCheckExpired:NO];
    }
    else {
        [_subsHelper reloadData];
        [_typesHelper reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SNSubCenterTypesHelperDelegate

- (void)didSelectTypeWithTypeId:(NSString *)typeId {
    [_subsHelper setTypeId:typeId];
}


- (void)didFinishLoadHomeDataWithTypeId:(NSString *)typeId {
    _fullscreenLoadingView.status = SNTripletsLoadingStatusStopped;
    
    [_subsHelper setTypeId:typeId];
    // init home data callback
    
    [self reloadOldAdsFromCache];
    [self reloadAdDataFromCache];
    
    // 没有任何广告
    if (self.topAdDataCarriers.count == 0 && self.topAds.count == 0) {
        [self setTopAdViewShown:NO animated:YES];
    }
    
    // 没有sdk广告，尝试加载老版本广告
    if (self.topAdDataCarriers.count == 0 && self.topAds.count > 0) {
        _adView.adDataCarriers = nil;
        _adView.adListArray = self.topAds;
        [self setTopAdViewShown:YES animated:YES];
    }

}

- (void)didFailLoadHomeData {
    [self typesFindNoDataToLoad];
}

- (void)typesTableDidScroll:(UIScrollView *)scroll {
    
}

- (void)typesFindNoDataToLoad {
    _fullscreenLoadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
}

- (void)typesStartToLoad {
    if (_bViewLoaded) {
        _fullscreenLoadingView.status = SNTripletsLoadingStatusLoading;
    }
    else {
        _bNeedLoading = YES;
    }
}

#pragma mark - SNSubCenterSubHelpDelegate

- (void)allSubTableDidScroll:(UIScrollView *)scrollview {
    // 一屏最大容纳的cell个数 改为动态计算 否则在iphone5 iphone6什么的上面 会出问题;
    int maxLimit = (int)(self.view.height - self.headerView.height - self.toolbarView.height) / (146 / 2) + 1;
    if (([_adView.adListArray count] > 0 || [_adView.adDataCarriers count] > 0) && [[_subsHelper subsArray] count] > maxLimit) {
        if (!_subTableView.isTracking) {
            if (scrollview.contentOffset.y > 60) {
                [self setTopAdViewShown:NO animated:YES];
            }
            else if (scrollview.contentOffset.y > 0) {
                [self setTopAdViewShown:YES animated:YES];
            }
        }
        else if (scrollview.contentOffset.y < 0) {
            [self setTopAdViewShown:YES animated:YES];
        }
    }

}

- (void)subsStartToLoad {
    _sublistLoadingView.status = SNTripletsLoadingStatusLoading;
}

- (void)subsFindNoDataToLoad {
    _sublistLoadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
}

- (void)subsFindDataToLoad {
    _sublistLoadingView.status = SNTripletsLoadingStatusStopped;
}

- (BOOL)isAdViewShown {
    return _bAdViewShown;
}

#pragma mark - SNAdDataCarrierDelegate
- (void)adViewDidAppearWithCarrier:(SNAdDataCarrier *)carrier {
//    if ([self.topAdDataCarriers indexOfObject:carrier] == NSNotFound) {
        //广告sdk加载成功,进行加载统计
        [carrier reportForLoadTrack];
        
        self.isSdkAdDisplay = YES;
        _adView.adListArray = nil;
        
        [self.topAdDataCarriers addObject:carrier];
        [_adView appendAdDataCarriers:carrier];
        
        [self setTopAdViewShown:YES animated:YES];
//    }
}

- (void)adViewDidFailToLoadWithCarrier:(SNAdDataCarrier *)carrier {
    // sdk都加载失败了 尝试加载老版本广告
    if (self.topAdDataCarriers.count == 0 && self.topAds.count > 0) {
        _adView.adDataCarriers = nil;
        _adView.adListArray = self.topAds;
        [self setTopAdViewShown:YES animated:YES];
    }
}

// 重新加载sdk广告
- (void)reloadAdDataFromCache {
    for (SNAdDataCarrier *cr in self.topAdDataCarriers) {
        cr.delegate = nil;
    }
    if (_adView.adDataCarriers.count > 0) {
        return;
    }
    [self.topAdDataCarriers removeAllObjects];
//    [_adView removeAllSubviews];
    
    if ([[SNAdvertiseManager sharedManager] isSDKAdEnable]) {
        NSArray *adCtrlInfos = [[SNDBManager currentDataBase] adInfoGetAdInfosByType:SNAdInfoTypeSubCenterTopBanner
                                                                              dataId:kAdInfoDefaultCategoryId
                                                                          categoryId:kAdInfoDefaultCategoryId];
        if ([adCtrlInfos count] > 0) {
            SNAdControllInfo *adCtrlInfo = adCtrlInfos[0];
            for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
                SNAdDataCarrier *adDataCarrier = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                                adInfoParam:adInfo.filterInfo];
                adDataCarrier.delegate = self;
                adDataCarrier.appChannel = adInfo.appChannel;
                adDataCarrier.newsChannel = adInfo.newsChannel;
                adDataCarrier.gbcode = adInfo.gbcode;
                adDataCarrier.subId = adInfo.filterInfo[@"subid"];
                adDataCarrier.adId = adInfo.adId;
                [self.topAdDataCarriers addObject:adDataCarrier];
                [adDataCarrier refreshAdData:NO];
            }
        }
    }
}

// 重新加载老版本广告
- (void)reloadOldAdsFromCache {
    [self.topAds removeAllObjects];
    if (_adView.adListArray.count > 0) {
        return;
    }
    
    NSArray *adListArray = [[SNSubscribeCenterService defaultService] loadAdListFromLocalDBForType:SNSubCenterAdListTypeSubCenter];
    if (adListArray) {
        [self.topAds addObjectsFromArray:adListArray];
        
        //添加订阅推广位加载统计
        [SNStatisticsInfoAdaptor uploadSubPopularizeLoadInfo:adListArray];
    }
}

#pragma mark - private methods
- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [_typesHelper stopListen];
        [_subsHelper stopListen];
    }
}

- (void)onBack:(id)sender {
    [_typesHelper stopListen];
    [_subsHelper stopListen];
    [[TTNavigator navigator].topViewController.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)onSearch:(id)sender {
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://search"] applyAnimated:YES] applyQuery:nil];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)showTopAdViewAnimationDidStop {
    _bAdViewAnimating = NO;
    _typeTableView.height = _viewFrame.size.height - kAdViewHeight - kHeadSelectViewHeight;
    _subTableView.height = _typeTableView.height;
}

- (void)hideTopAdViewAnimationDidStop {
    _bAdViewAnimating = NO;
    if (_bNeedRemoveAdViewData && _adView) {
        _bNeedRemoveAdViewData = NO;
        _adView.adListArray = nil;
        _adView.adDataCarriers = nil;
    }
}

- (void)setTopAdViewShown:(BOOL)bShow animated:(BOOL)bAnimated {
    if (!(_bAdViewShown ^ bShow)) {
        return;
    }
    
    if (bAnimated && _bAdViewAnimating) {
        return;
    }
    
    _bAdViewShown = bShow;
    
    if (bShow && ![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        if (!bAnimated) {
            _typeTableView.height = _viewFrame.size.height - kAdViewHeight - kHeadSelectViewHeight;
            _subTableView.height = _typeTableView.height;
        }
    }
    else {
        _typeTableView.height = _viewFrame.size.height;
        _subTableView.height = _typeTableView.height;
    }
    
    // fix 广告位被错误、loading页面遮挡的bug
    [self.view bringSubviewToFront:_adView];
    [self.view bringSubviewToFront:self.headerView];
    [self.view bringSubviewToFront:self.toolbarView];
    
    if (bAnimated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        if (bShow && ![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
            [UIView setAnimationDidStopSelector:@selector(showTopAdViewAnimationDidStop)];
        }
        else {
            [UIView setAnimationDidStopSelector:@selector(hideTopAdViewAnimationDidStop)];
        }
        
        _bAdViewAnimating = YES;
    }
    
    if (bShow && ![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        _adView.top = _viewFrame.origin.y + kHeadSelectViewHeight;
        _typeTableView.top = _adView.bottom ;
        _subTableView.top = _typeTableView.top;
        _viticleSepLine.top = _typeTableView.top;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            _typeTableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
            
            _subTableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
        }
        
    }
    else {
        _adView.top = _viewFrame.origin.y - kAdViewHeight;
        _typeTableView.top = _viewFrame.origin.y;
        _subTableView.top = _typeTableView.top;
        _viticleSepLine.top = _typeTableView.top;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            _typeTableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, kToolbarViewHeight, 0.f);
            
            _subTableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, kToolbarViewHeight, 0.f);
        }
    }
    
    if (bAnimated) {
        [UIView commitAnimations];
    }
}

- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        tripletsLoadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    tripletsLoadingView.status = SNTripletsLoadingStatusLoading;
    
    if (_fullscreenLoadingView == tripletsLoadingView) {
        [_typesHelper refreshDataWithCheckExpired:NO];
    }
    else {
        [_subsHelper setNeedForceRefresh:YES];
        [_subsHelper setTypeId:_subsHelper.typeId];
    }
}

#pragma mark - override superview
- (void)updateTheme:(NSNotification *)notifiction {
//    [self didReceiveMemoryWarning];
    [self updateTheme];
}

- (void)updateTheme {
    [self customerViewBg];
    
    // 默认先不显示adview
    
    // ad view
    if (_adView) {
//        SNSubCenterTopAdView *aNewAdView = [[SNSubCenterTopAdView alloc] initWithFrame:_adView.frame];
//        
//        if (_adView.adListArray) {
//            aNewAdView.adListArray = _adView.adListArray;
//        }
//        else if (_adView.adDataCarriers) {
//            aNewAdView.adDataCarriers = _adView.adDataCarriers;
//        }
//        
//        [self.view addSubview:aNewAdView];
//        
//        [_adView removeFromSuperview];
//         //(_adView);
//        _adView = aNewAdView;
        [_adView updateTheme];
    }
    
    // viticleSepLine
    UIEdgeInsets sepLineImageInsets = UIEdgeInsetsMake(1, 0, 1, 0);
    UIImage *sepLineImage = [[UIImage imageNamed:@"subcenter_allsub_vrticle_sep_line.png"] resizableImageWithCapInsets:sepLineImageInsets resizingMode:UIImageResizingModeStretch];
    _viticleSepLine.image = sepLineImage;
    
    // add header view
    if (self.headerView) {
        [self.headerView updateTheme];
        [[self.headerView viewWithTag:1000] removeFromSuperview];
        [self addSearchButton];
    }
    if (_toolbarView) {
        [_toolbarView removeFromSuperview];
         //(_toolbarView);
        [self addToolbar];
    }
}

@end
