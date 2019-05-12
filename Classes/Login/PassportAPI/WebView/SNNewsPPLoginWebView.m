//
//  SNNewsPPLoginWebView.m
//  sohunews
//
//  Created by wang shun on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginWebView.h"

#import "SNNewsPPLoginHeader.h"

#import "SNNewsPPLoginURLHeader.h"
#import "SNNewsPPLoginRequestList.h"

@interface SNNewsPPLoginWebView ()<UIWebViewDelegate>


@end

@implementation SNNewsPPLoginWebView

- (void)getJSEvalCode{
    
    NSDictionary* dic = @{@"var":@"var"};
    
    [[[SNNewsPPLoginJSRequest alloc] initWithDictionary:dic] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"pp Url::%@",request.url);
        SNDebugLog(@"SNNewsPPLoginJSRequest resq::::%@",responseObject);
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSNumber* status = [responseObject objectForKey:@"status"];
            if (status.integerValue == 200) {//
                NSString* jsData = [responseObject objectForKey:@"data"];
                if (jsData && jsData.length>0) {
                    [self loadJSWeb:jsData];
                }
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"err:::%@",error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(loadFailed:)]) {
            [self.delegate loadFailed:nil];
        }
    }];
}

- (void)loadJSWeb:(NSString*)data{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"PPLoginWebHtmlData" ofType:@""];
    
    NSString* html_Str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSString* html_data = @"";
    html_data = [html_Str stringByReplacingOccurrencesOfString:@"EXCHANGE_JS_CODE" withString:data];
    SNDebugLog(@"html:::%@",html_data);
    [self.webView loadHTMLString:html_data baseURL:nil];
}

- (NSString*)getUA{
    NSString* ua = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    //Mozilla/5.0 (iPhone; CPU iPhone OS 11_1 like Mac OS X) AppleWebKit/604.3.5 (KHTML, like Gecko) Mobile/15B87 JsKit/1.0 (iOS) /SohuNews
    return ua;
}

- (void)loadPPJV{
    [self getJSEvalCode];
}

- (void)createWebView{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.delegate = self;
}

- (instancetype)init{
    if (self = [super init]) {
        [self createWebView];
    }
    return self;
}

/*************************************************************************************/

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    SNDebugLog(@"SNNewsPPLoginWebView webViewDidFinishLoad");
    if (self.delegate && [self.delegate respondsToSelector:@selector(getPPJV:)]) {
        NSString* ppjv = [self.webView stringByEvaluatingJavaScriptFromString:@"document._jv"];
        [self.delegate getPPJV:ppjv];
    }
}

@end
