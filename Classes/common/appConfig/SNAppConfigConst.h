//
//  SNAppConfigConst.h
//  sohunews
//
//  Created by handy wang on 5/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//
// wiki http://10.13.80.133/wiki/pages/viewpage.action?pageId=7471405

#import <Foundation/Foundation.h>

static NSString *const kSNAppConfigJSONFileName = @"snappconfig.json";
static NSString *const kVideoAdConfigGroup = @"kVideoAdConfigGroup";
static NSString *const keyIsGuideInterestShow = @"smc.client.guide.interest.isShow";
static NSString *const keyActivityOn = @"smc.client.activity.isOpen";
static NSString *const keyAppInterestShow = @"smc.client.appDownLoad.interest.isOpen";
static NSString *const kPopupActivity = @"smc.client.activityframe.openInfo";
static NSString *const kSougouButtonShow = @"smc.client.search.sougou";
static NSString *const kRedoRegisterClient = @"smc.client.regist.redo";
static NSString *const kRequestMonitorConditions = @"smc.client.req_xxx";
static NSString *const kNewsPullBgImage = @"smc.client.pullRefreshPromotion.isOpen";
static NSString *const kPullAdSwitch = @"smc.client.channel.pullAd.switch";
static NSString *const kLoadingMySplashSwitch = @"smc.client.loading.usercustom.switch";
static NSString *const kReshowSplashInterval = @"smc.client.loading.reShowAd.interval";
static NSString *const kLoadingMiniLink = @"smc.client.loading.miniLink";
static NSString *const kCameraPhotoConfig = @"smc.client.camera.photo.config";
static NSString *const kPullNewsTips = @"smc.client.channel.pullNews.tips";
static NSString *const kLocalChannelUpdateOn = @"smc.client.locationChangeConfirm.isOpen";
static NSString *const kCheckPushPeriod = @"smc.client.push.checkPeriod";
static NSString *const kFloatingLayer = @"smc.client.floatingLayer";
static NSString *const kShareAlipayOption = @"smc.client.share.alipay.option";
static NSString *const kRedpackSwitch = @"smc.client.activity.redpack.switch";
static NSString *const kPullNewsRedPacketTips = @"smc.client.channel.pullNews.redPacketTips";
static NSString *const kRedPacketSlideNum = @"smc.client.RedPacket.slideNum";
static NSString *const kChannelVideoConfig = @"smc.client.channel.video.config";
static NSString *const kBottomTabBarConfig = @"smc.client.bottomTab.config";
static NSString *const kMytabCouponTicketUrl = @"smc.client.mytab.coupon.ticket.url";
static NSString *const kHomePageTimeCtrl = @"smc.client.channel.homePage.timeCtl";
static NSString *const kHttpsSwitchStatus = @"smc.client.https.switch";
static NSString *const kHttpsSwitchStatusAll = @"smc.client.https.all.switch";
static NSString *const kClientLoadingTimeOut = @"smc.client.loading.timeout";
static NSString *const kActivityJingDong = @"smc.client.activity.jd201611";
static NSString *const kH5RedPacket = @"smc.client.activity.redpack.h5";
static NSString *const kABTestAppStlye = @"smc.client.abtest.mode";
static NSString *const kAppSchemeList = @"smc.client.alltypeList";
static NSString *const kH5ArticleRedPacketInfo = @"smc.client.floatingLayer.article";
static NSString *const kH5ArticleShowRedPacket = @"smc.client.floatingLayer.article.show";
static NSString *const kMPSubscribeUrl = @"smc.client.mp.subscribe.url";

static NSString *const kNonstandardShareAD = @"smc.client.share.nonstandard.resource.switch";
static NSString *const kNonstandardSearchAD = @"smc.client.search.nonstandard.resource.switch";

static NSString *const kNonstandardShareADResource = @"smc.client.share.nonstandard.resource.list";
static NSString *const kNonstandardSearchADResource = @"smc.client.search.nonstandard.resource.list";


//第二次进入客户端的默认频道
static NSString *const kNewsDefaultEnterChannelID = @"smc.client.secondStart.channelId";
//阅读历史保留量
static NSString *const kNewsSaveDays = @"smc.client.history.saveDays";
//上拉刷新多少次出历史记录
static NSString *const kNewsPullTimes = @"smc.client.history.pullTimes";

//沉浸式焦点图皮肤
static NSString *const kNewsTheme = @"smc.client.focus.theme";
////来源字背景色透明度
static NSString *const kNewsThemeSourceWordBgColourTransparency = @"sourceWordBgColourTransparency";
//来源字背景色透明度
static NSString *const kNewsThemeGradientBgTransparency = @"gradientBgTransparency";
//分割线颜色透明度
static NSString *const kNewsThemeSplitLineTransparency = @"splitLineTransparency";
//文本新闻区域原点透明度
static NSString *const kNewsThemeNewsRegionImageTransparency = @"newsRegionImageTransparency";
//白色模版底部分割线透明度
static NSString *const kNewsThemeBottomSplitLineTransparency = @"bottomSplitLineTransparency";

//文本新闻字色
static NSString *const kNewsThemeWordColour = @"newsWordColour";
//文本新闻背景色
static NSString *const kNewsThemeNewsBgColour = @"newsBgColour";
//来源字色
static NSString *const kNewsThemeSourceWordColour = @"sourceWordColour";
//来源字背景色
static NSString *const kNewsThemeSourceWordBgColour = @"sourceWordBgColour";
//评论字色
static NSString *const kNewsThemeCommentWordColour = @"commentWordColour";
//文本新闻区域原点
static NSString *const kNewsThemeNewsRegionImage = @"newsRegionImage";
//渐变背景色
static NSString *const kNewsThemeGradientBgColour = @"gradientBgColour";
//分割线背景色
static NSString *const kNewsThemeSplitLineColor = @"splitLineColor";
//字体点击效果
static NSString *const kNewsThemeWordClickedColour = @"newsWordClickedColour";

//夜间
//文本新闻字色
static NSString *const kNightNewsThemeWordColour = @"night_newsWordColour";
//文本新闻背景色
static NSString *const kNightNewsThemeNewsBgColour = @"night_newsBgColour";
//来源字色
static NSString *const kNightNewsThemeSourceWordColour = @"night_sourceWordColour";
//来源字背景色
static NSString *const kNightNewsThemeSourceWordBgColour = @"night_sourceWordBgColour";
//评论字色
static NSString *const kNightNewsThemeCommentWordColour = @"night_commentWordColour";
//文本新闻区域原点
static NSString *const kNightNewsThemeNewsRegionImage = @"night_newsRegionImage";
//渐变背景色
static NSString *const kNightNewsThemeGradientBgColour = @"night_gradientBgColour";
//分割线背景色
static NSString *const kNightNewsThemeSplitLineColor = @"night_splitLineColor";
//夜间字体点击效果
static NSString *const kNightNewsThemeWordClickedColour = @"night_newsWordClickedColour";

static NSString *const kLoadingSCSwitch                 = @"smc.client.adXps.version.switch";

//北研SDK是否使用开关, 默认关闭
static NSString *const kCompassSDKSwitch = @"smc.client.buried.sdk";

typedef enum {
    SNAppConfigServiceErrorCode_EmptyResponseString = 2000,
    SNAppConfigServiceErrorCode_FailedToSaveConfigFile
} SNAppConfigServiceErrorCode;
