//
//  SNUserCenterGeneralLoginView.h
//  sohunews
//
//  Created by yangln on 14-9-29.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCustomTextField.h"

#define kMobileVerifyCodeTag 100
#define kMobileLoginTag 101

#define kRequestTypeLogin @"requestTypeLogin"
#define kRequestTypeVerifyCode @"requestTypeVerifyCode"
@protocol SNUserCenterGeneralLoginViewDelegate ;
@interface SNUserCenterGeneralLoginView : UIView {
    UIButton *_sendVerifyCodeButton;
    UILabel *_verifyCodeLabel;
    
    dispatch_source_t _timer;
}
@property (nonatomic,weak) id <SNUserCenterGeneralLoginViewDelegate> delegate;
@property (nonatomic, strong) SNCustomTextField *mobileNumTextField;
@property (nonatomic, strong) SNCustomTextField *verifyCodeTextField;
@property (nonatomic, strong) NSString *requestType;
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UILabel *copylabel;
@property (nonatomic, assign) BOOL isRequestFinish;

@property (nonatomic,strong) NSDictionary* phoneVerifyData;

@property (nonatomic, strong) NSString *fromType;//先这样加个区分 重构再说 wangshun (区分是否是)

@property (nonatomic, strong) NSString* type;

- (id)initWithFrame:(CGRect)frame buttonTitle:(NSString *)buttonTitle;
- (id)initWithFrame:(CGRect)frame buttonTitleWithNoSeperateLine:(NSString *)buttonTitle;
- (void)resetVerifyCodeLabelStatus;
- (void)setResignFirstResponder;
- (void)isValidateMobileNum:(NSString *)text isSendVerificode:(BOOL)isSendVerificode;
- (void)countDownTime;
- (void)setLoginButtonSatus:(BOOL)canClick;

- (void)showPhoneVerify;

@end

@protocol SNUserCenterGeneralLoginViewDelegate  <NSObject>

- (void)arrive10second;

@end


