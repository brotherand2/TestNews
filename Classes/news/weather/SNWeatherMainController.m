//
//  SNWeatherMainController.m
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherMainController.h"
#import "SNWeatherTopBar.h"
#import "SNWeatherBottomBar.h"

#import "SNThemeManager.h"
#import "SNActionMenuController.h"
#import "SNToolbar.h"
#import "SNLocationManager.h"
#import "SNWebImageView.h"
#import "SNNewsShareManager.h"


#define kBottomBarHeight            (100.0)

#define kNaviBtnTopMargin           (332.0 / 2)
#define kNaviBtnSideMargin          (7.0 / 2)
#define kNaviBtnWidth               (40.0 / 2)
#define kNaviBtnHeight              (70.0 / 2)

#define kNightThemeBgAlpha          (0.5)

#define kCompressionQuality         (0.5)


@interface SNWeatherToolBar : SNToolbar

@end

@implementation SNWeatherToolBar

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.leftButton) {
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            self.leftButton.frame = CGRectMake(2.0, (self.height -20 - self.leftButton.height) / 2, self.leftButton.width, self.leftButton.height);
        }else{
            self.leftButton.frame = CGRectMake(2.0, (self.height - self.leftButton.height) / 2, self.leftButton.width, self.leftButton.height);
        }
    }
    if (self.rightButton) {
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            self.rightButton.frame = CGRectMake(self.width - 2.0 - self.rightButton.width, (self.height - 20 - self.rightButton.height) / 2,self.rightButton.width, self.rightButton.height);
        }else{
            self.rightButton.frame = CGRectMake(self.width - 2.0 - self.rightButton.width, (self.height - self.rightButton.height) / 2,self.rightButton.width, self.rightButton.height);
        }
    }
}

@end


@interface SNWeatherMainController () {
    UIScrollView *_scrollView;
    SNWebImageView *_bgWeatherView;
    UIImageView *_animationMask;
    
    NSArray *_citiesArray;
    NSMutableArray *_citiesViewArray;
    
    SNWeatherTopBar *_topBar;
    SNToolbar *_toolBar;
    
    BOOL _isBarHide;
    
    int _currentViewIndex;
    int _scrollViewOffset;
    
    NSString *_lastWeatherName;
    
    UIButton *_preBtn;
    UIButton *_nextBtn;
    
    NSString *_lastScreenImagePath;
    NSString *_gbcode;
    NSString *_city;
    BOOL _isBack;
}

@property(nonatomic, strong) SNActionMenuController* actionMenuController;
@property(nonatomic, strong) SNNewsShareManager* shareManager;
@property(nonatomic, strong)NSArray *citiesArray;
@property(nonatomic, strong)NSArray *citiesViewArray;
@property(nonatomic, copy)NSString *lastWeatherName;
@property(nonatomic, copy)NSString *lastScreenImagePath;
@property(nonatomic, strong)NSString *gbcode;
@property(nonatomic, strong)NSString *city;
@property (nonatomic, copy) NSString  * channelId;

- (void)animateCurrentWeatherBackground:(BOOL)animated;
- (void)setCurrentCityName;
- (void)animateNaviBtn;

- (void)showTopBar:(BOOL)show animated:(BOOL)animated;

- (void)back;
- (void)openCitiesManagerController;
- (void)shareAction;

- (void)preCity;
- (void)nextCity;
@end

@implementation SNWeatherMainController
@synthesize citiesArray = _citiesArray;
@synthesize citiesViewArray = _citiesViewArray;
@synthesize lastWeatherName = _lastWeatherName;
@synthesize lastScreenImagePath = _lastScreenImagePath;
@synthesize gbcode = _gbcode;
@synthesize city = _city;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.hidesBottomBarWhenPushed = YES;
        self.citiesViewArray = [NSMutableArray array];
        self.gbcode = [query objectForKey:kGbcode];
        self.city = [query objectForKey:kCity];
        self.channelId = [query stringValueForKey:kChannelId defaultValue:@""];
    }
	
    return self;
}

