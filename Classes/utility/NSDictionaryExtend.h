//
//  NSDictionaryExtend.h
//  sohunews
//
//  Created by yanchen wang on 12-5-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(Extend)

// for value
- (id)objectForKey:(NSString *)key defalutObj:(id)defaultObj;
- (id)objectForKey:(id)aKey ofClass:(Class)aClass defaultObj:(id)defaultObj;
- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue;
- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue;
- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue;
- (long)longValueForKey:(NSString *)key defaultValue:(long)defaultValue;
- (long long)longlongValueForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSArray *)arrayValueForKey:(NSString *)key defaultValue:(NSArray *)defaultValue;
- (NSDictionary *)dictionaryValueForKey:(NSString *)key defalutValue:(NSDictionary *)defaultValue;


- (void)setRect:(CGRect)rect forKey:(NSString *)key;
- (CGRect)rectValueForKey:(NSString *)key;

// xml
- (NSArray*) toArray;
- (NSString*) toXMLString;

// url string

- (NSString *)toUrlString;
- (NSMutableString *)mutableUrlString;
- (NSString *)appendParamToUrlString:(NSString *)url;
- (NSString *)translateDictionaryToJsonString;

@end
