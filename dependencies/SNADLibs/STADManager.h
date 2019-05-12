//
//  STADManager.h
//  STAD
//
//  Created by hugo.chang on 13-9-26.
//  Copyright (c) 2013年 hugo.chang. All rights reserved.
//
//

#pragma mark 需要导入的Framework

// 注意：需要在Other Linker Flags中，加入-ObjC
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
//  第三方监测SDK
//  AdMaster libMobileTracking.a
//  Miaozhen libMZMonitor_iOS_SDK.a
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "STADADParam.h"
#pragma mark -
#pragma mark 外部传入播放器状态
typedef NS_ENUM(NSInteger, STADMovieState) {
    STADMovieStatePlaybackStopped = 1,          //结束播放，AD会全部停止，当作Skip来处理
    STADMovieStatePlaybackPlaying,              //播放
    STADMovieStatePlaybackPaused,               //暂停
    STADMovieStatePlaybackInterrupted,          //打断(暂不做处理)
    STADMovieStateFinishReasonPlaybackEnded,    //正常播放结束
    STADMovieStateFinishReasonPlaybackError,    //出现错误，播放结束
    STADMovieStateFinishReasonUserExited,       //用户退出，播放结束
    STADMovieStateFinishReasonLoadingError      //出现错误，无聊无法加载
};
#pragma mark -
#pragma mark Delegate返回标识信息
typedef NS_ENUM(NSInteger, kStadOadStateKey) {
    kStadOadStateLoaded = 1,  //OAD信息加载完毕
    kStadOadStateStarted,     //OAD开始播放
    kStadOadStatePaused,      //OAD暂停
    kStadOadStateResumed,     //OAD恢复播放
    kStadOadStateClicked,     //OAD被点击
    kStadOadStateEnded,       //OAD单帖结束
    kStadOadStateCompleted,   //OAD全部播放完毕
    kStadOadStateSkiped       //OAD跳过
};

typedef NS_ENUM(NSInteger, kStadOadTrackEventKey) {
    kStadOadTrackEventImpression = 1, //OAD 创建 曝光事件
    kStadOadTrackEventCreateView,     //OAD 创建 曝光事件
    kStadOadTrackEventStart,          //OAD 开始 曝光事件
    kStadOadTrackEventFirstQuartile,  //OAD 1/4 曝光事件
    kStadOadTrackEventMidPoint,       //OAD 1/2 曝光事件
    kStadOadTrackEventThirdQuartile,  //OAD 3/4 曝光事件
    kStadOadTrackEventComplete,       //OAD 结束 曝光事件
    kStadOadTrackEventPause,          //OAD 暂停 曝光事件
    kStadOadTrackEventResume,         //OAD 恢复 曝光事件
    kStadOadTrackEventSkip,           //OAD 跳过 曝光事件
    kStadOadTrackEventProgress,       //OAD 进程 曝光事件
    kStadOadTrackEventClickTracking,  //OAD 点击 曝光事件
    kStadOadTrackEventNull            //OAD 空广告 曝光事件
};

typedef NS_ENUM(NSInteger, kStadOadErrorKey) {
    kStadOadErrorNoNetwork = 1,       //无网络 错误
    kStadOadErrorHighDelay,           //缓冲时间过长，高延迟（超过广告一半时间）
    kStadOadErrorNoData,              //无信息 错误
    kStadOadErrorFailedToPlayToEnd,   //OAD 播放未完成 错误
    kStadOadErrorEntryError,          //OAD 播放无法开始 错误
    kStadOadErrorAssetNotAvaliable,   //OAD 无效播放文件 错误
    kStadOadErrorNullAD               //OAD 空广告 错误
};

typedef NS_ENUM(NSInteger, kStadOadPlayerGravity) {
    kStadOadPlayerGravityResize = 1,
    kStadOadPlayerGravityResizeAspect,
    kStadOadPlayerGravityResizeAspectFill
};

typedef NS_ENUM(NSInteger, kStadURLFormat) {
    kStadURLFormatFile = 1,           //链接文件地址
    kStadURLFormatVast,               //Vast协议地址
    kStadURLFormatJson,               //Json协议地址
    kStadURLFormatXML,                //XML协议地址
    kStadURLFormatLocalPath           //本地文件路径
};

typedef NS_ENUM(NSInteger, kStadActionForNewsType) {
    kStadActionForNewsTypeClose = 1,                //关闭窗口
    kStadActionForNewsTypeOpen,                     //在当前窗口中打开新地址
    kStadActionForNewsTypeExpend,                   //打开一个新开窗口
    kStadActionForNewsTypeSetExpandProperties,      //设置新开窗口属性
    kStadActionForNewsTypeResize,                   //更改当前窗口大小
    kStadActionForNewsTypeSetResizeProperties,      //设置当前窗口属性
    kStadActionForNewsTypeUseCustomClose,           //是否允许自定义关闭
    kStadActionForNewsTypeStorePicture,             //存储图像
    kStadActionForNewsTypeCreateCalendarEvent,      //创建日历事件
    kStadActionForNewsTypePlayVideo,                //播放视频
    kStadActionForNewsTypeAppDownload,              //跳转至App下载
    kStadActionForNewsTypeSetOrientationProperties  //朝向属性设置
};

