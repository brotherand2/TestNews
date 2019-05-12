//
//  NSArray+Utilities.m
//  sohunews
//
//  Created by jojo on 14-2-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "NSArray+Utilities.h"

@implementation NSArray (SNArray)

- (id)objectAtIndexWithRangeCheck:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    } else {
        SNDebugLog(@"warning: %d out of range [0...%d]", index, self.count-1);
        return nil;
    }
}

- (NSArray *)offsetRangesInArrayBy:(NSUInteger)offset
{
    NSUInteger aOffset = 0;
    NSUInteger prevLength = 0;
    
    
    NSMutableArray *ranges = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for(NSInteger i = 0; i < [self count]; i++)
    {
        @autoreleasepool {
            NSRange range = [[self objectAtIndex:i] rangeValue];
            prevLength    = range.length;
            
            range.location  = range.location;
            range.length    = offset;
            [ranges addObject:[NSValue valueWithRange:range]];
            
            aOffset = aOffset + prevLength - offset;
        }
    }
    
    return [ranges autorelease];
}

@end

@implementation NSMutableArray (SNMutableArray)

- (void)removeObjectAtIndexWithRangeCheck:(NSUInteger)index {
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    } else {
        SNDebugLog(@"warning: %d out of range [0...%d]", index, self.count-1);
    }
}

@end
