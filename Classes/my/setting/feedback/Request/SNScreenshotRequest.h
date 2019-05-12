//
//  SNScreenshotRequest.h
//  sohunews
//
//  Created by 李腾 on 2016/12/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//  获取截屏权限的请求类

#import "SNDefaultParamsRequest.h"

@interface SNScreenshotRequest : SNDefaultParamsRequest

@property (nonatomic, strong) UIImage *screenShotImage;


+ (instancetype)sharedInstance;
/**
 *  截屏反馈操作
 */
+ (void)getScreenShotToFeedBack;

/**
 *  截屏分享
 */
+ (void)getScreenShotToShare;
+ (void)getScreenShotToShareWithAnimation:(UIImage*)image WithData:(NSDictionary*)data;

+ (void)closeScreenShotToShare;

@end


