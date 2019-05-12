//
//  SNReportConsts.h
//  sohunews
//
//  Created by yangln on 2016/12/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#ifndef SNReportConsts_h
#define SNReportConsts_h

typedef NS_ENUM(NSInteger, ShareTargetType) {
    ShareTargetUnknown          = 0,        // 未知
    ShareTargetWeixinFriend     = 1,        // 通过微信分享
    ShareTargetWeixinTimeline   = 3,        // 微信朋友圈
    ShareTargetQQ_friends       = 4,        // QQ联系人
    ShareTargetSNS              = 2,        // 通过微博、社交网站分享
    ShareTargetSMS              = 5,        // 通过短信分享
    ShareTargetMail             = 6,        // 通过邮件分享
    ShareTargetEvernote         = 7,        // 保存印象笔记 已经不再使用
    ShareTargetQZone            = 8,        // 分享到QQ空间
    ShareTargetSohu             = 9,        // 分享到搜狐
    ShareTargetAPSession        = 10,       // 分享到支付宝会话
    ShareTargetAPTimeLine       = 11,       // 分享到支付宝生活圈
};

//wangshun 修改 #define kShareReportParams @"stat=s&s=%@&%@=&st=%@&stid=%@&sc=%@&subid=%@"
//去掉一个参数 weixin= 因为安卓没有
#define kShareReportParams @"stat=s&s=%@&st=%@&stid=%@&sc=%@&subid=%@"

// 正文 组图新闻 pv统计
#define kAnalyticsUrlNewsContentPv @"_act=read&_tp=pv&_page=%d&_refer=%d&newsId=%@"
// 正文 组图新闻 阅读时常 统计
#define kAnalyticsUrlNewsContentRead @"_act=read&_tp=tm&_page=%d&ttime=%d&isEnd=%@"
#define kAnalyticsUrlCC  @"_act=cc&page=%@&topage=%@&fun=%d"
#define kAppOpenAnalyzeUrl @"a=1&b=1&s1=%@&s2=%@&s0=%@"
//直播间时长
#define kLiveRoomDuration @"_act=live&_tp=read&liveId=%@&stime=%f&channelId=%@"

#endif /* SNReportConsts_h */
