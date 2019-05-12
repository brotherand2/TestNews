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
#import "SNNewsLoginPhoneVoiceVerifyBtn.h"
#import "SNNewsLoginKeyBoard.h"

#import "SNSendVcodeViewModel.h"
#import "SNBindPhoneViewModel.h"
#import "SNPhoneLoginViewModel.h"
#import "SNThirdBindPhone.h"

#import "SNNewAlertView.h"

#import "SNUserManager.h"
#import "SNSLib.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginEnvironment.h"
#import "SNNewAlertView.h"

@interface SNNewsBindViewController ()<SNPhoneLoginViewDelegate,SNBindPhoneViewModelDelegate,SNNewsLoginPhoneVoiceVerifyBtnDelegate,UIScrollViewDelegate,SNNewAlertViewDelegate>
{
    NSString* tmp_pVcode;
}
@property (nonatomic,strong) SNPhoneLoginView* phoneView;//手机号验证码
@property (nonatomic,strong) SNNewsLoginPhoneVoiceVerifyBtn* phoneVerifyBtn;//语音验证
@property (nonatomic,strong) UILabel* blabel;//
@property (nonatomic,strong) UIImageView* line;//
@property (nonatomic,strong) UILabel* tipLbl;
@property (nonatomic,strong) UIButton* bindBtn;//
@property (nonatomic,strong) UIScrollView* bgScrollView;
@property (nonatomic,strong) UIView* bgView;
@property (nonatomic,strong) UIView* coverLoginView;
@property (nonatomic,strong) UIImageView* p_vcode;
@property (nonatomic,strong) UITextField* p_vcode_field;

@property (nonatomic,strong) SNNewsLoginKeyBoard* keyboard;//键盘事件

@property (nonatomic,strong) SNSendVcodeViewModel* sendVcodeViewModel;//发送验证码流程
@property (nonatomic,strong) SNBindPhoneViewModel* bindPhoneViewModel;//绑定流程
@property (nonatomic,strong) SNPhoneLoginViewModel* phoneLoginViewModel;//登录流程 (绑定页面调登录流程)

@property (nonatomic,assign) BOOL isThird;//是否第三方登录
@property (nonatomic,assign) BOOL isSohuLogin;//是否搜狐登录绑定
@property (nonatomic,weak)   id <SNThirdBindPhoneDelegate> thirdDelegate;//是否第三方登录
@property (nonatomic,strong) NSString* thirdType;//第三方登录绑定type;
@property (nonatomic,strong) NSString* passport;//绑定passport;
@property (nonatomic,strong) NSDictionary* thirdBindData;//第三方绑定数据;

@property (nonatomic,strong) SNNewsBindSuccess* bindSuccessModel;//绑定成功
@property (nonatomic,strong) SNNewsLoginSuccess* loginSuccessModel;//登录成功
@property (nonatomic,assign) BOOL isPhoneLoginViewModel;//是否是登录

//埋点
@property (nonatomic,strong) NSString* local_plat;
@property (nonatomic,strong) NSString* sourceID;
@property (nonatomic,strong) NSString* screen;
@property (nonatomic,strong) NSString* entrance;

@end

