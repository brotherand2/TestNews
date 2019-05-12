//
//  SNCacheManager.m
//  sohunews
//
//  Created by iEvil on 17/11/2016.
//  Copyright © 2016 Sohu.com. All rights reserved.
//

#import "SNCacheManager.h"
#import "TMCache.h"

@interface SNCacheManager () {
    TMCache *_tmCache;
}
@end

@implementation SNCacheManager
+ (SNCacheManager *)sharedInstance {
    static SNCacheManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNCacheManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _tmCache = [TMCache sharedCache];
    }
    return self;
}

#pragma mark - Cache Operation
- (void)saveCacheOnDiskWithObject:(id <NSCoding>)object
                           forKey:(NSString *)key {
    [_tmCache setObject:object forKey:key];
}

- (id)getObjectFromCacheDiskForKey:(NSString *)key {
    return [_tmCache objectForKey:key];
}

- (void)clearDiskCache:(NSString *)key {
    [_tmCache removeObjectForKey:key];
}

- (void)clearAllCaches {
    [_tmCache removeAllObjects];
}
@end
