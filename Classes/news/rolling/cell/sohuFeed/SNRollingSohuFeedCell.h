//
//  SNRollingSohuFeedCell.h
//  sohunews
//
//  Created by wangyy on 2017/5/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingBaseCell.h"
#import "SNSohuFeedCellContentView.h"

#define SOHUFEEDCELL_ITEM_HEIGHT 3

@interface SNRollingSohuFeedCell : SNRollingBaseCell

@property (nonatomic, strong) SNSohuFeedCellContentView *cellContentView;

- (void)updateContentView;
+ (CGFloat)feedLineSpace:(SNRollingNewsTableItem *)newsItem;

@end
