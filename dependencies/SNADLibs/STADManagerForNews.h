//
//  STADManagerForNews.h
//  STAD
//
//  Created by jinkai on 15-11-22.
//  Copyright (c) 2015年 jinkai. All rights reserved.
//
//

#pragma mark 需要导入的Framework

// 注意：需要在Other Linker Flags中，加入-ObjC
//
//
//  UIKit
//  libsqite3
//  libxml2
//  AVFoundation
//  SystemConfiguration
//  CoreLocation
//  AdSupport
//  EventKit
//  EventKitUI
//  AudioToolbox
//  libc++
//  libz
//  CoreTelephony
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#pragma mark -
#pragma mark Delegate返回标识信息

typedef NS_ENUM(NSInteger, kStadActionForNewsType) {
    kStadActionForNewsTypeClose = 1,                /*!关闭窗口*/
    kStadActionForNewsTypeOpen,                     /*!在当前窗口中打开新地址*/
    kStadActionForNewsTypeExpend,                   /*!打开一个新开窗口*/
    kStadActionForNewsTypeSetExpandProperties,      /*!设置新开窗口属性*/
    kStadActionForNewsTypeResize,                   /*!更改当前窗口大小*/
    kStadActionForNewsTypeSetResizeProperties,      /*!设置当前窗口属性*/
    kStadActionForNewsTypeUseCustomClose,           /*!是否允许自定义关闭*/
    kStadActionForNewsTypeStorePicture,             /*!存储图像*/
    kStadActionForNewsTypeCreateCalendarEvent,      /*!创建日历事件*/
    kStadActionForNewsTypePlayVideo,                /*!播放视频*/
    kStadActionForNewsTypeAppDownload,              /*!跳转至App下载*/
    kStadActionForNewsTypeSetOrientationProperties  /*!朝向属性设置*/
};

typedef NS_ENUM(NSInteger, kStadErrorForNewsType) {
    kStadErrorForNewsTypeUnknow = 1,         /*!未知错误*/
    kStadErrorForNewsTypeNodata,             /*!无数据*/
    kStadErrorForNewsTypeDownload,           /*!下载错误*/
    kStadErrorForNewsTypeLoading             /*!加载错误*/
};

typedef NS_ENUM(NSInteger, kSTADAdTrackType) {
    kSTADAdTrackTypeNormal = 1,      /*!正常曝光*/
    kSTADAdTrackTypeAdmaster,        /*!Admaster 曝光*/
    kSTADAdTrackTypeMiaozhen,        /*!Miaozhen 曝光*/
    kSTADAdTrackTypeUnknow           /*!未知曝光（等同于正常曝光处理）*/
};

typedef NS_ENUM(NSInteger, kStadWebViewType) {
    kStadWebViewTypeUnknow = 1,         //未知类型
    kStadWebViewTypeNodata,             //无跳转地址
    kStadWebViewTypeNormal,             //正常跳转
    kStadWebViewTypeMediaPlayer,        //包含播放器
    kStadWebViewTypeAppStore,           //跳转至Appstore
    kStadWebViewTypeSafari              //跳转至Safari
};

typedef NS_ENUM(NSUInteger, SNADRequestADHostType) {
    SNADRequestADHostTypeRelease = 0,   // 线上环境
    SNADRequestADHostTypeDebug,         // 测试环境
    SNADRequestADHostTypePre,           // 准线上环境
    SNADRequestADHostTypeAppScreen      // 截屏服务器域名
};


#pragma mark -

/*! @brief 接收并处理来至STAD sdk的事件消息
 *
 * 接收并处理来至STAD sdk的事件消息
 */

@protocol SNADManagerDelegate <NSObject>

#pragma mark - 新闻开机&图文广告Delegate方法
/*! @brief 新闻开机&图文广告 成功展示
 *
 * @param itemspaceid 广告位id
 *
 */
@optional
-(void)stadAdViewDidAppearForNewsWithItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview;

/*! @brief 新闻开机&图文广告 动作报告方法
 *
 * @param actionType  动作类型
 * @param itemspaceid 广告位id
 *
 */
@optional
- (void)stadActionForNews:(kStadActionForNewsType)actionType andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview;// (Deprecated)

/*! @brief 新闻开机&图文广告错误报告方法
 *
 * @param errorType 错误类型
 * @param itemspaceid 广告位id
 * @param params 回传参数字典
 */
@optional
- (void)stadErrorForNews:(kStadErrorForNewsType)errorType andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview andAdParam:(NSDictionary *)params;

/*! @brief 新闻开机&图文广告点击方法
 *
 * 该方法会将SDK无法处理点击信息返回给App处理
 * @param clickThrough 点击信息
 * @param itemspaceid 广告位id
 *
 */
@optional
- (void)stadClickForNews:(NSString *)clickThrough andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview;

/*! @brief 新闻开机&图文广告 文本信息回调方法
 *
 * 该方法会将SDK处理后的文本信息返回给App
 * @param textInfo 文本信息
 * @param itemspaceid 广告位id
 *
 */
