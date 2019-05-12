//
//  SNHistoryLinks.h
//  sohunews
//
//  Created by Valar__Morghulis on 2017/3/1.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//  此类整理了历史版本遗留，未使用或已废弃接口

#ifndef SNHistoryLinks_h
#define SNHistoryLinks_h

#import "SNAPI.h"

#pragma mark - 直播
//#define kUrlLiveContentWithCursor           [SNAPI liveRootUrl:@"api/live/data.go?liveId=%@&rollingType=%@&contentId=%@&commentId=%@&type=%@&cursor=%d"]
//直播间-评论
//#define kUrlLiveContentComment              [SNAPI rootUrl:@"api/live/comment.go?liveId=%@&userName=%@&comment=%@"]
//#define kUrlLiveContentCommentReply         [SNAPI rootUrl:@"api/live/comment.go?liveId=%@&userName=%@&comment=%@&replyId=%@"]
//#define kUrlLiveComment                     [SNAPI rootUrl:@"api/live/comment.go"]

#pragma mark - 评论
//#define kUrlNewsComment						[SNAPI rootUrl:@"api/comment/save.go?newsId=%@&content=%@"]
//#define kUrlNewsCommentJson					[SNAPI rootUrl:@"api/comment/save.go?newsId=%@&content=%@&rt=json"]
//#define kUrlPhotoCommentJson				[SNAPI rootUrl:@"api/comment/save.go?gid=%@&content=%@&rt=json"]

//#define kUrlNewsCommentJsonV3				[SNAPI rootUrl:@"api/comment/savev3.go?newsId=%@&content=%@&author=%@&rt=json"]
//#define kUrlReplyNewsCommentJsonV3			[SNAPI rootUrl:@"api/comment/savev3.go?newsId=%@&content=%@&author=%@&commentId=%@&rt=json"]
//#define kUrlPhotoCommentJsonV3				[SNAPI rootUrl:@"api/comment/savev3.go?gid=%@&content=%@&author=%@&rt=json"]
//#define kUrlReplyPhotoCommentJsonV3			[SNAPI rootUrl:@"api/comment/savev3.go?gid=%@&content=%@&author=%@&commentId=%@&rt=json"]
//#define kUrlReplyCommentIdJsonV3			[SNAPI rootUrl:@"api/comment/savev3.go?content=%@&author=%@&commentId=%@&rt=json"]

//comment v4
//#define kUrlNewsCommentJsonV4				[SNAPI rootUrl:@"api/comment/savev4.go"]

//comment v5
//#define kV3UrlNewsCommentListByGid			[SNAPI rootUrl:@"api/comment/listv3.go?source=%@&gid=%@&type=%@&pageNo=%d&pageSize=%d"]

//#define kV3UrlNewsCommentListByNewsId		[SNAPI rootUrl:@"api/comment/listv3.go?source=%@&newsId=%@&type=%@&pageNo=%d&pageSize=%d"]
//#define kUrlNewsCommentList					[SNAPI rootUrl:@"api/comment/list.go?newsId=%@&num=%d&page=%@"]
//#define kUrlNewsCommentListJson				[SNAPI rootUrl:@"api/comment/list.go?newsId=%@&num=%d&page=%d&rt=json"]
//#define kUrlPhotoCommentListJson            [SNAPI rootUrl:@"api/comment/list.go?gid=%@&num=%d&page=%d&rt=json"]
//v3.0
//#define kUrlNewsCommentListByCursor         [SNAPI rootUrl:@"api/comment/getCommentListByCursor.go?busiCode=%@&id=%@&cursorId=%@&rollType=%d&size=%d&source=%@"]
//#define kUrlNewsHotCommentListByCursor      [SNAPI rootUrl:@"api/comment/getHotCommentListByCursor.go?busiCode=%@&id=%@&cursorId=%@&rollType=%d&size=%d&source=%@"]
//#define kUrlMyCommentListByUserId           [SNAPI rootUrl:@"api/comment/mylist.go?userId=%@&pageNo=%d&pageSize=%d"]

#pragma mark - 搜索
#define kArticleSearchUrl                   [SNAPI rootUrl:@"api/search/fingersearch.go"]

