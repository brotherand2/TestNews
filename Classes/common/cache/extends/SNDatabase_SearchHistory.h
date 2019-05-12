//
//  SNDatabase_SearchHistory.h
//  sohunews
//
//  Created by chenhong on 13-4-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"

@class SearchHistoryItem;

@interface SNDatabase (SearchHistory)

// add
- (BOOL)addSearchHistoryItem:(SearchHistoryItem *)item;

// delete
- (BOOL)clearAllSearchHistoryItems;
- (BOOL)deleteSearchHistoryItem:(NSString *)word;
- (BOOL)deleteSearchHistoryItemsBefore:(SearchHistoryItem *)item;

// get
- (NSArray *)getSearchHistoryItems:(int)count;

@end
