//
//  SNAdImageUTextDTemplate.m
//  sohunews
//
//  Created by Xiang Wei Jia on 3/17/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAd12238Template.h"
#import "SNSkinManager.h"

@interface SNAd12238Template()

@end

@implementation SNAd12238Template

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    
    _adImage.layer.borderWidth = 1;
    _adImage.layer.borderColor = [UIColor whiteColor].CGColor;
    _adImage.backgroundColor = [UIColor grayColor];
}

- (void)tap:(UIGestureRecognizer *)gesture
{
    CGPoint pt = [gesture locationInView:_adText];
    
    if (nil != self.clickBlock)
    {
        self.clickBlock(self, CGRectContainsPoint(_adText.frame, pt) ? _adText : _adImage);
    }
    
    if (nil != self.userClick)
    {
        self.userClick(self, CGRectContainsPoint(_adText.frame, pt) ? _adText : _adImage);
    }
}

@end
