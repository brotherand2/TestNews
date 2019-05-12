//
//  SNVideoBreakpointManager.m
//  sohunews
//
//  Created by Gao Yongyue on 13-11-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoBreakpointManager.h"
#import "SNDBManager.h"

static const CGFloat kBreakpointThresholdValue = 10.0f;

@implementation SNVideoBreakpointManager

+ (SNVideoBreakpointManager *)sharedInstance
{
    static SNVideoBreakpointManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNVideoBreakpointManager alloc] init];
    });
    return sharedInstance;
}

- (BOOL)addBreakpointByVid:(NSString *)vid breakpoint:(double)breakpoint
{
    return [self addBreakpointByVid:vid breakpoint:breakpoint context:VideoBreakpointContextTypeNone];
}

- (float)getBreakpointByVid:(NSString *)vid
{
    return [self getBreakpointByVid:vid context:VideoBreakpointContextTypeNone];
}

- (BOOL)addBreakpointByVid:(NSString *)vid breakpoint:(double)breakpoint context:(VideoBreakpointContextType)contextType
{
    //当超过10s后才进数据库
    BOOL isSuccess = NO;
    if (vid && [vid isKindOfClass:[NSString class]] && [vid length] && breakpoint > kBreakpointThresholdValue)
    {
        //当前时间
        double date = [[NSDate date] timeIntervalSince1970];
        if (date)
        {
            isSuccess = [[SNDBManager currentDataBase] addBreakpointByVid:vid breakpoint:breakpoint createAt:date context:contextType];
        }
    }
    return isSuccess;
}

- (float)getBreakpointByVid:(NSString *)vid context:(VideoBreakpointContextType)contextType
{
    float breakpoint = 0.f;
    if (vid && [vid isKindOfClass:[NSString class]] && [vid length])
    {
        breakpoint = [[SNDBManager currentDataBase] getBreakpointByVid:vid context:contextType];
    }
    return breakpoint;
}

- (BOOL)deleteBreakpointByVid:(NSString *)vid
{
    return [[SNDBManager currentDataBase] deleteVideoBreakpointByVid:vid];
}

- (BOOL)breakpointExistsByVid:(NSString *)vid
{
    float breakpoint = [[SNVideoBreakpointManager sharedInstance] getBreakpointByVid:vid];
    return (breakpoint > kBreakpointThresholdValue);
}

@end