//
//  SNLineraQueue.m
//  sohunews
//
//  Created by wang yanchen on 12-11-9.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLineraQueue.h"

@implementation SNLineraQueue
@synthesize count = _count;

- (id)init {
    self = [super init];
    if (self) {
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
     //(_queue);
}

- (NSInteger)count {
    return _count = [_queue count];
}

- (void)checkIn:(id)inObj {
    if (inObj) {
        if ([_queue count] > 0) {
            for (NSDictionary *dict in _queue) {
                NSString *pushURL = [dict objectForKey:@"url"];
                if ([pushURL containsString:@"showType=1"]) {
                    return;
                }
            }
        }
        [_queue addObject:inObj];
        _count = [_queue count];
    }
    SNDebugLog(@"in %@ queue.count=%d", inObj, _count);
}

- (id)checkOut {    
    id outObj = nil;
    if ([_queue count] > 0) {
        outObj = [[_queue objectAtIndex:0] copy];
        [_queue removeObjectsInRange:(NSRange){0,1}];
        _count = [_queue count];
    }
    SNDebugLog(@"out %@ queue.count=%d", outObj, _count);
    return outObj;
}

- (id)objectAtIndex:(int)index {
    id obj = nil;
    
    if (_queue.count > 0 && index < _queue.count && index >= 0) {
        obj = [_queue objectAtIndex:index];
    }
    
    return obj;
}

- (void)cleanUp {
    [_queue removeAllObjects];
}

@end
