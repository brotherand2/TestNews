//
//  SNAnalyticsConsts.h
//  sohunews
//
//  Created by jojo on 13-12-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNAnalyticsConsts_h
#define sohunews_SNAnalyticsConsts_h

// 4.0 新的cc pv统计 常量
// wifi : http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=7472467

// page
typedef enum {
    SNCCPVPageStart = -1,
    
    splash = 0, // loading页
    
    tab_news = 1, // 及时新闻TAB
    tab_video = 2, // 视频TAB
    tab_sub = 3, // 订阅TAB
    tab_me = 4, // 我TAB
    
    special = 5, // 专题首页
    live = 6, // 直播
    
    live_statistic = 7,  // 直播统计
    weiboDetail = 8,  // 微热议
    
    videoDetail = 9, // 视频新闻
    
    weather_main = 10,  // 天气页面
    
    sohu_http_web = 11,  // 外链
    channel_edit = 12, // 频道编辑页
    video_column_manage = 13, // 热播管理
    
    article_detail_txt = 14, // 图文新闻正文页
    article_detail_pic = 15, // 组图新闻正文
    article_full_pic = 16, // 大图浏览页面
    
    comment_list = 17, // 评论界面
    comment_reply = 18, // 评论回复页面
    circle_comment = 19, // 阅读圈评论页面
    search = 20, // 搜索界面
    share = 21, // 分享界面
    
    paper_main = 22, // 刊物首页
    paper_history = 23, // 刊物历史页
    paper_2dimensional = 24, // 二维码页
    paper_valuation = 25, // 刊物评价页
    paper_detail = 26, // 刊物详情页
    paper_yiy = 27, // 摇一摇页面
    paper_square = 28, // 广场页面
    
    city_setting = 29, // 城市设置
    city_manager = 30, // 城市管理
    
    more_offline = 31, // 离线下载页面
    more_message = 32, // 消息页
    more_favorite = 33, // 收藏页
    more_app = 34, // 应用推荐
    more_user = 35, // 用户中心
    more_setting = 36, // 设置页面
    more_offline_setting = 37, // 离线媒体设置
    more_about = 38, // 关于页面
    more_feedback = 39, // 意见反馈
    more_disclaimer = 40, // 免责声明页面
    more_setting_push = 41, // 消息通知设置页
    more_mediaplat = 42, // 媒体平台页
    more_offline_content = 43, // 离线内容页
    
    profile_frends_attention = 44, // 关注页面
    profile_fans_list = 45, // 粉丝页面
    profile_add_frends = 46, // 添加好友页面
    profile_user_edit = 47, // 个人信息编辑页
    
    login_sso = 48, // sso登录页面
    login_sohu = 49, // 搜狐登录页面
    login_halfdome = 50, // 半屏登录页面
    
    notify_push = 52, // 通知栏 push
    
    android_widget = 52, // widget页
    android_subshortcut = 53, // 桌面快捷方式
    android_third = 54, // 第三方
    
    video_full = 55, //全屏播放视频页
    circle_detail = 56, // 阅读圈详情页面
    
    profile_user_event = 57, // "我"tab 活动页面
    
    video_activities = 58, // 视频tab打开的活动页面（具体哪个页面未知，只能确定二代link）
    video_apps = 59, // 视频tab打开的换量app页面 （具体页面未知，只能确定二代link）
    video_media = 60, // 视频媒体栏目
    video_banner = 61, // 视频tab中banner
    
    myrsslist = 63, //我的订阅
    fingersearch_ios = 64, //指尖搜索
    
    video_sohuPGC = 66,  //流内首页PGC视频
    sohu_qfLive =67,    //流内千帆直播

}SNCCPVPage;

