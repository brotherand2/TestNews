//
//  SNPhoneLoginView.m
//  sohunews
//
//  Created by wang shun on 2017/3/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPhoneLoginView.h"
#import "SNNewsPPLogin.h"

#define SNNewsLogin_PhoneView_CountDownTime 60 //登录页

@interface SNPhoneLoginView () <SNNewsLoginTextFieldDelegate>

@end

@implementation SNPhoneLoginView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //[self createViews];
        [self createMobile];
        [self createSendVerifyCode];
        [self createPhotoVerifyCode];
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
    if (self.pcodeField.hidden == NO) {//如果是图形验证码
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCodeClick:)]) {
        [self.delegate sendVerifyCodeClick:nil];
    }
}

- (void)clearVerifyCode{
    [_vcodeField setText:@""];
}

- (void)becomefirstVcodeTextfield{
    [_vcodeField becomeFirst];
}

- (void)createMobile{
    CGFloat h = (self.bounds.size.height-13)/2.0;
    CGFloat w = (self.bounds.size.width-40);
    CGFloat l = 20;
    
    _phoneField = [[SNNewsLoginTextField alloc] initWithFrame:CGRectMake(l, 00, w, h) WithType:@"mobile"];
    [self addSubview:_phoneField];
}

- (void)createViews{
    
    CGFloat h = (self.bounds.size.height-13)/2.0;
    CGFloat w = (self.bounds.size.width-40);
    CGFloat l = 20;
    
    _phoneField = [[SNNewsLoginTextField alloc] initWithFrame:CGRectMake(l, 00, w, h) WithType:@"mobile"];
    
    _vcodeField = [[SNNewsLoginTextField alloc] initWithFrame:CGRectMake(l, CGRectGetMaxY(_phoneField.frame)+13, w, h) WithType:@"vcode"];
    _vcodeField.delegate = self;
    
    [self addSubview:_phoneField];
    [self addSubview:_vcodeField];
}

- (void)createSendVerifyCode{//发送验证码
    
    CGFloat h = (self.bounds.size.height-13)/2.0;
    CGFloat w = (self.bounds.size.width-40);
    CGFloat l = 20;
    
    _vcodeField = [[SNNewsLoginTextField alloc] initWithFrame:CGRectMake(l, CGRectGetMaxY(_phoneField.frame)+13, w, h) WithType:@"vcode"];
    _vcodeField.delegate = self;
    [self addSubview:_vcodeField];
    
    _sendVerifyCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendVerifyCodeBtn.backgroundColor = [UIColor clearColor];
    [_sendVerifyCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [_sendVerifyCodeBtn setTitleColor:SNUICOLOR(kThemeBlue2Color) forState:UIControlStateNormal];
    [_sendVerifyCodeBtn addTarget:self action:@selector(sendVerifyCodeClick:) forControlEvents:UIControlEventTouchUpInside];
    _sendVerifyCodeBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeG];
    [_vcodeField addSubview:_sendVerifyCodeBtn];
    
    _verifyCodeLabel = [[UILabel alloc] init];
    _verifyCodeLabel.backgroundColor = [UIColor clearColor];
    _verifyCodeLabel.textColor = SNUICOLOR(kThemeBlue2Color);
    _verifyCodeLabel.text = @"发送验证码";//这个是用来计时显示秒的 wangshun
    _verifyCodeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeG];
    [_verifyCodeLabel sizeToFit];
    _verifyCodeLabel.textAlignment = NSTextAlignmentRight;
    _verifyCodeLabel.userInteractionEnabled = NO;
    [_sendVerifyCodeBtn addSubview:_verifyCodeLabel];
    
    CGFloat y = (h-_verifyCodeLabel.size.height)/2.0;
    CGFloat sx = w - 8 - _verifyCodeLabel.size.width;
    //-8 是phonetextField 编辑X号位置
    CGRect rect = CGRectMake(sx, y, _verifyCodeLabel.size.width, _verifyCodeLabel.size.height);
    [_sendVerifyCodeBtn setFrame:rect];

    CGFloat vw = w -(10+13.5+10) -6 -_verifyCodeLabel.size.width-8-20;//6是关闭和发送验证码间距 (10+13.5+10)是左边图片宽度
    [_vcodeField setPassWordFieldRect:CGRectMake(0, 0, vw, 0)];
    
}

