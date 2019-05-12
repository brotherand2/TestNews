//
//  SNStatPlayInfo.m
//  sohunews
//
//  Created by H on 15/8/12.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNStatPlayInfo.h"

@implementation SNStatPlayInfo

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)statType {
    return @"playing";
}

- (STADDisplayTrackType)adTrackType {
    return STADDisplayTrackTypePlaying;
}

@end