// function
typedef enum {
    f_unknow = -1,
    f_subscribe = 0, // 订阅
    f_unsubscribe = 1, // 退订
    f_open = 2, // 打开
    f_uninterested = 3, // 不感兴趣
    f_expansion = 4, // 展开
    f_shrink = 5, // 收起
    
    f_login = 6, // 登陆
    f_login_cc_half = 7, // 半屏的登陆页面曝光
    
    f_delete = 8, // 删除操作
    f_comment = 9, // 评论
    f_reply = 10, // 回复
    f_get_more = 11, // 查看更多
    f_select = 12, // 选择
    f_live_recommend = 13, // 直播相关推荐
    f_slide_reading = 14, // 新闻正文页连续阅读
    f_expression_click = 15, // 表情按钮点击
    f_sort_click = 16, // 排序按钮点击
    f_intimenews_more = 17, // 新闻频道流更多
    f_intimenews_uninterest = 18, // 不感兴趣按钮点击
    f_intimenews_fav = 19, // 收藏
    f_activity_Shoot = 20, // 射门
    f_live_bigemotion = 21, // 大表情
    f_live_smallemotion = 22, // 小表情
    f_search_getmore = 23 ,// 搜索全部栏目中点击每项更多按钮
    f_search_getallinter = 24,//搜索全网数据中点击每一项
    f_template = 25,//个性化模板点击
    f_search_sougou_search = 26,//搜索搜狗选项点击 (26_icon的位置)
    f_sougou_hotword = 27,//搜狗热词点击
    f_sougou_changeword = 28,//  搜索热词换一换点击
    f_subject_open = 29,//聚合专题内容点击展开
    f_moblie_binding = 33,//手机绑定
    f_moblie_binded_success = 34, //手机绑定成功
    f_channel_edit_finish = 35, //频道编辑完成
    f_acticle_logo = 36,//正文页logo点击返回
    f_out_news = 37,//查看无版权新闻清新版
    f_into_user = 38,//进入用户中心
    f_change_city = 39, // 切换定位城市 v5.2.0
    f_joke_praise = 71, // 段子好文
    f_joke_listen = 72, // 段子听新闻
    
}SNCCPVFuction;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// enum value from http://10.13.81.60:8090/pages/viewpage.action?pageId=2163985

