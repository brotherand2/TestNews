//
//  SNRollingNewsRefreshCell.h
//  sohunews
//
//  Created by wangyy on 15/12/7.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNTableSelectStyleCell2.h"
#import "SNRollingNewsTableItem.h"

@interface SNRollingNewsRefreshCell : SNTableSelectStyleCell2
@property (nonatomic, strong) SNRollingNewsTableItem *refreshItem;
@end
