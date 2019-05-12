//
//  SNAdStatisticsManager.h
//  sohunews
//
//  Created by jialei on 14-8-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNStatInfo.h"
#import "SNStatExposureInfo.h"
#import "SNStatClickInfo.h"
#import "SNStatLoadInfo.h"
#import "SNStatEmptyInfo.h"
#import "SNStatUninterestedInfo.h"

@interface SNAdStatisticsManager : NSObject

+ (SNAdStatisticsManager *)shareInstance;

- (void)uploadAdSDKParamEvent:(SNStatInfo *)statInfo;
- (void)uploadAdSDKParamEventSync:(SNStatInfo *)statInfo;

@end
