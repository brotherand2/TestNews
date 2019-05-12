//
//  SNTableControlCell.m
//  sohunews
//
//  Created by Cong Dan on 5/8/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTableControlCell.h"
#import "UIColor+ColorUtils.h"

@implementation SNTableControlCell

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
    [UIView drawCellSeperateLine:rect];
	
}

@end
