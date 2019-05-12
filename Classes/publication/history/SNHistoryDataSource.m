//
//  SNCgWangQiDataSource.m
//  sohunews
//
//  Created by wangxiang on 4/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNHistoryDataSource.h"
#import "SNDBManager.h"
#import "SNPushSettingTableItem.h"
#import "SNHistoryController.h"
#import "SNHistoryTableCell.h"
#import "SNHistoryTableItem.h"
#import "SNHistoryModel.h"
#import "SNHistoryItem.h"
#import "SNTableMoreButton.h"
#import "SNTableAutoLoadMoreCell.h"

@implementation SNHistoryDataSource
@synthesize modelHistory = _modelHistory;

-(id)init{
	if (self = [super init]) {
        SNHistoryModel *model = [[SNHistoryModel alloc] init];
        self.modelHistory = model;
         model = nil;
	}
	return self;
}

- (id<TTModel>)model {
    return _modelHistory;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView 
{
    self.items = [NSMutableArray array];
    for (SNHistoryItem *hisitem in _modelHistory.wangqiArray) {		
		SNHistoryTableItem *item = [[SNHistoryTableItem alloc] init];
		item.historyItem = hisitem;
        item.historyModels = (SNHistoryModel *)self.model;
		if (item) {
			[self.items addObject:item];
			 //(item);
		}
	}
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _modelHistory.controller.tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, 0.f, 0.f);
    }

    if (!_modelHistory.hasNoMore) {
        SNTableMoreButton *moreBtn = [SNTableMoreButton itemWithText:NSLocalizedString(@"Loading...", @"Loading...")];
        moreBtn.model = self.model;
        [self.items addObject:moreBtn];
    }
}

#pragma mark -
#pragma mark TTTableViewDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[SNHistoryTableItem class]]) {
		return [SNHistoryTableCell class];
	}
    else if ([object isKindOfClass:[TTTableMoreButton class]]) {
        return [SNTableAutoLoadMoreCell class];
    }
    
    return [super tableView:tableView cellClassForObject:object];	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (UITableViewCellEditingStyleDelete == editingStyle) {
		if (indexPath.row <= self.modelHistory.wangqiArray.count) {
			SNHistoryItem *item = [self.modelHistory.wangqiArray objectAtIndex:indexPath.row];
			[[SNDBManager currentDataBase] deleteNewspaperByTermId:item.termId deleteFromTable:YES];
			[self.modelHistory.wangqiArray removeObjectAtIndex:indexPath.row];
			[_modelHistory didChange];
            NSArray *downloadPapers = [[SNDBManager currentDataBase] getNewspaperDownloadedList];
            if (!downloadPapers.count) {
                _modelHistory.controller.navigationItem.rightBarButtonItem.enabled = NO;
                [_modelHistory.controller  showEmptyNewsBg];
            }
		}
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (MANAGEMENT_MODE_WANGQI == _modelHistory.controller.historyMode) {
		return NO;
	}
    return YES;
}


- (UIImage*)imageForEmpty {
	return [UIImage imageNamed:@"tb_no_history.png"];
}

- (NSString*)titleForEmpty {
	return nil;
}

- (NSString*)subtitleForEmpty {
//	return NSLocalizedString(@"SubmitAComment", @"Submit a comment");
    return nil;
}

- (UIImage*)imageForError:(NSError*)error {
	return [UIImage imageNamed:@"tb_error_bg.png"];
}

- (NSString*)titleForError:(NSError*)error {
    return nil;
}

- (NSString*)subtitleForError:(NSError*)error {
//	return NSLocalizedString(@"CheckNetwork", @"Check Network");
    return nil;
}




@end
