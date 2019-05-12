//
//  SNPostCommentOperation.m
//  sohunews
//
//  Created by jialei on 14-4-25.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNPostCommentOperation.h"
#import "ASIFormDataRequest.h"

@interface SNPostCommentOperation()
{
    BOOL _executing;
    BOOL _finished;
}

@property (copy, nonatomic) SNPostCommentCompletedBlock completedBlock;
@property (strong, nonatomic) ASIFormDataRequest *request;

@end

@implementation SNPostCommentOperation

- (id)initWithRequest:(ASIFormDataRequest *)request
            completed:(void (^)(ASIHTTPRequest *))completedBlock
{
    if (self = [super init]) {
        self.request = request;
        self.completedBlock = completedBlock;
        self.request.delegate = self;
    }
    return self;
}

- (void)dealloc
{
     //(_completedBlock);
     //(_request);
    
}

- (void)start
{
    [_request startAsynchronous];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    CFRunLoopRun();
}

- (void)cancel
{
    [self reset];
}

- (void)done
{
    [self reset];
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _executing = NO;
    _finished  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)reset
{
    _request.delegate = nil;
     //(_request);
     //(_completedBlock);
}

#pragma mark -
#pragma mark Overrides
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

#pragma mark - asiform delegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    CFRunLoopStop(CFRunLoopGetCurrent());
    if (self.completedBlock) {
        self.completedBlock(request);
    }
    SNDebugLog(@"this request success %@" , self.request);
    [self done];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    CFRunLoopStop(CFRunLoopGetCurrent());
    SNDebugLog(@"this request failed %@" , self.request);
    [self done];
}

@end
