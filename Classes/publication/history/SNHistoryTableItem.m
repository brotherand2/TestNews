//
//  SNHistoryTableItem.m
//  sohunews
//
//  Created by wangxiang on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNHistoryTableItem.h"
#import "SNHistoryItem.h"

@interface SNHistoryTableItem (private) 
- (void)fillDataToTableItem;
@end


@implementation SNHistoryTableItem

@synthesize historyItem = _historyItem;
@synthesize historyModels =_historyModels;

- (void)dealloc {
	 //(_historyItem);
}

- (void)setWangqiItem:(SNHistoryItem *)newItem {
	if (_historyItem != newItem) {
		 //(_historyItem);
		_historyItem = newItem;
		[self fillDataToTableItem];
	}
}

- (void)fillDataToTableItem {
	self.text = _historyItem.termName;
//	self.URL = _wangqiItem.termLink;
    self.URL = [_historyItem realNewspaperPath];
}

@end

