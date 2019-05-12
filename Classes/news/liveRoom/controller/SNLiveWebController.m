//
//  SNLiveWebController.m
//  sohunews
//
//  Created by chenhong on 14-5-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNLiveWebController.h"

#define kErrorViewTag     (1001)

@interface SNLiveWebController () {
    UIButton *_errorView;
    BOOL _bRefreshInSilence;
}

@end

@implementation SNLiveWebController


- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:TTNavigationFrame()];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self updateBackgroundColor];
	
	//init web view
	_isFullScreen = NO;
    
	[self addWebView];
    
    [self resetEmptyHTML];
    
    //[self addLoadingView];
    
    _dragView.hidden = NO;
}

- (void)addWebView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _webView.delegate = self;
    _webScrollView = _webView.scrollView;
    _webScrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
    _webScrollView.delegate = self;
    _webScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    _webView.opaque = NO;//make system draw the logo below transparent webview
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    
    [self hideGradientBackground:_webView];
    
    [_webView startObserveProgress];
    
    _dragView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0, -_webView.height, _webView.width, _webView.height)];
    //_dragView.hidden = YES;
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    [_webScrollView addSubview:_dragView];
    
    [self.view addSubview:_webView];
}

- (UIScrollView *)scrollView {
    return _webScrollView;
}

- (void)addLoadingView {
     //(_loading);
	_loading = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, 0, 320, TTScreenBounds().size.height)];
    _loading.delegate = self;
    _loading.status = SNTripletsLoadingStatusStopped;
	[self.view addSubview:_loading];
}

# pragma mark - 网络错误界面
- (void)showError:(BOOL)show {
	if (show) {
        UIView *errorView = [_webScrollView viewWithTag:kErrorViewTag];
        if (errorView) {
            [errorView removeFromSuperview];
        }
        
        errorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tb_error_bg.png"]];
        errorView.clipsToBounds = YES;
        errorView.contentMode = UIViewContentModeCenter;
        errorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        errorView.center = CGPointMake(_webScrollView.width/2, _webScrollView.height/2);
        errorView.tag = kErrorViewTag;
        [_webScrollView addSubview:errorView];
        
	} else {
		UIView *errorView = [_webScrollView viewWithTag:kErrorViewTag];
		if (errorView) {
            [errorView removeFromSuperview];
        }
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
	if (scrollView.contentOffset.y <= kWebViewRefreshDeltaY && !_isLoading) {
        [self refreshAction];
	}
}

- (void)dragViewStartLoad {
    if (_dragView.hidden) {
        return;
    }
    
    [_dragView setStatus:TTTableHeaderDragRefreshLoading];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
    _webScrollView.contentInset = UIEdgeInsetsMake(kWebViewHeaderVisibleHeight, 0.0f, kToolbarViewHeight, 0.0f);
    _webScrollView.contentOffset = CGPointMake(0, -kWebViewHeaderVisibleHeight);
    [UIView commitAnimations];
    
    [_dragView setUpdateDate:[NSDate date]];
}

- (void)dragViewFinishLoad {
    if (_dragView.hidden) {
        return;
    }
    
    // drag view
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    _webScrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
    if (_webScrollView.contentOffset.y < 0) {
        _webScrollView.contentOffset = CGPointZero;
    }
    [UIView commitAnimations];
    
    [_dragView setCurrentDate];
}

- (void)dragViewFailLoad {
    if (_dragView.hidden) {
        return;
    }
    
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    _webScrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, kToolbarViewHeight, 0.f);
    if (_webScrollView.contentOffset.y < 0) {
        _webScrollView.contentOffset = CGPointZero;
    }
    [UIView commitAnimations];
}

