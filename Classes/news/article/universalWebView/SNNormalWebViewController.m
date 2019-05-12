//
//  SNNormalWebViewController.m
//  sohunews
//
//  Created by yangln on 2016/12/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNormalWebViewController.h"
#import "SNOptimizedReadRequest.h"


@interface SNNormalWebViewController ()

@property (nonatomic, strong) UIButton *optimizeReadBtn;//优化阅读
@property (nonatomic, strong) NSString *optimizeReadURL;
@property (nonatomic, assign) BOOL clickOptimizeButton;
@property (nonatomic, assign) BOOL backOptimize;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@end

@implementation SNNormalWebViewController

- (void)loadView {
    [super loadView];
    if (self.webViewType == NormalWebViewType) {
        [self judgeOptimizeRead:self.newsOriginLink];
    }
    
    if (self.landscape) {
        [self rotateForLandscape];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark process webview
- (void)webViewGoBack {
    [super webViewGoBack];
    self.backOptimize = YES;
}

- (void)webViewGoBackInToolBar {
    [super webViewGoBackInToolBar];
    self.backOptimize = YES;
}

#pragma mark webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    SNDebugLog(@"load normal webView URL:%@", urlString);
    
    if ([urlString isEqualToString:@"about:blank"]) {
        self.isWebviewLoad = NO;
        return YES;
    }
    
    if ([urlString containsString:@"ad/view.go"]) {
        return YES;
    }
    
    if ([urlString containsString:@".pdf"]) {
        self.forceBack = YES;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        self.newsLink = urlString;
    }
    
    if (self.isRedirect && ![SNUtility isProtocolV2:urlString] && ![SNAPI isItunes:urlString]) {
        if ([urlString containsString:@"home"] && [urlString containsString:@"mp.sohu.com"]) {
            self.isMPHomeLink = YES;
        }
        else {
            self.isMPHomeLink = NO;
        }
        self.isWebviewLoad = YES;
        return YES;
    }
    else {
        //暂时这么处理，下个版本由SNS使用native实现
        if ([urlString containsString:@"mp.sohu.com"] && [urlString containsString:@"#/home"]) {
            self.isMPHomeLink = YES;
        }
        else {
            self.isMPHomeLink = NO;
        }
    }
    
    //处理正文页、搜索页iOS8点击问题
    if ([urlString hasPrefix:@"js:"] && urlString.length > 3) {
        urlString = [urlString substringFromIndex:3];
    }
    
    //端内打开第三方APP
    if ([self canOpenThirdPartyApp:urlString]) {
        self.isWebviewLoad = YES;
        return NO;
    }
    
    //处理二代协议
    if ([SNUtility isProtocolV2:urlString]) {
        if ([urlString hasPrefix:@"mttbrowser://"]) {
            return NO;
        }
        self.isWebviewLoad = [self processProtocolV2:urlString navigationType:navigationType];
        return self.isWebviewLoad;
    }
    
    //处理特殊域名，转化为二代协议
    if ([SNUtility changeSohuLinkToProtocol:urlString]) {
        self.isWebviewLoad = [self processSpecialDomain:urlString navigationType:navigationType];
        return self.isWebviewLoad;
    }
    
    //搜狐域内种cookie
    if ([self needAddCookieForUrlString:urlString request:request]) {
        self.isWebviewLoad = NO;
        return NO;
    }
    
    //优化阅读
    if ((self.optimizeReadBtn.tag == kAddedTag && (navigationType == UIWebViewNavigationTypeLinkClicked)) || self.backOptimize) {
        [self judgeOptimizeRead:urlString];
    }
    
    if (self.clickOptimizeButton) {
        [self doOptimizedRead:request urlString:urlString];
    }
    
    self.isWebviewLoad = YES;
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
}

#pragma mark update title
- (void)updateTitle {
    NSString *title = [self.universalWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.newsTitle = title;
    if (title.length == 0) {
        self.newsTitle = kUniversalTitle;
        
    }
    self.titleLabel.text = self.newsTitle;
    
    if (self.optimizeReadBtn.tag == kUnAddedTag && self.backOptimize) {
        [self webViewGoBack];
        self.backOptimize = NO;
    }
}

#pragma mark optimize read
- (void)judgeOptimizeRead:(NSString *)newsURLString {
    newsURLString = [newsURLString stringByAppendingString:@"&ReqMode=content"];
    NSDictionary *param = [NSDictionary dictionaryWithObject:newsURLString forKey:@"url"];
    [[[SNOptimizedReadRequest alloc] initWithDictionary:param] send:^(SNBaseRequest *request, id responseObject) {
        UIImage *icon = [UIImage imageNamed:@"icotitlebar_sohu_v5.png"];
        if ([[responseObject objectForKey:kStatus] isEqualToString:@"success"]) {
            [self optimizeReadButton];
            [self initPopoverView];
            
            self.titleLabel.size = CGSizeMake(kAppScreenWidth - icon.size.width - 70.0, self.naviBarImageView.height - kSystemBarHeight);
        }
        else {
            self.optimizeReadBtn.hidden = YES;
            self.titleLabel.size = CGSizeMake(kAppScreenWidth - icon.size.width - 42.0, self.naviBarImageView.height - kSystemBarHeight);
        }
    } failure:nil];
}

- (BOOL)doOptimizedRead:(NSURLRequest *)request urlString:(NSString *)urlString {
    self.clickOptimizeButton = NO;
    self.backOptimize = NO;
    NSMutableURLRequest *optimizeRequest = [request mutableCopy];
    optimizeRequest.timeoutInterval = WEBVIEW_REQUEST_TIMEOUT;
    [optimizeRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];//减少内存占用
    if (self.optimizeReadBtn.tag == kUnAddedTag) {
        optimizeRequest.URL = [NSURL URLWithString:[NSString stringWithFormat:kShowOptimizedReadURL, [urlString URLEncodedString]]];
    }
    else {
        optimizeRequest.URL = [NSURL URLWithString:urlString];
    }
    
    [self.universalWebView loadRequest:optimizeRequest];
    self.isRedirect = YES;
    return NO;
}

- (void)optimizeReadButton {
    if (!self.optimizeReadBtn) {
        UIImage *image = [UIImage imageNamed:@"icowebview_read.png"];
        self.optimizeReadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.optimizeReadBtn.backgroundColor = [UIColor clearColor];
        self.optimizeReadBtn.frame = CGRectMake(0, kSystemBarHeight + (kHeaderHeight - image.size.width)/2, image.size.width, image.size.height);
        self.optimizeReadBtn.right = kAppScreenWidth - 14.0;
        self.optimizeReadBtn.tag = kAddedTag;
        [self.optimizeReadBtn setImage:image forState:UIControlStateNormal];
        [self.optimizeReadBtn addTarget:self action:@selector(optimizeReadAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.naviBarImageView addSubview:self.optimizeReadBtn];
    }
    else {
        self.optimizeReadBtn.hidden = NO;
    }
}

- (void)optimizeReadAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *imageName = nil;
    NSInteger buttonTag = 0;
    if (button.tag == kAddedTag) {//优化阅读
        self.clickOptimizeButton = YES;
        buttonTag = kUnAddedTag;
        imageName = @"icowebview_readRecover.png";
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=wvread&_tp=on&channelid=%@&newsid=", self.channelId]];
        [self.universalWebView reload];
        
        //add pinch gesture
        [self addPinchGesture:YES];
    }
    else {//恢复优化阅读前的状态
        self.clickOptimizeButton = NO;
        buttonTag = kAddedTag;
        imageName = @"icowebview_read.png";
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=wvread&_tp=off&channelid=%@&newsid=", self.channelId]];
        [self.universalWebView goBack];
        [self addPinchGesture:NO];
    }
    button.tag = buttonTag;
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)addPinchGesture:(BOOL)isAdd {
    //双指缩放
    if (!self.pinchGesture) {
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleGesture:)];
        [self.view addGestureRecognizer:self.pinchGesture];
    }
    else {
        if (isAdd) {
            [self.view addGestureRecognizer:self.pinchGesture];
        }
        else {
            [self.view removeGestureRecognizer:self.pinchGesture];
        }
    }
}