#pragma mark - 用户设置
//#define SNLinks_Path_User_Set               [SNAPI domain:SNLinks_Domain_BaseApiK url:@"api/user/set.go"]
//#define kUrlDeviceRegistFormat				[SNAPI rootUrl:@"api/user/regist.go?rt=json&jailbreak=%d"]
//#define kFontSettingUrl                     [SNAPI rootUrl:@"api/user/set.go?m=font"]//字体设置
////#define kPushMusicSettingUrl                [SNAPI rootUrl:@"api/user/set.go?m=pushMusic"]//保存音乐
//#define kNewsPushSettingUrl                 [SNAPI rootUrl:@"api/user/set.go?m=newsPush"]//保存用户newsPush选项
////#define kPaperPushSettingUrl                [SNAPI rootUrl:@"api/user/set.go?m=paperPush"]//保存用户paperPush选项
//#define kImageSettingUrl                    [SNAPI rootUrl:@"api/user/set.go?m=image"]//保存用户图片模式
//#define kVideoSettingUrl                    [SNAPI rootUrl:@"api/user/set.go?m=video"]//保存用户视频播放模式
//#define kDayModeSettingUrl                  [SNAPI rootUrl:@"api/user/set.go?m=dayMode"]//保存用户日夜间模式选项
//#define kSlideHideActionBarUrl              [SNAPI rootUrl:@"api/user/set.go?m=hide"]//保存用户滑动隐藏操作栏
//#define kNewsMiniVideoUrl                   [SNAPI rootUrl:@"api/user/set.go?m=videoMiniMode"]//保存用户小窗视频选项
//#define kLocationSet                        [SNAPI rootUrl:@"api/user/set.go?m=setUserLocation"] // 保存地理位置设置
//#define kHousePropLocationSet               [SNAPI rootUrl:@"api/user/set.go?m=setHousePropLocation"]

#pragma mark - 收藏
//#define kUrlCloudSave                       [SNAPI rootUrl:@"api/favorite/save.go"]       // 收藏
//#define kUrlCorpusRepeate                   [SNAPI rootUrl:@"api/corpus/repeate.go"]      // 判断收藏夹是否重名
//#define kUrlGetCorpusByFid                  [SNAPI rootUrl:@"api/corpusBind/getCorpusByFid.go"]//根据fid获取该收藏所在的收藏
//#define kUrlDeleteCorpusBatch               [SNAPI rootUrl:@"api/corpus/deleteBatch.go "]//批量删除

#pragma mark - 优惠券
//#define kSpecialWebURL                      [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/special/special.html?termId=%@&fontSize=%@"]
//#define kUrlMyTickets                       [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/couponList/couponList.html"]//我的优惠券html页

#pragma mark - 分享
//#define kShareLocalImageUrl                 [SNAPI rootUrl:@"api/share/uploadLocalImg.go?"] // 分享本地上传图片
//#define kShareWebImageUrl                   [SNAPI rootUrl:@"api/share/upload.go?"] // 分享图片链接

#pragma mark - 客户端配置
//#define kPreLoadCtl                         ([SNAPI rootUrl:@"api/client/preCtl.go?m=loadingPage"])
//#define kUrlLoadingPageImage                [SNAPI rootUrl:@"api/client/ctl.go?m=loadingPage&rt=json"]
//#define kUrlFormatFullscreenLoadingPage     [SNAPI rootUrl:@"api/client/v2/ctl.go?m=loadingPage&v=2&isFull=1&rt=json"]

#pragma mark - 推送
//#define kUrlMypush							[SNAPI rootUrl:@"api/push/myPush.go?rt=json"]  // 已经不使用 2017.1.14 liteng
//#define kSubCenterGetMyPushUrl              [SNAPI rootUrl:@"api/push/myPush.go?rt=json"]
//#define kSubCenterMyPushChangeUrl           [SNAPI rootUrl:@"api/push/change.go?rt=json"]          // 重复定义 2017.1.14
//#define kSubCenterMyPushSettingUrl          [SNAPI rootUrl:@"api/push/pushSetting.go?rt=json"]

