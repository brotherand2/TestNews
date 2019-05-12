//
//  SNSohuPhoneLoginView.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSohuPhoneLoginView.h"
#import "SNNewsPPLogin.h"

@interface SNSohuPhoneLoginView ()<UITextFieldDelegate,SNNewsLoginTextFieldDelegate>

@property (nonatomic,strong) UIView* coverLoginView;//登录button 遮罩
@property (nonatomic,strong) UIButton* loginBtn;

@property (nonatomic,strong) UIButton* photoVcode;

@end

@implementation SNSohuPhoneLoginView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createField];
        [self createButtonPart];
    }
    return self;
}

#pragma mark - 登录

- (void)submitLogin:(UIButton*)b{
    if (_coverLoginView.hidden == NO) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sohuLoginClick:)]) {
        [self.delegate sohuLoginClick:nil];
    }
}

#pragma mark - 获取账号密码

-(NSMutableDictionary *)getSohuAccountAndPassword{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [dic setObject:self.userNameTextField.text?:@"" forKey:@"sohuaccount"];
    [dic setObject:self.passwordTextField.text?:@"" forKey:@"password"];
    
    return dic;
}

- (NSString*)getPhotoVcode{
    return [self.photovcodeField text];
}

- (BOOL)isShowPhotoVcode{
    return !self.photovcodeField.hidden;
}

#pragma mark - 显示图形验证码

-(void)showPhotoVcode{
    self.photovcodeField.hidden = NO;
    CGFloat h = (110-13)/2.0;
    CGFloat w = (self.bounds.size.width-40);
    CGFloat l = 20;
    [self.passwordTextField setFrame:CGRectMake(l, CGRectGetMaxY(_photovcodeField.frame)+13, w, h)];
    CGFloat y =CGRectGetMaxY(self.passwordTextField.frame)+25;
    [self.loginBtn setFrame:CGRectMake(self.loginBtn.frame.origin.x, y, self.loginBtn.frame.size.width, self.loginBtn.size.height)];
    [self getPhotoVcode:nil];
}

#pragma mark - create UI

