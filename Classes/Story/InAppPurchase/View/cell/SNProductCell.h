//
//  SNProductCell.h
//  sohunews
//
//  Created by Huang Zhen on 2017/9/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNProductCell : UICollectionViewCell

/**
 购买的书币礼包id
 */
@property (nonatomic, copy) NSString * productId;

/**
 购买书币礼包的数量
 */
@property (nonatomic, assign) NSInteger quantity;

- (void)update:(NSDictionary *)updateInfo;

@end
