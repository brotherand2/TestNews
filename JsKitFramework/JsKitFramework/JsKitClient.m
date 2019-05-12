//
//  JsKitClient.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/15.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "JsKitClient.h"
#import "JKJsClassManager.h"
#import "JKWebAppManager.h"
#import "JKGlobalSettings.h"
#import "JsKitFramework.h"

#import "JKNotificationCenter.h"

#import "JKURLProtocol.h"

#import "Define.h"

#import "JKAuthUtils.h"

#import "JKJsKitCoreApi.h"

static NSMutableDictionary<NSString*,id>* globelJsInterfaces;

static NSMutableDictionary<id,id>* globelJsKitClients;

@implementation JsKitClient{
    //    WKWebView* wkWebView;
    NSMutableDictionary<NSString*,id>* jsInterfaces;
    NSMutableDictionary* userData;
    NSURL * currentURL;
    BOOL requestingNew;
}

-(instancetype)initWithWebView:(UIWebView*)aWebView{
    if (self=[super init]) {
        [[JKNotificationCenter defaultCenter] addClient:self];
        _webView = aWebView;
        _webView.delegate = self;
        _callbackBlockDic = [NSMutableDictionary dictionary];
        jsInterfaces = [[NSMutableDictionary alloc] initWithDictionary:[JsKitClient getGlobelJsInterface]];
        _coreApi = [[JKJsKitCoreApi alloc] init];
        [self addJavascriptInterface:_coreApi forName:@"jsKitCoreApi"];
        [[JsKitClient getGlobelJsKitClients] setObject:[NSValue valueWithNonretainedObject:self] forKey:@((NSInteger)self)];
    }
    return self;
}

-(void)dealloc{
    [[JKNotificationCenter defaultCenter] removeClient:self];
    [[JsKitClient getGlobelJsKitClients] removeObjectForKey:@((NSInteger)self)];
}

+(void)globelInit{
#if !USE_CACHE_BRIDGE
    [NSURLProtocol registerClass:[JKURLProtocol class]];
#endif
//    [NSURLCache setSharedURLCache:[JKURLCache defaultCache]];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newAgent = [oldAgent stringByAppendingString:@" JsKit/"JSKIT_VERSION_NAME" (iOS) /SohuNews"];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

+(NSMutableDictionary*)getGlobelJsInterface{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        globelJsInterfaces = [[NSMutableDictionary alloc] init];
    });
    return globelJsInterfaces;
}

+(NSMutableDictionary*)getGlobelJsKitClients{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        globelJsKitClients = [[NSMutableDictionary alloc] init];
    });
    return globelJsKitClients;
}

+(void)addGlobelJavascriptInterface:(id)target forName:(NSString*)name{
    [[JsKitClient getGlobelJsInterface] setObject:target forKey:name];
    
//    JSLog(@"addGlobelJsInterface %@ using class of %@",name,[target class]);
}


-(void)setUserData:(id)value forKey:(id)key{
    [userData setObject:value forKey:key];
}

-(void)setNoRetainUserData:(id)value forKey:(id)key{
    [userData setObject:[NSValue valueWithNonretainedObject:value] forKey:key];
}

-(id)getUserData:(id)key{
    return [userData objectForKey:key];
}

-(id)getNoRetainUserData:(id)key{
    return [[userData objectForKey:key] nonretainedObjectValue];
}

-(void)removeGlobelJavascriptInterface:(NSString*)name{
    [[JsKitClient getGlobelJsInterface] removeObjectForKey:name];
}

-(void)addJavascriptInterface:(id)target forName:(NSString*)name{
    [jsInterfaces setObject:target forKey:name];
    
//    JSLog(@"addJsInterface %@ using class of %@",name,[target class]);
}

-(void)removeJavascriptInterface:(NSString*)name{
    [jsInterfaces removeObjectForKey:name];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"delete(window.%@)",name]];
}