typedef NS_ENUM(NSInteger, kStadErrorForNewsType) {
    kStadErrorForNewsTypeUnknow = 1,         //未知错误
    kStadErrorForNewsTypeNodata,             //无数据
    kStadErrorForNewsTypeDownload,           //下载错误
    kStadErrorForNewsTypeLoading             //加载错误
};

typedef NS_ENUM(NSInteger, kStadWebViewType) {
    kStadWebViewTypeUnknow = 1,         //未知类型
    kStadWebViewTypeNodata,             //无跳转地址
    kStadWebViewTypeNormal,             //正常跳转
    kStadWebViewTypeMediaPlayer,        //包含播放器
    kStadWebViewTypeAppStore,           //跳转至Appstore
    kStadWebViewTypeSafari              //跳转至Safari
};

typedef NS_ENUM(NSInteger, kSTADAdTrackType) {
    kSTADAdTrackTypeNormal = 1,      //正常曝光
    kSTADAdTrackTypeAdmaster,        //Admaster 曝光
    kSTADAdTrackTypeMiaozhen,        //Miaozhen 曝光
    kSTADAdTrackTypeUnknow           //未知曝光（等同于正常曝光处理）
};

typedef NS_ENUM(NSInteger, kSTADDismissViewType) {
    kSTADDismissViewTypeLanding = 1,    //广告落地页（跳转页面）消失类型
    kSTADDismissViewTypePause,          //暂停广告消失类型
    kSTADDismissViewTypeFlogo,          //角标广告消失类型
    kSTADDismissViewTypeVideo,          //视频广告消失类型 (暂时不会回调)
    kSTADDismissViewTypeUnknow          //未知类型消失    (暂时不会回调)
};

typedef NS_ENUM(NSInteger, kStadErrorTrackType) {
    kStadErrorThirdPartyPlayFail = 1,  //第三方物料播放失败，播放打底物料
    kStadErrorOnlinePlayFail,          //预下载未完成，不播放在线物料地址
    kStadErrorMediaPlayTimeout         //搜狐物料播放超时
};

typedef NS_ENUM(NSInteger,kStadUseInAppType){
    kStadUseInSoHuNews=1,              //SDK使用在sohu视频app主线
    kStadUseInSohuTv                   //SDK使用在sohu新闻视频TAB
};

#pragma mark -

/*! @brief 接收并处理来至STAD sdk的事件消息
 *
 * 接收并处理来至STAD sdk的事件消息
 */

@protocol STADManagerDelegate <NSObject>
#pragma mark -
#pragma mark 前贴片,中插片,后贴片广告部分的Delegate事件

/*! @brief 获取贴片的播放物料
 *
 * 收到sdk 返回播放物料
 *
 * @param asset    为当前播放物料地址
 * @param isLocal  为当前播放物料是否为本地资源 (本地：YES,外部：NO)
 *
 */
@optional
- (void)stadOadAsset:(NSString *)asset isLocal:(BOOL)isLocal;

/*! @brief 批量获取贴片的播放物料
 *
 * 收到sdk 批量返回播放物料
 *
 * @param assets          为当前播放物料地址数组
 * @param oad_intervals   为当前播放物料时长数组
 * @param adtype          为当前播放物料为哪种广告类型（目前包括oad前贴，mad中插，ead后贴）
 *
 * @return UIView  需要返回当前可触发广告的View
 */
@optional
- (UIView *)stadOadAssets:(NSArray *)assets oadIntervals:(NSArray *)oad_intervals andADType:(NSString *)adtype;

/*! @brief 批量返回中插的播放物料
 *
 * （非主线程返回）收到sdk 批量返回中插播放物料，仅限当前点位，考虑有可能一个点位包含多个贴片情况
 *
 * @param assets          为当前播放中插物料地址数组
 * @param mad_intervals   为当前播放中插物料时长数组
 * @param isLastAsset     是否最后一个点位
 *
 * @return UIView  需要返回当前可触发广告的View
 */
@optional
- (UIView *)stadMadAssets:(NSArray *)assets madIntervals:(NSArray *)mad_intervals andIsLastAsset:(BOOL)isLastAsset;

/**
 *  可选广告回调接口
 *
 *  @param optAssets       可选广告物料地址数组
 *  @param normalAssets    普通广告物料地址数组
 *  @param skipoffset      等待用户选择可选广告跳过时长
 */
- (void)stadOptAssets:(NSArray *)optAssets normalAssets:(NSArray *)normalAssets andSkipOffset:(NSInteger)skipoffset;

/*! @brief 获取贴片的播放进度
 *
 * 收到sdk 返回的进度的事件，方法返回的频度于获取贴片方法中设置
 *
 * @param progress为0～1，用于标识贴片播放进度
 * @param current，贴片播放长度
 * @param duration，贴片总长度
 */
@optional
- (void)stadOADGetProgress:(float)progress current:(float)current duration:(float)duration;

/*! @brief 贴片的播放状态变更
 *
 * 播放器状态变更，包括Loaded（加载完毕），Started(开始)，Paused（暂停），Resumed（恢复），
 Clicked（被点击），Ended（单贴播放结束），Completed（整体播放结束），Skiped（跳过贴片播放）
 *
 * @param state为状态标识，详见kStadOadStateKey
 */
@optional
- (void)stadOADStateChanged:(kStadOadStateKey)state;

