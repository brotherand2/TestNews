//
//  SNMyMessageTableCell.h
//  sohunews
//
//  Created by jialei on 13-7-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "Three20UI.h"
#import "SNLabel.h"

@class SNMyMessageItem;

@interface SNMyMessageTableCell : TTTableViewCell<SNLabelDelegate>
{
    SNMyMessageItem *item;
    BOOL    isMenuShow;    
    float   _originY;
}

@property(nonatomic, strong)SNMyMessageItem *item;
@property(nonatomic, weak)id delegateController;

+ (CGFloat)rowHeightForObject:(id)object;

@end
