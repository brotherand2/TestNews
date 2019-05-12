//
//  SNURLRequest.m
//  sohunews
//
//  Created by kuanxi zhu on 8/9/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#define SN_DEFAULT_CACHE_EXPIRATION_AGE				(60)//60sec
#import "SNURLRequest.h"
#import "SNClientRegister.h"
#import "SNUserManager.h"

@interface SNURLRequest ()
@property(nonatomic, copy) SNURLRequestSuccessAction successCallback;
@property(nonatomic, copy) SNURLRequestFailureAction failureCallback;
- (unsigned long long)partialDownloadSize;
@end

//@class SNNotificationCenter;

@implementation SNURLRequest
@synthesize isShowNoNetWorkMessage = _isShowNoNetWorkMessage;
@synthesize isCancelled = _isCancelled;
@synthesize baseUrl = _baseUrl;
@synthesize successCallback = _successCallback;
@synthesize failureCallback = _failureCallback;

- (id)initWithURL:(NSString*)URL baseUrl:(NSString *)baseUrl delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie {
    URL = [SNUtility addProductIDIntoURL:URL];
    URL = [SNUtility addBundleIDIntoURL:URL];
    if (self = [super initWithURL:URL delegate:delegate]) {
        if (bCookie && [SNClientRegister sharedInstance].s_cookie.length > 0) {
            [self setValue:[SNClientRegister sharedInstance].s_cookie forHTTPHeaderField:@"SCOOKIE"];
        }
		//[self setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
		[self setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
		self.cachePolicy = TTURLRequestCachePolicyNoCache;
		self.cacheExpirationAge = SN_DEFAULT_CACHE_EXPIRATION_AGE;
        self.baseUrl = baseUrl;
		_isShowNoNetWorkMessage = NO;
        _isParamP = paramP;
	}
    SNDebugLog(@"Created request with url: %@", self.urlPath);
	return self;
}

- (id)initWithURL:(NSString*)URL baseUrl:(NSString *)baseUrl delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie isV6:(BOOL)isV6{
    URL = [SNUtility addProductIDIntoURL:URL];
    if (!isV6) {
        URL = [SNUtility addBundleIDIntoURL:URL];
    }
    if (self = [super initWithURL:URL delegate:delegate]) {
        if (bCookie && [SNClientRegister sharedInstance].s_cookie.length > 0) {
            [self setValue:[SNClientRegister sharedInstance].s_cookie forHTTPHeaderField:@"SCOOKIE"];
        }
        //[self setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        [self setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
        self.cachePolicy = TTURLRequestCachePolicyNoCache;
        self.cacheExpirationAge = SN_DEFAULT_CACHE_EXPIRATION_AGE;
        self.baseUrl = baseUrl;
        _isShowNoNetWorkMessage = NO;
        _isParamP = paramP;
    }
    SNDebugLog(@"Created request with url: %@", self.urlPath);
    return self;
}

- (id)initWithURL:(NSString*)URL baseUrl:(NSString *)baseUrl delegate:(id)delegate isParamP:(BOOL)paramP {
    return [self initWithURL:URL baseUrl:baseUrl delegate:delegate isParamP:paramP scookie:NO];
}

+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate {
    return [self requestWithURL:URL delegate:delegate isParamP:YES];
}


+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate isParamP:(BOOL)paramP {
    return [self requestWithURL:URL delegate:delegate isParamP:paramP scookie:NO];
}

+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie {
    NSString *requestUrl = URL;
    //5.2 add buildCode
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
	if (paramP) {
		requestUrl = [SNUtility addParamP1ToURL:URL];
        if (appBuild) {
            requestUrl = [requestUrl stringByAppendingFormat:@"&buildCode=%@", appBuild];
        }
	}
    else {
        if (NSNotFound == [requestUrl rangeOfString:@"?" options:NSCaseInsensitiveSearch].location && appBuild) {
            requestUrl = [requestUrl stringByAppendingFormat:@"?buildCode=%@", appBuild];
        }
        else {
            requestUrl = [requestUrl stringByAppendingFormat:@"&buildCode=%@", appBuild];
        }
    }
    
    SNDebugLog(@"INFO: %@--%@, Requesting with url: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), requestUrl);
    
	return [[self alloc] initWithURL:requestUrl baseUrl:URL delegate:delegate isParamP:paramP scookie:bCookie];
}

//+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie defaultP1:(BOOL)defaultP1 {
//    NSString *requestUrl = URL;
//    //5.2 add buildCode
//    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
//    if (paramP) {
//        if (defaultP1 == YES) {
//            requestUrl = [SNUtility addParamDefaultP1ToURL:URL];
//        }
//        else{
//            requestUrl = [SNUtility addParamP1ToURL:URL];
//        }
//        
//        if (appBuild) {
//            requestUrl = [requestUrl stringByAppendingFormat:@"&buildCode=%@", appBuild];
//        }
//    }
//    else {
//        if (NSNotFound == [requestUrl rangeOfString:@"?" options:NSCaseInsensitiveSearch].location && appBuild) {
//            requestUrl = [requestUrl stringByAppendingFormat:@"?buildCode=%@", appBuild];
//        }
//        else {
//            requestUrl = [requestUrl stringByAppendingFormat:@"&buildCode=%@", appBuild];
//        }
//    }
//    
//    SNDebugLog(@"INFO: %@--%@, Requesting with url: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), requestUrl);
//    
//    return [[[self alloc] initWithURL:requestUrl baseUrl:URL delegate:delegate isParamP:paramP scookie:bCookie] autorelease];
//}

+ (SNURLRequest *)requestWithURL:(NSString*)URL delegate:(id)delegate isParamP:(BOOL)paramP scookie:(BOOL)bCookie isV6:(BOOL)isV6{
    NSString *requestUrl = URL;
    //5.2 add buildCode
    NSString *appBuild = isV6 ? nil : [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild];
    if (paramP) {
        //BOOL defaultP1 = ([SNUserManager getP1] == nil);
        requestUrl = [SNUtility addParamP1ToURL:URL isV6:isV6];
        if (appBuild) {
            requestUrl = [requestUrl stringByAppendingFormat:@"&buildCode=%@", appBuild];
        }
    }
    else {
        if (NSNotFound == [requestUrl rangeOfString:@"?" options:NSCaseInsensitiveSearch].location && appBuild) {
            requestUrl = [requestUrl stringByAppendingFormat:@"?buildCode=%@", appBuild];
        }
        else {
            requestUrl = [requestUrl stringByAppendingFormat:@"&buildCode=%@", appBuild];
        }
    }
    
    SNDebugLog(@"INFO: %@--%@, Requesting with url: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), requestUrl);
    
    return [[self alloc] initWithURL:requestUrl baseUrl:URL delegate:delegate isParamP:paramP scookie:bCookie isV6:isV6];
}

- (BOOL)sendWithScuccessAction:(SNURLRequestSuccessAction)successAction failAction:(SNURLRequestFailureAction)failAction {
    
    [self.delegates addObject:self];
    self.successCallback = successAction;
    self.failureCallback = failAction;
    
    return [self send];
}

- (unsigned long long)partialDownloadSize {
    unsigned long long size = 0;
    NSString* filePath = [[TTURLCache sharedCache] cachePathForURL:self.urlPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size = [attrs fileSize];
    }
    return size;
}

- (void)buildRequestHeaders {
    if ([self partialDownloadSize]) {
        [self setValue:[NSString stringWithFormat:@"bytes=%llu-",[self partialDownloadSize]] forHTTPHeaderField:@"Range"];
    }
}

- (BOOL)send 
{
    //采样通知
    [SNNotificationManager postNotificationName:kSNSamplingFrequencyNotification object:[NSURL URLWithString:_urlPath]];
    
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
		if (_isShowNoNetWorkMessage) {
			[SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
		}
		[self cancel];
		for (id<TTURLRequestDelegate> delegate in self.delegates) {
			if ([delegate respondsToSelector:@selector(requestDidCancelLoad:)]) {
				[delegate requestDidCancelLoad:self];
			}
		}
	}
    if (_isAllowResume) {
        [self buildRequestHeaders];
    }
    return [super send];
}

- (BOOL)sendSynchronously {
    //采样通知
    [SNNotificationManager postNotificationName:kSNSamplingFrequencyNotification object:[NSURL URLWithString:_urlPath]];
    
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
		if (_isShowNoNetWorkMessage) {
			[SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
		}
		[self cancel];
		for (id<TTURLRequestDelegate> delegate in self.delegates) {
			if ([delegate respondsToSelector:@selector(requestDidCancelLoad:)]) {
				[delegate requestDidCancelLoad:self];
			}
		}
		//return NO;
	}
    return [super sendSynchronously];

	
}

- (void)cancel {
    if (_isAllowResume) {
        _isCancelled = YES;
    }
    [super cancel];
}

- (void)dealloc {
    [[TTURLRequestQueue mainQueue] cancelRequest:self];
    
     //(_baseUrl);
     //(_successCallback);
     //(_failureCallback);
}

- (void)setUrlPath:(NSString *)urlPath {
    NSString *urlWithP1 = _isParamP ? [SNUtility addParamP1ToURL:urlPath] : urlPath;
    urlWithP1 = [SNUtility addProductIDIntoURL:urlWithP1];
    urlWithP1 = [SNUtility addBundleIDIntoURL:urlWithP1];
    _urlPath = [urlWithP1 copy];
}

- (void)setUrlPath:(NSString *)urlPath isV6:(BOOL)isV6{
    NSString *urlWithP1 = _isParamP ? [SNUtility addParamP1ToURL:urlPath isV6:isV6] : urlPath;
    urlWithP1 = [SNUtility addProductIDIntoURL:urlWithP1];
//    if ([[SNUserManager getP1] isEqualToString:@"NTc2MjQzNzUyMTY2NTQyOTUxNw=="]) {
//        urlWithP1 = [urlWithP1 stringByAppendingString:@"&platformId=5"];
//    }
    urlWithP1 = [urlWithP1 stringByAppendingString:@"&platformId=5"];
    if (!isV6) {
        urlWithP1 = [SNUtility addBundleIDIntoURL:urlWithP1];
    }
    
    _urlPath = [urlWithP1 copy];
}

#pragma mark - TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    if (self.successCallback) {
        self.successCallback(self);
    }
    [self.delegates removeObject:self];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    if (self.failureCallback) {
        self.failureCallback(self, error);
    }
    [self.delegates removeObject:self];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    if (self.failureCallback) {
        self.failureCallback(self, [NSError errorWithDomain:@"user canceled" code:-1111 userInfo:nil]);
    }
    [self.delegates removeObject:self];
}

@end