/*! @brief trackEvent 跟踪事件类型反馈
 *
 * 贴片播放事件曝光跟踪，包括CreateView（创建），Start（开始），FirstQuartile（1/4长度），MidPoint（1/2长度），
 * ThirdQuartile（3/4长度），Complete（结束），Pause（暂停），Resume（恢复），
 * Skip（跳过），ClickTracking（点击），Null（空广告）
 *
 * @param trackEvent为事件曝光标识，详见kStadOadTrackEventKey
 */
@optional
- (void)stadOADTrackEvent:(kStadOadTrackEventKey)trackEvent;


/*! @brief 贴片错误报告
 *
 * 贴片播放中出现的错误，包括NoNetWork(无网络)，HighDelay（高延迟，缓冲事件过长），NoData（无信息），
 * FailedToPlayToEnd（播放未完成，不包括切换贴片），EntryError（播放无法开始），AssetNotAvaliable（播放资源无效）
 *
 * @param error错误标识，详见kStadOadErrorKey
 */
@optional
- (void)stadOADError:(kStadOadErrorKey)error;


/*! @brief 贴片点击事件
 *
 * 贴片被点击，如果贴片的点击信息SDK无法处理，则通过该方法返回
 *
 * @param clickInfo点击信息
 */
@optional
- (void)stadOADClickInfo:(NSString *)clickInfo;

/*! @brief 语音广告事件
 *
 * 贴片为可交互语音广告时，会调用该回调接口，并通过不断刷新信息来提醒用户如何互动
 *
 * @param voiceView 语音广告展示控件
 *
 */
@optional
- (void)stadVoiceADView:(UIView *)voiceView;

/*! @brief 语音广告成功
 *
 * 贴片为可交互语音广告时，如果语音识别成功，则会通过改接口返回
 *
 * @param voiceView 语音广告展示控件
 *
 */
@optional
- (void)stadVoiceADSucessed:(UIView *)voiceView;

/*! @brief 中插点位信息返回
 *
 * 使用 - (void)stadGetMadIndexInfosWithVid:(NSString *)vid 方法返回中插点位信息
 *
 * @param indexInfos 点位信息，数组对象，内部对象为NSDictionary
 *
 */
@optional
- (void)stadMadIndexInfos:(NSArray *)indexInfos;

/*! @brief 广告关闭回调事件
 *
 * 广告关闭时，会通过回调告知哪种类型及其容器
 *
 * @param dismissViewType 关闭广告的类型
 * @param dismissView     关闭广告所使用的容器
 *
 */
@optional
- (void)stadViewDismissedWithType:(kSTADDismissViewType)dismissViewType andView:(UIView *)dismissView;

/*! @brief 广告上报回调
 *
 * 广告开始时，会通过该方法回传上报地址，以及每贴广告时长（0为空广告，无时长）
 *
 * @param impArr        上报地址数组
 * @param intervalArr   广告每贴时长
 *
 */
- (void)stadOadImps:(NSArray *)impArr andOadIntervals:(NSArray *)intervalArr;

/*! @brief 广告单词上报回调
 *
 * 每贴广告开始会进行曝光上报，此时将该条上报返回
 *
 * @param imp  当前上报地址（包括空广告）
 * @param duration  当前贴数时长（包括空广告）
 *
 */
- (void)stadOadCurrentImp:(NSString *)imp andDuration:(NSString *)duration;

#pragma mark -
#pragma mark 暂停广告部分的Delegate事件

/*! @brief 暂停广告加载结束事件
 *
 * 暂停广告加载结束
 *
 * @param stadPadView 暂停广告容器
 */
@optional
- (void)stadPADDidFinishedLoading:(UIView *)stadPadView;

/*! @brief 暂停广告点击事件
 *
 * 暂停广告被点击，如果暂停广告的点击信息SDK无法处理，则通过该方法返回
 *
 * @param clickInfo点击信息
 */
@optional
- (void)stadPADClickInfo:(NSString *)clickInfo;

/*! @brief 暂停广告获取错误
 *
 * 暂停广告load错误，无法正常获取广告内容
 *
 */
@optional
- (void)stadPADLoadError;

#pragma mark -
#pragma mark 开机广告部分的Delegate事件

/*! @brief 开机广告加载结束事件
 *
 * 开机广告加载结束
 *
 * @param stadOpenView 开机广告容器
 */
@optional
- (void)stadOpenDidFinishedLoading:(UIView *)stadOpenView;

/*! @brief 开机广告获取错误
 *
 * 开机广告load错误，无法正常获取广告内容
 *
 */
@optional
- (void)stadOpenAssetNotAvaliable;

#pragma mark -
#pragma mark 角标广告部分的Delegate事件

/*! @brief 角标广告加载结束事件
 *
 * 需要app展示角标广告时SDK调用此函数，展示满足时长后app移除角标广告
 *
 * @param stadFlogoADView 角标广告容器
 * @param duration 角标广告展示时长,单位 (秒)
 */
@optional
- (void)stadFlogoADDidFinishedLoading:(UIView *)stadFlogoADView andDuration:(float)duration;

/*! @brief 角标广告获取错误
 *
 * 角标广告load错误，无法正常获取广告内容
 *
 */
@optional
- (void)stadFlogoADLoadError;

#pragma mark -
#pragma mark 离线下载部分的Delegate事件
/*! @brief 离线下载资源完成
 *
 * 离线下载资源完成
 *
 */
@optional
- (void)stadOfflineAssetsDownloaded;

