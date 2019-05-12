//
//  SNCacheManager.h
//  sohunews
//
//  Created by iEvil on 17/11/2016.
//  Copyright © 2016 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCacheManager : NSObject

/**
 *  单例初始化
 *
 *  @return StorageUserDefault
 */
+ (SNCacheManager *)sharedInstance;

/**
 *  保存数据到Cache文件
 *
 *  @param object 数据, 需要支持NSCoding协议
 *  @param key    键值
 */
- (void)saveCacheOnDiskWithObject:(id <NSCoding>)object
                           forKey:(NSString *)key;

/**
 *  通过键值获取从Cache文件获取数据
 *
 *  @param key 键值
 *
 *  @return 数据
 */
- (id)getObjectFromCacheDiskForKey:(NSString *)key;

/**
 *  通过键值删除Cache数据
 *
 *  @param key 键值
 */
- (void)clearDiskCache:(NSString *)key;

/**
 *  清除所有Cache文件
 */
- (void)clearAllCaches;

@end
