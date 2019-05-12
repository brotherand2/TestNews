//
//  SNVideoDownloadRequest.m
//  sohunews
//
//  Created by handy wang on 9/4/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadRequest.h"
#import "SNClientRegister.h"

@implementation SNVideoDownloadRequest

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
        [self setAllowResumeForFileDownloads:YES];
        [self setValidatesSecureCertificate:NO];
    }
	return self;
}

@end