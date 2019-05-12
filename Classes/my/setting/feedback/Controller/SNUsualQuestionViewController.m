//
//  SNUsualQuestionViewController.m
//  UserFeedBack
//
//  Created by 李腾 on 2016/10/2.
//  Copyright © 2016年 suhu. All rights reserved.
//

#import "SNUsualQuestionViewController.h"
#import "UIAlertView+Blocks.h"
#import "SNFeedBackApi.h"
#import "SHMediaApi.h"
#import "SNThemeManager.h"
#import "SNLoadingImageAnimationView.h"
#import "SNTripletsLoadingView.h"
#import "SNNewsLogin.h"
#import "SNUserManager.h"
#import "NSObject+YAJL.h"
#import "SNNewsLoginManager.h"
#import "SNUserinfo.h"

@interface SNUsualQuestionViewController () <UIWebViewDelegate, UIScrollViewDelegate,SNTripletsLoadingViewDelegate>
{
    BOOL isLoadFinishRedirectGo;//已经调过redirect.go 种cookie失败
}
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) SNLoadingImageAnimationView *animationImageView;
@property (nonatomic, strong) SNTripletsLoadingView *loadingView;
@property (nonatomic, strong) UIView *nightModeView;

@end

@implementation SNUsualQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    [self loadWebView];
    [self updateTheme];
    self.animationImageView.status = SNImageLoadingStatusLoading;

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([SNUserManager isLogin]) {
            [SNUtility deleteCookieForUrl:self.url];
            //避免token过期（有效期1天），每次新进，清cookie
            if (self.isUserComment) {
                [self addCookieForUrlString:self.url request:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
            }
            else {
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
            }
        }
        else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
        }
    });
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [self showErrorAnimationView];
    }
    
    [SNNotificationManager addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_animationImageView) {
        _animationImageView.status = SNImageLoadingStatusStopped;
    }
}

- (void)reachabilityChanged:(NSNotification *)noti {
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    if ([conn currentReachabilityStatus] != NotReachable) {
         [self hideError];
         self.animationImageView.status = SNImageLoadingStatusLoading;
         self.backView.hidden = NO;
         [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }
}

#pragma mark load subviews
- (void)loadWebView {
    self.webView = [[SHWebView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight-kHeaderHeightWithoutBottom-kToolbarHeight)];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.keyboardDisplayRequiresUserAction = NO;//设为NO后，focus方法即可自动弹出键盘
    self.webView.scrollView.scrollsToTop = YES;
    [self.webView setBackgroundColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor]];
    self.webView.scrollView.delegate = self;
    self.webView.opaque = NO; // 设成YES会使夜间模式时，视频新闻背景色闪白一下
    self.webView.jsDelegate = self;
    if (!self.isUserComment) {
        //用于接收JS事件
        SNFeedBackApi *feedBackApiModel = [[SNFeedBackApi alloc] init];
        feedBackApiModel.usualQuestionViewController = self;
        [self.webView registerJavascriptInterface:feedBackApiModel forName:@"FeedBackApi"];
    }
    
    [self.view addSubview:self.webView];
    
    [self setWebNightMode];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.isUserComment) {
        NSString *urlString = request.URL.absoluteString;
        SNDebugLog(@"webview load url:%@", urlString);
        if ([self processProtocol:urlString request:request LoginFrom:@"100034"]) {
            //二代协议处理
            return NO;
        }
        else {
            if ([urlString containsString:@"noBack=1"]) {
                if ([self.webView canGoBack]) {
                    [self.webView goBack];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2), dispatch_get_main_queue(), ^() {
                        [self h5Refresh];
                    });
                }
            }
        }
       
        [self setNativeCookieForUrl:urlString];
        
        return YES;
    }
    
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 禁用长按弹出框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    // 禁用用户选择
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    if (self.isUserComment) {
        [self stopLoadingAnimation];
        
        if (self.backUrl.length > 0) {
            [self newReloadWebUrl:self.backUrl];
            self.backUrl = nil;
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.isUserComment) {
        [self stopLoadingAnimation];
    }
}

#pragma mark scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isUserComment && _nightModeView) {
        CGFloat viewHeight = scrollView.contentSize.height;
        if (viewHeight < self.webView.height) {
            viewHeight = self.webView.height;
        }
        _nightModeView.frame = CGRectMake(0, 0, scrollView.width, viewHeight);
    }
}

