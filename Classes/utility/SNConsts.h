/*
 *  SNConsts.h
 *  sohunews
 *
 *  Created by zhu kuanxi on 5/16/11.
 *  Copyright 2011 sohu. All rights reserved.
 *
 */

#import "SNAPI.h"
#import "SNPublicLinks.h"
#import "SNNotificationKeys.h"
#import "SNNotificationManager.h"
#import "SNStandardProtocol.h"
#import "SNUserDefaultsConst.h"

// for analytics
#define RECORD_USER_ACTION_ENABLE           (0)
#define UPLOAD_USER_ACTION_ENABLE           (0)
//clear cahce
#define AUTO_CLEAR_CACHE_ENABLE             (1)

#define kNeedDownloadRollingNews            (1)

#define USE_NEW_SUBCENTER                   (1)

#define kLiveIdKey                          (@"liveId")
#define kLiveTypeKey                        (@"liveType")
#define kLiveMediaTypeKey                   (@"mediaType")

//system configuration
#define kChanPinID							(1)
#define kBundleNameKey						(@"搜狐新闻")
#define kUIWebViewUserAgent                 (@"SohuNews")

// app url schema
#define kSohuNewsUrlSchema                  (@"sohunews://")

#define kNeedApplicationRecommend           (0)
#define kDebugSubBrowser                    (0)

//#define H5Switch                            (1)    //正文H5化开关

#define PushSettingSwith                    0

#define APIVersion                          (38)

#define KEY_UID                             (@"uid")
#define KEY_SID                             (@"adaptId")
#define kTermGotMark						(@"term.go")
#define kSqliteName                         (@"sohunews.sqlite")
#define kRegistedNewUserKey                 (@"registed new user")
#define kDeviceAdaptIDKey					(@"device adapt id")//即sid, 服务器用来适配图片 9:iphone3 10:iphone4及以上(retina) 21:ipad
#define kDefaultDeviceAdaptID               (@"0")
#define kDefaultProfileClientID             (@"0")
#define kProfileDevicetokenKey				(@"device token")
#define kHeaderFormatString					(@"a=%d&b=%@&c=%@&idfa=%@&e=%@&f=%@&g=%@&h=%@&i=%@&j=%d&u=%d&machineId=%@")
#define kDeviceModel						(@"iPhone")
#define kBundleVersionKey					(@"CFBundleShortVersionString")
#define kBundleIdentifier                   (@"CFBundleIdentifier")
#define kBundleBuild                        (@"CFBundleVersion")
#define kUpgradeOffOn                       (@"kUpgradeOffOn")
#define kADToMeCommentId                    (@"kADToMeCommentId")
#define kADToMeCommentNumZero               (@"0")
#define kAESEncryptKey						(@"2D2AE7C87C712EB5")
#define kNewsFontClass						(@"SN_NewsContentFontClass")
#define kRequestTimeOut						(10.0)
#define KPaginationNum						(20)
#define KPhotoPaginationNum					(10)
#define kShowPhotoInfoUserDefaultKey		(@"ShowPhotoInfoUserDefaultKey")
#define kNewsAlreadyReadFlag				(@"1")
#define kNewsReadFlagKey					(@"readFlag")
#define KAlertAutoCloseTime					(3)
#define kChannelNewsRefreshInterval         (60)
#define kChannelVideoRefreshInterval        (60*30)
#define kChannelWeiboRefreshInterval        (60*30)
#define kChannelLiveRefreshInterval         (60*30)
#define kChannelNeedsRefresh				(@"channelNeedsRefresh")
#define kChannelModelRefreshTime            (@"channel_model_refresh_time")
#define kChannelManagerSwitchType           (@"kChannelManagerSwitchType")  //记录选择更多频道、本地频道
#define kCommontLoginTipInterval            (60*60*24*7*1)
#define kCommentRemarkTip                   (@"commentRemarkTips")

#define kUpdateCacheSizeInterval            (60 * 5)//5min
#define kCacheSize                          (@"cacheSize")

#define kIconsCacheFolderName               (@"iconsCache")
#define kCommentImageFolderName             (@"commentImage")
#define kCommentImageFolderId               (@"/Library/Caches/commentImage")

#define kNotificationAlertAppearTimeDiff    (2)
#define kRequestRollingChannelsWithP1       (@"kRequestRollingChannelsWithP1")
#define kGuideViewDidDismiss                (@"kGuideViewDidDismiss")

//guide
#define kProfileGuideOnFirstRun                   (@"guideOnFirstRun3_2_0")
#define kGuideMaskSetNickNameOnFirstRun_1         (@"maskGuideOnFirstRun_1")
#define kGuideMaskReplyCommentOnFirstRun_2        (@"maskGuideOnFirstRun_2")
#define kGuideMaskOfflineManageAOnFirstRun_3      (@"maskGuideOnFirstRun_3")
#define kGuideMaskOfflineManageBOnFirstRun_4      (@"maskGuideOnFirstRun_4")
//3.2.0
#define kGuideMaskSubCenterMyList                 (@"maskGuideSubCenterMyList")

#define KSCORES_TIMES                             @"scoresTimes"
#define kRateRemindTimes                          3
#define kRateRemindInterval                       3600
#define kLoadingBlockMaskViewTag                  (3248)

//UI common
#define kToolbarButtonSize					(44)
#define kBrownTextColor						RGBCOLOR(131, 48, 23)
#define kGrayTextColor						RGBCOLOR(76, 74, 70)
#define kGrayCellTextColor					RGBCOLOR(100, 100, 100)
#define kAppLogoWidth                       (205)
#define kAppLogoHeight                      (112)
#define kMessageLiveTime                    (1)
#define kErrorMessageLiveTime               (1)
#define kTransparentBGAlpha                 (0.7)

//front page
#define kCoverViewType						(@"coverView type")
#define kIsSubscribe						(@"isSubscribe")
#define kRestAllSubScribe					(@"RestAllSubScribe")
#define kNumberPerPage						(12)
#define kNumberPerRow						(3)
#define kCustomManageSub					(@"customManage")

#define kJoinRedPacketsValue      @"joinRedPacketsValue"

#define kRedPacketTips                      @"kRedPacketTips"

#define kSNLiveRoomCellPlayingVideoKeyPattern   (@"%@___%@")

// plugins
#define kPluginShake                        (@"yiy")
#define kPluginReadingCircle                (@"ydq")

#define kOpenProtocolOriginalLink2          (@"kOpenProtocolOriginalLink2")
#define kISOffReadingPublication            (@"kISOffReadingPublication")

#define kDefaultTimeText                    (@"00:00")

//记录推荐提示日期
#define kNewsRefreshTipsDate                (@"tipsDate")
//记录登录tips弹出日期
#define kLoginTipsShowDate                  (@"loginTipsDate")

//记录location.go请求时间
#define kLocationRequestDate                (@"kLocationRequestDate")
//记录上次定位时间
#define kLocationDate                       (@"kLocationDate")

//记录tab点击刷新提示语
#define kShowTabClickTips                   (@"kShowTabClickTips")

// subShowType
#define kSubShowTypePaper                   (@"31")
#define kSubShowTypeFlv                     (@"32")
#define kSubShowTypeNews                    (@"33")
#define kSubShowTypeWeibo                   (@"34")
#define kSubShowTypePhoto                   (@"35")

// 协议参数回传
#define kProtocolParamsFeedback             (@"protoParaFB")

#define kNewsPaperDir                       (@"kNewsPaperDir")

#define kMarkPublish						(@"publish://")
#define kNotifyKey							(@"pushurl")
#define kNotifyUrlKey						(@"url")
#define kNotifyKeyTitle						(@"txt")

#define kFadeOutAnimation                   (@"FadeOut")
#define kFadeInAnimation                    (@"FadeIn")

#define kRollingNewsFormCommon              (@"1")
#define kRollingNewsFormHeadline            (@"2")
#define kRollingNewsFormExpress             (@"3")
#define kRollingNewsFormRecommend           (@"4")
#define kRollingNewsFormFocus               (@"5") //焦点图数组
#define kRollingNewsFormTop                 (@"6") //置顶新闻
#define kRollingNewsFormTowTop              (@"7") //焦点图下两条
#define kRollingNewsFormTrainCard           (@"8") //火车卡片

#define kH5NoTriggerIOSClick @"noTriggerIOSClick=1"
#define kH5LinkTopDistance @"linkTop"
#define kH5LinkBottomTopDistance @"linkBottomTop"
#define kFromRollingChannelWebKey @"kFromRollingChannelWebKey"

//2016 jing dong
#define kJingDongActUrl @"actUrl"
#define kJingDongBackUrl @"backUrl"
#define kJingDongActivityID @"activityID"
#define kJingDongContentType @"contentType"
#define kJudgeOpenThirdApp @"是否前往"
#define kOpenThirdAppCancel @"取消"
#define kOpenThirdAppConfirm @"前往"

