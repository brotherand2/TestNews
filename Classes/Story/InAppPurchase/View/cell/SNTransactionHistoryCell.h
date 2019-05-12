//
//  SNTransactionHistoryCell.h
//  sohunews
//
//  Created by H on 2016/12/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTransactionHistoryItem.h"

@interface SNTransactionHistoryCell : UITableViewCell

- (void)layoutWithItem:(SNTransactionHistoryItem *)item;

@end
