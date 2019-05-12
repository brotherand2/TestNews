//
//  SNWeiboDetailMoreCell.h
//  sohunews
//
//  Created by Chen Hong on 12-12-27.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSubCenterMoreCell.h"
#import "SNTimelineConfigs.h"

#define kMoreCellHeight                     (45)

@interface SNLiveLoadMoreCell : SNSubCenterMoreCell

@property (nonatomic, assign)SNMoreCellState state;

+ (CGFloat)height;

- (void)setHasNoMore:(BOOL)noMore;
- (void)setPromtLabelText:(NSString *) text;
- (void)setPromtLabelTextHide:(BOOL) hide;

@end
