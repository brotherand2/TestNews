//
//  SNQRView.h
//  HZQRCodeDemo
//
//  Created by H on 15/11/4.
//  Copyright © 2015年 Hz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNQRMenu.h"
#import "SNQRUtility.h"
#import "SNQRFuncMenu.h"

typedef enum {
    QRDisableType_NoNetwork,    //无网络
    QRDisableType_NoResult,     //未识别到二维码
    QRDisableType_Unknown       //未知
}QRDisableType;

@protocol QRViewDelegate <NSObject>

- (void)scanTypeConfig:(SNQRItem *)item;

- (void)switchScanFunctionMode:(QRFuncType)scanType;

@end

@interface SNQRView : UIView

- (instancetype)initWithFrame:(CGRect)frame scanType:(QRFuncType)type;

@property (nonatomic, assign) CGRect translateAreaRect;
@property (nonatomic, weak) id<QRViewDelegate> delegate;
@property (nonatomic, assign) BOOL enable;

/**
 *  透明的区域
 */
@property (nonatomic, assign) CGSize transparentArea;

/**
 *  闪光灯按钮
 */
@property (nonatomic, retain) SNQRItem *ligthButton;

/**
 *  开始扫描动画。
 */
- (void)beginScanAnimation;

/**
 *  关闭扫描动画。
 */
- (void)stopScanAnimation;

/**
 *  设置无网络状态 或者未识别到二维码 扫一扫功能不可用
 *  如果enable为YES，errorType随便传
 *  如果enable为NO,errorType传相应的QRDisableType
 */
- (void)setScanEnable:(BOOL)enable errorType:(QRDisableType)errorType;
- (void)setTransparentAreaWithFuncType:(QRFuncType)funcType;

@end
