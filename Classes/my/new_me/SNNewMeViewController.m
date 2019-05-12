//
//  SNNewMeViewController.m
//  sohunews
//
//  Created by cuiliangliang on 16/8/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNewMeViewController.h"
#import "SNNewMeTableViewCell.h"
#import "SNNewsMeUserPortraitCell.h"//用户画像 ws
#import "SNUserManager.h"
#import "SNAppConfigFloatingLayer.h"
#import "SNNewsReport.h"
#import "SNResetPromptRequest.h"
#import "SNUserPortrait.h"
#import "SNAppConfigMPLink.h"
#import "SNUserAccountService.h"
#import "SNNewAlertView.h"
#import "SNMySDK.h"
#import "SNNewsLogin.h"
#import "SNApplicationSohuRequest.h"
#import "SNNewsMeLoginCell.h"
#import "SNNewsLogout.h"

//#define kTableViewEmptyHeaderHeight ((kAppScreenWidth == 320.0) ? 28.0 : 43.0)
#define kTableViewEmptyHeaderHeight ((kAppScreenWidth == 320.0) ? 0.0 : 0.0)


@interface SNNewMeViewController ()<UITableViewDataSource, UITableViewDelegate,SNUserAccountDelegate,SNNewsMeLoginCellDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *sectionsArray;
@property(nonatomic, strong) SNUserAccountService * userAccountService;

@property(nonatomic, strong) SNUserPortrait *userPortrait;
@property(nonatomic, assign) NSInteger top_space;
@property(nonatomic, strong) UIImageView *waringImage;
@property(nonatomic, strong) UILabel *waringTip;

@property(nonatomic, strong) UIView *loginBgView;

-(void)initTableView;
@end

@implementation SNNewMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _userPortrait = [[SNUserPortrait alloc] init];//初始化用户画像
    
    [self loadSettingData];
    
    _loginBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 138+20)];
    _loginBgView.backgroundColor = SNUICOLOR(kThemeMeLoginHeaderColor);
    [self.view addSubview:_loginBgView];
    if (![SNUserManager isLogin]) {
        _loginBgView.hidden = NO;
    }
    else{
        _loginBgView.hidden = YES;
    }


    [self initTableView];
    //[self addHeaderView];
    [self updateTheme];
    
    [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:KABTestChangeAppStyleNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(loginBackColorChangeLogin:) name:kUserDidLoginNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(loginBackColorChangeLogout:) name:kUserDidLogoutNotification object:nil];
}

- (void)loginBackColorChangeLogin:(NSNotification*)notification{
    //发这个通知的时候状态还没变呢 所以没法用 [SNUserManager isLogin];
//    UIColor *color = SNUICOLOR(kThemeBgRIColor);
//    _loginBgView.backgroundColor = color;
    _loginBgView.hidden = YES;
}
- (void)loginBackColorChangeLogout:(NSNotification*)notification{
    //发这个通知的时候状态还没变呢 所以没法用 [SNUserManager isLogin];
    _loginBgView.backgroundColor = SNUICOLOR(kThemeMeLoginHeaderColor);
    _loginBgView.hidden = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
   // self.tabbarView.hidden = NO;
    [self refreshLogoutCell];
    [self getfaceInfo];
    if ([SNUserManager isLogin]) {
        [self loadApplicationSohu];
        [self refreshSNSUserInfo];
    }
}

- (void)refreshSNSUserInfo{
    NSDictionary* dic = [SNSLib getSnsUserInfo];
    SNDebugLog(@"dic:::%@",dic);
    NSString* name = [dic objectForKey:@"name"];
    if (name && name.length>0) {
        [SNUserinfoEx userinfoEx].nickName = name;
    }
    NSString* avater = [dic objectForKey:@"avater"];
    if (avater && avater.length>0) {
        [SNUserinfoEx userinfoEx].headImageUrl = avater;
    }
    
    [[SNUserinfoEx userinfoEx] saveUserinfoToUserDefault];
    
    [self refreshTable];
}

