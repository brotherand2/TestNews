//
//  SNNewsLoginHalfViewController.m
//  sohunews
//
//  Created by wang shun on 2017/10/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginHalfViewController.h"
#import "SNNewsLoginKeyBoard.h"
#import "SNHalfPhoneView.h"
#import "SNNewsHalfThirdLoginView.h"
#import "SNNewsLoginPhoneVoiceVerifyBtn.h"

#import "SNPhoneLoginViewModel.h"
#import "SNThirdLoginViewModel.h"
#import "SNSendVcodeViewModel.h"
#import "SNNewsLoginSuccess.h"

#import "SNUserManager.h"
#import "SNSLib.h"
#import "SNNewsPPLoginEnvironment.h"
#import "SNNewsPPLogin.h"

#import "SNNewAlertView.h"

#define HalfLoginViewHeight 434/2.0

@interface SNNewsLoginHalfViewController ()<SNHalfPhoneViewDelegate,SNNewsHalfThirdLoginViewDelegate,SNNewsLoginPhoneVoiceVerifyBtnDelegate,SNNewsLoginKeyBoardDelegate,SNNewAlertViewDelegate>
{
    BOOL isThirdloading;
    NSString* tmp_pVcode;
}
@property (nonatomic,strong) UIView* maskBackgroundView;
@property (nonatomic,strong) UIView* bgView;
@property (nonatomic,strong) SNNewsLoginKeyBoard* keyboard;//键盘事件

@property (nonatomic,strong) SNHalfPhoneView* phoneView;//手机号验证码
@property (nonatomic,strong) SNNewsHalfThirdLoginView* thirdLoginView;//第三方
@property (nonatomic,strong) SNNewsLoginPhoneVoiceVerifyBtn* phoneVerifyBtn;

@property (nonatomic,strong) SNSendVcodeViewModel*  sendVcodeViewModel;//发送验证码流程
@property (nonatomic,strong) SNPhoneLoginViewModel* phoneLoginViewModel;//手机号登录流程
@property (nonatomic,strong) SNThirdLoginViewModel* thirdLoginViewModel;//第三方登录流程

@property (nonatomic,strong) SNNewsLoginSuccess*    loginSuccessModel;//登录成功逻辑

@property (nonatomic,strong) NSString* halfScreenTitle;
@property (nonatomic,strong) NSString* pprefer;

@end

@implementation SNNewsLoginHalfViewController

-(id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
    if (self = [super initWithNavigatorURL:URL query:query]) {
        if (query) {
            if([query objectForKey:@"loginSuccess"]){
                id sender = [query objectForKey:@"loginSuccess"];
                if ([sender isKindOfClass:[SNNewsLoginSuccess class]]) {
                    self.loginSuccessModel = [query objectForKey:@"loginSuccess"];
                }
            }
            
            if ([query objectForKey:@"halfScreenTitle"]) {
                id sender = [query objectForKey:@"halfScreenTitle"];
                if (sender && [sender isKindOfClass:[NSString class]]) {
                    self.halfScreenTitle = (NSString*)sender;
                }
            }
            
            if ([query objectForKey:@"pprefer"]) {
                NSString* p = [query objectForKey:@"pprefer"];
                if (p && [p isKindOfClass:[NSString class]]) {
                    self.pprefer = p;
                }
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self createClearView];
    
    [self createHalfLoginView];
    
    [self createPhoneView];
    [self createPhoneVoiceVerifyBtn];
    
    [self createThirdLoginView];
    
    [self createkeyboardNotification];
    
    [self performSelector:@selector(showHalfLoginView) withObject:nil afterDelay:0.25];
    
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
        NSDictionary* dic = @{@"loginSuccess":@"0",@"cid":[SNUserManager getP1],@"screen":@"1"};
        SNDebugLog(@"sourceID:%@,dic:%@",sourceChannelID,dic);
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
    
    NSString* agif = [NSString stringWithFormat:@"_act=pv&page=50&entrance=%@",self.loginSuccessModel.entrance?:@""];
    [SNNewsReport reportADotGif:agif];
    SNDebugLog(@"login agif::::%@",agif);
}

#pragma mark - 立即登录

- (void)loginClick:(id)sender{
    //[self.phoneView closeKeyBoard];//不收起键盘
    [self createPhoneLoginModel];
    
    self.phoneLoginViewModel.sourceChannelID = self.loginSuccessModel.sourceChannelID;
    self.phoneLoginViewModel.entrance = self.loginSuccessModel.entrance;
    
    if (self.thirdLoginViewModel && self.thirdLoginViewModel.isOpeningThrid == YES) {
        return;
    }
    
    NSDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    __weak SNNewsLoginHalfViewController* weakSelf = self;
    [self.phoneLoginViewModel loginWithPhoneAndVcode:phoneDic Successed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {//成功
                [weakSelf.loginSuccessModel halfLoginSucessed:resultDic WithAnimation:self];
            }
            else{
                [weakSelf clearVcode];
                [weakSelf.phoneView becomeFirstPasswordKeyBoard];
            }
        }
    }];
}

