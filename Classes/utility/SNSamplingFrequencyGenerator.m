//
//  SNSamplingFrequencyGenerator.m
//  sohunews
//
//  Created by WongHandy on 8/15/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNSamplingFrequencyGenerator.h"
#import "SNUtility.h"
#import "SNAppConfigManager.h"
#import "SNAppConfigRequestMonitorConditions.h"
#import "SNAppMonitorsManager.h"
#import "SNUserLocationManager.h"

@implementation SNSamplingFrequencyGenerator

+ (SNSamplingFrequencyGenerator *)sharedInstance {
    static SNSamplingFrequencyGenerator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNSamplingFrequencyGenerator alloc] init];
        [SNNotificationManager addObserver:sharedInstance
                                                 selector:@selector(samplingIfNeeded:)
                                                     name:kSNSamplingFrequencyNotification
                                                   object:nil];
    });
    return sharedInstance;
}

#pragma mark - Private
- (void)samplingIfNeeded:(NSNotification *)notification {
    id obj = [notification object];
    if ([obj isKindOfClass:[NSURL class]]) {
        [self samplingIfNeededForRequestMonitorWithURL:(NSURL *)obj];
    }
}

- (void)samplingIfNeededForRequestMonitorWithURL:(NSURL *)url {
    BOOL canStart = [self isItTimeToSampling];
    if (canStart) {
        [SNAppMonitorsManager detachARequestMonitorURL:url method:SNRequestMonitor_RequestMethod_GET];
    }
}

#pragma mark -
- (BOOL)isItTimeToSampling {
    BOOL isItTime = NO;
    
    SNAppConfigRequestMonitorConditions *conditions = [[SNAppConfigManager sharedInstance] requestMonitorConditions];
    NSInteger conditionMonitorScale = 0;
    if (![conditions.monitorScale isEqual:[NSNull null]] && conditions.monitorScale) {
        conditionMonitorScale = conditions.monitorScale.integerValue;
    }
    if (conditionMonitorScale > 0) {
        int randomNum = arc4random()%conditionMonitorScale;
        if (randomNum == 0) {//采样率中标
            //其它采样条件组合判断
            NSString *conditionCarrier = [conditions.carrier copy];
            NSString *conditionGBCode = [conditions.gbcode copy];
            NSString *conditionNetwork = [conditions.network copy];
            NSString *conditionDevicePlatform = [conditions.devicePlatform copy];
            NSString *conditionAppVersion = [conditions.appVersion copy];
            
            NSString *currentCarrier = [[self currentDeviceCarrier] copy];
            NSString *currentGBCode = [[SNUserLocationManager sharedInstance].currentChannelGBCode copy];
            NSString *currentNetwork = [[self currentNetwork] copy];
            NSString *currentDevicePlatform = [[self currentDevicePlatform] copy];
            NSString *currentAppVersion = [[self currentAppVersion] copy];
            
            BOOL isRightCarrier = [self isCurrentCarrier:currentCarrier inConditionCarrierGroup:conditionCarrier];
            BOOL isRightGBCode = [self isCurrentGBCode:currentGBCode inConditionGBCodeGroup:conditionGBCode];
            BOOL isRightNetwork = [self isCurrentNetwork:currentNetwork inConditionNetworkGroup:conditionNetwork];
            BOOL isRightDevicePlatform = [self isCurrentDevicePlatform:currentDevicePlatform inConditionDevicePlatformGroup:conditionDevicePlatform];
            BOOL isRightAppVersion = [self isCurrentAppVersion:currentAppVersion inConditionAppVersionGroup:conditionAppVersion];
            if (isRightCarrier && isRightGBCode && isRightNetwork && isRightDevicePlatform && isRightAppVersion) {
                isItTime = YES;//其它采样条件组合判断通过，则可以采样
            }
            
            conditionCarrier = nil;
            conditionGBCode = nil;
            conditionNetwork = nil;
            conditionDevicePlatform = nil;
            conditionAppVersion = nil;
            
            currentCarrier = nil;
            currentGBCode = nil;
            currentNetwork = nil;
            currentDevicePlatform = nil;
            currentAppVersion = nil;
        }
    }
    return isItTime;
}

