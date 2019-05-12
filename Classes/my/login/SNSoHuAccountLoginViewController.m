//
//  SNSoHuAccountLoginViewController.m
//  sohunews
//
//  Created by yangln on 14-10-3.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSoHuAccountLoginViewController.h"
#import "SNSoHuAccountLoginRegisterViewController.h"
#import "SNUserManager.h"
#import "SNUserUtility.h"
#import "SNCustomTextField.h"
#import "SNAdvertiseManager.h"
#import "SNInterceptConfigManager.h"
#import "SNSohuLoginRequest.h"
#import "SNLoginLaterBingPhone.h"//这个地方先这么引用
#import "SNEncryptManager.h"
#import "SNUserManager.h"
#import "SNSLib.h"
#import "SNNewsRecordLastLogin.h"


@interface SNSoHuAccountLoginViewController ()

@property (nonatomic,strong) NSDictionary* bindpreData;//绑定前数据
@property (nonatomic,assign) BOOL isloading;

- (void)customerBg;
- (void)viewTaped:(id)sender;
- (void)resetBgByTag:(NSInteger)aTag;
- (void)selectItembyTag:(NSInteger)aTag;

- (void)createScrollView;
- (void)createLoginPart;
- (void)createButtonPart;

@end

@implementation SNSoHuAccountLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self customerBg];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadView {
    [super loadView];
    
//    @autoreleasepool {
//        [self createScrollView];
//        [self createLoginPart];
//        [self createButtonPart];
//        [self addSwipeGesture];
//    }
}

-(void)viewTaped:(id)sender
{
    UITapGestureRecognizer* tapGesture = (UITapGestureRecognizer*)sender;
    [self selectItembyTag: tapGesture.view.tag];
    [_accountLoginRegisterViewController setToolBarOrigin];
}

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    [self selectItembyTag:textField.tag];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if(textField.tag==101)
        [(UITextField*)[self.view viewWithTag:102] becomeFirstResponder];
    else
        [self submitLogin:nil];
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]
        && [touch.view isKindOfClass:[UIButton class]])
        return NO;
    
    return YES;
}

