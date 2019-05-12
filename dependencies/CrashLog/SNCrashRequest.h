//
//  SNCrashRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/2/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

typedef void(^SNCrashRequestSuccessBlock)(NSURLRequest *request, id responseObject);
typedef void(^SNCrashRequestFailureBlock)(NSURLRequest *request, NSError *error);

@interface SNCrashRequest : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict andCrashLog:(NSString *)crashLog;

- (void)send:(SNCrashRequestSuccessBlock)success failure:(SNCrashRequestFailureBlock)failure;

@end
