//
//  SNSettingViewController.m
//  sohunews
//
//  Created by weibin cheng on 13-8-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSettingViewController.h"
#import "UIColor+ColorUtils.h"
#import "SNSettingBaseCell.h"
#import "SNDBManager.h"
#import "SNUserAccountService.h"
#import "SNUserManager.h"
#import "SNAppstoreRateHelper.h"
#import "SNToast.h"
#import "SNUpgradeInfo.h"
#import "SNMySDK.h"
#import "SNNewsLogout.h"

@interface SNSettingViewController ()<SKStoreProductViewControllerDelegate>
{
}
@property(nonatomic, strong) NSMutableArray *sectionsArray;
@property(nonatomic, strong) SNUserAccountService *accountService;
@property(nonatomic, strong) UIView*    footerView;
- (void)loadSettingData;
@end

@implementation SNSettingViewController
@synthesize tableView = _tableView;
@synthesize sectionsArray = _sectionsArray;
@synthesize upgrade = _upgrade;
@synthesize upgradeInfo = _upgradeInfo;
@synthesize actionSheet = _actionSheet;
@synthesize accountService = _accountService;
@synthesize footerView = _footerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        // load plist data
        [self loadSettingData];
    }
    return self;
}
- (SNCCPVPage)currentPage {
    return more_setting;
}

- (void)loadView
{
    [super loadView];
    
    
    CGRect rect = CGRectMake(0, 44-14, TTApplicationFrame().size.width, TTApplicationFrame().size.height - TTToolbarHeight()- 44 +  14);
    UITableView* tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    //5.9.3 wangchuanwen update
    //tableView.backgroundView = nil;
    //换成abTest背景色 5.9.3 by wangchuanwen
    tableView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    else
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.contentInset =UIEdgeInsetsMake(10, 0, 0, 0);
    tableView.sectionFooterHeight = 0;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [self addHeaderView];
    self.headerView.delegate = self;
    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"SouHuSetting",@""),nil]];
    CGSize titleSize = [NSLocalizedString(@"SouHuSetting",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    
    [self addToolbar];
    [self updateTheme];
    
    [SNNotificationManager addObserver:self selector:@selector(articleFontSizeSet:) name:kArticleFontSizeSetNotification object:nil];
    
    [[SNAppstoreRateHelper sharedInstance] showRateDialogIfNeeded];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSettingData];
    [_tableView reloadData];
        
    [self calculateCacheSizeInNewThreadIfNeeded];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
     //(_tableView);
     //(_sectionsArray);
     //(_accountService);
     //(_footerView);
}

#pragma mark - private
- (UIView*)footerView
{
    if(_footerView == nil)
    {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 90)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 100;
        button.frame = CGRectMake(10, 15, kAppScreenWidth-20, 40);
        [button addTarget:self action:@selector(kickLogout) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"退出登录" forState:UIControlStateNormal];
        [_footerView addSubview:button];
    }
    return nil;
}

- (void)updateFooterViewTheme
{
    if(self.footerView)
    {
        UIButton* button = (UIButton*)[self.footerView viewWithTag:100];
        if(button)
        {
            [button setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubCenterDetailWhiteBtnTextColor]] forState:UIControlStateNormal];
            UIImage* normalImage = [UIImage themeImageNamed:@"act_btn_destructive_normal.png"];
            UIImage* highlightImage = [UIImage themeImageNamed:@"act_btn_destructive_highlight.png"];
            [normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            [highlightImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            [button setBackgroundImage:normalImage forState:UIControlStateNormal];
            [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
        }
    }
}

- (NSMutableDictionary *)getShareSettingBtn
{
    NSMutableDictionary* shareDic = [NSMutableDictionary dictionaryWithCapacity:4];
    [shareDic setObject:@"分享设置" forKey:@"title"];
    [shareDic setObject:@"kickOpenUrl:" forKey:@"selector"];
    [shareDic setObject:@"SNSettingCellWithIndicatorOnly" forKey:@"cellClass"];
    [shareDic setObject:@"tt://shareSetting" forKey:@"openUrl"];
    
    return shareDic;
}

- (void)addShareSettingBtnIfNotExists
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.sectionsArray[1]];
    
    if (arr.count == 1) {
        [arr addObject:[self getShareSettingBtn]];
        
        self.sectionsArray[1] = arr;
    }
    
}

- (void)loadSettingData {
    self.sectionsArray = [NSMutableArray array];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settingList" ofType:@"plist"];
    NSArray *sections = [NSArray arrayWithContentsOfFile:plistPath];
    if ([sections count] > 0) {
        [self.sectionsArray addObjectsFromArray:sections];
    }
}

- (void)updateSettingData {
    //退出登录按钮
    if ([SNUserinfoEx isLogin]) {
        if (nil == self.tableView.tableFooterView) {
            self.tableView.tableFooterView = self.footerView;
        }
    } else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)updateTheme
{
    [_tableView setSeparatorColor:SNUICOLOR(kThemeBg6Color)];
    UIColor *color = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    _tableView.backgroundColor = color;
    self.view.backgroundColor = color;
    [_tableView reloadData];
    [self.headerView updateTheme];
    [self updateFooterViewTheme];
}

