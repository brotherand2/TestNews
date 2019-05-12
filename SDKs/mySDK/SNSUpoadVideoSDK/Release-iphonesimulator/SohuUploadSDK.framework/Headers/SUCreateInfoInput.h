//
//  SUInfo.h
//  SohuUploadSDK
//
//  Created by 王荣慧 on 16/6/1.
//  Copyright © 2016年 搜狐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUCreateInfoInput : NSObject

// 视频本地文件路径
@property (nonatomic, copy) NSString *localPath;
// 上传来源
@property (nonatomic, copy) NSString *uploadFrom;
// 视频标题(最大50）
@property (nonatomic, copy) NSString *title;
// 隐私级别设置（0、任何人可看 1、所有者的关注者可看 2、密码验证 3、仅限自己可看）(非必填)
@property (nonatomic, copy) NSString *plevel;
// 视频所属分类(非必填）
@property (nonatomic, copy) NSString *cateCode;
// 视频描述(非必填，最大1000）
@property (nonatomic, copy) NSString *desp;
// 用户信息token
@property (nonatomic, copy) NSString *token;
// 用户通行证
@property (nonatomic, copy) NSString *passport;
// 设备的唯一ID
@property (nonatomic, copy) NSString *gid;
// 设备的IMEI号(非必填)
@property (nonatomic, copy) NSString *imei;
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

@end
