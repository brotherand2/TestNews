//
//  SNRecommendUserCell.m
//  sohunews
//
//  Created by lhp on 6/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNRecommendUserCell.h"
#import "UIColor+ColorUtils.h"
#import "SNStatusBarMessageCenter.h"


@interface SNRecommendUserCell ()

@end

@implementation SNRecommendUserCell

@synthesize recommendUser = _recommendUser;
@synthesize cellIndexPath = _cellIndexPath;
@synthesize canOpenUserInfo = _canOpenUserInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.canOpenUserInfo = YES;
        
        _userImageView = [[SNHeadIconView alloc] initWithFrame:CGRectMake(USER_HEAD_LEFT, USER_HEAD_TOP, USER_HEAD_WIDTH, USER_HEAD_WIDTH)];
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserIcon)];
        [_userImageView addGestureRecognizer:tapGes];
        [self.contentView addSubview:_userImageView];
        
        _userNameButton = [[SNNameButton alloc] initWithFrame:CGRectMake(USER_NAME_LEFT, USER_HEAD_TOP, USER_NAME_WIDTH, USER_NAME_HEIGHT)];
        _userNameButton.backgroundColor = [UIColor clearColor];
        [_userNameButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_userNameButton addTarget:self action:@selector(clickNameBtn) forControlEvents:UIControlEventTouchUpInside];
        [_userNameButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor]] forState:UIControlStateNormal];
        [self.contentView addSubview:_userNameButton];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(USER_NAME_LEFT, USER_CONTENT_TOP, USER_NAME_WIDTH, USER_CONTENT_HEIGHT)];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = [UIFont systemFontOfSize:12.0];
        _contentLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorCommentDateColor]];
        [self.contentView addSubview:_contentLabel];

        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.frame = CGRectMake(USER_FOLLOW_LEFT, USER_FOLLOW_TOP, USER_FOLLOW_WIDTH, USER_FOLLOW_HEIGHT);
        _followButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _followButton.titleEdgeInsets = UIEdgeInsetsMake(7, 7, 5, 7);
        [_followButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleButtonNameColor]] forState:UIControlStateNormal];
        [_followButton setBackgroundImage:[UIImage imageNamed:@"userinfo_follow_button.png"] forState:UIControlStateNormal];
        [_followButton setBackgroundImage:[UIImage imageNamed:@"userinfo_followed_button.png"] forState:UIControlStateHighlighted];
        [_followButton setTitle:@"关注" forState:UIControlStateNormal];
        [_followButton addTarget:self action:@selector(followUser) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_followButton];
        
        _loadingActivity = [[SNWaitingActivityView alloc] init];
        _loadingActivity.frame = CGRectMake(0, 0, 12, 12);
        _loadingActivity.center = _followButton.center;
        [self.contentView addSubview:_loadingActivity];
        
        [self.contentView addSubview:_followButton];
        
        _followedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, USER_FOLLOWED_WIDTH, USER_FOLLOWED_HEIGHT)];
        _followedLabel.center = _followButton.center;
        _followedLabel.hidden = YES;
        _followedLabel.backgroundColor = [UIColor clearColor];
        _followedLabel.textAlignment = NSTextAlignmentCenter;
        _followedLabel.font = [UIFont systemFontOfSize:14.0];
        _followedLabel.text = @"已关注";
        _followedLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorCommentDateColor]];
        [self.contentView addSubview:_followedLabel];
        
        _followService = [[SNFollowUserService alloc] init];
        _followService.delegate = self;
        
        _badgeView = [[SNBadgeView alloc] init];
        _badgeView.delegate = self;
        [self.contentView addSubview:_badgeView];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)reuseWithUser:(SNRecommendUser *) newUser cellIndexPath:(NSIndexPath *)indexPath;{
    
    if (!newUser) {
        return;
    }
    [self setNeedsDisplay];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.recommendUser = newUser;
    self.cellIndexPath = indexPath;
    _userImageView.icon.defaultImage = [UIImage themeImageNamed:@"login_user_defaultIcon.png"];
    [_userImageView setIconUrl:_recommendUser.headUrl passport:@"passport" gender:_recommendUser.gender];
    _userImageView.alpha = themeImageAlphaValue();
    
    [_userNameButton setTitle:_recommendUser.nickName forState:UIControlStateNormal];
    CGSize nameSize = [_userNameButton.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0]];
    nameSize.width = nameSize.width>200 ? 200:nameSize.width;
    _userNameButton.frame = CGRectMake(USER_NAME_LEFT, USER_HEAD_TOP+2, nameSize.width, USER_NAME_HEIGHT);
    _contentLabel.text = _recommendUser.text;

    [_followButton setBackgroundImage:[UIImage imageNamed:@"userinfo_follow_button.png"] forState:UIControlStateNormal];
    [_followButton setBackgroundImage:[UIImage imageNamed:@"userinfo_followed_button.png"] forState:UIControlStateHighlighted];
    [_followButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleButtonNameColor]] forState:UIControlStateNormal];
    _followedLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorCommentDateColor]];
    if(_recommendUser.signList && _recommendUser.signList.count > 0)
    {
        _badgeView.hidden = NO;
        [_badgeView reloadBadges:_recommendUser.signList maxHeight:USER_NAME_HEIGHT];
    }
    else
    {
        _badgeView.hidden = YES;
    }
    
    if (_recommendUser.isFollowed) {
        _followButton.hidden = YES;
        _followedLabel.hidden = NO;
    }else{
        _followButton.hidden = NO;
        _followedLabel.hidden = YES;
    }
}

