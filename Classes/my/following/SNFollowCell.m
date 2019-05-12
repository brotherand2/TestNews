//
//  SNFollowCell.m
//  sohunews
//
//  Created by weibin cheng on 14-3-6.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNFollowCell.h"
#import "SNUserConsts.h"
#import "SNBubbleBadgeObject.h"

@implementation SNFollowCell
@synthesize pid = _pid;
@synthesize userinfo = _userinfo;
@synthesize arrow = _arrow;
@synthesize followPid = _followPid;
-(void)dealloc
{
     //(_userinfo);
     //(_arrow);
     //(_followPid);
     //(_bubbleView);
    [SNNotificationManager removeObserver:self];
}

-(id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self)
    {
        _followedLabel.hidden = YES;
        
        _userNameButton.userInteractionEnabled = NO;
        while (_userImageView.gestureRecognizers.count)
            [_userImageView removeGestureRecognizer:[_userImageView.gestureRecognizers objectAtIndex:0]];
        [SNNotificationManager addObserver:self selector:@selector(onGuideRegisterSuccess:) name:kGuideRegisterSuccessNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
	}
	return self;
    
}
-(void)onGuideRegisterSuccess:(NSNotification*)notification
{
    if(self.followPid)
    {
        _followButton.hidden = YES;
        [_loadingActivity startAnimating];
        [_followService followUserWithFpid:_userinfo.pid];
        self.followPid = nil;
    }
}

-(void)hideFollowedLabel
{
    _followedLabel.hidden = YES;
}

-(void)showFollowedLabel
{
    _followedLabel.hidden = NO;
}

-(void)initArrayIfNeeded
{
    if(_arrow==nil)
    {
        UIImage* image = [UIImage imageNamed:@"arrow.png"];
        _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 7, 12)];
        _arrow.image = image;
        _arrow.center = _followButton.center;
        _arrow.left = kAppScreenWidth-20;
        [self.contentView addSubview:_arrow];
    }
}

-(void)reuseWithUser2:(SNUserinfoEx*) newUser cellIndexPath:(NSIndexPath *)indexPath
{
    if (!newUser)
        return;
    
    self.userinfo = newUser;
    self.cellIndexPath = indexPath;
    _bubbleView.tipCount = 0;
    _arrow.hidden = YES;
    
    if(self.userinfo.headImageUrl.length>0)
        [_userImageView setIconUrl:newUser.headImageUrl passport:newUser.password gender:[newUser.gender intValue]];
    else
        _userImageView.icon.defaultImage = [UIImage themeImageNamed:@"login_user_defaultIcon.png"];
    _userImageView.alpha = themeImageAlphaValue();
    
    [_userNameButton setTitle:[_userinfo getNickname] forState:UIControlStateNormal];
    CGSize nameSize = [_userNameButton.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0]];
    nameSize.width = nameSize.width>200 ? 200:nameSize.width;
    _userNameButton.frame = CGRectMake(USER_NAME_LEFT, 24, nameSize.width, USER_NAME_HEIGHT);
    [_userNameButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor]] forState:UIControlStateNormal];
    
    //    NSDictionary* dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"SNCircle_Relation_patch"];
    //    NSString* relation = [dic objectForKey:newUser._pid];
    //    if(relation.length==0)
    //        relation = (NSString*)_userinfo._relation;
    NSString* relation = _userinfo.relation;
    if(relation!=nil && [relation intValue]==SNCircleFollowing){
        _followButton.hidden = YES;
        _followedLabel.hidden = NO;
    }
    else  if((relation!=nil && [relation intValue]==SNCircleSelf) || [_userinfo isSelfUser]){
        _followButton.hidden = YES;
        _followedLabel.hidden = YES;
    }
    else{
        _followButton.hidden = NO;
        _followedLabel.hidden = YES;
    }
}

