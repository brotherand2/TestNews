//
//  SNSelfCenterBaseViewController.m
//  sohunews
//
//  Created by yangln on 14-10-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSelfCenterBaseViewController.h"
#import "SNBubbleTipView.h"
#import "SNBubbleBadgeObject.h"
#import "SNWebImageView.h"
//#import "SNWeiboDetailMoreCell.h"
#import "SNSelfCenterViewController.h"


@interface SNSelfCenterBaseViewController ()
@property (nonatomic, strong) NSDate* lastRefreshDate;

@end

@implementation SNSelfCenterBaseViewController

@synthesize tableView = _tableView;
@synthesize pid = _pid;
@synthesize model = _model;
@synthesize lastRefreshDate = _lastRefreshDate;

#pragma -mark lifecircle
-(id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNavigatorURL:URL query:query];
    if(self)
    {
        self.pid = [query objectForKey:@"pid"];
        
        _model = [[SNUserinfoService alloc] init];
        _model.userinfoDelegate = self;
        
        [SNNotificationManager addObserver:self selector:@selector(notifyGetUserinfoSuccess:) name:kNotifyGetUserinfoSuccess object:nil];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = SNUICOLOR(kThemeBg3Color);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
     //(_tableView);
     //(_dragHeaderView);
     //(_model);
     //(_baseInfoView);
     //(_pid);
     //(_moreCell);
     //(_dfCell);
     //(_lastRefreshDate);
    [SNNotificationManager removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _tableView.scrollsToTop = YES;
}

#pragma -mark new method
-(void)createTableView
{
    if(_tableView)
        return;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kAppScreenWidth, kAppScreenHeight-kSystemBarHeight-kToolbarViewTop)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
    //_tableView.tableHeaderView = _baseInfoView;
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
}

-(void)addDragRefreshHeader
{
    if(!_dragHeaderView)
    {
        _dragHeaderView = [[SNTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0, -_tableView.bounds.size.height, _tableView.width, _tableView.bounds.size.height)];
        _dragHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [_dragHeaderView setStatus:TTTableHeaderDragRefreshPullToReload];
        [_tableView addSubview:_dragHeaderView];
    }
}

-(void)removeDragRefreshHeader
{
    if(_dragHeaderView)
    {
        [_dragHeaderView removeFromSuperview];
         //(_dragHeaderView);
    }
}

