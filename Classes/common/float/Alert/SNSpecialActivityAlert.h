//
//  SNJDActivityAlert.h
//  sohunews
//
//  Created by TengLi on 2017/6/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseAlertView.h"
#import "SNSpecialActivity.h"

typedef void(^SNSpecialAlertDismissCompletedBlock)();

@interface SNSpecialActivityAlert : SNBaseAlertView

@property (nonatomic, assign) SNFloatingADType adType;

@property (nonatomic, assign, readonly) BOOL isShowing;

/**
 广告资源图片是否可以正确展示

 @return YES:可以正确展示
 */
- (BOOL)adResourceAvailable;

- (void)dismissAlertViewCompleted:(SNSpecialAlertDismissCompletedBlock)dismissCompleted;

@end