/// 登录状态下用于检查申请公众号的状态,判断是否刷新表格
- (void)loadApplicationSohu {
    
    [SNApplicationSohuRequest checkReloadApplicationSohuWithHandler:^(BOOL needReload,NSDictionary *data) {
        if (needReload) {
            NSDictionary *sohuDict = [data dictionaryValueForKey:@"sohuHaoTab" defalutValue:nil];
            NSInteger isShow = [sohuDict intValueForKey:@"isShow" defaultValue:3];
            NSMutableArray *rows = [_sectionsArray objectAtIndex:0];
            __block BOOL hasApplicationSohu = NO;
            __block NSInteger applicationIndex = 0;
            [rows enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *openUrl = [obj stringValueForKey:@"openUrl" defaultValue:@""];
                if ([openUrl isEqualToString:@"application"]) {
                    hasApplicationSohu = YES;
                    applicationIndex = idx;
                    *stop = YES;
                }
            }];
            
            if (1 == isShow) {
                if (!hasApplicationSohu) { // 需要展示,但现在未显示
                    [self loadSettingData];
                    [self.tableView reloadData];
                } else { // 需要刷新
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:applicationIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            } else if (0 == isShow) {
                if (hasApplicationSohu) { // 不要展示,但现在显示
                    [rows removeObjectAtIndex:applicationIndex];
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:applicationIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
        
    }];
}

- (void)refreshLogoutCell {
    if (self.tableView) {
        /// ===========================
        NSMutableArray *rows = [_sectionsArray objectAtIndex:0];
        __block BOOL hasLogout = NO;
        __block NSInteger logoutIndex = 0;
        [rows enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *title = [obj stringValueForKey:@"title" defaultValue:@""];
            if ([title isEqualToString:@"退出登录"]) {
                hasLogout = YES;
                logoutIndex = idx;
                *stop = YES;
            }
        }];
        if ([SNUserManager isLogin]) {
            if (!hasLogout) {
                [self loadSettingData];
            }
        } else {
            if (hasLogout) {
                [rows removeObjectAtIndex:logoutIndex];
            }
        }
        /// ==========================
        [self.tableView reloadData];
    }
}

- (void)loadSettingData {
    self.sectionsArray = [NSMutableArray array];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"meList" ofType:@"plist"];
    NSArray *sections = [NSArray arrayWithContentsOfFile:plistPath];
    if ([sections count] > 0) {
        [self.sectionsArray addObjectsFromArray:sections];
    }
    
    self.sectionsArray = [_userPortrait addUserPortraitInitData:self.sectionsArray];
}
- (void)addHeaderView
{
    if (!_headerView)
    {
        _headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderTotalHeight)];
        [self.view addSubview:_headerView];
    }
    self.headerView.delegate = self;
    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"MeName",@""),nil]];
    CGSize titleSize = [NSLocalizedString(@"MeName",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
}

-(void)initTableView{
    self.top_space = 0;
    
    CGFloat height = 20+self.top_space;
    
    CGRect rect = CGRectMake(0, height, TTApplicationFrame().size.width, TTApplicationFrame().size.height - TTToolbarHeight()- height);
    UITableView* tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    tableView.contentInset = UIEdgeInsetsMake(kTableViewEmptyHeaderHeight, 0, 10, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //只在完成UI特效 wangshun
    SNDebugLog(@"self.%f",scrollView.contentOffset.y);
    if (self.loginBgView.hidden == NO) {
        self.loginBgView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 138+20-(scrollView.contentOffset.y));
    }
}

- (void)updateTheme
{
    //5.9.3 wangchuanwen update
    //UIColor *color = SNUICOLOR(kThemeBg3Color);
    //self.view.backgroundColor = color;
    UIColor *color = SNUICOLOR(kThemeBgRIColor);
    self.view.backgroundColor = color;
    
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
    [_tableView setSeparatorColor:grayColor];
    //_tableView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    _tableView.backgroundColor = [UIColor clearColor];
    
    if ([SNUserManager isLogin]) {
        _loginBgView.hidden = YES;
    }
    else{
        _loginBgView.hidden = NO;
        _loginBgView.backgroundColor = SNUICOLOR(kThemeMeLoginHeaderColor);
    }
    
    if (_waringImage) {
        [_waringImage setImage:[UIImage themeImageNamed:@"icome_bg_v5.png"]];
        _waringTip.textColor = SNUICOLOR(kThemeText2Color);
    }
}

- (void)updateTheme:(NSNotification *)notifiction
{
    [super updateTheme:notifiction];
    [self updateTheme];
    [self.tableView reloadData];
}

- (void)reloadSohuHao {
    if ([SNUserManager isLogin]) {
       [self loadApplicationSohu];
    }
}

-(void)refreshTable{
    [self refreshLogoutCell];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)iconNames {
    return [NSArray arrayWithObjects:@"icotab_set_v5.png", @"icotab_setpress_v5.png", nil];
}
- (NSString *)tabItemText {
    if ([SNUtility getTabBarName:3]) {
        return [SNUtility getTabBarName:3];
    }
    return NSLocalizedString(@"MeName", nil);
}
- (void)showTabbarView {
    if (_bLockTabbarView) {
        return;
    }
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat addHeight = 0.0;
    if (statusBarRect.size.height > 20.0) {
        addHeight = 20.0;
    }

    if (self.view.frame.size.height == kAppScreenHeight) {
        addHeight = 0;
    }

    SNTabbarView *tabView = self.tabbarView;
    [tabView removeFromSuperview];
    tabView.top = self.view.height - tabView.height - addHeight;
    [self.view addSubview:tabView];
    
    self.tabbarSnapView = tabView;
    
    [self setTabbarViewLocked:YES];
}

- (void)setTabbarViewVisible:(BOOL)bVisible {
    if (!bVisible) self.tabbarSnapView = nil;
}

- (void)setTabbarViewLocked:(BOOL)bLocked {
    _bLockTabbarView = bLocked;
}

-(void)loginSuccess{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDatasource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = (NSArray *)[_sectionsArray objectAtIndex:0];
    return _sectionsArray.count > 0 ? [array count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // cell data info
    NSArray *rows = [_sectionsArray objectAtIndex:[indexPath section]];
    NSDictionary *rowDic = [rows objectAtIndex:[indexPath row]];
    NSString *title = [rowDic stringValueForKey:@"title" defaultValue:@""];
    if ([title isEqualToString:@"UserPortrait"]) {//用户画像
        static NSString* identifier = @"UserPortrait";
        SNNewsMeUserPortraitCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[SNNewsMeUserPortraitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.showSlectedBg = YES;
        }
        [cell updateData:self.userPortrait.faceInfo];
        return cell;
    }
    else if ([title isEqualToString:@"登录"]) {
        static NSString* identifier = @"login";
        SNNewsMeLoginCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[SNNewsMeLoginCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.delegate = self;
        [cell update];
        
        return cell;
    }
    
    
    static NSString *cellIdentifier=@"UITableViewCellIdentifierKey1";
    SNNewMeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell=[[SNNewMeTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell loadDataToUpDateUI:rowDic];
    cell.showSlectedBg = YES;
    NSString *selector = [rowDic stringValueForKey:@"selector" defaultValue:@""];
    if ([title isEqualToString:@"space"]) {
            cell.showSlectedBg = NO;
    }
    if ([selector isEqualToString:@"openNight"]) {
       cell.showSlectedBg = NO;
    }
    //5.8.7特殊处理活动cell wyy
    if ([title isEqualToString:@"活动"]) {
        [self dealActivityCell:cell];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *rows = [_sectionsArray objectAtIndex:[indexPath section]];
    NSDictionary *rowDic = [rows objectAtIndex:[indexPath row]];
    NSString *title = [rowDic stringValueForKey:@"title" defaultValue:@""];
    if ([title isEqualToString:@"space"]) {
        return 25;
    } else if ([title isEqualToString:@"UserPortrait"]) {
        return [SNNewsMeUserPortraitCell getCellHeight:self.userPortrait.faceInfo];
    }
    else if ([title isEqualToString:@"登录"]) {
        if ([SNUserManager isLogin]) {
            return 100;
        }
        else{
            return 138;
        }
    }
    
    CGFloat topValue = [[SNDevice sharedInstance] isPlus] ? 49.5*1.1 : 49.5;
    return topValue;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SNUtility shouldUseSpreadAnimation:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *rows = [_sectionsArray objectAtIndex:[indexPath section]];
    NSDictionary *rowDic = [rows objectAtIndex:[indexPath row]];
    NSString *url = [rowDic stringValueForKey:@"openUrl" defaultValue:@""];
    NSString *fun = [rowDic stringValueForKey:@"fun" defaultValue:@""];
    if ([fun length] > 0) {
        NSString *paramStr = [NSString stringWithFormat:@"act=cc&fun=%@",fun];
        [SNNewsReport reportADotGif:paramStr];
    }
    if ([url length] > 0) {
        //self.tabbarView.hidden = YES;
        
        if ([url isEqualToString:@"activity"]) {
            NSString *actionURLString = nil;
            SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
            if ([themeManager.currentTheme isEqualToString:@"night"]) {
                actionURLString = [SNUtility addParamModeToURL:kUrlNewActionList];
                actionURLString = [actionURLString stringByAppendingString:@"&platformId=5"];
            } else {
                actionURLString = [NSString stringWithFormat:@"%@?platformId=5", kUrlNewActionList];
            }
            actionURLString = [NSString stringWithFormat:@"%@&p1=%@", actionURLString, [SNUserManager getP1]];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:actionURLString, kLink, kActionName_ActivePage, kActionType, [NSNumber numberWithInteger:ActivityWebViewType], kUniversalWebViewType, nil];
            [SNUtility openUniversalWebView:dic];
            //点击活动
            [self cancelActiveTips];
        } else if ([url isEqualToString:@"logout"]) { // 退出登录

            SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:@"退出当前账号？" cancelButtonTitle:@"取消" otherButtonTitle:@"退出"];
            [alert show];
            [alert actionWithBlocksCancelButtonHandler:^{
                
            } otherButtonHandler:^{
                [self submitLogout];
            }];
        } else if ([url isEqualToString:@"openSNS"]) { // 打开狐友

            SNTabbarView *tabView = self.tabbarView;
            for (UIButton *button in tabView.tabButtons) {
                //狐友Tag如果变化了需要修改
                if (button.tag == 2) {
                    [tabView tabButtonClicked:button];
                    break;
                }
            }
            //另一种跳转方式, 因为二代协议跳转有闪屏幕
            //[SNUtility openProtocolUrl:kJumpToSNS];
        } else if ([url isEqualToString:@"treasure"]){
            SNAppConfigFloatingLayer *floatingLayer = [SNAppConfigManager sharedInstance].floatingLayer;
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:[NSNumber numberWithInteger:RedPacketWebViewType] forKey:kUniversalWebViewType];
            if (floatingLayer.H5Url) {
                [SNUtility openProtocolUrl:floatingLayer.H5Url context:nil];
            }
        } else if ([url isEqualToString:@"favorable"]){
            //登录拦截
            if (![SNUserManager isLogin]) {
                [SNGuideRegisterManager login:kLoginFromShareMySohu];
                [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
                [SNUtility setUserDefaultSourceType:kUserActionIdForArticleComment keyString:kLoginSourceTag];
            } else {
                NSString *ticketUrl = [[SNAppConfigManager sharedInstance] getMytabCouponTicketUrl];
                if (ticketUrl.length > 0) {
                    [SNUtility openProtocolUrl:ticketUrl context:@{kUniversalWebViewType : [NSNumber numberWithInteger:MyTicketsListWebViewType]}];
                    [SNNotificationManager postNotificationName:kResetMyCouponBadgeNotification object:[NSNumber numberWithBool:YES]];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kMyCouponBadgeUnRead];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return;
                }
                [SNUtility openProtocolUrl:[@"login://back2url=" stringByAppendingString:FixedUrl_ApiK_CouponList] context:@{kUniversalWebViewType : [NSNumber numberWithInteger:MyTicketsListWebViewType]}];
                [SNNotificationManager postNotificationName:kResetMyCouponBadgeNotification object:[NSNumber numberWithBool:YES]];
                [SNUserDefaults setObject:[NSNumber numberWithBool:NO] forKey:kMyCouponBadgeUnRead];
            }
            
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=coupon&_tp=localpv&channelId=%@", [SNUtility getCurrentChannelId]]];
        } else if ([url isEqualToString:@"application"]) { // 申请公众号
            [self processApplicationSohuHao];
        } else if ([url isEqualToString:kProtocolReadHistory]) {
            [SNUtility openProtocolUrl:kProtocolReadHistory context:nil];
        } else if ([url isEqualToString:kPushHistory]) {
            [SNUtility openProtocolUrl:kPushHistory context:nil];
        } else if([url isEqualToString:kUserPortrait]) {
            SNNewsMeUserPortraitCell* cell = (SNNewsMeUserPortraitCell*)[tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                [cell jumpLink];
            }
        } else if ([url isEqualToString:@"tt://subscribeWebBrowser"]) {
            SNAppConfigMPLink *confifMPLink = [SNAppConfigManager sharedInstance].configMPLink;
            NSString *stat = nil;
            if (confifMPLink.mpLink.length > 0) {
                stat = confifMPLink.mpLink;
            } else {
                stat = [NSString stringWithFormat:FixedUrl_Subscribe];
            }
            if ([stat length] > 0 && [SNAPI isWebURL:stat]) {
                [SNNewsReport reportADotGif:@"_act=moresub&_tp=pv"];
                
                NSMutableDictionary *query = [NSMutableDictionary dictionary];
                [query setObject:stat forKey:kLink];
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://subscribeWebBrowser"] applyAnimated:YES] applyQuery:query];
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        } else {
            TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
            [[TTNavigator navigator] openURLAction:action];
        }
    }
}

- (void)processApplicationSohuHao {
    NSString *sohuFun = @"125";
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:SN_ApplicationSohuPath];
    NSDictionary *sohuDict = [dataDict dictionaryValueForKey:@"sohuHaoTab" defalutValue:nil];
    // 点击搜狐号的埋点
    NSInteger showType = [sohuDict intValueForKey:@"showType" defaultValue:3];
    if (1 == showType) { // 显示管理
        sohuFun = @"126";
    } else if (0 == showType) { // 显示申请
        sohuFun = @"125";
    }
    NSString *actionURLString = [dataDict stringValueForKey:@"nativeProtocol" defaultValue:nil];
    NSString *sohuStr = [NSString stringWithFormat:@"act=cc&fun=%@",sohuFun];
    [SNNewsReport reportADotGif:sohuStr];
    
    if ([SNUserManager isLogin]) {
        [SNUtility openProtocolUrl:actionURLString context:@{kUniversalWebViewType:[NSNumber numberWithInteger:ApplicationSohuWebViewType]}];
    } else { // 未登录状态
        //登录由sns处理
        [SNUtility openProtocolUrl:@"sns://applySohuNum/"];
    }
}

- (void)getfaceInfo{//这个功能早就下了 wangshun
}

- (void)cancelActiveTips {

    [[[SNResetPromptRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        
        NSString *status = [responseObject objectForKey:@"statusCode"];
        if ([status isEqualToString:@"000"]) {
            [SNNotificationManager postNotificationName:kUnActiveTipsClearNotification object:[NSNumber numberWithBool:YES]];
        } else {
            [SNNotificationManager postNotificationName:kUnActiveTipsClearNotification object:[NSNumber numberWithBool:YES]];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        
    }];
}

- (void)applicationWillEnterForeground{//从后台进前台 刷一下用户画像
    [self getfaceInfo];//
}

#pragma mark 特殊处理活动cell

- (void)dealActivityCell:(UITableViewCell *)cell{
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    BOOL isFirtShow = ![[NSUserDefaults standardUserDefaults] boolForKey:@"kActivityWarning"];
    
    //业务需要，提示阅读空间搬迁
    if ([versionStr isEqualToString:@"5.8.7"] && isFirtShow) {
        if (!_waringTip) {
            UIImage *image = [UIImage themeImageNamed:@"icome_bg_v5.png"];
            CGFloat yValue = (cell.frame.size.height - image.size.height)/2;
            yValue = [SNDevice sharedInstance].isPlus ? yValue + 6 : yValue + 2;
            _waringImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, yValue, image.size.width, image.size.height)];
            _waringImage.left = 90;
            _waringImage.layer.masksToBounds = YES;
            [_waringImage setImage:image];
            [cell addSubview:_waringImage];
            
            _waringTip = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, image.size.width - 7, image.size.height)];
            _waringTip.text = @"阅读空间搬家到这里啦！";
            _waringTip.textColor = SNUICOLOR(kThemeText2Color);
            _waringTip.backgroundColor = [UIColor clearColor];
            _waringTip.textAlignment = NSTextAlignmentCenter;
            _waringTip.font = [UIFont systemFontOfSize:15];
            [_waringImage addSubview:_waringTip];
        }
        
        _waringImage.transform = CGAffineTransformMakeScale(1,1);
        [NSTimer scheduledTimerWithTimeInterval:5
                                         target:self
                                       selector:@selector(dismissWaringTip)
                                       userInfo:nil
                                        repeats:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kActivityWarning"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)dismissWaringTip{
    [UIView animateWithDuration:0.3 animations:^{
        _waringImage.transform = CGAffineTransformMakeScale(0.2,0.2);
    } completion:^(BOOL finished) {
        [_waringImage removeFromSuperview];
    }];
}


-(void)submitLogout
{
    NSString *paramStr = [NSString stringWithFormat:@"act=cc&fun=124"];
    [SNNewsReport reportADotGif:paramStr];
    
//    if (!_userAccountService) {
//        _userAccountService = [[SNUserAccountService alloc] init];
//        _userAccountService.userDelegate = self;
//    }
//    [_userAccountService requestLogout];
    [[SNCenterToast shareInstance] showWithTitle:@"正在退出.."];
//    [[SNMySDK sharedInstance] logout];
    
    [SNNewsLogout requestLogout:^(NSDictionary *info) {
        if(info){
            NSString* success = [info objectForKey:@"loginOut"];
            if([success isEqualToString:@"1"]){//成功
                [self notifyUserLogoutSuccess];
            }
            else if([success isEqualToString:@"-2"]){//无网
                [self notifyUserAccountServerFailure:SNUserAccountTypeLogout withMsg:nil];
            }
            else {//失败
                NSString* msg = [info objectForKey:@"msg"];
//                [self notifyUserAccountServerFailure:SNUserAccountTypeLogout withMsg:msg];
                if (msg) {
                    [[SNCenterToast shareInstance] showCenterToastToFullScreenViewWithTitle:msg toUrl:nil userInfo:nil mode:SNCenterToastModeOnlyText];
                }
            }
        }
    }];
}

#pragma -mark SNUserAccountDelegate
-(void)notifyUserLogoutSuccess
{
    [self refreshLogoutCell];
    [[SNCenterToast shareInstance] hideToast];
//    [[SNCenterToast shareInstance] showWithTitle:@"退出成功"];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_logout_success",@"") toUrl:nil mode:SNCenterToastModeOnlyText];
}

-(void)notifyUserAccountServerFailure:(NSInteger)aType withMsg:(NSString *)aMsg
{
    [[SNCenterToast shareInstance] hideToast];
    [SNNotificationCenter showExclamation:aMsg];
}

-(void)notifyUserAccountNetworkFailure:(NSInteger)aType withError:(NSError *)aError
{
    [[SNCenterToast shareInstance] hideToast];
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"]){
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

@end