//定制化活动
#define kSpecialActivityCountKey            @"kSpecialActivityCountKey"
#define kSpecialActivityShowTimeKey         @"kSpecialActivityShowTimeKey"
#define kSpecialActivityShowNotification    @"kSpecialActivityShowNotification"
#define kSpecialActivityShouldShowKey       @"kSpecialActivityShouldShowKey"
#define kSpecialActivityDocumentName        @"specialActivity"
#define kSpecialActivityName                @"activity"
#define kSpecialActivityDocumentZipName     @"specialActivity.zip"
#define kSpecialActivityData                @"data"//动画相关数据
#define kSpecialActivityXAxisPercent        @"xAxisPercent"//素材在屏幕上的x，y 以百分比形式，float格式，比如0.65
#define kSpecialActivityYAxisPercent        @"yAxisPercent"//素材在屏幕上的x，y 以百分比形式，float格式，比如0.65
#define kSpecialActivityAlignCenter         @"alignCenter"//水平居中，垂直居中，int值， 0无效，1水平，2垂直，3屏幕居中
#define kSpecialActivityAlignSide           @"alignSide"//右对齐和下对齐， int型，0无效，1右对齐，2下对齐，3屏幕右下角
#define kSpecialActivityMaterialRatio       @"materialRatio"//素材宽度，百分比，float型，比如0.35，根据屏幕宽度计算;素材高度，素材宽度*图片的比例
#define kSpecialActivityActUrl              @"actUrl"//广告落地页URL
#define kSpecialActivityExpsMonitorUrl      @"expsMonitorUrl"//曝光URL，大数据使用
#define kSpecialActivityExpsAdverUrl        @"expsAdverUrl"//曝光URL，广告商使用
#define kSpecialActivityClickMonitorUrl     @"clickMonitorUrl"//点击URL，大数据使用
#define kSpecialActivityClickAdverUrl       @"clickAdverUrl"//点击URL，广告商使用
#define kSpecialActivityMaterial            @"material"//素材zip链接，ios和android都会根据上传的屏幕宽高，下发不同的素材，投放提供ios2套
#define kSpecialActivityAdSwitch            @"adSwitch"//活动显示开关
#define kSpecialActivityMD5Key              @"md5Key"//MD5加密，用于校验
#define kSpecialActivityDisplayTimeLength   @"displayTimeLength"//每帧动画播放时长，单位毫秒
#define kSpecialActivityPeroid              @"peroid"//每帧动画播放时长，单位毫秒
#define kSpecialActivityPlayTimes           @"playTimes"//帧动画播放次数
#define kSpecialActivityAdSwitch            @"adSwitch"//广告开关
#define kSpecialActivityStatConfig          @"statConfig"//正文页打开次数
#define kSpecialActivityChannelId           @"channelId"//频道id
#define kSpecialActivityEndTime             @"endTime"//广告过期时间
#define kSpecialActivityStartTime             @"startTime"//广告开始时间
#define kSpecialActivitystatPoint             @"statPoint"//广告自然日分割点 0830

#define kSpecialAdResourceDocumentName      @"SpecialAdResource"

#define kCompassSDKSwitchKey @"kCompassSDKSwitchKey"

#define kSohuNewsSubId                      (@"107")
#define kSohuNewsSubName                    (@"搜狐早晚报")
#define kYouMayLikeId                       (@"-99")
#define kYouMayLikeName                     (@"猜你喜欢")
#define kExpressPushId                      (@"89")
#define kExpressName                        (@"快讯")
#define kWeiboMarked                        (@"微博")
#define kPluginSubShowType                  (@"38")
#define kMediaPushID                        (@"90")
#define kMediaPushName                      (@"媒体推送")

//#define kHadShowUpdate                      (@"kHadShowUpdate")
#define kCheckDoResponse                    (@"kCheckDoResponse")
#define kClientInfoSynchronized             (@"kClientInfoSynchronized")
#define kCheckDoType                        (@"paper,up,ad,fb,loading,nf,reply,sub,subTab,notifys,vbub,slient")

#define kSNMessgeNum                        (@"msgNum")

//---------------------------------------------------------------------------------------------------------------
#define kCorpusNewsGidExist @"CorpusNewsGidExist"
#define kCorpusListCount 20
#define kCorpusCount 6
#define kCorpusNewFavourite @"新建收藏夹"
#define kCorpusFavouriteTitle @"请输入收藏夹名称"
#define kCorpusNameEmpty @"请输入收藏夹名称"
#define kInpututRightCorpusName @"请输入正确的收藏夹名称"
#define kCorpusNewCreat @"新建"
#define kCorpusProtect @"保存"
#define kCorpusMyFavourite @"我的收藏"
#define kCorpusMyShare @"我的分享"
#define kCorpusMyInclude @"我的保存"
#define kCorpusFavourite @"收藏"
#define kCorpusFavoritesManage @"收藏夹管理"
#define kCorpusManage @"管理"
#define kCorpusDown @"完成"
#define kCorpusCancel @"取消"
#define kCorpusLogin @"登录"
#define kCorpusSynchronous @"后收藏夹中的内容可同步到多个设备"
#define kCorpusDelete @"您确定删除收藏夹"
#define kCorpusDeleteTail @"吗？"
#define kCorpusShareEmpty @"您还没有分享过内容哦"
#define kCorpusGrabEmpty @"您还没有保存过内容哦"
#define kCorpusFavouriteEmpty @"咦？空的？"
#define kMyCorpusEmpty @"收藏夹空空如也"
#define kCorpusFavouriteAddEmpty @"赶快点击\"+\"让已收藏的内容把它塞满"
#define kCorpusIKnow @"我知道了"
#define kChooseListAll @"全选"
#define kCancelListAll @"取消全选"
#define kAddToCorpus @"添加到"
#define kAddedToCorpus @"已添加到"
#define kDeleteCorpus @"删除"
#define kConfirmDeleteNews @"您确定删除已选内容吗？"
#define kLoadFinished @"已全部加载"
#define kPullLoadMore @"上拉加载更多"
#define kCorpusContentShow @"查看"
#define kCorpusContentCancel @"取消"
#define kDeleteSucceed @"已删除"
#define kCorpusGuideInChannelList @"快来把收藏的内容分类吧！"
#define kCorpusGuideInArticle @"看这里，一键收藏更便捷"
#define kCorpusUpdateSucceed @"修改成功"
#define kNoCorpusCreat @"没有新建收藏夹"
#define kAlreadyCollect @"已收藏"
#define kAlreadyMoveFinished @"已移动完成"

#define kInsertToastTag 100000000
#define kRollingNewsPullStatus @"kRollingNewsPullStatus"

#define kPullGuideTag   200000000
#define kRecommendGuidShow       @"kRecommendGuidShow"

#define kFontGuideTag 100000001

#define kCellAnimationDuration 0.2
#define kCorpusGuideLeftDistance ((kAppScreenWidth > 375.0) ? 45.0/3 : ((kAppScreenWidth == 320.0) ? 12/2.0 : 30.0/2))
#define kCorpusGuideRightDistance ((kAppScreenWidth > 375.0) ? 24.0/3 : ((kAppScreenWidth == 320.0) ? 10/2.0 : 14.0/2))

#define kCorpusFolderName @"folderName"
#define kCorpusID @"corpusId"
#define kNoCorpusFolderName @"nofolderName"
#define kFromFavoriteManager @"kFromFavoriteManager"
#define kNotAutoPlay      @"kNotAutoPlay"

#define kSelectButtonMode @"kSelectButtonMode"
#define kIsMoveCorpusList @"kIsMoveCorpusList"
#define kIsFromCorpusListCreat @"kIsFromCorpusListCreat"

#define kIsSelectedItem @"kIsSelectedItem"
#define kOpenCorpusFromEmpty @"kOpenCorpusFromEmpty"
#define kAddNewsToEmptyCorpusKey @"kAddNewsToEmptyCorpusKey"
#define kEmptyCorpusName @"kEmptyCorpusName"
#define kEmptyCorpusID @"kEmptyCorpusID"
#define kEditeFavorite @"kEditeFavorite"
#define kNeedReloadCorpus @"kNeedReloadCorpus"
#define kMoveToNewCorpus @"kMoveToNewCorpus"
#define kMoveCorpusToTwo @"kMoveCorpusToTwo"

//登录相关统计参数
#define kLoginFromKey @"kLoginFromKey"
#define kLoginFromEmpty @"0" //非邮箱登录，调用userinfo接口，传0
#define kLoginFromComment @"1" //评论
#define kLoginFromMyTab @"2" //我的Tab
#define kLoginFromLive @"3" //直播
#define kLoginFromMyCorpus @"4" //收藏主动登录
#define kLoginFromMyCorpusManage @"5" //收藏管理拦截
#define kLoginFromMyExperience @"6" //我的阅历
#define kLoginFromReport @"7" //举报
#define kLoginFromShareMySohu @"8" //分享搜狐我的

#define kLoginTypeKey @"kLoginTypeKey"
#define kLoginTypeMobileNum @"21" //手机登录
#define kLoginTypeWeChat @"22" //微信登录
#define kLoginTypeQQ @"23" //QQ登录
#define kLoginTypeSina @"24" //微博登录
#define kLoginTypeSohu @"25" //邮箱登录
//
//push setting
#define kPushSettingContent @"第一时间获取重大新闻快讯，快去开启推送设置吧"
#define kPushOpenImmediate @"立即开启"
#define kPushTemporarily @"以后再说"
#define kLowVersionRemindContent @"请前往设置页面，在通知中心选择搜狐新闻应用，点击允许通知"
#define kLowVersionIKnow @"我知道啦"
#define kPushSettingOpened @"已成功开启推送通知"

//记录是初次安装或者升级App
#define kFirstInstallOrUpdateApp @"kFirstInstallOrUpdateApp"
#define kListGOSync @"kListGOSync"

#define kRecordFirstOpenNewsKey @"kRecordFirstOpenNewsKey"
#define kChannelVideoSwitchKey @"kChannelVideoSwitchKey"
#define kLoadingTimeOut @"kLoadingTimeOut"
#define kLoadingSCSDKSwitch @"kLoadingSCSDKSwitch"

#define kCustomPushShareIdentifier @"kCustomPushShareIdentifier"
#define kCustomPushShareTitle @"分享"
#define kCustomPushNoInterestIdentifier @"kCustomPushNoInterestIdentifier"
#define kCustomPushNoInterestTitle @"不感兴趣"
#define kCustomPushCategoryIdentifier @"kCustomPushCategoryIdentifier"

#define kAddedToText @"已添加"
#define kAddToOptionalStock @"添加到自选股"
#define kAddToChannel @"添加频道"
#define kStockCodeKey @"subscribeCode"
#define kStockFromKey @"stockfrom"
#define kFromSohuNewsClient @"来自搜狐新闻客户端"
#define kAddChannelSucceed @"添加成功"
#define kCopyLinkSucceed @"复制成功"
#define kBindSinaFirst @"请先绑定微博"
#define kRelieveSinaSucceed @"解除绑定成功"
#define kHaveAlreadyDing @"已赞过"
#define kArticleUnPublicNotShare @"文章未发布，暂无法分享"
#define kArticleUnPublicNotComment @"文章未发布，暂无法评论"

