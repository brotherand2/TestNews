//
//  SUUploadDefines.h
//  SohuUploadSDK
//
//  Created by 王荣慧 on 16/6/2.
//  Copyright © 2016年 搜狐. All rights reserved.
//

#ifndef SUUploadDefines_h
#define SUUploadDefines_h

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
    
    SUUploadVideoTimeOut = 22,//上传未完成，超过72小时，请重新创建视频
    SUUploadVideoIsCoveringCode = 23,//正在转码，不可播放
    SUUploadVideoIsCoverCodeFail = 24,//转码失败，不可播放
    SUUploadVideoIsCoverCodeSuccessPicNotFinish = 25,//转码成功，图片上传未完成，未审核
    SUUploadVideoIsCoverCodeSuccessMineWatch = 26,//转码成功，未审核，用户自已可以播放，其他人不可播放
    SUUploadVideoIsReviewUserEdit = 27,//视频审核后，用户再次编辑
    SUUploadVideoIsDeleteNoWatch= 28,//用户自己删除，不可播放
    SUUploadJiankongDeleteNoWatch = 29,//监控审核删除，不可播放
    SUUploadJianKongIsPassWatch = 30,//监控审核通过，可以播放
    SUUploadJianKongIsPassMineWatch = 31,//监控审核通过，只能自已，对外不可看
};

#endif /* SUUploadDefines_h */
