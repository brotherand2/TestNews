//
//  SNBindMobileNumViewController.h
//  sohunews
//
//  Created by yangln on 14-9-29.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNUserCenterGeneralLoginView.h"
@protocol SNBindMobileNumViewControllerDelegate;
@interface SNBindMobileNumViewController : SNBaseViewController</*ASIHTTPRequestDelegate, */SNUserinfoServiceGetUserinfoDelegate> {
    SNUserinfoService *_userinfoService;
}
@property (nonatomic,weak) id <SNBindMobileNumViewControllerDelegate> arri_delegate;
@property (nonatomic, strong) SNUserCenterGeneralLoginView *loginView;
@property (nonatomic, strong) NSString *loginFrom;
@property (nonatomic, assign) SNGuideRegisterType registerType;
@property (nonatomic, weak)   id delegate;
@property (nonatomic, strong) id method;
@property (nonatomic, strong) id methodBack;

@property (nonatomic, strong) NSString *loginFromType;//先这样 等待重构 wangshun
@property (nonatomic,strong) NSString* sourceChannelID;//登录来源 wangshun;

- (id)initWithButtonTitle:(NSString *)buttonTitle;

/** 手机号登录
 */
- (id)initWithButtonTitle:(NSString *)buttonTitle WithLoginSuccessBlock:(void (^)(NSDictionary*info))loginsuccessBlock;

- (NSDictionary*)getCurrentPhoneData:(id)sender;

@end

@protocol SNBindMobileNumViewControllerDelegate <NSObject>

- (void)arrive10secondLoginRegister;

@end
