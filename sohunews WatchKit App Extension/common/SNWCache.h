//
//  SNWCache.h
//  sohunews
//
//  Created by H on 15/12/9.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface SNWCache : NSObject

+ (SNWCache *)sharedInstance;

/**
 *  用于判断是否有缓存
 *
 *  @param key 缓存时设置的key
 *
 *  @return 结果
 */
- (BOOL)isCached:(NSString *)key;

/**
 *  通过key获取缓存
 *
 *  @param key    缓存时设置的key
 *  @param result 结果
 */
- (void)getDiskCacheDataForKey:(NSString *)key result:(void(^)(BOOL result,NSDictionary *cacheData))result;

/**
 *  持久化存储新闻数据
 *
 *  @param data     待存储的数据，必传
 *  @param key      数据对应的key，必传
 *  @param finished 返回结果
 */
- (void)diskCachedData:(NSDictionary *)data Key:(NSString *)key Result:(void(^)(BOOL result))finished;

/**
 *  将app config 等信息缓存起来(每次调用都会替换掉之前的cache)
 *
 *  @param info app info （p1、rooturl等）
 *
 *  @return yes 表示缓存成功
 */
- (void)cachedAppInfo:(NSDictionary *)info;

/**
 *  从缓存中读取app info
 *
 *  @return app info
 */
- (NSDictionary *)getAppInfoFromCache;

@end