#pragma mark -
#pragma mark 打开Web页面类型
/*! @brief 广告跳转
 *
 * 广告点击产生的跳转
 *
 * @param webViewType      跳转类型
 * @param urlString        跳转地址
 * @param webContentView   跳转打开容器
 */
@optional
- (void)stadWebViewType:(kStadWebViewType)webViewType andURL:(NSString *)urlString andWebContentView:(UIView *)webContentView;

#pragma mark -
#pragma mark 新闻开机&图文广告Delegate方法
/*! @brief 新闻开机&图文广告 成功展示
 *
 * @param itemspaceid广告位id
 *
 */
@optional
-(void)stadAdViewDidAppearForNewsWithItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview;

/*! @brief 新闻开机&图文广告 动作报告方法
 *
 * @param actionType为动作类型
 * @param itemspaceid广告位id
 *
 */
@optional
- (void)stadActionForNews:(kStadActionForNewsType)actionType andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview;

/*! @brief 新闻开机&图文广告错误报告方法
 *
 * @param errorType 为错误类型
 * @param itemspaceid 广告位id
 * @param params 回传参数字典
 */
@optional
- (void)stadErrorForNews:(kStadErrorForNewsType)errorType andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview andAdParam:(NSDictionary *)params;

/*! @brief 新闻开机&图文广告点击方法
 *
 * 该方法会将SDK无法处理点击信息返回给App处理
 * @param clickThrough点击信息
 * @param itemspaceid广告位id
 *
 */
@optional
- (void)stadClickForNews:(NSString *)clickThrough andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview;

/*! @brief 新闻开机&图文广告 文本信息回调方法
 *
 * 该方法会将SDK处理后的文本信息返回给App
 * @param textInfo文本信息
 * @param itemspaceid广告位id
 *
 */
@optional
- (void)stadTextInfoForNews:(NSDictionary *)textinfo andItemSpaceID:(NSString *)itemspaceid andAdView:(UIView *)adview;


@end

#pragma mark -
@interface STADManager : NSObject

/** STADManagerDelegate代理，用以获取代理事件
 * @note 所有方法都为@optional
 */
@property (nonatomic, weak) id <STADManagerDelegate> delegate;
- (void)setDelegateObject:(id<STADManagerDelegate>)delegateObject;
- (void)removeDelegateObject:(id<STADManagerDelegate>)delegateObject;

- (void)addObjectToSafeArr:(id)obj;
- (void)removeObjectFromeSafeArr:(id)obj;

/** 设置广告的URL参数（详细参见SDK接入手册）
 * @note 可读写属性
 */
@property (nonatomic, copy) NSString *latitude;       //纬度
@property (nonatomic, copy) NSString *longitude;      //经度

@property (nonatomic, copy) NSString *UUID;           //广告唯一标识UUID

/** 获取播放器的贴片播放状态
 * @note 只读属性
 */
@property (nonatomic, readonly) BOOL oadPlaying;
@property (nonatomic, readonly) CGFloat oad_time;
@property (nonatomic, readonly) CGFloat summery_time;

/** 设置广告的展示类型
 * @note 可读写属性
 */
@property (nonatomic, assign) BOOL isNonepicMode;       //无图模式
@property (nonatomic, assign) BOOL isNightMode;         //夜间模式

#pragma mark -
/*! @brief STAD Api接口函数
 *
 * 该类封装了STAD SDK的所有接口
 */

/*! @brief 返回一个STADManager对象
 *
 * @note 返回的对象是单例，不可释放
 */
+ (STADManager*)sharedSTADManager;

#pragma mark -
#pragma mark 播放贴片广告 API
/*! @brief 播放贴片广告 初始化方法
 *
 * 采用外部传入Vast广告物料，每次初始化由STADManager完成，并通过STADManagerDelegate方法
 * - (void)stadOadAsset:(NSString *)asset isLocal:(BOOL)isLocal
 * 返回播放物料
 *
 * @param adUrlString   贴片的广告物料地址 如果传入为nil，则使用ADParam来制作物料URL
 * @param timeoutInterval   贴片的超时时间, STADManager会使用该字段来限制请求的超时时间
 *
 */
- (void)playOADWithADURLString:(NSString *)adUrlString andTimeout:(CGFloat)timeoutInterval;

/*! @brief 播放贴片广告 初始化方法
 *
 * 采用外部传入Vast广告物料，每次初始化由STADManager完成，并通过STADManagerDelegate方法
 * - (void)stadOadAsset:(NSString *)asset isLocal:(BOOL)isLocal
 * 返回播放物料
 *
 * @param param             贴片的ADParam, STADManager会使用ADParam来制作物料URL
 * @param host              贴片的Host地质, STADManager会使用Host来制作物料URL
 * @param timeoutInterval   贴片的超时时间, STADManager会使用该字段来限制请求的超时时间
 *
 */
- (void)playOADWithADParam:(NSMutableDictionary *)param andServerHost:(NSString *)host andTimeout:(CGFloat)timeoutInterval;
- (void)playOADWithSTADADParam:(STADADParam *)param andServerHost:(NSString *)host andTimeout:(CGFloat)timeoutInterval;

/*! @brief 播放贴片广告进度报告方法
 *
 * 采用外部传入当前播放物料进度
 *
 * @param currentInterval  贴片的当前播放进度
 * @param summeryInterval  贴片的总播放长度
 *
 */