#pragma mark - 新闻

#define kUrlNewsArticle						[SNAPI rootUrl:@"api/news/v4/article.go?rt=xml&newsId=%@&termId=%@&supportTV=1&imgTag=1&recommendNum=%d&showSdkAd=1"]
#define kUrlRollingNewsArticle				[SNAPI rootUrl:@"api/news/v4/article.go?rt=xml&newsId=%@&channelId=%@&supportTV=1&imgTag=1&recommendNum=%d&showSdkAd=1"]

#define kGetNextSubContextUrl               [SNAPI rootUrl:@"api/news/context.go?"]     // SNNextSubRequestManager.h 此接口并未使用
// 投票接口   !!!!(所在方法均未调用,应该已弃用 2017.2.7 liteng)
#define kVotesDetailUrl                     [SNAPI rootUrl:@"api/news/votesDetail.go?newsId=%@&rt=json"]
#define kVoteRealTimerUrl                   [SNAPI rootUrl:@"api/news/votesRealTimeMes.go?topicId=%@&newsId=%@"]
#define kVoteSubmitUrl                      [SNAPI rootUrl:@"api/news/saveVotes.go?&topicId=%@&newsId=%@&%@"]
//#define kUrlNewsFavour                      [SNAPI rootUrl:@"api/news/newshot.go?"]     // 所在方法并未调用 2017.2.7 liteng
//#define kUrlNewsArticleVideoStatistics      [SNAPI rootUrl:@"api/news/tvStatistics.go?vid=%@"]
///相关推荐v5
//#define kUrlArticleRecommendNews            [SNAPI rootUrl:@"api/news/v5/relevance.go?galleryDo=channel&newsId=%@"]
//#define kUrlGalleryRecommendNews            [SNAPI rootUrl:@"api/news/v5/relevance.go?galleryDo=channel&gid=%@"]

//#define kUrlNewsCountJson					[SNAPI rootUrl:@"api/news/count.go?newsId=%@&rt=json"]

//#define kUrlHotWords                        [SNAPI rootUrl:@"api/news/hw.go?newsId=%@&channelId=%@"]

#pragma mark - 刊物相关

// 最新一期
#define kSubCenterCommentPostUrl            [SNAPI rootUrl:@"api/subcenter/subComment.go?subId=%@&author=%@&starGrade=%f&content=%@&rt=json"] // 添加刊物评论
#define kSubDetailUrl                       [SNAPI rootUrl:@"api/subcenter/subDetail.go?rt=json&subId=%@&showMore=1"] // 刊物详情
#define kSubInfoUrl                         [SNAPI rootUrl:@"api/subcenter/subInfo.go?rt=json&subId=%@"] // 获取刊物info 信息
#define kSubCommentListUrl                  [SNAPI rootUrl:@"api/subcenter/commentList.go?rt=json&pageSize=20&subId=%@"] // 获取刊物评论列表
#define kSubRecommendListUrl                [SNAPI rootUrl:@"api/subcenter/subRecom.go?rt=json"] // 获取推荐刊物列表
#define kSubQRInfoUrl                       [SNAPI rootUrl:@"api/subcenter/subQr.go?rt=json&subId=%@"] // 获取刊物二维码信息
#define kSubCenterSubRecomUrl               [SNAPI rootUrl:@"api/subcenter/subRecom.go?rt=json&exclude=%@"] // 摇一摇
#define kSubCenterSubTypesRefreshUrl        [SNAPI rootUrl:@"api/subcenter/subTypes.go?&rt=json"]
#define kSubCenterAllSubItemsForTypeUrl     [SNAPI rootUrl:@"api/subcenter/subList.go?typeId=%@&rt=json&pageSize=20"]
#define kSubCenterAllSubHomeDataInitUrl     [SNAPI rootUrl:@"api/subcenter/marrow.go?&rt=json&pageNo=1&pageSize=20&showSdkAd=1"]
#define kSubCenterAllSubMarroUrl            [SNAPI rootUrl:@"api/subcenter/marrow.go?&rt=json&pageNo=%d&pageSize=20"]
#define kSubCenterAllSubRankListUrl         [SNAPI rootUrl:@"api/subcenter/ranklist.go?&rt=json&pageSize=20"]
//#define kSubHomeURLPattern                  [SNAPI rootUrl:@"api/subcenter/subHome.go"]
//#define kPubInfoURLPattern                  [SNAPI rootUrl:@"api/subcenter/v2/subDetail.go"]
#define kSubCenterSynchMySubOrderUrl        [SNAPI rootUrl:@"api/subcenter/saveSubscribeList.go?rt=json&order=%@"]

