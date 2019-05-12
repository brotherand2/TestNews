//
//  SNRequestManager.m
//  TT_AllInOne
//
//  Created by tt on 15/5/28.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import "SNRequestManager.h"
#import "SNBaseRequest.h"
#import "SNNetworkConfiguration.h"
#import <libkern/OSAtomic.h>
#import "AFNetworking.h"

#define SNDefaultRequestTime 30.0

@interface SNRequestManager () {
    AFHTTPSessionManager *_requestManager;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    NSMutableArray<__kindof SNBaseRequest *> *_requestList;
    NSMutableDictionary *_requestManagerList;
#else
    NSMutableArray *_requestList;
#endif
    OSSpinLock _lock;
}

@property (nonatomic, strong) AFHTTPResponseSerializer *afHTTPResponseSerializer;
@property (nonatomic, strong) AFJSONResponseSerializer *afJSONResponseSerializer;
@property (nonatomic, strong) AFXMLParserResponseSerializer *afXMLResponseSerializer;
@property (nonatomic, strong) NSSet *acceptableContentTypes;


@end

@implementation SNRequestManager

#pragma mark 生命周期
+ (SNRequestManager *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _requestList = [NSMutableArray new];
        _requestManagerList = [NSMutableDictionary dictionary];
        _requestManager = [self createRequestManagerWithName:SNNet_Request_DefaultManager];
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (AFHTTPSessionManager *)createRequestManagerWithName:(NSString *)managerName {
    
    if ([_requestManagerList.allKeys containsObject:managerName]) {// 判断对应manager是否存在
        return [_requestManagerList objectForKey:managerName];
    }
    AFHTTPSessionManager *requestSessionManager = [AFHTTPSessionManager manager];
    [requestSessionManager.securityPolicy setAllowInvalidCertificates:YES];
    requestSessionManager.operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCountInNetwork;
    [requestSessionManager.requestSerializer setTimeoutInterval:SNDefaultRequestTime];
    requestSessionManager.responseSerializer = self.afJSONResponseSerializer;
    // 添加新的manager到字典
    OSSpinLockLock(&_lock);
    [_requestManagerList setValue:requestSessionManager forKey:managerName];
    OSSpinLockUnlock(&_lock);
    
    return requestSessionManager;
}

#pragma mark 请求相关
- (void)doRequest:(SNBaseRequest *)request {
    OSSpinLockLock(&_lock);
    [_requestList addObject:request];
    OSSpinLockUnlock(&_lock);
    // 处理拼接URL
    NSString *finalUrl = nil;
    SNNetworkConfiguration *config = [SNNetworkConfiguration sharedInstance];
    // 判断是否有自定义url
    if ([request.baseDelegate respondsToSelector:@selector(sn_customUrl)] && [request.baseDelegate sn_customUrl]) {
        finalUrl = [request.baseDelegate sn_customUrl];
    } else {
        // 处理前缀
        if ([request.baseDelegate respondsToSelector:@selector(sn_baseUrl)] && [request.baseDelegate sn_baseUrl]) {
            // 优先处理子类配置
            if ([request.baseDelegate sn_requestUrl]) {
                finalUrl = [[request.baseDelegate sn_baseUrl] stringByAppendingString:[request.baseDelegate sn_requestUrl]];
            } else {
                finalUrl = [request.baseDelegate sn_baseUrl];
            }
            
        } else if (config.baseUrl) {
            // 使用全局设置
            finalUrl = [config.baseUrl stringByAppendingString:[request.baseDelegate sn_requestUrl]];
        }
        
        // 处理后缀
        if ([request.baseDelegate respondsToSelector:@selector(sn_buildInParameters)] && [request.baseDelegate sn_buildInParameters]) {
            // 优先处理子类配置
            // 判断是否已有其他参数
            finalUrl = SNAddBuildInUrl(finalUrl, SNQueryStringFromParameters([request.baseDelegate sn_buildInParameters]));
        }
        
        // 增加全局的后缀
        if (config.buildInUrl) {
            finalUrl = SNAddBuildInUrl(finalUrl, config.buildInUrl);
        }
    }
    finalUrl = [finalUrl trim];
    if (!finalUrl || finalUrl.length == 0) return;
    if (![NSURL URLWithString:finalUrl]) return;
    
    AFHTTPSessionManager *manager = _requestManager;
    // 是否创建新的manager
    if ([request.baseDelegate respondsToSelector:@selector(sn_requestWithNewManager)]) {
        
        NSString *managerName = [request.baseDelegate sn_requestWithNewManager];
        manager = [self createRequestManagerWithName:managerName];
    }
    
    // 处理自定义header
    if ([request.baseDelegate respondsToSelector:@selector(sn_requestHTTPHeader)]) {
        NSDictionary *header = [request.baseDelegate sn_requestHTTPHeader];
        if ([header isKindOfClass:[NSDictionary class]] && header.count > 0) {
            [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    // 设置请求超时时间
    if ([request.baseDelegate respondsToSelector:@selector(sn_timeoutInterval)]) {
        [manager.requestSerializer setTimeoutInterval:[request.baseDelegate sn_timeoutInterval]];
    } else if (manager.requestSerializer.timeoutInterval != SNDefaultRequestTime) {
        [manager.requestSerializer setTimeoutInterval:SNDefaultRequestTime];
    }
    //判断返回数据类型
    switch ([request.baseDelegate sn_responseType]) {
        case SNResponseTypeJSON: {
            if (![manager.responseSerializer isMemberOfClass:[AFJSONResponseSerializer class]]) {
                manager.responseSerializer = self.afJSONResponseSerializer;
            }
            break;
        }
        case SNResponseTypeXML: {
            if (![manager.responseSerializer isMemberOfClass:[AFXMLParserResponseSerializer class]]) {
                manager.responseSerializer = self.afXMLResponseSerializer;
            }
            break;
        }
        case SNResponseTypeHTTP: {
            if (![manager.responseSerializer isMemberOfClass:[AFHTTPResponseSerializer class]]) {
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
            }
            break;
        }
    }

    [self doRequest:request withManager:manager andFinalUrl:finalUrl];
}

- (void)doRequest:(SNBaseRequest *)request
      withManager:(AFHTTPSessionManager *)requestSessionManager
      andFinalUrl:(NSString *)finalUrl {
    
    // 判断请求类型
    switch ([request.baseDelegate sn_requestMethod]) {
        case SNRequestMethodGet : {
            request.url = finalUrl;
            request.requestObject =
            [requestSessionManager GET:finalUrl parameters:([request.baseDelegate respondsToSelector:@selector(sn_parameters)] ? [request.baseDelegate sn_parameters] : nil) success:^(NSURLSessionDataTask *tas, id responseObject) {
                [self requestSucceeded:request
                        responseObject:responseObject];
            } failure:^(NSURLSessionDataTask *tas, NSError *error) {
                [self requestfailed:request error:error];
            }];
            request.url = ((NSURLSessionDataTask *)request.requestObject).currentRequest.URL.absoluteString;
        }
            break;
        case SNRequestMethodPost : {
            request.url = finalUrl;
            request.requestObject =
            [requestSessionManager POST:finalUrl parameters:([request.baseDelegate respondsToSelector:@selector(sn_parameters)] ? [request.baseDelegate sn_parameters] : nil) success:^(NSURLSessionDataTask *tas, id responseObject) {
                [self requestSucceeded:request
                        responseObject:responseObject];
            } failure:^(NSURLSessionDataTask *tas, NSError *error) {
                [self requestfailed:request error:error];
            }];
            
            request.url = ((NSURLSessionDataTask *)request.requestObject).currentRequest.URL.absoluteString;
        }
            break;
        case SNRequestMethodUpload : {
            request.url = finalUrl;
            request.requestObject =     // 此方法 Content-Type 是 multipart/form-data.
            [requestSessionManager POST:finalUrl parameters:([request.baseDelegate respondsToSelector:@selector(sn_parameters)] ? [request.baseDelegate sn_parameters] : nil) constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                if ([request.baseDelegate respondsToSelector:@selector(sn_appendFileDataWith:)]) {
                    [request.baseDelegate sn_appendFileDataWith:formData];
                }
            } success:^(NSURLSessionDataTask *tas, id responseObject) {
                [self requestSucceeded:request
                        responseObject:responseObject];
            } failure:^(NSURLSessionDataTask *tas, NSError *error) {
                [self requestfailed:request error:error];
            }];
            
            request.url = ((NSURLSessionDataTask *)request.requestObject).currentRequest.URL.absoluteString;
        }
            break;
        case SNRequestMethodDownloadFile: {
            if (!finalUrl) {
                [self requestfailed:nil error:nil];
            } else {
                AFHTTPSessionManager *_sessionManager = [AFHTTPSessionManager manager];
                [[_sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalUrl]] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    NSString *filePath = ([request.baseDelegate respondsToSelector:@selector(sn_downloadFilePath)]) ? [request.baseDelegate sn_downloadFilePath]:NSTemporaryDirectory();
                    
                    BOOL isDir = NO;
                    NSFileManager *fm = [NSFileManager defaultManager];
                    if ([fm fileExistsAtPath:filePath isDirectory:&isDir]) {
                        if (isDir) {
                            //路径正确
                        } else {
                            //传入路径为文件,使用默认路径
                            filePath = NSTemporaryDirectory();
                        }
                    } else { ///路径下不存在
                        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    
                    return [NSURL fileURLWithPath:[filePath stringByAppendingPathComponent:response.suggestedFilename]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    if (filePath) {
                        [self requestSucceeded:request
                                responseObject:[filePath path]];
                    } else {
                        [self requestfailed:request error:error];
                    }
                }] resume];
            }
        }
            break;
        default:
            break;
    }
    
    SNDebugLog(@"AFN_URL:%@",request.url);
}

- (void)batchRequest:(NSArray *)requests
     completionBlock:(void (^)(NSArray *requests, NSArray *responseObjects))completionBlock {
    __block NSUInteger count = 0;
    NSMutableArray *responseObjects = [NSMutableArray array];
    for (NSInteger i = 0; i < [requests count]; i++) {
        [responseObjects addObject:[NSNull null]];//占位
    }
    
    [requests enumerateObjectsUsingBlock:^(SNBaseRequest *request, NSUInteger idx, BOOL *stop) {
        [request send:^(SNBaseRequest *request, id responseObject) {
            count++;
            if (responseObject) {
                [responseObjects replaceObjectAtIndex:[requests indexOfObject:request] withObject:responseObject];
            }
            
            if ([requests count] == count) {
                //最终回调
                completionBlock(requests, responseObjects);
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            count++;
            if (error) {
                [responseObjects replaceObjectAtIndex:[requests indexOfObject:request] withObject:error];
            }
            if ([requests count] == count) {
                // 最终回调
                completionBlock(requests, responseObjects);
            }
        }];
    }];
}

- (void)cancelRequest:(SNBaseRequest *)request {
    // 当前使用AF 判断下类型
    if ([request.requestObject isKindOfClass:[NSURLSessionTask class]]) {
        // 取消网络
        [((NSURLSessionTask *)request.requestObject) cancel];
    }
    [self clearRequest:request];
}

- (void)batchCancelRequestWithManagerName:(NSString *)managerName {
    
    if ([_requestManagerList.allKeys containsObject:managerName]) {
        
        AFHTTPSessionManager *manager = [_requestManagerList objectForKey:managerName];
        [manager.operationQueue cancelAllOperations];
    }
}

#pragma mark 处理回调后结果
// 单个request
- (void)requestSucceeded:(SNBaseRequest *)request
          responseObject:(id)responseObject {
    if ([request.baseDelegate respondsToSelector:@selector(sn_checkResponse:responseObject:)]) {
        // 检查返回值
        BOOL f_checkResponse = [request.baseDelegate sn_checkResponse:request responseObject:responseObject];
        if (f_checkResponse) {
            if (request.successBlock) {
                @try {
                    request.successBlock(request, responseObject);
                } @catch (NSException *exception) {
                    SNDebugLog(@"SNRequestManager exception reason--%@", exception.reason);
                } @finally {
                    
                }
            }
        } else {
            // 回调失败
            // 自定义一个NSError 应该不需要__autoreleasing
            NSError *error = [NSError errorWithDomain:SNRequestCheckResponseErrorDomain code:-1 userInfo:nil];
            [self requestfailed:request error:error];
        }
    } else {
        // 没有检查返回值
        if (request.successBlock) {
            @try {
                request.successBlock(request, responseObject);
            } @catch (NSException *exception) {
                SNDebugLog(@"SNRequestManager exception reason--%@", exception.reason);
            } @finally {
                
            }
        }
    }
    [self clearRequest:request];
}

- (void)requestfailed:(SNBaseRequest *)request error:(NSError *)error {
    // 需判断 failureBlock == nil 在主动cancel的情况下, 会清空此block, 目前的设计是 当cancel后就不会进failureBlock了
    if (request.failureBlock) {
        // 如果请求失败，输出当前请求的request，错误原因，以及请求地址
        SNDebugLog(@"%@-->error:%@,url:%@",request.class,error.localizedDescription,request.url);
        request.failureBlock(request, error);
    }
    
    [self clearRequest:request];
}

- (void)clearRequest:(SNBaseRequest *)request {
    [request clearAfterFinished];
    
    OSSpinLockLock(&_lock);
    [_requestList removeObject:request];
    OSSpinLockUnlock(&_lock);
}

// 多个request
- (void)batchRequestFinished:(NSArray *)requests {
    for (SNBaseRequest *request in requests) {
        [request clearAfterFinished];
    }
    
    OSSpinLockLock(&_lock);
    [_requestList removeObjectsInArray:requests];
    OSSpinLockUnlock(&_lock);
}

- (AFHTTPResponseSerializer *)afHTTPResponseSerializer {
    if (!_afHTTPResponseSerializer) {
        @synchronized (_afHTTPResponseSerializer) {
            _afHTTPResponseSerializer = [AFHTTPResponseSerializer serializer];
            _afHTTPResponseSerializer.acceptableContentTypes = [self.acceptableContentTypes copy];
        }
    }
    return _afHTTPResponseSerializer;
}

- (AFJSONResponseSerializer *)afJSONResponseSerializer {
    if (!_afJSONResponseSerializer) {
        @synchronized (_afJSONResponseSerializer) {
            _afJSONResponseSerializer = [AFJSONResponseSerializer serializer];
            _afJSONResponseSerializer.acceptableContentTypes = self.acceptableContentTypes;
        }
    }
    return _afJSONResponseSerializer;
}

- (AFXMLParserResponseSerializer *)afXMLResponseSerializer {
    if (!_afXMLResponseSerializer) {
        @synchronized (_afXMLResponseSerializer) {
            _afXMLResponseSerializer = [AFXMLParserResponseSerializer serializer];
        }
    }
    return _afXMLResponseSerializer;
}

- (NSSet *)acceptableContentTypes {
    if (_acceptableContentTypes == nil) {
        _acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",@"image/png",@"image/gif",@"image/jpeg", nil];
    }
    return _acceptableContentTypes;
}


@end
