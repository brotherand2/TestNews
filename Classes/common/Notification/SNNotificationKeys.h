//
//  SNNotificationKeys.h
//  sohunews
//
//  Created by H on 2016/12/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#ifndef SNNotificationKeys_h
#define SNNotificationKeys_h

#define kBackFromBindViewControllerNotification             @"kBackFromBindViewControllerNotification"
#define kSNSHideTabBarNotification                          @"kSNSHideTabBarNotification"
#define kSNSShowTabBarNotification                          @"kSNSShowTabBarNotification"
#define kUIMenuControllerHideMenuNotification               @"kUIMenuControllerHideMenuNotification"
#define kCloseSearchWebNotification                         @"kCloseSearchWebNotification"
#define kUpdatePlayVideoImageNotification                   @"kUpdatePlayVideoImageNotification"
#define kHideKeyBoardFromChatBackNotification               @"kHideKeyBoardFromChatBackNotification"
#define kAddStockNotification                               @"addStockNotification"
#define kChangePreviewChannelNotification                   @"changePreviewChannelNotification"
#define kRefreshChannelTabNotification                      @"refreshChannelTab"
#define kHideStatusbarWhenAppearNotification                @"hideStatusbarWhenAppear"
#define kDragRefreshTableReloadNotification                 @"DragRefreshTableReload"

//红包
#define kRedPacketUserGuideNotification                     (@"kRedPacketUserGuideNotification")
#define kGetUserRedPacketNotification                       (@"kGetUserRedPacketNotification")
#define kShowSplashViewNotification                         (@"showSplashNotification")
#define kNonePictureModeChangeNotification                  @"kNonePictureModeChangeNotification"
#define kFontModeChangeNotification                         @"kFontModeChangeNotification"
#define kCommentHideKeyondNotification                      @"kCommentHideKeyondNotification"
#define kThemeDidChangeNotification                         @"kThemeDidChangeNotification"
#define KABTestChangeAppStyleNotification                   @"KABTestChangeAppStyleNotification"

#define kStatusBarStyleChangedNotification                  @"kStatusBarStyleChangedNotification"

#define kUpdateCellFontChangeNotification                   (@"kUpdateCellFontChangeNotification")
#define kUpdateStatusBarStyleChangeNotification             (@"kUpdateStatusBarStyleChangeNotification")
#define kUpdateCellFontChangeNotification                   (@"kUpdateCellFontChangeNotification")
//新手引导
#define kSlideToChangeChannelNotification                   @"kSlideToChangeChannelNotification"
#define kChannelRefreshMessageNotification                  @"kChannelRefreshMessageNotification"
#define kFontSetterGuideDismissNotification                 @"kFontSetterGuideDismissNotification"

//for jojo 登录拦截
#define kNewUserGuideViewDidCloseNotification               @"kNewUserGuideViewDidCloseNotification"

#define kLoadChannelListNotification                        @"kLoadChannelListNotification"
#define kCloseTipsImageViewNotification                     @"kCloseTipsImageViewNotification"
#define kAutoRefreshChannelNewsNotification                 @"kAutoRefreshChannelNewsNotification"
#define kAutoRefreshVideoNewsNotification                   @"kAutoRefreshVideoNewsNotification"
#define kAutoRefreshUserInfoNotification                    @"kAutoRefreshUserInfoNotification"
#define kDeleteNewsCellNotification                         @"kDeleteNewsCellNotification"
#define kSplashViewDidShow                                  @"kSplashViewDidShow"
#define kResetMyCouponBadgeNotification                     @"kResetMyCouponBadge"

#define kRecommendReadMoreDidClickNotification              @"kRecommendReadMoreDidClickNotification"
#define kFullscreenThemeDidFetchedkNotification             @"kFullscreenThemeDidFetchedkNotification"
//视频tab更新
#define kVideoTimelineCheckNewNotification                  @"kVideoTimelineCheckNewNotification"