#pragma mark webview night mode
- (void)setWebNightMode {
    if ([[SNThemeManager sharedThemeManager] isNightTheme] && self.isUserComment) {
        if ([self.webView.subviews count] > 0 && [[self.webView.subviews objectAtIndex:0].subviews count] > 0) {
            UIView *view = [[self.webView.subviews objectAtIndex:0].subviews objectAtIndex:0];
            [view addSubview:self.nightModeView];
        }
    }
}

- (UIView *)nightModeView {
    if (!_nightModeView) {
        _nightModeView = [[UIView alloc] init];
        _nightModeView.backgroundColor = SNUICOLOR(kBackgroundColor);
        _nightModeView.alpha = 0.6;
    }
    
    CGFloat offHeight = [[SNDevice sharedInstance] isPlus] ? 2.0 : 0.0;
    [_nightModeView setFrame:CGRectMake(0, 0, self.webView.scrollView.contentSize.width, self.webView.scrollView.contentSize.height + offHeight)];
    return _nightModeView;
}

- (void)stopLoadingAnimation {
    self.animationImageView.status = SNImageLoadingStatusStopped;
    self.backView.hidden = YES;

    [self hideError];
}

- (void)showErrorAnimationView {
    self.animationImageView.status = SNImageLoadingStatusStopped;
    self.backView.hidden = YES;
     [self showError];
}

- (SNLoadingImageAnimationView *)animationImageView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, -64, kAppScreenWidth, kAppScreenHeight)];
        _backView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        [self.view addSubview:_backView];
    }
    if (!_animationImageView) {
        _animationImageView = [[SNLoadingImageAnimationView alloc] init];
        _animationImageView.targetView = _backView;
    }
    
    return _animationImageView;
}

- (void)showError {
    if (!_loadingView)
    {
        CGRect rect = CGRectMake(0, -64, kAppScreenWidth, kAppScreenHeight);
        _loadingView = [[SNTripletsLoadingView alloc] initWithFrame:rect];
        _loadingView.delegate = self;
        _loadingView.status = SNTripletsLoadingStatusStopped;
        [self.view addSubview:_loadingView];
    }
    _loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
}

- (void)hideError {
    _loadingView.status = SNTripletsLoadingStatusStopped;
}

#pragma mark process url
- (BOOL)processProtocol:(NSString *)urlString request:(NSURLRequest *)request LoginFrom:(NSString*)loginFrom{
    if ([SNUtility isProtocolV2:urlString]) {
        if ([urlString hasPrefix:kProtocolLogin]) {
            NSDictionary *dict = [SNUtility parseURLParam:urlString schema:kProtocolLogin];
            NSString *backUrl = [[dict stringValueForKey:@"backUrl" defaultValue:nil] URLDecodedString];
            [SNNewsLogin loginWithParams:@{@"loginFrom":loginFrom} Success:^(NSDictionary *dict) {
                [SNNotificationManager postNotificationName:kCloseChatFeedbackNotification object:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.3), dispatch_get_main_queue(), ^() {
                    NSDictionary *dictInfo = nil;
                    if ([backUrl containsString:@"/topics/"]) {
                        dictInfo = @{kLoginBackUrlKey:backUrl};
                    }
                    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://feedback"] applyAnimated:NO] applyQuery:dictInfo];
                    [[TTNavigator navigator] openURLAction:action];
                });
            }];
        }
        else {
            [SNUtility openProtocolUrl:urlString];
        }
        return YES;
    }
    else{
        if ([urlString containsString:kProtocolTelBind]) {
            [SNNewsLoginManager bindData:nil Successed:^(NSDictionary *info) {
                [self.webView reload];
            } Failed:^(NSDictionary *errorDic) {
                [self.webView reload];
            }];
            return YES;
        }
    }
    
    return NO;

}

#pragma mark process url
- (BOOL)processProtocol:(NSString *)urlString request:(NSURLRequest *)request {
    if ([SNUtility isProtocolV2:urlString]) {
        if ([urlString hasPrefix:kProtocolLogin]) {
            NSDictionary *dict = [SNUtility parseURLParam:urlString schema:kProtocolLogin];
            NSString *backUrl = [[dict stringValueForKey:@"backUrl" defaultValue:nil] URLDecodedString];
            [SNNewsLogin loginSuccess:^(NSDictionary *dict) {
                [SNNotificationManager postNotificationName:kCloseChatFeedbackNotification object:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.3), dispatch_get_main_queue(), ^() {
                    NSDictionary *dictInfo = nil;
                    if ([backUrl containsString:@"/topics/"]) {
                        dictInfo = @{kLoginBackUrlKey:backUrl};
                    }
                    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://feedback"] applyAnimated:NO] applyQuery:dictInfo];
                    [[TTNavigator navigator] openURLAction:action];
                });
            }];
        }
        else {
            [SNUtility openProtocolUrl:urlString];
        }
        return YES;
    }
    return NO;
}

