//
//  SNBindMobileNumViewController.m
//  sohunews
//
//  Created by yangln on 14-9-29.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNBindMobileNumViewController.h"
#import "SNNotificationCenter.h"
#import "SNUserManager.h"
#import "SNUserUtility.h"
#import "SNInterceptConfigManager.h"
#import "SNMobileLoginRequest.h"
#import "NSJSONSerialization+String.h"
#import "SNGuideRegisterManager.h"
#import "SNActionSheetLoginManager.h"
#import "SNGuideRegisterManager.h"
#import "SNThirdRegisterPassportRequest.h"
#import "SNThirdBindMobileRequest.h"
#import "SNNewAlertView.h"
//#import "JKNotificationCenter.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNNewsThirdLoginEnable.h"

#import "SNSendSmsGo.h"

#import "SNMySDK.h"
#import "SNSLib.h"

#import "SNLoginLaterBingPhone.h"
#import "SNThirdBindPhone.h"

#import "SNNewsLoginSuccess.h"

#import "SNLoginRegisterViewController.h"
#import "SNNewsRecordLastLogin.h"

static NSString *staticString = @"积极响应国家号召，做真实的读者。";
#define kStaticLabelTag 10000

@interface SNBindMobileNumViewController ()<SNUserCenterGeneralLoginViewDelegate> {
    NSString *_headTitle;
    NSString *_buttonTitle;
    NSString *_staticFromPage;
    NSString *_backURLString;
    NSString *_staticTitle;
    NSString *_isFromH5;
    BOOL _isPushViewController;
    SNGuideRegisterType _guideRegisterType;
    BOOL _isCommentRegisterType;
    
    
    BOOL isloadingLogin;//登录等待
}

@property (nonatomic,strong) NSString* bindMsg;//绑定文案 这个地方先这样 重构再说 wangshun

@property (nonatomic,strong) NSDictionary* thirdLoginBingPhoneStatus;//登录后绑定手机类型 1:成功绑定 2:注册
@property (nonatomic,strong) id <SNThirdBindPhoneDelegate> thirdCallBack;//成功回调
@property (nonatomic,strong) SNSendSmsGo* sendSmsGo;
@property (nonatomic,weak) UIViewController* popvc; //搜狐绑定返回

@property (nonatomic,strong) NSString* commentBindOpen; //搜狐绑定返回
@property (nonatomic,weak) id commentpopvc;

//wangshun SNNewsLogin block
@property (nonatomic,strong) NSString* isNewsLogin;//是否是block调起 这么干太扯 wangshun


@property (nonatomic,strong) SNNewsLoginSuccess* bindSuccessModel; //搜狐绑定返回

@property (nonatomic,assign) BOOL isBindSuccessed;//红包用 wangshun 2017.5.12

//wangshun 2017.5.8
@property (nonatomic,copy) void (^mobileLoginLoginSuccessBlock)(NSDictionary* info);

@end

@implementation SNBindMobileNumViewController

-(void)dealloc{
    SNDebugLog(@"SNBindMobileNumViewController dealloc");
    [SNNotificationManager removeObserver:self];
}

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        _headTitle = [query objectForKey:@"headTitle"];
        _buttonTitle = [query objectForKey:@"buttonTitle"];
        _staticFromPage = [query objectForKey:@"staticFromPage"];
        _staticTitle = [query objectForKey:@"staticTitle"];
        _isFromH5 = [query objectForKey:@"isFromH5"];
        _backURLString = [query objectForKey:kRegisterInfoKeyBackUrl];
        _userinfoService = [[SNUserinfoService alloc] init];
        self.delegate = [query objectForKey:@"delegate"];
        self.method = [query objectForKey:@"method"];
        self.methodBack = [query objectForKey:@"methodBack"];
        _isPushViewController = YES;
        
        self.thirdLoginBingPhoneStatus = [query objectForKey:@"data"];
        
        self.loginFromType = @"bind";
        
        self.thirdCallBack = [query objectForKey:@"third"];//第三方绑定成功回调
        
        self.popvc = [query objectForKey:@"popvc"];//搜狐绑定返回
        
        if ([query objectForKey:@"isNewsLogin"]) {
            self.isNewsLogin = @"1";
        }
        
        self.commentBindOpen = [query objectForKey:@"commentBindOpen"];
        self.commentpopvc = [query objectForKey:@"commentpopvc"];
        
        if ([query objectForKey:@"bindSuccess"]) {
            id sender = [query objectForKey:@"bindSuccess"];
            if (sender && [sender isKindOfClass:[SNNewsLoginSuccess class]]) {
                self.bindSuccessModel = sender;
            }
        }
        
        self.isBindSuccessed = NO;
    }
    return self;
}

