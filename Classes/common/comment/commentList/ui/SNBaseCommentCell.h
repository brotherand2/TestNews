//
//  SNBaseCommentCell.h
//  sohunews
//
//  Created by jialei on 14-8-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"
#import "SNFloorCommentItem.h"

@interface SNBaseCommentCell : SNTableViewCell

@property (nonatomic, strong)SNFloorCommentItem *item;
@property (nonatomic, strong)NSString *identifier;
@property (nonatomic, assign)int index;

- (void)setObject:(SNFloorCommentItem *)commentItem;

@end
