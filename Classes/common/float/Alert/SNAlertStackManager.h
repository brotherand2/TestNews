//
//  SNAlertStackManager.h
//  sohunews
//
//  Created by TengLi on 2017/6/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNBaseAlertView;

@interface SNAlertStackManager : NSObject

@property (nonatomic, readwrite, assign) BOOL isShowing; // 当前是否有弹窗正在显示

+ (SNAlertStackManager *)sharedAlertStackManager;

/**
 用于判断当前是否有弹窗在界面上

 @return 在弹窗弹出时返回YES,弹窗消失时设置为NO.
 */
//+ (BOOL)isAlertViewShowing;


/**
 在loading页加载出来后去请求服务端获取最新弹窗数据 (!暂未使用)
 */
//- (void)getAlertViewToStack;


/**
 检查是否有符合条件的弹窗 (此方法在每次进入 首页流/推荐流/正文页/弹窗消失后 都去调用,如果有符合条件的弹窗就弹出)

 @return 返回YES,表示当前栈里有弹窗弹出;返回NO,表示队列里没有符合条件的弹窗
 */
- (BOOL)checkoutInStackAlertView;


/**
 将弹窗加入队列
 
 @param alert 弹窗
 */
- (void)addAlertViewToAlertStack:(SNBaseAlertView *)alert;


/**
 弹窗消失,将此弹窗数据从弹窗队列里移除.
 */
- (BOOL)removeAlertViewFromAlertStack:(SNBaseAlertView *)dismissAlert;

@end
