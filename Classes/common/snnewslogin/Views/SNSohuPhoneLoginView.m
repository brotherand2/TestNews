//
//  SNSohuPhoneLoginView.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSohuPhoneLoginView.h"

@interface SNSohuPhoneLoginView ()<UITextFieldDelegate>

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

#pragma mark - create UI

- (void)createField{
    UIImage* image = [UIImage imageNamed:@"userinfo_cellbg.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 49, 24)];
    
    UIImage* imagehl = [UIImage imageNamed:@"userinfo_cellbg_hl.png"];
    imagehl = [imagehl resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 49, 24)];
    
    UIColor* labelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoLabelColor]];
    UIColor* fieldTextColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoTextColor]];
    
    //------------------------------------------- Line 1 -------------------------------------------
    
    CGRect baseRect = CGRectMake(12.5, 27.5, kAppScreenWidth-29, 40);
    
    UIButton* cellbgButton = [[UIButton alloc] initWithFrame:baseRect];
    cellbgButton.tag = 201;
    [cellbgButton setBackgroundImage:image forState:UIControlStateNormal];
    [cellbgButton setBackgroundImage:imagehl forState:UIControlStateSelected];
    [self addSubview:cellbgButton];
    
    //用户名
    CGRect subRect = CGRectMake(baseRect.origin.x+10, baseRect.origin.y+12, 12.5, 12.5);
    UIImage* itemImage = [UIImage imageNamed:@"userinfo_head.png"];
    UIImageView* itemImageView = [[UIImageView alloc] initWithFrame:subRect];
    itemImageView.image = itemImage;
    [self addSubview:itemImageView];
    
    subRect.origin.x += subRect.size.width + 6;
    subRect.size = CGSizeMake(70,16);
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        subRect.size = CGSizeMake(60,16);
    }
    UILabel* username = [[UILabel alloc] initWithFrame:subRect];
    username.font = [UIFont systemFontOfSize:15];
    username.textColor = labelColor;
    username.backgroundColor = [UIColor clearColor];
    username.userInteractionEnabled = NO;
    username.text = @"搜狐账号";
    [self addSubview:username];
    
    //用户名编辑框
    subRect.origin.x += subRect.size.width + 6;
    subRect.origin.y -= 2;
    subRect.size = CGSizeMake(kAppScreenWidth-126,20);
    self.userNameTextField = [[SNCustomTextField alloc] initWithFrame:subRect];
    self.userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.userNameTextField.returnKeyType = UIReturnKeyNext;
    self.userNameTextField.textColor = fieldTextColor;
    self.userNameTextField.tag = 101;
    self.userNameTextField.placeholder = NSLocalizedString(@"user_info_textfield_login_username", nil);
    self.userNameTextField.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:15.0];
    self.userNameTextField.delegate = self;
    self.userNameTextField.backgroundColor = [UIColor clearColor];
    self.userNameTextField.exclusiveTouch = YES;
    [self addSubview:self.userNameTextField];
    
    baseRect.origin.y += 52.5;
    cellbgButton = [[UIButton alloc] initWithFrame:baseRect];
    cellbgButton.tag = 202;
    [cellbgButton setBackgroundImage:image forState:UIControlStateNormal];
    [cellbgButton setBackgroundImage:imagehl forState:UIControlStateSelected];
    [self addSubview:cellbgButton];
    
    subRect = CGRectMake(baseRect.origin.x+10, baseRect.origin.y+12, 12.5, 12.5);
    itemImage = [UIImage imageNamed:@"userinfo_password.png"];
    itemImageView = [[UIImageView alloc] initWithFrame:subRect];
    itemImageView.image = itemImage;
    [self addSubview:itemImageView];
    
    //密码
    subRect.origin.x += subRect.size.width + 6;
    subRect.size = CGSizeMake(70,16);
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        subRect.size = CGSizeMake(60,16);
    }
    UILabel* password = [[UILabel alloc] initWithFrame:subRect];
    password.font = [UIFont systemFontOfSize:15];
    password.textColor = labelColor;
    password.backgroundColor = [UIColor clearColor];
    password.userInteractionEnabled = NO;
    password.text = NSLocalizedString(@"user_info_label_password", nil);
    [self addSubview:password];
    
    //密码编辑框
    subRect.origin.x += subRect.size.width + 6;
    subRect.origin.y -= 2;
    subRect.size = CGSizeMake(kAppScreenWidth-126,20);
    self.passwordTextField = [[SNCustomTextField alloc] initWithFrame:subRect];
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.textColor = fieldTextColor;
    self.passwordTextField.tag = 102;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.placeholder = NSLocalizedString(@"user_info_textfield_login_password", nil);
    self.passwordTextField.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:15.0];
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.backgroundColor = [UIColor clearColor];
    self.passwordTextField.exclusiveTouch = YES;
    [self addSubview:self.passwordTextField];
}

-(void)createButtonPart
{
    UIColor* buttonFontColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoButtonFontColor]];
    
    //登录按钮
    CGRect buttonRect;
    NSString* title = nil;
    buttonRect = CGRectMake(62.5, 139, kAppScreenWidth-125, 42);
    title = NSLocalizedString(@"user_info_login", nil);
    
    UIButton* registerButton = [[UIButton alloc] initWithFrame:buttonRect];
    [registerButton setTitleColor:buttonFontColor forState:UIControlStateNormal];
    [registerButton setTitleColor:buttonFontColor forState:UIControlStateHighlighted];
    [registerButton setTitle:title forState:UIControlStateNormal];
    [registerButton setTitle:title forState:UIControlStateHighlighted];
    [registerButton setBackgroundImage:[UIImage imageNamed:@"userinfo_bigbutton.png"] forState:UIControlStateNormal];
    [registerButton setBackgroundImage:[UIImage imageNamed:@"userinfo_bigbutton_hl.png"] forState:UIControlStateHighlighted];
    [registerButton addTarget:self action:@selector(submitLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:registerButton];
}

- (void)closeKeyBoard{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField*)textField{
    [self selectItembyTag:textField.tag];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    if(textField.tag==101)
        [(UITextField*)[self viewWithTag:102] becomeFirstResponder];
    else
        [self submitLogin:nil];
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
    
    if(aTag!=101)
        [userNameTextField resignFirstResponder];
    else
        [userNameTextField becomeFirstResponder];
    
    if(aTag!=102)
        [passwordTextField resignFirstResponder];
    else
        [passwordTextField becomeFirstResponder];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
