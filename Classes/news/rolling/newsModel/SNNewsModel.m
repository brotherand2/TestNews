//
//  SNNewsModel.m
//  sohunews
//
//  Created by chenhong on 14-3-7.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsModel.h"

@implementation SNNewsModel
@synthesize link = _link;

- (BOOL)isPreloadChannel {
    return _isPreloadChannel;
}

- (NSString *)channelId {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

- (BOOL)hasRecommendNews {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return NO;
}

- (NSTimeInterval)refreshIntervalWithDefault:(NSTimeInterval)interval {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return interval;
}

#pragma mark drag refresh
- (NSDate *)refreshedTime {
	NSDate *time = nil;
    NSString *timeKey = [NSString stringWithFormat:@"channel_%@_refresh_time", self.channelId];
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
	if (data && [data isKindOfClass:[NSDate class]]) {
		time = data;
	}
	return time;
}

- (void)setRefreshedTime {
	NSString *timeKey = [NSString stringWithFormat:@"channel_%@_refresh_time", self.channelId];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:timeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRefreshStatusOfUpgrade {
    NSString *key = [NSString stringWithFormat:@"channel_%@_force_refresh", self.channelId];
	[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
