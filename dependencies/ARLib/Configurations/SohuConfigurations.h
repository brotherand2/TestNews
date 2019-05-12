//
//  SohuConfigurations.h
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*
 需求
 1. 用户ID 客户端提供 userID
 2. 活动编号 客户端提供 不提供就默认后来来做
 3. 设备的类型
 4. 是否支持AR
 5. APP版本
 6. 操作系统
 */

@interface SohuConfigurations : NSObject

//设备信息
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSString *systemVersion;
@property (nonatomic, copy, readonly) NSString *deviceName;
@property (nonatomic, assign,readonly) BOOL enableAR;
@property (nonatomic, assign,readonly) NSString *exceptionalMessage;

//版本信息
@property (nonatomic, readonly) NSString *appVersion;
@property (nonatomic,readonly) NSString *appBundle;

//用户信息
@property (nonatomic, copy,) NSString *userID;
@property (nonatomic, copy,) NSString *activityID;


+(NSMutableDictionary *)sohuConfigurations;

@end
