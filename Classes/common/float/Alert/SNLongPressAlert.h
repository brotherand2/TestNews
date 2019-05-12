//
//  SNLongPressAlert.h
//  sohunews
//
//  Created by ___TENG LI___ on 2017/4/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.

/*
 *  此类为正文页和大图浏览页面长按图片触发弹窗
 */

#import <Foundation/Foundation.h>

@interface SNLongPressAlert : NSObject

- (void)showLongPressAlertWithShareBlock:(void(^)())shareBlock andSaveBlock:(void(^)())saveBlock;

@end
