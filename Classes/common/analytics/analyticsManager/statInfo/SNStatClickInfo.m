//
//  SNStatClickInfo.m
//  sohunews
//
//  Created by jialei on 14-7-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatClickInfo.h"

@implementation SNStatClickInfo

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)statType {
    return @"clk";
}

- (STADDisplayTrackType)adTrackType {
    return STADDisplayTrackTypeClick;
}

@end
