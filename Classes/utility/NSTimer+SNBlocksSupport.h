//
//  NSTimer+SNBlocksSupport.h
//  sohunews
//
//  Created by Huang Zhen on 2017/9/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (SNBlocksSupport) 

+ (NSTimer *)sn_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)())block;
+ (NSTimer *)sn_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)())block;

@end
