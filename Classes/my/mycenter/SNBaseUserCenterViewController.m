 //
//  SNBaseUserCenterViewController.m
//  sohunews
//
//  Created by weibin cheng on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseUserCenterViewController.h"

@interface SNBaseUserCenterViewController ()
@property (nonatomic, strong) NSDate* lastRefreshDate;
@end

@implementation SNBaseUserCenterViewController
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
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    self.view.backgroundColor = [UIColor colorFromString:backgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
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
        
        [_dragHeaderView setStatus:TTTableHeaderDragRefreshLoading];
        [_tableView addSubview:_dragHeaderView];
    }
}

-(void)removeDragRefreshHeader
{
    if(_dragHeaderView)
    {
        [_dragHeaderView removeFromSuperview];
    }
}
-(void)createBaseInfoView
{
    if(_baseInfoView)
        return;
    _baseInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kBaseInfoViewHeight)];
    _baseInfoView.backgroundColor = [UIColor clearColor];
    CGFloat starty = 18;
    CGFloat startx = 10;
    CGRect baseRect = CGRectMake(10, 18, 66, 66);
    SNWebImageView* imageView = [[SNWebImageView alloc] initWithFrame:baseRect];
    imageView.tag = kUserCenterHeadViewTag;
    imageView.contentMode= UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    imageView.layer.masksToBounds   = YES;
    imageView.layer.cornerRadius = 2;
    imageView.defaultImage = [UIImage themeImageNamed:@"userinfo_default_headimage.png"];
    imageView.urlPath = nil;
    imageView.alpha = themeImageAlphaValue();
    [_baseInfoView addSubview:imageView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickHead)];
    [imageView addGestureRecognizer:tap];
    
    NSString *strNameColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoNameColor];
    UIColor* nameColor = [UIColor colorFromString:strNameColor];
    
    startx = 86;
    //用户名
    CGRect rect = CGRectMake(86, starty, 200, 20);
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:rect];
    nameLabel.tag = kUserCenterNameTag;
    nameLabel.numberOfLines = 1;
    nameLabel.font = [UIFont systemFontOfSize:18];
    nameLabel.textColor = nameColor;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.userInteractionEnabled = NO;
    nameLabel.textColor = nameColor;
    [_baseInfoView addSubview:nameLabel];
    
    NSString *strLabelColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoPlaceColor];
    UIColor* labelColor = [UIColor colorFromString:strLabelColor];
    
    starty += 30;
    //城市
    UILabel* city = [[UILabel alloc] initWithFrame:CGRectMake(startx, starty, 0, 16)];
    city.tag = kUserCenterCityTag;
    city.font = [UIFont systemFontOfSize:11];
    city.textColor = labelColor;
    city.backgroundColor = [UIColor clearColor];
    city.userInteractionEnabled = NO;
    city.textColor = labelColor;
    [_baseInfoView addSubview:city];
    
    //微博
    UIImageView* weiboImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    weiboImg.backgroundColor = [UIColor clearColor];
    weiboImg.tag = kUserCenterWeiboTag;
    weiboImg.userInteractionEnabled = YES;
    weiboImg.alpha = themeImageAlphaValue();
    [_baseInfoView addSubview:weiboImg];
    
    //性别
    UIImageView* genderImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    genderImg.backgroundColor = [UIColor clearColor];
    genderImg.tag =kUserCenterGenderTag;
    genderImg.userInteractionEnabled = YES;
    genderImg.alpha = themeImageAlphaValue();
    [_baseInfoView addSubview:genderImg];
    
    starty += 22;
    //关注
    UIButton* followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    followingButton.frame = CGRectMake(startx, starty, 70, 14);
    followingButton.backgroundColor = [UIColor clearColor];
    [followingButton addTarget:self action:@selector(onClickFollowing) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 28, 12)];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = labelColor;
    label.text = @"关注:";
    label.tag = kUserCenterFollowingTag;
    [followingButton addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(28, 2, 42, 12)];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    label.textColor = nameColor;
    label.tag = kUserCenterFollowingCountTag;
    [followingButton addSubview:label];
    [_baseInfoView addSubview:followingButton];
    
    SNBubbleTipView* bubble = [[SNBubbleTipView alloc] initWithType:SNHeadBubbleType];
    bubble.tag = kUserCenterFollowingBadgeTag;
    bubble.alignType = SNBubbleAlignLeft;
    bubble.backgroundColor = [UIColor clearColor];
    bubble.frame = CGRectZero;
    [followingButton addSubview:bubble];
    
    startx += 70 + 10;
    
    UIImage* image = [UIImage themeImageNamed:@"my_vertical_line.png"];
    UIImageView* lineView = [[UIImageView alloc] initWithFrame:CGRectMake(startx, starty, 1, 14)];
    lineView.tag = kUserCenterFollowLineTag;
    lineView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(7, 0, 7, 0)];
    [_baseInfoView addSubview:lineView];
    
    startx += 10;
    
    UIButton* followedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    followedButton.frame = CGRectMake(startx, starty, 70, 14);
    followedButton.backgroundColor = [UIColor clearColor];
    [followedButton addTarget:self action:@selector(onClickFollowed) forControlEvents:UIControlEventTouchUpInside];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 28, 12)];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = labelColor;
    label.text = @"粉丝:";
    label.tag = kUserCenterFollowedTag;
    [followedButton addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(28, 2, 42, 12)];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    label.textColor = nameColor;
    label.tag = kUserCenterFollowedCountTag;
    [followedButton addSubview:label];
    [_baseInfoView addSubview:followedButton];
    
    bubble = [[SNBubbleTipView alloc] initWithType:SNHeadBubbleType];
    bubble.tag = kUserCenterFollowedBadgeTag;
    bubble.alignType = SNBubbleAlignLeft;
    bubble.backgroundColor = [UIColor clearColor];
    bubble.frame = CGRectZero;
    [followedButton addSubview:bubble];
    
    strLabelColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleButtonNameColor];
    labelColor = [UIColor colorFromString:strLabelColor];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = kUserCenterButtonTag;
    button.frame = CGRectZero;
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:labelColor forState:UIControlStateNormal];
    [_baseInfoView addSubview:button];
}
-(void)updateBaseInfoView
{
    if(!_baseInfoView)
        return;
    UIImage* defaultimage = nil;
    if([@"1" isEqualToString:_model.usrinfo.gender])
        defaultimage = [UIImage themeImageNamed:@"userinfo_default_headimage_man.png"];
    else if([@"2" isEqualToString:_model.usrinfo.gender])
        defaultimage = [UIImage themeImageNamed:@"userinfo_default_headimage_woman.png"];
    else
        defaultimage = [UIImage themeImageNamed:@"userinfo_default_headimage.png"];
    
    SNWebImageView* headImage = (SNWebImageView*)[_baseInfoView viewWithTag:kUserCenterHeadViewTag];
    headImage.defaultImage = defaultimage;
    headImage.alpha = themeImageAlphaValue();
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
        }
    }
    
    
    if(_model!=nil && _model.usrinfo!=nil && _model.usrinfo.nickName!=nil && [_model.usrinfo.nickName length]>0)
    {
        SNDebugLog(@"nick name = %@", _model.usrinfo.nickName);
        UIColor* labelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoNameColor]];
        UILabel* nameLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterNameTag];
        if(nameLabel!=nil)
        {
            nameLabel.textColor = labelColor;
            nameLabel.text = [_model.usrinfo getNickname];
            if(nameLabel.text.length==0)
                nameLabel.text = @"";
        }
        SNBadgeView* badgeView = (SNBadgeView*)[_baseInfoView viewWithTag:kUserCenterBadgeTag];
        if(_model.usrinfo.signList && _model.usrinfo.signList.count > 0)
        {
            CGSize size = [nameLabel.text sizeWithFont:nameLabel.font];
            CGFloat signx = nameLabel.origin.x + size.width + 3;
            CGFloat signy = nameLabel.origin.y;
//            badgeView.alpha = themeImageAlphaValue();
            if(badgeView == nil)
            {
                badgeView = [[SNBadgeView alloc] initWithFrame:CGRectMake(signx, signy, 50, nameLabel.height-2)];
                badgeView.tag = kUserCenterBadgeTag;
                badgeView.delegate = self;
                
            }
            [badgeView reloadBadges:_model.usrinfo.signList maxHeight:nameLabel.height-6];
            [_baseInfoView addSubview:badgeView];
        }
        else if (badgeView) {
            nameLabel.width = 200;
            [badgeView removeFromSuperview];
        }
        labelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoPlaceColor]];
        NSInteger xOffset = 86;
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
            }
        }
        
        UIImageView* weiImgView = (UIImageView*)[_baseInfoView viewWithTag:kUserCenterWeiboTag];
        if(weiImgView!=nil && _model.usrinfo.from.length>0)
        {
            NSString* imgName = nil;
            //1:新浪微博2:腾讯微博 3搜狐微博 4 人人 5 开心 6 qzone 7百度 8淘宝
            if([@"1" isEqualToString:_model.usrinfo.from]) imgName = @"circleland_weibo.png";
            else if([@"2" isEqualToString:_model.usrinfo.from]) imgName = @"circleland_txweibo.png";
            else if([@"3" isEqualToString:_model.usrinfo.from]) imgName = @"circleland_sohu.png";
            else if([@"4" isEqualToString:_model.usrinfo.from]) imgName = @"circleland_renren.png";
            else if([@"5" isEqualToString:_model.usrinfo.from]) imgName = @"circleland_kaixin.png";
            else if([@"6" isEqualToString:_model.usrinfo.from]) imgName = @"circleland_QQ.png";
            else if([@"7" isEqualToString:_model.usrinfo.from]) imgName = @"circleland_baidu.png";
            else if([@"8" isEqualToString:_model.usrinfo.from]) imgName = @"circleland_taobao.png";
            
            if(imgName.length>0)
            {
                CGRect rect = CGRectMake(xOffset, cityLabel.origin.y, 13, 13);
                xOffset += (rect.size.width+5);
                weiImgView.frame = rect;
                weiImgView.backgroundColor = [UIColor clearColor];
                
                UIImage* platForm = [UIImage imageNamed:imgName];
                weiImgView.image = platForm;
            }
        }
        else
            weiImgView.frame = CGRectZero;
        
        UIImageView* genderImgView = (UIImageView*)[_baseInfoView viewWithTag:kUserCenterGenderTag];
        if(genderImgView!=nil && _model.usrinfo.gender.length>0)
        {
            CGRect rect = CGRectMake(xOffset, cityLabel.origin.y, 12, 12);
            genderImgView.frame = rect;
            genderImgView.backgroundColor = [UIColor clearColor];
            
            UIImage* gender;
            if([@"1" isEqualToString:_model.usrinfo.gender])
                gender = [UIImage imageNamed:@"man.png"];
            else
                gender = [UIImage imageNamed:@"woman.png"];
            
            genderImgView.image = gender;
        }
        else
            genderImgView.frame = CGRectZero;
        
        weiImgView.alpha = themeImageAlphaValue();
        genderImgView.alpha = themeImageAlphaValue();
    }
    
    UIColor* nameColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoNameColor]];
    UIColor* labelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoPlaceColor]];
    UILabel* followingLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterFollowingTag];
    if(followingLabel)
    {
        followingLabel.textColor = labelColor;
    }
    followingLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterFollowingCountTag];
    if(followingLabel)
    {
        followingLabel.textColor = nameColor;
        followingLabel.text = _model.usrinfo.followingCount;
        CGSize size = [followingLabel.text sizeWithFont:followingLabel.font];
        followingLabel.size = CGSizeMake(size.width, followingLabel.height);
    }
    SNBubbleTipView* followingBubble = (SNBubbleTipView*)[_baseInfoView viewWithTag:kUserCenterFollowingBadgeTag];
    if(followingBubble)
    {
        followingBubble.frame = CGRectMake(followingLabel.right, followingLabel.top-4, followingBubble.defaultWidth, followingBubble.defaultHeight);
    }
    UIButton* followingView = (UIButton*)[followingLabel superview];
    if(followingView)
    {
        followingView.width = followingLabel.right;
    }
    
    UIImageView* lineView = (UIImageView*)[_baseInfoView viewWithTag:kUserCenterFollowLineTag];
    if(lineView)
    {
        CGFloat right = followingView.right + 6;
        if(followingBubble.tipCount > 0)
            right += followingBubble.defaultWidth;
        lineView.left = right;
    }
    
    UILabel* followedLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterFollowedTag];
    if(followedLabel)
    {
        followedLabel.textColor = labelColor;
    }
    followedLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterFollowedCountTag];
    if(followedLabel)
    {
        followedLabel.textColor = nameColor;
        followedLabel.text = _model.usrinfo.followedCount;
        CGSize size = [followedLabel.text sizeWithFont:followedLabel.font];
        followedLabel.size = CGSizeMake(size.width, followedLabel.height);
    }
    SNBubbleTipView* followedBubble = (SNBubbleTipView*)[_baseInfoView viewWithTag:kUserCenterFollowedBadgeTag];
    if(followedBubble)
    {
        CGRect rect = CGRectMake(followedLabel.right, followedLabel.top-4, followedBubble.defaultWidth, followedBubble.defaultHeight);
        followedBubble.frame = rect;
    }
    
    UIButton* followedButton = (UIButton*)followedLabel.superview;
    if(followedButton)
    {
        followedButton.left = lineView.right + 8;
    }
}

-(void)badgeViewWidth:(float)width height:(float)height badgeView:(SNBadgeView *)badgeView
{
    UILabel* nameLabel = (UILabel*)[_baseInfoView viewWithTag:kUserCenterNameTag];
    if(nameLabel != nil)
    {
        badgeView.size = CGSizeMake(width, height);
        CGSize size = [nameLabel.text sizeWithFont:nameLabel.font];
        if(size.width + width + 86 > kAppScreenWidth)
        {
            badgeView.left = kAppScreenWidth - width - 10;
            badgeView.centerY = nameLabel.centerY;
            nameLabel.width = kAppScreenWidth - 86 - width - 10 - 2;
        }
        else
        {
            nameLabel.width = size.width;
            badgeView.left = nameLabel.right + 2;
            badgeView.centerY = nameLabel.centerY;
        }
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
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
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
    [SNNotificationCenter showMessage:aMsg];
    [self modelDidFailLoadWithError];
}

-(void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyGetUserinfoFailure");
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
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
        
        //        if (_tableView.contentOffset.y < 0) {
        //            _tableView.contentInset = UIEdgeInsetsMake(kHeaderVisibleHeight, 0.0f, kToolbarViewHeight, 0.0f);
        //        }
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
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];

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
