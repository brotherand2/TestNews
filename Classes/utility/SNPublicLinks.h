//
//  SNPublicLinks.h
//  sohunews
//
//  Created by lijian on 2016/11/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#ifndef SNPublicLinks_h
#define SNPublicLinks_h

//#define SNPublicLinks_Https_Mode

#import "SNHistoryLinks.h"


//--------------------------------------------------------------------------------------------------------------------------
#pragma mark - 域名部分

//已申请
#define SNLinks_Domain_K                    (@"k.sohu.com")
#define SNLinks_Domain_ApiK                 (@"api.k.sohu.com")
#define SNLinks_Domain_TestApiK             (@"testapi.k.sohu.com")
#define SNLinks_Domain_OnlineTestApiK       (@"onlinetestapi.k.sohu.com")
#define SNLinks_Domain_SnsK                 (@"sns.k.sohu.com")
#define SNLinks_Domain_CacheK               (@"cache.k.sohu.com")
#define SNLinks_Domain_PicK                 (@"pic.k.sohu.com")
#define SNLinks_Domain_MpK                  (@"mp.k.sohu.com")
#define SNLinks_Domain_3gK                  (@"3g.k.sohu.com")
#define SNLinks_Domain_MK                   (@"m.k.sohu.com")
//已申请中未在应用内使用的
#define SNLinks_Domain_ZcacheK              (@"zcache.k.sohu.com")
#define SNLinks_Domain_CmsK                 (@"cms.k.sohu.com")
#define SNLinks_Domain_ContentK             (@"content.k.sohu.com")
#define SNLinks_Domain_Test3gK              (@"test3g.k.sohu.com")
#define SNLinks_Domain_PushK                (@"push.k.sohu.com")
#define SNLinks_Domain_EeK                  (@"ee.k.sohu.com")
#define SNLinks_Domain_Api1K                (@"api1.k.sohu.com")
#define SNLinks_Domain_PartnerK             (@"partner.k.sohu.com")
#define SNLinks_Domain_SItcCN               (@"s.itc.cn")
#define SNLinks_Domain_MpWap                (@"mp.wap.sohu.com")
#define SNLinks_Domain_BiKSohuno            (@"bi.k.sohuno.com")
#define SNLinks_Domain_DataKSohuno          (@"data.k.sohuno.com")
#define SNLinks_Domain_DatainKSohuno        (@"datain.k.sohuno.com")
#define SNLinks_Domain_CodeKSohuno          (@"code.k.sohuno.com")


//未申请
#define SNLinks_Domain_InnerMtc             (@"inner.mtc.sohu.com")
#define SNLinks_Domain_Passport             (@"passport.sohu.com")
#define SNLinks_Domain_Tk                   (@"t.k.sohu.com")
#define SNLinks_Domain_PosterSce            (@"poster.sohusce.com")
#define SNLinks_Domain_Ldd                  (@"ldd.sohu.com")
//#define SNLinks_Domain_TAdrd                (@"t.adrd.sohuno.com")
#define SNLinks_Domain_M                    (@"m.sohu.com")
#define SNLinks_Domain_Stock                (@"stock.sohu.com")

#define SNLinks_Domain_W                    (@"w.sohu.com") //为sns的域名添加p1等信息
#define SNLinks_Domain_Mp                   (@"mp.sohu.com")
#define SNLinks_Domain_Tv                   (@"tv.sohu.com")
#define SNLinks_Domain_SohunewsMagicIP      (@"221.179.173.197")

//主域名
#define SNLinks_Domain_BaseURL              ([[SNAPI rootScheme] stringByAppendingString:SNLinks_Domain_ApiK])
#define SNLinks_Domain_ProductDomain        ([SNPreference sharedInstance].simulateOnLineEnabled ? (SNLinks_Domain_OnlineTestApiK):([SNPreference sharedInstance].testModeEnabled ? (SNLinks_Domain_TestApiK) : (SNLinks_Domain_ApiK)))
// 此为api.k.sohu.com域名，切换测试服与准线上
#define SNLinks_Domain_BaseApiK             ([SNPreference sharedInstance].testModeEnabled ? [SNPreference sharedInstance].basicAPIDomain : SNLinks_Domain_ProductDomain)

