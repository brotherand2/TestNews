//
//  SNSubscribeCenterCallbackDataSet.h
//  sohunews
//
//  Created by jojo on 14-2-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSubscribeCenterDefines.h"

@interface SNSubscribeCenterCallbackDataSet : NSObject

@property(strong) id strongDataRef;
@property(weak) id weakDataRef;
@property(assign) SCServiceOperationType operation;
@property(strong) NSError *lastError;
@property(strong) id reservedDataRef;

+ (id)callBackDataSetWithOperation:(SCServiceOperationType)opt;
+ (id)callBackDataSetWithOperation:(SCServiceOperationType)opt strongDataRef:(id)strongRef weakDataRef:(id)weakRef;

@end

