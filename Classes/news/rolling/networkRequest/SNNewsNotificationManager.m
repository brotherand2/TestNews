//
//  SNNewsNotificationManager.m
//  sohunews
//
//  Created by lhp on 12/18/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNNewsNotificationManager.h"

@interface SNNewsNotificationManager () {
    
    NSTimer *timer;
    int sendTime;
}
@property(nonatomic,strong)NSTimer *timer;

@end

#define kNewsNotificationTime        2*5
#define kNewsNotificationDate        @"kNewsNotificationDate"  //记录下拉提示时间

@implementation SNNewsNotificationManager
@synthesize timer;
@synthesize channelId;
@synthesize message;
@synthesize time;

+ (SNNewsNotificationManager *)sharedInstance {
    static SNNewsNotificationManager *_sharedInstance = nil;
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[SNNewsNotificationManager alloc] init];
        }
    }
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        time = kNewsNotificationTime;
        //无效使用, 不再自动发更新数据的通知
        //[self start];
    }
    return self;
}

- (void)start
{
    [self invalideteTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time
                                                  target:self
                                                selector:@selector(sendNotification)
                                                userInfo:nil
                                                 repeats:YES];
}

- (BOOL)isHomeChannel
{
    BOOL isHomeChannel = NO;
    if (self.channelId && [self.channelId isEqualToString:@"1"]) {
        isHomeChannel = YES;
    }
    return isHomeChannel;
}

- (void)sendNotification
{
    if (sendTime >= 2 && [self checkNotificationDate]) {
        return;
    }
    
    sendTime++;
    NSMutableDictionary *tipsDic = [NSMutableDictionary dictionary];
    if (self.message) {
        [tipsDic setObject:self.message forKey:@"message"];
    }
    if (self.channelId) {
        [tipsDic setObject:self.channelId forKey:@"channelId"];
    }
    [SNNotificationManager postNotificationName:kChannelRefreshMessageNotification object:tipsDic];
    
    [self saveNotificationDate];
}

- (BOOL)checkNotificationDate
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kNewsNotificationDate]) {
        NSTimeInterval notificationInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:kNewsNotificationDate] floatValue];
        NSDate *notificationDate = [NSDate dateWithTimeIntervalSince1970:notificationInterval];
        if (notificationDate) {
            return [notificationDate isToday];
        }else {
            return NO;
        }
    }else {
        return NO;
    }
}

- (void)saveNotificationDate
{
    NSTimeInterval dateInterval = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:dateInterval] forKey:kNewsNotificationDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)invalideteTimer
{
    if (timer) {
        [timer invalidate];
    }
}


@end
