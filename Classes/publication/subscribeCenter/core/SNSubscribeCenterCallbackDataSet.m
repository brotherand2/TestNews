//
//  SNSubscribeCenterCallbackDataSet.m
//  sohunews
//
//  Created by jojo on 14-2-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSubscribeCenterCallbackDataSet.h"
#import "SNStatusBarMessageCenter.h"

@implementation SNSubscribeCenterCallbackDataSet
@synthesize strongDataRef, weakDataRef, operation, reservedDataRef, lastError;

+ (id)callBackDataSetWithOperation:(SCServiceOperationType)opt {
    SNSubscribeCenterCallbackDataSet *dataSet = [[[self class] alloc] init];
    dataSet.operation = opt;
    return dataSet;
}

+ (id)callBackDataSetWithOperation:(SCServiceOperationType)opt strongDataRef:(id)strongRef weakDataRef:(id)weakRef {
    SNSubscribeCenterCallbackDataSet *dataSet = [[[self class] alloc] init];
    dataSet.operation = opt;
    dataSet.strongDataRef = strongRef;
    dataSet.weakDataRef = weakRef;
    return dataSet;
}

- (void)dealloc {
     //(strongDataRef);
     //(reservedDataRef);
     //(lastError);
    weakDataRef = nil;
}

@end
