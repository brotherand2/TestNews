//
//  SNNotificationCenter.h
//  sohunews
//
//  Created by Dan on 7/6/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//这个通知中心会发起3个通知，分别在window上显示消息，显示loading，隐藏loading
@interface SNNotificationCenter : NSObject {

}

+ (void)showMessage:(NSString *)text;//by default 1s
+ (void)showMessage:(NSString *)text hideAfter:(NSInteger)interval;

+ (void)showLoading:(NSString *)text;
+ (void)hideLoading;

+ (void)showLoadingAndBlockOtherActions:(NSString *)text;
+ (void)hideLoadingAndBlock;
//+ (void)hideLoadingAndBlockAfter:(NSInteger)interval ;

+ (void)showMessageTitle:(NSString *)text detail:(NSString *)text;//by default 1s
+ (void)showMessageTitle:(NSString *)text detail:(NSString *)text hideAfter:(NSInteger)interval;

+ (void)showExclamationTitle:(NSString *)title detail:(NSString *)detail;//by default 2s
+ (void)showExclamation:(NSString *)title;//by default 2s

+ (void)showMessageAboveKeyboard:(NSString *)text;
+ (void)showMessageAtBottom:(NSString *)text hideAfter:(NSInteger)interval;
+ (void)showMessage:(NSString *)text atPos:(CGPoint)pt hideAfter:(NSInteger)interval;
+ (void)showMessage:(NSString *)text atPos:(CGPoint)pt arrowXPosition:(CGFloat)xPos hideAfter:(NSInteger)interval;

+ (void)hideMessage;

#pragma mark -
+ (void)showMessage:(NSString *)text action:(NSString *)actionURL userInfo:(NSDictionary *)userInfo hideAfter:(NSInteger)interval;
+ (void)showMessageForFullScreenWSVideoPlayer:(NSString *)text;
+ (void)hideMessageImmediatelyForFullScreenWSVideoPlayer;
+ (void)showMessageForFullScreenWSVideoPlayer:(NSString *)text action:(NSString *)actionURL userInfo:(NSDictionary *)userInfo hideAfter:(NSInteger)interval;

#pragma mark -
+ (void)showNoWifiTitle:(NSString *)title detail:(NSString *)detail hideAfter:(NSInteger)interval;

@end