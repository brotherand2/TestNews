//
//  SNChannelSelectedLineView.m
//  sohunews
//
//  Created by HuangZhen on 2017/11/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNChannelSelectedLineView.h"
#import "SNTrainCellHelper.h"

@implementation SNChannelSelectedLineView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initMaskView];
    }
    return self;
}

- (void)initMaskView {
    if (!self.maskView) {
        self.maskView = [[UIView alloc] initWithFrame:self.bounds];
        self.maskView.backgroundColor = [SNTrainCellHelper newsTitleColor];
        [self addSubview:self.maskView];
        self.maskView.layer.masksToBounds = YES;
        self.maskView.layer.cornerRadius = self.height/4.f;
        self.maskView.alpha = 0.f;
    }
}

- (void)updateTheme {
    self.maskView.backgroundColor = [SNTrainCellHelper newsTitleColor];
}

@end
