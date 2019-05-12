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
#import "SNNewsLoginPhoneVoiceVerifyBtn.h"
#import "SNNewsLoginKeyBoard.h"

#import "SNSendVcodeViewModel.h"
#import "SNPhoneLoginViewModel.h"
#import "SNThirdLoginViewModel.h"
#import "SNUserManager.h"
#import "SNSLib.h"

#import "SNNewsPPLoginRequestList.h"
#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginEnvironment.h"

#import "SNNewsReport.h"
#import "SNNewAlertView.h"

@interface SNNewsLoginViewController ()<SNThirdLoginViewDelegate,SNPhoneLoginViewDelegate,SNNewsLoginPhoneVoiceVerifyBtnDelegate,UIScrollViewDelegate,SNNewAlertViewDelegate>
{
    BOOL isThirdloading;
    NSString* tmp_pVcode;//图形验证码
}
@property (nonatomic,strong) SNPhoneLoginView* phoneView;//手机号验证码
@property (nonatomic,strong) SNThirdLoginView* thirdLoginView;//第三方登录
@property (nonatomic,strong) SNNewsLoginPhoneVoiceVerifyBtn* phoneVerifyBtn;//语音验证
@property (nonatomic,strong) UILabel* tipLbl;
@property (nonatomic,strong) UIButton* bottomTip;
@property (nonatomic,strong) UIImageView* line;
@property (nonatomic,strong) UIButton* loginBtn;
@property (nonatomic,strong) UIScrollView* bgScrollView;
@property (nonatomic,strong) UIView* bgView;
@property (nonatomic,strong) UIView* coverLoginView;
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
    self.view.backgroundColor = SNUICOLOR(kThemeLoginBgColor);
    
    [self createScrollView];
    
    [self addHeaderView];
    
    [self createPhoneView]; //键盘
    
    [self createPhoneVoiceVerifyBtn];//语音验证码btn
    
    [self createLoginBtn];  //立即登录
    
    [self createlittleTipLabel];
    
    [self createBottomTipLabel];//用户服务协议
    //
    //    [self setSeperateLine];
    //
    [self createThirdLoginView]; //第三方登录
    
    [self addToolbar];
    
    [self createkeyboardNotification];
    
    if ([SNNewsPPLoginEnvironment isPPLogin]) {
        //新版登录 初始化 拿GID
        [[SNNewsPPLogin sharedInstance] getGID:^(NSString *gid) {
            SNDebugLog(@"PP-GID:%@",gid);
        }];

        SNDebugLog(@"pp login");//新接口
    }

    //埋点 wangshun
    NSString* sourceChannelID = self.loginSuccessModel.sourceChannelID;
    
    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
        NSDictionary* dic = @{@"loginSuccess":@"0",@"cid":[SNUserManager getP1],@"screen":@"0"};
        SNDebugLog(@"sourceID:%@,dic:%@",sourceChannelID,dic);
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
    
    NSString* agif = @"_act=pv&page=49";
    if(self.loginSuccessModel.entrance){
        agif = [agif stringByAppendingFormat:@"&entrance=%@",self.loginSuccessModel.entrance];
    }
    [SNNewsReport reportADotGif:agif];
    SNDebugLog(@"login agif::::%@",agif);
}

#pragma mark - 立即登录

- (void)loginClick:(UIButton*)btn{
    
    [self.phoneView closeKeyBoard];
    [self createPhoneLoginModel];
    
    if (_phoneView.pcodeField && _phoneView.pcodeField.hidden == NO) {///如果是图形验证码 不可点
        return;
    }

    self.phoneLoginViewModel.sourceChannelID = self.loginSuccessModel.sourceChannelID;
    self.phoneLoginViewModel.entrance        = self.loginSuccessModel.entrance;

    if (self.thirdLoginViewModel && self.thirdLoginViewModel.isOpeningThrid == YES) {
        return;
    }

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
    
    if (self.thirdLoginViewModel && self.thirdLoginViewModel.isOpeningThrid == YES) {
        return;
    }
    
    NSDictionary* params = @{@"loginSuccess":self.loginSuccessModel,@"loginFrom":self.loginSuccessModel.sourceChannelID?:@"",@"entrance":self.loginSuccessModel.entrance};

    __weak SNNewsLoginViewController* weakSelf = self;
    [self.thirdLoginViewModel thirdLoginWithName:name WithParams:params Success:^(NSDictionary *resultDic) {
        NSString* success = [resultDic objectForKey:@"success"];
        if ([success isEqualToString:@"1"]) {
            [weakSelf.loginSuccessModel loginSucessed:nil];
            isThirdloading = NO;
        }
        else if ([success isEqualToString:@"-1"]){
            isThirdloading = YES;
        }
        else{
            isThirdloading = NO;
        }
    }];
}

#pragma mark - 发送验证码

