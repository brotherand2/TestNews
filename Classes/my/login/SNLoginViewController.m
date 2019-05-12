//
//  SNLoginViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-16.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLoginViewController.h"
#import "SNLoginRegisterViewController.h"
#import "SNUserManager.h"
#import "SNUserUtility.h"
#import "SNCloudSynRequest.h"
#import "SNAdvertiseManager.h"
#import "SNSoHuAccountLoginRegisterViewController.h"
#import "SNSLib.h"

#import "SNNewsThirdLoginEnable.h"
#import "SNNewsLoginPhoneVerifyBtn.h"
#import "SNNewsRecordLastLogin.h"
#import "SNNewsLastThirdLoginIcon.h"

@interface SNLoginViewController()<SNNewsLoginPhoneVerifyBtnDataSource>
@property(nonatomic,strong)SNSoHuAccountLoginRegisterViewController *soHuAccountLoginRegisterViewController;


@property (nonatomic,strong) SNNewsLoginPhoneVerifyBtn *phoneVerifyBtn;
@property (nonatomic,strong) UIImageView *line;
@property (nonatomic,strong) UILabel* tipLbl;
@property (nonatomic,strong) UILabel* tip;

@property (nonatomic,strong) UIButton* sinaBtn;
@property (nonatomic,strong) UIButton* qqBtn;
@property (nonatomic,strong) UIButton* sohuBtn;
@property (nonatomic,strong) UIButton* weixinBtn;

@property (nonatomic,strong) SNNewsLastThirdLoginIcon* last_icon;

-(void)customerBg;
-(void)viewTaped:(id)sender;
-(void)resetBgByTag:(NSInteger)aTag;
-(void)selectItembyTag:(NSInteger)aTag;
-(NSString*)parameterVerify;

-(void)createGuideTip;
-(void)createScrollView;
-(void)createOpenLoginPart;
-(void)createOpenUrlItemArray;
@end

@implementation SNLoginViewController
@synthesize _SNLoginRegisterViewController;
@synthesize _openUrlItemArray;
@synthesize _scrollView;
@synthesize _guideLogin;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)dealloc
{
    [SNNotificationManager removeObserver:self];
     //(_queryDictionary);
}

