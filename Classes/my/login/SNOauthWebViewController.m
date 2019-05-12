//
//  SNOauthWebViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNOauthWebViewController.h"
#import "SNLoginRegisterViewController.h"
#import "SNTimelineLoginViewController.h"
#import "SNGuideRegisterManager.h"
#import "SNUserManager.h"


#define kIndicatorSize 20

@implementation SNOauthWebViewController

@synthesize _loadurl;
@synthesize _cookieName;
@synthesize _cookieValue;
@synthesize _lastUrl;
@synthesize _userInfoModel;
@synthesize _domain;
@synthesize _delegate,_method;
@synthesize _needPop;
@synthesize isModal;

-(void)dealloc
{
    
    if(_userInfoModel!=nil)
        [_userInfoModel clearRequestAndDelegate];
}

-(id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNavigatorURL:URL query:query];
    if(self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self._loadurl = [query objectForKey:@"url"];
        self._cookieName = [query objectForKey:@"cookiename"];
        self._cookieValue = [query objectForKey:@"cookievalue"];
        //self._userInfoModel = [query objectForKey:@"model"];
        self._domain = [query objectForKey:@"domain"];
        
        //后续处理
        self._delegate = [query objectForKey:@"openDelegate"];
        self._method = [query objectForKey:@"openSelector"];
        self.isModal = !![query objectForKey:@"isModal"];
        _isRegisterProtocol = [[query objectForKey:@"isRegisterProtocol"] boolValue];
        _userInfoModel = [[SNUserAccountService alloc] init];
        _userInfoModel.loginDelegate = self;
        _isLoginType = [[query objectForKey:@"isLoginType"] boolValue];
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)addHeaderView {
    CGRect screenFrame = TTApplicationFrame();
    SNHeadSelectView *headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, screenFrame.size.width, kHeaderTotalHeight)];
    //[headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"moreApp", @"")]];
    [headerView setSections:[NSArray arrayWithObject:@""]];
    [self.view addSubview:headerView];
}

- (void)addToolbar {
    SNToolbar *toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight)];
    
    if (self.isModal) {
        // 关闭按钮
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
        [rightButton setImage:[UIImage imageNamed:@"tb_close_browser.png"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"tb_close_browser_hl.png"] forState:UIControlStateHighlighted];
        [rightButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [toolbarView setRightButton:rightButton];
    }
    else {
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView setLeftButton:leftButton];
    }
    self.toolbar = toolbarView;
    [self.view addSubview:toolbarView];
}

- (void)onBack:(id)sender {
//    NSArray *array = (NSArray*)self.flipboardNavigationController.viewControllers;
//    if ([SNGuideRegisterManager popGuideRegisterController:array popController:self]) {
//        return;
//    }
    [self.flipboardNavigationController popViewControllerAnimated:YES];
    [SNNotificationManager postNotificationName:kSNCommonWebViewControllerDidCloseNotification object:nil];
}

- (void)onClose:(id)sender {
    NSArray *array = (NSArray*)self.flipboardNavigationController.viewControllers;
    if ([SNGuideRegisterManager popGuideRegisterController:array popController:self]) {
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [SNNotificationManager postNotificationName:kSNCommonWebViewControllerDidCloseNotification object:nil];
}

- (void)loadView
{
	[super loadView];
    [self.toolbar  removeFromSuperview];
    [self.progress removeFromSuperview];
//    _loading.frame = self.view.bounds;
    _loading.frame = CGRectMake(0, -30, kAppScreenWidth, kAppScreenHeight);
    
    //[self addHeaderView];
    [self addToolbar];
    
    //_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.autoresizingMask = UIViewAutoresizingNone;
	_webView.scalesPageToFit = NO;
    
    self.webUrlView.hidden = YES;
    if (_isRegisterProtocol || _isLoginType) {
        float bottomInset = kWebToolbarViewHeight;
        if (bottomInset > 0) {
            bottomInset -= 15;
        }
        _webScrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, bottomInset, 0.f);
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _loading.status = SNTripletsLoadingStatusStopped;
    [SNNotificationCenter hideLoading];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.webView.frame = CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight-kSystemBarHeight-kToolbarViewTop);
    if (SYSTEM_VERSION_LESS_THAN(@"7"))
    {
        //适配新用户引导
        if ([UIApplication sharedApplication].statusBarHidden)
        {
            self.webView.top = 20.f;
            self.toolbar.bottom += 20;
        }
        else
        {
            if (self.view.height == 568 || self.view.height == 480)
            {
                self.webView.top = 20.f;
                self.toolbar.bottom += 20;
            }
        }
    }
//    if ([[_webView subviews] count] > 0) {
//        UIScrollView *scrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
//        if ([scrollView isKindOfClass:[UIScrollView class]]) {
//            scrollView.contentInset = UIEdgeInsetsMake(kHeadBottomHeight, 0, 0, 0);
//            scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kHeadBottomHeight, 0, 0, 0);
//        }
//    }
    [self  openUrl];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_webView!=nil)
        [_webView stopLoading];
}

