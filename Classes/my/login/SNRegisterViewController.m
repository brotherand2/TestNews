//
//  SNRegisterViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNRegisterViewController.h"
#import "SNUserinfo.h"
#import "SNSoHuAccountLoginViewController.h"
#import "SNUserManager.h"
#import "SNUserUtility.h"
#import "SNSoHuAccountLoginRegisterViewController.h"


@interface SNRegisterViewController ()
-(void)customerBg;
-(void)viewTaped:(id)sender;
-(void)resetBgByTag:(NSInteger)aTag;
-(void)selectItembyTag:(NSInteger)aTag;
-(NSString*)parameterVerify;

-(void)willScrollToTop;
-(void)changeToTempScrollview;
-(void)keyboardWillShow:(NSNotification*)aNotification;
@end


@implementation SNRegisterViewController
@synthesize _usernameState;
@synthesize _checkUserErrorTip;
@synthesize _tempResizeScrollView;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)dealloc
{
    [SNNotificationManager removeObserver:self];
}

-(id)init
{
    if(self=[super init])
    {
        self._usernameState = EFail;
        self._checkUserErrorTip = nil;
        self._tempResizeScrollView = NO;
        
        _keyboardExHeight = 0;
        [SNNotificationManager addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    @autoreleasepool {
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
        UIColor* buttonFontColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoButtonFontColor]];
        UIColor* protocolLabelColor = SNUICOLOR(kThemeRed1Color);
        
        //------------------------------------------- Line 1 -------------------------------------------
        
        CGRect baseRect = CGRectMake(12.5, 27, kAppScreenWidth-29, 38);
        UIButton* cellbgImageView = [[UIButton alloc] initWithFrame:baseRect];
        cellbgImageView.tag = 201;
        [cellbgImageView setBackgroundImage:image forState:UIControlStateNormal];
        [cellbgImageView setBackgroundImage:imagehl forState:UIControlStateSelected];
        [self.view addSubview:cellbgImageView];
        
        //用户名
        CGRect subRect = CGRectMake(baseRect.origin.x+10, baseRect.origin.y+12, 12.5, 12.5);
        UIImage* itemImage = [UIImage imageNamed:@"userinfo_head.png"];
        UIImageView* itemImageView = [[UIImageView alloc] initWithFrame:subRect];
        itemImageView.image = itemImage;
        [self.view addSubview:itemImageView];
        
        subRect.origin.x += subRect.size.width + 6;
        subRect.size = CGSizeMake(48,16);
        UILabel* username = [[UILabel alloc] initWithFrame:subRect];
        username.font = [UIFont systemFontOfSize:15];
        username.textColor = labelColor;
        username.backgroundColor = [UIColor clearColor];
        username.userInteractionEnabled = NO;
        username.text = NSLocalizedString(@"user_info_label_name", nil);
        [self.view addSubview:username];
        
        //用户名编辑框
        subRect.origin.x += subRect.size.width + 6;
        subRect.origin.y -= 2;
        subRect.size = CGSizeMake(kAppScreenWidth-210,20);
        UITextField* userNameTextField = [[UITextField alloc] initWithFrame:subRect];
        userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userNameTextField.returnKeyType = UIReturnKeyNext;
        userNameTextField.textColor = fieldTextColor;
        userNameTextField.tag = 101;
        userNameTextField.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:15.0];
        userNameTextField.delegate = self;
        userNameTextField.backgroundColor = [UIColor clearColor];
        userNameTextField.exclusiveTouch = YES;
        [self.view addSubview:userNameTextField];
        
        //用户名后缀 @sohu.com
        subRect.origin.x += subRect.size.width;
        subRect.origin.y += 2;
        subRect.size = CGSizeMake(93,16);
        UILabel* usernamesuffix = [[UILabel alloc] initWithFrame:subRect];
        usernamesuffix.font = [UIFont systemFontOfSize:15];
        usernamesuffix.textColor = labelColor;
        usernamesuffix.backgroundColor = [UIColor clearColor];
        usernamesuffix.userInteractionEnabled = NO;
        usernamesuffix.text = @"@sohu.com";
        [self.view addSubview:usernamesuffix];
        
        //用户名提示
        subRect = CGRectMake(22, 70, kAppScreenWidth-44, 24);
        UILabel* usernameTip = [[UILabel alloc] initWithFrame:subRect];
        usernameTip.font = [UIFont systemFontOfSize:12];
        usernameTip.textColor = labelColor;
        usernameTip.backgroundColor = [UIColor clearColor];
        usernameTip.userInteractionEnabled = NO;
        usernameTip.text = NSLocalizedString(@"user_info_textfield_username", nil);
        [self.view addSubview:usernameTip];
        
        //------------------------------------------- Line 2 -------------------------------------------
        
        baseRect.origin.y += 72;
        cellbgImageView = [[UIButton alloc] initWithFrame:baseRect];
        cellbgImageView.tag = 202;
        [cellbgImageView setBackgroundImage:image forState:UIControlStateNormal];
        [cellbgImageView setBackgroundImage:imagehl forState:UIControlStateSelected];
        [self.view addSubview:cellbgImageView];
        
        subRect = CGRectMake(baseRect.origin.x+10, baseRect.origin.y+12, 12.5, 12.5);
        itemImage = [UIImage imageNamed:@"userinfo_password.png"];
        itemImageView = [[UIImageView alloc] initWithFrame:subRect];
        itemImageView.image = itemImage;
        [self.view addSubview:itemImageView];
        
        //密码
        subRect.origin.x += subRect.size.width + 6;
        subRect.size = CGSizeMake(48,16);
        UILabel* password = [[UILabel alloc] initWithFrame:subRect];
        password.font = [UIFont systemFontOfSize:15];
        password.textColor = labelColor;
        password.backgroundColor = [UIColor clearColor];
        password.userInteractionEnabled = NO;
        password.text = NSLocalizedString(@"user_info_label_password", nil);
        [self.view addSubview:password];
        
        //密码编辑框
        subRect.origin.x += subRect.size.width + 6;
        subRect.origin.y -= 2;
        subRect.size = CGSizeMake(kAppScreenWidth-116,20);
        UITextField* passwordTextField = [[UITextField alloc] initWithFrame:subRect];
        passwordTextField.returnKeyType = UIReturnKeyNext;
        passwordTextField.textColor = fieldTextColor;
        passwordTextField.tag = 102;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:15.0];
        passwordTextField.delegate = self;
        passwordTextField.backgroundColor = [UIColor clearColor];
        passwordTextField.exclusiveTouch = YES;
        [self.view addSubview:passwordTextField];
        
        //密码提示
        subRect = CGRectMake(22, 142, kAppScreenWidth-44, 24);
        UILabel* passwordTip = [[UILabel alloc] initWithFrame:subRect];
        passwordTip.font = [UIFont systemFontOfSize:12];
        passwordTip.textColor = labelColor;
        passwordTip.backgroundColor = [UIColor clearColor];
        passwordTip.userInteractionEnabled = NO;
        passwordTip.text = NSLocalizedString(@"user_info_textfield_password", nil);
        [self.view addSubview:passwordTip];
        
        
        //------------------------------------------- Line 3 -------------------------------------------
        
        baseRect.origin.y += 72;
        
        //------------------------------------------- Line 4 -------------------------------------------
        //baseRect.origin.y += 49.5;
        
        subRect = CGRectMake((kAppScreenWidth-200)/2, baseRect.origin.y, 24, 24);
        itemImage = [UIImage imageNamed:@"userinfo_check.png"];
        UIImage* itemImagehl = [UIImage imageNamed:@"userinfo_check_hl.png"];
        UIButton* checkboxView = [[UIButton alloc] initWithFrame:subRect];
        checkboxView.tag = 204;
        checkboxView.selected = YES;
        [checkboxView setBackgroundImage:itemImage forState:UIControlStateNormal];
        [checkboxView setBackgroundImage:itemImagehl forState:UIControlStateSelected];
        checkboxView.alpha = themeImageAlphaValue();
        [self.view addSubview:checkboxView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
        [checkboxView addGestureRecognizer:tap];
        
        subRect.origin.x += subRect.size.width-2;
        subRect = CGRectMake(subRect.origin.x, baseRect.origin.y+6.5, 200, 13);
        UILabel* protocol = [[UILabel alloc] initWithFrame:subRect];
        protocol.tag = 205;
        protocol.font = [UIFont systemFontOfSize:12];
        protocol.textColor = protocolLabelColor;
        protocol.backgroundColor = [UIColor clearColor];
        protocol.userInteractionEnabled = YES;
        protocol.text = NSLocalizedString(@"user_info_protocol", nil);
        [self.view addSubview:protocol];
        
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
        [protocol addGestureRecognizer:tap];
        
        
        //------------------------------------------- Register button -------------------------------------------
        
        //注册按钮
        UIButton* registerButton = [[UIButton alloc] initWithFrame:CGRectMake(62.5, 201, kAppScreenWidth-125, 42)];
        [registerButton setTitleColor:buttonFontColor forState:UIControlStateNormal];
        [registerButton setTitleColor:buttonFontColor forState:UIControlStateHighlighted];
        [registerButton setTitle:NSLocalizedString(@"user_info_register", nil) forState:UIControlStateNormal];
        [registerButton setTitle:NSLocalizedString(@"user_info_register", nil) forState:UIControlStateHighlighted];
        [registerButton setBackgroundImage:[UIImage imageNamed:@"userinfo_bigbutton.png"] forState:UIControlStateNormal];
        [registerButton setBackgroundImage:[UIImage imageNamed:@"userinfo_bigbutton_hl.png"] forState:UIControlStateHighlighted];
        [registerButton addTarget:self action:@selector(submitRegister:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:registerButton];
        
        [self addSwipeGesture];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self customerBg];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self resignResponserByTag:-1];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewTaped:(id)sender
{
    UITapGestureRecognizer* tapGesture = (UITapGestureRecognizer*)sender;
    if(tapGesture.view.tag==204)
    {
        UIButton* checkBox = (UIButton*)[self.view viewWithTag:204];
        checkBox.selected = !checkBox.selected;
    }
    else if(tapGesture.view.tag==205)
    {
        [self resignResponserByTag:-1];
        
        [_accountLoginRegisterViewController pushToProtocolWap];
        [_accountLoginRegisterViewController setToolBarOrigin];
    }
    else {
        [self selectItembyTag: tapGesture.view.tag];
        [_accountLoginRegisterViewController setToolBarOrigin];
    }
}

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    [self selectItembyTag:textField.tag];
    
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willScrollToTop) object:nil];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willChangeScrollviewBack) object:nil];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeToTempScrollview) object:nil];
//    [self performSelector:@selector(changeToTempScrollview) withObject:nil afterDelay:0.1f];
}

