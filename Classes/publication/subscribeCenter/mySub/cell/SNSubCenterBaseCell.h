//
//  SNSubCenterBaseCell.h
//  sohunews
//
//  Created by Chen Hong on 13-1-9.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "SNTableViewCell.h"

#define kSNSubCenterMyListCellNotifyUpdateTheme @"kSNSubCenterMyListCellNotifyUpdateTheme"

@interface SNSubCenterBaseCell : SNTableViewCell {
    UIImageView *_cellSelectedBg;
    NSString *_currentTheme;
    id _object;
}

@property(nonatomic,strong) id object;

- (BOOL)needsUpdateTheme;
-(void)updateTheme;

@end