// 视频频道tip提示通知
#define kVideoTimelineRefreshMsgNotification                @"kVideoTimelineRefreshMsgNotification"

//手动关闭或分享完成后自动关才SNShareWithCommentController时会发出这个通知
#define kShareWithCommentControllerDidDismissNotification   (@"kShareWithCommentControllerDidDismissNotification")
#define kCancelAutoPlayRelativeVideosNotification           (@"kCancelAutoPlayRelativeVideosNotification")
#define kFinishCheckTimelineVideosControlNotification       (@"kFinishCheckTimelineVideosControlNotification")

// 用户中心 登陆 注销相关notification
#define kUserDidLoginNotification                           (@"notifyLogin")
#define kUserDidLogoutNotification                          (@"notifyLogout")
#define kUserDidCancelLoginNotification                     (@"notifyCancelLogin")

#define SNNews_Login_ThridLogin_LoginSuccessed              (@"SNNews_Login_ThridLogin_LoginSuccessed")

#define kSendVerifyCodeNotification                         @"kSendVerifyCodeNotification"
#define kMobileNumLoginNotification                         @"kMobileNumLoginNotification"
#define kVerifyCodeAndMobileNumClickNotification            @"kVerifyCodeAndMobileNumClickNotification"
#define kMobileNumLoginSucceedNotification                  @"kMobileNumLoginSucceedNotification"
#define kViewTapedNotification                              @"kViewTapedNotification"

#define kVideoWillStartDownloadIn2G3GNotification           (@"kVideoWillStartDownloadIn2G3GNotification")
#define kVideosViewControllerWillAppearNotification         (@"kVideosViewControllerWillAppearNotification")

#define kSupportVideoDownloadValueChangedNotification       (@"kSupportVideoDownloadValueChangedNotification")

//V5.1收藏、举报弹出登录浮层，登录成功通知
#define kNewsCollectReportNotification                      (@"kNewsCollectReportNotification")
//设置中字号设定通知
#define kArticleFontSizeSetNotification                     (@"kArticleFontSizeSetNotification")
#define kSaveChannelsToCacheNotification                    (@"kSaveChannelsToCacheNotification")
#define kHideChannelManageViewNotification                  (@"kHideChannelManageViewNotification")
//by wangchuanwen 2016-09-18
#define LOCALNOTIFICATION                                   @"LocalNotification"
#define kEnterSelfCenterNotification                        @"kEnterSelfCenterNotification"

//notification
#define kNotifyDidReceive                                   (@"receiveRemoteNotify")
#define kNotifyExpressShow                                  (@"expressShowNotify")
#define kNotifyGuideFinish                                  (@"guideFinished")
#define kNotifyDidHandled                                   (@"kNotifyDidHandled")
#define kShouldAutorotateToInterfaceOrientationNotification (@"shouldAutorotateToInterfaceOrientationNotification")
#define kAddDownloadItemsNotification                       (@"kAddDownloadItemsNotification")

#define kRollingNewsTrainViewPositionChangedNotification (@"kRollingNewsTrainViewPositionChangedNotification")

#define kRollingChannelChangedNotification                  (@"kRollingChannelChangedNotification")
#define kPhotoChannelChangedNotification                    (@"kPhotoChannelChangedNotification")
#define kWeiboHotChannelChangedNotification                 (@"kWeiboHotChannelChangedNotification")
#define kWebViewHtmlEmptyNotification                       (@"kWebViewHtmlEmptyNotification")
#define kHasNewFeedBackOrVersin                             (@"newFeedbackorVersion")
#define kRefeshLocalChannelListNotification                 (@"kRefeshLocalChannelListNotification")
#define kRollingChannelUpdateLocalNotification              (@"kRollingChannelUpdateLocalNotification")
#define kRollingHouseChannelUpdateLocalNotification         (@"kRollingHouseChannelUpdateLocalNotification")
#define kChannelUpdateLocalNotChangeNotification            (@"kChannelUpdateLocalNotChangeNotification")
#define kRollingChannelReloadNotification                   (@"kRollingChannelReloadNotification")

