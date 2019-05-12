//
//  SNTagLabel.m
//  sohunews
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNTagButton.h"

@implementation SNTagButton

@synthesize tagItem;

-(void)dealloc {
     //(tagItem);
}

- (CGFloat)tagWidth {
    CGSize size = [tagItem.tagName sizeWithFont:self.titleLabel.font];
    return self.titleEdgeInsets.left + size.width + self.titleEdgeInsets.right;
}

@end
