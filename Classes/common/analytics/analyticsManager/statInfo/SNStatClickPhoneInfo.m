//
//  SNStatClickPhoneInfo.m
//  sohunews
//
//  Created by 赵青 on 2017/5/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNStatClickPhoneInfo.h"

@implementation SNStatClickPhoneInfo

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
    return STADDisplayTrackTypeTelImp;
}

@end
