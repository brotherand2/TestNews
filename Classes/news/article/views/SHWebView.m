//
//  SHWebView.m
//  sohunews
//
//  Created by 赵青 on 16/1/12.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHWebView.h"
#import "SNNotificationManager.h"
#import <objc/runtime.h>
#import "TTURLAction.h"
#import "TTNavigator.h"
#import "UIMenuController+Observe.h"

@interface SHWebView()<UIWebViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableDictionary *registClasses;
@end

@implementation SHWebView

typedef void (*CallFuc)(id, SEL, BOOL);
typedef BOOL (*GetFuc)(id, SEL);

- (BOOL)webView:(UIWebView *)view enableGL:(BOOL)bEnable {
    BOOL bRet = NO;
    do {
        Ivar internalVar = class_getInstanceVariable([view class], "_internal");
        if (!internalVar) {
            break;
        }
        
        UIWebViewInternal *internalObj = object_getIvar(view, internalVar);
        Ivar browserVar = class_getInstanceVariable(object_getClass(internalObj), "browserView");
        if (!browserVar) {
            break;
        }
        
        id webbrowser = object_getIvar(internalObj, browserVar);
        Ivar webViewVar = class_getInstanceVariable(object_getClass(webbrowser), "_webView");
        if (!webViewVar) {
            break;
        }
        
        id webView = (id)object_getIvar(webbrowser, webViewVar);
        if (!webView) {
        }
        
        if (object_getClass(webView) != NSClassFromString(@"WebView")) {
            break;
        }
        
        SEL selector = NSSelectorFromString(@"_setWebGLEnabled:");
        IMP impSet = [webView methodForSelector:selector];
        CallFuc func = (CallFuc)impSet;
        func(webView, selector, bEnable);
        
        SEL selectorGet = NSSelectorFromString(@"_webGLEnabled");
        IMP impGet = [webView methodForSelector:selectorGet];
        GetFuc funcGet = (GetFuc)impGet;
        BOOL val = funcGet(webView, selector);
        
        bRet = (val == bEnable);
    } while(NO);
    
    return bRet;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setInitData];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [(sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate] initH5Framework];
        [self setInitData];
    }
    
    return self;
}

- (void)setInitData
{
    self.backgroundColor = [UIColor clearColor];
    
    _registClasses = [NSMutableDictionary dictionary];
    [self resetMenuItems];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureOpenMenu:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    swipeGestureRecognizer.delegate = self;
    [self addGestureRecognizer:swipeGestureRecognizer];
    self.mediaPlaybackRequiresUserAction = NO;
    
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    //注册即将进入的前后台通知
    [SNNotificationManager addObserver:self selector:@selector(handleApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(handleApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

//即将进入的后台通知
- (void)handleApplicationWillResignActive:(NSNotification *)notification {
    [self webView:self enableGL:NO];
}

//即将进入的前台通知
- (void)handleApplicationWillEnterForegroundNotification:(NSNotification *)notification {
    [self webView:self enableGL:YES];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    NSArray *keys = [_registClasses allKeys];
    for (NSString *key in keys) {
        [_jsKit removeJavascriptInterface:key];
    }
    _jsKit = nil;
    
    if (swipeGestureRecognizer) {
        [self removeGestureRecognizer:swipeGestureRecognizer];
    }
    [self loadHTMLString:@"" baseURL:nil];
    [self stopLoading];
    self.delegate = nil;
    [self removeFromSuperview];
}

- (void)setJsDelegate:(id<UIWebViewDelegate>)jsDelegate {
    if(nil == _jsKit){
        self.jsKit = [[JsKitClient alloc] initWithWebView:self];
    }
    self.jsKit.delegate = self;
    _jsDelegate = jsDelegate;
}

- (void)registerJavascriptInterface:(id)target
                            forName:(NSString *)name {
    [_jsKit addJavascriptInterface:target forName:name];
    [_registClasses setValue:target forKey:name];
}

- (id)callJavaScript:(NSString *)jsString
              forKey:(NSString *)key
            callBack:(JsKitClientCallbackBlock)callBack {
    if (nil != key && nil != callBack) {
        [_jsKit.callbackBlockDic setValue:callBack forKey:key];
    }
    return [_jsKit evaluatingJavaScriptWithFormat:jsString];
}

- (id)callJavaScriptFunction:(NSString *)jsString
                      forKey:(NSString *)key
                    callBack:(JsKitClientCallbackBlock)callBack {
    if (nil != key && nil != callBack) {
        [_jsKit.callbackBlockDic setValue:callBack forKey:key];
    }
    return [_jsKit evaluatingJavaScriptFunction:jsString, [JKValue argEnd]];
}

- (void)removeCallBackBlockForKey:(NSString *)key {
    [_jsKit.callbackBlockDic removeObjectForKey:key];
}

#pragma mark - webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (nil != self.jsDelegate &&
        [self.jsDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.jsDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (nil != self.jsDelegate &&
        [self.jsDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.jsDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SNUserDefaults setInteger:0 forKey:kWebKitCacheModelPreferenceKey];
    [SNUserDefaults setBool:NO forKey:kWebKitDiskImageCacheEnabled];//自己添加的，原文没有提到。
    [SNUserDefaults setBool:NO forKey:kWebKitOfflineWebApplicationCacheEnabled];//自己添加的，原文没有提到。
    
    if (nil != self.jsDelegate &&
        [self.jsDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.jsDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (nil != self.jsDelegate &&
        [self.jsDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.jsDelegate webView:webView didFailLoadWithError:error];
    }
}

- (void)becomeActiveFunction {
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(searchText:) ||
        action == @selector(share:)) {
        return YES;
    }
    
    UIMenuController *menuController = sender;
    if ([menuController isKindOfClass:[UIMenuController class]] && [menuController respondsToSelector:@selector(getMenuControllerKey)]) {
        NSString *menuKey = [menuController getMenuControllerKey];
        if (menuKey.length > 0 && [menuKey isEqualToString:@"SNWebViewMenu"]) {
            return [super canPerformAction:action withSender:sender];
        } else {
            return NO;
        }
    }
    return NO;
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
    NSString *str = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    [content appendString:str];
    [content appendString:@"] 分享来自：@搜狐新闻客户端 %@ %@"];
    
    if (self.shareDelegate && [self.shareDelegate respondsToSelector:@selector(shareClick:)]) {
        [self.shareDelegate shareClick:content];
    } else {
        [SNNotificationManager postNotificationName:kShareAction object:content];
    }
}

- (void)searchText:(id)sender {
    NSString *searchText = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
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
