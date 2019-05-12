//
//  JKAccessOrderMutableDictionary.m
//  sohunews
//
//  Created by sevenshal on 16/5/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "JKLimitMemoryCache.h"

@interface JKLimitMemoryCache() {
    NSMutableDictionary* _cache;
    NSMutableArray* _accessOrderKeys;
    NSInteger _maxSize;
}

@end

@implementation JKLimitMemoryCache

-(instancetype)initWithMaxSize:(NSInteger)maxSize{
    if (self=[super init]) {
        _cache = [[NSMutableDictionary alloc] initWithCapacity:maxSize + 4];
        _accessOrderKeys = [[NSMutableArray alloc] initWithCapacity:maxSize + 4];
        _maxSize = maxSize;
    }
    return self;
}

-(id)objectForKey:(id)aKey{
    @synchronized (self) {
        id val = [_cache objectForKey:aKey];
        if (val) {
            [_accessOrderKeys removeObject:aKey];
            [_accessOrderKeys addObject:aKey];
        }
        return val;
    }
}

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey{
    @synchronized (self) {
        if (!anObject) {
            anObject = [NSNull null];
        }
        [_cache setObject:anObject forKey:aKey];
        [_accessOrderKeys removeObject:aKey];
        [_accessOrderKeys addObject:aKey];
        NSInteger needDelSize = [_accessOrderKeys count] - _maxSize;
        for (NSInteger i=0; i<needDelSize; i++) {
            [self removeObjectForKey:[_accessOrderKeys firstObject]];
        }
    }
}

-(void) removeObjectForKey:(id)aKey{
    @synchronized (self) {
        [_cache removeObjectForKey:aKey];
        [_accessOrderKeys removeObject:aKey];
    }
}

-(void)removeAllObjects{
    @synchronized (self) {
        [_cache removeAllObjects];
        [_accessOrderKeys removeAllObjects];
    }
}

-(NSArray *)allKeys{
    return _accessOrderKeys;
}

@end
