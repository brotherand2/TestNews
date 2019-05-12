//
//  SNOpenWayManager.h
//  sohunews
//
//  Created by wangyy on 15/5/4.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAppIconTp              @"10001"
#define kAppleWatchTP           @"10002"
#define kTodaywidget            @"10003"
#define kApplePushTp            @"10004" //普通
#define kAppFromH5Tp            @"10005"
#define kAppBecomeActive        @"10006"

#define kAppIcon                @"icon"
#define kAppPush                @"push"
#define kAppH5                  @"browser"
#define kOther                  @"other"


@interface SNOpenWayManager : NSObject

@property (nonatomic,assign) BOOL hotstart;

+ (SNOpenWayManager *)sharedInstance;
- (void)analysisAndPostURL:(NSString *)urlString from:(NSString *)fromType openOrigin:(NSString *)openOrigin;
+ (void)setAppLeaveTime:(NSDate *)leaveTime;

@end
