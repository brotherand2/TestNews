//
//  SNLiveDataSource.m
//  sohunews
//
//  Created by yanchen wang on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveDataSource.h"
#import "SNLiveTableItem.h"
#import "SNLiveFocusTableItem.h"
#import "SNLiveCategoryTableItem.h"
#import "SNLiveCell.h"
#import "SNLiveFocusCell.h"
#import "SNLiveCategoryCell.h"
//#import "SNRollingNewsTableController.h"
#import "SNTableMoreButton.h"

@implementation SNLiveDataSource

- (id)init {
    self = [super init];
    if (self) {
        _livingModel = [[SNLiveModel alloc] init];
    }
    return self;
}

- (id)initWithChannelID:(NSString *)channelID {
    self = [super init];
    if (self) {
        _livingModel = [[SNLiveModel alloc] initWithChannelID:channelID];
    }
    return self;
}

- (void)dealloc {
    self.livingModel = nil;
    self.focusGames = nil;
    self.todayGames = nil;
    
    self.categoryItems = nil;
    self.focusGames = nil;
    self.historyGames = nil;
    
}

#pragma mark - UITableViewDataSource
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"";
//}

#pragma mark - TTTableViewDataSource

- (id<TTModel>)model {
    return _livingModel;
}

//- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
//    
//}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object { 
    if ([object isKindOfClass:[SNLiveTableItem class]]) {
        return [SNLiveCell class];
    }
    else if ([object isKindOfClass:[SNLiveFocusTableItem class]]) {
        return [SNLiveFocusCell class];
    }
    else if ([object isKindOfClass:[SNLiveCategoryTableItem class]]) {
        return [SNLiveCategoryCell class];
    }
    else if ([object isKindOfClass:[TTTableMoreButton class]]) {
		return [SNTableAutoLoadMoreCell class];
	}
    return [super tableView:tableView cellClassForObject:object];
}

- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
    if ([object isKindOfClass:[SNLiveFocusTableItem class]]) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else if ([object isKindOfClass:[SNLiveCategoryTableItem class]]) {
        int section = (self.focusGames.count > 0 ? 1 : 0) +
        (self.todayGames.count > 0 ? 1 : 0);
        return [NSIndexPath indexPathForRow:0 inSection:section];
    }
    else if ([object isKindOfClass:[SNTableMoreButton class]]) {
        int section = (self.focusGames.count > 0 ? 1 : 0) +
        (self.todayGames.count > 0 ? 1 : 0) +
        (self.categoryItems.count > 0 ? 1 : 0) +
        (self.forecastGames.count > 0 ? 1 : 0);
        return [NSIndexPath indexPathForRow:0 inSection:section];
    }
    else {
        SNLiveTableItem *tableItem = object;
        if ([self.todayGames containsObject:tableItem]) {
            int section = self.focusGames.count > 0 ? 1 : 0;
            return [NSIndexPath indexPathForRow:[self.todayGames indexOfObject:tableItem] inSection:section];
        }
        else if ([self.forecastGames containsObject:tableItem]) {
            int section = (self.focusGames.count > 0 ? 1 : 0) +
            (self.todayGames.count > 0 ? 1 : 0) +
            (self.categoryItems.count > 0 ? 1 : 0);
            return [NSIndexPath indexPathForRow:[self.forecastGames indexOfObject:tableItem] inSection:section];
        }
        else if ([self.historyGames containsObject:tableItem]) {
            int section = (self.focusGames.count > 0 ? 1 : 0) +
            (self.todayGames.count > 0 ? 1 : 0) +
            (self.categoryItems.count > 0 ? 1 : 0) +
            (self.forecastGames.count > 0 ? 1 : 0);
            return [NSIndexPath indexPathForRow:[self.historyGames indexOfObject:tableItem] inSection:section];
        }
    }
    
    return nil;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
    if ([_livingModel.livingGamesToday count] +
        [_livingModel.livingGamesForecast count] +
        [_livingModel.livingCategoryArr count] +
        [_livingModel.livingGamesHistory count] <= 0) {
        return;
    }
    self.todayGames = [NSMutableArray array];
    self.focusGames = [NSMutableArray array];
    self.forecastGames = [NSMutableArray array];
    self.categoryItems = [NSMutableArray array];
    self.historyGames = [NSMutableArray array];
    
    SNLiveFocusTableItem *focusTableItem = [[SNLiveFocusTableItem alloc] init];
    focusTableItem.focusGameItems = [NSMutableArray array];
    
    NSMutableArray *sections = [NSMutableArray array];
    
    /*
    for (LivingGameItem *aGame in _livingModel.livingGamesToday) {
        if ([aGame.isFocus intValue] == 1) {
            [focusTableItem.focusGameItems addObject:aGame];
        }
        else {
            SNLiveTableItem *tableItem = [[SNLiveTableItem alloc] init];
            tableItem.gameItem = aGame;
            [self.todayGames addObject:tableItem];
            [tableItem release];
        }
    }
     */
    
    if (_livingModel.livingGameSectionCounts.count > 0) {
        
        __block NSInteger count = 0;
        [_livingModel.livingGameSectionCounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx == 0) {
                // 添加焦点 ？
                NSInteger focusCount = [obj integerValue];
                if (focusCount > 0) {
                    NSArray *focusArray = [_livingModel.livingGamesToday subarrayWithRange:NSMakeRange(0, focusCount)];
                    [focusTableItem.focusGameItems addObjectsFromArray:focusArray];
                    
                }
            } else {
                if ([_livingModel.livingGamesToday count] + 1 > [obj integerValue] && [_livingModel.livingGamesToday count] > 0) {
                    NSArray *everyArray = [_livingModel.livingGamesToday subarrayWithRange:NSMakeRange(count, [obj integerValue])];
                    
                    NSMutableArray *todayGamesArray = [[NSMutableArray alloc] init];
                    for (LivingGameItem *aGame in everyArray) {
                        SNLiveTableItem *tableItem = [[SNLiveTableItem alloc] init];
                        tableItem.gameItem = aGame;
                        [todayGamesArray addObject:tableItem];
                    }
                    
                    [self.todayGames addObject:todayGamesArray];
                }
            }
            
            count += [obj integerValue];
        }];
        
    }

    if ([focusTableItem.focusGameItems count] > 0) {
        [self.focusGames addObject:focusTableItem];
    }
    
    self.items = [NSMutableArray array];
    
    if ([self.focusGames count] > 0) {
        [sections addObject:@""];
        [self.items addObject:self.focusGames];
    }
    
    /*
    if ([self.todayGames count] > 0) {
        [sections addObject:@"今日直播"];
        [self.items addObject:self.todayGames];
    }
     */
    
    if (_todayGames.count > 0) {
        [self.items addObjectsFromArray:self.todayGames];
    }
    
    if (_livingModel.livingGameSectionTitles.count > 0) {
        [sections addObjectsFromArray:_livingModel.livingGameSectionTitles];
    }
    
    
    if (_livingModel.livingCategoryArr.count > 0) {
        [sections addObject:@"更多精彩"]; // 这还有 更多精彩 啊...

        SNLiveCategoryTableItem *tableItem = [[SNLiveCategoryTableItem alloc] init];
        tableItem.categoryItems = _livingModel.livingCategoryArr;
        [self.categoryItems addObject:tableItem];
        [self.items addObject:self.categoryItems];
    }

    /*
     * 预告不要了
     * v5.2.0
    for (LivingGameItem *aGame in _livingModel.livingGamesForecast) {
        SNLiveTableItem *tableItem = [[SNLiveTableItem alloc] init];
        tableItem.gameItem = aGame;
        [self.forecastGames addObject:tableItem];
        [tableItem release];
    }
    
    if ([self.forecastGames count] > 0) {
        [sections addObject:@"预告"];
        [self.items addObject:self.forecastGames];
    }
     */
    
    for (LivingGameItem *aGame in _livingModel.livingGamesHistory) {
        SNLiveTableItem *tableItem = [[SNLiveTableItem alloc] init];
        tableItem.gameItem = aGame;
        [self.historyGames addObject:tableItem];
    }
    
    
    if (!_livingModel.hasNoMore) {
        SNTableMoreButton *moreBtn = [SNTableMoreButton itemWithText:NSLocalizedString(@"Loading...", @"Loading...")];
        moreBtn.model = self.model;
        
        [self.historyGames addObject:moreBtn];
    }

    [sections addObject:@"往期"];
    
    [self.items addObject:self.historyGames];
    
    self.sections = [NSMutableArray arrayWithArray:sections];
    _livingModel.sectionsArray = self.sections;
    _livingModel.items = self.items;
}

- (UIImage*)imageForEmpty {
	return [UIImage imageNamed:@"tb_empty_bg.png"];
}

- (NSString*)titleForEmpty {
//	return NSLocalizedString(@"NoRollingNews", @"");
    return @"暂无直播";
}

- (NSString*)subtitleForEmpty {
	return NSLocalizedString(@"RefreshRollingNews", @"");
}

- (UIImage*)imageForError:(NSError*)error {
    return [UIImage imageNamed:@"tb_error_bg.png"];
}

- (NSString*)titleForError:(NSError*)error {
    //	return NSLocalizedString(@"NoRollingNews", @"");
    return nil;
}

- (NSString*)subtitleForError:(NSError*)error {
    //	return NSLocalizedString(@"RefreshRollingNews", @"");
    return nil;
}

@end
