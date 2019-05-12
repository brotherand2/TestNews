//
//  SNStatLoadInfo.m
//  sohunews
//
//  Created by jialei on 14-7-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatLoadInfo.h"

@implementation SNStatLoadInfo

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)statType {
    return @"load";
}

- (STADDisplayTrackType)adTrackType {
    return STADDisplayTrackTypeLoadImp;
}

@end
