//
//  SNLineraQueue.h
//  sohunews
//
//  Created by wang yanchen on 12-11-9.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNLineraQueue : NSObject {
    NSMutableArray *_queue;
}

@property(readonly) NSInteger count;

- (void)checkIn:(id)inObj;
- (id)checkOut;

- (id)objectAtIndex:(int)index;

- (void)cleanUp;

@end
