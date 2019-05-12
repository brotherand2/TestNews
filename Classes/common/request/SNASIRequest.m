//
//  SNASIRequest.m
//  sohunewsipad
//
//  Created by ivan on 9/25/12.
//  Copyright (c) 2012 sohu. All rights reserved.
//

#import "SNASIRequest.h"

@implementation SNASIRequest

@synthesize isShowNoNetWorkMessage;

- (id)initWithURL:(NSURL *)newURL {
    NSString *_urlString = [SNUtility addParamP1ToURL:[newURL absoluteString]];
    _urlString = [SNUtility addProductIDIntoURL:_urlString];
    _urlString = [SNUtility addBundleIDIntoURL:_urlString];
    SNDebugLog(@"requestUrl = %@", _urlString);
    if (self = [super initWithURL:[NSURL URLWithString:_urlString]]) {
        [self setResponseEncoding:NSUTF8StringEncoding];
        [self addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
        [self setNumberOfTimesToRetryOnTimeout:3];
        [self setTimeOutSeconds:30];
    }
	return self;
}

- (void)start {
    [super start];
    //采样通知
    [SNNotificationManager postNotificationName:kSNSamplingFrequencyNotification object:self.url];
}

- (void)startSynchronous {
    [super startSynchronous];
    //采样通知
    [SNNotificationManager postNotificationName:kSNSamplingFrequencyNotification object:self.url];
}

- (void)startAsynchronous {
    [super startAsynchronous];
    //采样通知
    [SNNotificationManager postNotificationName:kSNSamplingFrequencyNotification object:self.url];
}

@end
