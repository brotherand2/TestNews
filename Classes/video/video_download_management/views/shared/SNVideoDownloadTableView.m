//
//  SNVideoDownloadTableView.m
//  sohunews
//
//  Created by handy wang on 8/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadTableView.h"
#import "SNVideoDownloadTableViewCell.h"
#import "SNVideoDownloadTableViewController.h"

@implementation SNVideoDownloadTableView

#pragma mark - Public
- (void)beginEdit {
    if ([self.dataSource isKindOfClass:[SNVideoDownloadTableViewController class]]) {
        SNVideoDownloadTableViewController *_tableViewController = (SNVideoDownloadTableViewController *)self.dataSource;
        for (SNVideoDataDownload *_model in _tableViewController.items) {
            _model.isSelected   = NO;
            _model.isEditing = YES;
        }
    }
    
    for (SNVideoDownloadTableViewCell *_visibleCell in self.visibleCells) {
        [_visibleCell beginEdit];
    }
}

- (void)finishEdit {
    if ([self.dataSource isKindOfClass:[SNVideoDownloadTableViewController class]]) {
        SNVideoDownloadTableViewController *_tableViewController = (SNVideoDownloadTableViewController *)self.dataSource;
        for (SNVideoDataDownload *_model in _tableViewController.items) {
            _model.isEditing    = NO;
            _model.isSelected   = NO;
        }
    }
    
    for (SNVideoDownloadTableViewCell *_visibleCell in self.visibleCells) {
        [_visibleCell finishEdit];
    }
}

- (void)selectAll {
    if ([self.dataSource isKindOfClass:[SNVideoDownloadTableViewController class]]) {
        SNVideoDownloadTableViewController *_tableViewController = (SNVideoDownloadTableViewController *)self.dataSource;
        for (SNVideoDataDownload *_model in _tableViewController.items) {
            _model.isSelected   = YES;
        }
        
        for (SNVideoDownloadTableViewCell *_visibleCell in self.visibleCells) {
            [_visibleCell select];
        }
    }
}

- (void)deselectAll {
    if ([self.dataSource isKindOfClass:[SNVideoDownloadTableViewController class]]) {
        SNVideoDownloadTableViewController *_tableViewController = (SNVideoDownloadTableViewController *)self.dataSource;
        for (SNVideoDataDownload *_model in _tableViewController.items) {
            _model.isSelected   = NO;
        }
        
        for (SNVideoDownloadTableViewCell *_visibleCell in self.visibleCells) {
            [_visibleCell deselect];
        }
    }
}

@end