- (void)playOADProgressWithCurrentInterval:(float)currentInterval andSummeryInterval:(float)summeryInterval;

/*! @brief 贴片播放状态
 *
 * 采用外部传入当前播放物料状态
 *
 * @param movieState  贴片的当前播放状态
 *
 */
- (void)playOadStateChanged:(STADMovieState)movieState;

///*! @brief 外部播放器使用的单击贴片方法
// *
// * 单击播放中的贴片，由STADManager返回当前贴片单击信息
// *
// * @return 贴片单击URI
// *
// */
//- (NSString *)getOadClickThrough;

/*! @brief 离线播放贴片广告 初始化方法
 *
 * 采用外部传入本地视频videoID，每次初始化由STADManager完成，并通过STADManagerDelegate方法
 * - (void)stadOadAsset:(NSString *)asset isLocal:(BOOL)isLocal
 * 返回播放物料
 *
 * @param videoID   贴片的广告物料地址
 *
 * @return videoID是否有对应的离线广告播放物料
 *
 */
- (BOOL)playOfflineOADWithVideoID:(NSString *)videoID;

/*! @brief 单击贴片方法
 *
 * 单击播放中的贴片，由STADManager返回当前贴片单击信息
 *
 * @return 贴片单击URI
 *
 */
- (NSString *)getOadClickThrough;

/*! @brief 单击贴片方法
 *
 * 单击播放中的贴片，由STADManager返回当前贴片单击信息
 * 注：该方法不会进行点击上报
 *
 * @return 贴片单击URI
 *
 */
- (NSString *)getOadClickThroughWithoutTracking;

/*! @brief 贴片缓存地址获取方法
 *
 * 贴片缓存地址
 *
 * @return 贴片缓存地址
 *
 */
- (NSString *)getOadAdCachePath;

/*! @brief 播放贴片广告物料播放超时
 *
 * 采用外部传入超时事件
 * 当物料因为超时而无法播放时，请调用该方法
 */
- (void)playOadTimeout;

/*! @brief 贴片点击WebView展示页设置方法
 *
 * 传入点击View，广告点击之后，跳转的WebView展示页面
 *
 * @param contentView
 *
 */
- (void)setWebContentView:(UIView *)contentView;

/*! @brief 贴片点击WebView展示页关闭方法
 *
 * WebView展示页面可用户手动关闭或调用此接口关闭
 *
 * @param contentView
 */
- (void)closeWebContentView:(UIView *)contentView;

/*! @brief 打开广告SDK内部浏览器
 *
 * 通过STAD来打开广告内部浏览器
 *
 * @param urlString     跳转地址
 */
- (void)stadOpenUrlWithURLString:(NSString *)urlString;

/*! @brief 贴片播放相关方法
 *
 *  oadResume 恢复播放
 *  oadPause  暂停播放
 *  oadSkip   跳过
 *
 */
- (void)oadResume;
- (void)oadPause;
- (void)oadSkip;

/*! @brief 设置语音广告控件位置
 *
 * 用于语音广告控件View的位置，通过STADManager来控制控件位置
 * 注：需要传入右上角的坐标
 *
 * @param point 语音广告控件的右上角坐标
 *
 */
- (void)stadSetVoiceADViewRightOriginPoint:(CGPoint)point;

/*! @brief 停止贴片广告请求
 *
 * 用于停止当前贴片的广告请求
 *
 */
- (void)stadStopOADRequest;


/*! @brief 贴片广告播放错误上报接口
 *
 * 当物料地址播放超时或播放失败时由app告知sdk物料地址，由sdk上报不同类型错误
 *
 * @param inx  贴片索引
 * @param url  播放失败的物料地址
 */
- (void)stadErrorTrackingWithInx:(NSInteger)inx andUrl:(NSString*)urlString;

/*! @brief 前贴片广告播放使用打底物料播放
 *
 * 当第三方程序化才买物料无法播放，将要使用打底播放时告知SDK，切换上报数据
 *
 * @param inx  贴片索引
 *
 */
- (void)stadStandByPlayingSwitchWithInx:(NSString *)inx;

#pragma mark - 流内广告接口

/*! @brief 流内视频贴片广告vast解析
 *
 * 视频客户端流内贴片广告解析入口，传入vast内容，SDK解析完成后，回调前贴片广告delegate接口传递给客户端
 * 客户端需要在播放广告时仍需按原有接口报告广告播放进度，由SDK负责上报
 *
 * @param vastStr           vast内容
 * @param timeoutInterval   贴片的超时时间, STADManager会使用该字段来限制请求的超时时间
 *
 */
- (void)stadOadVastParseWithParam:(NSString *)vastStr andTimeout:(CGFloat)timeoutInterval;

#pragma mark -
#pragma mark 贴片广告缓存 API
/*! @brief 缓存贴片广告请求
 *
 * 用于缓存当天预定量Top10的前贴片的广告物料
 *
 */
- (void)stadStartPerdonwload;

#pragma mark -
#pragma mark 中插广告 API

/*! @brief 中插广告信息获取
 *
 * 用于获取当前视频的中插点位信息
 * 该方法返回信息通过方法 - (void)stadMadIndexInfos:(NSArray *)indexInfos 返回
 *
 * @param host 当前视频的打点信息的host地址
 * @param vid  当前视频的vid
 * @param tvid 当前视频的tvid
 * @param site 当前视频的mvrs与vid结合使用的唯一标识
 *
 * 注：正式地址为http://m.aty.sohu.com/mad
 *     测试地址为http://60.28.168.195/mad
 *
 */