//强制切成https域名
#define SNLinks_Https_Domain(d)             ([NSString stringWithFormat:@"https://%@/",(d)])

#pragma mark - 地址部分

#pragma mark  ------------------------------------ 直播相关接口 -----------------------------------------------
#define SNLinks_Path_Live_LiveList            @"api/live/liveList.go"         // 直播间-今日，栏目推荐，预告三合一接口
#define SNLinks_Path_Live_LiveHistory         @"api/live/hisLivesByDate.go"   // 直播间-往期比赛
#define SNLinks_Path_Live_Statistic           @"api/live/statistics.go"       // 直播间-技术统计
#define SNLinks_Path_Live_Content             @"api/live/data.go"             // 直播间-直播内容
#define SNLinks_Path_Live_AdFlow              @"api/live/adflow.go"
#define SNLinks_Path_Live_Surport             @"api/live/support.go"          // 直播间-提交支持数据（顶）
#define SNLinks_Path_Live_Info                @"api/live/info.go"             // 直播查询
#define SNLinks_Path_Live_RecList             @"api/live/recommandLiveList.go"// 直播间-直播推荐
#define SNLinks_Path_Live_Subscribe           @"api/live/subscribeLive.go"    // 直播频道--订阅列表
#define SNLinks_Path_Live_SubHistory          @"api/live/history.go"          // 直播频道--订阅往期列表
#define SNLinks_Path_Live_InviteStatus        @"api/live/getBindStatus.go"
#define SNLinks_Path_Live_InviteAnswer        @"api/live/inviteAnswer.go"


#pragma mark ------------------------------------ 意见反馈相关接口 -----------------------------------------

#define SNLinks_Path_FeedBack_TypeList        @"api/feedback/feedBackTypeList.go"        // 反馈问题类型列表
#define SNLinks_Path_FeedBack_Send            @"api/feedback/saveNew.go"                 // 发送反馈
#define SNLinks_Path_FeedBack_List            @"api/feedback/userFeedBack.go"            // 反馈内容列表
#define SNLinks_Path_FeedBack_ScreenShot      @"api/feedback/checkWhetherScreenshot.go"  // 截屏反馈权限
#define SNLinks_Path_FeedBack_RedReset        @"api/feedback/redPointReset.go"           // 重置反馈回复小红点
#define SNLinks_Path_FeedBack_SerQuesList     @"api/feedback/customerServiceQuestionsList.go" // 客服问题列表接口

#pragma mark ------------------------------------ 评论相关接口 -----------------------------------------

#define SNLinks_Path_Comment_UserComment      @"api/comment/userComment.go"     //发评论
#define SNLinks_Path_Comment_CommentList      @"api/comment/getCommentListByCursor.go"
#define SNLinks_Path_Comment_Delete           @"api/comment/delCommentBySljCmtId.go"
#define SNLinks_Path_Comment_Ding             @"api/comment/dingv3.go"


#pragma mark ------------------------------------ 搜索相关接口 -----------------------------------------
#define SNLinks_Path_Search_SuggestV2         @"api/search/v2/suggest.go"   // 获取搜索的联想词
#define SNLinks_Path_Search_HotwordV6         @"api/search/v6/hotwords.go"
#define SNLinks_Path_Search_Hotword           @"api/search/hotwords.go"

#pragma mark ------------------------------------ 用户设置相关 ------------------------------------------
#define SNLinks_Path_User_SaveSet             @"api/user/set.go"                // 保存用户各项设置
#define SNLinks_Path_User_GetSet              @"api/user/getUserSet.go"         // 获取用户设置
#define SNLinks_Path_User_Regist		      @"api/user/regist.go"

#pragma mark ------------------------------------ 网络诊断相关 ------------------------------------------

#define SNLinks_Path_NetDiag_Element          @"d/api/elements.php"  // SNLinks_Domain_Ldd
#define SNLinks_Path_NetDiag_Remote           @"d/api/ldd_api.php"   // SNLinks_Domain_Ldd
#define SNLinks_Path_NetDiag_Random           @"js/sohu.js"          // SNLinks_Domain_Ldd
#define SNLinks_Path_NetDiag_Report           @"api/user/reportDataGeneral.go"  // 网络诊断上报