- (id)initWithButtonTitle:(NSString *)buttonTitle {
    self = [super init];
    if (self) {
        _buttonTitle = buttonTitle;
        _userinfoService = [[SNUserinfoService alloc] init];
        _isPushViewController = NO;
        self.loginFromType = @"login";
        self.isBindSuccessed = NO;
    }
    
    return self;
}

- (id)initWithButtonTitle:(NSString *)buttonTitle WithLoginSuccessBlock:(void (^)(NSDictionary*info))loginsuccessBlock{
    if (self = [super init]) {
        _buttonTitle = buttonTitle;
        _userinfoService = [[SNUserinfoService alloc] init];
        _isPushViewController = NO;
        self.loginFromType = @"login";
        
        if (loginsuccessBlock) {
            self.mobileLoginLoginSuccessBlock = loginsuccessBlock;
        }
        self.isBindSuccessed = NO;
    }
    return self;
}



- (void)loadView {
    [super loadView];
    
    if (_isPushViewController) {
        [self addHeaderView];
        [self.headerView setSections:[NSArray arrayWithObjects:_headTitle, nil]];
        CGSize titleSize = [_headTitle sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        [self initLoginView:CGRectMake(0, kHeaderTotalHeight, kAppScreenWidth, kAppScreenHeight - kHeaderTotalHeight - 49)];
        [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height -2, titleSize.width + 6, 2)];
        [self addToolbar];
        [self setStaticString];
    } else {
        [self initLoginView:CGRectMake(0, 0, kAppScreenWidth, 170)];
    }
    
    [SNActionSheetLoginManager sharedInstance].guideType = self.registerType;
    
    [SNNotificationManager addObserver:self
                              selector:@selector(keyboardWillShow:)
                                  name:UIKeyboardWillShowNotification
                                object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(keyboardWillHidden:)
                                  name:UIKeyboardWillHideNotification
                                object:nil];
    
    
    [SNNotificationManager addObserver:self selector:@selector(sendVerifyCodeRequest:)  name:kSendVerifyCodeNotification object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(mobileNumLoginRequest:) name:kMobileNumLoginNotification object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(checkMobileNumResult:) name:kCheckMobileNumResultNotification object:nil];

}

- (void)initLoginView:(CGRect)frame {
    if ([self.loginFromType isEqualToString:@"login"]) {
        _loginView = [[SNUserCenterGeneralLoginView alloc] initWithFrame:frame buttonTitleWithNoSeperateLine:_buttonTitle];
        _loginView.delegate = self;
        [self.view addSubview:_loginView];
        _loginView.fromType = self.loginFromType;
    }
    else{
        _loginView = [[SNUserCenterGeneralLoginView alloc] initWithFrame:frame buttonTitle:_buttonTitle];
        if (self.thirdLoginBingPhoneStatus == nil) {
            _loginView.phoneVerifyData = @{@"type":@"bind"};
        }
        else{
            NSString* type = [self.thirdLoginBingPhoneStatus objectForKey:@"type"];
            NSDictionary* dic = @{@"type":type};
            _loginView.phoneVerifyData = dic;
        }
        _loginView.delegate = self;
        [self.view addSubview:_loginView];
        _loginView.fromType = self.loginFromType;
    }
}

