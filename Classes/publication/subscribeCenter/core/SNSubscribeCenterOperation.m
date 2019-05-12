//
//  SNSubscribeCenterOperation.m
//  sohunews
//
//  Created by jojo on 14-2-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSubscribeCenterOperation.h"
#import "SNStatusBarMessageCenter.h"
#import "SNSubscribeCenterService.h"


@implementation SNSubscribeCenterOperation
@synthesize operationRequest = _operationRequest;
@synthesize operationType = _operationType;
@synthesize listener = _listener;
@synthesize subId = _subId;
@synthesize succMsg = _succMsg;
@synthesize failMsg = _failMsg;
@synthesize isFinished;

+ (id)operationWithType:(SCServiceOperationType)type request:(SNURLRequest *)request refId:(NSString *)refId {
    SNSubscribeCenterOperation *opt = [[SNSubscribeCenterOperation alloc] init];
    opt.operationType = type;
    opt.operationRequest = request;
    opt.subId = refId;
    
    return opt;
}

- (void)dealloc {
     //(_operationRequest);
     //(_subId);
     //(_succMsg);
     //(_failMsg);
}

- (NSUInteger)hash {
    NSString *hashCode = [_subId length] > 0 ? [NSString stringWithFormat:@"%d%05ld", _operationType, (long)[_subId integerValue]] : [NSString stringWithFormat:@"%d%05d", _operationType, 0];
    return [hashCode integerValue];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self hash] == [(SNSubscribeCenterOperation *)object hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@> type %d refId %@ hash %lu request %@", NSStringFromClass([self class]), self.operationType, self.subId, (unsigned long)[self hash], self.operationRequest];
}

- (id)cancel {
    if (_operationRequest) {
        [_operationRequest cancel];
    }
    return self;
}

- (id)addBackgroundListenerWithSuccMsg:(NSString *)succMsg failMsg:(NSString *)failMsg {
    self.succMsg = succMsg;
    self.failMsg = failMsg;
    
    [[SNSubscribeCenterService defaultService] addBackgroundOperation:self];
    return self;
}

- (id)removeBackgroundListener {
    [[SNSubscribeCenterService defaultService] removeBackgroundOperation:self];
    return self;
}

- (id)addListener:(id)listener {
    self.listener = listener;
    [[SNSubscribeCenterService defaultService] addListener:_listener forOperation:self.operationType];
    return self;
}

- (id)removeListener {
    if (_listener) {
        [[SNSubscribeCenterService defaultService] removeListener:_listener];
        _listener = nil;
    }
    return self;
}

- (id)fire:(BOOL)bSucc {
    //订阅后图标变化会告知用户结构，订阅成功或失败不再弹出Toast提示
    if (bSucc) {
//        [[SNStatusBarMessageCenter sharedInstance] postImmediateMessage:_succMsg];
//        [[SNToast shareInstance] showToastWithTitle:_succMsg
//                                              toUrl:nil
//                                               mode:SNToastUIModeSuccess];
    }
    else {
//        [[SNStatusBarMessageCenter sharedInstance] postImmediateMessage:_failMsg];
//        [[SNToast shareInstance] showToastWithTitle:_failMsg
//                                              toUrl:nil
//                                               mode:SNToastUIModeWarning];
    }
    
    self.isFinished = YES;
    
    return self;
}

@end