- (void)stadGetMadIndexInfosWithServerHost:(NSString *)host
                                    andVid:(NSString *)vid
                                   andTvid:(NSString *)tvid
                                   andSite:(NSString *)site
                                __attribute__((deprecated));


#pragma mark - 中插和角标广告 API
/*! @brief 中插角标广告点位信息获取
 *
 * 用于获取当前视频的中插和角标点位信息
 *
 * @param videoAdParam 贴片的ADParam, STADManager会使用ADParam来获取中插和角标信息
 * @param paramhost   请求中插和角标点位信息host地址
 * @param madhost     请求中插物料host地址
 * @param flogohost   请求角标物料host地址
 * @param frame 角标广告尺寸
 * @param timeoutInterval 超时时间
 * @param isMadNeedSkip 是否中插播放跳过，YES不播放中插，NO正常播放
 */
- (void)stadGetMadAndFlogoInfosWithSTADADParam:(STADADParam *)videoAdParam
                                  andParamHost:(NSString *)paramhost
                                    andMadHost:(NSString *)madhost
                                  andFlogoHost:(NSString *)flogohost
                                 andFlogoFrame:(CGRect)frame
                                    andTimeout:(CGFloat)timeoutInterval
                              andIsMadNeedSkip:(BOOL)isMadNeedSkip;

/*! @brief 播放正片进度报告方法
 *
 * 采用外部传入当前播放正片进度,为中插和角标广告服务,播放广告物料时不调用！！
 * 当需要播放中插时，调用回调函数stadMadAssets:(NSArray *)assets madIntervals:(NSArray *)mad_intervals
 * 当需要播放角标且当前全屏模式时，获取角标并回调stadFlogoADDidFinishedLoading:(UIView *)stadFlogoADView andDuration:(float)duration
 *
 * @param currentInterval  正片的当前播放进度（秒）
 * @param summeryInterval  正片的总播放长度（秒）
 * @param isFullScreen     是否全屏播放
 */
- (void)stadVideoTicksWithCurrentInterval:(float)currentInterval andSummeryInterval:(float)summeryInterval andIsFullScreen:(BOOL)isFullScreen;

/*! @brief 角标展示上报方法
 *
 * 角标展示后由app通知sdk上报必要信息
 *
 * @param stadFlogoADView 角标广告容器
 *
 */
- (void)stadFlogoTrackWithAdView:(UIView *)stadFlogoADView;

/*! @brief 中插播放完成状态报告方法
 *
 * 多贴中插最后一贴播放完成状态后由app通知sdk，记录系统时间
 * 角标时间播放时间记录通过stadFlogoTrackWithAdView内部完成
 *
 */
- (void)stadMadPlayFinishRecordSysTime;

#pragma mark - 可选广告
/**
 *  用户从四个可选广告中选中一个开始播放时，由app告知sdk上报
 *
 *  @param inx             选中播放广告索引
 *  @param selectedseconds 可选广告开始展示到用户选中广告之间用户思考时长（秒）
 */
- (void)stadOptionalAdPlayWithInx:(NSInteger)inx userSelectedSec:(NSInteger)selectedseconds;

/**
 *  当前播放的可选广告物料播放进度
 *
 *  @param currentInterval 播放进度
 *  @param summeryInterval 总时长
 */
- (void)playOptionalAdProgressWithCurrentInterval:(float)currentInterval andSummeryInterval:(float)summeryInterval;

/**
 *  可选广告播放完成状态通知；当可选广告播放完成，或等待超时即将播放普通广告时调用告知SDK
 *
 *  @param isSkiped 可选广告播放完成：NO；跳过可选广告：YES；
 */
- (void)stadOptionalAdCompletedWithIsSkiped:(BOOL)isSkiped;

/**
 *  可选广告落地页地址获取
 *  当用户点击详情时调用次接口获取URL
 *
 *  @return 落地页URL
 */
- (NSString *)getOptionalAdClickThrough;

#pragma mark - 可跳过广告
/**
 *  当前贴片广告跳过时，告知sdk已播放时长
 *
 *  @param playedsec 广告跳过时已播放时长
 */
- (void)stadSkipAdPlayedSec:(NSInteger)playedsec;

#pragma mark -
#pragma mark 暂停广告
/*! @brief 暂停广告初始化方法
 *
 * 暂停广告初始化方法，每次初始化由STADManager返回UIView控件，之后由控件持有者控制广告生命周期
 * 默认广告可点击，展示内容不可交互
 *
 * @param param         暂停广告的ADParam, STADManager会使用ADParam来制作物料URL
 * @param host          暂停广告的Host, STADManager会使用host来制作物料URL
 * @param urlFormat     暂停广告的信息格式
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 *
 */
- (UIView *)getPADViewWithADParam:(NSMutableDictionary *)param
                    andServerHost:(NSString *)host
                andSuperviewFrame:(CGRect)superviewFrame
                       andTimeout:(CGFloat)timeoutInterval;
- (UIView *)getPADViewWithSTADADParam:(STADADParam *)param
                        andServerHost:(NSString *)host
                    andSuperviewFrame:(CGRect)superviewFrame
                           andTimeout:(CGFloat)timeoutInterval;
