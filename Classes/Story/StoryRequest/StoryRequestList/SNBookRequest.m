//
//  SNBookRequest.m
//  sohunews
//
//  Created by H on 2016/11/22.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#define kSNBookBaseUrl  [SNAPI rootUrl:@""]

#import "SNBookRequest.h"
#import "SNStoryUtility.h"
#import "AFHTTPSessionManager.h"

static inline NSString * SNQueryStringFromParameters(id params) {
    if ([params isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *parts = [NSMutableArray array];
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id<NSObject> obj, BOOL *stop) {
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *encodedValue = [[obj description] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
            [parts addObject:part];
        }];
        return [parts componentsJoinedByString:@"&"];
    } else if ([params isKindOfClass:[NSString class]]) {
        return params;
    }
    return params;
}

static inline NSString * SNAddBuildInUrl(NSString *originStr, NSString *buildInStr) {
    if ([originStr rangeOfString:@"?"].location != NSNotFound) {
        return [originStr stringByAppendingFormat:@"&%@",buildInStr];
    } else {
        return [originStr stringByAppendingFormat:@"?%@",buildInStr];
    }
}

@interface SNBookRequest ()

@property (strong, nonatomic) AFHTTPSessionManager * manager;

@end

@implementation SNBookRequest

- (instancetype)init {
    if (self = [super init]) {
        self.manager = [AFHTTPSessionManager manager];
        self.timeoutInterval = 0;
    }
    return  self;
}

- (NSDictionary *)baseParameters {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    /*
     测试服passport
     token f1faff89ed91ef24e22b2e093611fb90
     gid 0101011106000186cba9abc1f97f072e928bb8d45d23c0
     p1 NjIyMjM0MDkxOTExNTgyMTExNA==
     pid 6044410714889039978
     */
//    NSString * p1 = @"NjIyMjM0MDkxOTExNTgyMTExNA=="; //[SNStoryUtility getP1];
//    NSString * pid = @"6044410714889039978";//[SNStoryUtility getPid];
//    NSString * token = @"f1faff89ed91ef24e22b2e093611fb90";//[SNStoryUtility getToken];
//    NSString * u = [SNStoryUtility getU];
//    NSString * gid = @"0101011106000186cba9abc1f97f072e928bb8d45d23c0";//[SNStoryUtility getGid];
//    NSString * apiVer = [NSString stringWithFormat:@"%d", APIVersion];
    
    NSString * p1 = [SNStoryUtility getP1];
    NSString * pid = [SNStoryUtility getPid];
    NSString * token = [SNStoryUtility getToken];
    NSString * u = [SNStoryUtility getU];
    NSString * gid = [SNStoryUtility getGid];
    NSString * apiVer = [NSString stringWithFormat:@"%d", APIVersion];

    /*
     p1	String
     用户唯一标识
     
     pid	Long
     用户 passport 对应的 pid
     
     apiVersion	Integer
     版本号
     
     u	Integer
     productId产品 id
     
     token	String	
     passport登录用户 token
     
     gid	String	
     gid
     */
    [parameters setObject:p1 ? p1:@"" forKey:@"p1"];
    [parameters setObject:pid ? pid:@"" forKey:@"pid"];
    [parameters setObject:gid ? gid:@"" forKey:@"gid"];
    [parameters setObject:u ? u:@"" forKey:@"u"];
    [parameters setObject:apiVer ? apiVer:@"" forKey:@"apiVersion"];
    [parameters setObject:token ? token:@"" forKey:@"token"];

    return parameters;
}