//编辑框弹出时 临时增高高度
-(void)changeToTempScrollview
{
    self._tempResizeScrollView = YES;
    
    CGRect screenFrame = TTApplicationFrame();
    _accountLoginRegisterViewController.accountLoginViewController.view.frame = CGRectZero;
    _accountLoginRegisterViewController.registerViewContronller.view.frame =  CGRectMake(0, kHeaderHeightWithoutBottom,screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7+88+_keyboardExHeight);
    _accountLoginRegisterViewController.scrollView.contentSize = CGSizeMake(320,418+88+_keyboardExHeight-49.5);
    _accountLoginRegisterViewController.scrollView.pagingEnabled = NO;
    _accountLoginRegisterViewController.scrollView.delegate = nil; //临时关闭
}

//滚回头部 并异步触发把scrollview高度设置回原
-(void)willScrollToTop
{
    [_accountLoginRegisterViewController.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [self performSelector:@selector(willChangeScrollviewBack) withObject:nil afterDelay:0.5f];
}

//scrollview恢复原来的高度
-(void)willChangeScrollviewBack
{
    if(self._tempResizeScrollView)
    {
        self._tempResizeScrollView = NO;
        
        CGRect screenFrame = TTApplicationFrame();
        CGSize size = _accountLoginRegisterViewController.scrollView.contentSize;
        _accountLoginRegisterViewController.scrollView.contentSize = CGSizeMake(size.width*2,size.height-88-_keyboardExHeight);
        
        _accountLoginRegisterViewController.accountLoginViewController.view.frame = CGRectMake(0, kHeaderHeightWithoutBottom,screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7);
        _accountLoginRegisterViewController.registerViewContronller.view.frame =  CGRectMake(screenFrame.size.width, kHeaderHeightWithoutBottom,screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7);
        [_accountLoginRegisterViewController.scrollView setContentOffset:CGPointMake(screenFrame.size.width,_accountLoginRegisterViewController.scrollView.contentOffset.y) animated:NO];
        [_accountLoginRegisterViewController.headerView setCurrentIndex:1 animated:NO];
        _accountLoginRegisterViewController.scrollView.pagingEnabled = YES;
        _accountLoginRegisterViewController.scrollView.delegate = _accountLoginRegisterViewController; //还原
    }
}

-(void)showMessageNow:(NSString*)aText
{
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    UITextField* flushCodeTextField = (UITextField*)[self.view viewWithTag:103];
    if (userNameTextField.isFirstResponder || passwordTextField.isFirstResponder || flushCodeTextField.isFirstResponder) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂时没有推荐用户" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂时没有推荐用户" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    
}

-(void)textFieldDidEndEditing:(UITextField*)textField
{
    //界面别外界重置，不是用户自己触发的关闭操作，什么也不做
    if(!_tempResizeScrollView)
        return;
    
    if(textField.tag==101 && [textField.text length]>0)
    {
        if([SNUserUtility isValidateUsername:textField.text])
        {
            NSString* text = NSLocalizedString(@"user_info_name_check_fail", nil);
            [self performSelector:@selector(showMessageNow:) withObject:text afterDelay:0.1f];
        }
        else
        {
            self._usernameState = EPending;
            self._checkUserErrorTip = nil;
            //[_model checkUserRequest:textField.text];
        }
    }

    [self performSelector:@selector(willScrollToTop) withObject:nil afterDelay:0.1f];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag==101)
        [(UITextField*)[self.view viewWithTag:102] becomeFirstResponder];
    else if(textField.tag==102)
        [(UITextField*)[self.view viewWithTag:103] becomeFirstResponder];
    else
        [self submitRegister:nil];
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]
        && [touch.view isKindOfClass:[UIButton class]])
        return NO;
    
    return YES;
}