//search city
#define kCurrentLocating @"正在定位"
#define kCurrentLocationCity @"当前定位："
#define kCurrentLocationFail @"暂无城市定位"
#define kIntelligentSwitchClose @"开启后可以智能定位到所在城市"
#define kLightIntelligentSwitchClose @"智能定位到所在城市"
#define kIntelligentSwitchOpen @"每次进入客户端后智能定位到所在城市"
#define kLightIntelligentSwitchOpen @"智能定位到所在城市"
#define kHistorySearchCity @"历史访问城市"
#define kSaveSearchCityArrayKey @"kSaveSearchCityArrayKey"
#define kSaveSearchHouseArrayKey @"kSaveSearchHouseArrayKey"
#define kSaveLocalCityKey @"kSaveLocalCityKey"
#define kSaveLocalHouseKey @"kSaveLocalHouseKey"
#define kSaveSearchCityArrayCount 3
#define kPleaseInputSearchCity @"请输入城市名称"
#define kLocationText @"定位"
#define kHistoryText @"历史"
#define kRequestLocalChannelTimeKey @"kRequestLocalChannelTimeKey"
#define kRequestHomePageTimeKey @"kRequestHomePageTimeKey"
#define kRequestChannelExpireTime 30
#define kTemporaryCityNone @"无相关城市"
#define kSettingSysytemLocation @"请在系统中允许获取定位"
#define kGoSettingLocatin @"去设置"
#define kGoSettingLocatinKey @"kGoSettingLocatinKey"
#define kLocationCityKey @"kLocationCityKey"
#define kLocalChannelUnifyID @"283"//本地频道统一标识
//
#define kOptimizeReadRemind @"全新阅读模式，体验更佳"
#define kUniversalWebRefresh @"刷新"
#define kUniversalWebReport @"举报"

#define kScanMenuQrCode     @"二维码"
#define kScanMenuPoster     @"扫海报"

#define kUniversalTitle @"搜狐新闻"
#define kFirstOpenUniversalWebView @"kFirstOpenUniversalWebView"
#define kUniversalWebViewType @"kUniversalWebViewType"
#define kBrowserShareContent @"browser://action=share"
#define kWebViewForceBackKey @"kWebViewForceBackKey"
#define kNormalWebviewHideShareButton @"kNormalWebviewHideShareButton"

#define kChannelDeleteFromChannelPreview @"kChannelDeleteFromChannelPreview"

#define kImmediatelyLogin @"立即登录"
#define kMobileBindCopy @"为了保证帐号安全，需绑定手机号"
#define kMobileTip @"未注册用户，手机验证后自动登录"
#define kLoginBackUrl @"login://backUrl="
#define kShareTitleWechat @"微信朋友圈"
#define kShareTitleWechatSession @"微信好友"
#define kShareTitleSina @"新浪微博"
#define kShareTitleQQ @"QQ"
#define kShareTitleQQZone @"QQ空间"
#define kShareTitleMySohu @"狐友"
#define kShareTitleWebLink @"复制链接"
#define kShareTitleAliPaySession @"支付宝"
#define kShareTitleAliPayLifeCircle @"生活圈"
#define kShareTitleScreenshot @"划重点"
#define kShareTargetNameKey @"kShareTargetNameKey"
#define kShareTargetKey @"kShareTargetKey"
#define kShareContentKey @"kShareContentKey"
#define kCanalsKey @"kCanalsKey"

#define kRefreshChannelWebViewNotification @"kRefreshChannelWebViewNotification"

#define kRedPacketFetchInActivityNotifiction @"kRedPacketFetchInActivityNotifiction"
#define kRedPacketDrawTimeKey @"kRedPacketDrawTimeKey"
#define kRedPacketIDKey @"kRedPacketIDKey"
#define kSNSShareonInfo @"shareonInfo"

#define kShareOnKey @"shareon"
#define kShareSubActivityPageKey @"origin"

#define kH5LinkTop @"linkTop"
#define kH5LinkBottom @"linkBottomTop"


#define kRedPacketStoreKey (@"RedPacketKey")
#define kIsRedPacketNewsKey (@"kIsRedPacketNewsKey")

#define kTohoNoNeed @"土豪！不需要～"
#define kImmediatelyPickUp @"立即领取"

#define kMyChannelSectionTitle @"我的频道"
#define kMoreChannelSectionTitle @"更多频道"
#define kMyChannelTitle @"我的频道"
#define kClickShowMoreChannelViewTitle @"点击查看频道内容"
#define kFirstShowScreenShareTitle @"点击下方按钮，可以截屏分享哦"
#define kFirstShowChannelGuideText @"新增频道分类，快来查看吧"
#define kPressChannelSortText @"拖动频道排序"
#define kClickAddChannelText @"点击添加频道"
#define kChannelBottomSearchText @"没找到喜欢的频道？搜一下"
#define kRollingNewsSearchText   @"搜索感兴趣的内容"
#define kFirstShowNews @"点击快速返回顶部"
#define kFirstSlideBackTips @"右滑快速返回"

#define kHomePageEditModeText @"点击去看"
#define kHomePageEditModeBlueText @"今日要闻"

#define kPullMyConcernContent @"松开，去看兴趣推荐"
//#define kRecordEveryDayEnterAppDateKey @"kRecordEveryDayEnterAppDateKey"
//#define kRecordEnterBackgroundAppDateKey @"kRecordEnterBackgroundAppDateKey"
#define kShouldShowEditModeNewsKey @"kShouldShowEditModeNewsKey"
#define kBackRootFromSohuIconKey @"kBackRootFromSohuIconKey"
#define kShowLoadingPageKey @"kShowLoadingPageKey"
#define kEnterToNewsTabKey @"kEnterToNewsTabKey"
#define kEnterForegroundTips @"有内容更新，请下拉查看"
#define kUnintrestedTips @"将减少更新类似的新内容"
#define kHaveLoadRollingNewsFinished @"kHaveLoadRollingNewsFinished"
#define kSpreadAnimationStartKey @"kSpreadAnimationStartKey"//YES代表动画执行开始，NO代表结束
#define kEditRollingNewsRefreshTime @"kEditRollingNewsRefreshTime"

#define kTabBarNameKey @"tabName"
#define kTabBarNewsTab @"newsTab"
#define kTabBarVideoTab @"videoTab"
#define kTabBarSNSTab @"snsTab"
#define kTabBarMyTab @"myTab"

#define kOpenPageInCurrentWebViewTag @"sohunewsclient_finance_opentarget=_blank"
#define kScrollsToTopStatusKey @"kScrollsToTopStatusKey"

#define kCloseChatFeedbackNotification @"kCloseChatFeedbackNotification"
#define kLoginBackUrlKey @"loginBackUrl"

#define kCameraDenyAlertText @"请在iPhone的“设置-隐私-相机”选项中，允许搜狐新闻访问你的相机。"
#define kCameraDenyAlertConfirm @"好"

#define kRegistErrorType @"ios_registError"//注册失败

#define kOpenAppOriginFromKey @"kOpenAppOriginFromKey"//标记调起app来源

//用于判断各种情况点击Tab回到要闻
#define kClickTabToRefreshHomeKey @"CLICKTAB_TOREFRESHHOME"

typedef enum {
    ClickTabToRefreshHome_Tab = 1 //当前在新闻Tab, 点击Tab需要刷新要闻
} ClickTabToRefreshHome;

//视频统计
typedef enum {
    VideoStatRefer_Pub = 21,
    VideoStatRefer_RollingNews = 3,
    VideoStatRefer_VideoTab = 40,
    VideoStatRefer_VideoTabTimeline = 44,
    VideoStatRefer_RecommVideoInRollingNews = 50,
    VideoStatRefer_LiveRoom = 24
} VideoStatRefer;


#define kIsRedDot  @"isRedDot"     //标记订阅频道是否有红点（/更新）

#define kFbHaveReply                                  @"fbHaveReply"          // 帮助与反馈有回复  5.7.4
#define kFbScreenShot                                 @"fbScreenShot"         // 是否可截屏 5.7.4
#define kFeedBackScreenshot                           @"feedBackScreenshot"   // 截屏反馈key
#define kFeedBackTypeID                               @"feedBackTypeID"       // 反馈问题类型
#define kScreenShotSwitch                             @"fbScreenShotSwitch"   // 设置页面截屏开关

#define kActionType                         @"kActionType"  //lijian 2014.12.17 活动页要特殊处理隐藏地址栏
#define kActionName_ActivePage              @"ActivePage"   //lijian 2014.12.17 活动页要特殊处理隐藏地址栏