#pragma mark ------------------------------------ 收藏相关接口 -----------------------------------------

#define SNLinks_Path_Favorite_Delete          @"api/favorite/del.go"        // 删除收藏
#define SNLinks_Path_Favorite_Get             @"api/favorite/list.go"       // 获取收藏列表
#define SNLinks_Path_Corpus_Save              @"api/corpus/save.go"         // 创建收藏夹
#define SNLinks_Path_Corpus_Delete            @"api/corpus/deleteCorpus.go" // 删除收藏夹
#define SNLinks_Path_Corpus_List              @"api/corpus/getCorpusList.go"// 获取收藏夹列表
#define SNLinks_Path_Corpus_Update            @"api/corpus/update.go"       // 更新收藏夹信息
#define SNLinks_Path_Corpus_BindList          @"api/corpusBind/bindlist.go" // 获取收藏夹下的内容
#define SNLinks_Path_Corpus_BatchMove         @"api/corpusBind/batchMove.go"// 批量移动
#define SNLinks_Path_Corpus_BindDelete        @"api/corpusBind/delete.go"   // 删除收藏夹内的记录
#define SNLinks_Path_Favorite_ShareList       @"api/favorite/sharelist.go"  // 获取全部分享列表
#define SNLinks_Path_Favorite_Save            @"api/favorite/v2/save.go"    // 添加到收藏接口
#define SNLinks_Path_Favorite_List            @"api/favorite/v2/list.go"    // 全部收藏列表V2，带图片地址、评论数
#define SNLinks_Path_Favorite_DeleteV2        @"api/favorite/v2/del.go"     // 通过newsId删除接口
#define SNLinks_Path_Favorite_DelShare        @"api/favorite/delshare.go"   // 分享列表删除接口
#define SNLinks_Path_NewsGrab_List            @"api/news/grab/list.go"      // 我的录入列表 2017.9.19
#define SNLinks_Path_NewsGrab_Authority       @"api/news/grab/authorities.go" // pid是否支持新闻抓取 

/// @reason:一个是接口预留可以同步其他用户数据，再一个现在是默认同步，以后也可能会让用户来确认是否要同步. 2017.8.17
#define SNLinks_Path_SyncUserData             @"api/usercenter/syncUserData.go"   // 新增同步接口

#pragma mark  ----------------------------- 股票相关接口 -----------------------------------------------

#define SNLinks_Path_Stock_MyStock            @"api/stock/myStock.go"      // 我的股票
#define SNLinks_Path_Stock_Add                @"api/stock/addMyStock.go"   // 添加我关注的股票
#define SNLinks_Path_Stock_Del                @"api/stock/delMyStock.go"   // 删除我关注的股票
#define SNLinks_Path_Stock_Search             @"api/stock/searchStock.go"  // 搜索股票
#define SNLinks_Path_Stock_IsMyStock          @"api/stock/isMyStock.go"    // 查询某支股票是否是我关注的

#pragma mark  ----------------------------- 红包相关接口 -----------------------------------------------

#define SNLinks_Path_CodeCheck                @"api/task/code/checkout.go"
#define SNLinks_Path_RedPacket_Slide          @"api/packProfile/slide.go"        // 解锁失败上报接口
#define SNLinks_Path_RedPacket_Confirm        @"api/packProfile/confirm.go"      // 滑动解锁成功，确认收到红包接口
#define SNLinks_Path_RedPacket_UgcPack	      @"api/packProfile/ugcPack.go"      // 分享、评论、收藏成功后请求红包
#define SNLinks_Path_RedPacket_Withdraw       @"api/packProfile/withdraw.go"     // 红包提现功能
#define SNLinks_Path_Ticket_Group             @"api/ticket/ticketGroup.go"       // 获取优惠券组信息，领取优惠券页面使用
#define SNLinks_Path_RedPacket_IsBindAlipay   @"api/packProfile/isBindMobile.go" // 是否绑定支付宝
#define SNLinks_Path_RedPacket_BindAlipay     @"api/packProfile/bindAlipay.go"   // 绑定支付宝

