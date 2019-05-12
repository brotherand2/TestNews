//
//  SNNewsPaperWebController.m
//  Three20Learning
//
//  Created by zhukx on 5/15/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNWebController.h"
#import "SNToolbar.h"
#import "SNNotificationCenter.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "SNNewsPaperWebController.h"
#import "SNUserManager.h"
#import "SNActionMenuController.h"
#import "SNShareConfigs.h"
#import "NSString+Utilities.h"
#import "SNSkinManager.h"
#import <StoreKit/StoreKit.h>


#define kIndicatorSize 20
#define kHTMLBodyDetectInterval 0.1

#define kStockChannelType    @"stockType"

@implementation SharedInfo
@synthesize sharedTitle;
@synthesize sharedUrl;

- (void)dealloc {
    
    [SNNotificationManager removeObserver:self];
    
	 //(sharedTitle);
	 //(sharedUrl);
    
}
@end


@interface SNWebController (private)

- (void)handleDoubleTap:(id)sender;
- (void)enterFullScreen;
- (void)exitFullScreen;
- (SharedInfo *)getSharedInfo;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface SNWebController () <SKStoreProductViewControllerDelegate>{
    BOOL _isActivePage;
    NSURLRequest *_request;
    BOOL _isRedirect;
    BOOL _supportLandscape;
    BOOL _isLandscape;
    BOOL _isSubSearchPage;
    BOOL _isSpecialPhone5c;//特殊机型，内存较少，容易crash
    UIView * _backgroundView;
    SKStoreProductViewController *_sKStoreProductViewController;
}

@end

@implementation SNWebController

@synthesize encodeUid = _encodeUid;
@synthesize toolbar = _toolbar;
@synthesize url = _url;
@synthesize progress = _progress;
@synthesize webView = _webView;
@synthesize loading = _loading;
@synthesize webUrl = _webUrl;
@synthesize urlTitle = _urlTitle;
@synthesize subId;
@synthesize termId;
@synthesize isHistory;

@synthesize addChannel = _addChannel;
@synthesize channelType = _channelType;
@synthesize iDelegate = _iDelegate;
@synthesize subscribeCode = _subscribeCode;
@synthesize stockfrom = _stockfrom;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (id)init {
	if (self = [self initWithNibName:nil bundle:nil]) {
		self.hidesBottomBarWhenPushed = YES;

        [SNNotificationManager addObserver:self selector:@selector(handleWebViewProgressDidChange:) name:kSNWebViewProgressDidChangedNotification object:nil];
	}
	
	return self;
}

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        SNDebugLog(@"SNWebController query description : %@", [query description]);
        NSString * platformString = [SNUtility platformStringForSohuNews];
        if ([platformString isEqualToString:IPHONE_5C_NAMESTRING]) {
            _isSpecialPhone5c = YES;
        }
        self.query = query;
        NSString *address = [query objectForKey:@"address"];
        _supportLandscape = query[@"landscape"] ? YES : NO;//是否支持横屏展示
//        _isAD = ([query[kRefer] integerValue] == REFER_AD )? YES : NO; //广告标识
        _isSubSearchPage = [[query objectForKey:@"subSearch" defalutObj:nil] isEqualToString:@"1"];
        self.channelType = [query objectForKey:@"channelType" defalutObj:nil];
        if ([self.channelType isEqualToString:kStockChannelType]) {
            self.addChannel = [[query objectForKey:@"addChannel"] intValue];
            self.iDelegate = [query objectForKey:@"delegate"];
            self.subscribeCode = [query objectForKey:@"subscribeCode" defalutObj:nil];
            self.stockfrom = [query objectForKey:@"stockfrom" defalutObj:@"news"];
        }
        
        if (address.length > 0) {
            NSURL *url = [NSURL URLWithString:address];
            self.webUrl = address;
            //如果创建不成功，需要转义下。
            if (!url) {
                address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                url = [NSURL URLWithString:address];
            }
            [self updateWebView];
            [self openURL:url];
        }
        
        if ([[query objectForKey:kNewsExpressType] intValue] == 1){
            _isPushed = YES;
        }
        
        [SNNotificationManager addObserver:self selector:@selector(handleThemeChangeNotify:) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleWebViewProgressDidChange:) name:kSNWebViewProgressDidChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];        
    }
    return self;
}

- (void)handleThemeChangeNotify:(NSNotification *)notification {
    [self updateBackgroundColor];
    UIImageView* imgView = (UIImageView*)[_toolbar viewWithTag:200];
    if(imgView)
    {
        UIImage  *img = [UIImage themeImageNamed:@"postTab0.png"];
        imgView.image = img;
    }
    [self updateWebView];
}

- (void)updateWebView {
    NSString *webString = self.webUrl;
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        if (NSNotFound == [webString rangeOfString:@"mode=" options:NSCaseInsensitiveSearch].location) {
            webString = [SNUtility addParamModeToURL:webString];
        }
        else {
            webString = [webString stringByReplacingOccurrencesOfString:@"mode=0" withString:@"mode=1"];
        }
    }
    else {
        webString = [webString stringByReplacingOccurrencesOfString:@"mode=1" withString:@"mode=0"];
    }
    
    self.webUrl = webString;
    self.url = [NSURL URLWithString:self.webUrl];