// XML/JSON element
#define kNewsId								(@"newsId")
#define kTermId								(@"termId")
#define kPackId								(@"packId")
#define ktermid								(@"termid")
#define kWeiboId                            (@"weiboId")
#define kNextGid                            (@"nextGid")
#define kType								(@"type")
#define kTab								(@"tab")
#define kTypeId								(@"typeId")
#define kGallerySourceType					(@"kGallerySourceType")
#define kTitle								(@"title")
#define kBlueTitle                          (@"blueTitle")
#define kTime								(@"time")
#define kUpdateTime                         (@"updateTime")
#define kFrom								(@"from")
#define kOriginFrom                         (@"originFrom")
#define kNewsMark                           (@"newsMark")
#define kOriginTitle                        (@"originTitle")
#define kCommentNum							(@"commentNum")
#define kRecomReasons                       (@"recomReasons")
#define kRecomTime                          (@"recomTime")
#define kCountShowText                      (@"countShowText")//V5.1 add累计阅读
#define kLink								(@"link")
#define StoryProtocolLink                   (@"storyProtocolLink")// 2016-10-17 wangchuanwen 小说相关协议
#define StoryLink                           (@"storyLink")// 2016-10-17 wangchuanwen 小说相关Url
#define kDigNum								(@"digNum")
#define kContent							(@"content")
#define kNextName							(@"nextName")
#define kNextId								(@"nextId")
#define kPreName							(@"preName")
#define kPreId								(@"preId")
#define kGallery							(@"gallery")
#define kPhoto								(@"photo")
#define kPTitle								(@"ptitle")
#define kPic								(@"pic")
#define kAbstract							(@"abstract")
#define kShareLink							(@"shareLink")
#define kShareContent						(@"shareContent")
#define kShareImageUrls                     (@"images")
#define kImage                              (@"image")
#define kPhotos                             (@"photos")
#define kPhoto                              (@"photo")
#define kPic                                (@"pic")
#define kTagChannels                        (@"tagChannels")
#define kTagChannel                         (@"tagChannel")
#define kTagChannelName                     (@"name")
#define kTagChannelLink                     (@"link")
#define kStocks                             (@"stocks")
#define kStock                              (@"stock")
#define kStockName                          (@"name")
#define kStockLink                          (@"link")
#define kAbstract                           (@"abstract")
#define kWidth                              (@"width")
#define kHeight                             (@"height")
#define kIsLike                             (@"isLike")
#define kLikeCount                          (@"likeCount")
#define kGid                                (@"gid")
#define kOffset                             (@"offset")
#define kTvInfos                            (@"tvInfos")
#define kTvInfo                             (@"tvInfo")
#define kTvName                             (@"tvName")
#define kTvPic                              (@"tvPic")
#define kLayout                             (@"layout")
#define kTvPlayTime                         (@"tvPlayTime")
#define kTvUrl                              (@"tvUrl")
#define kTvUrlM3u8                          (@"tvUrlM3u8")
#define kTvUrlDivision                      (@"tvUrlDivision")
#define kTvVid                              (@"vid")
#define kExposureFrom                       (@"exposureFrom")
#define kH5link                             (@"h5link")
#define kFavIcon                            (@"favicon")
#define kMedia                              (@"media")
#define kMediaName                          (@"mediaName")
#define kMediaLink                          (@"mediaLink")
#define kOptimizeRead                       (@"optimizeRead")
#define kLandscape                          (@"landscape")
#define kRecomInfo                          (@"recominfo")

#define kHttpHeader                         (@"httpHeader")
#define kLogoUrl                            (@"httpHeader_logo")
#define kLinkUrl                            (@"httpHeader_url")
#define kCDNUrl                             (@"CDN_URL")

#define kAudioInfos                         (@"audios")
#define kAudioInfo                          (@"audio")
#define kPlayTime                           (@"playTime")
#define kSize                               (@"size")

#define kIsHasTV                            (@"isHasTv")
#define kIsHasAudio                         (@"isHasAudio")
#define kIsHasVote                          (@"isHasVote")
#define kRecomDay                           (@"recom_day")
#define kRecomNight                         (@"recom_night")
#define kNewsIconDay                        (@"iconDay")
#define kNewsIconNight                      (@"iconNight")
#define kNewsMedia                          (@"media")
#define kIsWeather                          (@"isWeather")
#define kWeatherVO                          (@"weatherVO")
#define kCity                               (@"city")
#define kTempHigh                           (@"tempHigh")
#define kTempLow                            (@"tempLow")
#define kWeather                            (@"weather")
#define kWeatherIoc                         (@"weatherIoc")
#define kWind                               (@"wind")
#define kGbcode                             (@"gbcode")
#define kDate                               (@"formatDate")
#define kLocalIoc                           (@"weatherLocalIoc")
#define kBackground                         (@"background")
#define kWeak                               (@"week")
#define kLiveTemperature                    (@"liveTemperature")

#define kIsRecom                            (@"isRecom")
#define kRecomType                          (@"recomType")
#define kLiveStatus                         (@"liveStatus")
#define kLocal                              (@"local")
#define kThirdPartUrl                       (@"thirdPartUrl")
#define kTemplateId                         (@"templateId")
#define kTemplateType                       (@"templateType")
#define kPlayTime                           (@"playTime")
#define kLiveType                           (@"liveType")
#define kIsFlash                            (@"isFlash")
#define kPos                                (@"pos")
#define kRollingNewsStatsType               (@"statsType")
#define kData                               (@"data")
#define kAdType                             (@"adType")
#define kAdAbPosition                       (@"abposition")
#define kAdPosition                         (@"position")
#define kAdRefreshCount                     (@"rc")
#define kAdLoadMoreCount                    (@"lc")
#define kAdScope                            (@"scope")
#define kAdAppChannel                       (@"appchn")
#define kAdNewsChannel                      (@"newschn")
#define kAdNewsAdpType                      (@"adp_type")
#define kAdItemSpaceId                      (@"itemspaceid")
#define kAdImpressionId                     (@"impressionid")
#define kAdMonitorKey                       (@"monitorkey")
#define kIsHasSponsorships                  (@"isHasSponsorships")
#define kIconText                           (@"iconText")
#define kNewsTypeText                       (@"newsTypeText")
#define kSponsorships                       (@"sponsorships")
#define kPublishTime                        (@"publishTime")
#define kCursor                             (@"cursor")
#define kCityVO                             (@"cityVO")
//红包
#define kBgPic                              (@"bgPic")
#define kSponsoredIcon                      (@"sponsoredIcon")
#define kDescription                        (@"description")
#define kRedPacketId                        (@"redPacketId")
#define kCouponId                           (@"couponId")
#define kRedPacketType                      (@"type")
#define kRedPacketMoney                     (@"money")
#define kSponsoredName                      (@"sponsoredName")
#define kDetailMsg                          (@"detail_msg")
#define kRedPacketMsg                       (@"msg")
#define kIsSupportPopWindow                 (@"isSupportPopWindow")
#define kPopTime                            (@"popTime")
#define kIsSlideUnlockRedpacket             (@"isSlideUnlockRedpacket")
#define kSlideUnlockRedPacketText           (@"slideUnlockRedPacketText")

#define kNewsItems                          (@"newsItems")

#define kNewsAdinfos                        (@"adInfos")
#define kNewsAdInfo                         (@"adInfo")

#define kTargetType                         (@"kTargetType")
#define kRecommendNewsXmlElemet             (@"recommendNews")
#define kNewsXmlElement                     (@"news")
#define kNewsLinkXmlElement                 (@"newsLink")
#define kNewsTitleXmlElement                (@"title")
#define kNewsTypeXmlElement                 (@"type")
#define kNewsIconXmlElement                 (@"icon")
#define kNewsIconNightXmlElement            (@"icon_night")
#define kVotes                              (@"votes")
#define kVoteTopicId                        (@"topicId")
#define kVoteStartTime                      (@"startTime")
#define kVoteEndTime                        (@"endTime")
#define kVoteViewResultCond                 (@"viewResultCond")
#define kVoteIsRandomOrdered                (@"isRandomOrdered")
#define kVoteIsOver                         (@"isOver")
#define kVoteIsShowDetail                   (@"isShowDetail")
#define kVoteVoteTotal                      (@"voteTotal")
#define kVoteItem                           (@"vote")
#define kVoteItemId                         (@"voteId")
#define kVoteItemContent                    (@"voteContent")
#define kVoteItemVoteType                   (@"voteType")
#define kVoteItemPosition                   (@"position")
#define kVoteItemMinVoteNum                 (@"minVoteNum")
#define kVoteItemMaxVoteNum                 (@"maxVoteNum")
#define kVoteItemOption                     (@"option")
#define kVoteItemOptionId                   (@"optionId")
#define kVoteItemOptionName                 (@"name")
#define kVoteItemOptionPos                  (@"position")
#define kVoteItemOptionPic                  (@"picPath")
#define kVoteItemOptionSmallPic             (@"smallPicPath")
#define kVoteItemOptionDesc                 (@"optionDesc")
#define kVoteItemOptionType                 (@"type")
#define kVoteItemOptionIsMyVote             (@"isMyVote")
#define kVoteItemOptionVoteTotal            (@"optionVoteTotal")
#define kVoteItemOptionPersent              (@"optionPersent")
#define kVoteItemOptionMsg                  (@"myMsg")
#define kRefer                              (@"refer")
#define kReferType                          (@"Refertype")
#define kReferValue                         (@"Refervalue")
#define kSearchReferType                    (@"refertype")

#define kNextId                             (@"nextId")
#define kNextNewsLink                       (@"nextNewsLink")
#define kNextNewsLink2                      (@"nextNewsLink2")
#define kNextName                           (@"nextName")
#define kPreId                              (@"preId")
#define kPreName                            (@"preName")
#define kMore                               (@"more")
#define kGroupPic                           (@"grouppic")
#define kGroupPicId                         (@"id")
#define kGroupPicTitle                      (@"title")
#define kGroupPicIconUrl                    (@"pic")
#define kTopicId                            (@"topicId")

#define kReturnMsg                          (@"returnMsg")
#define kReturnStatus                       (@"returnStatus")
#define kStatus                             (@"status")
#define kRole                               (@"role")
#define kMsg                                (@"msg")

//rolling news
#define kFlashes                            (@"flashes")
#define kRecoms                             (@"recoms")
#define kArticles                           (@"articles")
#define kListPic                            (@"listPic")
#define kListPics                           (@"pics")
#define kNewsType                           (@"newsType")
#define kTemplateType                       (@"templateType")
#define kNewsLink                           (@"newsLink")
#define kSubLink                            (@"subLink")
#define kNewsLink2                          (@"link")
#define kChannelId                          (@"channelId")
#define kTrainId                            (@"trainId")
#define kTrainIndex                         (@"trainIndex")
#define kController                         (@"kController")
#define kFocals                             (@"focals")
#define kShowAbstract                       (@"selection")
#define kDesc                               (@"description")
#define kChannel                            (@"channel")
#define kChannelData                        (@"data")
#define kNewsList                           (@"newsList")
#define kPhotoList                          (@"photoList")
#define kNewsListAll                        (@"newsListAll")
#define kNewsModel                          (@"newsModel")
#define kListPicsNumber                     (@"listPicsNumber")
#define kBeginIndex                         (@"beginIndex")
#define kDateSource                         (@"kDateSource")
#define kOpenType                           (@"openType")
#define kHasTV                              (@"hasTv")

