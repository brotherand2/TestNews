//
//  SNQRUtility.h
//  HZQRCodeDemo
//
//  Created by H on 15/11/5.
//  Copyright © 2015年 Hz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SNQRViewController.h"

typedef void(^HandlePushFinishBlock)(void);
typedef void(^HandleEnterBackgroundFinishBlock)(void);

@protocol SNQRUtilityVerifyDelegate <NSObject>

/**
 *  <扫一扫> 服务端验证二维码后的结果信息。
 */
- (void)verifyFinishedWithUrl:(NSString *)url
                      message:(NSString *)msg successed:(BOOL)success;
@end

@interface SNQRUtility : NSObject
@property (nonatomic, retain) SNQRViewController *qrviewController;
@property (nonatomic, weak) id <SNQRUtilityVerifyDelegate> verifyDelegate;
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, copy) NSMutableString * picFeatureArray;
@property (nonatomic, assign) NSInteger picReqCount;

/**
 *  <扫一扫> 扫一扫公共类单例
 */
+ (SNQRUtility *)sharedInstanced;

/**
 *  <扫一扫> 发送到服务端验证解析结果
 */
+ (void)verifyOnServerWith:(NSString *)content;

/**
 *  <扫一扫> 图片解析发送到服务端验证解析结果
 */
+ (void)verifyOnServerWithImageBase64String:(NSString *)imageString
                                  fromAlbum:(BOOL)isFromAlbum;

/**
 *  <扫一扫> 设置 SNQRUtilityVerifyDelegate
 */
+ (void)delegate:(id)delegate;

/**
 *  <扫一扫·埋点> 重置用户行为统计 
 *  扫一扫功能用户行为埋点，分为两次上报，第一次为用户打开扫一扫；第二次，客户端记录用户剩下的所有行为，然后统一上报。
 */
- (BOOL)resetStat;

/**
 *  <扫一扫·埋点> 用户打开相册埋点
 */
+ (void)dotOpenAlbum;

/**
 *  <扫一扫·埋点> 获取用户打开相册统计数据
 */
+ (NSString *)getDotOpenAlbum;

/**
 *  <扫一扫·埋点> 用户打开闪光灯埋点
 */
+ (void)dotOpenLight:(BOOL)on;

/**
 *  <扫一扫·埋点> 获取用户打开闪光灯统计数据
 */
+ (NSString *)getDotOpenLight;

/**
 *  <扫一扫·埋点> 图片识别失败
 */
+ (void)dotImgReadFail;

/**
 *  <扫一扫·埋点> 获取图片识别失败统计数据
 */
+ (NSString *)getDotImgReadFail;

/**
 *  <扫一扫·埋点> 打开相册未选取图片直接退出
 */
+ (void)dotNoSelectedImg;

/**
 *  <扫一扫·埋点> 获取打开相册未选取图片直接退出的数据统计
 */
+ (NSString *)getDotNoSelectedImg;

/**
 *  收到push 先做下处理
 */
- (void)handlePushWithFinish:(HandlePushFinishBlock)finishedBlock;

/**
 *  进入后台 做些处理
 */
- (void)handleEnterBackground:(HandleEnterBackgroundFinishBlock)finishedBlock;

/*---------------------------------------------------------------------------------------------*/

/**
 *  <扫一扫> 扫一扫内部使用，外部尽量不要调用。
 */
+ (CGRect)screenBounds;

/**
 *  <扫一扫> 扫一扫内部使用，外部尽量不要调用。
 */
+ (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation;

@end