//----------------------------------------------------------------------------------------------
//------------------------------------------- 网络回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)submitLogin:(id)sender
{
    [_accountLoginRegisterViewController setToolBarOrigin];
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    [userNameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    NSString* errorTip = nil;
    
    if(errorTip==nil)
    {
        _accountLoginRegisterViewController.accountService.loginDelegate = self;
        
//搜狐登录
        NSString* account   = [userNameTextField.text trim];
        NSString* password  = [passwordTextField.text trim];
        NSString* logintype = SNLogin_ThirdLogin_LoginType_Sohu;
        NSString* loginFrom = @"0";//登录
        
        if([userNameTextField.text trim]==nil || [passwordTextField.text trim]==nil){
            return;
        }
        
        NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:account forKey:@"account"];
        [params setObject:[password md5Hash] forKey:@"password"];
        [params setObject:logintype forKey:@"loginType"];
        [params setObject:loginFrom forKey:@"loginFrom"];
                
        if (self.isloading == YES) {
            return;
        }
        
        self.isloading = YES;
        
        [[[SNSohuLoginRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
            SNDebugLog(@"resp:%@",responseObject);
            
            NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
            
            [self analyseStatusCode:statusCode response:responseObject];
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            SNDebugLog(@"error:%@",error);
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            self.isloading = NO;
        }];
    }
    else
    {
        if (userNameTextField.isFirstResponder || passwordTextField.isFirstResponder) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:errorTip toUrl:nil mode:SNCenterToastModeWarning];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:errorTip toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
}

- (void)analyseStatusCode:(NSNumber*)statusCode response:(NSDictionary*)respDic{
    
    if (statusCode.integerValue == 10000000) {//成功
        
        NSNumber* bindMobileStatus = [respDic objectForKey:@"bindMobileStatus"];
        NSDictionary* userInfo = [respDic objectForKey:@"userInfo"];
        if (userInfo && bindMobileStatus == nil) {
            bindMobileStatus = [userInfo objectForKey:@"bindMobileStatus"];
        }

        if (bindMobileStatus.integerValue == 0) {//未绑定
            
            NSMutableDictionary* param = [NSMutableDictionary dictionary];
            [param setObject:@"bind" forKey:@"type"];
            
            NSString* passport = [userInfo objectForKey:@"passport"];
            if (passport) {
                [param setObject:passport?:@"" forKey:@"passport"];
            }   
            
            [param setObject:passport?:@"1" forKey:@"issohulogin"];
            
            [self openBindViewController:param];//去绑定
            
            self.bindpreData = respDic;
            
        }
        else{
            [self loginSuccessed:respDic];//登录成功
        }
        return;
    }
    else if (statusCode.integerValue == 10000020){//账户不存在
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"账户不存在" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else if (statusCode.integerValue == 10000021){//登录密码错误
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录密码错误" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else if (statusCode.integerValue == 10000022){//登录密码未设置
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录密码未设置" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else if (statusCode.integerValue == 10000004){//登录失败
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"登录失败" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    self.isloading = NO;//成功不允许再次点击登录 举报页弹好几个...
    [self burySuccess:@"-1"];
}



-(void)submitKickBack:(id)sender
{
    [_accountLoginRegisterViewController.flipboardNavigationController popViewControllerAnimated:YES];
}

//-(void)notifyGetUserinfoSuccess:(NSArray*)mediaArray
//{
//    [SNNotificationCenter hideLoading];
//    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_login_success",@"") toUrl:nil mode:SNCenterToastModeSuccess];
//    [SNUserUtility handleUserLogin];
//    //如果预定了需要触发的操作，那么就不进个人中心了
//    if(_accountLoginRegisterViewController!=nil)
//    {
//        BOOL needpop = _accountLoginRegisterViewController.needPop;
//        id delegate = _accountLoginRegisterViewController.delegate;
//        id method = _accountLoginRegisterViewController.method;
//        id object = _accountLoginRegisterViewController.object;
//        
//        if (method) {
//            if([method isKindOfClass:[NSValue class]]){
//                NSValue* mV = (NSValue*)method;
//                SEL m = [mV pointerValue];
//                SNDebugLog(@"wangshun m:::%@",NSStringFromSelector(m));
//            }
//        }
//        
//        //        if(delegate && method && [method isKindOfClass:[NSValue class]] &&[delegate respondsToSelector:[method pointerValue]])
//        //            [delegate performSelector:[method pointerValue] withObject:object afterDelay:0.1f];
//        
//        
//        //        if (needpop)
//        //            [_accountLoginRegisterViewController.flipboardNavigationController popViewControllerAnimated:YES];
//    }
//}


//搜狐账号登陆成功
-(void)notifyLoginSuccess
{//合并两个方法
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_login_success",@"") toUrl:nil mode:SNCenterToastModeSuccess];
    [SNUserUtility handleUserLogin];
    
    [SNNotificationManager postNotificationName:kNotifyGetUserinfoSuccess object:nil];
    [SNNotificationManager postNotificationName:kRollingChannelReloadNotification object:nil];
    
    [SNInterceptConfigManager refreshConfig];
    //只有成功获取到pid才算登陆成功
    if([[SNUserManager getPid] isEqualToString:@"-1"])
    {
        [_accountLoginRegisterViewController.userinfoService circle_userinfoRequest:nil loginFrom:self.loginFrom];
        _accountLoginRegisterViewController.userinfoService.userinfoDelegate = self;
//        [SNNotificationCenter showLoading:@"正在登录..."];
    }
    else
    {
        [[SNAdvertiseManager sharedManager] sendPassportIdForLoginSuccessed:[SNUserManager getPid]];
        
        [SNUtility getSyncStatusGo];
        
        if(_accountLoginRegisterViewController!=nil)
        {
            BOOL needpop = _accountLoginRegisterViewController.needPop;
            id delegate = _accountLoginRegisterViewController.delegate;
            id method = _accountLoginRegisterViewController.method;
            id object = _accountLoginRegisterViewController.object;
            //loginSuccess
            if(delegate && method && [method isKindOfClass:[NSValue class]] &&[delegate respondsToSelector:[method pointerValue]])//loginSuccess
                [delegate performSelector:[method pointerValue] withObject:object afterDelay:0.1f];
            if(needpop)
                [_accountLoginRegisterViewController.flipboardNavigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)openUserCenter
{
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://userCenter"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

-(void)notifyLoginFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
}

-(void)notifyLoginRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyLoginRequeestFailure");
    [SNNotificationCenter hideLoading];
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}

-(void)notifyGetUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
}

-(void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyLoginRequeestFailure");
    [SNNotificationCenter hideLoading];
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}


-(void)createScrollView
{
    CGRect screenFrame = TTApplicationFrame();
    NSInteger height = 344;
    
    self.scrollView = nil;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7)];
    _scrollView.contentSize = CGSizeMake(screenFrame.size.width, height);
    _scrollView.scrollEnabled = YES;
    [self.view addSubview:_scrollView];
}

-(void)createLoginPart
{
    UIImage* image = [UIImage imageNamed:@"userinfo_cellbg.png"];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 49, 24)];
    else
        image = [image stretchableImageWithLeftCapWidth:24.5 topCapHeight:24.5];
    
    UIImage* imagehl = [UIImage imageNamed:@"userinfo_cellbg_hl.png"];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        imagehl = [imagehl resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 49, 24)];
    else
        imagehl = [imagehl stretchableImageWithLeftCapWidth:24.5 topCapHeight:24.5];
    
    UIColor* labelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoLabelColor]];
    UIColor* fieldTextColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoTextColor]];
    
    //------------------------------------------- Line 1 -------------------------------------------
    
    CGRect baseRect = CGRectMake(12.5, 27.5, kAppScreenWidth-29, 40);
    
    UIButton* cellbgImageView = [[UIButton alloc] initWithFrame:baseRect];
    cellbgImageView.tag = 201;
    [cellbgImageView setBackgroundImage:image forState:UIControlStateNormal];
    [cellbgImageView setBackgroundImage:imagehl forState:UIControlStateSelected];
    [self.scrollView addSubview:cellbgImageView];
    
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
//    [cellbgImageView addGestureRecognizer:tap];
//    [tap release];
    
    //用户名
    CGRect subRect = CGRectMake(baseRect.origin.x+10, baseRect.origin.y+12, 12.5, 12.5);
    UIImage* itemImage = [UIImage imageNamed:@"userinfo_head.png"];
    UIImageView* itemImageView = [[UIImageView alloc] initWithFrame:subRect];
    itemImageView.image = itemImage;
    [self.scrollView addSubview:itemImageView];
    
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
    [self.scrollView addSubview:username];
    
    //用户名编辑框
    subRect.origin.x += subRect.size.width + 6;
    subRect.origin.y -= 2;
    subRect.size = CGSizeMake(kAppScreenWidth-126,20);
    SNCustomTextField* userNameTextField = [[SNCustomTextField alloc] initWithFrame:subRect];
    userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userNameTextField.returnKeyType = UIReturnKeyNext;
    userNameTextField.textColor = fieldTextColor;
    userNameTextField.tag = 101;
    userNameTextField.placeholder = NSLocalizedString(@"user_info_textfield_login_username", nil);
    userNameTextField.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:15.0];
    userNameTextField.delegate = self;
    userNameTextField.backgroundColor = [UIColor clearColor];
    userNameTextField.exclusiveTouch = YES;
    [self.scrollView addSubview:userNameTextField];
    
    
    //------------------------------------------- Line 2 -------------------------------------------
    
    baseRect.origin.y += 52.5;
    cellbgImageView = [[UIButton alloc] initWithFrame:baseRect];
    cellbgImageView.tag = 202;
    [cellbgImageView setBackgroundImage:image forState:UIControlStateNormal];
    [cellbgImageView setBackgroundImage:imagehl forState:UIControlStateSelected];
    [self.scrollView addSubview:cellbgImageView];
    