#define kSubscribeCenterMySubDidChangedNotify               (@"kSubscribeCenterMySubDidChangedNotify")
#define kSubscribeObjectStatusChangedNotification           (@"kSubscribeObjectStatusChangedNotification")

#define kStatusBarMessageDidTappedNotification              (@"kStatusBarMessageDidTappedNotification")
#define kLoadFinishDynamicPreferencesNotification           (@"kLoadFinishDynamicPreferencesNotification")

#define kLoginAndBindViewDisappearNotification              (@"kLoginAndBindViewDisappearNotification")

//关闭分享弹出界面通知
#define kHideActionMenuViewNotification                     (@"kHideActionMenuViewNotification")
//关闭登陆提示浮层通知
#define kResignFirstResponder                               (@"kResignFirstResponder")

#define kAudioStartNotification                             (@"kAudioStartNotification")

#define kAudioShareSNotification                            (@"kAudioShareSNotification")

#define kSNVideoPlayerDidPlayNotification                   (@"kSNVideoPlayerDidPlayNotification")
#define kBannerVideoDidPlayNotification                     (@"kBannerVideoDidPlayNotification")
#define kSNClickAudioViewInLiveCellNotification             (@"kSNClickAudioViewInLiveCellNotification")
#define kSNShortVideoDidStopNotification                    (@"kSNShortVideoDidStopNotification")
#define kSNPlayerViewPauseVideoNotification                 (@"kSNPlayerViewPauseVideoNotification")
#define kSNPlayerViewStopVideoNotification                  (@"kSNPlayerViewStopVideoNotification")

#define kShowVoteOptionImgNotification                      (@"kShowVoteOptionImgNotification")
#define kShowVoteOptionImgNotificationVoteID                (@"kShowVoteOptionImgNotificationVoteID")
#define kShowVoteOptionImgNotificationVoteOptID             (@"kShowVoteOptionImgNotificationVoteOptID")

#define kUserCenterFollowUpdateNotification                 (@"kUserCenterFollowUpdateNotification")

#define kUserSSOLoginSuccessNotification                    (@"kUserSSOLoginSuccessNotification")


// 关闭广告通知
#define kCloseNewsADNotify                                  (@"kCloseNewsADNotify")
#define kClosePhotoADNotify                                 (@"kClosePhotoADNotify")

//引导登陆
#define kGuideRegisterSuccessNotification                   (@"kGuideRegisterSuccessNotification")
#define KGuideRegisterBackNotification                      (@"KGuideRegisterBackNotification")

//搜索
#define kSearchKeyWordNotification                          (@"kSearchKeyWordNotification")
#define kSearchSetKeyWordNotification                       (@"kSearchSetKeyWordNotification")
#define kSearchClearHistoryNotification                     (@"kSearchClearHistoryNotification")
#define kSearchAddSubscribeNotification                     (@"kSearchAddSubscribeNotification")
#define kSearchCloseKeyboardNotification                    (@"kSearchCloseKeyboardNotification")
#define kCloseKeyboardNotification                          @"kCloseKeyboard"

//首页推荐流返回
#define kRecommendToEidtModeNotification (@"kRecommendToEidtModeNotification")
//流式频道刷新
#define kToastRefreshNotification                           @"toastRefreshNotification"

#define kRefreshHomePageNotification                        @"refreshHomePageNotification"

#define kStopPageTimerNotification                          @"stopPageTimerNotification"
#define kShowFirstPageNotification                          @"showFirstPageNotification"
#define kJoinRedPacketsStateChanged                         @"com.sohu.newssdk.action.joinRedPacketsStateChanged"

