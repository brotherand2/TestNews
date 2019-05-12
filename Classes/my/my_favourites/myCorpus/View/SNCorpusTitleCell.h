//
//  SNCorpusTitleCell.h
//  sohunews
//
//  Created by Scarlett on 15/9/1.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"

@interface SNCorpusTitleCell : SNTableViewCell

- (void)setCellInfoWithTitle:(NSString *)title time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link isItemSelected:(BOOL)isItemSelected hideStateView:(BOOL)hide status:(NSString *)status remark:(NSString *)remark;
+ (CGFloat)getCellHeight:(NSString *)title;
@end
