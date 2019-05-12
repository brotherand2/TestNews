//
//  SNRegisterViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//


#import "SNUserAccountService.h"
#import "SNUserinfoService.h"

typedef enum
{
	EFail,
	EOK,
	EPending
}TState;

//@class SNLoginRegisterViewController;
@class SNSoHuAccountLoginRegisterViewController;
@interface SNRegisterViewController : SNBaseViewController<SNUserAccountRegisterDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate, SNUserinfoServiceGetUserinfoDelegate>
{
    TState _usernameState;
    NSString* _checkUserErrorTip;
    NSInteger _keyboardExHeight; //键盘的额外高度 告诉216的部分
    BOOL _tempResizeScrollView;  //是否临时扩大了 滚动区域
}

@property(nonatomic,assign) TState _usernameState;
@property(nonatomic,strong) NSString* _checkUserErrorTip;
@property(nonatomic,weak) SNSoHuAccountLoginRegisterViewController* accountLoginRegisterViewController;
@property(nonatomic,assign) BOOL _tempResizeScrollView;

-(void)resignResponserByTag:(NSInteger)aTag;
-(void)submitRegister:(id)sender;
-(void)willChangeScrollviewBack;
//-(void)loadFlushCodeIfNeed;
@end
