//
//  SNDragRefreshURLRequestModel.m
//  sohunews
//
//  Created by Dan on 8/23/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNDragRefreshURLRequestModel.h"


@implementation SNDragRefreshURLRequestModel
@synthesize isRefreshManually, refreshedTime, isRefreshFromDrag;

- (void)requestDidStartLoad:(TTURLRequest *)request {
    [super requestDidStartLoad:request];
}

- (void)requestDidCancelLoad:(TTURLRequest *)request {
    [super requestDidCancelLoad:request];
}

- (void)requestDidFinishLoad:(TTURLRequest *)request {
    [super requestDidFinishLoad:request];
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
    [super request:request didFailLoadWithError:error];
}

#pragma mark drag refresh
- (NSDate *)refreshedTime {
	return [self loadedTime];
}

- (void)setRefreshedTime {
}

@end
