//
//  SNArticleSearchService.m
//  sohunews
//
//  Created by lhp on 6/17/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNArticleSearchService.h"
#import "SNURLDataResponse.h"
#import "NSObject+YAJL.h"


@interface SNArticleSearchService ()
{
    SNURLRequest *searchRequest;
}

@end

@implementation SNArticleSearchService

@synthesize html;
@synthesize delegate;

+ (SNArticleSearchService *)sharedInstance {
    static SNArticleSearchService *_sharedInstance = nil;
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[SNArticleSearchService alloc] init];
        }
    }
    return _sharedInstance;
}

- (void)requestArticleSearchWithText:(NSString *) searchText
{
    if (searchText.length > 0) {
        self.html = nil;
        [searchRequest cancel];
        NSString *urlString = [NSString stringWithFormat:@"%@?query=%@",kArticleSearchUrl,[searchText URLEncodedString]];
        if(!searchRequest) {
            searchRequest = [SNURLRequest requestWithURL:urlString delegate:self];
            searchRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
        } else {
            searchRequest.urlPath = urlString;
        }
        searchRequest.response = [[SNURLDataResponse alloc] init];
        [searchRequest send];
    }
}

#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
    
    SNURLDataResponse *response = request.response;
    NSDictionary *dic = [response.data yajl_JSON];
    if (dic) {
        self.html = [dic objectForKey:kUrl];
    }
    
    /*
    SNURLDataResponse *dataRes = (SNURLDataResponse *)request.response;
    if (dataRes.data) {
        NSString *htmlString = [[NSString alloc] initWithData:dataRes.data encoding:NSUTF8StringEncoding];
        self.html = htmlString;
        [htmlString release];
    }
    */
    
    if (delegate && [delegate respondsToSelector:@selector(requestDidFinishLoad)]) {
        [delegate requestDidFinishLoad];
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    if (delegate && [delegate respondsToSelector:@selector(requestDidFinishLoad)]) {
        [delegate requestDidFinishLoad];
    }
}

- (void)dealloc
{
    self.delegate = nil;
    [searchRequest cancel];
}

@end