-(void)createBaseInfoView
{
    if(_baseInfoView)
        return;
    _baseInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSNSelfCenterTableViewHeaderHeight)];
    _baseInfoView.backgroundColor = [UIColor clearColor];
    _baseInfoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapBaseInfoView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickHead)];
    [_baseInfoView addGestureRecognizer:tapBaseInfoView];
    
    UIImage *defaultImage = [UIImage themeImageNamed:@"bgseeme_defaultavatar_v5.png"];
    CGSize defaultSize = defaultImage.size;
    CGRect baseRect = CGRectMake(kSNSelfCenterUnloginHeadImageOriginX, kSNSelfCenterUnloginHeadImageOriginY, defaultSize.width, defaultSize.height);
    SNWebImageView* imageView = [[SNWebImageView alloc] initWithFrame:baseRect];
    imageView.tag = kUserCenterHeadViewTag;
    imageView.contentMode= UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    imageView.layer.masksToBounds   = YES;
    imageView.layer.cornerRadius = defaultSize.width/2;
    imageView.defaultImage = defaultImage;
    imageView.urlPath = nil;
    [_baseInfoView addSubview:imageView];
    
    _maskViewForHeaderImage = [SNUtility addMaskForImageViewWithRadius:defaultSize.width/2 width:defaultSize.width height:defaultSize.height];
    [imageView addSubview:_maskViewForHeaderImage];
    
    UIColor* nameColor = SNUICOLOR(kThemeText5Color);
    
    //用户名
    CGRect rect = CGRectMake(0, 0, 180, 20);
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:rect];
    nameLabel.tag = kUserCenterNameTag;
    nameLabel.numberOfLines = 1;
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.userInteractionEnabled = NO;
    nameLabel.textColor = nameColor;
    nameLabel.center = imageView.center;
    nameLabel.left = imageView.right +14;
    nameLabel.bottom = nameLabel.bottom-8.5;
    [_baseInfoView addSubview:nameLabel];
    
    //城市
    UILabel* city = [[UILabel alloc] init];
    city.tag = kUserCenterCityTag;
    city.font = [UIFont systemFontOfSize:11];
    city.textColor = nameColor;
    city.backgroundColor = [UIColor clearColor];
    city.userInteractionEnabled = NO;
    [_baseInfoView addSubview:city];
    
    //微博
    UIImageView* weiboImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    weiboImg.backgroundColor = [UIColor clearColor];
    weiboImg.tag = kUserCenterWeiboTag;
    weiboImg.userInteractionEnabled = YES;
    [_baseInfoView addSubview:weiboImg];
    
    //性别
    UIImageView* genderImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    genderImg.backgroundColor = [UIColor clearColor];
    genderImg.tag =kUserCenterGenderTag;
    genderImg.userInteractionEnabled = YES;
    [_baseInfoView addSubview:genderImg];
    
    //手机绑定
    UIImageView* mobileImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    mobileImg.backgroundColor = [UIColor clearColor];
    mobileImg.tag =kUserCenterMobileNumTag;
    mobileImg.userInteractionEnabled = YES;
    [_baseInfoView addSubview:mobileImg];
    
    //账号管理
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *editButtonImage = [UIImage imageNamed:@"icopersonal_edit_v5.png"];
    UIImage *editButtonImagePress = [UIImage imageNamed:@"icopersonal_editpress_v5.png"];
    editButton.backgroundColor = [UIColor clearColor];
    [editButton setImage:editButtonImage forState:UIControlStateNormal];
    [editButton setImage:editButtonImagePress forState:UIControlStateHighlighted];
    [editButton setTitle:@"编辑" forState: UIControlStateNormal];
    editButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [editButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    editButton.tag = kUserCenterAccountEditButtonTag;
    [editButton addTarget:self action:@selector(onClickHead) forControlEvents:UIControlEventTouchUpInside];
    editButton.bounds = CGRectMake(0, 0, editButtonImage.size.width+26, 27);
    editButton.origin = CGPointMake(kAppScreenWidth - editButton.width-16, imageView.top+27-editButton.height/2);
    editButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, -10);
    editButton.titleEdgeInsets = UIEdgeInsetsMake(0, editButton.imageView.bounds.size.width-8, 0, -editButton.imageView.bounds.size.width+8);
    [_baseInfoView addSubview:editButton];
}
-(void)updateBaseInfoView
{
    if(!_baseInfoView)
        return;
    UIImage* defaultimage = nil;
    if([@"1" isEqualToString:_model.usrinfo.gender]) {
        defaultimage = [UIImage themeImageNamed:@"userinfo_default_headimage_man.png"];
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            _maskViewForHeaderImage.alpha = 0.7;
        }
        else {
            _maskViewForHeaderImage.alpha = 0;
        }
    }
    else if([@"2" isEqualToString:_model.usrinfo.gender]) {
        defaultimage = [UIImage themeImageNamed:@"userinfo_default_headimage_woman.png"];
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            _maskViewForHeaderImage.alpha = 0.7;
        }
        else {
            _maskViewForHeaderImage.alpha = 0;
        }
    }
    else {
        defaultimage = [UIImage themeImageNamed:@"bgseeme_defaultavatar_v5.png"];
        _maskViewForHeaderImage.alpha = 0;
    }
    
    SNWebImageView* headImage = (SNWebImageView*)[_baseInfoView viewWithTag:kUserCenterHeadViewTag];
    headImage.defaultImage = defaultimage;
    headImage.urlPath = nil;
    if(_model!=nil && _model.usrinfo!=nil && (_model.usrinfo.tempHeader!=nil || [_model.usrinfo.headImageUrl length]>0))
    {
        if(headImage!=nil && _model.usrinfo.tempHeader!=nil)
        {
            headImage.defaultImage = _model.usrinfo.tempHeader;
            headImage.urlPath = nil;
        }
        else if(headImage!=nil)
        {
            headImage.defaultImage = defaultimage;
            headImage.urlPath = _model.usrinfo.headImageUrl;
            if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
                _maskViewForHeaderImage.alpha = 0.7;
            }
            else {
                _maskViewForHeaderImage.alpha = 0;
            }
        }
    }
    
    if(_model!=nil && _model.usrinfo!=nil && _model.usrinfo.nickName!=nil && [_model.usrinfo.nickName length]>0)
    {
        SNDebugLog(@"nick name = %@", _model.usrinfo.nickName);
        UIColor* labelColor = SNUICOLOR(kThemeText5Color);
        UILabel* nameLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterNameTag];
        if(nameLabel!=nil)
        {
            nameLabel.textColor = labelColor;
            nameLabel.text = [_model.usrinfo getNickname];
            if(nameLabel.text.length==0)
                nameLabel.text = @"";
        }
        if(_model.usrinfo.signList && _model.usrinfo.signList.count > 0)
        {
            CGSize size = [nameLabel.text sizeWithFont:nameLabel.font];
            CGFloat signx = nameLabel.origin.x + size.width + 3;
            CGFloat signy = nameLabel.origin.y;
            SNBadgeView* badgeView = (SNBadgeView*)[_baseInfoView viewWithTag:kUserCenterBadgeTag];
//            badgeView.alpha = themeImageAlphaValue();
            if(badgeView == nil)
            {
                badgeView = [[SNBadgeView alloc] initWithFrame:CGRectMake(signx, signy, 50, nameLabel.height-2)];
                badgeView.tag = kUserCenterBadgeTag;
                badgeView.delegate = self;
//                badgeView.alpha = themeImageAlphaValue();
                
            }
            [badgeView reloadBadges:_model.usrinfo.signList maxHeight:nameLabel.height-6];
            [_baseInfoView addSubview:badgeView];
        }
        NSInteger xOffset = 86;
        //城市
        UILabel* cityLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterCityTag];
        cityLabel.backgroundColor = [UIColor clearColor];
        if(cityLabel!=nil)
        {
            cityLabel.text = [_model.usrinfo getPlace];
            cityLabel.textColor = labelColor;
            if(cityLabel.text.length>0)
            {
                CGSize fontSize = [cityLabel.text sizeWithFont:cityLabel.font];
                CGRect rect = CGRectMake(xOffset, cityLabel.origin.y, fontSize.width, 15);
                xOffset += (rect.size.width+4);
                cityLabel.frame = rect;
                cityLabel.frame = CGRectMake(nameLabel.origin.x, nameLabel.bottom+4, fontSize.width, fontSize.height);
            }
        }
        //性别
        UIImage* gender = [UIImage imageNamed:@"icopersonal_male_v5.png"];
        CGSize imageSize = gender.size;
        UIImageView* genderImgView = (UIImageView*)[_baseInfoView viewWithTag:kUserCenterGenderTag];
        if(genderImgView!=nil && _model.usrinfo.gender.length>0)
        {
            CGRect rect = CGRectMake(xOffset, cityLabel.centerY-5.5, imageSize.width, imageSize.height);
            xOffset += (rect.size.width+5);
            genderImgView.frame = rect;
            genderImgView.backgroundColor = [UIColor clearColor];
            if (cityLabel.text.length>0) {
                genderImgView.left = cityLabel.right+7;
            }
            else {
                genderImgView.left = nameLabel.left;
                genderImgView.top = nameLabel.bottom+6;
            }

            if([@"1" isEqualToString:_model.usrinfo.gender])
                gender = [UIImage imageNamed:@"icopersonal_male_v5.png"];
            else
                gender = [UIImage imageNamed:@"icopersonal_female_v5.png"];
            
            genderImgView.image = gender;
        }
        else
            genderImgView.frame = CGRectZero;
        //微博
        UIImageView* weiImgView = (UIImageView*)[_baseInfoView viewWithTag:kUserCenterWeiboTag];
        if(weiImgView!=nil && _model.usrinfo.from.length>0)
        {
            NSString* imgName = nil;
            //1:新浪微博2:腾讯微博 3搜狐微博 4 人人 5 开心 6 qzone 7百度 8淘宝
            if([@"1" isEqualToString:_model.usrinfo.from]) imgName = @"icopersonal_weibo_v5.png";
            else if([@"2" isEqualToString:_model.usrinfo.from]) imgName = @"icopersonal_txweibo_v5.png";
            else if([@"3" isEqualToString:_model.usrinfo.from]) imgName = @"icopersonal_sohu_v5.png";
            else if([@"4" isEqualToString:_model.usrinfo.from]) imgName = @"icopersonal_renren_v5.png";
            else if([@"5" isEqualToString:_model.usrinfo.from]) imgName = @"icopersonal_kaixin_v5.png";
            else if([@"6" isEqualToString:_model.usrinfo.from]) imgName = @"icopersonal_qq_v5.png";
            else if([@"7" isEqualToString:_model.usrinfo.from]) imgName = @"icopersonal_baidu_v5.png";
            else if([@"8" isEqualToString:_model.usrinfo.from]) imgName = @"icopersonal_taobao_v5.png";
            
            if(imgName.length>0)
            {
                CGRect rect = CGRectMake(xOffset, cityLabel.origin.y, imageSize.width, imageSize.height);
                xOffset += (rect.size.width+5);
                weiImgView.frame = rect;
                weiImgView.backgroundColor = [UIColor clearColor];
                weiImgView.left = genderImgView.right+7;
                weiImgView.bottom = genderImgView.bottom;
                UIImage* platForm = [UIImage imageNamed:imgName];
                weiImgView.image = platForm;
            }
        }
        else
            weiImgView.frame = CGRectZero;
        //手机绑定
        UIImageView *mobileImgView = (UIImageView *)[_baseInfoView viewWithTag:kUserCenterMobileNumTag];
        if (mobileImgView!=nil && _model.usrinfo.mobile.length>0) {
            CGRect rect = CGRectMake(xOffset, cityLabel.origin.y, imageSize.width, imageSize.height);
            mobileImgView.frame = rect;
            mobileImgView.backgroundColor = [UIColor clearColor];
            mobileImgView.left = weiImgView.right+7;
            mobileImgView.bottom = weiImgView.bottom;
            mobileImgView.image = [UIImage imageNamed:@"icopersonal_phone_v5.png"];
        }
        else
            mobileImgView.frame = CGRectZero;
    }
    
    UIButton *editButton = (UIButton *)[_baseInfoView viewWithTag:kUserCenterAccountEditButtonTag];
    UIImage *editButtonImage = [UIImage imageNamed:@"icopersonal_edit_v5.png"];
    UIImage *editButtonImagePress = [UIImage imageNamed:@"icopersonal_editpress_v5.png"];
    [editButton setImage:editButtonImage forState:UIControlStateNormal];
    [editButton setImage:editButtonImagePress forState:UIControlStateHighlighted];
    [editButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
}