// page
typedef enum {
    p_notify = 1, // 通知栏
    p_box = 2, // 收件箱
    p_intime_news = 3, // 及时新闻列表
    p_rss = 4, // 订阅中心
    p_myrss = 5, // 订阅中心（我的订阅区域）
    p_rss_list = 6, // 订阅中心 （推荐列表区域）
    p_group_channel = 7, // 组图频道
    p_papep_main = 8, // 刊物首页
    p_news_text = 9, // 文本新闻正文
    p_more_setting = 10, // 更多/设置
    p_hot_comment = 11, // 最热评论
    p_new_comment = 12, // 最新评论
    p_feedback = 13, // 意见反馈
    p_weather = 14, // 天气
    p_share = 15, // 分享
    p_icon = 16, // 图标
    p_loading = 17, // loading
    p_video = 18, // 视频新闻
    p_list_pic = 19, // 组图新闻
    p_full_pic = 20, // 组图全屏
    p_paper = 21, // 报纸
    p_news_video = 22, // 视频新闻
    p_live_text = 23, // 直播内容页面
    p_special = 24, // 专题页面
    p_sohu_web = 25, // SOHU webView打开的页面(外链新闻)
    p_tab = 26, // SOHU 上次退出的页面（默认是订阅中心）
    p_edit = 27, // 编辑按钮
    p_favorite = 28, // 收藏
    p_night = 29, // 夜间
    p_pic = 30, // 有图模式
    p_app = 31, // 应用推荐
    p_comment = 32, // 评论页面
    p_update = 33, // 检查更新
    p_about = 34, // 关于
    p_exit = 35, // 退出
    p_day = 36, // 日间
    p_nopic = 37, // 无图模式
    p_nickname = 38, // 修改昵称
    p_reply = 39, // 回复
    p_font = 40, // 字体大小
    p_ding = 41, // 顶
    p_send = 42, // 发送，提交，确定
    p_alert = 43, // 直播间设置提醒
    p_noalert = 44, // 直播间取消提醒
    p_live_content = 45, // 直播间实况直播
    p_live_comment = 46, // 直播间边看边聊
    p_show_pic = 47, // 显示图片
    p_pichot = 48, // 组图推荐
    p_pichotpage = 49, // 组图推荐页面
    p_list_picmore = 50, // 组图更新数据
    p_download = 51, // 下载按钮
    p_show = 52, // 显示简介
    p_hide = 53, // 隐藏简介
    p_setting_fontsize = 54, // 文字大小
    p_setting_fontmode = 55, // 文字模式
    p_setting_picmode = 56, // 图片模式
    p_setting_nightmode = 57, // 日间夜间模式
    p_setting_offline = 58, // 离线下载
    p_setting_wifioffline = 59, // WIFI离线下载
    p_setting_push = 60, // 刊物
    p_setting_flash = 61, // 快讯
    p_setting_ring = 62, // 铃声
    p_setting_gprs = 63, // 流量统计
    p_setting_clearcache = 64, // 清除缓存
    p_setting_user = 65, // 用户中心
    p_setting_weibo = 66, // 帐户绑定
    p_widget = 67, // WIDGET
    p_widget_weather = 68, // 天气
    p_widget_news = 69, // 新闻
    p_widget_pre_news = 70, // 上一篇
    p_widget_next_news = 71, // 下一篇
    p_news_picmode = 72, // 大小图模式
    p_weather_getdata = 73, // 获取天气
    p_city = 74, // 城市设置
    p_gps = 75, // 城市定位
    p_navigation = 76, // 城市导航
    p_like = 77, // 猜你喜欢
    p_micronews=78, //微新闻
    p_offlinedownloadauto = 79, // 离线自动下载
    p_offlinedownload = 80, // 离线手动下载
    p_offline = 81, // 离线下载界面
    p_search = 82, //搜索界面
    p_paper_info = 83, //刊物信息界面
    p_one_level_paper = 84,//一级大报纸页面（针对iPad）
    p_two_level_paper = 85,//二级报纸页面（针对iPad）
    p_tile_page = 86, //磁片页面（针对iPad）
    p_weiboHot = 87, // 微热议
    p_live_audio = 88, // 直播间- 音频
    p_live_video = 89, // 直播间- 视频
    p_live_history = 90, // 直播频道 往期
    p_live_statistics = 91, // 直播间- 技术统计
    p_live_full_screen = 92, // 直播间- 全屏模式
    p_live_small_screen = 93, // 直播间- 收起模式
    p_notify_leaveuser = 94, // 提醒长时间没打开客户端用户
    p_channel_edit = 95, // 频道编辑
    p_mymessage = 96, // 我的消息页面。
    p_myaccount = 97, // 我的账号页面。
    p_news_spread = 98, // 图文新闻推广。
    p_news_chot = 99, // 图文新闻推荐。
    p_news_nightmode = 100, // 新闻正文中的日间夜间模式
}SNUserActionPage;

// function enum for cc & pv
typedef enum {
    SNUserActionFunctionUnknow          = -1,   // 初始定义
}SNUserActionFunction;

// section
typedef enum {
    s_loading_fling_in = 1, // 滑动进入
    s_loading_time_in = 2, // 倒计时进入
    s_loading_detail = 3, // 点击详细
    s_loading_select = 4, // 复选框勾选/去默认勾选
    
    s_news_head = 5, // 新闻头部
    s_news_hot_comment = 6, // 新闻热点评论
    s_intime_list_head = 7, // 及时新闻头部
    s_intime_list_focus = 8, // 及时新闻焦点新闻
    s_intime_list_item = 9, // 及时新闻列表项
    s_page_top = 10, // 顶
    s_page_middle = 11, // 中间
    s_page_bottom = 12, // 底
    s_page_menu = 13, // 菜单
    s_pic_recommend = 14, // 组图相关推荐
    s_search_result_list = 15 //搜索结果列表
}SNUserActionSction;

