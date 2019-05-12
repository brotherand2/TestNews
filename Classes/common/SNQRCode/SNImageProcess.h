//
//  SNImageProcess.h
//  sohunews
//
//  Created by H on 16/5/18.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNImageProcess : NSObject

+ (NSString *)getFingerPrint:(UIImage *)image;

+ (NSString *)getFingerPrintImageBuffer:(CVImageBufferRef) imageBuffer;

+ (UIImage *) compressImage:(UIImage *)image withWidth:(size_t)scaleWidth;

+ (UIImage*)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect ;

//缩图
+ (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)targetWidth ;

// 根据size截取图片中间矩形区域的图片 这里的size是正方形
+ (UIImage *)cutCenterImage:(UIImage *)image size:(CGSize)size;

/**
 * 截取部分图像
 *
 **/
+ (UIImage*)getSubImage:(UIImage *)image mCGRect:(CGRect)mCGRect centerBool:(BOOL)centerBool;

/**
 *  旋转图片
 */
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

@end
