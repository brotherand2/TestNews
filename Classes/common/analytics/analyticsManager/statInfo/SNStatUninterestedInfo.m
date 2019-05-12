//
//  SNStatUninterestedInfo.m
//  sohunews
//
//  Created by jialei on 14-7-31.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatUninterestedInfo.h"

@implementation SNStatUninterestedInfo

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)statType {
    return @"unintr";
}

- (STADDisplayTrackType)adTrackType {
    return STADDisplayTrackTypeNotInterest;
}

@end
