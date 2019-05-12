//
//  SNSelfCenterViewController.m
//  sohunews
//
//  Created by yangln on 14-9-23.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSelfCenterViewController.h"
#import "SNUserinfo.h"
#import "SNTimelineCircleModel.h"
#import "SNTimelineTrendCell.h"
#import "SNCommentConfigs.h"
#import "SNBubbleBadgeObject.h"
#import "SNDBManager.h"
#import "SNDataBase_Notification.h"
#import "SNTimelinePostService.h"
#import "SNCheckManager.h"
#import "SNSelfCenterMediaTableViewCell.h"
#import "SNUserinfoMediaObject.h"
#import "SNBubbleBadgeService.h"
#import "SNH5WebController.h"
#import "SNLabel.h"
#import "SNUserCenterViewController.h"
#import "SNNotificationCenter.h"
#import "Toast+UIView.h"
#import "SNUserManager.h"
#import "SNUserConsts.h"
#import "SNUserCenterEditViewContronller.h"

#import "SNSelfCenterTableViewCell.h"
#import "SNSelfCenterSearchCell.h"

#import <CoreLocation/CLLocationManager.h>
#import "SNAppConfigManager.h"
//#import "SNLoginActionSheetFloatView.h"
#import "SNGuideRegisterManager.h"

#define kShowHeadToastkey @"snshowHeadToast"
#define kShowMessageGuideKey @"snShowMessageGuideKey"
#define kShowActionHighlighgtKey @"snShowActionHighlighgtKey"
#define kSNSelfCenterActionHighLight     -1
#define kSNSelfCenterActionRmHighLight   0

@interface SNSelfCenterViewController () {
    UIView *_tableHeaderView;
    UIView *_unloginView;
    
    BOOL _isLoginFromTimeline;
    BOOL _hasOffline;
    
    UIView *_maskViewForTableHeaderView;
    
}

@property (nonatomic, strong)NSArray *selfCImageArray;
@property (nonatomic, strong)NSArray *selfCTitileArray;
@property (nonatomic, strong)NSArray *selfCTagArray;
@property (nonatomic, strong)NSArray *selfAImageArray;
@property (nonatomic, strong)NSArray *selfATitileArray;
@property (nonatomic, strong)NSArray *selfATagArray;

@property(nonatomic, strong) SNTimelineCircleModel *circleModel;
@property(nonatomic, copy)   NSString *actionAlert;

@end

@implementation SNSelfCenterViewController

-(id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNavigatorURL:URL query:query];
    if(self)
    {
        self.circleModel = [SNTimelineCircleModel modelForCurrentUser];
        self.circleModel.delegate = self;
        _isShowNetWork = NO;
        _hasOffline = NO;

        [SNNotificationManager addObserver:self selector:@selector(onUserLogout:) name:kUserDidLogoutNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(onUserLogin:) name:kUserDidLoginNotification object:nil];
        
        [SNStarGuideService shareInstance].delegate = self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTableHeaderView];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selfCImageArray = [[NSArray alloc] initWithObjects:@"icopersonal_journal_v5.png", @"icopersonal_video_v5.png", @"icopersonal_collect_v5.png", @"icopersonal_news_v5.png", nil];
    _selfCTitileArray = [[NSArray alloc] initWithObjects:@"离线搜狐号", @"离线视频", @"收藏", @"消息", nil];
    _selfCTagArray = [[NSArray alloc] initWithObjects:@"1003", @"1004", @"1005", @"1006", nil];
    
    _selfAImageArray = [[NSArray alloc] initWithObjects:@"icopersonal_activity_v5.png", @"icopersonal_setting_v5.png", nil];
    _selfATitileArray = [[NSArray alloc] initWithObjects:@"活动", @"设置", nil];
    _selfATagArray = [[NSArray alloc] initWithObjects:@"1007", @"1009", nil];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
    [self createTableHeaderView];
    [self createTableView];
    _tableView.frame = CGRectMake(0, kSNSelfCenterTableViewHeaderHeight, kAppScreenWidth, kAppScreenHeight-kSystemBarHeight-kToolbarViewTop-kSNSelfCenterTableViewHeaderHeight);
