//
//  SNUserCenterGeneralLoginView.m
//  sohunews
//
//  Created by yangln on 14-9-29.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNUserCenterGeneralLoginView.h"
#import "SNMobileValidateRequest.h"
#import "SNLabel.h"
#import "SNNewsLoginPhoneVerifyBtn.h"
#import "SNNewsRecordLastLogin.h"

#define kCountDownTime 60
#define kTextFieldWidth (kAppScreenWidth - 160)
#define kMobileTag 1000
#define kVerifyCodeTag 1001
#define kSeperateLineTag 1002
#define kLoginButtonTag 1003
#define kRightMobileNum @"30020001"//手机号正确：30020001
#define kWrongMobileNum @"30020002"//手机号错误：30020002
#define kEmptyMobileNum @"30020003"//手机号为空：30020003

@interface SNUserCenterGeneralLoginView ()<SNNewsLoginPhoneVerifyBtnDataSource,UITextFieldDelegate>

@property (nonatomic,strong) SNNewsLoginPhoneVerifyBtn* phoneVerifyBtn;
@property (nonatomic,strong) UIImageView* line;

@end

@implementation SNUserCenterGeneralLoginView

- (id)initWithFrame:(CGRect)frame buttonTitleWithNoSeperateLine:(NSString *)buttonTitle {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = SNUICOLOR(kThemeBg3Color);
        self.buttonTitle = buttonTitle;
        if (![buttonTitle isEqualToString:kImmediatelyLogin]) {
            [self createBindCopy];
        }

        [self creatTextField:@"手机号" placeHolder:@"请输入手机号" labelTag:kMobileTag];
        [self creatTextField:@"验证码" placeHolder:@"请输入验证码" labelTag:kVerifyCodeTag];
        [self sendVerifyCodeLabel:@"发送验证码"];
        
        [self createLoginButton:self.buttonTitle];
        
        //说是怕泄露用户手机号 又去掉了 wangshun 2018.9.15
        //如果有上次登录手机号
//        NSDictionary* dic = [SNNewsRecordLastLogin getLastLogin:nil];
//        if (dic) {
//            NSString* phoneNumber = [dic objectForKey:@"mobile"];
//            if (phoneNumber && [phoneNumber isKindOfClass:[NSString class]]) {
//                _mobileNumTextField.text = phoneNumber;
//                
//                [self createLastLoginPhone];
//                
//                [SNNotificationManager addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_mobileNumTextField];
//            }
//        }
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame buttonTitle:(NSString *)buttonTitle {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = SNUICOLOR(kThemeBg3Color);
        self.buttonTitle = buttonTitle;
        if (![buttonTitle isEqualToString:kImmediatelyLogin]) {
            [self createBindCopy];
        }
        [self creatTextField:@"手机号" placeHolder:@"请输入手机号" labelTag:kMobileTag];
        [self creatTextField:@"验证码" placeHolder:@"请输入验证码" labelTag:kVerifyCodeTag];
        [self sendVerifyCodeLabel:@"发送验证码"];
       
        [self createPhoneVerify:154];
        [self setSeperateLine];
        
        [self createLoginButton:self.buttonTitle];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)showPhoneVerify{
    self.phoneVerifyBtn.hidden = NO;
    [self.line setFrame:CGRectMake(0, 199.5, kAppScreenWidth, 0.5)];
}

- (void)createPhoneVerify:(CGFloat)height{
    self.phoneVerifyBtn = [[SNNewsLoginPhoneVerifyBtn alloc] initWithFrame:CGRectMake(0, height+14, self.frame.size.width, 15)];
    self.phoneVerifyBtn.dataSource = self;
    [self addSubview:self.phoneVerifyBtn];
    self.phoneVerifyBtn.hidden = YES;
}

- (NSDictionary *)getCurrentPhoneNumberData{
    NSString* type = [self.phoneVerifyData objectForKey:@"type"];
    NSDictionary* dic = @{@"mobileNo":self.mobileNumTextField.text,@"type":type};
    return dic;
}

- (void)createLastLoginPhone{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    titleLabel.text = @"上次使用";
    [titleLabel sizeToFit];
    titleLabel.tag = 507;
    titleLabel.textColor = SNUICOLOR(kThemeText3Color);
    [self addSubview:titleLabel];
    [titleLabel setFrame: CGRectMake(kAppScreenWidth-titleLabel.size.width-14, 27, titleLabel.size.width, 21)];
}

- (void)textFieldDidChange:(NSNotification *)notification{
    if ([self.buttonTitle isEqualToString:kImmediatelyLogin]) {
        if (_mobileNumTextField) {
            SNDebugLog(@"textField.text:%@",_mobileNumTextField.text);
            if (!_mobileNumTextField.text || [_mobileNumTextField.text isEqualToString:@""]) {
                UILabel* label = [self viewWithTag:507];
                label.hidden = YES;
            }
        }
    }
}

- (void)creatTextField:(NSString *)title placeHolder:(NSString *)placeHolder labelTag:(NSInteger)labelTag {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:16.0];
    titleLabel.text = title;
    titleLabel.tag = labelTag;
    [titleLabel sizeToFit];
    titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    [self addSubview:titleLabel];
    
    if(!_mobileNumTextField) {
        if ([self.buttonTitle isEqualToString:kImmediatelyLogin]) {
            titleLabel.origin = CGPointMake(14,26);
        }
        else {
            titleLabel.origin = CGPointMake(14,self.copylabel.bottom + 26);
        }
        
        _mobileNumTextField = [[SNCustomTextField alloc] initWithFrame:CGRectMake(titleLabel.origin.x+titleLabel.size.width+16, titleLabel.origin.y+2, kTextFieldWidth, titleLabel.size.height)];
        _mobileNumTextField.placeholder = placeHolder;
        _mobileNumTextField.keyboardType = UIKeyboardTypeNumberPad;
        _mobileNumTextField.font = [UIFont systemFontOfSize:13.0];
        _mobileNumTextField.textColor = SNUICOLOR(kThemeText4Color);
        [self addSubview:_mobileNumTextField];
    }
    else if (!_verifyCodeTextField) {
        if ([self.buttonTitle isEqualToString:kImmediatelyLogin]) {
            titleLabel.origin = CGPointMake(14,49+titleLabel.size.height);
        }
        else {
            titleLabel.origin = CGPointMake(14,49+titleLabel.size.height + self.copylabel.bottom);
        }
        
        _verifyCodeTextField = [[SNCustomTextField alloc] initWithFrame:CGRectMake(titleLabel.origin.x+titleLabel.size.width+16, titleLabel.origin.y+2, kTextFieldWidth, titleLabel.size.height)];
        _verifyCodeTextField.placeholder = placeHolder;
        _verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _verifyCodeTextField.font = [UIFont systemFontOfSize:13.0];
        _verifyCodeTextField.textColor = SNUICOLOR(kThemeText4Color);
        [self addSubview:_verifyCodeTextField];
    }
}

