//
//  SNStack.h
//  sohunews
//
//  Created by handy wang on 6/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNStack : NSObject {
    NSMutableArray *_dataArray;
    NSInteger _count;
}

@property(nonatomic, readonly, assign)NSInteger count;

- (void)push:(id)anyObj;

- (id)pop;

- (id)objectAtIndex:(int)index;

- (void)clear;

@end