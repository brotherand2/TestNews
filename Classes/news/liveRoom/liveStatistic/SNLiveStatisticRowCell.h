//
//  SNLiveStatisticRowCell.h
//  sohunews
//
//  Created by wang yanchen on 13-4-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewCell.h"

@interface SNLiveStatisticRowCell : SNTableViewCell

@property(nonatomic, strong) NSArray *rowDataArray;
@property(nonatomic, assign) BOOL isTitleColumn;

@end
