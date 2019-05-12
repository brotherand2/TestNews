//
//  SUTranscoding.h
//  SohuUploadSDK
//
//  Created by 王荣慧 on 16/6/2.
//  Copyright © 2016年 搜狐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUUploadDefines.h"

@interface SUTranscoder : NSObject

//获取单例
+ (SUTranscoder *)sharedInstance;

// 完成block，根据errCode判定结果
typedef void (^SUTranscodeCompletionBlock)(SUTranscodeErrorCode errCode);
// 进度block
typedef void (^SUTranscodeProgressBlock)(float progress);

// 开始转码
-(void)transcodeVideo:(NSString *)sourceVideoPath andTargetVideoPath:(NSString *)targetVideoPath withCompletionblock:(SUTranscodeCompletionBlock)cblock withProgressBlock:(SUTranscodeProgressBlock)pblock;
// 取消转码
-(void)cancelTranscode;

@end