#pragma mark  ----------------------------- 分享相关接口 -----------------------------------------------

#define SNLinks_Path_Share_ShareOn            @"api/share/shareon.go"
#define SNLinks_Path_Share_AppList            @"api/share/v4/getThirdAppList.go" // 获取分享平台列表
#define SNLinks_Path_Share_WebImageV4         @"api/share/v4/upload.go"
#define SNLinks_Path_Share_CancelAuth         @"api/share/cancelOauth.go"        // 获取分享平台列表
#define SNLinks_Path_Share_SyncToken          @"api/share/v4/synctoken.go"       // 同步token(客户端为sso登录时使用)
#define SNLinks_Path_Share_QQSyncToken        @"api/share/qqSsoLogin.go"         // qq登录

#define SNLinks_Path_Screen_UploadPic         @"api/screen/upLoadPic.go"         //截屏分享上传(截屏图) wangshun
#define SNLinks_Path_Screen_WXAuth            @"api/usercenter/screenshot/share/auth.go"//微信授权 wangshun
#define SNLinks_Path_Screen_UserInfo          @"api/usercenter/screenshot/share/userinfo"//userinfo wangshun

#pragma mark  ----------------------------- 用户画像相关接口 -----------------------------------------------

#define SNLinks_Path_Face_Info                @"api/face/faceInfo.go"
#define SNLinks_Path_Face_Preference          @"api/face/preference.go"
#define SNLinks_Path_Face_SubmitPreference    @"api/face/submitPreference.go"

#pragma mark  ----------------------------- 客户端配置相关接口 -----------------------------------------------

#define SNLinks_Path_Client_Setting           @"api/client/setting.go"
#define SNLinks_Path_Client_Config            @"api/client/config.go"
#define SNLinks_Path_Client_SpecialSkin       @"api/client/specialskin.go"

#pragma mark  ----------------------------- 新闻相关接口 -----------------------------------------------

#define SNLinks_Path_News_OptimizeRead        @"api/news/optimizeRead.go" // 判定是否支持优化阅读
#define SNLinks_Path_News_Article             @"api/news/v5/article.go"   // 正文页数据请求
#define SNLinks_Path_News_RecomVideo          @"api/news/videoRecom.go"   //正文页视频相关推荐
#define SNLinks_Path_News_RecomNews           @"api/news/adsense.go" // 正文页广告位
#define SNLinks_Path_News_NewsUpdate          @"api/recom/getUnreadNum.go"//push或端外调起正文 显示流内新闻未读数

#pragma mark  ----------------------------- 订阅刊物(搜狐公众号)相关接口 -----------------------------------------------

#define SNLinks_Path_Subcribe_Change          @"api/subscribe/change.go"         // 订阅或者退订刊物(关注/取消关注)
#define SNLinks_Path_Subcribe_MySub           @"api/subcenter/v4/mySubscribe.go" // 获取订阅刊物
#define SNLinks_Path_Subcribe_MoreSub         @"api/subcenter/v2/subRecom.go"    // 获取更多推荐刊物
#define SNLinks_Path_Subcribe_UnreadClear     @"api/unread/clear.go"             // 清空订阅未读数
#define SNLinks_Path_Subcribe_GetTabs         @"api/other/v1/getTabs.go"            // 管理申请搜狐号接口名称
//http://onlinetestapi.k.sohu.com/?p1=NjI2MjEzNzQ5NDkzOTU0NTcxMQ%3D%3D
#define SNLinks_Path_Subscribe_GetChannelList       [SNAPI rootUrl:@"api/subcenter/subscribeIndex.go"]//@"http://dev.api.data.sohuno.com/stars/getChannelList"
//http://onlinetestapi.k.sohu.com/?p1=NjI2MjEzNzQ5NDkzOTU0NTcxMQ%3D%3D&pageNo=1&pageSize=20&mediumIndex=1009
#define SNLinks_Path_Subscribe_GetChannelcontent    [SNAPI rootUrl:@"api/subcenter/subscribeList.go"]//@"http://dev.api.data.sohuno.com/stars/getAccountListByChannel"

