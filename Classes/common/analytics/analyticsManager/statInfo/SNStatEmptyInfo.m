//
//  SNStatEmptyInfo.m
//  sohunews
//
//  Created by jialei on 14-8-6.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNStatEmptyInfo.h"

@implementation SNStatEmptyInfo

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

//空广告stat传load
- (NSString *)statType {
    return @"load";
}

- (STADDisplayTrackType)adTrackType {
    return STADDisplayTrackTypeNullAD;
}

@end
