//
//  SNVideoDownloadTableViewCell.h
//  sohunews
//
//  Created by handy wang on 8/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ColorUtils.h"
#import "UIImageView+WebCache.h"
#import "SNVideoDownloadManager.h"
#import "SNWebImageView.h"

@class SNVideoDownloadTableViewController;

@interface SNVideoDownloadTableViewCell : UITableViewCell
@property (nonatomic, weak)SNVideoDownloadTableViewController *tableViewController;

@property (nonatomic, strong)SNVideoDataDownload    *model;
@property (nonatomic, strong)UILabel                *headlineLabel;
@property (nonatomic, strong)SNWebImageView         *thumnailImageView;
@property (nonatomic, strong)UIButton               *checkBox;

+ (CGFloat)heightForRow;

- (void)beginEdit;
- (void)finishEdit;
- (void)select;
- (void)deselect;
- (void)setData:(SNVideoDataDownload *)data;
- (void)tapCheckBox:(UIButton *)checkBox;
@end
