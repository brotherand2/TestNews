//
//  SNRequestManager.h
//  TT_AllInOne
//
//  Created by tt on 15/5/28.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNBaseRequest;

@interface SNRequestManager : NSObject

+ (SNRequestManager *)sharedInstance;

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