@implementation SNNewsBindViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.isPhoneLoginViewModel = NO;
        if ([query objectForKey:@"third"]) {
            self.thirdDelegate = [query objectForKey:@"third"];
            self.isThird = YES;
            
            if ([query objectForKey:@"data"]) {
                NSDictionary* data = [query objectForKey:@"data"];
                if (data && [data isKindOfClass:[NSDictionary class]]) {
                    self.thirdType = [data objectForKey:@"type"];
                    self.passport  = [data objectForKey:@"passport"];
                    self.thirdBindData = data;
                    self.local_plat = [query objectForKey:@"local_plat"];
                    self.sourceID = [query objectForKey:@"loginFrom"];
                }
            }
            
            self.isSohuLogin = NO;
            if ([query objectForKey:@"sohulogin"]) {//如果是搜狐passport登录
                NSString* issohulogin = [query objectForKey:@"sohulogin"];
                if ([issohulogin isEqualToString:@"1"]) {
                    self.isSohuLogin = YES;
                }
            }
            
            NSString* screen = [query objectForKey:@"screen"];
            if ([screen isEqualToString:@"1"]) {
                self.screen = @"1";
            }
            else{
                self.screen = @"0";
            }
            
            
            if ([query objectForKey:@"entrance"]) {
                self.entrance = [query objectForKey:@"entrance"];
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
            
            NSString* buttonTitle = [query objectForKey:@"buttonTitle"];
            if ([buttonTitle isEqualToString:@"立即登录"]) {
                self.isPhoneLoginViewModel = YES;
            }
            
            SNUserinfoEx* userInfoEx = [SNUserinfoEx userinfoEx];
            if (userInfoEx.passport) {
                self.passport = userInfoEx.passport?userInfoEx.passport:[SNUserManager getUserId];
            }
            else{
                self.passport = [SNUserManager getUserId];
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
    
    if (self.isPhoneLoginViewModel == NO) {//如果是绑定 显示 subTitle
        [self createSubTitle];
    }
    
    [self createPhoneView]; //键盘
    [self createBindBtn];   //立即绑定
    [self createlittleTipLabel];
    
    //    [self setSeperateLine];
    //
    //    [self createBottomTitle];
    
    [self createPhoneVoiceVerifyBtn];
    
    [self addToolbar];
    
    [self createkeyboardNotification];
    
    if(self.thirdDelegate){
        NSString* agif = @"_act=connect_phone&_tp=pv";
        [SNNewsReport reportADotGif:agif];
        SNDebugLog(@"login agif::::%@",agif);
    }
}

#pragma mark - 绑定

- (void)bindClick:(UIButton*)btn{
    [self.phoneView closeKeyBoard];
    [self createBindPhoneModel];
    
    if (self.isThird && [SNNewsPPLoginEnvironment isPPLogin]) {//如果是第三方和sohu登录
        [self ppBindClick:btn];
        return;
    }
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    if (self.isThird) {
        [phoneDic setObject:self.thirdType?:@"" forKey:@"type"];
    }
    else{//必传
        [phoneDic setObject:@"bind" forKey:@"type"];//绑定 bind
        [phoneDic setObject:@"1" forKey:@"bindSuccessModel"];
    }
    
    if (self.passport && self.passport.length>0) {//有passport 传passport 没有不传
        [phoneDic setObject:self.passport?:@"" forKey:@"passport"];
    }
    
    if (self.entrance) {
        [phoneDic setObject:self.entrance?:@"" forKey:@"entrance"];
    }
    
    __weak SNNewsBindViewController* weakSelf = self;
    [self.bindPhoneViewModel bindPhone:phoneDic ThirdData:self.thirdBindData Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {//绑定成功
                NSDictionary* userInfo = nil;
                if ([resultDic objectForKey:@"resp"]) {//如果有值(注册) 无值为绑定
                    userInfo = [resultDic objectForKey:@"resp"];
                }
                [weakSelf bindSuccessed:nil UserInfo:userInfo];//这里还需要区分是第三方/绑定
            }
        }
    }];
}

//pplogin bind
- (void)ppBindClick:(UIButton*)btn{
    if (_phoneView.pcodeField && _phoneView.pcodeField.hidden == NO) {///如果是图形验证码 不可点
        return;
    }
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];

    //加开关 wangshun
    if (self.isThird == YES) {
        if (self.isSohuLogin) {
            [phoneDic setObject:@"pp_sohu" forKey:@"pp_bind"];
        }
        else{
            [phoneDic setObject:@"pp_third" forKey:@"pp_bind"];
        }
    }
    
    if (self.entrance) {
        [phoneDic setObject:self.entrance?:@"" forKey:@"entrance"];
    }
    
    __weak SNNewsBindViewController* weakSelf = self;
    [self.bindPhoneViewModel bindPhone:phoneDic ThirdData:self.thirdBindData Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {//绑定成功
                [weakSelf ppBindSuccess:nil UserInfo:nil];//绑定
            }
        }
    }];
}

