//
//  SNSohuPhoneLoginView.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCustomTextField.h"

@protocol SNSohuPhoneLoginViewDelegate;
@interface SNSohuPhoneLoginView : UIView

@property (nonatomic,weak) id <SNSohuPhoneLoginViewDelegate> delegate;

@property (nonatomic,strong) SNCustomTextField* userNameTextField;
@property (nonatomic,strong) SNCustomTextField* passwordTextField;

- (instancetype)initWithFrame:(CGRect)frame;

/** 关闭键盘
 */
- (void)closeKeyBoard;

/** 获取 账号 和 密码
 */
- (NSMutableDictionary*)getSohuAccountAndPassword;

@end

@protocol SNSohuPhoneLoginViewDelegate <NSObject>

- (void)sohuLoginClick:(NSDictionary*)dic;

@end
