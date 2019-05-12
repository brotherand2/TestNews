//
//  SNMessageMgr.h
//  sohunews
//
//  Created by chenhong on 13-11-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNMessageMgr : NSObject

@property(nonatomic,copy)NSString *host;
@property(nonatomic,assign)uint16_t port;

+ (SNMessageMgr *)sharedInstance;

- (void)connect;
- (void)stop;

- (BOOL)isConnected;
- (void)stopTimer;

@end
