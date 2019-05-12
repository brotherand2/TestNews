//
//  SNCenterToast.h
//  WebViewZoomDemo
//
//  Created by Scarlett on 16/8/23.
//  Copyright © 2016年 Scalett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCenterToast : NSObject

typedef NS_ENUM(NSInteger, SNCenterToastMode) {
    SNCenterToastModeWarning,               //警告
    SNCenterToastModeSuccess,               //成功
    SNCenterToastModeError,                 //错误
    SNCenterToastModeOnlyText,            //纯文本反馈
    SNCenterToastModeLoading                //加载中
};

@property (nonatomic, assign) CGFloat verticalOffset;


+ (SNCenterToast *)shareInstance;

/**
 * 在顶层window展示Toast
 *
 * @param (NSString *)title Toast需要展示的文案
 * @param toUrl:(NSString *)url  Toast需要点击跳转的地址，默认nil
 * @param (SNToastUIMode)toastMode Toast提示模式，区分图标和用途，参考SNToastUIMode
 */
- (void)showCenterToastWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNCenterToastMode)toastMode;
- (void)showCenterToastWithTitle:(NSString *)title
                     toUrl:(NSString *)url
                  userInfo:(NSDictionary *)userInfo
                      mode:(SNCenterToastMode)toastMode;

/**
 * 在横屏全屏展示Toast
 *
 * @param (NSString *)title Toast需要展示的文案
 * @param toUrl:(NSString *)url  Toast需要点击跳转的地址，默认nil
 * @param (SNToastUIMode)toastMode Toast提示模式，用去区分图标和用途，参考SNToastUIMode
 */
- (void)showCenterToastToFullScreenViewWithTitle:(NSString *)title
                                     toUrl:(NSString *)url
                                  userInfo:(NSDictionary *)userInfo
                                      mode:(SNCenterToastMode)toastMode;

/**
 * 当前view退出，在上一层view展示Toast
 *
 * @param (NSString *)title Toast需要展示的文案
 * @param toUrl:(NSString *)url  Toast需要点击跳转的地址，默认nil
 * @param (SNToastUIMode)toastMode Toast提示模式，用去区分图标和用途，参考SNToastUIMode
 */
- (void)showCenterToastToSuperViewWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNCenterToastMode)toastMode;


- (void)showBlockUIToastWithTitle:(NSString *)title toUrl:(NSString *)url mode:(SNCenterToastMode)toastMode;

/**
 * 当指定view上展示Toast
 * @param (UIView *)targetView toast宿主view
 * @param (NSString *)title Toast需要展示的文案
 * @param toUrl:(NSString *)url  Toast需要点击跳转的地址，默认nil
 * @param (SNToastUIMode)toastMode Toast提示模式，用去区分图标和用途，参考SNToastUIMode
 */
- (void)showCenterToastToTargetView:(UIView *)targetView
                        title:(NSString *)title
                        toUrl:(NSString *)url
                     userInfo:(NSDictionary *)userInfo
                         mode:(SNCenterToastMode)toastMode;

/**
 * 在顶层window展示Toast
 *
 * @param (NSString *)title Toast需要展示的文案
 * @param toProfile:   是否跳转到profile页面
 * @param (SNToastUIMode)toastMode Toast提示模式，区分图标和用途，参考SNToastUIMode
 */
- (void)showCenterToastToProfileViewWithTitle:(NSString *)title
                              toProfile:(BOOL)toProfile
                               userInfo:(NSDictionary *)userInfo
                                   mode:(SNCenterToastMode)toastMode
                               callBack:(void(^)(void))callBack;
/**
 *  在顶层window展示Toast 自定义button title
 *
 *  @param title       toats文案
 *  @param toProfile   是否跳转到profile 页
 *  @param buttonTitle 自定义button title
 */
- (void)showCenterToastToProfileViewWithTitle:(NSString *)title
                              toProfile:(BOOL)toProfile
                               userInfo:(NSDictionary *)userInfo
                                   mode:(SNCenterToastMode)toastMode
                           customButton:(NSString *)buttonTitle
                               callBack:(void(^)(void))callBack;

/**
 加载loading

 @param title toast文案
 @param event cancelbutton的点击事件
 */
- (void)showCenterLoadingToastWithTitle:(NSString *)title
                      cancelButtonEvent:(void(^)(void))event;

/**
 取消loading状态
 */
- (void)hideCenterLoadingToast;


/**仅用于弹出toast 手动关闭
 */
- (void)showWithTitle:(NSString *)title;
- (void)hideToast;

@end
