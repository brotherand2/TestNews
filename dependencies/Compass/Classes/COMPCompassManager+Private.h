//
//  COMPCompassManager+Private.h
//  Compass
//
//  Created by 李耀忠 on 26/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "COMPCompassManager.h"
#import <Availability.h>

@interface COMPCompassManager (Private)

@property (nonatomic, readonly) COMPConfiguration *configuration;

+ (instancetype)sharedInstance;

- (void)urlSessionTaskDidStart:(NSURLSessionTask *)task;
- (void)urlSessionTask:(NSURLSessionTask *)task totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
- (void)urlSessionTask:(NSURLSessionTask *)task didReceiveResponse:(NSURLResponse *)response ts:(int64_t)timestamp;

#if (defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0)
- (void)urlSessionTask:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics;
#endif

- (void)urlSessionTaskDidStop:(NSURLSessionTask *)task error:(NSError *)error;

@end