//-(void)appendCookieToRequeset:(NSMutableURLRequest*)request url:(NSURL*)url
//{
//    if(self.url!=nil && _cookieName!=nil && _cookieValue!=nil)
//    {
//        NSString *cookieHeader = nil;
//        NSArray* cookiess = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
//        
//        if([cookiess count] > 0)
//        {
//            NSHTTPCookie *cookie;
//            for(cookie in cookiess)
//            {
//                if(!cookieHeader && ![[cookie name] isEqualToString:_cookieName])
//                    cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
//                else if(![[cookie name] isEqualToString:_cookieName])
//                    cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
//            }
//        }
//        
//        //append cookie
//#if kNewUserCenter
//        if (!cookieHeader)
//            cookieHeader = [NSString stringWithFormat: @"%@",_cookieValue];
//        else
//            cookieHeader = [NSString stringWithFormat: @"%@; %@",cookieHeader,_cookieValue];
//#else
//        if (!cookieHeader)
//            cookieHeader = [NSString stringWithFormat: @"%@=%@",_cookieName,_cookieValue];
//        else
//            cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,_cookieName,_cookieValue];
//#endif
//
//        //creat a new cookie
//        [request setValue: cookieHeader forHTTPHeaderField: @"Cookie" ];
//    }
//}



-(NSMutableURLRequest*)requestWithURL:(NSURL*)url
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [self appendCookieToRequeset:request url:url];
    return request;
}


-(void)openUrl
{
//    if(_loadurl!=nil)
//    {
        NSURL* url = [NSURL URLWithString:_loadurl];
        //[self openURL:url];
        
        self.url = url;
        NSMutableURLRequest* request = [self requestWithURL:url];
        [self openRequest:request];
//    }
}

- (void)handleProgress:(CGFloat)progress
{
}

- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    if(!_isLoading)
    {
        [self openUrl];
        _loading.status = SNTripletsLoadingStatusLoading;
    }
}


#pragma mark -
#pragma mark UIWebViewDelegate Methods

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        _loading.status = SNTripletsLoadingStatusNetworkNotReachable;
        return NO;
    }
    SNDebugLog(@"%@", [request.URL absoluteString]);
    NSString* curUrlStr = [[request.URL absoluteString] lowercaseString];
    BOOL ishttps = [SNAPI isWebURL:curUrlStr];
    BOOL isRu = (NSNotFound != [curUrlStr rangeOfString:@"ru=" options:NSCaseInsensitiveSearch].location); //第一次进入的引用字段
    BOOL isSohuDomain = (NSNotFound != [curUrlStr rangeOfString:@"sohu.com" options:NSCaseInsensitiveSearch].location);

    if ([SNPreference sharedInstance].debugModeEnabled) {
        if (!isSohuDomain) {
            isSohuDomain = [SNUtility isSohuDomain:curUrlStr];
        }
    }
    BOOL isLogin = (NSNotFound != [curUrlStr rangeOfString:@"login.go" options:NSCaseInsensitiveSearch].location);
    BOOL getToken = (NSNotFound != [curUrlStr rangeOfString:@"getToken.go" options:NSCaseInsensitiveSearch].location);
    BOOL isBind = (NSNotFound != [curUrlStr rangeOfString:@"bind.go" options:NSCaseInsensitiveSearch].location);
    
    //空操作
    if(curUrlStr==nil)
        return YES;
    //不要重复执行上一个操作
    if(self.url!=nil && self.url.absoluteString!=nil && [[self.url.absoluteString lowercaseString] isEqualToString:curUrlStr])
        return YES;
    
    if(!ishttps && isSohuDomain && !isRu) //单独处理自动登录
    {
        if(isLogin || getToken)
        {
            _loading.status = SNTripletsLoadingStatusStopped;
            
            NSString* urlWithGid = [NSString stringWithFormat:@"%@&gid=%@", [request.URL absoluteString], [SNUserManager getGid]];
            if(_delegate!=nil && _method!=nil && [_delegate respondsToSelector:NSSelectorFromString(_method)]) //分享登录+绑定
            {
                [_delegate performSelector:NSSelectorFromString(_method) withObject:urlWithGid afterDelay:0.0f];
                if (self.isModal) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else {
                    [self.flipboardNavigationController popViewControllerAnimated:YES];
                }
                return NO;
            }
            else if(_userInfoModel!=nil && [_userInfoModel openLoginRequest:urlWithGid domain:_domain]) //第三方网页登录
            {
                _userInfoModel.loginDelegate = self;
                [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
            }
            return NO;
        }
        else if (isBind)//只有绑定
        {
            _loading.status = SNTripletsLoadingStatusStopped;
            if(_delegate!=nil && _method!=nil && [_delegate respondsToSelector:NSSelectorFromString(_method)]) //sso绑定
            {
                [_delegate performSelector:NSSelectorFromString(_method) withObject:[request.URL absoluteString] afterDelay:0.0f];
                if (self.isModal) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else {
                    [self.flipboardNavigationController popViewControllerAnimated:YES];
                }
                return NO;
            }
            return NO;
        }
    }
    
    //Go on
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
	
	_isLoading = NO;
	_back.enabled = [_webView canGoBack];
	_front.enabled = [_webView canGoForward];
	_share.enabled = YES;
    if (!_firstLoaded) {
        _loading.status = SNTripletsLoadingStatusStopped;
    }
    _firstLoaded = YES;
    
    [self dragViewFinishLoad];
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
	
	_isLoading = YES;
    if (!_firstLoaded) {
        _loading.status = SNTripletsLoadingStatusLoading;
    }
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
    _isLoading = NO;
    if (_isRegisterProtocol) {//断网立即点击注册协议，避免页面一直红点加载
        _loading.status = SNTripletsLoadingStatusNetworkNotReachable;
    }
}

