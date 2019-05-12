/*
 *  SNUtility.h
 *  sohunews
 *
 *  Created by zhukx on 11-4-18.
 *  Copyright 2011 sohu.com. All rights reserved.
 *
 */

#import "SNConsts.h"
#import "sohunewsAppDelegate.h"
#import "AesEncryptDecrypt.h"
#import "UIImage+Utility.h"
#import <QuartzCore/QuartzCore.h>
#import "SNAnalytics.h"
#import "UIMenuController+Observe.h"
#import "SNFileSystemSize.h"
#import "CoreGraphicHelper.h"
#import "UIApplication+KeyboardView.h"
#import "NSArray+Utilities.h"
#import "NSDate-Utilities.h"
#import "NSString+Utilities.h"
#import "UIControl+Blocks.h"
#import "UIFontAdditions.h"
#import "UIDevice-Hardware.h"
#import "NSData+Utilities.h"
#import "SNChannel.h"
#import "SNBaseViewController.h"
#import "caltime.h"
#import "SNUserSettingRequest.h"
#import "SNWebViewManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "SNUserDefaults.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

typedef enum
{
    SNSettingSmallFont = 13, //小号字体，废弃
    SNSettingMiddleFont = 16,//小号字体
    SNSettingBigFont = 18,   //中号字体
    SNSettingMoreBigFont = 22//大号字体
} SNSettingFontSize;

/*
    统计打开Profile页的来源
 */
typedef enum {
    SNProfileRefer_Article_UserName     = 1,     //作者用户名
    SNProfileRefer_Article_Subscribe    = 2,     //订阅区块
    SNProfileRefer_Article_CommentUser  = 3,     //我来说两句用户
    SNProfileRefer_Article_ViewComment  = 4,     //我来说两句成功后浮层“查看评论”
    SNProfileRefer_Subscribe_MeMedia    = 5,     //订阅频道自媒体
    SNProfileRefer_Live_UserName        = 6,     //直播用户
    SNProfileRefer_Search_UserName      = 7      //搜索结果中订阅用户
} SNProfileRefer;

//A/B 测试4种界面风格类型
typedef enum{
    SNAppABTestStyleNO,
    SNAppABTestStyleAB, //默认样式
    SNAppABTestStyleAb,
    SNAppABTestStyleaB,
    SNAppABTestStyleab,
    SNAppABTestStyVideoChanged,//频道流视频样式改变
    SNAppABTestStyVideoDefault,//频道流视频样式保持不变
}SNAppABTestStyle;

//调起app来源
typedef NS_ENUM(NSInteger, SNOpenAppOriginFromType) {
    SNOpenAppOriginFromUniversalLink,//回流
    SNOpenAppOriginFromPush,//push
    SNOpenAppOriginFromWidget,//widget
    SNOpenAppOriginFromSpotLight,//spotlight
    SNOpenAppOriginFromOther
};

@interface SNUtility : NSObject<CAAnimationDelegate> {
	
}
@property (nonatomic, copy) NSString *currentChannelId;
@property (nonatomic, copy) NSString *currentChannelCategoryID;
@property (nonatomic, strong) NSString *currentChannelGbcode;
@property (nonatomic, copy) NSString *lastOpenUrl;
@property (nonatomic, assign) NSInteger lastArc4randomX; //记录上次数据库存储随机数
@property (nonatomic, strong) NSString *thirdPartName;
@property (nonatomic, assign) BOOL isShowRightSlipeTips;   //正文页右滑返回引导提示是否显示中

@property (nonatomic, assign) BOOL isShowSpecialActivity;//显示可定制活动弹窗

@property (nonatomic, strong) CTTelephonyNetworkInfo *tNetworkInfo;
@property (nonatomic, assign) BOOL isOpenFromUniversalLinks;//端外回流调起
@property (nonatomic, assign) BOOL isWrongP1RequestNewsList;//初次请求news.go时是否使用正确p1
@property (nonatomic, assign) BOOL isEnterBackground;//进入后台
@property (nonatomic, strong) NSDictionary *backThirdAppDict;//暂存返回第三方app数据