- (void)sendVerifyCodeClick:(NSDictionary*)params{//发送验证码
    [self.phoneView closeKeyBoard];
    [self createVcodeModel];
    
    if (self.thirdLoginViewModel && self.thirdLoginViewModel.isOpeningThrid == YES) {
        return;
    }
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    [phoneDic setObject:@"signin" forKey:@"type"];//signin:登录  signup:注册 bind：绑定手机
    
    //加入语音验证码 2017.7月份需求 wangshun
    NSString* sendMethod = [params objectForKey:@"sendMethod"];
    if (sendMethod) {
        [phoneDic setObject:sendMethod?:@"" forKey:@"sendMethod"];
    }
    
    if ([SNNewsPPLoginEnvironment isPPLogin]) {
        if (tmp_pVcode && [tmp_pVcode isKindOfClass:[NSString class]] && tmp_pVcode.length>0) {
            [phoneDic setObject:tmp_pVcode forKey:@"pvcode"];
            tmp_pVcode = nil;
        }
    }

    __weak SNNewsLoginViewController* weakSelf = self;
    [self.sendVcodeViewModel sendVcode:phoneDic Completion:^(NSDictionary *resultDic) {
        NSString* success = [resultDic objectForKey:@"success"];
        if ([success isEqualToString:@"1"]) {
            if (sendMethod && [sendMethod isEqualToString:@"1"]) {
                [weakSelf sendVoiceCodeSuccess:resultDic];
            }
            else{
                [weakSelf.phoneView countDownTime];
                
                if (![sendMethod isEqualToString:@"1"]) {//非语音验证码 wangshun
                    [weakSelf.phoneView becomefirstVcodeTextfield];
                }
            }
            
            [weakSelf.phoneView hidePhotoVcode];
            
            [weakSelf.phoneView clearVerifyCode];
        }
        else if ([success isEqualToString:@"40108"]){
            [weakSelf.phoneView showPhotoVcode];
            [weakSelf.phoneView clearVerifyCode];
            return;
        }
        else if ([success isEqualToString:@"40105"]){//图形验证错误
            [weakSelf.phoneView showPhotoVcode];
            [weakSelf.phoneView clearVerifyCode];
            return;
        }
        else if ([success isEqualToString:@"40109"]){//需要语音验证码
            [weakSelf.phoneView hidePhotoVcode];
            [weakSelf.phoneView closeKeyBoard];
            
            [weakSelf.phoneView countDownTime];
            [weakSelf showPhoneVoiceBtn];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                SNNewAlertView *actionSheet = [[SNNewAlertView alloc] initWithTitle:nil message:@"验证码发送异常，请使用语音验证" cancelButtonTitle:@"取消" otherButtonTitle:@"开始语音验证"];
                actionSheet.delegate = self;
                
                [actionSheet actionWithBlocksCancelButtonHandler:^{
                    
                } otherButtonHandler:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf sendVoiceCodeRequest];
                    });
                }];
                
                [actionSheet show];
            });
            
            return;
        }
    }];
}

//带图形验证码 发送短信验证码
- (void)verifyPhotoCodeAndSendVcode:(NSString *)text{
    tmp_pVcode = text;
    [self sendVerifyCodeClick:nil];
}

- (void)arrive10second{
    [self showPhoneVoiceBtn];
}

-(void)haveVerifyCode:(NSString *)text{
    if (text.length>0) {
        _coverLoginView.hidden = YES;
    }
    else{
        _coverLoginView.hidden = NO;
    }
}

-(void)sendVoiceCodeRequest{
    [self sendVerifyCodeClick:@{@"sendMethod":@"1"}];
}

- (void)sendVoiceCodeSuccess:(NSDictionary*)resultDic{
    [self.phoneVerifyBtn sendVoiceCodeSuccess:resultDic];
}

- (void)showPhoneVoiceBtn{
    self.phoneVerifyBtn.hidden = NO;
    
    CGFloat w = 242;
    CGFloat x = (self.view.bounds.size.width-w)/2.0;
    CGFloat h = 40;
    CGFloat y = CGRectGetMaxY(self.phoneVerifyBtn.frame)+25;
    [self.loginBtn setFrame:CGRectMake(x, y, w, h)];
    self.tipLbl.frame = CGRectMake(0,CGRectGetMaxY(self.loginBtn.frame)+13, self.view.frame.size.width, self.tipLbl.frame.size.height);
    
    //    [self.line setFrame:CGRectMake(0, self.tipLbl.bottom+14+15+12, kAppScreenWidth, 0.5)];
    //    [self.thirdLoginView setFrame:CGRectMake(0, kHeaderHeightWithoutBottom+ 208+16, 320, 80)];
}

#pragma mark - onBack

- (void)onBack:(id)sender{
    if (isThirdloading == YES) {
        return;
    }
    
    [self.loginSuccessModel loginCancel:nil];
    
    //埋点
    NSDictionary* dic = @{@"loginSuccess":@"2",@"cid":[SNUserManager getP1],@"errType":@"0",@"screen":@"0"};
    NSString* sourceChannelID = self.loginSuccessModel.sourceChannelID;
    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
}

#pragma mark -  create UI

