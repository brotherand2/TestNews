//
//  SNDevice.h
//  sohunews
//
//  Created by lhp on 9/24/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNDevice : NSObject

+ (SNDevice *)sharedInstance;

- (BOOL)isIOS7;
- (BOOL)isPhoneX;
- (BOOL)isPlus;
- (BOOL)isPhone6;
- (BOOL)isPhone5;
- (int)getScreenWidth;
- (BOOL)isMoreThan320;
- (UIDevicePlatform)devicePlat;

@end
