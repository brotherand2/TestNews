//
//  SNNewsSohuLoginViewController.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsSohuLoginViewController.h"
#import "SNNewsLoginSuccess.h"

#import "SNSohuPhoneLoginView.h"
#import "SNNewsLoginKeyBoard.h"

#import "SNSohuLoginViewModel.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginEnvironment.h"

#import "SNUserManager.h"
#import "SNSLib.h"


@interface SNNewsSohuLoginViewController ()<SNSohuPhoneLoginViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UIButton* bottomTip;
@property (nonatomic,strong) NSString* screen;//是否半屏

@property (nonatomic,strong) UIScrollView* bgScrollView;
@property (nonatomic,strong) UIView* bgView;

@property (nonatomic,strong) SNSohuPhoneLoginView* sohuPhoneView;//键盘
@property (nonatomic,strong) SNNewsLoginKeyBoard* keyboard;//键盘

@property (nonatomic,strong) SNSohuLoginViewModel* sohuLoginViewModel;//搜狐passport登录流程
@property (nonatomic,strong) SNNewsLoginSuccess* loginSuccessModel;//搜狐passport登录成功

@end

@implementation SNNewsSohuLoginViewController

- (void)dealloc{
    [self removeKeyBoardNotification];
}

-(id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
    if (self = [super initWithNavigatorURL:URL query:query]) {
        if ([query objectForKey:@"loginSuccess"]) {
            id sender = [query objectForKey:@"loginSuccess"];
            if ([sender isKindOfClass:[SNNewsLoginSuccess class]]) {
                self.loginSuccessModel = sender;
            }
        }
        
        NSString* s = [query objectForKey:@"screen"];
        if ([s isEqualToString:@"1"]) {//半屏
            self.screen = @"1";
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
    
    [self createSohuPhoneView];
    
    [self createBottomTipLabel];
    
    [self addToolbar];
    
    [self createkeyboardNotification];
}

#pragma mark -  sohu 登录

- (void)sohuLoginClick:(NSDictionary *)dic{
    [self createSohuLoginModel];
    [self.sohuPhoneView closeKeyBoard];
    
    NSDictionary* phoneDic = [self.sohuPhoneView getSohuAccountAndPassword];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:phoneDic];
    if (self.loginSuccessModel.sourceChannelID) {
        [params setObject:self.loginSuccessModel.sourceChannelID?:@"" forKey:@"loginFrom"];
        if ([self.loginSuccessModel.screen isEqualToString:@"1"]) {
            [params setObject:@"1" forKey:@"screen"];
        }
        else{
            [params setObject:@"0" forKey:@"screen"];
        }
    }
    
    if (self.loginSuccessModel.entrance) {
        [params setObject:self.loginSuccessModel.entrance?:@"" forKey:@"entrance"];
    }
    
    if ([SNNewsPPLoginEnvironment isPPLogin]) {
        if ([self.sohuPhoneView isShowPhotoVcode]) {
            NSString* captcha = [self.sohuPhoneView getPhotoVcode];
            [params setObject:captcha?:@"" forKey:@"captcha"];
        }
    }
    
    __weak SNNewsSohuLoginViewController* weakSelf = self;
    [self.sohuLoginViewModel sohuLogin:params WithSuccessed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {
                if ([weakSelf.screen isEqualToString:@"1"]) {
                    [weakSelf.loginSuccessModel halfLoginSucessed:resultDic WithAnimation:nil];
                }
                else{
                    [weakSelf.loginSuccessModel loginSucessed:resultDic];
                }
            }
            else if ([success isEqualToString:@"40108"]){//请输入图形验证码 wangshun
                [self.sohuPhoneView showPhotoVcode];
                [self.sohuPhoneView clearPassword];
                [self changeScrollViewContentSize];
            }
            else if ([success isEqualToString:@"40105"]){//图形验证码输入错误 wangshun
                [self.sohuPhoneView showPhotoVcode];
                [self changeScrollViewContentSize];
            }
            else if ([success isEqualToString:@"40501"]){//账号密码输入错误 wangshun
                [self.sohuPhoneView clearPassword];
            }
        }
    }];
}


#pragma mark - create UI

- (void)createSohuPhoneView{
    CGFloat h = (110-13)/2.0;
    self.sohuPhoneView = [[SNSohuPhoneLoginView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom+22, self.view.bounds.size.width, 200+h+13)];
    self.sohuPhoneView.delegate = self;
    [_bgView addSubview:self.sohuPhoneView];
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

- (void)userServeAgreementClick{
    [SNUtility openProtocolUrl:SNSOHU_USLER_Protocal];
}

- (void)changeScrollViewContentSize{
    if (self.view.bounds.size.height<=480) {//小屏
        [_bgScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.size.height+100)];
    }
    else{
        if (self.sohuPhoneView.photovcodeField.hidden == NO) {
            _bgScrollView.alwaysBounceVertical = YES;
        }
    }
}

- (void)createScrollView{
    _bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_bgScrollView];
    _bgScrollView.backgroundColor = [UIColor clearColor];
    _bgScrollView.delegate = self;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
    
    point = [self.sohuPhoneView.layer convertPoint:point fromLayer:_bgView.layer];
    //get layer using containsPoint:
    if (point.y>110) {//sohu view 110是两个textfield高度加一起中间还有13的间隔 wangshun
        [self.sohuPhoneView closeKeyBoard];
    }
}

- (void)onBack:(id)sender{
    
//    SNDebugLog(@"%@",self.flipboardNavigationController.childViewControllers);
//    埋点
    UIViewController* lastClass = [self.flipboardNavigationController.childViewControllers lastObject];
    if ([NSStringFromClass([lastClass class]) isEqualToString:@"SNNewsSohuLoginViewController"]) {
        NSInteger n = [self.flipboardNavigationController.childViewControllers count];
        if (n>=2) {
            NSInteger m = n-2;
            lastClass = [self.flipboardNavigationController.childViewControllers objectAtIndex:m];
            if (lastClass) {
                if ([NSStringFromClass([lastClass class]) isEqualToString:@"SNNewMeViewController"]) {
                    NSDictionary* dic = @{@"loginSuccess":@"2",@"cid":[SNUserManager getP1],@"errType":@"0",@"screen":@"0"};
                    NSString* sourceChannelID = self.loginSuccessModel.sourceChannelID;
                    SNDebugLog(@"sourceChannelID:%@",sourceChannelID);
                    SNDebugLog(@"dic:%@",dic);
                    if (sourceChannelID && ![sourceChannelID isEqualToString:@"-1"]) {
                        [SNSLib addCountForSohuNewsLoginEventWithKey:sourceChannelID bodyDic:dic];
                    }
                }
            }
        }
        
    }
    
    [super onBack:sender];
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

- (void)createSohuLoginModel{
    if (!_sohuLoginViewModel) {
        self.sohuLoginViewModel = [[SNSohuLoginViewModel alloc] init];
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
    [self.sohuPhoneView closeKeyBoard];
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
//    [self.sohuPhoneView closeKeyBoard];
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