- (id)initWithParams:(NSDictionary *)query {
    self = [super init];
    if (self) {
        _queryDictionary = query;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    @autoreleasepool {
//        [self createOpenUrlItemArray];
//        [self createScrollView];
//        //v3.4 引导登录
//        [self createGuideTip];
//        
//        //v3.3 合作方登录
//        [self createOpenLoginPart];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
//    
//    [self customerBg];
//    
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
//    tap.delegate = self;
//    [self.view addGestureRecognizer:tap];
//    
//    //SNNews_Login_ThridLogin_LoginSuccessed
//    [SNNotificationManager addObserver:self selector:@selector(thirdloginSuccessed:) name:SNNews_Login_ThridLogin_LoginSuccessed object:nil];
}

- (void)thirdloginSuccessed:(id)sender{
    [self notifyThridLogin];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self resignResponserByTag:-1];
    [super viewWillDisappear:animated];
    
    if (![SNUserinfoEx isLogin]) {//SNS需要
        [SNNotificationManager postNotificationName:kUserDidCancelLoginNotification object:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewTaped:(id)sender
{
    UITapGestureRecognizer* tapGesture = (UITapGestureRecognizer*)sender;
    [self selectItembyTag: tapGesture.view.tag];
}

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    [self selectItembyTag:textField.tag];
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


-(void)submitLogin:(id)sender
{
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    NSString* errorTip = nil;//[self parameterVerify];
    
    if(errorTip==nil)
    {
        _SNLoginRegisterViewController.accountService.loginDelegate = self;
        if([_SNLoginRegisterViewController.accountService loginHttpsRequest:[userNameTextField.text trim] password:[passwordTextField.text trim]])
        {
            [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
            [self selectItembyTag:-1];
        }
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

-(void)submitKickBack:(id)sender
{
    [_SNLoginRegisterViewController.flipboardNavigationController popViewControllerAnimated:YES];
}


- (void)notifyThridLogin{
    if(_SNLoginRegisterViewController!=nil)
    {
        BOOL needpop = _SNLoginRegisterViewController._needPop;
        id delegate = _SNLoginRegisterViewController._delegate;
        id method = _SNLoginRegisterViewController._method;
        id object = _SNLoginRegisterViewController._object;
        
        //SNLoginRegisterViewController 处理登录成功后关闭登录页等一些逻辑
        if (_SNLoginRegisterViewController && method && [method isKindOfClass:[NSValue class]] && [_SNLoginRegisterViewController respondsToSelector:[method pointerValue]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            //有隐患, 负责人注意方法调用
            [_SNLoginRegisterViewController performSelector:[method pointerValue]];
#pragma clang diagnostic pop
        }
        
//        if(_SNLoginRegisterViewController.loginSuccessModel && _SNLoginRegisterViewController.loginSuccessModel.current_topViewController){
//            
//        }
//        else{
//            //delegate 交给具体各个需要登录的页面处理登录成功的一些事情
//            if(delegate && method && [method isKindOfClass:[NSValue class]] &&[delegate respondsToSelector:[method pointerValue]]) {
//                [delegate performSelector:[method pointerValue] withObject:object afterDelay:0.1f];
//            }
//            if(needpop) {
//                [_SNLoginRegisterViewController.flipboardNavigationController popViewControllerAnimated:YES];
//                [[SNCenterToast shareInstance] hideToast];
//            }
//            
//        }
    }
    
    [[SNAdvertiseManager sharedManager] sendPassportIdForLoginSuccessed:[SNUserManager getPid]];
    [SNUtility getSyncStatusGo];
    
    [[SNCenterToast shareInstance] hideToast];
}
//新浪微博登陆成功  微信登陆成功
-(void)notifyLoginSuccess
{
    //只有成功获取到pid才算登陆成功
    if([[SNUserManager getPid] isEqualToString:@"-1"])
    {
        [_SNLoginRegisterViewController.userinfoService circle_userinfoRequest:nil loginFrom:nil];
        _SNLoginRegisterViewController.userinfoService.userinfoDelegate = self;
        [SNNotificationCenter showLoading:@"正在登录..."];
    }
    else
    {
        if(_SNLoginRegisterViewController!=nil)
        {
            BOOL needpop = _SNLoginRegisterViewController._needPop;
            id delegate = _SNLoginRegisterViewController._delegate;
            id method = _SNLoginRegisterViewController._method;
            id object = _SNLoginRegisterViewController._object;
            
            //SNLoginRegisterViewController 处理登录成功后关闭登录页等一些逻辑
            if (_SNLoginRegisterViewController && method && [method isKindOfClass:[NSValue class]] && [_SNLoginRegisterViewController respondsToSelector:[method pointerValue]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                //有隐患, 负责人注意方法调用
                [_SNLoginRegisterViewController performSelector:[method pointerValue]];
#pragma clang diagnostic pop
            }
            
            //delegate 交给具体各个需要登录的页面处理登录成功的一些事情
            if(delegate && method && [method isKindOfClass:[NSValue class]] &&[delegate respondsToSelector:[method pointerValue]]) {
                [delegate performSelector:[method pointerValue] withObject:object afterDelay:0.1f];
            }
            if(needpop) {
                [_SNLoginRegisterViewController.flipboardNavigationController popViewControllerAnimated:YES];
            }
        }
        
        [[SNAdvertiseManager sharedManager] sendPassportIdForLoginSuccessed:[SNUserManager getPid]];
        [SNUtility getSyncStatusGo];
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
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
}

-(void)notifyGetUserinfoSuccess:(NSArray*)mediaArray
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_login_success",@"") toUrl:nil mode:SNCenterToastModeSuccess];
    [SNUserUtility handleUserLogin];
    //如果预定了需要触发的操作，那么就不进个人中心了
    if(_SNLoginRegisterViewController!=nil)
    {
        BOOL needpop = _SNLoginRegisterViewController._needPop;
        id delegate = _SNLoginRegisterViewController._delegate;
        id method = _SNLoginRegisterViewController._method;
        id object = _SNLoginRegisterViewController._object;
        if(delegate && method && [method isKindOfClass:[NSValue class]] &&[delegate respondsToSelector:[method pointerValue]])
            [delegate performSelector:[method pointerValue] withObject:object afterDelay:0.1f];
        if (needpop)
            [_SNLoginRegisterViewController.flipboardNavigationController popViewControllerAnimated:YES];
    }
}

-(void)notifyGetUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeSuccess];
}

-(void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyLoginRequeestFailure");
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
}

//----------------------------------------------------------------------------------------------
//------------------------------------------- 外部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

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
    
    if(aTag!=201)
        bg1.selected = NO;
    else
        bg1.selected = YES;
    
    if(aTag!=202)
        bg2.selected = NO;
    else
        bg2.selected = YES;
}

-(NSString*)parameterVerify
{
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    if([[userNameTextField.text trim] length]==0)
        return NSLocalizedString(@"user_info_name_fail", nil);
    /*
    else if(_model!=nil && ![_model isValidateEmail:userNameTextField.text])
        return NSLocalizedString(@"user_info_name_check_fail", nil);*/
    
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    if([SNUserUtility isValidatePassword:[passwordTextField.text trim]])
        return NSLocalizedString(@"user_info_password_fail", nil);
    
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
    else
    {
        [self resignResponserByTag:-1];
        [self resetBgByTag:-1];
    }
}

//sina，renren，qq，taobao，baidu，kaixin，t.qq
-(void)createOpenUrlItemArray
{
    self._openUrlItemArray = nil;
    self._openUrlItemArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *dic = nil;
    //5.2 add 微信登录，未安装微信客户端，需要隐藏登录入口，否则隐含审核被拒风险
    if ([WXApi isWXAppInstalled]) {
        dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:@"wechat" forKey:@"type"];
        [dic setObject:@"微信" forKey:@"name"];
        [dic setObject:@"icoland_weixin_v5.png" forKey:@"image"];
        [dic setObject:@"icoland_weixinpress_v5.png" forKey:@"imageh"];
        [_openUrlItemArray addObject:dic];
    }
    
    dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:@"weibo" forKey:@"type"];//wangshun 按需改为weibo 原来sina 2017.8.7
    [dic setObject:@"新浪微博" forKey:@"name"];
    [dic setObject:@"icoland_sina_v5.png" forKey:@"image"];
    [dic setObject:@"icoland_sinapress_v5.png" forKey:@"imageh"];
    [_openUrlItemArray addObject:dic];
    
    dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:@"qq" forKey:@"type"];
    [dic setObject:@"QQ" forKey:@"name"];
    [dic setObject:@"icoland_qq_v5.png" forKey:@"image"];
    [dic setObject:@"icoland_qqpress_v5.png" forKey:@"imageh"];
    [_openUrlItemArray addObject:dic];
    
    dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:@"sohu" forKey:@"type"];
    [dic setObject:@"搜狐账号" forKey:@"name"];
    [dic setObject:@"icoland_sohu_v5.png" forKey:@"image"];
    [dic setObject:@"icoland_sohupress_v5.png" forKey:@"imageh"];
    [_openUrlItemArray addObject:dic];
}

#pragma mark -  第三方登录 点击

//第三方登录 点击

-(void)submitOpenLogin:(id)sender
{
    [SNUtility shouldUseSpreadAnimation:NO];
    UITextField* userNameTextField = (UITextField*)[self.view viewWithTag:101];
    UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:102];
    if(userNameTextField)
        [userNameTextField resignFirstResponder];
    if(passwordTextField)
        [passwordTextField resignFirstResponder];
    
    [_SNLoginRegisterViewController.bindMobileNumViewController.loginView setResignFirstResponder];
    UIButton* button = (UIButton*)sender;
    NSString* type = [self getTypeStringFromTag:button.tag];
    
    //埋点 wangshun login
    SNDebugLog(@"第三方登录点击:::%@",type);
    
    [self bury:type];
    
    if(type!=nil && [type length]>0)
    {
        if ([type isEqualToString:@"sohu"]) {
            if (self.isFromVideo) {
                NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
                NSValue* onBackMethod = [NSValue valueWithPointer:@selector(onBack)];
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:method,@"method",onBackMethod,@"onBackMethod", nil];
                self.soHuAccountLoginRegisterViewController = [[SNSoHuAccountLoginRegisterViewController alloc] initWithNavigatorURL:[NSURL URLWithString:@"tt://sohuAccountLoginRegister"] query:dic];
                self.soHuAccountLoginRegisterViewController.delegate = self;
                self.soHuAccountLoginRegisterViewController.sourceID = self.sourceChannelID;
                
                [[[TTNavigator navigator] topViewController] presentViewController:self.soHuAccountLoginRegisterViewController animated:YES completion:nil];
                
            }else{
                //NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:@"绑定手机", @"headTitle", @"立即绑定", @"buttonTitle", dic,@"data",self,@"third",nil];
                
                
                NSMutableDictionary* query = [NSMutableDictionary dictionaryWithDictionary:_queryDictionary];
                [query setObject:_SNLoginRegisterViewController forKey:@"popvc"];
                
                /*
                 @property(nonatomic, strong)NSString* commentBindOpen;
                 @property(nonatomic, weak)id commentpopvc;
                 */
                [query setObject:_SNLoginRegisterViewController.commentBindOpen forKey:@"commentBindOpen"];
                [query setObject:_SNLoginRegisterViewController.commentpopvc forKey:@"commentpopvc"];
                
//                if (_SNLoginRegisterViewController.loginSuccessModel) {
//                    [query setObject:_SNLoginRegisterViewController.loginSuccessModel forKey:@"loginSuccess"];
//                }
                
                
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://sohuAccountLoginRegister"] applyAnimated:YES] applyQuery:query];
                [[TTNavigator navigator] openURLAction:urlAction];
                
            }
        }
        else {
            if ([SNNewsThirdLoginEnable sharedInstance].isLanding == YES) {
                return;
            }
            
            ///第三方登录发起 wanshun third open
            //web登录流程
            if ([_SNLoginRegisterViewController.accountService openLoginLinkRequest:type loginFrom:self.sourceChannelID]) {
                
                
                _SNLoginRegisterViewController.accountService.openLoginUrlDelegate = self;
                [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
            }
            else {
                _SNLoginRegisterViewController.accountService.loginDelegate = self;
            }
        }
        
    }
}

- (void)bury:(NSString*)type{
}

-(void)loginSuccess{
    UIViewController *viewController = [SNSLib forLoginSuccessToPush];
    if (nil != viewController) {
        [self.flipboardNavigationController pushViewController:viewController];
    }else{
        [self.soHuAccountLoginRegisterViewController dismissViewControllerAnimated:YES completion:^{
            id delegate = _SNLoginRegisterViewController._delegate;
            id method = _SNLoginRegisterViewController._method;
            id object = _SNLoginRegisterViewController._object;
            if(delegate && method && [method isKindOfClass:[NSValue class]] &&[delegate respondsToSelector:[method pointerValue]])
                [delegate performSelector:[method pointerValue] withObject:object afterDelay:0.1f];
        }];
    }
}

-(void)onBack{
    [self.soHuAccountLoginRegisterViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(NSString*)getTypeStringFromTag:(NSInteger)aTag
{
    NSInteger index = (aTag-1) % 100;
    if(index>=0 && index<[_openUrlItemArray count])
    {
        NSMutableDictionary* dic = (NSMutableDictionary*)[_openUrlItemArray objectAtIndex:index];
        NSString* url = (NSString*)[dic objectForKey:@"type"];
        return url;
    }
    
    //default
    return nil;
}

-(void)openUrl:(NSString*)aUrl domain:(NSString*)aDomain
{
    if(aUrl!=nil && [aUrl length]>0)
    {
        NSDictionary* dic;
        dic = [NSDictionary dictionaryWithObjectsAndKeys:aUrl, @"url",nil, @"model", aDomain, @"domain", nil];
        
        TTURLAction* urlAction = [[TTURLAction actionWithURLPath:@"tt://oauthWebView"] applyQuery:dic];
        urlAction.animated = YES;
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

-(void)notifyOpenLoginUrSuccess:aUrl domain:(NSString*)aDomain
{
    [SNNotificationCenter hideLoading];
}

-(void)notifyOpenLoginUrFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeSuccess];
}

-(void)notifyOpenLoginUrDidFailLoadWithError:(NSError*)error
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
}

-(void)createGuideTip
{
    if(_guideLogin)
    {
        UIColor* labelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoLabelColor]];
        
        CGRect subRect = CGRectMake(0, 29, 320, 18);
        UILabel* guideTip = [[UILabel alloc] initWithFrame:subRect];
        guideTip.backgroundColor = [UIColor redColor];
        guideTip.textAlignment = NSTextAlignmentCenter;
        guideTip.font = [UIFont systemFontOfSize:16];
        guideTip.textColor = labelColor;
        guideTip.backgroundColor = [UIColor clearColor];
        guideTip.userInteractionEnabled = NO;
        guideTip.text = NSLocalizedString(@"user_info_guide_tip", nil);
        [self._scrollView addSubview:guideTip];
    }
}