#pragma mark - 频道

#define kNewsUninterestedUrl                [SNAPI rootUrl:@"api/channel/operate.go"] // 上报不感兴趣老接口 !!应该已经不使用了 2017.2.9 liteng
// watch v5.2.0
//#define snw_push_list_url(page,num,from,picScale,p1)    [SNAPI rootUrl:[NSString stringWithFormat:@"api/channel/push.go?page=%@&num=%@&from=%@&picScale=%@&p1=%@",page,num,from,picScale,p1]]

#pragma mark - 用户中心

#define kUrlUpdateUserInfo                  [SNAPI rootUrl:@"api/usercenter/updateUserInfo.go?userId=%@&type=info&%@=%@"]
#define kUrlUpdateUserInfo2                 [SNAPI rootUrl:@"api/usercenter/updateUserInfo.go?userId=%@&type=info&%@=%@&%@=%@"]
#define kUrlPostHeader                      [SNAPI rootUrl:@"api/usercenter/uploadAuthorImg.go"]

//#define kUrlCloudGetChannel                 [SNAPI rootUrl:@"api/usercenter/cloudGet.go?userId=%@&type=2,3&page=1&pageSize=10000"]
//用户中心
//2012 11 19 by Diao chunmeng
//#define kUrlFlushCode                       [SNAPI rootUrl:@"api/usercenter/flushCode.go"]
//#define kUrlCheckUserName                   [SNAPI rootUrl:@"api/usercenter/checkUser.go?userId=%@@sohu.com"]
//#define kUrlRegister                        [SNAPI rootUrl:@"api/usercenter/register.go?userId=%@@sohu.com&password=%@&code=%@"]
//#define kUrlLogin                           [SNAPI rootUrl:@"api/usercenter/login.go?userId=%@&password=%@"]
//#define kUrlUserInfo                        [SNAPI rootUrl:@"api/usercenter/userInfo.go?userId=%@"]

#pragma mark - SNS相关
//消息通知
#define SNLinks_Path_TimelineProperty       [SNAPI circleRootUrl:@"notify/timeLinePropertyPage/1"]
#define SNLinks_Path_Notify                 [SNAPI circleRootUrl:@"notify/notify/1"]
#define SNLinks_Path_PPNotify               [SNAPI circleRootUrl:@"notify/ppnotify/1"]
#define SNLinks_Path_UserFollow             [SNAPI circleRootUrl:@"user/%@/%@"]
#define SNLinks_Path_Relationopt            [SNAPI circleRootUrl:@"user/relationopt"] // SNFollowUserService.m
#define SNLinks_Path_UserMsgRec             [SNAPI circleRootUrl:@"user/userMsgRec/1"]

#define kTimelineDeleteTrendUrl             [SNAPI circleRootUrl:@"user/userAct?action=delUserAct&pid=%@&actId=%@"] // 删除动态
#define kTimelineServer                     [SNAPI circleRootUrl:@"user/"] // SNTimelineModel.m
#define kCircleTimelineServer               [SNAPI circleRootUrl:@"share/"]

#define kUrlStarGuide                       [SNAPI circleRootUrl:@"/user/recommend?action=getTabRecommend&version=1.0"] //名人引导 // 所在方法并未调用 2017.2.12 liteng
#define kRecommendUserListByPId             [SNAPI circleRootUrl:@"user/recommend/%@"]
#pragma mark - 统计相关


