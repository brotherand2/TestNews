//
//  SNShareManager.h
//  sohunews
//
//  Created by yanchen wang on 12-5-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNShareList.h"
#import "SNUserinfo.h"
#import "SNUserinfoService.h"

#import "CacheObjects.h"
#import "SNEmbededActivityIndicator.h"

#define kShareInfoKeyShareTo            @"shareTo"
#define kShareInfoKeyShareLink          @"shareLink"
#define kShareInfoKeyContent            @"content"
#define kShareInfoKeyComment            @"shareComment"
#define kShareInfoKeyShareContent       @"shareContent"
#define kShareInfoKeyShareType          @"shareType"
#define kShareInfoKeyScreenImagePath    @"screenImagePath"
#define kShareInfoKeyImagePath          @"imagePath"
#define kShareInfoKeyImageUrl           @"imageUrl"
#define kShareInfoKeyTitle              @"title"
#define kShareInfoKeyShareComment       @"shareComment"
#define kShareInfoKeyDelegatge          @"kEditorKeyDelegatge"
#define kShareInfoKeySubId              @"subId"
#define kShareInfoLogKeySubId           @"logSubId"
#define kShareInfoKeySource             @"Source"
#define kShareInfoKeyNewsId             @"newsId"
#define kShareInfoKeyGroupId            @"gid"
#define kShareInfoKeyLongitude          @"long"
#define kShareInfoKeyLatitude           @"lat"
#define kShareInfoKeyShareDelegate      @"shareDelegate"
#define kShareInfoKeyPersonCount        @"personCount"
#define kShareInfoKeyInfoDic            @"kShareInfoKeyInfoDic"
#define kShareInfoKeyUgcLimitWord       @"kShareInfoLimitWord"
#define kShareInfoKeyUserName           @"userName"

#define kShareInfoKeyShareRead          @"shareRead"
#define kPresentFromWindowDelegate      @"presentFromWindowDelegate"
#define kShareInfoKeyHtmlContent        @"htmlContent"
#define kShareInfoKeyNoteSourceURL      @"noteSourceURL"
#define kShareInfoKeyThumbImage         @"thumbImage"
#define kChannelPreviewPage             @"isChannelPreviewPage"
#define kChannelPreviewAnimationDuration      (0.5)

//weixin
#define kShareInfoKeyWebUrl             @"webUrl"
#define kShareInfoKeyMediaUrl           @"mediaUrl"

#define kShareInfoValueSina             @"新浪"
#define kShareInfoValueSohu             @"搜狐"
#define kShareInfoValueQQ               @"腾讯"

#define kSSOLoginTypeKey                @"kSSOLoginTypeKey"

#define kUserCenterLoginAppId           @"kUserCenterLoginAppId"

#define kSNShareManagerNoError          (-1)
#define kSNShareManagerErrorCode        (1012)

/*
 login：登录，返回用户中心信息
 bind：绑定，返回用户中心信息
 loginWithBind：登录并绑定，返回登录账号对应的绑定列表
 */

// string enum for login type
#define kSSOLoginTypeLogin              @"login"
#define kSSOLoginTypeBind               @"bind"
#define kSSOLoginTypeLoginWithBind      @"loginWithBind"

// notify

typedef enum {
    SNShareManagerAuthLoginTypeLogin = 1,
    SNShareManagerAuthLoginTypeBind,
    SNShareManagerAuthLoginTypeLoginWithBind
}SNShareManagerAuthLoginType;

typedef NS_ENUM(NSInteger, SNShareContentType) {
    SNShareContentTypeJson = 0,
    SNShareContentTypeString = 1
};

#pragma mark- shareItem
@interface SNShareItem : NSObject {
}

@property (nonatomic, assign)SNShareContentType  shareContentType;

@property (nonatomic, copy)NSString *shareContent;
@property (nonatomic, copy)NSString *shareTitle;
@property (nonatomic, copy)NSString *shareId;
@property (nonatomic, assign)int sourceType;
@property (nonatomic, copy)NSString *shareLink;      //资源对应二代协议
@property (nonatomic, copy)NSString *ugc;

@property (nonatomic, copy)NSString *appId;
@property (nonatomic, copy)NSString *shareImageUrl;
@property (nonatomic, copy)NSString *shareImagePath;
@property (nonatomic, copy)NSString *shareNewsUrl;   //文章连接
@property (nonatomic, assign)BOOL fromComment;

@property (nonatomic, assign)BOOL needTip;

@property (nonatomic, assign)BOOL isNotRealShare;

@end


#pragma mark- shareManager
@class SNShareManager;
@class SNTimelineOriginContentObject;
@protocol SNShareManagerDelegate <NSObject>

