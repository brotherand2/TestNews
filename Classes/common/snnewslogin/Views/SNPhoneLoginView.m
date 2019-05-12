//
//  SNPhoneLoginView.m
//  sohunews
//
//  Created by wang shun on 2017/3/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPhoneLoginView.h"

#define SNNewsLogin_PhoneView_CountDownTime 60 //登录页
#define SNNewsLogin_PhoneView_TextFieldWidth (kAppScreenWidth - 160)

@implementation SNPhoneLoginView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createViews];
        [self createSendVerifyCode];
    }
    return self;
}

- (NSMutableDictionary*)getPhoneAndVcode{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:_phoneField.text?_phoneField.text:@"" forKey:@"phone"];
    [dic setObject:_vcodeField.text?_vcodeField.text:@"" forKey:@"vcode"];
    return dic;
}

- (void)sendVerifyCodeClick:(UIButton*)b{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCodeClick:)]) {
        [self.delegate sendVerifyCodeClick:nil];
    }
}

-(void)clearVerifyCode{
    _vcodeField.text = @"";
}

- (void)createViews{
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:16.0];
    titleLabel.text = @"手机号";
    titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    [titleLabel setFrame:CGRectMake(14, 26, 0, 0)];
    [self addSubview:titleLabel];
    [titleLabel sizeToFit];
    
    if(!_phoneField) {
        
        CGRect rect = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width+16, titleLabel.frame.origin.y+2, SNNewsLogin_PhoneView_TextFieldWidth, titleLabel.frame.size.height);
        
        _phoneField = [[SNCustomTextField alloc] initWithFrame:rect];
        _phoneField.placeholder = @"请输入手机号";
        _phoneField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneField.font = [UIFont systemFontOfSize:13.0];
        _phoneField.textColor = SNUICOLOR(kThemeText4Color);
        [self addSubview:_phoneField];
    }
    
    UILabel *verifyCodeTitleLabel = [[UILabel alloc] init];
    verifyCodeTitleLabel.backgroundColor = [UIColor clearColor];
    verifyCodeTitleLabel.font = [UIFont systemFontOfSize:16.0];
    verifyCodeTitleLabel.text = @"验证码";
    [verifyCodeTitleLabel sizeToFit];
    verifyCodeTitleLabel.textColor = SNUICOLOR(kThemeText1Color);
    [verifyCodeTitleLabel setFrame:CGRectMake(14, 49+titleLabel.frame.size.height, verifyCodeTitleLabel.frame.size.width, verifyCodeTitleLabel.frame.size.height)];
    [self addSubview:verifyCodeTitleLabel];
    
    if (!_vcodeField) {
        CGRect rect = CGRectMake(verifyCodeTitleLabel.frame.origin.x+verifyCodeTitleLabel.frame.size.width+16, verifyCodeTitleLabel.frame.origin.y+2, SNNewsLogin_PhoneView_TextFieldWidth, verifyCodeTitleLabel.frame.size.height);
        
        _vcodeField = [[SNCustomTextField alloc] initWithFrame:rect];
        _vcodeField.placeholder = @"请输入验证码";
        _vcodeField.keyboardType = UIKeyboardTypeNumberPad;
        _vcodeField.font = [UIFont systemFontOfSize:13.0];
        _vcodeField.textColor = SNUICOLOR(kThemeText4Color);
        [self addSubview:_vcodeField];
    }
    //_vcodeField.Max Y = 90 wangshun
}

- (void)createSendVerifyCode{//发送验证码
    
    _sendVerifyCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendVerifyCodeBtn.backgroundColor = [UIColor clearColor];
    [_sendVerifyCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [_sendVerifyCodeBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
    [_sendVerifyCodeBtn addTarget:self action:@selector(sendVerifyCodeClick:) forControlEvents:UIControlEventTouchUpInside];
    _sendVerifyCodeBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:_sendVerifyCodeBtn];
    
    _verifyCodeLabel = [[UILabel alloc] init];
    _verifyCodeLabel.backgroundColor = [UIColor clearColor];
    _verifyCodeLabel.textColor = SNUICOLOR(kThemeText2Color);
    _verifyCodeLabel.text = @"发送验证码";//我认为这个发送验证码文字是用来算button rect的 wangshun
    _verifyCodeLabel.font = [UIFont systemFontOfSize:13.0];
    [_verifyCodeLabel sizeToFit];
    _verifyCodeLabel.userInteractionEnabled = NO;
    [_sendVerifyCodeBtn addSubview:_verifyCodeLabel];
    
    
    CGRect rect = CGRectMake(kAppScreenWidth-_verifyCodeLabel.size.width-14, 85-_verifyCodeLabel.size.height, _verifyCodeLabel.size.width, _verifyCodeLabel.size.height);
    [_sendVerifyCodeBtn setFrame:rect];
}

- (void)closeKeyBoard{
    [_phoneField resignFirstResponder];
    [_vcodeField resignFirstResponder];
}

#pragma mark count-down time
- (void)countDownTime {
    __block int timeout = SNNewsLogin_PhoneView_CountDownTime; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if (timeout<=0) { //倒计时结束，关闭
            [self resetVerifyCodeLabelStatus];
        }
        else {
            int seconds = timeout % (SNNewsLogin_PhoneView_CountDownTime+1);
            NSString *strTime = [NSString stringWithFormat:@"已发送%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示
                _sendVerifyCodeBtn.titleLabel.text = nil;
                _sendVerifyCodeBtn.userInteractionEnabled = NO;
                _verifyCodeLabel.text = strTime;
            });
            
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (void)resetVerifyCodeLabelStatus{
    if(!_timer)
        return;
    dispatch_source_cancel(_timer);
    //    dispatch_release(_timer);
    _timer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        //设置界面的按钮显示
        _verifyCodeLabel.text = nil;
        _sendVerifyCodeBtn.userInteractionEnabled = YES;
        _sendVerifyCodeBtn.titleLabel.text = @"发送验证码";
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
