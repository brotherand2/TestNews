//
//  SNBaseRequest.h
//  TT_AllInOne
//
//  Created by tt on 15/5/27.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"

#pragma once
/**
 *  请求类型
 */
typedef NS_ENUM(NSInteger, SNRequestMethod) {
    /**
     * Get
     */
    SNRequestMethodGet,
    /**
     * Post
     */
    SNRequestMethodPost,
    /**
     *  上传文件
     */
    SNRequestMethodUpload,
    /**
     *  下载文件
     */
    SNRequestMethodDownloadFile
};

/**
 *  请求类型
 */
typedef NS_ENUM(NSInteger, SNResponseType) {
    /**
     * XML
     */
    SNResponseTypeXML,
    /**
     * JSON
     */
    SNResponseTypeJSON,
    /**
     * Http
     */
    SNResponseTypeHTTP
};

@class SNBaseRequest;


@protocol SNRequestProtocol <NSObject>

@required
/**
 *  get or post ?
 *
 *  @return 请求类型
 */
- (SNRequestMethod)sn_requestMethod;

/**
 *  数据返回类型
 *
 *  @return XML or JSON
 */
- (SNResponseType)sn_responseType;

@optional

/**
 *  业务具体对应的url地址，不包含baseUrl和buildInParameters
 如 "/api/channel/push.go"
 注：sn_requestUrl和sn_customUrl 子类需至少实现一个！
 *
 *  @return 地址
 */
- (NSString *)sn_requestUrl;

/**
 *  如果重写了，会忽略baseUrl、buildInParameters和sn_requestUrl，一般访问第3方网址用，与自身业务无关
 注：sn_requestUrl和sn_customUrl 子类需至少实现一个！
 *
 *  @return 需要访问的完整地址
 */
- (NSString *)sn_customUrl;

/**
 *  下载文件所需要提供的文件存储本地的地址
 *  如果不实现默认放到 NSTemporaryDirectory() tmp文件夹下
 *  @return 文件下载到的目标文件夹路径 [注意是存在的文件夹，文件名字会自动生成，如果目标路径不存在则会自动创建]
 */
- (NSString *)sn_downloadFilePath;

/**
 *  请求中携带的具体参数，如果当前请求是get类型，会自动转成 "key=value" 拼在url后面 (直接套用了AF中的默认机制)
 目前数据结构需要是 dictionary
 *
 *  @return 字典
 */
- (id)sn_parameters;

/**
 *  统一的url前缀，如果不重写，就走全局配置
 *
 *  @return 前缀地址
 */
- (NSString *)sn_baseUrl;

/**
 *  超时，默认30s
 *
 *  @return 超时时间
 */
- (CGFloat)sn_timeoutInterval;

/**
 *  每次请求都添加的一些默认参数
 *
 *  @return 后缀地址
 */
- (id)sn_buildInParameters;

/**
 *  是否对初始收到的response做统一的检查，比如判断状态码，统一的code判断等
 *
 *  @return YES or NO
 */
- (BOOL)sn_checkResponse:(SNBaseRequest *)request responseObject:(id)responseObject;

/**
 *  添加自定义的header
 *
 *  @return dict格式
 */
- (NSDictionary *)sn_requestHTTPHeader;

/**
 *  上传文件二进制数据
 *  
 *  [formData appendPartWithFileData:<#(NSData *)#> name:<#(NSString *)#> fileName:<#(NSString *)#> mimeType:<#(NSString *)#>]
 */
- (void)sn_appendFileDataWith:(id<AFMultipartFormData>)formData;


/**
 为了解决AFN不支持@"text/plain"ContentType的问题

 @return 包含ContentType（NSString类型）的数组
 */
- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes;


/**
 创建新的manager，便于对请求进行操作（取消）

 @return manager对应key，用于标记
 */
- (NSString *)sn_requestWithNewManager;

@end

@protocol SNDataFormatProtocol <NSObject>

/**
 *  格式化返回接口返回的直接数据数据
 *
 *  @param request        取回调中
 *  @param responseObject 取回调中
 *
 *  @return 自定义model 字典等
 */
+ (id)formatDataWithRequest:(SNBaseRequest *)request
             responseObject:(id)responseObject;

@end

typedef void(^SNNetworkSuccessBlock)(SNBaseRequest *request, id responseObject);
typedef void(^SNNetworkFailureBlock)(SNBaseRequest *request, NSError *error);


@interface SNBaseRequest : NSObject

@property (copy, nonatomic) SNNetworkSuccessBlock successBlock;
@property (copy, nonatomic) SNNetworkFailureBlock failureBlock;
@property (copy, nonatomic) NSString *url;

/**
 * 2.x底层原始请求对象 当前在AFNetworking中为 AFHTTPRequestOperation
 * 3.0 为 NSURLSessionTask
 */
@property (strong, nonatomic) id requestObject;

@property (weak, nonatomic) id<SNRequestProtocol> baseDelegate;

/**
 * 暴露一个可变字典的参数字典，方便外部传递参数
 */
@property (strong, nonatomic) NSMutableDictionary *parametersDict;


#pragma mark 外部调用
- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (void)send:(SNNetworkSuccessBlock)success
     failure:(SNNetworkFailureBlock)failure;

- (void)cancel;

/**
 *  回调block完成后 做一些清理工作 比如 block = nil
 */
- (void)clearAfterFinished;

@end

