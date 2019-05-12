//
//  SNVideoDownloadTableViewController.h
//  sohunews
//
//  Created by handy wang on 8/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideoDownloadToolBar.h"
#import "SNVideoDownloadViewController.h"
#import "SNVideoDownloadTableView.h"
#import "SNVideoDownloadTableViewCell.h"

@protocol SNVideoDownloadTableViewControllerDelegate
- (void)didFinishEdit;
- (void)enableOrDisableEditBtn;
- (SNVideoDownloadViewMode)currentViewMode;
- (BOOL)isEditMode;
@end

@interface SNVideoDownloadTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SNVideoDownloadToolBarDelegate>
@property (nonatomic, weak)id                         delegate;
@property (atomic, strong)NSMutableArray                *items;
@property (nonatomic, strong)SNVideoDownloadTableView   *tableView;

- (void)reloadData;
- (void)reloadDataFromMem;
- (void)updateTheme;
- (void)beginEdit;
- (void)finishEdit;
- (void)didTapCheckBoxInCell:(SNVideoDownloadTableViewCell *)cell;

///////////////////子类重写方法，非外部调用方法
- (void)recycleContent;
- (void)didEndDisplayingCell:(UITableViewCell *)cell;
@end
