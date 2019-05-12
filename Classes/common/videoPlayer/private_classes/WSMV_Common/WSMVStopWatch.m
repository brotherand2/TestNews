//
//  WSMVStopWatch.m
//  sohunews
//
//  Created by Dan on 10/13/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "WSMVStopWatch.h"

@implementation WSMVStopWatch
@synthesize diff=_diff;

+ (id)watch {
	return [[WSMVStopWatch alloc] init];
}

- (id)begin {
	_start = [[NSDate date] timeIntervalSince1970];
	return self;
}

- (id)stop {
	_diff = [[NSDate date] timeIntervalSince1970] - _start;
	return self;
}

- (void)print:(NSString *)msg {
}

@end
