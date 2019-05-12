//
//  SNRollingChannelWebViewController.m
//  sohunews
//
//  Created by yangln on 2016/12/23.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRollingChannelWebViewController.h"
#import "SHWebView.h"

#import "SNUserManager.h"
#import "SNGetH5Request.h"
#import "SNRollingNewsTableController.h"

@interface SNRollingChannelWebViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) SHWebView *channelWebView;
@property (nonatomic, strong) NSString *channelID;
@property (nonatomic, strong) NSURL *channelURL;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, assign) BOOL isLoadMainPage;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) BOOL isRedirect;
@property (nonatomic, strong) UIView *nightModeView;

@end

@implementation SNRollingChannelWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.scrollsToTop = NO;//避免iOS7点击状态栏，不能置顶
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kAppScreenWidth, kAppScreenHeight)];
    _backgroundView.backgroundColor = SNUICOLOR(kBackgroundColor);
    [self.view addSubview:_backgroundView];
    
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);

    self.dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
    
    [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(setWebTopNotification:) name:kResetTopNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(webViewReload) name:kRefreshChannelWebViewNotification object:nil];
}

- (void)doRequest:(NSString *)channelID {
    self.channelID = channelID;
    
    [[[SNGetH5Request alloc] initWithDictionary:@{@"channelId":channelID}] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            self.channelURL = [NSURL URLWithString:[responseObject stringValueForKey:@"h5url" defaultValue:@""]];
            [self openWebView:self.channelURL];
        }
    } failure:nil];
}

- (void)openWebView:(NSURL *)URL {
    self.isLoadMainPage = YES;
    self.dragLoadingView.status = SNTwinsLoadingStatusLoading;
    if (!_request) {
        _request = [NSMutableURLRequest requestWithURL:URL];
        _request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    [self.channelWebView loadRequest:_request];
    
    [self setWebNightMode];
}

- (void)webViewReload {
    [self openWebView:self.channelURL];
}

- (SHWebView *)channelWebView {
    if (!_channelWebView) {
        if (SYSTEM_VERSION_LESS_THAN(@"8.0") && ![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initChannelWebView];
            });
        } else {
            [self initChannelWebView];
        }
        [self.view addSubview:_channelWebView];
    }
    return _channelWebView;
}

- (void)initChannelWebView {
    CGFloat offset = 2.0;
    if ([[SNDevice sharedInstance] isPlus]) {
        offset = 8.0;
    }
    CGFloat webViewHeight = kAppScreenHeight - kHeaderHeightWithoutBottom - kToolbarViewHeight - offset;
    CGFloat webViewTop = kHeaderHeightWithoutBottom;
    _channelWebView = [[SHWebView alloc] initWithFrame:CGRectMake(0, webViewTop, kAppScreenWidth, webViewHeight)];
    _channelWebView.jsDelegate = self;
    _channelWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _channelWebView.scrollView.delegate = self;
    _channelWebView.opaque = NO;
    _channelWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    _channelWebView.scalesPageToFit = YES;
    _channelWebView.backgroundColor = [UIColor clearColor];
}

- (SNTwinsLoadingView *)dragLoadingView {
    if (!_dragLoadingView) {
        CGRect dragLoadingViewFrame = CGRectMake(0, 8.0, kAppScreenWidth, kHeaderHeight);
        _dragLoadingView = [[SNTwinsLoadingView alloc] initWithFrame:dragLoadingViewFrame andObservedScrollView:self.channelWebView.scrollView];
        [self.channelWebView insertSubview:_dragLoadingView belowSubview:self.channelWebView.scrollView];
    }
    return _dragLoadingView;
}

