//
//  SNStandardProtocol.h
//  sohunews
//
//  Created by yangln on 2017/7/24.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#ifndef SNStandardProtocol_h
#define SNStandardProtocol_h

/**
 <-------注：二代协议第一个参数是不能用？拼接的，如a://b?c=d,非二代协议，正确的格式为a://b=f&c=d   无参数二代协议必须包含有类似格式，如a://b=，否则会认为是非二代协议------->
 */
#pragma mark <-----------------------含有参数型二代协议----------------------->
/**
 协议描述：打开普通正文页
 完整示例：news://newsId=205931718&subId=277999&channelId=13557&isHasSponsorships=1&tracker=type:relevance@engine:rel_new&token=1500887561979&cmt=0&newstype=3
 @param newsId 新闻标识，必要参数
 @param subId 所属刊物标识
 @param channelId 所属频道
 @param isHasSponsorships 是否有冠名广告
 @param tracker 服务端传参，原样传回
 @param token 每篇新闻对应一个token
 @param cmt 评论数
 @param newsType 新闻类型，3图文，其他类型参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 */
#define kProtocolNews                       (@"news://")

/**
 协议描述：打开组图新闻
 同news:// 类型的新闻
 photo://有时含有gid，没有newsId，表示该组图新闻大图浏览含有相关推荐新闻
 */
#define kProtocolPhoto						(@"photo://")

/**
 协议描述：打开直播间
 完整示例：live://liveId=65925&mediaType=0&from=channel&channelId=2&isHasSponsorships=1&templateType=7&newsType=9
 @param liveId 直播间标识 必要参数
 @param mediaType 0普通文字直播，1视频片段，2音频，3视频直播]
 @param from=channel 固定参数
 @param channelId所属频道
 @param isHasSponsorships 是否有冠名广告
 @param templateType 各种模板，7比分直播模版，其他模版参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 @param newsType 新闻类型，9代表直播，其他类型参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 */
#define kProtocolLive                       (@"live://")

/**
 协议描述：打开专题新闻
 完整示例：special://termId=465472&from=channel&channelId=177
 @param termId 专题标识 必要参数
 @param from=channel 固定参数
 @param channelId 所属频道
 */
#define kProtocolSpecial					(@"special://")

/**
 协议描述：打开用户评论
 完整示例：feedback://ScreenShotFeedBack=YES&jsFeedBack=1&feedBackDict=
 @param ScreenShotFeedBack 打开客服小秘书
 @param jsFeedBack js控制用户评论中跳转哪个tab，可以取0，1，2
 @param feedBackDict 其他信息，字典格式
 */
#define kProtocolFeedback                   (@"feedback://")

/**
 协议描述：打开投票新闻
 完整示例：vote://newsId=15557845&from=channel&channelId=1&isHasSponsorships=1&position=3&page=1&templateType=1&newsType=12
 @param newsId 新闻标识 必要参数
 @param from=channel 固定参数
 @param channelId 所属频道
 @param isHasSponsorships 是否有冠名广告
 @param position 流内位置
 @param page 流内页码
 @param templateType 模板类型，1图文模板，其他模版参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 @param newsType 新闻类型，12投票新闻，其他类型参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 */
#define kProtocolVote                       (@"vote://")

/**
 协议描述：打开相应频道
 完整示例：channel://channelId=279&channelName=跑步&fromChannelId=2&position=0&templateType=1&newsType=8
 @param channelId 频道ID 必要参数
 @param channelName 频道名字 必要参数
 @param fromChannelId 从哪个频道跳转
 @param position 流内位置
 @param templateType 模板类型，1图文模板，其他模版参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 @param newsType 新闻类型，8外链新闻，其他类型参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 */
#define kProtocolChannel                    (@"channel://")

/**
 协议描述：打开全屏样式广告
 完整示例：landscape://url=https%3a%2f%2fwww.baidu.com
 @param url 落地页url 必要参数
 */
#define kProtocolLandscape                  (@"landscape://")

