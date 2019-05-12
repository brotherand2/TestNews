//
//  SNSubscribeWebController.h
//  sohunews
//
//  Created by ZhaoQing on 15/7/10.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "Three20UI.h"
#import "SmsSupport.h"
#import "SNTripletsLoadingView.h"
#import "UIWebView+Utility.h"
#import "SNWebUrlView.h"
#import "SNProgressBar.h"

@class SNToolbar;
@interface SNSubscribeWebController : TTModelViewController
<UIWebViewDelegate, UIScrollViewDelegate, SNTripletsLoadingViewDelegate> {
    UILabel *_titleView;
    BOOL _isLoading;
    
    UIButton *_stopBtn;
    UIButton *_back;
    UIButton *_closeButton;
    
    BOOL isResettingHTML;
    NSString *_emptyHtmlPath;
    BOOL _isPushed;
    
    UIScrollView *_webScrollView;
    BOOL _firstLoaded;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) SNToolbar *toolbar;
@property (nonatomic, strong) SNProgressBar *progress;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) SNTripletsLoadingView *loading;
@property (nonatomic, copy) NSString *webUrl;
@property (nonatomic, strong) NSDictionary *query;

@end