@optional
- (void)stadTextInfoForNews:(NSDictionary *)textinfo andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview;

#pragma mark - 开机广告Delegate事件

/**
 *  开机广告加载成功事件
 *
 *  @param localImgPath 开机广告展示VC
 *  @param oadInterval  开机广告展示时长
 */
@optional
- (void)stadOpenAssetDidFinishedLoading:(UIViewController *)openADVC interval:(NSTimeInterval)oadInterval;

/*! @brief 开机广告获取错误
 *
 * 开机广告load错误，无法正常获取广告物料
 *
 */
@optional
- (void)stadOpenAssetNotAvaliableWithOpenADViewCtrler:(UIViewController *)openVC;


/*! @brief 开机广告结束，包括所有业务逻辑
 *
 */
@optional
- (void)stadOpenADFinishedWithOpenADViewCtrler:(UIViewController *)openVC;

/*! @brief 视频开机广告播放错误
 *
 */
@optional
- (void)stadOpenADFailedWithOpenADViewCtrler:(UIViewController *)openVC;


/*! @brief 开机广告点击事件
 *
 */
@required
- (void)stadOpenADClicked:(NSString *)loadingString;

@end


#pragma mark -
@interface SNADManager : NSObject

/** STADManagerDelegate代理，用以获取代理事件
 * @note 所有方法都为@optional
 */
@property (nonatomic, assign) id <SNADManagerDelegate> delegate;
- (void)setDelegateObject:(id<SNADManagerDelegate>)delegateObject;
- (void)removeDelegateObject:(id<SNADManagerDelegate>)delegateObject;

- (void)addObjectToSafeArr:(id)obj;
- (void)removeObjectFromeSafeArr:(id)obj;

@property  (nonatomic,strong)  NSMutableArray *delegates;
/** 设置广告的展示类型
 * @note 可读写属性
 */
@property (nonatomic, assign) BOOL isNonepicMode;       //无图模式
@property (nonatomic, assign) BOOL isNightMode;         //夜间模式

@property (nonatomic, assign) SNADRequestADHostType adHostType;   //

#pragma mark -
/*! @brief 返回一个STADManager对象
 *
 * @note 返回的对象是单例，不可释放
 */
+ (SNADManager*)sharedSTADManager;

#pragma mark sohu新闻私有协议广告 API
/*! @brief sohu新闻 图文广告
 *
 * sohu新闻私有协议 图文广告
 *
 * @param frame        广告的位置信息
 * @param param        广告参数
 * @param isNight      是否为夜间模式
 * @param isNonepic    是否为无图模式
 * @param shouldRender 是否需要渲染（加载至WebView）
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 */
- (UIView *)getNewsMraidWithFrame:(CGRect)frame
                         andParam:(NSDictionary *)param
                       andIsNight:(BOOL)isNight
                     andIsNonepic:(BOOL)isNonepic
                     shouldRender:(BOOL)shouldRender;
/*! @brief sohu新闻 开机广告
 *
 * sohu新闻私有协议 开机广告
 *
 * @param frame        广告的位置信息
 * @param param        广告参数
 * @param isNight      是否为夜间模式
 * @param isNonepic    是否为无图模式
 * @param shouldRender 是否需要渲染（加载至WebView）
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 */
- (UIView *)getNewsMraidOpenWithFrame:(CGRect)frame
                             andParam:(NSDictionary *)param
                           andIsNight:(BOOL)isNight
                         andIsNonepic:(BOOL)isNonepic
                         shouldRender:(BOOL)shouldRender;// (Deprecated)

/*! @brief sohu新闻 快速获取开机广告信息
 *
 * sohu新闻私有协议 用于快速获取开机广告信息，直接访问数据库，不通过控件层
 *
 * @param  itemspaceid 开机广告对应的itemspaceid
 * @return 返回开机广告的具体信息 如果为nil则无可展示数据
 *
 * 注：请配合创建开机广告接口，创建对象，并上报数据
 */
- (NSDictionary *)getLoadingInfosForNews:(NSString *)itemspaceid;// (Deprecated)

#pragma mark -
#pragma mark 广告位曝光接口

/*! @brief sohu新闻 点击曝光
 *
 * sohu新闻私有协议 点击曝光
 *
 * @param adView    SDK制作的广告View
 * @param dict      SDK提交至CountServer所需的参数
 *
 */
- (void)stadClickTrackingForNews:(UIView *)adView andParam:(NSDictionary *)dict;

/*! @brief sohu新闻 有效展示曝光（imp）
 *
 * sohu新闻私有协议 有效展示曝光（imp）
 *
 * @param adView    SDK制作的广告View
 * @param dict      SDK提交至CountServer所需的参数
 *
 */
- (void)stadImpTrackingForNews:(UIView *)adView andParam:(NSDictionary *)dict;

/*! @brief sohu新闻 load展示曝光（imp）
 *
 * sohu新闻私有协议 load展示曝光（imp）
 *
 * @param adView    SDK制作的广告View
 * @param dict      SDK提交至CountServer所需的参数
 *
 */
