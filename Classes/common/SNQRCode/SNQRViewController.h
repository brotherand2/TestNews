//
//  SNQRViewController.h
//  HZQRCodeDemo
//
//  Created by H on 15/11/5.
//  Copyright © 2015年 Hz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QRUrlBlock)(NSString *url);
typedef void(^QRHandlePushFinish)(void);

@interface SNQRViewController : UIViewController

@property (nonatomic, copy) QRUrlBlock qrUrlBlock;

- (void)didReceiveRemote:(QRHandlePushFinish)finishBlock;

- (void)didEnterBackground;

@end
