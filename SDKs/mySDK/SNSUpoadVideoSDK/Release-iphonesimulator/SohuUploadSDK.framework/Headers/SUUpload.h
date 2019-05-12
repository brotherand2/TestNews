//
//  SUUploadRequest.h
//  SohuUploadSDK
//
//  Created by 王荣慧 on 16/5/31.
//  Copyright © 2016年 搜狐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUUploadDefines.h"
#import "SUCreateInfoOutput.h"
#import "SUCreateInfoInput.h"
#import "SUUploadInfoInput.h"

@interface SUUpload : NSObject

// 创建视频信息block，返回SUCreateInfoOutput信息
typedef void(^SUCreateVideoCompleteHandler)(SUUpload *sender, SUCreateInfoOutput *outPut);
// 根据SUCreateInfoInput创建视频信息
-(void)createVideo:(SUCreateInfoInput *)input withCompleteHandler:(SUCreateVideoCompleteHandler)completeHandler;

// 上传结束block
typedef void(^SUUploadCompleteHandler)(SUUpload *sender, SUUploadErrorCode errCode);
// 上传进度block
typedef void(^SUUploadProgressHandler)(SUUpload *sender, UInt64 countOfBytesSent, UInt64 countOfBytesTotal);
// 根据SUUploadInfoInput启动上传，通过block反馈上传进度及其结束信息
-(void)startUpload:(SUUploadInfoInput *)input withCompleteHandler:(SUUploadCompleteHandler)cblock withProgressBlock:(SUUploadProgressHandler)pblock;

// 取消上传，通过结束block返回cancel信息
-(void)cancelUpload;

// 模拟登陆，未来删除，请不要在正式版本使用
-(void)login:(NSString*)userName andPassword:(NSString *)passWord andResult:(void(^)(NSDictionary* dic))fun;
@end