- (void)createPhotoVerifyCode{
    //图形验证码

    CGFloat h = (self.bounds.size.height-13)/2.0;
    CGFloat w = (self.bounds.size.width-40);
    CGFloat l = 20;
    
    _pcodeField = [[SNNewsLoginTextField alloc] initWithFrame:CGRectMake(l, CGRectGetMaxY(_phoneField.frame)+13, w, h) WithType:@"pcode"];
    _pcodeField.delegate = self;
    [self addSubview:_pcodeField];
    _pcodeField.hidden = YES;
    
    CGFloat ph = 58/2.0;
    CGFloat py = (h-ph)/2.0;
    CGFloat pw = 171/2.0;
    CGFloat px = w - pw - 8;//UI标注 8 最右侧宽度
    
    self.photoVcode = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.photoVcode setFrame:CGRectMake(px,  py, pw, ph)];
    [self.pcodeField addSubview:self.photoVcode];
    self.photoVcode.hidden = NO;
    [self.photoVcode setBackgroundColor:[UIColor clearColor]];
    
    [self.photoVcode addTarget:self action:@selector(getPhotoVcode:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat tw = w -(10+13.5+10) -8 -20 -pw - 6;//(10+13.5+10)是左边图片宽度 (20是 关闭按钮大小) 8 最右侧宽度 6是关闭于验证码间距
    CGRect rect = CGRectMake(0, 0, tw, 0);
    [self.pcodeField setPassWordFieldRect:rect];
}

- (void)getPhotoVcode:(UIButton*)btn{
    
    [SNNewsPPLogin getPhotoVcode:nil WithSuccess:^(UIImage *img) {
        
        [self.photoVcode setImage:img forState:UIControlStateNormal];
        if (img) {
            [self.pcodeField becomeFirst];
            [self.pcodeField setText:nil];
        }
    }];
}

- (void)showPhotoVcode{
    self.pcodeField.hidden = NO;
    [self getPhotoVcode:nil];
}

- (void)hidePhotoVcode{
    self.pcodeField.hidden = YES;
}

- (void)closeKeyBoard{
    [_phoneField resignFirstResponder];
    [_vcodeField resignFirstResponder];
    [_pcodeField resignFirstResponder];
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
            if (timeout == 50) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(arrive10second)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate arrive10second];
                    });
                }
            }
            
            int seconds = timeout % (SNNewsLogin_PhoneView_CountDownTime+1);
            NSString *strTime = [NSString stringWithFormat:@"已发送%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示
                _verifyCodeLabel.textColor = SNUICOLOR(kThemeText3Color);
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
        _verifyCodeLabel.textColor = SNUICOLOR(kThemeBlue2Color);
    });
}


-(void)textFieldDidChangeText:(SNNewsLoginTextField *)textField{
    if (textField == _vcodeField) {
        if ([_phoneField text].length>0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(haveVerifyCode:)]) {
                [self.delegate haveVerifyCode:textField.text];
            }
        }
    }
    else if (textField == _pcodeField){
        if (self.photoVcode.hidden == NO) {//如果输入的是图形验证码
            if ([_pcodeField text].length>=4) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(verifyPhotoCodeAndSendVcode:)]) {
                    [self.delegate verifyPhotoCodeAndSendVcode:[_pcodeField text]];
                }
            }
        }
    }
    else if (textField == _phoneField){
        if ([_phoneField text].length == 0) {
            [_pcodeField resignFirstResponder];
            _pcodeField.hidden = YES;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
