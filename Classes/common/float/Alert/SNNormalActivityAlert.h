//
//  SNNormalActivityAlert.h
//  sohunews
//
//  Created by TengLi on 2017/6/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseAlertView.h"

@interface SNNormalActivityAlert : SNBaseAlertView
/**
 *  缓存上次已弹过的activityID
 *
 *  @param lasttimePopupedActivityID 上次已弹过的activityID
 */
+ (void)cacheLasttimePopupedActivityID:(NSString *)lasttimePopupedActivityID;
@end
