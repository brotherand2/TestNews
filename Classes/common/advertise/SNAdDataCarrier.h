//
//  SNAdDataCarrier.h
//  sohunews
//
//  Created by jojo on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STADManagerForNews.h"
#import "SNAdvertiseConfigs.h"

typedef UIView * (^GetDataAction)(id dataCarrier, BOOL needRender);

typedef enum {
    SNAdDataStateUnkonw,
    SNAdDataStatePending,           // 正在拉取数据
    SNAdDataStateFailed,            // 获取数据失败
    SNAdDataStateReady,             // 成功加载广告
}SNAdDataState;

@class SNAdInfo;

@interface SNAdDataCarrier : NSObject

@property (nonatomic, weak) id delegate;

// 当前广告数据拉取情况
@property (nonatomic, assign) SNAdDataState dataState;

//错误类型
@property (nonatomic, assign) kStadErrorForNewsType errorType;

// 广告显示控件 （不需要关心是什么view）
@property (nonatomic, strong) UIView *adView;

// 由于广告sdk不会处理所有的点击事件 需要包一层view来作点击
@property (nonatomic, strong) UIView *adWrapperView;

// 是否需要禁用掉夜间模式 
@property (nonatomic, assign) BOOL shouldIgnoreNightMode;

@property (nonatomic, weak) id adViewTapDelegate;

//广告频道id
@property (nonatomic, strong) NSString *newsChannel;

//渠道号
@property (nonatomic, strong) NSString *appChannel;

@property (nonatomic, strong) NSString *gbcode;

/** 包含广告的分享语、标题等等可能需要的数据
 *  目前已知的key
 *  share_txt : 分享语
 *  ad_txt : 广告语
 *  click_url : 跳转连接
 *  ad_image : 图片资源本地地址
 *  nopic_txt : 无图模式下，展示文本
 *  ad_txt_link : 文字链广告，展示文本
 */
@property (nonatomic, strong) NSDictionary *adInfoDic;

// 广告位置对应id
@property (nonatomic, copy) NSString *adSpaceId;

// 广告id
@property (nonatomic, copy) NSString *adId;

// subId
@property (nonatomic, copy) NSString *subId;

//来源
@property (nonatomic, copy) NSString *from;

//来源ID
@property (nonatomic, copy) NSString *fromId;

//push newscate
@property (nonatomic, copy) NSString *newsCate;

//
@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, strong) NSDictionary *filter;

// 数据获取
@property (nonatomic, copy) GetDataAction refreshAdDataHandler;

/** 对应数据库中缓存的adInfo obj
 *  默认值为nil 按需在生成SNAdDataCarrier 时赋值
 */
@property (nonatomic, strong) SNAdInfo *adInfoObj;

@property (nonatomic, assign)BOOL isReportStatistics;

@property (nonatomic, assign)BOOL fromPush;  // 是否从 push定向加载而来

@property (nonatomic, copy)NSString *newsID;    //lijian 2015.03.26 广告上报用的newsID
@property (nonatomic, copy)NSString *newsType;  //lijian 2015.03.31 广告上报用文章类型

@property (nonatomic, copy) NSString *blockId;//直播间类型

// init
- (id)initWithAdSpaceId:(NSString *)adSpaceId;

- (void)setAdDataHandler:(UIView * (^)(id dataCarrier, BOOL needRender))refreshAdDataHandler;

/*
- 就是把(void)setAdInfoDic:(NSDictionary *)adInfoDic拆成了2个函数，并且增加了回调。为了解决广告SDK不再下图后，客户端自己下载图片和广告SDK回调不同步的问题。
*/
- (void)onlySetAdInfo:(NSDictionary *)adInfo;
- (void)loadAdImageFromAdInfo:(void(^)(UIImage *image, NSError *error, SNAdDataCarrier *adCarrier))complete;

// refresh ad data
- (UIView *)refreshAdData:(BOOL)needRender;

// 获取adInfoDic数据便利方法
- (NSString *)adClickUrl;
- (NSString *)adShareText;
- (NSString *)adNonePicTitle;
- (NSString *)adTextLink;
- (NSString *)adTitle;
- (NSString *)adImageFilePath;
- (NSString *)adImageUrl;
- (UIImage *)adImage; // load image from image file path

// for 统计

// 点击统计： 由于目前所有广告的点击都是客户端来做，所以每一个广告位都要作点击回调统计;
- (void)reportForClickTrack;

// 客户端自己渲染的广告位需要回调曝光统计;
- (void)reportForDisplayTrack;

// 加载统计
- (void)reportForLoadTrack;

// 空广告位统计
- (void)reportForEmptyTrack;

@end

@protocol SNAdDataCarrierDelegate <NSObject>

@optional
- (void)adViewDidAppearWithCarrier:(SNAdDataCarrier *)carrier;
- (void)adViewDidFailToLoadWithCarrier:(SNAdDataCarrier *)carrier;

@end

@protocol SNAdDataCarrierActionDelegate <NSObject>

@optional
- (void)adViewDidTap:(SNAdDataCarrier *)carrier;

@end
