//
//  SNHalfPhoneView.h
//  sohunews
//
//  Created by wang shun on 2017/10/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNNewsLoginTextField.h"

@protocol SNHalfPhoneViewDelegate;
@interface SNHalfPhoneView : UIView
{
    dispatch_source_t _timer;
}
@property (nonatomic,weak) id <SNHalfPhoneViewDelegate> delegate;

@property (nonatomic,strong) SNNewsLoginTextField* phoneField;//手机号
@property (nonatomic,strong) SNNewsLoginTextField* vcodeField;//验证码
@property (nonatomic,strong) SNNewsLoginTextField* pcodeField;//图形验证码

@property (nonatomic,strong) UIButton* sendVerifyCodeBtn;//发送验证码
@property (nonatomic,strong) UILabel* verifyCodeLabel;//倒计时文案
@property (nonatomic,strong) UIButton* photoVcode;//图形验证码

- (instancetype)initWithFrame:(CGRect)frame;

- (void)hiddenPassword:(BOOL)show;

/** 获取 手机号(phone) 和 验证码(vcode)
 */
- (NSMutableDictionary*)getPhoneAndVcode;


/** 倒计时开始计时/关闭倒计时 发送验证码接口成功后调用
 */
- (void)countDownTime;

/** 清空验证码
 */
- (void)clearVerifyCode;

/** 重置验证码
 */
- (void)resetVerifyCodeLabelStatus;

/** 关闭键盘
 */
- (void)closeKeyBoard;

- (void)becomeFirstPasswordKeyBoard;

/** 显示 图形验证码
 */
- (void)showPhotoVcode;

/** 隐藏 图形验证码
 */
- (void)hidePhotoVcode;

@end

@protocol SNHalfPhoneViewDelegate <NSObject>

- (void)sendVerifyCodeClick:(NSDictionary*)params;

- (void)arrive10second;

- (void)showHalfThirdView:(BOOL)show;

- (void)loginClick:(id)sender;

//图形验证码验证发送短信验证码
- (void)verifyPhotoCodeAndSendVcode:(NSString*)text;

@end
