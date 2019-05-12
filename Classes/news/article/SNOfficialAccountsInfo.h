//
//  SNOfficialAccountsInfo.h
//  sohunews
//
//  Created by HuangZhen on 21/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOffsetTopKey           (@"offsetTop")  //int类型 公众号信息区离页面顶部距离多少像素
#define kHeightKey              (@"height")     //int类型 公众号信息区高度
#define kSubNameKey             (@"subName")    //String类型 公众号名
#define kSubIconKey             (@"subIcon")    //String类型 公众号头像URL
#define kSubIdKey               (@"subId")      //String类型 公众号id
#define kSubLinkKey             (@"subLink")    //String类型 公众号profile page link
#define kTimeKey                (@"time")       //String类型 文章发布时间
#define kIsFollowedKey          (@"isFollowed") //Boolean类型 当前用户是否关注了公众号，true代表已关注，false代表未关注

typedef enum : NSUInteger {
    SNFollowedStatusFailed = -1,//接口请求失败
    SNFollowedStatusNone = 0,//0表示未建立关注关系
    SNFollowedStatusFollowing,//1表示登录用户单向关注此用户
    SNFollowedStatusFriend,//2表示登录用户和此用户为双向关注关系
    SNFollowedStatusFollower,//3表示此用户单向关注登录用户
    SNFollowedStatusSelf //4 表示自己
} SNFollowedStatus;

typedef void (^CheckFollowStatusCompleted)(SNFollowedStatus followedStatus);

@interface SNOfficialAccountsInfo : NSObject

//@property (nonatomic, assign, readonly) BOOL needHideStatusBar;

@property (nonatomic, weak) UIViewController * controller;

@property (nonatomic, copy) NSString * newsId;
@property (nonatomic, copy) NSString * channelId;

- (instancetype)initWithTargetWebView:(UIWebView *)webView position:(CGPoint)position h5Type:(NSString *)h5Type;

- (void)show;

- (void)hide;

- (void)updateTheme;

//- (void)autoHideFakeStatusBar;

//- (void)cropCurrentStatusBar;

- (void)updateWithJSON:(NSDictionary *)json;

- (void)h5UpdateWithJSON:(NSDictionary *)json;

- (void)checkFollowedStatus;

+ (void)checkFollowStatusWithSubId:(NSString *)subId completed:(CheckFollowStatusCompleted)completed;

@end
