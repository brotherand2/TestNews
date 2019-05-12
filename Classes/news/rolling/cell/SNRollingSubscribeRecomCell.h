//
//  SNRollingSubscribeRecomCell.h
//  sohunews
//
//  Created by 赵青 on 15/12/2.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNTableSelectStyleCell2.h"
#import "SNRollingSubscribeRecomItem.h"

@protocol SNSubscribeEventDelegate <NSObject>
- (void)subscribeFinished:(BOOL)success;
@end

@interface SNRollingSubscribeRecomCell : SNTableSelectStyleCell2

@property (nonatomic, strong) SNRollingSubscribeRecomItem *subscribeRecomItem;
@property (nonatomic, weak) id <SNSubscribeEventDelegate> subscribeDelegate;

- (void)addFollowAction:(id)sender;

@end
