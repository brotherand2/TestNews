//
//  SNVideoBreakpointManager.h
//  sohunews
//
//  Created by Gao Yongyue on 13-11-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoBreakpointObjects.h"

@interface SNVideoBreakpointManager : NSObject
+ (SNVideoBreakpointManager *)sharedInstance;
- (BOOL)addBreakpointByVid:(NSString *)vid breakpoint:(double)breakpoint;
- (BOOL)addBreakpointByVid:(NSString *)vid breakpoint:(double)breakpoint context:(VideoBreakpointContextType)contextType;

- (float)getBreakpointByVid:(NSString *)vid;
- (float)getBreakpointByVid:(NSString *)vid context:(VideoBreakpointContextType)contextType;

- (BOOL)deleteBreakpointByVid:(NSString *)vid;
- (BOOL)breakpointExistsByVid:(NSString *)vid;
@end