- (NSString *)currentDeviceCarrier {
    NSString *carrierName = [[SNUtility sharedUtility] getCarrierName];
    if (NSNotFound != [carrierName rangeOfString:@"移动" options:NSCaseInsensitiveSearch].location) {
        return @"mobile";
    } else if (NSNotFound != [carrierName rangeOfString:@"联通" options:NSCaseInsensitiveSearch].location) {
        return @"unicom";
    } else if (NSNotFound != [carrierName rangeOfString:@"电信" options:NSCaseInsensitiveSearch].location) {
        return @"telecom";
    } else {
        return @"else";
    }
}

- (NSString *)currentNetwork {
    if ([[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableViaWiFi) {
        return @"wifi";
    } else if ([[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableViaWWAN ||
               [[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableVia2G   ||
               [[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableVia3G   ||
               [[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableVia4G) {
        return @"2g,3g";
    } else {
        return @"";
    }
}

- (NSString *)currentDevicePlatform {
	UIDeviceFamily deviceFamily = [[UIDevice currentDevice] deviceFamily];
    switch (deviceFamily) {
        case UIDeviceFamilyiPhone:
            return @"iphone";
        case UIDeviceFamilyiPod:
            return @"iphone";
        case UIDeviceFamilyiPad:
            return @"ipad";
        default:
            return @"Apple";
    }
}

- (NSString *)currentAppVersion {
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    return version;
}

#pragma mark -
- (BOOL)isCurrentCarrier:(NSString *)currentCarrier inConditionCarrierGroup:(NSString *)conditionCarrierGroup  {
    
    if (currentCarrier.length <= 0 || conditionCarrierGroup.length <= 0) {
        return NO;
    }
    NSArray *conditionCarrierArray = [conditionCarrierGroup componentsSeparatedByString:@","];
    for (NSString *conditionCarrier in conditionCarrierArray) {
        if ([conditionCarrier isEqualToString:currentCarrier]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCurrentGBCode:(NSString *)currentGBCode inConditionGBCodeGroup:(NSString *)conditionGBCodeGroup {
    
    if (currentGBCode.length <= 0 || conditionGBCodeGroup.length <= 0) {
        return NO;
    }
    NSArray *conditionGBCodeArray = [conditionGBCodeGroup componentsSeparatedByString:@","];
    for (NSString *conditionGBCode in conditionGBCodeArray) {
        if ([currentGBCode startWith:conditionGBCode]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCurrentNetwork:(NSString *)currentNetworkGroup inConditionNetworkGroup:(NSString *)conditionNetworkGroup {
    
    if (currentNetworkGroup.length <= 0 || conditionNetworkGroup.length <= 0) {
        return NO;
    }
    NSArray *conditionNetworkArray = [conditionNetworkGroup componentsSeparatedByString:@","];
    NSArray *currentNetworkArray = [currentNetworkGroup componentsSeparatedByString:@","];
    for (NSString *conditionNetwork in conditionNetworkArray) {
        for (NSString *currentNetwork in currentNetworkArray) {
            if ([conditionNetwork isEqualToString:currentNetwork]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)isCurrentDevicePlatform:(NSString *)currentDevicePlatform inConditionDevicePlatformGroup:(NSString *)conditionPlatformGroup {
    
    if (currentDevicePlatform.length <= 0 || conditionPlatformGroup.length <= 0) {
        return NO;
    }
    NSArray *conditionPlatformArray = [conditionPlatformGroup componentsSeparatedByString:@","];
    for (NSString *conditionPlatform in conditionPlatformArray) {
        if ([conditionPlatform isEqualToString:currentDevicePlatform]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCurrentAppVersion:(NSString *)currentAppVersion inConditionAppVersionGroup:(NSString *)conditionAppVersionGroup {
    
    if (currentAppVersion.length <= 0 || conditionAppVersionGroup.length <= 0) {
        return NO;
    }
    NSArray *conditionAppVersionArray = [conditionAppVersionGroup componentsSeparatedByString:@","];
    for (NSString *conditionAppVersion in conditionAppVersionArray) {
        if ([conditionAppVersion isEqualToString:currentAppVersion]) {
            return YES;
        }
    }
    return NO;
}

@end