/*! @brief 暂停广告初始化方法
 *
 * 暂停广告初始化方法，每次初始化由STADManager返回UIView控件，之后由控件持有者控制广告生命周期
 * 默认广告可点击，展示内容不可交互
 *
 * @param adUrlString   暂停广告的信息地址
 * @param urlFormat     暂停广告的信息格式
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 *
 */
- (UIView *)getPADViewWithADURLString:(NSString *)adUrlString
                    andSuperviewFrame:(CGRect)superviewFrame
                           andTimeout:(CGFloat)timeoutInterval;
#pragma mark -
#pragma mark 开机广告 API
/*! @brief 开机广告初始化方法
 *
 * 开机广告初始化方法，每次初始化由STADManager返回UIView控件，之后由控件持有者控制广告生命周期
 * 默认广告可点击，展示内容不可交互
 *
 * @param param         开机广告的ADParam, STADManager会使用ADParam来制作物料URL
 * @param host          开机广告的Host, STADManager会使用host来制作物料URL
 * @param urlFormat     开机广告的信息格式
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 *
 */
- (UIView *)getOpenViewWithADParam:(NSMutableDictionary *)param
                     andServerHost:(NSString *)host
                 andSuperviewFrame:(CGRect)superviewFrame;
- (UIView *)getOpenViewWithSTADADParam:(STADADParam *)param
                         andServerHost:(NSString *)host
                     andSuperviewFrame:(CGRect)superviewFrame;

/*! @brief 开机广告初始化方法
 *
 * 开机广告初始化方法，每次初始化由STADManager返回UIView控件，之后由控件持有者控制广告生命周期
 *
 * @param frame         开机广告的frame
 * @param adUrlString   开机广告的信息地址
 * @param urlFormat   开机广告的信息格式
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 *
 */
- (UIView *)getOpenWithFrame:(CGRect)frame
             andADURLString:(NSString *)adUrlString;

/*! @brief 开机广告上报方法
 *
 * 开机广告参数上报方法，根据类型参数向广告服务器和第三方上报
 *
 * @param url    上报URL地址
 * @param trackType  上报类型 （目前第三方包括Admaster，miaozhen）
 */
- (void)stadOpenTrackWithURL:(NSString *)url andTrackType:(kSTADAdTrackType)trackType;

#pragma mark -
#pragma mark 离线暂停广告 API
/*! @brief 离线暂停广告初始化方法
 *
 * 离线暂停广告初始化方法，每次初始化由STADManager返回UIView控件，之后由控件持有者控制广告生命周期
 * 默认广告可点击，展示内容不可交互
 *
 * @param videoID       离线下载视频的ID信息
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 *
 */
- (UIView *)getOfflinePADViewWithVideoID:(NSString *)videoID
                       andSuperviewFrame:(CGRect)superviewFrame;

#pragma mark -
#pragma mark 离线广告资源管理 API
/*! @brief 离线资源下载
 *
 * 通过离线下载视频的ID信息，来获取对应离线贴片下载资源，交由STADManager管理下载
 *
 * @param param       离线下载视频的ADParam信息
 * @param host        广告的Host, STADManager会使用host来制作物料URL
 */
- (void)downloadOfflineADWithADParam:(NSMutableDictionary *)param
                       andServerHost:(NSString *)host;
- (void)downloadOfflineADWithSTADADParam:(STADADParam *)param
                           andServerHost:(NSString *)host;

/*! @brief 离线资源删除
 *
 * 通过离线下载视频的ID信息，来删除本地对应离线贴片下载资源
 *
 * @param param       离线下载视频的ADParam信息
 * @param host        广告的Host, STADManager会使用host来制作物料URL
 */
- (void)removeOfflineADWithADParam:(NSMutableDictionary *)param
                     andServerHost:(NSString *)host;
- (void)removeOfflineADWithSTADADParam:(STADADParam *)param
                         andServerHost:(NSString *)host;

#pragma mark -
#pragma mark 在线广告资源管理 API
/*! @brief 在线缓存资源删除
 *
 * 删除本地缓存的在线前贴片和角标资源
 *
 */
- (void)removeOnlineADCache;


#pragma mark -
#pragma mark 角标广告
/*! @brief 角标广告初始化方法
 *
 * 角标广告初始化方法，每次初始化由STADManager返回UIView控件，之后由控件持有者控制广告生命周期
 * 默认广告可点击，展示内容不可交互
 *
 * @param param         角标广告的ADParam, STADManager会使用ADParam来制作物料URL
 * @param host          角标广告的Host, STADManager会使用host来制作物料URL
 * @param urlFormat     角标广告的信息格式
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 *
 */
- (UIView *)getFlogoViewWithADParam:(NSMutableDictionary *)param
                      andServerHost:(NSString *)host
                           andFrame:(CGRect)frame
                         andTimeout:(CGFloat)timeoutInterval;
- (UIView *)getFlogoViewWithSTADADParam:(STADADParam *)param
                          andServerHost:(NSString *)host
                               andFrame:(CGRect)frame
                             andTimeout:(CGFloat)timeoutInterval;
/*! @brief 角标广告初始化方法
 *
 * 角标广告初始化方法，每次初始化由STADManager返回UIView控件，之后由控件持有者控制广告生命周期
 * 默认广告可点击，展示内容不可交互
 *
 * @param adUrlString   角标广告的信息地址
 * @param urlFormat     角标广告的信息格式
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 *
 */