#pragma mark native add cookie
- (void)setNativeCookieForUrl:(NSString *)urlString {
    if (![SNUserManager isLogin]) {
        return;
    }
    
    NSString *cookieHeader = [SNUtility extractionCookie:urlString key:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *cookieString = nil;
    NSString *cookieName = nil;
    NSHTTPCookie *cookie = nil;
    NSDictionary *dict = nil;
    
    //判断域名下是否种过cookie
    if (![cookieHeader containsString:@"news_info"] && [urlString containsString:@"kuaizhan.com"]) {
        cookieString = [[self getAppInfo] yajl_JSONString];
        dict = @{NSHTTPCookieDomain:[url host], NSHTTPCookiePath:@"/", NSHTTPCookieName:@"ppinf", NSHTTPCookieValue:cookieString};
        cookie = [NSHTTPCookie cookieWithProperties:dict];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
     }
    
    if (![cookieHeader containsString:@"kuaizhan_access_token"] && [urlString containsString:@"kuaizhan.com"]) {
        cookieString = [SNUtility getAccessTokenInWebCookie:[SNAPI baseUrlWithDomain:@"www.sohu.com"] cookieName:@"kuaizhan_access_token"];
        SNDebugLog(@"kuaizhan_access_token:%@", cookieString);
        if (cookieString.length > 0) {
            dict = @{NSHTTPCookieDomain:[url host], NSHTTPCookiePath:@"/", NSHTTPCookieName:@"access_token", NSHTTPCookieValue:cookieString};
            cookie = [NSHTTPCookie cookieWithProperties:dict];
            SNDebugLog(@"dic::::%@",dict);
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        else{
            
            if (![SNUtility getApplicationDelegate].isNetworkReachable) {//如果有网络才能登陆
                return;
            }
            
            if ([[url host] isEqualToString:@"sohuxinwen1.kuaizhan.com"] && isLoadFinishRedirectGo == YES) {
                //服务端种cookie 失败
                SNDebugLog(@"no kuaizhan_access_token");
                if ([SNUserManager isLogin]) {
                    SNUserinfoEx* user_info = [SNUserinfoEx userinfoEx];
                    NSString* passport = user_info.passport?user_info.passport:user_info.userName;
                    NSString* u = [NSString stringWithFormat:@"http://club.kuaizhan.sohuno.com/apiv1/internal/sohu/passport/gen-access-token?passport=%@&thirdport_name=sohu_news",passport];
                    if (u.length>0) {
                        NSURL* url = [NSURL URLWithString:u];
                        NSURLRequest* req = [NSURLRequest requestWithURL:url];
                        NSURLResponse* resp = nil;
                        NSError* error = nil;
                        NSData* data = [self sendSynchronousRequest:req returningResponse:&resp error:&error];
                        
                        NSDictionary* re_json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        if (re_json && [re_json isKindOfClass:[NSDictionary class]]) {
                            NSString* access_token = [re_json objectForKey:@"access_token"];
                            if (access_token) {
                                dict = @{NSHTTPCookieDomain:@"sohuxinwen1.kuaizhan.com", NSHTTPCookiePath:@"/", NSHTTPCookieName:@"access_token", NSHTTPCookieValue:access_token};
                                cookie = [NSHTTPCookie cookieWithProperties:dict];
                                SNDebugLog(@"dic::::%@",dict);
                                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                                
                                dict = @{NSHTTPCookieDomain:@"www.sohu.com", NSHTTPCookiePath:@"/", NSHTTPCookieName:@"kuaizhan_access_token", NSHTTPCookieValue:access_token};
                                cookie = [NSHTTPCookie cookieWithProperties:dict];
                                SNDebugLog(@"dic::::%@",dict);
                                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                            }
                        }
                    }
                }
            }
            
            if ([urlString containsString:@"redirect.go"]) {
                isLoadFinishRedirectGo = YES;
            }
        }
    }
}


- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error{
    NSError __block *err = NULL;
    NSData __block *data;
    BOOL __block reqProcessed = false;
    NSURLResponse __block *resp;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error) {
        
        resp = _response;
        if (_response) {
            SNDebugLog(@"request response kuaizhan:%@",resp);
        }
        err = _error;
        data = _data;
        reqProcessed = true;
        
    }] resume];
    
    while (!reqProcessed) {
        [NSThread sleepForTimeInterval:0];
    }
    
    *response = resp;
    *error = err;
    
    return data;
}