- (void)stadLoadImpTrackingForNews:(UIView *)adView andParam:(NSDictionary *)dict;

/*! @brief sohu新闻 空广告曝光（null ad）
 *
 * sohu新闻私有协议 空广告曝光（null ad）
 *
 * @param adView    SDK制作的广告View
 * @param dict      SDK提交至CountServer所需的参数
 *
 */
- (void)stadNullADTrackingForNews:(UIView *)adView andParam:(NSDictionary *)dict;

/*! @brief sohu新闻中插广告 关闭按钮曝光（close imp）
 *
 * sohu新闻私有协议 关闭按钮曝光（close imp）
 *
 * @param adView    SDK制作的广告View
 * @param dict      SDK提交至CountServer所需的参数
 *
 */
- (void)stadCloseImpTrackingForNews:(UIView *)adView andParam:(NSDictionary *)dict;

#pragma mark -
#pragma mark 流内广告曝光接口

typedef NS_ENUM(NSInteger, STADDisplayTrackType) {
    STADDisplayTrackTypeUnknown = 1,    //未知上报类型（不使用）
    STADDisplayTrackTypeNotInterest,    //不感兴趣
    STADDisplayTrackTypeClick,          //点击
    STADDisplayTrackTypeLoadImp,        //加载曝光 （曝光）
    STADDisplayTrackTypeImp,            //展示曝光 （有效曝光）
    STADDisplayTrackTypeNullAD,         //空广告曝光
    STADDisplayTrackTypePlaying,        //流内视频播放
    STADDisplayTrackTypeTelImp         //流内拨打电话上报
};

/*! @brief sohu静态展示广告 通用上报接口
 *
 * sohu私有协议，静态展示广告通用上报接口
 * 当host为空时，SDK会根据传入类型来判断，并使用默认地址
 *
 * @param trackType  上报类型
 * @param params     广告SDK未知参数，通过Map格式传入，SDK拼接生成
 *
 */
- (void)stadDisplayTrackWithType:(STADDisplayTrackType)trackType
                    andParamDict:(NSDictionary *)params;


/*! @brief sohu静态展示广告 Server to Server上报接口
 *
 * sohu私有协议，静态展示广告通用上报接口
 *
 * @param trackType  上报类型
 * @param params     广告SDK未知参数，通过Map格式传入，SDK拼接生成
 *
 */
- (void)stadServerToServerTrackWithType:(STADDisplayTrackType)trackType
                    andParamDict:(NSDictionary *)params;


#pragma mark 第三方曝光接口
/*! @brief 第三方曝光接口
 *
 * 通过STAD来进行普通曝光和调用第三方SDK曝光
 *
 * @param track_url     曝光地址
 * @param trackType     曝光类型 （目前第三方包括Admaster，miaozhen）
 */
- (void)stadAdTrack:(NSString *)track_url andTrackType:(kSTADAdTrackType)trackType;

#pragma mark 统计和上报
/*! @brief passport id上报接口
 *
 * 用户在客户端登陆成功后(包括前后台登陆)，客户端将passport id信息回传给广告sdk，供做精准投放决策优化
 *
 * @param passportId
 *
 */
- (void)stadLoginTrackWithPassport:(NSString *)passportId;

/**
 *  当前移动设备网络类型，如：wifi，2g，3g，4g
 *
 *  @return 当前网络类型
 */
- (NSString *)getCurrentNetworkType;

/**
 *  获得广告相关设备id信息，以字典key/value形式返回
 *  idfa
 *  idfv
 *  openudid
 *  adsid
 *
 *  @return 设备信息字典
 */
- (NSDictionary *)getStadDeviceInfo;

#pragma mark - 开机广告预加载（物料） API

/**
 *  开机广告预加载方法
 *
 *  @param param 开机广告的ADParam
 */
- (void)snadStartPerdonwloadWithParam:(NSDictionary *)param;

/**
 *  zip包获取本地缓存的接口，传进zip的remote URL，返回本地file URL或nil
 *
 *  @param remote zip的remote URL
 */
#pragma mark - 缓存接口

- (NSURL *)localFileExitsForRemote:(NSString *)remote;

#pragma mark - 开机广告 实时请求 API

/**
 *  开机广告接口
 *  @param param  请求参数
 *  @param isFirstLoad   是否第一次加载启动图，不是则不显示倒计时
 */
- (void)getNewsOpenWithParam:(NSDictionary *)param isFirstLoad:(BOOL)isFirstLoad;

/**
 *  开机广告接口
 *  key值如下
 NSString *const SNADOpenADShareTextKey = @"com.sohu.SNADOpenADShareTextKey";
 NSString *const SNADOpenADShareMediaKey = @"com.sohu.SNADOpenADShareMediaKey";
 *  @return 分享语和分享链接
 */
- (NSDictionary *)getNewsOpenShare;

/**
 *  关闭开机广告
 */
- (void)stopNewsOpenAD;

/**
 *  开机广告切换
 */
- (void)switchOpenAD;

/**
 *  移除开机广告controller时通知SDK
 */
- (void)removeOpenADViewCtrler;

@end