+ (instancetype)sharedUtility;

/**
 * 用于替换系统 -canOpenURL: 方法.[Fixed iOS_9]
 */
+ (BOOL)isWhiteListURL:(NSURL *)url;

//渠道号
+ (int)marketID;

//string handle
+ (NSString *)getStr:(NSString *)srcStr fromStr:(NSString *)str;
+ (NSString *)getStr:(NSString *)srcStr toStr:(NSString *)str;

//get sharedInstance
+ (sohunewsAppDelegate *)getApplicationDelegate;

//Create UUID
+ (NSString *)CreateUUID;
+ (NSString *)getDocumentPath;
+ (NSString *)getImageNameByDate;

// 正文动画便利方法
+ (CGRect)calculateFrameToFitScreenBySize:(CGSize)size defaultSize:(CGSize)defaultSize;
+ (CATransition *)getAnimation:(NSString *)kCATransitionType
          kCATransitionSubType:(NSString *)kCATransitionSubType
                   andDuration:(CFTimeInterval)duration;

//url拼接二代链接中的数据
+ (NSString *)strByAppendingParamsToUrl:(NSString *)url
                               fromLink:(NSDictionary *)userData;
// 二代链接中的数据以字典形式返回
+ (NSDictionary *)appendingParamsToUrl:(NSMutableDictionary *)params fromLink:(NSDictionary *)userData;

// open protocol url
+ (NSMutableDictionary *)parseProtocolUrl:(NSString *)urlPath
                                   schema:(NSString *)schemaStr;
+ (NSDictionary *)getParamsInfoWithUrl:(NSString *)url;

//+ (NSMutableDictionary *)parsePushUrlPath:(NSString*)pushUrlPath schema:(NSString *)schemaStr;  // 解析一代协议
//+ (NSMutableDictionary*)parseURLParam:(NSString*)link schema:(NSString *)schemaStr;             // 解析二代协议
+ (NSMutableDictionary *)parseURLParam:(NSString *)link
                                schema:(NSString *)schemaStr;

// 增加一个便利方法：直接解析二代link 解析出所有的参数 不考虑前缀协议  by jojo
+ (NSMutableDictionary *)parseLinkParams:(NSString *)link2;

//解析url链接参数包括http协议
+ (NSDictionary *)getParemsInfoWithLink:(NSString *) link;

// 增加一个便利方法：通过二代link解析对应打开的page by jojo
+ (SNCCPVPage)parseLinkPage:(NSString *)link2;

//将接口取到的数据转换成包含SNRollingNewsTableItem的数组
+ (NSMutableArray *)getNewsItemsArrayWithArray:(NSArray *)newsArray
                                      fromPush:(BOOL)fromPush;

//将接口数据转换成NSNews数组
+ (NSMutableArray *)getNewsArrayWithChannelId:(NSString *)channelId
                                         from:(NSString *)from
                                newsInfoArray:(NSArray *)newsInfoArray;

+ (BOOL)openProtocolUrl:(NSString *)url;
+ (BOOL)openProtocolUrl:(NSString *)url context:(NSDictionary *)context;
+ (BOOL)openProtocolAesUrl:(NSString *)aesUrl AesKey:(NSString *)aesKey;
+ (TTURLAction *)actionWithPluginName:(NSString *)plugin userInfo:(NSDictionary *)userInfo;

// 是否二代协议
+ (BOOL)isProtocolV2:(NSString *)urlStr;

// 从字符串中去掉二代协议
+ (NSString *)removeProtocolV2FromStr:(NSString *)urlStr;

// 根据二代协议 返回对应的refer
+ (SNReferFrom)referFromWithProtocolV2:(NSString *)urlStr;

+ (NSString *)getLinkFromShareContent:(NSString *)content;