-(void)badgeViewWidth:(float)width height:(float)height badgeView:(SNBadgeView *)badgeView
{
    UILabel* nameLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterNameTag];
    if(nameLabel != nil)
    {
        badgeView.size = CGSizeMake(width, height);
    }
    
    SNWebImageView *headImage = (SNWebImageView *)[_baseInfoView viewWithTag:kUserCenterHeadViewTag];
    if (headImage != nil) {
        badgeView.size = CGSizeMake(width, height);
        badgeView.left = headImage.right - 15;
        badgeView.bottom = headImage.bottom;
    }
}


-(void)onClickHead
{
    
}

-(void)onClickFollowing
{
    
}

-(void)onClickFollowed
{
    
}

-(void)refresh
{
    [self modelDidStartLoad];
}

-(void)updateTheme:(NSNotification *)notifiction
{
    [super updateTheme:notifiction];
    self.view.backgroundColor = SNUICOLOR(kThemeBg3Color);
    if(_baseInfoView)
        [self updateBaseInfoView];
    if(_tableView)
        [_tableView reloadData];
    if(_dfCell)
        [_dfCell updateTheme];
}
#pragma -mark SNUserinfoServiceGetUserinfoDelegate
-(void)notifyGetUserinfoSuccess:(NSArray*)mediaArray
{
    self.lastRefreshDate = [NSDate date];
    [self updateBaseInfoView];
    //[self updateOperationButton];
    [self.tableView reloadData];
    [self modelDidFinishLoad];
}

