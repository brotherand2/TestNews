//
//  COMPNetworkReachabilityManager.h
//  Compass
//
//  Created by 李耀忠 on 25/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const COMPNetowrkReachabilityStatusChangedNotification;

@interface COMPNetworkReachabilityManager : NSObject

+ (instancetype)sharedInstance;
- (void)startReachabilityMonitoring;
- (void)stopReachabilityMonitoring;
- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

@end
