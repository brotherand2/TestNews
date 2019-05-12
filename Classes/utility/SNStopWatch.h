//
//  SNStopWatch.h
//  sohunews
//
//  Created by Dan on 10/13/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SNStopWatch : NSObject {

	NSTimeInterval _start;
	NSTimeInterval _diff;
}

@property(nonatomic, readonly) NSTimeInterval diff;

+ (id)watch;

- (id)begin;
- (id)stop;
- (void)print:(NSString *)msg;

@end