-(id)evaluatingJavaScriptWithFormat:(NSString *)jsFormat, ...{
    va_list args;
    va_start(args, jsFormat);
    NSMutableString* evaluatStr = [[NSMutableString alloc] initWithCapacity:128];
    [evaluatStr appendString:@"JSON.stringify(["];
    [evaluatStr appendString:jsFormat];
    [evaluatStr appendString:@"])"];
    NSString *str = [[NSString alloc] initWithFormat:evaluatStr arguments:args];
    va_end(args);
    
//    JSLog(@"evaluatingJavaScript:%@",[str substringWithRange:NSMakeRange(16, str.length-18)]);
    
    return [self evaluatingJSONstringfy:str];
}

-(id)evaluatingJavaScriptFunction:(NSString*)functionName argsCount:(NSUInteger)count, ...{
    va_list args;
    va_start(args, count);
    NSMutableArray* array = [[NSMutableArray alloc] init];
    id arg;
    while (count--) {
        arg=va_arg(args, id);
        [array addObject:arg==nil?[NSNull null]:arg];
    }
    va_end(args);
    return [self evaluatingJavaScriptFunction:functionName arguments:array];
}

-(id)evaluatingJavaScriptFunction:(NSString*)functionName, ...{
    va_list args;
    va_start(args, functionName);
    NSMutableArray* array = [[NSMutableArray alloc] init];
    id arg;
    while ((arg=va_arg(args, id))!=[JKValue argEnd]) {
        [array addObject:arg==nil?[NSNull null]:arg];
    }
    va_end(args);
    return [self evaluatingJavaScriptFunction:functionName arguments:array];
}

-(id)evaluatingJavaScriptFunction:(NSString*)functionName arguments:(NSArray*)arguments{
    NSMutableString* js = [[NSMutableString alloc] initWithCapacity:256];
    [js appendString:@"JSON.stringify(["];
    [js appendString:functionName];
    [js appendString:@"("];
    NSString* params = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:arguments options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
    params = [params substringWithRange:NSMakeRange(1, params.length-2)];
    [js appendString:params];
    [js appendString:@")])"];
    
//    JSLog(@"evaluatingJavaScriptFunction:%@",[js substringWithRange:NSMakeRange(16, js.length-18)]);
    return [self evaluatingJSONstringfy:js];
}


-(id)evaluatingJSONstringfy:(id)str{
    if (![_webView isKindOfClass:[UIWebView class]])  return nil;
    
    NSString* result = [_webView stringByEvaluatingJavaScriptFromString:str];
    if (result.length == 0) {
        return nil;
    }
    NSArray* array = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    return [array objectAtIndex:0];
}

+(NSData *)jskitResponseOfRequest:(NSURLRequest*)request outMimeType:(NSString**)pMimeType policy:(NSURLCacheStoragePolicy*)policy{
    static NSDictionary* interceptMimeTypes;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        interceptMimeTypes = @{@"html":@"text/html",
                               @"js":@"application/javascript",
                               @"css":@"text/css",
                               @"png":@"image/png",
                               @"jpg":@"image/jpeg",
                               @"jpeg":@"image/jpeg"};
    });
    NSURL* url = request.URL;
    NSString* extension = [url pathExtension];
    NSString* mineType = extension==nil?nil:[interceptMimeTypes valueForKey:[extension lowercaseString]];
    if (mineType==nil) {
        mineType = @"application/octet-stream";
    }
    *pMimeType = mineType;
    
    NSString* relativePath;
    JKWebApp* webApp = [[JKWebAppManager manager] getWebAppWithUrl:url relativePath:&relativePath];
    return [webApp getResourceOfPath:relativePath];
}

