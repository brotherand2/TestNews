//
//  SNUserDefaults.h
//  sohunews
//
//  Created by yangln on 2017/9/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNUserDefaults : NSObject

+ (void)setObject:(nullable id)value forKey:(nullable NSString *)key;
+ (nullable id)objectForKey:(nullable NSString *)key;

+ (void)setValue:(nullable id)value forKey:(nullable NSString *)key;
+ (nullable id)valueForKey:(nullable NSString *)key;

+ (NSString *_Nullable)stringForKey:(nullable NSString *)key;

+ (void)setBool:(BOOL)value forKey:(nullable NSString *)key;
+ (BOOL)boolForKey:(nullable NSString *)key;

+ (void)setInteger:(NSInteger)value forKey:(nullable NSString *)key;
+ (NSInteger)integerForKey:(nullable NSString *)key;

+ (void)setFloat:(float)value forKey:(nullable NSString *)key;
+ (float)floatForKey:(nullable NSString *)key;

+ (void)setDouble:(double)value forKey:(nullable NSString *)key;
+ (double)doubleForKey:(nullable NSString *)key;

+ (void)removeObjectForKey:(nullable NSString *)key;

@end
