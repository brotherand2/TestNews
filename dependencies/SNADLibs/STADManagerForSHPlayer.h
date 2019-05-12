//
//  STADManagerForSHPlayer.h
//  STAD
//
//  Created by 唱宏博 on 14-2-17.
//  Copyright (c) 2014年 hugo.chang. All rights reserved.

#pragma mark 需要导入的Framework
//
// 注意：需要在Other Linker Flags中，加入-ObjC
//      已内含Admaster(MobileTracking)通用SDK 和 秒针SDK(MZMontior)
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
#import "STADADParam.h"

#pragma mark 外部传入播放器状态
typedef enum {
    STADMovieStatePlaybackStopped = 1,          //结束播放，AD会全部停止，当作Skip来处理
    STADMovieStatePlaybackPlaying,              //播放
    STADMovieStatePlaybackPaused,               //暂停
    STADMovieStatePlaybackInterrupted,          //打断(暂不做处理)
    STADMovieStateFinishReasonPlaybackEnded,    //正常播放结束
    STADMovieStateFinishReasonPlaybackError,    //出现错误，播放结束
    STADMovieStateFinishReasonUserExited,       //用户退出，播放结束
    STADMovieStateFinishReasonLoadingError      //出现错误，无聊无法加载
}STADMovieState;

#pragma mark Delegate返回标识信息
typedef enum {
    kStadOadStateLoaded = 1,  //OAD信息加载完毕
    kStadOadStateStarted,     //OAD开始播放
    kStadOadStatePaused,      //OAD暂停
    kStadOadStateResumed,     //OAD恢复播放
    kStadOadStateClicked,     //OAD被点击
    kStadOadStateEnded,       //OAD单帖结束
    kStadOadStateCompleted,   //OAD全部播放完毕
    kStadOadStateSkiped       //OAD跳过
}kStadOadStateKey;

typedef enum {
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
}kStadOadTrackEventKey;

typedef enum {
    kStadOadErrorNoNetwork = 1,       //无网络 错误
    kStadOadErrorHighDelay,           //缓冲时间过长，高延迟（超过广告一半时间）
    kStadOadErrorNoData,              //无信息 错误
    kStadOadErrorFailedToPlayToEnd,   //OAD 播放未完成 错误
    kStadOadErrorEntryError,          //OAD 播放无法开始 错误
    kStadOadErrorAssetNotAvaliable,   //OAD 无效播放文件 错误
    kStadOadErrorNullAD               //OAD 空广告 错误
}kStadOadErrorKey;

typedef enum {
    kStadWebViewTypeUnknow = 1,         //未知类型
    kStadWebViewTypeNodata,             //无跳转地址
    kStadWebViewTypeNormal,             //正常跳转
    kStadWebViewTypeMediaPlayer,        //包含播放器
    kStadWebViewTypeAppStore,           //跳转至Appstore
    kStadWebViewTypeSafari              //跳转至Safari
}kStadWebViewType;

typedef enum {
    kSTADAdTrackTypeNormal = 1,      //正常曝光
    kSTADAdTrackTypeAdmaster,        //Admaster 曝光
    kSTADAdTrackTypeMiaozhen,        //Miaozhen 曝光
    kSTADAdTrackTypeUnknow           //未知曝光（等同于正常曝光处理）
}kSTADAdTrackType;

#pragma mark -

/*! @brief 接收并处理来至STAD sdk的事件消息
 *
 * 接收并处理来至STAD sdk的事件消息
 */

@protocol STADManagerDelegate <NSObject>

#pragma mark -
#pragma mark 前贴片广告部分的Delegate事件
/*! @brief 获取前贴片的播放进度
 *
 * 收到sdk 返回的进度的事件，方法返回的频度于获取前贴片方法中设置
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

/*! @brief 前贴片的播放状态变更
 *
 * 播放器状态变更，包括Loaded（加载完毕），Started(开始)，Paused（暂停），Resumed（恢复），
 Clicked（被点击），Ended（单贴播放结束），Completed（整体播放结束），Skiped（跳过前贴片播放）
 *
 * @param state为状态标识，详见kStadOadStateKey
 */
@optional
- (void)stadOADStateChanged:(kStadOadStateKey)state;

/*! @brief trackEvent 跟踪事件类型反馈
 *
 * 前贴片播放事件曝光跟踪，包括CreateView（创建），Start（开始），FirstQuartile（1/4长度），MidPoint（1/2长度），
 * ThirdQuartile（3/4长度），Complete（结束），Pause（暂停），Resume（恢复），
 * Skip（跳过），ClickTracking（点击），Null（空广告）
 *
 * @param trackEvent为事件曝光标识，详见kStadOadTrackEventKey
 */
@optional
- (void)stadOADTrackEvent:(kStadOadTrackEventKey)trackEvent;


/*! @brief 前贴片错误报告
 *
 * 前贴片播放中出现的错误，包括NoNetWork(无网络)，HighDelay（高延迟，缓冲事件过长），NoData（无信息），
 * FailedToPlayToEnd（播放未完成，不包括切换前贴片），EntryError（播放无法开始），AssetNotAvaliable（播放资源无效）
 *
 * @param error错误标识，详见kStadOadErrorKey
 */
@optional
- (void)stadOADError:(kStadOadErrorKey)error;