-(void)notifyGetUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
    [self modelDidFailLoadWithError];
}

-(void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyGetUserinfoFailure");
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    [self modelDidFailLoadWithError];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    
    // hide menu
    [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification
                                                        object:nil
                                                      userInfo:nil];
    if (scrollView.dragging && !_isLoading) {
        if (scrollView.contentOffset.y > kRefreshDeltaY
            && scrollView.contentOffset.y < 0.0f)
        {
            if(_lastRefreshDate)
                [_dragHeaderView setUpdateDate:_lastRefreshDate];
            else
                [_dragHeaderView setCurrentDate];
            
            [_dragHeaderView setStatus:TTTableHeaderDragRefreshPullToReload];
            
        } else if (scrollView.contentOffset.y < kRefreshDeltaY) {
            
            [_dragHeaderView setStatus:TTTableHeaderDragRefreshReleaseToReload];
            
        }
    }
    if (_isLoading)
    {
        if (scrollView.contentOffset.y >= 0) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
            
        } else if (scrollView.contentOffset.y < 0) {
            _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight, 0, kToolbarViewHeight, 0);
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.contentOffset.y <= kRefreshDeltaY && !_isLoading) {
        [self refresh];
    }
}

- (void)modelDidStartLoad {
    
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        return;
    }
    if (_isLoadingMore)
    {
        //[_moreCell showLoading:YES];
        
    }
    else
    {
        [_dragHeaderView setStatus:TTTableHeaderDragRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight, 0.0f, kToolbarViewHeight, 0.0f);
        [UIView commitAnimations];
        
        
        if (_lastRefreshDate) {
            [_dragHeaderView setUpdateDate:_lastRefreshDate];
        }
        _isLoading = YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad {
    if (_isLoadingMore)
    {
        //        [_moreCell showLoading:NO];
        //        _isLoadingMore = NO;
        //        [_moreCell setHasNoMore:!_model.hasMore];
    }
    else
    {
        [_dragHeaderView setStatus:TTTableHeaderDragRefreshPullToReload];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
        if (_tableView.contentOffset.y < 0) {
            _tableView.contentOffset = CGPointZero;
        }
        [UIView commitAnimations];
        
        //        NSDate *date = [_model getLastRefreshDate];
        //        if (date) {
        //            [_headerView setUpdateDate:date];
        //        } else {
        //            [_headerView setCurrentDate];
        //        }
        _isLoading = NO;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFailLoadWithError {
    if (_isLoadingMore)
    {
        //        [_moreCell showLoading:NO];
        //        _isLoadingMore = NO;
        //        [_moreCell setHasNoMore:!_model.hasMore];
    }
    else
    {
        [_dragHeaderView setStatus:TTTableHeaderDragRefreshPullToReload];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ttkDefaultTransitionDuration];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
        if (_tableView.contentOffset.y < 0) {
            _tableView.contentOffset = CGPointZero;
        }
        [UIView commitAnimations];
        _isLoading = NO;
    }
}

#pragma mark - timelineCellDelegate
- (void)timelineCellExpandComment
{
    [_tableView reloadData];
}

- (BOOL)checkNetworkIsEnableAndTell {
    BOOL bRet = YES;
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        bRet = NO;
        _isShowNetWork = YES;
        [SNNotificationCenter showExclamation:NSLocalizedString(SN_String("network error"), @"")];
        [self setMoreCellState:kRCMoreCellStateDragRefresh];
    }
    return bRet;
}

- (void)setMoreCellState:(SNMoreCellState)state
{
    switch (state) {
        case kRCMoreCellStateLoadingMore:
            //[_moreCell showLoading:YES];
            break;
        case kRCMoreCellStateDragRefresh:
            //[_moreCell showLoading:NO];
            //[_moreCell setHasNoMore:NO];
            break;
        case kRCMoreCellStateEnd:
            //[_moreCell showLoading:NO];
            //[_moreCell setHasNoMore:YES];
            break;
        default:
            break;
    }
}

#pragma -mark UITablewViewDelegate
-(NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return  nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


@end