-(void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    if(kbSize.height>216)
        _keyboardExHeight = kbSize.height-216;
}

//----------------------------------------------------------------------------------------------
//------------------------------------------- 网络回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

//FlushCode
//-(void)flushCodeImageClicked:(id)sender
//{
//    [_model flushCodeRequest];
//    
//    UITextField* flushCodeTextField = (UITextField*)[self.view viewWithTag:103];
//    flushCodeTextField.text = @"";
//}

-(void)notifyFlushCodeSuccess:(NSString*)aCodeUrl
{
    [[TTURLCache sharedCache] removeURL:aCodeUrl fromDisk:YES];
    SNWebImageView* flushCodeImage = (SNWebImageView*)[self.view viewWithTag:104];
    flushCodeImage.urlPath = nil;
    [flushCodeImage loadUrlPath:aCodeUrl];
}

-(void)notifyFlushCodeFailure
{
    SNDebugLog(@"notifyFlushCodeFailure");
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", nil) toUrl:nil mode:SNCenterToastModeError];
    
    SNWebImageView* flushCodeImage = (SNWebImageView*)[self.view viewWithTag:104];
    [[TTURLCache sharedCache] removeURL:flushCodeImage.urlPath fromDisk:YES];
    flushCodeImage.urlPath = nil;
}