#pragma mark  ----------------------------- 频道相关接口 -----------------------------------------------
///TODO: news.go 接口调用较为复杂，待频道重构时再做处理
#define kUrlRollingNewsListJson				[SNAPI rootUrl:@"api/channel/v5/news.go?channelId=%@&num=%d&page=%d&groupPic=1&supportTV=1&imgTag=1&supportSpecial=1&supportLive=1&showSdkAd=1&rt=json"]

//lijian 20170912 news.go强制切成https的了
//#define kUrlRollingNewsListJsonV6			[SNAPI rootUrl:@"api/channel/v6/news.go?"]
//#define kUrlRollingNewsListJsonPrefix       [SNAPI rootUrl:@"api/channel/v5/news.go?"]
#define kUrlRollingNewsListJsonV6			[NSString stringWithFormat:@"https://%@/%@", SNLinks_Domain_ProductDomain, @"api/channel/v6/news.go?"]
#define kUrlRollingNewsListJsonPrefix       [NSString stringWithFormat:@"https://%@/%@", SNLinks_Domain_ProductDomain,@"api/channel/v5/news.go?"]

#define kUrlRollingNewsParams               @"num=%d&page=%d&groupPic=1&supportTV=1&imgTag=1&supportSpecial=1&supportLive=1&showSdkAd=1&rt=json"
#define kUrlRollingNewsParamsV6             @"num=%d&page=%d&groupPic=1&imgTag=1&showSdkAd=1&rt=json"
// ------------------------------------------------------------------------------------------------------------------
#define SNLinks_Path_Channel_NewsV5           @"api/channel/v5/news.go"
#define SNLinks_Path_Channel_NewsV6           @"api/channel/v6/news.go"
#define SNLinks_Path_Channel_List			  @"api/channel/v7/list.go"
#define SNLinks_Path_Channel_CheckLatest      @"api/channel/checkflash.go"
#define SNLinks_Path_Channel_LocalList        @"api/channel/getLocalChannelList.go"
#define SNLinks_Path_Channel_HouseChannel     @"api/channel/getHousePropChannelList.go"
#define SNLinks_Path_Channel_SaveChannel      @"api/channel/v2/saveChannelList.go"     // 保存频道
#define SNLinks_Path_Channel_DislikeReason    @"api/channel/dislike/get_reason.go"     // 获取不感兴趣理由标签
#define SNLinks_Path_Channel_DislikeReport    @"api/channel/dislike/submit_reason.go"  // 上报不感兴趣理由
#define SNLinks_Path_Channel_H5               @"api/channel/geth5url.go"               // 频道流请求h5地址
#define SNLinks_Path_Channel_PullAd           @"api/channel/ad/pullAd.go"
#define SNLinks_Path_Channel_LocalChannel     @"api/channel/getLocalChannel.go"        // 获取定位城市信息

#pragma mark  ----------------------------- 二维码扫描接口 -----------------------------------------------

#define SNLinks_Path_QRCodeCheck              @"api/qr/check.go"  // 二维码扫描相关
#define SNLinks_Path_ImgFeatureCheck          @"api/picid/identify.go"  // 二维码扫描相关

#pragma mark  ----------------------------- 书币充值接口 -----------------------------------------------

#define SNLinks_Path_GenerateId             [SNAPI rootUrl:@"api/payment/coin/generateId.go"]  // 生成充值订单号
#define SNLinks_Path_CoinBalance            [SNAPI rootUrl:@"api/payment/coin/account.go"]     // 金币余额接口
#define SNLink_Path_Product                 [SNAPI rootUrl:@"api/payment/coin/product.go"]     // 获取商品列表
//#define SNLink_Path_Product                 [SNAPI rootUrl:@"api/payment/coin/standard.go"]     // 获取商品列表
#define SNLink_Path_Verify                  [SNAPI rootUrl:@"api/payment/coin/purchase.go"]    // 金币充值验证
#define SNLink_Path_PurchaseList            [SNAPI rootUrl:@"api/payment/coin/purchaseList.go"]// 充值记录

#pragma mark  ----------------------------- 书币消费接口 -----------------------------------------------