#define kShowRedPacketThemeNotification                     @"kShowRedPacketThemeNotification"
#define kShowRedPacketTheme                                 @"kShowRedPacketTheme"
#define kShowRedPacketButtonNotification                     @"kShowRedPacketButtonNotification"
#define kReceiveRedPacketSucceedNotification @"kReceiveRedPacketSucceedNotification"

#define kRefreshAdsNotification                             (@"kRefreshAdsNotification")

#define kSNNewMessageNotification                           (@"SNNewMessageNotification")
#define kSNReadMessageNotification                          (@"SNReadMessageNotification")
#define kSNSocialMessageNotification                        (@"SNSocialMessageNotificaon")
#define kSNBubbleBadgeChangeNotification                    (@"kSNBubbleBadgeChangeNotification")

#define kSNAddHotVideoNotification                          (@"kSNAddHotViewNotification")
#define kSNLiveInviteNotification                           (@"kSNLiveInviteNotification")
#define kSNJoinActionNotification                           (@"kSNJoinActionNotification")

//#define kDeleteCorpusConfirmNotification                    @"kDeleteCorpusConfirmNotification"
//#define kDeleteCorpusClickNotification                      @"kDeleteCorpusClickNotification"
//#define kCorpusUpdateNameNotification                       @"kCorpusUpdateNameNotification"
//#define kClickCorpusNewsItemNotification                    @"kClickCorpusNewsItemNotification"
//#define kCreatCopusFromListNotification                     @"kCreatCopusFromListNotification"
//#define kFinishedManageCorpusNotification                   @"kFinishedManageCorpusNotification"
#define kOpenNewsFromWidgetNotification                     @"kOpenNewsFromWidgetNotification"
#define kOpenClientFrom3DTouchNotification                  @"kOpenClientFrom3DTouchNotification"
//#define kChangeCorpusNameNotification                       @"kChangeCorpusNameNotification"

//#define kClickSmallCorpusCellNotification                   @"kClickSmallCorpusCellNotification"
#define kMoveCorpusItemNotification                         @"kMoveCorpusItemNotification"

#define kUpdateBubbleStatusNotification                     @"kUpdateBubbleStatusNotification"
//
//v5.3.2
#define kCheckMobileNumResultNotification                   @"kCheckMobileNumResultNotification"

#define kLoginFromArticleCommentNotification                @"kLoginFromArticleCommentNotification"
#define kLoginFromArticleReplayCommentNotification          @"kLoginFromArticleReplayCommentNotification"

#define kPushOpenNewsFlashNotification                      @"kPushOpenNewsFlashNotification"
#define kFromPushOpenShareFloatViewNotification             @"kFromPushOpenShareFloatViewNotification"

#define kAppBecomeActivityNotification                      @"kAppBecomeActivityNotification"
#define kSNRollingNewsViewControllerInitContentNotification                      @"kSNRollingNewsViewControllerInitContentNotification"
#define kSNFullscreenModeFinishedNotification               @"kSNFullscreenModeFinishedNotification"
//#define kSNFullscreenModeStartNotification                  @"kSNFullscreenModeStartNotification"

#define kSNPhotoSlideshowRecommendAd                        @"kSNPhotoSlideshowRecommendAd"

//视频
#define kPrintSHMoviePlayerCurrentViewInfo                  @"kPrintSHMoviePlayerCurrentViewInfo"

#define kShareAction                                        (@"share")

//timeline
#pragma mark - notification
#define kTLTrendSendCommentSucNotification                  (@"trendSendCommentSuc")
#define kTLTrendSendApprovalSucNotification                 (@"trendSendApprovalSuc")
#define kTLTrendSendApprovalFailNotification                (@"trendSentApprovalFail")
#define kTLTrendCellDeleteNotification                      (@"trendCellDelete")

//登陆
#define kUserDidLoginNotification1                          @"kUserDidLoginNotification1"
#define kBackToMySdkNotification                            @"backToMySdk"
#define kUserLoginSplashShouldDismissNotification           @"kUserLoginSplashShouldDismiss"
#define kLoginMsgFromShareToSNSNotification                 @"kLoginMsgFromShareToSNS"