-(void)notifyFlushCodeRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyFlushCodeRequeestFailure");
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    
    SNWebImageView* flushCodeImage = (SNWebImageView*)[self.view viewWithTag:104];
    [[TTURLCache sharedCache] removeURL:flushCodeImage.urlPath fromDisk:YES];
    flushCodeImage.urlPath = nil;
}

//Check User name
-(void)notifyCheckUserNameSuccess
{
    self._usernameState = EOK;
}

-(void)notifyCheckUserNameFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    self._usernameState = EFail;
    self._checkUserErrorTip = aMsg;
    
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    UITextField* flushCodeTextField = (UITextField*)[self.view viewWithTag:103];
    if (userNameTextField.isFirstResponder || passwordTextField.isFirstResponder || flushCodeTextField.isFirstResponder)
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
    }
    else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
    }
}

-(void)notifyCheckUserNameRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    self._usernameState = EFail;
    SNDebugLog(@"notifyCheckUserNameRequeestFailure");
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}

//Register
-(void)submitRegister:(id)sender
{
    [_accountLoginRegisterViewController setToolBarOrigin];
    NSString* errorTip = [self parameterVerify];
    if(errorTip==nil)
    {
        UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
        UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
        //UITextField* flushCodeTextField = (UITextField*)[self.view viewWithTag:103];
        
        if([_accountLoginRegisterViewController.accountService registerHttpsRequest:userNameTextField.text password:passwordTextField.text])
        {
            _accountLoginRegisterViewController.accountService.registerDelegate = self;
            [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
            [self selectItembyTag:-1];
            //[self flushCodeImageClicked:nil];
        }
    }
    else
    {
        UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
        UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
        UITextField* flushCodeTextField = (UITextField*)[self.view viewWithTag:103];
        if (userNameTextField.isFirstResponder || passwordTextField.isFirstResponder || flushCodeTextField.isFirstResponder) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:errorTip toUrl:nil mode:SNCenterToastModeWarning];
        }
        else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:errorTip toUrl:nil mode:SNCenterToastModeWarning];
        }
        [self selectItembyTag:-1];
    }
}