#define SNLink_Path_CoinPay                 [SNAPI rootUrl:@"api/payment/coinPay.go"]  // 金币支付
#define SNLink_Path_CheckPaymentStatus      [SNAPI rootUrl:@"api/payment/payStatus.go"]// 监测订单状态

#pragma mark  ----------------------------- 用户中心相关接口 -----------------------------------------------

#define SNLinks_Path_Login_MobileLogin        @"api/usercenter/v2/mobileCaptLogin.go"
#define SNLinks_Path_Login_CheckValidate      @"api/usercenter/mobileValidate.go"    // 校验是否为有效手机号
#define SNLinks_Path_Login_CheckToken         @"api/usercenter/v2/checkToken.go"
#define SNLinks_Path_Login_Logout             @"api/usercenter/logout.go"            // 退出登录
#define SNLinks_Path_Login_OpenLoginLink      @"api/usercenter/openLoginLink.go"

#define SNLinks_Path_Login_ThirdLoginLink     @"api/share/thirdPartyLogin.go"//第三方登录绑定
#define SNLinks_Path_Login_CheckToken_V3      @"api/usercenter/chkTk.go" //checktoken.go
#define SNLinks_Path_Login_VerifyCode_V3      @"api/usercenter/sendSms.go"
#define SNLinks_Path_Login_BindMobile         @"api/share/bindMobile.go"//
#define SNLinks_Path_Login_MobileLogin_V3     @"api/usercenter/mobileSmsLogin.go"

#define SNLinks_Path_Login_thirdRegister      @"api/share/regist.go"
#define SNLinks_Path_Login_sohuLogin          @"api/share/sohuLogin.go"
#define SNLinks_Path_Login_MobileSmsLogin     @"api/usercenter/mobileSmsLogin.go"//手机号验证码登录

#define SNLinks_Path_IsBindMobile             @"api/usercenter/getBindMobileInfo.go" // 是否绑定手机
#define SNLinks_Path_Cloud_Get                @"api/usercenter/cloudGet.go"          // 云存储
#define SNLinks_Path_Cloud_Sync               @"api/usercenter/getSyncStatus.go"     // 是否云同步
#define SNLinks_Path_Cloud_SyncData           @"api/usercenter/syncCidData.go"       // 云同步数据

#define SNLinks_Path_PPLogin_GetPid           @"api/usercenter/passport/login.go"    //PPLogin 接口 同步pid

#define SNSOHU_USLER_Protocal                 @"http://m.passport.sohu.com/app/protocol"//用户协议

#pragma mark ------------------------------ api/photos -----------------------------------------------

#define SNLinks_Path_Photo_Gallery            @"api/photos/gallery.go"
#define SNLinks_Path_Photo_Tags    			  @"api/photos/keywords.go"
#define SNLinks_Path_Photo_ListInChannel      @"api/photos/listInChannel.go" // 美图频道新闻

#pragma mark  ----------------------------- 其他接口 -----------------------------------------------

#define SNLinks_Path_Push_Change		      @"api/push/change.go"       // 推送
#define SNLinks_Path_News_Exposure            @"news/exposure.go"
#define SNLinks_Path_CrashUpload              @"api/crash/v2/upload.go"   // crash日志上报
#define SNLinks_Path_Check                    @"api/check.do"             // 每3分钟请求一次,获取最新的消息数据(28项)
#define SNLinks_Path_Weather                  @"api/weather/weather.go"   // 天气预报
#define SNLinks_Path_Userinfo                 @"api/userinfo/user.go"     // 3.5 阅读圈接口 SNUserCircle
#define SNLinks_Path_Spotlight                @"api/spotlight/content.go" // spotlight
#define SNLinks_Path_ReportLocation           @"api/function/location.go" // 上报地理位置信息
#define SNLinks_Path_ClearPush                @"api/function/clearPushCount.go"     // 清空push消息数
#define SNLinks_Path_ActionIntercept          @"api/control/actionIntercept.go"     // 用户行为拦截
#define SNLinks_Path_Upgrade				  @"api/u.do"                           // 升级接口
#define SNLinks_Path_ReportPush               @"api/pushsdk/p.go"                // 统计上报
#define SNLinks_Path_Activity_Info            @"api/other/getPromptInfo.go"      // 活动红点提醒信息
#define SNLinks_Path_Activity_Reset           @"api/other/reSetPromptStatus.go"  // 取消活动红点提醒
#define SNLinks_Path_DotGifBaseUrl            @"img8/wb/tj/%@.gif"  // SNLinks_Domain_PicK
#define SNLinks_Weixin_Oauth2                 @"https://api.weixin.qq.com/sns/oauth2/access_token"  // 微信登录授权
#define SNLinks_Path_GetBroker              ([SNPreference sharedInstance].testModeEnabled ? @"https://10.10.76.74:8090/broker/get" : [SNAPI rootUrl:@"broker/get"]) // proxy
#define SNLinks_Path_Special_Activity         @"api/activity/popupAdsActivity.go"//可定制化活动
#define SNLinks_Path_Special_AdResource       @"api/resource/adResource.go"//频道流与正文页非标广告

