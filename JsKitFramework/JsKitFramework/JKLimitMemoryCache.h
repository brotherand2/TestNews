//
//  JKAccessOrderMutableDictionary.h
//  sohunews
//
//  Created by sevenshal on 16/5/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKLimitMemoryCache : NSObject

-(instancetype)initWithMaxSize:(NSInteger)maxSize;

-(id)objectForKey:(id)aKey;

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;

-(void)removeObjectForKey:(id)aKey;

-(void)removeAllObjects;

-(NSArray *)allKeys;

@end
