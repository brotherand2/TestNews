//
//  SNNotificationHandler.h
//  sohunews
//
//  Created by handy wang on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAPNSHandler : NSObject

+ (SNAPNSHandler *)sharedInstance;

//处理Push来的数据，打开
- (void)handleReciveNotifyWithFromBack:(BOOL)fromBack;

//接受到的push数据，弹出alert框选择‘关闭’、‘显示’之前调用
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end
