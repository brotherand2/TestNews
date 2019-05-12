//
//  SNVideoMediaWebService.m
//  sohunews
//
//  Created by handy wang on 12/7/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoMediaWebService.h"

@interface SNVideoMediaWebService()
@property (nonatomic, strong)SNASIRequest *request;
@end

@implementation SNVideoMediaWebService

#pragma mark - Lifecycle
- (void)dealloc {
    [self cancel];

}

#pragma mark - Public
- (void)loadAsynchronously {
    if (!(self.isLoading)) {
        self.isLoading = YES;
        if ([self.delegate respondsToSelector:@selector(didStartLoad)]) {
            [self.delegate didStartLoad];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self cancel];

            self.request = [SNASIRequest requestWithURL:self.url];
            self.request.cachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy;
            self.request.delegate = self;
            [self.request setValidatesSecureCertificate:NO];
            [self.request startAsynchronous];
            SNDebugLog(@"Requesting video media from url: %@", self.request.url.absoluteString);
        });
    }
    else {
        SNDebugLog(@"Video media webservice is loading...");
    }
}

- (void)cancel {
    [self.request clearDelegatesAndCancel];
    self.request = nil;
    self.isLoading = NO;
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    self.isLoading = NO;
    
    if (request.responseStatusCode == 200) {
        if ([self.delegate respondsToSelector:@selector(didFinishedLoad:request:)]) {
            [self.delegate didFinishedLoad:request.responseString request:request];
        }
    }
    else {
        [self requestFailed:request];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    self.isLoading = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailedLoad)]) {
        [self.delegate didFailedLoad];
    }
}

@end
