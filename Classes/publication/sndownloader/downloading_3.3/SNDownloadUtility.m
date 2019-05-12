//
//  SNDownloadUtility.m
//  sohunews
//
//  Created by handy wang on 2/21/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadUtility.h"
#import "SNDownloadScheduler.h"
#import "SNSubscribeCenterService.h"

#define kShouldContinueWhenAppEntersBackground                  (0)

static UIBackgroundTaskIdentifier _backgroundTask;

@implementation SNDownloadUtility

/**
 * 标记支持后台任务：只要在要运行的代码前调用这个方法那么程序进入后台后会继续执行后面的代码直到标记为结束或超时；
 * example:
 *          [SNDownloadUtility markBgTaskAsBegin];
 *          ...costomize your code...
 */
+ (void)markBgTaskAsBegin {
    #if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    if ([self isMultitaskingSupported] && kShouldContinueWhenAppEntersBackground) {
        if (!_backgroundTask || _backgroundTask == UIBackgroundTaskInvalid) {
            _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                SNDebugLog(@"===INFO: Bg task had timeout, ready to cancel all sub and news download.");
                [[SNDownloadScheduler sharedInstance] forceAllDownloadToFailWhenEndBgTask];
                [self markBgTaskAsFinished];
            }];
        }
    }
    #endif
}

/**
 * 标记结束后台任务：只要在要运行的代码后面调用这个方法那么程序进入后台后运行完业务逻辑后就会结束后台任务；
 * example:
 *          ...costomize your code...
 *          [SNDownloadUtility markBgTaskAsFinished];
 */
+ (void)markBgTaskAsFinished {
    #if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([self isMultitaskingSupported] && kShouldContinueWhenAppEntersBackground) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_backgroundTask != UIBackgroundTaskInvalid) {
				[[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
				_backgroundTask = UIBackgroundTaskInvalid;
			}
		});
	}
    #endif
}

/**
 * 从服务器更新最新的我的订阅和所有频道数据
 */
+ (void)updateMySubsAndChannelsFromServer {
    //从服务器更新最新的我的订阅
    [[SNSubscribeCenterService defaultService] loadMySubFromServer];
    
    //从服务器更新最新的所有频道
    [SNNotificationManager postNotificationName:kRegistGoSuccess object:nil];
}

#pragma mark - Private

//判断当前设备是否支持后台任务
+ (BOOL)isMultitaskingSupported {
    UIDevice* device = [UIDevice currentDevice];
    return [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
}

@end