- (void)arrive10second{
    if ([self.loginFromType isEqualToString:@"login"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.arri_delegate && [self.arri_delegate respondsToSelector:@selector(arrive10secondLoginRegister)]){
                [self.arri_delegate arrive10secondLoginRegister];
            }
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_loginView showPhoneVerify];
            [self showPhoneVerify];
        });
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped)];
    [self.view addGestureRecognizer:tapView];
    
    [self addSwipeGesture];
    
    _guideRegisterType = [[SNActionSheetLoginManager sharedInstance] getGuideRegisterType];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_loginView setResignFirstResponder];
    [SNNotificationManager postNotificationName:kLoginAndBindViewDisappearNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_isFromH5 && [_isFromH5 isEqualToString:@"1"]) {
        if (self.delegate != nil &&
            self.methodBack != nil &&
            [self.methodBack isKindOfClass:[NSValue class]] &&
            [self.delegate respondsToSelector:[self.methodBack pointerValue]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (self.isBindSuccessed == NO) {
                if ([self.delegate respondsToSelector:[self.methodBack pointerValue]]) {
                    [self.delegate performSelector:[self.methodBack pointerValue] withObject:nil];
                }
            }
#pragma clang diagnostic pop
        }
    }
    else{
        if (self.isBindSuccessed == NO) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([self.delegate respondsToSelector:[self.methodBack pointerValue]]) {
                [self.delegate performSelector:[self.methodBack pointerValue] withObject:nil];
            }
#pragma clang diagnostic pop
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)getCurrentPhoneData:(id)sender{
    
    NSString* type = @"signin";
    if (self.thirdLoginBingPhoneStatus) {
        type = [self.thirdLoginBingPhoneStatus objectForKey:@"type"];
    }
    
    NSString* mobileNo = _loginView.mobileNumTextField.text;
    
    NSDictionary* dic = @{@"type":type,@"mobileNo":mobileNo};
    return dic;
}

- (void)analysisThirdCallBack{
    NSString* classname = NSStringFromClass([self.thirdCallBack class]);
    NSString* loginType = @"";
    if (classname) {
        if ([classname isEqualToString:@"SNSSOQQWrapper"]) {
            loginType = @"qq";
        }
        else if ([classname isEqualToString:@"SNSSOSinaWrapper"]){
            loginType = @"weibo";
        }
        else if ([classname isEqualToString:@"SNWXHelper"]){
            loginType = @"wechat";
        }
        
        [self burySuccess:@"2" loginType:loginType errType:@"1"];
    }
}

- (void)onBack:(id)sender {
    
    [_loginView setResignFirstResponder];
    
    NSString* str = @"退出登录";
    if([self.commentBindOpen isEqualToString:@"1"]){
        str = @"退出绑定";
    }
    
    SNNewAlertView* alertView = [[SNNewAlertView alloc] initWithTitle:nil message:@"登录尚未完成，是否放弃绑定?" cancelButtonTitle:str otherButtonTitle:@"继续绑定"];
    [alertView actionWithBlocksCancelButtonHandler:^{
        
        if ([self.commentBindOpen isEqualToString:@"1"]) {
            if (self.popvc) {//wangshun 搜狐绑定返回
                [self.flipboardNavigationController popToViewController:self.popvc animated:YES];
                return ;
                
            }
        }
        
        if (self.thirdCallBack) {//如果是 第三方绑定 搜狐登录绑定
            [self analysisThirdCallBack];
            if (self.flipboardNavigationController) {
                
                if (self.popvc) {//wangshun 搜狐绑定返回
                    NSString* className = NSStringFromClass([self.popvc class]);
                    if ([className isEqualToString:@"SNLoginRegisterViewController"]) {
                        [self.flipboardNavigationController popToViewController:self.popvc animated:YES];
                        return ;
                    }
                }
                else{
                    if (_thirdCallBack) {//这个重构彻底解决 wangshun
                        SNDebugLog(@"self.flipboardNavigationController.viewControllers:::%@",self.flipboardNavigationController.viewControllers);
                        NSInteger num = self.flipboardNavigationController.viewControllers.count;
                        if (num>3) {
                            UIViewController* vc1 = [self.flipboardNavigationController.viewControllers objectAtIndex:num-1];
                            UIViewController* vc2 = [self.flipboardNavigationController.viewControllers objectAtIndex:num-2];
                            UIViewController* vc3 = [self.flipboardNavigationController.viewControllers objectAtIndex:num-3];
                            
                            if (vc1) {
                                NSString* classname = NSStringFromClass([vc1 class]);
                                if ([classname isEqualToString:@"SNBindMobileNumViewController"]) {
                                    if (vc2) {
                                        classname = NSStringFromClass([vc2 class]);
                                        if ([classname isEqualToString:@"SNLoginRegisterViewController"]) {
                                            if (vc3 && [vc3 isKindOfClass:[UIViewController class]]) {
                                                [self.flipboardNavigationController popToViewController:vc3 animated:YES];
                                                return;
                                            }
                                        }
                                        else if ([classname isEqualToString:@"SNSoHuAccountLoginRegisterViewController"]){
                                           
                                            if (vc3) {
                                                classname  = NSStringFromClass([vc3 class]);
                                                if ([classname isEqualToString:@"SNLoginRegisterViewController"]) {
                                                    
                                                    if (num>4) {
                                                        UIViewController* vc4 = [self.flipboardNavigationController.viewControllers objectAtIndex:num-4];
                                                        if (vc4 && [vc4 isKindOfClass:[UIViewController class]]) {
                                                            [self.flipboardNavigationController popToViewController:vc4 animated:YES];
                                                            return;
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
            }
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        else{
            if (self.flipboardNavigationController && !_isCommentRegisterType) {
                [self.flipboardNavigationController popViewController];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
        if (self.delegate != nil && self.methodBack != nil && [self.methodBack isKindOfClass:[NSValue class]] && [self.delegate respondsToSelector:[self.methodBack pointerValue]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:[self.methodBack pointerValue] withObject:nil];
#pragma clang diagnostic pop
        }
        
    } otherButtonHandler:^{
        
    }];
    
    [alertView show];
    
}

- (void)sendVerifyCodeRequest:(NSNotification*)notification {
    
    [self resetToolBarOrigin];
    
    //如果同时 login 和 bind 的实例都在
    NSString* fromType = [notification object];
    if (fromType && ![_loginView.fromType isEqualToString:fromType]) {
        return;
    }
    
    if (_loginView.mobileNumTextField.text.length == 0){
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    [_loginView isValidateMobileNum:_loginView.mobileNumTextField.text isSendVerificode:YES];
}

- (void)mobileNumLoginRequest:(NSNotification*)notification {
    [self resetToolBarOrigin];
    
    NSString* fromType = [notification object];
    if (fromType && ![_loginView.fromType isEqualToString:fromType]) {
        return;
    }
    
    if ([SNNewsThirdLoginEnable sharedInstance].isLanding == YES) {//第三方限制
        return;
    }

    //wangshun test bind
//    NSInteger num = self.flipboardNavigationController.viewControllers.count;
//    SNDebugLog(@"%d",num);
//    [self loginSuccessed:nil];
//    return;
    
    if (_loginView.mobileNumTextField.text.length == 0) {
        [_loginView setLoginButtonSatus:YES];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [_loginView setLoginButtonSatus:YES];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    
    //[self burySuccess:@"0" loginType:@"mobile" errType:@""];
    
    [_loginView isValidateMobileNum:_loginView.mobileNumTextField.text isSendVerificode:NO];
}

- (void)checkMobileNumResult:(NSNotification *)notification {
    NSString* fromType = [notification object];
    
    if (fromType && ![_loginView.fromType isEqualToString:fromType]) {
        return;
    }
    
    BOOL result = [[notification.userInfo objectForKey:kCheckMobileNumResultKey] boolValue];
    BOOL isSendVerifyCode = [[notification.userInfo objectForKey:kIsSendVerifyCodeKey] boolValue];
    if (!result) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入正确的手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }

    [self requestAction: isSendVerifyCode];
}

- (void)analyseResp:(SNBaseRequest *) request withData:(NSDictionary*)respDic{
    NSNumber* statusCode = [respDic objectForKey:@"statusCode"];
    if (statusCode.integerValue == 10000000) {//成功
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送成功" toUrl:nil mode:SNCenterToastModeOnlyText];
        if ([_loginView.requestType isEqualToString:kRequestTypeVerifyCode]) {
            SNDebugLog(@"send verifyCode success");
            [_loginView countDownTime];
        }
    }
    else if (statusCode.integerValue == 10000030){//
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"手机号错误" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else if (statusCode.integerValue == 10000031){
         [[SNCenterToast shareInstance] showCenterToastWithTitle:@"短信发送次数过多" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}

- (void)thirdSignup{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:self.thirdLoginBingPhoneStatus];
    
    [params setValue:_loginView.mobileNumTextField.text forKey:@"mobile"];
    [params setValue:_loginView.verifyCodeTextField.text forKey:@"smCode"];
    
    [params setValue:self.loginFrom forKey:@"loginfrom"];
    [params setValue:kLoginTypeMobileNum forKey:@"logintype"];
    
    
    //去掉原来的参数
    [params removeObjectForKey:@"type"];
    
    
    SNDebugLog(@"self.::::%@",self.thirdLoginBingPhoneStatus);
    
    [[[SNThirdRegisterPassportRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg = [responseObject objectForKey:@"statusMsg"];
        
        if (statusCode.integerValue == 10000000) {
            if ([statusMsg isEqualToString:@"登录成功"]) {
                statusMsg = @"绑定成功";
            }
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            [self performSelector:@selector(loginSuccessed:) withObject:responseObject afterDelay:2.5];
        }
        else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        
    }];
}


- (void)thirdBind{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:self.thirdLoginBingPhoneStatus];
    
    [params setValue:_loginView.mobileNumTextField.text forKey:@"mobile"];
    [params setValue:_loginView.verifyCodeTextField.text forKey:@"smCode"];
    
//    [params setValue:self.loginFrom forKey:@"loginfrom"];
//    [params setValue:kLoginTypeMobileNum forKey:@"logintype"];
    
    //去掉原来的参数
    [params removeObjectForKey:@"type"];
    
    
    SNDebugLog(@"self.::::%@",self.thirdLoginBingPhoneStatus);
    
    [[[SNThirdBindMobileRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
        NSString* statusMsg  = [responseObject objectForKey:@"statusMsg"];
        if (statusCode.integerValue == 10000000){//成功
            
            if ([statusMsg isEqualToString:@"登录成功，该手机号也绑定了其他登录方式哦！"]) {
                statusMsg = @"绑定成功，该手机号也绑定了其他登录方式哦！";
            }
            
            if ([statusMsg isEqualToString:@"登录成功"]) {
                statusMsg = @"绑定成功";
            }
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            [self performSelector:@selector(loginSuccessed:) withObject:nil afterDelay:1.8];
        }
        else if (statusCode.integerValue == 10000010){//验证码输入有误
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else if (statusCode.integerValue == 10000011){//该验证码已失效，请重新获取验证码
            
            //验证码输对了也不一定能过 所以要重置 passport 验证码只能用一次
            _loginView.verifyCodeTextField.text = @"";
            [_loginView resetVerifyCodeLabelStatus];
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else if (statusCode.integerValue == 10000012){//手机号绑定失败，已达安全手机绑定上限
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        
    }];
}

- (void)loginSuccessed:(NSDictionary*)dic{
    self.isBindSuccessed = YES;
    [[SNCenterToast shareInstance] hideToast];

    SNNavigationController* navi = [TTNavigator navigator].topViewController.flipboardNavigationController;
    
    NSInteger num = navi.viewControllers.count;
    if (num>3) {
        UIViewController* vc1 = [navi.viewControllers objectAtIndex:num-1];
        UIViewController* vc2 = [navi.viewControllers objectAtIndex:num-2];
        if (vc1 && [NSStringFromClass([vc1 class]) isEqualToString:@"SNBindMobileNumViewController"]) {
            if (vc2 && [NSStringFromClass([vc2 class]) isEqualToString:@"SNLoginRegisterViewController"]) {
                SNLoginRegisterViewController* loginregister_vc = (SNLoginRegisterViewController*)vc2;
//                if (loginregister_vc.loginSuccessModel && loginregister_vc.loginSuccessModel.current_topViewController) {
//                    self.isNewsLogin = @"1";
//                }
            }
        }
    }
    
    
    //wangshun 如果 微信 微博 qq 搜狐passpost 直接return 让第三方自己处理
    if (_thirdCallBack && [self.isNewsLogin isEqualToString:@"1"]) {
        [self performSelector:@selector(sendLoginNotification:) withObject:dic afterDelay:0.5];
        return;
    }
    
    
    [self performSelector:@selector(sendLoginNotification:) withObject:dic afterDelay:0.5];
    
    if (self.flipboardNavigationController) {
        if([self.commentBindOpen isEqualToString:@"1"]){
            if(self.commentpopvc){
                [self.flipboardNavigationController popToViewController:self.commentpopvc animated:YES];
                return;
            }
        }
    }
    
    if (_thirdCallBack) {//这个重构彻底解决 wangshun
        SNDebugLog(@"self.flipboardNavigationController.viewControllers:::%@",self.flipboardNavigationController.viewControllers);
        NSInteger num = self.flipboardNavigationController.viewControllers.count;
        if (num>3) {
            UIViewController* vc1 = [self.flipboardNavigationController.viewControllers objectAtIndex:num-1];
            UIViewController* vc2 = [self.flipboardNavigationController.viewControllers objectAtIndex:num-2];
            UIViewController* vc3 = [self.flipboardNavigationController.viewControllers objectAtIndex:num-3];
            
            if (vc1) {
                NSString* classname = NSStringFromClass([vc1 class]);
                if ([classname isEqualToString:@"SNBindMobileNumViewController"]) {
                    if (vc2) {
                        classname = NSStringFromClass([vc2 class]);
                        if ([classname isEqualToString:@"SNLoginRegisterViewController"]) {
                            if (vc3 && [vc3 isKindOfClass:[UIViewController class]]) {
                                SNDebugLog(@"这个重构彻底解决 wangshun");
                                [self.flipboardNavigationController popToViewController:vc3 animated:YES];
                                return;
                            }
                        }
                        else if ([classname isEqualToString:@"SNSoHuAccountLoginRegisterViewController"]){
                            
                            if (vc3) {
                                classname  = NSStringFromClass([vc3 class]);
                                if ([classname isEqualToString:@"SNLoginRegisterViewController"]) {
                                    
                                    if (num>4) {
                                        UIViewController* vc4 = [self.flipboardNavigationController.viewControllers objectAtIndex:num-4];
                                        if (vc4 && [vc4 isKindOfClass:[UIViewController class]]) {
                                            [self.flipboardNavigationController popToViewController:vc4 animated:YES];
                                            return;
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    if (self.delegate && self.method) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self.delegate respondsToSelector:[self.method pointerValue]]) {
            [self.delegate performSelector:[self.method pointerValue] withObject:nil];
        }
    }
#pragma clang diagnostic pop
    if (self.flipboardNavigationController) {
        if ([self.commentBindOpen isEqualToString:@"1"]) {
            if (self.popvc) {
                __weak SNBindMobileNumViewController* weakSelf = self;
               [self.flipboardNavigationController popToViewController:self.popvc animated:YES completion:^{
                   [SNGuideRegisterManager guideForContentComment];
                   
//                   if (weakSelf.bindSuccessModel) {
//                       [weakSelf.bindSuccessModel loginSuccessed:nil];
//                   }
               }];
                return;
            }
        }

        [self.flipboardNavigationController popViewControllerAnimated:YES];
        
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)sendLoginNotification:(NSDictionary*)dic{
    if (self.thirdCallBack) {//重构考虑原来是单例的问题 wangshun
        if ([self.thirdCallBack respondsToSelector:@selector(loginSuccessed:)]) {
            [self.thirdCallBack performSelector:@selector(loginSuccessed:) withObject:dic];
        }
    }
}

- (void)requestAction:(BOOL)isSendVerifyCode {
    NSString *urlString = nil;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    [params setValue:_loginView.mobileNumTextField.text forKey:@"mobileNo"];
    
    if (isSendVerifyCode) {//发送验证码
        
        if (self.thirdLoginBingPhoneStatus) {//如果是这版改的 第三方登录回调
            urlString = SNLinks_Path_Login_VerifyCode_V3;
            NSString* type = [self.thirdLoginBingPhoneStatus objectForKey:@"type"];
            [params setObject:type forKey:@"type"];
        }
        else{
            if ([_buttonTitle isEqualToString:kImmediatelyLogin]) {//手机登录
                urlString = SNLinks_Path_Login_VerifyCode_V3;
                [params setObject:@"signin" forKey:@"type"];
            } else {
//                urlString = SNLinks_Path_Login_BindVerifyCode;
                urlString = SNLinks_Path_Login_VerifyCode_V3;
                [params setObject:@"bind" forKey:@"type"];
            }
        }
    } else {//(登录/绑定)
        if(_loginView.verifyCodeTextField.text.length == 0) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入验证码" toUrl:nil mode:SNCenterToastModeOnlyText];
            return;
        }
        
        if (self.thirdLoginBingPhoneStatus && [self.thirdLoginBingPhoneStatus isKindOfClass:[NSDictionary class]]) {//如果是第三方
            NSString* type = [self.thirdLoginBingPhoneStatus objectForKey:@"type"];
            if ([type isEqualToString:@"signup"]) {//注册
                [self thirdSignup];
                return;
            }
            else if ([type isEqualToString:@"bind"]){//绑定
                [self thirdBind];
                return;
            }
        }
        
        if ([_buttonTitle isEqualToString:kImmediatelyLogin]){
            urlString = SNLinks_Path_Login_MobileLogin_V3;
            [params setValue:_loginView.verifyCodeTextField.text forKey:@"captcha"];
            [params setValue:self.loginFrom forKey:@"loginfrom"];
            [params setValue:kLoginTypeMobileNum forKey:@"logintype"];
            
            if (isloadingLogin == YES) {
                return;
            }
            isloadingLogin = YES;
        
        } else {
            urlString = SNLinks_Path_Login_BindMobile;
            [params setValue:_loginView.verifyCodeTextField.text forKey:@"captcha"];
            
            SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
            NSString* passport = userInfo.userName;
            [params setObject:passport?:@"" forKey:@"passport"];
            [params setValue:[_loginView.mobileNumTextField.text trim] forKey:@"mobile"];
            [params setValue:[_loginView.verifyCodeTextField.text trim] forKey:@"smCode"];
        }
    }
    
    [[[SNMobileLoginRequest alloc] initWithDictionary:params andUrl:urlString] send:^(SNBaseRequest *request, id requestDict) {
        
        if ([SNSendSmsGo isSendSmsGo:request]) {//如果是发送验证码
            
            if (self.sendSmsGo) {
                self.sendSmsGo = nil;
            }
            self.sendSmsGo = [[SNSendSmsGo alloc] init];
            
            __weak SNBindMobileNumViewController* weakSelf = self;
            self.sendSmsGo.countDownTime = ^(void){//这里先这样，等着重构吧 wangshun
                
                if ([weakSelf.loginView.requestType isEqualToString:kRequestTypeVerifyCode]) {
                    SNDebugLog(@"send verifyCode success");
                    [weakSelf.loginView countDownTime];
                }
            };
            
            [self.sendSmsGo analyseResp:request withData:requestDict];
            
            return;
        }
        
        
        if ([request.url rangeOfString:@"share/bindMobile.go"].location != NSNotFound) {
            NSNumber* statusCode = [requestDict objectForKey:@"statusCode"];
            NSString* statusMsg  = [requestDict objectForKey:@"statusMsg"];
            if (statusCode.integerValue == 10000000){//成功
                
                if ([statusMsg isEqualToString:@"登录成功，该手机号也绑定了其他登录方式哦！"]) {
                    statusMsg = @"绑定成功，该手机号也绑定了其他登录方式哦！";
                }
                
                if ([statusMsg isEqualToString:@"登录成功"]) {
                    statusMsg = @"绑定成功";
                }
                SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
                userInfo.isRealName = YES;
                [userInfo saveUserinfoToUserDefault];
                
                [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
                [self performSelector:@selector(loginSuccessed:) withObject:nil afterDelay:1.8];
            }
            else if (statusCode.integerValue == 10000010){//验证码输入有误
                [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (statusCode.integerValue == 10000011){//该验证码已失效，请重新获取验证码
                
                //验证码输对了也不一定能过 所以要重置 passport 验证码只能用一次
                _loginView.verifyCodeTextField.text = @"";
                [_loginView resetVerifyCodeLabelStatus];
                
                [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else if (statusCode.integerValue == 10000012){//手机号绑定失败，已达安全手机绑定上限
                [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            else {
                if ([statusMsg isEqualToString:@"登录失败"]) {
                    statusMsg = @"绑定失败";
                }
                [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            return;
        }
        
       
        NSString *requestStatus = [NSString stringWithFormat:@"%@", [requestDict objectForKey:@"status"]];
        NSString *requestMsg = [requestDict objectForKey:@"msg"];
        if (![requestStatus isEqualToString:@"0"] && requestMsg.length > 0) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:requestMsg toUrl:nil mode:SNCenterToastModeWarning];
            [self burySuccess:@"-1" loginType:@"mobile" errType:@"0"];
            isloadingLogin = NO;
            return;
        }
        //登录成功 wangshun
        //MobileNum login success
        if ([_loginView.requestType isEqualToString:kRequestTypeLogin]) {
            [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.loginChanged" withObject:nil];
            [SNInterceptConfigManager refreshConfig];
            
            //如果是手机号登录或者绑定拦截，进行以下处理；登录后再绑定，不做以下处理
            if ([_buttonTitle isEqualToString:kImmediatelyLogin] || ![SNUserinfoEx isLogin]) {
                
                NSString *userID = [requestDict objectForKey:@"userId"];
                NSString *token = [requestDict objectForKey:@"token"];
                NSString *pid = [requestDict objectForKey:@"pid"];
                NSString *nick = [requestDict objectForKey:@"nick"];
                
                SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
                userInfoEx.userName = userID;
                userInfoEx.pid = [NSString stringWithFormat:@"%@", pid];
                userInfoEx.token = token;
                userInfoEx.nickName = nick;
                userInfoEx.passport = userID;
    
                [userInfoEx parseUserinfoFromDictionary:requestDict];
                [userInfoEx saveUserinfoToUserDefault];
                
                if (![_buttonTitle isEqualToString:kImmediatelyLogin]) {
                    [SNNotificationCenter showLoading:@"正在绑定..."];
                    //CC统计
                    SNUserTrack *userTrack = [SNUserTrack trackWithPage:[_staticFromPage intValue] link2:nil];
                    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_moblie_binded_success];
                    [SNNewsReport reportADotGifWithTrack:paramString];
                } else {
                    [SNNotificationCenter showLoading:@"正在登录..."];
                }
            } else {
                [SNNotificationCenter showLoading:@"正在绑定..."];
                //CC统计
                
                SNUserTrack *userTrack = [SNUserTrack trackWithPage:profile_user_edit link2:nil];
                NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_moblie_binded_success];
                [SNNewsReport reportADotGifWithTrack:paramString];
                
                NSNumber* statusCode = [requestDict objectForKey:@"statusCode"];
                NSString* statusMsg  = [requestDict objectForKey:@"statusMsg"];
                if (statusCode.integerValue == 10000000){//成功
                    
                    if ([statusMsg isEqualToString:@"登录成功，该手机号也绑定了其他登录方式哦！"]) {
                        statusMsg = @"绑定成功，该手机号也绑定了其他登录方式哦！";
                    }
                    
                    if ([statusMsg isEqualToString:@"登录成功"]) {
                        statusMsg = @"绑定成功";
                    }
                    
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
                    
                    SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
                    userInfo.isRealName = YES;
                    [userInfo saveUserinfoToUserDefault];
                }
                else{
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
            
//            [_userinfoService circle_userinfoRequest:nil loginFrom:nil];
            _userinfoService.userinfoDelegate = self;

            [_userinfoService.userinfoDelegate notifyGetUserinfoSuccess:nil];
            [self burySuccess:@"1" loginType:@"mobile" errType:@"0"];

            //Send verifyCode success
        } else if ([_loginView.requestType isEqualToString:kRequestTypeVerifyCode]) {
            SNDebugLog(@"send verifyCode success");
            [_loginView countDownTime];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        [self burySuccess:@"-1" loginType:@"mobile" errType:@"0"];
        isloadingLogin = NO;
    }];
}

- (void)burySuccess:(NSString*)str loginType:(NSString*)loginType errType:(NSString*)errType{
//    NSDictionary* dic = @{@"loginSuccess":str,@"loginType":loginType,@"cid":[SNUserManager getP1],@"errType":errType?:@""};
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dic setObject:str?:@"" forKey:@"loginSuccess"];
    [dic setObject:loginType?:@"" forKey:@"loginType"];
    [dic setObject:[SNUserManager getP1] forKey:@"cid"];
   
    if (errType) {
       [dic setObject:errType?:@"" forKey:@"errType"];
    }
    
    NSString* sourceID = self.sourceChannelID;
    SNDebugLog(@"手机号 sourceChannelID:%@ dic:%@",sourceID,dic);
    if (!self.sourceChannelID) {
        sourceID = [SNShareManager defaultManager].loginFrom?:@"";
    }
    if (sourceID && ![sourceID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceID bodyDic:dic];
    }
}


#pragma mark UserInfoService delegate
- (void)notifyGetUserinfoSuccess:(NSArray*)mediaArray {//wangshun login
    NSLog(@"wangshun notifyGetUserinfoSuccess ");
    [SNNotificationCenter hideLoading];
    //wangshun lastlogin
    
    NSString* phoneNumber = [_loginView.mobileNumTextField.text trim]?:@"";
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"mobile",@"value":phoneNumber}];
    
    if (_guideRegisterType == SNGuideRegisterTypeContentComment ||
        _guideRegisterType == SNGuideRegisterTypeFavNews) {
        _isCommentRegisterType = YES;
    }

    if ([_buttonTitle isEqualToString:kImmediatelyLogin]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_login_success",@"") toUrl:nil mode:SNCenterToastModeSuccess];
        [SNNotificationManager postNotificationName:kMobileNumLoginSucceedNotification object:nil];
        
        __weak SNBindMobileNumViewController* weakSelf = self;
        
        [[SNActionSheetLoginManager sharedInstance] mobileLoginSuccess:nil SuccessBlock:^(NSDictionary *info) {
            
            [SNUtility getSyncStatusGo];
            
            if (weakSelf.mobileLoginLoginSuccessBlock) {
               weakSelf.mobileLoginLoginSuccessBlock(nil);
            }
        }];
        
    }
    else {
        
        //[[SNCenterToast shareInstance] showCenterToastWithTitle:@"绑定成功"  toUrl:nil mode:SNCenterToastModeSuccess];
        [[SNMySDK sharedInstance] bindPhone:_loginView.mobileNumTextField.text];
        NSDictionary *dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:_loginView.mobileNumTextField.text, @"phone", nil];
        [SNSLib bindPhoneWith:dictInfo];
        
        [SNNotificationManager postNotificationName:kBackFromBindViewControllerNotification object:nil];
        [SNUtility setUserDefaultSourceType:nil keyString:kLoginSourceTag];
    }
    
    if (self.delegate!=nil && self.method!=nil && [self.method isKindOfClass:[NSValue class]] && [self.delegate respondsToSelector:[self.method pointerValue]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:[self.method pointerValue] withObject:nil];
#pragma clang diagnostic pop
    }
    
    [SNUserUtility handleUserLogin];
}

- (void)notifyGetUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg {
    [SNNotificationCenter hideLoading];
    if (aMsg.length > 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
    }
}

- (void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    [SNNotificationCenter hideLoading];
}

- (void)viewTaped {
    [self resetToolBarOrigin];
    [_loginView setResignFirstResponder];
    [SNNotificationManager postNotificationName:kViewTapedNotification object:nil];
}

- (void)addSwipeGesture {
    UISwipeGestureRecognizer *recognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture)];
    [recognizerUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:recognizerUp];
    
    UISwipeGestureRecognizer *recognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture)];
    [recognizerDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizerDown];
}

- (void)handleSwipeGesture {
    [self resetToolBarOrigin];
    [_loginView setResignFirstResponder];
    [SNNotificationManager postNotificationName:kViewTapedNotification object:nil];
}

- (void)updateTheme {
    UILabel *label = (UILabel *)[_loginView viewWithTag:kStaticLabelTag];
    label.textColor = SNUICOLOR(kThemeText3Color);
}


//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

- (void)setStaticString {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:11];
    label.text = staticString;
    if (_staticTitle) {
        label.text = _staticTitle;
    }
    label.tag = kStaticLabelTag;
    label.textColor = SNUICOLOR(kThemeText3Color);
    [label sizeToFit];
    label.top = 192;
    label.left = (kAppScreenWidth - label.width) / 2.0;
    [_loginView addSubview:label];
}

- (void)showPhoneVerify{
    UIView* v = [_loginView viewWithTag:kStaticLabelTag];
    [UIView animateWithDuration:0.25 animations:^{
        v.top = 213;
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    CGFloat pointY = kAppScreenHeight - bg.size.height - keyboardSize.height + 5;
    self.toolbarView.origin = CGPointMake(self.toolbarView.frame.origin.x, pointY);
}

- (void)keyboardWillHidden:(NSNotification *)notification{
    
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    CGFloat pointY = kAppScreenHeight - bg.size.height + 5;
    self.toolbarView.origin = CGPointMake(self.toolbarView.frame.origin.x, pointY);
}
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

@end
