//
//  SNRollingNewsHistoryLineCell.h
//  sohunews
//
//  Created by wangyy on 2017/11/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNTableSelectStyleCell2.h"
#import "SNRollingNewsTableItem.h"

@interface SNRollingNewsHistoryLineCell : SNTableSelectStyleCell2

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) SNRollingNewsTableItem *newsItem;

@end
