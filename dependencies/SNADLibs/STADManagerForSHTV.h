//
//  STADManagerForSHTV.h
//  STAD
//
//  Created by jinkai on 13-10-25.
//  Copyright (c) 2015年 sohu All rights reserved.
//

#pragma mark 需要导入的Framework
//
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
//  StoreKit
//  WebKit
//  AddressBook
//

#import <UIKit/UIKit.h>
#import "STADADParam.h"

extern NSString *const STADThirdCellBnannerKey;
extern NSString *const STADFifthCellBnannerKey;
extern NSString *const STADSeventhCellBnannerKey;
extern NSString *const STADNinethCellBannerKey;

#pragma mark - 外部传入播放器状态
typedef NS_ENUM(NSInteger, STADMovieState) {
    STADMovieStatePlaybackStopped = 1,          //结束播放，AD会全部停止，当作Skip来处理
    STADMovieStatePlaybackPlaying,              //播放
    STADMovieStatePlaybackPaused,               //暂停
    STADMovieStatePlaybackInterrupted,          //打断(暂不做处理)
    STADMovieStateFinishReasonPlaybackEnded,    //正常播放结束
    STADMovieStateFinishReasonPlaybackError,    //出现错误，播放结束
    STADMovieStateFinishReasonUserExited,       //用户退出，播放结束
    STADMovieStateFinishReasonLoadingError,     //出现错误，无聊无法加载
    STADMovieStatePlayBackSwitch                // 在正常播放前贴片过程中切贴
};

#pragma mark - Delegate返回标识信息
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