//SNASIRequest
#define kSNSamplingFrequencyNotification                    @"kSNSamplingFrequencyNotification"

//audio helper
#define kUnunpluggingHeadsetNotification                    @"ununpluggingHeadset"
#define kPluggInMicrophoneNotification                      @"pluggInMicrophone"
#define kLostMicroPhoneNotification                         @"lostMicroPhone"

//SNChannelManagerView
#define kProcessChannelFromSearchNotification               @"processChannelFromSearchNotification"

//SNCheckManager
#define kUnReadCountIsShowNotification                      @"unReadCountIsShow"
#define kUnReadFbReplyNotification                          @"unReadFbReply"
#define kRegistGoSuccess                                    (@"kRegistGoSuccess")

//SNCloudSave
#define kRefreshChannelsNowNotification                     @"refreshchannelsnow"
#define kRefreshCategoriesNowNotification                   @"refreshcategoriesnow"

//SNDownload
#define kDoSuspendNowNotification                           @"doSuspendNow"
#define kDoResumeNowNotification                            @"doResumeNow"

//SNSlidePicture
#define kSliderShowViewClosedNotification                   @"kSliderShowViewClosed"

//SNHalf
#define kChannelManagerViewCloseNotification                @"kChannelManagerViewCloseNotification"

//SNLiveRoom
#define kLiveSubscribeChangedNotification                   @"liveSubscribeChanged"

//SNS
#define kMySDKviewWillAppearNotification                    @"MySDKviewWillAppear"

//SNNavigationController
#define kPushViewControllerNotification                     (@"kPushViewControllerNotification")
#define kPullDownADViewInitNotification                     (@"kPullDownADViewInitNotification")
#define kNewslistDidEndDragingNotification                  (@"kNewslistDidEndDraging")
#define kPopViewControllerNotification                      (@"SNNavigationDidPopAViewController")
#define kStopAudioNotification                              @"stopAudio"

//new me
#define kUnActiveTipsClearNotification                      @"unActiveTipsClear"

//news speaker
#define kPalyNextNewsNotification                           @"kPalyNextNewsNotificationCenter"

//stock
#define kRefreshStockDetailButtonNotification               @"kRefreshStockDetailButton"
#define kRefreshFreeStockTableNotification                  @"kRefreshFreeStockTable"

//subscribe
#define kUnreadClearNotification                            @"unreadClear"

//userinfo
#define kNotifyGetUserinfoSuccess                           @"kNotifyGetUserinfoSuccess"

#define kVideoChannelDidFinishLoadNotification              (@"kVideoChannelDidFinishLoadNotification")
#define kVideoChannelDidFinishLoadCategoriesNotification    (@"kVideoChannelDidFinishLoadCategoriesNotification")
#define kVideoChannelDidStartLoadCategoriesNotification     (@"kVideoChannelDidStartLoadCategoriesNotification")
#define kVideoChannelDidFinishLoadMoreCategoriesNotification (@"kVideoChannelDidFinishLoadMoreCategoriesNotification")
#define kSNVideoChannelManageViewDidSelectManageNotify      (@"kSNVideoChannelManageViewDidSelectManageNotify")

#define kSNVideoDetailDidFinishLoadNotification             (@"kSNVideoDetailDidFinishLoadNotification")
#define kSNVideoDetailShareContentDidFinishLoadNotification (@"kSNVideoDetailShareContentDidFinishLoadNotification")

//lijian 2015.1.1 增加视频广告的模板的全屏欣赏和不感兴趣通知
#define kSNVideoFullScreenMode                              (@"kSNVideoFullScreenMode")

// notify
#define kSNVideoDetialRecommendModelDidFinishLoadNotification                       (@"kSNVideoDetialRecommendModelDidFinishLoadNotification")
#define kCleanTipOfFinishingDownloadANewVideoNotification            (@"kCleanTipOfFinishingDownloadANewVideoNotification")