- (void)clearVcode{//清除验证码
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.phoneView clearVerifyCode];
    });
}

#pragma mark - 发送验证码

- (void)sendVerifyCodeClick:(NSDictionary*)params{//发送验证码
    //[self.phoneView closeKeyBoard];// 半屏 暂时不收起键盘
    [self createVcodeModel];
    
    if (self.thirdLoginViewModel && self.thirdLoginViewModel.isOpeningThrid == YES) {
        return;
    }
    
    NSMutableDictionary* phoneDic = [self.phoneView getPhoneAndVcode];
    [phoneDic setObject:@"signin" forKey:@"type"];
    
    //加入语音验证码 2017.7月份需求 wangshun
    NSString* sendMethod = [params objectForKey:@"sendMethod"];
    if (sendMethod) {
        [phoneDic setObject:sendMethod?:@"" forKey:@"sendMethod"];
    }
    
    if (tmp_pVcode && [tmp_pVcode isKindOfClass:[NSString class]] && tmp_pVcode.length>0) {
        [phoneDic setObject:tmp_pVcode forKey:@"pvcode"];
        tmp_pVcode = nil;
    }
    
    __weak SNNewsLoginHalfViewController* weakSelf = self;
    [self.sendVcodeViewModel sendVcode:phoneDic Completion:^(NSDictionary *resultDic) {
        NSString* success = [resultDic objectForKey:@"success"];
        if ([success isEqualToString:@"1"]) {
            if (sendMethod && [sendMethod isEqualToString:@"1"]) {//已发送后弹窗
                [weakSelf sendVoiceCodeSuccess:resultDic];//
            }
            else{
                [weakSelf.phoneView countDownTime];
                if (![sendMethod isEqualToString:@"1"]) {//非语音验证码 wangshun
                    [weakSelf.phoneView becomeFirstPasswordKeyBoard];
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
    }];
}


- (void)arrive10second{
    if (self.thirdLoginView.hidden == NO) {//如果回到第三方登录 不再显示语音验证
        return;
    }
    [self showPhoneVoiceBtn];
}

-(void)sendVoiceCodeRequest{
    [self sendVerifyCodeClick:@{@"sendMethod":@"1"}];
}

- (void)sendVoiceCodeSuccess:(NSDictionary*)resultDic{
    [self.phoneVerifyBtn sendVoiceCodeSuccess:resultDic];
}

- (void)showPhoneVoiceBtn{
    self.phoneVerifyBtn.hidden = NO;
}

//带图形验证码 发送短信验证码
- (void)verifyPhotoCodeAndSendVcode:(NSString *)text{
    tmp_pVcode = text;
    [self sendVerifyCodeClick:nil];
}

#pragma mark - 第三方登录

- (void)thirdLoginWithThirdName:(NSString *)name{
    [self.phoneView closeKeyBoard];
    [self createThirdLoginModel];
    
    if (self.thirdLoginViewModel && self.thirdLoginViewModel.isOpeningThrid == YES) {
        return;
    }
    
    NSDictionary* params = @{@"loginSuccess":self.loginSuccessModel,@"loginFrom":self.loginSuccessModel.sourceChannelID?:@"",@"entrance":self.loginSuccessModel.entrance,@"screen":@"1"};
    
    NSMutableDictionary* mDic = [NSMutableDictionary dictionaryWithDictionary:params];
    if (self.pprefer) {
        [mDic setObject:self.pprefer?:@"" forKey:@"pprefer"];
    }
    
    __weak SNNewsLoginHalfViewController* weakSelf = self;
    [self.thirdLoginViewModel thirdLoginWithName:name WithParams:mDic Success:^(NSDictionary *resultDic) {
        NSString* success = [resultDic objectForKey:@"success"];
        if ([success isEqualToString:@"1"]) {
            [weakSelf.loginSuccessModel halfLoginSucessed:nil WithAnimation:weakSelf];//因320 回不来了 sohu登录
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


#pragma mark -

- (void)createPhoneView{//手机号 验证码
    self.phoneView = [[SNHalfPhoneView alloc] initWithFrame:CGRectMake(0, 59, self.view.bounds.size.width, 110)];
    self.phoneView.delegate = self;
    [self.bgView addSubview:_phoneView];
    [self.phoneView hiddenPassword:YES];
}

//是否显示验证码输入框
- (void)showHalfThirdView:(BOOL)show{
    if (show) {
        [self.phoneView hiddenPassword:NO];
        self.thirdLoginView.hidden = YES;
        self.phoneVerifyBtn.hidden = YES;
    }
    else{
        [self.phoneView hiddenPassword:YES];
        self.thirdLoginView.hidden = NO;
        self.phoneVerifyBtn.hidden = YES;
    }
}

- (void)createPhoneVoiceVerifyBtn{
    CGFloat y = CGRectGetMaxY(self.phoneView.frame)+ (self.bgView.bounds.size.height-CGRectGetMaxY(self.phoneView.frame)-15)/2.0;
    self.phoneVerifyBtn = [[SNNewsLoginPhoneVoiceVerifyBtn alloc] initWithFrame:CGRectMake(20, y, self.view.frame.size.width-40, 15)];
    self.phoneVerifyBtn.delegate = self;
    self.phoneVerifyBtn.hidden = YES;
    [self.bgView addSubview:self.phoneVerifyBtn];
}

- (void)createThirdLoginView{//第三方登录
    //(self.bounds.size.height-13)/2.0
    CGFloat temp_y = (110-13)/2.0+CGRectGetMinY(self.phoneView.frame)+27;
    
    self.thirdLoginView = [[SNNewsHalfThirdLoginView alloc] initWithFrame:CGRectMake(0, temp_y, self.view.bounds.size.width, 62)];
    self.thirdLoginView.delegate = self;
    [self.bgView addSubview:_thirdLoginView];
}

- (void)createHalfLoginView{
    
    CGFloat iphonex = [[SNDevice sharedInstance] isPhoneX]?24:0;
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight, kAppScreenWidth, HalfLoginViewHeight+iphonex)];
    _bgView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [self.view addSubview:_bgView];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _bgView.bounds.size.width, 45)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    if (self.halfScreenTitle && self.halfScreenTitle.length>0) {
        [label setText:self.halfScreenTitle];
    }
    else{
        [label setText:@"一键登录，留下你的态度"];
    }
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = SNUICOLOR(kThemeText3Color);
    [_bgView addSubview:label];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(_bgView.bounds.size.width-40-10, 0, 40, 40)];
    btn.backgroundColor = [UIColor clearColor];
    
    [btn setImage:[UIImage themeImageNamed:@"icoland_halfscreen_close_v5.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage themeImageNamed:@"icoland_halfscreen_closepress_v5.png"] forState:UIControlStateHighlighted];
    
    btn.imageEdgeInsets =  UIEdgeInsetsMake(12, 10, 7, 10);
    
    [_bgView addSubview:btn];
    
    [btn addTarget:self action:@selector(outsideTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createClearView{
    _maskBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    _maskBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [self.view addSubview:_maskBackgroundView];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outsideTap:)];
//    [_maskBackgroundView addGestureRecognizer:tapGesture];
}

- (void)outsideTap:(UITapGestureRecognizer *)recognizer
{
    if (isThirdloading == YES) {//如果第三方正在登录不能关闭
        return;
    }
    [self.phoneView closeKeyBoard];
    [self.loginSuccessModel halfLoginCancel:nil WithAnimation:self];

    //埋点
    NSDictionary* dic = @{@"loginSuccess":@"2",@"cid":[SNUserManager getP1],@"errType":@"0",@"screen":@"0"};
    NSString* sourceChannelID = self.loginSuccessModel.sourceChannelID;
    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
    }
}

- (void)showHalfLoginView{
    [UIView animateWithDuration:0.25 animations:^{
        _maskBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        _bgView.frame = CGRectMake(0, kAppScreenHeight-(self.bgView.bounds.size.height), kAppScreenWidth, self.bgView.bounds.size.height);
    }];
}

- (void)closeHalfView:(void (^)(NSDictionary *))method{
    [UIView animateWithDuration:0.25 animations:^{
        _maskBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _bgView.frame = CGRectMake(0, kAppScreenHeight, self.bgView.bounds.size.width, self.bgView.bounds.size.height);
    } completion:^(BOOL finished) {
        if (method) {
            method(nil);
        }
    }];
}

#pragma mark - createModel

- (void)createPhoneLoginModel{
    if (self.phoneLoginViewModel == nil) {
        self.phoneLoginViewModel = [[SNPhoneLoginViewModel alloc] init];
        self.phoneLoginViewModel.screen = @"1";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark - 键盘

#pragma mark - createkeyboardNotification

- (void)createkeyboardNotification{
    if (!self.keyboard) {
        self.keyboard = [[SNNewsLoginKeyBoard alloc] initWithHalfLoginView:self.bgView];
        self.keyboard.delegate = self;
    }
    [self.keyboard createkeyboardNotification];
}

#pragma mark - removeKeyBoardNotification

- (void)removeKeyBoardNotification{
    [self.keyboard removeKeyBoardNotification];
}

- (void)keyBoardHeight:(CGSize)size{
    //NSLog(@"%@",NSStringFromCGSize(size));
    
    if (size.height>0) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.bgView setFrame:CGRectMake(0, self.view.bounds.size.height-size.height-self.bgView.bounds.size.height, self.bgView.size.width, self.bgView.size.height)];
        }];
    }
    else{
        [UIView animateWithDuration:0.25 animations:^{
            _bgView.frame = CGRectMake(0, kAppScreenHeight-(self.bgView.bounds.size.height), self.bgView.bounds.size.width, self.bgView.bounds.size.height);
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self createkeyboardNotification];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeKeyBoardNotification];
    [self.phoneView closeKeyBoard];//收起键盘
}

////////////////////////////////////////////////////////////////////////////////

-(BOOL)panGestureEnable{
    return NO;
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