/**
 协议描述：打开扫一扫页面
 完整示例：scan://tab=image&refer=0&closeLastPage=1
 @param tab 扫描类型，image扫图，qr扫码 必要参数
 @param refer 来源，0其他，1首页流，2本地频道
 @param closeLastPage 0不关闭当前页面，1关闭当前页面
 */
#define kProtocolScanQrCode                 (@"scan://")

/**
 协议描述：打开优惠卷页面
 完整示例：coupon://back2url=
 @param back2url 优惠卷页面链接 必要参数
 */
#define kProtocolCoupon                     (@"coupon://")

/**
 协议描述：打开正文页蓝词搜索
 完整示例：search://type=0&words=%0d%0a%0d%0a%e5%ae%b9%e5%8e%bf&linkBottomTop=182&linkTop=131&noTriggerIOSClick=1
 @param type 搜索类型，0全部，3图文新闻，4组图新闻，9直播，13微博，10专题，11期刊，30订阅，14视频，60全网
 @param words 搜索内容 必要参数
 @param linkBottomTop 坐标，中间展开动画使用
 @param linkTop 坐标，中间展开动画使用
 @param noTriggerIOSClick h5拦截了navigationType事件，使用noTriggerIOSClick标记点击事件
 */
#define kProtocolSearch                     (@"search://")

/**
 协议描述：打开视频页面（老的协议仅视频频道有，不使用视频sdk播放；流内视频相关均由视频sdk播放，协议为videov2://开头）
 完整示例：video://vid=5158795&mid=31778877&columnId=4128&from=channel&channelId=36&isHasSponsorships=1&position=3&page=1&templateType=1&newsType=14
 @param vid 视频源标识 必要参数
 @param mid 视频的唯一标识
 @param columnId 栏目标识，属于哪个栏目
 @param from=channel 固定参数
 @param channelId 所属频道
 @param isHasSponsorships 是否含有冠名广告
 @param position 流内的位置
 @param page 流内页码，从服务端下发，属于第几页
 @param templateType 模板类型，1图文模板其他模版参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 @param newsType 新闻类型，14视频，其他类型参考wiki http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444
 */
#define kProtocolVideo                      (@"video://")

/**
 协议描述：打开离线视频下载页
 完整示例：videoDownload://kSNVideoDownloadViewMode=1
 @param kSNVideoDownloadViewMode 打开离线视频的某个tab，0已离线tab，1正在离线tab
 */
#define kProtocolVideoDownload              (@"videoDownload://")

/**
 协议描述：打开登录页面
 完整示例：login://backUrl=http%3A%2F%2Fapi.k.sohu.com%2Fh5apps%2Fcoupon.sohu.com%2Fmodules%2Fcoupon%2Fdetail.html%3FreceiveType%3D1%26tgId%3D77%26nc%3D1
 @param backUrl 登录成功后的跳转的页面
 注：由于二代协议需要正则验证，当无登录后跳转页面时，使用的协议为login://backUrl=否则会调不起登录页面
 */
#define kProtocolLogin                      (@"login://")

/**
 协议描述：打开频道预览页
 完整示例：previewchannel://channelId=460&channelName=%E8%80%81%E4%BA%BA&linkBottomTop=439&linkTop=422&noTriggerIOSClick=1
 @param channelId 频道ID 必要参数
 @param channelName 频道名字 必要参数
 @param linkBottomTop 坐标，中间展开动画使用
 @param linkTop 坐标，中间展开动画使用
 @param noTriggerIOSClick h5拦截了navigationType事件，使用noTriggerIOSClick标记点击事件
 */
#define kProtocolPreview                    (@"previewChannel://")

