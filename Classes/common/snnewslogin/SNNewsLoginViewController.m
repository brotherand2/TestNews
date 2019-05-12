//
//  SNNewsLoginViewController.m
//  sohunews
//
//  Created by wang shun on 2017/3/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginViewController.h"
#import "SNNewsLoginSuccess.h"

#import "SNPhoneLoginView.h"
#import "SNThirdLoginView.h"
#import "SNNewsLoginKeyBoard.h"

#import "SNSendVcodeViewModel.h"
#import "SNPhoneLoginViewModel.h"
#import "SNThirdLoginViewModel.h"

@interface SNNewsLoginViewController ()<SNThirdLoginViewDelegate,SNPhoneLoginViewDelegate>

@property (nonatomic,strong) SNPhoneLoginView* phoneView;//手机号验证码
@property (nonatomic,strong) SNThirdLoginView* thirdLoginView;//第三方登录
@property (nonatomic,strong) SNNewsLoginKeyBoard* keyboard;//键盘弹出/收起事件


@property (nonatomic,strong) SNSendVcodeViewModel*  sendVcodeViewModel;//发送验证码流程
@property (nonatomic,strong) SNPhoneLoginViewModel* phoneLoginViewModel;//手机号登录流程
@property (nonatomic,strong) SNThirdLoginViewModel* thirdLoginViewModel;//第三方登录流程
@property (nonatomic,strong) SNNewsLoginSuccess*    loginSuccessModel;//登录成功逻辑

@end

@implementation SNNewsLoginViewController

- (void)dealloc{
    [self removeKeyBoardNotification];
}

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
    if (self = [super initWithNavigatorURL:URL query:query]) {
        if (query) {
            if([query objectForKey:@"loginSuccess"]){
                id sender = [query objectForKey:@"loginSuccess"];
                if ([sender isKindOfClass:[SNNewsLoginSuccess class]]) {
                   self.loginSuccessModel = [query objectForKey:@"loginSuccess"];
                }
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addHeaderView];
    
    [self createPhoneView]; //键盘
    [self createLoginBtn];  //立即登录
    
    [self setSeperateLine];
    
    [self createLoginView]; //第三方登录
    
    [self addToolbar];
    
    [self createkeyboardNotification];
}

#pragma mark - 立即登录

- (void)loginClick:(UIButton*)btn{
    [self.phoneView closeKeyBoard];
    [self createPhoneLoginModel];
    
    NSDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    __weak SNNewsLoginViewController* weakSelf = self;
    [self.phoneLoginViewModel loginWithPhoneAndVcode:phoneDic Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {//成功
                [weakSelf.loginSuccessModel loginSucessed:resultDic];
            }
            else{
                
            }
        }
    }];
}

#pragma mark - 第三方登录

- (void)thirdLoginWithThirdName:(NSString *)name{
    [self.phoneView closeKeyBoard];
    [self createThirdLoginModel];
    
    NSDictionary* params = @{@"loginSuccess":self.loginSuccessModel};
    
    __weak SNNewsLoginViewController* weakSelf = self;
    [self.thirdLoginViewModel thirdLoginWithName:name WithParams:params Success:^(NSDictionary *resultDic) {
        [weakSelf.loginSuccessModel loginSucessed:nil];
    }];
}

#pragma mark - 发送验证码

- (void)sendVerifyCodeClick:(NSDictionary*)params{//发送验证码
    [self.phoneView closeKeyBoard];
    [self createVcodeModel];
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    [phoneDic setObject:@"signin" forKey:@"type"];
    
    __weak SNNewsLoginViewController* weakSelf = self;
    [self.sendVcodeViewModel sendVcode:phoneDic Completion:^(NSDictionary *resultDic) {
        NSString* success = [resultDic objectForKey:@"success"];
        if ([success isEqualToString:@"1"]) {
            [weakSelf.phoneView countDownTime];
        }
    }];
}

#pragma mark - onBack

- (void)onBack:(id)sender{
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -  create UI

- (void)createLoginBtn{//立即登录
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = [UIColor clearColor];
    [loginButton setTitle:@"立即登录" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginButton sizeToFit];
    [loginButton setFrame:CGRectMake((kAppScreenWidth-loginButton.frame.size.width)/2, kHeaderHeightWithoutBottom+120, loginButton.frame.size.width, loginButton.frame.size.height)];
    [self.view addSubview:loginButton];
    [loginButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];

    [loginButton addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createPhoneView{//手机号 验证码
    self.phoneView = [[SNPhoneLoginView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom, self.view.bounds.size.width, 90)];
    self.phoneView.delegate = self;
    [self.view addSubview:_phoneView];
}

- (void)createLoginView{
    self.thirdLoginView = [[SNThirdLoginView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom+ 180, 320, 80)];
    self.thirdLoginView.delegate = self;
    [self.view addSubview:_thirdLoginView];
}

- (void)setSeperateLine {
    UIImageView *sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom+169.5, kAppScreenWidth, 0.5)];
    sImageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [self.view addSubview:sImageView];
}

- (void)addHeaderView
{
    if (!_headerView)
    {
        _headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderTotalHeight)];
        [self.view addSubview:_headerView];
    }
    
    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"user_info_login", nil), nil]];
    CGSize titleSize = [NSLocalizedString(@"user_info_login", nil) sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
}

#pragma mark - createModel

- (void)createPhoneLoginModel{
    if (self.phoneLoginViewModel == nil) {
        self.phoneLoginViewModel = [[SNPhoneLoginViewModel alloc] init];
    }
}

- (void)createVcodeModel{
    if (self.sendVcodeViewModel == nil) {
        self.sendVcodeViewModel = [[SNSendVcodeViewModel alloc] init];
    }
}

- (void)createThirdLoginModel{
    if (self.thirdLoginViewModel == nil) {
        self.thirdLoginViewModel = [[SNThirdLoginViewModel alloc] init];
    }
}


#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark - 键盘

#pragma mark - createkeyboardNotification

- (void)createkeyboardNotification{
    self.keyboard = [[SNNewsLoginKeyBoard alloc] initWithToolbar:self.toolbarView];
    [self.keyboard createkeyboardNotification];
}

#pragma mark - removeKeyBoardNotification

- (void)removeKeyBoardNotification{
    [self.keyboard removeKeyBoardNotification];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.phoneView closeKeyBoard];
}

////////////////////////////////////////////////////////////////////////////////






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
