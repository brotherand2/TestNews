//
//  SNNavigatorMap.m
//  sohunews
//
//  Created by Dan Cong on 2/7/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNNavigatorMap.h"

#import "SNFollowingViewController.h"
#import "SNFollowedViewController.h"
#import "SNReadCircleDetailViewController.h"
#import "SNQRViewController.h"

#import "SNSettingViewController.h"
#import "SNH5WebController.h"
#import "SNNewsPaperWebController.h"
#import "SNHistoryController.h"

#import "SNDownloadViewController.h"
#import "SNLiveRoomViewController.h"
#import "SNRollingNewsViewController.h"
#import "SNPushSettingController.h"
#import "SNNovelPushSettingController.h"
#import "SNShareSettingController.h"
#import "SNNewsListViewController.h"
#import "SNPhotosListViewController.h"
#import "SNLiveStatisticTableViewController.h"
#import "SNDownloadingExViewController.h"
#import "SNCommentEditorViewController.h"
#import "SNPhotosTableController.h"
#import "SNWordSettingController.h"
#import "SNTagPhotoTableViewController.h"
#import "SNMoreAppController.h"

#import "SNLoginRegisterViewController.h"
#import "SNOauthWebViewController.h"
#import "SNSubCenterAllListViewController.h"
#import "SNSubShakingCenterViewController.h"
#import "SNSubCenterPostCommentController.h"
#import "SNDownloadSettingViewController.h"
#import "SNStatementViewController.h"
#import "SNWeatherMainController.h"
#import "SNWeatherCitiesManageController.h"
#import "SNWeatherCityAddController.h"
#import "SNUserPortraitIntroViewController.h"
#import "SNUserPortraitSexSetViewController.h"
#import "SNPhotoGalleryPlainSlideshowController.h"
#import "SNAboutController.h"
#import "SNUserCenterViewController.h"
#import "SNTimelineLoginViewController.h"
#import "SNCircleCommentEditorController.h"
#import "SNSubCenterQRInfoViewController.h"
#import "SNGuideRegisterViewController.h"
#import "SNVideoDownloadViewController.h"
#import "SNVideoDetailViewController.h"
#import "SNVideoChannelManageViewController.h"
#import "SNChatFeedbackController.h"
#import "SNMessageCenterViewController.h"
#import "SNLocalChannelListViewController.h"
#import "SNSelfCenterViewController.h"
#import "SNSoHuAccountLoginRegisterViewController.h"
#import "SNBindMobileNumViewController.h"
#import "SNSearchWebViewController.h"

#import "SNNewsLoginViewController.h"//login
#import "SNNewsBindViewController.h"//bind
#import "SNNewsSohuLoginViewController.h"//sohulogin

#import "SNSubscribeWebController.h"
#import "SNLiveMoreViewController.h"
#import "SNCreatCorpusViewController.h"
#import "SNMyCorpusViewController.h"
#import "SNCorpusNewsViewController.h"
#import "SNNormalWebViewController.h"
#import "SNJSKitWebViewController.h"
#import "SNADWebViewController.h"
#import "SNRedPacketDetailViewController.h"
#import "SNStoryWebViewController.h"
#import "SNFavoriteViewController.h"

//cll add
#import <SVVideoForNews/SVVideoForNews.h>
#import "SHH5NewsWebViewController.h"
#import "SNNewMeViewController.h"

#import "SNMyConcernViewController.h"
#import "SNSohuHaoViewController.h"

#import "SNQuickFeedbackViewController.h"
#import "SohuARGameController.h"

#import "SNRechargeHelpViewController.h"
#import "SNTransactionHistoryViewController.h"
#import "SNVoucherCenterViewController.h"
#import "SNCommonNewsController.h"
#import "SNADFullScreenController.h"

#import "SNNewsLoginHalfViewController.h"

@implementation SNNavigatorMap

