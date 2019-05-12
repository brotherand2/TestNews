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


@interface SNNewsSohuLoginViewController ()<SNSohuPhoneLoginViewDelegate>

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addHeaderView];
    
    [self createSohuPhoneView];
    
    [self addToolbar];
}

#pragma mark -  sohu 登录

- (void)sohuLoginClick:(NSDictionary *)dic{
    [self createSohuLoginModel];
    
    NSDictionary* phoneDic = [self.sohuPhoneView getSohuAccountAndPassword];
    __weak SNNewsSohuLoginViewController* weakSelf = self;
    [self.sohuLoginViewModel sohuLogin:phoneDic WithSuccessed:^(NSDictionary *resultDic) {
        if (resultDic) {
            NSString* success = [resultDic objectForKey:@"success"];
            if ([success isEqualToString:@"1"]) {
                [weakSelf.loginSuccessModel loginSucessed:resultDic];
            }
        }
    }];
}

#pragma mark - create UI

- (void)createSohuPhoneView{
    
    self.sohuPhoneView = [[SNSohuPhoneLoginView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom, self.view.bounds.size.width, 200)];
    self.sohuPhoneView.delegate = self;
    [self.view addSubview:self.sohuPhoneView];
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
    self.sohuLoginViewModel = [[SNSohuLoginViewModel alloc] init];
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
    [self.sohuPhoneView closeKeyBoard];
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
