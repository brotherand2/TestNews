//
//  SNGuideRegisterManager.h
//  sohunews
//
//  Created by jialei on 13-8-8.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRegisterInfoKeyTitle           @("kRegisterInfoKeyTitle")
#define kRegisterInfoKeyName            @("kRegisterInfoKeyName")
#define kRegisterInfoKeyImage           @("kRegisterInfoKeyImage")
#define kRegisterInfoKeyImageUrl        @"kRegisterInfoKeyImageUrl"
#define kRegisterInfoKeyText            @("kRegisterInfoKeyText")
//#define kRegisterInfoKeyDelegate        @("kRegisterInfoKeyDelegate")
#define kRegisterInfoKeyGuideType       @"kRegisterInfoKeyGuideType"
#define kRegisterInfoKeySubId           @"kRegisterInfoKeySubId"
#define kRegisterInfoKeyUserPid         @"kRegisterInfoKeyUserPid"
#define kRegisterInfoKeyUserLink        @"kRegisterInfoKeyUserLink"
#define kRegisterInfoKeyFavObject       @"kRegisterInfoKeyFavObject"
#define kRegisterInfoKeyNewsId          @"kRegisterInfoKeyNewsId"
#define kRegisterInfoKeyChannelId       @"kRegisterInfoKeyChannelId"
#define kRegisterInfoKeyBackUrl         @"kRegisterInfoKeyBackUrl"
#define kRegisterInfoKeyActId           @"kRegisterInfoKeyActId"
#define kRegisterInfoKeyApprovalType    @"kRegisterInfoKeyApprovalType"

typedef NS_ENUM(NSInteger, SNGuideRegisterType)
{
    SNGuideRegisterTypeUnknow           = -1,
    SNGuideRegisterTypeSubscribe        = 0,
    SNGuideRegisterTypeContentComment   = 1,
    SNGuideRegisterTypeMediaComment     = 2,
    SNGuideRegisterTypeShake            = 3,
    SNGuideRegisterTypeUsercenter       = 4,
    SNGuideRegisterTypeUserAttention    = 5,
    SNGuideRegisterTypeLogin            = 6,
    SNGuideRegisterTypeFav              = 7,
    SNGuideRegisterTypeMessage          = 8,
    SNGuideRegisterTypeFavNews          = 9,
    SNGuideRegisterTypeReport           = 10,
    SNGuideRegisterTypeStar             = 11,
    SNGuideRegisterTypeProtocolLogin    = 12,
    SNGuideRegisterTypeTrendApproval    = 13,
    SNGuideRegisterTypeH5LiveInvite     = 14,
    SNGuideRegisterTypeBackToUrl        = 15,
    SNGuideRegisterTypeReplayComment    = 16,
};

@interface SNGuideRegisterManager : NSObject

//订阅引导登陆
+ (void)showGuideWithSubId:(NSString *)subId;
/*
 *登陆成功后订阅
 *param (NSString *)subId 订阅ID 
 */
+ (void)guideForSubscribe:(NSString *)subId;
//评论引导登陆
+ (void)showGuideWithContentComment:(NSString *)loginFrom;
+ (void)showGuideWithContentCommentImage;
+ (void)showGuideWithContentCommentAudio;

//H5页面内直播邀请
+ (void)showGuideWithH5LiveInvite;

//评论引导登陆成功操作
+ (void)guideForContentComment;
//回复评论引导登陆成功操作
+ (void)guideForReplyComment;
//摇一摇引导登陆
+ (void)showGuideWithShake:(NSString*)subId;
+ (void)guideForShake:(NSString *)subId;
//自媒体评论
+ (void)showGuideWithMediaComment:(NSString *)subId;
+ (void)guideForMediaComment;
//进入用户中心引导登陆
+ (void)showGuideWithUserCenter:(NSString *)pid userSpace:(NSString *)link subUser:(SCSubscribeObject *)subObj;
+ (void)guideForUserCenter:(NSString *)pid userSpace:(NSString *)link;
//登录提示
+ (void)showLoginActionSheetWithDict:(NSDictionary *) dict;

//用户中心关注
+ (void)showGuideForAttention:(NSString *)iconUrl userName:(NSString *)name;
+ (void)guideForAttention;
//弹出引导界面
+ (BOOL)popGuideRegisterController:(NSArray*)conntrollerArray popController:(UIViewController *)controller;

//登陆
+ (void)login:(NSString *)loginFrom;
+ (void)showUserCenter;


+ (void)showMyFav;
+ (void)showMyFavByFloat;

+ (void)myMessage;
+ (void)showMyMessage;
+ (void)showMyMessageByFloat;

//添加好友
+ (BOOL)showAddFriend;

//赞动态引导登陆
+ (void)showGuideWithApproval:(NSString *)actId pid:(NSString *)pid approvalType:(int)type;

//二代协议登陆
+ (void)protocolLogin:(NSString*)backUrl dictInfo:(NSDictionary *)dictInfo;

+ (void)gotoLoginSuccessBackUrl;

@end