- (UIView *)getFlogoViewWithADURLString:(NSString *)adUrlString
                               andFrame:(CGRect)frame
                             andTimeout:(CGFloat)timeoutInterval;

#pragma mark 统计
/*! @brief passport id上报接口
 *
 * 用户在客户端登陆成功后(包括前后台登陆)，客户端将passport id信息回传给广告sdk，供做精准投放决策优化
 *
 * @param passportId
 *
 */
- (void)stadLoginTrackWithPassport:(NSString *)passportId;

/**
 *  用于区别视频广告SDK使用场景，请在sdk初始化是传入
 *  （1）嵌入到新闻app视频TAB是，请传入kStadUseInSoHuNews
 *  （2）嵌入到搜狐视频app主线版本，请传入kStadUseInSohuTv
 *
 *  @param type 使用场景类型
 */
- (void)setAppId:(kStadUseInAppType)type;

#pragma mark - 落地页新接口
/**
 *  落地页展示接口，样式及功能与SFSafariViewController一致，支持iOS6+
 *
 *  @param url                   url地址
 *  @param currentViewController 展示落地页viewcontroller
 */
- (void)stadOpenLoadingPageWithUrl:(NSURL *)url andCurrentViewController:(UIViewController *)currentViewController;

/**
 *  关闭当前落地页
 */
- (void)stadCloseLoadingPage;

#pragma mark sohu新闻私有协议广告 API
/*! @brief sohu新闻 图文广告
 *
 * sohu新闻私有协议 图文广告
 *
 * @param frame       广告的位置信息
 * @param param       广告参数
 * @param url         私有协议的开机广告信息地址
 * @param isNight     是否为夜间模式
 * @param isNonepic   是否为无图模式
 * @param shouldRender是否需要渲染（加载至WebView）
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 */
- (UIView *)getNewsMraidWithFrame:(CGRect)frame
                         andParam:(NSDictionary *)param
                       andHosturl:(NSString *)url
                       andIsNight:(BOOL)isNight
                     andIsNonepic:(BOOL)isNonepic
                     shouldRender:(BOOL)shouldRender;
/*! @brief sohu新闻 开机广告
 *
 * sohu新闻私有协议 开机广告
 *
 * @param frame       广告的位置信息
 * @param param       广告参数
 * @param url         私有协议的开机广告信息地址
 * @param isNight     是否为夜间模式
 * @param isNonepic   是否为无图模式
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 */
- (UIView *)getNewsMraidOpenWithFrame:(CGRect)frame
                             andParam:(NSDictionary *)param
                           andHosturl:(NSString *)url
                           andIsNight:(BOOL)isNight
                         andIsNonepic:(BOOL)isNonepic
                         shouldRender:(BOOL)shouldRender;

/*! @brief sohu新闻 快速获取开机广告信息
 *
 * sohu新闻私有协议 用于快速获取开机广告信息，直接访问数据库，不通过控件层
 *
 * @param  itemspaceid 开机广告对应的itemspaceid
 * @return 返回开机广告的具体信息 如果为nil则无可展示数据
 *
 */
- (NSDictionary *)getLoadingInfosForNews:(NSString *)itemspaceid;

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


#pragma mark -
#pragma mark 流内广告曝光接口

typedef NS_ENUM(NSInteger, STADDisplayTrackType) {
    STADDisplayTrackTypeUnknown = 1,    //未知上报类型（不使用）
    STADDisplayTrackTypeNotInterest,    //不感兴趣
    STADDisplayTrackTypeClick,          //点击
    STADDisplayTrackTypeLoadImp,        //加载曝光 （曝光）
    STADDisplayTrackTypeImp,            //展示曝光 （有效曝光）
    STADDisplayTrackTypeNullAD,         //空广告曝光
    STADDisplayTrackTypePlaying         //流内视频播放
};

/*! @brief sohu静态展示广告 通用上报接口
 *
 * sohu私有协议，静态展示广告通用上报接口 
 * 当host为空时，SDK会根据传入类型来判断，并使用默认地址
 *
 * @param trackType  上报类型
 * @param host       上报host,如传入空，则由SDK根据类型，使用默认地址
 * @param params     广告SDK未知参数，通过Map格式传入，SDK拼接生成
 *
 */
- (void)stadDisplayTrackWithType:(STADDisplayTrackType)trackType
                      andHostURL:(NSString *)host
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


#pragma mark -
#pragma mark 第三方曝光接口
/*! @brief 第三方曝光接口
 *
 * 通过STAD来进行普通曝光和调用第三方SDK曝光
 *
 * @param track_url     曝光地址
 * @param trackType     曝光类型 （目前第三方包括Admaster，miaozhen）
 */
- (void)stadAdTrack:(NSString *)track_url andTrackType:(kSTADAdTrackType)trackType;


#pragma mark sohu视频私有协议广告 API
/*! @brief sohu视频 图文广告
 *
 * sohu视频私有协议 图文广告
 *
 * @param frame       广告的位置信息
 * @param param       广告参数
 * @param url         私有协议的开机广告信息地址
 * @param isNight     是否为夜间模式
 * @param isNonepic   是否为无图模式
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 */
- (UIView *)getTVMraidWithFrame:(CGRect)frame
                       andParam:(NSDictionary *)param
                     andHosturl:(NSString *)url
                     andIsNight:(BOOL)isNight
                   andIsNonepic:(BOOL)isNonepic;

@end
