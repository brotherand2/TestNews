//
//  SNCrashRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCrashRequest.h"
#import <AFNetworking.h>

@interface SNCrashRequest ()

/**
 崩溃日志
 */
@property (nonatomic, copy) NSString *crashLog;

/**
 上报地址
 */
@property (nonatomic, copy) NSString *url;
@end

@implementation SNCrashRequest

/**
 初始化方法
        
 @param dict 参数
 @param crashLog 日志
 @return 请求
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict andCrashLog:(NSString *)crashLog
{
    self = [super init];
    if (self) {
        self.crashLog = crashLog;
        self.url = [dict appendParamToUrlString:[NSString stringWithFormat:@"%@%@?",[SNAPI baseUrlWithDomain:SNLinks_Domain_BaseApiK],SNLinks_Path_CrashUpload]];
    }
    return self;
}

/**
 发送请求

 @param success 成功的回调
 @param failure 失败的回调
 */
- (void)send:(SNCrashRequestSuccessBlock)success failure:(SNCrashRequestFailureBlock)failure {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSURL* URL = [NSURL URLWithString:self.url];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self.crashLog dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Fetch Request
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        success(operation.request,response);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation.request,error);
    }];
    
    [manager.operationQueue addOperation:operation];

}

@end
