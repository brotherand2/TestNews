//
//  SNPopupActivityCenter.h
//  sohunews
//
//  Created by handy wang on 6/24/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  客户端活动中心
 */
@interface SNPopupActivityCenter : NSObject

/**
 *  获取客户端活动中心实例
 *
 *  @return 客户端活动中心实例
 */
+ (SNPopupActivityCenter *)defaultCenter;

/**
 *  提示用户有新活动发布
 */
- (void)popupActivityIfNeeded;

/**
 *  提示用户有红包活动发布
 */
- (void)popupRedPacketActivityIfNeeded;

@end