- (SNCCPVPage)currentPage {
    return weather_main;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
     //(_scrollView);
     //(_bgWeatherView);
     //(_animationMask);
     //(_citiesArray);
     //(_citiesViewArray);
     //(_lastWeatherName);
     //(_topBar);
     //(_toolBar);
    _actionMenuController.delegate = nil;
     //(_actionMenuController);
     //(_preBtn);
     //(_nextBtn);
     //(_lastScreenImagePath);
     //(_gbcode);
     //(_city);
     //(_channelId);
}

- (void)loadView {
    [super loadView];
    // custom bg color
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    _bgWeatherView = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    _bgWeatherView.backgroundColor = [UIColor clearColor];
    _bgWeatherView.defaultImage = [UIImage imageNamed:@"bg_default.jpg"];
    _bgWeatherView.contentMode = UIViewContentModeScaleAspectFill;
    _bgWeatherView.showFade = NO;
    [self.view addSubview:_bgWeatherView];
    
    _animationMask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    _animationMask.backgroundColor = [UIColor clearColor];
    _animationMask.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_animationMask];
    _animationMask.alpha = 0;
    
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        _bgWeatherView.alpha = kNightThemeBgAlpha;
        _animationMask.alpha = kNightThemeBgAlpha;
        self.view.backgroundColor = [UIColor blackColor];
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentOffset = CGPointMake(_scrollViewOffset, 0);
    [self.view addSubview:_scrollView];
    
    _topBar = [[SNWeatherTopBar alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kTopBarHeight)];
    _topBar.backgroundColor = [UIColor clearColor];
    [_topBar.titleButton addTarget:self action:@selector(openCitiesManagerController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_topBar];
    
    _toolBar = [[SNWeatherToolBar alloc] initWithFrame:CGRectMake(0, self.view.height - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    _toolBar.backgroundColor = [UIColor clearColor];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    NSString *back1 = @"icotext_back_v5.png";
    NSString *back2 = @"icotext_backpress_v5.png";
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    leftBtn.accessibilityLabel = @"返回";
    [leftBtn setImage:[UIImage themeImageNamed:back1] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage themeImageNamed:back2] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    _toolBar.leftButton = leftBtn;
        
    NSString *share1 = @"icotext_share_v5.png";
    NSString *share2 = @"icotext_sharepress_v5.png";
    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,43, 43)];
    [shareBtn setImage:[UIImage themeImageNamed:share1]forState:UIControlStateNormal];
    [shareBtn setImage:[UIImage themeImageNamed:share2] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    _toolBar.rightButton = shareBtn;
    shareBtn.accessibilityLabel = @"分享";
    
    [_toolBar setBackgroundImage:[UIImage themeImageNamed:@"weather_titlebar.png"]];
    
    [self.view addSubview:_toolBar];
    
    NSString *preFileName = @"weather_pre.png";
    _preBtn = [[UIButton alloc] initWithFrame:CGRectMake(kNaviBtnSideMargin, kNaviBtnTopMargin, kNaviBtnWidth, kNaviBtnHeight)];
    _preBtn.showsTouchWhenHighlighted = YES;
    _preBtn.backgroundColor = [UIColor clearColor];
    [_preBtn setImage:[UIImage imageNamed:preFileName] forState:UIControlStateNormal];
    [_preBtn addTarget:self action:@selector(preCity) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_preBtn];
    
    NSString *nextFileName = @"weather_next.png";
    _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(kAppScreenWidth - kNaviBtnWidth - kNaviBtnSideMargin,
                                                          kNaviBtnTopMargin, kNaviBtnWidth, kNaviBtnHeight)];
    _nextBtn.showsTouchWhenHighlighted = YES;
    _nextBtn.backgroundColor = [UIColor clearColor];
    [_nextBtn setImage:[UIImage imageNamed:nextFileName]forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextCity) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    
    [SNNotificationManager addObserver:self selector:@selector(handleWeatherCitiesDidChangeNotification:) name:kWeatherCitiesDidChangeNotify object:nil];
        
    [self resetAllWeathers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //add location manager
    CGPoint pt;
    SNLocationManager* location = [SNLocationManager GetInstance];
    [location startLocating:&pt];
}

- (void)viewDidUnload
{
    [SNNotificationManager removeObserver:self name:kWeatherCitiesDidChangeNotify object:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
     //(_scrollView);
     //(_bgWeatherView);
     //(_animationMask);
     //(_topBar);
     //(_lastWeatherName);
     //(_preBtn);
     //(_nextBtn);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self resetAllWeathers];
//    SNDebugLog(@"%@ offset=%d width=%d _currentViewIndex=%d", NSStringFromSelector(_cmd), offset, pageWidth, _currentViewIndex);
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_isBack) {
        _isBack = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - private methods

- (void)handleWeatherCitiesDidChangeNotification:(id)sender {
    [self resetAllWeathers];
}

- (void)resetAllWeathers {
        
    // clean old views
    for (UIView *subView in [_scrollView subviews]) {
        if ([subView isKindOfClass:[SNWeatherDetailView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    [_citiesViewArray removeAllObjects];
    
    self.citiesArray = [[SNWeatherCenter defaultCenter] subedCitiesArray];
    
    //替换天气cell传递的gbcode
    if (self.gbcode && ![self.gbcode isEqualToString:@""]) {
        NSMutableDictionary *cityInfoDic = [NSMutableDictionary dictionary];
        [cityInfoDic setObject:self.gbcode forKey:@"gbcode"];
        if (self.city) {
            [cityInfoDic setObject:self.city forKey:@"city"];
        }
        NSMutableArray *cityArray = [NSMutableArray array];
        [cityArray addObject:cityInfoDic];
        self.citiesArray = cityArray;
    }
    
    NSInteger pageNum = _citiesArray ? _citiesArray.count : 1;
    _scrollView.contentSize = CGSizeMake(pageNum * _scrollView.width, _scrollView.height);
    
    for (int i = 0; i < _citiesArray.count; ++i) {
        NSDictionary *cityInfo = [_citiesArray objectAtIndex:i];
        SNWeatherDetailView *detailView = [[SNWeatherDetailView alloc] initWithFrame:CGRectMake(i * _scrollView.width, kSystemBarHeight,
                                                                                                TTScreenBounds().size.width, TTScreenBounds().size.height)];
        detailView.delegate = self;
        detailView.cityGBcode = [cityInfo objectForKey:@"gbcode"];
        if (_currentViewIndex == i) {
            [detailView reloadWeather];
        }
        [_scrollView addSubview:detailView];
        [_citiesViewArray addObject:detailView];
    }
    
    if (_citiesViewArray.count <= 0) {
        _bgWeatherView.image = [UIImage imageNamed:@"bg_default.jpg"];
    }
    
    CGPoint pt = _scrollView.contentOffset;
    _scrollViewOffset = (int)pt.x;
    int pageWidth = (int)_scrollView.width;
    
    if (_scrollViewOffset < _scrollView.width) {
        _currentViewIndex = 0;
    }
    else {
        _currentViewIndex = _scrollViewOffset / pageWidth;
    }
    
    [self animateCurrentWeatherBackground:NO];
    [self setCurrentCityName];
    [self animateNaviBtn];
}

- (void)animateCurrentWeatherBackground:(BOOL)animated {
    if (_citiesViewArray.count > 0) {
        CGFloat alpha = 0;
        if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
            alpha = kNightThemeBgAlpha;
        }
        else {
            alpha = 1.0;
        }
        SNWeatherDetailView *view = [_citiesViewArray objectAtIndex:_currentViewIndex];
        WeatherReport *report = [view weather];
        
        if ([report.weatherLocalIconUrl isEqualToString:_lastWeatherName]) {
            return;
        }
        else {
            self.lastWeatherName = report.weatherLocalIconUrl;
        }
        
        _animationMask.image = _bgWeatherView.image;
        _animationMask.alpha = alpha;
        _bgWeatherView.alpha = 0;
        [_bgWeatherView loadUrlPath:report.weatherLocalIconUrl];
        
        if (animated) {
            [UIView beginAnimations:@"animateCurrentWeatherBackground" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            [UIView setAnimationDuration:0.5];
        }
        
        _bgWeatherView.alpha = alpha;
        _animationMask.alpha = 0;
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void)setCurrentCityName {
    if (_citiesArray.count > 0) {
        NSDictionary *cityInfo = [_citiesArray objectAtIndex:_currentViewIndex];
        _topBar.title = [cityInfo objectForKey:@"city"];
    }
    else {
        _topBar.title = @"点击添加城市";
    }
}

- (void)animateNaviBtn {
    if (_citiesViewArray.count > 0) {
        _preBtn.hidden = (_currentViewIndex == 0) ? YES : NO;
        _nextBtn.hidden = (_currentViewIndex == _citiesArray.count - 1) ? YES : NO;
    }
    else {
        _preBtn.hidden = YES;
        _nextBtn.hidden = YES;
    }
}

- (void)showTopBar:(BOOL)show animated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:@"barAnimation" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    if (show) {
        CGRect frame = _topBar.frame;
        frame.origin = CGPointMake(0, kSystemBarHeight);
        _topBar.frame = frame;
        
        frame = _toolBar.frame;
        frame.origin = CGPointMake(0, self.view.height - kTopBarHeight);
        _toolBar.frame = frame;
    }
    else {
        CGRect frame = _topBar.frame;
        frame.origin = CGPointMake(0, -_topBar.height);
        _topBar.frame = frame;
        
        frame = _toolBar.frame;
        frame.origin = CGPointMake(0, self.view.height + kBottomBarHeight);
        _toolBar.frame = frame;
    }
    
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)back {
    _isBack = YES;
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)openCitiesManagerController {
    
    TTURLAction *urlAction = [[TTURLAction actionWithURLPath:@"tt://weatherCities"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:urlAction];
//    if (_citiesArray.count > 1) {
//        TTURLAction *urlAction = [[TTURLAction actionWithURLPath:@"tt://weatherCities"] applyAnimated:YES];    
//        [[TTNavigator navigator] openURLAction:urlAction];
//    }
//    else {
//        TTURLAction *urlAction = [[TTURLAction actionWithURLPath:@"tt://weatherCityAdd"] applyAnimated:YES];    
//        [[TTNavigator navigator] openURLAction:urlAction];
//    }
}

//天气分享
- (void)shareAction {
//    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
//        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
//        return;
//    }
    
    if (_citiesViewArray.count > 0) {
        SNWeatherDetailView *view = [_citiesViewArray objectAtIndex:_currentViewIndex];
        NSString *shareContent = [view weatherShareString];
        if ([shareContent length] <= 0) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"天气信息错误" toUrl:nil mode:SNCenterToastModeError];
            return;
        }
        self.lastScreenImagePath = [UIImage screenshotImagePathFromView:self.view];
        
#if 1   //wangshun share test
        NSMutableDictionary* mDic = [self createActionMenuContentContext];
        [mDic setObject:@"weather" forKey:@"shareLogType"];
        [self callShare:mDic];
        return;
#endif
        
        if (self.actionMenuController == nil) {
            self.actionMenuController = [[SNActionMenuController alloc] init];
        }
        
        _actionMenuController.contextDic = [self createActionMenuContentContext];
        _actionMenuController.shareLogType = @"weather";
        _actionMenuController.delegate = self;
        _actionMenuController.disableLikeBtn = YES;
        [_actionMenuController showActionMenu];
    }
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

- (void)preCity {
    if (_currentViewIndex > 0 && _citiesViewArray.count > 0) {
        int index = _currentViewIndex - 1;
        [_scrollView setContentOffset:CGPointMake(_scrollView.width * index, 0) animated:YES];
        [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:_scrollView afterDelay:0.4];
    }
}

- (void)nextCity {
    if (_currentViewIndex < _citiesArray.count - 1 && _citiesViewArray.count > 0) {
        int index = _currentViewIndex + 1;
        [_scrollView setContentOffset:CGPointMake(_scrollView.width * index, 0) animated:YES];
        [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:_scrollView afterDelay:0.4];
    }
}

#pragma mark - weather detail view delegate

- (void)weatherDetailNeedRefresh:(NSString *)gbcode {
    [[SNWeatherCenter defaultCenter] refreshCityWeatherByCityCode:@"" gbcode:gbcode delegate:self channelId:self.channelId];
}

- (void)weatherDetailNeedForceRefresh:(NSString *)gbcode {
    [[SNWeatherCenter defaultCenter] forceRefreshWeatherByCityCode:@"" gbcode:gbcode delegate:self channelId:self.channelId];
}


- (void)viewTaped:(SNWeatherDetailView *)view {
    [self showTopBar:_isBarHide animated:YES];
    for (SNWeatherDetailView *otherView in _citiesViewArray) {
        [otherView showBottomBar:_isBarHide animated:otherView == view];
    }
    _isBarHide = !_isBarHide;
}

- (void)barSelectionChangedTo:(NSInteger)index {
    [self animateCurrentWeatherBackground:YES];
}

#pragma mark - weather center delegate

- (void)weatherDidFinishLoad:(NSString *)gbcode weatherReports:(NSArray *)weathers {
    for (UIView *subView in [_scrollView subviews]) {
        if ([subView isKindOfClass:[SNWeatherDetailView class]]) {
            if ([[(SNWeatherDetailView *)subView cityGBcode] isEqualToString:gbcode]) {
                ((SNWeatherDetailView *)subView).weathers = weathers;
                [self animateCurrentWeatherBackground:YES];
                break;
            }
        }
    }
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int lastIndex = _currentViewIndex;
    CGPoint pt = _scrollView.contentOffset;
    _scrollViewOffset = (int)pt.x;
    int pageWidth = (int)_scrollView.width;
    
    if (_scrollViewOffset < _scrollView.width) {
        _currentViewIndex = 0;
    }
    else {
        _currentViewIndex = _scrollViewOffset / pageWidth;
    }
    
    if (lastIndex != _currentViewIndex) {
        [self animateCurrentWeatherBackground:YES];
        [self setCurrentCityName];
        [self animateNaviBtn];
    }
    
    if (_citiesViewArray.count > 0) {
        SNWeatherDetailView *view = [_citiesViewArray objectAtIndex:_currentViewIndex];
        [view reloadWeather];
    }
//    SNDebugLog(@"%@ offset=%d width=%d _currentViewIndex=%d", NSStringFromSelector(_cmd), offset, pageWidth, _currentViewIndex);
}


- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    if (_scrollView.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}
#pragma mark - shareinfoController delegate

- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    if ([_lastScreenImagePath length] > 0) {
        [dicInfo setObject:_lastScreenImagePath forKey:kShareInfoKeyScreenImagePath];
    }
    SNWeatherDetailView *view = [_citiesViewArray objectAtIndex:_currentViewIndex];
    NSString *shareContent = [view weatherShareString];
    if ([shareContent length] > 0) {
//        if ([shareContent length] > 120) {
//            shareContent = [[shareContent substringToIndex:120] stringByAppendingString:@"..."];
//        }
        [dicInfo setObject:shareContent forKey:kShareInfoKeyContent];
    }
    
    int ugcLimit = [view weatherShareLimitWord];
    [dicInfo setObject:@(ugcLimit) forKey:kShareInfoKeyUgcLimitWord];
    
    //weixin
    NSString *shareLink = [view weatherShareLinkString];
    if ([shareLink length] > 0) {
        [dicInfo setObject:shareLink forKey:kShareInfoKeyWebUrl];
    }
    
    //log
    NSDictionary *cityInfo = [_citiesArray objectAtIndex:_currentViewIndex];
    NSString *gbcode = [cityInfo objectForKey:@"gbcode"];
    if ([gbcode length] > 0) {
        [dicInfo setObject:gbcode forKey:kShareInfoKeyNewsId];
    }
    if ([shareContent length] > 0) {
        [dicInfo setObject:shareContent forKey:kShareInfoKeyShareContent];
    }
    
    //mail title
    [dicInfo setObject:@"搜狐天气分享" forKey:kShareInfoKeyTitle];
    
    [dicInfo setObject:@"web" forKey:@"contentType"];
    
    return dicInfo;
}

#pragma mark - test motion

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if (motion == UIEventSubtypeMotionShake) {
        if (_citiesViewArray.count > 0) {
            SNWeatherDetailView *view = [_citiesViewArray objectAtIndex:_currentViewIndex];
            [view refreshWeatherForce];
        }
    }
}


@end
