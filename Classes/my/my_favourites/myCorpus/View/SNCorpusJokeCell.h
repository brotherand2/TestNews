//
//  SNCorpusJokeCell.h
//  sohunews
//
//  Created by H on 16/5/10.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"
#import "SNRollingNewsTableItem.h"

@interface SNCorpusJokeCell : SNTableViewCell

@property (nonatomic, strong) SNRollingNewsTableItem * item;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSIndexPath * indexPath;
- (float)getCellHeight;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDic:(NSDictionary*)newsItemDict;
- (void)setCellInfoWithInfoDic:(NSDictionary *)info time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link isItemSelected:(BOOL)isItemSelected;
+ (float)getCellHeightWithDic:(NSDictionary*)newsItemDict;
@end
