//
//  SNAdImageTemplate.m
//  sohunews
//
//  Created by Xiang Wei Jia on 3/18/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAdImageTemplate.h"

@implementation SNAdImageTemplate

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_adImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
}

- (void)tap
{
    if (nil != self.clickBlock)
    {
        self.clickBlock(self, _adImage);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
