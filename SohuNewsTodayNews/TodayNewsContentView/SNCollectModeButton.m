//
//  SNCollectModeButton.m
//  sohunews
//
//  Created by TengLi on 2017/9/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCollectModeButton.h"

#define kAddManually     @"保存方式: 手动"
#define kAddAuto         @"保存方式: 自动"

@implementation SNCollectModeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.collectMode = SNCollectModeNormal;
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self setTitleColor:[UIColor colorWithRed:(46.0/255.0) green:(46.0/255.0) blue:(46.0/255.0) alpha:1] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setCollectMode:(SNCollectModeType)collectMode {
    _collectMode = collectMode;
    switch (collectMode) {
        case SNCollectModeAuto:
            [self setTitle:kAddAuto forState:UIControlStateNormal];
            break;
        case SNCollectModeManually:
            [self setTitle:kAddManually forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

@end
