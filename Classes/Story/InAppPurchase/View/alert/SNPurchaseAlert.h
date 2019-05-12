//
//  SNPurchaseAlert.h
//  sohunews
//
//  Created by H on 2016/12/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SNPurchaseInAppstore, //使用appstore进行充值
    SNPurchaseInBalance, //使用财富余额进行充值
} SNPurchaseMode;

typedef void(^SNPurchaseAlertCancelEvent)();
typedef void(^SNPurchaseAlertGoOnEvent)(SNPurchaseMode purchaseMode);

@interface SNPurchaseAlert : UIView

+ (void)alertWithPrice:(NSString *)price cancelButtonEvent:(SNPurchaseAlertCancelEvent)cancelEvent goOnButtonEvent:(SNPurchaseAlertGoOnEvent)goOnEvent;

@end
