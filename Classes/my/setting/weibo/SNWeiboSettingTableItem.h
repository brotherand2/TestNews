//
//  SNWeiboSettingTableItem.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
@class SNWeiboSettingItem;
@class SNWeiboSettingController;
@interface SNWeiboSettingTableItem : TTTableControlItem {
	SNWeiboSettingItem	*__weak _weiboSettingItem;
	SNWeiboSettingController *__weak _controller;
}

@property(nonatomic,weak)SNWeiboSettingItem	*weiboSettingItem;
@property(nonatomic,weak)SNWeiboSettingController *controller;

@end