//    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
//    [cellbgImageView addGestureRecognizer:tap];
//    [tap release];
    
    subRect = CGRectMake(baseRect.origin.x+10, baseRect.origin.y+12, 12.5, 12.5);
    itemImage = [UIImage imageNamed:@"userinfo_password.png"];
    itemImageView = [[UIImageView alloc] initWithFrame:subRect];
    itemImageView.image = itemImage;
    [self.scrollView addSubview:itemImageView];
    
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
    [self.scrollView addSubview:password];
    
    //密码编辑框
    subRect.origin.x += subRect.size.width + 6;
    subRect.origin.y -= 2;
    subRect.size = CGSizeMake(kAppScreenWidth-126,20);
    SNCustomTextField* passwordTextField = [[SNCustomTextField alloc] initWithFrame:subRect];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.textColor = fieldTextColor;
    passwordTextField.tag = 102;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.placeholder = NSLocalizedString(@"user_info_textfield_login_password", nil);
    passwordTextField.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:15.0];
    passwordTextField.delegate = self;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.backgroundColor = [UIColor clearColor];
    passwordTextField.exclusiveTouch = YES;
    [self.scrollView addSubview:passwordTextField];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    SNCustomTextField* field = [self.scrollView viewWithTag:101];
    [field resignFirstResponder];
    field = [self.scrollView viewWithTag:102];
    [field resignFirstResponder];
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
    [self.scrollView addSubview:registerButton];
}

-(void)customerBg
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

-(void)resetBgByTag:(NSInteger)aTag
{
    UIButton* bg1 = (UIButton*)[self.view viewWithTag:201];
    UIButton* bg2 = (UIButton*)[self.view viewWithTag:202];
    
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
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    
    if(aTag!=101)
        [userNameTextField resignFirstResponder];
    else
        [userNameTextField becomeFirstResponder];
    
    if(aTag!=102)
        [passwordTextField resignFirstResponder];
    else
        [passwordTextField becomeFirstResponder];
}