- (void)bindSuccessed:(NSDictionary*)result UserInfo:(NSDictionary*)userInfo{
    //如果是第三放登录绑定 搜狐passport绑定
    if (self.thirdDelegate && [self.thirdDelegate respondsToSelector:@selector(loginSuccessed:WithUserInfo:)]) {
        [self.thirdDelegate loginSuccessed:nil WithUserInfo:userInfo];
    }
    else{//绑定成功
        if (!self.bindSuccessModel) {
            [self onBack:nil];
        }
        else{
            [self.bindSuccessModel bindSucessed:userInfo];
        }
    }
}

- (void)ppBindSuccess:(NSDictionary*)result UserInfo:(NSDictionary*)userInfo{
    
    //开关
    if (self.thirdDelegate && [self.thirdDelegate respondsToSelector:@selector(ppLoginSuccessed:)]) {
        [self.thirdDelegate ppLoginSuccessed:nil];
        return;
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
    
    //加入语音验证码 2017.7月份需求 wangshun
    NSString* sendMethod = [params objectForKey:@"sendMethod"];
    if (sendMethod) {
        [phoneDic setObject:sendMethod?:@"" forKey:@"sendMethod"];
    }
    
    //开关
    if ([SNNewsPPLoginEnvironment isPPLogin]) {
        if (tmp_pVcode && [tmp_pVcode isKindOfClass:[NSString class]] && tmp_pVcode.length>0) {
            [phoneDic setObject:tmp_pVcode forKey:@"pvcode"];
            tmp_pVcode = nil;
        }
        
        [phoneDic setObject:@"bind" forKey:@"type"];
    }

    __weak SNNewsBindViewController* weakSelf = self;
    [self.sendVcodeViewModel sendVcode:phoneDic Completion:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if([success isEqualToString:@"1"]){
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
                [weakSelf.phoneView countDownTime];
                [weakSelf showPhoneVoiceBtn];
                [weakSelf.phoneView closeKeyBoard];
                
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
        }
    }];
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

//带图形验证码 发送短信验证码
- (void)verifyPhotoCodeAndSendVcode:(NSString *)text{
    tmp_pVcode = text;
    [self sendVerifyCodeClick:nil];
}


//- (void)showPhoneVoiceBtn{
//    self.phoneVerifyBtn.hidden = NO;
//    [self.line setFrame:CGRectMake(0, self.line.bottom+16, kAppScreenWidth, 0.5)];
//    [self.blabel setFrame:CGRectMake(self.blabel.frame.origin.x, self.blabel.frame.origin.y+16, self.blabel.frame.size.width, self.blabel.frame.size.height)];
//}

- (void)showPhoneVoiceBtn{
    self.phoneVerifyBtn.hidden = NO;
    
    CGFloat w = 242;
    CGFloat x = (self.view.bounds.size.width-w)/2.0;
    CGFloat h = 40;
    CGFloat y = CGRectGetMaxY(self.phoneVerifyBtn.frame)+25;
    [self.bindBtn setFrame:CGRectMake(x, y, w, h)];
    self.tipLbl.frame = CGRectMake(0,CGRectGetMaxY(self.bindBtn.frame)+13, self.view.frame.size.width, self.tipLbl.frame.size.height);
    
    //    [self.line setFrame:CGRectMake(0, self.tipLbl.bottom+14+15+12, kAppScreenWidth, 0.5)];
    //    [self.thirdLoginView setFrame:CGRectMake(0, kHeaderHeightWithoutBottom+ 208+16, 320, 80)];
}

//绑定页面走登录逻辑(手机号登录)
- (void)phoneLoginClick:(UIButton*)btn{
    [self createPhoneLoginModel];
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    if (self.isPhoneLoginViewModel) {
        [phoneDic setObject:@"1" forKey:@"isPhoneLoginViewModel"];
    }
    
    
    __weak SNNewsBindViewController* weakSelf = self;
    [self.phoneLoginViewModel loginWithPhoneAndVcode:phoneDic Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {//成功
                if (weakSelf.isPhoneLoginViewModel) {
                    if (!weakSelf.loginSuccessModel) {
                        [self cancelBindpopViewController];
                        return;
                    }
                }
                [weakSelf.loginSuccessModel loginSucessed:resultDic];
            }
            else{
                

            }
        }
    }];
    
}


