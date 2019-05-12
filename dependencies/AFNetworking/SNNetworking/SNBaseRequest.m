//
//  SNBaseRequest.m
//  TT_AllInOne
//
//  Created by tt on 15/5/27.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import "SNBaseRequest.h"
#import "SNRequestManager.h"
#import "SNRequestManagerIOS7.h"
#import "SNNetworkConfiguration.h"

@interface SNBaseRequest ()
@end

@implementation SNBaseRequest

#pragma mark 生命周期
- (instancetype)init {
    if (self = [super init]) {
        [self conformsToProtocol:@protocol(SNRequestProtocol)];
        //子类必须实现SNRequestProtocol协议
        NSAssert([self conformsToProtocol:@protocol(SNRequestProtocol)], @"SNRequestProtocol");
        
        self.baseDelegate = (id<SNRequestProtocol>)self;
        
        _parametersDict = [@{} mutableCopy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [self init]) {
        [_parametersDict setDictionary:dict];
    }
    return self;
}

#pragma mark 对外
- (void)send:(SNNetworkSuccessBlock)success
     failure:(SNNetworkFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [[SNRequestManagerIOS7 sharedInstance] doRequest:self];
    } else {
        [[SNRequestManager sharedInstance] doRequest:self];
    }
}

- (void)cancel {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [[SNRequestManagerIOS7 sharedInstance] cancelRequest:self];
    } else {
        [[SNRequestManager sharedInstance] cancelRequest:self];
    }
}

- (void)clearAfterFinished {
    self.successBlock = nil;
    self.failureBlock = nil;
    self.baseDelegate = nil;
}

@end

