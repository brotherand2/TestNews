//
//  SNWeiboSettingDataSource.m
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNWeiboSettingDataSource.h"
#import "SNWeiboSettingModel.h"
#import "SNWeiboSettingItem.h"
#import "SNWeiboSettingTableItem.h"
#import "SNWeiboSettingTableCell.h"


@implementation SNWeiboSettingDataSource
@synthesize weiboSettingModel=_weiboSettingModel;

-(SNWeiboSettingDataSource*)init{
	if (self = [super init]) {
		_weiboSettingModel = [[SNWeiboSettingModel alloc] init];
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
	if ([object isKindOfClass:[SNWeiboSettingTableItem class]]) {
		return [SNWeiboSettingTableCell class];
	}
	return [super tableView:tableView cellClassForObject:object];	
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
	self.items = [NSMutableArray array];
	for (SNWeiboSettingItem *weiboItem in self.weiboSettingModel.weiboSettingItems) {		
		UIButton *switchBtn	= [[UIButton alloc] init];
        SNWeiboSettingTableItem *tableItem	= [SNWeiboSettingTableItem itemWithCaption:@"" control:switchBtn];
		tableItem.weiboSettingItem	= weiboItem;
		tableItem.controller		= self.weiboSettingModel.controller;
		if (tableItem) {
			[self.items addObject:tableItem];
		}
	}
}

@end
