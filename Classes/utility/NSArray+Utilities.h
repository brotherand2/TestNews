//
//  NSArray+Utilities.h
//  sohunews
//
//  Created by jojo on 14-2-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SNArray)
- (id)objectAtIndexWithRangeCheck:(NSUInteger)index;
- (NSArray *)offsetRangesInArrayBy:(NSUInteger)offset;
@end

@interface NSMutableArray (SNMutableArray)
- (void)removeObjectAtIndexWithRangeCheck:(NSUInteger)index;
@end