// todo: 这些应该移动到用户中心相关的地方
+ (NSString *)addAPIVersionToURL:(NSString *)URL;
+ (NSString *)addProductIDIntoURL:(NSString *)URL;
+ (NSString *)addBundleIDIntoURL:(NSString *)URL;
+ (NSString *)addPLProductIDIntoURL:(NSString *)url;
+ (NSString *)getP1;
+ (NSString *)addParamP1ToURL:(NSString *)URL;
+ (NSString *)addParamP1ToURL:(NSString *)URL isV6:(BOOL)isV6;
+ (NSString *)addParamModeToURL:(NSString *)URL;
+ (NSString *)addParamImgsToURL:(NSString *)URL;
+ (NSString *)addParamSuccessToURL:(NSString *)URL;
+ (NSString *)addParamsToURLForReadingCircle:(NSString *)URL; //给阅读圈接口添加默认参数,for 3.5
+ (NSString *)addParamsToURLForShare:(NSString *)URL;         //给分享接口添加默认参数,for 3.5
+ (NSDictionary *)paramsDictionaryForReadingCircle;

//分享数据 截屏分享 wangshun
+ (NSMutableDictionary *)createShareData:(NSString *)pushURLStr
                                 Context:(NSDictionary *)context;
// todo: 这些应该移动到用户中心相关的地方

// todo: 这些应该移动到video相关的地方
+ (NSString *)addVideoCipherToURL:(NSString *)url;
+ (NSString *)addVideoP1ToURL:(NSString *)url;
// todo: 这些应该移动到video相关的地方

+ (NSString *)copyrightText;

// 非wifi下看图消耗流量提醒
+ (void)showNoWifiTipForPhotosWithKey:(NSString *)key;

// Post创建http body使用
+(NSString*)getCFUUID;

// 正文字体大小
+ (CGFloat)newsContentFontSize;
//评论页面的行高
+ (CGFloat)newsContentFontLineheight;

//获取某url的cookie
+ (NSString *)extractionCookie:(NSString *)aUrl
                           key:(NSString *)aKey;
//获取cookie中的access_token
+ (NSString *)getAccessTokenInWebCookie:(NSString *)urlString
                             cookieName:(NSString *)cookieName;
//删除指定url cookie
+ (void)deleteCookieForUrl:(NSString *)url;
//删除所有cookie
+ (void)deleteAllCookies;

//add by chengweibin
//设置字体大小
+ (void)setFontSize:(SNSettingFontSize)fontSize showText:(BOOL)show;
+ (void)setNewsFontSize:(NSInteger)fontSize;

//获得字体大小
+ (int)getDefaultFontSizeIndex;
+ (int)getNewsFontSizeIndex;
+ (NSString *)getNewsFontSizeClass;
+ (NSString *)getNewsFontSizeLabelText;
+ (SNSettingFontSize)getFontSize;
+ (CGPoint)getNewsFontSizePoint;
+ (void)setFontSize:(SNSettingFontSize)fontSize;
+ (UIFont *)getNewsTitleFont;
+ (float)getNewsTitleFontSize;
+ (float)getNewsTitleHeight;
+ (UIFont *)getFeedUserNameFont; //feed流用户昵称比title小1号

//判断当前设备
+ (NSString *)platformStringForSohuNews;

//字体大一号
+ (void)setBiggerFontSize;

//字体小一号
+ (void)setSmallerFontSize;

//app 显示特大字号排版
+ (BOOL)shownBigerFont;

//PGC显示3行时，页面布局错误
+ (BOOL)changePGCLayOut;

//正文页更多浮层设置字体大小
+ (void)setH5NewsFontSize:(NSInteger)fontSize;

//link2 格式化：参数按照大写字母顺序排列
+ (NSString *)link2Format:(NSString *)link2;

// 判断是否是3G/2G网络
+ (BOOL)isNetworkWWANReachable;

// 判断是否有网
+ (BOOL)isNetworkReachable;

//网络相关参数的获取