#define kTipsViewRefreshNotification                        (@"kTipsViewRefreshNotification")
#define kWeatherDidChangeNotify                             (@"kWeatherDidChangeNotify")
#define kWeatherCitiesDidChangeNotify                       (@"kWeatherCitiesDidChangeNotify")
#define kWeatherWillOpenNotify                              (@"kWeatherWillOpenNotify")
//UIWebView+utility
#define kSNWebViewProgressDidChangedNotification            (@"kSNWebViewProgressDidChangedNotification")
#define kSNWebViewCurrentProgressValueKey                   (@"kSNWebViewCurrentProgressValueKey")

#define kChannelManageBeginEditNotification                 (@"kChannelManageBeginEditNotification")
#define kChannelManageFinishEditNotification                (@"kChannelManageFinishEditNotification")
#define kChannelManageDidBeginEditModeNotification          (@"kChannelManageDidBeginEditModeNotification")

#define SNCLMoreCellStateChanged                            @"SNCLMoreCellStateChanged"
#define SNCLMoreCellHiddin                                  @"SNCLMoreCellHiddin"
#define SNCECheckIconDidPressed                             @"SNCECheckIconDidPressed"

#define NotificationCommentShareLoginFinished               @"commentShareLoginFinished"

#define NotificationAudioSend                               @"audioSendFinishedNotification"
#define NotificationCommentCache                            @"commentCacheMangerSave"
#define NotificationCommentCacheClean                       @"commentCacheClean"
#define NotificationCommentListMenu                         @"CommentListMenu"
#define NotificationCommentListHotCommentFinishend          @"hotCommentFinishend"
#define NotificationCommentListEmpty                        @"showEmptyCommentList"
#define NotificationCommentEditorPop                        @"NotificationCommentEditorPop"

#define NotificationCommentDispShaFa                        @"NotificationCommentDispShaFa"
#define kCommentSoundPlayStatusChanged                      @"kCommentSoundPlayStatusChanged"

#define kNetworkDidChangedNotify                            @"kNetworkDidChangedNotify" //无网络通知
#define kWebImgDownloaded                                   @"kWebImgDownloaded"
#define kSoundDownloaded                                    @"kSoundDownloaded"
#define kSoundPlayFinished                                  @"kSoundPlayFinished"
#define kSoundPlayStatusChanged                             @"kSoundPlayStatusChanged"

#define kCommentSoundDownloaded                             @"kCommentSoundDownloaded"
#define kCommentSoundPlayFinished                           @"kCommentSoundPlayFinished"
//从首页搜索打开的正文，点击左上角搜狐logo（返回首页流）时，关闭搜索页
#define kSearchWebViewCancle                                (@"kSearchWebViewCancle")
#define k3DTouchHomeKeyBoardClose                           (@"k3DTouchHomeKeyBoardClose")//从3DTouch首页搜索取消
#define kIs3DTouchShowKeyboard                              (@"kIs3DTouchShowKeyboard")  //从3DTouch启动搜索页面时，loading页消失时通知显示键盘

#define kReloadCorpus                                       @"kReloadCorpus"
#define kCorpusVideoPlay                                    @"kCorpusVideoPlay"
#define kVideoAutoPlay                                      @"kVideoAutoPlay"

#define kSNLiveBannerViewStopVideoNotification              (@"kSNLiveBannerViewStopVideoNotification")
#define kSNLiveBannerViewPauseVideoNotification             (@"kSNLiveBannerViewPauseVideoNotification")
#define kSNLiveBannerViewResumeVideoNotification            (@"kSNLiveBannerViewResumeVideoNotification")

#define kNetDiagnosisDidEnd                                 @"com.sohu.newssdk.action.setting.feedBackNetDiagnosisDidEnd"
#define kSNCommonWebViewControllerDidCloseNotification      (@"kSNCommonWebViewControllerDidCloseNotification")
#define kPostCommentSuccessNotifiaction                     @"postCommentSuccess"