-(void)createScrollView
{
    CGRect screenFrame = TTApplicationFrame();    
    self._scrollView = nil;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height-kToolbarHeight+7)];
    _scrollView.contentSize = CGSizeMake(screenFrame.size.width, 0);
    [self.view addSubview:_scrollView];
}

- (void)setSeperateLine:(CGFloat)height {
    self.line = [[UIImageView alloc] initWithFrame:CGRectMake(0, height, kAppScreenWidth, 0.5)];
    self.line.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [self.view addSubview:self.line];
}

- (NSDictionary *)getCurrentPhoneNumberData{
    NSDictionary* dic = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(getPhoneNumberData)]) {
        dic = [self.dataSource getPhoneNumberData];
    }
    return dic;
}

- (void)showPhoneVerify{
    self.phoneVerifyBtn.hidden = NO;
    [self.line setFrame:CGRectMake(0, self.tipLbl.bottom+14+15+12, kAppScreenWidth, 0.5)];
    self.tip.top = 224;
    
    self.weixinBtn.top = self.weixinBtn.frame.origin.y +16;
    self.qqBtn.top     = self.qqBtn.frame.origin.y     +16;
    self.sinaBtn.top   = self.sinaBtn.frame.origin.y   +16;
    self.sohuBtn.top   = self.sohuBtn.frame.origin.y   +16;
    
    self.last_icon.top = self.last_icon.frame.origin.y +16;
}

