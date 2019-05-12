//
//  NSTimer+SNBlocksSupport.m
//  sohunews
//
//  Created by Huang Zhen on 2017/9/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "NSTimer+SNBlocksSupport.h"

@implementation NSTimer (SNBlocksSupport)

+ (NSTimer *)sn_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)())block {
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(sn_blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)sn_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)())block {
    return [self timerWithTimeInterval:interval target:self selector:@selector(sn_blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)sn_blockInvoke:(NSTimer *)timer {
    void (^block)() = timer.userInfo;
    if (block) {
        block();
    }
}

@end
