//
//  SNADWebImageView.m
//  sohunews
//
//  Created by wangyy on 15/5/6.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNADWebImageView.h"

@implementation SNADWebImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setImage:(UIImage *)image {
    [super setImage:image];
    self.contentMode = UIViewContentModeScaleToFill;
}


@end
