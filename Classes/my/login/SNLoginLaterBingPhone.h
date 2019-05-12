//
//  SNLoginLaterBingPhone.h
//  sohunews
//
//  Created by wang shun on 2017/3/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//
//  wangshun 登录后绑定手机 2017.3.6
//  api/share/v5/thirdPartyLogin.go

#import <Foundation/Foundation.h>

#define SNLogin_ThirdLogin_LoginType_MobileNum @"21" //手机登录
#define SNLogin_ThirdLogin_LoginType_WeChat    @"22" //微信登录
#define SNLogin_ThirdLogin_LoginType_QQ        @"23" //QQ登录
#define SNLogin_ThirdLogin_LoginType_Sina      @"24" //微博登录
#define SNLogin_ThirdLogin_LoginType_Sohu      @"25" //邮箱登录


@protocol SNLoginLaterBingPhoneDelegate;

@interface SNLoginLaterBingPhone : NSObject

@property (nonatomic,weak) id <SNLoginLaterBingPhoneDelegate> delegate;

@property (nonatomic,strong) NSDictionary* userInfo;

- (instancetype)initWithDelegate:(id <SNLoginLaterBingPhoneDelegate>)del;

- (void)bindThirdPartyLogin:(NSDictionary*)params;

@end

@protocol SNLoginLaterBingPhoneDelegate <NSObject>

- (void)openBindPhoneViewControllerData:(NSDictionary*)dic WithUserInfo:(NSDictionary*)userinfo;

- (void)loginSuccessed:(NSDictionary*)data;

@end
