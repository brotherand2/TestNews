//
//  SNStatExposureInfo.m
//  sohunews
//
//  Created by jialei on 14-7-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatExposureInfo.h"

@implementation SNStatExposureInfo

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)statType {
    return @"show";
}

- (STADDisplayTrackType)adTrackType {
    return STADDisplayTrackTypeImp;
}

@end
