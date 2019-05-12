//
//  UIWebView+Utility.h
//  sohunews
//
//  Created by jojo on 14-3-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (UIWebViewScrollToTopAdditions)

- (void)setScrollsToTop:(BOOL)scrollsToTop;

@end

@interface UIWebView (progressObserve)

- (void)startObserveProgress;
- (void)stopObserveProgress;
- (void)h5StartObserveProgress:(CGFloat)progress;

@end
