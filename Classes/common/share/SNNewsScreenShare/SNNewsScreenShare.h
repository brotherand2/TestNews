//
//  SNNewsScreenShare.h
//  sohunews
//
//  Created by wang shun on 2017/6/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SHH5NewsWebViewController.h"
//截屏分享二维码默认url
#define SNNews_SHARE_ScreenShare_QRCode_Default_URL @"http://3g.k.sohu.com"

@interface SNNewsScreenShare : NSObject

- (instancetype)initWithImage:(UIImage*)image WithParams:(NSDictionary*)dic;

- (BOOL)isShowSelf;

- (void)reEnter;

- (void)closeScreenShare;

/**
 *  再次切图 用于 画板编辑完成
 */
- (UIImage*)clipImageAgain:(UIImage*)image;

+ (UIImage*)createQRcodeImage:(NSString*)url;

+ (UIImage *)getImageFromView:(UIView *)theView;

/**
 *  时间差
 */
+ (double)getDateInterval:(NSDate*)date1 Date2:(NSDate*)date2;

/** 是否是正文页*/
+ (SHH5NewsWebViewController*)isNewsWebPage;

@end
