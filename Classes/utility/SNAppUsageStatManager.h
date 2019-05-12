//
//  SNAppUsageStatManager.h
//  sohunews
//
//  Created by you guess on 14-8-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SNAppUsageStatPage) {
    SNAppUsageStatPage_RollingNewsTimeline,
    SNAppUsageStatPage_VideoTimeline,
    SNAppUsageStatPage_MyCenter,
    SNAppUsageStatPage_NewsContent,
    SNAppUsageStatPageTypeCount
};

typedef NS_ENUM(NSInteger, SNAppLaunchingRefer) {
    SNAppLaunchingRefer_iCon    = 0,
    SNAppLaunchingRefer_Push    = 1 << 0,
    SNAppLaunchingRefer_Other   = 1 << 1
};

#define kAppLaunchingRefer          (@"kAppLaunchingRefer")

@interface SNAppUsageStatManager : NSObject
@property (nonatomic, assign)BOOL isFromLaunch;
+ (SNAppUsageStatManager *)sharedInstance;
- (void)statAppLaunching;
- (void)statAppResigning;
- (void)statAppLaunchingRefer:(SNAppLaunchingRefer)refer;
- (void)statEnteringPage:(id)page withPageType:(SNAppUsageStatPage)pageType;
- (void)statExitingPage:(id)page withPageType:(SNAppUsageStatPage)pageType;

@end
