//
//  SNRollingNewsImageFetcher.m
//  sohunews
//
//  Created by handy wang on 1/6/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNNewsImageFetcher.h"
#import "ASIHTTPRequest.h"

#import "SNDownloadConfig.h"
#import "UIImage+Utility.h"

@implementation SNNewsImageFetcher
@synthesize delegate = _delegate;

+ (SNNewsImageFetcher *)sharedInstance {
    static SNNewsImageFetcher *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNNewsImageFetcher alloc] init];
    });
    return _sharedInstance;
}

- (void)fetchRollingNewsImagesInThread:(NSArray *)imageURLStringArray {
    if (!imageURLStringArray || (imageURLStringArray.count <= 0)) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //同步方式平行计算
    dispatch_apply([imageURLStringArray count], queue, ^(size_t index){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(isCancel)])
        {
            NSNumber* cancel = [_delegate performSelector:@selector(isCancel)];
            if(cancel!=nil && [cancel boolValue])
                return;
        }
#pragma clang diagnostic pop
        
        NSString *imageURLString = [imageURLStringArray objectAtIndex:index];
        if (![[TTURLCache sharedCache] ifImageExistInDisk:imageURLString]) {
            //因为SNDownloadRequest包含cookie了，静态资源不用带p1和cookie，所以这里用原生的ASIHttpRequest.
            ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageURLString]];
            [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
            [_request setResponseEncoding:NSUTF8StringEncoding];
            [_request setNumberOfTimesToRetryOnTimeout:3];
            [_request setTimeOutSeconds:30];
            _request.delegate = self;
            _request.validatesSecureCertificate = NO;
            _request.downloadDestinationPath = [SNDownloadConfig rollingnewsImagesFileDownloadPathWithURL:imageURLString];
            [_request startSynchronous];
        }
    });
    
    if ([_delegate respondsToSelector:@selector(finishedToFetchRollingNewsImagesInThread)]) {
        [_delegate finishedToFetchRollingNewsImagesInThread];
    }
    _delegate = nil;
    
//    dispatch_release(group);
}

- (void)fetchImagesInThread:(NSArray *)imageURLStringArray forNewsContent:(id)newsContent {
    if (!imageURLStringArray || (imageURLStringArray.count <= 0)) {
        return;
    }
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //同步方式平行计算
    dispatch_apply([imageURLStringArray count], queue, ^(size_t index){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(isCancel)])
        {
            NSNumber* cancel = [_delegate performSelector:@selector(isCancel)];
            if(cancel!=nil && [cancel boolValue])
                return;
        }
#pragma clang diagnostic pop

        
        NSString *imageURLString = [imageURLStringArray objectAtIndex:index];
        if (![[TTURLCache sharedCache] ifImageExistInDisk:imageURLString]) {
            //因为SNDownloadRequest包含cookie了，静态资源不用带p1和cookie，所以这里用原生的ASIHttpRequest.
            ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageURLString]];
            [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
            [_request setResponseEncoding:NSUTF8StringEncoding];
            [_request setNumberOfTimesToRetryOnTimeout:3];
            [_request setTimeOutSeconds:30];
            _request.delegate = self;
            _request.validatesSecureCertificate = NO;
            _request.downloadDestinationPath = [SNDownloadConfig rollingnewsImagesFileDownloadPathWithURL:imageURLString];
            [_request startSynchronous];
        }
    });
    
    if ([_delegate respondsToSelector:@selector(finishedToFetchImagesInThreadForNewsContent:)]) {
        [_delegate finishedToFetchImagesInThreadForNewsContent:newsContent];
    }
    _delegate = nil;
    
//    dispatch_release(group);
}

#pragma mark - ASIHttpRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request {
    SNDebugLog(@"===INFO: Main thread:%d, Succeed to download a image from %@", [NSThread isMainThread], [request.url absoluteString]);
    [request clearDelegatesAndCancel];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    SNDebugLog(@"===INFO: Main thread:%d, Failed to download a image from %@", [NSThread isMainThread], [request.url absoluteString]);
    [request clearDelegatesAndCancel];
}

@end