+ (void)mapTabBarAndTabItemControllers {
    TTURLMap* map = [TTNavigator navigator].URLMap;
	[map from:@"tt://tabBar" toSharedViewController:[SNTabBarController class]];
    [map from:@"tt://rollingNews" toSharedViewController:[SNRollingNewsViewController class]];
    [map from:@"tt://videos" toSharedViewController:[SVChannelsViewController class]];
    [map from:@"tt://more" toSharedViewController:NSClassFromString(@"SNSPlaygroundViewController")];
    [map from:@"tt://newMe" toViewController:[SNNewMeViewController class]];
}

+ (void)mapBusinessViewControllers {
    TTURLMap* map = [TTNavigator navigator].URLMap;
    //    [map from:@"tt://videos" toSharedViewController:[SNVideosViewController class]];
	[map from:@"tt://setting" toViewController:[SNSettingViewController class]];
//	[map from:@"tt://m_comWebBrowser" toModalViewController:[SNWebController class]];
    [map from:@"tt://simpleWebBrowser" toViewController:[SNWebController class]];
	[map from:@"tt://h5WebBrowser" toViewController:[SNH5WebController class]];
    [map from:@"tt://subscribeWebBrowser" toViewController:[SNSubscribeWebController class]];
    [map from:@"tt://scanQRCode" toViewController:[SNQRViewController class]];
    [map from:@"tt://h5NewsWebView" toViewController:[SHH5NewsWebViewController class]];
    //---刊首H5框改版前
    /**
     * 期刊 paper/term.go
     * 流刊 paper/term.go
     * 视频 videoMedia.go|videoPerson.go
     * 政企 vm/orgHome.go|vm/orgColumn.go
     * 新闻频道 channel/news.go
     * 直播频道 live/subscribeLive.go
     * 微闻频道 weibo/list.go
     * 组图频道 photos/list.go
     */
//    //期刊paper://和流刊dataFlow://，h5代码实现
//	  [map from:@"tt://paperBrowser" toViewController:[SNNewsPaperWebController class]];
//
//    //直播liveChannel://，native代码实现
//    [map from:@"tt://livesChannel" toViewController:[SNLiveListViewController class]];
//    
//    //新闻频道newsChannel://和微闻weiboChannel://，native代码实现
//    [map from:@"tt://newsChannel" toViewController:[SNNewsListViewController class]];
//    
//    //机构自媒体videoMedia://和个人自媒体videoPerson://，h5代码实现
//    [map from:@"tt://videoMedia" toViewController:[SNVideoMediaBaseViewController class]];
//    
//    //流式频道组图聚合型刊物groupPicChannel://，native代码实现
//    [map from:@"tt://photosChannel" toViewController:[SNPhotosListViewController class]];
//    
//    //政企首页(orgHome://)和政企内容页(orgColumn://)，h5代码实现
//    [map from:@"tt://orgHome" toViewController:[SNOrgHomeViewController class]];
//    [map from:@"tt://orgColumn" toViewController:[SNOrgColumnViewController class]];
//
//    
//    //---支持刊首H5框改版后
//    /**
//     * 刊首H5框可以承载 期刊订阅H5、流刊订阅H5、视频自媒体订阅H5、政企订阅H5、新闻频道订阅H5，统一通过subHome.go接口请求H5内容
//     * 刊首H5框架需请求subDetail.go和subHome.go两个接口
//     */
//    [map from:@"tt://orgColumn" toViewController:[SNOrgColumnViewController class]];
    //------------------------------------------------------------------------------
    
    [map from:@"tt://wangqi" toViewController:[SNHistoryController class]];
//    [map from:@"tt://wangqi/(initWithType:)" toViewController:[SNHistoryController class]];
	
//	[map from:@"tt://newsContent" toViewController:[SNNewsContentController class]];
    
//    [map from:@"tt://h5newsWeb" toViewController:[SNH5NewsWebViewController class]];
    
    [map from:@"tt://liveStatistic" toViewController:[SNLiveStatisticTableViewController class]];
    
//    [map from:@"tt://wordSetting" toViewController:[SNWordSettingController  class]];
    
//    [map from:@"tt://tagPhotos" toViewController:[SNPhotosTableController class]];
    
    [map from:SUBSCRIBE_CENTER_URL_ACTION toViewController:[SNSubCenterAllListViewController class]];
    
    [map from:@"tt://subCommentPost" toModalViewController:[SNSubCenterPostCommentController class]];
    
    [map from:@"tt://weather" toViewController:[SNWeatherMainController class]];
    [map from:@"tt://weatherCities" toViewController:[SNWeatherCitiesManageController class]];
    [map from:@"tt://weatherCityAdd" toViewController:[SNWeatherCityAddController class]];
    
	[map from:@"tt://pushSeting" toViewController:[SNPushSettingController class]];
    [map from:@"tt://novelPushSeting" toViewController:[SNNovelPushSettingController class]];
	[map from:@"tt://shareSetting" toViewController:[SNShareSettingController class]];
    
	[map from:@"tt://m_about" toViewController:[SNAboutController class]];
    [map from:@"tt://m_statement" toViewController:[SNStatementViewController class]];
    [map from:@"tt://m_moreApp" toViewController:[SNMoreAppController class]];
    
    [map from:@"tt://photoSlideshow" toViewController:[SNPhotoGalleryPlainSlideshowController class]];
    [map from:@"tt://globalDownloader" toViewController:[SNDownloadViewController class]];
    [map from:@"tt://globalDownloading" toViewController:[SNDownloadingExViewController class]];
    [map from:@"tt://live" toViewController:[SNLiveRoomViewController class]];
    
    //userinfo
    //wangshun login
    [map from:@"tt://loginRegister" toViewController:[SNLoginRegisterViewController class]];
    [map from:@"tt://login" toViewController:[SNNewsLoginViewController class]];
    [map from:@"tt://bind" toViewController:[SNNewsBindViewController class]];
    [map from:@"tt://halflogin" toViewController:[SNNewsLoginHalfViewController class]];
    
    //搜狐账号登录注册
    [map from:@"tt://sohuAccountLoginRegister" toViewController:[SNSoHuAccountLoginRegisterViewController class]];
    //wangshun sohulogin
    [map from:@"tt://sohulogin" toViewController:[SNNewsSohuLoginViewController class]];
    //手机绑定/登录
    [map from:@"tt://mobileNumBindLogin" toViewController:[SNNewsBindViewController class]];
//    [map from:@"tt://mobileNumBindLogin" toViewController:[SNBindMobileNumViewController class]];
    
    //引导登陆，推荐新浪微博和QQ登录，点“其他”进tt://loginRegister
    [map from:@"tt://guideRegister" toViewController:[SNGuideRegisterViewController class]];
    
    //[map from:@"tt://userCenter" toViewController:[SNCircleUserCenterViewContronller class]];
    [map from:@"tt://userCenter" toViewController:[SNUserCenterViewController class]];
    [map from:@"tt://oauthWebView" toViewController:[SNOauthWebViewController class]];
    //shaking
    [map from:@"tt://shakingView" toViewController:[SNSubShakingCenterViewController class]];
    
    //离线下载设置
    [map from:@"tt://downloadSettingViewController" toViewController:[SNDownloadSettingViewController class]];
    
    //连续阅读
    [map from:@"tt://commonNewsController" toViewController:[SNCommonNewsController class]];
    
    //搜索
    [map from:@"tt://search" toViewController:[SNSearchWebViewController class]];
    
    //写评论
    [map from:@"tt://commentEditor" toViewController:[SNCommentEditorViewController class]];
    
    [map from:@"tt://myMessage" toViewController:[SNMessageCenterViewController class]];
    
    // timeline
    [map from:@"tt://timeline_login" toViewController:[SNTimelineLoginViewController class]];
    
    //阅读圈评论
    [map from:@"tt://readCircleDetail" toViewController:[SNReadCircleDetailViewController class]];
    
    // v3.5.1 刊物 媒体  二维码页面
    [map from:@"tt://subQRInfo" toViewController:[SNSubCenterQRInfoViewController class]];
    
    [map from:@"tt://modalCommentEditor" toModalViewController:[SNCommentEditorViewController class]];
    [map from:@"tt://modalCircleCommentEditor" toModalViewController:[SNCircleCommentEditorController class]];
    
    //视频
    [map from:@"tt://videoDownloadViewController" toViewController:[SNVideoDownloadViewController class]];
    [map from:@"tt://videoDetail" toViewController:[SNVideoDetailViewController class]];
    [map from:@"tt://videoChannelManage" toViewController:[SNVideoChannelManageViewController class]];
    
    [map from:@"tt://followingList" toViewController:[SNFollowingViewController class]];
    [map from:@"tt://followedList" toViewController:[SNFollowedViewController class]];
    
    //本地频道
    [map from:@"tt://localChannelList" toViewController:[SNLocalChannelListViewController class]];
    
    //指尖搜索
    [map from:@"tt://articleSearch" toViewController:[SNSearchWebViewController class]];
    
    //个人中心
    [map from:@"tt://selfCenter" toViewController:[SNSelfCenterViewController class]];
        
    // 直播列表更多
    [map from:@"tt://liveMore" toViewController:[SNLiveMoreViewController class]];
    
    //收藏主页面
    [map from:@"tt://homeCorpus" toViewController:[SNFavoriteViewController class]];
    //收藏夹管理页面
    [map from:@"tt://myCorpus" toViewController:[SNMyCorpusViewController class]];
    //收藏详情页
    [map from:@"tt://corpusList" toViewController:[SNCorpusNewsViewController class]];
    //新建收藏夹
    [map from:@"tt://creatCorpus" toViewController:[SNCreatCorpusViewController class]];
    
    //用户画像
    [map from:@"tt://userPortraitIntro" toViewController:[SNUserPortraitIntroViewController class]];
    [map from:@"tt://userPortraitSexSet" toViewController:[SNUserPortraitSexSetViewController class]];
    
    //通用webView模版
    [map from:@"tt://normalWebView" toViewController:[SNNormalWebViewController class]];//普通wenbiew
    [map from:@"tt://jsKitWebView" toViewController:[SNJSKitWebViewController class]];//JSKit相关webview
    [map from:@"tt://adWebView" toViewController:[SNADWebViewController class]];//广告wenbiew
    
    [map from:@"tt://adFullScreenWebView" toViewController:[SNADFullScreenController class]];//@qz 2017.8 全屏广告
    
    //红包详情页面
    [map from:@"tt://redPacketDetail" toViewController:[SNRedPacketDetailViewController class]];
    
    //京东AR
    [map from:@"tt://JDGameView" toViewController:[SohuARGameController class]];
    
    //我关注的搜狐公众号
    [map from:@"tt://myConcern" toViewController:[SNSohuHaoViewController class]];

    //意见反馈主界面
    [map from:@"tt://feedback" toViewController:[SNChatFeedbackController class]];
    //意见反馈输入页面
    [map from:@"tt://quickFeedBack" toViewController:[SNQuickFeedbackViewController class]];
    
    [map from:@"tt://storyWebView" toViewController:[SNStoryWebViewController class]];
    
    //小说支付
    [map from:@"tt://voucherCenter" toViewController:[SNVoucherCenterViewController class]];
    [map from:@"tt://transactionHistory" toViewController:[SNTransactionHistoryViewController class]];
    [map from:@"tt://rechargeHelp" toViewController:[SNRechargeHelpViewController class]];

}

@end