// for tips 点击统计
#define kSNRefreshMessageViewDidTapTipsNotification         (@"kSNRefreshMessageViewDidTapTipsNotification")
#define kSNRefreshMessageViewDidTapTipsToLoginNotification      (@"kSNRefreshMessageViewDidTapTipsToLoginNotification")

#define kShareItemEnableChangedNotification                 @"shareItemEnabelChangedNotification"
#define kSharelistDidChangedNotification                    (@"kSharelistDidChangedNotification")
#define kShareUnbundlingSelectNotification                  (@"kShareUnbundlingSelectNotification")
#define kSinaBindStatus                                     (@"kSinaBindStatus")
#define kShareListLastRefreshTimeKey                        (@"kShareListLastRefreshTimeKey")
#define kSSOLoginDidCancelOrFailNotification                (@"kSSOLoginDidCancelOrFailNotification")
#define kPlayTrafficContenComplete                          @"kPlayTrafficContenComplete"

#define kThereIsNoVideoNeededToDownloadNotification         (@"kThereIsNoVideoNeededToDownloadNotification")
#define kVideoDownloadManagerIsRunningNotification          (@"kVideoDownloadManagerIsRunningNotification")

#define kDidAddANewsDownloadItemNotification                (@"kDidAddANewsDownloadItemNotification")
#define kDidStartDownloadingVideoNotification               (@"kDidStartDownloadingVideoNotification")
#define kDidFailedToDownloadAVideoNotification              (@"kDidFailedToDownloadAVideoNotification")
#define kDidSucceedToDownloadAVideoNotification             (@"kDidSucceedToDownloadAVideoNotification")
#define kDidFinishedToDownloadAllVideosNotification         (@"kDidFinishedToDownloadAllVideosNotification")
#define kVideoDownloadingProgressNotification               (@"kVideoDownloadingProgressNotification")
#define kRefreshFileSystemSizeBarNotification               (@"kRefreshFileSystemSizeBarNotification")
#define kResetTopNotification (@"kResetTopNotification")

//首页频道流自动跳到下一个频道页面
#define SNROLLINGNEWS_PUSHTONEXTCHANNEL                     @"SNROLLINGNEWS_PUSHTONEXTCHANNEL"
#define SHROLLINGNEWS_PUSHTORECOMCHANNEL                    @"SHROLLINGNEWS_PUSHTORECOMCHANNEL"//跳转到推荐频道

//隐藏要闻改版同步List.go的动画
#define SNROLLINGNEWS_HIDEANIMATIONLOADING @"SNROLLINGNEWS_HIDEANIMATIONLOADING"

#define GallerySliderPicturesNotification (@"gallerySliderPicturesNotification")//大图超出屏幕，能够上下滑退出图集适用
#define NovelPushSwtichNotification (@"NovelPushSwtichNotification")//小说总开关通知
#define NovelAutoPurchaseStatusDidChangedNotification (@"NovelAutoPurchaseStatusDidChangedNotification")//小说总开关通知

#define kNovelDidAddBookShelfNotification                 @"kNovelDidAddBookShelfNotification"


#define kSNNovelCoinBalanceRefreshSuccessedNotification     @"kSNNovelCoinBalanceRefreshSuccessedNotification"

static NSString *SNToastNotificaionRollingCellUninterested = @"toastUninterested";
static NSString *kSNVideoAdMaskShowVideoAdDetailNotification = @"kSNVideoAdMaskShowVideoAdDetailNotification";
static NSString *kSNVideoAdMaskEnterOrExitFullscreenNotification = @"kSNVideoAdMaskEnterOrExitFullscreenNotification";

//设置大视频已读
static NSString *kSNRollingNewViewCellReadNotification = @"kSNRollingNewViewCellReadNotification";
#endif /* SNNotificationKeys_h */
