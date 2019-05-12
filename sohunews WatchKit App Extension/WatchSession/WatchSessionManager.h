//
//  WatchSessionManager.h
//  PZWeather
//
//  Created by iEvil on 10/13/15.
//  Copyright © 2015 iEvil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface WatchSessionManager : NSObject<WCSessionDelegate>
+ (WatchSessionManager *)sharedInstance;

- (void)startSession;
- (void)updateApplicationContext:(NSDictionary *)applicationContext;

/**
 *  从 iOS APP 获取p1、host url等信息
 *  SNWTools会进行存储
 *  想要获得具体信息可到SNWTools中获得
 */
- (void)updateAppInfo;

@end