#define kTrainCardId                        (@"trainId")
#define kTrainPos                           (@"trainPos")

#define kTopArticles                        (@"topArticles")
#define kRecommendArticles                  (@"recommendArticles")
#define kFunctionArticles                   (@"functionArticles")
#define kFocusAreaItem                      (@"focusAreaItem")
#define kFocusUnderAreaItems                (@"focusUnderAreaItems")

#define kStarGrade                          (@"starGradeAvg")
#define kSubCount                           (@"subCount")
#define kNewsSubId                          (@"subId")
#define kNeedLogin                          (@"needLogin")
#define kIsSubscribe                        (@"isSubscribe")

#define kRootId                             (@"rootId")
#define kToken                              (@"token")
#define kVid                                (@"vid")
#define kExpandTips                         (@"expandTips")
#define kRollingNoticeText                  (@"noticeText")
#define kRollingNormalNoticeText            (@"tip1")
#define kRollingBlueNoticeText              (@"tip2")

// promotion
#define kPromotions                         (@"promotions")
#define kPrmTitle                           (@"title")
#define kPrmAbs                             (@"abstracts")
#define kPrmBgUrl                           (@"bgPic")
#define kPrmLftUrl                          (@"listPic")
#define kPrmLkUrl                           (@"newsLink")
#define kTips                               (@"tips")
//hot photo news
#define kHotTitle                           (@"title")
#define kHotFavoriteNum                     (@"favoriteNum")
#define kHotImageNum                        (@"imageNum")
#define kHotNews                            (@"news")

#define	kBigPicUrl                          @"bigPicUrl"
#define	kSmallPicUrl                        @"smallPicUrl"
#define	kStartTime                          @"startTime"
#define	kEndTime                            @"endTime"
#define	kPosition                           @"position"
#define	kADVersion                          @"version"
#define kPicUrl                             @"picUrl"

//photo tag
#define kName                               (@"name")
#define kTags                               (@"tags")
#define kTagId                              (@"id")
#define kTagName                            (@"name")
#define kCategories                         (@"categories")
#define kCategory                           (@"category")
#define kCategoryId                         (@"categoryId")
#define kIcon                               (@"icon")
#define kId                                 (@"id")
#define kTag                                (@"tag")
//news channel
#define kTopIcon                            (@"topIcon")
#define kIsShow                             (@"isShow")
#define kPostion                            (@"position")
#define kTop                                (@"top")
#define kTopTime                            (@"topTime")
#define kCurrPosition                       (@"currPosition")
#define kLocalType                          (@"localType")
#define kChannelCloudSyn                    (@"channelCloudSyn") //频道是否已经被云同步过了
#define kCatagoryCloudSyn                   (@"catagoryCloudSyn") //组图频道是否已经被云同步过了
#define kIsRecomAllowed                     (@"isRecomAllowed") //是否支持推荐
#define kTips                               (@"tips")
#define kTipsInterval                       (@"tipsInterval")
#define kServerVersion                      (@"version")
#define kChannelCategoryName                (@"categoryName")//频道分类名
#define kChannelCategoryID                  (@"categoryId")//频道分类ID
#define kChannelList                        (@"channelList")//频道分类对应数组
#define kChannelIconFlag                    (@"iconFlag")//频道热门与新标记
#define kChannelShowType                    (@"showType")//频道流显示 0 native, 1 h5
#define kChannelListFirstVisitKey            (@"kChannelListFirstVisitKey")//初次访问v7/list.go
#define kChannelSubId                       (@"subId")
#define kIsMixStream                        (@"isMixStream")
#define kTopCount                           (@"topCount")

#define kIdentifyImageOnMeTabKey            (@"kIdentifyImageOnMeTabKey")//我tab上标识，添加图片
#define KIdentifyOnMeText                   (@"分现金")

//第三方APP Scheme
#define kThirdAppSchemeLink                 (@"iosLink")//scheme
#define kThirdAppSchemeName                 (@"name")//app name
#define kThirdAppSchemeLoading              (@"loading")//loading页广告是否支持白名单跳转
#define kThirdAppSchemeInstream             (@"instream")//流内、正文页广告是否支持白名单跳转
#define kThirdAppSchemeOutCall              (@"outcall")//是否支持返回第三方app

//search
#define kSearchWord                         (@"words")
#define kSearchType                         (@"type")

//push setting
#define	kSubId								(@"subId")
#define	ksubid								(@"subid")
#define kPubName							(@"pubName")
#define kPubIcon							(@"pubIcon")
#define kPubPush							(@"pubPush")
#define kVideoColumnId                      (@"columnId")

//userinfo key/value
#define kNewsMode							(@"mode")
#define kNewsOffline						(@"offline")
#define kNewsOnline							(@"online")
#define kNewsExpressType                    (@"expressNews")
#define kisFromRelatedNewsList              (@"isFromRelatedNewsList")
#define kRecommendNewsIDList                (@"recommendNewsIDList")
#define kNewsSupportNext                    (@"supportNext")
#define kCtx                                (@"ctx")
#define kTracker                            (@"tracker")
#define kIsRecommend                        (@"isRecommend")

//living
#define kLiveGameItem                       (@"liveGameItem")

//more wordSize
#define kWordMoreBig                        (@"font5")
#define kWordBig                            (@"font4")
#define kWordMiddle                         (@"font3")
#define kWordSmall                          (@"font2")
#define kWordSmall1                         (@"font1")

//pic mode
#define kPicModeAlways                      0     //阅读模式：畅读
#define kPicModeNone                        1     //阅读模式：小图   （服务端和h5:1是无图）
#define kPicModeWiFi                        2     //阅读模式：无图    (服务端和h5:2是小图)

#define kCommentList                        (@"commentList")
#define kCommentId                          (@"commentId")
#define kAuthorimg                          (@"authorimg")
#define kCity                               (@"city")
#define kWeatherCity                        (@"weather_city")
#define kWeatherGbcode                      (@"weather_gbcode")     
#define kReplyNum                           (@"replyNum")
#define kDigNum                             (@"digNum")
#define kFloors                             (@"floors")
#define kPlCount                            (@"plCount")
#define kReadCount                          (@"readCount")
#define kStpAudCmtRsn                       (@"stpAudCmtRsn")
#define kPassport                           (@"passport")
#define kLinkStyle                          (@"linkStyle")
#define kSpaceLink                          (@"spaceLink")
#define kPid                                (@"pid")
#define kCommentImageSmall                  (@"imageSmall")
#define kCommentImage                       (@"image")
#define kCommentImageBig                    (@"imageBig")
#define kCommentNewsTitle                   (@"newsTitle")
#define kCommentNewsLink                    (@"newsLink")
#define kCommentAudLen                      (@"audLen")
#define kCommentAudUrl                      (@"audUrl")
#define kCommentUserComtId                  (@"userComtId")
#define kFavoriteCount                      (@"favoriteCount")

//my message(我的消息)
#define kMsgReceive                         (@"msgReceive")
#define kMsgApi                             (@"apiMsg")
#define kMsgNext                            (@"nextCursor")
#define kMsgPre                             (@"preCursor")
#define kMsgResult                          (@"result")
#define kMsgUserActUrl                      (@"url")
#define kMsgActComment                      (@"actComment")
#define kMsgReplyComment                    (@"beReplyComment")
#define kMsgRelateActInfo                   (@"relateActInfo")
#define kMsgType                            (@"msgType")
#define kMyMsgContent                       (@"content")
#define kMyMsgOrignalContent                (@"myContent")
#define kMyMsgCommentType                   (@"commentType")
#define kMyMsgCtime                         (@"ctime")
#define kMyMsgGender                        (@"gender")
#define kMyMsgHeadUrl                       (@"headUrl")
#define kMyMsgFromLink                      (@"link")
#define kMyMsgId                            (@"msgId")
#define kMyMsgNickName                      (@"nickName")
#define kMyMsgPid                           (@"pid")
#define kMyMsgCity                          (@"city")
#define kMyMsgShareInfo                     (@"originContent")

//Special news(专题新闻)
#define kSNTermId                           (@"termId")
#define kSNPubId                            (@"pubId")
#define kSNTermName                         (@"termName")
#define kSNFocus                            (@"focals")
#define kSNNews                             (@"news")
#define kSNNewsId                           (@"newsId")
#define kSNNewsType                         (@"newsType")
#define kSNTitle                            (@"title")
#define kSNPic                              (@"pic")
#define kSNIsFocusDisp                      (@"isFocusDisp")
#define kSNAbstract                         (@"abstract")
#define kSNLink                             (@"link")
#define kSNLink2                            (@"link2")
#define kSNGuide                            (@"guide")
#define kSNNormal                           (@"normal")
#define kSNPage                             (@"page")
#define kSNName                             (@"name")
#define kSNNewsList                         (@"newsList")
#define kSNColumn                           (@"column")
#define kSNShareContent                     (@"shareContent")
#define kSpecailNewsListAll                 (@"specialnewsListAll")
//V5.3.0
#define kSNCorpusFoldID                     (@"fid")
#define kSNCorpusImageUrl                   (@"imgUrl")
#define kSNCorpusCollectTime                (@"collectTime")

//splash
#define kTimestamp                          (@"timestamp")
#define kUrl                                (@"url")
#define kAdText                             (@"adText")
#define kAdLink                             (@"adLink")
#define kAdLink2                            (@"adV2Link")
#define kStartDate                          (@"startTime")
#define kEndDate                            (@"endTime")
#define kCheckTitle                         (@"checkTitle")
#define kIsChecked                          (@"isChecked")
#define kShareText                          (@"shareText")
#define kSubscribe                          (@"subscribe")