#define SNLinks_Check_Video_Site              @"api/videoext/checkSite.go"  //@qz 视频播放失败的时候检查是否需要切site
#define SNLinks_Report_Video_Site              @"api/videoext/reportSite.go"//@qz 视频重新尝试播放成功的时候发送此接口
#pragma mark -------------------------------- H5 / WebView及不涉及请求的相关接口 ---------------------------------------------

#define SNLinks_path_Kuaizhan_UserComment @"https://sohuxinwen1.kuaizhan.com/clubv2/newsapp/forums/WT9ivGerpA0MKCNo"//快站用户评论
#define SNLinks_Path_FeedBackH5_HotQuestion   [SNAPI rootUrl:@"h5apps/hotquestion/modules/hotquestion/detail.html"] // 意见反馈热门问题
#define SNLinks_Path_FeedBackH5_AllQuestion   [SNAPI rootUrl:@"h5apps/hotquestion/modules/hotquestion/hotquestionlist.html"]  // 意见反馈全部问题
#define SNLinks_Path_RedPacketH5_GetTicket    [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/coupon/coupon.html?tgId=%@"]//优惠券领取html页
#define SNLinks_Path_FaceH5                   [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/readZone/readZone.html?sohunewsclient_h5_title=hide"] // 用户画像H5页面

#define kAdInfo                             [SNAPI rootUrl:@"api/function/extendInfo.go?rt=json"] // XML解析
#define kUrlOpenCMSEntranceControl          [SNAPI rootUrl:@"api/usercenter/mediaControl.go?isClose=1"] // webView
#define kH5LoginUrl                         [SNAPI rootUrl:@"api/usercenter/redirect.go?m=withUserInfo&url=%@"] // webView
#define kH5LoginUrlString                   [SNAPI rootUrl:@"api/usercenter/redirect.go?m=withUserInfo&url="] // webView
#define kSNSUserCenterURL                   [SNAPI rootUrl:@"api/usercenter/passportByPid.go?pid=%@"] // 使用的系统的NSURLRequest

#define kLoginToPushProtocolUrl             [SNAPI rootUrl:@"api/ad/view.go?adId=1215&cid=%@"] // webview 加载
#define kH5StatementURL                     [SNAPI rootUrl:@"api/support/declare.go"]     // 二代协议解析
#define kForwardHost                        [SNAPI rootUrl:@"api/vforward"]

#define kUrlNewActionList                   [SNAPI rootUrl:@"h5apps/activitylist.sohu.com/list.go"]
#define kUrlReadHistory                     [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/history/history.html"]
#define kUrlPushHistory                     [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/pushHistory/pushHistory.html"]
#define kShowOptimizedReadURL               [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/optimizedread/optimizedread.html?url=%@"] // 显示优化后的页面
#define FixedUrl_ApiK_CouponList            [SNAPI rootUrl:@"h5apps/coupon.sohu.com/modules/coupon/couponList.html"]
#define kOpenDebugModeURL                   [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/debug/debug.html"]
#define kH5AppsNewsSDKURL                   [SNAPI rootUrl:@"h5apps/newssdk.sohu.com%@"]
#define kUrlReport                          [SNAPI rootUrl:@"h5apps/newssdk.sohu.com/modules/report/report.html?reportType=%@"]





