//
//  SNH5WebController.m
//  sohunews
//
//  Created by chenhong on 13-8-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNH5WebController.h"

#define kBrowserProtocolClose @"browser://action=close"

@interface SNH5WebController (){
    BOOL _isGoBackReq;//加一个back标识，fix 网页 back之后_currentHistoryIndex增加的bug   add by hz
    BOOL _isChangeTheme;
}

@end

@implementation SNH5WebController

@synthesize historyRequests = _historyRequests;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        _currentHistoryIndex = -1;
        _historyRequests = [[NSMutableArray alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [SNNotificationManager addObserver:self selector:@selector(handleWebViewProgressDidChange:) name:kSNWebViewProgressDidChangedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
#pragma clang diagnostic pop

    }
    return self;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
     //(_historyRequests);
     //(_failedRequest);
    
}


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {

    NSString *reqUrlStr = [request.URL absoluteString];
    if ([reqUrlStr hasPrefix:kBrowserProtocolClose]) {
        [self closeBrowser];
        return NO;
    }
    
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [self resetEmptyHTML];
        _loading.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
        _loading.frame = CGRectMake(0, -20, _webView.frame.size.width, _webView.frame.size.height);
        self.failedRequest = request;
        
//        return NO;
    }
    
    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)addWebView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                               kSystemBarHeight+kWebUrlViewHeight,
                                                               kAppScreenWidth,
                                                               kAppScreenHeight-kToolbarHeightWithoutShadow-kWebUrlViewHeight-kSystemBarHeight)];
        
        //lijian 2014.12.17 活动页要特殊处理隐藏地址栏
        if(nil != self.query){
            NSString *activeName = [self.query objectForKey:kActionType];
            if(nil != activeName && [activeName isEqualToString:kActionName_ActivePage]){
                _webView.frame = CGRectMake(0, kSystemBarHeight, _webView.frame.size.width, _webView.frame.size.height + kWebUrlViewHeight);
                //_webView.scrollView.scrollEnabled = NO;
                self.webUrlView.hidden = YES;
                self.webUrlView.frame = CGRectMake(0, -20, self.webUrlView.frame.size.width, self.webUrlView.frame.size.height);
            }
        }
        
        _webView.delegate = self;
        id viewObj = [[_webView subviews] objectAtIndex:0];
        if ([viewObj isKindOfClass:[UIScrollView class]]) {
            _webScrollView = viewObj;
        }
        _webScrollView.delegate = self;
        _webScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
        _webView.opaque = NO;//make system draw the logo below transparent webview
        //_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor clearColor];
        
        [self hideGradientBackground:_webView];
        
        [_webView startObserveProgress];
        
        _dragView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0, -_webView.height, _webView.width, _webView.height)];
        _dragView.hidden = YES;
        [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
        _dragView.refreshStartPosY = 65 + 61;
        [_webScrollView addSubview:_dragView];
    }
    [self.view addSubview:_webView];
}

// override: 防止网页中拍照后内存警告导致页面重建
- (void)cleanWebView {
    //nothing
}


- (void)backAction {
    if (![self canGoBack] || _isChangeTheme) {
        [self closeBrowser];
    } else if ([self canLeavePage]) {
        [self goBack];
    }
}


- (void)forwardAction {
    if ([self canLeavePage]) {
        [self goForward];
    }
}

- (NSMutableURLRequest *)currentRequest
{
    SNDebugLog(@"self.historyRequests %@", self.historyRequests);
    
    if (_currentHistoryIndex >= 0 && _currentHistoryIndex < self.historyRequests.count) {
        return self.historyRequests[_currentHistoryIndex];
    }
    return nil;
}

- (NSMutableURLRequest *)previousRequest
{
    SNDebugLog(@"self.historyRequests %@", self.historyRequests);
    
    if (_currentHistoryIndex > 0 && _currentHistoryIndex < self.historyRequests.count) {
        _currentHistoryIndex--;
        return self.historyRequests[_currentHistoryIndex];
    }
    return nil;
}

- (NSMutableURLRequest *)nextRequest
{
    SNDebugLog(@"self.historyRequests %@", self.historyRequests);
    
    if (_currentHistoryIndex >= 0 && _currentHistoryIndex < self.historyRequests.count - 1) {
        _currentHistoryIndex++;
        return self.historyRequests[_currentHistoryIndex];
    }
    return nil;
}