//#define SNLinks_Pick_cGif                   ([SNAPI domain:SNLinks_Domain_PicK url:@"img8/wb/tj/c.gif?"])
//#define SNLinks_Pick_aDotGifBaseUrl         ([SNAPI domain:SNLinks_Domain_PicK url:@"img8/wb/tj/a.gif"])

//#define SNLinks_Pick_sGifLogBaseUrl         ([SNAPI domain:SNLinks_Domain_PicK url:@"img8/wb/tj/s.gif"])
//#define SNLinks_Pick_cDotGifBaseUrl         ([SNAPI domain:SNLinks_Domain_PicK url:@"img8/wb/tj/c.gif"])
//#define SNLinks_Pick_nDotGifBaseUrl         ([SNAPI domain:SNLinks_Domain_PicK url:@"img8/wb/tj/n.gif"])
//#define SNLinks_Pick_usrDotGifBaseUrl       ([SNAPI domain:SNLinks_Domain_PicK url:@"img8/wb/tj/usr.gif"])
//#define SNLinks_Pick_reqstatDotGifBaseUrl   ([SNAPI domain:SNLinks_Domain_PicK url:@"img8/wb/tj/reqstat.gif"])
//#pragma mark - 域名:aDotGif

// sms share analyze
// mail share analyze
//#define kWSMV_VideoPVStatURL                [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=show&vid=%@&newsId=%@&subId=%@&channelId=%@&mid=%@&net=%@&_refer=%d"]
//#define kWSMV_VideoVVStatURL                [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=vv&vid=%@&newsId=%@&subId=%@&channelId=%@&mid=%@&net=%@&_refer=%d&ptime=%f&ttime=%f&siteId=%@&columnId=%@&offline=%@&ad=%d&adtime=%f"]
//#define kWSMV_VideoSVStatURL                [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=chainPlay&vid=%@&newsId=%@&mId=%@&net=%@&_refer=%d&ptimes=%@"]
//#define kWSMV_VideoPlayerActionsStatURL     [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=playActs&vid=%@&newsId=%@&subId=%@&channelId=%@&mId=%@&net=%@&_refer=%d&pacts=%@"]
////虽然在这里&ptime=&ttime=两个参数没有意义，但田亮要求加上并让它空着
//#define kWSMV_VideoFFLStatURL               [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=loading&vid=%@&newsId=%@&subId=%@&channelId=%@&mid=%@&net=%@&_refer=%d&suc=%d&ltime=%f&ptime=&ttime=&siteId=%@"]
//流内视频统计
//#define kWSMV_NewsVideoPVStatURL            [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=pgc_vv&vid=%@&channelId=%@"]
//
//// 视频 频道 热播管理 pv 统计 url + &p1=&pid=
//#define kWSMV_VideoChannelsPvStatURL        [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=tag&net=%@"]
//#define kWSMV_VideoHotColumnPvStatURL       [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=hot&net=%@"]
//#define kWSMV_VideoHotColumnActionStatURL   [SNAPI aDotGifUrlWithParameters:@"_act=video&_tp=hotset&action=%@&columnId=%@&net=%@"]

// v5.2.0 QQ空间的分享统计
//#define kAppQQZoneAnalyzeUrl                [SNAPI aDotGifUrlWithParameters:@"stat=s&p1=%@&p=ios&v=%@&s=qq&qq=&st=%@&stid=%@&sc=%@&subid=%@"]
//正文页评论统计
//#define kAppCommentStatisticalByGidUrl      [SNAPI aDotGifUrlWithParameters:@"p1=%@&u=%d&p=i&a=14&b=%@&s1=client&s2=%@&gid=%@"]
// 3.7统计需求
// 及时新闻列表 滑动统计
//#define kAnalyticsUrlRollingNewsSlide       [SNAPI aDotGifUrlWithParameters:@"_act=read&_tp=slide&_page=%d&channelId=%@&tcount=%d&ttime=%d&net=%@"]


// 4.0统计需求
//#define kAnalyticsUrlPV                     [SNAPI aDotGifUrlWithParameters:@"_act=pv&page=%@&track=%@"]

//#define kAnalyticsNewsAddFavour             [SNAPI aDotGifUrlWithParameters:@"_act=read&_tp=tm&newsId=%@&isHot=1"]

