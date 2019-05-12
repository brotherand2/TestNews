//
//  JKDownloadManager.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/26.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKDownloadManager.h"
#import "JsKitFramework.h"
#import "AFNetworking.h"
@interface JKDownloadManager ()

@property (nonatomic, strong) NSMutableArray *paths;

@end

@implementation JKDownloadManager

- (NSMutableArray *)paths {
    
    if (!_paths) {
        
        _paths = [[NSMutableArray alloc] init];
    }
    
    return _paths;
}

#pragma mark - 类方法

+ (unsigned long long)fileSizeForPath:(NSString *)path {
    
    return [[self alloc] fileSizeForPath:path];
}

+ (AFHTTPRequestOperation *)downloadFileWithURLString:(NSString *)URLString progressBlock:(DownloadProgress)progressBlock successBlock:(DownloadSuccess)successBlock failureBlock:(DownloadFailure)failureBlock {
    
    return [[self alloc] downloadFileWithURLString:URLString
                                     progressBlock:progressBlock
                                      successBlock:successBlock
                                      failureBlock:failureBlock];
}

+ (void)pauseWithOperation:(AFHTTPRequestOperation *)operation {
    
    [[self alloc] pauseWithOperation:operation];
}

#pragma mark - 实例方法

- (unsigned long long)fileSizeForPath:(NSString *)path {
    
    signed long long fileSize = 0;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path]) {
        
        NSError *error = nil;
        
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        
        if (!error && fileDict) {
            
            fileSize = [fileDict fileSize];
        }
    }
    
    return fileSize;
}

- (AFHTTPRequestOperation *)downloadFileWithURLString:(NSString *)URLString progressBlock:(DownloadProgress)progressBlock successBlock:(DownloadSuccess)successBlock failureBlock:(DownloadFailure)failureBlock {
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL* URL = [NSURL URLWithString:URLString];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:[URL path]];
    
    NSString* fileDir = [filePath stringByDeletingLastPathComponent];
    BOOL existed = [fileManager fileExistsAtPath:fileDir isDirectory:&isDir];
    
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5*60];
    unsigned long long downloadedBytes = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        // 获取已下载的文件长度
        downloadedBytes = [self fileSizeForPath:filePath];
        
        // 检查文件是否已经下载了一部分
        if (downloadedBytes > 0) {
            
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    
    // 不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    // 下载请求
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // 检查是否已经有该下载任务. 如果有, 释放掉...
    for (NSDictionary *dic in self.paths) {
        
        if ([filePath isEqualToString:dic[@"path"]] && ![(AFHTTPRequestOperation *)dic[@"operation"] isPaused]) {
            
            return dic[@"operation"];
            
        } else {
            
            [(AFHTTPRequestOperation *)dic[@"operation"] cancel];
        }
    }
    NSDictionary *dicNew = @{@"path"        : filePath,
                             @"operation"   : operation};
    [self.paths addObject:dicNew];
    
    // 下载路径
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    
    if (progressBlock) {
        // 下载进度回调
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            
            // 下载进度
            CGFloat progress = ((CGFloat)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
            
            progressBlock(progress, (totalBytesRead + downloadedBytes) / 1024 / 1024.0f, (totalBytesExpectedToRead + downloadedBytes) / 1024 / 1024.0f);
        }];
    }
    
    // 成功和失败回调
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        successBlock(operation,filePath, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failureBlock(operation,filePath, error);
    }];
    
    [operation start];
    
    // 为了做暂停，把这个下载任务返回
    return operation;
}

- (void)pauseWithOperation:(AFHTTPRequestOperation *)operation {
    
//    JSLog(@"Pause download");
    
    [operation pause];
}

@end
