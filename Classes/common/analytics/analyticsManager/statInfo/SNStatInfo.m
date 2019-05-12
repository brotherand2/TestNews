//
//  SNStatInfo.m
//  sohunews
//
//  Created by jialei on 14-7-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatInfo.h"

@implementation SNStatInfo

- (id)init {
    self = [super init];
    if (self) {
        self.token = @"";
        self.objType = @"";
        self.objFrom = @"";
        self.objFromId = @"";
        self.fromObjLabel = @"";
        _requestFilter = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)statType
{
    return nil;
}

@end