- (void)doRequest {

    NSString * finalUrl = nil;
    //判断自定义url
    if (self.customUrl.length > 0) {
        finalUrl = self.customUrl;
    }else{
        //url前缀
        if (self.baseUrl.length > 0) {
            if (self.requestUrl.length > 0) {
                finalUrl = [self.baseUrl stringByAppendingString:self.requestUrl];
            }else{
                finalUrl = self.baseUrl;
            }
        }else{
            //使用默认hosturl
            NSString * rootUrl = [[SNAPI rootScheme] stringByAppendingString:SNLinks_Domain_ProductDomain];
            finalUrl = [rootUrl stringByAppendingFormat:@"/%@",self.requestUrl];
        }
        
        //url后缀
        if (self.buildInParameters.count > 0) {
            finalUrl = SNAddBuildInUrl(finalUrl, SNQueryStringFromParameters(self.buildInParameters));
        }
        
    }
    finalUrl = [finalUrl trim];
    
    SNDebugLog(@"SNBookRequest -------- : \n url = %@",finalUrl);
    
    //处理header
    if (self.requestHTTPHeader.count > 0) {
        [self.requestHTTPHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    //返回数据类型
    switch (self.responseType) {
        case SNBookResponseTypeJSON:
        {
            self.manager.responseSerializer = [AFJSONResponseSerializer new];
            break;
        }
        case SNBookResponseTypeXML:
        {
            self.manager.responseSerializer = [AFXMLParserResponseSerializer new];
            break;
        }
        case SNBookResponseTypeHTTP:
        {
            self.manager.responseSerializer = [AFHTTPResponseSerializer new];
            break;
        }
        default:
            break;
    }
    
    //设置responseSerializer.acceptableContentTypes
    if (self.excessResponseSerializerAcceptableContentTypes.count > 0) {
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:self.excessResponseSerializerAcceptableContentTypes];
    }
    
    //设置请求超时
    if (self.timeoutInterval != 0) {
        [self.manager.requestSerializer setTimeoutInterval:self.timeoutInterval];
    }else{
        [self.manager.requestSerializer setTimeoutInterval:30];
    }
    
    //添加base参数
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:[self baseParameters]];
    [parameters setValuesForKeysWithDictionary:self.parameters];
    
    //设置请求类型
    switch (self.requestMethod) {
        case SNBookRequestMethodGet:
        {
            _url = finalUrl;
            self.requestObject = [self.manager GET:finalUrl parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                [self requestSucceeded:responseObject];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self requestFailed:error];
            }];
            _url = ((NSURLSessionTask *)self.requestObject).currentRequest.URL.absoluteString;
            break;
        }
        case SNBookRequestMethodPost:
        {
            _url = finalUrl;
            self.requestObject = [self.manager POST:finalUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(appendFileDataWith:)]) {
                    [self.delegate appendFileDataWith:formData];
                }
                
            } success:^(NSURLSessionDataTask *task, id responseObject) {
                [self requestSucceeded:responseObject];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self requestFailed:error];
            }];
            _url = ((NSURLSessionTask *)self.requestObject).currentRequest.URL.absoluteString;
            break;
        }
        case SNBookRequestMethodDownloadFile:
        {
            if (!finalUrl) {
                [self requestFailed:nil];
            }else{
                [[self.manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalUrl]] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    
                    NSString *filePath = self.downloadFilePath.length > 0 ? self.downloadFilePath:NSTemporaryDirectory();
                    
                    BOOL isDir = NO;
                    NSFileManager * fm = [NSFileManager defaultManager];
                    
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
                        [self requestSucceeded:[filePath path]];
                    } else {
                        [self requestFailed:error];
                    }
                
                }] resume];
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)clear {
    [self clearAfterFinished];
}

- (void)requestSucceeded:(id)responseObject {
    self.successBlock(self,responseObject);
    [self clear];
}

- (void)requestFailed:(NSError *)error {
    self.failureBlock(self,error);
    [self clear];
}

#pragma mark 对外
- (void)send:(SNBookNetworkSuccessBlock)success
     failure:(SNBookNetworkFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    [self doRequest];
}

- (void)cancel {
    if ([self.requestObject isKindOfClass:[NSURLSessionTask class]]) {
        [((NSURLSessionTask *)self.requestObject) cancel];
    }
    [self clear];
}

- (void)clearAfterFinished {
    self.successBlock = nil;
    self.failureBlock = nil;
}

@end
