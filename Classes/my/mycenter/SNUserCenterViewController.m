//
//  SNUserCenterViewController.m
//  sohunews
//
//  Created by weibin cheng on 13-12-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNUserCenterViewController.h"
#import "SNUserCenterEditViewContronller.h"
#import "SNOauthWebViewController.h"
#import "SNGuideRegisterViewController.h"
#import "SNLoginRegisterViewController.h"
#import "SNTimeLineTrendModel.h"
#import "SNTimelineTrendCell.h"
#import "SNTimelinePostService.h"
#import "SNStatusBarMessageCenter.h"
#import "SNUserinfoMediaObject.h"
#import "SNUserConsts.h"
#import "SNUserManager.h"
#import "SNSoHuAccountLoginRegisterViewController.h"
#import "SNNewsLogout.h"


@interface SNUserCenterViewController ()
{
    SNFollowUserService* _followUserService;
    NSString* _followPid; //关注pid，用于游客浏览时引导登陆
}
@property(nonatomic, strong)    SNUserAccountService* accountService;
@property(nonatomic, strong)    SNTimeLineTrendModel *trendModel;
@property(nonatomic, strong)    NSString* followPid;
@property(nonatomic, strong)    NSString *trendActId;
@property(nonatomic, strong)    NSString *trendPid;
@property(nonatomic, assign)    int trendCellIndex;

@end

@implementation SNUserCenterViewController
@synthesize accountService = _accountService;
@synthesize followPid = _followPid;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNavigatorURL:URL query:query];
    if(self)
    {
        self.pid = [query objectForKey:@"pid"];
        
        _followUserService = [[SNFollowUserService alloc] init];
        _followUserService.delegate = self;
        
        self.trendModel = [SNTimeLineTrendModel modelForUserWithPid:self.pid];
        //self.trendModel = [SNTimeLineTrendModel modelForUserWithPid:[SNUserinfoEx userinfoEx]._pid];
        self.trendModel.delegate = self;
        
        if (query) {
            self.queryDic = [NSMutableDictionary dictionaryWithDictionary:query];
        }
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(onGuideRegisterSuccess:)
                                                     name:kGuideRegisterSuccessNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(tlSendCommentSuc:)
                                                     name:kTLTrendSendCommentSucNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(tlCellDelete:)
                                                     name:kTLTrendCellDeleteNotification
                                                   object:nil];
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return more_user;
}