//    _tableView.tableHeaderView = _tableHeaderView;
    [self.view addSubview:_tableHeaderView];
    [self addToolbar];
}

- (void)createTableHeaderView {
    if(_tableHeaderView)
        return;
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSNSelfCenterTableViewHeaderHeight)];

    UIImageView *tableHeaderBackground = [[UIImageView alloc] initWithFrame:_tableHeaderView.frame];
    tableHeaderBackground.image = [UIImage imageNamed:@"bgpersonal_bg_v5.png"];
    [_tableHeaderView addSubview:tableHeaderBackground];
    tableHeaderBackground.tag = kTableHeaderBackgroundImageTag;
    
    _maskViewForTableHeaderView = [SNUtility addMaskForImageViewWithRadius:0 width:kAppScreenWidth height:kSNSelfCenterTableViewHeaderHeight];
    [_tableHeaderView addSubview:_maskViewForTableHeaderView];
    
    if([SNUserinfoEx isLogin])
    {
        [self createBaseInfoView];
        [_tableHeaderView addSubview:_baseInfoView];
    }
    else
    { 
        [self createUnloginView];
        [_tableHeaderView addSubview:_unloginView];
    }
}

- (void)createUnloginView {
    if(_unloginView)
        return;
    _unloginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSNSelfCenterTableViewHeaderHeight)];
    _unloginView.backgroundColor = [UIColor clearColor];
    
    UIView* tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSNSelfCenterTableViewHeaderHeight)];
    tapView.backgroundColor = [UIColor clearColor];
    tapView.userInteractionEnabled = YES;
    [_unloginView addSubview:tapView];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onclickLogin)];
    [tapView addGestureRecognizer:tapGesture];
    
    UIImage *defaultImage = [UIImage themeImageNamed:@"bgseeme_defaultavatar_v5.png"];
    
    CGFloat startx = kSNSelfCenterUnloginHeadImageOriginX;
    CGFloat starty = kSNSelfCenterUnloginHeadImageOriginY;
    CGRect baseRect = CGRectMake(startx, starty, defaultImage.size.width, defaultImage.size.height);
    SNWebImageView *imageView = [[SNWebImageView alloc] initWithFrame:baseRect];
    imageView.tag = kUserCenterHeadViewTag;
    imageView.contentMode= UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = NO;
    imageView.layer.masksToBounds   = YES;
    imageView.defaultImage = defaultImage;
    [_unloginView addSubview:imageView];
    
    startx = imageView.right+14;

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = [UIColor clearColor];
    [loginButton setTitle:@"立即登录" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [loginButton sizeToFit];
    loginButton.center = imageView.center;
    loginButton.origin = CGPointMake(startx, loginButton.origin.y-8.5);
    loginButton.tag = kUserCenterUnloginNameTag;
    [loginButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(onclickLogin) forControlEvents:UIControlEventTouchUpInside];
    [_unloginView addSubview:loginButton];
    
    starty = loginButton.bottom-8;
    if ([[UIDevice currentDevice].systemVersion floatValue]<7.0) {
        starty += 10.5;
    }
    UIButton *moreButtonLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButtonLabel.backgroundColor = [UIColor clearColor];
    moreButtonLabel.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    [moreButtonLabel setTitle:@"查看更多精彩内容" forState:UIControlStateNormal];
    moreButtonLabel.tag = kUserCenterUnloginTextTag;
    [moreButtonLabel sizeToFit];
    moreButtonLabel.origin = CGPointMake(startx, starty);
    [moreButtonLabel setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    [moreButtonLabel addTarget:self action:@selector(onclickLogin) forControlEvents:UIControlEventTouchUpInside];
    [_unloginView addSubview:moreButtonLabel];
 }

#pragma -mark private
-(void)onclickLogin
{
    _isLoginFromTimeline = NO;
    [SNGuideRegisterManager login:nil];
    [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
}

-(void)onClickHead
{
    if([SNUserManager isLogin])
    {
        SNCircleUserCenterEditViewContronller* editViewController = [[SNCircleUserCenterEditViewContronller alloc] initWithModel:_model];
        [[TTNavigator navigator].topViewController.flipboardNavigationController pushViewController:editViewController animated:YES];
        // 4.0.1 cc统计
        SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:profile_user_edit link2:nil];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
}

#pragma mark notification

- (void)onUserLogout:(NSNotification*)notification
{
    [[SNBubbleNumberManager shareInstance] resetAll];
    [_tableView reloadData];
}

- (void)onUserLogin:(NSNotification*)notification
{
    [self updateTableHeaderView];
    self.circleModel = [SNTimelineCircleModel modelForCurrentUser];
    self.circleModel.delegate = self;
    [_tableView reloadData];
    if(_isLoginFromTimeline) {
        [[SNStarGuideService shareInstance] followAllStar];
    }
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)) {
        _tableView.contentOffset = CGPointMake(0, 0);
    }
}

