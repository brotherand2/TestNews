//
//  SNDownloadUtility.h
//  sohunews
//
//  Created by handy wang on 2/21/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDownloadUtility : NSObject

/**
 * 标记支持后台任务：只要在要运行的代码前调用这个方法那么程序进入后台后会继续执行后面的代码直到标记为结束或超时；
 * example:
 *          [SNDownloadUtility markBgTaskAsBegin];
 *          ...costomize your code...
 */
+ (void)markBgTaskAsBegin;

/**
 * 标记结束后台任务：只要在要运行的代码后面调用这个方法那么程序进入后台后运行完业务逻辑后就会结束后台任务；
 * example:
 *          ...costomize your code...
 *          [SNDownloadUtility markBgTaskAsFinished];
 */
+ (void)markBgTaskAsFinished;

/**
 * 从服务器更新最新的我的订阅和所有频道数据
 */
+ (void)updateMySubsAndChannelsFromServer;

@end