//
//  SNRollingAddSubscribeCell.h
//  sohunews
//
//  Created by lhp on 10/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNTableSelectStyleCell2.h"
#import "SNRollingAddSubscribeItem.h"

@interface SNRollingAddSubscribeCell : SNTableSelectStyleCell2 {
    SNRollingAddSubscribeItem *subscribeItem;
}

@property (nonatomic, strong) SNRollingAddSubscribeItem *subscribeItem;

@end
