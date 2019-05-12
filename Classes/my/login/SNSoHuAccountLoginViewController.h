//
//  SNSoHuAccountLoginViewController.h
//  sohunews
//
//  Created by yangln on 14-10-3.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//


#import "SNUserAccountService.h"
#import "SNUserinfoService.h"

@class SNSoHuAccountLoginRegisterViewController;

@interface SNSoHuAccountLoginViewController : SNBaseViewController<SNUserAccountLoginDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate, SNUserAccountOpenLoginUrlDelegate, SNUserinfoServiceGetUserinfoDelegate>
{
}

@property(nonatomic,strong) UIScrollView* scrollView;
@property(nonatomic,weak) SNSoHuAccountLoginRegisterViewController* accountLoginRegisterViewController;
@property (nonatomic, strong)NSString *loginFrom;
@property (nonatomic,strong) NSString* sourceChannelID;//登录来源 wangshun;

- (void)resignResponserByTag:(NSInteger)aTag;
- (void)submitLogin:(id)sender;
- (void)submitKickBack:(id)sender;

@end
