//
//  SNBaseCommentCell.m
//  sohunews
//
//  Created by jialei on 14-8-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNBaseCommentCell.h"

@implementation SNBaseCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)setObject:(SNFloorCommentItem *)commentItem
{
    self.item = commentItem;
}

@end