+(NSData*)httpRequestArgsData:(NSURLRequest*)request{
    if ([[request.HTTPMethod lowercaseString] isEqualToString:@"post"]) {
        return [request HTTPBody];
    }
    NSURL* url = request.URL;
    CFStringRef unescapedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef)url.absoluteString,
                                                                                          CFSTR(""),
                                                                                          kCFStringEncodingUTF8);
    NSString *changeUrl = (__bridge_transfer NSString *)unescapedString;
    NSString* paramsStr = nil;
    NSRange range = [changeUrl rangeOfString:@"args="];
    if(range.length > 0){
        range.location = range.location + (@"args=".length);
        range.length = changeUrl.length - range.location;
        paramsStr = [changeUrl substringWithRange:range];
    }
    return [paramsStr dataUsingEncoding:NSUTF8StringEncoding];
}

+(NSData*)callNative:(NSURLRequest*) request{
    NSURL* url = request.URL;
    NSArray* pathComponents = [url pathComponents];
    NSInteger clientId = [[pathComponents objectAtIndex:1] integerValue];
    NSString* objName = [pathComponents objectAtIndex:2];
    NSString* methodName = [pathComponents objectAtIndex:3];
    NSData* argsData = [self httpRequestArgsData:request];
    
    NSArray* params = [NSJSONSerialization JSONObjectWithData:argsData options:NSJSONReadingMutableContainers error:nil];
    
#if DEBUG
    NSLog(@"js call method:%@.%@(%@)",objName,methodName,[params componentsJoinedByString:@","]);
#endif
    NSValue* value = [[JsKitClient getGlobelJsKitClients] objectForKey:@(clientId)];
    id result = nil;
    if (value==nil) {
        result = nil;
    }else{
        JsKitClient* client = [value nonretainedObjectValue];
        if(client==nil){
            result = nil;
        }else{
            result = [client callNative:objName jsMethodName:methodName params:params];
        }
    }
    return [NSJSONSerialization dataWithJSONObject:result?[NSArray arrayWithObject:result]:[NSArray array] options:kNilOptions error:nil];
}

-(id)callNative:(NSString*)objName jsMethodName:(NSString*)methodName params:(NSArray*)params{
    if([objName isEqualToString:@"_jsKitN"] && [methodName isEqualToString:@"getInitScript"]){
        return [self getInitScript];
    }
    id receiver = [jsInterfaces objectForKey:objName];
    if(receiver==nil){
        return nil;
    }
    return [[[JKJsClassManager manager] getJsClass:[receiver class]] invokeMethod:methodName receiver:receiver jsKitClient:self params:params];
}

-(NSString*)getInitScript{
    if (![JKAuthUtils checkWebAppAuth:currentURL]) {
        return nil;
    }
    NSMutableString* buffer = [[NSMutableString alloc] initWithCapacity:1024];
    JKJsClass* jsClz;
    JKJsClassManager* manager = [JKJsClassManager manager];
    @synchronized (jsInterfaces){
        NSArray* keys = [jsInterfaces allKeys];
        NSString* objName;
        id obj;
        NSMutableSet* interfaceClzes = [[NSMutableSet alloc] init];
        for (NSInteger i=0,c=[keys count]; i<c; i++) {
            objName = [keys objectAtIndex:i];
            obj = [jsInterfaces valueForKey:objName];
            jsClz = [manager getJsClass:[obj class]];
            if (![interfaceClzes containsObject:jsClz]) {
                [interfaceClzes addObject:jsClz];
                [buffer appendString:jsClz.scriptInit];
            }
            [buffer appendFormat:@"jsKit.newInstance('%@',%@);",objName,jsClz.jsClassName];
        }
        _jsKitInited = true;
    }
    return buffer;
}

-(BOOL)webView:(UIWebView *)aWebView shouldDelegateStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_delegate webView:aWebView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

-(void)reload{
    if ([[NSThread currentThread] isMainThread]) {
        [self.webView reload];
    }else{
        [self performSelectorOnMainThread:@selector(toMainThread) withObject:nil waitUntilDone:NO];
    }
}

-(void)toMainThread{
    [self.webView reload];
}

