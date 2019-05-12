//
//  SNInterceptConsts.h
//  sohunews
//
//  Created by jojo on 13-12-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNInterceptConsts_h
#define sohunews_SNInterceptConsts_h

// 用户行为拦截  埋点数据

// 搜索结果订阅按钮
#define kUserActionIdForSearchSubAction             (@"1101")

// 摇一摇订阅按钮
#define kUserActionIdForSubShakeSubButton           (@"1102")

// 订阅中心订阅按钮
#define kUserActionIdForSubCenterSubAction          (@"1103")

// 刊物首页订阅按钮
#define kUserActionIdForPaperSubAction              (@"1104")

// 新闻正文页订阅按钮
#define kUserActionIdForArticleSubAction            (@"1105")

// 进入订阅广场
#define kUserActionIdForEnterSubCenterAction        (@"1106")

// 正文页评论
#define kUserActionIdForArticleComment              (@"1201")

// 组图浏览模式评论
#define kUserActionIdForSlideShowComment            (@"1202")

// 微闻评论
#define kUserActionIdForWeiboHotComment             (@"1203")

// 直播间边看边聊
#define kUserActionIdForLiveChat                    (@"1204")

// 写媒体刊物的评论
#define kUserActionIdForMediaPaperComment           (@"1205")

// 刊物info页评论按钮
#define kUserActionIdForSubDetailComment            (@"1206")

// 一键离线按钮
#define kUserActionIdForDownloadAllSub              (@"1301")

// 刊物首页离线按钮
#define kUserActionIdForPaperDownload               (@"1302")

// 新闻编辑频道
#define kUserActionIdForNewsChannelEdit             (@"1401")

// 视频编辑频道
#define kUserActionIdForVideoChannelEdit            (@"1402")

// 使用摇一摇
#define kUserActionIdForSubShake                    (@"1501")

// 新手引导页面展示完成
#define kUserActionIdForUserGuide                   (@"1601")

// 用户中心立即登录
#define kUserActionIdForUserCenterLogin             (@"1704")

// 用户中心消息
#define kUserActionIdForUserCenterMessage           (@"1702")

// 用户中心收藏
#define kUserActionIdForUserCenterFaverite          (@"1703")

// 用户中心 空内容引导登陆按钮
#define kUserActionIdForUserCenterGuideLogin        (@"1701")

// 客户端行为 对应的代号

// 功能Id
// 弹出半屏登录框
#define kUserActionInterceptClientActionGuideLogin      (@"f101")

// 直接自动sso登录
#define kUserActionInterceptClientActionDoSSO           (@"f102")

//  弹出绑定手机号框（未绑定时才会下发）
#define kUserActionInterceptClientActionBindMobileNum   (@"f103")

#endif