#define kChangeSplashTimeKey                (@"kChangeSplashTimeKey")
#define kCurrentSplashImageOrder            (@"kCurrentSplashImageOrder")

#define kIs3DTouchOpen                      (@"kIs3DTouchOpen")
#define kIsWidgetOpen                       (@"kIsWidgetOpen")  // 从widget打开进入我的收藏的我的录入tab


//news web view
#define WEBVIEW_REQUEST_TIMEOUT				(60)
#define kLoadingSize						(40)
#define kContentFrame						(TTNavigationFrame())
#define kFullScreenFrame					(TTApplicationFrame())
#define kNextContentFrame					(CGRectMake(320, 0, 320, TTApplicationFrame().size.height - TTToolbarHeight()))
#define kNextFullScreenFrame				(CGRectMake(320, 0, 320, TTApplicationFrame().size.height))
#define kNewsSlideDuration					(0.4)
#define kWebUrlViewHeight                   (44)

//geture
#define	kZoomDistanceThreshold				(20)
#define	kDetectionDelay						(0.2)

//photo list
#define kShareBtnWidth                      (32)
#define kShareBtnHeight                     (26)
#define kPhotoListTitleFont                 (15)
#define kPhotoListTextFont                  (16)
#define kMaxRecommendCount                  (3)
#define kControlSpace                       (10)
#define kMaxPhotoHeight                     (450/2)
#define kClipTopPercent                     (0.0)
#define kPhotoListHeaderSecHeight           (44)
#define kPhotoListMaxLoadImageCount         (8)

//只有报纸里的组图才使用termId和newsId。
//相关推荐出来的组图,组图tab里的组图，实时新闻里的组图都使用gid，不用newsId，因为没有termId。
//termId为闲置字段，还用来作为区分3种组图的标志位。
#define kDftSingleGalleryTermId             (@"0")
#define kDftGroupGalleryTermId              (@"0")
#define kDftChannelGalleryTermId            (@"-1")

#define kClipPercentFromTop                 (1/10.0)
#define kImageLeftMargin                    (28/2)


//newspaper property
#define kNewspaperHomePageFlag				(@"mpaperhome_")

//publication
#define SUBSCRIBE_CENTER_URL_ACTION         (@"tt://subscribe_center")

#define kSubscribed                         (1) //1表示刊物已订阅
#define kUnsubscribed                       (0) //0表示刊物未订阅
#define kUnsubscribedPubSubIDs              (@"nosubid")
#define kSubscribedPubSubIDs                (@"yessubid")
#define kSubscribeMode                      (0)
#define kUnsubscribeMode                    (1)
#define kSUBSCRIBE                          (@"1")
#define kUNSUBSCRIBE                        (@"0")
#define kMUST_PUSH                          (@"1")
#define kDONT_PUSH                          (@"0")

//这个key对应的值表示当前设置是否是新注册过，1表示新注册，0表示已注册过
#define kNEW_REGISTERED_DEVICE_KEY          (@"new")
#define kIS_NEW_REGISTERED_DEVICE           (@"isNewRegisteredDevice")
#define kUNKNOWN_REGISTERED                 (@"unknown")
#define kNEW_REGISTERED                     (@"1")
#define kHAD_REGISTERED                     (@"0")
#define kPAPERS                             (@"papers")
#define kDEFAULT                            (@"default")
#define kMY_SUB                             (@"mySub")
#define kPUB_TYPE                           (@"pubType")
#define kPAPER                              (@"paper")
//default JSON数据解析相关
#define kSUB_ID                             (@"subId")
#define kPUB_ID                             (@"pubId")
#define kPUB_NAME                           (@"pubName")
#define kPUB_TYPE_NAME                      (@"name")
#define kPUB_PUBSUBSCRIBE                   (@"pubSubscribe")
#define kPUB_ICON                           (@"pubIcon")
#define kORDER_INDEX                        (@"orderIndex")
#define kLAST_TERM_LINK                     (@"lastTermLink")
#define kSUB_TYPE                           (@"subType")
#define kDEFAULT_PUSH                       (@"defaultPush")
#define kDEFAULT_SUB                        (@"defaultSub")
#define kHadMySubDBMigrationDone            (@"kHadMySubDBMigrationDone")
//与navigator相关
#define kNAVIGATOR_REFERENCE                (@"navigator_reference")
#define kNAVIGATOR_REFERENCE_PUB_HOME       (@"navigator_reference_from_publication_home")
//与批量下载相关
#define kIfDownloadSettingHadShown          (@"kIfDownloadSettingHadShown")
#define kHAD_DOWNLOADED                     (@"1")
#define kNOT_DOWNLOADED                     (@"0")
#define kNOT_FOUND_PACKAGE_IN_SERVER_ERROR_CODE         (404)
#define kCORRUPTED_PACKAGE_ERROR_CODE                   (1314)
#define kReferOfDownloader                  (@"kReferOfDownloader")
#define kDownloadingSubSectionDataTag                                   (@"kDownloadingSubSectionDataTag")
#define kDownloadingNewsSectionDataTag                                  (@"kDownloadingNewsSectionDataTag")
#define kWeiboDetailModelPageSize           (20)
//与及时新闻下载相关
#define kArticleNewsWorker                  (@"kArticleNewsWorker")
#define kGroupPhotoNewsWorker               (@"kGroupPhotoNewsWorker")
#define kSpecialNewsWorker                  (@"kSpecialNewsWorker")
#define kLiveNewsWorker                     (@"kLiveNewsWorker")
#define kWeiboHotDetailWorker               (@"kWeiboHotDetailWorker")

#define kDownloadSettingItemSelected        (@"1")
#define kDownloadSettingItemUnselected      (@"0")
#define kDownloadSettingSubSectionHeaderIsFolded    (@"kDownloadSettingSubSectionHeaderIsFolded")
#define kDownloadSettingNewsSectionHeaderIsFolded   (@"kDownloadSettingNewsSectionHeaderIsFolded")
#define kDownloadingSubSectionHeaderIsFolded        (@"kDownloadingSubSectionHeaderIsFolded")
#define kDownloadingNewsSectionHeaderIsFolded       (@"kDownloadingNewsSectionHeaderIsFolded")

//是否有新一期
#define kNO_NEW_TERM                        (@"0")
#define kHAVE_NEW_TERM                      (@"1")
#define KHAD_BEEN_OFFLINE                   (@"2")//已经最新一期离线
//订阅首页刷新控制相关
#define kSUB_HOME_LAST_REFRESHING_TIME      (@"SUB_HOME_LAST_REFRESHING_TIME")
#define kSUB_HOME_REFRESHING_DURATION_SEC   (300)
#define kSUB_HOME_BACK_TABLE_VIEW_CELL      (@"sub_home_back_table_view_cell")
#define kPubIDsForWangQiAction              (@"kPubIDsForWangQiAction")
//订阅推荐相关
#define kDONT_REMIND_ME_RECOMMEND_SUBS      (@"kDONT_REMIND_ME_RECOMMEND_SUBS")
#define kDONT_REMIND_ME_RECOMMEND_SUBS_Y    (@"kDONT_REMIND_ME_RECOMMEND_SUBS_Y")
#define kDONT_REMIND_ME_RECOMMEND_SUBS_N    (@"kDONT_REMIND_ME_RECOMMEND_SUBS_N")
//我的订阅相关
#define MAX_ITEMS_COUNT_PER_PAGE            (8)

#define SPLASH_SLIDE_INTERVAL               (0.6)
#define SPLASH_CONTENT_FASTER_FACTOR        (0.25)

// 组图请求类型
#define kGroupPhotoHot                      (@"hot")
#define kGroupPhotoCategory                 (@"category")
#define kGroupPhotoChannel                  (@"channel")
#define kGroupPhotoDefaultId                (@"12")
#define kGroupPhotoChannelDefaultId         (@"12")
#define kGroupPhotoDefaultTitle             (@"新闻")
#define kGroupPhotoTag                      (@"tag")

//STHeitiSC-Light: 常州华文的黑体-简，iOS默认中文字体
//Helvetica: iOS默认英文字体
#define kFontFimalyName                     @"Helvetica"
#define kDigitAndLetterFontFimalyName       @"Helvetica"
#define kCommentNumberFontFimalyName        @"Helvetica"
#define kCopyrightFontFimalyName            @"Helvetica"

#define kParameterSeparator                 (@"^_^")

#define KCommentSourceNews                  (@"news")
#define KCommentSourceComment               (@"comment")
#define KCommentTypeHot                     (@"hot")
#define KCommentTypeLatest                  (@"all")
#define KCommentTypeToMe                    (@"tome")
#define KCommentTypeMy                      (@"my")
//comment status 0：评论正常， 1：关闭评论，不能发如何评论,包括文字、图片、语音 , 2：禁止语音评论 , 3：禁止图片评论 ,4：禁止文件评论，即同时禁止图片语音评论
#define kCommentStsNormal                (@"0")
#define kCommentStsForbidAll             (@"1")
#define kCommentStsForbidAudio           (@"2")
#define kCommentStsForbidImage           (@"3")
#define kCommentStsForbidMedia           (@"4")

#define kNewsTypePhotoAndText               (@"3")
#define kNewsTypeGroupPhoto                 (@"4")
#define kNewsTypeLive                       (@"9")
#define kNewsTypeSpecialNews                (@"10")
#define kNewsTypePaper                      (@"11")
#define kNewsTypeVoteNews                   (@"12")
#define kNewsTypeWeibo                      (@"13")
#define kNewsTypePublic                     (@"19") //彩票、世界杯入口类型
#define kNewsTypeAd                         (@"21") //广告
#define kNewsTypeMySubscribe                (@"22") //我的订阅
#define kNewsTypeVideo                      (@"14") //视频
#define kNewsTypeFinance                    (@"20") //财经
#define kNewsTypeNewFinance                 (@"54") //新财经
#define kNewsTypeApp                        (@"18") //下载应用
#define kNewsTypeFocusWeather               (@"16") //焦点天气
#define kNewsTypeAppArray                   (@"23") //批量应用
#define kNewsTypeOtherNews                  (@"60") //全网新闻
#define kNewsTypeIndividuation              (@"25") //个性化模版
#define kNewsTypeRollingVideo               (@"64") //频道流视频
#define kNewsTypeRollingFunnyText           (@"62") //频道流段子
#define kNewsTypeRollingBigVideo            (@"37")//流内大图模式
#define kNewsTypeRollingMiddleVideo         (@"38")//流内中图模式

