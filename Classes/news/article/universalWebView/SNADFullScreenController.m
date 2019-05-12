//
//  SNADFullScreenController.m
//  sohunews
//
//  Created by qz on 2017/2/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNADFullScreenController.h"

@implementation SNADFullScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;

    if ([self canOpenThirdPartyApp:urlString]) {
        self.isWebviewLoad = NO;
        return NO;
    }
    
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
    
    if ([self canOpenThirdPartyApp:urlString]) {
        self.isWebviewLoad = NO;
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([SNUtility changeSohuLinkToProtocol:urlString]) {
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}


#pragma mark iOS9 WKUIDelegate

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        //@qz 如果navigationAction.request返回为nil 就还是可能出现在wk上面点击标签不响应的情况 但是我现在还没遇到这样的页面
        // 可能是html中有_blank标签，但是这样改必须二次点击才有响应。
        //    if (!navigationAction.targetFrame.isMainFrame) { //http://www.soku.com/m/y/video?q=%E9%98%BF%E5%87%A1%E8%BE%BE%20%E7%89%87%E6%AE%B5#loaded
        //        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:^(id object, NSError * error){
        //            decisionHandler(WKNavigationActionPolicyAllow);
        //        }];
        //    }
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusHidden;
}

//-(UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleDefault;
//}

@end
