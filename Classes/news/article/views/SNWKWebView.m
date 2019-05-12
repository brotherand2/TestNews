//
//  SNWKWebView.m
//  sohunews
//
//  Created by qz on 07/06/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNWKWebView.h"
#import "SNNotificationManager.h"
#import <objc/runtime.h>
#import "TTURLAction.h"
#import "TTNavigator.h"
#import "UIMenuController+Observe.h"

@interface SNWKWebView ()<WKNavigationDelegate,WKUIDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableDictionary *registClassDic;
@end

@implementation SNWKWebView

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        [self setInitData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setInitData];
    }
    return self;
}

- (void)setInitData
{
    self.backgroundColor = [UIColor clearColor];
    self.registClassDic = [NSMutableDictionary dictionary];
    [self resetMenuItems];
    
    self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureOpenMenu:)];
    _swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    _swipeGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_swipeGestureRecognizer];
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

//    if (@available(iOS 11.0, *)) {
//        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
    //self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    //注册即将进入的前后台通知
    //[SNNotificationManager addObserver:self selector:@selector(handleApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    //[SNNotificationManager addObserver:self selector:@selector(handleApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"estimatedProgress"];
    [SNNotificationManager removeObserver:self];
    
    NSArray *keys = [_registClassDic allKeys];
    for (NSString *key in keys) {
        [_jsClient removeJavascriptInterface:key];
    }
    _jsClient = nil;
    
    if (_swipeGestureRecognizer) {
        [self removeGestureRecognizer:_swipeGestureRecognizer];
    }
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
}

//- (void)setJsDelegate:(id)jsDelegate {
////    if(!_jsClient){
////        self.jsClient = [[JsKitClient alloc] initWithWebView:self];
////    }
//    //_jsClient.wkNavDelegate = self;
//    //_jsClient.wkUIDelegate = self;
//    _jsDelegate = jsDelegate;
//}

- (void)registerJavascriptInterface:(id)target forName:(NSString *)name {
    [_jsClient addJavascriptInterface:target forName:name];
    [_registClassDic setValue:target forKey:name];
}

- (id)callJavaScript:(NSString *)jsString forKey:(NSString *)key callBack:(JsKitClientCallbackInWkWeb)callBack {
    if (nil != key && nil != callBack) {
        [_jsClient.callbackBlockDic setValue:callBack forKey:key];
    }
    return [_jsClient evaluatingJavaScriptWithFormat:jsString];
}

- (id)callJavaScriptFunction:(NSString *)jsString forKey:(NSString *)key callBack:(JsKitClientCallbackInWkWeb)callBack {
    if (nil != key && nil != callBack) {
        [_jsClient.callbackBlockDic setValue:callBack forKey:key];
    }
    return [_jsClient evaluatingJavaScriptFunction:jsString, [JKValue argEnd]];
}

- (void)removeCallBackBlockForKey:(NSString *)key {
    [_jsClient.callbackBlockDic removeObjectForKey:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self) {
            NSString *progress = [NSString stringWithFormat:@"%.2f",self.estimatedProgress];
            [SNNotificationManager postNotificationName:kSNWebViewProgressDidChangedNotification object:self userInfo:@{kSNWebViewCurrentProgressValueKey: progress}];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if(_jsDelegate){
        [_jsDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    if(_jsDelegate){
        [_jsDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (_jsDelegate) {
        [_jsDelegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    if(_jsDelegate){
        [_jsDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)becomeActiveFunction {
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = sender;
    NSString *menuKey = [menuController getMenuControllerKey];
    
    if (action == @selector(searchText:) ||
        action == @selector(share:)) {
        return YES;
    }
    
    if (menuKey.length > 0 && [menuKey isEqualToString:@"SNWebViewMenu"]) {
        return [super canPerformAction:action withSender:sender];
    } else {
        return NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)gestureOpenMenu:(UIGestureRecognizer *)tapGesture {
    [self becomeFirstResponder];
    [self resetMenuItems];
}

- (void)share:(id)sender {
    NSMutableString *content = [NSMutableString stringWithString:@"["];
    
    __block NSString *str = @"";
    
    [self evaluateJavaScript:@"window.getSelection().toString()" completionHandler:^ (id object, NSError * error){
        if ([object isKindOfClass:[NSString class]]) {
            str = (NSString *)object;
        }
    }];
    [content appendString:str];
    [content appendString:@"] 分享来自：@搜狐新闻客户端 %@ %@"];
    
    if (self.shareDelegate && [self.shareDelegate respondsToSelector:@selector(shareClick:)]) {
        [self.shareDelegate shareClick:content];
    } else {
        [SNNotificationManager postNotificationName:kShareAction object:content];
    }
}

- (void)searchText:(id)sender {
    __block NSString *searchText = @"";
    [self evaluateJavaScript:@"window.getSelection().toString()" completionHandler:^ (id object, NSError * error){
        if ([object isKindOfClass:[NSString class]]) {
            searchText = (NSString *)object;
        }
    }];
    
    if (searchText.length > 0) {
        NSDictionary *searchDic = [NSDictionary dictionaryWithObjectsAndKeys:searchText, @"searchText", nil];
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://articleSearch"] applyAnimated:YES] applyQuery:searchDic];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (void)resetMenuItems {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.menuVisible) {
        [menuController setMenuVisible:NO animated:YES];
        return;
    }
    
    [menuController setMenuControllerKeyWithString:@"SNWebViewMenu"];
    [menuController setMenuItems:nil];
    
    UIMenuItem *searchItem = [[UIMenuItem alloc] initWithTitle:@"搜索" action:@selector(searchText:)];
    UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(share:)];
    [menuController setMenuItems:[NSArray arrayWithObjects:searchItem,shareItem, nil]];
    [menuController update];
}

- (void)resetMenuItemsWithoutUpdate {
    [self resetMenuItems];
}

@end