/**
 协议描述：打开分享浮层
 完整示例1：share://hideShareIcons=sohu,lifeCircle,copyLink&logstaisType=sns_profile&shareonInfo=profile_user_id%3D243189955013221120%26feed_id%3D%26shareType%3D1%26log_user_id%3Dyangln02%40sohu.com
 @param hideShareIcons 需要隐藏的分享平台
 @param logstaisType 标记sns类型页面
 @param shareonInfo 分享信息，sns拼接
 注：该种方式的二代协议为SNS使用样式，根据profile_user_id从shareon.go 获取分享信息，具体其他地方的分享调用与此处share://拼接不同，
 
 完整示例2：share://link=http%3A%2F%2F3g.k.sohu.com%2Fh5apps%2Factivity%2Fh5-forecast-activity%2Fshare_ques.html%3Fshare%3D1%26pid%3D5937831839602749555%26p1%3DNjI2NzYzMDAxMDc5MTAxNDQ4Ng%3D%3D%26gid%3D0101011106000143e8034a3ae17e9033adddea52c3a59e%26token%3D42e8a8e0b3762d0e06dbc5c29f86d29c%26activityId%3D6%26time%3D1501061678470%26u%3Djk67lvyzzng%26aid%3D6%26qid%3D41&title=傅园慧能否卫冕世锦赛50米仰泳冠军？&content=结局我已看破，你敢赌吗？&pics=http://3g.k.sohu.com/h5apps/activity/h5-forecast-activity/static/app/share-icon.png&shareOrigin=universalWebView&shareon=
 @param link 当前页面分享的url
 @param title 分享的标题
 @param content 分享的内容
 @param pics 分享的logo
 @param shareOrigin 分享来源
 @param shareon 该参数有值时，shareon.go会根据这个返回数据
 */
#define kProtocolShare                      (@"share://")

/**
 协议描述：快速分享，直接打开指定分享平台
 完整示例：fastShare://shareTo=moments&link=http%3A%2F%2F3g.k.sohu.com%2Fh5apps%2Factivity%2Fh5-forecast-activity%2Fshare_ques.html%3Fshare%3D1%26pid%3D5937831839602749555%26p1%3DNjI2NzYzMDAxMDc5MTAxNDQ4Ng%3D%3D%26gid%3D0101011106000143e8034a3ae17e9033adddea52c3a59e%26token%3D42e8a8e0b3762d0e06dbc5c29f86d29c%26activityId%3D6%26time%3D1501061678470%26u%3Djk67lvyzzng%26aid%3D6%26qid%3D41&title=傅园慧能否卫冕世锦赛50米仰泳冠军？&content=结局我已看破，你敢赌吗&pics=&shareOrigin=
 @param shareTo 要打开的分享平台 必要参数
 moments-微信朋友圈 weChat-微信好友 sohu-狐友 sina-新浪微博 qq-QQ qqZone-QQ空间 alipay-支付宝好友 lifeCircle-生活圈 copyLink-复制链接
 @param link 当前页面分享的url 必要参数
 @param title 分享的标题
 @param content 分享的内容
 @param pics 分享的logo
 @param shareOrigin 分享来源
 */
#define kProtocolFastShare                  (@"fastShare://")

/**
 协议描述：打开收藏页面
 完整示例：openCorpus://corpusId=0&folderName=我的收藏&id=455113789
 @param corpusId 对应收藏夹ID，默认为0
 @param folderName 收藏夹名字 必要参数
 @param id 所收藏新闻端ID
 注：当前仅支持调起收藏页面，不支持tab跳转
 */
#define kProtocolOpenCorpus                 (@"openCorpus://")

/**
 协议描述：打开天气页面
 完整示例：weather://channelId=137&weather_city=安庆&weather_gbcode=340800
 @param channelId 所属频道标识
 @param weather_city 城市名字
 @param weather_gbcode 城市代码
 weather_city与weather_gbcode若为空，则打开当前所在城市的天气页面
 */
#define kProtocolWeather                    (@"weather://")

/**
 协议描述：服务端可控的弹窗
 完整示例：popup://msg=123&leftbutton=left&leftaction=close&rightbutton=right&rightaction=http://ww.baidu.com
 @param msg  弹窗消息题
 @param leftbutton 弹窗左标题
 @param leftaction 弹窗左按钮事件，赋值为一个协议，若为close，则关闭弹窗(若含有参数，需要encode)
 @param rightbutton 弹窗右标题
 @param rightaction 弹窗右按钮事件，赋值为一个协议(若含有参数，需要encode)
 
 */
#define kProtocolPopup                      (@"popup://")