/*! @brief 前贴片点击事件
 *
 * 前贴片被点击，如果前贴片的点击信息SDK无法处理，则通过该方法返回
 *
 * @param clickInfo点击信息
 */
@optional
- (void)stadOADClickInfo:(NSString *)clickInfo;

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
@end


@interface STADManager : NSObject

/** STADManagerDelegate代理，用以获取代理事件
 * @note 所有方法都为@optional
 */
@property (nonatomic, assign) id <STADManagerDelegate> delegate;
- (void)setDelegateObject:(id<STADManagerDelegate>)delegateObject;
- (void)removeDelegateObject:(id<STADManagerDelegate>)delegateObject;

/*! @brief 返回一个STADManager对象
 *
 * @note 返回的对象是单例，不可释放
 */
+ (STADManager*)sharedSTADManager;

/*! @brief STAD Api接口函数
 *
 * 该类封装了STAD SDK的所有接口
 */

#pragma mark -
#pragma mark 播放前贴片广告 API
/*! @brief 播放前贴片广告 初始化方法
 *
 * 采用外部传入Vast广告物料，每次初始化由STADManager完成，并通过STADManagerDelegate方法
 * - (void)stadOadAsset:(NSString *)asset isLocal:(BOOL)isLocal
 * 返回播放物料
 *
 * @param adUrlString   前贴片的广告物料地址 如果传入为nil，则使用ADParam来制作物料URL
 *
 */
- (void)playOADWithADURLString:(NSString *)adUrlString andTimeout:(CGFloat)timeoutInterval;

/*! @brief 播放前贴片广告 初始化方法
 *
 * 采用外部传入Vast广告物料，每次初始化由STADManager完成，并通过STADManagerDelegate方法
 * - (void)stadOadAsset:(NSString *)asset isLocal:(BOOL)isLocal
 * 返回播放物料
 *
 * @param param             前贴片的ADParam, STADManager会使用ADParam来制作物料URL
 * @param host              前贴片的Host地质, STADManager会使用Host来制作物料URL
 * @param timeoutInterval   前贴片的超时时间, STADManager会使用该字段来限制请求的超时时间
 *
 */
- (void)playOADWithSTADADParam:(STADADParam *)param andServerHost:(NSString *)host andTimeout:(CGFloat)timeoutInterval;


/*! @brief 播放前贴片广告进度报告方法
 *
 * 采用外部传入当前播放物料进度
 *
 * @param currentInterval  前贴片的当前播放进度
 * @param summeryInterval  前贴片的总播放长度
 *
 */
- (void)playOADProgressWithCurrentInterval:(float)currentInterval andSummeryInterval:(float)summeryInterval;

/*! @brief 前贴片播放状态
 *
 * 采用外部传入当前播放物料状态
 *
 * @param movieState  前贴片的当前播放状态
 *
 */
- (void)playOadStateChanged:(STADMovieState)movieState;

/*! @brief 前贴片点击WebView展示页设置方法
 *
 * 传入点击View，广告点击之后，跳转的WebView展示页面
 *
 * @param contentView
 *
 */
- (void)setWebContentView:(UIView *)contentView;

/*! @brief 单击前贴片方法
 *
 * 单击播放中的前贴片，由STADManager返回当前前贴片单击信息
 *
 * @return 前贴片单击URI
 *
 */
- (NSString *)getOadClickThrough;

/*! @brief 单击前贴片方法
 *
 * 单击播放中的前贴片，由STADManager返回当前前贴片单击信息
 * 注：该方法不会进行点击上报
 *
 * @return 前贴片单击URI
 *
 */
- (NSString *)getOadClickThroughWithoutTracking;

/*! @brief 播放前贴片广告物料播放超时
 *
 * 采用外部传入超时事件
 * 当物料因为超时而无法播放时，请调用该方法
 */
- (void)playOadTimeout;

/*! @brief 停止前贴片广告请求
 *
 * 用于停止当前前贴片的广告请求
 *
 */
- (void)stadStopOADRequest;

#pragma mark 第三方曝光接口
/*! @brief 离线资源删除
 *
 * 通过STAD来进行普通曝光和调用第三方SDK曝光
 *
 * @param track_url     曝光地址
 * @param trackType     曝光类型 （目前第三方包括Admaster，miaozhen）
 */
- (void)stadAdTrack:(NSString *)track_url andTrackType:(kSTADAdTrackType)trackType;

#pragma mark -
#pragma mark 离线广告资源管理 API
/*! @brief 离线资源下载
 *
 * 通过离线下载视频的ID信息，来获取对应离线前贴片下载资源，交由STADManager管理下载
 *
 * @param param       离线下载视频的ADParam信息
 * @param host        广告的Host, STADManager会使用host来制作物料URL
 */
- (void)downloadOfflineADWithSTADADParam:(STADADParam *)param
                           andServerHost:(NSString *)host;

/*! @brief 离线资源删除
 *
 * 通过离线下载视频的ID信息，来删除本地对应离线前贴片下载资源
 *
 * @param param       离线下载视频的ADParam信息
 * @param host        广告的Host, STADManager会使用host来制作物料URL
 */
- (void)removeOfflineADWithSTADADParam:(STADADParam *)param
                         andServerHost:(NSString *)host;
@end