- (void)createLoginButton:(NSString *)title {
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = [UIColor clearColor];
    [loginButton setTitle:title forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    loginButton.tag = kLoginButtonTag;
    [loginButton sizeToFit];
    loginButton.left = (kAppScreenWidth-loginButton.width)/2;
    loginButton.bottom = 154;
    //loginButton.bottom = 154;
    
    [loginButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:loginButton];
    
    //    UILabel *tipLbl = [[UILabel alloc] init];
    //    tipLbl.backgroundColor = [UIColor clearColor];
    //    tipLbl.textColor = SNUICOLOR(kThemeText3Color);
    //    tipLbl.text = kMobileTip;
    //    tipLbl.font = [UIFont systemFontOfSize:11];
    //    tipLbl.textAlignment = 1;
    //    [tipLbl sizeToFit];
    //    tipLbl.frame = CGRectMake(0,CGRectGetMaxY(loginButton.frame)+6, self.frame.size.width, tipLbl.frame.size.height);
    //    [self addSubview:tipLbl];
}

- (void)createBindCopy {
    self.copylabel = [[UILabel alloc] init];
    self.copylabel.backgroundColor = [UIColor clearColor];
    self.copylabel.textColor = SNUICOLOR(kThemeText3Color);
    self.copylabel.text = kMobileBindCopy;
    self.copylabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [self.copylabel sizeToFit];
    self.copylabel.top = 10;
    self.copylabel.left = 14;
    [self addSubview:self.copylabel];
}

- (void)loginClick {
    [self setLoginButtonSatus:NO];
    [self setResignFirstResponder];
    
    [self loginRequest];
    [SNNotificationManager postNotificationName:kVerifyCodeAndMobileNumClickNotification object:nil];
}

- (void)sendVerifyCodeLabel:(NSString *)text {
    _sendVerifyCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendVerifyCodeButton.backgroundColor = [UIColor clearColor];
    [_sendVerifyCodeButton setTitle:text forState:UIControlStateNormal];
    [_sendVerifyCodeButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
    [_sendVerifyCodeButton addTarget:self action:@selector(sendVerifyCodeClick:) forControlEvents:UIControlEventTouchUpInside];
    _sendVerifyCodeButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:_sendVerifyCodeButton];
    
    _verifyCodeLabel = [[UILabel alloc] init];
    _verifyCodeLabel.backgroundColor = [UIColor clearColor];
    _verifyCodeLabel.textColor = SNUICOLOR(kThemeText2Color);
    _verifyCodeLabel.text = text;
    _verifyCodeLabel.font = [UIFont systemFontOfSize:13.0];
    [_verifyCodeLabel sizeToFit];
    _verifyCodeLabel.userInteractionEnabled = NO;
    [_sendVerifyCodeButton addSubview:_verifyCodeLabel];
    
    CGRect rect = CGRectZero;
    
    if ([self.buttonTitle isEqualToString:kImmediatelyLogin]) {
        rect = CGRectMake(kAppScreenWidth-_verifyCodeLabel.size.width-14, 85-_verifyCodeLabel.size.height, _verifyCodeLabel.size.width, _verifyCodeLabel.size.height);
    }
    else {
        rect = CGRectMake(kAppScreenWidth-_verifyCodeLabel.size.width-14, 85-_verifyCodeLabel.size.height + self.copylabel.bottom, _verifyCodeLabel.size.width, _verifyCodeLabel.size.height);
    }
    
    _sendVerifyCodeButton.frame = rect;
    _verifyCodeLabel.text = nil;
}

- (void)sendVerifyCodeClick:(id)sender {
    [self setResignFirstResponder];
    
    //发送验证码请求
    [self sendVerifyCodeRequest];
    [SNNotificationManager postNotificationName:kVerifyCodeAndMobileNumClickNotification object:nil];
}

- (void) sendVerifyCodeRequest {
    _requestType = kRequestTypeVerifyCode;
    [SNNotificationManager postNotificationName:kSendVerifyCodeNotification object:self.fromType];
}

- (void) loginRequest {
    _requestType = kRequestTypeLogin;
    [SNNotificationManager postNotificationName:kMobileNumLoginNotification object:self.fromType];
}

//校验是否为手机号
- (void)isValidateMobileNum:(NSString *)text isSendVerificode:(BOOL)isSendVerificode {
    
    [[[SNMobileValidateRequest alloc] initWithDictionary:@{@"mobileNo":text}] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        [self setLoginButtonSatus:YES];
        
        NSString *status = [responseObject stringValueForKey:@"statusCode" defaultValue:nil];
        NSMutableDictionary *dictInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isSendVerificode], kIsSendVerifyCodeKey, nil];
        if ([status isEqualToString:kRightMobileNum]) {
            [dictInfo setObject:[NSNumber numberWithBool:YES] forKey:kCheckMobileNumResultKey];
            [SNNotificationManager postNotificationName:kCheckMobileNumResultNotification object:self.fromType userInfo:dictInfo];
        }
        else if ([status isEqualToString:kWrongMobileNum] || [status isEqualToString:kEmptyMobileNum]) {
            [dictInfo setObject:[NSNumber numberWithBool:NO] forKey:kCheckMobileNumResultKey];
            [SNNotificationManager postNotificationName:kCheckMobileNumResultNotification object:self.fromType userInfo:dictInfo];
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
}

- (BOOL)regexMatch:(NSString *)regetString matchText:(NSString *)matchText{
    BOOL isValidateNum = NO;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regetString];
    isValidateNum = [pred evaluateWithObject:matchText];
    return isValidateNum;
}