/**
 协议描述：全屏视频 用户画像
 完整示例：videoFullScreen://site2=0&playById=1&vid=222222&site=2&url=***&tvid=&posInfo={x:1,y:1,width:1,height:1}
 @param site2 对应搜狐主站下的3个来源站的ID， 1搜狐视频，2播客，3直播，这个参数用来告诉播放器SDK， vid是何种类型的视频的ID
 @param playById 是否按ID来播放视频，1是，0否
 @param vid 视频源标识 必要参数
 @param site 视频sdk需要参数，默认为2 必要参数
 @param url 视频源url
 @param tvid 视频源标识2
 @param posInfo 位置信息，字典格式
 */
#define kProtocolVideoFullScreen            (@"videofullscreen://")

/**
 协议描述：h5调用分享到支付宝、生活圈
 完整示例：sharethirdpart://to=alipaylife&link=&icon=&titlte=&content=
 @param to 分享平台 必要参数
 alipaylife 生活圈 alipayfriends 支付宝
 @param link 分享的链接
 @param icon 分享展示的logo链接
 @param title 分享标题
 @param content 分享内容
 */
#define kProtocolSharethirdpart                     (@"sharethirdpart://")

/**
 协议描述：打开小说的章节列表
 完整示例：chapterlist://novelId=171827759
 @param novelId 小说标识 必要参数
 */
#define kProtocolStoryChapterList                  (@"chapterlist://")

/**
 协议描述：打开小说某一章节
 完整示例：readchapter://novelId =171827759&chapterIndex=12
 @param novelId 小说标识 必要参数
 @param chapterIndex 第几章
 */
#define kProtocolStoryReadChapter                  (@"readchapter://")

/**
 协议描述：打开小说详情页
 完整示例：noveldetail://novelId=171827759
 @param 小说标识 必要参数
 */
#define kProtocolStoryNovelDetail                  (@"noveldetail://")

/**
 协议描述：小说详情页全部评论
 完整示例：novelDetailAllComments://link=
 @param link 页面链接 必要参数
 */
#define kProtocolStoryNovelDetailAllComments       (@"novelDetailAllComments://")

/**
 协议描述：小说发现更多页面
 完整示例：novel://link=http://api.k.sohu.com/h5apps/novel.sohu.com/modules/novel/novel.html&novelId=171827759
 @param link 页面链接 必要参数
 @param novelId 小说标识
 */
#define kProtocolStoryNovel                        (@"novel://")

/**
 协议描述：小说运营标签
 完整示例：noveloperate://tagId=67&name=江湖女侠&channelId=960415
 @param tagId 标签标识
 @param name 小说名字 必要参数
 @param channelId 所属频道ID
 */
#define kProtocolStoryOperate                     (@"noveloperate://")

/**
 协议描述：小说分类标签
 完整示例：novelclassify://tagId=1&name=玄幻仙侠
 @param tagId 标签标识
 @param name 小说名字 必要参数
 */
#define kProtocolStoryClassify                    (@"novelclassify://")

/**
 协议描述：新闻tab跳转
 完整示例：tab://tabName=snsTab
 @param tabName 底部tab名字 必要参数
 newsTab新闻，videoTab视频，snsTab狐友，myTab我的
 */
#define kProtocolTab                        (@"tab://")

/**
 协议描述：打开AR游戏页面
 完整示例：thirdparty://activityID=3&contentType=web
 @param activityID AR游戏样式，参数由大数据定义 必要参数
 @param contentType 启动AR的位置
 */
#define kProtocolThirdParty                 (@"thirdparty://")

/**
 协议描述：打开全屏广告
 完整示例：fullscreen://url=https%3a%2f%2fwww.baidu.com
 @param url 落地页地址 必要参数
 
 */
#define kProtocolFullScreen                 (@"fullscreen")

#pragma mark <-----------------------第三方相关二代协议（SNS、视频SDK、千帆SDK）----------------------->
/**
 协议描述：打开视频sdk详情页
 完整示例：videov2://vid=90826736&from=channel&channelId=1&site=2
 @param vid 视频源标识 必要参数
 @param from=channel 固定参数
 @param channelId 所属频道
 @param site 视频sdk需要参数，默认为2 必要参数
 注：site值传错，会导致视频不能播放，出现请稍后再试页面
 */
