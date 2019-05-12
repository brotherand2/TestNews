//
//  SNPhoneLoginView.h
//  sohunews
//
//  Created by wang shun on 2017/3/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SNCustomTextField.h"
#import "SNNewsLoginTextField.h"

@protocol SNPhoneLoginViewDelegate;
@interface SNPhoneLoginView : UIView
{
    dispatch_source_t _timer;
}
@property (nonatomic,weak) id <SNPhoneLoginViewDelegate> delegate;

@property (nonatomic,strong) SNNewsLoginTextField* phoneField;//手机号
@property (nonatomic,strong) SNNewsLoginTextField* vcodeField;//验证码
@property (nonatomic,strong) SNNewsLoginTextField* pcodeField;//图形验证码

@property (nonatomic,strong) UIButton* sendVerifyCodeBtn;//发送验证码
@property (nonatomic,strong) UILabel* verifyCodeLabel;//倒计时文案
@property (nonatomic,strong) UIButton* photoVcode;//图形验证码

- (instancetype)initWithFrame:(CGRect)frame;

/** 获取 手机号(phone) 和 验证码(vcode)
 */
- (NSMutableDictionary*)getPhoneAndVcode;


/** 倒计时开始计时/关闭倒计时 发送验证码接口成功后调用
 */
- (void)countDownTime;

/** 清空验证码
 */
- (void)clearVerifyCode;

/** 关闭键盘
 */
- (void)closeKeyBoard;

/** becomefirst 验证码
 */
- (void)becomefirstVcodeTextfield;

/** 显示 图形验证码
 */
- (void)showPhotoVcode;

/** 隐藏 图形验证码
 */
- (void)hidePhotoVcode;

@end

@protocol SNPhoneLoginViewDelegate <NSObject>

- (void)sendVerifyCodeClick:(NSDictionary*)params;

- (void)arrive10second;

- (void)haveVerifyCode:(NSString*)text;

//图形验证码验证发送短信验证码
- (void)verifyPhotoCodeAndSendVcode:(NSString*)text;

@end
