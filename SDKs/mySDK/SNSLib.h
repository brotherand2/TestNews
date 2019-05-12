//
//  Lib.h
//  Lib
//
//  Created by 黄 敬 on 14-11-26.
//  Copyright (c) 2014年 n. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
typedef NS_ENUM(NSInteger,AppRunStatus)
{
    RunStatus_applicationWillResignActive = 1,
    RunStatus_applicationDidEnterBackground,
    RunStatus_applicationWillEnterForeground,
    RunStatus_applicationDidBecomeActive,
    RunStatus_applicationWillTerminate
};
#pragma mark -
@protocol SNSProtocol <NSObject>
// 获取新闻客户端加载更多视图 SNTwinsMoreView
- (UIView *)getMoreAnimationViewWithFrame:(CGRect)frame;

// 获取新闻客户端下拉视图 SNTwinsLoadingView
- (UIView *)getLoadingViewWithFrame:(CGRect)frame ObservedScrollView:(UIScrollView *)scrollView;

// 获取空页面加载视图 SNTripletsLoadingView
- (UIView *)getTripletsLoadViewWithFrame:(CGRect)frame;

- (UIView *)getTripletsLoadViewForVideoWithFrame:(CGRect)frame;


//更新用户信息
- (void)updateUserWithInfo:(NSDictionary *)info;/*
                                                 *avatar 头像
                                                 *city 城市
                                                 *description 描述
                                                 *followCount 关注数
                                                 *followerCount 粉丝数
                                                 *sex 性别 0女 1男
                                                 *userId 用户id
                                                 *userName 用户昵称
                                                 *mobile 手机号
                                                 */

//获取第三方登录信息
- (NSDictionary *)getThirdLoginInfo; /*avatar 头像
                                      userName 用户昵称*/

//获取 新浪微博绑定状态 Dictionary需包含是否绑定及绑定的openId key为sinaOpenid及sinabindStatus
- (NSDictionary *)getBindSinaStatusInfo;

//提示框调用
- (void)showToastWithTitle:(NSString *)title toUrl:(NSString *)url mode:(int)toastMode onView:(UIView *)view;

//中心提示框
- (void)showCenterToastWithTitle:(NSString *)title mode:(int)mode;

// 跳转的新闻详情页
- (void)pushToNewsViewControllerWith:(NSDictionary *)info;

// 新浪微博绑定跳转
- (void)pushToBindSinaAccountViewController;

//申请开通媒体帐号
- (void)pushToApplyForMediAccountViewController;

//跳转城市界面
- (void)pushToCityViewController;

//跳转绑定手机界面
- (void)pushToBindPhoneViewController;

//获取当前小红点状态 YES为显示
- (BOOL)getRedPointShowStatus;

//改变小红点状态 YES为显示
- (void)changeRedPointShowStatus:(BOOL)show;

//跳转到管理自媒体
- (void)pushToManageMediaViewControllerWith:(NSDictionary *)info;

//跳转到登录页
- (void)pushToLoginViewController:(NSString *)loginfrom;

//login callback
- (void)callSohuNewsLogin:(NSString*)loginFrom WithCallBack:(void (^)(NSDictionary*info))method;

//wangshun  登录半屏浮层 2017.10.9
/** params : {@"loginFrom":xxxx,@"halfScreenTitle":xxxx}
 */
- (void)callHalfSohuNewsLogin:(NSDictionary*)params WithCallBack:(void (^)(NSDictionary*info))method;

//获取登录状态
- (NSDictionary *)getLoginStatusInfo;

//根据pid获取passport信息
- (void)getPassPortByPid:(NSString *)pid callback:(void (^)(NSString *passport))result;

//跳转到自媒体首页
- (void)jumpToMediaCenter:(NSString *)link hideShare:(BOOL)hideShare;

//跳转分享界面
- (void)jumpToShareCenter:(NSString *)link;

//获取新闻客户端传递的passport appkey和appID
- (NSDictionary*)getPassportParams:(id)sender;

#pragma mark - sns调用退出
//退出登录 sns调用
- (void)loginOutWithInfo:(NSDictionary *)info;

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType offLine:(BOOL)offLine;;

- (void)connectWebviewWithBridge:(UIWebView *)webView withSubId:(NSString *)subID callback:(void (^)(NSString *subId))down;

- (void)loadOffLineWebView:(UIWebView *)webView other:(void (^)(NSDictionary *dictionary))other withInfo:(NSDictionary *)info;

//获取当前导航
- (UINavigationController *)getNav;

//获取设备类型
- (NSString *)platformStringForSohuNews;

- (NSString *)getLongitude;

- (NSString *)getLatitude;
//更新位置
- (void)reLocation;
//获取渠道号
- (NSString *)getMarketId;

//后台统计
- (void)addLog:(NSString *)string;

//返回首页
- (void)popToRoot;
//返回上级页面
- (void)popToPreview;
//获取狐友tab上的文字
- (NSString *)getTabItemText;

//端外回流，退出大屏时调用，禁用universal link跳转，新闻端需求
- (void)resetOpenInSafariView;

- (CTTelephonyNetworkInfo *)creatTelephonyNetworkInfo;
@end

#pragma mark -

typedef void (^ICallbackMap)(BOOL isStatusOk,NSDictionary *resultInfo);
@interface SNSLib : NSObject
@property (nonatomic, weak) id<SNSProtocol>delegate;
/*
 *YES为夜间模式,默认NO.新闻端修改夜间模式时请修改此值
 */