typedef NS_ENUM(NSInteger, kStadWebViewType) {
    kStadWebViewTypeUnknow = 1,         //未知类型
    kStadWebViewTypeNodata,             //无跳转地址
    kStadWebViewTypeNormal,             //正常跳转
    kStadWebViewTypeMediaPlayer,        //包含播放器
    kStadWebViewTypeAppStore,           //跳转至Appstore
    kStadWebViewTypeSafari,             //跳转至Safari
    kStadWebURLHALFScreen,              //半屏展示 iphone
    kStadWebViewTypeSOHUVIDEO           //视频app协议
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
    kSTADDismissViewTypeCustomSafariController, //SDK提供落地页，返回事件由客户端处理
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

#pragma mark - 视频下载模板协议
@protocol STADVideoBannerProtocol <NSObject>

/**
 开始播放
 在视频下载模板中可用此方法控制视频的播放
 */
- (void)startPlay;

/**
 暂停播放
 在视频下载模板中可用此方法控制视频的暂停
 */
- (void)pausePlay;

/**
 重置播放
 在视频下载模板中可用此方法控制视频的进度重置，重置后为暂停状态
 */
- (void)resetPlay;

/**
 是否为视频广告
 
 @return YES/NO
 */
- (BOOL)isVideoAd;

/**
 是否全屏
 
 @return YES/NO
 */
- (BOOL)isFullScreen;

@end

#pragma mark -

/*! @brief 接收并处理来至STAD sdk的事件消息
 *
 * 接收并处理来至STAD sdk的事件消息
 */

@protocol STADManagerDelegate <NSObject>

#pragma mark - 前贴片广告Delegate事件

/*! @brief 获取前贴的播放进度
 *
 * 收到sdk 返回的进度的事件，方法返回的频度于获取贴片方法中设置
 *
 * @param asset    为当前播放物料地址
 * @param isLocal  为当前播放物料是否为本地资源 (本地：YES,外部：NO)
 *
 */
@optional
- (void)stadOadAsset:(NSString *)asset isLocal:(BOOL)isLocal;

/*! @brief 批量获取前贴的播放物料
 *
 * 收到sdk 批量返回前贴的播放物料
 *
 * @param assets          为当前播放物料地址数组
 * @param oad_intervals   为当前播放物料时长数组
 * @param adtype          为当前播放物料为哪种广告类型（目前包括oad前贴，mad中插，ead后贴）
 *
 * @return UIView  需要返回当前可触发广告的View
 */
@optional
- (UIView *)stadOadAssets:(NSArray *)assets oadIntervals:(NSArray *)oad_intervals andADType:(NSString *)adtype;

/*! @brief 贴片的播放状态变更
 *
 * 播放器状态变更，包括Loaded（加载完毕），Started(开始)，Paused（暂停），Resumed（恢复），
 Clicked（被点击），Ended（单贴播放结束），Completed（整体播放结束），Skiped（跳过贴片播放）
 *
 * @param state 为状态标识，详见kStadOadStateKey
 */
@optional
- (void)stadOADStateChanged:(kStadOadStateKey)state;

/*! @brief trackEvent 跟踪事件类型反馈
 *
 * 贴片播放事件曝光跟踪，包括CreateView（创建），Start（开始），FirstQuartile（1/4长度），MidPoint（1/2长度），
 * ThirdQuartile（3/4长度），Complete（结束），Pause（暂停），Resume（恢复），
 * Skip（跳过），ClickTracking（点击），Null（空广告）
 *
 * @param trackEvent 为事件曝光标识，详见kStadOadTrackEventKey
 */
@optional
- (void)stadOADTrackEvent:(kStadOadTrackEventKey)trackEvent;


/*! @brief 贴片错误报告
 *
 * 贴片播放中出现的错误，包括NoNetWork(无网络)，HighDelay（高延迟，缓冲事件过长），NoData（无信息），
 * FailedToPlayToEnd（播放未完成，不包括切换贴片），EntryError（播放无法开始），AssetNotAvaliable（播放资源无效）
 *
 * @param error 错误标识，详见kStadOadErrorKey
 */
@optional
- (void)stadOADError:(kStadOadErrorKey)error;


/*! @brief 贴片点击事件
 *
 * 贴片被点击，如果贴片的点击信息SDK无法处理，则通过该方法返回
 *
 * @param clickInfo 点击信息
 */
@optional
- (void)stadOADClickInfo:(NSString *)clickInfo;

/**
 *  MRIAD广告加载完成事件，由app贴在播放器中间区域
 *  可能包含多个View,由索引标明对应哪贴广告
 *  例如：视频广告包含5贴 oad1-5，其中只有3，4，5贴包含mraid广告，则字典内容｛［2，view3］，［3，view4］，［4，view5］｝，索引从0开始
 *
 *  @param mraidViewsDict  mraid广告对象字典，key是索引指，value是mraidView对象
 */
@optional
- (void)stadOADMraidViewDidFinishLoading:(NSDictionary *)mraidViewsDict;

/**
 *  MRIAD广告浮层消隐回调事件
 *  由SDK移除前贴片广告的MRAID浮层后回调函数
 *
 * @param mraidView  mraid广告对象
 */
@optional
- (void)stadOADMraidViewDismiss:(UIView *)mraidView;

/**
 *  MRIAD广告浮层暂停回调事件
 *
 * @param mraidView  mraid广告对象
 */
@optional
- (void)stadOADMraidViewPause:(UIView *)mraidView;

/**
 *  MRIAD广告浮层继续播放回调事件
 *
 * @param mraidView  mraid广告对象
 */
@optional
- (void)stadOADMraidViewResume:(UIView *)mraidView;

/**
 *  MRIAD广告浮层跳过前贴片回调事件
 *
 * @param mraidView  mraid广告对象
 */
@optional
- (void)stadOADMraidViewSkip:(UIView *)mraidView;

/**
 *  去广告按钮点击回调，有客户端处理
 *
 */
@optional
- (void)stadDisableADbuttonClick;

/**
 *  跳过广告按钮点击回调，有客户端处理
 *
 */
@optional
- (void)stadSkipbuttonClick;


#pragma mark - 中插广告Delegate事件

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

#pragma mark - 可选广告Delegate事件

/**
 *  可选广告回调接口
 *
 *  @param optAssets       可选广告物料地址数组
 *  @param normalAssets    普通广告物料地址数组
 *  @param skipoffset      等待用户选择可选广告跳过时长
 *  @param notifyImgUrlStr 提示语图片链接
 */
@optional
- (void)stadOptAssets:(NSArray *)optAssets normalAssets:(NSArray *)normalAssets andSkipOffset:(NSInteger)skipoffset andNotifyImgUrlStr:(NSString *)url;

/**
 *  用户从四个可选广告中选中一个开始播放时，由sdk告知app播放
 *
 *  @param inx             选中播放广告索引
 */
@optional
- (void)stadOptionalAdSelectWithInx:(NSInteger)index;

/**
 *  用户未选择，由sdk告知app播放普通广告
 *
 */
@optional
- (void)stadOptionalNoSelect;


#pragma mark - 语音广告Delegate事件
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

#pragma mark - 暂停广告Delegate事件

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
 * @param clickInfo 点击信息
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

#pragma mark - 角标广告Delegate事件

/*! @brief 角标广告加载完成事件
 *
 * 需要app展示角标广告时SDK调用此函数，展示满足时长后app移除角标广告
 *
 * @param stadFlogoADView 角标广告容器
 * @param duration 角标广告展示时长,单位 (秒)
 */
@optional
- (void)stadFlogoADDidFinishedLoading:(UIView *)stadFlogoADView andDuration:(float)duration;

/*! @brief 全时角标广告加载完成事件
 *
 * 全时角标广告在正片播放期间持续展示，不可关闭，app不能移除
 *
 * @param stadFlogoADView 角标广告容器
 */
@optional
- (void)stadFullTimeFlogoADDidFinishedLoading:(UIView *)stadFlogoADView;

/*! @brief 角标广告获取错误
 *
 * 角标广告load错误，无法正常获取广告内容
 *
 */
@optional
- (void)stadFlogoADLoadError;

#pragma mark - 压屏条广告Delegate事件
/*! @brief 压屏条广告加载结束事件
 *
 * 需要app展示角标广告时SDK调用此函数，展示满足时长后app移除角标广告
 *
 * @param stadBandADView 压屏条广告容器
 * @param duration 压屏条广告展示时长,单位 (秒)
 * @param location 压屏条广告位置,1表示左下角，2表示居中
 */
@optional
- (void)stadBandADDidFinishedLoading:(UIView *)stadBandADView andDuration:(float)duration andLocation:(NSInteger)location;

/*! @brief 压屏条广告获取错误
 *
 * 压屏条广告load错误，无法正常获取广告内容
 *
 */
@optional
- (void)stadBandADLoadError;

#pragma mark - 焦点图Delegate事件
/*! @brief 焦点图被点击
 *
 */
@optional
- (void)focusViewClicked:(NSString *)clickURLString supportDeeplink:(BOOL)supportDeeplink;

/*! @brief 焦点图加载完毕
 *
 */
@optional
- (void)focusViewDidFinishLoadWithDict:(NSDictionary *)dict catecode:(NSString *)catecode;

#pragma mark - 浮层广告Delegate事件
/*! @brief 浮层广告获取错误
 *
 * 可能是网络出错、数据解析错误、缓存未命中等原因
 *
 */
@optional
- (void)overflyViewDidFailed:(UIView *)overflyView;
/*! @brief 浮层广告获取成功
 *
 * 此时返回一个浮层的view，将这个view添加到客户端自己的view上，视频就会自动开始加载。
 *
 */
@optional
- (void)overflyViewDidSucceed:(UIView *)overflyView;
/*! @brief 浮层广告播放时出错
 *
 * 这个回调是当浮层的view被添加到view上加载视频失败的情况，此时应该及时将浮层移除。
 *
 */
@optional
- (void)overflyViewdidFailedToPlayVideo:(UIView *)overflyView;
/*! @brief 浮层广告播放视频结束
 *
 * 浮层广告播放视频结束，可以将浮层view移除
 *
 */
@optional
- (void)overflyViewdidFinishToPlayVideo:(UIView *)overflyView;
/*! @brief 浮层广告被点击
 *
 * 和前贴片一样处理点击事件即可，同时需注意，此时要移除浮层view
 *
 */
@optional
- (void)overflyView:(UIView *)overflyView didClickedWithURLString:(NSString *)urlString stadWebViewType:(kStadWebViewType)type supportDeeplink:(BOOL)supportDeeplink;

#pragma mark - Banner广告Delegate事件

/*! @brief Banner广告加载完成
 *
 * SDK完成数据解析和UI渲染，返回UIView数组，包含一个或多个View对象
 * 注意：如果提前预请求广告，但是不马上展示在界面上，等到用户滑动广告内容到可视区域内，再addSubview展示
 *
 * @param stadBadViewArr Banner广告View容器数组
 * @param pageId Banner广告所在页面ID,由app生成唯一参数，sdk回调时回传，用于区别广告属于不同页面
 */
@optional
- (void)stadBADDidFinishedLoading:(NSArray *)stadBadViewArr andPageId:(NSString *)pageId;

/*! @brief Banner广告点击事件
 *
 * Banner广告被点击，app根据回传url调用sdk拉起落地页，此时如果广告／内容播放中需要暂停
 * @param url  落地页地址
 * @param pageId Banner广告所在页面ID,由app生成唯一参数，sdk回调时回传，用于区别广告属于不同页面
 */
@optional
- (void)stadBADWillBeClickedWithUrl:(NSString *)url andPageId:(NSString *)pageId supportDeeplink:(BOOL)supportDeeplink;


@optional
/**
 *  Banner广告获取错误
 *
 *  @param pageId Banner广告所在页面ID,由app生成唯一参数，sdk回调时回传，用于区别广告属于不同页面
 */
- (void)stadBADLoadErrorWithPageId:(NSString *)pageId;

#pragma mark - 非播放页Banner广告Delegate事件

/**
 *  非播放页Banner广告加载完成事件，由sdk回传app贴在指定位置
 *
 *  @param imgBadView bannerView数组
 *  @param bannerId   banner广告位置id
 */
@optional
- (void)stadImgBannerViewFinishedLoading:(NSArray *)imgBadArr posCode:(kStadBannerId)bannerId;

/**
 *  非播放页Banner广告点击事件
 *  Banner广告被点击，app根据回传url调用sdk拉起落地页
 *
 *  @param url      落地页地址
 *  @param bannerId banner广告位置id
 */
@optional
- (void)stadImgBannerViewWillBeClickedWithUrl:(NSString *)url posCode:(kStadBannerId)bannerId supportDeeplink:(BOOL)supportDeeplink;

/**
 *  非播放页Banner广告获取错误
 *
 *  @param bannerId banner广告位置id
 */
@optional
- (void)stadImgBannerViewLoadErrorWithPosCode:(kStadBannerId)bannerId;

/**
 *  非播放页Banner开始播放视频
 *
 *  @param view 开始播放的banner
 */
@optional
- (void)stadImgBannerViewStartToPlayVideo:(UIView<STADVideoBannerProtocol> *)view;

/**
 *  非播放页Banner停止播放视频
 *
 *  @param view 停止播放的banner
 */
@optional
- (void)stadImgBannerViewStopPlayVideo:(UIView<STADVideoBannerProtocol> *)view;

/**
 *  非播放页Banner播放视频完毕
 *
 *  @param view 播放完毕的banner
 */
@optional
- (void)stadImgBannerViewFinishToPlayVideo:(UIView<STADVideoBannerProtocol> *)view;

/**
 *  非播放页Banner全屏播放
 *
 *  @param view 全屏播放的banner
 */
@optional
- (void)stadImgBannerViewEnterFullScreen:(UIView<STADVideoBannerProtocol> *)view;

/**
 *  非播放页Banner退出全屏
 *
 *  @param view 退出全屏的banner
 */
@optional
- (void)stadImgBannerViewExitFullScreen:(UIView<STADVideoBannerProtocol> *)view;

#pragma mark - 广告关闭/跳转Delegate事件
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

/*! @brief 广告跳转
 *
 * 广告点击产生的跳转
 *
 * @param webViewType      跳转类型
 * @param urlString        跳转地址
 * @param webContentView   跳转打开容器
 */
@optional
- (void)stadWebViewType:(kStadWebViewType)webViewType andURL:(NSString *)urlString andWebContentView:(UIView *)webContentView supportDeeplink:(BOOL)supportDeeplink;

#pragma mark - 开机广告Delegate事件
/**
 *  开机广告图片加载成功事件
 *
 *  @param localImgPath 开机广告展示viewcontroller
 *  @param oadInterval  开机广告展示时长
 */
@optional
- (void)stadOpenAssetDidFinishedLoading:(UIViewController *)openADVC interval:(NSTimeInterval)oadInterval;

/*! @brief 开机广告获取错误
 *
 * 开机广告load错误，无法正常获取广告内容
 *
 */
@optional
- (void)stadOpenAssetNotAvaliable;


/*! @brief 开机广告结束，包括所有业务逻辑
 *
 */
@optional
- (void)stadOpenADFinished;

/*! @brief 开机广告错误
 *
 */
@optional
- (void)stadOpenADFailed;

#pragma mark - 贴片广告上报信息回传Delegate事件
/*! @brief 广告上报回调
 *
 * 广告开始时，会通过该方法回传上报地址，以及每贴广告时长（0为空广告，无时长）
 *
 * @param impArr        上报地址数组
 * @param intervalArr   广告每贴时长
 *
 */
@optional
- (void)stadOadImps:(NSArray *)impArr andOadIntervals:(NSArray *)intervalArr;

/*! @brief 广告单词上报回调
 *
 * 每贴广告开始会进行曝光上报，此时将该条上报返回
 *
 * @param imp  当前上报地址（包括空广告）
 * @param duration  当前贴数时长（包括空广告）
 *
 */
@optional
- (void)stadOadCurrentImp:(NSString *)imp andDuration:(NSString *)duration;


#pragma mark - 弹幕广告Delegate事件

/**
 *  弹幕广告加载完成，开始展示
 *  @param barrageView  弹幕广告View对象
 */
@optional
- (void)stadBarrageDidFinishedLoading:(UIView *)barrageView;

/**
 *  弹幕广告加载失败
 *  @param barrageView  弹幕广告View对象
 */
@optional
- (void)stadBarrageLoadError:(UIView *)barrageView;

/**
 *  弹幕广告点击事件触发，即将弹出落地页，需要暂停视频播放
 *
 *  @param barrageView 弹幕广告View对象
 *  @param url         落地页地址
 */
@optional
- (void)stadBarrageDidClicked:(UIView *)barrageView Url:(NSString *)url supportDeeplink:(BOOL)supportDeeplink;

#pragma mark - 包框广告Delegate事件
/**
 *  包框广告加载完成，回传包框广告View，由app贴在播放器下层
 *
 *  @param wrapframeView  包框广告View对象
 *  @param duration  展示时长
 */
@optional
- (void)stadWrapframeDidFinishedLoading:(UIView *)wrapframeView duration:(NSTimeInterval)duration;

/**
 *  包框广告加载失败
 *
 *  @param wrapframeView  包框广告View对象
 */
@optional
- (void)stadWrapframeLoadError:(UIView *)wrapframeView;

/**
 *  包框广告点击事件触发，即将弹出落地页
 *
 *  @param wrapframeView  包框广告View对象
 */
@optional
- (void)stadWrapframeDidClicked:(UIView *)wrapframeView;

#pragma mark - 埋点上报delegate

/**
 *  为了解决线上数据差距较大，设置此回调由客户端上报，现只针对15512广告位
 *
 *  @param eventID         打点的点位
 *  @param guid            应视频要求加上广告库存参数
 *  @param dict            需要上报的必要信息
 */
@optional
- (void)trackWithEventID:(NSString *)eventID guid:(NSString *)guid infoDictionary:(NSDictionary *)dict;

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

#pragma mark - 焦点图 API
/**
 *  焦点图广告初始化方法
 *
 *  @param param 焦点图广告的ADParam
 *  @param catecode 用于区分不同的频道
 *  @param host  焦点图广告的Host
 */
- (void)getFocusAdWithADParam:(STADADParam *)param
                     catecode:(NSString *)catecode
                andServerHost:(NSString *)host;

/**
 *  焦点图展示上报方法
 *
 */
- (void)focusViewActiveImpressionWithKeys:(NSString *)key ;

#pragma mark - 播放视频浮层 API
/**
 *  视频浮层广告初始化方法
 *
 *  @param param 浮层广告的ADParam
 *  @param host  浮层广告的Host
 */
- (void)getOverflyAdWithADParam:(STADADParam *)param
                  andServerHost:(NSString *)host;

#pragma mark - 切换模式 API
/*! @brief 切换夜间模式，目前提供给新闻app视频tab
 *
 * @param isNightMode 是否开启夜间模式
 */
- (void)switchMode:(BOOL)isNightMode;

#pragma mark - 播放贴片广告 API
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
 * @param host              贴片的Host地址, STADManager会使用Host来制作物料URL
 * @param timeoutInterval   贴片的超时时间, STADManager会使用该字段来限制请求的超时时间
 *
 */
- (void)playOADWithADParam:(NSMutableDictionary *)param andServerHost:(NSString *)host andTimeout:(CGFloat)timeoutInterval;
- (void)playOADWithSTADADParam:(STADADParam *)param andServerHost:(NSString *)host andTimeout:(CGFloat)timeoutInterval;

/*! @brief 传入播放前贴片的view
 *
 * 当app传入view之后，将渲染前贴片UI
 *
 * @param parentView  播放前贴片的view
 *
 */
- (void)stadOadParentView:(UIView *)parentView;

- (void)destoryOadParentView:(UIView *)parentView;

/*! @brief 传入播放可选前贴片的view
 *
 * 当app传入view之后，将渲染可选前贴片UI
 *
 * @param parentView  播放可选前贴片的view
 *
 */
- (void)stadOptionalOadParentView:(UIView *)parentView;

/*! @brief app开始播放前贴片
 *
 *
 * 当播放器开始播放前贴片时候，告知sdk，开始倒计时
 */
- (void)startPlayOad;

/*! @brief 播放贴片广告进度报告方法
 *
 * 采用外部传入当前播放物料进度
 *
 * @param currentInterval  当前一贴广告的播放进度
 * @param summeryInterval  当前一贴广告的总播放长度
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

/*! @brief 可选前贴片播放状态
 *
 * 采用外部传入当前播放物料状态
 *
 * @param movieState  可选前贴片的当前播放状态
 *
 */
- (void)playOptionalOadStateChanged:(STADMovieState)movieState;

/*! @brief 贴片点击WebView展示页设置方法
 *
 * 传入点击View，广告点击之后，跳转的WebView展示页面
 *
 * @param contentView 落地页的webView
 *
 */
- (void)setWebContentView:(UIView *)contentView;

/*! @brief 贴片点击WebView展示页关闭方法
 *
 * WebView展示页面可用户手动关闭或调用此接口关闭
 *
 * @param contentView 落地页的webView
 */
- (void)closeWebContentView:(UIView *)contentView;

/*! @brief 单击贴片方法
 *
 * 单击播放中的贴片，由STADManager返回当前贴片单击信息
 *
 * @return 贴片单击URI
 *
 */
- (NSString *)getOadClickThroughWithPoint:(CGPoint)point;

/*! @brief 单击贴片方法
 *
 * 单击播放中的贴片，由STADManager返回当前贴片单击信息
 * 注：该方法不会进行点击上报
 *
 * @return 贴片单击URI
 *
 */
- (NSString *)getOadClickThroughWithoutTracking;

/*! @brief 播放贴片广告物料播放超时
 *
 * 采用外部传入超时事件
 * 当物料因为超时而无法播放时，请调用该方法
 */
- (void)playOadTimeout;

/*! @brief 打开广告SDK内部浏览器
 *
 * 通过STAD来打开广告内部浏览器
 *
 * @param urlString     跳转地址
 */
- (void)stadOpenUrlWithURLString:(NSString *)urlString;

/*! @brief 设置语音广告控件位置
 *
 * 用于语音广告控件View的位置，通过STADManager来控制控件位置
 * 注：需要传入右上角的坐标
 *
 * @param point 语音广告控件的右上角坐标
 *
 */
- (void)stadSetVoiceADViewRightOriginPoint:(CGPoint)point;

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
                                   andBandHost:(NSString *)bandHost
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
 * 多贴中插最后一贴播放完成状态后由app通知sdk，记录系统时间，
 *
 */
- (void)stadMadPlayFinishRecordSysTime;

#pragma mark - 可选广告API
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
- (NSString *)getOptionalAdClickThroughWithPoint:(CGPoint)point;

/**
 *  可选广告提示语播放一次
 */
- (void)stadOptionalAdSoundPlay;

/**
 *  可选广告提示语停止播放
 */
- (void)stadOptionalAdSoundStop;

#pragma mark - 可跳过广告API
/**
 *  当前贴片广告跳过时，告知sdk已播放时长
 *
 *  @param playedsec 广告跳过时已播放时长
 */
- (void)stadSkipAdPlayedSec:(NSInteger)playedsec;

#pragma mark - 暂停广告 API
/*! @brief 暂停广告初始化方法
 *
 * 暂停广告初始化方法，每次初始化由STADManager返回UIView控件，之后由控件持有者控制广告生命周期
 * 默认广告可点击，展示内容不可交互
 *
 * @param param         暂停广告的ADParam, STADManager会使用ADParam来制作物料URL
 * @param host          暂停广告的Host, STADManager会使用host来制作物料URL
 * @param superviewFrame 暂停广告的Superview大小, 用来调整暂停广告展示大小
 *
 * @return  初始化成功返回UIView控件，失败返回nil
 *
 */
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

#pragma mark - 开机广告 API
/**
 *  开机广告初始化方法
 *
 *  @param param 开机广告的ADParam
 *  @param host  开机广告的Host
 */
- (void)getOpenAdWithADParam:(NSMutableDictionary *)param andServerHost:(NSString *)host;

/**
 *  开机广告展示成功或超时不展示时通知sdk
 *
 *  @param isShow 是否展示成功
 */
- (void)openAd:(BOOL)isShow;

/*! @brief 开机广告上报方法
 *
 * 开机广告参数上报方法，根据类型参数向广告服务器和第三方上报
 *
 * @param url    上报URL地址
 * @param trackType  上报类型 （目前第三方包括Admaster，miaozhen）
 */
- (void)stadOpenTrackWithURL:(NSString *)url andTrackType:(kSTADAdTrackType)trackType;

#pragma mark - 贴片广告缓存 API
/*! @brief 缓存贴片广告请求
 *
 * 用于缓存当天预定量Top10的前贴片的广告物料
 *
 */
- (void)stadStartPerdonwload;

#pragma mark - 在线广告资源管理 API
/*! @brief 在线缓存资源删除
 *
 * 删除本地缓存的在线前贴片和角标资源
 *
 */
- (void)removeOnlineADCache;

#pragma mark - 离线广告资源管理 API
/*! @brief 离线资源下载
 *
 * 通过离线下载视频的ID信息，来获取对应离线贴片下载资源，交由STADManager管理下载
 *
 * @param param       离线下载视频的ADParam信息
 * @param host        广告的Host, STADManager会使用host来制作物料URL
 */
- (void)downloadOfflineADWithSTADADParam:(STADADParam *)param
                           andServerHost:(NSString *)host;

/*! @brief 离线资源删除
 *
 * 通过离线下载视频的ID信息，来删除本地对应离线贴片下载资源
 *
 * @param param       离线下载视频的ADParam信息
 * @param host        广告的Host, STADManager会使用host来制作物料URL
 */
- (void)removeOfflineADWithSTADADParam:(STADADParam *)param
                         andServerHost:(NSString *)host;

#pragma mark - 第三方曝光接口 API
/*! @brief 第三方曝光接口
 *
 * 通过STAD来进行普通曝光和调用第三方SDK曝光
 *
 * @param track_url     曝光地址
 * @param trackType     曝光类型 （目前第三方包括Admaster，miaozhen）
 */
- (void)stadAdTrack:(NSString *)track_url andTrackType:(kSTADAdTrackType)trackType;

#pragma mark - 统计上报 API
/*! @brief passport id上报接口
 *
 * 用户在客户端登陆成功后(包括前后台登陆)，客户端将passport id信息回传给广告sdk，供做精准投放决策优化
 *
 * @param passportId 登录密码
 *
 */
- (void)stadLoginTrackWithPassport:(NSString *)passportId;

/**
 *  用于区别视频广告SDK使用场景，请在sdk初始化时传入
 *  （1）嵌入到新闻app视频TAB是，请传入kStadUseInSoHuNews
 *  （2）嵌入到搜狐视频app主线版本，请传入kStadUseInSohuTv
 *
 *  @param type 使用场景类型
 */
- (void)setAppId:(kStadUseInAppType)type;

#pragma mark - 落地页新接口 API
/**
 *  生成STAD的webview
 */
- (UIViewController *)stadSafariControllerWithURL:(NSURL *)URL supportDeeplink:(BOOL)supportDeeplink;

/**
 *  落地页展示接口，样式及功能与SFSafariViewController一致，支持iOS6+
 *
 *  @param url                   url地址
 *  @param currentViewController 展示落地页viewcontroller
 */
- (void)stadOpenLoadingPageWithUrl:(NSURL *)url andCurrentViewController:(UIViewController *)currentViewController supportDeeplink:(BOOL)supportDeeplink;

/**
 *  检查当前是否有落地页打开，如果有则关闭
 */
- (void)stadCloseLoadingPage;

/**
 *  落地页首次打开时强制指定展示方向，只需在横屏展示时调用
 *  指定拉起方向是UIDeviceOrientationLandscapeRight或UIInterfaceOrientationLandscapeRight
 *  注意：需要在stadOpenLoadingPageWithUrl:andCurrentViewController:使用前调用
 */
- (void)setLoadingPageInitOrientation:(UIDeviceOrientation) deviceOrientation;

#pragma mark - Banner广告 API

/*! @brief Banner广告初始化方法
 *
 * Banner初始化方法，SDK返回UIView控件，之后由控件持有者控制广告生命周期
 * 默认广告可点击，展示内容不可交互
 *
 * @param param          Banner广告的ADParam,三个参数必传；vid详情页必须传，首页置空;poscode广告位ID；pagecode页面id
 * @param host           Banner广告的Host, STADManager会使用host来制作物料URL
 * @param superviewFrame Banner广告的Superview大小, 用来调整广告展示大小
 * @param pageId         Banner广告所在页面ID,由app生成唯一参数，sdk回调时回传，用于区别广告属于不同页面
 *
 */
- (void)getBADViewWithSTADADParam:(STADADParam *)param
                    andServerHost:(NSString *)host
                andSuperviewFrame:(CGRect)superviewFrame
                        andPageId:(NSString *)pageId
                       andTimeout:(CGFloat)timeoutInterval;

#pragma mark - 非播放页Banner广告 API
/**
 *  通用图片Banner广告位初始化方法
 *
 *  @param param    Banner广告的ADParam
 *  @param host     Banner广告的Host
 *  @param bannerId Banner广告位置ID
 */
- (void)getImageBannerViewWithSTADADParam:(STADADParam *)param
                            andServerHost:(NSString *)host
                                 bannerId:(kStadBannerId)bannerId;

#pragma mark - 弹幕广告 API

/**
 *  正片开始播放时，调用SDK开始弹幕广告请求，此函数必需调用与是否用户开启弹幕无关
 *
 *  @param param           参数
 *  @param host            Host
 *  @param parentView      弹幕广告展示的父窗口，全屏大小
 *  @param timeoutInterval 超时时间
 *  @param isFullScreen    是否全屏模式
 */
- (void)getBarrageViewWithSTADADParam:(STADADParam *)param
                           serverHost:(NSString *)host
                            superView:(UIView *)parentView
                              timeout:(CGFloat)timeoutInterval
                         isFullScreen:(BOOL)isFullScreen;

/**
 *
 *  由app实时通知SDK弹幕superView的变化
 *
 *
 *  @param frame 弹幕superView改变后的frame
 */
- (void)barrageAdSuperViewFrameChanged:(CGRect)frame;

/**
 *  由app实时通知SDK，视频弹幕开关是否开启
 *
 *  @param isOn 弹幕开关是否开启
 */
- (void)stadBarrageSwitch:(BOOL)isOn;

/**
 *
 *  由app实时通知SDK弹幕是否需要暂停
 *
 *
 *  @param isPause 是否暂停弹幕
 */
- (void)stadBarrageStatus:(BOOL)isPause;

#pragma mark - 包框广告 API

/**
 *  全屏模式时，由app在跳过片尾前倒计时2分钟时，调用SDK请求包框广告
 *
 *  @param param           广告参数
 *  @param host            host地址
 *  @param superView       父窗口对象，用于展示包框广告，全屏大小
 *  @param timeoutInterval 请求超时时间
 */
- (void)playWrapFrameAdViewWithSTADADParam:(STADADParam *)param
                             serverHost:(NSString *)host
                                  superView:(UIView *)superView
                                andTimeout:(CGFloat)timeoutInterval;

/**
 *  包框广告开始展示，即播放器缩小至60%时，通知SDK，由SDK在包框展示期间不请求广告
 */
- (void)stadWrapFrameAdDidShow;

/**
 *  退出包框状态，但是不销毁包框广告，避免反复拖拽进入包框时间区域
 */
- (void)exitWrapFrameAdView;

/**
 *  播放器横屏切换到竖屏，或切集播放时，告知SDK关闭包框广告对象，app负责移除展示包框广告父窗口
 */
- (void)closeWrapFrameAdView;

/**
 *   获取包框广告落地页页面
 *
 *  @return 广告落地页页面UIView
 */
- (UIView *)getWrapFrameAdClickThrough;

# pragma mark - 视频app旋转屏，为了解决全屏且剧集导致的av上报

- (void)videoPlayerIsFullScreen:(BOOL)isFullScreen;

# pragma mark - 流量统计接口，返回30天的数据记录
- (NSArray *)flowRecords;

#pragma mark - 公共配置
#pragma mark -


/**
 sdk release环境是否开启调试模式，默认NO

 @param enable 是否开启调试模式
 */
- (void)enableDebugModel:(BOOL)enable;

@end