-(NSString*)urlStringByAppendingJsKitClientId:(NSString*)urlStr with:(NSTextCheckingResult*)result{
    if (result!=nil) {
        return [urlStr stringByReplacingCharactersInRange:[result rangeAtIndex:1] withString:[NSString stringWithFormat:@"%ld", (long)self]];
    }
    NSUInteger posInsert = 0;
    NSRange dotRange = [urlStr rangeOfString:@"#"];
    if (dotRange.length>0) {
        posInsert = dotRange.location;
    }else{
        posInsert = urlStr.length;
    }
    NSString* idParam = nil;
    NSRange firstR = [urlStr rangeOfString:@"?"];
    if (firstR.location == NSNotFound) {
        idParam = [NSString stringWithFormat:@"?jsKitClientId=%ld",(long)self];
    }else{
        NSString* lastChar = [urlStr substringWithRange:NSMakeRange(posInsert-1, 1)];
        if ((firstR.location == posInsert-1) || [lastChar isEqualToString:@"&"]) {
            idParam = [NSString stringWithFormat:@"jsKitClientId=%ld",(long)self];
        }
        else if(firstR.location > posInsert) {
            idParam = [NSString stringWithFormat:@"&jsKitClientId=%ld",(long)self];
            //暂时这么修改，解决URL中同时含有#和？
            return [urlStr stringByReplacingCharactersInRange:NSMakeRange(firstR.location, 0) withString:idParam];
        }
        else {
            idParam = [NSString stringWithFormat:@"&jsKitClientId=%ld",(long)self];
        }
    }
    return [urlStr stringByReplacingCharactersInRange:NSMakeRange(posInsert, 0) withString:idParam];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString* webAppName = [[JKWebAppManager manager] getNameByUrl:request.URL relativePath:nil];
    if (webAppName) {
        static NSRegularExpression* reg;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            reg = [NSRegularExpression regularExpressionWithPattern:@"[&\?]jsKitClientId=(-?[0-9]+)" options:NSRegularExpressionCaseInsensitive error:nil];
        });
        NSString* absUrl = request.URL.absoluteString;
        NSTextCheckingResult* result = [reg firstMatchInString:absUrl options:0 range:NSMakeRange(0, absUrl.length)];
        NSInteger clientId = result==nil ? 0 :[[absUrl substringWithRange:[result rangeAtIndex:1]] integerValue];
        if (clientId != (NSUInteger)self) {
            if (![self webView:aWebView shouldDelegateStartLoadWithRequest:request navigationType:navigationType]) {
                return NO;
            }
            JsKitStorage* storage = [[JsKitStorageManager manager] storageForWebApp:webAppName];
            [self addJavascriptInterface:storage forName:@"jsKitStorage"];
            
            NSURL* clientURL = [NSURL URLWithString:[self urlStringByAppendingJsKitClientId:absUrl with:result]];
            currentURL = request.URL;
            NSURLRequest* newRequest = [NSURLRequest requestWithURL:clientURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
            requestingNew = YES;
            [_webView loadRequest:newRequest];
            return NO;
        }else {
            if (!requestingNew){
                if (![self webView:aWebView shouldDelegateStartLoadWithRequest:request navigationType:navigationType]) {
                    return NO;
                }
            }
            requestingNew = NO;
            return YES;
        }
        //        JSLog(@"load jskit webApp(%@)' url:%@",webAppName,request.URL);
    }else {
        if (![self webView:aWebView shouldDelegateStartLoadWithRequest:request navigationType:navigationType]) {
            return NO;
        }
//        JSLog(@"load a outlink(not jskit webApp) url:%@",request.URL);
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView{
    if ([_delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_delegate webViewDidStartLoad:aWebView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView{
    if ([_delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_delegate webViewDidFinishLoad:aWebView];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error{
    if ([_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_delegate webView:aWebView didFailLoadWithError:error];
    }
}


@end
