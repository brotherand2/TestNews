//
//  SNStoryToast.h
//  sohunews
//
//  Created by chuanwenwang on 2016/11/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SNStoryToast : NSObject

+ (SNStoryToast *)shareInstance;

/**
 * 在顶层window展示Toast
 *
 * @param title Toast需要展示的文案
 * @param url  Toast需要点击跳转的地址，默认nil
 */
- (void)showToastWithTitle:(NSString *)title toUrl:(NSString *)url showTime:(float)showTime rect:(CGRect)rect;
- (void)showToastWithTitle:(NSString *)title toUrl:(NSString *)url userInfo:(NSDictionary *)userInfo showTime:(float)showTime rect:(CGRect)rect;


/**
 * 当前view退出，在上一层view展示Toast
 *
 * @param title Toast需要展示的文案
 * @param url  Toast需要点击跳转的地址，默认nil
 */
- (void)showToastToSuperViewWithTitle:(NSString *)title toUrl:(NSString *)url showTime:(float)showTime rect:(CGRect)rect;

/**
 * 当指定view上展示Toast
 * @param targetView toast宿主view
 * @param title Toast需要展示的文案
 * @param url  Toast需要点击跳转的地址，默认nil
 */
- (void)showToastToTargetView:(UIView *)targetView title:(NSString *)title toUrl:(NSString *)url userInfo:(NSDictionary *)userInfo showTime:(float)showTime rect:(CGRect)rect;


/**
 * 隐藏Toast
 */
- (void)hideToast;

@end
