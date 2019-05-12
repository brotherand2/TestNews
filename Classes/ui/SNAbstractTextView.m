//
//  SNAbstractTextView.m
//  sohunews
//
//  Created by Gao Yongyue on 13-8-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNAbstractTextView.h"

@implementation SNAbstractTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
