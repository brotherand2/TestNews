//
//  SNVideoBreakpointObjects.m
//  sohunews
//
//  Created by Gao Yongyue on 13-11-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoBreakpointObjects.h"
#import "NSDictionaryExtend.h"
#import "CacheDefines.h"

@implementation SNVideoBreakpointObjects

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        self.vid = [dict stringValueForKey:TB_VIDEO_BREAKPOINT_VID defaultValue:nil];
        self.breakpoint = [dict doubleValueForKey:TB_VIDEO_BREAKPOINT_BREAKPOINT defaultValue:0.f];
        self.createAt = [dict doubleValueForKey:TB_VIDEO_BREAKPOINT_CREATE defaultValue:0.f];
        self.context = [dict intValueForKey:TB_VIDEO_BREAKPOINT_CONTEXT defaultValue:0];
    }
}

- (void)dealloc
{
    _vid = nil;
}

@end
