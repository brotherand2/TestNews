//
//  SNDevice.m
//  sohunews
//
//  Created by lhp on 9/24/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNDevice.h"

@interface SNDevice ()
{
    BOOL isIOS7;
    BOOL isPlus;
    BOOL isPhone6;
    BOOL isPhone5;
    BOOL isPhoneX;
    int screenWidth;
    int screenHeight;
    UIDevicePlatform plat;
}

@end

@implementation SNDevice

+ (SNDevice *)sharedInstance {
    static SNDevice *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNDevice alloc] init];
    });
    return _sharedInstance;
}

- (UIDevicePlatform) getDeviceSimulatoriPhoneType {
    plat = UIDeviceSimulatoriPhone;
    if (screenWidth == 414) {
        plat = UIDevice6PlusiPhone;
    }else if (screenWidth == 375) {
        plat = UIDevice6iPhone;
        if (screenHeight == 812) {
            plat = UIDeviceiPhoneX;
        }
    }
    return plat;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        isIOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0;
        screenWidth  = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
        plat = [[UIDevice currentDevice] platformTypeForSohuNews];
#if TARGET_IPHONE_SIMULATOR
        plat = [self getDeviceSimulatoriPhoneType];
#endif
        isPlus = (plat==UIDevice6PlusiPhone || plat==UIDevice7PlusiPhone || plat == UIDevice8PlusiPhone)?YES:NO;
        isPhone6 = (plat==UIDevice6iPhone || plat==UIDevice7iPhone || plat == UIDevice8iPhone)?YES:NO;
        isPhone5 = (plat == UIDevice5GiPod || plat == UIDevice5iPhone || plat == UIDevice5CiPhone || plat == UIDevice5SiPhone || plat == UIDeviceSEiPhone) ? YES : NO;
        
        isPhoneX = (plat == UIDeviceiPhoneX)?YES:NO;
    }
    return self;
}

- (BOOL)isIOS7 {
    return isIOS7;
}

- (BOOL)isPhoneX {
    return isPhoneX;
}

- (BOOL)isPlus {
    return isPlus;
}

- (BOOL)isPhone6 {
    return isPhone6;
}

- (BOOL)isPhone5 {
    return isPhone5;
}

- (BOOL)isMoreThan320 {
    return screenWidth > 320;
}

- (int)getScreenWidth {
    return screenWidth;
}

- (UIDevicePlatform)devicePlat {
    return plat;
}

@end