#pragma mark - photos

#define kUrlCategoryPhoto                   [SNAPI rootUrl:@"api/photos/list.go?rt=json&pageNo=%d&pageSize=%d&categoryId=%@"]
#define kUrlTagPhoto                        [SNAPI rootUrl:@"api/photos/list.go?rt=json&pageNo=%d&pageSize=%d&tagId=%@"]

#define kUrlTermPhotoGallery				[SNAPI rootUrl:@"api/photos/gallery.go?termId=%@&newsId=%@&rt=json&showSdkAd=1&moreCount=%d"]
#define kUrlChannelPhotoGallery				[SNAPI rootUrl:@"api/photos/gallery.go?channelId=%@&newsId=%@&rt=json&showSdkAd=1&moreCount=%d"]
//#define kUrlSinglePhotoGallery              [SNAPI rootUrl:@"api/photos/gallery.go?gid=%@&rt=json&showSdkAd=1&moreCount=%d"]
//#define kUrlLikeNewsByGid    				[SNAPI rootUrl:@"api/photos/like.go?gid=%@&rt=json"]
//#define kUrlLikeNewsByNewsId    			[SNAPI rootUrl:@"api/photos/like.go?newsId=%@&termId=%@&rt=json"]
//#define kUrlNewsIdPhotoGallery              [SNAPI rootUrl:@"api/photos/gallery.go?newsId=%@&rt=json&showSdkAd=1&moreCount=%d"]
#pragma mark - paper

#define kUrlTermZip							[SNAPI rootUrl:@"api/paper/termZip.go?termId=%@&zipType=all"]
#define kUrlTermPaper						[SNAPI rootUrl:@"api/paper/term.go?termId=%@&redirect=0&nested=1"]
#define kUrlSubPaper						[SNAPI rootUrl:@"api/paper/term.go?subId=%@&redirect=0&nested=1"]
#define kUrlTermGo                          [SNAPI rootUrl:@"api/paper/term.go?%@&redirect=0&nested=1"]
#define kUrlSpecialNewsList                 [SNAPI rootUrl:@"api/paper/newsList.go?termId=%@&rt=json&supportTV=1"] 
#define kUrlHistory							[SNAPI rootUrl:@"api/paper/history.go?rt=json&pubId=%@&page=%@&num=%@"]
#define kOffline                            [SNAPI rootUrl:@"api/paper/offline.go?p1=%@"] // 离线接口
//#define kLastTermLinkUrl                    [SNAPI rootUrl:@"api/paper/lastTermLink.go?subId=%@&redirect=0&nested=1"]
//#define kInputBox                           [SNAPI rootUrl:@"api/paper/inputbox.go?rt=json&subIds=%@"] // 收件箱接口

#pragma mark - 视频相关

#define kVideoMediaURL                      ([SNAPI rootUrl:@"api/video/videoMedia.go?subId=%@&columnId=%@"]) // SNVideoMediaBaseViewController 已不使用
#define kVideoPersonURL                     ([SNAPI rootUrl:@"api/video/videoPerson.go?mid=%@"]) // SNVideoMediaBaseViewController 已不使用
#define kVideoUrlChannel                    ([SNAPI rootUrl:@"api/video/channelList.go"])
#define kVideoUrlHotChannelCategory         ([SNAPI rootUrl:@"api/video/hotColumnList.go"])
#define kVideoUrlUploadChannelList          ([SNAPI rootUrl:@"api/video/uploadChannelList.go"])
#define kVideoDetailUrl                     ([SNAPI rootUrl:@"api/video/message.go?id=%@"]) // 此id为mid 并不是vid
#define kVideoShareContentUrl               ([SNAPI rootUrl:@"api/video/shareInfo.go?mid=%@"]) // 未真正调用 2017.2.6 liteng
#define kSNVideoDetailRecommendUrlV2        ([SNAPI rootUrl:@"api/video/relationMessageList.go?mid=%@&cursor=%@&size=10"])
//cursor - 客户端拉取的热播数据的最大游标（preCursor字段）
#define VIDEO_TIMELINE_CHECK_URL            ([SNAPI rootUrl:@"api/video/check.go?cursor=%@"])