- (void)updateTheme:(NSNotification *)notifiction
{
    [super updateTheme:notifiction];
    [self updateTheme];
}

- (void)calculateCacheSizeInNewThreadIfNeeded {
    
    dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bNeedUpdateCacheSize	= YES;
        
        NSDate *cacheSizeUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:kCacheSizeUpdateDate];
        if(!cacheSizeUpdateDate || fabs([cacheSizeUpdateDate timeIntervalSinceNow]) >= kUpdateCacheSizeInterval) {
            bNeedUpdateCacheSize = YES;
            //防止计算过程中又启动线程而进行多次计算；
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kCacheSizeUpdateDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            bNeedUpdateCacheSize = NO;
        }
        
        if (bNeedUpdateCacheSize) {
            
            SNDebugLog(@"INFO: Geting size at %@....... main thread %d", [NSDate date], [NSThread isMainThread]);
            
            //SNStopWatch *watch = [[SNStopWatch watch] begin];
            //[self saveCacheSizeBlockUI];
            //[[watch stop] print:@"getCacheSize"];
            CGFloat fCacheSize = [self getCacheSizeAtPath:[self getCachesPath]];
            //float fCacheSize = [[SNDBManager currentDataBase] getTTCacheSize];
            NSString *_strCacheSize = @"0.0 MB";
            if (fCacheSize >= 0.1) {
                _strCacheSize = [NSString stringWithFormat:@"%0.1f MB",fCacheSize];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:_strCacheSize forKey:kCacheSize];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            SNDebugLog(@"INFO: FINISH Geting size at %@.......", [NSDate date]);
            
            [self updateCacheSizeLabelInMainThread];
        }
        else {
            SNDebugLog(@"use old cache size, will calculate cache size every 5 min.");
            [self updateCacheSizeLabelInMainThread];
        }
        
        //NSString *_tempCacheSize = [[NSUserDefaults standardUserDefaults] objectForKey:kCacheSize];
        //SNDebugLog(@"INFO: cacheSizeUpdateDate is %@, bNeedUpdateCacheSize is %d, cache size is %@", cacheSizeUpdateDate, bNeedUpdateCacheSize, _tempCacheSize);
    });
    
}

-(NSString *)getCachesPath{
    // 获取Caches目录路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    //NSString *filePath = [cachesDir stringByAppendingPathComponent:@"myCache"];
    return cachesDir;
}

-(long long)fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(CGFloat)getCacheSizeAtPath:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];//从前向后枚举器
    NSString* fileName;
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        SNDebugLog(@"fileName ==== %@",fileName);
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        SNDebugLog(@"fileAbsolutePath ==== %@",fileAbsolutePath);
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    SNDebugLog(@"folderSize ==== %lld",folderSize);
    return folderSize/(1024.0*1024.0);
}

- (void)saveCacheSizeBlockUI {
    float fCacheSize = [[SNDBManager currentDataBase] getTTCacheSize];
    NSString *_strCacheSize = @"0.0 MB";
    if (fCacheSize >= 0.1) {
        _strCacheSize = [NSString stringWithFormat:@"%0.1f MB",fCacheSize];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_strCacheSize forKey:kCacheSize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)updateCacheSizeLabelInMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView  reloadData];
    });
}

- (void)kickLogout
{
//    SNConfirmFloatView* confrimView = [[SNConfirmFloatView alloc] init];
//    confrimView.message = @"确认要退出当前账号吗";
//    [confrimView setConfirmText:@"退出登录" andBlock:^{
//        [self submitLogout];
//    }];
//    if (![SNBaseFloatView isFloatViewShowed]) {
//        [confrimView show];
//    }
    
    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:@"确认要退出当前账号吗" cancelButtonTitle:@"取消" otherButtonTitle:@"退出登录"];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        
    } otherButtonHandler:^{
        [self submitLogout];
    }];

}

-(void)submitLogout
{
//    if(!_accountService)
//    {
//        SNUserAccountService* service = [[SNUserAccountService alloc] init];
//        service.userDelegate = self;
//        self.accountService = service;
//    }
//    [self.accountService requestLogout];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"正在退出，请稍候" toUrl:nil mode:SNCenterToastModeOnlyText];
    
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
                [self notifyUserAccountServerFailure:SNUserAccountTypeLogout withMsg:msg];
            }
        }
    }];
}
#pragma mark - public
- (void)refreshTableViewDataWhenAppBecomeActive {
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //升级检测
    if ([alertView.title isEqualToString:NSLocalizedString(@"Upgrade", @"")]) {
        if (buttonIndex == 1) {
            
            if (_upgradeInfo != nil && [_upgradeInfo.downloadUrl length] != 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_upgradeInfo.downloadUrl]];
                if (_upgradeInfo.upgradeType == 3) {
                    exit(0);
                }
            }
            else {
                SNDebugLog(@"sohunewsAppDelegate - remindUserAboutUpgrade: Invalid upgradeInfo");
            }
        }
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(actionSheet.tag == 300)//注销
    {
        if(buttonIndex == 0)
        {
            [self submitLogout];
        }
    }
    else//清除缓存
    {
        if (buttonIndex == 0) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Please wait",@"") toUrl:nil mode:SNCenterToastModeOnlyText];
            [self performSelector:@selector(clearCache) withObject:nil afterDelay:0.5];
            //[self.view setUserInteractionEnabled:NO];
        }
        self.actionSheet = nil;
    }

}