- (NSString *)currentOpenLink2Url {
    return [self.queryDic stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    _trendModel.delegate = nil;
     //(_trendModel);
     //(_followUserService);
     //(_accountService);
     //(_followPid);
}
- (void)loadView
{
    [super loadView];
    [self createBaseInfoView];
    [self createTableView];
    [self createToolbar];
    [self addDragRefreshHeader];
    _tableView.tableHeaderView = _baseInfoView;
}

#pragma -mark layout
-(void)createToolbar
{
    [self addToolbar];
    /*
    if(self.pid.length==0 || [self.pid isEqualToString:[SNUserinfoEx userinfoEx]._pid])
    {
        //更多按钮
        UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(270.5, 0, 42, 42)];
        rightButton.backgroundColor = [UIColor clearColor];
        [rightButton setBackgroundImage:[UIImage themeImageNamed:@"tb_more.png"] forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage themeImageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
        [rightButton addTarget:self action:@selector(onRightButton) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView setRightButton:rightButton];
        [rightButton release];
    }*/
}

-(void)updateOperationButton
{
    UIButton* button = (UIButton*)[_baseInfoView viewWithTag:kUserCenterButtonTag];
    NSString* relation = (NSString*)_model.usrinfo.relation;
    button.enabled = YES;
    if(relation!=nil && [relation intValue]== SNCircleFollowing) //已关注 取消关注按钮
    {
        NSInteger width = 70;
        button.frame = CGRectMake(kAppScreenWidth-width-10, 52, width, 35);
        [button setTitle:nil forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"circle_cancel.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"circle_cancel_hl.png"] forState:UIControlStateHighlighted];
        [button removeTarget:self action:@selector(submitFollowing:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(submitUnFollowing:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(relation!=nil && [relation intValue]==SNCircleSelf) //自己 编辑按钮
    {
//        NSInteger width = 65;
//        button.frame = CGRectMake(kAppScreenWidth-width-10, 52, width, 35);
//        UIImage* followBg = [UIImage imageNamed:@"userinfo_follow_button.png"];
//        UIImage* followBgHl = [UIImage imageNamed:@"userinfo_follow_button_hl.png"];
//        [button setBackgroundImage:followBg forState:UIControlStateNormal];
//        [button setBackgroundImage:followBgHl forState:UIControlStateHighlighted];
//        [button addTarget:self action:@selector(submitEdit) forControlEvents:UIControlEventTouchUpInside];
//        button.titleLabel.font = [UIFont systemFontOfSize:14];
//        [button setTitle:@"账号管理" forState:UIControlStateNormal];
//        UIColor* labelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoPlaceColor]];
//        [button setTitleColor:labelColor forState:UIControlStateNormal];
    }
    else if(relation!=nil) //未关注 关注按钮
    {
        UIImage* followBg = [UIImage imageNamed:@"userinfo_follow_button.png"];
        UIImage* followBgHl = [UIImage imageNamed:@"userinfo_follow_button_hl.png"];
        NSInteger width = 45;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.frame = CGRectMake(kAppScreenWidth-width-10, 52, width, 35);
        
        [button setTitle:@"关注" forState:UIControlStateNormal];
        [button setBackgroundImage:followBg forState:UIControlStateNormal];
        [button setBackgroundImage:followBgHl forState:UIControlStateHighlighted];
        [button removeTarget:self action:@selector(submitUnFollowing:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(submitFollowing:) forControlEvents:UIControlEventTouchUpInside];
    }
}
#pragma -mark base
-(void)updateTheme:(NSNotification *)notifiction
{
    [super updateTheme:notifiction];
    [self updateOperationButton];
//    if(self.pid.length==0 || [self.pid isEqualToString:[SNUserinfoEx userinfoEx]._pid])
//    {
//        //更多按钮
//        UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(270.5, 0, 42, 42)];
//        rightButton.backgroundColor = [UIColor clearColor];
//        [rightButton setBackgroundImage:[UIImage themeImageNamed:@"tb_more.png"] forState:UIControlStateNormal];
//        [rightButton setBackgroundImage:[UIImage themeImageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
//        [rightButton addTarget:self action:@selector(onRightButton) forControlEvents:UIControlEventTouchUpInside];
//        [_toolbarView setRightButton:rightButton];
//        [rightButton release];
//    }
}

- (BOOL)isSupportPushBack
{
    NSArray *viewControllers = [TTNavigator navigator].topViewController.flipboardNavigationController.viewControllers;
    if(viewControllers.count > 1)
    {
        UIViewController* vc = [viewControllers objectAtIndex:viewControllers.count-2];
        if([vc isKindOfClass:[SNOauthWebViewController class]])
        {
            return NO;
        }
        else if([vc isKindOfClass:[SNLoginRegisterViewController class]] || [vc isKindOfClass:[SNSoHuAccountLoginRegisterViewController class]])
        {
            return NO;
        }
        else if([vc isKindOfClass:[SNGuideRegisterViewController class]])
        {
            return NO;
        }
    }
    return YES;
}

#pragma -mark private
-(void)onClickHead
{
    
}

-(void)onClickFollowing
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.pid,@"pid", nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://followingList"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

-(void)onClickFollowed
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.pid,@"pid", nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://followedList"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

-(void)submitUnFollowing:(id)sender
{
    if([SNUserManager isLogin])
    {
        [_followUserService cancelFollowUserWithFpid:_pid];
        UIButton* button = sender;
        if(button)
        {
            button.enabled = NO;
        }
    }
    else
    {
        [SNGuideRegisterManager showGuideForAttention:_model.usrinfo.headImageUrl userName:_model.usrinfo.nickName];
    }
}

-(void)submitFollowing:(id)sender
{
    if([SNUserManager isLogin])
    {
        [_followUserService followUserWithFpid:_pid];
        UIButton* button = sender;
        if(button)
        {
            button.enabled = NO;
        }
    }
    else
    {
        [SNGuideRegisterManager showGuideForAttention:_model.usrinfo.headImageUrl userName:_model.usrinfo.nickName];
        [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_READ_CIRCLE referId:_pid referAct:SNReferActFollow];
        _followPid = _pid;
    }
}

-(void)submitEdit
{
    SNCircleUserCenterEditViewContronller* editViewController = [[SNCircleUserCenterEditViewContronller alloc] initWithModel:_model];
    [[TTNavigator navigator].topViewController.flipboardNavigationController pushViewController:editViewController animated:YES];
    // 4.0.1 cc统计
    SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
    SNUserTrack *toPage = [SNUserTrack trackWithPage:profile_user_edit link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

-(void)submitSharingSetting
{
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:SN_String("tt://shareSetting")] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
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
    [SNNotificationCenter showLoading:@"正在注销"];
    
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

-(void)refresh
{
    [_model circle_userinfoRequest:self.pid loginFrom:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_trendModel timelineRefresh];
    });
    [super refresh];
}

/*
-(void)onRightButton
{
    if(_pid.length==0 || [_model.usrinfo isSelfUser])
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                             destructiveButtonTitle:nil otherButtonTitles: @"分享设置", @"注销", nil];
        sheet.destructiveButtonIndex = 1;
        sheet.tag = kUserCenterMoreActionTag;
        [sheet showInView:self.tabBarController.tabBar];
        [sheet release];
    }
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == kUserCenterMoreActionTag)
    {
            if(buttonIndex==0) //分享设置
                [self submitSharingSetting];
            else if(buttonIndex==1) //注销
                [self submitLogout];
    }
//    else if (actionSheet.tag == kUserCenterDeleteActionTag)
//    {
//        [self actionSheetDeleteTrend:buttonIndex];
//    }
}*/

-(void)onBack:(id)sender
{
    [[SNSoundManager sharedInstance] stopAmr];
    NSArray* viewControllers = (NSArray*)self.flipboardNavigationController.viewControllers;
    
    /*不使用SNGuideRegisterManager处理返回，这样会导致进入别的用户的个人中心返回直接返回到更多
     if ([SNGuideRegisterManager popGuideRegisterController:viewControllers popController:self])
     {
     return;
     }*/
    
    if(viewControllers.count > 1)
    {
        UIViewController* vc = [viewControllers objectAtIndex:viewControllers.count-2];
        if([vc isKindOfClass:[SNOauthWebViewController class]])
        {
            [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
            return;
        }
        else if([vc isKindOfClass:[SNLoginRegisterViewController class]])
        {
            [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
            return;
        }
        else if([vc isKindOfClass:[SNGuideRegisterViewController class]])
        {
            [self.flipboardNavigationController popToRootViewControllerAnimated:YES];
            return;
        }
    }
    //Default
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

-(void)onGuideRegisterSuccess:(NSNotification*)notification
{
    if(_followPid)
    {
        [_followUserService followUserWithFpid:_pid];
        _followPid = nil;
    }
}

#pragma -mark SNFollowUserServiceDelegate
-(void)followedUserSucceedWithType:(SNRequestType)type
{
    if(type==SNRequestTypeAddFollow)
    {
        _model.usrinfo.relation = [NSString stringWithFormat:@"%ld", (long)SNCircleFollowing];
        SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
        if(userinfo)
        {
            userinfo.followingCount = [NSString stringWithFormat:@"%d", [userinfo.followingCount intValue]+1];
            [userinfo saveUserinfoToUserDefault];
        }
    }
    else
    {
        _model.usrinfo.relation = [NSString stringWithFormat:@"%ld", (long)SNCircleUnFollow];
        SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
        if(userinfo)
        {
            userinfo.followingCount = [NSString stringWithFormat:@"%d", [userinfo.followingCount intValue]-1];
            [userinfo saveUserinfoToUserDefault];
        }
    }
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:2];
    [dic setObject:_model.usrinfo.relation forKey:@"relation"];
    [dic setObject:_model.usrinfo.pid forKey:@"pid"];
    [SNNotificationManager postNotificationName:kUserCenterFollowUpdateNotification object:nil userInfo:dic];
    [self updateOperationButton];
}

-(void)followedUserFailWithError:(NSError*)error requestType:(SNRequestType) type
{
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    [self updateOperationButton];
}

#pragma -mark UITablewViewDelegate
-(NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(_model.usrinfo.personMediaArray.count > 0 && section == 0 && ![SNUserinfoEx isSelfUser:self.pid])
    {
        return _model.usrinfo.personMediaArray.count;
    }
    else if(_trendModel.timelineObjects.count <= 0)
    {
        return 1;
    }
    else if(_trendModel.timelineObjects.count > 0)
    {
        return _trendModel.hasMore ? _trendModel.timelineObjects.count + 1 : _trendModel.timelineObjects.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_model.usrinfo.personMediaArray.count > 0 && indexPath.section == 0 && ![SNUserinfoEx isSelfUser:self.pid])
    {
        return kUserinfoMediaCellHeight;
    }
    else
    {
        if (_trendModel.timelineObjects.count <= 0) {
            return kAppScreenHeight - kUserinfoMediaCellHeight;
        }
        else if(_trendModel.timelineObjects.count > 0 &&
           [indexPath row] < _trendModel.timelineObjects.count) {
            SNTimelineTrendItem *obj = [_trendModel.timelineObjects objectAtIndex:[indexPath row]];
            return [SNTimelineTrendCell heightForTimelineTrendObj:obj];
        }
    }
    return kAppScreenHeight - kUserinfoMediaCellHeight;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray* mediaArray = [_model.usrinfo getPersonMediaObjects];
    if(mediaArray.count > 0 && indexPath.section==0 && ![SNUserinfoEx isSelfUser:self.pid])
    {
            static NSString* personMediaIndent = @"personMediaCell";
            SNUserinfoMediaCell *personMediaCell = [tableView dequeueReusableCellWithIdentifier:personMediaIndent];
            if(!personMediaCell)
            {
                personMediaCell = [[SNUserinfoMediaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:personMediaIndent];
                personMediaCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            SNUserinfoMediaObject* object = [mediaArray objectAtIndex:indexPath.row];
            if(object)
            {
                BOOL show = (indexPath.row == mediaArray.count-1) ? NO : YES;
                [personMediaCell setMediaObject:object showSeperateLine:show];
            }
            return personMediaCell;
    }
    else
    {
        if (_trendModel.timelineObjects.count <= 0) {
            if (!_dfCell) {
                _dfCell = [[SNCenterViewDefaultCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:@"centerViewDfCell_inentifier"];
            }
            _dfCell.eventDelegate = self;
            _dfCell.status = _trendModel.lastErrorCode;
            return _dfCell;
        }
        else if(_trendModel.timelineObjects.count > 0 &&
           [indexPath row] < _trendModel.timelineObjects.count)
        {
            SNTimelineTrendItem *trendItem = [_trendModel.timelineObjects objectAtIndex:[indexPath row]];
            Class itemCellClass = [SNTimelineTrendCell cellClassForItem:trendItem.trendType];
            NSString* trendCellIdentifier = NSStringFromClass(itemCellClass);
            SNTimelineTrendCell * trendCell = (SNTimelineTrendCell *)[tableView dequeueReusableCellWithIdentifier:trendCellIdentifier];
            if (!trendCell) {
                trendCell= [[itemCellClass alloc]initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:trendCellIdentifier];
            }
            
            trendCell.delegate = self;
            trendCell.indexPath = (int)[indexPath row];
            trendCell.canEnterCenter = NO;
            [trendCell setTrendObject:trendItem];
            
            return trendCell;
        } else if (_trendModel.hasMore) {
        }
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray* mediaArray = [_model.usrinfo getPersonMediaObjects];
    if(mediaArray.count > 0 && indexPath.section == 0 && ![SNUserinfoEx isSelfUser:self.pid])
    {
        SNUserinfoMediaObject* mediaObject = [mediaArray objectAtIndex:indexPath.row];
        if(mediaObject)
        {
            [SNUtility openProtocolUrl:mediaObject.link];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_model.usrinfo.personMediaArray.count > 0 && ![SNUserinfoEx isSelfUser:self.pid])
        return 2;
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TTApplicationFrame().size.width, 30)];
    view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    view.alpha = 0.8;
    
    
    UIImage *titleBgImage = [UIImage themeImageNamed:@"cell_section_bg.png"];
    UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.width, 30)];
    backView.layer.contents = (id)titleBgImage.CGImage;
    backView.layer.cornerRadius = 2;
    backView.layer.masksToBounds = YES;
    [view addSubview:backView];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRecommendSectionTitleColor]];
    label.textAlignment = NSTextAlignmentLeft;
    if(section == 0 && _model.usrinfo.personMediaArray.count > 0 && ![SNUserinfoEx isSelfUser:self.pid])
        label.text = @"媒体账号";
    else
        label.text = @"动态";
    [view addSubview:label];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

#pragma mark- scrollEvent
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    [self loadMoreTrendInfo:scrollView];
}

- (void)loadMoreTrendInfo:(UIScrollView *)scrollView {
    //上拉加载更多
    if (scrollView.contentOffset.y + scrollView.height + kToolbarViewHeight >
         scrollView.contentSize.height - 60 && !_isCommentLoading && _trendModel.hasMore &&
           scrollView.contentOffset.y - _lastOffsetY > 0) {
        if ([self checkNetworkIsEnableAndTell]) {
            [_trendModel timelineGetMore];
            _isCommentLoading = YES;
        }
    }
    _lastOffsetY = scrollView.contentOffset.y;
}

#pragma mark- delegateAction
- (void)timelineCellDelete:(NSDictionary *)dic
{
    int cellIndex = [dic intValueForKey:kDeleteCellKeyIndex defaultValue:0];
    [_trendModel.timelineObjects removeObjectAtIndex:cellIndex];
    [_tableView reloadData];
    
    SNTimelineTrendCell *dlCell = [dic objectForKey:kDeleteCellKeyCell];
    BOOL hasNext = cellIndex < _trendModel.timelineObjects.count;
    NSIndexPath *deleteCellIndexPath = [_tableView indexPathForCell:dlCell];
    if (deleteCellIndexPath && hasNext) {
        [_tableView scrollToRowAtIndexPath:deleteCellIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark- timelineModelDelegate
- (void)timelineModelDidStartLoad
{
    [self setMoreCellState:kRCMoreCellStateLoadingMore];
}

- (void)timelineModelDidFinishLoad
{
    _isCommentLoading = NO;
    if (_trendModel.timelineObjects.count > 0 && _dfCell) {
        [_dfCell showEmpty:NO];
    }
    if (!_trendModel.hasMore) {
//        [_moreCell setPromtLabelTextHide:YES];
//        [_moreCell setHasNoMore:NO];
//        [_moreCell showLoading:NO];
        [self setMoreCellState:kRCMoreCellStateEnd];
    }
    [_tableView reloadData];
}

- (void)timelineModelDidFailToLoadWithError:(NSError *)error
{
    _isCommentLoading = NO;
    switch (error.code) {
        case kSNCircleErrorCodeDisconnect:
        case kSNCircleErrorCodeTimeOut:
        {
            if (_trendModel.timelineObjects.count == 0 && _dfCell) {
                [_dfCell showError];
            }
            break;
        }
        case kSNCircleErrorCodeNoData:
        {
            if (_trendModel.timelineObjects.count == 0 && _dfCell) {
                [_dfCell hideLoading];
                [_dfCell showEmpty:YES];
            }
            break;
        }
        default:
            break;
    }
    [_tableView reloadData];
}

- (void)commentTableRefreshModel
{
    [self refresh];
}

#pragma -mark SNUserAccountDelegate
-(void)notifyUserLogoutSuccess
{
    [SNNotificationCenter hideLoading];
    [SNNotificationManager postNotificationName:kUserDidLogoutNotification object:nil];
    
    [self onBack:nil];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_logout_success",@"") toUrl:nil mode:SNCenterToastModeSuccess];
}

-(void)notifyUserAccountServerFailure:(NSInteger)aType withMsg:(NSString *)aMsg
{
    [SNNotificationCenter hideLoading];
    [SNNotificationCenter showExclamation:aMsg];
}

-(void)notifyUserAccountNetworkFailure:(NSInteger)aType withError:(NSError *)aError
{
    [SNNotificationCenter hideLoading];
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}

- (void)tlSendCommentSuc:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    [SNTimelineTrendItem SNTimelineTrendSendCmtSuc:_trendModel.timelineObjects info:dic];
    [_tableView reloadData];
}

- (void)tlCellDelete:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    int cellIndex = [dic intValueForKey:kDeleteCellKeyIndex defaultValue:0];
    SNTimelineTrendCell *dlCell = [dic objectForKey:kDeleteCellKeyCell];
    
    if (_trendModel.timelineObjects.count > 0 && cellIndex < _trendModel.timelineObjects.count) {
        [_trendModel.timelineObjects removeObjectAtIndex:cellIndex];
    }
    [_tableView reloadData];
    
    BOOL hasNext = cellIndex < _trendModel.timelineObjects.count;
    NSIndexPath *deleteCellIndexPath = [_tableView indexPathForCell:dlCell];
    if (deleteCellIndexPath && hasNext) {
        [_tableView scrollToRowAtIndexPath:deleteCellIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma -mark SNUserinfoGetUserinfoDelegate
-(void)notifyGetUserinfoSuccess:(NSArray *)mediaArray
{
    [self updateOperationButton];
    [super notifyGetUserinfoSuccess:mediaArray];
    //如果没有pid，则认为是取当前用户动态
    if(self.pid.length == 0)
    {
        self.pid = _model.usrinfo.pid;
        self.trendModel = [SNTimeLineTrendModel modelForUserWithPid:self.pid];
        self.trendModel.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_trendModel timelineRefresh];
        });
    }
}

#pragma mark- SNNavigationController delegate

- (void)popFromControllerClass:(Class)class
{
    if([class isSubclassOfClass:SNCircleUserCenterEditViewContronller.class])
    {
        //[self refresh];
        [self updateBaseInfoView];
    }
}

@end
