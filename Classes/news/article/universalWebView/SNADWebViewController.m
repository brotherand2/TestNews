//
//  SNADWebViewController.m
//  sohunews
//
//  Created by yangln on 2017/2/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNADWebViewController.h"
#import "SNWKWebView.h"

@implementation SNADWebViewController

- (void)loadView {
    [super loadView];
    //在 SNBaseWebViewController 设置的 self.landscape
    if (self.landscape) {
        [self rotateForLandscape];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    SNDebugLog(@"load ad webView URL:%@", urlString);
    //端内打开第三方APP
    if ([self canOpenThirdPartyApp:urlString]) {
        self.isWebviewLoad = YES;
        return NO;
    }
    
    //处理特殊域名，转化为二代协议
    if ([SNUtility changeSohuLinkToProtocol:urlString]) {
        self.isWebviewLoad = [self processSpecialDomain:urlString navigationType:navigationType];
        return self.isWebviewLoad;
    }
    
    self.isWebviewLoad = YES;
    return YES;
}

#pragma mark iOS9 WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *urlString = navigationAction.request.URL.absoluteString;
    
    //@qz wk 默认打不了电话 2017.10.21
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    UIApplication *app = [UIApplication sharedApplication];
    // 打电话
    if ([scheme isEqualToString:@"tel"]) {
        if ([app canOpenURL:URL]) {
            [app openURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
//    if ([url.absoluteString containsString:@"ituns.apple.com"]) {
//        if ([app canOpenURL:url]) {
//            [app openURL:url];
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
//    }
    
    if ([self canOpenThirdPartyApp:urlString]) {
        self.isWebviewLoad = YES;
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if ([SNUtility changeSohuLinkToProtocol:urlString]) {
        //eg. @"http://3g.k.sohu.com/t/n197316460"
        self.isWebviewLoad = [self processSpecialDomain:urlString WKNavigationType:navigationAction.navigationType];
        if (self.isWebviewLoad) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }else{
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        return;
    }
    
    self.isWebviewLoad = YES;
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark iOS9 WKUIDelegate

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (![navigationAction.targetFrame isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
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
    float width = self.view.frame.size.height + 10; //@qz 这里为什么要加10，不知道
    self.backgroundView.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);

    if (self.universalWKWebView) {
        CGFloat newWidth = (kAppScreenWidth > kAppScreenHeight) ? kAppScreenWidth : kAppScreenHeight;
        CGFloat newHeight = (newWidth == kAppScreenWidth) ? kAppScreenHeight : kAppScreenWidth;
        self.universalWKWebView.frame = CGRectMake(0, 44, newWidth, newHeight - 44 - kToolbarViewHeight);
    }else{
        self.universalWebView.frame = CGRectMake(0, 0, width, self.view.frame.size.width - kWebUrlViewHeight - kToolbarViewTop + kSystemBarHeight);
    }
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

@end