//    [self openURL:self.url];
    
    [_back setImage:[UIImage imageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [_back setImage:[UIImage imageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [_share setImage:[UIImage imageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
    [_share setImage:[UIImage imageNamed:@"icotext_share_v5.png"] forState:UIControlStateHighlighted];
}

- (SNToolbar *)toolbar {
	if (!_toolbar) {
		_toolbar = [[SNToolbar alloc] initWithFrame:CGRectMake(0, 
															   kAppScreenHeight - kToolbarHeight,
															   kAppScreenWidth,
															   kToolbarHeight)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[_backgroundView addSubview:_toolbar];
    }
    return _toolbar;
}

-(void)dealloc {
    
    [SNNotificationManager removeObserver:self];
    
	 //(_url);
	 //(_encodeUid);
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];

//    [_request release];
//    _request = nil;
    
    //clean webView memory
    if (_webView) {
        _webView.delegate = nil;
        [_webView stopObserveProgress];
         //(_webView);
    }
    
     //(_dragView);
	 //(_toolbar);
	 //(_actionSheet);
	 //(_back);
	 //(_front);
	 //(_refresh);
	 //(_stopBtn);
     //(_share);
     //(_placeholderBtn);
     //(_more);
     //(_dismissBtn);
	 //(_loading);
	 //(_progress);
     //(subId);
     //(termId);
     //(isHistory);
     //(_shareMenuController);
     //(_webUrlView);
    
     //(_query);
     //(_channelType);
     //(_subscribeCode);
     //(_sKStoreProductViewController);
}

- (void)resetWebKitCacheModelPreferenKey{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kWebKitCacheModelPreferenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//为了解决“home” icon仍然无法明确退出键的功能的问题，当浏览历史为空的时候【上一步】按钮等同于【退出】按钮。
- (void)backAction {
    if (_isSpecialPhone5c) {
        [self resetWebKitCacheModelPreferenKey];
    }
    if (_isPushed) {
        [SNUtility popViewToPreViewController];
    }
    else{
        if (![_webView canGoBack]) {
            [_webView stopLoading];
            _webView.delegate = nil;
            [self closeBrowser];
        } else if ([self canLeavePage]) {
            [_webView goBack];
        }
    }
}


- (void)forwardAction {
    if ([self canLeavePage]) {
        [_webView goForward];
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_isFullScreen = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    if (_supportLandscape) {
//        [SNNotificationManager addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [self rotateForLandscape];
    }
}

- (void)rotateForLandscape {
    
    [UIView animateWithDuration:0.5f animations:^{
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, M_PI/2);
        _backgroundView.transform = transform;
        [self resetUIForLandscape];
        
    } completion:^(BOOL finished) {
    }];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
    }

}

- (void)orientChange:(NSNotification *)noti{
    if (!_supportLandscape) {
        return;
    }

    NSObject * obj = [noti object];
    if ([obj isKindOfClass:[UIDevice class]]) {
        UIDeviceOrientation o = [(UIDevice *)obj orientation];
        switch (o) {
            case UIDeviceOrientationPortrait: {

                [UIApplication sharedApplication].statusBarHidden = NO;
                _isLandscape = NO;
                [UIView animateWithDuration:0.5f animations:^{
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformRotate(transform, 0);
                    _backgroundView.transform = transform;
                    [self resetUiForPortrait];

                } completion:^(BOOL finished) {
                }];

                break;
            }
            case UIDeviceOrientationPortraitUpsideDown: {
                break;
            }
            case UIDeviceOrientationLandscapeLeft: {
                
                [UIApplication sharedApplication].statusBarHidden = YES;
                
                [UIView animateWithDuration:0.5f animations:^{
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformRotate(transform, M_PI/2);
                    _backgroundView.transform = transform;
                    [self resetUIForLandscape];
                    
                } completion:^(BOOL finished) {
                }];
                
                break;
            }
            case UIDeviceOrientationLandscapeRight: {
                [UIApplication sharedApplication].statusBarHidden = YES;

                [UIView animateWithDuration:0.5f animations:^{
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformRotate(transform, -M_PI/2);
                    _backgroundView.transform = transform;
                    [self resetUIForLandscape];

                } completion:^(BOOL finished) {
                }];

                break;
            }
            default:
                break;
        }
    }
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
    }
}

- (void)resetUiForPortrait {
    _backgroundView.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
//    self.webView.frame = CGRectMake(0, self.webView.frame.origin.y, self.view.frame.size.width, kAppScreenHeight - kToolbarViewTop);
    self.webView.frame = CGRectMake(0, kSystemBarHeight, self.view.frame.size.width, kAppScreenHeight-kToolbarViewTop);
    self.toolbar.frame = CGRectMake(0,
                                    kAppScreenHeight - kToolbarHeight,
                                    kAppScreenWidth,
                                    kToolbarHeight);
    self.webUrlView.frame = CGRectMake(0, 0, self.view.frame.size.width, kWebUrlViewHeight);
    _progress.frame = CGRectMake(0, self.webUrlView.bottom-2+kSystemBarHeight, self.view.width, 2);
    _loading.frame = CGRectMake(0, 0, TTScreenBounds().size.width, TTScreenBounds().size.height);

    [_loading layoutTriplets];
    [self.webUrlView updateUIForRotate:NO];
    [self.toolbar updateUIForRotate];

}

- (BOOL)prefersStatusBarHidden {
    
    return _isLandscape;
}

- (void)resetUIForLandscape {
    _isLandscape = YES;
    float width = self.view.frame.size.height + kWebUrlViewHeight + 20;
    _backgroundView.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
//    self.webView.frame = CGRectMake(0, self.webView.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width - kWebUrlViewHeight - kToolbarViewTop);
    self.webView.frame = CGRectMake(0, 0, width, self.view.frame.size.width - kWebUrlViewHeight - kToolbarViewTop + kSystemBarHeight);
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.width - kToolbarViewTop - kWebUrlViewHeight, width, kToolbarViewHeight);
    self.webUrlView.frame = CGRectMake(0, 0,width, kWebUrlViewHeight);
    _progress.frame = CGRectMake(0, self.webUrlView.bottom-2, width, 2);
    _loading.frame = CGRectMake(0, 0, TTScreenBounds().size.height, TTScreenBounds().size.width);

    [_loading layoutTriplets];
    [self.webUrlView updateUIForRotate:YES];
    [self.toolbar updateUIForRotate];
}

- (void)viewDidDisappear:(BOOL)animated {
//    if (![[self.url absoluteString] containsString:@"sohu.com"]) {
//        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_request];
//    
//        [[NSURLCache sharedURLCache] removeAllCachedResponses];
//    
//        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
//        
//            //if([[cookie domain] isEqualToString:someNSStringUrlDomain]) {
//            //            SNDebugLog(@"%@",[cookie domain]);
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//            // }
//        }
//    }
//    _request = nil;
    [super viewDidDisappear:animated];
//    if (_isAD) {
//        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_request];
//        
//        [[NSURLCache sharedURLCache] removeAllCachedResponses];
//        
//        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
//            
//            //if([[cookie domain] isEqualToString:someNSStringUrlDomain]) {
////            SNDebugLog(@"%@",[cookie domain]);
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//            // }
//        }
////    }
}

//Only works for iOS7 and greater.
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

//Only works for iOS7 and greater.
- (UIStatusBarStyle)preferredStatusBarStyle {
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"]) {
        return UIStatusBarStyleLightContent;
    }
    else {
        return UIStatusBarStyleDefault;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    [_dragView removeObserver];
}

- (void)hideGradientBackground:(UIView*)theView {
	for (UIView* subview in theView.subviews) {
		if ([subview isKindOfClass:[UIImageView class]])
			subview.hidden = YES;
		
		[self hideGradientBackground:subview];
	}

}

- (void)handleWebViewProgressDidChange:(NSNotification *)notification {
    if (notification.object == _webView) {
        CGFloat progress = [[notification userInfo] floatValueForKey:kSNWebViewCurrentProgressValueKey
                                                        defaultValue:0];
        
        [self handleProgress:progress];
    }
}

- (void)handleProgress:(CGFloat)progress
{
    _progress.curProgress = progress;
}

- (void)addWebView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight-kSystemBarHeight-kToolbarViewTop)];
    _webView.delegate = self;
    _webScrollView = _webView.scrollView;
    float bottomInset = kWebToolbarViewHeight;
    
    if (bottomInset > 0) {
        bottomInset -= 15;
    }
    
    _webScrollView.contentInset = UIEdgeInsetsMake(kWebUrlViewHeight, 0.f, bottomInset, 0.f);
    _webScrollView.delegate = self;
    _webScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    _webView.opaque = NO;//make system draw the logo below transparent webview
    //_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = [UIColor whiteColor];
    
    [self hideGradientBackground:_webView];
    
    [_webView startObserveProgress];
    
    _dragView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0, -_webView.height, _webView.width, _webView.height)];
    _dragView.hidden = YES;
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    _dragView.refreshStartPosY = 65 + 61;
    [_webScrollView addSubview:_dragView];
    
    [_backgroundView addSubview:_webView];
}

- (void)addWebUrlView
{
    SNWebUrlView* webUrlView = [[SNWebUrlView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kWebUrlViewHeight + kSystemBarHeight)];
    webUrlView.delegate = self;
    //[webUrlView disableSohuIcon];
    [_backgroundView addSubview:webUrlView];
    self.webUrlView = webUrlView;
    self.webUrlView.backgroundColor = [UIColor clearColor];
    if ([self.channelType isEqualToString:kStockChannelType]) {
        self.webUrlView.buttonState = self.addChannel;        
        [self.webUrlView refreshButtonState];
    }
    else{
        self.webUrlView.buttonState = SNSubscribeButtonHide;
    }
    if(self.urlTitle)
    {
//        [self.webUrlView updateLogoUrl:nil withLink:self.urlTitle];
        [self.webUrlView updateTile:self.urlTitle];
    }

    //lijian 2014.12.17 活动页要特殊处理隐藏地址栏
    if(nil != self.query){
        NSString *activeName = [self.query objectForKey:kActionType];
        if(nil != activeName && [activeName isEqualToString:kActionName_ActivePage]){
            //_webView.frame = CGRectMake(0, kSystemBarHeight, _webView.frame.size.width, _webView.frame.size.height + kWebUrlViewHeight);
            //_webView.scrollView.scrollEnabled = NO;
            self.webUrlView.hidden = YES;
            _isActivePage = YES;
            //self.webUrlView.frame = CGRectMake(0, -20, self.webUrlView.frame.size.width, self.webUrlView.frame.size.height);
        }
    }
}