- (void)createLoginBtn{//立即登录
    
    CGFloat w = 242;
    CGFloat x = (self.view.bounds.size.width-w)/2.0;
    CGFloat h = 40;
    CGFloat y = CGRectGetMaxY(self.phoneView.frame)+25;
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = SNUICOLOR(kThemeRed1Color);
    [loginButton setTitle:@"立即登录" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginButton sizeToFit];
    [loginButton setFrame:CGRectMake(x, y, w, h)];
    [_bgView addSubview:loginButton];
    [loginButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    
    [loginButton addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)createPhoneView{//手机号 验证码
    self.phoneView = [[SNPhoneLoginView alloc] initWithFrame:CGRectMake(0, kHeaderTotalHeight+22, self.view.bounds.size.width, 110)];
    self.phoneView.delegate = self;
    [_bgView addSubview:_phoneView];
}

- (void)createPhoneVoiceVerifyBtn{
    self.phoneVerifyBtn = [[SNNewsLoginPhoneVoiceVerifyBtn alloc] initWithFrame:CGRectMake(20, self.phoneView.bottom+12, self.view.frame.size.width-40, 15)];
    self.phoneVerifyBtn.delegate = self;
    self.phoneVerifyBtn.hidden = YES;
    [_bgView addSubview:self.phoneVerifyBtn];
}

- (void)createThirdLoginView{//第三方登录
    self.thirdLoginView = [[SNThirdLoginView alloc] initWithFrame:CGRectMake(20, _bgView.bounds.size.height- 41 - 80 -[SNToolbar toolbarHeight], self.view.bounds.size.width-40, 80)];
    self.thirdLoginView.delegate = self;
    [_bgView addSubview:_thirdLoginView];
}

- (void)setSeperateLine {
    self.line = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom+190.5, kAppScreenWidth, 0.5)];
    self.line.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [_bgView addSubview:self.line];
}

- (void)createlittleTipLabel{
    self.tipLbl = [[UILabel alloc] init];
    self.tipLbl.backgroundColor = [UIColor clearColor];
    self.tipLbl.textColor = SNUICOLOR(kThemeText3Color);
    self.tipLbl.text = @"未注册用户，手机验证后自动登录";
    self.tipLbl.font = [UIFont systemFontOfSize:11];
    self.tipLbl.textAlignment = 1;
    [self.tipLbl sizeToFit];
    self.tipLbl.frame = CGRectMake(0,CGRectGetMaxY(self.loginBtn.frame)+13, self.view.frame.size.width, self.tipLbl.frame.size.height);
    [_bgView addSubview:self.tipLbl];
}

- (void)createBottomTipLabel{
    self.bottomTip = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bottomTip.backgroundColor = [UIColor clearColor];
    //    self.bottomTip.textColor = SNUICOLOR(kThemeText3Color);
    [self.bottomTip setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    [self.bottomTip setTitle:@"登录即代表同意“搜狐用户服务协议”" forState:UIControlStateNormal];
    self.bottomTip.titleLabel.font = [UIFont systemFontOfSize:11];
    self.bottomTip.frame = CGRectMake(0,_bgView.bounds.size.height-41-[SNToolbar toolbarHeight], self.view.frame.size.width, 41);
    [_bgView addSubview:self.bottomTip];
    [self.bottomTip addTarget:self action:@selector(userServeAgreementClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)userServeAgreementClick{//进入用户服务协议页面  h5 wangshun 2017.9.25
    [SNUtility openProtocolUrl:SNSOHU_USLER_Protocal];
}

- (void)createScrollView{
    _bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_bgScrollView];
    _bgScrollView.backgroundColor = [UIColor clearColor];
    _bgScrollView.delegate = self;
    
    if (self.view.bounds.size.height<=480) {//4s 适配 wangshun
        _bgScrollView.alwaysBounceVertical = YES;
    }
    
    if (@available(iOS 11.0, *)) {
        _bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _bgView.userInteractionEnabled = YES;
    [_bgScrollView addSubview:_bgView];
    _bgView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [_bgView addGestureRecognizer:tap];
}

- (void)tapClick:(UIGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:_bgView];
    NSLog(@"handleSingleTap!pointx:%f,y:%f",point.x,point.y);
    
    point = [self.phoneView.layer convertPoint:point fromLayer:_bgView.layer];
    //get layer using containsPoint:
    if (![self.phoneView.layer containsPoint:point]) {
        [self.phoneView closeKeyBoard];
    }
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

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.phoneView closeKeyBoard];
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark - 键盘

#pragma mark - createkeyboardNotification

- (void)createkeyboardNotification{
    if (!self.keyboard) {
        self.keyboard = [[SNNewsLoginKeyBoard alloc] initWithToolbar:self.toolbarView];
    }
    [self.keyboard createkeyboardNotification];
}

#pragma mark - removeKeyBoardNotification

- (void)removeKeyBoardNotification{
    [self.keyboard removeKeyBoardNotification];
}

////////////////////////////////////////////////////////////////////////////////

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self createkeyboardNotification];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeKeyBoardNotification];
}





/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

