//
//  SNNewsFaourService.m
//  sohunews
//
//  Created by weibin cheng on 14-8-1.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsFaourService.h"
#import "SNASIRequest.h"
#import "NSDictionaryExtend.h"
#import "SNConsts.h"
#import "NSJSONSerialization+String.h"

@interface SNNewsFavourService ()<ASIHTTPRequestDelegate>

@property (nonatomic ,strong) SNASIRequest* httpRequest;

@end

@implementation SNNewsFavourService

- (id)init
{
    self = [super init];
    if(self)
    {
        _favourCount = -1;
        _readingCount = -1;
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [self cancel];
}


#pragma mark - Private
- (void)cancel {
    _httpRequest.delegate = nil;
    [_httpRequest cancel];
    _httpRequest = nil;
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(_delegate && [_delegate respondsToSelector:@selector(newsFavourServiceDisdFailed:)])
        [_delegate newsFavourServiceDisdFailed:request.error];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary* root = [NSJSONSerialization JSONObjectWithString:request.responseString
                                                           options:NSJSONReadingMutableLeaves
                                                             error:NULL];
    int count= [root intValueForKey:@"newsHotCount" defaultValue:-1];
    int read = [root intValueForKey:@"newsPageView" defaultValue:-1];
    if(count >= 0)
    {
        self.favourCount = count;
        self.readingCount = read;
        if(_delegate && [_delegate respondsToSelector:@selector(newsFavourServiceDidFinished:readingCount:)])
            [_delegate newsFavourServiceDidFinished:count readingCount:read];
    }
    else
    {
        if(_delegate && [_delegate respondsToSelector:@selector(newsFavourServiceDisdFailed:)])
            [_delegate newsFavourServiceDisdFailed:request.error];
    }
}
@end
