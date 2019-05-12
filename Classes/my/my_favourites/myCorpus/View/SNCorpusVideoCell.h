//
//  SNCorpusVideoCell.h
//  sohunews
//
//  Created by cuiliangliang on 16/5/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"

@interface SNCorpusVideoCell : SNTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDic:(NSDictionary*)newsItemDict;
- (void)setCellInfoWithDic:(NSDictionary*)newsItemDict isEditMode:(BOOL)isEditMode  isItemSelected:(BOOL)isItemSelected;

@end
