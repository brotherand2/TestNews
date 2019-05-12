//
//  SNDownloadRequest+ASI.m
//  sohunews
//
//  Created by handy wang on 6/13/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDownloaderRequest.h"
#import "SNClientRegister.h"

@implementation SNDownloaderRequest

- (id)initWithURL:(NSURL *)newURL {
    if (self = [super initWithURL:newURL]) {
        [self setResponseEncoding:NSUTF8StringEncoding];
        if ([SNClientRegister sharedInstance].s_cookie.length > 0) {
            [self addRequestHeader:@"SCOOKIE" value:[SNClientRegister sharedInstance].s_cookie];
        }
        [self addRequestHeader:@"Content-Type" value:@"text/plain"];
        [self addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
        [self setNumberOfTimesToRetryOnTimeout:1];
        [self setTimeOutSeconds:30];
    }
	return self;
}

@end

@implementation SNDownloaderSndRequest

- (id)initWithURL:(NSURL *)newURL {
    if (self = [super initWithURL:newURL]) {
        [self setResponseEncoding:NSUTF8StringEncoding];
        //[self addRequestHeader:@"SCOOKIE" value:[SNUtility getApplicationDelegate].s_cookie];
        [self addRequestHeader:@"Content-Type" value:@"audio/mpeg"];
        [self addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
        [self setNumberOfTimesToRetryOnTimeout:1];
        [self setTimeOutSeconds:30];
    }
    return self;
}

@end