//
//  SNWeiboSettingModel.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

@class SNWeiboSettingController;
@interface SNWeiboSettingModel : TTModel {
	SNWeiboSettingController *__weak _controller;
	NSMutableArray			*_weiboSettingItems;
}

@property(nonatomic,weak)SNWeiboSettingController *controller;
@property(nonatomic,strong)NSMutableArray *weiboSettingItems;

@end