#pragma mark - 固定链接
//#define kSinaAppRedirectURI                 (SNLinks_Domain_ApiK)

#define kSinaWeiboSDKAPIDomain              (@"https://open.weibo.cn/2/")
#define kSinaWeiboSDKOAuth2APIDomain        (@"https://open.weibo.cn/2/oauth2/")
#define kSinaWeiboWebAuthURL                (@"https://open.weibo.cn/2/oauth2/authorize")
#define kSinaWeiboWebAccessTokenURL         (@"https://open.weibo.cn/2/oauth2/access_token")
#define kSinaWeiboSDKAPIDomainUrl           (@"https://open.weibo.cn")

#define FixedUrl_AppStore_Sohunews          (@"https://itunes.apple.com/cn/app/id436957087")
#define FixedUrl_QianFan                    (@"://qf.56.com")
#define FixedUrl_NewQianFan                 (@"://mbl.56.com")

#define FixedHost_Applink                   (@"applink.k.sohu.com")

#define SNLinks_FixedUrl_Express_IconPic    ([SNAPI domain:SNLinks_Domain_CacheK url:@"img8/wb/iospicon/2012/04/10/1334050368429.png"])


#define SNLinks_FixedUrl_3gk                        [SNAPI domain:SNLinks_Domain_3gK url:nil]
#define SNLinks_FixedUrl_3gk_Mediain                [SNAPI domain:SNLinks_Domain_3gK url:@"mediain/index.jsp"]
#define SNLinks_FixedUrl_3gk_Mediain_night          [SNAPI domain:SNLinks_Domain_3gK url:@"mediain/index_night.jsp"]

#define kSearchSubUrl                       [SNAPI domain:SNLinks_Domain_Mp url:@"h5/subscribe/searchIndex?"]
#define FixedUrl_Subscribe                  [SNAPI domain:SNLinks_Domain_Mp url:@"h5/client/fe_app/index.html#/follow/recommend"]//[SNAPI domain:SNLinks_Domain_Mp url:@"h5/subscribe/index?v=1"]

#define FixedUrl_NewMe_SohuSignUp           [SNAPI domain:SNLinks_Domain_Mp url:@"v2/index#/signup/reg"] // 暂未启用
#define FixedUrl_NewMe_SohuLogin            [SNAPI domain:SNLinks_Domain_Mp url:@"v2/index#/login"] // 暂未启用


#define kUrlHttpsLogin                      ([SNPreference sharedInstance].testModeEnabled ? (@"http://192.168.132.83/mobile/gettoken") : ([SNAPI domain:SNLinks_Domain_Passport url:@"mobile/gettoken"]))
#define kUrlHttpsRegister                   ([SNPreference sharedInstance].testModeEnabled ? (@"http://192.168.132.83/mobile/reguser") : ([SNAPI domain:SNLinks_Domain_Passport url:@"mobile/reguser"]))
#define FixedUrl_Oauth_Passport             [SNAPI domain:SNLinks_Domain_Passport url:@"openlogin/request.action"]


#define SNLinks_DEFALUT_SUB_SERVER          ([SNPreference sharedInstance].testModeEnabled ? @"https://10.10.76.38" : @"http://live.k.sohu.com")

//#define SNLinks_FixedUrl_AdManager_TestPath ([SNAPI domain:SNLinks_Domain_TAdrd url:@"adgtr/"])
// 测试服广告地址 t.adrd.sohuno.com
//#define SNLinks_DEFALUT_AD_HOST             ([SNPreference sharedInstance].testModeEnabled ? SNLinks_FixedUrl_AdManager_TestPath : nil)

//手机搜狐网
#define SNLinks_FixedUrl_SohuMobile         ([SNAPI domain:SNLinks_Domain_M url:@"?_trans_=000010_khd_about"]) // webview

#define KUserPrivacyProtectPolicyUrl [SNAPI rootUrl:@"h5apps/settings/modules/settings/userSecret.html"]

#endif /* SNPublicLinks_h */