- (void)scaleGesture:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.pinchScale > gesture.scale) {
            [SNUtility setSmallerFontSize];
        }
        else if (self.pinchScale < gesture.scale) {
            [SNUtility setBiggerFontSize];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateBegan) {
        self.pinchScale = gesture.scale;
    }
}

- (void)initPopoverView {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kFirstOpenUniversalWebView]) {
        [userDefaults setBool:YES forKey:kFirstOpenUniversalWebView];
        [userDefaults synchronize];
        CGPoint point = CGPointMake(kAppScreenWidth - 30.0, kSystemBarHeight + kWebUrlViewHeight);
        CGSize size = [SNDevice sharedInstance].isPlus ? CGSizeMake(1000.0/3 - 40, 182.0/3) : CGSizeMake(262.0, 105.0/2);
        self.popoverView = [[SNPopoverView alloc] initWithTitle:kOptimizeReadRemind Point:point size:size leftImageName:@"ico_homehand_v5.png"];
        [self.popoverView show];
    }
}

#pragma mark full screen
- (void)rotateForLandscape {
    [UIApplication sharedApplication].statusBarHidden = YES;
    [UIView animateWithDuration:0.5f animations:^{
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, M_PI/2);
        self.backgroundView.transform = transform;
        [self resetUIForLandscape];
        
    } completion:^(BOOL finished) {
    }];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (void)resetUIForLandscape {
    float width = self.view.frame.size.height + 10;
    self.backgroundView.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    self.universalWebView.frame = CGRectMake(0, 0, width, self.view.frame.size.width - kWebUrlViewHeight - kToolbarViewTop + kSystemBarHeight);
    self.toolBar.frame = CGRectMake(0, self.view.frame.size.width - kToolbarViewTop - kWebUrlViewHeight, width, kToolbarViewHeight);
    self.naviBarImageView.frame = CGRectMake(0, -kSystemBarHeight,width, kHeaderHeight + kSystemBarHeight);
    self.progressBar.frame = CGRectMake(0, self.naviBarImageView.bottom-2, width, 2);
    self.loadingView.frame = CGRectMake(0, 0, TTScreenBounds().size.height, TTScreenBounds().size.width);
    
    [self.loadingView layoutTriplets];
    [self.toolBar updateUIForRotate];
}

- (BOOL)prefersStatusBarHidden {
    return self.landscape;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [SNNotificationManager removeObserver:self];
}
@end
