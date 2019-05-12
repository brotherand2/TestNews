//
//  COMPHelper.h
//  Compass
//
//  Created by 李耀忠 on 26/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IOS_VERSION_GREATER_THAN_OR_EQUAL_TO_10 ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 10)

@interface COMPHelper : NSObject

+ (int64_t)timestampInMiniseconds;
//+ (UIViewController*)topMostViewController;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSString *)currentDateString;

@end
