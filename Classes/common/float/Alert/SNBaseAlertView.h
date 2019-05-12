//
//  SNBaseAlertView.h
//  sohunews
//
//  Created by TengLi on 2017/6/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 弹窗类型枚举
 !! 此枚举的顺序由产品确定,不可随意更改顺序 !!
 */
typedef NS_ENUM(NSUInteger, SNAlertViewType) {
    SNAlertViewPasteBoardType = 0,  // 剪贴板浮层
    SNAlertViewFontSettingType,     // 字体调整浮层
    SNAlertViewUpgradeType,         // 升级浮层
    SNAlertViewPushType,            // push浮层
    SNAlertViewPushGuideType,       // push引导浮层
    SNAlertViewSpecialActivityType, // 京东等第三方活动浮层
    SNAlertViewNomalActivityType,   // 普通活动浮层
    SNAlertViewCloudSynType,        // 云同步浮层
    SNAlertViewNormalType,          // 普通弹窗(手动触发)
};

@interface SNBaseAlertView : UIView
@property (nonatomic, assign) SNAlertViewType alertViewType; // 弹窗类型

/**
  初始化弹窗并设置弹窗内容

 @param content 弹窗内容
 @return 弹窗
 */
- (instancetype)initWithAlertViewData:(id)content;

/**
 所有弹窗的弹出都使用此方法弹出
 */
- (void)showAlertView;

/**
 所有弹窗都调用此方法消失,在此方法种先实现子类代码,
 再调用 [super dismissAlertView]
 */
- (void)dismissAlertView;
@end
