//
//  SNLiveCategoryCell.h
//  sohunews
//
//  Created by chenhong on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNLiveCategoryTableItem;

@interface SNLiveCategoryCell : TTTableViewCell

@property(nonatomic, strong)SNLiveCategoryTableItem *liveItem;

+ (CGFloat)cellHeight:(NSArray *)categoryItems;

@end
