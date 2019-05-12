//
//  SUUploadDefines.h
//  SohuUploadSDK
//
//  Created by 王荣慧 on 16/6/2.
//  Copyright © 2016年 搜狐. All rights reserved.
//

#ifndef SUUploadDefines_h
#define SUUploadDefines_h

typedef NS_ENUM(NSInteger, SUTranscodeErrorCode) {
    // 转码成功
    SUTranscodeErrorCodeSuccess = 0,
    // 转码失败
    SUTranscodeErrorCodeFailure,
    // 文件过大，超过4G
    SUTranscodeErrorCodeFileTooBig,
    // 文件打开错误
    SUTranscodeErrorCodeFileOpenError,
    // 文件格式不支持转码
    SUTranscodeErrorCodeFileNotSupport,
    // 系统低于8.0，不支持转码
    SUTranscodeErrorCodeFeatureNotSupport,
};

typedef NS_ENUM(NSInteger, SUUploadErrorCode) {
    // 成功
    SUUploadErrorCodeSuccess = 0,
    // 网络不可用
    SUUploadErrorCodeNetworkUnavailable,
    // 视频信息不存在
    SUUploadErrorCodeVideoNotExist,
    // 服务器有误
    SUUploadErrorCodeServerError,
    // 读取数据失败
    SUUploadErrorCodeDataBufferNull,
    // 取消
    SUUploadErrorCodeCancel,
    // 文件过大，超过4G
    SUUploadErrorCodeFileTooBig,
    // 文件打开错误
    SUUploadErrorCodeFileOpenError,
    // 视频已经上传
    SUUploadErrorCodeVideoAlreadyUploaded,
    // 内容包含国家有关部门所禁止的内容
    SUUploadErrorCodeVideoForbiddenWords,
    // 标题为空
    SUUploadErrorCodeTitleEmpty,
    // 参数错误
    SUUploadErrorCodeWrongParameter,
    // 账号被封禁
    SUUploadErrorCodeUserIsFrozen,
    // 用户未登陆
    SUUploadErrorCodeUserNotLogin,
    // 用户被禁止上传视频
    SUUploadErrorCodeUserForbidUpload,
    //请登录账号绑定手机号
    SUUploadErrorCodePassportNotBindPhone,
};

#endif /* SUUploadDefines_h */
