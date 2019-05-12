//
//  SNSpecialAD.h
//  sohunews
//
//  Created by Huang Zhen on 2017/9/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 //定制化活动
 #define kSpecialActivityCountKey @"kSpecialActivityCountKey"
 #define kSpecialActivityShowTimeKey @"kSpecialActivityShowTimeKey"
 #define kSpecialActivityShowNotification @"kSpecialActivityShowNotification"
 #define kSpecialActivityShouldShowKey @"kSpecialActivityShouldShowKey"
 #define kSpecialActivityDocumentName @"specialActivity"
 #define kSpecialActivityName @"activity"
 #define kSpecialActivityDocumentZipName @"specialActivity.zip"
 #define kSpecialActivityData @"data"//动画相关数据
 
 */
typedef enum : NSUInteger {
    SNSpecialADAlignmentInvalid = 0,//无效
    SNSpecialADAlignmentHorizontal,//水平居中
    SNSpecialADAlignmentVertical,//垂直居中
    SNSpecialADAlignmentCenter,//屏幕居中
} SNSpecialADAlignment;

typedef enum : NSUInteger {
    SNSpecialADAlignSideInvalid = 0,//无效
    SNSpecialADAlignSideRight,//右对齐
    SNSpecialADAlignSideBottom,//下对齐
    SNSpecialADAlignSideLowerRightCorner,//屏幕右下角
} SNSpecialADAlignSide;

@interface SNSpecialAD : NSObject<NSCoding>


#pragma mark - Frame
//"xAxisPercent"//素材在屏幕上的x，y 以百分比形式，float格式，比如0.65
@property (nonatomic, assign, readonly) CGFloat xAxisPercent;

//"yAxisPercent"//素材在屏幕上的x，y 以百分比形式，float格式，比如0.65
@property (nonatomic, assign, readonly) CGFloat yAxisPercent;

//"alignCenter"//水平居中，垂直居中，int值， 0无效，1水平，2垂直，3屏幕居中
@property (nonatomic, assign, readonly) SNSpecialADAlignment alignCenter;

//"alignSide"//右对齐和下对齐， int型，0无效，1右对齐，2下对齐，3屏幕右下角
@property (nonatomic, assign, readonly) SNSpecialADAlignSide alignSide;

//"materialRatio"//素材宽度，百分比，float型，比如0.35，根据屏幕宽度计算;素材高度，素材宽度*图片的比例
@property (nonatomic, assign, readonly) CGFloat materialRatio;


#pragma mark - data
//"actUrl"//广告落地页URL
@property (nonatomic, copy, readonly) NSString * actUrl;

//"material"//素材zip链接，ios和android都会根据上传的屏幕宽高，下发不同的素材，投放提供ios2套
@property (nonatomic, copy, readonly) NSString * material;


#pragma mark - Statistics
//"expsMonitorUrl"//曝光URL，大数据使用
@property (nonatomic, copy, readonly) NSString * expsMonitorUrl;

//"expsAdverUrl"//曝光URL，广告商使用
@property (nonatomic, copy, readonly) NSString * expsAdverUrl;

//"clickMonitorUrl"//点击URL，大数据使用
@property (nonatomic, copy, readonly) NSString * clickMonitorUrl;

//"clickAdverUrl"//点击URL，广告商使用
@property (nonatomic, copy, readonly) NSString * clickAdverUrl;


#pragma mark - Business

//"adSwitch"//活动显示开关
@property (nonatomic, assign, readonly) BOOL adSwitch;

/**
 当天曝光次数
 */
@property (nonatomic, assign, readonly) NSUInteger dayImpressions;

/**
 当天曝光次数限制
 */
@property (nonatomic, assign, readonly) NSUInteger dayImpressionsLimit;

/**
 广告失效时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval endTimeInterval;

/**
 广告生效时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval startTimeInterval;

//"md5Key"//MD5加密，用于校验
@property (nonatomic, copy, readonly) NSString * md5Key;

//"playTimes"//帧动画播放次数
@property (nonatomic, assign, readonly) NSInteger playTimes;

//"displayTimeLength"//每帧动画播放时长，单位毫秒
@property (nonatomic, assign, readonly) CGFloat displayTimeLength;

//广告位标识id
@property (nonatomic, copy, readonly) NSString * spaceId;

/**
 自然日时间分割点 0900 
 */
@property (nonatomic, copy, readonly) NSString * statPoint;

/**
 md5key有变化，需要更新本地广告物料
 */
@property (nonatomic, assign) BOOL needRefreshResources;

#pragma mark - Static Func
+ (SNSpecialAD *)createSpecialADWithDictionary:(NSDictionary *)dic;

#pragma mark - Func
/**
 available = YES 表示广告有效
 */
- (BOOL)available;

/**
 正文页浮层广告与正文页打开次数相关

 @param pageCount 正文页打开次数
 @return YES 表示广告有效
 */
- (BOOL)availableWithPageCount:(NSUInteger)pageCount ;

/**
 广告是否过期

 @return YES 广告有效，未过期
 */
- (BOOL)isAvailableFromLifeCircle ;

/**
 设置后，该广告一个自然日内不再出现
 */
- (void)cantSeeInDay;

/**
 如果广告展示需要计数，每次展示需要调用 -didShow 来计数+1
 */
- (void)didShow ;

/**
 设置后，该广告受展示次数限制 dayImpressions
 */
- (void)limitExposureCount;

/**
 如果之前已经创建好SpecialAD模型，用来刷新广告配置信息

 @param dic 广告信息json
 */
- (void)updateWithDic:(NSDictionary *)dic;

@end
