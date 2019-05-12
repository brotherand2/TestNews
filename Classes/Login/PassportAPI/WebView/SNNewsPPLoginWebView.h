//
//  SNNewsPPLoginWebView.h
//  sohunews
//
//  Created by wang shun on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SNNewsPPLoginWebViewDelegate;
@interface SNNewsPPLoginWebView : NSObject

@property (nonatomic,strong) id <SNNewsPPLoginWebViewDelegate> delegate;

@property (nonatomic,strong) UIWebView* webView;

- (void)loadJSWeb:(NSString*)data;
- (void)getJSEvalCode;

- (NSString*)getUA;
- (void)loadPPJV;

@end

@protocol SNNewsPPLoginWebViewDelegate <NSObject>

- (void)getPPJV:(NSString*)ppjv;

- (void)loadFailed:(id)sender;

@end
