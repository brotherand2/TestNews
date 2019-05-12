//
//  SNRollingSubscribeBottomCell.m
//  sohunews
//
//  Created by lhp on 10/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingSubscribeBottomCell.h"
#define kSubscribeBottomCellHeight      (28 / 2)

@implementation SNRollingSubscribeBottomCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kSubscribeBottomCellHeight;
}


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
    }
    return self;
}

@end
