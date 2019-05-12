//
//  SNWeiboSettingDelegate.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

@class SNWeiboSettingController;
@class SNWeiboSettingModel;
@interface SNWeiboSettingDelegate : TTTableViewDelegate {
	SNWeiboSettingController *__weak _weiboSettingController;
	SNWeiboSettingModel *_model;
}

@property(nonatomic,weak)SNWeiboSettingController *weiboSettingController;
@property(nonatomic,strong)SNWeiboSettingModel *model;

@end