///人人网账号登陆成功 百度账号登陆成功 淘宝账号登陆成功 腾讯微博登陆
-(void)notifyLoginSuccess
{
    SNUserinfoEx* info = [SNUserinfoEx userinfoEx];
    info.cookieName = kSetCookie;
    
    //3.5.1扩展cookie
    NSString* cookieValue = [SNUtility extractionCookie:FixedUrl_Oauth_Passport key:nil];
    if(cookieValue.length>0 && [info.cookieValue rangeOfString:cookieValue options:NSCaseInsensitiveSearch].location==NSNotFound)
    {
        if(info.cookieValue.length==0)
            info.cookieValue = cookieValue;
        else
            info.cookieValue = [NSString stringWithFormat:@"%@; %@", info.cookieValue, cookieValue];
    }
    
    [info saveUserinfoToUserDefault];
    
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_login_success", nil) toUrl:nil mode:SNCenterToastModeSuccess];
    [SNNotificationManager postNotificationName:kNewsCollectReportNotification object:nil];
    
    NSArray* array = (NSArray*)self.flipboardNavigationController.viewControllers;
    if(array!=nil && [array count]>=3)
    {
        NSObject* beforeLogin = nil;
        NSObject* obj = [array objectAtIndex:[array count]-2];
        if([array count]>=4)
            beforeLogin = [array objectAtIndex:[array count]-3];
        
        // 如果是阅读圈登陆的 这里需要特殊处理一下 by diao
        if([obj isKindOfClass:[SNLoginRegisterViewController class]] && [beforeLogin isKindOfClass:[SNTimelineLoginViewController class]]) //前一页是从登录注册页,但前前页是阅读圈登录页
        {
            [(SNTimelineLoginViewController *)beforeLogin notifyLoginSuccess];
            return;
        }
        // 如果是阅读圈登陆的 这里需要特殊处理一下 by jojo
        else if ([obj isKindOfClass:[SNTimelineLoginViewController class]])
        {
            [(SNTimelineLoginViewController *)obj notifyLoginSuccess];
            return;
        }
        else if([obj isKindOfClass:[SNLoginRegisterViewController class]]) //前一页是从登录注册页
        {
            SNLoginRegisterViewController* loginReg = (SNLoginRegisterViewController*)obj;
            
            id delegate = loginReg._delegate;
            id method = loginReg._method;
            id object = loginReg._object;
            
            if(delegate!=nil && method!=nil && [method isKindOfClass:[NSValue class]] && [delegate respondsToSelector:[method pointerValue]])
            {
                [delegate performSelector:[method pointerValue] withObject:object afterDelay:0.8f];
                return;
            }
        }
    }
    
    //处理登录操作
    if ([SNActionSheetLoginManager sharedInstance].logining) {
        [[SNActionSheetLoginManager sharedInstance] notifyLoginSuccess];
        return;
    }

    //特殊处理百度
    if([@"baidu" isEqualToString:_domain])
    {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
    }
}

-(void)notifyLoginFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [SNActionSheetLoginManager sharedInstance].logining = NO;
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
}

-(void)notifyLoginRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyLoginRequeestFailure");
    [SNActionSheetLoginManager sharedInstance].logining = NO;
    [SNNotificationCenter hideLoading];
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", nil) toUrl:nil mode:SNCenterToastModeError];
}
@end
