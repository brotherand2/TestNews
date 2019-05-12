//
//  SNReWangQiTableCell.h
//  sohunews
//
//  Created by wangjiangshan on 6/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheObjects.h"

@interface SNDownloadedTableViewCell : UITableViewCell {
    NewspaperItem *_newspaperItem;
    id             __weak _tableViewCellDelegate;
}

@property(nonatomic, strong)NewspaperItem *newspaperItem;
@property(nonatomic, weak) id            tableViewCellDelegate;

- (void)beginEditMode;

- (void)endEditMode;

- (void)selectIt;

- (void)deselectIt;

@end