-(void)createOpenLoginPart
{
//    UIColor* textTipColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoTextTipColor]];
//    UIColor* textThridPartyColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoTextThirdPartyColor]];
    NSString* lastLoginPlatform = @"";
    NSDictionary* dic = [SNNewsRecordLastLogin getLastLogin:nil];
    if (dic) {
        NSString* key = [dic allKeys].firstObject;
        if (key) {
            if ([key isEqualToString:@"weibo"]) {
                lastLoginPlatform = @"新浪微博";
            }
            else if ([key isEqualToString:@"qq"]){
                lastLoginPlatform = @"QQ";
            }
            else if ([key isEqualToString:@"weixin"]){
                lastLoginPlatform = @"微信";
            }
            else if ([key isEqualToString:@"sohu"]){
                lastLoginPlatform = @"搜狐账号";
            }
        }
    }
    
    self.tipLbl = [[UILabel alloc] init];
    self.tipLbl.backgroundColor = [UIColor clearColor];
    self.tipLbl.textColor = SNUICOLOR(kThemeText3Color);
    self.tipLbl.text = kMobileTip;
    self.tipLbl.font = [UIFont systemFontOfSize:11];
    self.tipLbl.textAlignment = 1;
    [self.tipLbl sizeToFit];
    self.tipLbl.frame = CGRectMake(0,154+7, self.view.frame.size.width, self.tipLbl.frame.size.height);
    [self.view addSubview:self.tipLbl];
    
    self.phoneVerifyBtn = [[SNNewsLoginPhoneVerifyBtn alloc] initWithFrame:CGRectMake(0, self.tipLbl.bottom+14, self.view.frame.size.width, 15)];
    self.phoneVerifyBtn.dataSource = self;
    self.phoneVerifyBtn.hidden = YES;
    [self.view addSubview:self.phoneVerifyBtn];
    
    [self setSeperateLine:self.tipLbl.bottom+14];//tipLbl.bottom+14+15+12
    
    //@qz 这可以注了吧
    CGRect subRect = CGRectMake(0, 188, 320, 15);
    if(_guideLogin)
        subRect.origin.y += GUIDE_LOGIN_HEIGHT;
    
    self.tip = [[UILabel alloc] init];
    self.tip.font = [UIFont systemFontOfSize:11];
    self.tip.textColor = SNUICOLOR(kThemeText3Color);
    self.tip.backgroundColor = [UIColor clearColor];
    self.tip.textAlignment = NSTextAlignmentCenter;
    self.tip.userInteractionEnabled = NO;
    self.tip.text = NSLocalizedString(@"其他登录方式", nil);
    [self.tip sizeToFit];
    self.tip.left = 14;
    self.tip.top = 208;//224
    [self._scrollView addSubview:self.tip];

    float originX = 14;
    float originY = self.tip.bottom+14;
    
    NSArray* dicArray = _openUrlItemArray;
    if( dicArray!=nil && [dicArray count]>0)
    {
        UIImage *commonImage = [UIImage imageNamed:@"icoland_sohu_v5.png"];
        CGRect itemRect = CGRectMake(originX, originY, commonImage.size.width, commonImage.size.height);
        if(_guideLogin)
        {
            itemRect.origin.y += GUIDE_LOGIN_HEIGHT;
            itemRect.origin.y -= 10; //微调，露出文字来
        }
        
        for(NSInteger i=0; i<[dicArray count]; i++)
        {
            NSDictionary* item = (NSDictionary*)[dicArray objectAtIndex:i];
            UIButton* itemButton = [[UIButton alloc] initWithFrame:itemRect];
            itemButton.accessibilityLabel = [item objectForKey:@"name"];
            NSLog(@"name:::%@",itemButton.accessibilityLabel);

            itemButton.tag = 301+i;
            UIImage* normal = [UIImage imageNamed:[item objectForKey:@"image"]];
            UIImage* highLighted = [UIImage imageNamed:[item objectForKey:@"imageh"]];
            [itemButton setImage:normal forState:UIControlStateNormal];
            [itemButton setImage:highLighted forState:UIControlStateHighlighted];
            [itemButton addTarget:self action:@selector(submitOpenLogin:) forControlEvents:UIControlEventTouchUpInside];
            [self._scrollView addSubview:itemButton];
            
            if (lastLoginPlatform && lastLoginPlatform.length>0) {
                if ([itemButton.accessibilityLabel isEqualToString:lastLoginPlatform]) {//上次登录显示icon
                    SNNewsLastThirdLoginIcon* icon = [[SNNewsLastThirdLoginIcon alloc] initWithFrame:CGRectMake(itemRect.origin.x+20, itemRect.origin.y+1-10, 42, 17)];
                    [self._scrollView addSubview:icon];
                    self.last_icon = icon;
                }
            }
            
            if (i==0) {
                self.weixinBtn = itemButton;
            }
            else if (i==1){
                self.qqBtn = itemButton;
            }
            else if (i==2){
                self.sinaBtn = itemButton;
            }
            else if (i==3){
                self.sohuBtn = itemButton;
            }
            
            //Adjust base pos
            
            if ((i+1)%5!=0) {
                itemRect.origin.x += itemRect.size.width + (kAppScreenWidth - 5*normal.size.width - 28)/4;
            }
            else {
                itemRect.origin.x = originX;
                itemRect.origin.y += itemRect.size.height+14;
            }
        }
    }
}

@end
