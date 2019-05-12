//
//  SNSohuPhoneLoginView.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCustomTextField.h"
#import "SNNewsLoginTextField.h"

@protocol SNSohuPhoneLoginViewDelegate;
@interface SNSohuPhoneLoginView : UIView

@property (nonatomic,weak) id <SNSohuPhoneLoginViewDelegate> delegate;

@property (nonatomic,strong) SNNewsLoginTextField* userNameTextField;
@property (nonatomic,strong) SNNewsLoginTextField* passwordTextField;
@property (nonatomic,strong) SNNewsLoginTextField* photovcodeField;

- (instancetype)initWithFrame:(CGRect)frame;

/** 关闭键盘
 */
- (void)closeKeyBoard;

/** 获取 账号 和 密码
 */
- (NSMutableDictionary*)getSohuAccountAndPassword;

/** 显示 图形验证码
 */
- (void)showPhotoVcode;

- (BOOL)isShowPhotoVcode;

- (NSString*)getPhotoVcode;

- (void)clearPassword;

@end

@protocol SNSohuPhoneLoginViewDelegate <NSObject>

- (void)sohuLoginClick:(NSDictionary*)dic;

@end