- (void)notifyOpenLoginUrSuccess:aUrl domain:(NSString*)aDomain {
    [SNNotificationCenter hideLoading];
}

- (void)notifyOpenLoginUrFailure:(NSInteger)aStatus msg:(NSString*)aMsg {
    [SNNotificationCenter hideLoading];
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
}

- (void)notifyOpenLoginUrDidFailLoadWithError:(NSError*)error {
    [SNNotificationCenter hideLoading];
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
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
    [_accountLoginRegisterViewController setToolBarOrigin];
    [self resignResponserByTag:-1];
    [self resetBgByTag:-1];
}

#pragma mark -

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

- (void)loginSuccessed:(NSDictionary*)responseObject{
    //搜狐登录成功
    SNDebugLog(@"%@",responseObject);
    
    if (responseObject == nil) {//只限于搜狐登录(邮箱密码)登录后需要进入绑定页面的
        responseObject = self.bindpreData;
    }
    
    NSDictionary* userInfoDic = [responseObject objectForKey:@"userInfo"];
    if (userInfoDic == nil) {
        return;
    }
    
    NSString *userID = [userInfoDic objectForKey:@"passport"];//passport 就是userID
    NSString *token  = [userInfoDic objectForKey:@"token"];
    NSString *pid    = [userInfoDic objectForKey:@"pid"];
    NSString *nick   = [userInfoDic objectForKey:@"nick"];
    
    SNUserinfoEx *userInfo = [SNUserinfoEx userinfoEx];
    userInfo.userName = userID;
    userInfo.pid = [NSString stringWithFormat:@"%@", pid];
    userInfo.token = token;
    userInfo.nickName = nick;
    
    //wangshun
    [userInfo parseUserinfoFromDictionary:userInfoDic];
    [userInfo saveUserinfoToUserDefault];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:kUserCenterLoginAppId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //    [self notifyGetUserinfoSuccess:nil];//合并方法
    [self notifyLoginSuccess];
    [self burySuccess:@"1"];
    
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    NSString* account = [userNameTextField.text trim]?:@"";
    [SNNewsRecordLastLogin saveLogin:@{@"key":@"sohu",@"value":account}];
}

- (void)burySuccess:(NSString*)type{
    //埋点 wangshun login
    NSDictionary* dic = @{@"loginSuccess":type,@"loginType":@"sohu",@"cid":[SNUserManager getP1]};
    if ([type isEqualToString:@"-1"]) {
        dic = @{@"loginSuccess":type,@"loginType":@"sohu",@"errType":@"0",@"cid":[SNUserManager getP1]};
    }
    SNDebugLog(@"狐友 sourceChannelID ::::%@ dic:%@",self.sourceChannelID,dic);
    
    if (self.sourceChannelID && ![self.sourceChannelID isEqualToString:@"-1"]) {
        [SNSLib addCountForSohuNewsLoginEventWithKey:self.sourceChannelID bodyDic:dic];
    }
}

- (void)openBindViewController:(NSDictionary*)params{
    
    UIViewController* vc = [_accountLoginRegisterViewController.queryDictionary objectForKey:@"popvc"];
    
    id commentpopvc = _accountLoginRegisterViewController.commentpopvc;
    id commentBindOpen = _accountLoginRegisterViewController.commentBindOpen;
    
    NSMutableDictionary* query = [[NSMutableDictionary alloc] initWithCapacity:0];
    [query setObject:@"绑定手机" forKey:@"headTitle"];
    [query setObject:@"立即绑定" forKey:@"buttonTitle"];
    [query setObject:params forKey:@"data"];
    [query setObject:self forKey:@"third"];
    [query setObject:vc forKey:@"popvc"];
    [query setObject:commentpopvc forKey:@"commentpopvc"];
    [query setObject:commentBindOpen forKey:@"commentBindOpen"];
    
    if (_accountLoginRegisterViewController.loginSuccessModel) {//仅sohu passpost登录 绑定回调用
        [query setObject:@"1" forKey:@"isNewsLogin"];
    }
    
    
//    NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:@"绑定手机", @"headTitle", @"立即绑定", @"buttonTitle", params,@"data",self,@"third",vc,@"popvc",commentpopvc,@"commentpopvc",commentBindOpen,@"commentBindOpen",nil]; //( self,@"third" ) 这个参数用来回调成功
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:query];
    
    [[TTNavigator navigator] openURLAction:_urlAction];
}

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

@end