//#define VIDEO_TIMELINE_URL                  ([SNAPI rootUrl:@"api/video/messageList.go?channelId=%@&type=0&size=20"])

#define NEW_VIDEO_TIMELINE_URL              ([SNAPI rootUrl:@"api/video/multipleMessageList.go?channelId=%@&type=0&size=20"])

/*
 action	是
 1:取消 0: 加入
 columnId	是	 	栏目id
 */
#define kVideoUrlCategorySubscribe          ([SNAPI rootUrl:@"api/video/addColumn.go?columnId=%@&action=%@"])


#pragma mark - 其他

#define kUrlActionList                      [SNAPI rootUrl:@"api/other/activityList.go"] 
#define kUrlMoreApp                         [SNAPI rootUrl:@"api/thirdparty/app.go?platform=iphone"]

// 获取微博频道列表
//#define kWeiboHotChannelListUrl             [SNAPI rootUrl:@"api/weibo/channel.go?rt=json"]
// 微博列表
#define kWeiboListUrl                       [SNAPI rootUrl:@"api/weibo/list.go?rt=json&pageSize=20&pageNo=%d"]
// 微博评论列表
#define kWeiboCommentListUrl                [SNAPI rootUrl:@"api/weibo/detail.go?rt=json&pageSize=%d&pageNo=%d&rootId=%@&showWeiboDetail=%@&share=%@"]

//政企
#define kUrlOrgHome                         [SNAPI rootUrl:@"api/vm/orgHome.go?subId=%@"]
#define kUrlOrgColumn                       [SNAPI rootUrl:@"api/vm/orgColumn.go?subId=%@&columnId=%@"]

//#define kUrlNewsReport                      [SNAPI rootUrl:@"api/report/toreport.go?newsId=%@"]

//上传日志
//#define kUrlUploadRecord					[SNAPI rootUrl:@"api/s.do"]

//#define kAnalytics                          [SNAPI rootUrl:@"api/analytics/count.go"]


//#define kCheckFB                            [SNAPI rootUrl:@"api/check.do?v=8&checkType=fb&b=%@"]

//#define kHadShowUpdate                      (@"kHadShowUpdate")
//#define kCheckDoResponse                    (@"kCheckDoResponse")
//#define kClientInfoSynchronized             (@"kClientInfoSynchronized")
//#define kCheckDoType                        (@"paper,up,ad,fb,loading,nf,reply,sub,subTab,notifys,vbub,slient")

//#define kUrlOpencmsRegister                 ([SNPreference sharedInstance].testModeEnabled ? ([SNAPI domain:SNLinks_Domain_Tk url:nil]) : ([SNAPI domain:SNLinks_Domain_MpK url:nil]))

//#define FixedUrl_Splash_Poster              ([SNAPI domain:SNLinks_Domain_PosterSce url:@"poster/h5"])

//#define kDefaultImageUrl                    ([SNAPI domain:kProductMainDomain url:@"khtml/images/sohunews_about.png"])

//#define kUploadToShareUrl                   [SNAPI domain:SNLinks_Domain_InnerMtc url:@"paike/upload_status.json?key=%@"] //(@"http://inner.mtc.sohu.com/paike/upload_status.json?key=%@")
//#define kUploadLocalImageUrl                [SNAPI domain:SNLinks_Domain_InnerMtc url:@"paike/upload_localImg.json?key=%@"]//(@"http://inner.mtc.sohu.com/paike/upload_localImg.json?key=%@")
//#define kCancelBindingUrl                   [SNAPI domain:SNLinks_Domain_InnerMtc url:@"paike/cancelOauth/%@.json?key=%@"]//(@"http://inner.mtc.sohu.com/paike/cancelOauth/%@.json?key=%@")
//#define kURLGetShareList                    [SNAPI domain:SNLinks_Domain_InnerMtc url:@"paike/thirdApp.json?key=%@"]//(@"http://inner.mtc.sohu.com/paike/thirdApp.json?key=%@")

#endif /* SNHistoryLinks_h */
