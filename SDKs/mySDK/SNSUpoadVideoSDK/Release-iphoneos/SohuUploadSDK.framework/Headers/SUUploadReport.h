//
//  SUUploadReport.h
//  SohuUploadSDK
//
//  Created by Liqun Wu on 2017/7/5.
//  Copyright © 2017年 搜狐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUUploadReport : NSObject
//视频id
@property (nonatomic, copy) NSString *vid;
//分辨率
@property (nonatomic, copy) NSString *resolution;
//宽高比
@property (nonatomic, copy) NSString *whRatio;
//封转格式
@property (nonatomic, copy) NSString *sealedFormat;
//视频编码
@property (nonatomic, copy) NSString *videoCode;
//音频 编码
@property (nonatomic, copy) NSString *audioCode;
//手机型号
@property (nonatomic, copy) NSString *phoneModel;
//app 版本号
@property (nonatomic, copy) NSString *appVersion;
//系统版本号
@property (nonatomic, copy) NSString *sysVersion;
//视频时长
@property (nonatomic, copy) NSString *length;
//旋转
@property (nonatomic, copy) NSString *rotate;
@end
