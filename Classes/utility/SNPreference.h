//
//  SNPreference.h
//  sohunews
//
//  Created by Dan Cong on 5/9/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNPreferenceStatus.h"

static NSString *const kProductID = @"1";


@interface SNPreference : NSObject

@property(nonatomic)BOOL autoFullscreenMode;
@property(nonatomic)int pictureMode;
@property(nonatomic)int videoMode;
@property(nonatomic)BOOL webpEnabled;

@property(nonatomic, strong)NSString *basicAPIDomain;
@property(nonatomic, strong)NSString *circleAPIDomain;
@property(nonatomic, copy)NSString *productId;
@property(nonatomic, copy)NSString *marketId;
@property(nonatomic, assign)BOOL videoAdTestServerEnabled;
@property(nonatomic, assign)BOOL simulateRoadnaviEnabled;
@property(nonatomic, assign)BOOL simulateCloudSyncEnabled;
@property(nonatomic, assign)BOOL simulateOnLineEnabled;
@property(nonatomic)BOOL testModeEnabled;
@property(nonatomic)BOOL debugModeEnabled;
@property(nonatomic)BOOL memUsageEnabled;
@property(nonatomic)BOOL bandwidthEnabled;
@property(nonatomic)BOOL touchDetectEnabled;
@property (nonatomic, assign) BOOL appInspectorEnabled; // 开启app监测（内存/cpu等）
@property (nonatomic, assign) BOOL adScreenshotSwitch; // 广告截屏专版开关
+ (SNPreference *)sharedInstance;

- (SNPreferenceStatus *)loadAndCheckChanged;

@end