@required
- (void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController;

@optional
// 绑定
- (void)shareManagerDidAuthSuccess:(SNShareManager *)manager;
- (void)shareManagerDidAuthAndLoginSuccess:(SNShareManager *)manager;
- (void)shareManagerDidCancelAuth:(SNShareManager *)manager;
- (void)shareManager:(SNShareManager *)manager didAuthFailedWithError:(NSError *) error;
- (BOOL)shareManagerShouldModalAuthViewController:(SNShareManager *)manager;

// 取消绑定
- (void)shareManagerDidCancelBindingSuccess:(SNShareManager *)manager;
- (void)shareManagerDidCancelBindingFail:(SNShareManager *)manager;

// 分享
- (void)shareManagerShareSuccess:(SNShareManager *)manager;
- (void)shareManagerShareFailed:(SNShareManager *)manager;

// 分享带评论 回传评论内容
- (void)shareManager:(SNShareManager *)manager willShareComment:(NSString *)comment;

@end

@interface SNShareManager : NSObject<SNUserinfoServiceGetUserinfoDelegate,TTURLRequestDelegate>
{
    id<SNShareManagerDelegate> __weak _delegate;
    id<SNShareManagerDelegate> __weak _shareDelegate;
    NSDictionary *_shareDicInfo;
    SNUserinfoService*  _userinfoModel;
    BOOL _isNotRealShare;
}

@property(nonatomic, weak)id<SNShareManagerDelegate> delegate;
@property(nonatomic, weak)id<SNShareManagerDelegate> shareDelegate;
@property(nonatomic, strong)NSDictionary *shareDicInfo;
@property (nonatomic, assign)BOOL needTip;
@property (nonatomic, strong)NSString *loginFrom;
@property (nonatomic, strong)NSString *loginType;
@property (nonatomic, assign)BOOL isVideo;
@property (nonatomic, assign)BOOL isVideoShare;
@property (nonatomic, assign)BOOL isQianfanShare;
@property (nonatomic, strong)NSString *shareLink;
@property (nonatomic, assign)int sourceType;
@property (nonatomic, assign) NSTimeInterval lastShareTime;
+ (void)startWork;
+ (SNShareManager *)defaultManager;

// 分享列表
- (NSArray *)shareList; // 返回所有的item
- (NSArray *)itemsCouldShare; // 返回可以分享的items数组
- (NSArray *)namesBinded; // 返回所有的绑定账号的昵称
- (NSArray *)itemsBinded; // 返回所有的绑定的shareitem
- (void)updateShareList;

// 绑定相关

// 下面这个方法已经改为私有方法了 防止再少传了参数出现问题 -- 替代方法在下面
//- (void)authrizeByAppId:(NSString *)appId delegate:(id<SNShareManagerDelegate>)delegate; // 绑定
- (void)cancelAuthrizeByAppId:(NSString *)appId delegate:(id<SNShareManagerDelegate>)delegate; // 取消绑定
- (void)changedUserByAppId:(NSString *)appId delegate:(id<SNShareManagerDelegate>)delegate;
- (BOOL)isAppAuthrized:(NSString *)appId;

// 用户中心登录 如果登录的第三方支持sso  return yes 后面的流程就不用关心 拿到token自动调用下面的上传同步token
- (BOOL)loginByAppId:(NSString *)appId loginType:(SNShareManagerAuthLoginType)loginType delegate:(id<SNShareManagerDelegate>)delegate loginFrom:(NSString *)loginFrom;

// 绑定v2.0
- (void)authrizeByAppId:(NSString *)appId loginType:(SNShareManagerAuthLoginType)loginType delegate:(id<SNShareManagerDelegate>)delegate;

// 同步sso拿到的token到服务器
/** 参数
 *
    syncToken:(NSString *)token // 必须的参数
    refreshToken:(NSString *)refreshToken // 如果有就必须传
    expire:(NSDate *)expireDate // 过期时间  必须的参数
    userName:(NSString *)userName // 有就传
    userId:(NSString *)userId // 必须的参数
    appId:(NSString *)appId // 必须的参数
 */
- (BOOL)syncToken:(NSString *)token // 必须的参数
     refreshToken:(NSString *)refreshToken // 如果有就必须传
           expire:(NSDate *)expireDate // 过期时间  必须的参数
         userName:(NSString *)userName // 有就传
           userId:(NSString *)userId // 必须的参数
            appId:(NSString *)appId; // 必须的参数

// 取消掉同步token的请求 
- (void)cancelSyncTokenRequest;

/** QQ SSO 同步token
 @p1
 @nickName	 第三方返回的昵称
 @appId	 对应的第三方编号 为 6
 @openId	  第三方唯一标示，腾讯叫openId，其他第三方名字可能不同
 @from	 字符串 请求入口： 值为login：登陆，返回用户中心信息 值为loginWithBind：登陆并绑定，返回登陆账号对应的绑定列表
 @version	 字符串	version 值为3.0 区分于之前的两版登陆
 @refer	 整型	统计使用
 @gender	 整型	性别：1男 2女
 @gid	 字符串	手机的唯一标示号
 @headUrl	 url 头像
 */

- (BOOL)qqSyncTokenWithAppId:(NSString *)appId
                      openId:(NSString *)openId
                    userInfo:(NSDictionary *)userInfo;

// start share  v2.0
- (void)startShareControllerWithShareInfo:(NSDictionary *)shareInfoDic;
// 4.2分享接口重构，上传本地图片和网络图片url，分享json格式content和stirng格式content合并为一个接口
- (void)postShareItemToServer:(SNShareItem *)shareItem;

- (BOOL)isAppIdLoginForUserCenter:(NSString *)appId;

@end
