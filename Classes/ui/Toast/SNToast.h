//
//  SNToast.h
//  sohunews
//
//  Created by jialei on 14-10-18.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//  For ARC


#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SNToastUIMode) {
    SNToastUIModeWarning,               //警告
    SNToastUIModeSuccess,               //成功
    SNToastUIModeFeedBackCommon,        //通用反馈
    SNToastUIModeFeedBackRefresh,       //下拉刷新反馈
    SNToastUIModeFeedBackAudio,         //语音反馈
    SNToastUIModeFeedBackLogin,         //登陆反馈
    SNToastUIModeFeedBackPraise         //好评反馈
};

typedef NS_ENUM(NSInteger, SNToastLayoutType) {
    SNToastLayoutTypeBelowStatusBar,
    SNToastLayoutTypeTop
};

@interface SNToast : NSObject

+ (SNToast *)shareInstance;

- (void)setPosition:(SNToastLayoutType)currentPosition;

/**
 * 在顶层window展示Toast
 *
 * @param (NSString *)title Toast需要展示的文案
 * @param toUrl:(NSString *)url  Toast需要点击跳转的地址，默认nil
 * @param (SNToastUIMode)toastMode Toast提示模式，区分图标和用途，参考SNToastUIMode
 */
- (void)showToastWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNToastUIMode)toastMode;
- (void)showToastWithTitle:(NSString *)title
                     toUrl:(NSString *)url
                  userInfo:(NSDictionary *)userInfo
                      mode:(SNToastUIMode)toastMode;

/**
 * 在横屏全屏展示Toast
 *
 * @param (NSString *)title Toast需要展示的文案
 * @param toUrl:(NSString *)url  Toast需要点击跳转的地址，默认nil
 * @param (SNToastUIMode)toastMode Toast提示模式，用去区分图标和用途，参考SNToastUIMode
 */
- (void)showToastToFullScreenViewWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNToastUIMode)toastMode;
- (void)showToastToFullScreenViewWithTitle:(NSString *)title
                                     toUrl:(NSString *)url
                                  userInfo:(NSDictionary *)userInfo
                                      mode:(SNToastUIMode)toastMode;

/**
 * 当前view退出，在上一层view展示Toast
 *
 * @param (NSString *)title Toast需要展示的文案
 * @param toUrl:(NSString *)url  Toast需要点击跳转的地址，默认nil
 * @param (SNToastUIMode)toastMode Toast提示模式，用去区分图标和用途，参考SNToastUIMode
 */
- (void)showToastToSuperViewWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNToastUIMode)toastMode;


- (void)showBlockUIToastWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNToastUIMode)toastMode;

/**
 * 当指定view上展示Toast
 * @param (UIView *)targetView toast宿主view
 * @param (NSString *)title Toast需要展示的文案
 * @param toUrl:(NSString *)url  Toast需要点击跳转的地址，默认nil
 * @param (SNToastUIMode)toastMode Toast提示模式，用去区分图标和用途，参考SNToastUIMode
 */
- (void)showToastToTargetView:(UIView *)targetView
                        title:(NSString *)title
                        toUrl:(NSString *)url
                     userInfo:(NSDictionary *)userInfo
                         mode:(SNToastUIMode)toastMode;

/**
 * 在顶层window展示Toast
 *
 * @param (NSString *)title Toast需要展示的文案
 * @param toProfile:   是否跳转到profile页面
 * @param (SNToastUIMode)toastMode Toast提示模式，区分图标和用途，参考SNToastUIMode
 */
- (void)showToastToProfileViewWithTitle:(NSString *)title
                                 toProfile:(BOOL)toProfile
                                  userInfo:(NSDictionary *)userInfo
                                      mode:(SNToastUIMode)toastMode
                                   callBack:(void(^)(void))callBack;
/**
 *  在顶层window展示Toast 自定义button title
 *
 *  @param title       toats文案
 *  @param toProfile   是否跳转到profile 页
 *  @param buttonTitle 自定义button title
 */
- (void)showToastToProfileViewWithTitle:(NSString *)title
                              toProfile:(BOOL)toProfile
                               userInfo:(NSDictionary *)userInfo
                                   mode:(SNToastUIMode)toastMode
                           customButton:(NSString *)buttonTitle
                               callBack:(void(^)(void))callBack;
/**
 * 隐藏Toast
 */
- (void)hideToast;

@end