#define kNewsTypeRollingBook                (@"26") //频道流小说
#define kNewsTypeRollingBookShelf           (@"121") //频道流小说书架
#define kNewsTypeRecommendBook              (@"67") //推荐流小说 以前是26，现在是67，不知原因

//newsType大于30都为订阅类型
#define kSubscriptionType                   (@"32") //搜索中的订阅类型
#define kSubscriptionVideoType              (@"41") //视频订阅类型
#define kSubscriptionOrgType                (@"39") //政企订阅类型
#define kSubscriptionLinkType               (@"37") //订阅外链
#define kSubscriptionOtherType              (@"31")

#define kNavigationBarShadowOffset          CGSizeMake(0, 1)
#define kNavigationBarShadowOpacity         (0.38)
#define kNavigationBarShadowRadius          (3)
#define kCurrentUserName                    (@"kCurrentUserName")
#define kDefaultUserName                    (@"搜狐网友")
#define kAdRefreshTime                      (@"kAdRefreshTime")

#define kChannleRefreshTime                     @"kChannleRefreshTime"
#define kChannleOnHourRefreshTime               @"kChannleOnHourRefreshTime"
#define kNewsThemeNightValidTime                @"kNewsThemeNightValidTime"
#define kABTestAppStyleChangeValidTime          @"kABTestAppStyleChangeValidTime"
#define kABTestCurAppStyle                      @"kABTestCurAppStyle"
#define kABTestValidAppStyle                    @"kABTestValidAppStyle"

#define kNonePictureModeKey                     @"kNonePictureModeKey"
#define kNoneVideoModeKey                       @"kNoneVideoModeKey"
#define kAutoFullscreenModeKey                  @"kAutoFullscreennModeKey"

#define kThemeDirName                           (@"Themes")
#define kPhotoListDataFinsh                     (@"kPhotoListDataFinsh")

#define kAppNotLaunchedForSomeTimeNotifyEnabled (@"kAppNotLaunchedForSomeTimeNotifyEnabled")
#define kAppNotLaunchedForSomeTime              (@"kAppNotLaunchedForSomeTime")
#define kAppNotLaunchedPeriod                   (60*60*24*10)
#define kAppNotLaunchedFireTime                 (9)

#define kNewsPushSet                            (@"newsPushSet")
#define kReaderPushSet                          (@"readerPushSet")//小说推送总开关
#define kPaperPushSet                           (@"paperPushSet")
//系统push相关
#define kPushAlert                              (@"alert")
#define kPushAPS                                (@"aps")
#define kPushTitle                              (@"title")
#define kPushBody                               (@"body")

#define OPEN_COMMENT_BTN_HEIGHT                       (28 / 2)
#define MarginTopBetweenUserLabelAndTimeDingLabel     (10.0f / 2)
#define CELL_USER_ICON_HEIGHT                         (60 / 2)
#define FLOOR_TOP_MARGIN                              (18 /2.0f)
#define NEWSTITLE_LEFT_MARGIN                         (16 /2.0f)
#define CELL_DATE_CITY_DING_LABEL_HEIGHT              (25/2.0f)
#define CELL_CITY_LABEL_WIDTH                         (140.0f)
#define SOUNDVIEW_WIDTH                               232
#define SOUNDVIEW_HEIGHT                              38
#define SOUNDVIEW_SPACE                               8
#define kPicViewWidth                                (54)
#define kPicViewHeight                               (54)
#define kCommentRoleTypeLeft                         (18)
#define kCommentRoleTypeTopMargin                    (50)
#define kExpandLimit                                 (4)
#define EXPAND_BTN_HEIGHT                            (40)

//专题
#define kSpecialNewsTermId                      kTermId
#define kSpecialNewsTitle                       (@"kSpecialNewsTitle")
#define kSpecialNewsRefreshInterval             (60*30)
#define kSNkSpecialNormal                       (@"0")
#define kSNFocusNewsType                        (@"1")
#define kSNPhotoAndTextNewsType                 (@"3")
#define kSNGroupPhotoNewsType                   (@"4")
#define kSNTextNewsType                         (@"6")
#define kSNHeadlineNewsType                     (@"7")
#define kSNOuterLinkNewsType                    (@"8")
#define kSNLiveNewsType                         (@"9")
#define kSNSpecialNewsType                      (@"10")
#define kSNNewsPaperNewsType                    (@"11")
#define kSNVoteNewsType                         (@"12")
#define kSNVoteWeiwenType                       (@"13")
#define kSNIsFocusDisp_YES                      (@"1")
#define kSNIsFocusDisp_NO                       (@"0")
#define kSNSpecialNewsIsRead_YES                (@"1")
#define kSNSpecialNewsIsRead_NO                 (@"0")
#define kSNSpecialNewsForm_Headline             (@"headlinenews")
#define kSNSpecialNewsForm_Normal               (@"normalnews")

//自定义状态栏相关
#define kNotificationWillOpenDownloader         (@"notification_will_open_downloader")

//收藏
#define kMyFavouriteRefer                       @"kMyFavouriteRefer"
#define kPubDate                                @"kPubDate"
#define kMyFavouriteCellIsRead_YES              @"1"
#define kMyFavouriteCellIsRead_NO               @"0"

//推荐新闻相关
//--- 以下三个值是为了区分新闻最终页是从哪个入口打开的（刊物、及时新闻列表、专新闻列表、收藏列表等），以便在新闻最终页返回时能区分是返回刊物首页、及时新闻列表页、专题新闻列表页、收藏列表页；
#define kReferFrom                              (@"kReferFrom")
#define kReferFromPublication                   (@"kReferFromPublication")
#define kReferFromRollingNews                   (@"kReferFromRollingNews")
#define kReferFromSpecialNews                   (@"kReferFromSpecialNews")
#define kReferFromMyFavourite                   (@"kReferFromMyFavourite")
#define kReferFromSearch                        (@"kReferFromSearch")

//点击推荐出来的新闻的时候，在访问接口的时候加上参数from=recommend&fromId=${newsId}，以便统计到相关数据
#define kRecommendFromNewsId                    (@"kRecommendFromNewsId")
//#define kRecommendFromURLParams                 (@"from=recommend&fromId=%@")

//连续阅读
#define kContinuityNews                         (@"kContinuityNews")
#define kContinuityPhoto                        (@"kContinuityPhoto")
#define kContinuitySpecial                      (@"kContinuitySpecial")
#define kContinuityLive                         (@"kContinuityLive")
#define kContinuityWeb                          (@"kContinuityWeb")
#define kContinuityWeibo                        (@"kContinuityWeibo")
#define kContinuityType                         (@"kContinuityType") //连续阅读默认状态
#define kNewsPaperPtr                           (@"kNewsPaperPtr")
#define kClickOpenNews                          (@"kClickOpenNews")

//comment busiCode
#define kCommentBusiCodeLive                           (@"1")
#define kCommentBusiCodeNews                           (@"2")
#define kCommentBusiCodePhoto                          (@"3")
#define kCommentBusiCodeWeibo                          (@"4")

//新手引导，频道滑动切换
#define kSlideToChangeChannelGuideKey @"kSlideToChangeChannelGuideKey"
#define kTriggerPopoverMessage  @"triggerPopoverMessage"

#define kClickSohuIconBackToHomePageKey @"kClickSohuIconBackToHomePageKey"

#define kCommentInputViewRect CGRectMake(0, 0, kAppScreenWidth, 216)

#define CGFLOAT_MAX_CORE_TEXT    (5000.0f)

#define AUDIO_REC_MIN_DUR 0.5f

typedef enum {
    GallerySourceTypeNewsPaper          = 0,
    GallerySourceTypeGroupPhoto         = 1,
    GallerySourceTypeRecommend          = 2
} GallerySourceType;

typedef enum {
    GalleryLoadTypeNone                 = 0,
    GalleryLoadTypePrev                 = 1,
    GalleryLoadTypeNext                 = 2
} GalleryLoadType;

typedef enum {
    GalleryTargetTypeNone               = 0,
    GalleryTargetTypeToPrev             = 1,
    GalleryTargetTypeToNext             = 2
} GalleryTargetType;

typedef enum {
    GenderUnknown   = 0,
    GenderMale      = 1,
    GenderFemale    = 2
} Gender;

// 视频Tab新视频数通知
#define kVideoTimelineCntForNew            @"kVideoTimelineCntForNew"
#define kVideoTimelinePrecursor            @"kVideoTimelinePrecursor"

#import "UIDevice-Hardware.h"
// 视频Timeline UI相关
//#define kPlayerViewHeight                                   (([[UIDevice currentDevice] platformTypeForSohuNews] == UIDevice6PlusiPhone)?(290.0f):(452/2.0f)) //lijian 2015.03.06
//#define kPlayerViewHeight                                   (452/2.0f)
#define kTimelineContentViewWidth                           (kAppScreenWidth - 20)
#define kTimelineCellBgViewSideMargin                       (16/2.0f)
#define kTimelineVideoCellSubContentViewsTopMargin          (6/2.0f)
#define kPlayerViewHeight                                   ((kAppScreenWidth - (kTimelineCellBgViewSideMargin * 2)) * 3/4) //lijian 2015.04.07
#define kTimelineVideoCellSubContentViewsHeight             (kPlayerViewHeight + 43)//(538/2)
#define kTimelineVideoCellHeight                            (kTimelineVideoCellSubContentViewsHeight + 2*kTimelineVideoCellSubContentViewsTopMargin)
#define kHeadlineTitleHeight_NonFullScreen                  (34.0f/2.0f)
#define kHeadlineTitleFontSize_NonFullScreen                (32.0f/2.0f)