-(void)updateTheme:(NSNotification *)notifiction
{
    [super updateTheme:notifiction];
    [self updateUnloginView];
    [_tableView reloadData];
}

#pragma mark- SNNavigationController delegate

- (void)popFromControllerClass:(Class)class
{
    if ([class isSubclassOfClass:SNH5WebController.class]) {
        [[SNBubbleBadgeService shareInstance] requestNewBadge];
    }
    else if([class isSubclassOfClass:SNUserCenterViewController.class])
    {
        [self updateTableHeaderView];
    }
}

#pragma mark update
-(void)updateTableHeaderView
{
    if(_tableHeaderView == nil)
        return;
    if([SNUserManager isLogin])
    {
        _model.usrinfo = [SNUserinfoEx userinfoEx];
        if(_baseInfoView == nil)
        {
            [self createBaseInfoView];
            [_tableHeaderView addSubview:_baseInfoView];
        }
        [self updateBaseInfoView];
        
        if(_unloginView)
        {
            [_unloginView removeFromSuperview];
             //(_unloginView);
        }
    }
    else
    {
        if(_unloginView == nil)
        {
            [self createUnloginView];
            [_tableHeaderView addSubview:_unloginView];
        }
        [self updateUnloginView];
        if(_baseInfoView)
        {
            [_baseInfoView removeFromSuperview];
             //(_baseInfoView);
        }
    }
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        _maskViewForTableHeaderView.alpha = 0.7;
    }
    else {
        _maskViewForTableHeaderView.alpha = 0;
    }
    UIImageView *tableHeaderBackground = (UIImageView *)[_tableHeaderView viewWithTag:kTableHeaderBackgroundImageTag];
    tableHeaderBackground.image = [UIImage imageNamed:@"bgpersonal_bg_v5.png"];
}

