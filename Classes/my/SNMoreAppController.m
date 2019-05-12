//
//  SNMoreAppController.m
//  sohunews
//
//  Created by wangxiang on 3/31/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNMoreAppController.h"
#import "SNToolbar.h"
#import "SNHeadSelectView.h"
#import "NSDictionaryExtend.h"

#define kIndicatorSize 20

#define TITLE_KEY @"title"
#define URL_KEY @"url"

@interface SNMoreAppController () {
    NSDictionary *_userInfo;
}

@property(nonatomic, copy) NSString *urlStr;

@end

@implementation SNMoreAppController
@synthesize isFristURL;
@synthesize urlStr = _urlStr;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.hidesBottomBarWhenPushed = YES;
        _userInfo = query;
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return more_app;
}

- (void)dealloc {
     //(_userInfo);
     //(_urlStr)
}

- (void)addHeaderView {
    CGRect screenFrame = TTApplicationFrame();
    NSString *title = [_userInfo stringValueForKey:TITLE_KEY defaultValue:NSLocalizedString(@"SohuNews", @"")];
    SNHeadSelectView *headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, screenFrame.size.width, kHeaderTotalHeight)];
    [headerView setSections:[NSArray arrayWithObject:title]];
    [self.view addSubview:headerView];
}

- (void)addToolbar {
    CGRect screenFrame = TTApplicationFrame();
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    SNToolbar *toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, screenFrame.size.height - bg.size.height, screenFrame.size.width, bg.size.height)];
    [toolbarView setBackgroundColor:[UIColor clearColor]];
    [toolbarView setBackgroundImage:bg];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage imageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView setLeftButton:leftButton];
    
    [self.view addSubview:toolbarView];
}

- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)loadView
{
	[super loadView];
    [self.toolbar  removeFromSuperview];
    [self.progress removeFromSuperview];
    
    self.webView.frame = TTApplicationFrame();//CGRectMake(0,0,320,480);
    self.isFristURL = YES;
    
    if (_userInfo) {
        [self openWebPage];
        
        [self addHeaderView];
        [self addToolbar];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.webView.frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth, kAppScreenHeight - kHeadSelectViewBottom - kToolbarViewTop);
    
    if ([[_webView subviews] count] > 0) {
        UIScrollView *scrollView = _webView.scrollView;
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                scrollView.contentInset = UIEdgeInsetsMake(kHeadSelectViewHeight, 0.f, kToolbarViewHeight, 0.f);
                //scrollView.contentOffset = CGPointMake(0.f, -kHeadSelectViewHeight);
                scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kHeaderTotalHeight, 0, kToolbarViewHeight, 0);
            } else {
                scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kHeaderTotalHeight - kHeadSelectViewBottom, 0, 0, 0);
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)loadUrl:(NSString *)urlStr {
    
//    [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
    if (_webView.isLoading) {
        return;
    }
    
    self.urlStr = urlStr;
    if (urlStr.length > 0) {
        urlStr = [SNUtility addParamP1ToURL:urlStr];
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        [self openURL:url];
         //(url);
    }
}

- (void)openWebPage
{
    if (self.urlStr) {
        self.urlStr = [SNUtility addParamP1ToURL:self.urlStr];
        NSURL *url = [[NSURL alloc] initWithString:self.urlStr];
        [self openURL:url];
         //(url);
    }
    else {
        NSString *urlStr = [_userInfo stringValueForKey:URL_KEY defaultValue:@""];
        urlStr = [SNUtility addParamP1ToURL:urlStr];
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        [self openURL:url];
         //(url);
    }
}

- (void)handleProgress:(CGFloat)progress
{
    if (progress > 0) {
        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
        } else {
            _loading.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
        }
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType 
{
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        _loading.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
        return NO;
    }
    
    if (!isFristURL) 
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
         return NO;
    }
    //打开appstore后回来时需要重新打开页面
    else if (_loading.status != SNTripletsLoadingStatusLoading && isFristURL)
    {
         [self openWebPage];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _loading.status = SNEmbededActivityIndicatorStatusStartLoading;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error 
{
    SNDebugLog(@"SNMoreAppController didFailLoadWithError-%@", [error description]);
    //101 is WebKitErrorCannotShowURL, ignore this error while redirect to 3rd-party webpage
    if (101 == error.code) {
        return;
    }
    
    _loading.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
}

- (void )webViewDidFinishLoad:(UIWebView *)webView 
{
    _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
    self.isFristURL = NO;
}

@end