//获取运营商的名称
- (NSString *)getCarrierName;

- (NSString *)getCountryCode;

- (NSString *)getNetworkCode;
//网络监测，判断当前为wifi、蜂窝
- (NSString *)getRadioAccessTechnology;
// webp
+ (BOOL)isWebpEnabled;

//0：评论正常， 1：关闭评论，不能发任何评论,包括文字、图片、语音 , 2：禁止语音评论 , 3：禁止图片评论 ,4：禁止文件评论，即同时禁止图片语音评论
/*
 *是否需要禁止评论
 *param @cmtStatus 服务器返回评论状态  
 *      @curStatus 当前所要发出的评论类型（1，点击进入评论框，2，语音评论，3，图片评论）
 */
+ (BOOL)needCommentControlTip:(NSString *)cmtStatus
                currentStatus:(NSString*)curStatus
                          tip:(NSString *)cmtHint
                     isBottom:(BOOL)bottom;

+ (void)setCmtRemarkTips:(NSString *)curTips;

+ (NSString *)getHumanReadableTime:(double)secondsOfHumanUnreadable;

+ (BOOL)isSohuDomain:(NSString *)url;

#pragma mark - File system size
+ (SNFileSystemSize *)getCachedFileSystemSize;
+ (NSString *)formatStrForMediaSize:(unsigned long long)mediaSize;

+ (void)popToTabViewController:(UIViewController*)topViewController;

+ (UIView *)addCoverViewForInfoIcon:(CGRect)frame;

//追加网安部门需要的监控参数
+ (NSString *)addNetSafeParametersForURL:(NSString *)urlString;

+ (UIImage *)chooseActDefaultIconImage;
+ (UIImage *)chooseActEditIconImage;

//V5.0版本
#pragma mark - Debug Util
+ (void)debugViews:(NSArray *)views;
+ (void)debugView:(UIView *)v;
#pragma mark - 二代协议相关
+ (BOOL)isSohuNewsProtocol:(NSString *)protocol;

+ (UIView *)addMaskForImageViewWithRadius:(CGFloat)radius width:(CGFloat)width height:(CGFloat)height;
+ (NSString *)replaceString:(NSString *)str;
+ (NSString *)statisticsDataChangeType:(NSString *)data;
+ (BOOL)isFromChannelManagerViewOpened;//用于判定频道预览页面及子界面点击sohu logo

+ (void)popViewToRootController;//后新闻页，首页

+ (void)popViewToPreViewController;//返回上级页面

+ (void)sendSettingModeType:(SNUserSettingModeType)settingModeType
                       mode:(NSString *)mode; //保存用户设置信息

+ (void)executeFloatView:(id)delegate selector:(SEL)selector;
+ (BOOL)isOpenMobileBindSwitch:(NSString *)soureceType;
+ (void)setUserDefaultSourceType:(NSString *)soureceType keyString:(NSString *)keyString;
+ (void)showToastWithID:(NSString *)corpusId folderName:(NSString *) folderName;
+ (BOOL)isChannelExitWithChannelID:(NSString *)channelID;//根据ChannelID判断该频道是否已加入到频道列表
//从APPDelegate OpenUrl 转给SNS处理的外部协议
+ (BOOL)openSNSSchemeUrl:(NSString *)schemeUrl;

+ (BOOL)isBindMobile;
+ (void)checkIsBindMobileWithResult:(void(^)(BOOL isBindMobile))result;
+ (BOOL)isBindAlipay;
+ (void)checkIsBindAlipayWithResult:(void(^)(BOOL isBindAlipay))result;

+ (BOOL)isRightP1; // 用于判断是否为register.go回来正确的p1
/**
 *  打开扫一扫，开始扫描二维码。
 */
+ (BOOL)openQRCodeViewWith:(NSDictionary *)query;

+ (NSString *)getCurrentChannelId;
+ (NSString *)getCurrentChannelCategoryID;