-(void)badgeViewWidth:(float)width height:(float)height
{
    if(width + _userNameButton.width > USER_NAME_WIDTH)
    {
        _userNameButton.width = USER_NAME_WIDTH - width - 2;
        _badgeView.frame = CGRectMake(_userNameButton.right+2, _userNameButton.top, width, height);
        _badgeView.center = CGPointMake(_badgeView.centerX, _userNameButton.centerY);
    }
    else
    {
        CGFloat startx = _userNameButton.right + 2;
        _badgeView.frame = CGRectMake(startx, _userNameButton.top, width, height);
        _badgeView.center = CGPointMake(_badgeView.centerX, _userNameButton.centerY);
    }
}

//- (void)removeSignViews
//{
//    for(UIView* view in _signViewList)
//    {
//        if(view)
//           [view removeFromSuperview];
//    }
//    [_signViewList removeAllObjects];
//}
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    [UIView drawCellSeperateLine:rect];
}

- (void)followUser{
    _followButton.hidden = YES;
    
    [_loadingActivity updateTheme];    
    [_loadingActivity startAnimating];
    [_followService followUserWithFpid:_recommendUser.pID];
}

- (void)openUserInfo{
    
    if (!_canOpenUserInfo) {
        return;
    }
    
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
    if (_recommendUser.pID) {
        [userDic setObject:_recommendUser.pID forKey:@"pid"];
    }
    if (_recommendUser.nickName) {
        [userDic setObject:_recommendUser.nickName forKey:@"nickName"];
    }
    if (_recommendUser.headUrl) {
        [userDic setObject:_recommendUser.headUrl forKey:@"headUrl"];
    }
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyAnimated:YES] applyQuery:userDic];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)clickUserIcon{
    [self openUserInfo];
}

- (void)clickNameBtn{
    [self openUserInfo];
}

- (void)followUserSucceedWithType:(SNRequestType) type{
    
}

#pragma mark -
#pragma mark SNFollowUserServiceDelegate

- (void)followedUserSucceedWithType:(SNRequestType) type{
    
    if (type == SNRequestTypeAddFollow) {
        [_loadingActivity stopAnimating];
        _followedLabel.hidden = NO;
        _recommendUser.isFollowed = YES;
        SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
        if(userinfo)
        {
            userinfo.followingCount = [NSString stringWithFormat:@"%d", [userinfo.followingCount intValue]+1];
            [userinfo saveUserinfoToUserDefault];
        }
        
    }
    [self followUserSucceedWithType:type];
    
}
- (void)followedUserFailWithError:(NSError*)error requestType:(SNRequestType) type{
    
    if (type == SNRequestTypeAddFollow) {
        [_loadingActivity stopAnimating];
        _followedLabel.hidden = YES;
        _followButton.hidden = NO;
    }
    if (error) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
    }
}

- (void)updateTheme:(NSNotification *)notifiction {
    [_followButton setBackgroundImage:[UIImage imageNamed:@"userinfo_follow_button.png"] forState:UIControlStateNormal];
    [_followButton setBackgroundImage:[UIImage imageNamed:@"userinfo_followed_button.png"] forState:UIControlStateHighlighted];
    [_followButton setTitleColor:SNUICOLOR(kCircleButtonNameColor) forState:UIControlStateNormal];
    _followedLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    _userImageView.alpha = themeImageAlphaValue();
    _contentLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
}

- (void)dealloc{
    
     //(_userImageView);
     //(_userNameButton);
     //(_contentLabel);
     //(_loadingActivity);
     //(_followedLabel);
     //(_cellIndexPath);
    _badgeView.delegate = nil;
     //(_badgeView);
    _followService.delegate = nil;
     //(_followService);
    [SNNotificationManager removeObserver:self];
}

@end