- (void)loadView {
	[super loadView];
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    [self.view addSubview:_backgroundView];
    
	//init web view
	_isFullScreen = NO;
 
    [self addWebView];
    [self addWebUrlView];
    
    [self updateBackgroundColor];
    
    [_webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
	
	//add logo
	 //(_loading);
	_loading = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, 0, TTScreenBounds().size.width, TTScreenBounds().size.height)];
    _loading.delegate = self;
    _loading.status = SNTripletsLoadingStatusStopped;
	[_backgroundView addSubview:_loading];
    //add toolbar
    if (!_dismissBtn) {
        _dismissBtn = [[UIButton alloc] init];
    }
    NSString *img1 = @"icotab_close_v5.png";
    NSString *img2 = @"icotab_closepress_v5.png";
	[_dismissBtn setImage:[UIImage imageNamed:img1] forState:UIControlStateNormal];
	[_dismissBtn setImage:[UIImage imageNamed:img2] forState:UIControlStateHighlighted];
	[_dismissBtn setBackgroundColor:[UIColor clearColor]];
	[_dismissBtn addTarget:self action:@selector(closeBrowser) forControlEvents:UIControlEventTouchUpInside];
    
    if (!_back) {
        _back = [[UIButton alloc] init];
    }
    img1 = @"icotext_back_v5.png";
    img2 = @"icotext_backpress_v5.png";
	[_back setImage:[UIImage imageNamed:img1] forState:UIControlStateNormal];
	[_back setImage:[UIImage imageNamed:img2] forState:UIControlStateHighlighted];
	[_back setBackgroundColor:[UIColor clearColor]];
	[_back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
	
//	_front = [[UIButton alloc] init];
//    NSString *img3 = @"icotab_next_v5.png";
//    NSString *img4 = @"icotab_nextpess_v5.png";
//	[_front setImage:[UIImage imageNamed:img3] forState:UIControlStateNormal];
//	[_front setImage:[UIImage imageNamed:img4] forState:UIControlStateHighlighted];
//	[_front addTarget:self action:@selector(forwardAction) forControlEvents:UIControlEventTouchUpInside];
//	[_front setBackgroundColor:[UIColor clearColor]];

    if (!_refresh) {
        _refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    NSString *img7 = @"icotab_refresh_v5.png";
    NSString *img8 = @"icotab_refreshpress_v5.png";
	[_refresh setImage:[UIImage imageNamed:img7] forState:UIControlStateNormal];
	[_refresh setImage:[UIImage imageNamed:img8] forState:UIControlStateHighlighted];
	[_refresh addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
	[_refresh setBackgroundColor:[UIColor clearColor]];


//    _more = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//    NSString *img9 = @"icotext_more_v5.png";
//    NSString *img10 = @"icotext_morepress_v5.png";
//	[_more setImage:[UIImage imageNamed:img9] forState:UIControlStateNormal];
//	[_more setImage:[UIImage imageNamed:img10] forState:UIControlStateHighlighted];
//	[_more addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
//	[_more setBackgroundColor:[UIColor clearColor]];
    
    if (!_share) {
        _share = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    NSString *img11 = @"icotext_share_v5.png";
    NSString *img12 = @"icotext_sharepress_v5.png";
    [_share setImage:[UIImage imageNamed:img11] forState:UIControlStateNormal];
    [_share setImage:[UIImage imageNamed:img12] forState:UIControlStateHighlighted];
    [_share addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [_share setBackgroundColor:[UIColor clearColor]];
    
//    _placeholderBtn = [UIButton buttonWithType:UIButtonTypeCustom];//占位button
//    _placeholderBtn.userInteractionEnabled = NO;
//    [_placeholderBtn setBackgroundColor:[UIColor clearColor]];
    NSArray * buttons = [[NSArray alloc] initWithObjects: _back,_dismissBtn,_refresh,_share, nil];
	[self.toolbar setButtons:buttons];
//    [self.toolbar setButtons:[NSArray arrayWithObjects:_back,_dismissBtn,_refresh,_share, nil]];
    [self hideDismissBtn:YES];
//    [self.toolbar setButtons:[NSArray arrayWithObjects:_back,_share, nil] withType:SNToolbarAlignRight];

    if (_isSubSearchPage) {
        _dismissBtn.hidden = YES;
        _refresh.hidden = YES;
        _share.hidden = YES;
    }
    
    _back.enabled = YES;
	_front.enabled = NO;
	_share.enabled = YES;
    
    //add progress bar
    _progress = [[SNProgressBar alloc] initWithFrame:CGRectMake(0, self.webUrlView.bottom-2, self.view.width, 2)];
    //_progress.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _progress.layer.cornerRadius = 1;
    _progress.backgroundColor = [UIColor clearColor];
    [_backgroundView addSubview:_progress];
    
}

- (void)hideDismissBtn:(BOOL)hide {
    if (hide) {
        _dismissBtn.hidden = YES;
        _dismissBtn.userInteractionEnabled = NO;
    }else {
        _dismissBtn.hidden = NO;
        _dismissBtn.userInteractionEnabled = YES;
    }
}

- (BOOL)canLeavePage {
    NSString *canLeavePage = [_webView stringByEvaluatingJavaScriptFromString:@"sohunews_canLeavePage();"];
    //未定义此函数返回值为空字符串，当做true处理
    return ![@"false" isEqualToString:canLeavePage];
}

- (BOOL)canCloseBrowser {
    NSString *canCloseBrowser = [_webView stringByEvaluatingJavaScriptFromString:@"sohunews_canCloseBrowser();"];
    //未定义此函数返回值为空字符串，当做true处理
    return ![@"false" isEqualToString:canCloseBrowser];
}

- (BOOL)canRefreshBrowser {
    NSString *canCloseBrowser = [_webView stringByEvaluatingJavaScriptFromString:@"sohunews_canRefreshBrowser();"];
    //未定义此函数返回值为空字符串，当做true处理
    return ![@"false" isEqualToString:canCloseBrowser];
}

- (void)closeBrowser {
    
    if ([self canCloseBrowser]) {
        //返回bug wangyy
        [self.flipboardNavigationController popViewControllerAnimated:YES];
//        if (_isPushed && self.flipboardNavigationController) {
//            [self.flipboardNavigationController popViewControllerAnimated:YES];
//        }
//        else {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
    }

}

- (void)shareAction{
    NSString *title = @"";
    NSString *content = @"";
    NSString *link = @"";
    if (self.urlTitle.length > 0) {
        NSString * decodeStr = [self.urlTitle URLDecodedString];
        if (decodeStr) {
            title = decodeStr;
        }else{
            title = self.urlTitle;
        }
    }
    if (self.webUrl.length > 0) {
        link = self.webUrl;
    }
    if (link.length == 0) {
        link = [self.url absoluteString];
    }
    content = [NSString stringWithFormat:@"%@ %@ ",title,link];
    [self shareWithTitle:title content:content link:link imageUrl:nil];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSURL *webUrl = _webView.request.URL;
    if (!webUrl) {
        webUrl = self.url;
    }
    
    switch (buttonIndex) {
        case 0:
            if ([SNUtility isWhiteListURL:webUrl]) {
                [[UIApplication sharedApplication] openURL:webUrl];
            }            
            break;
        case 1:
            [[UIPasteboard generalPasteboard] setString:[webUrl absoluteString]];
            break;
        case 2: {
            NSString *title = @"";
            NSString *content = @"";
            NSString *link = @"";
            if (self.urlTitle.length > 0) {
                title = [self.urlTitle URLDecodedString];
            }
            if (self.webUrl.length > 0) {
               link = self.webUrl;
            }
            content = [NSString stringWithFormat:@"%@（%@）",title,link];
            [self shareWithTitle:title content:content link:link imageUrl:nil];
            break;
        }
        default:
            break;
    }
}

//- (void)moreAction
//{
////    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles: @"用Safari打开", @"复制链接",@"分享", nil];
////    [sheet showInView:self.tabBarController.tabBar];
////    [sheet release];
////    NSURL *webUrl = _webView.request.URL;
////    if (!webUrl) {
////        webUrl = self.url;
////    }
////    SNSheetFloatView* sheet = [[SNSheetFloatView alloc] init];
////    [sheet addSheetItemWithTitle:@"用Safari打开" andBlock:^{
////        if ([SNUtility isWhiteListURL:webUrl]) {
////            [[UIApplication sharedApplication] openURL:webUrl];
////        }
////    } layOut:NO];
////    [sheet addSheetItemWithTitle:@"复制链接" andBlock:^{
////        [[UIPasteboard generalPasteboard] setString:[webUrl absoluteString]];
////    } layOut:NO];
////    [sheet addSheetItemWithTitle:@"分享" andBlock:^{
////        NSString *title = @"";
////        NSString *content = @"";
////        NSString *link = @"";
////        if (self.urlTitle.length > 0) {
////            title = [self.urlTitle URLDecodedString];
////        }
////        if (self.webUrl.length > 0) {
////            link = self.webUrl;
////        }
////        content = [NSString stringWithFormat:@"%@（%@）",title,link];
////        [self shareWithTitle:title content:content link:link imageUrl:nil];
////    } layOut:YES];
////    [sheet show];
//}

- (UIImage *)image {
    NSString *name1 = @"backNomal.png";
	return [[UIImage imageNamed:name1] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
}

- (void)showInitProgress
{
    [_progress startProgress];
}

- (void)hideInitProgress
{
    [_progress resetProgress];
}

//由于webview在加载新内容时仍显示旧内容，这个方法用来清空旧新闻页面用的空白html，里面只有一个logo
- (void)resetEmptyHTML {
	[_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';document.body.style.background='transparent'"] ;
    
    //_webView.opaque = NO;//make system draw the logo below transparent webview
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_webView.dataDetectorTypes = UIDataDetectorTypeNone;
	_webView.scalesPageToFit = NO;
    _webView.backgroundColor = [UIColor clearColor];
}

- (void)dragViewStartLoad {
    if (_dragView.hidden) {
        return;
    }
    
    // show drag view loading
    [_dragView setStatus:TTTableHeaderDragRefreshLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
    
    if (_webScrollView.contentOffset.y < 0) {
        _webScrollView.contentInset = UIEdgeInsetsMake(kWebViewHeaderVisibleHeight, 0.0f, kToolbarViewHeight, 0.0f);
    }
    [UIView commitAnimations];
    
    _webScrollView.contentInset = UIEdgeInsetsMake(kWebViewHeaderVisibleHeight, 0.0f,kToolbarViewHeight, 0.0f);
    
    // Grab the last refresh date if there is one.
    [_dragView setUpdateDate:[NSDate date]];
}

- (void)dragViewFinishLoad {
    if (_dragView.hidden) {
        return;
    }
    
    // drag view
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    _webScrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
    if (_webScrollView.contentOffset.y < 0) {

        _webScrollView.contentOffset = CGPointZero;
    }
    [UIView commitAnimations];
    
    [_dragView setCurrentDate];
}

- (void)dragViewFailLoad {
    if (_dragView.hidden) {
        return;
    }
    
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    _webScrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
    if (_webScrollView.contentOffset.y < 0) {
        _webScrollView.contentOffset = CGPointZero;
    }
    [UIView commitAnimations];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
												navigationType:(UIWebViewNavigationType)navigationType {
    NSString *reqUrlStr = [request.URL absoluteString];
//    self.webUrl = reqUrlStr;
    if (![reqUrlStr isEqualToString:@"about:blank"]) {
        _webUrl = [reqUrlStr copy];
    }
    
    if ([SNUtility changeSohuLinkToProtocol:reqUrlStr]) {
        [SNUtility openProtocolUrl:[SNUtility changeSohuLinkToProtocol:reqUrlStr] context:nil];
        return NO;
    }

    if (_isRedirect) {
        _isRedirect = NO;
        return YES;
    }
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [self resetEmptyHTML];
        [self showErrorView:nil];
//        return NO;
    }
    
	BOOL shouldStart = YES;
	
    //SNDebugLog(@"%@", [request.URL scheme]);
    
    SNDebugLog(@"SNWebController shouldStartLoadWithRequest %@", reqUrlStr);
    
    //support https://itunes.apple.com to open iTunes or Appstore
    if ([SNAPI isItunes:reqUrlStr]) { // || [[request.URL scheme] isEqualToString:@"itms-appss"]
        
        [_progress resetProgress];
//        [self showAppStoreInApp:request.URL];
        [[UIApplication sharedApplication] openURL:request.URL];
        [self hideError];
        [self backAction];
        return NO;
    }
    else if ([reqUrlStr containsString:@"sohuExternalLink=1"]) {//某刊物的团购第三方支付，需端外打开
        [_progress resetProgress];
        [[UIApplication sharedApplication] openURL:request.URL];
        [self hideError];
        [self backAction];
        return NO;
    }
    
    //搜狐域以外的其他域名不做url修改和拼接
    BOOL isSohuNewsDomain;
    NSArray *urlArray = [reqUrlStr componentsSeparatedByString:@"?"];
    if ([urlArray count]) {
        isSohuNewsDomain = [SNUtility isSohuDomain:[urlArray objectAtIndex:0]];
    } else {
        isSohuNewsDomain = [SNUtility isSohuDomain:reqUrlStr];
    }
    
	if ([reqUrlStr hasPrefix:kProtocolHTTP] && isSohuNewsDomain)
    {
		//Google AD filter
		if ([reqUrlStr containsString:@"googleads"] ||
			[reqUrlStr containsString:@"doubleclick"]) {
			return NO;
		}

        NSString *cookieValue = [SNUserManager getCookie];
        if ((![cookieValue containsString:@"ppinf"] || ![cookieValue containsString:@"pprdig"]) && ![reqUrlStr containsString:kH5LoginUrlString] && [self isSNSUrl:reqUrlStr]) {
            reqUrlStr = [NSString stringWithFormat:kH5LoginUrl , [reqUrlStr URLEncodedString]];
        }
		
		BOOL isChangedUrl = NO;
		if (![reqUrlStr containsString:@"u="]) {
			if (![reqUrlStr containsString:@"?"]) {
				reqUrlStr = [reqUrlStr stringByAppendingFormat:@"?u=%@", [SNAPI productId]];
			}
			else {
				reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&u=%@", [SNAPI productId]];
			}
			isChangedUrl = YES;
            SNDebugLog(@"add chanpin ID----%@", reqUrlStr);
		}
		
		if (![reqUrlStr containsString:@"p1="]) {
			if (!_encodeUid) {
				NSString *savedUid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
				self.encodeUid = [[savedUid dataUsingEncoding:NSUTF8StringEncoding] base64String];
			}
			NSString *p1Str = [_encodeUid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if (![reqUrlStr containsString:@"?"]) {
				reqUrlStr = [reqUrlStr stringByAppendingFormat:@"?p1=%@", p1Str];
			}
			else {
				reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&p1=%@", p1Str];
			}
            reqUrlStr = [self addParametersForSNSUrl:reqUrlStr];
			isChangedUrl = YES;
            SNDebugLog(@"add p1----%@", reqUrlStr);
		}
        if (![reqUrlStr containsString:@"gid="]) {
            reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&gid=%@", [SNUserManager getGid]];
        }
        if (![reqUrlStr containsString:@"pid="]) {
            reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&pid=%@", [SNUserManager getPid]];
        }
        if (![reqUrlStr containsString:@"p2="]) {
            reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&p2=%@", [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
        }
        if (![reqUrlStr containsString:@"sdk="]) {
            reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&sdk=%@", [[UIDevice currentDevice] systemVersion]];
        }
        if (![reqUrlStr containsString:@"ver="]) {
            reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&ver=%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        }
        if (![reqUrlStr containsString:@"token="]) {
            reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&token=%@", [SNUserManager getToken]];
        }
		
		if (isChangedUrl) {
			SNDebugLog(@"add parameter complete, request final url again----%@", reqUrlStr);
			NSMutableURLRequest *newRequest = [request mutableCopy];
            newRequest.timeoutInterval = WEBVIEW_REQUEST_TIMEOUT;
            [newRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];//减少内存占用
			newRequest.URL = [NSURL URLWithString:reqUrlStr];
            [self appendCookieToRequeset:newRequest url:newRequest.URL];
			[_webView loadRequest:newRequest];
			shouldStart = NO;
            _isRedirect = YES;
		} else {
            SNDebugLog(@"can request url----%@", reqUrlStr);
        }
	}
    else if ([reqUrlStr hasPrefix:kBrowserShareContent]) {
        // h5页面内调用客户端分享
        NSDictionary *dic = [SNUtility parseURLParam:reqUrlStr schema:kBrowserShareContent];
        NSString *content = [dic stringValueForKey:@"content" defaultValue:@""];
        content = [content URLDecodedString];
        NSString *link = [dic stringValueForKey:@"link" defaultValue:nil];
        link = [link URLDecodedString];
        NSString *title = [dic stringValueForKey:@"title" defaultValue:nil];
        title = [title URLDecodedString];
        [self shareH5Content:content link:link title:title];
        return NO;
    }
    else if([reqUrlStr hasPrefix:kShareProtocal])
    {
        NSDictionary* dic = [SNUtility parseURLParam:reqUrlStr schema:kShareProtocal];
        NSString* link = [dic objectForKey:@"link"];
        if(link)
            link = [link URLDecodedString];
        NSString* pics = [dic objectForKey:@"pics"];
        if(pics)
            pics = [pics URLDecodedString];
        NSString* title = [dic objectForKey:@"title"];
        if(title)
            title = [title URLDecodedString];
        NSString* content = [dic objectForKey:@"content"];
        if(content)
            content = [content URLDecodedString];
        [self shareWithTitle:title content:content link:link imageUrl:pics];
        return NO;
    }
    else if (![reqUrlStr hasPrefix:kProtocolHTTP] && ![reqUrlStr hasPrefix:kProtocolFILE] && ![reqUrlStr hasPrefix:kProtocolHTTPS]) {
        if ([SNUtility isWhiteListURL:request.URL]) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
        else if ([SNUtility isProtocolV2:reqUrlStr] && ![reqUrlStr containsString:@"subscirbe://"]) {
            [SNUtility openProtocolUrl:reqUrlStr];
            return NO;
        }
    }
    
    if (shouldStart) {
        [_progress resetProgress];
        
        if (![reqUrlStr isEqualToString:@"about:blank"]) {
            self.url = request.URL;
        }
    }
    
	return shouldStart;
}

- (void)stopAction:(id)sender {
	[_webView stopLoading];
    [_progress resetProgress];
	//[self.toolbar replaceButtonAtIndex:2 withItem:_refresh];
}

#pragma mark -
#pragma mark webView delegate
- (void)webViewDidFinishLoad:(UIWebView*)webView {
    
    _isLoading = NO;
//	_back.enabled = [_webView canGoBack];
    _front.enabled = [_webView canGoForward];
	_share.enabled = YES;
    [self hideLoading];
    [self dragViewFinishLoad];
    
    if (_front.enabled) {
        [self hideDismissBtn:NO];
    }else {
        [self hideDismissBtn:YES];
    }
    
    NSString * title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0) {
        _urlTitle = title;
    }
//    
//    if (!self.urlTitle) {
//        self.urlTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    }

    if (self.urlTitle.length == 0) {
        self.urlTitle = @"搜狐新闻客户端";
    }

    // 链接地址也显示搜狐新闻客户端
    NSRange range = [self.urlTitle rangeOfString:@"://"];
    
    if (range.length > 0)
    {
        range.length = range.location;
        range.location = 0;

        NSString *head = [self.urlTitle substringWithRange:range];

        head = [head lowercaseString];
        
        int i = 0;
        
        for (; i < head.length; i++) {
            int c = [head characterAtIndex:0];
            
            // 不是链接
            if (c < 'a' || c > 'z') {
                break;
            }
        }
        
        if (i == head.length) {
            self.urlTitle = @"搜狐新闻客户端";
        }
    }
    
    if(self.urlTitle)
    {
        [self.webUrlView updateLogoUrl:nil withLink:self.urlTitle];
    }
    
    if (_isSpecialPhone5c) {
        [self resetWebKitCacheModelPreferenKey];
    }
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
	
	_isLoading = YES;
	//[self.toolbar replaceButtonAtIndex:2 withItem:_stopBtn];
    if (!_firstLoaded) {
        //_loading.status = SNEmbededActivityIndicatorStatusStartLoading;
    }
    _firstLoaded = YES;
    
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{    
    [self dragViewFailLoad];
    if ([_webView canGoForward]) {
        [self hideDismissBtn:NO];
    }else {
        [self hideDismissBtn:YES];
    }
	SNDebugLog(@"snwebcontroller didFailLoadWithError-%@", [error description]);
	if (kCFURLErrorBadURL == error.code || 
		kCFURLErrorUnsupportedURL == error.code ||
		kCFURLErrorCannotFindHost == error.code ||
		kCFURLErrorTimedOut == error.code ||
		kCFURLErrorCannotConnectToHost == error.code ||
		kCFURLErrorNotConnectedToInternet == error.code) {
		_isLoading = NO;
		[self showErrorView:NSLocalizedString(@"LoadFailRefresh", @"加载失败，点击屏幕刷新")];
        [_progress resetProgress];
	}
    
    else {
        //Once you see an "itms" scheme, stop the webView from loading and open the URL with Safari to download app.
        NSURL *url = [NSURL URLWithString:[error.userInfo objectForKey:@"NSErrorFailingURLStringKey"]];
        
        if ([error.domain isEqual:@"WebKitErrorDomain"]) {
            //support itms:// or itms-apps:// or itms-appss:// or itmss:// to open iTunes or Appstore
            
            if ([SNUtility isWhiteListURL:url]) {
                if ([[url scheme] hasPrefix:@"itms"]) {
                    
                    // v5.2.0 这个string传什么都没用了... bug #40370
                    //[self showErrorView:@"返回上一级安装更多App吧"];
                    
                    [_progress resetProgress];
                    [[UIApplication sharedApplication] openURL:url];
                }
                
                return;
            }
            
        }
    }
    if (_isSpecialPhone5c) {
        [self resetWebKitCacheModelPreferenKey];
    }
}

- (void)refreshAction {
    
    if ([self canRefreshBrowser]) {
        //统计
        if (![self isError]) {
            [self resetEmptyHTML];
        }
        [self showLoading];
        
//        _webView.scalesPageToFit = YES;
        [_webView reload];
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.webUrlView resignFirstResponder];
    if (_dragView.hidden) {
        return;
    }
    
    if (scrollView.dragging && !_isLoading) {
        if (scrollView.contentOffset.y > kWebViewRefreshDeltaY
            && scrollView.contentOffset.y < 0.0f) {
            // 这里需要一个上次刷新时间的提醒
            [_dragView setCurrentDate];
            
            [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
            
        } else if (scrollView.contentOffset.y < kWebViewRefreshDeltaY) {
            
            [_dragView setStatus:TTTableHeaderDragRefreshReleaseToReload];
            
        } else if (scrollView.contentOffset.y > 0) {
            //            _model.isRefreshManually = isLoadingMore;
            //            _model.isRefreshManually = NO;
        }
    }
	
	// This is to prevent odd behavior with plain table section headers. They are affected by the
	// content inset, so if the table is scrolled such that there might be a section header abutting
	// the top, we need to clear the content inset.
	if (_isLoading) {
        //SNDebugLog(@"### scrollView.contentOffset.y: %f", scrollView.contentOffset.y);
		if (scrollView.contentOffset.y >= 0) {
			scrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
			
		} else if (scrollView.contentOffset.y < 0) {
			scrollView.contentInset = UIEdgeInsetsMake(kWebViewHeaderVisibleHeight, 0, kToolbarViewHeight, 0);
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    
    if (_dragView.hidden) {
        return;
    }
	// If dragging ends and we are far enough to be fully showing the header view trigger a
	// load as long as we arent loading already
	if (scrollView.contentOffset.y <= kWebViewRefreshDeltaY && !_isLoading) {
        _isLoading = YES;
        [self dragViewStartLoad];
        [self refreshAction];
	}
}

//- (void)otherAction {
//	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//	
//	TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://wangqi"] applyAnimated:YES] applyQuery:userInfo];
//	[[TTNavigator navigator] openURLAction:urlAction];
//}

#pragma mark -
#pragma mark ShareInfo
- (BOOL)checkIfHadBeenMyFavourite
{
    return NO;
}

#pragma mark -
#pragma mark Private methods

- (BOOL)isError {
	return _loading.status == SNTripletsLoadingStatusNetworkNotReachable ;
}

- (void)hideError {
    _loading.status = SNTripletsLoadingStatusStopped;
}

- (void)showLoading {
    _loading.status = SNTripletsLoadingStatusLoading;
}

- (void)hideLoading
{
    _loading.status = SNTripletsLoadingStatusStopped;
}

- (void)showErrorView:(NSString *)error {
	_loading.status = SNTripletsLoadingStatusNetworkNotReachable;
}

- (void)enterFullScreen {
	_webView.frame = kFullScreenFrame;
	[_toolbar show:NO animated:YES];
}

- (void)exitFullScreen {
	_webView.frame = TTNavigationFrame();
	[_toolbar show:YES animated:NO];
}

- (SharedInfo *)getSharedInfo {
	SharedInfo *sharedInfo = [[SharedInfo alloc] init];
	sharedInfo.sharedUrl =  [_webView.request.URL absoluteString];
	
	NSString *htmlTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];

    NSString *retultHtmlTitle = [SNUtility getStr:htmlTitle fromStr:@"share:"];
	if (retultHtmlTitle) {
		sharedInfo.sharedTitle = retultHtmlTitle;
	}
	else {
		sharedInfo.sharedTitle = NSLocalizedString(@"SMS share to friends",@"");
	}
    SNDebugLog(@"%@\n%@\n%@", htmlTitle, sharedInfo.sharedUrl, sharedInfo.sharedTitle);
	return sharedInfo;
}

- (void)urlAppendingTimeStamps:(NSURL *)URL {
    
    NSString * urlString = [URL absoluteString];
    if (urlString.length > 0 && ![urlString containsString:@"timestamp="]) {
        if ([URL.absoluteString containsString:@"?"]) {
            NSString *timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
            self.url = [NSURL URLWithString:[URL.absoluteString stringByAppendingFormat:@"&timestamp=%@",timestamp]];
        }
        else{
            NSString *timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
            self.url = [NSURL URLWithString:[URL.absoluteString stringByAppendingFormat:@"?timestamp=%@",timestamp]];
        }

    }
}

- (void)openURL:(NSURL*)URL {
	self.url = URL;
    
    self.webUrl = [URL URLValue];
    if (self.webUrl.length == 0) {
        self.webUrl = [self.url absoluteString];
    }
    self.urlTitle = @"";
    
//    [self urlAppendingTimeStamps:URL];
    
    if(self.webUrlView)
//        [self.webUrlView updateLogoUrl:nil withLink:self.url.absoluteString];
        [self.webUrlView updateTile:self.urlTitle];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	[self openRequest:request];
}

- (void)openRequest:(NSMutableURLRequest*)request {
	[self view];
    [self appendCookieToRequeset:request url:_url];
	[_webView loadRequest:request];
    SNDebugLog(@"request : %@",request);
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
		shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	
    return YES;
}

- (void)tapOnLoadingView {
	if ([self isError]) {
		[self refreshAction];
	}
}

- (void)handleDoubleTap:(id)sender {
	//	UITapGestureRecognizer *gesture = sender;
	//	CGPoint touchPoint = [gesture locationInView:self.view];
	if (_isLoading /*|| [_toolbar pointInside:touchPoint withEvent:nil]*/) {
		return;
	}
	_isFullScreen = !_isFullScreen;
	if (_isFullScreen) {
		[self enterFullScreen];
	}
	else {
		[self exitFullScreen];
	}
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if (!_webView.isLoading) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
        [self appendCookieToRequeset:request url:_url];
        [_webView loadRequest:request];
        [self hideError];
        [_progress startProgress];
        _loading.status = SNEmbededActivityIndicatorStatusStartLoading;
    }
}


#pragma mark -
#pragma mark UIView

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
}

- (void)cleanWebView {
    if (_webView) {
        _webView.delegate = nil;
         //(_webView);
        
         //(_dragView);
    }
}

- (void)viewDidUnload {
	[super viewDidUnload];
	    
    [self cleanWebView];
    
	 //(_toolbar);
	 //(_actionSheet);
	 //(_back);
	 //(_front);
	 //(_refresh);
	 //(_stopBtn);
	 //(_share);
     //(_more);
	 //(_loading);
     //(_titleView);
     //(_progress);
}

// 3.5.1
// 给所有网页访问增加用户中心cookie
- (void)appendCookieToRequeset:(NSMutableURLRequest*)request url:(NSURL*)url;
{
    if(![SNUserManager isLogin])
        return;
    
    if (![self isSNSUrl:url.absoluteString] || ![SNUtility isSohuDomain:url.absoluteString]) {//v5.3.2 非sohu域下不加cookie hz lijiaming
        return;
    }
    
    NSString* cookieValue = [SNUserManager getCookie];
    if(self.url!=nil && cookieValue)
    {
        NSString *cookieHeader = nil;
        NSArray* cookiess = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        
        if([cookiess count] > 0)
        {
            NSHTTPCookie *cookie;
            for(cookie in cookiess)
            {
                if(!cookieHeader)
                    cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
                else 
                    cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
            }
        }
        
        //append cookie
        if (!cookieHeader)
            cookieHeader = [NSString stringWithFormat: @"%@",cookieValue];
        else
            cookieHeader = [NSString stringWithFormat: @"%@; %@",cookieHeader,cookieValue];
        
        SNDebugLog(@"cookieHeader %@", cookieHeader);
        //creat a new cookie
        [request setValue: cookieHeader forHTTPHeaderField: @"Cookie" ];
    }
}

- (void)updateBackgroundColor {
    if (kBackgroundColor && [kBackgroundColor length] > 0) {
        [_webView setBackgroundColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]]];
        [_backgroundView setBackgroundColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]]];
    } else {
        _webView.backgroundColor = RGBCOLOR(248, 248, 248);
        _backgroundView.backgroundColor = RGBCOLOR(248, 248, 248);
    }
}

#pragma mark - h5页面内分享
- (void)shareH5Content:(NSString *)text link:(NSString *)aLink title:(NSString *)aTitle {
    if (!text)
        return;
    
    if (nil == self.shareMenuController) {
        self.shareMenuController = [[SNActionMenuController alloc] init];
    }
    
    self.shareMenuController.shareSubType = ShareSubTypeTextOnly;
    if (_isActivePage) {
        self.shareMenuController.sourceType = SNShareSourceTypeActivityNoUgc;
    }else {
        self.shareMenuController.sourceType = SNShareSourceTypeADSpread;//因为没拿到，和安卓统一，暂时写死为43.  add by huang
    }
    self.shareMenuController.delegate = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (text) [dic setObject:text forKey:kShareInfoKeyContent];
    if (aLink) [dic setObject:aLink forKey:kShareInfoKeyWebUrl];
    if (aTitle) [dic setObject:aTitle forKey:kShareInfoKeyTitle];
    
    self.shareMenuController.contextDic = dic;
    self.shareMenuController.shareLogType = @"liveinvite";
    self.shareMenuController.lastButtonType = SNActionMenuButtonTypeH5Share;
    [self.shareMenuController showActionMenu];
}

//H5分享 推广分享、活动分享、调查分享
- (void)shareWithTitle:(NSString*)aTitle content:(NSString*)aContent link:(NSString*)aLink imageUrl:(NSString*)aImageUrl
{
    if (nil == self.shareMenuController) {
        self.shareMenuController = [[SNActionMenuController alloc] init];
    }
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (_isActivePage) {
        self.shareMenuController.sourceType = SNShareSourceTypeActivityNoUgc;
        [dic setObject:@"activityPage" forKey:@"contentType"];
    }else {
        [dic setObject:@"web" forKey:@"contentType"];
        self.shareMenuController.sourceType = SNShareSourceTypeADSpread;//因为没拿到，和安卓统一，暂时写死为43.  add by huang
    }
    //self.shareMenuController.shareSubType = ShareSubTypeQuoteCard;
    
    self.shareMenuController.delegate = self;
    self.shareMenuController.disableLikeBtn = YES;
    SNTimelineOriginContentObject* shareOjb = [[SNTimelineOriginContentObject alloc] init];
    shareOjb.title = aTitle;
    shareOjb.link = aLink;
    shareOjb.picUrl = aImageUrl;
    shareOjb.description = aContent;
    if(aTitle)
        [dic setObject:aTitle forKey:kShareInfoKeyTitle];
    if(aLink)
        [dic setObject:aLink forKey:kShareInfoKeyWebUrl];
    if(aImageUrl)
        [dic setObject:aImageUrl forKey:kShareInfoKeyImageUrl];
    if(aContent)
        [dic setObject:aContent forKey:kShareInfoKeyContent];
    [dic setObject:shareOjb forKey:kShareInfoKeyShareRead];
    self.shareMenuController.contextDic = dic;
    self.shareMenuController.shareLogType = @"protocal";
    [self.shareMenuController showActionMenu];
}

/* mode 1.微信好友 2.qq 3.短信 4.邮件 */
- (int)actionMenuOption2ShareMode:(SNActionMenuOption)type {
    switch (type) {
        case SNActionMenuOptionWXSession:
            return 1;
        case SNActionMenuOptionQQ:
            return 2;
        case SNActionMenuOptionSMS:
            return 3;
        case SNActionMenuOptionMail:
            return 4;
        default:
            break;
    }
    return -1;
}

- (void)actionmenuWillSelectItemType:(SNActionMenuOption)type {
    if ([self.shareMenuController.shareLogType isEqualToString:@"liveinvite"]) {
        // 执行js函数addPlaceholder4Invite(link)回传给web
        NSString *shareLink = [self.shareMenuController.contextDic stringValueForKey:kShareInfoKeyWebUrl defaultValue:nil];
        if (shareLink.length > 0) {
            NSString *sharemodeKey = @"sharemode";
            int sharemode = [self actionMenuOption2ShareMode:type];
            if (![shareLink containsString:sharemodeKey]) {
                if ([shareLink containsString:@"?"]) {
                    shareLink = [shareLink stringByAppendingFormat:@"&%@=%d", sharemodeKey, sharemode];
                } else {
                    shareLink = [shareLink stringByAppendingFormat:@"?%@=%d", sharemodeKey, sharemode];
                }
                
                [self.shareMenuController.contextDic setObject:shareLink forKey:kShareInfoKeyWebUrl];
                
                NSString *content = [self.shareMenuController.contextDic stringValueForKey:kShareInfoKeyContent defaultValue:@""];
                if (content.length > 0) {
                    content = [content stringByAppendingFormat:@"：（%@）", shareLink];
                    [self.shareMenuController.contextDic setObject:content forKey:kShareInfoKeyContent];
                    SNDebugLog(@"kShareInfoKeyContent: %@", content);
                }
            }
        }
    }
}

#pragma mark - SNWebUrlViewDelegate
- (void)refreshWebView
{
    [self refreshAction];
}

- (void)clickIconView
{
    //不管在那个tab，点击都回到新闻tab头条流，并刷新
    UIViewController* topController = [TTNavigator navigator].topViewController;
    [SNUtility popToTabViewController:topController];
    //tab切换到新闻
    [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
    //栏目切换到焦点
    [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];
    if ([SNUtility isFromChannelManagerViewOpened]) {
        [SNNotificationManager postNotificationName:kHideChannelManageViewNotification object:nil];
    }
}

- (void)subscribeAction{
    if (self.iDelegate && [self.iDelegate respondsToSelector:@selector(subscribeRequest:from:)]) {
        [self.iDelegate subscribeRequest:self.subscribeCode from:self.stockfrom];
    }
}

- (void)unSubscribeAciton{
    if (self.iDelegate && [self.iDelegate respondsToSelector:@selector(unsubscribeRequest:from:)]) {
        [self.iDelegate unsubscribeRequest:self.subscribeCode from:self.stockfrom];
    }
}

- (void)updateTheme {
    NSString *img1 = @"icotab_close_v5.png";
    NSString *img2 = @"icotab_closepess_v5.png";
    [_dismissBtn setImage:[UIImage imageNamed:img1] forState:UIControlStateNormal];
    [_dismissBtn setImage:[UIImage imageNamed:img2] forState:UIControlStateHighlighted];
    
    img1 = @"icotext_back_v5.png";
    img2 = @"icotext_backpress_v5.png";
    [_back setImage:[UIImage imageNamed:img1] forState:UIControlStateNormal];
    [_back setImage:[UIImage imageNamed:img2] forState:UIControlStateHighlighted];
    
    img1 = @"icotab_next_v5.png";
    img2 = @"icotab_nextpess_v5.png";
    [_front setImage:[UIImage imageNamed:img1] forState:UIControlStateNormal];
    [_front setImage:[UIImage imageNamed:img2] forState:UIControlStateHighlighted];
    
    img1 = @"icotab_refresh_v5.png";
    img2 = @"icotab_refreshpess_v5.png";
    [_refresh setImage:[UIImage imageNamed:img1] forState:UIControlStateNormal];
    [_refresh setImage:[UIImage imageNamed:img2] forState:UIControlStateHighlighted];
    
    img1 = @"icotext_more_v5.png";
    img2 = @"icotext_morepress_v5.png";
    [_more setImage:[UIImage imageNamed:img1] forState:UIControlStateNormal];
    [_more setImage:[UIImage imageNamed:img2] forState:UIControlStateHighlighted];
    
    img1 = @"icotext_share_v5.png";
    img2 = @"icotext_sharepress_v5.png";
    [_share setImage:[UIImage imageNamed:img1] forState:UIControlStateNormal];
    [_share setImage:[UIImage imageNamed:img2] forState:UIControlStateHighlighted];
    
    [_progress updateTheme];
}

#pragma mark - 对sns的url特殊处理   add by huangzhen

- (NSString *)addParametersForSNSUrl:(NSString *)snsUrl{
    //p1=NTk3ODg2NDc3MDE2OTA5MDA4NA%3D%3D&gid=02ffff1106111158bcc0d2bd21cdc8c95f76e618d73785&pid=-1&p2=QTAwMDAwMzk0MEY4RkU%3D&u=1&sdk=21&ver=5.2.3
    if ([self isSNSUrl:snsUrl]) {
        
        //gid
        if (![snsUrl containsString:@"gid="]) {
            NSString *gid = [SNUserManager getGid];
            if (![snsUrl containsString:@"?"]) {
                snsUrl = [snsUrl stringByAppendingFormat:@"?gid=%@", gid];
            }
            else {
                snsUrl = [snsUrl stringByAppendingFormat:@"&gid=%@", gid];
            }
        }
        
        //pid
        if (![snsUrl containsString:@"pid="]) {
            NSString *pid = [SNUserManager getPid];
            if (!pid) {
                pid = @"-1";
            }
            if (![snsUrl containsString:@"?"]) {
                snsUrl = [snsUrl stringByAppendingFormat:@"?pid=%@", pid];
            }
            else {
                snsUrl = [snsUrl stringByAppendingFormat:@"&pid=%@", pid];
            }
        }
        
        //p2
        if (![snsUrl containsString:@"p2="]) {
            NSString *p2 = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];//imei
            if (![snsUrl containsString:@"?"]) {
                snsUrl = [snsUrl stringByAppendingFormat:@"?p2=%@", p2];
            }
            else {
                snsUrl = [snsUrl stringByAppendingFormat:@"&p2=%@", p2];
            }
        }
        
        //sdk
        if (![snsUrl containsString:@"sdk="]) {
            NSString *sdk = [[UIDevice currentDevice] systemVersion];
            if (![snsUrl containsString:@"?"]) {
                snsUrl = [snsUrl stringByAppendingFormat:@"?sdk=%@", sdk];
            }
            else {
                snsUrl = [snsUrl stringByAppendingFormat:@"&sdk=%@", sdk];
            }
        }
        
        //ver
        if (![snsUrl containsString:@"ver="]) {
            NSString *ver = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            if (![snsUrl containsString:@"?"]) {
                snsUrl = [snsUrl stringByAppendingFormat:@"?ver=%@", ver];
            }
            else {
                snsUrl = [snsUrl stringByAppendingFormat:@"&ver=%@", ver];
            }
        }
        //token
        snsUrl = [snsUrl stringByAppendingString:[NSString stringWithFormat:@"&token=%@", [SNUserManager getToken]]];

    }

    return snsUrl;
    
}

/**
 *判断是否是SNS的Url。
 */
- (BOOL)isSNSUrl:(NSString *)url{
    return [url containsString:SNLinks_Domain_W];
}

- (void)showAppStoreInApp:(NSURL *)appStoreURL {
    Class isAllow = NSClassFromString(@"SKStoreProductViewController");
    if (isAllow != nil) {
        if (!_sKStoreProductViewController) {
            _sKStoreProductViewController = [[SKStoreProductViewController alloc] init];
            _sKStoreProductViewController.delegate = self;
        }
        [self showLoading];
        [self.webUrlView updateTile:@"努力为您跳转中..."];
        [_sKStoreProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: [self appIdInURL:appStoreURL]}
                                                completionBlock:^(BOOL result, NSError *error) {
                                                    [self hideLoading];
                                                    [self.webUrlView updateTile:@"跳转成功！"];
                                                    if (result) {
                                                        [self presentViewController:_sKStoreProductViewController
                                                                           animated:YES
                                                                         completion:nil];
                                                    }
                                                    else{
                                                        [self.webUrlView updateTile:@"出错啦~"];
                                                        SNDebugLog(@"%@",error);
                                                    }
                                                }];
    }
    else{
        //低于iOS6没有这个类
//        NSString *string = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",_appId];
        [[UIApplication sharedApplication] openURL:appStoreURL];
    }
}

- (NSString *)appIdInURL:(NSURL *)appStoreURL {
    NSString * appId = nil;
    if ([appStoreURL.absoluteString containsString:@"/id"]) {
        appId = [[appStoreURL.absoluteString componentsSeparatedByString:@"/id"] lastObject];
        if ([appId containsString:@"?"]) appId = [[appId componentsSeparatedByString:@"?"] firstObject];
    }
    
    return appId;
}

#pragma mark - SKStoreProductViewControllerDelegate
//对视图消失的处理
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [self backAction];
}

//预览页面初始化
- (id)initWithParams:(NSDictionary *)query URL:(NSURL *)URL{
    if (self = [super initWithNavigatorURL:URL query:query]) {
        SNDebugLog(@"SNWebController query description : %@", [query description]);
        NSString * platformString = [SNUtility platformStringForSohuNews];
        if ([platformString isEqualToString:IPHONE_5C_NAMESTRING]) {
            _isSpecialPhone5c = YES;
        }
        self.query = query;
        NSString *address = [query objectForKey:@"address"];
        _supportLandscape = query[@"landscape"] ? YES : NO;//是否支持横屏展示
        //        _isAD = ([query[kRefer] integerValue] == REFER_AD )? YES : NO; //广告标识
        _isSubSearchPage = [[query objectForKey:@"subSearch" defalutObj:nil] isEqualToString:@"1"];
        self.channelType = [query objectForKey:@"channelType" defalutObj:nil];
        if ([self.channelType isEqualToString:kStockChannelType]) {
            self.addChannel = [[query objectForKey:@"addChannel"] intValue];
            self.iDelegate = [query objectForKey:@"delegate"];
            self.subscribeCode = [query objectForKey:@"subscribeCode" defalutObj:nil];
            self.stockfrom = [query objectForKey:@"stockfrom" defalutObj:@"news"];
        }
        
        if (address.length > 0) {
            NSURL *url = [NSURL URLWithString:address];
            self.webUrl = address;
            //如果创建不成功，需要转义下。
            if (!url) {
                address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                url = [NSURL URLWithString:address];
            }
            [self updateWebView];
            [self openURL:url];
        }
        
        if ([[query objectForKey:kNewsExpressType] intValue] == 1){
            _isPushed = YES;
        }
        
        [SNNotificationManager addObserver:self selector:@selector(handleThemeChangeNotify:) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleWebViewProgressDidChange:) name:kSNWebViewProgressDidChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        
    }
    return self;
}

//预览页面 底部Action Items
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"进入" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self.sourceVC openNewsFrom3DTouch];
    }];
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"关闭" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
    }];
    
    [arr addObject:action1];
    [arr addObject:action2];
    
    return arr;
}

@end
