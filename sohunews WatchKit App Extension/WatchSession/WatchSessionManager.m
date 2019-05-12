//
//  WatchSessionManager.m
//  PZWeather
//
//  Created by iEvil on 10/13/15.
//  Copyright © 2015 iEvil. All rights reserved.
//

#import "WatchSessionManager.h"
#import "SNWDefine.h"
#import "SNWTools.h"

@interface WatchSessionManager () {
    WCSession *_seesion;
}

@end

@implementation WatchSessionManager

+ (instancetype)sharedInstance {
    static WatchSessionManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[WatchSessionManager alloc] init];
    });
    
    return _shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _seesion = [WCSession defaultSession];
    }
    return self;
}

//检测是否支持
- (BOOL)p_isSessionVaild {
    if ([WCSession isSupported]) {
        return YES;
    }
    return NO;
}

//实时消息
- (BOOL)p_validReachableSession {
    if ([_seesion isReachable]) {
        return YES;
    }
    return NO;
}

- (void)startSession {
    if ([self p_isSessionVaild]) {
        _seesion.delegate = self;
        [_seesion activateSession];
    }
}

- (void)updateApplicationContext:(NSDictionary *)applicationContext {
    NSError *error;
    [_seesion updateApplicationContext:applicationContext error:&error];
}

#pragma mark -
- (void)sessionWatchStateDidChange:(WCSession *)session {
    
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    //NSString *result = [applicationContext valueForKey:@"Key"];
    //NSLog(@"%@", result);
}

- (void)sessionReachabilityDidChange:(WCSession *)session {
    if (session.reachable) {
        
    } else {
        
    }
}

- (WCSession *)session{
    return _seesion;
}

- (void)updateAppInfo{
    
    NSDictionary * msgInfo = @{snw_sessionType:snw_sessionType_getAppInfo};
   
    [_seesion sendMessage:msgInfo replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
       
        [SNWTools updateAppInfoWith:replyMessage];
    
    } errorHandler:^(NSError * _Nonnull error) {

    }];
}


@end
