//
//  SUUploadInfoInput.h
//  SohuUploadSDK
//
//  Created by 王荣慧 on 16/6/3.
//  Copyright © 2016年 搜狐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUUploadInfoInput : NSObject

// 本地视频的文件地址
@property (nonatomic, copy) NSString *localPath;

// 上传视频id
@property (nonatomic, copy) NSString *vid;
// 用户信息token
@property (nonatomic, copy) NSString *token;
// 用户通行证
@property (nonatomic, copy) NSString *passport;
// 设备的唯一ID
@property (nonatomic, copy) NSString *gid;
// 上传来源
@property (nonatomic, copy) NSString *uploadFrom;

@property (nonatomic, copy) NSString *appVer;
// 快转方式（后台转码设置，非必须，未设置时默认后端转码）
/*
* 1.原画不转，转其它低版本，(已实现)
* 2.超清不转，转其它低版本（未实现）
* 3.高清不转，转其它低版本（未实现）
* 4.标清不转, 转low版本（未实现）
* 11.原画不转，无其它低版本（未实现）
* 12.超清不转，无其它低版本（未实现）
* 13.高清不转，无其它低版本（未实现）
* 14.标清不转，也无low版本（已实现）
*/
@property (nonatomic, copy) NSString *fastTranscode;

//appid	passport分配	移动端登陆参数
@property (nonatomic, copy) NSString * appid;
//ua	客户端ua-在客户端缓存中存在 移动端登陆参数
@property (nonatomic, copy) NSString * ua;

@end
