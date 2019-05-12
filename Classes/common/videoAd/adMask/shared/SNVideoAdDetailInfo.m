//
//  SNVideoAdDetailInfo.m
//  sohunews
//
//  Created by handy wang on 5/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNVideoAdDetailInfo.h"

@implementation SNVideoAdDetailInfo

- (NSString *)description {
    NSDictionary *desc = @{@"url":_url, @"isOpenInApp":@(_isOpenInApp)};
    return [desc description];
}

@end