- (BOOL)canGoBack
{
    return [_webView canGoBack];
//    return _currentHistoryIndex > 0 &&  self.historyRequests.count > 0;
}

- (BOOL)canGoForward
{
    return self.historyRequests.count > 0 && _currentHistoryIndex < self.historyRequests.count - 1;
}

- (void)systemGoback{
    if (![_webView canGoBack]) {
        [self closeBrowser];
    }else{
//    [self closeBrowser];
        [self appendCookieToRequeset:[self previousRequest] url:_url];
        [_webView goBack];
    }
}

- (void)goBack
{
    _isNaviInHistory = YES;
    _isGoBackReq = YES;//加一个back标识，fix 网页 back之后_currentHistoryIndex增加的bug   add by hz
    if (self.historyRequests.count > 1) {
        [self systemGoback];//为解决某些网页授权登陆会无限循环跳转网页的bug（例如自媒体管理页qq第三方登陆），这里返回采用UIWebView的goback  add by hz
        return;
    }
    [self openRequest:[self previousRequest]];
}

- (void)goForward
{
    _isNaviInHistory = YES;
    [self openRequest:[self nextRequest]];
}

- (void)reload
{
    _isNaviInHistory = YES;
    [self openRequest:[self currentRequest]];
}

//- (void)moreAction
//{
//    SNSheetFloatView* sheet = [[SNSheetFloatView alloc] init];
//    [sheet addSheetItemWithTitle:@"用Safari打开" andBlock:^{
//        if ([SNUtility isWhiteListURL:[self currentRequest].URL]) {
//            [[UIApplication sharedApplication] openURL:[self currentRequest].URL];
//        }
//    }layOut:YES ];
//    [sheet addSheetItemWithTitle:@"复制链接" andBlock:^{
//        [[UIPasteboard generalPasteboard] setString:[[self currentRequest].URL absoluteString]];;
//    }layOut:YES ];
//    [sheet addSheetItemWithTitle:@"分享"  andBlock:^{
//        NSString *title = @"";
//        NSString *content = @"";
//        NSString *link = @"";
//        if (self.urlTitle.length > 0) {
//            title = [self.urlTitle URLDecodedString];
//        }
//        if (self.webUrl.length > 0) {
//            link = self.webUrl;
//        }
//        content = [NSString stringWithFormat:@"%@（%@）",title,link];
//        [self shareWithTitle:title content:content link:link imageUrl:nil];
//    }layOut:YES ];
//    [sheet show];
//}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if ([SNUtility isWhiteListURL:[self currentRequest].URL]) {
                [[UIApplication sharedApplication] openURL:[self currentRequest].URL];
            }
            break;
        case 1:
            [[UIPasteboard generalPasteboard] setString:[[self currentRequest].URL absoluteString]];
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

- (void)refreshAction {
    
    if ([self canRefreshBrowser]) {
        //统计
        if (![self isError]) {
            [self resetEmptyHTML];
        }
        [self showLoading];
        [self showInitProgress];
        [self reload];
    }
}


- (void)addRequestToHistory:(NSURLRequest *)request
{
//    NSURLRequest *lastRequest = [self.historyRequests lastObject];
//    if (request == lastRequest) {
//        return;///防止web自动刷新跳转造成无限循环  add by hz
//    }
    if ([self canGoForward]) {
        [self.historyRequests removeObjectsInRange:NSMakeRange(_currentHistoryIndex + 1, self.historyRequests.count - _currentHistoryIndex - 1)];
    }
    if (_isGoBackReq) {
        _isGoBackReq = NO;
        return;
    }
    [self.historyRequests addObject:request];
    _currentHistoryIndex++;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
	
    
    SNDebugLog(@"self.historyUrls %@", self.historyRequests);
    
    [super webViewDidFinishLoad:webView];
    
    _front.enabled = [self canGoForward];
    _isNaviInHistory = NO;
    if (!_isNaviInHistory) {
        [self addRequestToHistory:webView.request];
    }

}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
    self.failedRequest = webView.request;
    [super webView:webView didFailLoadWithError:error];
}

- (void)didTapRetry
{
    if (!_webView.isLoading && _failedRequest) {
        [_webView loadRequest:_failedRequest];
    }
}

- (void)updateTheme {
    _isChangeTheme = YES;
}

@end
