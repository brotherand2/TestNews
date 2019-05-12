//
//  SNCommenTableCell.m
//  sohunews
//
//  Created by Cong Dan on 5/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNCommenTableCell.h"

@implementation SNCommenTableCell

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[UIView drawCellSeperateLine:rect];
}

@end