#define kProtocolVideoV2                    (@"videov2://")

/**
 协议描述：正文页评论，点击浮层上私信功能（SNS页面）
 完整示例：sns://privatemessage/open/%7B%22passport_id%22:%2218638870388@sohu.com%22,%22avatar%22:%22%22,%22name%22:%22186***846915%22,%22feedData%22:%7B%22comment_id%22:1157768302,%22content%22:%22%E5%B9%B3%E6%97%B6%E7%A4%BE%E4%BC%9A%E9%A3%8E%E6%B0%94%E4%B8%8D%E6%AD%A3%EF%BC%8C%E6%89%A7%E6%B3%95%E4%B8%8D%E4%B8%A5%EF%BC%8C%E4%BA%BA%E4%B8%8D%E7%95%8F%E6%B3%95%EF%BC%8C%E6%89%80%E4%BB%A5%E6%89%8D%E4%BC%9A%E5%87%BA%E7%8E%B0%E7%9B%97%E6%8A%A2%22,%22news_id%22:%22212932035%22%7D%7D
 @param 这种协议格式为SNS特有，直接透传，open/拼接的是一个字典
 */
#define kSohuNewsPrivatemessage             (@"sns://privatemessage/open/")

/**
 协议描述：打开个人中心profile页（SNS页面）
 完整示例：userInfo://pid=5937831839602749555&fromPush=1
 @param pid 当前登录用户的pid 必要参数
 @param fromPush 标记来自于push
 */
#define kProtocolUserInfoProfile            (@"userInfo://")

/**
 协议描述：打开刊物profile页（SNS页面）
 完整示例：subHome://subId=326
 @param subId 刊物标识 必要参数
 注：直接将该协议整个透传sns，客户端不作处理
 */
#define kProtocolSubHome                    (@"subHome://")

/**
 协议描述：打开SNS相关页面（SNS页面）
 完整示例：sns://userInfoEdit/{"snsTab":"1"}
 @param userInfoEdit 个人资料编辑页，后面拼接的为字典
 @param snsTab 1代表跳转狐友tab
 
 sns://openEachAddressBook/{"snsTab":"1"}
 @param openEachAddressBook 互关通信录页面，后面拼接的为字典
 注：直接将该协议整个透传sns，客户端不作处理(该协议主要在端内使用)
 @param snsTab 1代表跳转狐友tab
 
 sns://user/login/{"snsTab":"1"}
 @param login 调起登录页面
 @param snsTab 1代表跳转狐友tab
 
 sns://backToSNSRoot/
 @param backToSNSRoot 跳转狐友tab
 
 */
#define kProtocolSNS                        (@"sns://")

/**
 协议描述：打开SNS相关页面（SNS页面）
 完整示例：sohusns://userInfoEdit/{"snsTab":"1"}
 @param userInfoEdit 个人资料编辑页，后面拼接的为字典
 @param
 注：直接将该协议整个透传sns，客户端不作处理(该协议主要在端外使用)
 */
#define kSchemeUrlSNS                       (@"sohusns://")

/**
 协议描述：打开千帆直播(协议中第一个参数拼接为？，不能经过正则验证，是非二代协议)
 完整示例：qfsdk://action.cmd?action=1.0&partner=10051&roomid=2036452
 @param action 区分事件
 @param partner 渠道号
 @param roomid 直播房间号 必要参数
 注：协议透传，客户端不作处理
 */
#define kProtocolSohuQFLive                         (@"qfsdk://")

#pragma mark <-----------------------无需参数型二代协议----------------------->
//注：由于二代协议需要经过正则验证，故需拼接任意一个参数
/**
 协议描述：返回新闻tab中要闻频道
 完整示例：newsTab://tab=
 */
#define kProtocolNewsTab                    (@"newsTab://")

/**
 协议描述：打开手机绑定页面
 完整示例：telbind://tel=
 */
#define kProtocolTelBind                    (@"telbind://")

/**
 协议描述：打开系统定位设置
 完整示例：openSysLocation://location=
 注：iOS8以上支持
 */
#define kProtocolOpenSysytemLocation         (@"openSysLocation://")

