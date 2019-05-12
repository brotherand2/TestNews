//
//  SNBookRequest.h
//  sohunews
//
//  Created by H on 2016/11/22.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  请求类型
 */
typedef NS_ENUM(NSInteger, SNBookRequestMethod) {
    /**
     * Get
     */
    SNBookRequestMethodGet,
    /**
     * Post
     */
    SNBookRequestMethodPost,
    /**
     *  下载文件
     */
    SNBookRequestMethodDownloadFile
};

/**
 *  返回类型
 */
typedef NS_ENUM(NSInteger, SNBookResponseType) {
    /**
     * XML
     */
    SNBookResponseTypeXML,
    /**
     * JSON
     */
    SNBookResponseTypeJSON,
    /**
     * Http
     */
    SNBookResponseTypeHTTP
};

@protocol SNBookRequestDelegate <NSObject>
@optional
//用于文件上传
//[formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/png"];
- (void)appendFileDataWith:(id<AFMultipartFormData>)formData;

@end

@class SNBookRequest;

typedef void(^SNBookNetworkSuccessBlock)(SNBookRequest *request, id responseObject);
typedef void(^SNBookNetworkFailureBlock)(SNBookRequest *request, NSError *error);

@interface SNBookRequest : NSObject

@property (copy, nonatomic) SNBookNetworkSuccessBlock successBlock;
@property (copy, nonatomic) SNBookNetworkFailureBlock failureBlock;
@property (nonatomic, copy, readonly) NSString * url;

@property (nonatomic, weak) id<SNBookRequestDelegate>delegate;

/**
 请求类型 GET or POST
 */
@property (assign, nonatomic) SNBookRequestMethod requestMethod;

/**
 返回类型 XML or JSON
 */
@property (assign, nonatomic) SNBookResponseType responseType;

/**
 业务具体对应的url地址，不包含baseUrl和buildInParameters
 如 "/api/channel/push.go"
 */
@property (copy, nonatomic) NSString * requestUrl;

/**
 如果设置了自定义url，则此url优先级最高。需要完整的url。
 */
@property (copy, nonatomic) NSString * customUrl;

/**
 统一的url前缀，如果不重写，就走全局配置 @"http://api.k.soho.com"
 */
@property (copy, nonatomic) NSString * baseUrl;

/**
 超时，默认30s
 */
@property (assign, nonatomic) CGFloat timeoutInterval;

/**
 下载文件所需要提供的文件存储本地的地址
 如果不实现默认放到 NSTemporaryDirectory() tmp文件夹下
 文件下载到的目标文件夹路径 [注意是存在的文件夹，文件名字会自动生成，如果目标路径不存在则会自动创建]
 */
@property (copy, nonatomic) NSString * downloadFilePath;

/**
 请求中携带的具体参数，如果当前请求是get类型，会自动转成 "key=value" 拼在url后面 (直接套用了AF中的默认机制)
 */
@property (strong, nonatomic) NSDictionary * parameters;

/**
 每次请求都会添加的一些默认参数
 */
@property (strong, nonatomic) NSDictionary * buildInParameters;

/**
 添加header
 */
@property (strong, nonatomic) NSDictionary * requestHTTPHeader;

/**
 AFN默认不支持@"text/plain"ContentType，可以在这里手动添加。
 */
@property (strong, nonatomic) NSArray *excessResponseSerializerAcceptableContentTypes;

/**
 * 2.x底层原始请求对象 当前在AFNetworking中为 AFHTTPRequestOperation
 * 3.0 为 NSURLSessionTask
 */
@property (strong, nonatomic) id requestObject;


#pragma mark 外部调用
- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (void)send:(SNBookNetworkSuccessBlock)success
     failure:(SNBookNetworkFailureBlock)failure;

- (void)cancel;

/**
 *  回调block完成后 做一些清理工作 比如 block = nil
 */
- (void)clearAfterFinished;

@end
