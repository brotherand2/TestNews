//
//  SNTrainClickLabel.m
//  sohunews
//
//  Created by Huang Zhen on 2017/10/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNTrainClickLabel.h"
#import "SNTrainCellHelper.h"

@implementation SNTrainClickLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)click {
    if (self.clickBlock) {
        self.textColor = [SNTrainCellHelper newsWordClickedColour];
        self.clickBlock();
    }
}

@end
