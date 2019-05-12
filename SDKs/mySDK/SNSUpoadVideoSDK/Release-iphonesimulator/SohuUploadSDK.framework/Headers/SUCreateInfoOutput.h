//
//  SUCreateInfoOutput.h
//  SohuUploadSDK
//
//  Created by 王荣慧 on 16/6/3.
//  Copyright © 2016年 搜狐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUUploadDefines.h"

@interface SUCreateInfoOutput : NSObject

// 错误码
@property (nonatomic, assign) SUUploadErrorCode errCode;

// 视频id
@property (nonatomic, copy) NSString *vid;
// 用户空间
@property (nonatomic, copy) NSString *fwd;
// 上传文件接口token
@property (nonatomic, copy) NSString *token;
// 状态码
@property (nonatomic, copy) NSString *code;
// 错误信息
@property (nonatomic, copy) NSString *errmsg;
// 视频标题
@property (nonatomic, copy) NSString *title;
// 视频标签
@property (nonatomic, copy) NSString *tag;
// 视频简介
@property (nonatomic, copy) NSString *introduction;
// categoriesId
@property (nonatomic, copy) NSString *categoriesId;
// 视频状态
@property (nonatomic, copy) NSString *videostatus;
// 是否已经上传过
@property (nonatomic, copy) NSString *isold;
// 隐私设置
@property (nonatomic, copy) NSString *plevel;
// 视频类型
@property (nonatomic, copy) NSString *videoType;
// 是否有播放限制
@property (nonatomic, copy) NSString *playLimit;

@end
