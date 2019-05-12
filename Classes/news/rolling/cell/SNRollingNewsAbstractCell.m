//
//  SNRollingNewsAbstractCell.m
//  sohunews
//
//  Created by lhp on 5/5/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingNewsAbstractCell.h"

#define kAbstractFont       (20/2)

@implementation SNRollingNewsAbstractCell

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    int cellHeight = [super tableView:tableView rowHeightForObject:object];
    return cellHeight;
}

+ (CGFloat)getAbstractWidth {
    int titleWidth = TTApplicationFrame().size.width - 2 * CONTENT_LEFT;
    return titleWidth;
}

- (void)updateNewsContent {
    [super updateNewsContent];
    self.cellContentView.abstractWidth = [[self class] getAbstractWidth];
    self.cellContentView.abstractHeight = self.item.abstractHeight;
    self.cellContentView.abstractAttStr = self.item.abstractString;
}

@end