//-(void)followUserSucceedWithType:(SNRequestType) type
//{
//    //当前登陆用户与当前被访问用户的关系(0未关注 1 已关注 -1自己)
//    NSString* relation;
//    if(type==SNRequestTypeAddFollow) relation = @"1";
//    else relation = @"0";
//
//    NSMutableDictionary* dic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SNCircle_Relation_patch"] mutableCopy];
//    [dic setObject:relation forKey:_userinfo._pid];
//    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"SNCircle_Relation_patch"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [dic release];
//}

-(void)reuseWithUser2_addFriend:(SNUserinfoEx*) newUser cellIndexPath:(NSIndexPath *)indexPath
{
    if (!newUser)
        return;
    
    [self initArrayIfNeeded];
    _arrow.hidden = NO;
    
    self.userinfo = newUser;
    self.cellIndexPath = indexPath;
    _followedLabel.hidden = YES;
    
    if(_bubbleView == nil)
    {
        _bubbleView = [[SNBubbleTipView alloc] initWithType:SNTableBubbleType];
        CGRect bubbleRect;
        bubbleRect.origin.x = _arrow.frame.origin.x - _bubbleView.defaultWidth - 10;
        bubbleRect.origin.y = 22;
        bubbleRect.size.width = _bubbleView.defaultWidth;
        bubbleRect.size.height = _bubbleView.defaultHeight;
        _bubbleView.frame = bubbleRect;
        [self.contentView addSubview:_bubbleView];
    }
    if([_userinfo.nickName isEqualToString:@"添加好友"])
        [_bubbleView setTipCount:[SNBubbleNumberManager shareInstance].ppfollowing];
    else
        [_bubbleView setTipCount:0];
    
    NSString* image = @"circle_add.png";
    [_userImageView resetDefaultImage:[UIImage imageNamed:image]];
    _userImageView.alpha = themeImageAlphaValue();
    [_userNameButton setTitle:_userinfo.nickName forState:UIControlStateNormal];
    CGSize nameSize = [_userNameButton.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0]];
    nameSize.width = nameSize.width>200 ? 200:nameSize.width;
    _userNameButton.frame = CGRectMake(USER_NAME_LEFT, 24, nameSize.width, USER_NAME_HEIGHT);
    [_userNameButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor]] forState:UIControlStateNormal];
    
    NSString* relation = (NSString*)_userinfo.relation;
    if(relation!=nil && [relation intValue]==SNCircleFollowing){
        _followButton.hidden = YES;
    }
    else  if(relation!=nil && [relation intValue]==SNCircleSelf){
        _followButton.hidden = YES;
    }
    else{
        _followButton.hidden = YES;
    }
}

-(void)followUser
{
    if([SNUserinfoEx isLogin])
    {
        _followButton.hidden = YES;
        [_loadingActivity startAnimating];
        // Cae. 修改加载效果后注释掉了。
        //_loadingActivity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [_followService followUserWithFpid:_userinfo.pid];
    }
    else
    {
        [SNGuideRegisterManager showGuideForAttention:_userinfo.headImageUrl userName:_userinfo.nickName];
        [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_FOLLOW referId:_userinfo.pid referAct:SNReferActFollow];
        self.followPid = _userinfo.pid;
    }
}

-(void)followedUserSucceedWithType:(SNRequestType)type
{
    [super followedUserSucceedWithType:type];
    //[_model performSelector:@selector(circle_userinfoRequest:) withObject:_pid];
    
    if(type==SNRequestTypeAddFollow)
        _userinfo.relation = [NSString stringWithFormat:@"%ld", (long)SNCircleFollowing];
    else  if(type==SNRequestTypeCancelFollow)
        _userinfo.relation = [NSString stringWithFormat:@"%ld", (long)SNCircleUnFollow];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:2];
    [dic setObject:_userinfo.relation forKey:@"relation"];
    [dic setObject:_userinfo.pid forKey:@"pid"];
    [SNNotificationManager postNotificationName:kUserCenterFollowUpdateNotification object:nil userInfo:dic];
}

- (void)updateTheme {
    _arrow.image = [UIImage imageNamed:@"arrow.png"];
    [self setNeedsDisplay];
}
@end
