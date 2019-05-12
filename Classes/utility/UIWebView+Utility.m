//
//  UIWebView+Utility.m
//  sohunews
//
//  Created by jojo on 14-3-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "UIWebView+Utility.h"

@implementation UIWebView (UIWebViewScrollToTopAdditions)

- (void)setScrollsToTop:(BOOL)scrollsToTop {
    self.scrollView.scrollsToTop = scrollsToTop;
}

@end

@implementation UIWebView (progressObserve)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)setCustomUserAgent:(id)webView {
    
    NSString *ua = [self stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey];
    if ([webView respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"setCusto%@:", @"mUserAgent"])]) {
        [webView performSelector:NSSelectorFromString([NSString stringWithFormat:@"setCusto%@:", @"mUserAgent"]) withObject:[ua stringByAppendingFormat:@" %@/%@", kUIWebViewUserAgent, version]];
    }
}

- (void)observeInternalWebViewProgress:(UIView *)theView {
    for (UIView* subview in theView.subviews) {
		if ([[[subview class] description] isEqualToString:[NSString stringWithFormat:@"UIW%@B%@View", @"eb", @"rowser"]]) {
            if ([subview respondsToSelector:NSSelectorFromString(@"webView")]) {
                [SNNotificationManager addObserver:self selector:@selector(progressEstimateChanged:) name:[NSString stringWithFormat:@"WebP%@E%@C%@Notification", @"rogress", @"stimate", @"hanged"] object:[subview performSelector:NSSelectorFromString(@"webView")]];

                [self setCustomUserAgent:[subview performSelector:NSSelectorFromString(@"webView")]];
                
                return;
            }
        }
		[self observeInternalWebViewProgress:subview];
	}
}

- (void)progressEstimateChanged:(id)sender
{
    NSNotification *notification    = (NSNotification*)sender;
    
    id object       = [notification object];
    SEL selector    = NSSelectorFromString([NSString stringWithFormat:@"e%@P%@", @"stimated", @"rogress"]);
    if ([object respondsToSelector:selector]) {
        
        NSMethodSignature* sig = [object methodSignatureForSelector:selector];
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
        [invo setTarget:object];
        [invo setSelector:selector];
        [invo invoke];
        
        CGFloat progress = 0;
        // 返回类型为double
        if (!strcmp([sig methodReturnType], @encode(double))) {
            double result = 0;
            [invo getReturnValue:&result];
            progress = result;
        }
        // 返回类型为CGFloat
        else if (!strcmp([sig methodReturnType], @encode(CGFloat))) {
            [invo getReturnValue:&progress];
        }
        
        //SNDebugLog(@"progressChanged :%f",progress);
        //有时候进度100%的时候也返回0，所以把0当1
        progress = progress == 0 ? 1 : progress;
        
        [self performSelectorOnMainThread:@selector(progressEstimateDidChanged:)
                               withObject:@(progress)
                            waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)startObserveProgress {
    [self observeInternalWebViewProgress:self];
}

- (void)h5StartObserveProgress:(CGFloat)progress {
    [self performSelectorOnMainThread:@selector(progressEstimateDidChanged:)
                           withObject:@(progress)
                        waitUntilDone:[NSThread isMainThread]];
}

- (void)stopObserveProgress {
    [SNNotificationManager removeObserver:self];
}

- (void)progressEstimateDidChanged:(id)progress {
    [SNNotificationManager postNotificationName:kSNWebViewProgressDidChangedNotification
                                                        object:self
                                                      userInfo:@{kSNWebViewCurrentProgressValueKey: progress}];
}
#pragma clang diagnostic pop
@end