#pragma mark count-down time
- (void)countDownTime {
    __block int timeout = kCountDownTime; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if (timeout<=0) { //倒计时结束，关闭
            [self resetVerifyCodeLabelStatus];
        }
        else {
            
            if (timeout == 50) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(arrive10second)]) {
                    [self.delegate arrive10second];
                }
            }
            
            int seconds = timeout % (kCountDownTime+1);
            NSString *strTime = [NSString stringWithFormat:@"已发送%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示
                _sendVerifyCodeButton.titleLabel.text = nil;
                _sendVerifyCodeButton.userInteractionEnabled = NO;
                _verifyCodeLabel.text = strTime;
            });
            
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (void)resetVerifyCodeLabelStatus {
    if(!_timer)
        return;
    dispatch_source_cancel(_timer);
    //    dispatch_release(_timer);
    _timer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        //设置界面的按钮显示
        _verifyCodeLabel.text = nil;
        _sendVerifyCodeButton.userInteractionEnabled = YES;
        _sendVerifyCodeButton.titleLabel.text = @"发送验证码";
    });
}

- (void)setSeperateLine {
    UIImageView *sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 169.5, kAppScreenWidth, 0.5)];
    sImageView.tag = kSeperateLineTag;
    sImageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [self addSubview:sImageView];
    self.line = sImageView;
}

- (void)setResignFirstResponder {
    [_mobileNumTextField resignFirstResponder];
    [_verifyCodeTextField resignFirstResponder];
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kThemeBg3Color);
    self.superview.backgroundColor = SNUICOLOR(kThemeBg3Color);
    
    UILabel *mobileLabel = (UILabel *)[self viewWithTag:kMobileTag];
    mobileLabel.textColor = SNUICOLOR(kThemeText1Color);
    UILabel *verifyCodeLabel = (UILabel *)[self viewWithTag:kVerifyCodeTag];
    verifyCodeLabel.textColor = SNUICOLOR(kThemeText1Color);
    
    UIImageView *sImageView = (UIImageView *)[self viewWithTag:kSeperateLineTag];
    sImageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    
    _mobileNumTextField.textColor = SNUICOLOR(kThemeText4Color);
    _verifyCodeTextField.textColor = SNUICOLOR(kThemeText4Color);
    _verifyCodeLabel.textColor = SNUICOLOR(kThemeText2Color);
    [_sendVerifyCodeButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
    
    UIButton *loginButton = (UIButton *)[self viewWithTag:kLoginButtonTag];
    [loginButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
}

- (void)setLoginButtonSatus:(BOOL)canClick {
    UIButton *button = (UIButton *)[self viewWithTag:kLoginButtonTag];
    button.userInteractionEnabled = canClick;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