#pragma mark - onBack

- (void)onBack:(id)sender{
    
    if (self.thirdDelegate == nil) {
        [self cancelBindpopViewController];
        return;
    }
    
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
    
    if(self.isThird == YES){//如果是登录(第三方/sohu passport)绑定
        if (self.isSohuLogin) {//sohu登录特殊
            UIViewController* top_vc = [TTNavigator navigator].topViewController;
            NSArray* vc_arr = top_vc.flipboardNavigationController.viewControllers;
            if (vc_arr.count>3) {
                UIViewController* sohu_vc = [vc_arr objectAtIndex:vc_arr.count-2];
                NSString* classname = NSStringFromClass([sohu_vc class]);
                if([classname isEqualToString:@"SNNewsSohuLoginViewController"]){//如果是搜狐登录 退到搜狐登录页的上一层
                    UIViewController* vc = [vc_arr objectAtIndex:vc_arr.count-3];
                    if (vc) {
                        [top_vc.flipboardNavigationController popToViewController:vc animated:YES completion:^{
                            
                        }];
                    }
                    else{
                        [self.flipboardNavigationController popViewControllerAnimated:YES];
                    }
                    return;
                }
            }
            else{
                [self.flipboardNavigationController popViewControllerAnimated:YES];
            }
        }
        else{//退一层
            [self.flipboardNavigationController popViewControllerAnimated:YES];
        }
        
        [self burySuccess:@"2" loginType:self.local_plat errType:@"1"];
    }
    else{//如果是绑定
        
        if (self.bindSuccessModel && !self.isPhoneLoginViewModel) {
            [self.bindSuccessModel bindCanceled:nil];
            return;
        }
        
        if (self.isPhoneLoginViewModel){
            if (self.loginSuccessModel) {
                [self.loginSuccessModel loginSucessed:nil];
            }
            else{
                [self.flipboardNavigationController popViewControllerAnimated:YES];
            }
        }
        else{
            [self.flipboardNavigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)burySuccess:(NSString*)str loginType:(NSString*)loginType errType:(NSString*)errType{
    //    NSDictionary* dic = @{@"loginSuccess":str,@"loginType":loginType,@"cid":[SNUserManager getP1],@"errType":errType?:@""};
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:str?:@"" forKey:@"loginSuccess"];
    [dic setObject:loginType?:@"" forKey:@"loginType"];
    [dic setObject:[SNUserManager getP1] forKey:@"cid"];
    if (self.screen) {
        [dic setObject:self.screen?:@"0" forKey:@"screen"];
    }
    
    if (errType) {
        [dic setObject:errType?:@"" forKey:@"errType"];
    }
    
    NSString* sourceID = self.sourceID?:@"";
    SNDebugLog(@"手机号 sourceChannelID:%@ dic:%@",sourceID,dic);
    if (sourceID && ![sourceID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceID bodyDic:dic];
    }
}

#pragma mark -  create UI

- (void)createBindBtn{//立即登录
    
    CGFloat w = 242;
    CGFloat x = (self.view.bounds.size.width-w)/2.0;
    CGFloat h = 40;
    CGFloat y = CGRectGetMaxY(self.phoneView.frame)+25;
    
    
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
    [loginButton setFrame:CGRectMake(x, y, w, h)];
    [_bgView addSubview:loginButton];
    
    [loginButton setBackgroundColor:SNUICOLOR(kThemeRed1Color)];
    [loginButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    
    if (self.isPhoneLoginViewModel == YES) {
        [loginButton addTarget:self action:@selector(phoneLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [loginButton addTarget:self action:@selector(bindClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.bindBtn = loginButton;
    
    _coverLoginView = [[UIView alloc] initWithFrame:loginButton.bounds];
    [_coverLoginView setBackgroundColor:SNUICOLOR(kThemeLoginBgColor)];
    _coverLoginView.userInteractionEnabled = NO;
    [loginButton addSubview:_coverLoginView];
    _coverLoginView.alpha = 0.4;
    _coverLoginView.hidden = NO;
}

- (void)createPhoneView{//手机号 验证码
    //16 是subtitle height
    CGFloat subtitleHeight = 16;
    if (self.isPhoneLoginViewModel == YES) {
        subtitleHeight = 0;
    }
    self.phoneView = [[SNPhoneLoginView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom+22+subtitleHeight, self.view.bounds.size.width, 90)];
    self.phoneView.delegate = self;
    [_bgView addSubview:_phoneView];
}

- (void)createPhoneVoiceVerifyBtn{
    self.phoneVerifyBtn = [[SNNewsLoginPhoneVoiceVerifyBtn alloc] initWithFrame:CGRectMake(20, self.phoneView.bottom+12, self.view.frame.size.width-40, 15)];
    self.phoneVerifyBtn.delegate = self;
    self.phoneVerifyBtn.hidden = YES;
    [_bgView addSubview:self.phoneVerifyBtn];
}

- (void)setSeperateLine {
    self.line = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom+169.5, kAppScreenWidth, 0.5)];
    self.line.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [_bgView addSubview:self.line];
}

- (void)createSubTitle{//为了保证帐号安全，需绑定手机号
    UILabel* subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, kHeaderHeightWithoutBottom+10, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = SNUICOLOR(kThemeText3Color);
    subTitleLabel.text = @"为了保证帐号安全，需绑定手机号";
    subTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [subTitleLabel sizeToFit];
    [_bgView addSubview:subTitleLabel];
}

- (void)createlittleTipLabel{
    self.tipLbl = [[UILabel alloc] init];
    self.tipLbl.backgroundColor = [UIColor clearColor];
    self.tipLbl.textColor = SNUICOLOR(kThemeText3Color);
    self.tipLbl.text = @"未注册用户，手机验证后自动登录";
    self.tipLbl.font = [UIFont systemFontOfSize:11];
    self.tipLbl.textAlignment = 1;
    [self.tipLbl sizeToFit];
    self.tipLbl.frame = CGRectMake(0,CGRectGetMaxY(self.bindBtn.frame)+13, self.view.frame.size.width, self.tipLbl.frame.size.height);
    [_bgView addSubview:self.tipLbl];
}

- (void)createBottomTitle{//积极响应国家号召，做真实的读者
    self.blabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.blabel.backgroundColor = [UIColor clearColor];
    self.blabel.textColor = SNUICOLOR(kThemeText3Color);
    self.blabel.text = @"积极响应国家号召，做真实的读者";
    self.blabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [self.blabel sizeToFit];
    [self.blabel setFrame:CGRectMake((kAppScreenWidth - self.blabel.frame.size.width) / 2.0, kHeaderHeightWithoutBottom+192,self.blabel.frame.size.width, self.blabel.frame.size.height)];
    self.blabel.textAlignment = NSTextAlignmentCenter;
    [_bgView addSubview:self.blabel];
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
    
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_bgScrollView addSubview:_bgView];
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

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self.phoneView closeKeyBoard];
//}

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
