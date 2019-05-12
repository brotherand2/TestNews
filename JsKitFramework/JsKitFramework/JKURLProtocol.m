//
//  JKURLProtocol.m
//  JsKitFramework
//
//  Created by sevenshal on 16/1/5.
//  Copyright © 2016年 sohu. All rights reserved.
//

#import "JKURLProtocol.h"

#import <Foundation/Foundation.h>

#import "JKWebAppManager.h"
#import "JKAuthUtils.h"
#import "JsKitClient.h"

#import "Define.h"

#import "JsKitFramework.h"
#import "JKBridgeHandler.h"

#define URLProtocolHandledKey @"JsKitURLProtocolHandled"

@interface JKURLProtocol () <NSURLConnectionDelegate>

@property (nonatomic, strong) JKBridgeHandler *bridgeHandler;

@property (nonatomic, assign)BOOL loading;

@end

@implementation JKURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSURL *url = [request URL];
    NSString* ext = [url pathExtension];
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        if ([@"go" isEqualToString:ext]  || [JKGlobalSettings defaultSettings].debugMode){
            ((NSMutableURLRequest*)request).cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        }
    }
    
    /*  //@qz 方便调试
    if ([JSKIT_BRIDGE_EXTENSION isEqualToString:ext]) {
        return YES;
    }
    if ([url.path hasPrefix:BRIDGE_PATH_PREFIX]) {
        return YES;
    }
    if ([url.scheme isEqualToString:JSKIT_FILE]) {
        return YES;
    }
    if ([JKGlobalSettings defaultSettings].debugMode) {
        return NO;
    }else{
        if (![JKAuthUtils checkWebAppAuth:url]) {
            return NO;
        }else{
            NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"^/h5apps/([^/]*)/" options:NSRegularExpressionCaseInsensitive error:nil];
            NSTextCheckingResult* result = [regEx firstMatchInString:url.path options:0 range:NSMakeRange(0, url.path.length)];
            if (!result) {
                return NO;
            }else{
                NSString *webName = [url.path substringWithRange:[result rangeAtIndex:1]];
                if ([[JKWebAppManager manager] getWebAppWithName:webName]) {
                    return YES;
                }
            }
        }
    }
    return NO;
    */
    
    return [JSKIT_BRIDGE_EXTENSION isEqualToString:ext]
    || ([[JKWebAppManager manager] isBuildInWebAppWithUrl:url]
        && ![JKGlobalSettings defaultSettings].debugMode)
    || [url.path hasPrefix:BRIDGE_PATH_PREFIX]
    || [JSKIT_FILE isEqualToString:url.scheme];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *newRequest;
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        newRequest = (NSMutableURLRequest*)request;
    }else{
        newRequest = [request mutableCopy];
    }
    newRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    return newRequest;
}

-(instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client{
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    return self;
}

- (void)startLoading {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doLoadingData];
    });
}

-(void)doLoadingData{
    _loading = YES;
    NSString* extension = [self.request.URL pathExtension];
    NSData *data = nil;
    NSString* mimeType = @"";
    if ([JSKIT_FILE isEqualToString:self.request.URL.scheme]) {
        data = [NSData dataWithContentsOfFile:self.request.URL.path];
    }else if ([JSKIT_BRIDGE_EXTENSION isEqualToString:extension]) {
        data = [JsKitClient callNative:self.request];//调用native的方法并获得返回值
    }else if([self.request.URL.path hasPrefix:BRIDGE_PATH_PREFIX]){
        _bridgeHandler = [[JKBridgeHandler alloc] init];
        [_bridgeHandler handleUrl:self.request callback:^(JKBridgeHandler* handler, NSData *data, NSString* mimeType) {
            if (data) {
                [self didFinish:data mimeType:mimeType];
            }else{
                [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"jskitbridge" code:400 userInfo:nil]];
            }
        }];
        return;
    }else{
        NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
        data = [JsKitClient jskitResponseOfRequest:self.request outMimeType:&mimeType policy:&policy];
    }
    [self didFinish:data mimeType:mimeType];
}

- (void)stopLoading {
    [_bridgeHandler stopHandle];
    _bridgeHandler = nil;
    _loading = NO;
}

-(void)didFinish:(NSData*)data mimeType:(NSString*)mimeType{
    if (!_loading) {
        return;
    }
    NSURLResponse* cachedResponse = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:mimeType expectedContentLength:data.length textEncodingName:nil];
    [self.client URLProtocol:self didReceiveResponse:cachedResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

-(BOOL)conformsToProtocol:(Protocol *)aProtocol{
    return [super conformsToProtocol:aProtocol];
}

@end
