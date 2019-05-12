//
//  SNVideoDownloadingViewController.m
//  sohunews
//
//  Created by handy wang on 8/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadingViewController.h"
#import "SNVideoDownloadingCell.h"

@implementation SNVideoDownloadingViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadData];
}

- (void)handle:(NSNotification *)notification {
}

#pragma mark - Override
#pragma mark - Invoked by SNDownloadViewController
- (void)reloadData {
    self.items = [[SNVideoDownloadManager sharedInstance] itemsForDownloadingView];
    [self.tableView reloadData];
    
    BOOL isEdit = NO;
    if ([self.delegate respondsToSelector:@selector(isEditMode)]) {
        isEdit = [self.delegate isEditMode];
    }

    if (self.items.count <= 0 && isEdit) {
        if ([self.delegate respondsToSelector:@selector(finishEdit)]) {
            [self.delegate finishEdit];
        }
    }
    
    [super reloadData];
}

- (void)reloadDataFromMem {
    [self.tableView reloadData];
    [super reloadData];
}

- (void)updateTheme {
    [super updateTheme];
    //TODO:.....
    [self reloadData];
}

- (void)beginEdit {
    [super beginEdit];
    //TODO:.....
}

- (void)finishEdit {
    [super finishEdit];
    //TODO:.....
}

#pragma mark - Called by super controller
- (void)recycleContent {
    [super recycleContent];
    //TODO:.....
}

#pragma mark - Delegates
#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *_cellIdentifier = @"CELL_INDENTIFIER";
    SNVideoDownloadingCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (!_cell) {
        _cell = [[SNVideoDownloadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
        _cell.tableViewController = self;
    }
    [_cell setData:[self.items objectAtIndex:indexPath.row]];
    return _cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(isEditMode)]) {
        if ([self.delegate isEditMode]) {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
            return;
        }
    }
    
    if (indexPath.row < self.items.count) {
        SNVideoDownloadingCell *cell = (SNVideoDownloadingCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell tap];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    SNDebugLog(@"===INFO: Cell end display....");
}

#pragma mark - SNVideoDownloadToolBarDelegate
- (void)selectAll {
    [super selectAll];
    //TODO:.....
}

- (void)deselectAll {
    [super deselectAll];
    //TODO:.....
}

- (void)deleteSelected {
    [super deleteSelected];
    //TODO:.....
}

- (void)cancelEdit {
    if ([self.delegate respondsToSelector:@selector(finishEdit)]) {
        [self.delegate finishEdit];
    }
    //TODO:.....
}

@end
