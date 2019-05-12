//
//  SNPushSettingSectionInfo.m
//  sohunews
//
//  Created by 李 雪 on 11-7-5.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPushSettingSectionInfo.h"

@implementation SNPushSettingSectionInfo
@synthesize name=_name;
@synthesize settingItems=_settingItems;

-(NSMutableArray*)settingItems
{
	if (_settingItems == nil) {
		_settingItems = [[NSMutableArray alloc] init];
	}
	
	return _settingItems;
}

-(void)dealloc
{
	 //(_name);
	 //(_settingItems);
	
}

@end
