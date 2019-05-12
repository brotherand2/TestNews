//
//  SNNewsBindViewController.m
//  sohunews
//
//  Created by wang shun on 2017/4/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsBindViewController.h"

#import "SNNewsLoginSuccess.h"
#import "SNNewsBindSuccess.h"

#import "SNPhoneLoginView.h"
#import "SNNewsLoginKeyBoard.h"

#import "SNSendVcodeViewModel.h"
#import "SNBindPhoneViewModel.h"
#import "SNPhoneLoginViewModel.h"

#import "SNNewAlertView.h"

@interface SNNewsBindViewController ()<SNPhoneLoginViewDelegate,SNBindPhoneViewModelDelegate>

@property (nonatomic,strong) SNPhoneLoginView* phoneView;//手机号验证码
@property (nonatomic,strong) SNNewsLoginKeyBoard* keyboard;//键盘事件

@property (nonatomic,strong) SNSendVcodeViewModel* sendVcodeViewModel;//发送验证码流程
@property (nonatomic,strong) SNBindPhoneViewModel* bindPhoneViewModel;//绑定流程
@property (nonatomic,strong) SNPhoneLoginViewModel* phoneLoginViewModel;//登录流程 (绑定页面调登录流程)

@property (nonatomic,assign) BOOL isThird;//是否第三方登录
@property (nonatomic,assign) BOOL isSohuLogin;//是否搜狐登录绑定
@property (nonatomic,weak)   id <SNLoginLaterBingPhoneDelegate> thirdDelegate;//是否第三方登录
@property (nonatomic,strong) NSString* thirdType;//第三方登录绑定type;
@property (nonatomic,strong) NSString* passport;//绑定passport;

@property (nonatomic,strong) SNNewsBindSuccess* bindSuccessModel;//绑定成功
@property (nonatomic,strong) SNNewsLoginSuccess* loginSuccessModel;//登录成功
@property (nonatomic,assign) BOOL isPhoneLoginViewModel;//是否是登录

@end

@implementation SNNewsBindViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.isPhoneLoginViewModel = NO;
        if ([query objectForKey:@"third"]) {
            self.thirdDelegate = [query objectForKey:@"thrid"];
            self.isThird = YES;
            
            if ([query objectForKey:@"data"]) {
                NSDictionary* data = [query objectForKey:@"data"];
                if (data && [data isKindOfClass:[NSDictionary class]]) {
                    self.thirdType = [data objectForKey:@"type"];
                     self.passport = [data objectForKey:@"passport"];
                }
            }
            
            self.isSohuLogin = NO;
            if ([query objectForKey:@"sohulogin"]) {//如果是搜狐passport登录
                NSString* issohulogin = [query objectForKey:@"sohulogin"];
                if ([issohulogin isEqualToString:@"1"]) {
                    self.isSohuLogin = YES;
                }
            }
        }
        else{
            
            if ([query objectForKey:@"bindSuccess"]){//如果是绑定
                id sender = [query objectForKey:@"bindSuccess"];
                if ([sender isKindOfClass:[SNNewsBindSuccess class]]) {
                    self.bindSuccessModel = (SNNewsBindSuccess*)sender;
                }
            }
            else if([query objectForKey:@"loginSuccess"]){//如果是绑定走登录逻辑
                id sender = [query objectForKey:@"loginSuccess"];
                if ([sender isKindOfClass:[SNNewsLoginSuccess class]]) {
                    self.loginSuccessModel = (SNNewsLoginSuccess*)sender;
                    self.isPhoneLoginViewModel = YES;
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
    
    if (self.isPhoneLoginViewModel == NO) {//如果是绑定 显示 subTitle
        [self createSubTitle];
    }
    
    [self createPhoneView]; //键盘
    [self createBindBtn];  //立即绑定
    
    [self setSeperateLine];
    
    [self createBottomTitle];
    
    [self addToolbar];
    
    [self createkeyboardNotification];
}

#pragma mark - 绑定

- (void)bindClick:(UIButton*)btn{
    [self.phoneView closeKeyBoard];
    [self createBindPhoneModel];
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    if (self.isThird) {
        [phoneDic setObject:self.thirdType?:@"" forKey:@"type"];
    }
    else{
        [phoneDic setObject:@"bind" forKey:@"type"];//绑定 bind
    }
    
    if (self.passport && self.passport.length>0) {//有passport 传passport 没有不传
        [phoneDic setObject:self.passport?:@"" forKey:@"passport"];
    }

    
    __weak SNNewsBindViewController* weakSelf = self;
    [self.bindPhoneViewModel bindPhone:phoneDic Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {//成功
                [weakSelf bindSuccessed:resultDic];//这里还需要区分是第三方/绑定
            }
        }
    }];
}

- (void)bindSuccessed:(NSDictionary*)result{
    //如果是第三放登录绑定 搜狐passport绑定
    if (self.thirdDelegate && [self.thirdDelegate respondsToSelector:@selector(loginSuccessed:)]) {
        [self.thirdDelegate loginSuccessed:result];
    }
    else{//绑定成功
        [self.bindSuccessModel bindSucessed:result];
    }
}

#pragma mark - 发送验证码

- (void)sendVerifyCodeClick:(NSDictionary*)params{//发送验证码
    [self createVcodeModel];
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    if (self.isThird) {
        [phoneDic setObject:self.thirdType forKey:@"type"];
    }
    else{
        [phoneDic setObject:@"bind" forKey:@"type"];//绑定 bind
    }
    
    __weak SNNewsBindViewController* weakSelf = self;
    [self.sendVcodeViewModel sendVcode:phoneDic Completion:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if([success isEqualToString:@"1"]){
                [weakSelf.phoneView countDownTime];
            }
        }
    }];
}


