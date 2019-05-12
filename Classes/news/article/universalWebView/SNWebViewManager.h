//
//  SNWebViewManager.h
//  sohunews
//
//  Created by yangln on 2017/2/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UniversalWebViewType) {
    NormalWebViewType,//普通webview
    AdvertisementWebViewType,//广告
    SpecialWebViewType,//专题
    ChannelPreviewWebViewType,//频道预览
    StockMarketWebViewType,//股票行情
    StockChannelLoginWebViewType,//股票登录页面
    InterlligentOfferWebViewType,//智能报盘
    RedPacketWebViewType,//红包活动页面
    RedPacketTaskWebViewType,//任务红包活动页面
    ActivityWebViewType,//活动页面
    MyTicketsListWebViewType,//我的优惠券列表页面
    ReportWebViewType,//新版举报页面
    ReadHistoryWebViewType, //历史页面
    ApplicationSohuWebViewType,//申请搜狐号页面
    FeedBackWebViewType, // 反馈问题页面
    UserPortraitWebViewType,//用户画像
    FictionWebViewType,//小说页面
    TimeFreeWebViewType,//限时免费小说
    FullScreenADWebViewType,//全屏广告 2017.8
};

@interface SNWebViewManager : NSObject

/**
 参数传递
 */
- (void)processWebViewWithDict:(NSDictionary *)dict;

/**普通 webview（普通的url）
 广告
 推广
 外链
 申请公众号
 订阅搜索页面
 ...
 */
- (void)openNormalWebView;

/**JSKit webview（H5模板相关）
频道预览
股票详情页
活动
优惠卷
专题
阅读历史
新闻推送
用户画像
举报
...
*/
- (void)openJSKitWebView;

@end
