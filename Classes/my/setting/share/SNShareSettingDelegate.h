//
//  SNShareSettingDelegate.h
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

@class SNShareSettingController;
@class SNShareSettingModel;
@interface SNShareSettingDelegate : TTTableViewDelegate {
	SNShareSettingController *__weak _weiboSettingController;
	SNShareSettingModel *_model;
}

@property(nonatomic,weak)SNShareSettingController *weiboSettingController;
@property(nonatomic,strong)SNShareSettingModel *model;

@end
