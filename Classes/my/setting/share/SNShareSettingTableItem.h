//
//  SNShareSettingTableItem.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
@class SNShareSettingItem;
@class SNShareSettingController;
@interface SNShareSettingTableItem : TTTableControlItem {
	SNShareSettingItem	*__weak _shareSettingItem;
	SNShareSettingController *__weak _controller;
}

@property(nonatomic,weak)SNShareSettingItem	*shareSettingItem;
@property(nonatomic,weak)SNShareSettingController *controller;

@end
