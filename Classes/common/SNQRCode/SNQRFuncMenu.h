//
//  SNQRFuncMenu.h
//  sohunews
//
//  Created by H on 16/5/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    QRFuncTypeScanQrCode,
    QRFuncTypeScanImage,
    QRFuncTypeUnknown,
} QRFuncType;

@protocol SNQRFuncMenuDelegate <NSObject>
- (void)switchScanMode:(QRFuncType)scanType;
@end

@interface SNQRFuncMenu : UIView
@property (nonatomic, weak) id <SNQRFuncMenuDelegate> scanModeDelegate;

- (void)setScanType:(QRFuncType)scanType;
- (id)initWithFrame:(CGRect)frame funcType:(QRFuncType)type;
@end
