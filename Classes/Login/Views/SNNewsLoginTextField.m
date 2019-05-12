//
//  SNNewsLoginTextField.m
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginTextField.h"
#import "SNCustomTextField.h"
@interface SNNewsLoginTextField ()<UITextFieldDelegate>

@property (nonatomic,strong) SNCustomTextField* textField;

@property (nonatomic,strong) UIButton* close;
@property (nonatomic,strong) UIImageView* headImg;

@end

@implementation SNNewsLoginTextField

- (instancetype)initWithFrame:(CGRect)frame WithType:(NSString*)type{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        if ([type isEqualToString:@"mobile"]) {
            [self createPhoneUI];
        }
        else if ([type isEqualToString:@"password"]){
            [self createPasswordUI];
        }
        else if ([type isEqualToString:@"sohu"]){
            [self createSohuUI];
        }
        else if ([type isEqualToString:@"vcode"]){
            [self createVcodeUI];
        }
        else if ([type isEqualToString:@"pcode"]){
            [self createPcodeUI];
        }
        
        self.backgroundColor = SNUICOLOR(kThemeLoginTextFieldBgColor);
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        self.layer.borderColor = SNUICOLOR(kThemeLoginTextFieldBorderColor).CGColor;
        self.layer.cornerRadius = 1;
    }
    return self;
}

- (void)createPhoneUI{
    [self createUI];
    _textField.placeholder = @"请输入手机号";
    self.headImg.image = [UIImage themeImageNamed:@"icologin_sj_v5.png"];
    _textField.keyboardType = UIKeyboardTypeNumberPad;
}

- (void)createSohuUI{
    [self createUI];
    _textField.placeholder = NSLocalizedString(@"user_info_textfield_login_username", nil);
    self.headImg.image = [UIImage themeImageNamed:@"icologin_sj_v5.png"];
}

- (void)createPasswordUI{
    [self createUI];
    _textField.secureTextEntry = YES;
    _textField.placeholder = @"请输入密码";
    self.headImg.image = [UIImage themeImageNamed:@"icologin_yzm_v5.png"];
}

- (void)createVcodeUI{
    [self createUI];
    _textField.placeholder = @"请输入验证码";
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    self.headImg.image = [UIImage themeImageNamed:@"icologin_yzm_v5.png"];
}

- (void)createPcodeUI{
    [self createUI];
    _textField.placeholder = @"请输入图中文字";
    self.headImg.image = [UIImage themeImageNamed:@"icologin_txyzm_v5.png"];
}

- (void)createUI{
    CGFloat y = (self.bounds.size.height-16)/2.0;
    
    self.headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, 13.5, 16)];
    self.headImg.backgroundColor = [UIColor clearColor];
    [self addSubview:self.headImg];
    
    _textField = [[SNCustomTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImg.frame)+10, 00, self.bounds.size.width-(CGRectGetMaxX(self.headImg.frame)+10)-20-8, self.bounds.size.height)];
    _textField.delegate = self;
//    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.backgroundColor = [UIColor clearColor];
    [_textField setFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [_textField setTextColor:SNUICOLOR(kThemeText10Color)];
    [_textField setTintColor:SNUICOLOR(kThemeBlue2Color)];
    
    CGFloat close_width = 20;
    _close = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_close setImage:[UIImage themeImageNamed:@"icologin_close_v5.png"] forState:UIControlStateNormal];
    [_close setImage:[UIImage themeImageNamed:@"icologin_closepress_v5.png"] forState:UIControlStateHighlighted];
    
    [_close setFrame:CGRectMake(CGRectGetMaxX(_textField.frame), (_textField.bounds.size.height-20)/2.0, 20, 20)];
    [_close setBackgroundColor:[UIColor clearColor]];
    _close.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    
    [self addSubview:_close];
    self.close.hidden = YES;
    
    [self.close addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //监听输入变化
    [_textField addTarget:self action:@selector(textFieldDidEditing:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_textField];

}

- (void)closeClick:(UIButton*)btn{
    if (_textField.text && _textField.text.length>0) {
        _textField.text = @"";
        btn.hidden = YES;
        [self.delegate textFieldDidChangeText:self];
    }
}

//调整密码textfield rect 因为后面有发送验证码
-(void)setPassWordFieldRect:(CGRect)rect{
    
    CGFloat close_width = 20;
    
    CGFloat w = CGRectGetWidth(rect); //rect只给宽度
    
    [_textField setFrame:CGRectMake(_textField.frame.origin.x, _textField.frame.origin.y, w, _textField.frame.size.height)];
    [_close setFrame:CGRectMake(CGRectGetMaxX(_textField.frame), (_textField.bounds.size.height-close_width)/2.0, close_width, close_width)];
}

- (void)setText:(NSString *)text{
    self.textField.text = text;
    if (text == nil) {
        _close.hidden = YES;
    }
}

- (NSString*)text{
    return self.textField.text;
}
    
    
-(BOOL)resignFirstResponder{
    _close.hidden = YES;
    return [self.textField resignFirstResponder];
}

- (void)setEnable:(BOOL)enable{
    self.textField.enabled = enable;
}

- (BOOL)enable{
    return self.textField.enabled;
}

- (void)becomeFirst{
    if (![_textField isFirstResponder]) {
        [_textField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEditing:(UITextField*)textField{
    //NSLog(@"%@",textField.text);
    if (textField.text && textField.text.length>0) {
        self.close.hidden = NO;
    }
    else{
        self.close.hidden = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidChangeText:)]) {
        [self.delegate textFieldDidChangeText:self];
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldReturnClick:)]) {
        [self.delegate textFieldReturnClick:self];
    }
    
    return YES;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.text.length>0) {
       self.close.hidden = NO;
    }

    return YES;
}

// 失去焦点
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.close.hidden = YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
