//
//  COMPNetworkReachabilityManager.m
//  Compass
//
//  Created by 李耀忠 on 25/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "COMPNetworkReachabilityManager.h"
#import "COMPReachability.h"

NSString *const COMPNetowrkReachabilityStatusChangedNotification = @"COMPNetowrkReachabilityStatusChangedNotification";

@interface COMPNetworkReachabilityManager ()

@property (nonatomic) COMPReachability *reachability;

@end

@implementation COMPNetworkReachabilityManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static COMPNetworkReachabilityManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[COMPNetworkReachabilityManager alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        COMPReachability *reachability = [COMPReachability reachabilityForInternetConnection];
        _reachability = reachability;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChanged) name:kCOMPReachabilityChangedNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reachabilityStatusChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:COMPNetowrkReachabilityStatusChangedNotification object:nil];
}

- (void)startReachabilityMonitoring {
    [self.reachability startNotifier];
}

- (void)stopReachabilityMonitoring {
    [self.reachability stopNotifier];
}

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.reachability.currentReachabilityStatus == COMPReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.reachability.currentReachabilityStatus == COMPReachableViaWiFi;
}

@end
