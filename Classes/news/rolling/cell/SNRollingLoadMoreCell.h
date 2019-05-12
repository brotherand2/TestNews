//
//  SNRollingLoadMoreCell.h
//  sohunews
//
//  Created by lhp on 8/5/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableSelectStyleCell2.h"
#import "SNRollingLoadMoreItem.h"

@interface SNRollingLoadMoreCell : SNTableSelectStyleCell2 {
    SNRollingLoadMoreItem *loadMoreItem;
}

@property (nonatomic, strong) SNRollingLoadMoreItem *loadMoreItem;

- (void)endLoadAnimation;

@end