//绑定页面走登录逻辑(手机号登录)
- (void)phoneLoginClick:(UIButton*)btn{
    [self createPhoneLoginModel];
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    
    __weak SNNewsBindViewController* weakSelf = self;
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


#pragma mark - onBack

- (void)onBack:(id)sender{
    
    NSString* str = @"退出绑定";
    if (self.isThird) {//如果是第三封登录绑定
        str = @"退出登录";
    }
    
    SNNewAlertView* alertView = [[SNNewAlertView alloc] initWithTitle:nil message:@"登录尚未完成，是否放弃绑定?" cancelButtonTitle:str otherButtonTitle:@"继续绑定"];
    [alertView actionWithBlocksCancelButtonHandler:^{//退出绑定
        [self cancelBindpopViewController];
    } otherButtonHandler:nil];
    
    [alertView show];
}

- (void)cancelBindpopViewController{//需要区分是不是搜狐passport
    
    if (self.isSohuLogin == YES) {//如果是搜狐passport登录 back至登录页面 wangshun 测试认为这样更好
        NSArray* vc_arr = self.flipboardNavigationController.viewControllers;
        if (vc_arr.count>3) {
            UIViewController* vc = [vc_arr objectAtIndex:vc_arr.count-3];
            NSString* classname = NSStringFromClass([vc class]);
            if([classname isEqualToString:@"SNNewsLoginViewController"]){//如果是登录退至登录
                [self.flipboardNavigationController popToViewController:vc animated:YES];
                return;
            }
        }
    }
    
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -  create UI

- (void)createBindBtn{//立即登录
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = [UIColor clearColor];
    if (self.isPhoneLoginViewModel == YES) {
        [loginButton setTitle:@"立即登录" forState:UIControlStateNormal];
    }
    else{
        [loginButton setTitle:@"立即绑定" forState:UIControlStateNormal];
    }
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginButton sizeToFit];
    [loginButton setFrame:CGRectMake((kAppScreenWidth-loginButton.frame.size.width)/2, kHeaderHeightWithoutBottom+120, loginButton.frame.size.width, loginButton.frame.size.height)];
    [self.view addSubview:loginButton];
    [loginButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    if (self.isPhoneLoginViewModel == YES) {
       [loginButton addTarget:self action:@selector(phoneLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [loginButton addTarget:self action:@selector(bindClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)createPhoneView{//手机号 验证码
    //16 是subtitle height
    CGFloat subtitleHeight = 16;
    if (self.isPhoneLoginViewModel == YES) {
        subtitleHeight = 0;
    }
    self.phoneView = [[SNPhoneLoginView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom+subtitleHeight, self.view.bounds.size.width, 90)];
    self.phoneView.delegate = self;
    [self.view addSubview:_phoneView];
}

- (void)setSeperateLine {
    UIImageView *sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom+169.5, kAppScreenWidth, 0.5)];
    sImageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [self.view addSubview:sImageView];
}

- (void)createSubTitle{//为了保证帐号安全，需绑定手机号
    UILabel* subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, kHeaderHeightWithoutBottom+10, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = SNUICOLOR(kThemeText3Color);
    subTitleLabel.text = @"为了保证帐号安全，需绑定手机号";
    subTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [subTitleLabel sizeToFit];
    [self.view addSubview:subTitleLabel];
}

- (void)createBottomTitle{//积极响应国家号召，做真实的读者
    UILabel* bottomTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    bottomTitleLabel.backgroundColor = [UIColor clearColor];
    bottomTitleLabel.textColor = SNUICOLOR(kThemeText3Color);
    bottomTitleLabel.text = @"积极响应国家号召，做真实的读者";
    bottomTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [bottomTitleLabel sizeToFit];
    [bottomTitleLabel setFrame:CGRectMake((kAppScreenWidth - bottomTitleLabel.frame.size.width) / 2.0, kHeaderHeightWithoutBottom+192,bottomTitleLabel.frame.size.width, bottomTitleLabel.frame.size.height)];
    bottomTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:bottomTitleLabel];
}

- (void)addHeaderView
{
    if (!_headerView)
    {
        _headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderTotalHeight)];
        [self.view addSubview:_headerView];
    }
    
    NSString* title = @"绑定手机";
    if (self.isPhoneLoginViewModel == YES) {
        title = @"手机登录";
    }
    
    [self.headerView setSections:[NSArray arrayWithObjects:title, nil]];
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
}


#pragma mark - createModel

- (void)createVcodeModel{
    if (self.sendVcodeViewModel == nil) {
        self.sendVcodeViewModel = [[SNSendVcodeViewModel alloc] init];
    }
}

- (void)createBindPhoneModel{
    if (self.bindPhoneViewModel == nil) {
        self.bindPhoneViewModel = [[SNBindPhoneViewModel alloc] init];
        self.bindPhoneViewModel.delegate = self;
    }
}

- (void)createPhoneLoginModel{
    if (self.phoneLoginViewModel == nil) {
        self.phoneLoginViewModel = [[SNPhoneLoginViewModel alloc] init];
    }
}

#pragma mark - SNBindPhoneViewModelDelegate 绑定逻辑 代理方法

-(void)resetPhoneViewText:(NSDictionary *)dic{
    [self.phoneView clearVerifyCode];
    [self.phoneView countDownTime];
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