#pragma mark webView delegate
- (void)webViewDidFinishLoad:(UIWebView*)webView {
	_isLoading = NO;
    _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
    [self dragViewFinishLoad];
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
	_isLoading = YES;
    if (!_bRefreshInSilence) {
        [self dragViewStartLoad];
    }
    _bRefreshInSilence = NO;
    [self showError:NO];
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
    _isLoading = NO;
    [self dragViewFailLoad];
    [self resetEmptyHTML];
    [self showError:YES];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [self resetEmptyHTML];
        [self showError:YES];
        return NO;
    }
    
	BOOL shouldStart = YES;
    
	NSString *reqUrlStr = [request.URL absoluteString];
    SNDebugLog(@"%@", [request.URL scheme]);
    
    SNDebugLog(@"SNWebController shouldStartLoadWithRequest %@", reqUrlStr);
    
    if ([SNAPI isItunes:reqUrlStr] || [reqUrlStr containsString:@"sohuExternalLink=1"]) {
        
        [self hideInitProgress];
        
        [self backAction];
        
        [[UIApplication sharedApplication] openURL:request.URL];
        _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
        return NO;
    }
    
    //搜狐域以外的其他域名不做url修改和拼接
    BOOL isSohuNewsDomain = [SNUtility isSohuDomain:reqUrlStr];
    
	if ([reqUrlStr hasPrefix:kProtocolHTTP])
    {
		//Google AD filter
		if ([reqUrlStr containsString:@"googleads"] ||
			[reqUrlStr containsString:@"doubleclick"]) {
			return NO;
		}
		
        if (isSohuNewsDomain) {
            BOOL isChangedUrl = NO;
            if (![reqUrlStr containsString:@"u="]) {
                if (![reqUrlStr containsString:@"?"]) {
                    reqUrlStr = [reqUrlStr stringByAppendingFormat:@"?u=%@", [SNAPI productId]];
                }
                else {
                    reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&u=%@", [SNAPI productId]];
                }
                isChangedUrl = YES;
                SNDebugLog(@"add chanpin ID----%@", reqUrlStr);
            }
            
            if (![reqUrlStr containsString:@"p1="]) {
                if (!_encodeUid) {
                    NSString *savedUid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
                    self.encodeUid = [[savedUid dataUsingEncoding:NSUTF8StringEncoding] base64String];
                }
                NSString *p1Str = [_encodeUid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (![reqUrlStr containsString:@"?"]) {
                    reqUrlStr = [reqUrlStr stringByAppendingFormat:@"?p1=%@", p1Str];
                }
                else {
                    reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&p1=%@", p1Str];
                }
                isChangedUrl = YES;
                SNDebugLog(@"add p1----%@", reqUrlStr);
            }
            
            if (isChangedUrl) {
                SNDebugLog(@"add parameter complete, request final url again----%@", reqUrlStr);
                
                if ([reqUrlStr containsString:self.originalUrl]) {
                    NSMutableURLRequest *newRequest = [request mutableCopy];
                    newRequest.timeoutInterval = 10;
                    [newRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];//减少内存占用
                    newRequest.URL = [NSURL URLWithString:reqUrlStr];
                    [self appendCookieToRequeset:newRequest url:newRequest.URL];
                    [_webView loadRequest:newRequest];
                    
                } else {
                    if ([SNUtility openProtocolUrl:reqUrlStr]) {
                        return NO;
                    }
                }
                
                shouldStart = NO;
            } else {
                SNDebugLog(@"can request url----%@", reqUrlStr);
            }
        } else {
            if ([SNUtility openProtocolUrl:reqUrlStr]) {
                return NO;
            }
        }
	}
    else if ([reqUrlStr hasPrefix:kBrowserShareContent]) {
        // h5页面内调用客户端分享
        NSDictionary *dic = [SNUtility parseURLParam:reqUrlStr schema:kBrowserShareContent];
        NSString *content = [dic stringValueForKey:@"content" defaultValue:@""];
        content = [content URLDecodedString];
        NSString *link = [dic stringValueForKey:@"link" defaultValue:nil];
        link = [link URLDecodedString];
        NSString *title = [dic stringValueForKey:@"title" defaultValue:nil];
        title = [title URLDecodedString];
        [self shareH5Content:content link:link title:title];
        return NO;
    }
    else if([reqUrlStr hasPrefix:kShareProtocal])
    {
        NSDictionary* dic = [SNUtility parseURLParam:reqUrlStr schema:kShareProtocal];
        NSString* link = [dic objectForKey:@"link"];
        if(link)
            link = [link URLDecodedString];
        NSString* pics = [dic objectForKey:@"pics"];
        if(pics)
            pics = [pics URLDecodedString];
        NSString* title = [dic objectForKey:@"title"];
        if(title)
            title = [title URLDecodedString];
        NSString* content = [dic objectForKey:@"content"];
        if(content)
            content = [content URLDecodedString];
        [self shareWithTitle:title content:content link:link imageUrl:pics];
        return NO;
    }
    else if (![reqUrlStr hasPrefix:kProtocolHTTP] && ![reqUrlStr hasPrefix:kProtocolFILE] && ![reqUrlStr hasPrefix:kProtocolHTTPS]) {
        if ([SNUtility isWhiteListURL:request.URL]) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
        else if ([SNUtility isProtocolV2:reqUrlStr] && [SNUtility openProtocolUrl:reqUrlStr]) {
            return NO;
        }
    }
    
    if (shouldStart) {
        [self showInitProgress];
        
        if (![[request.URL absoluteString] isEqualToString:@"about:blank"]) {
            self.url = request.URL;
        }
    }
    
	return shouldStart;
}

- (void)refreshAction {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        return;
    }
    _webView.scalesPageToFit = YES;
    if (_webView.request != nil) {
        [_webView reload];
    } else {
        NSString *urlWithP1 = [SNUtility addParamP1ToURL:self.originalUrl];
        [self openURL:[NSURL URLWithString:urlWithP1]];
    }
    
    [self showError:NO];
}

- (void)refreshInSilence {
}

- (void)openWithUrl:(NSString *)url {
    UIView *errorView = [_webScrollView viewWithTag:kErrorViewTag];
    if (![_originalUrl isEqualToString:url] || errorView) {
        self.originalUrl = url;
        NSString *urlWithP1 = [SNUtility addParamP1ToURL:url];
        [self openURL:[NSURL URLWithString:urlWithP1]];
    }
}

- (void)openRequest:(NSMutableURLRequest*)request {
    request.timeoutInterval = 10;
    [super openRequest:request];
}

- (void)handleProgress:(CGFloat)progress {
    SNDebugLog(@"progress: %f", progress);
}

@end
