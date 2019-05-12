//
//  SNStack.m
//  sohunews
//
//  Created by handy wang on 6/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNStack.h"

@implementation SNStack

@synthesize count = _count;

- (id)init {
    if (self = [super init]) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)push:(id)anyObj {
    if (!anyObj) {
        return;
    }
    [_dataArray addObject:anyObj];
}

- (id)pop {
    id obj = nil;
    if(_dataArray.count > 0) {
        obj = [_dataArray lastObject];
        [_dataArray removeLastObject];
    }
    return obj;
}

- (id)objectAtIndex:(int)index {
    id obj = nil;
    if (_dataArray.count > 0 && index >= 0 && index < _dataArray.count) {
        obj = [_dataArray objectAtIndex:index];
    }
    return obj;
}

- (void)clear {
    [_dataArray removeAllObjects];
}

- (NSInteger)count {
    return _dataArray.count;
}

- (void)dealloc {
     //(_dataArray);
}

@end