- (void)createField{
    
    CGFloat h = (110-13)/2.0;
    CGFloat w = (self.bounds.size.width-40);
    CGFloat l = 20;
    
    self.userNameTextField = [[SNNewsLoginTextField alloc] initWithFrame:CGRectMake(l, 00, w, h) WithType:@"sohu"];
    self.userNameTextField.delegate = self;
    self.userNameTextField.tag = 101;
    [self addSubview:self.userNameTextField];
    
    self.passwordTextField = [[SNNewsLoginTextField alloc] initWithFrame:CGRectMake(l, CGRectGetMaxY(_userNameTextField.frame)+13, w, h) WithType:@"password"];
    self.passwordTextField.delegate = self;
    self.passwordTextField.tag = 102;
    [self addSubview:self.passwordTextField];
    
    self.photovcodeField = [[SNNewsLoginTextField alloc] initWithFrame:CGRectMake(l, CGRectGetMaxY(_userNameTextField.frame)+13, w, h) WithType:@"pcode"];
    [self addSubview:self.photovcodeField];
    self.photovcodeField.delegate = self;
    self.photovcodeField.hidden = YES;
    self.photovcodeField.tag = 103;

    
    CGFloat ph = 58/2.0;
    CGFloat py = (h-ph)/2.0;
    CGFloat pw = 171/2.0;
    CGFloat px = w - pw - 8;//UI标注 8 最右侧宽度
    
    self.photoVcode = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.photoVcode setFrame:CGRectMake(px,  py, pw, ph)];
    [self.photovcodeField addSubview:self.photoVcode];
    [self.photoVcode setBackgroundColor:[UIColor clearColor]];
    
    [self.photoVcode addTarget:self action:@selector(getPhotoVcode:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat tw = w -(10+13.5+10) -8 -20 -pw - 6;//(10+13.5+10)是左边图片宽度 (20是 关闭按钮大小) 8 最右侧宽度 6是关闭于验证码间距
    CGRect rect = CGRectMake(0, 0, tw, 0);
    [self.photovcodeField setPassWordFieldRect:rect];

}

- (void)getPhotoVcode:(UIButton*)btn{
    
    [SNNewsPPLogin getPhotoVcode:nil WithSuccess:^(UIImage *img) {
        
        [self.photoVcode setImage:img forState:UIControlStateNormal];
        if (img) {
            [self.photovcodeField becomeFirst];
            [self.photovcodeField setText:nil];
        }
    }];
}

-(void)createButtonPart
{
    CGFloat w = 242;
    CGFloat x = (self.bounds.size.width-w)/2.0;
    CGFloat h = 40;
    CGFloat y = CGRectGetMaxY(self.passwordTextField.frame)+25;
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = SNUICOLOR(kThemeRed1Color);
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginButton sizeToFit];
    [loginButton setFrame:CGRectMake(x, y, w, h)];
    [self addSubview:loginButton];
    [loginButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    
    [loginButton addTarget:self action:@selector(submitLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = 1;
    
    self.loginBtn = loginButton;
    
    _coverLoginView = [[UIView alloc] initWithFrame:loginButton.bounds];
    [_coverLoginView setBackgroundColor:SNUICOLOR(kThemeLoginBgColor)];
    _coverLoginView.userInteractionEnabled = NO;
    [loginButton addSubview:_coverLoginView];
    _coverLoginView.alpha = 0.4;
    _coverLoginView.hidden = NO;
}

- (void)closeKeyBoard{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.photovcodeField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField*)textField{
    [self selectItembyTag:textField.tag];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    if(textField.tag==101){
        [(UITextField*)[self viewWithTag:102] becomeFirstResponder];
        [(UITextField*)[self viewWithTag:103] becomeFirstResponder];
    }
    else{
        [self submitLogin:nil];
    }
    return YES;
}

#pragma mark - 

-(void)resetBgByTag:(NSInteger)aTag
{
    UIButton* bg1 = (UIButton*)[self viewWithTag:201];
    UIButton* bg2 = (UIButton*)[self viewWithTag:202];
    
    if(aTag!=201)
        bg1.selected = NO;
    else
        bg1.selected = YES;
    
    if(aTag!=202)
        bg2.selected = NO;
    else
        bg2.selected = YES;
}

-(void)selectItembyTag:(NSInteger)aTag
{
    if(aTag==101 || aTag==201)
    {
        [self resignResponserByTag:101];
        [self resetBgByTag:201];
    }
    else if(aTag==102 || aTag==202)
    {
        [self resignResponserByTag:102];
        [self resetBgByTag:202];
    }
    else
    {
        [self resignResponserByTag:-1];
        [self resetBgByTag:-1];
    }
}

-(void)resignResponserByTag:(NSInteger)aTag
{
    UITextField* userNameTextField = (UITextField*)[self viewWithTag:101];
    UITextField* passwordTextField = (UITextField*)[self viewWithTag:102];
    UITextField* pvcodeTextField   = (UITextField*)[self viewWithTag:103];
    
    if(aTag!=101)
        [userNameTextField resignFirstResponder];
    else
        [userNameTextField becomeFirstResponder];
    
    if(aTag!=102)
        [passwordTextField resignFirstResponder];
    else
        [passwordTextField becomeFirstResponder];
    
    if(aTag!=103)
        [pvcodeTextField resignFirstResponder];
    else
        [pvcodeTextField becomeFirstResponder];
}

- (void)textFieldDidChangeText:(SNNewsLoginTextField *)textField{
    
    if ([self.passwordTextField text].length>0) {
        if ([self.userNameTextField text].length>0) {
            if (self.photovcodeField.hidden == NO) {
                if ([self.photovcodeField text].length>0) {
                    [self haveVerifyCode:YES];
                    return;
                }
            }
            else{
                [self haveVerifyCode:YES];
                return;
            }
        }
    }
    
    [self haveVerifyCode:NO];
    return;
}

- (void)haveVerifyCode:(BOOL)enable{
    if (enable) {
        _coverLoginView.hidden = YES;
    }
    else{
        _coverLoginView.hidden = NO;
    }
}

- (void)clearPassword{
    [self.passwordTextField setText:nil];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
