//
//  SNCorpusPhotoAndTitleCell.h
//  sohunews
//
//  Created by Scarlett on 15/9/1.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"

@interface SNCorpusPhotoAndTitleCell : SNTableViewCell

- (void)setCellInfoWithUrl:(NSString *)url newsType:(NSString *)newsType title:(NSString *)title time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link hasTV:(BOOL)hasTV isItemSelected:(BOOL)isItemSelected hideStateView:(BOOL)hide status:(NSString *)status remark:(NSString *)remark;
+ (CGFloat)getCellHeight:(NSString *)title isEditMode:(BOOL)isEditMode;
@end
