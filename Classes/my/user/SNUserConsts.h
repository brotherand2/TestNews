//
//  SNUserConsts.h
//  sohunews
//
//  Created by weibin cheng on 14-2-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#define kSetCookie @"set-Cookie"
#define kPassportAppId @"1106"
#define kPassportSignKey @"UGA7aNYJeU)Uc6@16E*2C759Bo3fTc"



//relation	整型	当前登陆用户与当前被访问用户的关系(0未关注 1 已关注 -1自己)
typedef NS_ENUM(NSInteger, SNCircleFollowType)
{
	SNCircleUnFollow = 0,
	SNCircleFollowing = 1,
	SNCircleSelf = -1
};

//用户类型
typedef NS_ENUM(NSInteger, SNUserType)
{
    SNUserTypePeople = 0,   //普通用户
    SNUserTypeOrganization, //政企用户
    SNUserTypeMedia         //媒体用户
};

static NSString *const kUserExpire = @"SNUserExpire";
