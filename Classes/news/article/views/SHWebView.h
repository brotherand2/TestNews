//
//  SHWebView.h
//  sohunews
//
//  Created by 赵青 on 16/1/12.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JsKitFramework/JsKitFramework.h>
@protocol SHWebViewShareDelegate;

typedef void (^JsKitClientCallbackBlock)(JsKitClient *client,id data,NSString *key);

@interface SHWebView : UIWebView {
    UISwipeGestureRecognizer *swipeGestureRecognizer;
}

@property (weak, nonatomic) id<UIWebViewDelegate> jsDelegate;
@property (nonatomic, strong) JsKitClient *jsKit;

@property (weak, nonatomic) id <SHWebViewShareDelegate> shareDelegate;

- (void)registerJavascriptInterface:(id)target
                            forName:(NSString *)name;
- (id)callJavaScript:(NSString *)jsString
              forKey:(NSString *)key
            callBack:(JsKitClientCallbackBlock)callBack;
- (id)callJavaScriptFunction:(NSString *)jsString
                      forKey:(NSString *)key
                    callBack:(JsKitClientCallbackBlock)callBack;
- (void)removeCallBackBlockForKey:(NSString *)key;

@end


@protocol SHWebViewShareDelegate <NSObject>

- (void)shareClick:(id)sender;

@end