- (NSDictionary *)getAppInfo {
    NSString *p1 = [SNUserManager getP1] ? : @"";
    NSString *pid = [SNUserManager getPid] ? : @"-1";
    NSString *productId = [SNAPI productId] ? : @"";
    NSString *phoneBrand = [[UIDevice currentDevice] platformStringForSohuNews];
    NSString *gid = [SNUserManager getGid] ? : @"";
    NSDictionary *dict = @{@"p1":p1, @"pid":pid, @"productId":productId, @"phoneBrand":phoneBrand, @"gid":gid};
    return dict;
}

#pragma mark server add cookie
- (void)addCookieForUrlString:(NSString *)urlString request:(NSURLRequest *)request {
    NSString *cookieHeader = [SNUtility extractionCookie:urlString key:nil];
    //判断域名下是否种过cookie，没种过则调用redirect.go种cookie
    if ([cookieHeader containsString:@"ppinf"] && [cookieHeader containsString:@"pprdig"]) {
        [self.webView reload];
        return;
    }
    
    BOOL isHttp = [urlString hasPrefix:kProtocolHTTP] || [urlString hasPrefix:kProtocolHTTPS];
    if (isHttp) {
        NSString *pid = [SNUserManager getPid] ? : @"-1";
        NSString *token = [SNUserManager getToken] ? : @"";
        NSString *passport = [SNUserManager getUserId] ? : @"";
        if (![urlString containsString:kH5LoginUrlString]) {
            NSString *format = nil;
            if ([urlString containsString:@"?"]) {
                format = @"&u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@";
            }
            else {
                format = @"?u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@";
            }
            
            urlString = [urlString stringByAppendingFormat:format, [SNAPI productId], [SNUserManager getP1], [SNUserManager getGid], pid, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], token, passport];
            urlString = [NSString stringWithFormat:kH5LoginUrl , [urlString URLEncodedString]];
        }
        urlString = [urlString stringByAppendingFormat:@"&u=%@&p1=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@&passport=%@", [SNAPI productId], [SNUserManager getP1], [SNUserManager getGid], pid, [[UIDevice currentDevice] uniqueDeviceIdentifier], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], token, passport];
        
        NSMutableURLRequest *newRequest = [request mutableCopy];
        newRequest.timeoutInterval = WEBVIEW_REQUEST_TIMEOUT;
        [newRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];//减少内存占用
        newRequest.URL = [NSURL URLWithString:urlString];
        [self.webView loadRequest:newRequest];
    }
}

- (void)newReloadWebUrl:(NSString *)urlString {
    NSMutableURLRequest *newRequest = [self.webView.request mutableCopy];
    newRequest.timeoutInterval = WEBVIEW_REQUEST_TIMEOUT;
    [newRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];//减少内存占用
    newRequest.URL = [NSURL URLWithString:urlString];
    [self.webView loadRequest:newRequest];
}

- (void)updateTheme {
    BOOL nightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    
    if (self.isUserComment) {
        self.url = [NSString stringWithFormat:SNLinks_path_Kuaizhan_UserComment];
        [self setNativeCookieForUrl:self.url];
    }
    else {
        self.url = [NSString stringWithFormat:@"%@?mode=%zd",SNLinks_Path_FeedBackH5_AllQuestion,nightTheme];
    }
}

#pragma mark - SNTripletsLoadingViewDelegate
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        [self hideError];
        self.animationImageView.status = SNImageLoadingStatusLoading;
        self.backView.hidden = NO;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }
}

- (void)h5Refresh {
    [self.webView callJavaScriptFunction:@"window.location.reload()" forKey:nil callBack:^(JsKitClient *client, id data, NSString *key){
    }];
}

- (void)dealloc {
    if (self.webView) {
        self.webView.jsDelegate = nil;
        self.webView.scrollView.delegate = nil;
    }
    
    [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
}


@end
