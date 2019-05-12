//
//  SNRequestManagerIOS7.h
//  TT_AllInOne
//
//  Created by tt on 15/5/28.
//  Copyright (c) 2015年 tt. All rights reserved.
/*
 此类仅用于iOS7设备调用,在SNBaseRequest类中做了区分
 现网络请求底层改为如下:
 AFHTTPRequestOperationManager  ---> iOS7
 AFHTTPSessionManager           ---> iOS8及以上
 */

#import <Foundation/Foundation.h>

@class SNBaseRequest;

@interface SNRequestManagerIOS7 : NSObject

+ (SNRequestManagerIOS7 *)sharedInstance;

- (void)doRequest:(SNBaseRequest *)request;
- (void)cancelRequest:(SNBaseRequest *)request;

/**
 批量取消请求，对应的同一个mannager

 @param managerName manager对应的key
 */
- (void)batchCancelRequestWithManagerName:(NSString *)managerName;

- (void)batchRequest:(NSArray *)requests
     completionBlock:(void (^)(NSArray *requests, NSArray *responseObjects))completionBlock;

@end
