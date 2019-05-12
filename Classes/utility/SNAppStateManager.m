//
//  SNAppStateManager.m
//  sohunews
//
//  Created by wangyy on 15/7/3.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNAppStateManager.h"
#import "TMCache.h"
#import "SNRollingNewsPublicManager.h"

#define kLaunch_Refresh_Channel @"Launch_refresh_channel"

@implementation SNAppStateManager

@synthesize activeDate = _activeDate;
@synthesize inactiveDate = _inactiveDate;

+ (SNAppStateManager *)sharedInstance {
    static SNAppStateManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNAppStateManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //程序进入后台不清理TM中的MemoryCache
        [TMCache sharedCache].memoryCache.removeAllObjectsOnEnteringBackground = NO;
    }
    
    return self;
}

- (BOOL)reloadWithChannelNewsTime:(NSTimeInterval)timeInterval {
    NSTimeInterval interval = timeInterval;
    if (self.inactiveDate == nil) {
        //表示应用没有锁屏或进入后台
        return NO;
    }
  
    NSTimeInterval secondsInterval = [self.activeDate timeIntervalSinceDate:self.inactiveDate];
    if (secondsInterval > interval) {
        //重置时间,下次时间app状态切换再记录
        [self resetAppStateDate];
        return YES;
    }
    
    return NO;
}


- (void)resetAppStateDate {
    if (self.activeDate != self.inactiveDate) {
        self.activeDate = [NSDate date];
        self.inactiveDate = [NSDate date];
    }
}

- (BOOL)appFinishLaunchLoadNewsWithChannelId:(NSString *)channelId {
    if (channelId != nil) {
        NSMutableArray *list = [[TMCache sharedCache] objectForKey:kLaunch_Refresh_Channel];
        if (list == nil || [list count] == 0) {
            return YES;
        }
        
        return !([list indexOfObject:channelId] != NSNotFound);
    }
    
    return NO;
}

- (void)loadedChannelNewsWith:(NSString *)channelId {
    if (channelId != nil) {
        [[TMCache sharedCache] objectForKey:kLaunch_Refresh_Channel block:^(TMCache *cache, NSString *key, id object) {
            NSMutableArray *list = (NSMutableArray *)object;
            if (list == nil) {
                list = [[NSMutableArray alloc] init];
            }
            
            NSUInteger index = [list indexOfObject:channelId];
            if (NSNotFound == index) {
                [list addObject:channelId];
                [[TMCache sharedCache] setObject:list forKey:kLaunch_Refresh_Channel];
            }
        }];
    }
}

- (void)removeAllChannelRefreshList {
    [[TMCache sharedCache] removeObjectForKey:kLaunch_Refresh_Channel];
    [[SNRollingNewsPublicManager sharedInstance] deleteAllChannelsRequestParams];
}

@end