-(void)notifyRegisterSuccess
{
    //注册后清空密码
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    passwordTextField.text = @"";
    [_accountLoginRegisterViewController.userinfoService circle_userinfoRequest:nil loginFrom:nil];
    _accountLoginRegisterViewController.userinfoService.userinfoDelegate = self;
}

-(void)notifyRegisterFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
    
//    if(aStatus==1)
//    {
//        UITextField* flushCodeTextField = (UITextField*)[self.view viewWithTag:103];
//        flushCodeTextField.text = @"";
//        [_model flushCodeRequest];
//    }
}

-(void)notifyRegisterRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyRegisterRequeestFailure");
    [SNNotificationCenter hideLoading];
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}

//用户中心
-(void)notifyGetUserinfoSuccess:(NSArray*)mediaArray
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_register_success",@"") toUrl:nil mode:SNCenterToastModeSuccess];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:nil toUrl:nil mode:SNCenterToastModeSuccess];
    [SNUserUtility handleUserLogin];
    if(_accountLoginRegisterViewController!=nil)
    {
        BOOL needpop = _accountLoginRegisterViewController.needPop;
        id delegate = _accountLoginRegisterViewController.delegate;
        id method = _accountLoginRegisterViewController.method;
        id object = _accountLoginRegisterViewController.object;
        
        [delegate performSelector:[method pointerValue] withObject:object afterDelay:0.5f];
        if(needpop)
            [_accountLoginRegisterViewController.flipboardNavigationController popViewControllerAnimated:YES];
    }
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

//----------------------------------------------------------------------------------------------
//------------------------------------------- 外部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)resignResponserByTag:(NSInteger)aTag
{
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    UITextField* flushCodeTextField = (UITextField*)[self.view viewWithTag:103];
    
    if(aTag!=101)
        [userNameTextField resignFirstResponder];
    else
        [userNameTextField becomeFirstResponder];
    
    if(aTag!=102)
        [passwordTextField resignFirstResponder];
    else
        [passwordTextField becomeFirstResponder];
    
    if(aTag!=103)
        [flushCodeTextField resignFirstResponder];
    else
        [flushCodeTextField becomeFirstResponder];
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 内部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)customerBg
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

-(void)resetBgByTag:(NSInteger)aTag
{
    UIButton* bg1 = (UIButton*)[self.view viewWithTag:201];
    UIButton* bg2 = (UIButton*)[self.view viewWithTag:202];
    UIButton* bg3 = (UIButton*)[self.view viewWithTag:203];
    
    if(aTag!=201)
        bg1.selected = NO;
    else
        bg1.selected = YES;
    
    if(aTag!=202)
        bg2.selected = NO;
    else
        bg2.selected = YES;
    
    if(aTag!=203)
        bg3.selected = NO;
    else
        bg3.selected = YES;
}

-(NSString*)parameterVerify
{
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    if([userNameTextField.text length]==0)
        return NSLocalizedString(@"user_info_name_fail", nil);

//    else if(_usernameState == EPending)
//        return NSLocalizedString(@"user_info_name_checking", nil);
//    else if(_usernameState == EFail && _checkUserErrorTip!=nil)
//        return _checkUserErrorTip;
//    else if(_usernameState == EFail)
//        return NSLocalizedString(@"user_info_name_check_fail", nil);
    else if(![SNUserUtility isValidateUsername:userNameTextField.text])
        return NSLocalizedString(@"user_info_name_check_fail", nil);
    
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    if(![SNUserUtility isValidatePassword:passwordTextField.text])
        return NSLocalizedString(@"user_info_password_bad", nil); 
    
//    UITextField* flushCodeTextField = (UITextField*)[self.view viewWithTag:103];
//    if([flushCodeTextField.text length]==0)
//        return NSLocalizedString(@"user_info_flushcode_empty", nil);
    
    UIButton* checkbox = (UIButton*)[self.view viewWithTag:204];
    if(!checkbox.selected)
        return NSLocalizedString(@"user_info_checkbox_uncheck", nil);
    
    //Ok let's go!
    return nil;
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
    else if(aTag==103 || aTag==203)
    {
        [self resignResponserByTag:103];
        [self resetBgByTag:203];
    }
    else
    {
        [self resignResponserByTag:-1];
        [self resetBgByTag:-1];
    }
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

@end
