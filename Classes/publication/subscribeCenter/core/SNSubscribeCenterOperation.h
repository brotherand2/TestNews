//
//  SNSubscribeCenterOperation.h
//  sohunews
//
//  Created by jojo on 14-2-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSubscribeCenterDefines.h"

@interface SNSubscribeCenterOperation : NSObject {
    SCServiceOperationType _operationType;
    SNURLRequest *_operationRequest;
    id __weak _listener;
    NSString *_subId;
    
    NSString *_succMsg;
    NSString *_failMsg;
}

@property(assign) SCServiceOperationType operationType;
@property(strong) SNURLRequest *operationRequest;
@property(weak) id listener;
@property(nonatomic, copy) NSString *subId;
@property(nonatomic, copy) NSString *succMsg;
@property(nonatomic, copy) NSString *failMsg;
@property(assign) BOOL isFinished;

+ (id)operationWithType:(SCServiceOperationType)type request:(SNURLRequest *)request refId:(NSString *)refId;

- (id)cancel;
- (id)addBackgroundListenerWithSuccMsg:(NSString *)succMsg failMsg:(NSString *)failMsg;
- (id)removeBackgroundListener;
- (id)addListener:(id)listener;
- (id)removeListener;

- (id)fire:(BOOL)bSucc;

@end