+ (BOOL)isHavePushSwitchOpened;
+ (BOOL)judgeOldSubscribePushSwitch;//判断老版本订阅刊物开关状态，对应新版本媒体推送
+ (void)showSettingPushHalfFloatView:(BOOL)isOverIOS8 isFromSetting:(BOOL)isFromSetting;
+ (BOOL)isCoverInstallAPP;//是否升级安装
+ (void)saveHistoryShowWithChannel:(SNChannel *)channel isHouseChannel:(BOOL)isHouseChannel;//记录展示过的城市频道，最多三个
+ (NSArray *)getHistoryShowChannel:(BOOL)isHouseChannel;
+ (void)saveLocalChannel:(SNChannel *)channel isHouseChannel:(BOOL)isHouseChannel;
+ (SNChannel *)getLocalChannel:(BOOL)isHouseChannel;
+ (SNChannel *)getThirdChannel;
+ (SNChannel *)getChannelByChannelID:(NSString *)channelID;
+ (NSInteger)getChannelIndexByChannelID:(NSString *)channelID;
+ (BOOL)isAllowUseLocation;
+ (NSString *)getFirstChannelID;
+ (BOOL)resetLocationChannelWithChannelID:(NSString *)channelID;
+ (BOOL)needResetHomePageChannel;
+ (NSString *)changeSohuLinkToProtocol:(NSString *)linkUrl;//将sohu域名URL转换成二代协议
+ (BOOL)getSinaBindStatus;
+ (void)missingCheckReportWithUrl:(NSString *)url;//丢失校验统计
+ (NSString *)aesEncryptWithString:(NSString *)string;//统计组使用，对数据进行保真和重复校验
+ (NSString *)getDeviceIDFA;
+ (NSString *)getDeviceIDFV;
+ (NSString *)currentWebNetworkStatusString;
+ (BOOL)isConnectedToNetwork;
+ (NSString *)getShareNewsSourceType:(NSString *)urlString type:(int)type;
+ (NSString *)getDeviceUDID;
+ (void)requestRedPackerAndCoupon:(NSString *)protocolContent
                             type:(NSString *)type;
+ (void)showRedPacketPopView:(NSDictionary *)dictInfo isActivity:(BOOL)isActivity;
+ (void)showCouponFloatView:(NSDictionary *)dictInfo;
+ (NSString *)getPushMsgID:(NSString *)pushUrlString;

//解析link中的adid
+ (NSString *)getNewsItemAdId:(NSString *)link;

+ (BOOL)channelVideoSwitchStatus;//流内视频播放开关状态

+ (NSString *)getTabBarName:(NSInteger)index;//tab bar文案

+ (void)reportSNSShareLogWithType:(NSString *)type shareonInfo:(NSString *)shareonInfo originType:(NSString *)originType;//SNS分享日志上报
+ (void)recordShowEditModeNewsFromBack:(BOOL)fromBack;//记录启动APP，或者从后台进入APP的时间，从而判断显示编辑流还是推荐流
+ (BOOL)shouldShowEditMode;//显示编辑流，否则推荐流
+ (NSInteger)getResetEditRollingNewsTime;//每天6点曝光一次编辑流
+ (NSInteger)getRefreshRollingNewsTime;//30分钟刷新
+ (BOOL)getHttpsSwitchStatus;//服务端控制https开关
+ (void)shouldUseSpreadAnimation:(BOOL)use;//设置是否使用展开动画
+ (void)shouldAddAnimationOnSpread:(BOOL)add;//展开动画上是否添加动画
+ (NSDate *)changeNowDateToSysytemDate:(NSDate *)nowDate;
+ (BOOL)shouldShowSpecialActivity;//是否显示可定制化活动
+ (void)trigerSpecialActivity;//触发定制活动浮层
+ (void)clearPushCount;//清空端外push计数
+ (void)forceScreenPortrait;//强制竖屏
+ (BOOL)isPureNum:(NSString *)string;//纯数字判断
+ (NSDate *)getSettingValidTime:(NSInteger)timeValue;//获取设定时间戳
+ (void)openUniversalWebView:(NSDictionary *)dict;//打开webview

