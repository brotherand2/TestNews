//
//  SNSpecialADTools.h
//  sohunews
//
//  Created by Huang Zhen on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * SNFloatingADTypeHomePageIdentifier      = @"SNFloatingADTypeHomePageIdentifier";
static NSString * SNFloatingADTypeChannelsIdentifier      = @"SNFloatingADTypeChannelsIdentifier";
static NSString * SNFloatingADTypeNewsDetailIdentifier    = @"SNFloatingADTypeNewsDetailIdentifier";

static NSString * SNNewsPageOpenCountCacheKey       = @"SNNewsPageOpenCountCacheKey";
static NSString * SNNewsPageOpenDateCacheKey        = @"SNNewsPageOpenDateCacheKey";

static NSString * SNArticleADDefaultSpaceID         = @"SNArticleADDefaultSpaceID";
static NSString * SNHomePageADDefaultSpaceID         = @"SNHomePageADDefaultSpaceID";

typedef enum : NSUInteger {
    SNFloatingADTypeHomePage,//首页浮层广告
    SNFloatingADTypeChannels,//频道流浮层广告
    SNFloatingADTypeNewsDetail,//正文页浮层广告
} SNFloatingADType;

typedef void(^SNFetchSpecialADConfigBlock)(BOOL successed);


@interface SNSpecialADTools : NSObject

typedef void(^SNSpecialADToolsFetchArticleAdCompleted)(NSArray * articleAds);
typedef void(^SNSpecialADToolsFetchChannelAdCompleted)(NSArray * channelAds);

/**
 判断两个日期间隔是否超过一个自然日 9：00 - 9：00

 @param date 之前的一个日期
 @return YES 表示超过一个自然日
 */
+ (BOOL)isNaturalDaythanDate:(NSDate*)date;

/**
 判断现在距离date是否超过一个自然日
 
 @param date 之前的一个时间戳
 @param timePoint 自然日的时间分割点 例如:0830为8点半
 @return YES 超过一个自然日
 */
+ (BOOL)isNaturalDaythanDate:(NSDate*)date withTimePoint:(NSString *)timePoint;

/**
 请求运营位广告配置信息

 @param articleAdsBlock 正文页广告请求完成回调
 @param channelAdsBlock 频道流广告请求完成回调
 */
+ (void)fetchAdConfigArticleAd:(SNSpecialADToolsFetchArticleAdCompleted)articleAdsBlock channelAd:(SNSpecialADToolsFetchChannelAdCompleted)channelAdsBlock;

/**
 下载运营位广告资源包

 @param url 资源包地址 不可为空
 @param md5Key 用于校验的md5key 不可为空
 @param mkey 唯一标识key 不可为空
 */
+ (void)preDownloadAdResourceWithUrl:(NSString *)url md5Key:(NSString *)md5Key majorKey:(NSString *)mkey;

/**
 路径下是否已经下载了广告资源包

 @param mkey 广告位ID
 @return YES 为已经下载
 */
+ (BOOL)didDownloadResourceWithMajorkey:(NSString *)mkey;

/**
 删除该广告的资源包

 @param mkey 广告位ID
 @return YES 为成功删除
 */
+ (BOOL)removeAdResourceWithMajorkey:(NSString *)mkey;

/**
 删除所有的广告资源包

 @return YES 为成功删除
 */
+ (BOOL)removeAllAdResource;

/**
 广告资源路径

 @param mkey 广告位ID
 @return 广告资源路径
 */
+ (NSString *)rootPathWithMajorkey:(NSString *)mkey;

/**
 广告图片资源路径

 @param mkey 广告位ID
 @param imageName 图片名称
 @return 广告图片资源路径
 */
+ (NSString *)imagePathWithMajorkey:(NSString *)mkey imageName:(NSString *)imageName;

@end
