//
//  SNRollingAddStockCell.h
//  sohunews
//
//  Created by wangyy on 15/8/12.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingAddSubscribeCell.h"
#import "SNRollingNewsTableItem.h"

@interface SNRollingAddStockCell : SNTableSelectStyleCell2 {
    SNRollingNewsTableItem *stockItem;
}

@property (nonatomic, strong) SNRollingNewsTableItem *stockItem;

@end
