//
//  SNLiveMoreViewController.m
//  sohunews
//
//  Created by tt on 15/7/6.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNLiveMoreViewController.h"
//#import "Masonry.h"
#import "SNThemeManager.h"
#import "SNSkinManager.h"
#import "SHUrlMaping.h"
#import "SHWebView.h"
#import "SHH5LiveMoreApi.h"

@interface SNLiveMoreViewController ()<UIWebViewDelegate> {
    SHWebView *_webView;
}

@property (copy, nonatomic) NSString *liveTitle;
@property (copy, nonatomic) NSString *liveType;

@end


@implementation SNLiveMoreViewController

#pragma mark 生命周期
- (instancetype)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        _liveTitle = [query[@"name"] copy];
        _liveType = [[query[@"blockType"] stringValue] copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)updateTheme:(NSNotification *)notifiction {
    [super updateTheme:notifiction];
    // 日夜间切换
    [self updateDayAndNightColor];
}

- (void)updateDayAndNightColor {
    _webView.backgroundColor = [SNSkinManager color:SkinBg3];
}

- (void)dealloc {
    _webView.jsDelegate = nil;
}

#pragma mark 私有
- (NSString *)modeUrlString {
    return [NSString stringWithFormat:@"?mode=%@&blockType=%@",@([[SNThemeManager sharedThemeManager] isNightTheme]).stringValue,_liveType];
}

- (void)setupView {
    if (!_webView) {
        _webView = [SHWebView new];
        [self.view addSubview:_webView];
        [_webView setJsDelegate:self];
        SHH5LiveMoreApi *jsChannelModel = [[SHH5LiveMoreApi alloc] init];
        [_webView registerJavascriptInterface:jsChannelModel forName:@"liveMoreApi"];
    }
    
    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _webView.scrollView.contentInset = UIEdgeInsetsMake(44.0, 0.f, kToolbarHeight, 0.f);
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            _webView.scrollView.contentInset = UIEdgeInsetsMake(44.0+24, 0.f, [SNToolbar toolbarHeight]-30, 0.f);
        }
    }
    _webView.scrollView.scrollIndicatorInsets = _webView.scrollView.contentInset;
    _webView.opaque = NO;
    _webView.frame = self.view.bounds;
    
    [self addHeaderView];
    [self addToolbar];
    [_headerView setSections:@[_liveTitle]];
    CGSize titleSize = [_liveTitle sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, _headerView.height - 2, titleSize.width+6, 2)];
    
    [self updateDayAndNightColor];
}

- (void)loadData {
    NSString *urlString = [[SHUrlMaping getLocalPathWithKey:SH_JSURL_LIVE_MORE] stringByAppendingFormat:@"%@", [self modeUrlString]];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = request.URL.absoluteString;
    if ([url hasPrefix:@"js:"]) {
        url = [url substringFromIndex:3];
    }
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        BOOL result = [SNUtility openProtocolUrl:url context:nil];
        return !result;
    }else if ([url hasPrefix:@"live://"]){
        BOOL result = [SNUtility openProtocolUrl:url context:nil];
        return !result;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

@end