#pragma clang diagnostic pop

#pragma mark - UITableViewDatasource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = (NSArray *)[_sectionsArray objectAtIndex:section];
    return _sectionsArray.count > 0 ? [array count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // cell data info
    NSArray *rows = [_sectionsArray objectAtIndex:[indexPath section]];
    NSDictionary *rowDic = [rows objectAtIndex:[indexPath row]];
    NSString *cellClass = [rowDic stringValueForKey:kMoreViewCellDicKeyClass defaultValue:@""];
    
    SNSettingBaseCell *cell = nil;
    
    if ([cellClass length] == 0) {
        cellClass = NSStringFromClass([SNSettingBaseCell class]);
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellClass];
    if (nil == cell) {
        cell = [(SNSettingBaseCell *)[NSClassFromString(cellClass) alloc] initWithStyle:UITableViewCellStyleDefault
                                                                          reuseIdentifier:cellClass];
        
        if (cell == nil) {
            SNDebugLog(@"Error cellClass name is invalid!");
        }
        
        cell.viewController = self;
        //5.9.3 wangchuanwen update
        //cell.backgroundColor = [UIColor  clearColor];
        //cell.contentView.backgroundColor = [UIColor clearColor];
        //换成abTest背景色 5.9.3 by wangchuanwen
        cell.contentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        else
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    cell.cellData = rowDic;
    
    if ([indexPath row] == 0) {
        cell.cellBgType = SNMoreCellBgTypeTop;
    }
    else if ([indexPath row] == rows.count - 1) {
        cell.cellBgType = SNMoreCellBgTypeBottom;
    }
    else {
        cell.cellBgType = SNMoreCellBgTypeMiddle;
    }
    
    if (rows.count == 1) {
        cell.cellBgType = SNMoreCellBgTypeSingle;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SNSettingBaseCell *cell = (SNSettingBaseCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *cellDic = cell.cellData;
    NSString *selectorStr = [cellDic stringValueForKey:kMoreViewCellDicKeySelector defaultValue:@""];
    SEL selector = NSSelectorFromString(selectorStr);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([selectorStr length] > 0 && selector && [self respondsToSelector:selector]) {
        NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
        if ([sig numberOfArguments] == 2) {
            //TODO: 测试代码：跳到用户评星
//            [SKStoreReviewController requestReview];
//            return;
            [self performSelector:selector];
        }
        else if([sig numberOfArguments] == 3) {
            //TODO: 测试代码：跳到用户评论
//            SKStoreProductViewController *store = [[SKStoreProductViewController alloc] init];
//            store.delegate = self;
//            [store loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : @"436957087",@"action":@"write-review"} completionBlock:^(BOOL result, NSError * _Nullable error) {
//                if(error){
//                    NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
//                }else{
//                    //模态弹出AppStore应用界面
//                    [self presentViewController:store animated:YES completion:^{}];
//                }
//            }];
//            return;
            [self performSelector:selector withObject:cell];
        }
#if DEBUG_MODE
        else {
            // 不知道你要调用什么
            SNDebugLog(@"%@-->%@, 不知道你要调用什么",
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd));
        }
#endif
    }
#pragma clang diagnostic pop
}

//TODO: 测试代码：跳到用户评论
//- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
//    viewController.delegate = nil;
//    [viewController dismissViewControllerAnimated:YES completion:nil];
//}


#pragma -mark SNUserAccountDelegate
-(void)notifyUserLogoutSuccess
{
//    [SNNotificationCenter hideLoading];
    [[SNToast shareInstance] hideToast];
    [self onBack:nil];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_logout_success",@"") toUrl:nil mode:SNCenterToastModeSuccess];
}

-(void)notifyUserAccountServerFailure:(NSInteger)aType withMsg:(NSString *)aMsg
{
//    [SNNotificationCenter hideLoading];
    [[SNToast shareInstance] hideToast];
    [SNNotificationCenter showExclamation:aMsg];
}

-(void)notifyUserAccountNetworkFailure:(NSInteger)aType withError:(NSError *)aError
{
//    [SNNotificationCenter hideLoading];
    [[SNToast shareInstance] hideToast];
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}

- (void)articleFontSizeSet:(NSNotification *)notification {
    [self updateSettingData];
    [_tableView reloadData];
    
    [self calculateCacheSizeInNewThreadIfNeeded];
}

@end