/**
 协议描述：打开搜狐视频
 完整示例：sohuvideo://video=
 */
#define kProtocolSohuVideo                  (@"sohuvideo://")

/**
 协议描述：打开阅读历史页面
 完整示例：readhistory://history=
 */
#define kProtocolReadHistory                         (@"readhistory://")

/**
 协议描述：打开意见反馈输入页面
 完整示例：feedbacksubmit://submit=
 */
#define kProtocolFeedBackEdit               (@"feedbacksubmit://")

/**
 协议描述：小说书币充值历史纪录
 完整示例：rechargehistory://history=
 */
#define kProtocolStoryRechargeHistory             (@"rechargehistory://")

/**
 协议描述：小说书币充值页面
 完整示例：rechargecenter://center=
 */
#define kProtocolStoryRechargeCenter              (@"rechargecenter://")

#pragma mark <-----------------------其他----------------------->

/**
 协议描述：以http开头的新闻、广告
 */
#define kProtocolHTTP						(@"http://")

/**
 协议描述：以https开头的新闻、广告
 */
#define kProtocolHTTPS                      (@"https://")

/**
 协议描述：端外调起客户端，打开新闻协议
 @param sohunewsiphone://pr/ 前缀，后面拼接二代协议
 现在已使用新的sohunews://pr/ 前缀
 h5已做判断iOS9.2之前的调起使用sohunews://pr/ 拼接二代协议的形式，新的系统版本使用的是universal links调起
 */
#define kSohuNewsIphoneNews                 (@"sohunewsiphone://pr/news://")
#define kSohuNewsIphonePhoto                (@"sohunewsiphone://pr/photo://")
#define kSohuNewsIphoneVote                 (@"sohunewsiphone://pr/vote://")

/**
 协议描述：端外回流样式
 完整示例：sohunews://pr/news://newsId=234563
 @param pr/后面拼接协议
 */
#define kProtocolBackFlow                   (@"sohunews://pr/")

#pragma mark <-----------------------二代协议公共参数定义----------------------->
/*
http://applink.k.sohu.com/?url=news%3a%2f%2fnewsId%3d205931718%26subId%3d277999%26channelId%3d13557%26backApp%3durl%253dweibo%253a%252f%252f%2526title%253d%25e8%25bf%2594%25e5%259b%259e%25e5%25be%25ae%25e5%258d%259a
sohunews://pr/news://newsId=205931718&subId=277999&channelId=13557&ignoreLoadingAd=1&backApp=url%3dweibo%3a%2f%2f%26title%3d%e8%bf%94%e5%9b%9e%e5%be%ae%e5%8d%9a
*/

#pragma mark <-----------------------废弃协议----------------------->

#define kProtocolPaper						(@"paper://")
#define kProtocolDataFlow					(@"dataFlow://")
#define kProtocolReadCircleDetail           (@"userAct://")
#define kProtocolFILE						(@"file://")
#define kProtocolSub						(@"sub://")
#define kProtocolWeibo                      (@"weibo://")
#define kProtocolJoke                       (@"joke://")
#define kProtocolNewsChannel                (@"newsChannel://")
#define kProtocolWeiboChannel               (@"weiboChannel://")
#define kProtocolPhotoChannel               (@"groupPicChannel://")
#define kProtocolLiveChannel                (@"liveChannel://")
#define kProtocolPlugin                     (@"plugin://")
#define kProtocolComment                    (@"comment://")
#define kProtocolOrgHome                    (@"orgHome://")
#define kProtocolOrgColumn                  (@"orgColumn://")
#define kProtocolQRCode                     (@"qrcode://")
#define kProtocolVideoMidia                 (@"videoMedia://")
#define kProtocolVideoPerson                (@"videoPerson://")
#define kProtocolMySubs                     (@"mySubs://")
#define kProtocolSubscirbe                  (@"subscirbe://")
#define kProtocolUnsubscirbe                (@"unsubscirbe://")
#define kJumpToSNS                          (@"tab://tabName=snsTab")
#define kPushHistory                         (@"pushHistory://")
#define kUserPortrait                        (@"userportrait://")

#endif /* SNStandardProtocol_h */