-(void)updateUnloginView
{
    if(!_unloginView)
        return;
//    _tableHeaderView.alpha = themeImageAlphaValue();
    SNWebImageView *imageView = (SNWebImageView*)[_unloginView viewWithTag:kUserCenterHeadViewTag];
    imageView.image = [UIImage imageNamed:@"bgseeme_defaultavatar_v5.png"];
    
    UIButton *loginButton = (UIButton *)[_unloginView viewWithTag:kUserCenterUnloginNameTag];
    if(loginButton)
        [loginButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];;
    
    UIButton *moreButtonLabel = (UIButton *)[_unloginView viewWithTag:kUserCenterUnloginTextTag];
    [moreButtonLabel setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    
    UIImageView* arrowView = (UIImageView*)[_unloginView viewWithTag:kUserCenterArrowViewTag];
    if(arrowView)
        arrowView.alpha = 1.0;
    
}

#pragma -mark UITablewViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if([SNUserManager isLogin])
        {
            SNUserinfoEx* userinfoEx = [SNUserinfoEx userinfoEx];
            NSArray* array = [userinfoEx getPersonMediaObjects];
            if(array.count > 0 && !userinfoEx.isShowManage)
                return [array count] + 1;
            else
                return 1;
        }
        else
            return 1;
    }
    else if (section == 1)
        return [_selfCTitileArray count];
    else if (section == 2)
        return [_selfATitileArray count];
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNUserinfoEx* userinfoEx = [SNUserinfoEx userinfoEx];
    NSArray* array = [userinfoEx getPersonMediaObjects];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (![SNUserManager isLogin] || !(array.count > 0 && !userinfoEx.isShowManage)) {
            return kSNSelfCenterTableViewSearchCellHeight - 11;
        }
        else {
        return kSNSelfCenterTableViewSearchCellHeight;
        }
    }
    else if ([SNUserManager isLogin] && indexPath.section == 0 ) {
//        SNUserinfoEx* userinfoEx = [SNUserinfoEx userinfoEx];
//        NSArray* array = [userinfoEx getPersonMediaObjects];
        if(array.count > 0 && !userinfoEx.isShowManage)
            return kSelfCenterMediaTableViewCellHeight;
        else
            return 0;
    }
    else if (indexPath.row == 0 || (indexPath.section == 1 && indexPath.row == 3)) {
        return kSNSelfCenterTableViewCellHeight + 11;
    }
    else {
        return kSNSelfCenterTableViewCellHeight;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = nil;
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    if (section == 0) {
        if (row == 0) {
            static NSString *cellIndentifier = @"searchCellIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[SNSelfCenterSearchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:cellIndentifier];
            }
            [(SNSelfCenterSearchCell *)cell setCellItem];
        }
        else {
            if ([SNUserManager isLogin]) {
                SNUserinfoEx* userinfoEx = [SNUserinfoEx userinfoEx];
                NSArray* array = [userinfoEx getPersonMediaObjects];
                if (array.count > 0 && !userinfoEx.isShowManage && indexPath.section == 0) {
                    static NSString* cellIndentifier = @"mymediatableviewcell";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                    if(!cell) {
                        cell = [[SNSelfCenterMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                              reuseIdentifier:cellIndentifier];
                    }
                    SNUserinfoMediaObject* mediaObject = [array objectAtIndex:row-1];
                    [(SNSelfCenterMediaTableViewCell *)cell setMyMediaObject:mediaObject];
                    if([array count] == row)
                        [(SNSelfCenterMediaTableViewCell *)cell setCellItemSeperateLine];
                }
            }
        }
    }
    else {
        static NSString *cellIndentifier = @"normalCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[SNSelfCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:cellIndentifier];
        }
        if (section == 1) {
            [(SNSelfCenterTableViewCell *)cell setCellItem:[_selfCImageArray objectAtIndex:row] text:[_selfCTitileArray objectAtIndex:row] tag:[[_selfCTagArray objectAtIndex:row] intValue]];
            if (row == 3)
                [(SNSelfCenterTableViewCell *)cell setCellItemSeperateLine:row];
        } else if (section == 2) {
            [(SNSelfCenterTableViewCell *)cell setCellItem:[_selfAImageArray objectAtIndex:row] text:[_selfATitileArray objectAtIndex:row] tag:[[_selfATagArray objectAtIndex:row] intValue]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {//搜索
            [self onClickSearch];
        }
        else {//自媒体
            [self onClickSelfMedia:indexPath.row];
        }
    }
    if(indexPath.section == 1) {
        if(indexPath.row == 0) {//已离线媒体
            [self onClickOfflineMedia];
        }
        else if (indexPath.row == 1) {//离线视频
            [self onClickOfflineVideo];
            SNSelfCenterTableViewCell *videoCell = (SNSelfCenterTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [videoCell reSetBubble:indexPath];
        }
        else if (indexPath.row == 2) {//收藏
            [self onClickCollection];
        }
        else if (indexPath.row == 3) {//消息
            [self onClickMessage];
            SNSelfCenterTableViewCell *messageCell = (SNSelfCenterTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [messageCell reSetBubble:indexPath];
        }
    }
    else if (indexPath.section == 2) {
        if(indexPath.row == 0) {//活动
            [self onClickActivity];
            SNSelfCenterTableViewCell *activityCell = (SNSelfCenterTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [activityCell reSetBubble:indexPath];
        }
        
    }
}

- (void)onClickSearch {
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://search"] applyAnimated:YES] applyQuery:nil];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)onClickSelfMedia:(NSInteger)row {
    SNUserinfoEx* userinfoEx = [SNUserinfoEx userinfoEx];
    NSArray* array = [userinfoEx getPersonMediaObjects];
    if(array.count > 0 && !userinfoEx.isShowManage)
    {
        //自媒体首页
        SNUserinfoMediaObject* object = [array objectAtIndex:row-1];
        [SNUtility openProtocolUrl:object.link];
    }
}

- (void)onClickOfflineMedia {
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:SN_String("tt://globalDownloader")] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

- (void)onClickMessage {
    if(![SNUserManager isLogin]) {
        _isLoginFromTimeline = NO;
//        [SNGuideRegisterManager myMessage];
        //5.1改为登录拦截浮层
//        SNLoginActionSheetFloatView *floatView = [[SNLoginActionSheetFloatView alloc] init];
//        if (![SNBaseFloatView isFloatViewShowed]) {
//            [floatView show];
//        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInteger:SNGuideRegisterTypeMessage], kRegisterInfoKeyGuideType,
                             nil];
        [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:dic];
    }
    else
    {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], @"showNotification", nil];
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://myMessage"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:_urlAction];
        
        [self.tableView reloadData];
    }
}
- (void)onClickCollection
{
    if(![SNUserManager isLogin])
    {
        _isLoginFromTimeline = NO;
//        [SNGuideRegisterManager myFav];
        //5.1修改为登录拦截浮层
//        SNLoginActionSheetFloatView *floatView = [[SNLoginActionSheetFloatView alloc] init];
//        if (![SNBaseFloatView isFloatViewShowed]) {
//            [floatView show];
//        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"收藏",kRegisterInfoKeyTitle,
                             NSLocalizedString(@"user_info_guide_register_tip", nil), kRegisterInfoKeyText,
                             @"收藏", kRegisterInfoKeyName,
                             [NSNumber numberWithInteger:SNGuideRegisterTypeFav], kRegisterInfoKeyGuideType,
                             nil];
        [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:dic];
    }
    else
    {
        TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://myFavourites"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
}
- (void)onClickOfflineVideo
{
    if ([[SNCheckManager sharedInstance] supportVideoDownload])
    {
        TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://videoDownloadViewController"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
    else {
        TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://globalDownloader"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }
    // cc统计
    SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
    SNUserTrack *toPage = [SNUserTrack trackWithPage:more_offline link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

-(void)onClickApplication
{
    NSString *urlStr = kUrlMoreApp;
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        urlStr = [urlStr stringByAppendingString:@"&mode=1"];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"应用推荐", @"title", urlStr, @"url", nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://m_moreApp"] applyAnimated:YES] applyQuery:dict];
    [[TTNavigator navigator] openURLAction:_urlAction];
    
    // cc统计
    SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
    SNUserTrack *toPage = [SNUserTrack trackWithPage:more_app link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
}
-(void)onClickSetting
{
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://setting"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
    
    // cc统计
    SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
    SNUserTrack *toPage = [SNUserTrack trackWithPage:more_setting link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
}
-(void)onClickActivity
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:kUrlActionList, @"address",kActionName_ActivePage,kActionType,nil];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5WebBrowser"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:urlAction];
    
    // cc统计
    SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
    SNUserTrack *toPage = [SNUserTrack trackWithPage:profile_user_event link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

#pragma mark - Overide
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    //Override super class's action
}

- (SNCCPVPage)currentPage {
    return tab_me;
}

- (void)dealloc {
     //(_tableHeaderView);
     //(_unloginView);
    
     //(_selfCImageArray);
     //(_selfCTitileArray);
     //(_selfCTagArray);
     //(_selfAImageArray);
     //(_selfATitileArray);
     //(_selfATagArray);
    
}

@end
