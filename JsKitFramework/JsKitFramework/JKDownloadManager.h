//
//  JKDownloadManager.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/26.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class AFHTTPRequestOperation;

typedef void(^DownloadProgress)(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead);
typedef void(^DownloadSuccess)(AFHTTPRequestOperation *operation, NSString* filePath, id responseObject);
typedef void(^DownloadFailure)(AFHTTPRequestOperation *operation, NSString* filePath, NSError *error);

@interface JKDownloadManager : NSObject

/**
 *  开始下载文件
 *
 *  @param URLString     文件链接
 *  @param progressBlock 进度回调
 *  @param successBlock  成功回调
 *  @param failureBlock  失败回调
 *
 *  @return 下载任务
 */
+ (AFHTTPRequestOperation *)downloadFileWithURLString:(NSString *)URLString
                                        progressBlock:(DownloadProgress)progressBlock
                                         successBlock:(DownloadSuccess)successBlock
                                         failureBlock:(DownloadFailure)failureBlock;
/**
 *  暂停下载文件
 *
 *  @param operation 下载任务
 */
+ (void)pauseWithOperation:(AFHTTPRequestOperation *)operation;

/**
 *  获取文件大小
 *
 *  @param path 本地路径
 *
 *  @return 文件大小
 */
+ (unsigned long long)fileSizeForPath:(NSString *)path;

#pragma mark - 实例方法

/**
 *  开始下载文件
 *
 *  @param URLString     文件链接
 *  @param progressBlock 进度回调
 *  @param successBlock  成功回调
 *  @param failureBlock  失败回调
 *
 *  @return 下载任务
 */
- (AFHTTPRequestOperation *)downloadFileWithURLString:(NSString *)URLString
                                        progressBlock:(DownloadProgress)progressBlock
                                         successBlock:(DownloadSuccess)successBlock
                                         failureBlock:(DownloadFailure)failureBlock;
/**
 *  暂停下载文件
 *
 *  @param operation 下载任务
 */
- (void)pauseWithOperation:(AFHTTPRequestOperation *)operation;

/**
 *  获取文件大小
 *
 *  @param path 本地路径
 *
 *  @return 文件大小
 */
- (unsigned long long)fileSizeForPath:(NSString *)path;

@end
