//
//  SNWKWebView.h
//  sohunews
//
//  Created by qz on 07/06/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <JsKitFramework/JsKitFramework.h>
@protocol WKWebViewShareDelegate;

typedef void (^JsKitClientCallbackInWkWeb)(JsKitClient *client,id data,NSString *key);

@interface SNWKWebView : WKWebView

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (weak, nonatomic) id<WKNavigationDelegate> jsDelegate;
@property (nonatomic, strong) JsKitClient *jsClient;
@property (weak, nonatomic) id <WKWebViewShareDelegate> shareDelegate;


- (void)registerJavascriptInterface:(id)target forName:(NSString *)name;
- (id)callJavaScript:(NSString *)jsString forKey:(NSString *)key callBack:(JsKitClientCallbackInWkWeb)callBack;
- (id)callJavaScriptFunction:(NSString *)jsString forKey:(NSString *)key callBack:(JsKitClientCallbackInWkWeb)callBack;
- (void)removeCallBackBlockForKey:(NSString *)key;

@end


@protocol WKWebViewShareDelegate <NSObject>
- (void)shareClick:(id)sender;
@end
