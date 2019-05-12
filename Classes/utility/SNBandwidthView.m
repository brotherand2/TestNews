//
//  SNBandwidthView.m
//  sohunews
//
//  Created by handy on 3/13/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNBandwidthView.h"

@implementation SNBandwidthView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.text = @"0.0K/S";
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.textColor = [UIColor greenColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont boldSystemFontOfSize:12];
    }
    return self;
}

@end
