//
//  SNLocalNotifReminder.h
//  sohunews
//
//  Created by chenhong on 14-4-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNLocalNotifReminder : NSObject

// 打印当前本地通知列表
+ (void)printAllPendingLocalNotifications;

// 设置本地通知
+ (void)cancelLocalNotifications;
+ (void)setupLocalNotifications;

@end
