//
//  SNDownloadSettingTableViewCell.h
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDownloadSettingViewController.h"
#import "SNDBManager.h"
#import "SNTableViewCell.h"

@protocol SNDownloadSettingTableViewCellDelegate;

@interface SNDownloadSettingTableViewCell : SNTableViewCell {
    id __weak _delegate;
    id _data;
    UILabel *_titleLabel;
    UIButton *_checkMarkBtn;
}
@property(nonatomic, weak)id delegate;
@property(nonatomic, strong)id data;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UIButton *checkMarkBtn;
@property(nonatomic, assign)SNDownloadSettingCellOrder order;

- (void)reverseSelectedState;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegateParam;
@end

@protocol SNDownloadSettingTableViewCellDelegate
- (void)updateSectionHeaderTriggeredByCell:(SNDownloadSettingTableViewCell *)cell;
@end
