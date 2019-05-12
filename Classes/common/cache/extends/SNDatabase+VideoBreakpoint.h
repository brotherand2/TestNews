//
//  SNDatabase_VideoBreakpoint.h
//  sohunews
//
//  Created by Gao Yongyue on 13-11-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase (VideoBreakpoint)

- (BOOL)addBreakpointByVid:(NSString *)vid breakpoint:(double)breakpoint createAt:(double)createAt context:(int)contextType;

- (float)getBreakpointByVid:(NSString *)vid context:(int)contextType;

- (BOOL)deleteVideoBreakpointByVid:(NSString *)vid;

// 清空VideoBreakpoint列表
- (BOOL)clearVideoBreakpointList;

@end