@property (nonatomic, assign) BOOL isNight;

@property (nonatomic,assign) BOOL isMyPage; //是否在我的模块相关界面

/*
 *分享到我的
 *如果想发送图片，请增加如下字段
  type//图片的时候传3(之所以为3是和第三方分享的二代协议的type一致)，其他情况不传
  imageData//图片的data 或者 imageUrl//图片的链接
 */
+ (void)shareToSns:(NSDictionary *)shareInfo callback:(ICallbackMap)result;
//外部app分享
+ (void)shareThirdAppMessageToSns:(NSDictionary *)shareInfo callback:(ICallbackMap)result;
/*
 *新闻端衔接单例
 *第一次初始化后请赋值delegate
 */
+ (SNSLib *)sharedInstance;
/*
 *info为登录后sdk所需参数
 *key&value统一定为NSString类型
 *passport的key先定为 @"userId"、@"token"、@"cid"
 *登录类型和第三方登录key后续再定
 */
#pragma mark - 退出回调
//配置登录信息
+ (void)setupWithInfo:(NSDictionary *)dic;

//获取登录 viewController
+ (UIViewController *)getTimeLineViewControlWithDictionary:(NSDictionary *)info;

//新浪微博绑定后回跳  info 需包含openId
+ (void)sinaBindBackWithDictionary:(NSDictionary *)info;

//城市回调方法
+ (void)chooseCity:(NSDictionary *)cityInfo;

//绑定手机后的回调
+ (void)bindPhoneWith:(NSDictionary *)info;

////退出登录 新闻端回调 @“loginOut” : @"1" 或 @“0”
+ (void)loginOutWith:(NSDictionary *)info;

//点击tabBar我的
+ (void)clickTabLastSelsct:(int)lastIndex andClickSelext:(int)index;
/* info的相关key
 "pid"              prfile的pid                有传无不传
 "profileUserId"    prfile的passportId         有传无不传
 "subId"           刊物页的subId               有传无不传
 "protocolLink2"    二代协议                    有传无不传
 "type"             来源类型                    必须传
 */
//跳转profile页
+ (void)pushToProfileViewControllerWithDictionary:(NSDictionary *)info;

//通过App Delegate 的openUrl传过来的操作
+ (void)actionFromOpenUrl:(NSString *)info;

//获取初始登录界面 viewController
+ (UIViewController *)getPlaygroundViewControlWithDictionary:(NSDictionary *)info;

//获取登录成功sns需要push的ViewController ****为nil时不要push****
+ (UIViewController *)forLoginSuccessToPush;

//当app运行状态发生改变时通知SNS
+ (void)appRunStatus:(AppRunStatus)status;

/**
 清理sns视频本地缓存
 */
+ (void)clearSnsVideoCache;

/**
 获取sns视频当前缓存的文件大小，单位是字节（B）返回-1是调用失败，需要在非播放情况下调用
 */
+ (long long)getSnsVideoCacheSize;

//红包
+ (void)openRedPacketInSNS:(NSDictionary *)packetInfo;

/**
 获取sns用户信息
 
 @return passportId、token、gid、name、avater
 */
+ (NSDictionary *)getSnsUserInfo;


/**
 sns用户是否登录，千帆SDK登录需要用到
 
 @return YES:已登录 NO:未登录
 */
+ (BOOL)isSnsUserLogin;


/**
 sns用户登录通知的名称，初始化千帆SDK用到
 
 @return sns用户登录通知的名称
 */
+ (NSString *)getSnsUserLoginNotiName;

/**
 sns用户登出通知的名称，初始化千帆SDK用到
 
 @return sns用户登出通知的名称
 */
+ (NSString *)getSnsUserLogoutNotiName;



/**
 在狐友页面时，推送弹窗是否允许打开展示
 
 @return YES:允许, NO:禁止
 */
+ (BOOL)isPushViewShouldOpenInSNSView;


/**
 更新sns的session，tabbar切换时更新（包含点击切换及二代协议切换）
 目前是切到新闻tab及狐友tab时更新
 */
+ (void)updateSnsSessionWithTabbarSelectedIndex:(NSUInteger)selectedIndex;


/**
 统计新闻端登录埋点
 2017-08-15，产品@郝志杰 确认，要求上传到md3
 @param key 渠道号
 @param dict 业务相关信息
 
 格式举例：
 [SNSLogCollectorInstance addUserBehaviorLogWithKey:@"feed_stay"
 bodyDic:@{@"cid":[UserModel sharedInstance].cid,
         @"feedId":self.feedModel.feedId,
         @"type":typeStr,
         @"startTime":startTime,
         @"endTime":endTime}];

 */
+ (void)addCountForSohuNewsLoginEventWithKey:(NSString *)key
                              bodyDic:(NSDictionary *)dict;

/**
 app收到push 用于清理badge数
*/
+ (void)clearSNSBadgeNumberWithRemoteNotification:(NSDictionary *)receivedUserInfo;

/**
 狐友push设置页
 */
+ (UIViewController *)remoteNotificationSettingController;

/**
 获取push点击埋点参数 参数为push的二代协议
 */
+ (NSDictionary *)parameterForPushProtocalUrl:(NSString *)aUrl;

+ (BOOL)updatePassportInfo:(NSDictionary*)ppInfo;

@end
