//
//  SNNovelEntranceView.h
//  sohunews
//
//  Created by qz on 14/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//


#import "SNRollingNewsTableController.h"

@interface SNNovelEntranceView : UIView

@property (nonatomic,strong) SNRollingNews *novelItem;

- (void)updateTheme;
+ (CGPoint)popOverPoint;
@end
