//
//  SNAppUsageStatData.h
//  sohunews
//
//  Created by XiaoShan on 11/6/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNAppUsageStatManager.h"

@interface SNAppUsageStatData : NSObject
@property(nonatomic, assign) NSTimeInterval launchingTimeInSec;
@property(nonatomic, assign) NSTimeInterval currentTimeResigningTimeInSec;
@property(nonatomic, assign) SNAppLaunchingRefer appLaunchingRefer;
@property(nonatomic, assign) NSTimeInterval lastTimeResigningTimeInSec;
@property(nonatomic, assign) NSTimeInterval rollingNewsStayDurInSec;
@property(nonatomic, assign) NSTimeInterval videosStayDurInSec;
@property(nonatomic, assign) NSTimeInterval myCenterStayDurInSec;
@property(nonatomic, assign) NSTimeInterval newsContentStayDurInSec;
@end