// action
typedef enum {
    ACTION_CLICK = 1, // 单击事件
    
    ACTION_FLING = 2, // 滑动事件
    
    ACTION_DRAG = 3, // 拖拽事件
    
    ACTION_LONG_CLICK = 4, // 长按事件
    
    ACTION_DOUBLE_CLICK = 5, // 双击事件
    
    ACTION_MENU = 6, // menu事件
    
    ACTION_TIMER = 7 // 定时器触发
}SNUserActionAction;

typedef enum {
    REFER_NOTIFY = 1,  // 通知
    REFER_INBOX = 2,  // 收件箱
    REFER_ROLLINGNEWS = 3,  // 及时新闻
    REFER_SUBCENTER = 4,  // 订阅中心
    REFER_SUBCENTER_MYSUB = 5,  // 订阅中心（我的订阅区域）
    //REFER_SUBCENTER_RECOMMENDLIST = 6,  // 订阅中心 （推荐列表区域）
    REFER_GROUPPHOTO = 7,  // 组图频道
    REFER_PUB_HOME = 8,  // 刊物首页
    REFER_ARTICLE = 9,  // 新闻正文
    REFER_MORE = 10,  // 更多/设置
    REFER_HOT_COMMENT = 11,  // 最热评论
    REFER_LATEST_COMMENT = 12,  // 最新评论
    REFER_FEEDBACK = 13,  // 意见反馈
    REFER_WEATHER = 14,  // 天气
    REFER_SHARE = 15,  // 分享
    REFER_ICON = 16,  // icon
    REFER_LOADING = 17,  // loading
    REFER_VIDEO = 18,  // 视频
    REFER_GROUPPHOTOLIST = 19,  // 组图列表
    REFER_PHOTOLISTNEWS = 20,  // 组图新闻
    REFER_PAPER = 21,  // 刊物（报纸）
    REFER_WIDGET = 22,  // widget
    REFER_WEIHOT = 23,  // 微热议
    REFER_LIVE = 24,  // 直播
    REFER_SHAKE = 25 ,  // 摇一摇
    REFER_PUBRECOMMEND = 26 ,  // 刊物推荐
    //REFER_UNSUBRECOMMEND = 27 ,  // 退订后推荐
    REFER_RANK = 28 ,  // 排行
    REFER_SUBCENTER_RECOMMENDLIST = 29,
    REFER_SPECIALNEWSLIST = 30,  // 专题
    REFER_AD = 31,  // 广告
    REFER_SUBCENTER_PROMOTION = 32,  // 订阅中心运营位
    REFER_PUB_INFO = 33,  // 马上阅读页（我要订阅）
    REFER_PAPER_SUBBTN = 34,  // 刊物/报纸（右上角订阅+按钮）
    REFER_SEARCH = 35,  // 搜索
    REFER_SEARCH_HOTWORDS = 36, // 搜索热词
    REFER_READ_CIRCLE = 37, // 阅读圈
    REFER_FOLLOW = 38, // 关注
    REFER_TIPS = 39, // 即时新闻 刷新tips
    REFER_VIDEO_TAB = 40, // 视频tab
    REFER_SUB_TAB = 41, // 首页tab
    REFER_SUB_DETAIL = 42, // 刊物详情
    REFER_LOADING_H5 = 43, // landing page (H5)
    REFER_BACK_THIRD_APP = 44,//返回第三方APP
}SNReferFrom;

typedef enum {
    SNReferActCommentText = 1, // 文字评论
    SNReferActCommentAudio = 2, // 语音评论
    SNReferActCommentPic = 3, // 图片评论
    SNReferActSubscribe = 4, // 订阅
    SNReferActShare = 5, // 分享
    SNReferActFollow = 6, //关注
}SNReferAct;


#endif