+ (BOOL)isABTestAppStyleChangeTime:(NSDate *)date;//业务规定样式发生变化后早上6点app样式生效
+ (void)changeABTestAppStyle:(SNAppABTestStyle) style;//appUI界面风格切换
+ (void)doChangeABTestAppStyle:(SNAppABTestStyle) style;
//+ (void)recordAppStyleChangeTime:(SNAppABTestStyle) style;//记录appstyle切换样式和生效时间
+ (SNAppABTestStyle)AbTestAppStyle;//当前生效的界面样式
//+ (BOOL)rollingNewsShowVideoChange;//频道流显示视频样式改版
//+ (BOOL)articleShowTopBar;//正文页是否显示顶部toolbar
+ (void)customSettingChange:(BOOL)change;
+ (BOOL)customSettingChange;//用户设置修改，需要reload tableview 比如：字体，样式风格
+ (SNAppABTestStyle)getCurrentAbTestStlye:(BOOL)isCurrent;//当前style，和6点后服务端生效的appstlye
+ (SNAppABTestStyle)getSettingParamMode;
+ (NSNumber *)ABTestUserMode;

+ (void)resultErrorReportWithType:(NSString *)type dict:(NSDictionary *)dict;//接口请求失败上报
+ (BOOL)isContainSchemeWithType:(NSString *)type urlString:(NSString *)urlString;//判断是否属于京东白名单，type区loading页和流内

+ (BOOL)isRecommandGuideShow;//推荐流显示引导
+ (void)hideRecommendGuide:(NSString *)channelId;
+ (void)openLoginViewWithDict:(NSDictionary *)dict;//打开登录页面
+ (void)handleClipper;//处理剪切板内容
+ (void)banUniversalLinkOpenInSafari;//禁止universal links调起safari

+ (void)setTimeToResetChannel;//设置第二天重置时间
+ (BOOL)isTimeToResetChannel;//每天早上6点重置频道
+ (void)recordRefreshTime:(NSString *)channelId;//频道刷新完成时间（用于记录1小时后重置刷新功能）
+ (BOOL)shouldResetChannel;//1小时后进入频道，需要重置
+ (void)deleteChannelParamsWithChannelId:(NSString *)channelId;//重置频道流参数

/**
 * 小说热词搜索
 */
+(void)novelSearchHotWord:(void (^)(NSArray *hotNovelWords))hotNovelWords;
//解压zip文件至当前目录
+ (BOOL)unZipFile:(NSString *)file zipFileTo:(NSString *)fileTo;
//文件流MD5加密
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath);

+ (void)getSyncStatusGo;

+ (NSString *)getImagePathWithName:(NSString *)imageName;//根据图片名字，获取路径

/**
 第三方分享登录平台注册
 */
+ (void)registerSharePlatform;

+ (NSString *)fullScreenADServerFlagString;

+ (NSDate *)getTodayValidTime:(NSInteger)timeValue;

//记录App是否首次安装或者升级, 需要同步List.go
+ (BOOL)isListGOSync;
+ (void)recordListGOSync:(BOOL)isSync;

+ (BOOL)isFirstInstallOrUpdateApp;
+ (void)recordIsFirstInstallOrUpdateApp:(BOOL)isFirst;

//获取wifi信息，Wi-Fi名字，网卡mac地址
+ (NSDictionary *)getWifiSSIDInfo;

//注册北研统计SDK
+ (void)registCompassSDK;

//返回第三方APP button
+ (void)showBackThirdAppView;

+ (UIFont *)getTopTitleFont;
+ (BOOL)isNewDayToBackHomeChannel;
+ (void)resetHomeChannelTime;

@end

@interface UIView(SNUtiltyView)

@property (nonatomic, retain) NSNumber *isXibAwaked;

@end
