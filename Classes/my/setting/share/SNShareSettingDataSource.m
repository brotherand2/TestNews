//
//  SNShareSettingDataSource.m
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNShareSettingDataSource.h"
#import "SNShareSettingModel.h"
#import "SNShareSettingItem.h"
#import "SNShareSettingTableItem.h"
#import "SNShareSettingTableCell.h"


@implementation SNShareSettingDataSource
@synthesize weiboSettingModel=_weiboSettingModel;

-(SNShareSettingDataSource*)init{
	if (self = [super init]) {
		_weiboSettingModel = [[SNShareSettingModel alloc] init];
	}
	
	return self;
}

- (id<TTModel>)model {
	return _weiboSettingModel;
}

- (void)dealloc {
	 //(_weiboSettingModel);
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
	if ([object isKindOfClass:[SNShareSettingTableItem class]]) {
		return [SNShareSettingTableCell class];
	}
	return [super tableView:tableView cellClassForObject:object];	
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
	self.items = [NSMutableArray array];
	for (SNShareSettingItem *weiboItem in self.weiboSettingModel.shareSettingItems) {		
		UIButton *switchBtn	= [[UIButton alloc] init];
        SNShareSettingTableItem *tableItem	= [SNShareSettingTableItem itemWithCaption:@"" control:switchBtn];
		tableItem.shareSettingItem	= weiboItem;
		tableItem.controller		= self.weiboSettingModel.controller;
		if (tableItem) {
			[self.items addObject:tableItem];
		}
	}
}

@end