#define kTimelineVideoCellSubContentViewsSideMargin         (20/2)

#define kTimelineSiteNameAndDurationLRMarginToPosterLRSide  (11.0f)
#define kTimelineSiteNameAndDurationFontSize                (7.0f)
#define kTimelineSiteNameAndDurationHeight                  (9.0f)

#define kVideosAppContentHeight                             (170/2.0f)
#define kVideosAppCellHeight                                (kVideosAppContentHeight + 2*kTimelineVideoCellSubContentViewsTopMargin)

#define kVideosActivityContentHeight                        kVideosAppContentHeight
#define kVideosActivityCellHeight                           kVideosAppCellHeight


// 热播ChannelId
#define kVideoTimelineMainChannelId        @"1"

#define kSohuVideoBundleID                  (@"com.sohu.sohuvideo")

#define kPlayerViewWithActionSheet                      (@"kPlayerViewWithActionSheet")


#define kAutoPlayTimelineVideos                         (@"kAutoPlayTimelineVideos")
#define kCanTimelineToVideoDetailPage                   (@"kCanTimelineToVideoDetailPage")

#define kTimelineVideoPausedManually                    (@"kTimelineVideoPausedManually")
#define kTimelineVideoHadEverAutoPlayInWifi             (@"kTimelineVideoHadEverAutoPlayInWifi")

#define kWSMVVideoPlayerReferKey                        (@"kWSMVVideoPlayerReferKey")
#define kDataKey_TimelineVideo                          (@"timelineVideo")
#define kDataKey_TimelineVideos                         (@"timelineVideos")
#define kDataKey_VideoTabTimelineVideoModel             (@"videoModel")
#define kDataKey_OfflinePlayVideos                      (@"offlinePlayVideos")
#define kWSMVRecommendVideoTableViewWidth               (454.0f/2.0f)

//---RecommendCell相关
#define kWSMVRecommendVideoCellHeadlineLabelMarginLeft                      (20.0f/2.0f)
#define kWSMVRecommendVideoCellHeadlineLabelMarginRight                     (20.0f/2.0f)
#define kWSMVRecommendVideoCellHeadlineLabelMarginTop                       (22.0f/2.0f)
#define kWSMVRecommendVideoCellHeadlineLabelMarginBottom                    (22.0f/2.0f)
#define kWSMVRecommendVideoCellHeadlineLabelFontSize                        (28.0f/2.0f)
//---

#define kActionMenuViewDidTapLikeBtn                        (@"didTapLikeBtn")

//视频自媒体
#define kVideoMediaTitle                    (@"kVideoMediaTitle")
#define kVideoMediaLink                     (@"kVideoMediaLink")
#define kMidInMediaLink                     (@"mid")

//---视频Timeline App换量相关-------------------------------------------------
#define kTimelineAppContent_IconOpen                        (@"iconOpen")
#define kTimelineAppContent_IconDownload                    (@"iconDown")
#define kTimelineAppContent_IconUpgrade                     (@"iconUpdate")
#define kTimelineAppContent_AppDownloadLink                 (@"appDownloadLink")
#define kTimelineAppContent_AppIdOfAppWillBeOpen            (@"appId")
#define kTimelineAppContent_AppURLSchemaOfAppWillBeOpen     (@"urlScheme")
#define kTimelineAppContent                                 (@"appContent")
//---------------------------------------------------------------------------
#define kDefaultChannelIdForVideoDownload                   (@"-1000")

#define kToast_ActionURL                                    (@"______ToastActionURL______")
#define kToast_Text                                         (@"______ToastsText______")
#define kToast_HideAfter                                    (@"______ToastHideAfter______")

#define kSNVideoDownloadViewMode                            (@"kSNVideoDownloadViewMode")

#define kToBeDownloadedVideoModel                           (@"______ToBeDownloadedVideoModel______")

#define kWSMVStatVV_Offline_NO                              @"0"
#define kWSMVStatVV_Offline_YES                             @"1"

//视频离线
typedef enum {
    SNVideoDownloadState_Waiting     = 0,
    SNVideoDownloadState_Downloading = 1,
    SNVideoDownloadState_Pause       = 2,
    SNVideoDownloadState_Canceled    = 3,
    SNVideoDownloadState_Failed      = 4,
    SNVideoDownloadState_Successful  = 5
} SNVideoDownloadState;

//枚举说明见wiki：http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=7471346
//新闻列表中新闻的统计类型
typedef NS_ENUM(NSInteger, SNRollingNewsStatsType) {
    SNRollingNewsStatsType_NormalNewsStat,//普通新闻统计
    SNRollingNewsStatsType_ShnAdStat//搜狐新闻投放的广告统计(c.gif)
};

//我的界面
#define kShowAddFriend                                      (@"kShowAddFriend")
//用户启动APP标示
#define kUserStartAPPType                                    (@"usr_start_app")
#define kVideoPlayerPosterBgColor() ([[SNThemeManager sharedThemeManager] isNightTheme] ? [UIColor colorFromString:@"#888888"] : [UIColor colorFromString:@"#e5e5e5"])

#define kShowRedDotForNewInstallApp                         (@"kShowRedDotForNewInstallApp")

#define kEnterChannelManageViewTag (@"kEnterChannelManageViewTag")


//新闻来源
#define kOtherNews              @"0" //其他
#define kNormalChannlNews       @"1" //从频道内点击
#define kTagChannalNews         @"2" //从TAG标签预览频道点击
#define kSearchNews             @"3" //从搜索点击
#define kSubscrieNews           @"4" //从刊物内点击
#define kChannelEditionNews     @"5" //从频道内编辑流点击
#define kChannelRecomNews       @"6" //从频道内推荐流点击
#define kNewsRecomNews          @"7" //从新闻正文下的相关推荐点击
#define kPushShareNews          @"10" //从push分享打开
#define kTopicNews              @"11" //从专题内点击
#define khotSearch              @"12" //热点搜索的搜索结果列表点击
#define kArticleBlueWordsSearch @"13" //正文蓝词搜索结果列表的点击
#define kHomePagePullSearch     @"14" //首页下拉搜索框搜索结果列表的点击
#define kChannelListSearch      @"15" //频道列表的搜索入口进来的正文点击
#define kBackToNews             @"17" //其他页面返回到正文页
#define kNewsFrom               @"newsfrom"
#define kCurrentChannelId       @"currentChannelId"

#define kOtherCollection                  @"0"  //其他
#define kChannelRecomCollection           @"3"  //推荐流列表上收藏
#define kRecomNewsCollection              @"4"  //推荐流进来的正文上收藏
#define kChannelEditionCollection         @"5"  //编辑流列表上收藏
#define kEditionNewsCollection            @"6"  //编辑流进来的正文上的收藏
#define kSearchNewsCollection             @"7"  //搜索列表进来的正文上收藏
#define kNewsRecomNewsCollection          @"8"  //相关推荐进来的正文收藏
#define kCollectionFrom                   @"collectionfrom"
#define kH5WebType                        @"h5WebType"//标记是否是外链新闻模版,用于分享和收藏上报

#define kCommentEditorViewShowTime 0.25

#define kCloudSynchronousWords @"换手机了？快来把我的频道、收藏和订阅的刊物同步到这里吧"
#define kCancelCloudSynchronous @"取消"
#define kImmediatelyCloudSynchronous @"马上同步"
#define kCloudSynchronousStatus @"正在同步您的信息到本机"
#define kCloudSynchronousSucceed @"已成功同步您的信息到本机"

#define kSNCorpusServerSynced @"SNCorpusServerSynced"

#define kFavouritePageTag @"kFavouritePageTag"


/*
 企业版：
 appid: 2016031501214747
 正式版：
 appid：2016031101203522

 */
#define kSNAPAPPID_INHOUSE @"2016031501214747"
#define kSNAPAPPID @"2016031101203522"
#define kSNAPPID @"2088221384467458"


#define isINHOUSE [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.sohu.newspaper.inhouse"]  

#define kPopupAESKEY       @"popup01234567890"

#define kNewUserGuideSwitch 0       //新手引导页开关

#define SN_ApplicationSohuPath  [NSString writeToFileWithName:@"ApplicationSohu.plist"]
#define SN_ApplicationSohu @"申请成为搜狐号"
#define SN_ManageSohu @"管理搜狐号"

/**
 requestManagerName
 */
#define SNNet_Request_HostManager           @"SNNet_Request_HostManager"
#define SNNet_Request_DefaultManager        @"SNNet_Request_DefaultManager"
#define SNNet_Request_SCookieManager        @"SNNet_Request_SCookieManager"
#define SNNet_Request_ResponseHttpManager   @"SNNet_Request_ResponseHttpManager"
#define SNNet_Request_CommentManager        @"SNNet_Request_CommentManager"

#define SNNews_Push_Back_FocusNews_ValidTime    @"kNewsBackFocusNewsValidTime"
#define SNNews_Push_Back_Key                    @"backWhere"
#define SNNews_Push_Back_FocusNews              @"2"    //新闻强制返回《要闻》频道。（只在当天6点以后第一次，push或者端外启动正文）
#define SNNews_Push_Back_RecomNews              @"1"    //新闻强制返回《推荐》频道。（push或者端外非第一次启动正文 || push或者端外后台1小时调起正文）


#define kTodaynewswidgetGroup  @"group.com.sohu.widget"
#define kTodaynewswidgetPid    @"TodaynewswidgetPid"
#define kTodaynewswidgetP1    @"TodaynewswidgetP1"
#define kNewsGrabAuthority     @"kNewsGrabAuthority"

#define kTemplateTypeFullScreenFocus        @"202"
#define kTemplateTypeTrainCard              @"79"
#define kTemplateTypeRollingNewsHistoryLine         @"203"

#define LoadingSwitch           (![[SNUserDefaults objectForKey:kLoadingSCSDKSwitch] isEqualToString:@"0"])//loading新品算开关