#pragma mark UIWebView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.isRedirect) {
        return YES;
    }
    NSString *urlString = request.URL.absoluteString;
    BOOL isFromH5 = [urlString containsString:kH5NoTriggerIOSClick] && [SNUtility isProtocolV2:urlString];
    if (navigationType == UIWebViewNavigationTypeLinkClicked || isFromH5) {
        if ([urlString containsString:kOpenPageInCurrentWebViewTag] || self.isLoadMainPage) {
            if (self.isLoadMainPage) {
                self.isLoadMainPage = NO;
            }
            return YES;
        } else {
            NSString *newUrlString = [SNUtility changeSohuLinkToProtocol:urlString];
            if (newUrlString.length == 0) {
                newUrlString = urlString;
            }
            
            if ([SNUtility isProtocolV2:newUrlString]) {
                [SNUtility shouldUseSpreadAnimation:YES];
            } else {
                [SNUtility shouldUseSpreadAnimation:NO];
            }
            
            [SNUtility openProtocolUrl:newUrlString context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], kFromRollingChannelWebKey, nil]];
            return NO;
        }
    }
    
    if (self.isLoadMainPage) {
        self.isLoadMainPage = NO;
    }

    if ([SNAPI isWebURL:urlString]) {
        return [self seedCookieForURLString:urlString];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //处理网络慢的情况下，动画展示延迟结束
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(processH5ChannelLoading)] && [self.delegate isKindOfClass:[SNRollingNewsTableController class]]) {
            [self.delegate processH5ChannelLoading];
        }
    });
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self.delegate respondsToSelector:@selector(processH5ChannelLoading)] && [self.delegate isKindOfClass:[SNRollingNewsTableController class]]) {
        [self.delegate processH5ChannelLoading];
    }
    self.dragLoadingView.status = SNTwinsLoadingStatusPullToReload;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isRedirect = NO;
        
        if ([self.delegate respondsToSelector:@selector(resetH5TripletsLoadingView)] && [self.delegate isKindOfClass:[SNRollingNewsTableController class]]) {
            [self.delegate resetH5TripletsLoadingView];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.channelWebView.scrollView.contentOffset = CGPointZero;
        }];
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showNetWorkError];
    self.isRedirect = NO;
}

#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_nightModeView) {
        CGFloat viewHeight = scrollView.contentSize.height;
        if (viewHeight < self.channelWebView.height) {
            viewHeight = self.channelWebView.height;
        }
        _nightModeView.frame = CGRectMake(0, 0, scrollView.width, viewHeight);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if ((scrollView.contentOffset.y + scrollView.contentInset.top) <= -_dragLoadingView.frame.size.height) {
        [self openWebView:self.channelURL];
    }
}

- (void)updateTheme {
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    _backgroundView.backgroundColor = SNUICOLOR(kBackgroundColor);
    [self setWebNightMode];
}

- (void)setWebTopNotification:(NSNotification *)notification {
    BOOL isTop = [[notification.userInfo objectForKey:kScrollsToTopStatusKey] boolValue];
    self.tableView.scrollsToTop = NO;
    self.channelWebView.scrollView.scrollsToTop = isTop;
}

- (void)showNetWorkError {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

- (BOOL)seedCookieForURLString:(NSString *)urlString {
    if ([SNUserManager isLogin] && [urlString containsString:SNLinks_Domain_M]) {
        urlString = [NSString stringWithFormat:kH5LoginUrl, [urlString URLEncodedString]];
        urlString = [urlString stringByAppendingFormat:@"&u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@", [SNAPI productId], [SNUserManager getP1], [SNUserManager getGid], [SNUserManager getPid], [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [SNUserManager getToken]];
        
        NSMutableURLRequest *newRequest = [_request mutableCopy];
        newRequest.timeoutInterval = WEBVIEW_REQUEST_TIMEOUT;
        //减少内存占用
        [newRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        newRequest.URL = [NSURL URLWithString:urlString];
        [self.channelWebView loadRequest:newRequest];
        self.isRedirect = YES;
        return NO;
    }
    return YES;
}

- (void)setWebNightMode {
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        if ([self.channelWebView.subviews count] > 1 && [[self.channelWebView.subviews objectAtIndex:0].subviews count] > 0) {
            UIView *view = [[self.channelWebView.subviews objectAtIndex:1].subviews objectAtIndex:0];
            [view addSubview:self.nightModeView];
        }
    } else {
        if (_nightModeView) {
            [self.nightModeView removeFromSuperview];
        }
    }
}

- (UIView *)nightModeView {
    if (!_nightModeView) {
        _nightModeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.channelWebView.width, self.channelWebView.height)];
        UIColor *color = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
        _nightModeView.backgroundColor = color;
        _nightModeView.alpha = 0.6;
    }
    [_nightModeView setFrame:CGRectMake(0, 0, self.channelWebView.scrollView.contentSize.width, self.channelWebView.scrollView.contentSize.height)];
    return _nightModeView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_dragLoadingView removeObserver];
    _channelWebView.jsDelegate = nil;
    [_channelWebView removeFromSuperview];
    _dragLoadingView.status = SNTwinsLoadingStatusNil;
    [_dragLoadingView removeFromSuperview];
    [SNNotificationManager removeObserver:self];
    self.delegate = nil;
}

@end
